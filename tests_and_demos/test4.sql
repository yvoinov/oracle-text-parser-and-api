rem Check homographs detection and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test4.log

set serveroutput on

declare
 v_hom boolean;
begin
 v_hom := ctx_api.has_homographs('�����');
 if v_hom then dbms_output.put_line('��������� ����');
          else dbms_output.put_line('���������� ���');
 end if;
end;
/

declare
 v_hom boolean;
begin
 v_hom := ctx_api.has_homographs('����� (����)');
 if v_hom then dbms_output.put_line('��������� ����');
          else dbms_output.put_line('���������� ���');
 end if;
end;
/

declare
 v_hom boolean;
begin
 v_hom := ctx_api.has_homographs('����');
 if v_hom then dbms_output.put_line('��������� ����');
          else dbms_output.put_line('���������� ���');
 end if;
end;
/

spool off

set echo off
set timing off