CREATE OR REPLACE Type plex_matchword  UNDER plex_matcher
(

    CONSTRUCTOR FUNCTION plex_matchword RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
