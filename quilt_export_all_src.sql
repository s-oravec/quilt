SET TERM ON
SET ECHO OFF

-- create tmp sql file
DEFINE file_name = _src_export.sql

PROMPT Prepare SQL script for export source codes
SET TERM OFF
spool &&file_name
set serveroutput on size unlimited format wrapped
set trimspool on
set linesize 4000
set feedback off
set heading off
set auto off
set trimspool on
set long 32767
set longchunk 32767

column text format a255

SELECT DISTINCT '@@coverage_export_src '|| owner ||' '|| object_name ||' "'|| object_type ||'" ' as text
FROM table(quilt.reported_objects)
ORDER BY 1;
SPOOL OFF

-- execute export src
SET TERM ON
PROMPT Export all DB source codes to files
SET TERM OFF
@@_src_export.sql