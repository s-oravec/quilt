CREATE OR REPLACE PACKAGE quilt_logger IS

    -- Purpose : PL/SQL code coverage tool - logger

    -- TODO: create method for logging exception

    -- log start of profiling into QUILT_RUN table
    --
    -- %param p_runId DBMS_PROFILER run number as returned from DBMS_PROFILER.start_profiler call
    -- %param p_test_name test name
    --
    PROCEDURE log_start(p_runId IN NUMBER,
                        -- TODO: rename p_test_name to p_testName
                        p_test_name IN VARCHAR2);

    -- log end of profiling into QUILT_RUN table
    --
    -- %param p_runId DBMS_PROFILER run number as returned from DBMS_PROFILER.start_profiler call
    --
    PROCEDURE log_stop(p_runId IN NUMBER);

    -- log message int QUILT_LOG table
    --
    -- %param p_msg message with $1, $2, ... $10 placeholders that get replaced by values passed into p_placeholderx arguments
    --
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
    );

END quilt_logger;
/
