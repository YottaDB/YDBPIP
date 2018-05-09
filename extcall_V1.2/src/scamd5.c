/*******************************************************************************
*	File		:	scamd5.c
*	Author		:	Lian Chen
*	Created		:	September 21, 1998
*	Modified	:	12/24/98 - Use descriptor struct as arguments
*	Purpose		:	Provide one way hash function utility for 
*				password encryption.
*	Revision	:	03/09/98 - Use STR_DESCRIPTOR instead of DSCR
*				for string structure. (Hien Ly)
*******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "scatype.h"
#include "scamd5.h"

/*
	Function:	ProfileENC
	Purpose:	This API uses MD5 one way hash function to encrypt 
			input message and to generate a fixed-length output,
			which is a 32-byte string.
	Output:		Overwrite output buffer with encrypted message
			Overwrite outlen with the length of encrypted password
			And return the length of the encrypted message, if no 
			error
*/

void ProfileENC(int count,
		STR_DESCRIPTOR *msg,
		STR_DESCRIPTOR *digest,
		SLONG          *outlen,
		STR_DESCRIPTOR *opt,
		SLONG *rc)
{
	MD5_CTX		context;
	unsigned char	tmp[17] = "";
	unsigned int	i = 0, j = 0;

	/* Make sure that output buffer has enough buffer */

	if (*outlen == 0) {
		*rc = 33;
	    return;
	}

	MD5Init(&context);

	MD5Update(&context, (unsigned char *)msg->str,msg->length); 

	MD5Final(tmp, &context);

	/* Make sure the tmp is a null terminated string */
	tmp[16] = (unsigned char)0x0;

	/* Convert to twice long printable string and store in output buffer */
	for (; i<16; i++)
	{
		/* Print out in hex mode and at least two characters */
		j += sprintf(digest->str + j, "%02x", tmp[i]);
	}
	sprintf(digest->str + j, "\0");

	/* output descriptor */
	digest->length = strlen (digest->str);
	*outlen = j;
	
	*rc = j;
	return;
}
