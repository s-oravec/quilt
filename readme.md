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