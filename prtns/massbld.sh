#!/bin/ksh
#
#   Mark Spier	11/20/2002
#
#---REVISION HISTORY---------------------------------------------------------
#
#
#----------------------------------------------------------------------------
#
# File defs. DBTBL1 and DBTBL1D
DIR=$1
# this will remove sub dirs so make sure nothing is below the dit cd'd to
cd $DIR
. /SCA/scaenv
. ./gtmenv
$
$gtm_dist/mumps -direct <<-FIN
        S %LIBS="SYSDEV"
	D NEWPROC^PSLTEST
	h
FIN
$gtm_dist/mumps -direct <<-FIN
        S %LIBS="SYSDEV"
	D NEWBAT^PSLTEST
	h
FIN
$gtm_dist/mumps -direct <<-FIN
        S %LIBS="SYSDEV"
	D NEWFILE^PSLTEST
	H
FIN
