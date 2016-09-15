prompt .. Creating fixture function
CREATE OR REPLACE FUNCTION fix_util_optimizelevel_f RETURN PLS_INTEGER AS
BEGIN
    RETURN 0;
END;
/

prompt .. Creating fixture procedure
CREATE OR REPLACE PROCEDURE fix_util_optimizelevel_p AS
BEGIN
    NULL;
END;
/

prompt .. Creating fixture package
CREATE OR REPLACE PACKAGE fix_util_optimizelevel_pkg AS

    PROCEDURE dummy;

END;
/

prompt .. Creating fixture package
CREATE OR REPLACE PACKAGE BODY fix_util_optimizelevel_pkg AS

    PROCEDURE dummy IS
    BEGIN
        NULL;
    END;

END;
/

prompt .. Creating fixture table
create table fix_util_optimizelevel_tab as select 1 n from dual;

prompt .. Creating fixture trigger
CREATE OR REPLACE TRIGGER fix_util_optimizelevel_trg
    BEFORE INSERT ON fix_util_optimizelevel_tab
    FOR EACH ROW
BEGIN
    NULL;
END;
/
