CREATE OR REPLACE Type plparse_ast AS OBJECT
(
    id_registry INTEGER,
    symbol_type VARCHAR2(30), -- plarse_parser AstSymbolType
    token       plex_token,
    children    plparse_AstChildren,

    CONSTRUCTOR FUNCTION plparse_ast(token plex_token) RETURN SELF AS Result,

    MEMBER PROCEDURE addChild(child plparse_ast),

    MEMBER FUNCTION toString RETURN VARCHAR2

)
NOT FINAL;
/
