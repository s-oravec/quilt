rem
rem Creates Quilt schema
rem
rem Usage
rem     sql @install_teste.sql <test_target>
rem
rem     test_target   multischema_profiled_app
rem                   | multischema_privileged_profiler
rem                   | multischmea_unpivileged_profiler
rem                   | singleschema
rem
set verify off
define g_test_target = "&1"

prompt init sqlsn
@sqlsnrc

--we need sqlsn run module to traverse directory tree during install
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt Uninstall test objects
prompt .. Define uninstall action and script
define g_run_action = uninstall
define g_run_script = uninstall

prompt .. Run uninstall action
@&&run_dir test

exit
