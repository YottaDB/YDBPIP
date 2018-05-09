PROCESS=alertsversion

# Define your C objects list
OBJECTS=\
	version.o

${PROCESS}:
	cc -o ${PROCESS} version.c -L. alerts.sl

# DO NOT DELETE THIS LINE
