PROCESS=extcallversion

# Define your C objects list
OBJECTS=\
	version.o

${PROCESS}:
	gcc -o ${PROCESS} version.c -L. -lextcall

# DO NOT DELETE THIS LINE
