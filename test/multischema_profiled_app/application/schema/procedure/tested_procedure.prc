CREATE OR REPLACE PROCEDURE tested_procedure IS
BEGIN
    dbms_output.put_line($$PLSQL_UNIT_OWNER || '.' || $$PLSQL_UNIT);
END;
/
