#	
#	File that contains contains the make rules
#	for Sanchez Computer Associates
#
#SCA Includes
SCA_INCL =	${LIBDIR}

#SCA Libraries
SCA_LIB =	${LIBDIR}/lib

#Tools directory
TOOLS =		${LIBDIR}/tools

#Build Tools directory
BUILD_TOOLS =	${LIBDIR}/build

#SCA Code and Unit Test
SCA_CUT =	${LIBDIR}
SCA_CUT_LIB =	${LIBDIR}
SCA_CUT_INC =	${LIBDIR}

#Profile build directory
SCA_REL_DIR = 	${LIBDIR}
SCA_INC = 	${LIBDIR}
SCA_LIB =	${LIBDIR}

#MTM build directory
MTM_LIB = 	${LIBDIR}

# get SCA environment setup
#CC = /usr/local/bin/gcc
CC = /usr/bin/gcc
#CC = /usr/bin/cc
MAKE = /usr/bin/make
AR = /bin/ar
#LD = /usr/local/bin/gcc
LD = /usr/bin/gcc
#LD = /usr/bin/ld

INCLUDES = -I. ${LIBDIR}

LIBS = /lib/libc.a 

# make a .o from a .c 
.SUFFIXES: .o .c .m
.c.o:
	${CC} ${INCLUDES} ${CFLAGS} ${DEBUG} $<

.m.o:
	/usr/local/bin/dcm $< $*.o ${LIBDIR}

