PROCESS=alertsversion

# Define your C objects list
OBJECTS=\
	version.o

${PROCESS}:
	cc -std=c89 -o ${PROCESS} version.c -L. alerts.sl

# DO NOT DELETE THIS LINE
