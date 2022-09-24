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
rem ���� 1. ����� ������� �� ���������, ����� KEYWORD
select ctx_api.search_string_parser('����� ����� ������� �������� ��� ���������','keyword') as "Parsed" 
from dual;

rem ���� 2. ����� ������� �� ���������, ����� CONCEPT
select ctx_api.search_string_parser ('����� ����� ������� �������� ��� ���������','concept') as "Parsed" 
from dual;

rem ���� 3. ���� ��������� �������� - ����� �� SQL
select ctx_api.search_string_parser ('����� ����� ������� �������� ��� ���������','concept','and','nt',1,'default',1) as "Parsed" 
from dual;

rem ���� 4. ���� ��������� �������� - ����� �� PL/SQL
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('����� ����� ������� �������� ��� ���������','concept', p_refine_on=>ctx_api.c_refine_on);
 dbms_output.put_line(v_out);
end;
/

rem ���� 5. ����� ������� �� ���������, PL/SQL, ����� CONCEPT, ��������� ��������
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('����� ��������� ���� ������ �����','concept', p_refine_on=>ctx_api.c_refine_on);
 dbms_output.put_line(v_out);
end;
/

rem ���� 6. �������� ������������ �������� ��������� �������� - ��� ����� �� ����� ���������.
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('����� ������� ���','concept', p_refine_on=>ctx_api.c_refine_on);
 dbms_output.put_line(v_out);
end;
/

rem ���� 7. �������� ������������ �������� ��������� ��������� ����� � ������������� �������������� �������
rem         NT/BT. ��� ��������� ��������� ��������� (p_exp_detail_on) �������� ��������� p_expansion_level
rem         ������������!
declare
  v_out varchar2(32767);
begin
 v_out := ctx_api.search_string_parser('����� ������� ��� ��������','concept',
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
