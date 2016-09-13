CREATE OR REPLACE Type BODY plex_matcher AS

    ----------------------------------------------------------------------------  
    MEMBER FUNCTION isMatch RETURN plex_token IS
        l_matchedToken plex_token;
    BEGIN
        IF plex_lexer.eof THEN
            RETURN new plex_token(plex_lexer.tk_EOF);
        END IF;
        plex_lexer.takeSnapshot;
        l_matchedToken := isMatchImpl();
        IF l_matchedToken IS NULL THEN
            plex_lexer.rollbackSnapshot;
        ELSE
            plex_lexer.commitSnapshot;
        END IF;
        RETURN l_matchedToken;
    END;

    ----------------------------------------------------------------------------
    MEMBER FUNCTION isMatchImpl RETURN plex_token IS
    BEGIN
        raise_application_error(-20000, 'this should be overriden by matcher');
        RETURN NULL;
    END;

END;
/
