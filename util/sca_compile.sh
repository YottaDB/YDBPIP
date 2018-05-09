#!/bin/sh
# sca_compile.sh 	- Sara Walters         -	    3/23/95
# Revised	 	- Harsha Lakshmikantha -	    1/10/96 
#
#
# This command procedure compiles mumps source code for a given routine or
# list of routines.	
#
# ----------------------------------------------------------------------------
# Revision History
# 
# 12/01/2000	Anurag Mathur
#		Commented out the check to delete the $HOME/gtm_compile.err
#
# ----------------------------------------------------------------------------
#
#

cmd_line()
{
	verbose=$1
	src_dir=$2
	obj_dir=$3
	if test -d $obj_dir
	then
		echo ""
	else
		obj_dir=$src_dir
		if test $verbose = "1"
		then
			echo "Source directory is $src_dir\n"	
			echo "Object directory is $obj_dir\n"	
		fi
	fi
	while test "$4" != ""
	do
		UPPER=`basename $4 .m`
		if test -f ${obj_dir}/$UPPER.o
		then
			if test -w ${obj_dir}/$UPPER.o
			then
				echo ""
			else
				echo "$0: File ${obj_dir}/$UPPER.o is not writeable by user\n" 
				echo "$0: File ${obj_dir}/$UPPER.o is not writeable by user\n" > ${HOME}/gtm_compile.err
				exit -1
			fi
		fi
		if test -r ${src_dir}/$UPPER.m
		then
			if test $verbose = "1"
			then
				#echo "${GTM_DIST}/mumps -o=${obj_dir}/$UPPER.o -labels=upper ${src_dir}/$UPPER.m\n"
				echo " "
			fi
			${GTM_DIST}/mumps -o=${obj_dir}/$UPPER.o -labels=upper ${src_dir}/$UPPER.m
			#chmod +x ${obj_dir}/$UPPER.o
		else
			echo "$0: File ${src_dir}/$UPPER.m is not readable by user\n" 
			echo "$0: File ${src_dir}/$UPPER.m is not readable by user\n" > ${HOME}/gtm_compile.err
			exit -1
		fi
		shift
	done
}

input_filenames()
{
	while true
	do
		echo "Enter Cntrl-C to exit at any time\n"
		echo "File Name:\c"; read file
		echo "Source Directory:\c"; read src_dir
		echo "Object Directory:\c"; read obj_dir
		UPPER=`basename $file .m`
		if test -w ${src_dir}/$UPPER.o
		then
			if test -r ${src_dir}/$UPPER.m
			then
				#echo "{GTM_DIST}/mumps -o=${obj_dir}/$UPPER.o -labels=upper ${src_dir}/$UPPER.m\n"
				${GTM_DIST}/mumps -o=${obj_dir}/$UPPER.o -labels=upper ${src_dir}/$UPPER.m
				chmod +x ${obj_dir}/$UPPER.o
			else
				echo "$0: File ${src_dir}/$UPPER.m is not readable by user\n" 
			fi
		else
			echo "$0: File ${obj_dir}/$UPPER.o is not writeable by user\n" 
		fi
	done
}

#	Errors are re-directed to a file in the setuid directory.
2>${HOME}/gtm_compile.err
if test $# = 0
then
	input_filenames
else
	if test $# = 4
	then
		cmd_line $1 $2 $3 $4
	else
		echo "$0: Usage sca_compile verbose[1 or 0] SourceDirectory ObjectDirectory\n"
		exit -1
	fi
#nlines=`cat ${HOME}/gtm_compile.err | wc -l`
#if test $nlines -eq 0
#then
#        rm -fr ${HOME}/gtm_compile.err
#fi
fi

