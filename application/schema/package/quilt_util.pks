CREATE OR REPLACE PACKAGE quilt_util IS

    -- PL/SQL code coverage tool - helper utilities

    /** compile object - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
    PROCEDURE set_Level
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2 DEFAULT NULL,
        p_level       IN NUMBER DEFAULT 1
    );

    /** compile all objects for spying list - set PLSQL_OPTIMALIZE_LEVEL = 1/2 */
    PROCEDURE set_LevelAll(p_level IN NUMBER DEFAULT 1);

    /** get name of method */
    FUNCTION getName(p_textline IN VARCHAR2) RETURN VARCHAR2;

    /** get list of objects */
    FUNCTION getObjectList
    (
        p_schema_name IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2 DEFAULT NULL
    ) RETURN quilt_object_list_type;

    -- returs true if p_string contains p_char
    FUNCTION contains
    (
        p_string IN VARCHAR2,
        p_char   IN VARCHAR2 DEFAULT '%'
    ) RETURN BOOLEAN;

    FUNCTION getCallerQualifiedName RETURN VARCHAR2;
    FUNCTION getCurrentQualifiedName RETURN VARCHAR2;

END quilt_util;
/
