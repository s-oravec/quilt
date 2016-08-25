set echo off

declare
  x sys_refcursor;
begin
  x := ut_tsip_iface_oracle12c_pkg.getList(100);
end;
/

