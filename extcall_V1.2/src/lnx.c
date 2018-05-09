/*
*	lnx.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Ray Kane	- 18 August 1991
*
*	UNIX:	Sara G. Walters - 22 Feburary 1995
*
*	DESC:	This routine calls the "C" routine lnx, which returns the	
*			Natural Logrithmic value of the Value Passed in by the		
*			Mumps program.							
*
*   $Id$
*   $Log:	lnx.c,v $
 * Revision 1.1  95/07/24  11:25:47  11:25:47  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:01:49  15:01:49  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "extcall.h"

void
lnx(	int count,
		STR_DESCRIPTOR *in_data,
		SLONG length,
		STR_DESCRIPTOR *out_data)
{
	double 	i,j;

	in_data->str[length]='\0';	
	i = atof(in_data->str);
	j = log(i);
	(void)sprintf(out_data->str,"%.15f",j);
	out_data->length = strlen(out_data->str);
}


