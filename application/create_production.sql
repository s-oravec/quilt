whenever sqlerror exit 1 rollback

rem Quilt 0.1.0
define g_quilt_prod_schema_def       = "QUILT_000100"
define g_quilt_prod_schema_tbspc_def = "USERS"
define g_quilt_prod_temp_tbspc_def   = "TEMP"

accept g_quilt_prod_schema       prompt "Quilt schema [&&g_quilt_prod_schema_def] : " default "&&g_quilt_prod_schema_def"
accept g_quilt_prod_schema_pwd   prompt "Quilt schema password : " hide
accept g_quilt_prod_schema_tbspc prompt "Quilt schema tablespace [&&g_quilt_prod_schema_tbspc_def] : " default "&&g_quilt_prod_schema_tbspc_def"
accept g_quilt_prod_temp_tbspc   prompt "Quilt temp tablespace [&&g_quilt_prod_temp_tbspc_def] : " default "&&g_quilt_prod_temp_tbspc_def"

declare
  lc_error_message constant varchar2(255) := 'ERROR: Zero-length password not permitted.';
begin
  if '&&g_quilt_prod_schema_pwd' is null then
    dbms_output.put_line(lc_error_message);
    raise_application_error(-20000, lc_error_message);
  end if;
end;
/

prompt .. Creating Quilt schema [&&g_quilt_prod_schema] with default tablespace [&&g_quilt_prod_schema_tbspc] and temp tablespace [&&g_quilt_prod_temp_tbspc]
create user &&g_quilt_prod_schema
  identified by "&&g_quilt_prod_schema_pwd"
  default tablespace &&g_quilt_prod_schema_tbspc
  temporary tablespace &&g_quilt_prod_temp_tbspc
  quota unlimited on &&g_quilt_prod_schema_tbspc
  account unlock
/

prompt .. Granting privileges to Quilt production schema [&&g_quilt_prod_schema]

prompt .. Granting CREATE SESSION to &&g_quilt_prod_schema
grant create session to &&g_quilt_prod_schema;

prompt .. Granting CREATE TABLE to &&g_quilt_prod_schema
grant create table to &&g_quilt_prod_schema;

prompt .. Granting CREATE PROCEDURE to &&g_quilt_prod_schema
grant create procedure to &&g_quilt_prod_schema;

prompt .. Granting CREATE TYPE to &&g_quilt_prod_schema
grant create type to &&g_quilt_prod_schema;

prompt .. Granting CREATE SEQUENCE to &&g_quilt_prod_schema
grant create sequence to &&g_quilt_prod_schema;

prompt .. Granting CREATE VIEW to &&g_quilt_prod_schema
grant create view to &&g_quilt_prod_schema;