/*
*	rtb.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Ray Kane - 17 August 1992
*
*	UNIX:	Sara G. Walters - 21 Feburary 1995
*
*	DESC:	This function will remove all trailing spaces from a string.	
*
*   $Id$
*   $Log:	rtb.c,v $
 * Revision 1.1  95/07/24  11:26:02  11:26:02  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:01:51  15:01:51  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "extcall.h"

#define SPACE ' '

void
rtb(int count,STR_DESCRIPTOR *src,STR_DESCRIPTOR *dst, SLONG *rc)
{
	char *ptr = (char *)NULL;
	long data_length = 0;

	/* ptr = src->str;
	if((ptr == (char *)NULL) 
		|| (src->length <= 0) 
		|| (dst->str == (char *)NULL) 
		|| (dst->length <= 0))
	{
		*rc = MUMPS_FAILURE;
		return;
	} */

    /*  find the length of the string Minus the trailing Bars.      */

     for(data_length = src->length;
		(data_length>0) && (src->str[data_length-1]==SPACE);
								 --data_length)
	;

    /*  Create a string to be passed back to the calling mumps 
	*	program that does not have the trailing bars.			             
	*/

    if(data_length>0)   /* Check if there is a string to be passed back.    */
    {
         memcpy((char *) dst->str,(char *) src->str, data_length); 
         dst->length = data_length;
    }
    else                /* if Null String was passed or only spaces.  */
    {
         memset((char *) dst->str, 0, src->length);
         dst->length = 0;
    }

	return;
}


