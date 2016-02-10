# Quilt - PL/SQL code coverage tool

Quilt is PL/SQL code coverage tool written in PL/SQL and SQL*Plus.
It uses [DBMS_PROFILER](http://docs.oracle.com/database/121/ARPLS/d_profil.htm#ARPLS039) supplied with Oracle Database

## How it works (will work)

  1. Implement code & test
  2. `dbms_profiler.start_profiler`
  3. Run test
  4. `dbms_profiler.stop_profiler`
  5. Spool `ALL_SOURCE` from tested schemas to `<schema>/<objectType>/<objectName>`
  6. Create [LCOV file](http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php) from `PLSQL_PROFILER%` tables data - reference generated source files in `lcov.info` file
  
## Out of scope

  * LCOV > HTML (should be able to use already existing tools)

## Installation

  * Dependency - install tables for DBMS_PROFILER in schema

  1. Connect to target schema
  2. @install

## Note

  SQL scripts are in directory Application/SQL_scripts

## Example

  Directory test show example use Quilt appication (Oracle 12c)

  1. connect to databese - SQLPLUS (test directory)
  2. @install.sql
  3. @run.sql 
    * set spying objects - exec quilt_codecoverage_pkg.set_SpyingObject('&schem','&obj_name','&obj_type') 
    * start profiling - @coverage_start "Test name"
    * run test - @test
    * stop profiling - @coverage_stop
    * export source from database - @coverage_export_all_src
    * create and export report - @coverage_export_report