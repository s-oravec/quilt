CREATE OR REPLACE Type quilt_matchword  UNDER quilt_matcher
(

    CONSTRUCTOR FUNCTION quilt_matchword RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
