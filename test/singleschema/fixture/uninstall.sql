prompt quilt_Util.%PLSQLOptimizeLevel% methods fixtures
@@fix_util_optimizelevel.uninstall.sql

prompt quilt parser fixture for package functions/procedures
drop package fix_parser_fncandproc;

prompt .. Dropping PLParse parser fixture - IF statement
drop procedure fix_parser_if;

prompt .. Dropping PLParse parser fixture - CASE statement
drop procedure fix_parser_case;

prompt .. Dropping PLParse parser fixture - Declaration with initialization
drop procedure fix_parser_dec_with_init;

prompt .. Dropping PLParse parser fixture - Declaration without initialization
drop procedure fix_parser_dec_without_init;
