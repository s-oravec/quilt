CREATE OR REPLACE TYPE quilt_object_type  AS OBJECT
(
    owner       VARCHAR2(128),
    object_name VARCHAR2(128),
    object_type VARCHAR2(25)
)
/
