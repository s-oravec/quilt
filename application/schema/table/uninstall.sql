@&&run_dir_begin


prompt Creating table QUILT_METHODS
DROP TABLE quilt_methods CASCADE CONSTRAINTS PURGE;

prompt Dropping table QUILT_LOG
DROP TABLE quilt_log CASCADE CONSTRAINTS PURGE;

prompt Dropping table QUILT_REPORT
DROP TABLE quilt_report CASCADE CONSTRAINTS PURGE;

prompt Dropping table QUILT_RUN
DROP TABLE quilt_run CASCADE CONSTRAINTS PURGE;


@&&run_dir_end