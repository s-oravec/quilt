prompt Dropping tables
@&&run_dir table

prompt Dropping types
@&&run_dir type

prompt Dropping sequences
@&&run_dir sequence

prompt Dropping packages
@&&run_dir package

prompt Dropping views
@&&run_dir view

prompt Compiling invalid objects
begin
  dbms_utility.compile_schema(schema => user, compile_all => FALSE);
end;
/
