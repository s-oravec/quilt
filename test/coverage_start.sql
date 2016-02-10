SET ECHO OFF
SET TERM OFF

--exec dbms_profiler.start_profiler(run_comment  => to_char(sysdate, quilt_const_pkg.DATE_TIME_FM))

exec quilt_pkg.spying_start('&1')

-- NESMI BYT exit