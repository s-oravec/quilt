disconnect
connect QUILT_000100_DEV/QUILT_000100_DEV@local
set serveroutput on size unlimited format wrap
set trimspool on

begin
  pete.run(user);
end;
/
