SET TERM ON
SET ECHO OFF

-- create tmp sql file
DEFINE file_name = _src_export.sql

PROMPT Prepare SQL script for export source codes
SET TERM OFF
spool &&file_name
SET LINESIZE 80
SET PAGESIZE 50000
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET AUTO OFF
SET TERM OFF

SELECT DISTINCT '@@coverage_export_src '|| object_schema ||' '|| object_name ||' "'|| object_type ||'"'
FROM quilt_methods
WHERE sid = quilt_core_pkg.get_SID
AND sessionid = quilt_core_pkg.get_SESSIONID;
SPOOL OFF

-- execute export src
SET TERM ON
PROMPT Export all DB source codes to files
SET TERM OFF
@@_src_export.sql