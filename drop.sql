rem
rem Drops Quilt schema
rem
rem Usage
rem     sql @drop.sql <environment>
rem
set verify off
define g_environment = "&1"

prompt init sqlsn
@sqlsnrc

--we need sqlsn run module to traverse directory tree during install
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt define action and script
define g_run_action = drop
define g_run_script = drop_&&g_environment..sql

prompt Drop Quilt schema
@&&run_dir application

show errors

exit
