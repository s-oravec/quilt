CREATE OR REPLACE Type BODY plex_matchnumberliteral AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_matchnumberliteral RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text VARCHAR2(255);
        l_Sign VARCHAR2(1);
        PROCEDURE consumeAndAppend IS
        BEGIN
            l_Text := l_Text || plex_lexer.currentItem;
            plex_lexer.consume;
        END;
    BEGIN
        IF plex_lexer.currentItem IN ('-', '+') THEN
            l_Sign := plex_lexer.currentItem;
            plex_lexer.consume;
        END IF;
    
        IF ascii(plex_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') THEN
            WHILE NOT plex_lexer.eof AND ascii(plex_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
            IF plex_lexer.currentItem = '.' THEN
                consumeAndAppend;
            END IF;
            WHILE NOT plex_lexer.eof AND ascii(plex_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
        ELSIF plex_lexer.currentItem = '.' THEN
            consumeAndAppend;
            IF ascii(plex_lexer.currentItem) NOT BETWEEN ascii('0') AND ascii('9') THEN
                RETURN NULL;
            END IF;
            WHILE NOT plex_lexer.eof AND ascii(plex_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
        ELSE
            RETURN NULL;
        END IF;
    
        IF plex_lexer.currentItem IN ('e', 'E', '-', '+') THEN
            IF plex_lexer.currentItem IN ('e', 'E') THEN
                consumeAndAppend;
            END IF;
            IF plex_lexer.currentItem IN ('-', '+') THEN
                consumeAndAppend;
            END IF;
            IF ascii(plex_lexer.currentItem) NOT BETWEEN ascii('0') AND ascii('9') THEN
                RETURN NULL;
            END IF;
            WHILE NOT plex_lexer.eof AND ascii(plex_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
        END IF;
    
        IF plex_lexer.currentItem IN ('f', 'F', 'd', 'D') THEN
            consumeAndAppend;
        END IF;
    
        IF l_Text IS NOT NULL THEN
            RETURN NEW plex_token(plex_lexer.tk_NumberLiteral, l_Sign || l_Text);
        END IF;
    
        RETURN NULL;
    END;

END;
/
