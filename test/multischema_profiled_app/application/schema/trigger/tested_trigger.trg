create or replace trigger tested_trigger
  before insert on tested_table
  for each row
begin
  dbms_output.put_line(:new.id || ' inserted');
end;
/
