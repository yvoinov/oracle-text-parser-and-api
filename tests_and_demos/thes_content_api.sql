
set serveroutput on

spool thes_content_api.log

select ctx_api.term_counter('default') from dual;

select ctx_api.term_counter('english') from dual;

declare
  xtab ctx_api.thes_tab;
  i number;
begin
  ctx_api.thes_loaded(xtab);
  if xtab.count > 0 then dbms_output.put_line('Has '||xtab.count||' thesauri'); end if;
  for i in 1..xtab.last loop
    dbms_output.put_line('Thes '||i||': '||xtab(i));
  end loop;
end;
/

spool off