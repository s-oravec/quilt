@&&run_dir schema

prompt Compiling invalid objects
begin
  dbms_utility.compile_schema(schema => user, compile_all => FALSE);
end;
/
show errors