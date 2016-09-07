CREATE OR REPLACE PACKAGE quilt_util_cu AUTHID CURRENT_USER AS

    -- Oracle 9i and earlier
    PLSQL_OPTIMIZE_LEVEL_0 CONSTANT BINARY_INTEGER := 0;
    -- Generally does not move source code out of its original order
    PLSQL_OPTIMIZE_LEVEL_1 CONSTANT BINARY_INTEGER := 1;
    -- May move the code to optimize it
    PLSQL_OPTIMIZE_LEVEL_2 CONSTANT BINARY_INTEGER := 2;
    -- Goes beyond level 2 and performs optimizations automatically including techniques not specifically requested
    PLSQL_OPTIMIZE_LEVEL_3 CONSTANT BINARY_INTEGER := 3;

    -- Returns objects PLSQL Optimize level
    --
    -- %param p_owner owner
    -- %param p_object_name object_name
    -- %param p_object_type object_type
    --
    FUNCTION getPLSQLOptimizeLevel
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN BINARY_INTEGER;

    -- TODO: set optimization to LEVEL 1 as it yields more profiling data
    -- Compiles object with PLSQL_OPTIMIZE_LEVEL = p_level
    --
    -- %param p_objects
    -- %param p_level new PLSQL_OPTIMIZE_LEVEL %see http://bit.ly/2bnwv9O
    --
    PROCEDURE setPLSQLOptimizeLevel
    (
        p_objects IN quilt_object_list_type,
        p_level   IN NUMBER DEFAULT PLSQL_OPTIMIZE_LEVEL_1
    );

    -- Gets list of objects (schemaName, objectName, objectType) from ALL_OBJECTS that match passed values using SQL LIKE expression with "\" as escape character
    --
    -- %param p_owner schema name
    -- %param p_object_name object name
    --
    FUNCTION getObjectList
    (
        p_owner       IN VARCHAR2,
        p_object_name IN VARCHAR2,
        p_object_type IN VARCHAR2
    ) RETURN quilt_object_list_type;

    PROCEDURE save_reported_object_source
    (
        p_quilt_run_id IN INTEGER,
        p_objects      IN quilt_object_list_type
    );

    PROCEDURE save_profiler_data
    (
        p_quilt_run_id    IN INTEGER,
        p_profiler_run_id IN NUMBER
    );

END;
/
