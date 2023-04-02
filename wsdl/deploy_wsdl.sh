#!/bin/sh

#
# CTX_API WSDL Version 1.0.0.5
# Automated deployments for OC4J 10.1.3.2.0
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
CNTXT="wsdl"
export CNTXT
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

echo "-----------------------------------------------------------------"
echo "This script for deployment CTX_API WSDL in Unix shell environment"
echo ""
echo "Steps for deployment:"
echo ""
echo "(1) Install CTX_API in appropriate scheme in target database"
echo "(2) Update config.xml with the correct database connection"
echo "(3) Add OracleDS entry in j2ee/home/config/data-sources.xml" 
echo "(4) Run this script "
echo "-----------------------------------------------------------------"
echo "Note: First need to install Oracle OC4J standalone!"

echo "OC4J Initialization..."
DIR=`pwd`; cd ${ORACLE_HOME}/bin
echo "------------------------------------------------------"
oc4j -start &
cd ${DIR}
$SLEEP $SLEEP_TIME

CLASSPATH=".:${HOME}:${ORACLE_HOME}/webservices/lib/wsdl.jar:${ORACLE_HOME}/lib/xmlparserv2.jar:${ORACLE_HOME}/:${ORACLE_HOME}/soap/lib/soap.jar:${CLASSPATH}"
export CLASSPATH
echo "CLASSPATH: "${CLASSPATH}

echo "Generate the server code..."
java -jar ${ORACLE_HOME}/webservices/lib/WebServicesAssembler.jar -config config.xml

echo "Re-start OC4J ... You may need to adjust the sleeping time if the server does not go up soon enought for the client to call."
$PS -ef | $GREP oc4j | $AWK -e '{print $2}' |$XARGS $KILL -9
$SLEEP 10 
DIR=`pwd`; cd ${ORACLE_HOME}/bin; 
oc4j -start &  
cd ${DIR}
$SLEEP $SLEEP_TIME

echo "Deploy... http://${HOSTNAME}:${PORT}/${CNTXT}/${DEPLOYMENT_NAME}..."
java -jar ${ORACLE_HOME}/j2ee/home/admin.jar ormi://${HOSTNAME}:${PORT} ${ADMIN} ${ADMIN_PWD} -deploy -file ./$DEPLOYMENT_NAME.ear -deploymentName ${DEPLOYMENT_NAME}

java -jar ${ORACLE_HOME}/j2ee/home/admin.jar ormi://${HOSTNAME}:${PORT} ${ADMIN} $PADMIN_PWD} -bindWebApp ${APP_NAME} ${APP_NAME}_web default-web-site /${CNTXT}

echo "--------------------------------------------------------------------"
echo "Finished."
echo "--------------------------------------------------------------------"
echo "Endpoint URL: http://${HOSTNAME}:${PORT}/${CNTXT}/${DEPLOYMENT_NAME}"

# Restore ORACLE_HOME if it was defined
if [ ! -z "$ORACLE_HOME_OLD" ]; then
 ORACLE_HOME=$ORACLE_HOME_OLD
 export ORACLE_HOME
fi

# Clean up
unset ADMIN ADMIN_PWD HOSTNAME PORT DEPLOYMENT_NAME APP_NAME CNTXT SLEEP_TIME
