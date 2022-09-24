#!/bin/sh

# Check $ORACLE_HOME environment variable
if [ -z "$ORACLE_HOME" ]; then
 echo "ORACLE_HOME environment variable not set!"
 echo "Exiting ..."
 exit 1
fi

sqlplus /nolog @all_tests.sql