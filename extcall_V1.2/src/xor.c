/*
*	xor.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Ray Kane - 21 September 1992
*
*	UNIX:	Sara G. Walters - 21 Feburary 1995
*
*	DESC:	Perform repeated exclusive ORs
*			on an input string.
*
*			input:	a variable length string from Mumps.
*			output:	result of XOR sin a long word.
*
*   $Id$
*   $Log:	xor.c,v $
 * Revision 1.1  95/07/24  11:26:23  11:26:23  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:01:54  15:01:54  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <extcall.h>

void
xor(int count,STR_DESCRIPTOR *src, SLONG *dst)
{
	int i=0;
	char xor_char=0;

	xor_char=0;

	if(src->length > 0)
		xor_char=*src->str;

	if(src->length > 1)
		for(i=1;i<src->length;++i)
			xor_char=xor_char ^ src->str[i];

	*dst=(long)xor_char;
}
