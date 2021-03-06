CREATE OR REPLACE PACKAGE BODY quilt_coverage IS

    ----------------------------------------------------------------------------
    CURSOR rcu_report(p_quilt_run_id INTEGER) IS
        WITH plsql_profiler AS
         (SELECT pu.unit_owner OWNER,
                 pu.unit_name AS Name,
                 DECODE(pu.unit_type, 'PACKAGE SPEC', 'PACKAGE', pu.unit_type) AS Type,
                 pd.line# AS Line,
                 pd.total_occur,
                 pd.total_time
            FROM quilt_profiler_units pu
           INNER JOIN quilt_profiler_data pd ON (pd.quilt_run_id = p_quilt_run_id AND pd.unit_number = pu.unit_number)
           WHERE pu.quilt_run_id = p_quilt_run_id
             AND pu.unit_type != 'ANONYMOUS BLOCK')
        SELECT qs.quilt_run_id, qs.owner, qs.name, qs.type, qs.line, qs.text, ps.total_occur, ps.total_time
          FROM quilt_reported_object_source qs
          Left OUTER JOIN plsql_profiler ps ON (ps.owner = qs.owner --
                                               AND ps.name = qs.name --
                                               AND ps.type = qs.type --
                                               AND ps.line = qs.line --
                                               )
         WHERE qs.quilt_run_id = p_quilt_run_id
         ORDER BY qs.OWNER, qs.name, qs.type, qs.line;

    ----------------------------------------------------------------------------    
    FUNCTION lines_found
    (
        p_quilt_run_id INTEGER,
        p_unitName     VARCHAR2,
        p_owner        VARCHAR2,
        p_unitType     VARCHAR2
    ) RETURN PLS_INTEGER IS
        l_Result PLS_INTEGER;
    BEGIN
        SELECT Count(1)
          INTO l_Result
          FROM quilt_profiler_units pu
         INNER JOIN quilt_profiler_data pd ON (pd.quilt_run_id = p_quilt_run_id AND pd.unit_number = pu.unit_number)
         WHERE pu.quilt_run_id = p_quilt_run_id
           AND pu.unit_name = upper(p_unitName) -- TODO: not so correct
           AND pu.unit_owner = upper(p_owner) -- TODO: not so correct
           AND pu.unit_type = upper(p_unitType) -- TODO: not so correct              
        ;
        --
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    FUNCTION lines_hit
    (
        p_quilt_run_id INTEGER,
        p_unitName     VARCHAR2,
        p_owner        VARCHAR2,
        p_unitType     VARCHAR2
    ) RETURN PLS_INTEGER IS
        l_Result PLS_INTEGER;
    BEGIN
        SELECT Count(1)
          INTO l_Result
          FROM quilt_profiler_units pu
         INNER JOIN quilt_profiler_data pd ON (pd.quilt_run_id = p_quilt_run_id AND pd.unit_number = pu.unit_number)
         WHERE pu.quilt_run_id = p_quilt_run_id
           AND pu.unit_name = upper(p_unitName) -- TODO: not so correct
           AND pu.unit_owner = upper(p_owner) -- TODO: not so correct
           AND pu.unit_type = upper(p_unitType) -- TODO: not so correct
           AND NOT (pd.total_occur = 0 AND pd.total_time = 0);
        --
        RETURN l_Result;
        --
    END;

    ----------------------------------------------------------------------------    
    PROCEDURE insert_report_line
    (
        p_quilt_run_id IN INTEGER,
        p_line         IN OUT NUMBER,
        p_text         IN VARCHAR2
    ) IS
    BEGIN
        --
        INSERT INTO quilt_report_line (quilt_run_id, Line, Text) VALUES (p_quilt_run_id, p_line, p_text);
        p_line := p_line + 1;
    END insert_report_line;

    ----------------------------------------------------------------------------
    PROCEDURE save_report
    (
        p_quilt_run_id IN INTEGER,
        p_object       IN OUT quilt_report_process_type
    ) IS
        l_idx NUMBER := p_object.idx;
        --
        PROCEDURE lproc_insRow(p_text IN VARCHAR2) IS
        BEGIN
            insert_report_line(p_quilt_run_id, l_idx, p_text);
            quilt_logger.log_detail(p_text);
        END;
        --
    BEGIN
        quilt_logger.log_detail('begin:p_quilt_run_id=$1', p_quilt_run_id);
        quilt_logger.log_detail('idx', l_idx);
        -- TN
        lproc_insRow(quilt_const.TAG_TN || p_object.tag_tn);
        -- SF
        lproc_insRow(quilt_const.TAG_SF || p_object.tag_sf);
        -- FN list
        IF p_object.tag_fn IS NOT NULL AND p_object.tag_fn.count > 0 THEN
            FOR i IN p_object.tag_fn.first .. p_object.tag_fn.last LOOP
                lproc_insRow(quilt_const.TAG_FN || p_object.tag_fn(i));
            END LOOP;
        END IF;
        -- FNDA list
        IF p_object.tag_fnda IS NOT NULL AND p_object.tag_fnda.count > 0 THEN
            FOR i IN p_object.tag_fnda.first .. p_object.tag_fnda.last LOOP
                lproc_insRow(quilt_const.TAG_FNDA || p_object.tag_fnda(i));
            END LOOP;
        END IF;
        -- FNF
        lproc_insRow(quilt_const.TAG_FNF || p_object.tag_fnf);
        -- FNH
        lproc_insRow(quilt_const.TAG_FNH || p_object.tag_fnh);
        -- BRDA list
        IF p_object.tag_brda IS NOT NULL AND p_object.tag_brda.count > 0 THEN
            FOR i IN p_object.tag_brda.first .. p_object.tag_brda.last LOOP
                lproc_insRow(quilt_const.TAG_BRDA || p_object.tag_brda(i));
            END LOOP;
        END IF;
        -- BRF
        lproc_insRow(quilt_const.TAG_BRF || p_object.tag_brf);
        -- BFH
        lproc_insRow(quilt_const.TAG_BRH || p_object.tag_brh);
        -- DA list
        IF p_object.tag_da IS NOT NULL AND p_object.tag_da.count > 0 THEN
            FOR i IN p_object.tag_da.first .. p_object.tag_da.last LOOP
                lproc_insRow(quilt_const.TAG_DA || p_object.tag_da(i));
            END LOOP;
        END IF;
        -- LH
        lproc_insRow(quilt_const.TAG_LH || p_object.tag_lh);
        -- LF
        lproc_insRow(quilt_const.TAG_LF || p_object.tag_lf);
        -- EOR
        lproc_insRow(quilt_const.TAG_EOR);    
        p_object.idx := l_idx;
        COMMIT;
    END save_report;

    ----------------------------------------------------------------------------
    PROCEDURE process_profiler_run(p_quilt_run_id IN NUMBER) IS
        lrec_quilt_run quilt_run%ROWTYPE;
        lrec_report    rcu_report%ROWTYPE;
        --
        l_isFirstRun    BOOLEAN := FALSE;
        l_reportProcess quilt_report_process_type := quilt_report_process_type(2, quilt_const.TAG_EOR);
        l_Name          VARCHAR2(4000);
        l_branchCount   NUMBER;
        l_inBranch      BOOLEAN := FALSE;
        l_branchLine    PLS_INTEGER;
        --
        ----------------------------------------------------------------------------  
        PROCEDURE initPLSQLBodyObject IS
        BEGIN
            --
            l_reportProcess.tag_da   := quilt_lcov_lines();
            l_reportProcess.tag_fn   := quilt_lcov_lines();
            l_reportProcess.tag_fnda := quilt_lcov_lines();
            l_reportProcess.tag_brda := quilt_lcov_lines();
            l_reportProcess.tag_fnf  := 0;
            l_reportProcess.tag_fnh  := 0;
            l_reportProcess.tag_brf  := 0;
            -- TN
            l_reportProcess.tag_tn := lrec_quilt_run.test_name;
            -- SF
            l_reportProcess.tag_sf := '/tmp/report/src/' || lrec_report.owner || '/' || REPLACE(lrec_report.type, ' ', '_') || '/' ||
                                      lrec_report.name || '.sql';
            quilt_logger.log_detail(': ' || p_quilt_run_id || ',' || lrec_report.quilt_run_id || ',' || lrec_report.name || ',' ||
                                    lrec_report.owner || ',' || lrec_report.type);
            -- LH - lines hit
            l_reportProcess.tag_lh := lines_hit(p_quilt_run_id => p_quilt_run_id,
                                                p_unitName     => lrec_report.name,
                                                p_owner        => lrec_report.owner,
                                                p_unitType     => lrec_report.type);
            -- LF - lines found
            l_reportProcess.tag_lf := lines_found(p_quilt_run_id => p_quilt_run_id,
                                                  p_unitName     => lrec_report.name,
                                                  p_owner        => lrec_report.owner,
                                                  p_unitType     => lrec_report.type);
            -- BR
            l_branchCount := 0;
        END;
        --
    BEGIN
        quilt_logger.log_detail('begin:p_quilt_run_id=$1', p_quilt_run_id);
        SELECT * INTO lrec_quilt_run FROM quilt_run WHERE quilt_run_id = p_quilt_run_id;
        --
        --uklid pred novym reportem pro stejne RUNID
        DELETE quilt_report_line WHERE quilt_run_id = p_quilt_run_id;
        --
        OPEN rcu_report(p_quilt_run_id);
        --
        LOOP
            FETCH rcu_report
                INTO lrec_report;
            EXIT WHEN rcu_report%NOTFOUND;
            -- zpracovani vice souboru
            -- prvni radek objektu, inicializace typu, promennych
            IF lrec_report.line = 1 THEN
                --
                IF l_isFirstRun THEN
                    quilt_logger.log_detail('vice souboru');
                    -- vice souboru, provedeme zapis dat z typu do tabulky
                    quilt_logger.log_detail('idx_1s', l_reportProcess.idx);
                    save_report(p_quilt_run_id, l_reportProcess);
                    --
                    quilt_logger.log_detail('idx_1e', l_reportProcess.idx);
                    l_reportProcess := quilt_report_process_type(l_reportProcess.idx, quilt_const.TAG_EOR);
                    quilt_logger.log_detail('idx_2', l_reportProcess.idx);
                ELSE
                    quilt_logger.log_detail(': prvni beh');
                    l_isFirstRun := TRUE;
                END IF;
                --
                initPLSQLBodyObject;
                --
            END IF;
            -- analyza radku, todo
            IF regexp_like(lrec_report.text, '(^|\s+)procedure(\s|$|[^a-z])', 'i') OR
               regexp_like(lrec_report.text, '(^|\s+)function(\s|$|[^a-z])', 'i') AND ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
                -- FN:<line number of function start>,<function name>
                BEGIN
                    l_Name := quilt_util.getMethodName(lrec_report.text);
                EXCEPTION
                    WHEN OTHERS THEN
                        quilt_logger.log_detail(': FN: ' || SQLERRM);
                        l_Name := lrec_report.text;
                END;
                l_reportProcess.tag_fn.extend;
                l_reportProcess.tag_fn(l_reportProcess.tag_fn.last) := lrec_report.line || ',' || l_Name;
                -- TODO: has to solve overloads - if overloaded then add all_procedures.overload in parenths (1)
                -- FNDA:<execution count>,<function name>
                l_reportProcess.tag_fnda.extend;
                l_reportProcess.tag_fnda(l_reportProcess.tag_fnda.last) := nvl(lrec_report.total_occur, 0) || ',' || l_Name;
                -- FNF:<number of functions found>
                l_reportProcess.tag_fnf := l_reportProcess.tag_fnf + 1;
                -- FNH:<number of function hit>
                IF lrec_report.total_occur > 0 THEN
                    l_reportProcess.tag_fnh := l_reportProcess.tag_fnh + 1;
                END IF;
            END IF;
            --
            -- TODO: this is really not sufficient - needs parsing, as we need to eat all whitespace and comments and works only for specially formated code
            IF l_inBranch AND ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
                -- BRDA:<line number>,<block number>,<branch number>,<taken>
                l_reportProcess.tag_brda.extend;
                -- todo ,1 -> counts blocks
                -- TODO: else doesn't show correct total_occur - it has to be solved using lexer - finding line of next token which is not single line comment, whitespace, multiline comment and use its total_count
                l_reportProcess.tag_brda(l_reportProcess.tag_brda.last) := lrec_report.line || ',1,' || l_branchCount || ',' ||
                                                                           nvl(lrec_report.total_occur, 0);
                l_branchCount := l_branchCount + 1;
                -- BRF:<number of branches found>
                l_reportProcess.tag_brf := nvl(l_reportProcess.tag_brf, 0) + 1;
                -- BRH:<number of branches hit>
                l_reportProcess.tag_brh := 0;
                l_inBranch              := FALSE;
            END IF;
            --
            IF (lower(lrec_report.text) LIKE '% if %' OR --
               lower(lrec_report.text) LIKE '% elsif %' OR --
               regexp_like(lrec_report.text, '(^|\s+)else(\s|$|[^a-z])', 'i') OR --
               lower(lrec_report.text) LIKE '% when %') AND ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
                l_branchLine := lrec_report.line;
                l_inBranch   := TRUE;
            END IF;
            -- DA
            -- write DA only when total occur is not null
            IF lrec_report.total_occur IS NOT NULL THEN
                l_reportProcess.tag_da.extend;
                --DA:<line number>,<execution count>[,<checksum>]
                l_reportProcess.tag_da(l_reportProcess.tag_da.last) := lrec_report.line || ',' || nvl(lrec_report.total_occur, 0);
                quilt_logger.log_detail(': DA ' || quilt_const.TAG_DA || lrec_report.line || ',' || nvl(lrec_report.total_occur, 0));
            END IF;
            --
        END LOOP;
        --
        IF l_reportProcess.tag_da IS NOT NULL THEN
            quilt_logger.log_detail('DA count:' || l_reportProcess.tag_da.count);
            -- zapis
            quilt_logger.log_detail('zapis');
            save_report(p_quilt_run_id, l_reportProcess);
        ELSE
            quilt_logger.log_detail(': lobj_report.tag_da is null!!!');
        END IF;
        --
        CLOSE rcu_report;
        --
    EXCEPTION
        WHEN OTHERS THEN
            IF rcu_report%ISOPEN THEN
                CLOSE rcu_report;
            END IF;
    END process_profiler_run;

    ----------------------------------------------------------------------------
    FUNCTION Report(p_quilt_run_id IN NUMBER) RETURN quilt_report IS
        l_Result quilt_report;
    BEGIN
        SELECT quilt_report_item(Text) BULK COLLECT INTO l_Result FROM quilt_report_line WHERE quilt_run_id = p_quilt_run_id ORDER BY Line;
        --
        RETURN l_Result;
        --
    END;

END quilt_coverage;
/
