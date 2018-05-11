PROCESS=extcallversion

# Define your C objects list
OBJECTS=\
	version.o

${PROCESS}:
	gcc -std=c89 -o ${PROCESS} version.c -L. -l:extcall.sl

# DO NOT DELETE THIS LINE
