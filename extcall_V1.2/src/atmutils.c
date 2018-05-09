/*
*       atmutils.c
*
*       Copyright(c)2004 Sanchez Computer Associates, Inc.
*       All Rights Reserved
*
*       UNIX:   Manoj Thoniyil 10 August 2004
*
*       DESC:   External Call from MUMPS to translate between HEX and DEC
*
* $Id: $
*
* $Log: atmutils.c,v $
*
*
*/
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "extcall.h"

int getdecvalue(char);
char gethexvalue(int);

/*
 * Name : dec2hex
 * Description:
 *	This function is called from M to convert an ASCII string
 *	to hexadecimal string.
 * Parameters:
 *	ASCII Input String
 *	Hexadecimal Output String
 *	Result (1 = SUCCESS 	0 = FAILURE) 
 */
void
dec2hex(int count,STR_DESCRIPTOR *str_d,STR_DESCRIPTOR *str_d2, SLONG *rc)
{
        int i,strcount=0,val=0,val0=0,val1=0;
        char *str = (char *)NULL;
        char *ptr = (char *)NULL;
 
        if((str_d->str == (char *)NULL) || (str_d->length <= 0))
        {
                /*
                *       if Null String was passed
                */
                str_d->length=0;
                *rc = MUMPS_FAILURE;
                return;
        }
 
        if((str = (char *)malloc((str_d->length*2)+1)) == (char *)NULL)
        {
                *rc = MUMPS_FAILURE;
                return;
        }
        (void)memset(str,'\0',str_d->length);
        ptr = str;
 
        for(i=0;i<str_d->length;i++)
        {
                val = (int)str_d->str[i];

		/* For values above 128, int returns a negative value */
                if (val < 0) val=val+256; 

                val0 = val/16;
                val1 = val%16;
                *ptr++ = gethexvalue(val0);
                *ptr++ = gethexvalue(val1);

                strcount+=2;
        }
 
        (void)memcpy(str_d2->str,str,strcount);
        str_d2->length = strcount;

        (void)free(str);
 
        *rc = MUMPS_SUCCESS;
        return;
}
  
/*
 * Name : hex2dec
 * Description:
 *	This function is called from M to convert a hexadecimal string
 *	to ASCII string.
 * Parameters:
 *	Hexadecimal Input String
 *	ASCII Output String
 *	Result (1 = SUCCESS 	0 = FAILURE) 
 */
void
hex2dec(int count,STR_DESCRIPTOR *str_d,STR_DESCRIPTOR *str_d2, SLONG *rc)
{
        int i,decval,decval1,decval2,strcount=0;
        char *str = (char *)NULL;
        char *ptr = (char *)NULL;
 
        if((str_d->str == (char *)NULL) || (str_d->length <= 0))
        {
                /*
                *       if Null String was passed
                */
                str_d->length=0;
                *rc = MUMPS_FAILURE;
                return;
        }
 
        if((str = (char *)malloc(str_d->length)) == (char *)NULL)
        {
                *rc = MUMPS_FAILURE;
                return;
        }
        (void)memset(str,'\0',str_d->length);
        ptr = str;
 
        for(i=0;i<str_d->length;i++)
        {
                decval1 = getdecvalue(str_d->str[i]);
                decval2 = getdecvalue(str_d->str[++i]);
                decval  = decval1*16+decval2;
                *ptr++ = decval;
                strcount++;
        }
 
        (void)memcpy(str_d2->str,str,strcount);
        str_d2->length = strcount;
 
        (void)free(str);
 
        *rc = MUMPS_SUCCESS;
        return;
}
  
/*
 * Name : getdecvalue
 * Description:
 *	This function is called from hex2dec to get the decimal value
 *	for a given hexadecimal value
 * Parameters:
 *	Hexadecimal Value
 * Return:
 *	Decimal value
 */
int getdecvalue(char c)
{
        switch (c)
        {
                case '0':
                        return 0;
                        break;
                case '1':
                        return 1;
                        break;
                case '2':
                        return 2;
                        break;
                case '3':
                        return 3;
                        break;
                case '4':
                        return 4;
                        break;
                case '5':
                        return 5;
                        break;
                case '6':
                        return 6;
                        break;
                case '7':
                        return 7;
                        break;
                case '8':
                        return 8;
                        break;
                case '9':
                        return 9;
                        break;
                case 'A':
                        return 10;
                        break;
                case 'B':
                        return 11;
                        break;
                case 'C':
                        return 12;
                        break;
                case 'D':
                        return 13;
                        break;
                case 'E':
                        return 14;
                        break;
                case 'F':
                        return 15;
                        break;
        }
}

/*
 * Name : gethexvalue
 * Description:
 *	This function is called from dec2hex to get the hexadecimal value
 *	for a given decimal value
 * Parameters:
 *	Decimal Value
 * Return:
 *	Hexadecimal value
 */
char gethexvalue(int i)
{
        switch (i)
        {
                case 0:
                        return '0';
                        break;
                case 1:
                        return '1';
                        break;
                case 2:
                        return '2';
                        break;
                case 3:
                        return '3';
                        break;
                case 4:
                        return '4';
                        break;
                case 5:
                        return '5';
                        break;
                case 6:
                        return '6';
                        break;
                case 7:
                        return '7';
                        break;
                case 8:
                        return '8';
                        break;
                case 9:
                        return '9';
                        break;
                case 10:
                        return 'A';
                        break;
                case 11:
                        return 'B';
                        break;
                case 12:
                        return 'C';
                        break;
                case 13:
                        return 'D';
                        break;
                case 14:
                        return 'E';
                        break;
                case 15:
                        return 'F';
                        break;
        }
}
  
 
