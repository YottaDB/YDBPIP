/*
*	unpack2.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Dan S. Russell	- 15 October 1991
*
*	UNIX:	Sara G. Walters - 14 Feburary 1995
*
*	DESC:	$ZCall from MUMPS to unpack packed data with leading sign and
*			which may begin or end in either nibble
*		
*			S NUM=$ZC("UNPACK2",STRING,LENGTH,SIGND,LEFT_NIBBLE)
*		
*			Where:	STRING is packed string
*					LENGTH is number of digits in number, excluding sign,
*					should not exceed 15 digits
*					SIGND = 1 if signed, 0 if not
*					returns unpacked number
*		
*			Note:	Uses double floating point for result, so length of
*					 unpacked number cannot exceed 15
*		
*			Note:	B and D are considered negative signs
*					Anything else is considered positive
*		
*			Note:	Format of packed data for this translation is:
*		
*						C1 23 45	=	 12345
*						C 12 34	=	 1234
*						D1 23 45	=	-12345
*						12 34 56	=	 123456 (not signed)	
*
*   $Id$
*   $Log:	unpack2.c,v $
 * Revision 1.1  95/07/24  11:26:16  11:26:16  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:01:53  15:01:53  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <extcall.h>

void unpack2(	int count,
				STR_DESCRIPTOR *src,
				SLONG length,
				SLONG signd,
				SLONG left_nibble,
				STR_DESCRIPTOR *ret_data)
{
	int		  i	= 0;
	int		  location	= 0;
	int		  signmult = 1;
	double	  result	= 0;
	unsigned char  ch;

#ifdef DEBUG
printf("src->str %s\n",src->str);
sca_fflush(stdout);
#endif

	result = 0;

	for (;;) {
		ch = src->str[i];					/* Get byte */

		if (left_nibble) ch = ch>>4;		/* Shift to rightmost 4 bits */
			else ch = ch&15;				/* or mask leftmost 4 */

		left_nibble = !left_nibble;			/* Switch nibble to work */
		if (left_nibble) ++i;				/* Increment byte pointer */

		if (signd) {						/* Get sign, if signd */
			if (ch == 11 || ch == 13) {		/* B or D => negative */
			signmult = -1;
			++location;
		}
			signd = 0;						/* Turn off sign flag */
			continue;						/* Go get next nibble */
		}

		result = result * 10 + ch;
		++location;

		--length;							/* Decrement length */
		if (!length) break;					/* If done, stop */

	}

	result = result * signmult;

#ifdef DEBUG
printf("result %.14f\n",result);
sca_fflush(stdout);
printf("ret_data->length %d\n",ret_data->length);
sca_fflush(stdout);
#endif

	(void)sprintf(ret_data->str,"%.14f",result);

#ifdef DEBUG
printf("ret_data->str %s\n",ret_data->str);
sca_fflush(stdout);
#endif

	ret_data->length = strlen(ret_data->str);

	return;
}
