CREATE OR REPLACE Type plex_matchnumberliteral  UNDER plex_matcher
(

    CONSTRUCTOR FUNCTION plex_matchnumberliteral RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
