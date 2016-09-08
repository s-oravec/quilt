connect QUILT_000100_DEV/QUILT_000100_DEV@local

set serveroutput on size unlimited format wrapped
set trimspool on
set linesize 4000
set echo off
set feedback off
set verify off
set heading off
set auto off
set term off
set pages 0
set long 32767
set longchunk 32767


rem Enable CodeCoverage report for QUILT_000100_DEV
exec quilt.enable_report(user);

rem QUILT_000100_DEV only
rem this would get called internally by quilt.start_profiling, but of course you can't recompile object that is
rem being executed so, we have to recompile quilt objects beforehand
DECLARE
    PROCEDURE setPLSQLOptimizeLevelImpl
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN NUMBER DEFAULT 1
    ) IS
        lc_sqlTemplate CONSTANT VARCHAR2(128) := 'alter #objectType# #schemaName#.#objectName# #compile# PLSQL_OPTIMIZE_LEVEL=#level#';
        l_ObjectType VARCHAR2(30);
        l_compile    VARCHAR2(400);
        l_sql        VARCHAR2(4000);
    BEGIN
        l_ObjectType := regexp_substr(upper(p_object_type), '[^ ]+', 1, 1);
        l_compile := CASE
                         WHEN regexp_substr(upper(p_object_type), '[^ ]+', 1, 2) = 'BODY' THEN
                          'COMPILE BODY'
                         ELSE
                          'COMPILE'
                     END;
        --
        l_sql := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lc_sqlTemplate, '#level#', p_level), '#objectType#', l_ObjectType),
                                         '#schemaName#',
                                         p_owner),
                                 '#objectName#',
                                 p_object_name),
                         '#compile#',
                         l_compile);
        dbms_output.put_line(l_sql);
        EXECUTE IMMEDIATE l_sql;
    END setPLSQLOptimizeLevelImpl;
BEGIN
    FOR plsqlObject IN (SELECT OWNER, object_name, object_type
                          FROM all_objects
                         WHERE OWNER = 'QUILT_000100_DEV'
                           AND USER = 'QUILT_000100_DEV'
                           AND object_type IN ('PACKAGE BODY', 'TYPE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER')) LOOP
        setPLSQLOptimizeLevelImpl(plsqlObject.owner, plsqlObject.object_name, plsqlObject.object_type, 1);
    END LOOP;
END;
/

rem Start profiling
exec quilt.start_profiling;

rem Do your tests or what ...
exec pete.run(user);

rem Stop profiling
exec quilt.stop_profiling;

rem Generate report from profiling data
exec quilt.generate_report;

rem Export report into report/lcov.info file
@@quilt_export_report.sql

rem Export sources of reported objects into report/src
@@quilt_export_all_src.sql

rem First build docker container with LCOV
host docker build -t lcov .

rem Then start docker container and mount pwd to /tmp
host docker run -itd --name quilt-lcov -v `pwd`:/tmp lcov /bin/bash

rem And generate HTML report
host docker exec quilt-lcov /tmp/docker_gen_script.sh

rem Open report in your web browser
host open report/html/index.html

exit
