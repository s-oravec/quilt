rem
rem Creates Quilt schema
rem
rem Usage
rem     sql @create.sql <environment>
rem
set verify off
define g_environment = "&1"

prompt init sqlsn
@sqlsnrc

--we need sqlsn run module to traverse directory tree during install
prompt require sqlsn-run module
@&&sqlsn_require sqlsn-run

prompt define action and script
define g_run_action = create
define g_run_script = create_&&g_environment..sql

prompt install application
@&&run_dir application

show errors

exit
