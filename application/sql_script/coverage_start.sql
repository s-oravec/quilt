SET ECHO OFF
SET TERM OFF

prompt Start profile
exec quilt_pkg.spying_start('&1')

-- Don't exit from sqlplus!!!