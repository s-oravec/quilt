SET ECHO OFF
SET TERM ON

PROMPT Start profile
PROMPT Enter test name, max length 240 char
ACCEPT l_test_name char prompt 'Test name: '
SET TERM OFF

EXEC quilt.spying_start('&l_test_name');

undefine l_test_name
-- Don't exit from sqlplus!!!