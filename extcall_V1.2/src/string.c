/*	string.c: String functions
*
*	Copyright(c)1995 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
* 	ORIG: Fan Zeng - 03/20/96
*
*	DESC:
*
*	SQL returns a bit map value for column attributes, relating to data
*	item protection.  Every column will be represented for each row that
*	that is returned in the SQL request. Two of the functions translate
*	between the bit map and LV strings, based on the specification
*	in the PROFILE Enterprise Server document.
*
*	Function rm_trailing_char removes trailing occurrences of specified 
*	character
*	Function rm_leading_char removes leading occurrences of specified 
*	character
*/

#include <string.h>
#include <errno.h>
#include <scatype.h>

#define	MAX_BYTE		256
#define MAX_MSG_HEADER		5

/*
 * For DEC/VMS version, mememory for output string is allocated before
 * the function is called. For Unix version, no memory is allocated,
 * a static char array is defined to stored the outputs.
 */
#ifndef VMS
static char 	out_buf[MAX_MSG_SIZE+MAX_MSG_HEADER];
#endif	/* VMS */

static char	*table_delimiter = "\r\n";
static void	parse_header (char *, int *, int *size);
static void	format_header(long, STR_DESCRIPTOR *);

/*
 * fromat_header - Format a LV length header for a given length
 */
static void
format_header (long length, STR_DESCRIPTOR *header)
{
	static char	buf[MAX_MSG_HEADER+1];

	header->str = buf;

	if (length < MAX_BYTE - 1)
	{
		header->str[0] = length + 1;
		header->length = 1;
	}
	else
	{
		header->str[0] = 0;
		header->str[1] = 2;
		header->str[2] = (unsigned char) ((length + 2) / MAX_BYTE);
		header->str[3] = (unsigned char) ((length + 2) % MAX_BYTE);
		header->length = 4;
	}
}

/*
 * sql_bitmap_to_lv - Convert a column attribute bitmap to a LV format string
 * 
 * This function can be called in MUMPS via $$colout^%ZFUNC.
 */
void 
sql_bitmap_to_lv (
#ifndef	VMS
		int		count,
#endif	/* VMS */
		STR_DESCRIPTOR	*in,
		STR_DESCRIPTOR	*out)
{
	char	*current;
	char	*next;
	int	i;
	char	column_buf[MAX_MSG_SIZE+1];
	char	in_buf[MAX_MSG_SIZE+1];
	STR_DESCRIPTOR	header;
	STR_DESCRIPTOR	column;

#ifndef	VMS
	out->str = out_buf;
#endif	/* VMS */

	out->length = 0;

	if (in->length == 0)
	{
		out->length = 1;
		out->str[0] = 1;
		return;
	}

	next = current = in_buf;
	strncpy (current, in->str, in->length);
	current[in->length] = '\0';

	/*
	 * Terminate the input with delimiter <CR><LN>
	 */
	strcat (current, table_delimiter);

	column.str = column_buf;

	while ((next = strstr (next, table_delimiter)) != NULL)
	{
		*next = '\0';
		next += 2;

		column.length = 0;
		for (i = 0; i < strlen (current); i++)
			if (current[i] != '0')
			{
				column.str[column.length] =
					(unsigned char)(i + 1) / 256;
				column.str[column.length+1] =
					(unsigned char)(i + 1) % 256;
				column.str[column.length+2] = current[i] - '0';
				column.length += 3;
			}

		format_header (column.length, &header);
		memcpy (out->str + out->length + MAX_MSG_HEADER,
			header.str, header.length);
		out->length += header.length;
  		memcpy (out->str + out->length + MAX_MSG_HEADER,
			column.str, column.length);
		out->length += column.length;

		current = next;
	}

	format_header (out->length, &header);
	memcpy (out->str + MAX_MSG_HEADER - header.length,
		header.str, header.length);
	out->length += header.length;

	memmove (out->str, out->str + MAX_MSG_HEADER - header.length,
		out->length);

}

/*
 * parse_header - parse the header field of a LV message
 */
static void
parse_header (char *str, int *field_len, int *header_size)
{
	if (*str != 0)
	{
		*field_len = (unsigned char) str[0] - 1;
		*header_size = 1;
	}
	else
	{
		*header_size = 4;
		*field_len = (unsigned char) str[2] * 256 +
				(unsigned char) str[3] - 2;
	}
}

/*
 * sql_lv_to_bitmap - Convert a LV string to a column attribute bitmap
 * 
 * This function can be called in MUMPS via $$colin^%ZFUNC.
 */
void
sql_lv_to_bitmap (
#ifndef	VMS
		int		count,
#endif	/* VMS */
		STR_DESCRIPTOR	*in,
		STR_DESCRIPTOR	*out)
{
	char	*current;
	int	field_length;
	int	header_size;
	int	in_length;

	int	pos;
	int	last_pos;

	int 	i, j;

#ifndef	VMS
	out->str = out_buf;
#endif	/* VMS */

	if (in->length == 1)
	{
		out->length = 0;
		return;
	}

	current = in->str;
	in_length = in->length;

	/*
	 *	remove the first length header
	 */
	parse_header (current, &field_length, &header_size);
	current += header_size;
	in_length -= header_size;

	out->length = 0;
	while (in_length > 0)
	{
		parse_header (current, &field_length, &header_size);
		current += header_size;
		in_length -= header_size + field_length;

		last_pos = 0;
		for (i = 0; i < field_length; i += 3)
		{
			pos = (unsigned char) current[0] * 256 +
					(unsigned char) current[1];

			for (	j = out->length + last_pos;
				j < out->length + pos - 1; j++)
				out->str[j] = '0';
			out->str[j] = '0' + current[2];

			last_pos = pos;
			current += 3;
		}
		out->length += last_pos;
		out->str[out->length] = '\r';
		out->str[out->length + 1] = '\n';
		out->length += 2;
	}

	/*
	 * remove the last pair of <CR><LN>
	 */
	out->length -= 2;
}

/*		
 * rm_leading_char - Remove leading characters.
 *
 * Description
 *	This function removes leading occurrences of the character specified
 *	from a string. 
 * 
 *	This function can be called in MUMPS via $$RLCHR^%ZFUNC.
 *
 * Parameters
 *	source	Specifies the source string from which the leading occurrences
 *		of character ch will be removed. The string may contain null
 *		characters.
 *	
 *	lead	Specifies the character to be removed.
 *
 *	dest	Specifies the destination string.
 */

void
rm_leading_char (
#ifndef	VMS
		int		count,
#endif	/* VMS */
	STR_DESCRIPTOR		*source,
	STR_DESCRIPTOR		*lead,
	STR_DESCRIPTOR		*dest)
{
	int	length;
	int	i=0;
	char	ch;
	char	*ptr;

#ifndef	VMS
	dest->str = out_buf;
#endif	/* VMS */

	/*
	 * if no character specified in lead, assign source to dest without
	 * change; otherwise use the first character in trail.
	 */
	if (lead->length == 0) {
		memcpy ((void *) dest->str, 
			(const void *) source->str,
			source->length);
		dest->length = source->length;
		return;
	}
	else	
		ch = lead->str [0];

	/* 
	 * find the beginning of the sub-string without the leading ch's
	 */
	length = source->length;
	ptr = source->str;
	while (length > 0) {
		if (source->str [i] != ch)
			break;
		else {
			i++;
			ptr++;
			length--;
		}
	}

	memcpy ((void *) dest->str, 
		(const void *) ptr, length);
	dest->length = length;

	return;
}

/*		
 * rm_trailing_char - Remove trailing characters.
 *
 * Description
 *	This function removes trailing occurrences of the character specified
 *	from a string. It is a generalized form of two existing functions,
 *	RTBAR (Remove trailing bars) and RTB (Remove trailing blanks). 
 * 
 *	This function can be called in MUMPS via $$RTCHR^%ZFUNC.
 *
 * Parameters
 *	source	Specifies the source string from which the trailing occurrences
 *		of character ch will be removed. The string may contain null
 *		characters.
 *	
 *	trail	Specifies the character to be removed.
 *
 *	dest	Specifies the destination string.
 */

void
rm_trailing_char (
#ifndef	VMS
		int		count,
#endif	/* VMS */
	STR_DESCRIPTOR		*source,
	STR_DESCRIPTOR		*trail,
	STR_DESCRIPTOR		*dest)
{
	int	length;
	char	ch;

#ifndef	VMS
	dest->str = out_buf;
#endif	/* VMS */

	/*
	 * if no character specified in trail, assign source to dest without
	 * change; otherwise use the first character in trail.
	 */
	if (trail->length == 0) {
		memcpy ((void *) dest->str, 
			(const void *) source->str,
			source->length);
		dest->length = source->length;
		return;
	}
	else	
		ch = trail->str [0];

	/* 
	 * find the length of the sub-string without the trailing ch's
	 */
	length = source->length;
	while (length > 0)
		if (source->str [length - 1] != ch)
			break;
		else
			length--;

	memcpy ((void *) dest->str, 
		(const void *) source->str, length);
	dest->length = length;

	return;
}

#ifdef	DEBUG

/* these are for debuging only */
#include <stdio.h>
#define MAX_CHAR_PER_LINE 16

void hex_dmp(char *);
void chr_dmp(char *);

LV(int length, char *msg)
{
	char	hex[MAX_CHAR_PER_LINE];
	char	ch;
	int	count;

	fprintf(stdout,"LV: Message Length %d\n",length);

	memset (hex, 0, MAX_CHAR_PER_LINE);
	count = 0;

	while (length > 0) {
		ch = *msg++;
		hex[count] = ch;
		length--;
		count++;
		if (count == MAX_CHAR_PER_LINE) {
			hex_dmp(hex);
			chr_dmp(hex);
			count = 0;
			memset (hex, 0, MAX_CHAR_PER_LINE);
		}
	}
	if (count) {
		hex_dmp(hex);
		chr_dmp(hex);
	}

	sca_fflush(stdout);
}


void hex_dmp(char *msg)
{
	int	count;

	for (count = 0; count < MAX_CHAR_PER_LINE; count++)
			fprintf(stdout, "%02x ", (unsigned char) msg[count]);
	do {
		fprintf(stdout, "----- ");
	} while (errno ==EINTR);
}


void chr_dmp(char *msg)
{
	int	count;

	for (count = 0; count < MAX_CHAR_PER_LINE; count++) {
		if ((msg[count] > 31) && (msg[count] < 127))
			do {
				fprintf(stdout, "%c", msg[count]);
			} while (errno == EINTR);
		else
			do {
				fprintf(stdout, "~");
			} while (errno == EINTR);
	}
	do {
		fprintf(stdout, "\n");
	} while (errno == EINTR);
}

main(int argc, char **argv)
{
	int		i;
	STR_DESCRIPTOR	col,trail;
	char		*colatb = "00020002\r\n003009\r\n99000000000001";
	char		*trailing = "1";
	STR_DESCRIPTOR	out, orig;
 	char		*ptr;
	char		buf[MAX_MSG_SIZE];

	col.str = colatb; 
	col.length = strlen (colatb);

	sql_bitmap_to_lv (0, &col, &out);

	LV (out.length, out.str);
	memcpy(buf, out.str, out.length);
	out.str = buf;
	sql_lv_to_bitmap (0, &out, &orig);

	LV (orig.length, orig.str);

	trail.length=1;
	trail.str = trailing;
	rm_trailing_char (0, &col, &trail, &orig);
	LV (orig.length, orig.str);

}

#endif
