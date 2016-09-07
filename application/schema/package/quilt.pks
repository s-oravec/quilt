CREATE OR REPLACE PACKAGE quilt AUTHID CURRENT_USER IS

    -- PL/SQL code coverage tool - start/stop profiling using DBMS_PROFILER

    -- Enables Code Coverage reporting for schema/object
    --
    -- %param owner owner of the object
    -- %param object_name object name accepts LIKE expressions with \ as escape, optional
    -- %param object_type object type exact value (PACKAGE BODY, TYPE BODY, PROCEDURE, FUNCTION, TRIGGER) or null
    --
    PROCEDURE enable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2 DEFAULT NULL,
        object_type IN VARCHAR2 DEFAULT NULL
    );

    -- Disables Code Coverage reporting for schema/object
    --
    -- %param owner owner of the object
    -- %param object_name object name accepts LIKE expressions with \ as escape
    -- %param object_type object type exact value (PACKAGE BODY, TYPE BODY, PROCEDURE, FUNCTION, TRIGGER) or null
    --
    PROCEDURE disable_report
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2 DEFAULT NULL,
        object_type IN VARCHAR2 DEFAULT NULL
    );

    FUNCTION reported_objects RETURN quilt_object_list_type
        PIPELINED;

    -- Default Test name
    DEFAULT_TEST_NAME CONSTANT VARCHAR2(255) := 'Code coverage test';

    -- Starts profilign
    --
    -- %param p_test_name tet name
    --
    -- %return Quilt run_id
    --
    FUNCTION start_profiling(test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME) RETURN NUMBER;
    PROCEDURE start_profiling(test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME);

    -- Stops profiling
    --
    PROCEDURE stop_profiling;

    -- Generate report
    --
    -- %param run_id Quilt run id returned by start_profiling function; default is last run id
    --
    PROCEDURE generate_report(run_id IN NUMBER DEFAULT NULL);

    -- returns lines of report formated as LCOV report identified by runid - returned by start_profiling
    -- if no runid is passed then last report within session is displayed
    --
    -- %param run_id Quilt run id returned by start_profiling function; default is last run id
    --
    FUNCTION display_lcov(run_id IN NUMBER DEFAULT NULL) RETURN quilt_report
        PIPELINED;

END quilt;
/
