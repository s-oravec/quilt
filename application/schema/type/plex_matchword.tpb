CREATE OR REPLACE Type BODY plex_matchword AS

    ----------------------------------------------------------------------------  
    CONSTRUCTOR FUNCTION plex_matchword RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------  
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text VARCHAR2(255);
    BEGIN
        IF regexp_like(plex_lexer.currentItem, '[a-z]', 'i') THEN
            l_Text := plex_lexer.currentItem;
            plex_lexer.consume;
            --
            WHILE regexp_like(plex_lexer.currentItem, '[a-z0-9_#\$]', 'i') AND NOT plex_lexer.eof LOOP
                l_Text := l_Text || plex_lexer.currentItem;
                plex_lexer.consume;
            END LOOP;
            --
            RETURN NEW plex_token(plex_lexer.tk_Word, l_Text);
            --
        ELSIF plex_lexer.currentItem = '"' THEN
            l_Text := plex_lexer.currentItem;
            plex_lexer.consume;
            --
            WHILE NOT plex_lexer.eof AND plex_lexer.currentItem != '"' LOOP
                l_Text := l_Text || plex_lexer.currentItem;
                plex_lexer.consume;
            END LOOP;
            --
            l_Text := l_text || plex_lexer.currentItem;
            plex_lexer.consume;
            --
            RETURN NEW plex_token(plex_lexer.tk_Word, l_Text);
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
