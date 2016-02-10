

exec quilt_codecoverage_pkg.set_SpyingObject('&schem','ut_tsip_iface_oracle12c_pkg','package')
exec quilt_codecoverage_pkg.set_SpyingObject('&schem','ut_tsip_iface_oracle12c_pkg','package body')
exec quilt_codecoverage_pkg.set_SpyingObject('&schem','ut_rt_iface_test_oracle12c_pkg','package')
exec quilt_codecoverage_pkg.set_SpyingObject('&schem','ut_rt_iface_test_oracle12c_pkg','package body')
exec quilt_codecoverage_pkg.set_SpyingObject('&schem','ut_rt_core_test_oracle12c_pkg','package')
exec quilt_codecoverage_pkg.set_SpyingObject('&schem','ut_rt_core_test_oracle12c_pkg','package body')


@coverage_start "Muj Test 1"

@test

@coverage_stop

@coverage_export_report

@coverage_export_all_src