CREATE OR REPLACE Type quilt_token AS OBJECT
(
    token           VARCHAR2(30), -- see quilt_lexer.TokenType
    Text            VARCHAR2(4000),
    sourceIndex     INTEGER, -- position in source composed as concatenation of lines, separated by chr(10)
    sourceLine      INTEGER, -- source line - all_source.line
    sourceLineIndex INTEGER, -- position within source line - all_source.lines

    CONSTRUCTOR FUNCTION quilt_token(token IN VARCHAR2) RETURN SELF AS Result,

    CONSTRUCTOR FUNCTION quilt_token
    (
        token IN VARCHAR2,
        Text  IN VARCHAR2
    ) RETURN SELF AS Result
)
/
