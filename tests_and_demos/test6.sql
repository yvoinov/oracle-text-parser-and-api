rem Get BTs testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

set serveroutput on

col "���������" format a40

spool test6.log

prompt ������������� ������� get_bt

select ctx_api.get_bt('���') as "���������" from dual;

select ctx_api.get_bt('�����') as "���������" from dual;

select ctx_api.get_bt('����� (�������)') as "���������" from dual;

prompt ������������� ��������� get_bt

declare
  xtab ctx_api.term_tab;
begin
  -- ������ � ����������� - ��������� ��� ��������� BT ���� �� ������
  ctx_api.get_bt(xtab, '�����', 5, 'default');
  for i in 1..xtab.count loop
   dbms_output.put_line(xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
begin
  -- ������ � ����������� - ����������������� �������� ������ �� �����������
  ctx_api.get_bt(xtab, '����� (��������)', 5, 'default');
  for i in 1..xtab.count loop
   dbms_output.put_line(xtab(i));
  end loop;
end;
/

declare
  xtab ctx_api.term_tab;
begin
  -- ������ � ����������� - ������ ����������������� ��������
  ctx_api.get_bt(xtab, '����� (����������������)', 5, 'default');
  for i in 1..xtab.count loop
   dbms_output.put_line(xtab(i));
  end loop;
end;
/

spool off

set echo off
set timing off