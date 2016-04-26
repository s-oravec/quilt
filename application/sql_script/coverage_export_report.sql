SET TERM ON
SET ECHO OFF

-- gen report
prompt Prepare data for lcov report
define file_name = lcov.log
spool &&file_name
SET ECHO ON
BEGIN
  quilt_codecoverage_pkg.ProcessingCodeCoverage;
END;
/
spool off

-- file name lcov.info
define file_name = lcov.info

-- export lcov.info
prompt Export lcov report
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
SELECT replace(line,chr(10))
FROM quilt_report
WHERE sessionid = quilt_core_pkg.get_SESSIONID 
AND sid = quilt_core_pkg.get_SID
AND runid = quilt_core_pkg.get_Runid
ORDER BY idx; 

spool off