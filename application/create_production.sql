rem Quilt 1.0.0
define g_quilt_production_schema = "QUILT_000100"

--TODO: configurable tablespaces
prompt Create Quilt schema [&&g_quilt_production_schema]
CREATE USER &&g_quilt_production_schema IDENTIFIED BY &&g_quilt_production_schema
  DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

prompt Grant privileges to Quilt schema
GRANT CONNECT TO &&g_quilt_production_schema;
GRANT CREATE TABLE TO &&g_quilt_production_schema;
GRANT CREATE PROCEDURE TO &&g_quilt_production_schema;
GRANT CREATE TYPE TO &&G_quilt_production_schema;
GRANT CREATE SEQUENCE TO &&g_quilt_production_schema;
GRANT CREATE VIEW TO &&g_quilt_production_schema;