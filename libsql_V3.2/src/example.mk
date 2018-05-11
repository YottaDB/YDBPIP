PROCESS=./example

# Define your C objects list
OBJECTS=\
	example.o

#all:	${PROCESS} utilclean

${PROCESS}:
	gcc -std=c89 -o ${PROCESS} example.c -L./ -lsql
#------------------------------------------------------------------------
# Define the command-line options to the compiler.  
#------------------------------------------------------------------------

#example.o:\
#	   example.o


#utils.o:\
#	scatype.h\
#	mtm.h


#utilclean:
#	rm -f utils.o
# DO NOT DELETE THIS LINE
