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

prompt .. Dropping type PLEX_MATCHMULTILINECOMMENT
DROP TYPE PLEX_MATCHMULTILINECOMMENT FORCE;

prompt .. Dropping type PLEX_MATCHSINGLELINECOMMENT
DROP TYPE PLEX_MATCHSINGLELINECOMMENT FORCE;

prompt .. Dropping type PLEX_MATCHNUMBERLITERAL
DROP TYPE PLEX_MATCHNUMBERLITERAL FORCE;

prompt .. Dropping type PLEX_MATCHWORD
DROP TYPE PLEX_MATCHWORD FORCE;

prompt .. Dropping type PLEX_MATCHERSLIST
DROP TYPE PLEX_MATCHERSLIST FORCE;

prompt .. Dropping type PLEX_MATCHERS
DROP TYPE PLEX_MATCHERS FORCE;

prompt .. Dropping type PLEX_MATCHKEYWORD
DROP TYPE PLEX_MATCHKEYWORD FORCE;

prompt .. Dropping type PLEX_TOKEN
DROP TYPE PLEX_TOKEN FORCE;

prompt .. Dropping type PLEX_MATCHTEXTLITERAL
DROP TYPE PLEX_MATCHTEXTLITERAL FORCE;

prompt .. Dropping type PLEX_MATCHWHITESPACE
DROP TYPE PLEX_MATCHWHITESPACE FORCE;

prompt .. Dropping type PLEX_MATCHER
DROP TYPE PLEX_MATCHER FORCE;

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

prompt .. Dropping type QUILT_REPORT
DROP TYPE QUILT_REPORT FORCE;

prompt .. Dropping type PLEX_TOKENS
DROP TYPE PLEX_TOKENS FORCE;

prompt .. Dropping type QUILT_LCOV_LINES
DROP TYPE QUILT_LCOV_LINES;

prompt .. Dropping type QUILT_REPORT_ITEM
DROP TYPE QUILT_REPORT_ITEM;
