CREATE OR REPLACE Type quilt_matchkeyword UNDER quilt_matcher
(
    token            VARCHAR2(30), -- quilt_lexer.tokenType
    stringToMatch    VARCHAR2(255), -- longest supported token
    allowAsSubstring VARCHAR2(1), -- Y/N

    CONSTRUCTOR FUNCTION quilt_matchkeyword
    (
        token            IN VARCHAR2,
        stringToMatch    IN VARCHAR2,
        allowAsSubstring IN VARCHAR2 DEFAULT 'Y'
    ) RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
