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
	../shlib/shlib.o

include ./rules.mk
include ./slibrule.mk

all: ${OBJECTS} ${SHARED_LIBRARY}

clean:
	rm -f *.o *.sl extcallversion

#------------------------------------------------------------------------
# Define the command-line options to the compiler.  The options we use
# have the following meanings:
#------------------------------------------------------------------------
#DEBUG = -DDEBUG

lnx.o:\
	extcall.h\
	scatype.h

logsca.o:\
	extcall.h\
	scatype.h

xor.o:\
	extcall.h\
	scatype.h

rtb.o:\
	extcall.h\
	scatype.h

rtbar.o:\
	extcall.h\
	scatype.h

unpack.o:\
	extcall.h\
	scatype.h

unpack2.o:\
	extcall.h\
	scatype.h

ebc2asc.o:\
	extcall.h\
	scatype.h

atmutils.o:\
        extcall.h\
        scatype.h
 
elfhash.o:\
	extcall.h\
	scatype.h

expsca.o:\
	extcall.h\
	scatype.h

readport.o:\
	extcall.h\
	scatype.h

sysutils.o:\
	extcall.h\
	scatype.h

devutils.o:\
	extcall.h\
	scatype.h

pidutils.o:\
	extcall.h\
	scatype.h

utils.o:\
	extcall.h\
	scatype.h

remote.o:\
	extcall.h\
	scatype.h

string.o:\
	extcall.h\
	scatype.h

scamd5.o:\
	scamd5.h\
	md5.h\
	scatype.h
 
md5c.o:\
	md5.h\
	scatype.h
 
# DO NOT DELETE THIS LINE
