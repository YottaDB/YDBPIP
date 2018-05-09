#	Subsystem:  MTM
#
#	Copyright (C) 1995 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	mtm.mk,v $
#	Revision 1.1  96/03/21  15:06:41  15:06:41  zengf (Fan Zeng)
#	Initial revision
#	
#	$Revision: 1.1 $
#
#
#
#
#
#
#
PROCESS=./mtm

# Define your C objects list
OBJECTS=\
	mtmcntrl.o\
	mtmclnt.o\
	mtmmain.o\
	mtmserver.o\
	mtmcomm.o\
	mtmutils.o\
	utils.o\
	sca_wrapper.o\
	socket_utils.o\
	alarm_utils.o\
	msg_utils.o

all:	${PROCESS} utilclean

include ./rules.mk
include ./procrule.mk

#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------
#DEBUG = -DDEBUG -DMTM_ATTACHED -g
#DEBUG = -DDEBUG -g

mtmcntrl.o:\
	scatype.h\
	mtm.h\
	mtmerrno.h\
	mtmext.h\
	mtmmsgs.h\
	mtmprototypes.h

mtmclnt.o:\
	scatype.h\
	mtm.h\
	mtmerrno.h\
	mtmext.h\
	mtmmsgs.h\
	mtmprototypes.h

mtmmain.o:\
	scatype.h\
	mtm.h\
	mtmerrno.h\
	mtmext.h\
	mtmmsgs.h\
	mtmprototypes.h

mtmserver.o:\
	scatype.h\
	mtm.h\
	mtmerrno.h\
	mtmext.h\
	mtmmsgs.h\
	mtmprototypes.h

utils.o:\
	scatype.h\
	mtm.h

mtmcomm.o:\
	scatype.h\
	mtm.h\
	mtmerrno.h\
	mtmext.h\
	mtmmsgs.h\
	mtmprototypes.h

mtmutils.o:\
	scatype.h\
	mtm.h\
	mtmerrno.h\
	mtmext.h\
	mtmmsgs.h\
	mtmprototypes.h

sca_wrapper.o:\
	scatype.h\
	mtm.h

socket_utils.o:\
	scatype.h\
	mtm.h

alarm_utils.o:\
	scatype.h\
	mtm.h

msg_utils.o:\
	scatype.h\
	mtm.h

utilclean:
#	rm -f utils.o
# DO NOT DELETE THIS LINE
