#------------------------------------------------------------------------
# Define the flags to the compiler.  
#------------------------------------------------------------------------
#
# The rule makes a shared library and puts it in ${SHARED_LIBRARY)

#${LD} -o ${SHARED_LIBRARY} $(OBJECTS) -bE:./libsql.exp -H512 -T512 -bM:SRE -lc -bh:4 -lm -eProfileConnect
#${LD} -o ${SHARED_LIBRARY}  ${OBJECTS} ${LFLAGS}
${SHARED_LIBRARY}:	${OBJECTS} 
					rm -f ${SHARED_LIBRARY}
					echo create ${SHARED_LIBRARY} 
	${LD} -o ${SHARED_LIBRARY}  ${OBJECTS} ${LFLAGS}

