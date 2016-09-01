CREATE OR REPLACE Type quilt_matchtextliteral  UNDER quilt_matcher
(

    CONSTRUCTOR FUNCTION quilt_matchtextliteral RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
