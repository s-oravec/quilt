CREATE TABLE quilt_log
  (
    sessionid NUMBER ,
    sid       NUMBER ,
    runid     NUMBER ,
    msg       VARCHAR2 (4000) ,
    insert_ts TIMESTAMP
  ) ;
CREATE INDEX quilt_log_IDX1 ON quilt_log
  ( insert_ts ASC
  ) ;
CREATE INDEX quilt_log_IDX2 ON quilt_log
  ( sessionid, sid, runid
  ) ;