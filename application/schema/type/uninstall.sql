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

prompt .. Dropping type QUILT_OBJECT_LIST_TYPE
DROP TYPE quilt_object_list_type FORCE;

prompt .. Dropping type QUILT_OBJECT_TYPE
DROP TYPE quilt_object_type FORCE;

prompt .. Dropping type QUILT_REPORT_PROCESS_TYPE
DROP TYPE quilt_report_process_type FORCE;

prompt .. Dropping type QUILT_REPORT_TYPE
DROP TYPE quilt_report_type FORCE;

@&&run_dir_end