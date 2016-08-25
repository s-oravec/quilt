CREATE OR REPLACE PACKAGE BODY quilt_log_pkg IS

    -- Private type declarations

    -- Private constant declarations

    -- Private variable declarations

    -- Function and procedure implementations
    PROCEDURE log_start
    (
        p_runid     IN NUMBER,
        p_test_name IN VARCHAR2
    ) IS
    
    BEGIN
    
        -- todo log
    
        INSERT INTO quilt_run
            (sessionid, SID, runid, start_ts, test_name)
        VALUES
            (quilt_core_pkg.get_SESSIONID, quilt_core_pkg.get_SID, p_runid, systimestamp, p_test_name);
    
        COMMIT;
    
    END log_start;

    PROCEDURE log_stop(p_runid IN NUMBER) IS
    
    BEGIN
    
        -- todo osetreni
        UPDATE quilt_run
           SET stop_ts = systimestamp
         WHERE sessionid = quilt_core_pkg.get_SESSIONID
           AND SID = quilt_core_pkg.get_SID
           AND runid = p_runid;
    
        COMMIT;
    END log_stop;

    PROCEDURE log_detail(p_msg IN VARCHAR2) IS
        lint_sessionid NUMBER := quilt_core_pkg.get_SESSIONID;
        lint_sid       NUMBER := quilt_core_pkg.get_SID;
        lint_runid     NUMBER := quilt_core_pkg.get_Runid;
    
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO quilt_log (sessionid, SID, runid, msg, insert_ts) VALUES (lint_sessionid, lint_sid, lint_runid, p_msg, systimestamp);
        COMMIT;
    END log_detail;

END quilt_log_pkg;
/
