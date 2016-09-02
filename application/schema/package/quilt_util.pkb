CREATE OR REPLACE PACKAGE BODY quilt_util IS

    SPACE     CONSTANT VARCHAR2(1) := ' ';
    BRACKET   CONSTANT VARCHAR2(1) := '(';
    SEMICOLON CONSTANT VARCHAR2(1) := ';';

    ----------------------------------------------------------------------------
    FUNCTION objectExists
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2
    ) RETURN BOOLEAN IS
        l_Result NUMBER;
    BEGIN
        SELECT Count(*)
          INTO l_Result
          FROM all_objects t
         WHERE t.owner = p_owner
           AND t.object_name = p_object_name;
        --
        RETURN TRUE;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END objectExists;

    ----------------------------------------------------------------------------
    FUNCTION getPLSQLOptimizeLevel
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2
    ) RETURN BINARY_INTEGER IS
        l_Result NUMBER;
    BEGIN
        SELECT plsql_optimize_level
          INTO l_Result
          FROM all_plsql_object_settings t
         WHERE t.owner = p_owner
           AND t.name = p_object_name
           AND t.type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                          quilt_const.OBJ_TYPE_TYPE_BODY,
                          quilt_const.OBJ_TYPE_PROCEDURE,
                          quilt_const.OBJ_TYPE_FUNCTION,
                          quilt_const.OBJ_TYPE_TRIGGER);
        --
        RETURN l_Result;
        --
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN l_Result;
    END getPLSQLOptimizeLevel;

    ----------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevelImpl
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2,
        p_level       IN NUMBER DEFAULT PLSQL_OPTIMIZE_LEVEL_1
    ) IS
        lc_sqlTemplate CONSTANT VARCHAR2(128) := 'alter #objectType# #schemaName#.#objectName# #compile# PLSQL_OPTIMIZE_LEVEL=#level#';
        l_ObjectType VARCHAR2(30);
        l_compile    VARCHAR2(400);
        l_sql        VARCHAR2(4000);
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1, p_object_name=$2, p_object_type=$3, p_level=$4',
                                p_owner,
                                p_object_name,
                                p_object_type,
                                p_level);
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
        quilt_logger.log_detail('l_sql', l_sql);
        --
        EXECUTE IMMEDIATE l_sql;
        quilt_logger.log_detail('end:$1 $2.$3 compiled with PLSQL_OPTIMIZE_LEVEL=$4', p_object_type, p_owner, p_object_name, p_level);
    END setPLSQLOptimizeLevelImpl;

    ----------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevel
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_level       IN NUMBER
    ) IS
        ltab_objectList quilt_object_list_type;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1, p_object_name=$2, p_level=$3', p_owner, p_object_name, p_level);
        -- check level first
        IF p_level IN (PLSQL_OPTIMIZE_LEVEL_0, PLSQL_OPTIMIZE_LEVEL_1, PLSQL_OPTIMIZE_LEVEL_2, PLSQL_OPTIMIZE_LEVEL_3) THEN
            -- get both header/spec in case of package/type
            ltab_objectList := getObjectList(p_owner, p_object_name);
            --
            FOR idx IN 1 .. ltab_objectList.count LOOP
                IF ltab_objectList(idx).object_type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                                    quilt_const.OBJ_TYPE_TYPE_BODY,
                                    quilt_const.OBJ_TYPE_PROCEDURE,
                                    quilt_const.OBJ_TYPE_FUNCTION,
                                    quilt_const.OBJ_TYPE_TRIGGER) THEN
                    setPLSQLOptimizeLevelImpl(p_owner       => ltab_objectList(idx).schema_name,
                                              p_object_name => ltab_objectList(idx).object_name,
                                              p_object_type => ltab_objectList(idx).object_type,
                                              p_level       => p_level);
                ELSE
                    -- NoFormat Start
                    raise_application_error(-20000,
                                            formatString('$1 $2.$3 is not PLSQL object. Cannot set PLSQL Optimize level',
                                                         ltab_objectList(idx).object_type,
                                                         ltab_objectList(idx).schema_name,
                                                         ltab_objectList(idx).object_name)
                                           );
                    -- NoFormat End
                END IF;
            END LOOP;
        ELSE
            raise_application_error(-20000, 'Unsupported PLSQL Optimize level: ' || p_level);
        END IF;
        quilt_logger.log_detail('end');
    END setPLSQLOptimizeLevel;

    ---------------------------------------------------------------------------
    PROCEDURE setPLSQLOptimizeLevelAll(p_level IN NUMBER) IS
        l_sessionId NUMBER := quilt_core.get_SESSIONID;
        l_SID       NUMBER := quilt_core.get_SID;
        l_level     NUMBER;
    BEGIN
        quilt_logger.log_detail('begin');
        BEGIN
            FOR reportedObject IN (SELECT *
                                     FROM quilt_reported_object t
                                    WHERE t.sessionid = l_sessionId
                                      AND t.sid = l_SID) LOOP
                IF objectExists(reportedObject.owner, reportedObject.object_name) THEN
                    l_level := getPLSQLOptimizeLevel(reportedObject.owner, reportedObject.object_name);
                    IF NOT l_level = p_level THEN
                        setPLSQLOptimizeLevelImpl(p_owner       => reportedObject.owner,
                                                  p_object_name => reportedObject.object_name,
                                                  p_object_type => reportedObject.object_type,
                                                  p_level       => p_level);
                    ELSE
                        quilt_logger.log_detail('$1 $2.$3 already has level=$4',
                                                reportedObject.object_type,
                                                reportedObject.owner,
                                                reportedObject.object_name,
                                                l_level);
                    END IF;
                ELSE
                    quilt_logger.log_detail('Object $1 $2.$3 does not exist.',
                                            reportedObject.object_type,
                                            reportedObject.owner,
                                            reportedObject.object_name);
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
                -- todo spravne osetreni
                quilt_logger.log_detail('Unhandled exception:', substr(SQLERRM, 1, 2000));
        END;
        quilt_logger.log_detail('end');
    END setPLSQLOptimizeLevelAll;

    ----------------------------------------------------------------------------  
    FUNCTION getMethodName(p_textLine IN VARCHAR2) RETURN VARCHAR2 IS
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
    END getMethodName;

    ----------------------------------------------------------------------------
    FUNCTION getObject
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2
    ) RETURN quilt_object_type IS
        lobj_result quilt_object_type;
    BEGIN
        quilt_logger.log_detail('begin: p_owner=$1, p_object_name=$2', p_owner, p_object_name);
        --
        BEGIN
            SELECT quilt_object_type(OWNER, object_name, object_type)
              INTO lobj_result
              FROM all_objects
             WHERE OWNER LIKE '%' || upper(p_owner) || '%'
               AND object_name LIKE '%' || upper(p_object_name) || '%';
        EXCEPTION
            WHEN no_data_found THEN
                quilt_logger.log_detail('not found');
                lobj_result := NULL;
        END;
        --    
        quilt_logger.log_detail('end');
        RETURN lobj_result;
        --
    END getObject;

    ----------------------------------------------------------------------------
    FUNCTION getObjectList
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2
    ) RETURN quilt_object_list_type IS
        ltab_result quilt_object_list_type;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1,p_object_name=$2,p_object_type=$3', p_owner, p_object_name);
        --
        SELECT quilt_object_type(OWNER, object_name, object_type)
          BULK COLLECT
          INTO ltab_result
          FROM all_objects
         WHERE OWNER LIKE upper(p_owner) ESCAPE '/'
           AND object_name LIKE upper(p_object_name) ESCAPE '/'
           AND object_type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                               quilt_const.OBJ_TYPE_TYPE_BODY,
                               quilt_const.OBJ_TYPE_PROCEDURE,
                               quilt_const.OBJ_TYPE_FUNCTION,
                               quilt_const.OBJ_TYPE_TRIGGER);
        --    
        quilt_logger.log_detail('end');
        RETURN ltab_result;
        --
    END getObjectList;

    ----------------------------------------------------------------------------
    FUNCTION contains
    (
        p_string IN VARCHAR2,
        p_lookup IN VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
        RETURN instr(p_string, p_lookup) > 0;
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

    ----------------------------------------------------------------------------
    FUNCTION formatString
    (
        p_string        IN VARCHAR2,
        p_placeholder1  IN VARCHAR2 DEFAULT NULL,
        p_placeholder2  IN VARCHAR2 DEFAULT NULL,
        p_placeholder3  IN VARCHAR2 DEFAULT NULL,
        p_placeholder4  IN VARCHAR2 DEFAULT NULL,
        p_placeholder5  IN VARCHAR2 DEFAULT NULL,
        p_placeholder6  IN VARCHAR2 DEFAULT NULL,
        p_placeholder7  IN VARCHAR2 DEFAULT NULL,
        p_placeholder8  IN VARCHAR2 DEFAULT NULL,
        p_placeholder9  IN VARCHAR2 DEFAULT NULL,
        p_placeholder10 IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS
        Type tab IS TABLE OF VARCHAR2(255);
        ltab_args tab;
        l_Result  VARCHAR2(4000) := p_string;
    BEGIN
        -- create collection from args
        -- NoFormat Start        
        ltab_args := tab(p_placeholder1,
                         p_placeholder2,
                         p_placeholder3,
                         p_placeholder4,
                         p_placeholder5,
                         p_placeholder6,
                         p_placeholder7,
                         p_placeholder8,
                         p_placeholder9,
                         p_placeholder10);
        -- NoFormat End                         
        -- foreach arg
        FOR argIdx IN REVERSE 1 .. 10 LOOP
            -- if string contains plaaceholder $1, $2, ...
            IF regexp_like(l_Result, '\$' || argIdx) THEN
                -- replace placeholder with placeholder value
                l_Result := regexp_replace(l_Result, '\$' || argIdx, ltab_args(argIdx));
            ELSIF ltab_args(argIdx) IS NOT NULL THEN
                -- else append to string if placeholder value is not null
                l_Result := l_Result || ' ' || ltab_args(argIdx);
            END IF;
        END LOOP;
        --
        RETURN l_Result;
        --
    END formatString;

END quilt_util;
/
