SET TERM OFF
SET ECHO OFF

-- gen report
define file_name = lcov.log
spool &&file_name
BEGIN
  quilt_codecoverage_pkg.ProcessingCodeCoverage;
END;
/
spool off
