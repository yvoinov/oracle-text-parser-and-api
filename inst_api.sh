#!/bin/sh

# --------------------------------------------------------------------------
# -- PROJECT_NAME: CTX_API                                                --
# -- RELEASE_VERSION: 1.0.0.5                                             --
# -- RELEASE_STATUS: Release                                              --
# --                                                                      --
# -- PLATFORM_IDENTIFICATION: UNIX                                        --
# -- OS SHELL: Bourne                                                     --
# --                                                                      --
# -- IDENTIFICATION: inst_api.sh                                          --
# -- DESCRIPTION: CTX API installation script.                            --
# --                                                                      --
# --                                                                      --
# -- INTERNAL_FILE_VERSION: 0.0.0.1                                       --
# --                                                                      --
# -- COPYRIGHT: Yuri Voinov (C) 2004, 2009                                --
# --                                                                      --
# -- MODIFICATIONS:                                                       --
# -- 20.06.2006 -Initial code written.                                    --
# --------------------------------------------------------------------------

INSTFILE="inst_api.sql"

# Check $ORACLE_HOME environment variable
if [ -z "$ORACLE_HOME" ]; then
 echo "ERROR: ORACLE_HOME environment variable not set!"
 echo "Exiting ..."
 exit 1
fi

if [ -f "$INSTFILE" ]; then
 sqlplus /nolog @"$INSTFILE"
else
 echo "ERROR: $INSTFILE file not found"
 echo "Exiting..."
 exit 1
fi