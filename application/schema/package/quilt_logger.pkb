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
        l_msg    quilt_log.msg%Type;
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
            (sessionid, SID, runid, procedure_name, msg, insert_ts)
        VALUES
            (quilt_core.get_SESSIONID, quilt_core.get_SID, quilt_core.get_Runid, l_caller, l_msg, systimestamp);
        COMMIT;
    END log_detail;

END quilt_logger;
/
