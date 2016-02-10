CREATE OR REPLACE PACKAGE quilt_core_pkg IS

  -- Author  : HENRY
  -- Created : 17.12.2015 16:45:08
  -- Purpose : PL/SQL code coverage tool
  -- Purpose : obsluha parametru testovani - RUNID,SID,SESSIONID

  
  -- Public type declarations

  
  -- Public constant declarations


  -- Public variable declarations


  -- Public function and procedure declarations

  /** set RUNID */
  PROCEDURE set_Runid(p_runid IN NUMBER);

  /** get RUNID */
  FUNCTION get_Runid
      RETURN NUMBER;

  /** get SID */
  FUNCTION get_SID
      RETURN NUMBER;

  /** get SESSIONID */
  FUNCTION get_SESSIONID
      RETURN NUMBER;

  /** inicialization from session */
  PROCEDURE init;

  /** set test name */
  PROCEDURE set_TestName(p_testname IN VARCHAR2);

  /** get test name */  
  FUNCTION get_TestName
      RETURN VARCHAR2;

END quilt_core_pkg;
/
