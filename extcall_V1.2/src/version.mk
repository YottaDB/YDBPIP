PROCESS=extcallversion

# Define your C objects list
OBJECTS=\
	version.o

${PROCESS}:
	cc -o ${PROCESS} version.c -L. extcall.sl

# DO NOT DELETE THIS LINE
