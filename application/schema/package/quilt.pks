CREATE OR REPLACE PACKAGE quilt IS

    -- PL/SQL code coverage tool - start/stop profiling using DBMS_PROFILER

    -- TODO: make it authid current_user to enable enableReport/disableReport to be run without any parameters and to pickup schema from USERENV, CURREN_USER context attribute

    -- Default Test name
    DEFAULT_TEST_NAME CONSTANT VARCHAR2(255) := 'Code coverage test';

    -- Starts profilign
    --
    -- %param p_test_name tet name
    --
    PROCEDURE spying_start(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME);

    -- Stops profiling
    --
    PROCEDURE spying_end;

    -- Enables Code Coverage reporting for schema/object
    --
    -- %param owner owner of the object
    -- %param object_name object name accepts LIKE expressions with \ as escape
    --
    PROCEDURE enableReport
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2
    );

    -- Disables Code Coverage reporting for schema/object
    --
    -- %param owner owner of the object
    -- %param object_name object name accepts LIKE expressions with \ as escape
    --
    PROCEDURE disableReport
    (
        OWNER       IN VARCHAR2,
        object_name IN VARCHAR2
    );

END quilt;
/
