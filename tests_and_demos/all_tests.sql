conn scott/tiger@sun10

rem Check CTX API version
rem Logging result separately
col "CTX API Version" format a20
spool ctx_api_ver.log
select ctx_api.version as "CTX API Version" from dual;
spool off

@@test.sql
@@test2.sql
@@test3.sql
@@test4.sql
@@test5.sql
@@test6.sql
@@test7.sql
@@test8.sql
@@test9.sql

disconnect

exit
