CREATE OR REPLACE PACKAGE BODY quilt_logger IS

    g_quilt_run_id quilt_run.quilt_run_id%Type;

    ----------------------------------------------------------------------------
    PROCEDURE log_start
    (
        p_quilt_run_id IN INTEGER,
        p_test_name    IN VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        log_detail('starting quilt with p_quilt_run_id=$1, test_name=$2', p_quilt_run_id, p_test_name);
        g_quilt_run_id := p_quilt_run_id;
        INSERT INTO quilt_run (quilt_run_id, start_ts, test_name) VALUES (p_quilt_run_id, systimestamp, p_test_name);
        COMMIT;
    END log_start;

    ----------------------------------------------------------------------------
    PROCEDURE log_profiler_run_id
    (
        p_quilt_run_id    IN INTEGER,
        p_profiler_run_id IN NUMBER,
        p_profiler_user   IN VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        log_detail('stopping quilt with quilt_run_id=$1', p_quilt_run_id);
        UPDATE quilt_run SET profiler_run_id = p_profiler_run_id, profiler_user = p_profiler_user WHERE quilt_run_id = p_quilt_run_id;
        COMMIT;
    END log_profiler_run_id;

    ----------------------------------------------------------------------------
    PROCEDURE log_stop(p_quilt_run_id IN INTEGER) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        log_detail('stopping quilt with quilt_run_id=$1', p_quilt_run_id);
        UPDATE quilt_run SET stop_ts = systimestamp WHERE quilt_run_id = p_quilt_run_id;
        COMMIT;
    END log_stop;

    ----------------------------------------------------------------------------
    PROCEDURE log_detail
    (
        p_msg           IN VARCHAR2,
        p_placeholder1  IN VARCHAR2 DEFAULT NULL,
        p_placeholder2  IN VARCHAR2 DEFAULT NULL,
        p_placeholder3  IN VARCHAR2 DEFAULT NULL,
        p_placeholder4  IN VARCHAR2 DEFAULT NULL,
        p_placeholder5  IN VARCHAR2 DEFAULT NULL,
        p_placeholder6  IN VARCHAR2 DEFAULT NULL,
        p_placeholder7  IN VARCHAR2 DEFAULT NULL,
        p_placeholder8  IN VARCHAR2 DEFAULT NULL,
        p_placeholder9  IN VARCHAR2 DEFAULT NULL,
        p_placeholder10 IN VARCHAR2 DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_caller VARCHAR2(255);
        l_msg    VARCHAR2(32767);
    BEGIN
        l_caller := quilt_util.getCallerQualifiedName;
        l_msg    := quilt_util.formatString(p_msg,
                                            p_placeholder1,
                                            p_placeholder2,
                                            p_placeholder3,
                                            p_placeholder4,
                                            p_placeholder5,
                                            p_placeholder6,
                                            p_placeholder7,
                                            p_placeholder8,
                                            p_placeholder9,
                                            p_placeholder10);
        --    
        INSERT INTO quilt_log
            (log_id, quilt_run_id, procedure_name, msg, insert_ts)
        VALUES
            (quilt_log_id.nextval, g_quilt_run_id, l_caller, l_msg, systimestamp);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('quilt_logger.log_detail failed: ' || SQLERRM);
            dbms_output.put_line('l_caller' || substr(l_caller, 1, 50));
            dbms_output.put_line('l_msg' || substr(l_msg, 1, 50));
    END log_detail;

END quilt_logger;
/
