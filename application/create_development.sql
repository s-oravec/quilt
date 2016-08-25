rem Quilt 0.1.0
define g_quilt_dev_schema = "QUILT_000100_DEV"

rem Quilt Development Schema
prompt create new &&g_quilt_dev_schema user
CREATE USER &&g_quilt_dev_schema IDENTIFIED BY &&g_quilt_dev_schema
  DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

GRANT CONNECT TO &&g_quilt_dev_schema;
GRANT CREATE TABLE to &&g_quilt_dev_schema;
GRANT CREATE PROCEDURE to &&g_quilt_dev_schema;
GRANT CREATE TYPE to &&g_quilt_dev_schema;
GRANT CREATE SEQUENCE TO &&g_quilt_dev_schema;
GRANT CREATE VIEW TO &&g_quilt_dev_schema;
GRANT CREATE SYNONYM TO &&g_quilt_dev_schema;

--testing only
GRANT DEBUG CONNECT SESSION TO &&g_quilt_dev_schema;



