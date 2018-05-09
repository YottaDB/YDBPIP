#	Subsystem:  MTS
#
#	Copyright (C) 1995 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	Makefile,v $
# Revision 1.2  96/03/22  16:40:20  16:40:20  zengf (Fan Zeng)
# *** empty log message ***
# 
# Revision 1.1  95/07/24  11:26:26  11:26:26  rcs ()
# Initial revision
# 
# Revision 1.2  95/05/22  15:02:10  15:02:10  sca ()
# I VMS
# 
#	$Revision: 1.2 $
#
#
#
#
SHARED_LIBRARY=extcall.sl

# Define your C objects list
OBJECTS=\
	atmutils.o\
	asc2ebc.o\
	devutils.o\
	ebc2asc.o\
	elfhash.o\
	expsca.o\
	lnx.o\
	logsca.o\
	pidutils.o\
	readport.o\
	remote.o\
	rtb.o\
	rtbar.o\
	string.o\
	sysutils.o\
	unpack.o\
	unpack2.o\
	utils.o\
	xor.o\
	scamd5.o\
	md5c.o\
	${BUILD_DIR}/sca_gtm/shlib/shlib.o

include ./rules.mk
include ./slibrule.mk

all: ${OBJECTS} ${SHARED_LIBRARY}

#------------------------------------------------------------------------
# Define the command-line options to the compiler.  The options we use
# have the following meanings:
#------------------------------------------------------------------------
#DEBUG = -DDEBUG

lnx.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

logsca.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

xor.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

rtb.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

rtbar.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

unpack.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

unpack2.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

ebc2asc.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

atmutils.o:\
        extcall.h\
        ${BUILD_DIR}/include/scatype.h
 
elfhash.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

expsca.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

readport.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

sysutils.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

devutils.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

pidutils.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

utils.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

remote.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

string.o:\
	${BUILD_DIR}/sca_gtm/extcall/extcall.h\
	${BUILD_DIR}/include/scatype.h

scamd5.o:\
	${BUILD_DIR}/sca_gtm/extcall/scamd5.h\
	${BUILD_DIR}/sca_gtm/extcall/md5.h\
	${BUILD_DIR}/include/scatype.h
 
md5c.o:\
	${BUILD_DIR}/sca_gtm/extcall/md5.h\
	${BUILD_DIR}/include/scatype.h
 
# DO NOT DELETE THIS LINE
