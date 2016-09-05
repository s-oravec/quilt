prompt Recompile test packages with debug
@@recompile_with_debug.sql

define g_pete_schema = 'PETE_010000'
@./oradb_modules/pete/application/api/synonyms.sql

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

rem Uncomment for easier debug
rem exec pete_config.set_show_asserts(a_value_in => pete_config.g_ASSERTS_ALL);
rem exec pete_config.set_show_hook_methods(a_value_in => true);
rem exec pete_config.set_show_failures_only(a_value_in => false);

prompt Run Pete Testing Suite
set serveroutput on size unlimited
exec pete.run_test_suite(a_suite_name_in => user);
