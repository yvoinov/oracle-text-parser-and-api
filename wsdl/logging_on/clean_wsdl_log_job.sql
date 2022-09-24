rem Job for clean WSDL log every 30 days
rem Y.Voinov (C) 2007, 2008

declare
 -- Don't forget to add semicolon after PL/SQL calls in 'what'!
 v_job binary_integer;
 v_what varchar2(255);
begin
 -- Check job is exist
 select job, what
 into v_job, v_what
 from user_jobs
 where what like '%clean_wsdl_log%';
 -- Remove job if exist
 dbms_job.remove(v_job);
 commit;
 -- Then create new job
 dbms_job.submit(job=>v_job,
                 what=>'clean_wsdl_log;',
                 next_date=>sysdate+30,
                 interval=>'sysdate+30',
                 no_parse=>false);
 commit;
exception
 when no_data_found then
  -- Create job if it not exist
  dbms_job.submit(job=>v_job,
                  what=>'clean_wsdl_log;',
                  next_date=>sysdate+30,
                  interval=>'sysdate+30',
                  no_parse=>false);
  commit;
 when too_many_rows then
  -- Maintain rare case with much jobs
  raise_application_error(-20100,'Too many jobs exist. Remove all manually.');
end;
/
