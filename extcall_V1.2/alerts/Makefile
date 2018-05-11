#
#	Copyright (C) 1999 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	Makefile,v $
#
#
#
#
SHARED_LIBRARY=alerts.sl

# Define your C objects list
OBJECTS=\
	alerts.o\
	../shlib/shlib.o

include ./rules.mk
include ./slibrule.mk

all: ${OBJECTS} ${SHARED_LIBRARY}

clean:
	rm -f *.o *.sl alertsversion

#------------------------------------------------------------------------
# Define the command-line options to the compiler.  The options we use
# have the following meanings:
#------------------------------------------------------------------------
#DEBUG = -DDEBUG
