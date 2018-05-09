#!/bin/bash
# ------------------------------------------------------------------------
# dm - GT.M and PROFILE/Anyware direct mode script
#
# Description:
# This script will put the user in direct mode (GTM prompt) for the
# directory in which it resides.  
#
# Input: None
#
# Output: Places the user at the GTM prompt (GTM>)
#
# Usage: dm or /directory_path/dm
#	 $ /ibsprod/dm
#	 or
#	 $ cd /ibsprod
#	 $ dm
#
# Setup: None
# ---------Revision History ----------------------------------------------
# 06/30/06 - Saurabh Jadia
#		Modified the awk command to locate the ipcs resource id from
#		the 'ipcsout' file. 
# 04/23/04 - Rick Silvagni 
#	        Added quotes around mftok to prohibit file substitution.
# ------------------------------------------------------------------------
# Processing starts at main()
ARG0=$0
if [ ! -f ${ARG0} ] ; then
   echo "Usage: dm or /directory_path/dm"
   return 1
fi

. `dirname ${ARG0}`/gtmenv

main()
{

$gtm_dist/mumps -direct
}
main
