rem Quilt 1.0.0
define g_quilt_production_schema = "QUILT_000100"

rem Quilt Development Schema
prompt drop &&g_quilt_production_schema user
DROP USER &&g_quilt_production_schema CASCADE;
