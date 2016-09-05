CREATE OR REPLACE PACKAGE BODY quilt_reported_objects AS

    ----------------------------------------------------------------------------  
    PROCEDURE enable_report(p_objects IN quilt_object_list_type) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        quilt_logger.log_detail('begin');
        MERGE INTO quilt_reported_object t
        USING (SELECT * FROM TABLE(p_objects)) s
        ON (s.owner = t.owner AND s.object_name = t.object_name AND s.object_type = t.object_type)
        WHEN NOT MATCHED THEN
            INSERT (OWNER, object_name, object_type) VALUES (s.owner, s.object_name, s.object_type);
        COMMIT;
        quilt_logger.log_detail('end');
    EXCEPTION
        WHEN OTHERS THEN
            quilt_logger.log_detail('error:', SQLERRM);
            ROLLBACK;
            RAISE;
    END enable_report;

    ----------------------------------------------------------------------------  
    PROCEDURE disable_report(p_objects IN quilt_object_list_type) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        quilt_logger.log_detail('begin');
        DELETE FROM quilt_reported_object WHERE (OWNER, object_name, object_type) IN (SELECT * FROM TABLE(p_objects));
        COMMIT;
        quilt_logger.log_detail('end');
    EXCEPTION
        WHEN OTHERS THEN
            quilt_logger.log_detail('error:', SQLERRM);
            ROLLBACK;
            RAISE;
    END disable_report;

    ----------------------------------------------------------------------------
    FUNCTION get_reported_objects RETURN quilt_object_list_type IS
        ltab_result quilt_object_list_type;
    BEGIN
        quilt_logger.log_detail('begin');
        --
        SELECT quilt_object_type(OWNER, object_name, object_type) BULK COLLECT INTO ltab_result FROM quilt_reported_object;
        --
        RETURN ltab_result;
        --
    END get_reported_objects;

    ----------------------------------------------------------------------------
    PROCEDURE save_source
    (
        p_quilt_run_id IN INTEGER,
        p_sources      IN typ_source_tab
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        -- TODO: merge?
        FORALL idx IN p_sources.first .. p_sources.last
            INSERT INTO quilt_reported_object_source
            VALUES
                (p_quilt_run_id,
                 p_sources(idx).owner,
                 p_sources(idx).name,
                 p_sources(idx).type,
                 p_sources(idx).line,
                 p_sources(idx).text,
                 p_sources(idx).origin_con_id);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;

END quilt_reported_objects;
/
