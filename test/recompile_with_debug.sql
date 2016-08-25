prompt .. Recompiling &&_USER schema object bodies with debug
DECLARE
BEGIN
    FOR compile_statement IN (SELECT REPLACE(CASE type
                                                 WHEN 'PACKAGE BODY' THEN
                                                  'ALTER PACKAGE #objectName# COMPILE DEBUG BODY'
                                                 WHEN 'TYPE BODY' THEN
                                                  'ALTER TYPE #objectName# COMPILE DEBUG BODY'
                                                 WHEN 'PROCEDURE' THEN
                                                  'ALTER PROCEDURE #objectName# COMPILE DEBUG'
                                                 WHEN 'FUNCTION' THEN
                                                  'ALTER FUNCTION #objectName# COMPILE DEBUG'
                                             END,
                                             '#objectName#',
                                             name) AS text
                                FROM user_plsql_object_settings
                               WHERE type IN ('PACKAGE BODY',
                                                     'TYPE BODY',
                                                     'PROCEDURE',
                                                     'FUNCTION')
                                 AND plsql_debug = 'FALSE')
    LOOP
        EXECUTE IMMEDIATE compile_statement.text;
    END LOOP;
END;
/
prompt .. done
