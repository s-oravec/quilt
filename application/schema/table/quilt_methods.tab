CREATE TABLE quilt_methods
  (
    sessionid     NUMBER NOT NULL ,
    sid           NUMBER NOT NULL ,
    object_schema VARCHAR2 (128 BYTE) NOT NULL ,
    object_name   VARCHAR2 (128 BYTE) NOT NULL ,
    object_type   VARCHAR2 (128 BYTE) ,
    insert_dt     DATE ,
    last_dt       DATE
  ) ;
ALTER TABLE quilt_methods ADD CONSTRAINT quilt_methods_sssoo_uk UNIQUE ( sessionid , sid , object_schema , object_name , object_type ) ;
