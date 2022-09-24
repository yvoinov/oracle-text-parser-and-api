rem Clean WSDL log job removal script
rem Y.Voinov (C) 2007,2009

declare
 v_job binary_integer;
begin
 select job
 into v_job
 from user_jobs
 where what like '%clean_wsdl_log%';
 dbms_job.remove(v_job);
 commit;
exception
 when no_data_found then null;
end;
/
