CREATE OR REPLACE Type plex_matchsinglelinecomment UNDER plex_matcher
(

    CONSTRUCTOR FUNCTION plex_matchsinglelinecomment RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
