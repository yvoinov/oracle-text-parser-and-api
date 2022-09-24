------------------------------------------------------------
Version 1.0.0.5         Copyright (C) 2004,2008, Yuri Voinov
------------------------------------------------------------

Logged Web Service Version
--------------------------
This version contains an automatic log cleanup task every 30
days and is designed to work as part of the portal.

                     CTX_API package
                     ===============

WARNING:  The  package  uses  the procedures of the CTX_THES
package.  For  correct  loading and operation of the package
must be given a direct grant for CTX_THES package:

grant execute on ctx_thes to <user>;

CTXAPP  role grant is not enough! (role is granted by target
scheme  with  an  installation  script  due  to the need for
access package functions to CTXSYS schema representations)

Note: This grant will automatically given during installation
parser script inst_parser.*

Note  1:  If  the  parser  is  executed  in a mode that uses
thesaurus  (CONTEXT  query  mode  /  context  refinement  by
thesaurus),  in  the  absence  of  a  loaded  thesaurus,  an
ORA-20150  error is raised. The rest of the package routines
also  use  the  thesaurus  and  in  the  absence of a loaded
thesaurus raise an error 20150. Note that a thesaurus is not
necessarily has the name DEFAULT, in this case, when calling
subroutines (including the parser) it is necessary to define
the name of the used thesaurus.

Note 2: The ctx_nt_terms package constant defines the number
of terms NT of the level of the thesaurus hierarchy at which
should  be  stopped  when performing automatic extensions of
BT/NT    hierarchical   functions   by   package   functions
search_expansion_level,               search_expansion_term,
search_string_parser.  By  default,  functions  stop  at the
level  whose BT contains more than 5 NT terms. Usually, this
is  sufficient  for  typical applications. If the values the
default  is  not enough, you need to change the constant (by
editing   the   package   spec)   and   reload  the  package
(specification and body).

Note  3:  Of  course,  before  installing  the  package, the
database  must contain the Oracle Text (ConText) option. The
package contains data type definitions based on types Oracle
text. When a package is installed, checking the existence of
Oracle Text in the target database.

Behavior features:
==================

1.  The p_thes_name parameter cannot contain "_" characters,
they  will  be  removed  from  the resulting string returned
parser.

2. If the p_exp_detail_on parameter is enabled (equal to 1),
the parameter p_expansion_level will be ignored.

3.  If the query extension mode is p_query_opt='about','syn'
or   'rt',   or  if  p_query_mode  =  'keyword'  (search  by
keywords), the p_exp_detail_on will parameter ignored.

------------------------------------------------------------
Version 1.0.0.5         Copyright (C) 2004,2008, Yuri Voinov
------------------------------------------------------------