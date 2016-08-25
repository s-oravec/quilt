CREATE OR REPLACE PACKAGE BODY quilt_util_pkg IS

    -- Private type declarations

    -- Private constant declarations

    -- todo presun do const package
    DML_AL    CONSTANT VARCHAR2(10) := 'ALTER';
    PL_LEVEL1 CONSTANT VARCHAR2(50) := 'PLSQL_OPTIMIZE_LEVEL=1';
    PL_LEVEL2 CONSTANT VARCHAR2(50) := 'PLSQL_OPTIMIZE_LEVEL=2';
    SPACE     CONSTANT VARCHAR2(1) := ' ';
    DOT       CONSTANT VARCHAR2(1) := '.';
    BRACKET   CONSTANT VARCHAR2(1) := '(';
    SEMICOLON CONSTANT VARCHAR2(1) := ';';
    LEVEL1    CONSTANT NUMBER := 1;
    LEVEL2    CONSTANT NUMBER := 2;
    --
    PKG_HEADER_TYPE CONSTANT VARCHAR2(30) := 'PACKAGE';
    PKG_BODY_TYPE   CONSTANT VARCHAR2(30) := 'PACKAGE BODY';

    -- Private variable declarations

    -- Function and procedure implementations
    /** check optimalizace level */
    FUNCTION check_Level
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2,
        p_level    IN NUMBER
    ) RETURN BOOLEAN IS
    
        lint_res NUMBER;
    BEGIN
        SELECT Count(*)
          INTO lint_res
          FROM all_plsql_object_settings t /*user_plsql_object_settings*/
         WHERE t.owner = p_sch_name
           AND t.name = p_obj_name
           AND t.type = p_obj_type
           AND t.plsql_optimize_level = p_level;
    
        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END check_Level;

    /** check exists object */
    FUNCTION check_ExistObject
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2
    ) RETURN BOOLEAN IS
    
        lint_res NUMBER;
    BEGIN
        SELECT Count(*)
          INTO lint_res
          FROM all_objects t
         WHERE t.owner = p_sch_name
           AND t.object_name = p_obj_name
           AND t.object_type = p_obj_type;
    
        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END check_ExistObject;

    /** get optimalizace level for object */
    FUNCTION get_Level
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2
    ) RETURN NUMBER IS
    
        lint_res NUMBER;
    BEGIN
        SELECT plsql_optimize_level
          INTO lint_res
          FROM all_plsql_object_settings t /*user_plsql_object_settings*/
         WHERE t.owner = p_sch_name
           AND t.name = p_obj_name
           AND t.type = p_obj_type;
    
        RETURN lint_res;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN lint_res;
    END get_Level;

    /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 1 */
    PROCEDURE set_Level1
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2
    ) IS
    
        ltxt_type VARCHAR2(400) := CASE
                                       WHEN upper(p_obj_type) IN (PKG_HEADER_TYPE, PKG_BODY_TYPE) THEN
                                        PKG_HEADER_TYPE
                                       ELSE
                                        upper(p_obj_type)
                                   END;
        ltxt_comp VARCHAR2(400) := CASE
                                       WHEN upper(p_obj_type) = PKG_BODY_TYPE THEN
                                        'COMPILE BODY'
                                       ELSE
                                        'COMPILE'
                                   END;
        ltxt_sql  VARCHAR2(4000);
    BEGIN
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_Level1');
    
        ltxt_sql := DML_AL || SPACE || ltxt_type || SPACE || p_sch_name || DOT || p_obj_name || SPACE || ltxt_comp || SPACE || PL_LEVEL1;
        -- log
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_Level1: ' || ltxt_sql);
        --
        EXECUTE IMMEDIATE ltxt_sql;
    END set_Level1;

    /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 2 */
    PROCEDURE set_Level2
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2
    ) IS
    
        ltxt_type VARCHAR2(400) := CASE
                                       WHEN upper(p_obj_type) IN (PKG_HEADER_TYPE, PKG_BODY_TYPE) THEN
                                        PKG_HEADER_TYPE
                                       ELSE
                                        upper(p_obj_type)
                                   END;
        ltxt_comp VARCHAR2(400) := CASE
                                       WHEN upper(p_obj_type) = PKG_BODY_TYPE THEN
                                        'COMPILE BODY'
                                       ELSE
                                        'COMPILE'
                                   END;
        ltxt_sql  VARCHAR2(4000);
    BEGIN
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_Level2');
    
        ltxt_sql := DML_AL || SPACE || ltxt_type || SPACE || p_sch_name || DOT || p_obj_name || SPACE || ltxt_comp || SPACE || PL_LEVEL2;
        -- log
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_Level2: ' || ltxt_sql);
        --
        EXECUTE IMMEDIATE ltxt_sql;
    END set_Level2;

    /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
    PROCEDURE set_Level
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2,
        p_level    IN NUMBER
    ) IS
    
    BEGIN
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_Level');
    
        IF p_obj_type IN (PKG_HEADER_TYPE, PKG_BODY_TYPE) THEN
            IF p_level = LEVEL1 THEN
                set_Level1(p_sch_name, p_obj_name, p_obj_type);
            ELSIF p_level = LEVEL2 THEN
                set_Level2(p_sch_name, p_obj_name, p_obj_type);
            END IF;
        ELSIF p_obj_type IS NULL THEN
            IF p_level = LEVEL1 THEN
                set_Level1(p_sch_name, p_obj_name, PKG_HEADER_TYPE);
                set_Level1(p_sch_name, p_obj_name, PKG_BODY_TYPE);
            ELSIF p_level = LEVEL2 THEN
                set_Level2(p_sch_name, p_obj_name, PKG_HEADER_TYPE);
                set_Level2(p_sch_name, p_obj_name, PKG_BODY_TYPE);
            END IF;
        END IF;
    
    END set_Level;

    /** compile all objects for spying list - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
    PROCEDURE set_LevelAll(p_level IN NUMBER) IS
    
        lint_sessionid NUMBER := quilt_core_pkg.get_SESSIONID;
        lint_sid       NUMBER := quilt_core_pkg.get_SID;
        ltxt_log       VARCHAR2(1000);
    BEGIN
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_LevelAll');
    
        BEGIN
            FOR i IN (SELECT t.object_schema, t.object_name, t.object_type
                        FROM quilt_methods t
                       WHERE t.sessionid = lint_sessionid
                         AND t.sid = lint_sid) LOOP
                IF check_ExistObject(i.object_schema, i.object_name, i.object_type) AND
                   NOT check_Level(i.object_schema, i.object_name, i.object_type, p_level) THEN
                
                    set_Level(p_sch_name => i.object_schema, p_obj_name => i.object_name, p_obj_type => i.object_type, p_level => p_level);
                ELSE
                    -- log
                    ltxt_log := 'object_schema:' || i.object_schema || ' object_name:' || i.object_name || ' object_type:' || i.object_type ||
                                ' p_level:' || p_level || ' level:' || get_Level(i.object_schema, i.object_name, i.object_type);
                    quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_LevelAll !:' || ltxt_log);
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
                -- todo spravne osetreni
                quilt_log_pkg.log_detail($$PLSQL_UNIT || '.set_LevelAll !:!' || substr(SQLERRM, 1, 2000));
        END;
    END set_LevelAll;

    /** get name of method */
    FUNCTION getName(p_textline IN VARCHAR2) RETURN VARCHAR2 IS
        C_FUNCT     CONSTANT VARCHAR2(10) := 'FUNCTION';
        C_PROCE     CONSTANT VARCHAR2(10) := 'PROCEDURE';
        C_FUNCT_LEN CONSTANT NUMBER := length(C_FUNCT);
        C_PROCE_LEN CONSTANT NUMBER := length(C_PROCE);
    
        lstr_result VARCHAR2(4000);
        lint_start  NUMBER;
        lint_end_s  NUMBER;
        lint_end_b  NUMBER;
        lint_end_c  NUMBER;
        lint_end3   NUMBER;
    BEGIN
        -- najdi funkci
        lint_start := instr(upper(p_textline), C_FUNCT);
        IF lint_start = 0 THEN
            -- najdi proceduru
            lint_start := instr(upper(p_textline), C_PROCE);
            IF lint_start = 0 THEN
                RETURN NULL;
            END IF;
            -- je procedura
            lint_end_s := instr(upper(p_textline), SPACE, lint_start + C_PROCE_LEN + 1);
            lint_end_b := instr(upper(p_textline), BRACKET, lint_start + C_PROCE_LEN + 1);
            lint_end_c := instr(upper(p_textline), SEMICOLON, lint_start + C_PROCE_LEN + 1);
        
            IF lint_end_s <> 0 AND lint_end_b <> 0 AND lint_end_c <> 0 THEN
                lint_end3 := least(lint_end_s, lint_end_b, lint_end_c) - (lint_start + C_PROCE_LEN);
            ELSIF lint_end_s = 0 AND lint_end_b <> 0 AND lint_end_c <> 0 THEN
                lint_end3 := least(lint_end_b, lint_end_c) - (lint_start + C_PROCE_LEN);
            ELSIF lint_end_s <> 0 AND lint_end_b = 0 AND lint_end_c <> 0 THEN
                lint_end3 := least(lint_end_s, lint_end_c) - (lint_start + C_PROCE_LEN);
            ELSIF lint_end_s <> 0 AND lint_end_b <> 0 AND lint_end_c = 0 THEN
                lint_end3 := least(lint_end_s, lint_end_b) - (lint_start + C_PROCE_LEN);
            ELSIF lint_end_s = 0 AND lint_end_b = 0 AND lint_end_c <> 0 THEN
                lint_end3 := lint_end_c - (lint_start + C_PROCE_LEN);
            ELSIF lint_end_s = 0 AND lint_end_b <> 0 AND lint_end_c = 0 THEN
                lint_end3 := lint_end_b - (lint_start + C_PROCE_LEN);
            ELSIF lint_end_s <> 0 AND lint_end_b = 0 AND lint_end_c = 0 THEN
                lint_end3 := lint_end_s - (lint_start + C_PROCE_LEN);
            ELSE
                lint_end3 := length(p_textline) - (lint_start + C_PROCE_LEN);
            END IF;
            -- lint_end3 >30: chybka
            lstr_result := TRIM(REPLACE(REPLACE(REPLACE(TRIM(substr(p_textline, lint_start + C_PROCE_LEN + 1, lint_end3)), '(', ''),
                                                ' ',
                                                ''),
                                        ';',
                                        ''));
            IF ascii(substr(lstr_result, length(lstr_result))) = 10 THEN
                lstr_result := substr(lstr_result, 1, length(lstr_result) - 1);
            END IF;
        ELSE
            -- je funkce
            lint_end_s := instr(upper(p_textline), SPACE, lint_start + C_FUNCT_LEN + 1);
            lint_end_b := instr(upper(p_textline), BRACKET, lint_start + C_FUNCT_LEN + 1);
            lint_end_c := instr(upper(p_textline), SEMICOLON, lint_start + C_FUNCT_LEN + 1);
        
            IF lint_end_s <> 0 AND lint_end_b <> 0 AND lint_end_c <> 0 THEN
                lint_end3 := least(lint_end_s, lint_end_b, lint_end_c) - (lint_start + C_FUNCT_LEN);
            ELSIF lint_end_s = 0 AND lint_end_b <> 0 AND lint_end_c <> 0 THEN
                lint_end3 := least(lint_end_b, lint_end_c) - (lint_start + C_FUNCT_LEN);
            ELSIF lint_end_s <> 0 AND lint_end_b = 0 AND lint_end_c <> 0 THEN
                lint_end3 := least(lint_end_s, lint_end_c) - (lint_start + C_FUNCT_LEN);
            ELSIF lint_end_s <> 0 AND lint_end_b <> 0 AND lint_end_c = 0 THEN
                lint_end3 := least(lint_end_s, lint_end_b) - (lint_start + C_FUNCT_LEN);
            ELSIF lint_end_s = 0 AND lint_end_b = 0 AND lint_end_c <> 0 THEN
                lint_end3 := lint_end_c - (lint_start + C_FUNCT_LEN);
            ELSIF lint_end_s = 0 AND lint_end_b <> 0 AND lint_end_c = 0 THEN
                lint_end3 := lint_end_b - (lint_start + C_FUNCT_LEN);
            ELSIF lint_end_s <> 0 AND lint_end_b = 0 AND lint_end_c = 0 THEN
                lint_end3 := lint_end_s - (lint_start + C_FUNCT_LEN);
            ELSE
                lint_end3 := length(p_textline) - (lint_start + C_FUNCT_LEN);
            END IF;
            lstr_result := TRIM(REPLACE(REPLACE(REPLACE(TRIM(substr(p_textline, lint_start + C_FUNCT_LEN + 1, lint_end3)), '(', ''),
                                                ' ',
                                                ''),
                                        ';',
                                        ''));
            IF ascii(substr(lstr_result, length(lstr_result))) = 10 THEN
                lstr_result := substr(lstr_result, 1, length(lstr_result) - 1);
            END IF;
        END IF;
    
        RETURN TRIM(lstr_result);
    END getName;

    /** get list of objects */
    FUNCTION getObjectList
    (
        p_sch_name IN VARCHAR2,
        p_obj_name IN VARCHAR2,
        p_obj_type IN VARCHAR2 DEFAULT NULL
    ) RETURN quilt_object_list_type IS
    
        ltxt_schema  all_objects.owner%Type := upper(p_sch_name);
        ltxt_objname all_objects.object_name%Type := upper(p_obj_name);
        ltxt_objtype all_objects.object_type%Type := upper(p_obj_type);
        ltab_objs    quilt_object_list_type;
        ltxt_sql     VARCHAR2(4000) := 'SELECT quilt_object_type(owner, object_name, object_type) FROM all_objects ';
        ltxt_sql_w1  VARCHAR2(100) := q'{ WHERE owner = :schema  }';
        ltxt_sql_w11 VARCHAR2(100) := q'{ WHERE owner LIKE '%'|| :schema ||'%' }';
        ltxt_sql_w2  VARCHAR2(100) := q'{ AND object_name = :objname }';
        ltxt_sql_w21 VARCHAR2(100) := q'{ AND object_name LIKE '%'|| :objname ||'%' }';
        ltxt_sql_w3  VARCHAR2(100) := q'{ AND object_type = :objtype }';
        ltxt_sql_w31 VARCHAR2(100) := q'{ AND object_type LIKE '%'|| :objtype ||'%' }';
        ltxt_sql_w4  VARCHAR2(100) := ' AND object_type IN (SELECT /*+ RESULT_CACHE */ DISTINCT type FROM all_source)';
    BEGIN
        quilt_log_pkg.log_detail($$PLSQL_UNIT || '.getObjectList');
        --
        IF NOT checkString(ltxt_schema) THEN
            ltxt_sql := ltxt_sql || ltxt_sql_w1;
        ELSE
            ltxt_sql := ltxt_sql || ltxt_sql_w11;
        END IF;
        IF NOT checkString(ltxt_objname) THEN
            ltxt_sql := ltxt_sql || ltxt_sql_w2;
        ELSE
            ltxt_sql := ltxt_sql || ltxt_sql_w21;
        END IF;
        IF NOT checkString(ltxt_objtype) THEN
            ltxt_sql := ltxt_sql || ltxt_sql_w3;
        ELSE
            ltxt_sql := ltxt_sql || ltxt_sql_w31;
        END IF;
        ltxt_sql := ltxt_sql || ltxt_sql_w4;
        EXECUTE IMMEDIATE ltxt_sql BULK COLLECT
            INTO ltab_objs
            USING ltxt_schema, ltxt_objname, ltxt_objtype;
    
        RETURN ltab_objs;
    END getObjectList;

    /** check char in string */
    FUNCTION checkString
    (
        p_string IN VARCHAR2,
        p_char   IN VARCHAR2
    ) RETURN BOOLEAN IS
    
    BEGIN
        RETURN instr(p_string, p_char) > 0;
    END checkString;

END quilt_util_pkg;
/
