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

-- file name lcov.info
define file_name = lcov.info

-- export lcov.info
spool &&file_name
--SET SPACE 0
SET LINESIZE 4000
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET AUTO OFF
SET TRIMSPOOL ON
SET TERM OFF
SET EMB ON
SELECT line
FROM quilt_report
WHERE sessionid = quilt_core_pkg.get_SESSIONID 
AND sid = quilt_core_pkg.get_SID
AND runid = quilt_core_pkg.get_Runid
ORDER BY idx; 

spool off