-- Logged Web Service Version
rem --------------------------------------------------------------------------
rem -- PROJECT_NAME: CTX_API                                                --
rem -- RELEASE_VERSION: 1.0.0.5                                             --
rem -- RELEASE_STATUS: Release                                              --
rem --                                                                      --
rem -- REQUIRED_ORACLE_VERSION: 10.1.0.x                                    --
rem -- MINIMUM_ORACLE_VERSION: 9.2.0.3                                      --
rem -- MAXIMUM_ORACLE_VERSION: 11.x.x.x                                     --
rem -- PLATFORM_IDENTIFICATION: Generic                                     --
rem --                                                                      --
rem -- IDENTIFICATION: inst_api.sql                                         --
rem -- DESCRIPTION: This script installs CTX API into specified existin     --
rem --              schema. Must be run as SYS user with SYSDBA priv.       --
rem --              This script are interactive. Command-line version is    --
rem --              inst_parser_c.sql                                       --
rem --                                                                      --
rem -- INTERNAL_FILE_VERSION: 0.0.0.3                                       --
rem --                                                                      --
rem -- COPYRIGHT: Yuri Voinov (C) 2004, 2009                                --
rem --                                                                      --
rem -- MODIFICATIONS:                                                       --
rem -- 19.12.2006 -Add Oracle Text installation check.                      --
rem -- 22.10.2006 -Fixed minor bug with GRANT EXECUTE ON ctx_thes package.  --
rem --             Check grant if not already granted added.                --
rem -- 20.08.2006 -Initial code written.                                    --
rem --------------------------------------------------------------------------

-- Grantee schema which will manage statistics
define grantee_usr = 'www_own'
-- Storage for log data
define tbs = 'www_data_jn'
define idx_tbs = 'www_data_jn'

set verify off

whenever sqlerror continue

spool inst_api.log

prompt ============================================
prompt CTX_API installation ...
prompt ============================================
prompt --------------------------------------------

prompt Specify target user schema to install API
prompt and target schema password for clean log job 
prompt
prompt You must specify sys password and ORACLE SID
prompt for database to run this script

prompt --------------------------------------------

accept schema_name char prompt 'Input target user schema:'

accept schema_pwd char prompt 'Input target schema password:' hide

accept ora_sid char prompt 'Input ORACLE SID:'

accept sys_password char prompt 'Input SYS password:' hide

connect sys/&&sys_password@&&ora_sid as sysdba

set serveroutput on

declare
 -- Check Oracle Text installed
 v_ctx varchar2(30);
begin
 select object_name
 into v_ctx
 from all_objects 
 where object_name = 'CTX_THES'
   and object_type = 'PACKAGE';
 dbms_output.put_line('Oracle Text Installed. Check OK.');
exception
 when no_data_found then
  raise_application_error(-20111,'Oracle Text does not installed.');
end;
/

set serveroutput off

declare
 --
 -- Check user and select target schema stuff.
 --
 c_ctx_role constant varchar2(30) := 'ctxapp'; -- CTXAPP role name
 v_user varchar2(30); -- Target user buffer
 v_ddl varchar2(255); -- DDL buffer
 v_priv varchar2(40); -- Priv buffer
begin
 begin
  select username -- Check target user exists
  into v_user
  from all_users
  where username = upper('&&schema_name');
 exception
  when too_many_rows then -- Check most suggest username
   select max(username)
   into v_user
   from all_users
   where username = upper('&&schema_name');
 end;
 --
 -- Make grants
 --
 begin
  -- Verify if grant is not already for target user
  select privilege
  into v_priv
  from all_tab_privs
  where grantee = upper('&&schema_name')
    and privilege = 'EXECUTE' 
    and table_name = 'CTX_THES'
    and grantor = 'CTXSYS';
 exception
  -- If not granted, then do it now
  when no_data_found then
   v_ddl := 'grant execute on ctxsys.ctx_thes to &&schema_name';
   execute immediate(v_ddl);
 end;
 --
 -- Grant CTXAPP role to target user
 v_ddl := 'grant '||c_ctx_role||' to &&schema_name';
 execute immediate(v_ddl);
 -- Grant select on thes view to target user
 v_ddl := 'grant select on ctxsys.ctx_thesauri to &&schema_name';
 execute immediate(v_ddl);
 -- Grant select on phrases view to target user
 v_ddl := 'grant select on ctxsys.ctx_thes_phrases to &&schema_name';
 execute immediate(v_ddl);
 --
 -- Set schema for installation
 --
 v_ddl := 'alter session set current_schema = '||v_user||'';
 execute immediate(v_ddl);
exception
 -- Exceptions handlers
 when no_data_found then raise_application_error(-20110,'Target user specified NOT FOUND!');
 when others then raise_application_error(-20120,'Error ORA'||SQLCODE);
end;
/

-- LOG storage creation
prompt
prompt CTX_API_LOG table and indexes creation...
drop table ctx_api_log
/

create table ctx_api_log
 (serviced    date default sysdate,
  request     varchar2(4000),
  api_funct   varchar2(200),
  api_params  varchar2(200) default null)
tablespace &tbs
/

grant all on ctx_api_log to &grantee_usr
/

create index ctx_api_log_date_idx on ctx_api_log(serviced)
tablespace &idx_tbs pctfree 0
/

create index ctx_api_log_req_idx on ctx_api_log(request)
tablespace &idx_tbs pctfree 0
/

create index ctx_api_funct_idx on ctx_api_log(api_funct)
tablespace &idx_tbs pctfree 0
/

whenever sqlerror exit sql.sqlcode

prompt
prompt CTX WSDL log clean procedure...
create or replace procedure clean_wsdl_log is
begin
 execute immediate 'truncate table ctx_api_log';
end;
/

show errors

-- Will connect as owner to setup job...
conn &&schema_name/&&schema_pwd@&&ora_sid

prompt
prompt WSDL Log Cleanup job install...
@@clean_wsdl_log_job.sql

prompt
prompt CTX_API package specification loading...

@@ctx_api.sql

prompt
prompt CTX_API package body loading...

rem @@prvtctxapi.pls

@@prvtctxapi.plb

prompt ============================================
prompt CTX_API installation done.  
prompt ============================================

spool off

disconnect

exit