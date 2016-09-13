CREATE OR REPLACE Type plex_matchtextliteral  UNDER plex_matcher
(

    CONSTRUCTOR FUNCTION plex_matchtextliteral RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN plex_token

)
;
/
