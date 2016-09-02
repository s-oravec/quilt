CREATE OR REPLACE Type BODY quilt_matchmultilinecomment AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_matchmultilinecomment RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text VARCHAR2(32767);
    BEGIN
        IF quilt_lexer.currentItem = '/' AND quilt_lexer.peek(1) = '*' THEN
            quilt_lexer.consume;
            quilt_lexer.consume;
            l_Text := '/*';
            WHILE NOT quilt_lexer.eof AND NOT (quilt_lexer.currentItem = '*' AND quilt_lexer.peek(1) = '/') LOOP
                l_Text := l_Text || quilt_lexer.currentItem;
                quilt_lexer.consume;
            END LOOP;
            quilt_lexer.consume;
            quilt_lexer.consume;
            l_Text := l_Text || '*/';
            RETURN quilt_token(quilt_lexer.tk_multiLineComment, l_Text);
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
