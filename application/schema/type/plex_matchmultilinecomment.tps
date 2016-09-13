CREATE OR REPLACE Type plex_matchmultilinecomment UNDER plex_matcher
(

    CONSTRUCTOR FUNCTION plex_matchmultilinecomment RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
