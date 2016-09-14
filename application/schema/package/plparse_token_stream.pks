CREATE OR REPLACE PACKAGE plparse_token_stream AS

    SUBTYPE AstSymbolType IS VARCHAR2(30);

    PROCEDURE initialize
    (
        p_owner all_source.owner%Type,
        p_name  all_source.name%Type,
        p_type  all_source.type%Type
    );

    PROCEDURE initialize(p_source_lines IN plex_lexer.typ_source_text);

    FUNCTION getIndex RETURN PLS_INTEGER;

    FUNCTION currentToken RETURN plex_token;

    PROCEDURE consume;

    FUNCTION eof RETURN BOOLEAN;

    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN plex_token;

    PROCEDURE takeSnapshot;

    PROCEDURE rollbackSnapshot;

    PROCEDURE commitSnapshot;

    FUNCTION capture(ast plparse_ast) RETURN plparse_ast;

    FUNCTION take RETURN plex_token;
    FUNCTION take(tokenType plex_lexer.TokenType) RETURN plex_token;
    PROCEDURE take(tokenType plex_lexer.TokenType);

    FUNCTION takeReservedWord(Text VARCHAR2) RETURN plex_token;
    PROCEDURE takeReservedWord(Text VARCHAR2);

    FUNCTION alt(ast plparse_ast) RETURN BOOLEAN;

END;
/
