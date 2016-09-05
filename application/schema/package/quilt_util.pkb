CREATE OR REPLACE PACKAGE BODY quilt_util IS

    SPACE     CONSTANT VARCHAR2(1) := ' ';
    BRACKET   CONSTANT VARCHAR2(1) := '(';
    SEMICOLON CONSTANT VARCHAR2(1) := ';';

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

    ----------------------------------------------------------------------------
    FUNCTION next_run_id RETURN INTEGER IS
    BEGIN
        RETURN quilt_run_id.nextval;
    END;

END quilt_util;
/
