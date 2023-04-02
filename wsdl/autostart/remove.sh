#!/bin/sh

# Oracle services autostart remove for Solaris 8,9,10,>10, Linux
# Yuri Voinov (C) 2006, 2009
#
# ident "@(#)remove.sh    1.7    07/02/17 YV"
#

#############
# Variables #
#############

SERVICE_NAME="oc4j"
export SERVICE_NAME
SCRIPT_NAME="init.$SERVICE_NAME"
export SCRIPT_NAME
BOOT_DIR="/etc/init.d"
export BOOT_DIR
SMF_DIR="/var/svc/manifest/application/oracle"
export SMF_DIR
SVC_MTD="/lib/svc/method"
export SVC_MTD

#
# OS Commands location variables
#
CUT=`which cut`
ID=`which id`
RM=`which rm`
UNAME=`which uname`
UNLINK=`which unlink`

OS_VER=`$UNAME -r|$CUT -f1 -d" "`
export OS_VER
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
export OS_NAME
OS_FULL=`$UNAME -sr`
export OS_FULL

# Check supported Linux
supported_linux ()
{
 # Supported Linux: RHEL3, RHEL4, SuSE, Fedora, Oracle Enterprose Linux
 if [ -f /etc/redhat-release -o -f /etc/SuSE-release -o -f /etc/fedora-release -o -f /etc/enterprise-release ]; then
  echo "1"
 else
  echo "0"
 fi
}

##############
# Main block #
##############

echo "#####################################################"
echo "#      Oracle OC4J autostart remove script          #"
echo "#                                                   #"
echo "# Make sure that services is stopped and disabled ! #"
echo "# Press <Enter> to continue, <Ctrl+C> to cancel ... #"
echo "#####################################################"
read p

if [ "$OS_FULL" = "SunOS 5.9" -o "$OS_FULL" = "SunOS 5.8" ]; then
 WHO=`$ID | $CUT -f1 -d" "`
 if [ ! "$WHO" = "uid=0(root)" ]; then
   echo "ERROR: you must be super-user to run this script."
   exit 1
  else
   # Uninstall for OS 8,9
   echo "OS: $OS_FULL"
   $RM $BOOT_DIR/$SCRIPT_NAME>/dev/null 2>&1
   $UNLINK /etc/rc3.d/K01$SERVICE_NAME>/dev/null 2>&1
   $UNLINK /etc/rc3.d/S99$SERVICE_NAME>/dev/null 2>&1
   retcode=`echo $?`
   case "$retcode" in
    0) echo "*** Service deleted successfuly";;
    *) echo "*** Service delete operation has errors";;
   esac
   echo "-------------------- Done. ------------------------"
   echo "Complete. Restart host."
 fi
elif [ "$OS_NAME" = "SunOS" -a "$OS_VER" -ge "5.10" ]; then
 WHO=`/usr/xpg4/bin/id -n -u`
 if [ ! "$WHO" = "root" ]; then
  echo "ERROR: you are not authorized to run this script."
  exit 1
 else
  # Uninstall for SunOS>=10
  echo "OS: $OS_FULL"
  SVCCFG=`which svccfg`
  $SVCCFG delete -f /application/$SERVICE_NAME:default>/dev/null 2>&1
  retcode=`echo $?`
  case "$retcode" in
   0) echo "*** Service deleted successfuly";;
   *) echo "*** Service delete operation has errors";;
  esac
  $RM $SVC_MTD/$SCRIPT_NAME>/dev/null 2>&1
  $RM -R $SMF_DIR>/dev/null 2>&1
  echo "-------------------- Done. ------------------------"
  echo "Complete."
 fi
else
 if [ "$OS_NAME" = "Linux" -a "`supported_linux`" = "1" ]; then
  WHO=`$ID | $CUT -f1 -d" "`
  if [ ! "$WHO" = "uid=0(root)" ]; then
   echo "ERROR: you must be super-user to run this script."
   exit 1
  else
   # Uninstall for OS Linux
   echo "OS: $OS_FULL"
   # Service unregistering and remove links
   CHKCONFIG=`which chkconfig`
   $CHKCONFIG --del $SCRIPT_NAME>/dev/null 2>&1
   $CHKCONFIG --level 345 $SCRIPT_NAME off>/dev/null 2>&1
   $RM $BOOT_DIR/$SCRIPT_NAME>/dev/null 2>&1
   retcode=`echo $?`
   case "$retcode" in
    0) echo "*** Service deleted successfuly";;
    *) echo "*** Service delete operation has errors";;
   esac
   echo "-------------------- Done. ------------------------"
   echo "Complete. Restart host."
  fi
 else
  echo "Unsupported OS: $OS_FULL"
  echo "Exiting..."
  exit 1
 fi
fi

# Clean up  
unset SERVICE_NAME SCRIPT_NAME OS_VER OS_NAME OS_FULL BOOT_DIR SMF_DIR SVC_MTD