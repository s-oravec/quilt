create or replace force view quiltv_EnabledObject as
select *
  from quilt_reported_object
 where sessionID = sys_context('USERENV','SESSIONID')
   and SID = sys_context('USERENV','SID')
;
