#	Subsystem:  MTM
#
#	Copyright (C) 1995 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	api.mk,v $
#	Revision 1.1  96/03/21  15:06:19  15:06:19  zengf (Fan Zeng)
#	Initial revision
# 
#	$Revision: 1.1 $
#

# Define Process Name

#SHARED_LIBRARY=${BUILD_DIR}/sca_gtm/extcall/libsql.a
SHARED_LIBRARY=./libsql.a

all:    ${SHARED_LIBRARY}

# Define your C objects list
OBJECTS=\
	libsql.o\
	util.o\
	client.o\
	utils.o \
	scafmtcol.o

#include ${LIBDIR}/rules.mk
#include ${LIBDIR}/make_lib.mk
include ./rules.mk
include ./make_lib.mk
#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------
#DEBUG = -DDEBUG -g

libsql.o:\
	libsql.h\
	scatype.h\
	util.o

util.o:\
	libsql.h\
	scatype.h

client.o:\
        mtmapi.h\
        scatype.h\
        mtm.h

utils.o:\
        mtmapi.h\
        scatype.h\
        mtm.h

scafmtcol.o:\
        mtmapi.h\
        scatype.h\
        mtm.h

# DO NOT DELETE THIS LINE
