CREATE OR REPLACE PACKAGE BODY quilt AS

    g_quilt_run_id    quilt_run.quilt_run_id%Type;
    g_profiler_run_id quilt_run.profiler_run_id%Type;

    ----------------------------------------------------------------------------
    PROCEDURE exec_ddl(p_ddl IN VARCHAR2) IS
        e_name_alerady_used EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_name_alerady_used, -955);
        e_pkey_exists EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_pkey_exists, -2260);
        e_fkey_exists EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_fkey_exists, -2275);
    BEGIN
        EXECUTE IMMEDIATE p_ddl;
    EXCEPTION
        WHEN e_name_alerady_used THEN
            NULL;
        WHEN e_fkey_exists THEN
            NULL;
        WHEN e_pkey_exists THEN
            NULL;
        WHEN OTHERS THEN
            RAISE;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE ensure_profiler_objects_exist IS
    BEGIN
        -- NoFormat Start
        -- Sequence
        exec_ddl(
            'create sequence PLSQL_PROFILER_RUNNUMBER' || chr(10) ||
            '  minvalue 1 maxvalue 9999999999999999999999999999' || chr(10) ||
            '  start with 1 increment by 1 nocache'
        );
        -- Profiler runs
        exec_ddl(
            'create table PLSQL_PROFILER_RUNS' || chr(10) ||
            '(' || chr(10) ||
            '  runid           NUMBER not null,' || chr(10) ||
            '  related_run     NUMBER,' || chr(10) ||
            '  run_owner       VARCHAR2(32),' || chr(10) ||
            '  run_date        DATE,' || chr(10) ||
            '  run_comment     VARCHAR2(2047),' || chr(10) ||
            '  run_total_time  NUMBER,' || chr(10) ||
            '  run_system_info VARCHAR2(2047),' || chr(10) ||
            '  run_comment1    VARCHAR2(2047),' || chr(10) ||
            '  spare1          VARCHAR2(256)' || chr(10) ||
            ')'
        );
        exec_ddl('comment on table PLSQL_PROFILER_RUNS is ''Run-specific information for the PL/SQL profiler''');
        exec_ddl('alter table PLSQL_PROFILER_RUNS add primary key (RUNID)');
        -- Profiler Units
        exec_ddl(
            'create table PLSQL_PROFILER_UNITS' || chr(10) ||
            '(' || chr(10) ||
            '  runid          NUMBER not null,' || chr(10) ||
            '  unit_number    NUMBER not null,' || chr(10) ||
            '  unit_type      VARCHAR2(32),' || chr(10) ||
            '  unit_owner     VARCHAR2(32),' || chr(10) ||
            '  unit_name      VARCHAR2(32),' || chr(10) ||
            '  unit_timestamp DATE,' || chr(10) ||
            '  total_time     NUMBER default 0 not null,' || chr(10) ||
            '  spare1         NUMBER,' || chr(10) ||
            '  spare2         NUMBER' || chr(10) ||
            ')'
        );
        exec_ddl('comment on table PLSQL_PROFILER_UNITS is ''Information about each library unit in a run''');
        exec_ddl('alter table PLSQL_PROFILER_UNITS add primary key (RUNID, UNIT_NUMBER)');
        exec_ddl('alter table PLSQL_PROFILER_UNITS add foreign key (RUNID) references PLSQL_PROFILER_RUNS (RUNID)');
        -- Profiler Data
        exec_ddl(
            'create table PLSQL_PROFILER_DATA' || chr(10) ||
            '(' || chr(10) ||
            '  runid       NUMBER not null,' || chr(10) ||
            '  unit_number NUMBER not null,' || chr(10) ||
            '  line#       NUMBER not null,' || chr(10) ||
            '  total_occur NUMBER,' || chr(10) ||
            '  total_time  NUMBER,' || chr(10) ||
            '  min_time    NUMBER,' || chr(10) ||
            '  max_time    NUMBER,' || chr(10) ||
            '  spare1      NUMBER,' || chr(10) ||
            '  spare2      NUMBER,' || chr(10) ||
            '  spare3      NUMBER,' || chr(10) ||
            '  spare4      NUMBER' || chr(10) ||
            ')'
        );
        exec_ddl('comment on table PLSQL_PROFILER_DATA  is ''Accumulated data from all profiler runs''');
        exec_ddl('alter table PLSQL_PROFILER_DATA add primary key (RUNID, UNIT_NUMBER, LINE#)');
        exec_ddl('alter table PLSQL_PROFILER_DATA add foreign key (RUNID, UNIT_NUMBER) references PLSQL_PROFILER_UNITS (RUNID, UNIT_NUMBER)');
        -- NoFormat End
    END ensure_profiler_objects_exist;

    -- TODO: this is really ugly - rewrite
    ----------------------------------------------------------------------------
    PROCEDURE check_create_privilege
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2,
        object_type IN VARCHAR2
    ) IS
    
        ltab_objects quilt_object_list_type;
    
        ----------------------------------------------------------------------------
        PROCEDURE has_privilege(p_object_type IN VARCHAR2) IS
            l_privilege session_privs.privilege%Type;
            CURSOR lcrs_privilege(p_privilege IN session_privs.privilege%Type) IS
                SELECT * FROM session_privs WHERE privilege = p_privilege;
            lrec_privilege session_privs%ROWTYPE;
        BEGIN
            CASE
                WHEN p_object_type IN (quilt_const.OBJ_TYPE_FUNCTION, quilt_const.OBJ_TYPE_PACKAGE_BODY, quilt_const.OBJ_TYPE_PROCEDURE) THEN
                    l_privilege := 'CREATE ANY PROCEDURE';
                WHEN p_object_type = quilt_const.OBJ_TYPE_TRIGGER THEN
                    l_privilege := 'CREATE ANY TRIGGER';
                WHEN p_object_type = quilt_const.OBJ_TYPE_TYPE_BODY THEN
                    l_privilege := 'CREATE ANY TYPE';
                ELSE
                    raise_application_error(-20000, 'Unexpected object_type=' || p_object_type);
            END CASE;
            OPEN lcrs_privilege(l_privilege);
            FETCH lcrs_privilege
                INTO lrec_privilege;
            CLOSE lcrs_privilege;
            IF lrec_privilege.privilege IS NULL THEN
                raise_application_error(-20000,
                                        quilt_util.formatString('User $1 has be either owner of $2 $3.$4 object(s) or it has to have $5 privilege',
                                                                sys_context('USERENV', 'CURRENT_USER'),
                                                                p_object_type,
                                                                OWNER,
                                                                object_name,
                                                                l_privilege));
            END IF;
        END;
    
    BEGIN
        -- current_user is either owner of objects
        IF OWNER IS NOT NULL AND OWNER = sys_context('USERENV', 'CURRENT_USER') THEN
            RETURN;
        ELSIF object_type IS NOT NULL THEN
            -- or if object_type is specified than has CREATE ANY privilege
            has_privilege(object_type);
        ELSE
            -- "unwind" list of objects specified by like expression
            -- check create privilege for each object
            ltab_objects := quilt_util_cu.getObjectList(OWNER, object_name, object_type);
            FOR objType IN (SELECT DISTINCT object_type FROM TABLE(ltab_objects)) LOOP
                has_privilege(objType.object_type);
            END LOOP;
        END IF;
    END;

    ------------------------------------------------------------------------
    PROCEDURE enable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2,
        object_type IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        quilt_logger.log_detail('begin:owner=$1,object_name=$2,object_type=$3', OWNER, object_name, object_type);
        check_create_privilege(OWNER, object_name, object_type);
        quilt_reported_objects.enable_report(quilt_util_cu.getObjectList(OWNER, object_name, object_type));
        quilt_logger.log_detail('end');
    END enable_report;

    ------------------------------------------------------------------------
    PROCEDURE disable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2,
        object_type IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        quilt_logger.log_detail('begin:owner=$1,object_name=$2,object_type=$3', OWNER, object_name, object_type);
        check_create_privilege(OWNER, object_name, object_type);
        quilt_reported_objects.disable_report(quilt_util_cu.getObjectList(OWNER, object_name, object_type));
        quilt_logger.log_detail('end');
    END disable_report;

    ------------------------------------------------------------------------
    FUNCTION start_profiling(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) RETURN NUMBER IS
    BEGIN
        quilt_logger.log_detail('begin');
        --
        ensure_profiler_objects_exist;
        --
        g_quilt_run_id := quilt_util.next_run_id;
        quilt_logger.log_start(p_quilt_run_id => g_quilt_run_id, p_test_name => p_test_name);
        -- save sources
        quilt_util_cu.save_reported_object_source(p_quilt_run_id => g_quilt_run_id,
                                                  p_objects      => quilt_reported_objects.get_reported_objects);
        -- start DBMS_PROFILER
        dbms_profiler.start_profiler(run_comment  => to_char(SYSDATE, quilt_const.DATE_TIME_FM),
                                     run_comment1 => p_test_name,
                                     run_number   => g_profiler_run_id);
        -- log start DBMS_PROFILER profiling
        quilt_logger.log_profiler_run_id(p_quilt_run_id    => g_quilt_run_id,
                                         p_profiler_run_id => g_profiler_run_id,
                                         p_profiler_user   => sys_context('USERENV', 'CURRENT_USER'));
        -- zapamatovat si v package context: test name
        quilt_logger.log_detail('end');
        --
        RETURN g_quilt_run_id;
        --
    END start_profiling;

    ------------------------------------------------------------------------
    PROCEDURE start_profiling(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) IS
        l_runid NUMBER;
    BEGIN
        l_runid := start_profiling(p_test_name => p_test_name);
    END start_profiling;

    ------------------------------------------------------------------------
    PROCEDURE stop_profiling IS
    BEGIN
        quilt_logger.log_detail('begin');
        -- stop profilingu
        dbms_profiler.stop_profiler;
        -- zalogovat stop profilingu
        quilt_logger.log_stop(p_quilt_run_id => g_quilt_run_id);
        quilt_logger.log_detail('end');
    END stop_profiling;

    ------------------------------------------------------------------------
    FUNCTION display_lcov(runid IN NUMBER DEFAULT NULL) RETURN quilt_report
        PIPELINED IS
    BEGIN
        PIPE ROW(quilt_report_item('Not Implemented!'));
        RETURN;
    END;

    ----------------------------------------------------------------------------
    -- TODO: move to view
    FUNCTION reported_objects RETURN quilt_object_list_type
        PIPELINED IS
        ltab_objects quilt_object_list_type;
    BEGIN
        ltab_objects := quilt_reported_objects.get_reported_objects;
        FOR idx IN 1 .. ltab_objects.count LOOP
            PIPE ROW(ltab_objects(idx));
        END LOOP;
        RETURN;
    END;

END quilt;
/
