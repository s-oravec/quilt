@&&run_dir_begin

rem SET SERVEROUTPUT ON
rem
rem prompt Dropping types
rem BEGIN
rem     FOR i IN (SELECT 'DROP TYPE '|| o.object_name ||' FORCE' sql_comm
rem                    , o.*
rem                 FROM all_objects o
rem                WHERE object_name LIKE 'QUILT_%'
rem                  AND object_type = 'TYPE'
rem                ORDER BY object_id DESC) LOOP
rem     BEGIN
rem         EXECUTE IMMEDIATE i.sql_comm;
rem         --dbms_output.put_line(i.sql_comm);
rem         dbms_output.put_line('Dropping type '|| i.object_name ||' in schema :'|| i.owner);
rem     EXCEPTION
rem         WHEN OTHERS THEN
rem             dbms_output.put_line('Don''t drop type :'|| i.object_name ||' ERROR:'|| sqlerrm);
rem     END;
rem     END LOOP;
rem END;
rem /

prompt .. Dropping type QUILT_MATCHMULTILINECOMMENT
DROP TYPE QUILT_MATCHMULTILINECOMMENT FORCE;

prompt .. Dropping type QUILT_MATCHSINGLELINECOMMENT
DROP TYPE QUILT_MATCHSINGLELINECOMMENT FORCE;

prompt .. Dropping type QUILT_MATCHNUMBERLITERAL
DROP TYPE QUILT_MATCHNUMBERLITERAL FORCE;

prompt .. Dropping type QUILT_MATCHWORD
DROP TYPE QUILT_MATCHWORD FORCE;

prompt .. Dropping type QUILT_MATCHERSLIST
DROP TYPE QUILT_MATCHERSLIST FORCE;

prompt .. Dropping type QUILT_MATCHERS
DROP TYPE QUILT_MATCHERS FORCE;

prompt .. Dropping type QUILT_MATCHKEYWORD
DROP TYPE QUILT_MATCHKEYWORD FORCE;

prompt .. Dropping type QUILT_TOKEN
DROP TYPE QUILT_TOKEN FORCE;

prompt .. Dropping type QUILT_MATCHTEXTLITERAL
DROP TYPE QUILT_MATCHTEXTLITERAL FORCE;

prompt .. Dropping type QUILT_MATCHWHITESPACE
DROP TYPE QUILT_MATCHWHITESPACE FORCE;

prompt .. Dropping type QUILT_MATCHER
DROP TYPE QUILT_MATCHER FORCE;

prompt .. Dropping type QUILT_INTEGER_STACK
DROP TYPE QUILT_INTEGER_STACK FORCE;

prompt .. Dropping type QUILT_INTEGER_TAB
DROP TYPE QUILT_INTEGER_TAB FORCE;

prompt .. Dropping type QUILT_OBJECT_LIST_TYPE
DROP TYPE QUILT_OBJECT_LIST_TYPE FORCE;

prompt .. Dropping type QUILT_OBJECT_TYPE
DROP TYPE QUILT_OBJECT_TYPE FORCE;

prompt .. Dropping type QUILT_REPORT_PROCESS_TYPE
DROP TYPE QUILT_REPORT_PROCESS_TYPE FORCE;

prompt .. Dropping type QUILT_REPORT_TYPE
DROP TYPE QUILT_REPORT_TYPE FORCE;

prompt .. Dropping type QUILT_TOKENS
DROP TYPE QUILT_TOKENS FORCE;

@&&run_dir_end
