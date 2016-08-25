CREATE TABLE quilt_run
  (
    sessionid NUMBER NOT NULL ,
    sid       NUMBER NOT NULL ,
    runid     NUMBER NOT NULL ,
    start_ts  TIMESTAMP ,
    stop_ts   TIMESTAMP ,
    test_name VARCHAR2 (255)
  ) ;
ALTER TABLE quilt_run ADD CONSTRAINT quilt_run_pk PRIMARY KEY ( sessionid, sid, runid ) ;