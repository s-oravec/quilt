rem Quilt 0.1.0

rem Quilt Development Schema
define g_quilt_dev_schema = "QUILT_000100_DEV"
prompt drop &&g_quilt_dev_schema user
DROP USER &&g_quilt_dev_schema CASCADE;

define g_quilt_tst_profiled_app    = "QUILT_000100_TST_PROF_APP"
prompt drop &&g_quilt_tst_profiled_app user
DROP USER &&g_quilt_tst_profiled_app CASCADE;

define g_quilt_tst_priv_profiler   = "QUILT_000100_TST_PRIV_PROF"
prompt drop &&g_quilt_tst_priv_profiler user
DROP USER &&g_quilt_tst_priv_profiler CASCADE;

define g_quilt_tst_unpriv_profiler = "QUILT_000100_TST_UNPRIV_PROF"
prompt drop &&g_quilt_tst_unpriv_profiler user
DROP USER &&g_quilt_tst_unpriv_profiler CASCADE;

