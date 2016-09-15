CREATE OR REPLACE PACKAGE plparse_parser AS

    -- AST Symbol Type Type
    SUBTYPE AstSymbolType IS VARCHAR2(30);

    -- AST Symbols    
    ast_Block           CONSTANT AstSymbolType := 'Block';
    ast_BlockCode       CONSTANT AstSymbolType := 'BlockCode';
    ast_BlockDeclPart   CONSTANT AstSymbolType := 'BlockDeclPart';
    ast_Branch          CONSTANT AstSymbolType := 'Branch';
    ast_ConstantDecl    CONSTANT AstSymbolType := 'ConstantDecl';
    ast_Decision        CONSTANT AstSymbolType := 'Decision';
    ast_ExceptionBlock  CONSTANT AstSymbolType := 'ExceptionBlock';
    ast_FunctionDef     CONSTANT AstSymbolType := 'FunctionDef';
    ast_FunctionDecl    CONSTANT AstSymbolType := 'FunctionDecl';
    ast_InnerBlock      CONSTANT AstSymbolType := 'InnerBlock';
    ast_OtherDecl       CONSTANT AstSymbolType := 'OtherDecl';
    ast_ExecutableDecl  CONSTANT AstSymbolType := 'ExecutableDecl';
    ast_PackageBody     CONSTANT AstSymbolType := 'PackageBody';
    ast_ProcedureDef    CONSTANT AstSymbolType := 'ProcedureDef';
    ast_ProcedureDecl   CONSTANT AstSymbolType := 'ProcedureDecl';
    ast_SimpleStatement CONSTANT AstSymbolType := 'SimpleStatement';

    -- initializes parser with object source
    PROCEDURE initialize
    (
        p_owner all_source.owner%Type,
        p_name  all_source.name%Type,
        p_type  all_source.type%Type
    );

    -- initializes parser with source lines    
    PROCEDURE initialize(p_source_lines IN plex_lexer.typ_source_text);

    -- parse source lines and return root AST
    FUNCTION parse RETURN plparse_ast;

END;
/
