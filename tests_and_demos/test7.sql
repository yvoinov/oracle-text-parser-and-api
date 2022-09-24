rem Get NTs testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test7.log

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_nt(xtab,'мифология',1,'default');
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NT('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  -- Если термин является нижним уровнем, значение p_level игнорируется
  ctx_api.get_nt(xtab,'сунны',1,'default');  -- Нет NT, нижний уровень
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NT('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_nt(xtab,'планер',1,'default');  -- Нет NT, нижний уровень
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NT('||i||')='||xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
  i number;
begin
  ctx_api.get_nt(xtab,'планер (части летательных аппаратов)',1,'default');  -- Нет NT, нижний уровень
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' NT''s'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('NT('||i||')='||xtab(i));
  end loop;
end;
/

spool off

set echo off
set timing off