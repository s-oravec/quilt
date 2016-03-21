CREATE OR REPLACE PACKAGE BODY quilt_codecoverage_pkg IS

  -- Private type declarations

  
  -- Private constant declarations


  -- Private variable declarations

  /** CURSOR data report */
  CURSOR rcu_report(ri NUMBER,si NUMBER,se NUMBER) IS
    WITH plsql AS (
      SELECT r.runid,
             CASE WHEN u.unit_type = 'PACKAGE SPEC' THEN 'PACKAGE' ELSE u.unit_type END type,
             u.unit_owner owner,
             u.unit_name name,
             d.line# line,
             d.total_occur,
             d.total_time,
             u.unit_number
        FROM PLSQL_PROFILER_RUNS r,PLSQL_PROFILER_UNITS u,PLSQL_PROFILER_DATA d
       WHERE r.runid = ri
         AND r.runid = u.runid
         AND u.runid = d.runid
         AND u.unit_number = d.unit_number
         AND u.unit_type != 'ANONYMOUS BLOCK')
    SELECT s.OWNER,
           s.NAME,
           s.TYPE,
           s.LINE,
           s.text,
           p.runid,
           p.unit_number,
           p.total_occur,
           p.total_time
      FROM all_source s, plsql p, quilt_methods q
     WHERE s.OWNER LIKE q.object_schema
       AND s.NAME LIKE q.object_name
       AND s.TYPE = nvl(q.object_type,'PACKAGE BODY')
       --
       AND q.sid = si
       AND q.sessionid = se       
       --
       AND s.OWNER = p.owner(+)
       AND s.NAME = p.name(+)
       AND s.TYPE = p.type(+)
       AND s.LINE = p.line(+)
     ORDER BY s.OWNER, s.name, s.type,s.line;

  /** CURSOR total rows */
  CURSOR rcu_total (ri NUMBER, na VARCHAR2, ow VARCHAR2, ty VARCHAR2) IS
    SELECT count(1) cnt
      FROM plsql_profiler_data d, plsql_profiler_units u
     WHERE d.runid = ri
       AND u.runid = d.runid
       AND u.unit_number = d.unit_number
       AND u.unit_name = upper(na)
       AND u.unit_owner = upper(ow)
       --
       AND u.unit_type = upper(ty);

  /** CURSOR exec rows */
  CURSOR rcu_exec (ri NUMBER, na VARCHAR2, ow VARCHAR2, ty VARCHAR2) IS
    SELECT count(1) cnt
      FROM plsql_profiler_data d, plsql_profiler_units u
     WHERE d.runid = ri
       AND u.runid = d.runid
       AND u.unit_number = d.unit_number
       AND u.unit_name = upper(na)
       AND u.unit_owner = upper(ow)
       --
       AND u.unit_type = upper(ty)
       AND d.total_occur > 0;


  -- Function and procedure implementations

  /** Insert row to the table of reports */
  PROCEDURE insert_Row(p_sessionid IN NUMBER,
                       p_sid       IN NUMBER,
                       p_runid     IN NUMBER,
                       p_idx       IN OUT NUMBER,
                       p_line      IN VARCHAR2) IS
  BEGIN
      --
      INSERT INTO quilt_report
          (sessionid, sid, runid, idx, line)
          VALUES
              (p_sessionid,p_sid,p_runid,p_idx,p_line);
      p_idx := p_idx + 1;
  END insert_Row;

  /** Save object data to the table of reports */
  PROCEDURE save_ObjectReport(p_sessionid IN NUMBER,
                              p_sid       IN NUMBER,
                              p_runid     IN NUMBER,
                              p_object    IN OUT quilt_report_process) IS

      lint_idx     NUMBER := p_object.idx;
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport');

      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : idx '|| lint_idx);
      -- TN
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_TN || p_object.tag_tn);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : TN '|| p_object.tag_tn);
      -- SF
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_SF ||p_object.tag_sf);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : SF '|| p_object.tag_sf);
      -- FN list
      IF p_object.tag_fn IS NOT NULL AND p_object.tag_fn.count > 0 THEN
          FOR i IN p_object.tag_fn.first .. p_object.tag_fn.last LOOP
              insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_FN || p_object.tag_fn(i));
              quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport: FN '||p_object.tag_fn(i));
          END LOOP;
      END IF;
      -- FNDA list
      IF p_object.tag_fnda IS NOT NULL AND p_object.tag_fnda.count > 0 THEN
          FOR i IN p_object.tag_fnda.first .. p_object.tag_fnda.last LOOP
              insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_FNDA || p_object.tag_fnda(i));
              quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport: FNDA '||p_object.tag_fnda(i));
          END LOOP;
      END IF;
      -- FNF
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_FNF ||p_object.tag_fnf);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : FNF '|| p_object.tag_fnf);
      -- FNH
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_FNH ||p_object.tag_fnh);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : FNF '|| p_object.tag_fnf);
      -- BRDA list
      IF p_object.tag_brda IS NOT NULL AND p_object.tag_brda.count > 0 THEN
          FOR i IN p_object.tag_brda.first .. p_object.tag_brda.last LOOP
              insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_BRDA || p_object.tag_brda(i));
              quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport: BRDA '||p_object.tag_brda(i));
          END LOOP;
      END IF;
      -- BRF
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_BRF ||p_object.tag_brf);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : FNF '|| p_object.tag_fnf);
      -- BFH
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_BRH ||p_object.tag_brh);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : FNF '|| p_object.tag_fnf);
      -- DA list
      IF p_object.tag_da IS NOT NULL AND p_object.tag_da.count > 0 THEN
          FOR i IN p_object.tag_da.first .. p_object.tag_da.last LOOP
              insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_DA || p_object.tag_da(i));
              quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport: DA '||p_object.tag_da(i));
          END LOOP;
      END IF;
      -- LH
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_LH || p_object.tag_lh);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : LH '|| p_object.tag_lh);
      -- LF
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_LF || p_object.tag_lf);          
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : LF '|| p_object.tag_lf);
      -- EOR
      insert_Row(p_sessionid,p_sid,p_runid,lint_idx,quilt_const_pkg.TAG_EOR);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.save_ObjectReport : EOR '|| p_object.tag_eor);

      p_object.idx := lint_idx;
      commit;
  END save_ObjectReport;

  /** get list of spying objects */
  FUNCTION get_SpyingObjects
      RETURN SYS_REFCURSOR IS

      lrcu_result  SYS_REFCURSOR;
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.get_SpyingObjects');
      --
      OPEN lrcu_result FOR
          SELECT object_schema, object_name, object_type
            FROM quilt_methods
           WHERE sid = quilt_core_pkg.get_SID
             AND sessionid = quilt_core_pkg.get_SESSIONID;
      
      RETURN lrcu_result;
  END get_SpyingObjects;

  /** set spying objects for session */
  PROCEDURE set_SpyingObject(p_schema IN VARCHAR2,
                             p_object IN VARCHAR2,
                             p_object_type IN VARCHAR2 DEFAULT NULL) IS

      lstr_schema      quilt_methods.object_schema%TYPE := upper(p_schema);
      lstr_object      quilt_methods.object_name%TYPE := upper(p_object);
      lstr_object_type quilt_methods.object_type%TYPE := upper(p_object_type);
      lint_sessionid   quilt_methods.sessionid%TYPE := quilt_core_pkg.get_SESSIONID;
      lint_sid         quilt_methods.sid%TYPE := quilt_core_pkg.get_SID;
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.set_SpyingObject');

      BEGIN
          INSERT INTO quilt_methods
              (sessionid, sid, object_schema, object_name, object_type, insert_dt)
              VALUES
                  (lint_sessionid, lint_sid, lstr_schema, lstr_object, lstr_object_type, sysdate);
      EXCEPTION
          WHEN OTHERS THEN -- todo specificka
              UPDATE quilt_methods
                 SET last_dt = sysdate
               WHERE sessionid = lint_sessionid
                 AND sid = lint_sid
                 AND object_schema = lstr_schema
                 AND object_name = lstr_object
                 AND nvl(object_type,'-1') = nvl(lstr_object_type,'-1');

      END;
      --
      COMMIT;
  END set_SpyingObject;

  /** delete list of spying objects for session */
  PROCEDURE del_SpyingObjectList IS
  BEGIN
      DELETE quilt_methods
       WHERE sid = quilt_core_pkg.get_SID
         AND sessionid = quilt_core_pkg.get_SESSIONID;
      COMMIT;
  END del_SpyingObjectList;

  /** create dat for report - lcov.info */
  PROCEDURE ProcessingCodeCoverage(p_sessionid IN NUMBER DEFAULT NULL,
                                   p_sid       IN NUMBER DEFAULT NULL,
                                   p_runid     IN NUMBER DEFAULT NULL) IS
  
      lrec_report  rcu_report%ROWTYPE;
      lrec_total   rcu_total%ROWTYPE;
      lrec_exec    rcu_exec%ROWTYPE;
      --
      --lint_idx       NUMBER := 1;
      lbol_first_run BOOLEAN := FALSE;
      --
      lint_sessionid    NUMBER := nvl(p_sessionid,quilt_core_pkg.get_SESSIONID);
      lint_sid          NUMBER := nvl(p_sid,quilt_core_pkg.get_SID);
      lint_runid        NUMBER := nvl(p_runid,quilt_core_pkg.get_Runid);
      lstr_testname     VARCHAR2(2000) := nvl(quilt_core_pkg.get_TestName,quilt_const_pkg.TEST_NAME_DEFAULT);
      lobj_report       quilt_report_process := quilt_report_process(2,quilt_const_pkg.TAG_EOR);
      lstr_name         VARCHAR2(4000);
      --
      lint_branch_cnt   NUMBER;
  BEGIN
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage');

      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage:lint_sessionid '||lint_sessionid);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage:lint_sid '||lint_sid);
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage:lint_runid '||lint_runid);
      --
      --uklid pred novym reportem pro stejne RUNID
      DELETE quilt_report
       WHERE sessionid = lint_sessionid
         AND sid = lint_sid
         AND runid = lint_runid;
      --
      OPEN rcu_report(lint_runid,lint_sid,lint_sessionid);
      --
      LOOP
          FETCH rcu_report INTO lrec_report;
          EXIT WHEN rcu_report%NOTFOUND;
          -- zpracovani vice souboru
          -- prvni radek objektu, inicializace typu, promennych
          IF lrec_report.line = 1 THEN
              --
              IF lbol_first_run THEN
                  quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: vice souboru');
                  -- vice souboru, provedeme zapis dat z typu do tabulky
                  quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: idx_1s '|| lobj_report.idx);
                  save_ObjectReport(lint_sessionid,lint_sid,lint_runid,lobj_report);
                  --
                  quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: idx_1e '|| lobj_report.idx);
                  lobj_report := quilt_report_process(lobj_report.idx,quilt_const_pkg.TAG_EOR);
                  quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: idx_2 '|| lobj_report.idx);
              ELSE
                  quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: prvni beh');
                  lbol_first_run := TRUE;

              END IF;
              --
              lobj_report.tag_da := quilt_report_type();
              lobj_report.tag_fn := quilt_report_type();
              lobj_report.tag_fnda := quilt_report_type();
              lobj_report.tag_brda := quilt_report_type();
              lobj_report.tag_fnf := 0;
              lobj_report.tag_brf := 0;
              -- TN
              lobj_report.tag_tn := lstr_testname;
              -- SF
              lobj_report.tag_sf := './'|| lrec_report.owner ||'.'|| lrec_report.name ||'.'|| lrec_report.type ||'.sql';
              quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: '||  lint_runid ||','|| lrec_report.runid ||','|| lrec_report.name ||','|| lrec_report.owner ||','|| lrec_report.type);
              
              OPEN rcu_total(lint_runid,lrec_report.name,lrec_report.owner,lrec_report.type);
              OPEN rcu_exec(lint_runid,lrec_report.name,lrec_report.owner,lrec_report.type);
              FETCH rcu_total INTO lrec_total;
              FETCH rcu_exec INTO lrec_exec;
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
          IF (lower(lrec_report.text) LIKE '%procedure %' OR lower(lrec_report.text) LIKE '%function %' ) AND
              ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
              -- FN:<line number of function start>,<function name>
              BEGIN
                  lstr_name := quilt_util_pkg.getName(lrec_report.text);
              
              EXCEPTION
                  WHEN OTHERS THEN
                      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: FN: '|| SQLERRM);
                      lstr_name := lrec_report.text;
              END;
              lobj_report.tag_fn.extend;
              lobj_report.tag_fn(lobj_report.tag_fn.last) := lrec_report.line ||','|| lstr_name;
              -- FNDA:<execution count>,<function name>
              
              -- FNF:<number of functions found>
              lobj_report.tag_fnf := nvl(lobj_report.tag_fnf,0) + 1;
              -- FNH:<number of function hit>
              lobj_report.tag_fnh := 0;
          END IF;
          IF lower(lrec_report.text) LIKE '% if %'  AND
              ltrim(lower(lrec_report.text)) NOT LIKE '--%' THEN
              -- BRDA:<line number>,<block number>,<branch number>,<taken>
              lobj_report.tag_brda.extend;
              -- todo ,1 -> counts blocks
              lobj_report.tag_brda(lobj_report.tag_brda.last) := lrec_report.line ||',1,'|| lint_branch_cnt ||','|| lint_branch_cnt;
              lint_branch_cnt := lint_branch_cnt + 1;
              -- BRF:<number of branches found>
              lobj_report.tag_brf := nvl(lobj_report.tag_brf,0) + 1;
              -- BRH:<number of branches hit>
              lobj_report.tag_brh := 0;
          END IF;
          -- DA
          lobj_report.tag_da.extend;
          --DA:<line number>,<execution count>[,<checksum>]
          lobj_report.tag_da(lobj_report.tag_da.last) := lrec_report.line ||','|| nvl(lrec_report.total_occur,0);
          quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: DA '||  quilt_const_pkg.TAG_DA || lrec_report.line ||','|| nvl(lrec_report.total_occur,0));
          --
      END LOOP;
      IF lobj_report.tag_da IS NOT NULL THEN
          quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: '|| lobj_report.tag_da.count);
      ELSE
          quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: lobj_report.tag_da is null!!!');
      END IF;
      
      -- zapis
      quilt_log_pkg.log_detail($$PLSQL_UNIT ||'.ProcessingCodeCoverage: zapis');
      save_ObjectReport(lint_sessionid,lint_sid,lint_runid,lobj_report);

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
       Taken is either ’-’ if the basic block containing the branch was  never
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

END quilt_codecoverage_pkg;
/