CREATE OR REPLACE Type BODY quilt_token AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_token(token IN VARCHAR2) RETURN SELF AS Result IS
    BEGIN
        self.token := token;
        self.text  := NULL;
        -- position of token    
        self.sourceIndex     := quilt_lexer.getIndex;
        self.sourceLine      := quilt_lexer.getLine;
        self.sourceLineIndex := quilt_lexer.getLineIndex;
        --
        RETURN;
    END;

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION quilt_token
    (
        token IN VARCHAR2,
        Text  IN VARCHAR2
    ) RETURN SELF AS Result IS
    BEGIN
        self.token := token;
        self.text  := Text;
        -- position of token    
        self.sourceIndex     := quilt_lexer.getIndex;
        self.sourceLine      := quilt_lexer.getLine;
        self.sourceLineIndex := quilt_lexer.getLineIndex;
        --
        RETURN;
    END;

END;
/
