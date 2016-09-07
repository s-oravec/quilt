clear
disconnect
connect QUILT_000100_TST_PRIV_PROF/QUILT_000100_TST_PRIV_PROF@local

set pages 999

set serveroutput on size unlimited format wrapped
set trimspool on


var run_id number

exec quilt.enable_report('QUILT_000100_TST_PROF_APP','FULL_COVERAGE');
exec :run_id := quilt.start_profiling;
--
exec QUILT_000100_TST_PROF_APP.full_coverage.all_methods;
---
exec quilt.stop_profiling;
---
exec quilt.generate_report(:run_id);

select * from table(quilt.display_lcov);

SELECT DISTINCT '@@coverage_export_src ' || OWNER || ' ' || object_name || ' "' || object_type || '" ' ||
                REPLACE(OWNER || ' ' || object_name || ' "' || object_type, ' ', '_')
  FROM TABLE(quilt.reported_objects);
