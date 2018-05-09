#!/bin/bash
#
#	sca_alert.sh 
#
#	Harsha Lakshmikantha	09/29/99
#
# This is the default script that is called by the function $$ERRLOS^%ZFUNC
# to send an alert. This script can be overridden by setting the environment
# variable ALERT_SCRIPT.
#
# sca_alert.sh input parameters:
#   parameter 1 - Name of the system sending the event (hostname -s)
#   parameter 2 - Event title
#   parameter 3 - Event text (must start with "SANCHEZ " and then 
#                 the actual error)
#   parameter 4 - The severity of the event (one of clear, indeterminate, 
#                 warning, minor, critical or major)
#
#---REVISION HISTORY----------------------------------------------------------
#
#	01/21/2004	-Saurabh Jadia
#			Assigned a variable OUTFILE to define the log file.
#
#-----------------------------------------------------------------------------

OUTFILE=/tmp/sca_alert.log

if [ ! -f ${OUTFILE} ]
then
	touch ${OUTFILE}
	chmod 777 ${OUTFILE}
fi

EVENT_TEXT=`echo $3 | tr '^' ' '`

echo "Alert Message:" >> ${OUTFILE}
echo "	${EVENT_TEXT}\n" >> ${OUTFILE} 

echo "Alert Data Items:" >> ${OUTFILE}
echo "	System sending the event	: ${1}" >> ${OUTFILE}
echo "	Event title			: ${2}" >> ${OUTFILE}
echo "	Event text			: ${EVENT_TEXT}" >> ${OUTFILE}
echo "	Event severity			: ${4}" >> ${OUTFILE}
echo "	Timestamp			: `date`" >> ${OUTFILE}
echo "	User Id				: `whoami`" >> ${OUTFILE}
echo "\n\n\n" >> ${OUTFILE}

# Call site specific alert script (Example shown below)
#/usr/local/bin/inglog -a "PROFILE" -m "sanchez.cat" -s ${4} ${3}
