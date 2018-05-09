/*   hexdmp
*
*   Description:
*   Dump content of address (in hex) to screen.
*
*/

#include <stdio.h>
#define dump_max 16

void clear(char *);
void hprint(char *);
void vprint(char *);
void hexdmp(char *, int);

void hexdmp(char *ptr, int length)

{
 char hex[dump_max];
 char ch;
 int count;

 printf("base address: %x     length: %d\n",ptr,length);

 clear(hex);
 
 count=0;

 while (length>0)
   {
     ch=*ptr++;
     hex[count]=ch;
     length--;
     count++;
     if (count==dump_max)
       {
	 hprint(hex);
	 vprint(hex);
	 count=0;
	 clear(hex);
       }
   };
 if (count)
   {
     hprint(hex);
     vprint(hex);
   }
}

void hprint(char *ptr)
{
 int count;

 for (count=0;count<dump_max;count++)
   {
       printf("%02x ",(0xFF & ptr[count]));
   }
 printf("----- ");
}

void vprint(char *ptr)
{
 int count;

 for (count=0;count<dump_max;count++)
   {
     if ((ptr[count]>31) && (ptr[count]<127))
       printf("%c",ptr[count]);
     else
       printf("^");
   }
 printf("\n");
}

void clear(char *str)

{
 int count=0;

 for (count=0;count<dump_max;count++)
   {
     str[count]='\0';
   }
} 



