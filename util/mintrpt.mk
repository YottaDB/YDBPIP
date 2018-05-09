#
#	Copyright (C) 2005 - Fidelity Information Services
#
#	$Id$
#	$Log:	Makefile,v $
#
#	$Revision: 1.0 $
#

PROCESS=mintrpt

# Define your C objects list

OBJECTS=\
	./mintrpt.o

${PROCESS}:
	gcc -o ${PROCESS} mintrpt.c

# DO NOT DELETE THIS LINE
