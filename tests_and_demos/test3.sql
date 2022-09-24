rem Check expansions testing and demonstration script
rem Copyright (C) 2005,2009 Y.Voinov

set echo on
set serveroutput on

spool test3.log

set serveroutput on

declare
 result number;
begin
 result := ctx_api.search_expansion_level('динозавр');
 dbms_output.put_line(result);
end;
/

declare
 result varchar2(255);
begin
 result := ctx_api.search_expansion_term('динозавр');
 dbms_output.put_line(result);
end;
/

spool off

set echo off
