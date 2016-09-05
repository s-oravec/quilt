rem
rem Run from your schema to use specific Quilt installation (schema)
rem
rem Usage
rem     sql @use.sql <Quilt schema>
rem
set verify off
define g_quilt_schema = "&1"

prompt init sqlsn
@sqlsnrc

prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt define test action and script
define g_run_action = run
define g_run_script = run

@&&run_dir test

exit