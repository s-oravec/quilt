CREATE OR REPLACE Type BODY quilt_matchwhitespace AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_matchwhitespace RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text VARCHAR2(4000);
    BEGIN
        WHILE (NOT quilt_lexer.eof AND regexp_like(quilt_lexer.currentItem, '\s')) LOOP
            l_Text := l_Text || quilt_lexer.currentItem;
            quilt_lexer.consume;
        END LOOP;
    
        IF l_Text IS NOT NULL THEN
            RETURN NEW quilt_token(quilt_lexer.tk_WhiteSpace, l_Text);
        END IF;
    
        RETURN NULL;
    END;

END;
/
