CREATE OR REPLACE PACKAGE BODY quilt_reported_objects AS

    ----------------------------------------------------------------------------  
    PROCEDURE enable_report
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1,p_object_name=$2', p_owner, p_object_name);
        MERGE INTO quilt_reported_object t
        USING (SELECT sys_context('USERENV', 'SESSIONID') AS sessionid,
                      sys_context('USERENV', 'SID') AS SID,
                      OWNER,
                      object_name,
                      object_type
                 FROM all_objects
                WHERE OWNER = p_owner
                  AND object_name LIKE '%' || p_object_name || '%'
                  AND object_type IN (quilt_const.OBJ_TYPE_PACKAGE_BODY,
                                      quilt_const.OBJ_TYPE_TYPE_BODY,
                                      quilt_const.OBJ_TYPE_PROCEDURE,
                                      quilt_const.OBJ_TYPE_FUNCTION,
                                      quilt_const.OBJ_TYPE_TRIGGER)) s
        ON (s.owner = t.owner AND s.object_name = t.object_name AND s.object_type = t.object_type AND s.sessionid = t.sessionid AND s.sid = t.sid)
        WHEN NOT MATCHED THEN
            INSERT (sessionid, SID, OWNER, object_name, object_type) VALUES (s.sessionid, s.sid, s.owner, s.object_name, s.object_type);
        COMMIT;
        quilt_logger.log_detail('end');
    EXCEPTION
        WHEN OTHERS THEN
            quilt_logger.log_detail('error:', SQLERRM);
            ROLLBACK;
            RAISE;
    END enable_report;

    ----------------------------------------------------------------------------  
    PROCEDURE disable_report
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1,p_object_name=$2', p_owner, p_object_name);
        DELETE FROM quilt_reported_object
         WHERE OWNER = p_owner
           AND object_name LIKE '%' || p_object_name || '%';
        COMMIT;
        quilt_logger.log_detail('end');
    EXCEPTION
        WHEN OTHERS THEN
            quilt_logger.log_detail('error:', SQLERRM);
            ROLLBACK;
            RAISE;
    END disable_report;

    ----------------------------------------------------------------------------
    FUNCTION get_reported_objects
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
            SELECT OWNER, object_name, object_type
              FROM quilt_reported_object
             WHERE SID = l_SID
               AND sessionid = l_sessionId;
        --
        RETURN lrcu_result;
        --
    END get_reported_objects;

END quilt_reported_objects;
/
