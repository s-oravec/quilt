CREATE OR REPLACE Type BODY plex_matchwhitespace AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_matchwhitespace RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text VARCHAR2(4000);
    BEGIN
        WHILE (NOT plex_lexer.eof AND regexp_like(plex_lexer.currentItem, '\s')) LOOP
            l_Text := l_Text || plex_lexer.currentItem;
            plex_lexer.consume;
        END LOOP;
    
        IF l_Text IS NOT NULL THEN
            RETURN NEW plex_token(plex_lexer.tk_WhiteSpace, l_Text);
        END IF;
    
        RETURN NULL;
    END;

END;
/
