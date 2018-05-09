PROCESS=mqapi_version

# Define your C objects list
OBJECTS=\
	version.o

${PROCESS}:
	cc -o ${PROCESS} version.c -L. ./libmqmapi.sl

# DO NOT DELETE THIS LINE
