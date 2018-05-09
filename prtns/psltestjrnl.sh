#!/bin/ksh
#
# Desc:  psltest.sh is used to confirm changes made to the PSL
#        compiler.  This runs through a series of PSL procedures
#        for a generic non-application level test of the compiler.
#        the focus is on data access (for database independence
#        and PSL language constructs.
#
#        The tests are responsible for data setup and teardown.
#        The tests are designed to be runable in any environment.
#
echo 'psltest.sh '
echo 'Sanchez Computer Associates'
echo 'This test compiles, then executes test procedures'
echo 'in order to conifrm that the core functionality'
echo 'of the PSL Compiler is working as expected.'
echo ''


if (( $# < 1 ))
then    echo "ERROR: directory name required."
	echo 'Syntax: psltest.sh dirname '
	echo ''
        exit 1
fi

DIR=$1

cd /$DIR
. ./gtmenv
echo "Turning Journaling on"
cd gbls
mupip set -journal=on,nobefore,enable,file="ubg.mjl" -reg "UBG"
mupip set -journal=on,nobefore,enable,file="tbls.mjl" -reg "TBLS"
cd ..
echo "PSLTEST - Compiling Part 1"
$gtm_dist/mumps -direct <<-FIN
	D QA^DBSPROC("ZTSTPSL")
	D ^ZTSTPSL
	H
FIN
echo "Turning Journaling off"
cd gbls
mupip set -journal=off -reg "UBG"
mupip set -journal=off -reg "TBLS"
mupip journal -extract -forward ubg.mjl
mupip journal -extract -forward tbls.mjl
cp ubg.mjf ../prtns/UBG.MJF
cp tbls.mjf ../prtns/TBLS.MJF
rm ubg.*
rm tbls.*
