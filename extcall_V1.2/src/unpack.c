/*
*	unpack.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Ray Kane - 16 September 1992
*
*	UNIX:	Sara G. Walters - 22 Feburary 1995
*
*	DESC:	$ZCall from MUMPS to unpack packed data with sign in the very 
*			last byte.
*
*			S NUM=$ZC("UNPACK",STRING,LENGTH,STRING)
*
* 			Where:	STRING is packed string
*					LENGTH is number of digits in number, excluding sign,
*					should not exceed 15 digits
*					STRING is unpacked string
*	 		returns unpacked number
*
*			Note:	Format of packed data for this translation is:
*
*				NN NN NS
*
*				N = some number from 0-9
*				S = Sign	(A/C/E/F = Positive) (anything else = Negative)
*
*				Key			Hex			Decimal
* 				======		========	=========
*
*				"ctl-R4Z"	12 34 5A	=	12345
*				"ABC"		31 32 33	=	-31323
*				"ctl-YbJ"	19 08 4A	=	19084
*				"J"	 4A	 =	4
*				"AJ"	41 4A	 =	414	 				
*
*   $Id$
*   $Log:	unpack.c,v $
 * Revision 1.1  95/07/24  11:26:12  11:26:12  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:01:52  15:01:52  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <extcall.h>

void unpack(int count,
			STR_DESCRIPTOR *src,
			SLONG length,
			STR_DESCRIPTOR *dst)
{
	int		  		i = 0;
	int		  		x = 0;
	int		  		left_nibble = 1;
	char         	buf[10];
	char         	result[256];
	char         	*indx = result;
	unsigned char 	ch;
	
	memset(result, 0, sizeof(result));

	/*  Default Negative.    */
	result[0] = '-';                       
	++indx;

	ch = src->str[i];

	if((ch>>4) == 0)                    /*	Check for insignificant digit */
		left_nibble = !left_nibble;     /*	if found disregard. */

	for (x=0; x<=length; ++x) {
		ch = src->str[i];				/* Get byte */

		if (left_nibble) 
			ch = ch>>4;		  			/* Shift to rightmost 4 bits */
		else 
			ch = ch&15;					/* or mask leftmost 4 */

		left_nibble = !left_nibble;		/* Switch nibble to work */
		if (left_nibble) 
	 		++i; 	 					/* Increment byte pointer */

		if (x<length)
		{
			sprintf(buf, "%d", (int) ch);
	 		*indx = buf[0];
	 		++indx;
		}
		else
		{   							/*  Check for positive number.  */
			if (ch==0x0a || ch==0x0c || ch==0x0e || ch==0x0f)
				indx=result+1;          /*  Point to beginning of number. */
	  		else
				indx=result;            /*  Point to beginning of string. */
	 	}
	}

	strcpy (dst->str,  indx);
	dst->length=strlen(dst->str);

	return;
}

