CREATE OR REPLACE PACKAGE BODY quilt_logger IS

    ----------------------------------------------------------------------------
    PROCEDURE log_start
    (
        p_runid     IN NUMBER,
        p_test_name IN VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        log_detail('starting quilt with runid: ' || p_runid || ', test_name: ' || p_test_name);
        INSERT INTO quilt_run
            (sessionid, SID, runid, start_ts, test_name)
        VALUES
            (quilt_core.get_SESSIONID, quilt_core.get_SID, p_runid, systimestamp, p_test_name);
        COMMIT;
    END log_start;

    ----------------------------------------------------------------------------
    PROCEDURE log_stop(p_runid IN NUMBER) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- TODO: Henry?
        -- todo osetreni
        log_detail('stopping quilt with runid: ' || p_runid);
        UPDATE quilt_run
           SET stop_ts = systimestamp
         WHERE sessionid = quilt_core.get_SESSIONID
           AND SID = quilt_core.get_SID
           AND runid = p_runid;
        COMMIT;
    END log_stop;

    ----------------------------------------------------------------------------
    PROCEDURE log_detail(p_msg IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_caller VARCHAR2(255);
    BEGIN
        l_caller := quilt_util.getCallerQualifiedName;
        INSERT INTO quilt_log
            (sessionid, SID, runid, procedure_name, msg, insert_ts)
        VALUES
            (quilt_core.get_SESSIONID, quilt_core.get_SID, quilt_core.get_Runid, l_caller, p_msg, systimestamp);
        COMMIT;
    END log_detail;

END quilt_logger;
/
