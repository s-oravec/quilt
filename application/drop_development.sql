rem Quilt 0.1.0
define g_quilt_dev_schema = "QUILT_000100_DEV"

rem Quilt Development Schema
prompt drop &&g_quilt_dev_schema user
DROP USER &&g_quilt_dev_schema CASCADE;

