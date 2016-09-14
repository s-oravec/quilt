CREATE OR REPLACE Type plex_matchkeyword UNDER plex_matcher
(
    tokenType        VARCHAR2(30), -- plex_lexer.tokenType
    stringToMatch    VARCHAR2(255), -- longest supported token
    allowAsSubstring VARCHAR2(1), -- Y/N

    CONSTRUCTOR FUNCTION plex_matchkeyword
    (
        tokenType        IN VARCHAR2,
        stringToMatch    IN VARCHAR2,
        allowAsSubstring IN VARCHAR2 DEFAULT 'Y'
    ) RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
