CREATE OR REPLACE Type BODY quilt_matchsinglelinecomment AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_matchsinglelinecomment RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text VARCHAR2(32767);
    BEGIN
        IF quilt_lexer.currentItem = '-' AND quilt_lexer.peek(1) = '-' THEN
            WHILE NOT quilt_lexer.eof AND quilt_lexer.currentItem != chr(10) LOOP
                l_Text := l_Text || quilt_lexer.currentItem;
                quilt_lexer.consume;
            END LOOP;
            RETURN quilt_token(quilt_lexer.tk_SingleLineComment, l_Text);
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
