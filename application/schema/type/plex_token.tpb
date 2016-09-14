CREATE OR REPLACE Type BODY plex_token AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plex_token(tokenType IN VARCHAR2) RETURN SELF AS Result IS
    BEGIN
        self.tokenType := tokenType;
        self.text      := NULL;
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
        tokenType IN VARCHAR2,
        Text      IN VARCHAR2
    ) RETURN SELF AS Result IS
    BEGIN
        self.tokenType := tokenType;
        self.text      := Text;
        -- position of token    
        self.sourceIndex     := plex_lexer.getIndex;
        self.sourceLine      := plex_lexer.getLine;
        self.sourceLineIndex := plex_lexer.getLineIndex;
        --
        RETURN;
    END;
    
    ----------------------------------------------------------------------------
    MEMBER FUNCTION matchText
    (
        Text       IN VARCHAR,
        ignoreCase BOOLEAN DEFAULT TRUE
    ) RETURN BOOLEAN is
    begin
      if ignoreCase then
        return upper(text) = upper(self.text);
      else 
        return text = self.text;
      end if;
    end;

END;
/
