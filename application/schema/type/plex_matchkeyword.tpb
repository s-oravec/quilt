CREATE OR REPLACE Type BODY plex_matchkeyword AS

    ----------------------------------------------------------------------------  
    CONSTRUCTOR FUNCTION plex_matchkeyword
    (
        tokenType        IN VARCHAR2,
        stringToMatch    IN VARCHAR2,
        allowAsSubstring IN VARCHAR2 DEFAULT 'Y'
    ) RETURN SELF AS Result IS
    BEGIN
        --
        self.tokenType        := tokenType;
        self.stringToMatch    := stringToMatch;
        self.allowAsSubstring := allowAsSubstring;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------  
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token IS
        l_Text  VARCHAR2(255);
        l_found BOOLEAN;
        l_next  VARCHAR2(1);
    BEGIN
        FOR charIdx IN 1 .. length(self.stringToMatch) LOOP
            IF upper(plex_lexer.currentItem) = upper(substr(self.stringToMatch, charIdx, 1)) THEN
                l_Text := l_Text || plex_lexer.currentItem;
                plex_lexer.consume;
            ELSE
                RETURN NULL;
            END IF;
        END LOOP;
        IF self.allowAsSubstring = 'N' THEN
            l_next  := plex_lexer.currentItem;
            l_found := regexp_like(l_next, '\s') OR plex_lexer.isSpecialCharacter(l_next) OR plex_lexer.eof;
        ELSE
            l_found := TRUE;
        END IF;
        IF l_found THEN
            RETURN NEW plex_token(self.tokenType, l_Text);
        END IF;
        RETURN NULL;
    END;

END;
/
