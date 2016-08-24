@&&run_dir_begin


prompt .. Dropping table QUILT_METHODS
DROP TABLE quilt_methods CASCADE CONSTRAINTS PURGE;

prompt .. Dropping table QUILT_LOG
DROP TABLE quilt_log CASCADE CONSTRAINTS PURGE;

prompt .. Dropping table QUILT_REPORT
DROP TABLE quilt_report CASCADE CONSTRAINTS PURGE;

prompt .. Dropping table QUILT_RUN
DROP TABLE quilt_run CASCADE CONSTRAINTS PURGE;

prompt .. Dropping table PLSQL_PROFILER_DATA
DROP TABLE plsql_profiler_data CASCADE CONSTRAINTS PURGE;

prompt .. Dropping table PLSQL_PROFILER_RUNS
DROP TABLE plsql_profiler_runs CASCADE CONSTRAINTS PURGE;

prompt .. Dropping table PLSQL_PROFILER_UNITS
DROP TABLE plsql_profiler_units CASCADE CONSTRAINTS PURGE;


@&&run_dir_end