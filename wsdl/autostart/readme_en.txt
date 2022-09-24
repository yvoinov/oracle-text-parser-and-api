============================================================
Autostart OC4J & Solaris 10 SMF   (C) 2006,2009, Yuri Voinov
============================================================

This  set  of  scripts  allows  you  to activate and disable
automatic start and stop of services Oracle OC4J in one step
on the following systems:

- Solaris 8,9
- Solaris 10 and above.
- Linux (RHEL3, RHEL4, SuSE, Fedora, 
         Oracle Enterprise Linux)

The  init.oc4j  script is used to enable autostart of Oracle
services.  Depending  on the platform (Solaris 8-10), either
links   are   created   in   the  /etc/rc3.d  directory,  or
registration  of  the  service  and creation of links by the
command chkconfig (Linux RHEL3/4) or register service in the
SMF service.

This  service  is intended for use on Sun Solaris 8,9,10,>10
or  on  Linux  platforms  (tested  on  Solaris and RHEL3/4).
Platform recognition is done automatically.

To   install  script(s)  and/or  create  links  and  service
descriptor  registration, script is used install.sh . Before
running  it,  you  need to check and edit init.oracle script
variables   depending   on   the   target   host's   service
configuration.  Of  course  the install.sh/remove.sh scripts
should run from the root account.

The following variables are edited:

#
# ORA_HOME variable for Standalone OC4J.
# This is substitution variable for legal
# ORACLE_HOME variable below.
# DO NOT RENAME THIS VARIABLE!!
ORA_HOME="/export/home/OraHome3"

#
# Log file. Default /var/adm/oc4j.log
#
LOG="/var/log/oc4j.log"

After  editing the variables, you must also check oracle.xml
file  (When installing autostart on Solaris 10) and edit the
paths if necessary.

To install services, unpack the following files:

init.oc4j            - main start-stop script OC4J
oracle.xml           - OC4J service descriptor for OMF
install.sh           - auto start installation script
remove.sh            - auto start removal script

to  the  required  directory and execute with account rights
root  install.sh  script.  After  its  completion,  all  the
necessary  file  structures  will  be  created  and  you can
perform  service  activation  either  by restarting the host
(Solaris 8,9, Linux) or by running the command (Solaris 10):

# svcadm enable oc4j

controlling the launch of services in a separate session:

# tail -f /var/log/oc4j.log 

(the  path  and  name  of  the  log may be different and are
configurable in the init.oc4j script with the LOG parameter)

To stop and delete autostart, you need to do following:

- For Solaris 8,9, Linux:
1. Stop Oracle services manually;
2. Execute as root the remove.sh script from the given archive

- For Solaris 10 and above:
1. Execute:
# svcadm disable oracle
2. Execute as root the remove.sh script from the given archive

For  Solaris  10 and higher start/stop/restart oc4j services
performed  through  the  administrative  interface  OMF  (by
commands svcadm/svcs). To monitor the status of services and
processes  startup  is  used  as  the  main  start/stop  log
(/var/log/oc4j.log  by  default) and own logs OC4J services.
In  addition,  for  both Solaris 10 and previous versions of
start/stop  operations  can be performed by directly calling
the  script /etc/init.d/init.oc4j {start|stop|restart} (when
performing these operations on Solaris 10 must first disable
the  service  OC4J  using  the  OMF interface, otherwise OMF
restarter  will  restart  manually  stopped services without
notice).

Noted: 
======

1.Autostart    install/uninstall    scripts    use   several
assumptions and are subject to certain rules, namely:
-  It  is  assumed  that  OC4J is installed according to the
recommendations  Oracle  Installation Guide and uses the DBA
group. If a DBA group missing, on Solaris 8.9 and Linux exit
with error and return code 1 (for example, if OC4J installed
with  the oinstall group - this is a mistake in principle is
not,  but  can  serve  as  a  source of difficult detectable
errors  when  using  OHS  services  and  iAS. Moreover, this
behavior  is  poorly  documented  -  and therefore it is not
recommended  to  violate  the  canonical recommendations and
install OC4J with a group other than dba).
- It is assumed (or verified) that they are fulfilled in run
level  multi-user  (3).  Otherwise  access  to  many  system
commands  and  services  is  impossible and the execution of
scripts will be interrupted with an error.
-  Execution  level  of  auto-run script(s) at least 3 (i.e.
signle user will not attempt to start services OC4J).
- It is assumed that the administrator performing the data
install/uninstall scripts, runs them as root. If it is not,
execution aborts with an error and a return code of 1.
-    It   is   assumed   that   before   executing   scripts
install/uninstall     system     administrator/administrator
database  has  stopped  the OC4J services manually. Services
are  not checked for execution. Also no automatic operations
start/stop  (Solaris  8.9, Linux) or activation/deactivation
of Oracle services (for Solaris 10). Starting services after
installing  autostart  should also be executed manually with
svcadm commands or /etc/init.oracle start
-  For  Linux  RHEL 3/4 when stopping the host with the init
0/init  5  system  services are stopped by the command kill.
This  causes  an abort instance of Oracle and the subsequent
start  of  services  can require a significantly longer time
due to perform automatic service recovery.
============================================================
Autostart OC4J & Solaris 10 SMF   (C) 2006,2009, Yuri Voinov
============================================================