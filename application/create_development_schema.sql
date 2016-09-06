define l_schema_name="&1"

rem Quilt Development Schema
prompt create new &&l_schema_name user
CREATE USER &&l_schema_name IDENTIFIED BY &&l_schema_name
  DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

GRANT CONNECT TO &&l_schema_name;

GRANT CREATE TABLE to &&l_schema_name;
GRANT CREATE PROCEDURE to &&l_schema_name;
GRANT CREATE TYPE to &&l_schema_name;
GRANT CREATE SEQUENCE TO &&l_schema_name;
GRANT CREATE VIEW TO &&l_schema_name;
GRANT CREATE SYNONYM TO &&l_schema_name;
GRANT CREATE TRIGGER TO &&l_schema_name;

GRANT DEBUG CONNECT SESSION TO &&l_schema_name;

undefine l_schema_name