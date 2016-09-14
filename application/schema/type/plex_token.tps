CREATE OR REPLACE Type plex_token AS OBJECT
(
    tokenType       VARCHAR2(30), -- see plex_lexer.TokenType
    Text            VARCHAR2(4000),
    sourceIndex     INTEGER, -- position in source composed as concatenation of lines, separated by chr(10)
    sourceLine      INTEGER, -- source line - all_source.line
    sourceLineIndex INTEGER, -- position within source line - all_source.lines

    CONSTRUCTOR FUNCTION plex_token(tokenType IN VARCHAR2) RETURN SELF AS Result,

    CONSTRUCTOR FUNCTION plex_token
    (
        tokenType IN VARCHAR2,
        Text      IN VARCHAR2
    ) RETURN SELF AS Result,

    MEMBER FUNCTION matchText
    (
        Text       IN VARCHAR,
        ignoreCase BOOLEAN DEFAULT TRUE
    ) RETURN BOOLEAN
)
/
