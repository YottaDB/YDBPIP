#
#	Copyright (C) 1995 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	Makefile,v $
# Revision 1.5  96/03/21  15:07:27  15:07:27  zengf (Fan Zeng)
# makefile for both APIs and mtm.
# 
#	$Revision: 1.5 $
#
#
#
#
#
#
#
all:	DEC SUN HPUX AIX version

DEC:
	make -f libsql.mk "CFLAGS= -c -g" "LFLAGS=-shared -lxnet"

SUN:
	make -f libsql.mk "CFLAGS= -c -g" "LFLAGS=-G -lxnet"

AIX:
	make -f libsql.mk "CFLAGS= -c -g" "LFLAGS=-shared"

HPUX:
	make -f libsql.mk "CFLAGS= -Aa -c +z -D_HPUX_SOURCE" "LFLAGS=-b -lm"

LINUX:
	make -f libsql.mk "CFLAGS= -c -g -std=c89 -D_GNU_SOURCE -fPIC" "LFLAGS=-shared"

version:
	make -f version.mk
clean:
	rm -f *.o *.a getversion
# DO NOT DELETE THIS LINE
