@&&run_dir_begin

SET SERVEROUTPUT ON

prompt Dropping types
BEGIN
    FOR i IN (SELECT 'DROP TYPE '|| o.object_name ||' FORCE' sql_comm
                   , o.* 
                FROM all_objects o
               WHERE object_name LIKE 'QUILT_%'
                 AND object_type = 'TYPE'
               ORDER BY object_id DESC) LOOP
    BEGIN
        EXECUTE IMMEDIATE i.sql_comm;
        --dbms_output.put_line(i.sql_comm);
        dbms_output.put_line('Drop type :'|| i.object_name ||' in schema :'|| i.owner);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Don''t drop type :'|| i.object_name ||' ERROR:'|| sqlerrm);
    END;
    END LOOP;
END;
/

@&&run_dir_end