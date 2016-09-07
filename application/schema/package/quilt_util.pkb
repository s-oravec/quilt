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
    
        l_result VARCHAR2(4000);
        l_start  NUMBER;
        l_end_s  NUMBER;
        l_end_b  NUMBER;
        l_end_c  NUMBER;
        l_end3   NUMBER;
    BEGIN
        -- najdi funkci
        l_start := instr(upper(p_textline), C_FUNCT);
        IF l_start = 0 THEN
            -- najdi proceduru
            l_start := instr(upper(p_textline), C_PROCE);
            IF l_start = 0 THEN
                RETURN NULL;
            END IF;
            -- je procedura
            l_end_s := instr(upper(p_textline), SPACE, l_start + C_PROCE_LEN + 1);
            l_end_b := instr(upper(p_textline), BRACKET, l_start + C_PROCE_LEN + 1);
            l_end_c := instr(upper(p_textline), SEMICOLON, l_start + C_PROCE_LEN + 1);
        
            IF l_end_s <> 0 AND l_end_b <> 0 AND l_end_c <> 0 THEN
                l_end3 := least(l_end_s, l_end_b, l_end_c) - (l_start + C_PROCE_LEN);
            ELSIF l_end_s = 0 AND l_end_b <> 0 AND l_end_c <> 0 THEN
                l_end3 := least(l_end_b, l_end_c) - (l_start + C_PROCE_LEN);
            ELSIF l_end_s <> 0 AND l_end_b = 0 AND l_end_c <> 0 THEN
                l_end3 := least(l_end_s, l_end_c) - (l_start + C_PROCE_LEN);
            ELSIF l_end_s <> 0 AND l_end_b <> 0 AND l_end_c = 0 THEN
                l_end3 := least(l_end_s, l_end_b) - (l_start + C_PROCE_LEN);
            ELSIF l_end_s = 0 AND l_end_b = 0 AND l_end_c <> 0 THEN
                l_end3 := l_end_c - (l_start + C_PROCE_LEN);
            ELSIF l_end_s = 0 AND l_end_b <> 0 AND l_end_c = 0 THEN
                l_end3 := l_end_b - (l_start + C_PROCE_LEN);
            ELSIF l_end_s <> 0 AND l_end_b = 0 AND l_end_c = 0 THEN
                l_end3 := l_end_s - (l_start + C_PROCE_LEN);
            ELSE
                l_end3 := length(p_textline) - (l_start + C_PROCE_LEN);
            END IF;
            -- l_end3 >30: chybka
            l_result := TRIM(REPLACE(REPLACE(REPLACE(TRIM(substr(p_textline, l_start + C_PROCE_LEN + 1, l_end3)), '(', ''),
                                                ' ',
                                                ''),
                                        ';',
                                        ''));
            IF ascii(substr(l_result, length(l_result))) = 10 THEN
                l_result := substr(l_result, 1, length(l_result) - 1);
            END IF;
        ELSE
            -- je funkce
            l_end_s := instr(upper(p_textline), SPACE, l_start + C_FUNCT_LEN + 1);
            l_end_b := instr(upper(p_textline), BRACKET, l_start + C_FUNCT_LEN + 1);
            l_end_c := instr(upper(p_textline), SEMICOLON, l_start + C_FUNCT_LEN + 1);
        
            IF l_end_s <> 0 AND l_end_b <> 0 AND l_end_c <> 0 THEN
                l_end3 := least(l_end_s, l_end_b, l_end_c) - (l_start + C_FUNCT_LEN);
            ELSIF l_end_s = 0 AND l_end_b <> 0 AND l_end_c <> 0 THEN
                l_end3 := least(l_end_b, l_end_c) - (l_start + C_FUNCT_LEN);
            ELSIF l_end_s <> 0 AND l_end_b = 0 AND l_end_c <> 0 THEN
                l_end3 := least(l_end_s, l_end_c) - (l_start + C_FUNCT_LEN);
            ELSIF l_end_s <> 0 AND l_end_b <> 0 AND l_end_c = 0 THEN
                l_end3 := least(l_end_s, l_end_b) - (l_start + C_FUNCT_LEN);
            ELSIF l_end_s = 0 AND l_end_b = 0 AND l_end_c <> 0 THEN
                l_end3 := l_end_c - (l_start + C_FUNCT_LEN);
            ELSIF l_end_s = 0 AND l_end_b <> 0 AND l_end_c = 0 THEN
                l_end3 := l_end_b - (l_start + C_FUNCT_LEN);
            ELSIF l_end_s <> 0 AND l_end_b = 0 AND l_end_c = 0 THEN
                l_end3 := l_end_s - (l_start + C_FUNCT_LEN);
            ELSE
                l_end3 := length(p_textline) - (l_start + C_FUNCT_LEN);
            END IF;
            l_result := TRIM(REPLACE(REPLACE(REPLACE(TRIM(substr(p_textline, l_start + C_FUNCT_LEN + 1, l_end3)), '(', ''),
                                                ' ',
                                                ''),
                                        ';',
                                        ''));
            IF ascii(substr(l_result, length(l_result))) = 10 THEN
                l_result := substr(l_result, 1, length(l_result) - 1);
            END IF;
        END IF;
    
        RETURN TRIM(l_result);
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
        Type tab IS TABLE OF VARCHAR2(4000);
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

    ----------------------------------------------------------------------------
    PROCEDURE save_profiler_data(p_data IN typ_profiler_data_tab) IS
    BEGIN
        FORALL idx IN 1 .. p_data.count
            INSERT INTO quilt_profiler_data VALUES p_data (idx);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE save_profiler_units(p_units IN typ_profiler_units_tab) IS
    BEGIN
        FORALL idx IN 1 .. p_units.count
            INSERT INTO quilt_profiler_units VALUES p_units (idx);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE save_profiler_runs(p_runs IN typ_profiler_runs_tab) IS
    BEGIN
        FORALL idx IN 1 .. p_runs.count
            INSERT INTO quilt_profiler_runs VALUES p_runs (idx);
    END;

END quilt_util;
/
