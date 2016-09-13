CREATE OR REPLACE PACKAGE plparse_parser AS

    SUBTYPE AstSymbolType IS VARCHAR2(30);

    ast_PLSQLObjectBody CONSTANT AstSymbolType := 'PLSQLObjectBody';

    /* 
    Initializes lexer and parser internals
    
    %param p_owner owner of the object
    %param p_name object name
    %param p_type object type
    
    */
    PROCEDURE initialize
    (
        p_owner all_source.owner%Type,
        p_name  all_source.name%Type,
        p_type  all_source.type%Type
    );

    PROCEDURE initialize(p_source_lines IN plex_lexer.typ_source_text);

    -- TokenStream methods
    FUNCTION getIndex RETURN PLS_INTEGER;

    FUNCTION currentToken RETURN plex_token;

    PROCEDURE consume;

    FUNCTION eof RETURN BOOLEAN;

    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN plex_token;

    PROCEDURE takeSnapshot;

    PROCEDURE rollbackSnapshot;

    PROCEDURE commitSnapshot;
    -- TokenStream methods

END;
/
