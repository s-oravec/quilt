CREATE OR REPLACE Type plex_matcher  AS OBJECT
(

    dummy INTEGER,

    MEMBER FUNCTION isMatch RETURN plex_token,

    MEMBER FUNCTION isMatchImpl RETURN plex_token

)
NOT FINAL;
/
