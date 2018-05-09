#!/bin/sh
# pgtm.sh 	- Sara Walters 	       - 03/23/95
#
#		  Harsha Lakshmikantha - 02/06/97
#
# This command procedure determines if a process is a gtm process
#
# ----------------------------------------------------------------------------
#

ps -ef | grep $1 | grep mumps | grep -v "grep" | grep -v "pgtm" > /tmp/pgtm.$2

x=`cat /tmp/pgtm.$2 | wc -l`

if [ $x -eq 0 ]
then
	echo "0"
else
	echo "1"
fi

rm -f /tmp/pgtm.$2
