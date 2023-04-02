#!/bin/sh

#
# CTX_API WSDL Version 1.0.0.5
# Undeployment script
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

# OC4J deployment defaults
ADMIN="oc4jadmin"
export ADMIN
ADMIN_PWD="cefixmoc123"
export ADMIN_PWD
HOSTNAME=`hostname`
export HOSTNAME
PORT="8888"
export PORT
DEPLOYMENT_NAME="ctxapi"
export DEPLOYMENT_NAME
APP_NAME="ctx_api"
export APP_NAME
# Sleep time for starting OC4J instance
SLEEP_TIME="60"
export SLEEP_TIME

# System utilities
AWK=`which awk`
GREP=`which grep`
KILL=`which kill`
PS=`which ps`
SLEEP=`which sleep`
XARGS=`which xargs`

echo "OC4J Initialization..."
DIR=`pwd`; cd ${ORACLE_HOME}/bin
echo "------------------------------------------------------"
oc4j -start &
cd ${DIR}
$SLEEP $SLEEP_TIME

CLASSPATH=".:${HOME}:${ORACLE_HOME}/webservices/lib/wsdl.jar:${ORACLE_HOME}/lib/xmlparserv2.jar:${ORACLE_HOME}/:${ORACLE_HOME}/soap/lib/soap.jar:${CLASSPATH}"
export CLASSPATH
echo "CLASSPATH: "${CLASSPATH}

echo "Undeploy previously installed webservice..."
java -jar ${ORACLE_HOME}/j2ee/home/admin.jar ormi://${HOSTNAME}:${PORT} ${ADMIN} ${ADMIN_PWD} -undeploy ${APP_NAME}

# Restore ORACLE_HOME if it was defined
if [ ! -z "$ORACLE_HOME_OLD" ]; then
 ORACLE_HOME=$ORACLE_HOME_OLD
 export ORACLE_HOME
fi

# Clean up
unset ADMIN ADMIN_PWD HOSTNAME PORT DEPLOYMENT_NAME APP_NAME SLEEP_TIME
