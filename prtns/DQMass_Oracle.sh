#!/bin/ksh
#
# This shell script is called by the MassCompile.exp script.  It is used to run
# regular mumps mass compiles as well as PSL mass compiles, before finishing with integs.
# The script will use the directory name sent from the testmanager.ini file and 
# the output will be logged to a file in that directories home under the name of
# massbld_DIR.LOG where DIR=the directory named in the ini file.
#
# Example call: 'Expect MassCompile.exp' which then calls 'DQMass.sh v70qaix' output is
# then logged to /v70qaix/massbld_v70qaix.LOG which will then call CompParse.java to 
# list out all found files with errors to standard output.
#
#   Original: Mark Spier  11/20/2002
#
#---REVISION HISTORY---------------------------------------------------------
# 
# 050803 - sharffj, combined mass compile script to cover all areas at once.
#----------------------------------------------------------------------------
#
# File defs. DBTBL1 and DBTBL1D
DIR=$1
cd /$DIR
rm massbld_$DIR.LOG
echo "@Break RegM" >>massbld_$DIR.LOG 2>&1
# /SCA/tools/misc/mass_compile.sh /$DIR >>massbld_$DIR.LOG 2>&1
# this will remove sub dirs so make sure nothing is below the dit cd'd to
cd /$DIR
. /SCA/scaenv
. ./gtmenv
DIR=$1
echo "@Break Proc" >>massbld_$DIR.LOG 2>&1
$gtm_dist/mumps -run C^ORACON >>massbld_$DIR.LOG 2>&1 <<-FIN 
        S %LIBS="SYSDEV"
        D NEWPROC^PSLTEST
        h
FIN
echo "@Break Bats" >>massbld_$DIR.LOG 2>&1
$gtm_dist/mumps -run C^ORACON >>massbld_$DIR.LOG 2>&1 <<-FIN
        S %LIBS="SYSDEV"
        D NEWBAT^PSLTEST
        h
FIN
echo "@Break FDef" >>massbld_$DIR.LOG 2>&1
$gtm_dist/mumps -run C^ORACON >>massbld_$DIR.LOG 2>&1 <<-FIN
        S %LIBS="SYSDEV"
        D NEWFILE^PSLTEST
        H
FIN
echo "@Break Intg" >>massbld_$DIR.LOG 2>&1
$gtm_dist/mumps -run C^ORACON >>massbld_$DIR.LOG 2>&1 <<-FIN
        S POP="$I"
        D TBLINTEG^DDPXFR
        H
FIN
