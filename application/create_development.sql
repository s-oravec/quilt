rem Quilt 0.1.0
rem Deployment of dev envirnment
define g_quilt_dev_schema = "QUILT_000100_DEV"
@@create_development_schema &&g_quilt_dev_schema

rem multischema test users
define g_quilt_tst_profiled_app    = "QUILT_000100_TST_PROF_APP"
@@create_development_schema &&g_quilt_tst_profiled_app

define g_quilt_tst_priv_profiler   = "QUILT_000100_TST_PRIV_PROF"
@@create_development_schema &&g_quilt_tst_priv_profiler

rem privileged profiler user has create any procedure/trigger/type
grant create any procedure to &&g_quilt_tst_priv_profiler;
grant create any trigger to &&g_quilt_tst_priv_profiler;
grant create any type to &&g_quilt_tst_priv_profiler;

define g_quilt_tst_unpriv_profiler = "QUILT_000100_TST_UNPRIV_PROF"
@@create_development_schema &&g_quilt_tst_unpriv_profiler

