rem Get homograph's qualifiers testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on
set timing on

spool test5.log

set serveroutput on

declare
 v_hom ctx_api.term_tab;
 i pls_integer;
begin
 ctx_api.get_qualifiers(v_hom,'якорь','default');
 for i in v_hom.first..v_hom.last loop
  dbms_output.put_line(v_hom(i));
 end loop;
end;
/

declare
 v_hom ctx_api.term_tab;
 i pls_integer;
begin
 ctx_api.get_qualifiers(v_hom,'варкалось','default');
 for i in v_hom.first..v_hom.last loop
  dbms_output.put_line(v_hom(i));
 end loop;
end;
/

spool off

set echo off
set timing off