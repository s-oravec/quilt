CREATE OR REPLACE Type BODY quilt_matchkeyword AS

    ----------------------------------------------------------------------------  
    CONSTRUCTOR FUNCTION quilt_matchkeyword
    (
        tokenType     IN VARCHAR2, -- quilt_lexer 
        stringToMatch IN VARCHAR2
    ) RETURN SELF AS Result IS
    BEGIN
        --
        self.tokenType     := tokenType;
        self.stringToMatch := stringToMatch;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------  
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        l_Text VARCHAR2(255);
    BEGIN
        FOR charIdx IN 1 .. length(self.stringToMatch) LOOP
            IF upper(quilt_lexer.currentItem) = upper(substr(self.stringToMatch, charIdx, 1)) THEN
                l_Text := l_Text || quilt_lexer.currentItem;
                quilt_lexer.consume;
            ELSE
                RETURN NULL;
            END IF;
        END LOOP;
        RETURN NEW quilt_token(self.tokenType, l_Text);
    END;

END;
/
