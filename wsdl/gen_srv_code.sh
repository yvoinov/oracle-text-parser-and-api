#!/bin/sh

#
# CTX_API WSDL Version 1.0.0.5
# Generate srv code for manual deployments
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
echo "This script for generation CTX_API WSDL app in Unix environment"
echo ""
echo "Steps for generation:"
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

echo "--------------------------------------------------------------------"
echo "Finished."
echo "--------------------------------------------------------------------"

# Restore ORACLE_HOME if it was defined
if [ ! -z "$ORACLE_HOME_OLD" ]; then
 ORACLE_HOME=$ORACLE_HOME_OLD
 export ORACLE_HOME
fi

# Clean up
unset SLEEP_TIME
