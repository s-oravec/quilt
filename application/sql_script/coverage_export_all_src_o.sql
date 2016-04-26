SET TERM ON
SET ECHO OFF

-- create tmp sql file
define file_name = __src_export.sql

prompt Prepare SQL script for export source codes
prompt Enter Session ID, SID from table QUILT_METHODS
accept s1 number prompt 'Session ID:'
accept s2 number prompt 'SID:'
spool &&file_name
SET SPACE 0
SET LINESIZE 80
SET PAGESIZE 50000
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET AUTO OFF
SET TERM OFF

select distinct '@@coverage_export_src '|| object_schema ||' '|| object_name ||' "'|| object_type ||'"'
from quilt_methods
where sid = &s2
and sessionid = &s1;

--
spool off


-- execute export src
prompt Export source codes to files
@@__src_export.sql