CREATE OR REPLACE Type BODY plex_matchmultilinecomment AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_matchmultilinecomment RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text VARCHAR2(32767);
    BEGIN
        IF plex_lexer.currentItem = '/' AND plex_lexer.peek(1) = '*' THEN
            plex_lexer.consume;
            plex_lexer.consume;
            l_Text := '/*';
            WHILE NOT plex_lexer.eof AND NOT (plex_lexer.currentItem = '*' AND plex_lexer.peek(1) = '/') LOOP
                l_Text := l_Text || plex_lexer.currentItem;
                plex_lexer.consume;
            END LOOP;
            plex_lexer.consume;
            plex_lexer.consume;
            l_Text := l_Text || '*/';
            RETURN plex_token(plex_lexer.tk_multiLineComment, l_Text);
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
