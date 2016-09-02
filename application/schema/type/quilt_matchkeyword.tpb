CREATE OR REPLACE Type BODY quilt_matchkeyword AS

    ----------------------------------------------------------------------------  
    CONSTRUCTOR FUNCTION quilt_matchkeyword
    (
        token            IN VARCHAR2,
        stringToMatch    IN VARCHAR2,
        allowAsSubstring IN VARCHAR2 DEFAULT 'Y'
    ) RETURN SELF AS Result IS
    BEGIN
        --
        self.token            := token;
        self.stringToMatch    := stringToMatch;
        self.allowAsSubstring := allowAsSubstring;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------  
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text  VARCHAR2(255);
        l_found BOOLEAN;
        l_next  VARCHAR2(1);
    BEGIN
        FOR charIdx IN 1 .. length(self.stringToMatch) LOOP
            IF upper(quilt_lexer.currentItem) = upper(substr(self.stringToMatch, charIdx, 1)) THEN
                l_Text := l_Text || quilt_lexer.currentItem;
                quilt_lexer.consume;
            ELSE
                RETURN NULL;
            END IF;
        END LOOP;
        IF self.allowAsSubstring = 'N' THEN
            l_next  := quilt_lexer.currentItem;
            l_found := regexp_like(l_next, '\s') OR quilt_lexer.isSpecialCharacter(l_next) OR quilt_lexer.eof;
        ELSE
            l_found := TRUE;
        END IF;
        IF l_found THEN
            RETURN NEW quilt_token(self.token, l_Text);
        END IF;
        RETURN NULL;
    END;

END;
/
