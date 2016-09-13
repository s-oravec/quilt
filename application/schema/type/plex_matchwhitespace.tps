CREATE OR REPLACE Type plex_matchwhitespace  UNDER plex_matcher
(

    CONSTRUCTOR FUNCTION plex_matchwhitespace RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
