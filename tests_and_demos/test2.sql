rem Check relations testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on

spool test2.log

declare
 result boolean;
begin
 dbms_output.put_line('�������� ������������� ��������� BT/NT/RT/SYN ��� �������� �����');

 result := ctx_api.phrase_relation_exists('�������');
 if (result) then dbms_output.put_line('��������� ����');
             else dbms_output.put_line('��������� ���');
 end if;
end;
/

spool off

set echo off