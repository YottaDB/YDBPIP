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
SHARED_LIBRARY=mtmapi.sl

all:	${SHARED_LIBRARY} utilclean

# Define your C objects list
OBJECTS=\
	client.o\
	server.o\
	mtm.o\
	utils.o\
	sca_wrapper.o\
	socket_utils.o\
	alarm_utils.o\
	msg_utils.o

include ./rules.mk
include ./slibrule.mk

#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------
#DEBUG = -DDEBUG -g

client.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

server.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

mtm.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

utils.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

sca_wrapper.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

socket_utils.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

alarm_utils.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

msg_utils.o:\
	mtmapi.h\
	scatype.h\
	mtm.h

# rm utils.o since utils.c is shared by mtm and api
utilclean:
#	rm -f utils.o
# DO NOT DELETE THIS LINE
