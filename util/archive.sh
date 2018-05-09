#!/bin/sh
#
#	Usage: archive.sh dir archive_file GDS_file_name size target_dir
#	
#	Exapmle:
#
#	$SCA_RTNS/archive.sh ibsdev HIST arch_hist1 5000 /ibsdev/gbls/archive
#
#	David Cinalli 2/12/99
#
#	Parameters
#
#	$1	-	PROFILE Directory name
#	$2	-	Archive file (HIST, EFTPAY, etc.)
#	$3	-	Arvhive GDS file name (PROFILE variable name)
#	$4	-	Intended size of new database file (# of 2K blks)
#	$5	-	Target directory
#

# Check for correct usage

if [ $# -lt 5 ]
then
	echo $0: Usage: $0 dir arch_file GDS_file_name size target_dir
	echo $0: Example: $0 ibsdev HIST arch_hist1 5000 /ibsdev/gbls/arvhive
	echo ""
	echo "Enter IBS HOST directory name: \c"
	read PDIR
	echo ""
	echo "Enter Archive File: \c"
	read FILE
	echo ""
	echo "Enter Archive GDS File Name: \c"
	read NAME
	echo ""
	echo "Enter Size of New Database File: \c"
	read SIZE
	echo ""
	echo "Enter Target Directory: \c"
	read ARCHDIR
	echo ""
	$SCA_RTNS/archive.sh ${PDIR} ${FILE} ${NAME} ${SIZE} ${ARCHDIR} >> /${PDIR}/gbls/archive/archive.log
	exit

fi

PDIR=$1
FILE=$2
NAME=$3
SIZE=$4
ARCHDIR=$5

if [ ! -d /${PDIR} ]
then
	echo "ERROR: /${PDIR} not a valid PROFILE directory\n"
	exit
fi

if [ ! -d ${ARCHDIR} ]
then
	echo "ERROR: ${ARCHDIR} directory not found\n"
	exit
fi

if [ ! -f /${PDIR}/gtmenv ]
then
	echo "ERROR: /${PDIR}/gtmenv not found\n"
	exit
fi

# Define environment variables for the PROFILE directory

. /${PDIR}/gtmenv

# Assign logicals for new database and global directory files

export SCAU_${PDIR}_${NAME}=${ARCHDIR}/mumps.${NAME}
export ${PDIR}_${NAME}=${PDIR}_${NAME}.gld

# Create profile_archive.gld Global Directory
#	Note: This won't be needed at client site

cd /${PDIR}/gbls
gtmgbldir=${ARCHDIR}/${PDIR}_${NAME}.gld
export gtmgbldir

${gtm_dist}/mumps -direct >> /${PDIR}/gbls/archive/gde.log <<-FIN

	D ^GDE
	add -reg archive -dyn=archive
	change -reg archive -key=210 -rec=510
	add -seg archive -file=${ARCHDIR}/mumps.${NAME}
	change -seg archive -alloc=${SIZE}
	lock -reg=archive
	change -name * -reg=archive
        delete -seg default
        delete -reg default
	sh
	exit

FIN

#  Create Archive Database File

${gtm_dist}/mupip create

# Exit

echo "CREATE PROFILE ARCHIVE process successfully completed"

echo "ATTENTION*****ATTENTION****ATTENTION****ATTENTION"

echo "***Define environment variables for the PROFILE directory***"
