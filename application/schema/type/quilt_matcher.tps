CREATE OR REPLACE Type quilt_matcher  AS OBJECT
(

    dummy INTEGER,

    MEMBER FUNCTION isMatch RETURN quilt_token,

    MEMBER FUNCTION isMatchImpl RETURN quilt_token

)
NOT FINAL;
/
