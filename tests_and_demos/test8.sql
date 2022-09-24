rem Get RTs testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test8.log

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_rt(xtab,'мифология');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' RT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('RT('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_rt(xtab,'вексель','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' RT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('RT('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_rt(xtab,'планер','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' RT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('RT('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_rt(xtab,'планер (части летательных аппаратов)','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' RT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('RT('||i||')='||xtab(i));
  end loop;
end;
/

spool off

set echo off
set timing off
