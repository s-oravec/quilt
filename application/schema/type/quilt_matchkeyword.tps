CREATE OR REPLACE Type quilt_matchkeyword  UNDER quilt_matcher
(

    tokenType        VARCHAR2(30), -- quilt_lexer.tokenType
    stringToMatch    VARCHAR2(255), -- longest supported token

    CONSTRUCTOR FUNCTION quilt_matchkeyword
    (
        tokenType     IN VARCHAR2,
        stringToMatch IN VARCHAR2
    ) RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
