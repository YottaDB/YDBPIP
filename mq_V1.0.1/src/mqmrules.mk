#	
#	File that contains contains the make rules
#	for Sanchez Computer Associates
#
#SCA Includes
SCA_INCL =	${BUILD_DIR}/include

#SCA Libraries
SCA_LIB =	${BUILD_DIR}/lib

#Tools directory
TOOLS =		${BUILD_DIR}/tools

#Build Tools directory
BUILD_TOOLS =	${TOOLS}/build

#SCA Code and Unit Test
SCA_CUT =	${HOME}/wd/sca
SCA_CUT_LIB =	${SCA_CUT}/lib
SCA_CUT_INC =	${SCA_CUT}/include

#Profile build directory
SCA_REL_DIR = 	${BUILD_DIR}
SCA_INC = 	${SCA_REL_DIR}/include
SCA_LIB =	${SCA_REL_DIR}/lib

#MTM build directory
MQM_LIB = 	${BUILD_DIR}/sca_gtm/mq

# get SCA environment setup
CC = /usr/bin/cc
MAKE = /usr/bin/make
AR = /bin/ar
LD = /usr/bin/ld

INCLUDES = -I. -I${SCA_INC}

#LIBS = /lib/libc.a 
LIBS = mqm

# make a .o from a .c 
.SUFFIXES: .o .c .m
.c.o:
	${CC} ${INCLUDES} ${CFLAGS}  $<

.m.o:
	/usr/local/bin/dcm $< $*.o ${BUILD_DIR}

