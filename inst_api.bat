@Echo off
cls
rem --------------------------------------------------------------------------
rem -- PROJECT_NAME: CTX_API                                                --
rem -- RELEASE_VERSION: 1.0.0.5                                             --
rem -- RELEASE_STATUS: Release                                              --
rem --                                                                      --
rem -- PLATFORM_IDENTIFICATION: Windows (x86)                               --
rem --                                                                      --
rem -- IDENTIFICATION: inst_api.bat                                         --
rem -- DESCRIPTION: CTX API installation script.                            --
rem --                                                                      --
rem --                                                                      --
rem -- INTERNAL_FILE_VERSION: 0.0.0.1                                       --
rem --                                                                      --
rem -- COPYRIGHT: Yuri Voinov (C) 2004, 2009                                --
rem --                                                                      --
rem -- MODIFICATIONS:                                                       --
rem -- 20.06.2006 -Initial code written.                                    --
rem --------------------------------------------------------------------------

set INSTFILE=inst_api.sql

if exist %INSTFILE% goto go
echo ERROR: %INSTFILE not found. Exiting...
goto fin

:go
sqlplus /nolog @inst_api.sql

:fin