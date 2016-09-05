set echo off
set verify off

define l_test_name_def = "Code coverage test"
prompt .. Starting profiling

prompt Enter test name (max length 240 char)
accept l_test_name  prompt "Test name [&&l_test_name_def]: " default "&&l_test_name_def"

exec quilt.start_profiling('&l_test_name');

undefine l_test_name
undefine l_test_name_def