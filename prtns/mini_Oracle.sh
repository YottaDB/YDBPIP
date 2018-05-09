#!/bin/ksh
#
#----------------------------------------------------------------------------
#
# File defs. DBTBL1 and DBTBL1D
cd /v70oracle
. gtmenv
mumps -run C^ORACON >mini_Oracle.LOG 2>&1 <<-FIN 
        D ALL^DBMAP("ORACLE")
        S %LIBS="SYSDEV"
        D QA^DBSPROC("CUVAR")
        D QA^DBSPROC("ACHBCH")
        D QA^DBSPROC("ACHDTL")
        D QA^DBSPROC("ACHORIG")
        D QA^DBSPROC("ACNADDRCDI")        
        h
FIN
cat mini_Oracle.LOG
