set echo off
set verify off

prompt .. Stopping profiling
set term off

exec quilt.stop_profiling;

-- Don't exit from sqlplus!!!

