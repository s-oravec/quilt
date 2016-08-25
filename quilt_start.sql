SET ECHO OFF
SET TERM ON

PROMPT Start profile
PROMPT Enter test name, max length 240 char
ACCEPT st1 char prompt 'Test name: '
SET TERM OFF
EXEC quilt_pkg.spying_start(&st1)

-- Don't exit from sqlplus!!!