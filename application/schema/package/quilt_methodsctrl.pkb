CREATE OR REPLACE PACKAGE BODY quilt_MethodsCtrl AS

    ----------------------------------------------------------------------------  
    PROCEDURE enableReport
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1,p_object_name=$2', p_owner, p_object_name);
        MERGE INTO quilt_methods t
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
    END enableReport;

    ----------------------------------------------------------------------------  
    PROCEDURE disableReport
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        quilt_logger.log_detail('begin:p_owner=$1,p_object_name=$2', p_owner, p_object_name);
        DELETE FROM quilt_methods
         WHERE OWNER = p_owner
           AND object_name LIKE '%' || p_object_name || '%';
        COMMIT;
        quilt_logger.log_detail('end');
    EXCEPTION
        WHEN OTHERS THEN
            quilt_logger.log_detail('error:', SQLERRM);
            ROLLBACK;
            RAISE;
    END disableReport;

END quilt_methodsctrl;
/
