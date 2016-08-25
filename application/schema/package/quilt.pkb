CREATE OR REPLACE PACKAGE BODY quilt IS

    ------------------------------------------------------------------------
    PROCEDURE spying_start(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) IS
        l_run_id NUMBER;
    BEGIN
        quilt_logger.log_detail('begin');
    
        -- start profilingu
        dbms_profiler.start_profiler(run_comment  => to_char(SYSDATE, quilt_const.DATE_TIME_FM),
                                     run_comment1 => p_test_name,
                                     run_number   => l_run_id);
    
        -- zalogovat start profilingu
        quilt_logger.log_start(p_runid => l_run_id, p_test_name => p_test_name);
    
        -- zapamatovat si v package context: runid
        quilt_core.set_Runid(l_run_id);
        -- zapamatovat si v package context: test name
        quilt_core.set_TestName(p_test_name);
    END spying_start;

    ------------------------------------------------------------------------
    PROCEDURE spying_end IS
    BEGIN
        quilt_logger.log_detail($$PLSQL_UNIT || '.spying_end');
    
        -- stop profilingu
        dbms_profiler.stop_profiler;
    
        -- zalogovat stop profilingu
        quilt_logger.log_stop(quilt_core.get_Runid);
    END spying_end;

END quilt;
/
