SET TERM ON
SET ECHO OFF

-- gen report
prompt Prepare data for lcov report
prompt Enter Session ID, SID and RUN ID from table QUILT_RUN
accept s1 number prompt 'Session ID:'
accept s2 number prompt 'SID:'
accept s3 number prompt 'RUN ID:'
define file_name = lcov.log
spool &&file_name
SET ECHO ON
BEGIN
  quilt_codecoverage_pkg.ProcessingCodeCoverage(&s1,&s2,&s3);
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
WHERE sessionid = &s1
AND sid = &s2
AND runid = &s3
ORDER BY idx; 

spool off