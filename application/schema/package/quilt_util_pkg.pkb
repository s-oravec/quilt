CREATE OR REPLACE PACKAGE BODY quilt_util_pkg IS

  -- Private type declarations

  
  -- Private constant declarations

  -- todo presun do const package
  DML_AL                CONSTANT VARCHAR2(10) := 'ALTER';
  PL_LEVEL1             CONSTANT VARCHAR2(50) := 'PLSQL_OPTIMIZE_LEVEL=1';
  PL_LEVEL2             CONSTANT VARCHAR2(50) := 'PLSQL_OPTIMIZE_LEVEL=2';
  SPACE                 CONSTANT VARCHAR2(10) := ' ';
  --
  PKG_HEADER_TYPE       CONSTANT VARCHAR2(30) := 'PACKAGE';
  PKG_BODY_TYPE         CONSTANT VARCHAR2(30) := 'PACKAGE BODY';


  -- Private variable declarations


  -- Function and procedure implementations

-- check
-- select * from user_plsql_object_settings t where t.name = upper('&n');

  /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 1 */
  PROCEDURE set_Level1(p_obj_name IN VARCHAR2, p_obj_type IN VARCHAR2) IS

      ltxt_type    VARCHAR2(400) := CASE WHEN upper(p_obj_type) IN (PKG_HEADER_TYPE, PKG_BODY_TYPE) THEN PKG_HEADER_TYPE ELSE upper(p_obj_type) END;
      ltxt_comp    VARCHAR2(400) := CASE WHEN upper(p_obj_type) = PKG_BODY_TYPE THEN 'COMPILE BODY' ELSE 'COMPILE' END;
      ltxt_sql     VARCHAR2(4000);
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.set_Level1');

      ltxt_sql := DML_AL || SPACE || ltxt_type || SPACE || p_obj_name || SPACE || ltxt_comp || SPACE || PL_LEVEL1;
      -- todo debug
      --dbms_output.put_line(ltxt_sql);
      EXECUTE IMMEDIATE ltxt_sql;
  END set_Level1;

  /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 2 */
  PROCEDURE set_Level2(p_obj_name IN VARCHAR2, p_obj_type IN VARCHAR2) IS

      ltxt_type    VARCHAR2(400) := CASE WHEN upper(p_obj_type) IN (PKG_HEADER_TYPE, PKG_BODY_TYPE) THEN PKG_HEADER_TYPE ELSE upper(p_obj_type) END;
      ltxt_comp    VARCHAR2(400) := CASE WHEN upper(p_obj_type) = PKG_BODY_TYPE THEN 'COMPILE BODY' ELSE 'COMPILE' END;
      ltxt_sql     VARCHAR2(4000);
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.set_Level2');

      ltxt_sql := DML_AL || SPACE || ltxt_type || SPACE || p_obj_name || SPACE || ltxt_comp || SPACE || PL_LEVEL2;
      -- todo debug
      --dbms_output.put_line(ltxt_sql);      --
      EXECUTE IMMEDIATE ltxt_sql;
  END set_Level2;

  /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
  PROCEDURE set_Level(p_obj_name IN VARCHAR2, p_obj_type IN VARCHAR2 DEFAULT NULL, p_level IN NUMBER DEFAULT 1) IS
      
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.set_Level');

      IF p_obj_type IN (PKG_HEADER_TYPE, PKG_BODY_TYPE) THEN
          IF p_level = 1 THEN
              set_Level1(p_obj_name,p_obj_type);
          ELSIF p_level = 2 THEN
              set_Level2(p_obj_name,p_obj_type);
          END IF;
      ELSIF p_obj_type IS NULL THEN
          IF p_level = 1 THEN
              set_Level1(p_obj_name,PKG_HEADER_TYPE);
              set_Level1(p_obj_name,PKG_BODY_TYPE);
          ELSIF p_level = 2 THEN
              set_Level2(p_obj_name,PKG_HEADER_TYPE);
              set_Level2(p_obj_name,PKG_BODY_TYPE);
          END IF;
      END IF;
      
  END set_Level;

  /** compile all objects for spying list - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
  PROCEDURE set_LevelAll(p_level IN NUMBER DEFAULT 1) IS

      lint_sessionid NUMBER := quilt_core_pkg.get_SESSIONID;
      lint_sid       NUMBER := quilt_core_pkg.get_SID;
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.set_LevelAll');

      BEGIN
          FOR i IN (SELECT --t.object_schema,
                           t.object_name,
                           t.object_type
                      FROM quilt_methods t
                     WHERE t.sessionid = lint_sessionid
                       AND t.sid = lint_sid)
          LOOP
              set_Level(p_obj_name => i.object_name,
                        p_obj_type => i.object_type,
                        p_level    => p_level);
          END LOOP;       
      EXCEPTION
          WHEN OTHERS THEN
              NULL;
              -- todo spravne osetreni
      END;      
  END set_LevelAll;

END quilt_util_pkg;
/
