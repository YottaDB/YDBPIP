/*
*       elfhash.c
*
*       Copyright(c)1998 Sanchez Computer Associates, Inc.
*       All Rights Reserved
*
*       ORIG:   Dan S. Russell		 - 16 November 1997
*
*       UNIX:   Harsha Lakshmikantha 	 - 26 May 1998
*
*       DESC:   This function will return the hash value for string.
*
*   $Id$
*   $Log:       elfhash.c,v $
*
*/


#include <stdio.h>
#include <string.h>
#include <extcall.h>

void elfhash(int count,STR_DESCRIPTOR *src,STR_DESCRIPTOR *dst, SLONG *rc)

{
   unsigned long	h = 0;
   unsigned long	g,i;
   char			buffer[10];

   char *ptr = (char *)NULL;

   ptr = src->str;
   if((ptr == (char *)NULL)
           || (src->length <= 0)
           || (dst->str == (char *)NULL)
           || (dst->length <= 0))
   {
       /*
        *       if Null String was passed
        */
       *rc = MUMPS_FAILURE;
       return;
   } 

   for (i=0; i < src->length; i++) {
	h = (h << 4) + src->str[i];
	if (g = h & 0xF0000000) h ^= g >> 24;
	h &= ~g;
   }

   sprintf(buffer,"%u",h);
   dst->length = strlen(buffer);
   memcpy((char *) dst->str, buffer, strlen(buffer));

   *rc = MUMPS_SUCCESS;
   return;
}
