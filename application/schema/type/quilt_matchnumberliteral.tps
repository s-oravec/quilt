CREATE OR REPLACE Type quilt_matchnumberliteral  UNDER quilt_matcher
(

    CONSTRUCTOR FUNCTION quilt_matchnumberliteral RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
