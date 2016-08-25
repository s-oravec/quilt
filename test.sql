prompt init sqlsn
@sqlsnrc

prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt define test action and script
define g_run_action = run
define g_run_script = run

@&&run_dir test

exit