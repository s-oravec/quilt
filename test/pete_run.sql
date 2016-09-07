disconnect
connect QUILT_000100_DEV/QUILT_000100_DEV@local
set serveroutput on size unlimited format wrap
set trimspool on

truncate table quilt_log;

begin
  pete.run(user);
end;
/

select * from quilt_log order by 1;
