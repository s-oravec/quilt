CREATE OR REPLACE PACKAGE plparse_ast_util AS

    PROCEDURE init;

    PROCEDURE register(ast IN OUT NOCOPY plparse_ast);

    PROCEDURE unregister(ast IN OUT NOCOPY plparse_ast);

    FUNCTION get_by_id(id_registry IN INTEGER) RETURN plparse_ast;

END;
/
