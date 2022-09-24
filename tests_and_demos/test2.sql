rem Check relations testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on

spool test2.log

declare
 result boolean;
begin
 dbms_output.put_line('Проверка существования отношений BT/NT/RT/SYN для заданной фразы');

 result := ctx_api.phrase_relation_exists('котопес');
 if (result) then dbms_output.put_line('Отношения есть');
             else dbms_output.put_line('Отношений НЕТ');
 end if;
end;
/

spool off

set echo off