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
PROCESS=./shlib.o

# Define your C objects list
OBJECTS=\
	shlib.o

CFLAGS = -c -fpic -std=c89 ${DEBUG}
#CFLAGS = -c  -nomember_alignment ${DEBUG}
include ./rules.mk
 
#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------
#DEBUG = -DDEBUG -g

shlib.o:\
	shlib.c\
	types.h


# rm utils.o since utils.c is shared by mtm and api

# DO NOT DELETE THIS LINE
