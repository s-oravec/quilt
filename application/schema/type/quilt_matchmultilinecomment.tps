CREATE OR REPLACE Type quilt_matchmultilinecomment UNDER quilt_matcher
(

    CONSTRUCTOR FUNCTION quilt_matchmultilinecomment RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
