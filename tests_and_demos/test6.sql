rem Get BTs testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

set serveroutput on

col "Категория" format a40

spool test6.log

prompt Использование функции get_bt

select ctx_api.get_bt('кот') as "Категория" from dual;

select ctx_api.get_bt('крыло') as "Категория" from dual;

select ctx_api.get_bt('крыло (авиация)') as "Категория" from dual;

prompt Использование процедуры get_bt

declare
  xtab ctx_api.term_tab;
begin
  -- Термин с гомографами - выводятся оба субдерева BT одно за другим
  ctx_api.get_bt(xtab, 'алмаз', 5, 'default');
  for i in 1..xtab.count loop
   dbms_output.put_line(xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
begin
  -- Термин с гомографами - квалифицированная подветвь одного из поддеревьев
  ctx_api.get_bt(xtab, 'алмаз (геология)', 5, 'default');
  for i in 1..xtab.count loop
   dbms_output.put_line(xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
begin
  -- Термин с гомографами - вторая квалифицированная подветвь
  ctx_api.get_bt(xtab, 'алмаз (металлообработка)', 5, 'default');
  for i in 1..xtab.count loop
   dbms_output.put_line(xtab(i));
  end loop;
end;
/

spool off

set echo off
set timing off