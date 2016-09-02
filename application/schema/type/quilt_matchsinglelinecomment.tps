CREATE OR REPLACE Type quilt_matchsinglelinecomment UNDER quilt_matcher
(

    CONSTRUCTOR FUNCTION quilt_matchsinglelinecomment RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
