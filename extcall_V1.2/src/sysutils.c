/*
*	sysutils.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 28 April 1995
*
*	DESC:	This routine performs the associated UNIX service calls
*			to provide the functionality as provided by the GT.M
*			call $ZGETSYI.
*
*   $Id$
*   $Log:	sysutils.c,v $
 * Revision 1.1  95/07/24  11:26:08  11:26:08  rcs ()
 * Initial revision
 * 
 * Revision 1.1  95/05/22  15:01:45  15:01:45  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <errno.h>
#include <extcall.h>

void
getnodename(int count,STR_DESCRIPTOR *response)
{
	RETURNSTATUS rc = SUCCESS;

	if((rc = gethostname(response->str, response->length)) != SUCCESS)
	{
		(void)strcpy(response->str,DINO);
	}

	response->length=strlen(response->str);

	return;
}


