CREATE OR REPLACE Type BODY plex_token AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_token(token IN VARCHAR2) RETURN SELF AS Result IS
    BEGIN
        self.token := token;
        self.text  := NULL;
        -- position of token    
        self.sourceIndex     := plex_lexer.getIndex;
        self.sourceLine      := plex_lexer.getLine;
        self.sourceLineIndex := plex_lexer.getLineIndex;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_token
    (
        token IN VARCHAR2,
        Text  IN VARCHAR2
    ) RETURN SELF AS Result IS
    BEGIN
        self.token := token;
        self.text  := Text;
        -- position of token    
        self.sourceIndex     := plex_lexer.getIndex;
        self.sourceLine      := plex_lexer.getLine;
        self.sourceLineIndex := plex_lexer.getLineIndex;
        --
        RETURN;
    END;

END;
/
