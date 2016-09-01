CREATE OR REPLACE Type BODY quilt_matchwhitespace AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_matchwhitespace RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_found BOOLEAN := FALSE;
    BEGIN
        WHILE (NOT quilt_lexer.eof AND regexp_like(quilt_lexer.currentItem, '\s')) LOOP
            l_found := TRUE;
            quilt_lexer.consume;
        END LOOP;
    
        IF l_found THEN
            RETURN NEW quilt_token(quilt_lexer.tk_WhiteSpace);
        END IF;
    
        RETURN NULL;
    END;

END;
/
