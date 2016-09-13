CREATE OR REPLACE Type BODY plex_matchsinglelinecomment AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_matchsinglelinecomment RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text VARCHAR2(32767);
    BEGIN
        IF plex_lexer.currentItem = '-' AND plex_lexer.peek(1) = '-' THEN
            WHILE NOT plex_lexer.eof AND plex_lexer.currentItem != chr(10) LOOP
                l_Text := l_Text || plex_lexer.currentItem;
                plex_lexer.consume;
            END LOOP;
            RETURN plex_token(plex_lexer.tk_SingleLineComment, l_Text);
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
