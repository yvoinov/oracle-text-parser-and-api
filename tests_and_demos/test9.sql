rem Get SYNs testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test9.log

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'джиринг');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'вексель','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'приземление (ракетная техника)','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'старт (ракетная техника)','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'старт','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'зенитная ракета','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_syn(xtab,'курение','default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' SYN''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('SYN('||i||')='||xtab(i));
  end loop;
end;
/

spool off

set echo off
set timing off