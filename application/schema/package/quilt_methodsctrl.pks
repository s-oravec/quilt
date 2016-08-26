CREATE OR REPLACE PACKAGE quilt_MethodsCtrl IS

    -- PL/SQL code coverage tool - manages enables/disables spying on schema objects

    -- TODO: enable specific method of object (e.g. procedure of package)
    -- TODO: enable like - match using LIKE expression

    -- spy on object
    PROCEDURE enableReport
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    );

    PROCEDURE disableReport
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    );

END quilt_methodsctrl;
/
