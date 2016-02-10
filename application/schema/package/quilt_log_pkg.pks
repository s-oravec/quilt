CREATE OR REPLACE PACKAGE quilt_log_pkg IS

  -- Author  : HENRY
  -- Created : 18.12.2015 9:27:06
  -- Purpose : PL/SQL code coverage tool
  -- Purpose : logovani

  
  -- Public type declarations

  
  -- Public constant declarations


  -- Public variable declarations


  -- Public function and procedure declarations

  /** Loging start */
  PROCEDURE log_start(p_runid IN NUMBER, p_test_name IN VARCHAR2);

  /** Loging stop */
  PROCEDURE log_stop(p_runid IN NUMBER);  

  /** Loging message */
  PROCEDURE log_detail(p_msg IN VARCHAR2);

END quilt_log_pkg;
/
