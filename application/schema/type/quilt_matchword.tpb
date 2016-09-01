CREATE OR REPLACE Type BODY quilt_matchword AS

    ----------------------------------------------------------------------------  
    CONSTRUCTOR FUNCTION quilt_matchword RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------  
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text VARCHAR2(255);
    BEGIN
        IF regexp_like(quilt_lexer.currentItem, '[a-z]', 'i') THEN
            l_Text := quilt_lexer.currentItem;
            quilt_lexer.consume;
            --
            WHILE regexp_like(quilt_lexer.currentItem, '[a-z0-9_#\$]', 'i') AND NOT quilt_lexer.eof LOOP
                l_Text := l_Text || quilt_lexer.currentItem;
                quilt_lexer.consume;
            END LOOP;
            --
            RETURN NEW quilt_token(quilt_lexer.tk_Word, l_Text);
            --
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
