@&&run_dir_begin


@&&run_dir table
@&&run_dir type
@&&run_dir sequence
@&&run_dir package

prompt Compiling invalid objects
begin
  dbms_utility.compile_schema(schema => user, compile_all => FALSE);
end;
/


@&&run_dir_end