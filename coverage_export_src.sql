define l_owner  = '&1'
define l_object_name = '&2'
define l_object_type = '&3'

column file_name new_value l_file_name
select replace('report/src/&l_owner..&l_object_name..&l_object_type..sql', ' ', '_') file_name
  from dual;

set term off
set echo off
set serveroutput on size unlimited format wrapped
set trimspool on
set linesize 4000
set feedback off
set heading off
set auto off
set trimspool on
set long 32767
set longchunk 32767

set term on
prompt Spooling source of &l_object_type &l_owner..&l_object_name into file &l_file_name
set term off

column text format a255

spool &l_file_name

BEGIN
    FOR Line IN (SELECT CASE
                            WHEN Line = 1 THEN
                             'CREATE OR REPLACE ' || Text
                            ELSE
                             Text
                        END as Text
                   FROM all_source
                  WHERE OWNER = '&l_owner'
                    AND Name = '&l_object_name'
                    AND Type = '&l_object_type'
                  ORDER BY Line) LOOP
        dbms_output.put_line(rtrim(rtrim(line.text, chr(13)), chr(10)));
    END LOOP;
END;
/

spool off

undefine l_owner
undefine l_object_name
undefine l_object_type
undefine l_file_name