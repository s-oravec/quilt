CREATE OR REPLACE PACKAGE BODY quilt_util_cu AS

    ----------------------------------------------------------------------------
    FUNCTION getObjectList
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2 DEFAULT NULL,
        p_object_type IN VARCHAR2 DEFAULT NULL
    ) RETURN quilt_object_list_type IS
        ltab_result quilt_object_list_type;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1,p_object_name=$2,p_object_type=$3', p_owner, p_object_name, p_object_type);
        SELECT quilt_object_type(obj.OWNER, obj.object_name, obj.object_type)
          BULK COLLECT
          INTO ltab_result
          FROM all_objects obj
         WHERE OWNER = p_owner
           AND (p_object_name IS NULL OR object_name LIKE upper(p_object_name) ESCAPE '/')
           AND (p_object_type IS NULL OR object_type = p_object_type)
           AND object_type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                               quilt_const.OBJ_TYPE_TYPE_BODY,
                               quilt_const.OBJ_TYPE_PROCEDURE,
                               quilt_const.OBJ_TYPE_FUNCTION,
                               quilt_const.OBJ_TYPE_TRIGGER)
         ORDER BY obj.owner, obj.object_type, obj.object_name;
        RETURN ltab_result;
    END getObjectList;

    ----------------------------------------------------------------------------
    FUNCTION objectExists
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN BOOLEAN IS
        l_Result NUMBER;
    BEGIN
        SELECT Count(*)
          INTO l_Result
          FROM all_objects t
         WHERE t.owner = p_owner
           AND t.object_name = p_object_name
           AND t.object_type = p_object_type;
        --
        RETURN TRUE;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END objectExists;

    ----------------------------------------------------------------------------
    FUNCTION getPLSQLOptimizeLevel
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN BINARY_INTEGER IS
        l_Result NUMBER;
    BEGIN
        SELECT plsql_optimize_level
          INTO l_Result
          FROM all_plsql_object_settings t
         WHERE t.owner = p_owner
           AND t.name = p_object_name
           AND t.type = p_object_type
           AND t.type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                          quilt_const.OBJ_TYPE_TYPE_BODY,
                          quilt_const.OBJ_TYPE_PROCEDURE,
                          quilt_const.OBJ_TYPE_FUNCTION,
                          quilt_const.OBJ_TYPE_TRIGGER);
        --
        RETURN l_Result;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN l_Result;
    END getPLSQLOptimizeLevel;

    ----------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevelImpl
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN NUMBER DEFAULT PLSQL_OPTIMIZE_LEVEL_1
    ) IS
        lc_sqlTemplate CONSTANT VARCHAR2(128) := 'alter #objectType# #schemaName#.#objectName# #compile# PLSQL_OPTIMIZE_LEVEL=#level#';
        l_ObjectType VARCHAR2(30);
        l_compile    VARCHAR2(400);
        l_sql        VARCHAR2(4000);
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1, p_object_name=$2, p_object_type=$3, p_level=$4',
                                p_owner,
                                p_object_name,
                                p_object_type,
                                p_level);
        l_ObjectType := regexp_substr(upper(p_object_type), '[^ ]+', 1, 1);
        l_compile := CASE
                         WHEN regexp_substr(upper(p_object_type), '[^ ]+', 1, 2) = 'BODY' THEN
                          'COMPILE BODY'
                         ELSE
                          'COMPILE'
                     END;
        --
        l_sql := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lc_sqlTemplate, '#level#', p_level), '#objectType#', l_ObjectType),
                                         '#schemaName#',
                                         p_owner),
                                 '#objectName#',
                                 p_object_name),
                         '#compile#',
                         l_compile);
        quilt_logger.log_detail('l_sql', l_sql);
        --
        EXECUTE IMMEDIATE l_sql;
        quilt_logger.log_detail('end:$1 $2.$3 compiled with PLSQL_OPTIMIZE_LEVEL=$4', p_object_type, p_owner, p_object_name, p_level);
    END setPLSQLOptimizeLevelImpl;

    ---------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevel
    (
        p_objects IN quilt_object_list_type,
        p_level   IN NUMBER
    ) IS
        l_level NUMBER;
    BEGIN
        quilt_logger.log_detail('begin');
        BEGIN
            FOR idx IN 1 .. p_objects.count LOOP
                IF objectExists(p_objects(idx).owner, p_objects(idx).object_name, p_objects(idx).object_type) THEN
                    l_level := getPLSQLOptimizeLevel(p_objects(idx).owner, p_objects(idx).object_name, p_objects(idx).object_type);
                    IF NOT l_level = p_level THEN
                        setPLSQLOptimizeLevelImpl(p_owner       => p_objects(idx).owner,
                                                  p_object_name => p_objects(idx).object_name,
                                                  p_object_type => p_objects(idx).object_type,
                                                  p_level       => p_level);
                    ELSE
                        quilt_logger.log_detail('$1 $2.$3 already has level=$4',
                                                p_objects                     (idx).object_type,
                                                p_objects                     (idx).owner,
                                                p_objects                     (idx).object_name,
                                                l_level);
                    END IF;
                ELSE
                    quilt_logger.log_detail('Object $1 $2.$3 does not exist.',
                                            p_objects                       (idx).object_type,
                                            p_objects                       (idx).owner,
                                            p_objects                       (idx).object_name);
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
                -- todo spravne osetreni
                quilt_logger.log_detail('Unhandled exception:', substr(SQLERRM, 1, 2000));
        END;
        quilt_logger.log_detail('end');
    END setPLSQLOptimizeLevel;

    ----------------------------------------------------------------------------  
    PROCEDURE save_reported_object_source
    (
        p_quilt_run_id IN INTEGER,
        p_objects      IN quilt_object_list_type
    ) IS
        ltab_sources quilt_reported_objects.typ_source_tab;
    BEGIN
        SELECT s.*
          BULK COLLECT
          INTO ltab_sources
          FROM TABLE(p_objects) o
          JOIN all_source s ON (s.owner = o.owner AND s.name = o.object_name AND s.type = o.object_type)
         ORDER BY s.owner, s.name, s.type, s.line;
        quilt_reported_objects.save_source(p_quilt_run_id => p_quilt_run_id, p_sources => ltab_sources);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE save_profiler_data
    (
        p_quilt_run_id    IN INTEGER,
        p_profiler_run_id IN NUMBER
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_Data    quilt_util.typ_profiler_data_tab;
        l_Units   quilt_util.typ_profiler_units_tab;
        l_runs    quilt_util.typ_profiler_runs_tab;
        l_objects quilt_object_list_type;
    BEGIN
        --
        l_objects := quilt_reported_objects.get_reported_objects;
        --
        -- runs
        SELECT p_quilt_run_id, related_run, run_owner, run_date, run_comment, run_total_time, run_system_info, run_comment1
          BULK COLLECT
          INTO l_runs
          FROM plsql_profiler_runs
         WHERE runid = p_profiler_run_id;
        -- units
        SELECT p_quilt_run_id, unit_number, unit_type, unit_owner, unit_name, unit_timestamp, total_time
          BULK COLLECT
          INTO l_Units
          FROM TABLE(l_objects) obj
          JOIN plsql_profiler_units pu ON (pu.runid = p_profiler_run_id --
                                          AND pu.unit_owner = obj.owner --
                                          AND pu.unit_name = obj.object_name --
                                          AND decode(pu.unit_type, 'PACKAGE SPEC', 'PACAKGE', pu.unit_type) = obj.object_type);
        -- data
        SELECT p_quilt_run_id, pd.unit_number, pd.line#, pd.total_occur, pd.total_time, pd.min_time, pd.max_time
          BULK COLLECT
          INTO l_Data
          FROM TABLE(l_objects) obj
          JOIN plsql_profiler_units pu ON (pu.runid = p_profiler_run_id --
                                          AND pu.unit_owner = obj.owner --
                                          AND pu.unit_name = obj.object_name --
                                          AND decode(pu.unit_type, 'PACKAGE SPEC', 'PACAKGE', pu.unit_type) = obj.object_type)
          JOIN plsql_profiler_data pd ON (pd.runid = pu.runid --
                                         AND pd.unit_number = pu.unit_number)
        -- needs very thorough parsing of code - maybe later                                         
        -- WHERE NOT (pd.total_time = 0 AND total_occur = 0)
        ;
        -- save
        quilt_util.save_profiler_runs(l_runs);
        quilt_util.save_profiler_units(l_Units);
        quilt_util.save_profiler_data(l_Data);
        --
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;

END;
/
