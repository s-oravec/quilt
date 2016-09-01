CREATE OR REPLACE Type BODY quilt_matcher AS

    ----------------------------------------------------------------------------  
    MEMBER FUNCTION isMatch RETURN quilt_token IS
        l_matchedToken quilt_token;
    BEGIN
        IF quilt_lexer.eof THEN
            RETURN new quilt_token(quilt_lexer.tk_EOF);
        END IF;
        quilt_lexer.takeSnapshot;
        l_matchedToken := isMatchImpl();
        IF l_matchedToken IS NULL THEN
            quilt_lexer.rollbackSnapshot;
        ELSE
            quilt_lexer.commitSnapshot;
        END IF;
        RETURN l_matchedToken;
    END;

    ----------------------------------------------------------------------------
    MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
    BEGIN
        raise_application_error(-20000, 'this should be overriden by matcher');
        RETURN NULL;
    END;

END;
/
