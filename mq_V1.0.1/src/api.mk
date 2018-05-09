#	Subsystem:  MQSeries
#
#	Copyright (C) 1999 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	api.mk,v $
# 
#	$Revision: 1.1 $
#

# Define Process Name
SHARED_LIBRARY=./libmqmapi.sl

all:	${SHARED_LIBRARY} 

# Define your C objects list
OBJECTS=\
	mqclient.o\
	mqserver.o\
	mqmutils.o

include mqmrules.mk
include mqmslibrule.mk

#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------
DEBUG = -DDEBUG -g

mqclient.o:\
	mqmapi.h\
	${BUILD_DIR}/include/scatype.h\
	mqmmsg.h\
        mqm.h

mqserver.o:\
	mqmapi.h\
	${BUILD_DIR}/include/scatype.h\
	mqmmsg.h\
        mqm.h

mqmutils.o:\
	${BUILD_DIR}/include/scatype.h\
        mqmmsg.h\
        mqm.h

# DO NOT DELETE THIS LINE
