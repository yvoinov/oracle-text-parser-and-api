#!/bin/sh

#
# CTX_API WSDL Version 1.0.0.5
# Pre-Deployment script
#
# Copyright (C) 2007,2009 Yuri Voinov
#

# Store old ORACLE_HOME value if defined...
if [ ! -z "$ORACLE_HOME" ]; then
 ORACLE_HOME_OLD=$ORACLE_HOME
fi

# Default variables
ORACLE_HOME="/export/home/OraHome4"
export ORACLE_HOME
JAVA_HOME="/usr"
export JAVA_HOME
DISPLAY="`hostname`:0.0"
export DISPLAY

echo "OC4J Installation..."
DIR=`pwd`; cd ${ORACLE_HOME}/bin
oc4j -start
cd ${DIR}

# Restore ORACLE_HOME if it was defined
if [ ! -z "$ORACLE_HOME_OLD" ]; then
 ORACLE_HOME=$ORACLE_HOME_OLD
 export ORACLE_HOME
fi
