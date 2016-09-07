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

spool report/lcov.info
select * from table(quilt.display_lcov);
spool off
