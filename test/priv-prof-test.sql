disconnect
connect QUILT_000100_TST_PRIV_PROF/QUILT_000100_TST_PRIV_PROF@local

set serveroutput on size unlimited format wrapped
set trimspool on

exec quilt.enable_report('QUILT_000100_TST_PROF_APP');
exec quilt.start_profiling;
exec QUILT_000100_TST_PROF_APP.TESTED_PROCEDURE;
exec QUILT_000100_TST_PROF_APP.TESTED_PACKAGE.test;
insert into QUILT_000100_TST_PROF_APP.TESTED_TABLE select level from dual connect by level <= 10;
commit;
exec quilt.stop_profiling;
