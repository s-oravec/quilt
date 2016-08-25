CREATE OR REPLACE PACKAGE quilt_pkg IS

  -- PL/SQL code coverage tool - start/stop profiling using DBMS_PROFILER

  DEFAULT_TEST_NAME constant varchar2(255) := 'Code coverage test';

  -- Starts profilign
  --
  -- %param p_test_name tet name
  --
  PROCEDURE spying_start(p_test_name IN VARCHAR2 DEFAULT DEFAULT_TEST_NAME);

  -- Stops profiling
  --
  PROCEDURE spying_end;

END quilt_pkg;
/
