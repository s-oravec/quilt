SET TERM ON
SET ECHO OFF

-- create tmp sql file
define file_name = _src_export.sql

prompt Prepare SQL script for export source codes
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
where sid = quilt_core_pkg.get_SID
and sessionid = quilt_core_pkg.get_SESSIONID;

--
spool off


-- execute export src
prompt Export source codes to files
@@_src_export.sql