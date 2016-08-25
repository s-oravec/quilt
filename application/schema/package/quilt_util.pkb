CREATE OR REPLACE PACKAGE BODY quilt_util IS

    -- todo presun do const package
    SPACE     CONSTANT VARCHAR2(1) := ' ';
    BRACKET   CONSTANT VARCHAR2(1) := '(';
    SEMICOLON CONSTANT VARCHAR2(1) := ';';
    LEVEL1    CONSTANT NUMBER := 1;
    LEVEL2    CONSTANT NUMBER := 2;
    --
    PACKAGE_SPECIFICATION CONSTANT VARCHAR2(30) := 'PACKAGE';
    PACKAGE_BODY          CONSTANT VARCHAR2(30) := 'PACKAGE BODY';

    ----------------------------------------------------------------------------
    FUNCTION check_Level
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN NUMBER
    ) RETURN BOOLEAN IS
        l_Result NUMBER;
    BEGIN
        SELECT Count(*)
          INTO l_Result
          FROM all_plsql_object_settings t
         WHERE t.owner = p_schema_name
           AND t.name = p_object_name
           AND t.type = p_object_type
           AND t.plsql_optimize_level = p_level;
        --
        RETURN TRUE;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END check_Level;

    ----------------------------------------------------------------------------
    FUNCTION check_ExistObject
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN BOOLEAN IS
        l_Result NUMBER;
    BEGIN
        SELECT Count(*)
          INTO l_Result
          FROM all_objects t
         WHERE t.owner = p_schema_name
           AND t.object_name = p_object_name
           AND t.object_type = p_object_type;
        --
        RETURN TRUE;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END check_ExistObject;

    ----------------------------------------------------------------------------
    FUNCTION get_Level
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN NUMBER IS
        l_Result NUMBER;
    BEGIN
        SELECT plsql_optimize_level
          INTO l_Result
          FROM all_plsql_object_settings t /*user_plsql_object_settings*/
         WHERE t.owner = p_schema_name
           AND t.name = p_object_name
           AND t.type = p_object_type;
        --
        RETURN l_Result;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN l_Result;
    END get_Level;

    ----------------------------------------------------------------------------
    PROCEDURE set_LevelImpl
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN INTEGER
    ) IS
        lc_sqlTemplate CONSTANT VARCHAR2(128) := 'alter #objectType# #schemaName#.#objectName# #compile# PLSQL_OPTIMIZE_LEVEL=#level#';
        l_ObjectType VARCHAR2(400) := CASE
                                          WHEN upper(p_object_type) IN (PACKAGE_SPECIFICATION, PACKAGE_BODY) THEN
                                           PACKAGE_SPECIFICATION
                                          ELSE
                                           upper(p_object_type)
                                      END;
        l_compile VARCHAR2(400) := CASE
                                       WHEN upper(p_object_type) = PACKAGE_BODY THEN
                                        'COMPILE BODY'
                                       ELSE
                                        'COMPILE'
                                   END;
        l_sql        VARCHAR2(4000);
    BEGIN
        quilt_logger.log_detail('begin');
        --
        l_sql := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lc_sqlTemplate, '#level#', p_level), '#objectType#', l_ObjectType),
                                         '#schemaName#',
                                         p_schema_name),
                                 '#objectName#',
                                 p_object_name),
                         '#compile#',
                         l_compile);
        quilt_logger.log_detail('l_sql', l_sql);
        --
        EXECUTE IMMEDIATE l_sql;
        quilt_logger.log_detail('end:$1 $2.$3 compiled with PLSQL_OPTIMIZE_LEVEL=$4', p_object_type, p_schema_name, p_object_name, p_level);
    END set_LevelImpl;

    ----------------------------------------------------------------------------
    PROCEDURE set_Level
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN NUMBER
    ) IS
    
    BEGIN
        quilt_logger.log_detail('begin:p_schema_name=$1, p_object_name=$2, p_object_type=$3, p_level=$4',
                                p_schema_name,
                                p_object_name,
                                p_object_type,
                                p_level);
        IF p_level IN (LEVEL1, LEVEL2) THEN
            IF p_object_type IN (PACKAGE_SPECIFICATION, PACKAGE_BODY) THEN
                set_LevelImpl(p_schema_name, p_object_name, p_object_type, p_level);
            ELSIF p_object_type IS NULL THEN
                set_LevelImpl(p_schema_name, p_object_name, PACKAGE_SPECIFICATION, p_level);
                set_LevelImpl(p_schema_name, p_object_name, PACKAGE_BODY, p_level);
            ELSE
                raise_application_error(-20000, 'Unsupported object type: ' || p_object_type);
            END IF;
        ELSE
            raise_application_error(-20000, 'Unsupported PLSQL Optimize level: ' || p_level);
        END IF;
        quilt_logger.log_detail('end');
    END set_Level;

    ----------------------------------------------------------------------------
    PROCEDURE set_LevelAll(p_level IN NUMBER) IS
        l_sessionId NUMBER := quilt_core.get_SESSIONID;
        l_SID       NUMBER := quilt_core.get_SID;
        l_level     NUMBER;
    BEGIN
        quilt_logger.log_detail('begin');
        BEGIN
            FOR spiedObject IN (SELECT t.object_schema, t.object_name, t.object_type
                                  FROM quilt_methods t
                                 WHERE t.sessionid = l_sessionId
                                   AND t.sid = l_SID) LOOP
                IF check_ExistObject(spiedObject.object_schema, spiedObject.object_name, spiedObject.object_type) THEN
                    l_level := get_Level(spiedObject.object_schema, spiedObject.object_name, spiedObject.object_type);
                    IF NOT l_level = p_level THEN
                        set_Level(p_schema_name => spiedObject.object_schema,
                                  p_object_name => spiedObject.object_name,
                                  p_object_type => spiedObject.object_type,
                                  p_level       => p_level);
                    ELSE
                        quilt_logger.log_detail('$1 $2.$3 already has level=$4',
                                                spiedObject.object_type,
                                                spiedObject.object_schema,
                                                spiedObject.object_name,
                                                l_level);
                    END IF;
                ELSE
                    quilt_logger.log_detail('Object $1 $2.$3 does not exist.',
                                            spiedObject.object_type,
                                            spiedObject.object_schema,
                                            spiedObject.object_name);
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
                -- todo spravne osetreni
                quilt_logger.log_detail('Unhandled exception:', substr(SQLERRM, 1, 2000));
        END;
        quilt_logger.log_detail('end');
    END set_LevelAll;

    ----------------------------------------------------------------------------  
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
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2 DEFAULT NULL
    ) RETURN quilt_object_list_type IS
    
        ltxt_schema  all_objects.owner%Type := upper(p_schema_name);
        ltxt_objname all_objects.object_name%Type := upper(p_object_name);
        ltxt_objtype all_objects.object_type%Type := upper(p_object_type);
        ltab_objs    quilt_object_list_type;
        l_sql        VARCHAR2(4000) := 'SELECT quilt_object_type(owner, object_name, object_type) FROM all_objects ';
        l_sql_w1     VARCHAR2(100) := q'{ WHERE owner = :schema  }';
        l_sql_w11    VARCHAR2(100) := q'{ WHERE owner LIKE '%'|| :schema ||'%' }';
        l_sql_w2     VARCHAR2(100) := q'{ AND object_name = :objname }';
        l_sql_w21    VARCHAR2(100) := q'{ AND object_name LIKE '%'|| :objname ||'%' }';
        l_sql_w3     VARCHAR2(100) := q'{ AND object_type = :objtype }';
        l_sql_w31    VARCHAR2(100) := q'{ AND object_type LIKE '%'|| :objtype ||'%' }';
        l_sql_w4     VARCHAR2(100) := ' AND object_type IN (SELECT /*+ RESULT_CACHE */ DISTINCT type FROM all_source)';
    BEGIN
        quilt_logger.log_detail($$PLSQL_UNIT || '.getObjectList');
        --
        IF NOT contains(ltxt_schema) THEN
            l_sql := l_sql || l_sql_w1;
        ELSE
            l_sql := l_sql || l_sql_w11;
        END IF;
        IF NOT contains(ltxt_objname) THEN
            l_sql := l_sql || l_sql_w2;
        ELSE
            l_sql := l_sql || l_sql_w21;
        END IF;
        IF NOT contains(ltxt_objtype) THEN
            l_sql := l_sql || l_sql_w3;
        ELSE
            l_sql := l_sql || l_sql_w31;
        END IF;
        l_sql := l_sql || l_sql_w4;
        EXECUTE IMMEDIATE l_sql BULK COLLECT
            INTO ltab_objs
            USING ltxt_schema, ltxt_objname, ltxt_objtype;
    
        RETURN ltab_objs;
    END getObjectList;

    ----------------------------------------------------------------------------
    FUNCTION contains
    (
        p_string IN VARCHAR2,
        p_char   IN VARCHAR2
    ) RETURN BOOLEAN IS
    
    BEGIN
        RETURN instr(p_string, p_char) > 0;
    END contains;

    ----------------------------------------------------------------------------
    FUNCTION getCallerQualifiedName RETURN VARCHAR2 IS
        ltab_qualifiedName utl_call_stack.unit_qualified_name;
        l_Result           VARCHAR2(255);
        e_BadDepthIndicator EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_BadDepthIndicator, -64610);
    BEGIN
        ltab_qualifiedName := utl_call_stack.subprogram(dynamic_depth => 3);
        --
        FOR idx IN 1 .. ltab_qualifiedName.count LOOP
            l_Result := l_Result || '.' || ltab_qualifiedName(idx);
        END LOOP;
        --  
        RETURN ltrim(l_Result, '.');
    EXCEPTION
        WHEN e_BadDepthIndicator THEN
            RETURN 'TOP_LEVEL_BLOCK';
    END;

    ----------------------------------------------------------------------------
    FUNCTION getCurrentQualifiedName RETURN VARCHAR2 IS
        ltab_qualifiedName utl_call_stack.unit_qualified_name;
        l_Result           VARCHAR2(255);
    BEGIN
        ltab_qualifiedName := utl_call_stack.subprogram(dynamic_depth => 2);
        --
        FOR idx IN 1 .. ltab_qualifiedName.count LOOP
            l_Result := l_Result || '.' || ltab_qualifiedName(idx);
        END LOOP;
        --  
        RETURN ltrim(l_Result, '.');
    END;

END quilt_util;
/
