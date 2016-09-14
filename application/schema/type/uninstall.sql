rem SET SERVEROUTPUT ON
rem
rem prompt Dropping types
rem BEGIN
rem     FOR i IN (SELECT 'DROP TYPE '|| lower(o.object_name) ||' FORCE' sql_comm
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
DROP TYPE plex_matchmultilinecomment FORCE;

prompt .. Dropping type PLEX_MATCHSINGLELINECOMMENT
DROP TYPE plex_matchsinglelinecomment FORCE;

prompt .. Dropping type PLEX_MATCHNUMBERLITERAL
DROP TYPE plex_matchnumberliteral FORCE;

prompt .. Dropping type PLEX_MATCHWORD
DROP TYPE plex_matchword FORCE;

prompt .. Dropping type PLEX_MATCHERSLIST
DROP TYPE plex_matcherslist FORCE;

prompt .. Dropping type PLEX_MATCHERS
DROP TYPE plex_matchers FORCE;

prompt .. Dropping type PLEX_MATCHKEYWORD
DROP TYPE plex_matchkeyword FORCE;

prompt .. Dropping type PLEX_TOKEN
DROP TYPE plex_token FORCE;

prompt .. Dropping type PLEX_MATCHTEXTLITERAL
DROP TYPE plex_matchtextliteral FORCE;

prompt .. Dropping type PLEX_MATCHWHITESPACE
DROP TYPE plex_matchwhitespace FORCE;

prompt .. Dropping type PLEX_MATCHER
DROP TYPE plex_matcher FORCE;

prompt .. Dropping type QUILT_INTEGER_STACK
DROP TYPE quilt_integer_stack FORCE;

prompt .. Dropping type QUILT_INTEGER_TAB
DROP TYPE quilt_integer_tab FORCE;

prompt .. Dropping type QUILT_OBJECT_LIST_TYPE
DROP TYPE quilt_object_list_type FORCE;

prompt .. Dropping type QUILT_OBJECT_TYPE
DROP TYPE quilt_object_type FORCE;

prompt .. Dropping type QUILT_REPORT_PROCESS_TYPE
DROP TYPE quilt_report_process_type FORCE;

prompt .. Dropping type QUILT_REPORT
DROP TYPE quilt_report FORCE;

prompt .. Dropping type PLEX_TOKENS
DROP TYPE plex_tokens FORCE;

prompt .. Dropping type PLPARSE_AST
DROP TYPE plparse_ast FORCE;

prompt .. Dropping type PLPARSE_ASTCHILDREN
DROP TYPE plparse_astchildren FORCE;

prompt .. Dropping type QUILT_LCOV_LINES
DROP TYPE quilt_lcov_lines;

prompt .. Dropping type QUILT_REPORT_ITEM
DROP TYPE quilt_report_item;
