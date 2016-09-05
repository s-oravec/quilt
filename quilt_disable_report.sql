set echo off
set verify off

prompt .. Enabling coverage report for objects

accept l_owner       prompt "Owner [&&_user]: " default "&&_user"
accept l_object_name prompt "Object name (you can use LIKE expression) [%]: " default "%"

exec quilt.disable_report('&&l_owner', '&&l_object_name');

undefine l_owner
undefine l_object_name