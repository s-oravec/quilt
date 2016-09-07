connect QUILT_000100_TST_PRIV_PROF/QUILT_000100_TST_PRIV_PROF@local

set serveroutput on size unlimited format wrapped
set trimspool on
set linesize 4000
set echo off
set feedback off
set verify off
set heading off
set auto off
set term off
set pages 0

rem Enable CodeCoverage report for this object
exec quilt.enable_report('QUILT_000100_TST_PROF_APP','FULL_COVERAGE');

rem Start profiling
exec quilt.start_profiling;

rem Do your tests or what ...
exec QUILT_000100_TST_PROF_APP.full_coverage.all_methods;

rem Stop profiling
exec quilt.stop_profiling;

rem Generate report from profiling data
exec quilt.generate_report;

rem Export report into report/lcov.info file
@@quilt_export_report.sql

rem Export sources of reported objects into report/src
@@quilt_export_all_src.sql

rem Now start docker containter
rem docker run -v `pwd`:/tmp -it lcov /bin/bash
rem go to /tmp
rem and generate html report
rem $ ./docker_gen_script

rem Open your report is in report/html/index.html

exit
