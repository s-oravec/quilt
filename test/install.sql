prompt install test

prompt Crate or replace synonyms for pete objects
define g_pete_schema = PETE_010000
BEGIN
    FOR ii IN (SELECT * FROM all_objects WHERE OWNER = '&&g_pete_schema') LOOP
        dbms_output.put_line('.. Creating synonym ' || ii.object_name || ' for ' || ii.owner || '.' || ii.object_name);
        EXECUTE IMMEDIATE 'create or replace synonym ' || ii.object_name || ' for ' || ii.owner || '.' || ii.objecT_name;
    END LOOP;
END;
/

@&&run_dir application

@&&run_dir fixture

