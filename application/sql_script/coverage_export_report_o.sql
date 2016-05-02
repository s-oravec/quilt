SET TERM ON
SET ECHO OFF

-- gen report
PROMPT Prepare data for lcov report
PROMPT Enter Session ID, SID and RUN ID from table QUILT_RUN
ACCEPT s1 number prompt 'Session ID:'
ACCEPT s2 number prompt 'SID:'
ACCEPT s3 number prompt 'RUN ID:'
SET TERM OFF
DEFINE file_name = lcov.log
SPOOL &&file_name
BEGIN
  quilt_codecoverage_pkg.ProcessingCodeCoverage(&s1,&s2,&s3);
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
WHERE sessionid = &s1
AND sid = &s2
AND runid = &s3
ORDER BY idx; 
SPOOL OFF