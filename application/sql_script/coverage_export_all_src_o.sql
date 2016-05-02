SET TERM ON
SET ECHO OFF

-- create tmp sql file
DEFINE file_name = __src_export.sql

PROMPT Prepare SQL script for export source codes
PROMPT Enter Session ID, SID from table QUILT_METHODS
ACCEPT s1 number prompt 'Session ID:'
ACCEPT s2 number prompt 'SID:'
SET TERM OFF

SPOOL &&file_name
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
WHERE sid = &s2
AND sessionid = &s1;
SPOOL OFF

-- execute export src
SET TERM ON
PROMPT Export all DB source codes to files
SET TERM OFF
@@__src_export.sql