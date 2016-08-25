set serveroutput on size unlimited format wrapeds
SET TERM ON
SET ECHO OFF

-- gen report
PROMPT Prepare data for lcov report
SET TERM OFF
DEFINE file_name = lcov.log
SPOOL &&file_name
BEGIN
  quilt_codecoverage_pkg.ProcessingCodeCoverage;
END;
/
SPOOL OFF

-- file name lcov.info
DEFINE file_name = lcov.info

-- export lcov.info
SET TERM ON
PROMPT Export lcov report
SET TERM OFF
SPOOL &&file_name
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
SPOOL OFF