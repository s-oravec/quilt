SET TERM OFF
SEt ECHO OFF

--
define SCHEMA_OBJ = '&1'
define OBJECT_NAME = '&2'
define OBJECT_TYPE = '&3'
define SURFIX = '.sql'
define DOT = '.'
define FILE_NAME = '&1&DOT&2&DOT&3&SURFIX'

--debug
--select '&FILE_NAME' x from dual; 

-- spool src
prompt Export source code
spool '&FILE_NAME' 
--SET SPACE 0
SET LINESIZE 4000
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET AUTO OFF
SET TRIMSPOOL ON
SET TERM OFF
SET EMB ON
select case when line = 1 then 'CREATE OR REPLACE '||text else text end text_line
from all_source
where owner = '&SCHEMA_OBJ'
and name = '&OBJECT_NAME'
and type = '&OBJECT_TYPE'
order by line;
spool off

