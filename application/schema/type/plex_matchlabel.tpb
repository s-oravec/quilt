CREATE OR REPLACE Type BODY plex_matchLabel AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_matchLabel RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text VARCHAR2(4000);
    BEGIN
        IF plex_lexer.currentItem = '<' AND plex_lexer.peek(1) = '<' THEN
            -- consume <<
            plex_lexer.consume;
            plex_lexer.consume;
            WHILE NOT ((plex_lexer.currentItem = '>' AND plex_lexer.peek(1) = '>') OR plex_lexer.eof) LOOP
                l_Text := l_Text || plex_lexer.currentItem;
                plex_lexer.consume;
            END LOOP;
            -- consume >>            
            plex_lexer.consume;
            plex_lexer.consume;
        END IF;
    
        IF l_Text IS NOT NULL THEN
            RETURN NEW plex_token(plex_lexer.tk_Label, l_Text);
        END IF;
    
        RETURN NULL;
    END;

END;
/
