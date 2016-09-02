CREATE OR REPLACE PACKAGE quilt_reported_objects IS

    -- PL/SQL code coverage tool - manages enables/disables spying on schema objects

    -- TODO: enable specific method of object (e.g. procedure of package)
    -- TODO: enable like - match using LIKE expression

    -- spy on object
    PROCEDURE enable_report
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    );

    PROCEDURE disable_report
    (
        p_owner       IN all_objects.owner%Type,
        p_object_name IN all_objects.object_name%Type DEFAULT NULL
    );

    -- what is use of this method?
    FUNCTION get_reported_objects
    (
        p_sessionId IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL
    ) RETURN SYS_REFCURSOR;

END quilt_reported_objects;
/
