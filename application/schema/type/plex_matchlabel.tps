CREATE OR REPLACE Type plex_matchLabel UNDER plex_matcher
(
    CONSTRUCTOR FUNCTION plex_matchLabel RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
