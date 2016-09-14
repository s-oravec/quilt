CREATE OR REPLACE PACKAGE BODY plparse_parser AS

    FUNCTION blockDeclPart RETURN plparse_AST_BlockDeclPart;
    FUNCTION blockCode RETURN plparse_AST_BlockCode;

    ----------------------------------------------------------------------------
    PROCEDURE initialize
    (
        p_owner all_source.owner%Type,
        p_name  all_source.name%Type,
        p_type  all_source.type%Type
    ) IS
    BEGIN
        plparse_token_stream.initialize(p_owner, p_name, p_type);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initialize(p_source_lines IN plex_lexer.typ_source_text) IS
    BEGIN
        plparse_token_stream.initialize(p_source_lines);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE raiseUnexpectedToken(tokenType IN plex_lexer.TokenType) IS
    BEGIN
        -- TODO: create wiki page on github and add bitly link here
        raise_application_error(-20000, 'Unexpected token ' || tokenType);
    END;

    ----------------------------------------------------------------------------  
    PROCEDURE appendToList
    (
        ast      IN plparse_ast,
        children IN OUT NOCOPY plparse_ASTChildren
    ) IS
    BEGIN
        IF ast IS NOT NULL THEN
            children.extend();
            children(children.last) := ast.id_registry;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentTokenType RETURN plex_lexer.TokenType IS
    BEGIN
        RETURN plparse_token_stream.currentToken().tokenType;
    END;

    ---------------------------------------------------------------------------- 
    FUNCTION currentTokenTypeIs(tokeType plex_lexer.TokenType) RETURN BOOLEAN IS
    BEGIN
        RETURN plparse_token_stream.currentToken().tokenType = tokeType;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION currentTokenIsReserwedWord(reservedWord plex_lexer.TokenType) RETURN BOOLEAN IS
        l_currentToken plex_token;
    BEGIN
        l_currentToken := plparse_token_stream.currentToken();
        RETURN l_currentToken.tokenType = plex_lexer.tk_Word AND upper(l_currentToken.text) = upper(reservedWord);
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentTokenText RETURN VARCHAR2 IS
    BEGIN
        RETURN plparse_token_stream.currentToken().text;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE raiseUnexpectedToken IS
    BEGIN
        raise_application_error(-20000, 'Unexpected token ' || currentTokenType || ':' || currentTokenText);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeAny
    (
        tokenType1 IN plex_lexer.TokenType,
        tokenType2 IN plex_lexer.TokenType
    ) IS
    BEGIN
        IF currentTokenType IN (tokenType1, tokenType2) THEN
            plparse_token_stream.consume;
        ELSE
            raiseUnexpectedToken;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION peekTokenType(lookahead IN PLS_INTEGER DEFAULT 0) RETURN plex_lexer.TokenType IS
    BEGIN
        RETURN plparse_token_stream.peek(lookahead).tokenType;
    END;

    ----------------------------------------------------------------------------
    FUNCTION peekTokenText(lookahead IN PLS_INTEGER DEFAULT 0) RETURN plex_lexer.TokenType IS
    BEGIN
        RETURN plparse_token_stream.peek(lookahead).text;
    END;

    ----------------------------------------------------------------------------
    FUNCTION simpleName RETURN VARCHAR2 IS
        l_Result VARCHAR2(255);
    BEGIN
        IF currentTokenType = plex_lexer.tk_Word THEN
            l_Result := currentTokenText;
            plparse_token_stream.consume;
            RETURN l_Result;
        END IF;
        raiseUnexpectedToken;
    END;

    ----------------------------------------------------------------------------
    FUNCTION qualifiedNameLocal RETURN VARCHAR2 IS
        l_Result VARCHAR2(255);
    BEGIN
        IF currentTokenType = plex_lexer.tk_Word THEN
            l_Result := currentTokenText;
            plparse_token_stream.consume;
            --
            IF currentTokenType = plex_lexer.tk_Dot THEN
                -- consume rest of qualified name
                l_Result := l_Result || currentTokenText;
                plparse_token_stream.consume;
                l_Result := l_Result || currentTokenText;
                plparse_token_stream.consume;
            END IF;
            RETURN l_Result;
        END IF;
        raiseUnexpectedToken;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION otherDecl RETURN plparse_ast IS
        l_sourceLine_start      PLS_INTEGER;
        l_sourceLineIndex_start PLS_INTEGER;
        l_sourceLine_end        PLS_INTEGER;
        l_sourceLineIndex_end   PLS_INTEGER;
        l_currentToken          plex_token;
    BEGIN
        l_currentToken          := plparse_token_stream.currentToken;
        l_sourceLine_start      := l_currentToken.sourceLine;
        l_sourceLineIndex_start := l_currentToken.sourceLineIndex;
        LOOP
            l_currentToken        := plparse_token_stream.take;
            l_sourceLine_end      := l_currentToken.sourceLine;
            l_sourceLineIndex_end := l_currentToken.sourceLineIndex + length(l_currentToken.text);
            IF l_currentToken.tokenType = plex_lexer.tk_Semicolon THEN
                RETURN plparse_ast.createNew(symbol_type           => plparse_parser.ast_OtherDecl,
                                             sourceLine_start      => l_sourceLine_start,
                                             sourceLineIndex_start => l_sourceLineIndex_start,
                                             sourceLine_end        => l_sourceLine_end,
                                             sourceLineIndex_end   => l_sourceLineIndex_end);
            ELSIF l_currentToken.tokenType = plex_lexer.tk_EOF THEN
                raiseUnexpectedToken;
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION procedureDefinition RETURN plparse_AST_Block IS
        l_Name VARCHAR2(255);
    BEGIN
        plparse_token_stream.take(plex_lexer.kw_PROCEDURE);
        l_Name := simpleName();
        -- TODO: param list
        takeAny(plex_lexer.kw_IS, plex_lexer.kw_AS);
        RETURN plparse_ast_block.createNew(l_Name, plparse_parser.ast_Procedure, blockDeclPart(), blockCode());
    END;

    ----------------------------------------------------------------------------  
    FUNCTION blockDeclPart RETURN plparse_AST_BlockDeclPart IS
    
        l_declarations plparse_AstChildren;
    
        ----------------------------------------------------------------------------  
        PROCEDURE appendIfMatch(ast IN plparse_ast) IS
        BEGIN
            IF ast IS NOT NULL THEN
                l_declarations.extend();
                l_declarations(l_declarations.last) := ast.id_registry;
            END IF;
        END;
    
    BEGIN
        IF currentTokenType NOT IN (plex_lexer.kw_END, plex_lexer.kw_BEGIN) THEN
            l_declarations := plparse_AstChildren();
            WHILE currentTokenType NOT IN (
                                           -- end of package body/type body declaration - when it doesn't contain initialization block
                                           plex_lexer.kw_END,
                                           -- end of function/procedure declaration pat or start of initialization bloc in package body
                                           plex_lexer.kw_BEGIN) LOOP
                IF currentTokenType = plex_lexer.kw_PROCEDURE THEN
                    -- procedure
                    appendIfMatch(procedureDefinition);
                    -- TODO: rest of objects
                    --   function
                    --   declaration with initialization
                    --     - constant
                    --     - variable with initialization
                ELSIF (currentTokenType IN (plex_lexer.kw_TYPE, plex_lexer.kw_CURSOR)) OR
                      (currentTokenType = plex_lexer.tk_Word AND upper(currentTokenText) IN (plex_lexer.rw_PRAGMA)) THEN
                    -- other declarations - type, cursor, pragma - consume until ;                
                    appendIfMatch(otherDecl);
                ELSE
                    -- consume rest unknown
                    -- TODO: declaration without initialization - consume until ;                            
                    -- TODO: raiseUnexpectedToken here
                    plparse_token_stream.consume;
                END IF;
            END LOOP;
            RETURN plparse_AST_BlockDeclPart.createNew(l_declarations);
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION isSimpleStatement RETURN BOOLEAN IS
    BEGIN
        RETURN currentTokenType IN(plex_lexer.kw_NULL,
                                   plex_lexer.kw_SELECT,
                                   plex_lexer.kw_WITH,
                                   plex_lexer.kw_INSERT,
                                   plex_lexer.kw_GOTO,
                                   plex_lexer.kw_UPDATE,
                                   plex_lexer.kw_FETCH) OR(currentTokenType = plex_lexer.tk_Word AND
                                                           upper(currentTokenText) IN (plex_lexer.rw_FORALL,
                                                                                       plex_lexer.rw_MERGE,
                                                                                       plex_lexer.rw_EXIT,
                                                                                       plex_lexer.rw_RETURN,
                                                                                       plex_lexer.rw_OPEN,
                                                                                       plex_lexer.rw_CONTINUE,
                                                                                       plex_lexer.rw_PIPE,
                                                                                       plex_lexer.rw_RAISE,
                                                                                       plex_lexer.rw_CLOSE,
                                                                                       plex_lexer.rw_EXECUTE));
    END;

    ---------------------------------------------------------------------------- 
    FUNCTION simpleStatement RETURN plparse_ast IS
        l_sourceLine_start      PLS_INTEGER;
        l_sourceLineIndex_start PLS_INTEGER;
        l_sourceLine_end        PLS_INTEGER;
        l_sourceLineIndex_end   PLS_INTEGER;
        l_currentToken          plex_token;
    BEGIN
        IF isSimpleStatement THEN
            --
            l_currentToken          := plparse_token_stream.currentToken;
            l_sourceLine_start      := l_currentToken.sourceLine;
            l_sourceLineIndex_start := l_currentToken.sourceLineIndex;
            LOOP
                l_currentToken        := plparse_token_stream.take;
                l_sourceLine_end      := l_currentToken.sourceLine;
                l_sourceLineIndex_end := l_currentToken.sourceLineIndex + length(l_currentToken.text);
                IF l_currentToken.tokenType = plex_lexer.tk_Semicolon THEN
                    RETURN plparse_ast.createNew(symbol_type           => plparse_parser.ast_SimpleStatement,
                                                 sourceLine_start      => l_sourceLine_start,
                                                 sourceLineIndex_start => l_sourceLineIndex_start,
                                                 sourceLine_end        => l_sourceLine_end,
                                                 sourceLineIndex_end   => l_sourceLineIndex_end);
                ELSIF l_currentToken.tokenType = plex_lexer.tk_EOF THEN
                    raiseUnexpectedToken;
                END IF;
            END LOOP;
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------  
    FUNCTION blockCode RETURN plparse_AST_BlockCode IS
        l_statements plparse_AstChildren;
    BEGIN
        IF currentTokenType = plex_lexer.kw_BEGIN THEN
            plparse_token_stream.consume;
            l_statements := plparse_AstChildren();
            WHILE currentTokenType != plex_lexer.kw_END LOOP
                -- parse complex statements
                --   if
                --   case
                --   while
                --   for
                --   loop
                IF currentTokenType = plex_lexer.kw_DECLARE THEN
                    -- conusme DECLARE kw
                    plparse_token_stream.consume;
                    -- append inner anonymous block with declaration
                    appendToList(plparse_ast_block.createNew(NULL, plparse_parser.ast_InnerBlock, blockDeclPart(), blockCode()),
                                 l_statements);
                ELSIF currentTokenType = plex_lexer.kw_BEGIN THEN
                    -- append inner anonymous block without declaration
                    appendToList(plparse_ast_block.createNew(NULL, plparse_parser.ast_InnerBlock, NULL, blockCode()), l_statements);
                ELSIF isSimpleStatement THEN
                    -- simple statements - forall, select, with, insert, update, delete, merge, exit, return, fetch, open, close, execute, null - take until ;
                    -- goto, raise, pipe, continue
                    appendToList(simpleStatement(), l_statements);
                ELSE
                    plparse_token_stream.consume;
                END IF;
            END LOOP;
            -- take block end
            plparse_token_stream.take(plex_lexer.kw_END);
            -- consume optional name after end
            IF currentTokenType = plex_lexer.tk_Word THEN
                plparse_token_stream.consume;
            END IF;
            -- and semicolon
            plparse_token_stream.take(plex_lexer.tk_Semicolon);
            RETURN plparse_AST_BlockCode.createNew(l_statements);
        END IF;
        RETURN NULL;
    END;

    ----------------------------------------------------------------------------
    FUNCTION packageBody RETURN plparse_AST_Block IS
        l_Name VARCHAR2(255);
    BEGIN
        plparse_token_stream.takeReservedWord(plex_lexer.rw_PACKAGE);
        plparse_token_stream.takeReservedWord(plex_lexer.rw_BODY);
        l_Name := qualifiedNameLocal();
        takeAny(plex_lexer.kw_IS, plex_lexer.kw_AS);
        RETURN plparse_ast_block.createNew(l_Name, plparse_parser.ast_PackageBody, blockDeclPart(), blockCode());
    END;

    ----------------------------------------------------------------------------
    FUNCTION parse RETURN plparse_ast IS
        l_statements plparse_ASTChildren;
        l_ast        plparse_ast;
    BEGIN
        RETURN packageBody;
    END;

END;
/
