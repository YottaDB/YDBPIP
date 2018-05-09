#!/bin/bash
#------------------------------------------------------------------------------
#
# DBSDRVM.sh - shell script for invoking local procedures in M
#
# This script invokes the Profile local procedure driver, DBSDRV, which uses
# the command line to run the function specified in the first command line
# parameter, with the function input parameters specified in the remaining
# command line parameters.
#
# This script should reside at the top level M directory.
#
# Usage: DBSDRVM.sh or /directory_path/DBSDRVM.sh
#	 $ /pip/DBSDRVM.sh in1 in2
#	 or
#	 $ cd /pip
#	 $ DBSDRVM.sh in1 in2
#
# ---------Revision History ----------------------------------------------
#
# 2009-03-12 - RussellDS
#
#		* Created
#
# ------------------------------------------------------------------------

. `dirname $0`/gtmenv

mumps -r ^DBSDRV $*

