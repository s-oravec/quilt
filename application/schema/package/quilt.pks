CREATE OR REPLACE PACKAGE quilt IS

    -- PL/SQL code coverage tool - start/stop profiling using DBMS_PROFILER

    -- TODO: make it authid current_user to enable enableReport/disableReport to be run without any parameters and to pickup schema from USERENV, CURREN_USER context attribute

    -- Default Test name
    DEFAULT_TEST_NAME CONSTANT VARCHAR2(255) := 'Code coverage test';

    -- Starts profilign
    --
    -- %param p_test_name tet name
    --
    PROCEDURE begin_profiling(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME);

    FUNCTION begin_profiling(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) RETURN NUMBER;

    -- Stops profiling
    --
    PROCEDURE end_profiling;

    -- Enables Code Coverage reporting for schema/object
    --
    -- %param owner owner of the object
    -- %param object_name object name accepts LIKE expressions with \ as escape
    --
    PROCEDURE enable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2
    );

    -- Disables Code Coverage reporting for schema/object
    --
    -- %param owner owner of the object
    -- %param object_name object name accepts LIKE expressions with \ as escape
    --
    PROCEDURE disable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2
    );

    -- returns lines of report formated as LCOV report identified by runid - returned by begin_profiling
    -- if no runid is passed then last report within session is displayed
    --
    -- %param runid DBMS_PROFILER runid
    --
    FUNCTION display_lcov(runid IN NUMBER DEFAULT NULL) RETURN quilt_report
        PIPELINED;

END quilt;
/
