CREATE OR REPLACE PACKAGE quilt_util_pkg IS

  -- Author  : HENRY
  -- Created : 17.12.2015 16:46:08
  -- Purpose : PL/SQL code coverage tool
  -- Purpose : pomocne utility

  
  -- Public type declarations

  
  -- Public constant declarations


  -- Public variable declarations


  -- Public function and procedure declarations

  /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
  PROCEDURE set_Level(p_sch_name IN VARCHAR2, p_obj_name IN VARCHAR2, p_obj_type IN VARCHAR2 DEFAULT NULL, p_level IN NUMBER DEFAULT 1);

  /** compile all objects for spying list - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
  PROCEDURE set_LevelAll(p_level IN NUMBER DEFAULT 1);
  
  /** get name method */
  FUNCTION getName(p_textline IN VARCHAR2) RETURN VARCHAR2;
END quilt_util_pkg;
/