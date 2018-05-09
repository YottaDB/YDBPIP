
#------------------------------------------------------------------------
# Define the flags to the compiler.  
#------------------------------------------------------------------------
CFLAGS = -g -Aa -c ${DEBUG} -D_HPUX_SOURCE ${INCLUDES}

#
# The rule makes a library and puts it in ${LIBRARY)
#
${LIBRARY}:	${OBJECTS} 
			rm -f ${LIBRARY}
			echo create ${LIBRARY} 
			${AR} r ${LIBRARY} $(OBJECTS)

