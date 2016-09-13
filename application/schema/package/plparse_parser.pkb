CREATE OR REPLACE PACKAGE BODY plparse_parser AS

    -- list of tokens returned by lexer
    g_tokens plex_tokens;
    -- current index
    g_index PLS_INTEGER;
    --
    g_snapshotIndexes quilt_integer_stack;

    ----------------------------------------------------------------------------
    PROCEDURE initialize_impl IS
    BEGIN
        plparse_ast_util.init;
        g_tokens          := plex_lexer.tokens;
        g_index           := 1;
        g_snapshotIndexes := quilt_integer_stack();
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentToken RETURN plex_token IS
    BEGIN
        RETURN g_tokens(g_index);
    END;

    ----------------------------------------------------------------------------
    FUNCTION isMatch(TokenType plex_lexer.TokenType) RETURN BOOLEAN IS
        l_currentToken plex_token := currentToken;
    BEGIN
        IF l_currentToken.token = TokenType THEN
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;

    ----------------------------------------------------------------------------  
    PROCEDURE initialize
    (
        p_owner all_source.owner%Type,
        p_name  all_source.name%Type,
        p_type  all_source.type%Type
    ) IS
    BEGIN
        plex_lexer.initialize(p_owner, p_name, p_type);
        initialize_impl;
    END;

    ----------------------------------------------------------------------------  
    PROCEDURE initialize(p_source_lines IN plex_lexer.typ_source_text) IS
    BEGIN
        plex_lexer.initialize(p_source_lines);
        initialize_impl;
    END;

    ----------------------------------------------------------------------------
    FUNCTION getIndex RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_index;
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof(p_lookahead PLS_INTEGER) RETURN BOOLEAN IS
        l_currentToken plex_token;
    BEGIN
        l_currentToken := currentToken;
        IF g_tokens IS NULL OR g_index + p_lookahead > g_tokens.count OR l_currentToken.token = plex_lexer.tk_EOF THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof RETURN BOOLEAN IS
    BEGIN
        RETURN eof(0);
    END;

    ----------------------------------------------------------------------------
    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN plex_token IS
    BEGIN
        IF eof(p_lookahead) THEN
            RETURN NULL;
        ELSE
            RETURN g_tokens(g_index + p_lookahead);
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE consume IS
    BEGIN
        g_index := g_index + 1;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeSnapshot IS
    BEGIN
        g_snapshotIndexes.push(g_index);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE rollbackSnapshot IS
    BEGIN
        g_index := g_snapshotIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    PROCEDURE commitSnapshot IS
    BEGIN
        g_snapshotIndexes.pop();
    END;

END;
/
