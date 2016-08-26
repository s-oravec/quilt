create or replace force view quiltv_EnabledObject as
select *
  from quilt_methods
 where sessionID = sys_context('USERENV','SESSIONID')
   and SID = sys_context('USERENV','SID')
;