#!/bin/ksh
# recreate_mintrpt.sh - Recreate image for PROFILE interrupt processing
# Copyright(c)2005 Fidelity Information Services.  All Rights Reserved

# Desc:  Script to recreate PROFILE Async Interrupt Processing Manager image

# Orig:  Rick Silvagni - 09/06/2005

# Input:
# 	$1 - Owner to assign to m interupt process
#	$2 - Group to assign to m interupt process

# Output:
#	mintrpt process with UID bit set for $1

# Return Status:  0 if successful
#                 1 if any failures

# Directions:
# 1.  Change directory to the location of this script.  mintrpt.c and 
#     mintrpt.mk must exist in the same directory.
# 2.  Run script as the user which needs to own the mintrpt process

# ---REVISION HISTORY---------------------------------------------------------

# ----------------------------------------------------------------------------
if [ $# -lt 2 ] ; then
   echo "Usage: $0 <owner of mintrpt> <group to assign to mintrpt>"
   exit 1
fi
owner=${1-"root"}
group=${2-"sca"}

uid=`whoami`
if [ "${uid}" != "root" -a "${uid}" != ${owner} ] ; then
      echo "Warning - Running as ${uid}, and not ${owner}, permissions will not be assigned correctly..."
fi

make -f mintrpt.mk

chown ${owner}:${group} mintrpt
if [ $? -ne 0 ] ; then
   echo "Error - could not change owner to ${owner} and group to ${group}"
fi

chmod 4750 mintrpt

ls -l mintrpt
