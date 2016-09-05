CREATE OR REPLACE PACKAGE quilt_coverage IS

    -- PL/SQL code coverage tool - report creation

    -- process PLSQL_PROFILER% tables for objects registered in QUILT_REPORTED_OBJECT
    -- and insert report lines into QUILT_REPORT_LINE table
    --
    -- %param p_quilt_run_id 
    --
    PROCEDURE process_profiler_run(p_quilt_run_id IN NUMBER DEFAULT NULL);

END quilt_coverage;
/
