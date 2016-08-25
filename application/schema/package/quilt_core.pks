CREATE OR REPLACE PACKAGE quilt_core IS

    -- PL/SQL code coverage tool - parameters of testing - RUNID,SID,SESSIONID

    -- set RUNID
    --
    -- %param p_runId DBMS_PROFILER run_number
    --
    PROCEDURE set_Runid(p_runid IN NUMBER);

    -- get RUNID
    --
    -- %return DBMS_PROFILER run_number
    --
    FUNCTION get_Runid RETURN NUMBER;

    -- get UserEnv SID
    --
    -- %return UserEnv context SID attribute
    --
    FUNCTION get_SID RETURN NUMBER;

    -- get UserEnv sessionId
    --
    -- %return UserEnv context sessionId attribute
    --
    FUNCTION get_sessionId RETURN NUMBER;

    -- set Test name
    --
    -- %param p_testName Test name
    --
    PROCEDURE set_TestName(p_testName IN VARCHAR2);

    -- get get Test name
    --
    -- %return Test name
    --
    FUNCTION get_TestName RETURN VARCHAR2;

END quilt_core;
/
