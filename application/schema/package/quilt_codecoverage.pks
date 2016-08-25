CREATE OR REPLACE PACKAGE quilt_codecoverage IS

    -- Author  : HENRY
    -- Created : 17.12.2015 16:42:38
    -- Purpose : PL/SQL code coverage tool
    -- Purpose : vytvoreni reportu, registrace objektu pro sledovani

    -- Public type declarations

    -- Public constant declarations

    -- Public variable declarations

    -- Public function and procedure declarations

    /** get list of spying objects */
    FUNCTION get_SpyingObjects
    (
        p_sessionid IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL
    ) RETURN SYS_REFCURSOR;

    /** set spying objects for session */
    PROCEDURE set_SpyingObject
    (
        p_schema      IN VARCHAR2,
        p_object      IN VARCHAR2,
        p_object_type IN VARCHAR2 DEFAULT NULL,
        p_sessionid   IN NUMBER DEFAULT NULL,
        p_sid         IN NUMBER DEFAULT NULL
    );

    /** delete list of spying objects for session */
    PROCEDURE del_SpyingObjectList
    (
        p_sessionid IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL
    );

    /** create dat for report - lcov.info */
    PROCEDURE ProcessingCodeCoverage
    (
        p_sessionid IN NUMBER DEFAULT NULL,
        p_sid       IN NUMBER DEFAULT NULL,
        p_runid     IN NUMBER DEFAULT NULL
    );

END quilt_codecoverage;
/
