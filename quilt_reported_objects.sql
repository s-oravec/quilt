set echo off
set verify off

prompt Quilt reported object

column owner format a30
column object_name format a30
column object_type format a20

select *
  from table(quilt.reported_objects)
 order by owner, object_type, object_name;