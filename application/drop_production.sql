rem Quilt 0.1.0
define g_quilt_prod_schema_def = "QUILT_000100"

accept g_quilt_prod_schema prompt "Quilt schema [&&g_quilt_prod_schema_def] : " default "&&g_quilt_prod_schema_def"

rem Quilt Production Schema
prompt .. Dropping &&g_quilt_prod_schema user
drop user &&g_quilt_prod_schema cascade;
