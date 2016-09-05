prompt Create tables
@&&run_dir table

prompt Create types
@&&run_dir type

prompt Create sequences
@&&run_dir sequence

prompt Create packages
@&&run_dir package

prompt Compiling invalid objects
begin
  dbms_utility.compile_schema(schema => user, compile_all => FALSE);
end;
/
