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
