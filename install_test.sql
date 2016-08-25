prompt init sqlsn
@sqlsnrc

--we need sqlsn run module to traverse directory tree during install
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt Install test objects
prompt .. Define install action and script
define g_run_action = install
define g_run_script = install

prompt .. Run install action
@&&run_dir test

exit
