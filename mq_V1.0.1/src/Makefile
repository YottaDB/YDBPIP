#
#	Copyright (C) 1999 - Sanchez Computer Associates
#
#	$Id$
#	$Log:	Makefile,v $
# makefile for both APIs and MQSeries.
# 
#	$Revision: 1.5 $
#
#
#
#
#
#
#

all:	clean api version

clean:
	rm -f *.o
	rm -f mqapi_version

api:
	make -f api.mk
	cp libmqmapi.sl mqmapi.sl

version:
	make -f version.mk

sample:
	rm -f test
	make -f sample.mk

sample_srv:
	rm -f test_srv
	make -f sample_srv.mk

# DO NOT DELETE THIS LINE
