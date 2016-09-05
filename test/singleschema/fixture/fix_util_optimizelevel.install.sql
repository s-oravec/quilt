prompt .. Creating fixture function
create function fix_util_optimizelevel_f return pls_integer as
begin
  return 0;
end;
/

prompt .. Creating fixture procedure
create procedure fix_util_optimizelevel_p as
begin
  null;
end;
/

prompt .. Creating fixture package
create package fix_util_optimizelevel_pkg as

  procedure dummy;

end;
/

prompt .. Creating fixture package
create package body fix_util_optimizelevel_pkg as

  procedure dummy is
  begin
    null;
  end;

end;
/

prompt .. Creating fixture table
create table fix_util_optimizelevel_tab as select 1 n from dual;

prompt .. Creating fixture trigger
create trigger fix_util_optimizelevel_trg
  before insert on fix_util_optimizelevel_tab
  for each row
begin
  null;
end;
/
