CREATE OR REPLACE PACKAGE BODY quilt IS

    ------------------------------------------------------------------------
    FUNCTION begin_profiling(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) RETURN NUMBER IS
        l_runid NUMBER;
    BEGIN
        quilt_logger.log_detail('begin');
        -- start profilingu
        dbms_profiler.start_profiler(run_comment  => to_char(SYSDATE, quilt_const.DATE_TIME_FM),
                                     run_comment1 => p_test_name,
                                     run_number   => l_runid);
        -- zalogovat start profilingu
        quilt_logger.log_start(p_runid => l_runid, p_test_name => p_test_name);
        -- zapamatovat si v package context: runid
        quilt_core.set_Runid(l_runid);
        -- zapamatovat si v package context: test name
        quilt_core.set_TestName(p_test_name);
        quilt_logger.log_detail('end');
        --
        RETURN l_runid;
        --
    END begin_profiling;

    ------------------------------------------------------------------------
    PROCEDURE begin_profiling(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) IS
        l_runid NUMBER;
    BEGIN
        l_runid := begin_profiling(p_test_name => p_test_name);
    END begin_profiling;

    ------------------------------------------------------------------------
    PROCEDURE end_profiling IS
    BEGIN
        quilt_logger.log_detail('begin');
        -- stop profilingu
        dbms_profiler.stop_profiler;
        -- zalogovat stop profilingu
        quilt_logger.log_stop(quilt_core.get_Runid);
        quilt_logger.log_detail('end');
    END end_profiling;

    ------------------------------------------------------------------------
    PROCEDURE enable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2
    ) IS
    BEGIN
        quilt_logger.log_detail('begin:owner=$1,object_name=$2', OWNER, object_name);
        quilt_reported_objects.enable_report(OWNER, object_name);
        quilt_logger.log_detail('end');
    END enable_report;

    ------------------------------------------------------------------------
    PROCEDURE disable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2
    ) IS
    BEGIN
        quilt_logger.log_detail('begin:owner=$1,object_name=$2', OWNER, object_name);
        quilt_reported_objects.disable_report(OWNER, object_name);
        quilt_logger.log_detail('end');
    END disable_report;

    ------------------------------------------------------------------------
    FUNCTION display_lcov(runid IN NUMBER DEFAULT NULL) RETURN quilt_report
        PIPELINED IS
    BEGIN
        PIPE ROW(quilt_report_item('Not Implemented!'));
    END;

END quilt;
/
