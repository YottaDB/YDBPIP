#!/bin/sh
# scaedit_edt.sh
#
# Purpose: wrap around shell for various editors under UNIX environment.
#
# Description: The problem with editing a file is that we don't know whether
#              the user exited (with save) or quit (without save). Under VMS,
#              we can check if a file was saved by looking at the version
#              number. Unfortunately, UNIX does not have the same file 
#              structure. As a result, ^DBSEDT thinks the file was modified
#              when in fact the user only "looked" at it.
#              This shell script provides a way for returning a value to a
#              MUMPS process, so that it could make better decision whether
#              to file the change in DATAQWIK or not. We begin by saving the
#              file creation date/time timestamp. If the user "saves" the
#              buffer anytime during the edit session, a new timestamp is 
#              generated for the buffer. In the end, we can compare the old
#              timestamp against the new one to figure out if file has been
#              changed. If so, we return 0. Otherwise, we will return 1.
#
# Usage: This script is called by routine ^DBSEDT from within MUMPS to edit
#        files. Input parameter $1 is the name of the editor. Parameter $2 is
#        the file storing routine to edit. This file must exit before calling
#        the script file.
#
#        If exit (with save), it will return value 0 for success.
#        If quit (without save), it will return value 1 for failure.
#
# Notes:
#
# Revision History:
#
# 04/19/99 - Hien Ly
#            The problem with checksum compare (or diff) is that if the buffer
#            is the same before and after editing, we will generate a 1 (no
#            changes made). This impacts the "create" mode as user keeps the
#            default editing buffer as starting point (no changes made). The
#            return code from this shell script forces DATAQWIK to abandon
#            the "edit" session, and the user is returned to the main menu.
#            This is undesirable behavior. Here, we attempt to resolve
#            it with a call to a C program (filecdt) to get the file creation
#            date/time timestamp of the buffer before and after the edit
#            session. If they are different, then the user must have "saved"
#            the buffer at least once, and we will return 0 to indicate
#            exit with changes. Otherwise, we will return 1 to indicate quit
#            without changes made. 
#
# 03/25/99 - Hien Ly
#            Return 1 for failure instead of -1. Every system handles the
#            return value to MUMPS differently. The -1 somehow comes back
#            to MUMPS as 0 on Digital Unix system (TRU64).
#
# 03/16/99 - Hien Ly
#            Use file checksum for compare purpose.
#-----------------------------------------------------------------------------

#
# set up initial variables
#  
success=0
failure=1

#
# check if we have at least 2 parameters passed in
#
if [ $# -lt 2 ]
then
	exit $failure
fi

#
# set editor name for use later
#
editor=$1

#
# exit if file does not exists
#
filename=$2
if [ ! -f ${filename} ]
then
	exit $failure
fi

#
# get file checksum
#
# old_cksum=`cksum ${filename} | awk '{print $1}'`

#
# check if filecdt is in targeted directory
#
if [ ! -f ${BUILD_DIR}/tools/misc/filecdt ]
then
	echo "${BUILD_DIR}/tools/misc/filecdt is missing.\n"
	echo "DBSEDIT will not behave correctly.\n"
	echo "Please install the appropriate executable.\n"
else
	# save file creation date/time timestamp
	old_cdt=`${BUILD_DIR}/tools/misc/filecdt ${filename}`
fi

#
# Optional processing: At this point, we can search the user's home directory
# for editor startup file such as .emacs or .vi or .pico, etc. This section
# of code is left here as sample only. The system automatically loads these
# files into the editor so don't have to do much. Please feel free to modify
# it as required by customer.
# 
# if [ -f ${HOME}/.vi ]
# then
#	vi -R ${filename}           <<< put vi in READ mode, not very useful!
# else
#	vi ${filename}
# fi

#
# delay a second so that user can catch up
#
sleep 1

#
# start the editor
#
${editor} ${filename}

#
# check if editor returned cleanly
#
if [ $? != 0 ]
then
	exit $failure
fi

#
# done with editing, now check if the file was touched.
#
if [ ! -f ${BUILD_DIR}/tools/misc/filecdt ]
then
	exit $success
else
	new_cdt=`${BUILD_DIR}/tools/misc/filecdt ${filename}`
	# determine exit status based on file creation date/time timestamp
	if [ "$old_cdt" != "$new_cdt" ]
	then
		exit $success
	else
		exit $failure
	fi
fi
#
# end of script
#
