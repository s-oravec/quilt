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
