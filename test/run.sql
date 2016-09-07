prompt Recompile test packages with debug
@@recompile_with_debug.sql

rem Uncomment for easier debug
rem exec pete_config.set_show_asserts(a_value_in => pete_config.g_ASSERTS_ALL);
rem exec pete_config.set_show_hook_methods(a_value_in => true);
rem exec pete_config.set_show_failures_only(a_value_in => false);

prompt Run Pete Testing Suite
set serveroutput on size unlimited
exec pete.run_test_suite(a_suite_name_in => user);
