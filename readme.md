# Quilt - PL/SQL code coverage tool

Quilt is PL/SQL CodeCoverage tool written in PL/SQL and SQL*Plus.
It uses [DBMS_PROFILER](http://docs.oracle.com/database/121/ARPLS/d_profil.htm#ARPLS039) supplied with Oracle Database and generates HTML report using [LCOV](http://ltp.sourceforge.net/coverage/lcov.php)

# How it works

It is pretty obvious from this SQL*Plus script (excerpt from [`example.sql`](example.sql))

````
rem 1. Enable CodeCoverage report for objects
exec quilt.enable_report(user);

rem 2. Start profiling
exec quilt.start_profiling;

rem 3. Execute your tests
exec pete.run(user);

rem 4. Stop profiling
exec quilt.stop_profiling;

rem 5. Generate report from profiling data
exec quilt.generate_report;

rem 6. Export LCOV report into report/lcov.info file
@@quilt_export_report.sql

rem 7. Export sources of reported objects into report/src
@@quilt_export_all_src.sql

rem Now use LCOV bundled in Docker image (see Dockerfile for image definition)
rem 8. First build docker container with LCOV
host docker build -t lcov .

rem 9. Then start docker container and mount pwd to /tmp
host docker run -itd --name quilt-lcov -v `pwd`:/tmp lcov /bin/bash

rem 10. And generate HTML report
host docker exec quilt-lcov /tmp/docker_gen_script.sh

rem 11. Open report in your web browser
host open report/html/index.html

exit
````

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
> * first connect to database using privileged user (for granted privileges see [`application/create_production.sql`](application/create_production.sql))
> * then run `@create.sql production` script 

**3. Connect to target schema and install Quilt objects**

````
SQL> @install production
````

# Docker on Windows

## 1. Create Docker image using supplied [`Dockerfile`](Dockerfile)

````
docker build -t lcov .
````
    
## 2. Start Docker container

````
docker run -i -t -P --name quilt-lcov -v //%cd%://tmp lcov
````
    
## 3. Execute docker_gen_script.sh within Docker container

````
docker exec quilt-lcov /tmp/docker_gen_script.sh
````
    
# Example

See [example.sql](example.sql) for example of usage.
    
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

## Grunt task runner

> use nodejs + npm + [Grunt](http://gruntjs.com) to automate some development and CI tasks
> see [Gruntfile.js](Gruntfile.js) for all tasks

**!!! Assumes development environment has been created**

### Install packages defined in package.json

````
$ npm install
````

### Reinstall Quilt and Quilt tests

````
$ grunt reinstall reinstall_test
````

### Execute Pete tests

````
$ grunt test
````

# Credits

* Štefan Oravec
* Henry Abeska
