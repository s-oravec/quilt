CREATE OR REPLACE PACKAGE BODY quilt_core_pkg IS

    -- Private type declarations

    -- Private constant declarations

    -- Private variable declarations

    /** global variable for RUNID */
    gint_runid NUMBER;
    /** global variable for SID from session */
    gint_sid NUMBER;
    /** global variable for SESSIONID from session */
    gint_sessionid NUMBER;
    /** global variable for test name */
    gstr_testname VARCHAR2(2000);

    -- Function and procedure implementations

    /** set RUNID */
    PROCEDURE set_Runid(p_runid IN NUMBER) IS
    
    BEGIN
        -- ?todo log provolani?
        gint_runid := p_runid;
    END set_Runid;

    /** get RUNID */
    FUNCTION get_Runid RETURN NUMBER IS
    BEGIN
        -- ?todo log provolani?
        RETURN gint_runid;
    END get_Runid;

    /** get SID */
    FUNCTION get_SID RETURN NUMBER IS
    BEGIN
        -- ?todo log provolani?
        RETURN gint_sid;
    END get_SID;

    /** get SESSIONID */
    FUNCTION get_SESSIONID RETURN NUMBER IS
    BEGIN
        -- ?todo log provolani?
        RETURN gint_sessionid;
    END get_SESSIONID;

    /** inicialization from session */
    PROCEDURE init IS
    BEGIN
        -- ?todo log provolani?
        SELECT sys_context('USERENV', 'SID'), sys_context('USERENV', 'SESSIONID') INTO gint_sid, gint_sessionid FROM dual;
    END init;

    /** set test name */
    PROCEDURE set_TestName(p_testname IN VARCHAR2) IS
    
    BEGIN
        -- ?todo log provolani?
        gstr_testname := substr(p_testname, 1, quilt_const_pkg.TEST_NAME_MAX_LEN);
    END set_TestName;

    /** get test name */
    FUNCTION get_TestName RETURN VARCHAR2 IS
    
    BEGIN
        --?todo log provolani?
        RETURN gstr_testname;
    END get_TestName;

BEGIN
    -- Initialization
    init;

END quilt_core_pkg;
/
