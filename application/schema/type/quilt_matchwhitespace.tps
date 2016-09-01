CREATE OR REPLACE Type quilt_matchwhitespace  UNDER quilt_matcher
(

    CONSTRUCTOR FUNCTION quilt_matchwhitespace RETURN SELF AS Result,

    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
;
/
