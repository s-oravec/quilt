CREATE OR REPLACE PACKAGE quilt_util IS

    -- PL/SQL code coverage tool - helper utilities

    -- get method name from source line that CONTAINS PROCEDURE/FUNCTION keyword
    -- TODO: refactor to quilt_parser
    --
    -- %param p_textLine - ALL_SOURCE.text for source line
    --
    -- %return method name
    --
    FUNCTION getMethodName(p_textLine IN VARCHAR2) RETURN VARCHAR2;

    /* -- Gets object (schemaName, objectName, objectType) from ALL_OBJECTS that match passed values using SQL LIKE expression with "\" as escape character
        --
        -- %param p_owner schema name
        -- %param p_object_name object name
        --
        -- %return found quilt_object_type object or NULL when not found
        -- 
        FUNCTION getObject
        (
            p_owner       IN VARCHAR2,
            p_object_name IN VARCHAR2
        ) RETURN quilt_object_type;
    */

    -- Returns true if p_string contains p_lookup
    --
    -- %param p_string string
    -- %param p_lookup string
    --
    FUNCTION contains
    (
        p_string IN VARCHAR2,
        p_lookup IN VARCHAR2 DEFAULT '%'
    ) RETURN BOOLEAN;

    -- Returns method's caller's qualified name
    --
    -- %returns caller's qualified name
    --
    FUNCTION getCallerQualifiedName RETURN VARCHAR2;

    -- Returns method's qualified name
    --
    -- %returns qualified name
    --
    FUNCTION getCurrentQualifiedName RETURN VARCHAR2;

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
    ) RETURN VARCHAR2;

    FUNCTION next_run_id RETURN INTEGER;

END quilt_util;
/
