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
