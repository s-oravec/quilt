CREATE OR REPLACE Type BODY quilt_matchnumberliteral AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_matchnumberliteral RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text VARCHAR2(255);
        l_Sign VARCHAR2(1);
        PROCEDURE consumeAndAppend IS
        BEGIN
            l_Text := l_Text || quilt_lexer.currentItem;
            quilt_lexer.consume;
        END;
    BEGIN
        IF quilt_lexer.currentItem IN ('-', '+') THEN
            l_Sign := quilt_lexer.currentItem;
            quilt_lexer.consume;
        END IF;
    
        IF ascii(quilt_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') THEN
            WHILE NOT quilt_lexer.eof AND ascii(quilt_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
            IF quilt_lexer.currentItem = '.' THEN
                consumeAndAppend;
            END IF;
            WHILE NOT quilt_lexer.eof AND ascii(quilt_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
        ELSIF quilt_lexer.currentItem = '.' THEN
            consumeAndAppend;
            IF ascii(quilt_lexer.currentItem) NOT BETWEEN ascii('0') AND ascii('9') THEN
                RETURN NULL;
            END IF;
            WHILE NOT quilt_lexer.eof AND ascii(quilt_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
        ELSE
            RETURN NULL;
        END IF;
    
        IF quilt_lexer.currentItem IN ('e', 'E', '-', '+') THEN
            IF quilt_lexer.currentItem IN ('e', 'E') THEN
                consumeAndAppend;
            END IF;
            IF quilt_lexer.currentItem IN ('-', '+') THEN
                consumeAndAppend;
            END IF;
            IF ascii(quilt_lexer.currentItem) NOT BETWEEN ascii('0') AND ascii('9') THEN
                RETURN NULL;
            END IF;
            WHILE NOT quilt_lexer.eof AND ascii(quilt_lexer.currentItem) BETWEEN ascii('0') AND ascii('9') LOOP
                consumeAndAppend;
            END LOOP;
        END IF;
    
        IF quilt_lexer.currentItem IN ('f', 'F', 'd', 'D') THEN
            consumeAndAppend;
        END IF;
    
        IF l_Text IS NOT NULL THEN
            RETURN NEW quilt_token(quilt_lexer.tk_NumberLiteral, l_Sign || l_Text);
        END IF;
    
        RETURN NULL;
    END;

END;
/
