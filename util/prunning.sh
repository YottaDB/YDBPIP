#!/bin/sh
# prunning.sh 	- Sara Walters 	       - 03/23/95
#
#		  Harsha Lakshmikantha - 02/06/97
#
# This command procedure determines if a process is running
#
# ----------------------------------------------------------------------------
#
 
ps -ef | grep $1 | grep -v "grep" | grep -v "prunning" > /tmp/prunning.$2

x=`cat /tmp/prunning.$2 | wc -l`

if [ $x -eq 0 ]
then
	echo "0"
else
	echo "1"
fi

rm -f /tmp/prunning.$2
