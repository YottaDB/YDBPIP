PROCESS=getversion

# Define your C objects list
OBJECTS=\
	version.o

#all:	${PROCESS} utilclean

${PROCESS}:
	gcc -std=c89 -o ${PROCESS} version.c -L./ -lsql
#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------

#version.o:\
#	   version.o


#utils.o:\
#	${BUILD_DIR}/include/scatype.h\
#	mtm.h


utilclean:
#	rm -f utils.o
# DO NOT DELETE THIS LINE
