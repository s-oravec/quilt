CREATE OR REPLACE PACKAGE BODY quilt_core IS

    /** global variable for RUNID */
    gint_runid NUMBER;
    /** global variable for test name */
    gstr_testname VARCHAR2(2000);

    ----------------------------------------------------------------------------
    PROCEDURE set_Runid(p_runid IN NUMBER) IS
    BEGIN
        quilt_logger.log_detail('begin');
        gint_runid := p_runid;
    END set_Runid;

    ----------------------------------------------------------------------------
    FUNCTION get_runId RETURN NUMBER IS
    BEGIN
        RETURN gint_runid;
    END get_Runid;

    ----------------------------------------------------------------------------
    FUNCTION get_SID RETURN NUMBER IS
    BEGIN
        RETURN sys_context('USERENV', 'SID');
    END get_SID;

    ----------------------------------------------------------------------------
    FUNCTION get_SESSIONID RETURN NUMBER IS
    BEGIN
        RETURN sys_context('USERENV', 'SESSIONID');
    END get_SESSIONID;

    ----------------------------------------------------------------------------
    PROCEDURE set_TestName(p_testName IN VARCHAR2) IS
    BEGIN
        quilt_logger.log_detail('begin:p_testName=$1', p_testName);
        gstr_testname := substr(p_testName, 1, quilt_const.TEST_NAME_MAX_LEN);
    END set_TestName;

    ----------------------------------------------------------------------------
    FUNCTION get_TestName RETURN VARCHAR2 IS
    BEGIN
        RETURN gstr_testname;
    END get_TestName;

END quilt_core;
/
