CREATE OR REPLACE PACKAGE BODY quilt_util_cu AS

    ----------------------------------------------------------------------------
    FUNCTION getObject
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2
    ) RETURN quilt_object_type IS
        lobj_result quilt_object_type;
    BEGIN
        quilt_logger.log_detail('begin: p_owner=$1, p_object_name=$2', p_owner, p_object_name);
        --
        BEGIN
            SELECT quilt_object_type(OWNER, object_name, object_type)
              INTO lobj_result
              FROM all_objects
             WHERE OWNER LIKE '%' || upper(p_owner) || '%'
               AND object_name LIKE '%' || upper(p_object_name) || '%';
        EXCEPTION
            WHEN no_data_found THEN
                quilt_logger.log_detail('not found');
                lobj_result := NULL;
        END;
        --    
        quilt_logger.log_detail('end');
        RETURN lobj_result;
        --
    END getObject;

    ----------------------------------------------------------------------------
    FUNCTION getObjectList
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN quilt_object_list_type IS
        ltab_result quilt_object_list_type;
    BEGIN
        SELECT quilt_object_type(obj.OWNER, obj.object_name, obj.object_type)
          BULK COLLECT
          INTO ltab_result
          FROM all_objects obj
         WHERE OWNER LIKE upper(p_owner) ESCAPE '/'
           AND object_name LIKE upper(p_object_name) ESCAPE '/'
           AND (p_object_type IS NULL OR object_type = p_object_type)
           AND object_type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                               quilt_const.OBJ_TYPE_TYPE_BODY,
                               quilt_const.OBJ_TYPE_PROCEDURE,
                               quilt_const.OBJ_TYPE_FUNCTION,
                               quilt_const.OBJ_TYPE_TRIGGER);
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

    ----------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevel
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN NUMBER
    ) IS
        ltab_objects quilt_object_list_type;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1, p_object_name=$2, p_level=$3', p_owner, p_object_name, p_level);
        -- check level first
        IF p_level IN (PLSQL_OPTIMIZE_LEVEL_0, PLSQL_OPTIMIZE_LEVEL_1, PLSQL_OPTIMIZE_LEVEL_2, PLSQL_OPTIMIZE_LEVEL_3) THEN
            -- get both header/spec in case of package/type
            ltab_objects := getObjectList(p_owner, p_object_name, p_object_type);
            FOR obj IN (SELECT * FROM TABLE(ltab_objects)) LOOP
                IF obj.object_type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                                       quilt_const.OBJ_TYPE_TYPE_BODY,
                                       quilt_const.OBJ_TYPE_PROCEDURE,
                                       quilt_const.OBJ_TYPE_FUNCTION,
                                       quilt_const.OBJ_TYPE_TRIGGER) THEN
                    setPLSQLOptimizeLevelImpl(p_owner       => obj.owner,
                                              p_object_name => obj.object_name,
                                              p_object_type => obj.object_type,
                                              p_level       => p_level);
                ELSE
                    -- NoFormat Start
                    raise_application_error(-20000,
                                            quilt_util.formatString('$1 $2.$3 is not PLSQL object. Cannot set PLSQL Optimize level',
                                                         obj.object_type,
                                                         obj.owner,
                                                         obj.object_name)
                                           );
                    -- NoFormat End
                END IF;
            END LOOP;
        ELSE
            raise_application_error(-20000, 'Unsupported PLSQL Optimize level: ' || p_level);
        END IF;
        quilt_logger.log_detail('end');
    END setPLSQLOptimizeLevel;

    ---------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevelAll(p_level IN NUMBER) IS
        l_level NUMBER;
    BEGIN
        quilt_logger.log_detail('begin');
        BEGIN
            FOR reportedObject IN (SELECT * FROM quilt_reported_object t) LOOP
                IF objectExists(reportedObject.owner, reportedObject.object_name, reportedObject.object_type) THEN
                    l_level := getPLSQLOptimizeLevel(reportedObject.owner, reportedObject.object_name, reportedObject.object_type);
                    IF NOT l_level = p_level THEN
                        setPLSQLOptimizeLevelImpl(p_owner       => reportedObject.owner,
                                                  p_object_name => reportedObject.object_name,
                                                  p_object_type => reportedObject.object_type,
                                                  p_level       => p_level);
                    ELSE
                        quilt_logger.log_detail('$1 $2.$3 already has level=$4',
                                                reportedObject.object_type,
                                                reportedObject.owner,
                                                reportedObject.object_name,
                                                l_level);
                    END IF;
                ELSE
                    quilt_logger.log_detail('Object $1 $2.$3 does not exist.',
                                            reportedObject.object_type,
                                            reportedObject.owner,
                                            reportedObject.object_name);
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
                -- todo spravne osetreni
                quilt_logger.log_detail('Unhandled exception:', substr(SQLERRM, 1, 2000));
        END;
        quilt_logger.log_detail('end');
    END setPLSQLOptimizeLevelAll;

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

END;
/
