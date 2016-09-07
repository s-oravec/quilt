# Quilt - PL/SQL code coverage tool

Quilt is PL/SQL code coverage tool written in PL/SQL and SQL*Plus.
It uses [DBMS_PROFILER](http://docs.oracle.com/database/121/ARPLS/d_profil.htm#ARPLS039) supplied with Oracle Database

# How it works (will work)

  1. Implement your code & test
  2. `quilt.enable_report('OWNER', 'PACKAGE');`
  3. `quilt.start_profiling('My Coverage Test')`
  3. Run your test
  4. `dbms_profiler.stop_profiling`
  5. Spool `ALL_SOURCE` from tested schemas to `<schema>.<objectType>.<objectName>.sql`
  6. Create [LCOV file](http://ltp.sourceforge.net/coverage/lcov/geninfo.1.php) from `PLSQL_PROFILER%` tables data - reference generated source files in `lcov.info` file

# Installation

**1. Download required Oracle DB modules**

SQLSN is light weight SQL*Plus Script Toolkit

````
$ git clone https://github.com/principal-engineering/sqlsn.git oradb_modules/sqlsn
````

**2. Grant required privileges to target schema**

````
grant connect to <quilt_schema>;  
grant create table to <quilt_schema>;
grant create procedure to <quilt_schema>;
grant create type to <quilt_schema>;
grant create sequence to <quilt_schema>;
grant create view to <quilt_schema>;
grant create synonym to <quilt_schema>
````

> Optionally create dedicated schema for Quilt
>
> * first connect to database using privileged user (for granted privileges see `application/create_production.sql`)
> * then run `@create.sql production` script 

**3. Connect to target schema and install Quilt objects**

````
SQL> @install production
````

# Note

  * SQL scripts are in directory Application/SQL_scripts
  * Gen lcov report on WINDOWS, use docker

  1. copy source files, lcov.info file and shell script to <host direcory>
  2. create docker image - linux Debian
    * docker build -t my_debi <path to Dockerfile>, example:  docker build -t my_debi /c/Work/docker/debian/
  3. start docker container
    * docker run -i -t -P --name <my name> -v //<host directory>://<container directory> <image name>, example: docker run -i -t -P --name debi -v //c/Users/Henry://mnt my_debi
  4. create lcov report in docker container
    * run shell script docker_gen_script.sh

# Example

  Directory test show example use Quilt appication (Oracle 12c)

  1. connect to databese - SQLPLUS (test directory)
  2. @install.sql
  3. @run.sql 
    * set spying objects - exec quilt_codecoverage_pkg.set_SpyingObject('&schem','&obj_name','&obj_type') 
    * start profiling - @coverage_start "Test name"
    * run test - @test
    * stop profiling - @coverage_stop
    * export source from database - @coverage_export_all_src
    * create and export report (file lcov.info) - @coverage_export_report
    
# How to contribute

## Setup development environment config

Edit JSON file `config/env/development.js` with connection strings

## Create develpment environment

````
$ sqlplus sys/oracle@local @create development
````

## Install Pete for testing

Read more about Pete at github page
https://github.com/principal-engineering/pete

````
$ git clone https://github.com/principal-engineering/pete.git oradb_modules/pete
````

## Write tests using Pete

* Look at test folder for inspiration - it is super easy
* Write tests for both singleschema and multischema scenarios
    * singleschema deployment - when Quilt is deployed and executed from user that owns profiled objects
    * multischema deployment - when Quilt is deployed in its own schema, and profiling user  is different
* Implement your feature
* Test & fix & rinse & repeate until all tests passed

> PUll requests without tests will not be accepted (with exceptions for obvious reasons)

# Credits

* Henry Abeska
