define g_quilt_schema = 'QUILT_000100_DEV'
set termout off
@./application/api/synonyms.sql
set termout on

define g_pete_schema = 'PETE_010000'
set termout off
@./oradb_modules/pete/application/api/synonyms.sql
set termout on

@&&run_dir &&g_test_target

prompt Grant execute on UT% packages to Pete
define g_pete_schema = PETE_010000
BEGIN
    FOR ii IN (SELECT *
                 FROM user_objects
                WHERE object_name LIKE 'UT%'
                  AND object_type = 'PACKAGE') LOOP
        dbms_output.put_line('.. Granting execute on ' || ii.object_name);
        EXECUTE IMMEDIATE 'grant execute on ' || ii.object_name || ' to &&g_pete_schema';
    END LOOP;
END;
/