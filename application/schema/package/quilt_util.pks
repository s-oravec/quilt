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

    -- TODO move somewhere else
    Type typ_profiler_data_tab IS TABLE OF quilt_profiler_data%ROWTYPE;
    PROCEDURE save_profiler_data(p_data IN typ_profiler_data_tab);

    Type typ_profiler_units_tab IS TABLE OF quilt_profiler_units%ROWTYPE;
    PROCEDURE save_profiler_units(p_units IN typ_profiler_units_tab);

    Type typ_profiler_runs_tab IS TABLE OF quilt_profiler_runs%ROWTYPE;
    PROCEDURE save_profiler_runs(p_runs IN typ_profiler_runs_tab);

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
