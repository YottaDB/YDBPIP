/*
*	logsca.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 22 Feburary 1995
*
*	DESC:	This routine calls the "C" routine log10, which returns the
*			Base 10 Logarithmic value of the Value Passed in by a
*			Mumps program.						
*
*   $Id$
*   $Log:	logsca.c,v $
 * Revision 1.1  95/07/24  11:25:51  11:25:51  rcs ()
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
#include <math.h>
#include <extcall.h>

void
logsca(	int count,
		STR_DESCRIPTOR *in_data,
		SLONG length,
		STR_DESCRIPTOR *out_data)
{
	double 	i,j;

	in_data->str[length]='\0';	
	i = atof(in_data->str);
	j = log10(i);
	(void)sprintf(out_data->str,"%.15f",j);
	out_data->length = strlen(out_data->str);
}


