CREATE OR REPLACE PACKAGE BODY plex_lexer AS

    g_index               PLS_INTEGER;
    g_line                PLS_INTEGER;
    g_lineIndex           PLS_INTEGER;
    g_snapshotIndexes     quilt_integer_stack;
    g_snapshotLines       quilt_integer_stack;
    g_snapshotLineIndexes quilt_integer_stack;
    g_source              CLOB;
    g_sourceTextLines     typ_source_text;

    Type typ_tableOfTokens IS TABLE OF TokenType;
    g_specialCharacterTokens typ_tableOfTokens;
    g_keywordTokens          typ_tableOfTokens;

    g_matchers plex_matchers;

    ----------------------------------------------------------------------------
    FUNCTION getIndex RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_index;
    END;

    ----------------------------------------------------------------------------
    FUNCTION getLine RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_line;
    END;

    ----------------------------------------------------------------------------
    FUNCTION getLineIndex RETURN PLS_INTEGER IS
    BEGIN
        RETURN g_lineIndex;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initializeMatchers IS
        PROCEDURE appendMatcher(p_matcher plex_matcher) IS
        BEGIN
            g_matchers.extend();
            g_matchers(g_matchers.count) := p_matcher;
        END;
    BEGIN
        g_matchers := plex_matchers();
        --
        -- single line comment
        appendMatcher(NEW plex_matchSingleLineComment());
        --
        -- single line comment
        appendMatcher(NEW plex_matchMultiLineComment());
        --
        -- add special characters matchers    
        FOR idx IN 1 .. g_specialCharacterTokens.count LOOP
            appendMatcher(NEW plex_matchKeyword(token => g_specialCharacterTokens(idx), stringToMatch => g_specialCharacterTokens(idx)));
        END LOOP;
        --
        -- add keyword matchers
        FOR idx IN 1 .. g_keywordTokens.count LOOP
            appendMatcher(NEW
                          plex_matchKeyword(token => g_keywordTokens(idx), stringToMatch => g_keywordTokens(idx), allowAsSubstring => 'N'));
        END LOOP;
        --
        -- add whitespace matcher
        appendMatcher(NEW plex_matchWhitespace());
        --
        -- add matcher for matching string literals
        appendMatcher(NEW plex_matchTextLiteral());
        --
        -- add matcher for matching number literals
        appendMatcher(NEW plex_matchNumberLiteral());
        --
        -- add matcher for matching words
        appendMatcher(NEW plex_matchWord());
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initialize(p_source_lines IN typ_source_text) IS
    BEGIN
        -- set indexes (we index from 1 in PLSQL)
        g_index     := 1;
        g_line      := 1;
        g_lineIndex := 1;
        -- load source from db
        g_snapshotIndexes     := quilt_integer_stack();
        g_snapshotLines       := quilt_integer_stack();
        g_snapshotLineIndexes := quilt_integer_stack();
        --
        g_sourceTextLines := p_source_lines;
        g_source          := '';
        --
        FOR lineIdx IN 1 .. g_sourceTextLines.count LOOP
            g_source := g_source || g_sourceTextLines(lineIdx);
        END LOOP;
        --
        initializeMatchers;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE initialize
    (
        p_owner all_source.owner%Type,
        p_name  all_source.name%Type,
        p_type  all_source.type%Type
    ) IS
        l_sourceTextLines typ_source_text;
    BEGIN
        --
        SELECT Text
          BULK COLLECT
          INTO l_sourceTextLines
          FROM all_source
         WHERE OWNER = p_owner
           AND Name = p_name
           AND Type = p_type
         ORDER BY Line;
        --
        initialize(p_source_lines => l_sourceTextLines);
    END;

    ----------------------------------------------------------------------------
    FUNCTION eof(p_lookahead PLS_INTEGER) RETURN BOOLEAN IS
    BEGIN
        IF g_source IS NULL OR g_index + p_lookahead > length(g_source) THEN
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
    FUNCTION peek(p_lookahead PLS_INTEGER) RETURN VARCHAR2 IS
        l_Result VARCHAR2(1);
    BEGIN
        IF eof(p_lookahead) THEN
            RETURN NULL;
        ELSE
            l_Result := substr(g_source, g_index + p_lookahead, 1);
            RETURN l_Result;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION currentItem RETURN VARCHAR2 IS
    BEGIN
        IF (eof(0)) THEN
            RETURN NULL;
        ELSE
            RETURN substr(g_source, g_index, 1);
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE consume IS
    BEGIN
        g_index := g_index + 1;
        -- increase line is already beyon count of chars on line (= g_lineIndex is on chr(10) that we used to separate lines in g_source clob)
        IF length(g_sourceTextLines(g_line)) < g_lineIndex THEN
            -- switch to next line
            g_line      := g_line + 1;
            g_lineIndex := 1;
        ELSE
            g_lineIndex := g_lineIndex + 1;
        END IF;
    END;

    ----------------------------------------------------------------------------
    PROCEDURE takeSnapshot IS
    BEGIN
        g_snapshotIndexes.push(g_index);
        g_snapshotLines.push(g_line);
        g_snapshotLineIndexes.push(g_lineIndex);
    END;

    ----------------------------------------------------------------------------
    PROCEDURE rollbackSnapshot IS
    BEGIN
        g_index     := g_snapshotIndexes.pop();
        g_line      := g_snapshotLines.pop();
        g_lineIndex := g_snapshotLineIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    PROCEDURE commitSnapshot IS
    BEGIN
        g_snapshotIndexes.pop();
        g_snapshotLines.pop();
        g_snapshotLineIndexes.pop();
    END;

    ----------------------------------------------------------------------------
    FUNCTION isSpecialCharacter(p_character IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        -- TODO: fix this
        RETURN p_character IN(tk_Asterix,
                              tk_Colon,
                              tk_Comma,
                              tk_Dollar,
                              tk_Dot,
                              tk_Equals,
                              tk_ExclamationMark,
                              tk_GreaterThan,
                              tk_Hash,
                              tk_LessThan,
                              tk_LParenth,
                              tk_Minus,
                              tk_Percent,
                              tk_Pipe,
                              tk_Plus,
                              tk_Quote,
                              tk_RParenth,
                              tk_Semicolon,
                              tk_Slash,
                              tk_Underscore);
    END;

    ----------------------------------------------------------------------------
    FUNCTION nextTokenImpl RETURN plex_token IS
        l_Result plex_token;
    BEGIN
        IF eof THEN
            l_Result := NEW plex_token(tk_EOF);
        ELSE
            FOR matcherIdx IN 1 .. g_matchers.count LOOP
                l_Result := g_matchers(matcherIdx).isMatch();
                EXIT WHEN l_Result IS NOT NULL;
            END LOOP;
        END IF;
        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    FUNCTION nextToken RETURN plex_token IS
        l_Result plex_token;
    BEGIN
        l_Result := nextTokenImpl();
        WHILE l_Result IS NOT NULL AND l_result.token != tk_EOF LOOP
            IF l_result.token != tk_WhiteSpace THEN
                RETURN l_Result;
            END IF;
            l_Result := nextTokenImpl;
        END LOOP;
        IF l_Result IS NULL THEN
            raise_application_error(-20000,
                                    'Unknown token at ' || g_line || ':' || g_lineIndex || ' "' || substr(g_source, g_index, 10) || ' ..."');
        ELSE
            RETURN l_Result;
        END IF;
    END;

    ----------------------------------------------------------------------------
    FUNCTION tokens RETURN plex_tokens IS
        l_Result plex_tokens;
    BEGIN
        l_Result := plex_tokens();
        LOOP
            l_Result.extend;
            l_Result(l_Result.count) := plex_lexer.nextToken;
            EXIT WHEN l_Result(l_Result.count).token = plex_lexer.tk_EOF;
        END LOOP;
        RETURN l_Result;
    END;

BEGIN
    g_specialCharacterTokens := typ_tableOfTokens(tk_Dot,
                                                  tk_Comma,
                                                  tk_Colon,
                                                  tk_Semicolon,
                                                  tk_Plus,
                                                  tk_Minus,
                                                  tk_Asterix,
                                                  tk_Slash,
                                                  tk_Hash,
                                                  tk_Underscore,
                                                  tk_Dollar,
                                                  tk_Pipe,
                                                  tk_Percent,
                                                  tk_Quote,
                                                  tk_ExclamationMark,
                                                  tk_Equals,
                                                  tk_GreaterThan,
                                                  tk_LessThan,
                                                  tk_LParenth,
                                                  tk_RParenth);

    g_keywordTokens := typ_tableOfTokens(kw_ALL,
                                         kw_ALTER,
                                         kw_AND,
                                         kw_ANY,
                                         kw_AS,
                                         kw_ASC,
                                         kw_AT,
                                         kw_BEGIN,
                                         kw_BETWEEN,
                                         kw_BY,
                                         kw_CASE,
                                         kw_CHECK,
                                         kw_CLUSTERS,
                                         kw_CLUSTER,
                                         kw_COLAUTH,
                                         kw_COLUMNS,
                                         kw_COMPRESS,
                                         kw_CONNECT,
                                         kw_CRASH,
                                         kw_CREATE,
                                         kw_CURSOR,
                                         kw_DECLARE,
                                         kw_DEFAULT,
                                         kw_DESC,
                                         kw_DISTINCT,
                                         kw_DROP,
                                         kw_ELSE,
                                         kw_END,
                                         kw_EXCEPTION,
                                         kw_EXCLUSIVE,
                                         kw_FETCH,
                                         kw_FOR,
                                         kw_FROM,
                                         kw_FUNCTION,
                                         kw_GOTO,
                                         kw_GRANT,
                                         kw_GROUP,
                                         kw_HAVING,
                                         kw_IDENTIFIED,
                                         kw_IF,
                                         kw_IN,
                                         kw_INDEX,
                                         kw_INDEXES,
                                         kw_INSERT,
                                         kw_INTERSECT,
                                         kw_INTO,
                                         kw_IS,
                                         kw_LIKE,
                                         kw_LOCK,
                                         kw_MINUS,
                                         kw_MODE,
                                         kw_NOCOMPRESS,
                                         kw_NOT,
                                         kw_NOWAIT,
                                         kw_NULL,
                                         kw_OF,
                                         kw_ON,
                                         kw_OPTION,
                                         kw_OR,
                                         kw_ORDER,
                                         kw_OVERLAPS,
                                         kw_PROCEDURE,
                                         kw_PUBLIC,
                                         kw_RESOURCE,
                                         kw_REVOKE,
                                         kw_SELECT,
                                         kw_SHARE,
                                         kw_SIZE,
                                         kw_SQL,
                                         kw_START,
                                         kw_SUBTYPE,
                                         kw_TABAUTH,
                                         kw_TABLE,
                                         kw_THEN,
                                         kw_TO,
                                         kw_TYPE,
                                         kw_UNION,
                                         kw_UNIQUE,
                                         kw_UPDATE,
                                         kw_VALUES,
                                         kw_VIEW,
                                         kw_VIEWS,
                                         kw_WHEN,
                                         kw_WHERE,
                                         kw_WITH);
END plex_lexer;
/
