#------------------------------------------------------------------------
# Define the flags to the compiler.  
#------------------------------------------------------------------------
CFLAGS = -c -g -std=c89 -D_GNU_SOURCE -fpic ${DEBUG}

#
# The rule makes an absolute executable
# and puts it in ${PACKAGE_NAME)
#
${PROCESS}:	${OBJECTS}
		rm -f ${PROCESS}
		${CC} ${OBJECTS} -o ${PROCESS} -lm
		chmod 775 ${PROCESS}

