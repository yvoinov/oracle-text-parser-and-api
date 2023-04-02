#!/bin/sh

# Oracle OC4J services autostart setup for Solaris 8,9,10,>10, Linux
# Yuri Voinov (C) 2006, 2009
#
# ident "@(#)install.sh    1.7    07/02/17 YV"
#

#############
# Variables #
#############

SERVICE_NAME="oc4j"
export SERVICE_NAME
SCRIPT_NAME="init.$SERVICE_NAME"
export SCRIPT_NAME
SMF_XML="$SERVICE_NAME.xml"
export SMF_XML
BOOT_DIR="/etc/init.d"
export BOOT_DIR
SMF_DIR="/var/svc/manifest/application/oracle"
export SMF_DIR
SVC_MTD="/lib/svc/method"
export SVC_MTD

#
# OS Commands location variables
#
CAT=`which cat`
CHOWN=`which chown`
CHMOD=`which chmod`
CP=`which cp`
CUT=`which cut`
ID=`which id`
GREP=`which grep`
LN=`which ln`
LS=`which ls`
UNAME=`which uname`
UNLINK=`which unlink`

OS_VER=`$UNAME -r|$CUT -f1 -d" "`
export OS_VER
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
export OS_NAME
OS_FULL=`$UNAME -sr`
export OS_FULL

################
# Subroutines. #
################

# Copy init script function
copy_init ()
{
 SC_NAME=$1
 NON_10_OS=$2

 if [ "$NON_10_OS" = "1" ]; then
  if [ ! -f $BOOT_DIR/$SC_NAME ]; then
   $CP $SC_NAME $BOOT_DIR/$SC_NAME>/dev/null 2>&1
  fi
 else
  if [ ! -f $SVC_MTD/$SC_NAME ]; then
   $CP $SC_NAME $SVC_MTD>/dev/null 2>&1
  fi
 fi

}

# Link legacy RC scripts
link_rc ()
{
 SC_NAME=$1

 $UNLINK /etc/rc3.d/K01$SERVICE_NAME>/dev/null 2>&1
 $UNLINK /etc/rc3.d/S99$SERVICE_NAME>/dev/null 2>&1
 $LN -s $BOOT_DIR/$SC_NAME /etc/rc3.d/K01$SERVICE_NAME
 $LN -s $BOOT_DIR/$SC_NAME /etc/rc3.d/S99$SERVICE_NAME
}

# Check group dba exists
check_group_dba ()
{
 GR_NAME=`$CAT /etc/group|$GREP dba|$CUT -f1 -d":"`
 
 if [ "$GR_NAME" != "dba" ]; then
  echo "ERROR: Group DBA does not exists. Make sure Oracle software installed."
  echo "Exiting..."
  exit 1
 fi
}

# Make OMF entry
make_omf ()
{

 SVCCFG=`which svccfg`

 if [ ! -d $SMF_DIR ]; then
  mkdir $SMF_DIR
 fi
 $CP $SMF_XML $SMF_DIR
 $CHOWN -R root:sys $SMF_DIR
 $SVCCFG validate $SMF_DIR/$SMF_XML>/dev/null 2>&1
 retcode=`echo $?`
 case "$retcode" in
  0) echo "*** XML service descriptor validation successful";;
  *) echo "*** XML service descriptor validation has errors";;
 esac
 $SVCCFG import $SMF_DIR/$SMF_XML>/dev/null 2>&1
 retcode=`echo $?`
 case "$retcode" in
  0) echo "*** XML service descriptor import successful";;
  *) echo "*** XML service descriptor import has errors";;
 esac
}

# Installed service verification
verify_svc ()
{
 SC_NAME=$1

 echo "------------ Service verificstion ----------------"
 if [ "$OS_FULL" = "SunOS 5.9" -o "$OS_FULL" = "SunOS 5.8" ]; then
  $LS -al /etc/rc3.d/*$SERVICE_NAME
 elif [ "$OS_NAME" = "SunOS" -a "$OS_VER" -ge "5.10" ]; then
  SVCS=`which svcs`
  $LS -al $SVC_MTD/$SC_NAME
  $LS -l $SMF_DIR
  $SVCS $SERVICE_NAME
 else
  $LS -al /etc/rc3.d/*$SERVICE_NAME
  $LS -al /etc/rc0.d/*$SERVICE_NAME
 fi 
}

# Check supported Linux
supported_linux ()
{
 # Supported Linux: RHEL3, RHEL4, SuSE, Fedora, Oracle Enterprise Linux
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
echo "#     Oracle OC4J autostart installation script     #"
echo "#                                                   #"
echo "# Press <Enter> to continue, <Ctrl+C> to cancel ... #"
echo "#####################################################"
read p

if [ ! -f $SMF_XML -a ! -f $SCRIPT_NAME ]; then
 echo "One or more installation files not found."
 echo "Exiting..."
 exit 1
fi

if [ "$OS_FULL" = "SunOS 5.9" -o "$OS_FULL" = "SunOS 5.8" ]; then
 WHO=`$ID | $CUT -f1 -d" "`
 if [ ! "$WHO" = "uid=0(root)" ]; then
   echo "ERROR: you must be super-user to run this script."
   exit 1
  else
   # Install for SunOS 8,9
   echo "OS: $OS_FULL"
   copy_init $SCRIPT_NAME 1
   check_group_dba
   $CHOWN root:dba $BOOT_DIR/$SCRIPT_NAME
   $CHMOD 755 $BOOT_DIR/$SCRIPT_NAME
   link_rc $SCRIPT_NAME
   # Verify installation
   verify_svc $SCRIPT_NAME
   echo "-------------------- Done. ------------------------"
   echo "Complete. Check $SCRIPT_NAME working and if true,"
   echo "restart host to verify."
 fi
elif [ "$OS_NAME" = "SunOS" -a "$OS_VER" -ge "5.10" ]; then
 WHO=`/usr/xpg4/bin/id -n -u`
 if [ ! "$WHO" = "root" ]; then
  echo "ERROR: you are not authorized to run this script."
  exit 1
 else
  # Install for SunOS >= 10
  echo "OS: $OS_FULL"
  copy_init $SCRIPT_NAME 0
  $CHOWN root:sys $SVC_MTD/$SCRIPT_NAME
  $CHMOD 755 $SVC_MTD/$SCRIPT_NAME
  make_omf
  # Verify installation
  verify_svc $SCRIPT_NAME
  echo "-------------------- Done. ------------------------"
  echo "Complete. Check $SCRIPT_NAME working and if true,"
  echo "enable service by svcadm."
 fi
else
 if [ "$OS_NAME" = "Linux" -a "`supported_linux`" = "1" ]; then
  WHO=`$ID | $CUT -f1 -d" "`
  if [ ! "$WHO" = "uid=0(root)" ]; then
   echo "ERROR: you must be super-user to run this script."
   exit 1
  else
   # Install for Linux
   echo "OS: $OS_FULL"
   CHKCONFIG=`which chkconfig`
   copy_init $SCRIPT_NAME 1
   check_group_dba
   $CHOWN root:dba $BOOT_DIR/$SCRIPT_NAME
   $CHMOD 755 $BOOT_DIR/$SCRIPT_NAME
   # Service registration and add links
   $CHKCONFIG --add $SCRIPT_NAME>/dev/null 2>&1
   $CHKCONFIG --level 345 $SCRIPT_NAME on>/dev/null 2>&1
   # Verify installation
   verify_svc $SCRIPT_NAME
   echo "-------------------- Done. ------------------------"
   echo "Complete. Check $SCRIPT_NAME working and if true,"
   echo "restart host to verify."
  fi
 else
  echo "Unsupported OS: $OS_FULL"
  echo "Exiting..."
  exit 1
 fi
fi

# Clean up  
unset SERVICE_NAME SCRIPT_NAME SMF_XML SMF_DIR SVC_MTD OS_VER OS_NAME OS_FULL