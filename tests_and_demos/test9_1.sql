rem Get NTPs testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test9_1.log

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_ntp(xtab,'вексель',1,'default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NTP''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NTP('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_ntp(xtab,'общая физика',1,'default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NTP''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NTP('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_ntp(xtab,'химия',1,'default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NTP''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NTP('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_ntp(xtab,'ценные бумаги',1,'default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NTP''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NTP('||i||')='||xtab(i));
  end loop;
end;
/

spool off

set echo off
set timing off