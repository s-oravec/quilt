CREATE OR REPLACE PACKAGE quilt_core IS

    -- PL/SQL code coverage tool - parameters of testing - RUNID,SID,SESSIONID

    /** set RUNID */
    PROCEDURE set_Runid(p_runid IN NUMBER);

    /** get RUNID */
    FUNCTION get_Runid RETURN NUMBER;

    /** get SID */
    FUNCTION get_SID RETURN NUMBER;

    /** get SESSIONID */
    FUNCTION get_SESSIONID RETURN NUMBER;

    /** set test name */
    PROCEDURE set_TestName(p_testname IN VARCHAR2);

    /** get test name */
    FUNCTION get_TestName RETURN VARCHAR2;

END quilt_core;
/
