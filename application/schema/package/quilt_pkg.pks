CREATE OR REPLACE PACKAGE quilt_pkg IS

  -- Author  : HENRY
  -- Created : 17.12.2015 15:36:26
  -- Purpose : PL/SQL code coverage tool
  -- Purpose : start/stop dbms_profiler
  

  -- Public type declarations

  
  -- Public constant declarations


  -- Public variable declarations


  -- Public function and procedure declarations

  /** Start profiling */
  PROCEDURE spying_start(p_test_name IN VARCHAR2 DEFAULT 'Code coverage test');

  /** Stop profiling */
  PROCEDURE spying_end;

END quilt_pkg;
/
