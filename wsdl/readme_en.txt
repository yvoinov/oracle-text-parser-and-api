      Automatic launch of an OC4J instance
      ------------------------------------

When  automatically launching an OC4J instance, you must set
the  DISPLAY  variables (pointing to the server!), JAVA_HOME
(/usr   on   Solaris)   and   ORACLE_HOME   which  looks  on
OC4J_EXTENDED.

The  schema  owner name in config.xml must be set correctly,
as  well as the password for the connection. In addition, it
must be specified valid reference to the database instance.

  To enable Oc4jMount for OHS (Apache) you need to:
  -------------------------------------------------

1.  Edit  the  default-web-site.xml  of the OC4J instance by
explicitly  specifying  (or  by changing default http) ajp13
protocol for port 8888. (config/oc4j directory).
2.  Modify  Apache's  mod_oc4j.conf  file  as  shown  in the
mod_oc4j.conf file of this archive (config/ohs directory).
3. Activate automatic start of OC4J and restart Apache (OHS)
and OC4J.

-----------------------------------------------------------
- Copyright (C) 2007,2008 Yuri Voinov                     -
-----------------------------------------------------------