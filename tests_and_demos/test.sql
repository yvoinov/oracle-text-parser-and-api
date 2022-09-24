rem Parser testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test.log

col Parsed format a80
rem 
rem Default mode call
rem For all parameters see documentation or package spec
rem 
rem Тест 1. Вызов парсера по умолчанию, режим KEYWORD
select ctx_api.search_string_parser('сунны алмаз молитва животные бог пассатижи','keyword') as "Parsed" 
from dual;

rem Тест 2. Вызов парсера по умолчанию, режим CONCEPT
select ctx_api.search_string_parser ('сунны алмаз молитва животные бог пассатижи','concept') as "Parsed" 
from dual;

rem Тест 3. Тест уточнения тематики - вызов из SQL
select ctx_api.search_string_parser ('сунны алмаз молитва животные бог пассатижи','concept','and','nt',1,'default',1) as "Parsed" 
from dual;

rem Тест 4. Тест уточнения тематики - вызов из PL/SQL
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('сунны алмаз молитва животные бог пассатижи','concept', p_refine_on=>ctx_api.c_refine_on);
 dbms_output.put_line(v_out);
end;
/

rem Тест 5. Вызов парсера по умолчанию, PL/SQL, режим CONCEPT, уточнение включено
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('сунны пассатижи пила пинцет тиски','concept', p_refine_on=>ctx_api.c_refine_on);
 dbms_output.put_line(v_out);
end;
/

rem Тест 6. Проверка корректности действия уточнения тематики - все слова из одной категории.
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('сунны молитва бог','concept', p_refine_on=>ctx_api.c_refine_on);
 dbms_output.put_line(v_out);
end;
/

rem Тест 7. Проверка корректности действия уточнения категории слова в иерархическом расширительном запросе
rem         NT/BT. При включении уточнения категории (p_exp_detail_on) значение параметра p_expansion_level
rem         ИГНОРИРУЕТСЯ!
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('сунны молитва бог динозавр','concept',
                                         p_query_opt=>ctx_api.c_query_op_nt,
                                         p_refine_on=>ctx_api.c_refine_off,
                                         p_exp_detail_on=>ctx_api.c_exp_detail_on);
 dbms_output.put_line(v_out);
end;
/

col Parsed format a80
spool off

set echo off
set timing off
