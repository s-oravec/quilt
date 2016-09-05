CREATE OR REPLACE PACKAGE quilt_reported_objects IS

    -- PL/SQL code coverage tool - manages enables/disables spying on schema objects

    -- TODO: enable specific method of object (e.g. procedure of package)
    -- TODO: enable like - match using LIKE expression

    -- spy on object
    PROCEDURE enable_report(p_objects IN quilt_object_list_type);

    PROCEDURE disable_report(p_objects IN quilt_object_list_type);

    -- what is use of this method?
    FUNCTION get_reported_objects RETURN quilt_object_list_type;

    Type typ_source_tab IS TABLE OF all_source%ROWTYPE;
    PROCEDURE save_source
    (
        p_quilt_run_id IN INTEGER,
        p_sources      IN typ_source_tab
    );

END quilt_reported_objects;
/
