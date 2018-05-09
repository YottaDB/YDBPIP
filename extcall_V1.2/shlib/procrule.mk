#------------------------------------------------------------------------
# Define the flags to the compiler.  
#------------------------------------------------------------------------
#CFLAGS = -Aa -c -D_HPUX_SOURCE ${DEBUG} ${INCLUDES}
CFLAGS = -c ${DEBUG} ${INCLUDES}

#
# The rule makes an absolute executable
# and puts it in ${PACKAGE_NAME)
#
${PROCESS}:	${OBJECTS} ${LIBS}
			rm -f ${PROCESS}
			${CC} ${OBJECTS} ${LIBS} -o ${PROCESS}
			chmod 775 ${PROCESS}
			chgrp sca ${PROCESS}
