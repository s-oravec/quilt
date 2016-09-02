CREATE OR REPLACE PACKAGE quilt_coverage IS

    -- PL/SQL code coverage tool - report creation

    -- process PLSQL_PROFILER% tables for objects registered in QUILT_METHODS
    -- and insert report lines into QUILT_REPORT_LINE table
    --
    -- %param p_sessionid 
    -- %param p_sid 
    -- %param p_runid 
    --
    PROCEDURE process_profiler_run
    (
        p_sessionid IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL,
        p_runid     IN NUMBER DEFAULT NULL
    );

END quilt_coverage;
/
