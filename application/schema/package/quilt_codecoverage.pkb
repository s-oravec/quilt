CREATE OR REPLACE PACKAGE BODY quilt_codecoverage IS

    /** CURSOR data report */
    CURSOR rcu_report
    (
        p_runId     NUMBER,
        p_SID       NUMBER,
        p_sessionId NUMBER
    ) IS
        WITH plsql AS
         (SELECT r.runid,
                 CASE
                     WHEN u.unit_type = 'PACKAGE SPEC' THEN
                      'PACKAGE'
                     ELSE
                      u.unit_type
                 END Type,
                 u.unit_owner OWNER,
                 u.unit_name Name,
                 d.line# Line,
                 d.total_occur,
                 d.total_time,
                 u.unit_number
            FROM plsql_profiler_runs r, plsql_profiler_units u, plsql_profiler_data D
           WHERE r.runid = p_runId
             AND r.runid = u.runid
             AND u.runid = d.runid
             AND u.unit_number = d.unit_number
             AND u.unit_type != 'ANONYMOUS BLOCK')
        SELECT s.owner, s.name, s.type, s.line, s.text, p.runid, p.unit_number, p.total_occur, p.total_time
          FROM all_source s, plsql P, quilt_methods q
         WHERE s.owner LIKE q.object_schema
           AND s.name LIKE q.object_name
           AND s.type = nvl(q.object_type, 'PACKAGE BODY')
              --
           AND q.sid = p_SID
           AND q.sessionid = p_sessionId
              --
           AND s.OWNER = p.owner(+)
           AND s.NAME = p.name(+)
           AND s.TYPE = p.type(+)
           AND s.LINE = p.line(+)
         ORDER BY s.OWNER, s.name, s.type, s.line;

    /** CURSOR total rows */
    CURSOR rcu_total
    (
        p_runId    NUMBER,
        p_unitName VARCHAR2,
        p_owner    VARCHAR2,
        p_unitType VARCHAR2
    ) IS
        SELECT Count(1) Cnt
          FROM plsql_profiler_data D, plsql_profiler_units u
         WHERE d.runid = p_runId
           AND u.runid = d.runid
           AND u.unit_number = d.unit_number
           AND u.unit_name = upper(p_unitName)
           AND u.unit_owner = upper(p_owner)
              --
           AND u.unit_type = upper(p_unitType);

    /** CURSOR exec rows */
    CURSOR rcu_exec
    (
        p_runId    NUMBER,
        p_unitName VARCHAR2,
        p_owner    VARCHAR2,
        p_unitType VARCHAR2
    ) IS
        SELECT Count(1) Cnt
          FROM plsql_profiler_data D, plsql_profiler_units u
         WHERE d.runid = p_runId
           AND u.runid = d.runid
           AND u.unit_number = d.unit_number
           AND u.unit_name = upper(p_unitName)
           AND u.unit_owner = upper(p_owner)
              --
           AND u.unit_type = upper(p_unitType)
           AND d.total_occur > 0;

    ----------------------------------------------------------------------------    
    PROCEDURE insert_Row
    (
        p_sessionId IN NUMBER,
        p_sid       IN NUMBER,
        p_runId     IN NUMBER,
        p_idx       IN OUT NUMBER,
        p_line      IN VARCHAR2
    ) IS
    BEGIN
        --
        INSERT INTO quilt_report (sessionid, SID, runid, idx, Line) VALUES (p_sessionId, p_sid, p_runId, p_idx, p_line);
        p_idx := p_idx + 1;
    END insert_Row;

    /** Save object data to the table of reports */
    PROCEDURE save_ObjectReport
    (
        p_sessionId IN NUMBER,
        p_sid       IN NUMBER,
        p_runId     IN NUMBER,
        p_object    IN OUT quilt_report_process_type
    ) IS
        l_idx NUMBER := p_object.idx;
        --
        PROCEDURE lproc_insRow
        (
            p_idx  IN OUT NUMBER,
            p_line IN VARCHAR2
        ) IS
        BEGIN
            insert_row(p_sessionId, p_SID, p_runId, p_idx, p_line);
            quilt_logger.log_detail(p_line);
        END;
        --
    BEGIN
        quilt_logger.log_detail('begin:p_sessionId=$1, p_SID=$2, p_runId=$3', p_sessionId, p_SID, p_runId);
        quilt_logger.log_detail('idx', l_idx);
        -- TN
        lproc_insRow(l_idx, quilt_const.TAG_TN || p_object.tag_tn);
        -- SF
        lproc_insRow(l_idx, quilt_const.TAG_SF || p_object.tag_sf);
        -- FN list
        IF p_object.tag_fn IS NOT NULL AND p_object.tag_fn.count > 0 THEN
            FOR i IN p_object.tag_fn.first .. p_object.tag_fn.last LOOP
                lproc_insRow(l_idx, quilt_const.TAG_FN || p_object.tag_fn(i));
            END LOOP;
        END IF;
        -- FNDA list
        IF p_object.tag_fnda IS NOT NULL AND p_object.tag_fnda.count > 0 THEN
            FOR i IN p_object.tag_fnda.first .. p_object.tag_fnda.last LOOP
                lproc_insRow(l_idx, quilt_const.TAG_FNDA || p_object.tag_fnda(i));
            END LOOP;
        END IF;
        -- FNF
        lproc_insRow(l_idx, quilt_const.TAG_FNF || p_object.tag_fnf);
        -- FNH
        lproc_insRow(l_idx, quilt_const.TAG_FNH || p_object.tag_fnh);
        -- BRDA list
        IF p_object.tag_brda IS NOT NULL AND p_object.tag_brda.count > 0 THEN
            FOR i IN p_object.tag_brda.first .. p_object.tag_brda.last LOOP
                lproc_insRow(l_idx, quilt_const.TAG_BRDA || p_object.tag_brda(i));
            END LOOP;
        END IF;
        -- BRF
        lproc_insRow(l_idx, quilt_const.TAG_BRF || p_object.tag_brf);
        -- BFH
        lproc_insRow(l_idx, quilt_const.TAG_BRH || p_object.tag_brh);
        -- DA list
        IF p_object.tag_da IS NOT NULL AND p_object.tag_da.count > 0 THEN
            FOR i IN p_object.tag_da.first .. p_object.tag_da.last LOOP
                lproc_insRow(l_idx, quilt_const.TAG_DA || p_object.tag_da(i));
            END LOOP;
        END IF;
        -- LH
        lproc_insRow(l_idx, quilt_const.TAG_LH || p_object.tag_lh);
        -- LF
        lproc_insRow(l_idx, quilt_const.TAG_LF || p_object.tag_lf);
        -- EOR
        lproc_insRow(l_idx, quilt_const.TAG_EOR);
    
        p_object.idx := l_idx;
        COMMIT;
    END save_ObjectReport;

    ----------------------------------------------------------------------------
    FUNCTION get_SpyingObjects
    (
        p_sessionId IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL
    ) RETURN SYS_REFCURSOR IS
        l_sessionId NUMBER := nvl(p_sessionId, quilt_core.get_sessionId);
        l_SID       NUMBER := nvl(p_sid, quilt_core.get_SID);
        lrcu_result SYS_REFCURSOR;
    BEGIN
        quilt_logger.log_detail('begin:p_sessionId=$1, p_SID=$2, l_sessionId=$3, l_SID=$4', p_sessionId, p_SID, l_sessionId, l_SID);
        --
        OPEN lrcu_result FOR
            SELECT object_schema, object_name, object_type
              FROM quilt_methods
             WHERE SID = l_SID
               AND sessionid = l_sessionId;
        --
        RETURN lrcu_result;
        --
    END get_SpyingObjects;

    ----------------------------------------------------------------------------  
    PROCEDURE set_SpyingObject
    (
        p_schema      IN VARCHAR2,
        p_object      IN VARCHAR2,
        p_object_type IN VARCHAR2 DEFAULT NULL,
        p_sessionId   IN NUMBER DEFAULT NULL,
        p_sid         IN NUMBER DEFAULT NULL
    ) IS
    
        l_sessionId quilt_methods.sessionid%Type := nvl(p_sessionId, quilt_core.get_SESSIONID);
        l_SID       quilt_methods.sid%Type := nvl(p_sid, quilt_core.get_SID);
        ltab_objs   quilt_object_list_type := quilt_object_list_type();
    BEGIN
        quilt_logger.log_detail('begin:p_sessionId=$1, p_SID=$2, l_sessionId=$3, l_SID=$4', p_sessionId, p_SID, l_sessionId, l_SID);
        --
        ltab_objs := quilt_util.getObjectList(p_schema, p_object, p_object_type);
        --
        FOR i IN (SELECT schema_name, object_name, object_type FROM TABLE(ltab_objs)) LOOP
            BEGIN
                INSERT INTO quilt_methods
                    (sessionid, SID, object_schema, object_name, object_type, insert_dt)
                VALUES
                    (l_sessionId, l_SID, i.schema_name, i.object_name, i.object_type, SYSDATE);
            EXCEPTION
                WHEN OTHERS THEN
                    -- todo specificka
                    UPDATE quilt_methods
                       SET last_dt = SYSDATE
                     WHERE sessionid = l_sessionId
                       AND SID = l_SID
                       AND object_schema = i.schema_name
                       AND object_name = i.object_name
                       AND nvl(object_type, '-1') = nvl(i.object_type, '-1');
            END;
        END LOOP;
        --
        COMMIT;
        --
        quilt_logger.log_detail('end');
        --
    END set_SpyingObject;

    ----------------------------------------------------------------------------
    PROCEDURE del_SpyingObjectList
    (
        p_sessionId IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_sessionId NUMBER := nvl(p_sessionId, quilt_core.get_SESSIONID);
        l_SID       NUMBER := nvl(p_sid, quilt_core.get_SID);
    BEGIN
        quilt_logger.log_detail('begin:p_sessionId=$1, p_SID=$2, l_sessionId=$3, l_SID=$4', p_sessionId, p_SID, l_sessionId, l_SID);
        --    
        DELETE quilt_methods
         WHERE SID = l_SID
           AND sessionid = l_sessionId;
        --
        COMMIT;
        --
        quilt_logger.log_detail('end');
        --
    END del_SpyingObjectList;

    ----------------------------------------------------------------------------
    PROCEDURE ProcessingCodeCoverage
    (
        p_sessionId IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL,
        p_runId     IN NUMBER DEFAULT NULL
    ) IS
    
        lrec_report rcu_report%ROWTYPE;
        lrec_total  rcu_total%ROWTYPE;
        lrec_exec   rcu_exec%ROWTYPE;
        --
        --lint_idx       NUMBER := 1;
        lbol_first_run BOOLEAN := FALSE;
        --
        l_sessionId   NUMBER := nvl(p_sessionId, quilt_core.get_SESSIONID);
        l_SID         NUMBER := nvl(p_sid, quilt_core.get_SID);
        lint_runid    NUMBER := nvl(p_runId, quilt_core.get_Runid);
        lstr_testname VARCHAR2(2000) := nvl(quilt_core.get_TestName, quilt.DEFAULT_TEST_NAME);
        lobj_report   quilt_report_process_type := quilt_report_process_type(2, quilt_const.TAG_EOR);
        lstr_name     VARCHAR2(4000);
        --
        lint_branch_cnt NUMBER;
    BEGIN
        quilt_logger.log_detail('begin:p_sesionId=$1, p_SID=$2, p_runId=$3, l_sessionId=$4, l_SID=$5, l_runId=$6',
                                p_sessionId,
                                p_sid,
                                p_runId,
                                l_sessionId,
                                l_SID,
                                lint_runid);
        --
        --uklid pred novym reportem pro stejne RUNID
        DELETE quilt_report
         WHERE sessionid = l_sessionId
           AND SID = l_SID
           AND runid = lint_runid;
        --
        OPEN rcu_report(lint_runid, l_SID, l_sessionId);
        --
        LOOP
            FETCH rcu_report
                INTO lrec_report;
            EXIT WHEN rcu_report%NOTFOUND;
            -- zpracovani vice souboru
            -- prvni radek objektu, inicializace typu, promennych
            IF lrec_report.line = 1 THEN
                --
                IF lbol_first_run THEN
                    quilt_logger.log_detail('vice souboru');
                    -- vice souboru, provedeme zapis dat z typu do tabulky
                    quilt_logger.log_detail('idx_1s', lobj_report.idx);
                    save_ObjectReport(l_sessionId, l_SID, lint_runid, lobj_report);
                    --
                    quilt_logger.log_detail('idx_1e', lobj_report.idx);
                    lobj_report := quilt_report_process_type(lobj_report.idx, quilt_const.TAG_EOR);
                    quilt_logger.log_detail('idx_2', lobj_report.idx);
                ELSE
                    quilt_logger.log_detail(': prvni beh');
                    lbol_first_run := TRUE;
                END IF;
                --
                lobj_report.tag_da   := quilt_report_type();
                lobj_report.tag_fn   := quilt_report_type();
                lobj_report.tag_fnda := quilt_report_type();
                lobj_report.tag_brda := quilt_report_type();
                lobj_report.tag_fnf  := 0;
                lobj_report.tag_brf  := 0;
                -- TN
                lobj_report.tag_tn := lstr_testname;
                -- SF
                lobj_report.tag_sf := './' || lrec_report.owner || '.' || lrec_report.name || '.' || lrec_report.type || '.sql';
                quilt_logger.log_detail(': ' || lint_runid || ',' || lrec_report.runid || ',' || lrec_report.name || ',' ||
                                        lrec_report.owner || ',' || lrec_report.type);
            
                OPEN rcu_total(lint_runid, lrec_report.name, lrec_report.owner, lrec_report.type);
                OPEN rcu_exec(lint_runid, lrec_report.name, lrec_report.owner, lrec_report.type);
                FETCH rcu_total
                    INTO lrec_total;
                FETCH rcu_exec
                    INTO lrec_exec;
                CLOSE rcu_total;
                CLOSE rcu_exec;
                -- LH
                lobj_report.tag_lh := lrec_exec.cnt;
                -- LF
                lobj_report.tag_lf := lrec_total.cnt;
                -- BR
                lint_branch_cnt := 0;
            END IF;
            -- analyza radku, todo
            IF (lower(lrec_report.text) LIKE '%procedure %' OR lower(lrec_report.text) LIKE '%function %') AND
               ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
                -- FN:<line number of function start>,<function name>
                BEGIN
                    lstr_name := quilt_util.getMethodName(lrec_report.text);
                
                EXCEPTION
                    WHEN OTHERS THEN
                        quilt_logger.log_detail(': FN: ' || SQLERRM);
                        lstr_name := lrec_report.text;
                END;
                lobj_report.tag_fn.extend;
                lobj_report.tag_fn(lobj_report.tag_fn.last) := lrec_report.line || ',' || lstr_name;
                -- FNDA:<execution count>,<function name>
            
                -- FNF:<number of functions found>
                lobj_report.tag_fnf := nvl(lobj_report.tag_fnf, 0) + 1;
                -- FNH:<number of function hit>
                lobj_report.tag_fnh := 0;
            END IF;
            IF lower(lrec_report.text) LIKE '% if %' AND ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
                -- BRDA:<line number>,<block number>,<branch number>,<taken>
                lobj_report.tag_brda.extend;
                -- todo ,1 -> counts blocks
                lobj_report.tag_brda(lobj_report.tag_brda.last) := lrec_report.line || ',1,' || lint_branch_cnt || ',' || lint_branch_cnt;
                lint_branch_cnt := lint_branch_cnt + 1;
                -- BRF:<number of branches found>
                lobj_report.tag_brf := nvl(lobj_report.tag_brf, 0) + 1;
                -- BRH:<number of branches hit>
                lobj_report.tag_brh := 0;
            END IF;
            -- DA
            lobj_report.tag_da.extend;
            --DA:<line number>,<execution count>[,<checksum>]
            lobj_report.tag_da(lobj_report.tag_da.last) := lrec_report.line || ',' || nvl(lrec_report.total_occur, 0);
            quilt_logger.log_detail(': DA ' || quilt_const.TAG_DA || lrec_report.line || ',' || nvl(lrec_report.total_occur, 0));
            --
        END LOOP;
        IF lobj_report.tag_da IS NOT NULL THEN
            quilt_logger.log_detail(': ' || lobj_report.tag_da.count);
        
            -- zapis
            quilt_logger.log_detail(': zapis');
            save_ObjectReport(l_sessionId, l_SID, lint_runid, lobj_report);
        ELSE
            quilt_logger.log_detail(': lobj_report.tag_da is null!!!');
        END IF;
    
        --
        CLOSE rcu_report;
    EXCEPTION
        WHEN OTHERS THEN
            IF rcu_report%ISOPEN THEN
                CLOSE rcu_report;
            END IF;
    END ProcessingCodeCoverage;
    /*
           A tracefile is made up of several human-readable lines of text, divided
           into sections. If available, a tracefile begins with the testname which
           is stored in the following format:
    
             TN:<test name>
    
           For  each  source  file  referenced in the .da file, there is a section
           containing filename and coverage data:
    
             SF:<absolute path to the source file>
    
           Following is a list of line numbers for each function name found in the
           source file:
    
             FN:<line number of function start>,<function name>
    
           Next,  there  is a list of execution counts for each instrumented func-
           tion:
    
             FNDA:<execution count>,<function name>
    
           This list is followed by two lines containing the number  of  functions
           found and hit:
    
             FNF:<number of functions found>
             FNH:<number of function hit>
    
           Branch coverage information is stored which one line per branch:
    
             BRDA:<line number>,<block number>,<branch number>,<taken>
    
           Block  number  and  branch  number are gcc internal IDs for the branch.
           Taken is either �-� if the basic block containing the branch was  never
           executed or a number indicating how often that branch was taken.
    
           Branch coverage summaries are stored in two lines:
    
             BRF:<number of branches found>
             BRH:<number of branches hit>
    
           Then  there  is  a  list of execution counts for each instrumented line
           (i.e. a line which resulted in executable code):
    
             DA:<line number>,<execution count>[,<checksum>]
    
           Note that there may be an optional checksum present  for  each  instru-
           mented  line.  The  current  geninfo implementation uses an MD5 hash as
           checksumming algorithm.
    
           At the end of a section, there is a summary about how many  lines  were
           found and how many were actually instrumented:
    
             LH:<number of lines with a non-zero execution count>
             LF:<number of instrumented lines>
    
           Each sections ends with:
    
             end_of_record
    */

END quilt_codecoverage;
/
