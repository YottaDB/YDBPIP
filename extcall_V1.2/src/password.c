/*****************************************************************************
*  08/09/1997 - Dennis Ratmansky					     *
*  PASSWORD  - Encrypt/Decrypt an input string.   		             *
*                                                                            *
*         input:       String and direction(Encrypt/Decrypt).                *
*         output:      Encrypted/Decrypted string.                           *
*                                                                            *
*                                                                            *
/*****************************************************************************/

#include descrip
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define VOID  void
#define STRCPY  strcpy  
#define STRNCPY strncpy  
#define STRCAT  strcat
#define STRNCAT strncat
#define STRLEN  strlen
#define STRSTR  strstr
#define STRCHR  strchr
#define STRCMP  strcmp
#define STRTOK  strtok
#define STRCSPN strcspn

#define pass_len 20

typedef unsigned short WORD;
typedef unsigned char BYTE;
typedef char* LPSTR;
typedef long LONG;
typedef int BOOL;
typedef int INT;
typedef unsigned int UINT;
typedef unsigned long ULONG;
typedef char CHAR;
typedef double DOUBLE;
typedef short int SHORT;

const char lpsEncodeChars[] ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int password(dir,pas,dst)
struct  dsc$descriptor  *pas, *dst;
{
 LPSTR result;
 LPSTR password1(LPSTR lpsEncode, BOOL direction);
   if (dir & strlen((char *)pas->dsc$a_pointer)>pass_len)
     {
       /* Error, Password is too long */
       *dst->dsc$a_pointer='\0';
       dst->dsc$w_length=1;      
       return 1;
     }
 result=password1((char *)pas->dsc$a_pointer,dir);
 /*memcpy((char *) dst->dsc$a_pointer,result,strlen(result));*/
 strcpy (dst->dsc$a_pointer,result);
 dst->dsc$w_length=strlen(dst->dsc$a_pointer);
 free(result);
 return 1;
}

/*---------------------------------------------------------------------------*/ 
LPSTR password1(LPSTR lpsEncode, BOOL direction)
{
  LPSTR lpsBuffer = malloc(64);
  LPSTR strnicat(LPSTR lpsPassword, LPSTR lpsTarget, ULONG ulTargetLen, BOOL dir);
  /* Dennis' logic */
  return strnicat(lpsEncode, lpsBuffer, 64, direction);
}

/*---------------------------------------------------------------------------*/

LPSTR strnicat(LPSTR lpsPassword, LPSTR lpsTarget, ULONG ulTargetLen, BOOL dir)
{
  CHAR  lpsPWBuffer[pass_len + ((pass_len + 3) / 4) + 1];
  INT   nPWLen;
  WORD  wNullPos;

  VOID ReverseBLOB(LPSTR lpsTarget, WORD wCount);
  VOID PadWithGarbage(LPSTR lpsTarget, WORD wCount);
  ULONG ASCDecode(LPSTR lpsEncodedStr, LPSTR lpsStr, ULONG ulBufferLen);
  VOID ASCEncode(LPSTR lpsStr, ULONG ulInStrLen, LPSTR lpsEncodedStr, ULONG ulBufferLen);
  VOID XorBuffer(LPSTR lpsBuffer, ULONG ulBufferLen, BOOL bReverse);

  if (dir)     /* Encrypt*/
    {
      nPWLen = STRLEN(lpsPassword);  /* Password length*/

      lpsPWBuffer[0] = (BYTE)nPWLen; /* Make it a 'Pascal' string*/
      STRCPY(lpsPWBuffer + 1, lpsPassword);

      PadWithGarbage(lpsPWBuffer + 1 + nPWLen, pass_len - nPWLen -1); /* Pad it w/trash (Also make fixed length)*/
      ReverseBLOB(lpsPWBuffer, pass_len);
      XorBuffer(lpsPWBuffer, pass_len, 0);
      ASCEncode(lpsPWBuffer, pass_len, lpsTarget, ulTargetLen); /*ASCII armor the string*/
    }
  else /* Decrypt,*/
    {
      ASCDecode(lpsPassword, lpsPWBuffer, ulTargetLen); /* Extract the binary from the string*/
      XorBuffer(lpsPWBuffer, pass_len,1 );
      ReverseBLOB(lpsPWBuffer, pass_len);

      wNullPos = (BYTE)lpsPWBuffer[0] + 1;
      if (wNullPos >= ulTargetLen)
        wNullPos = (WORD)(ulTargetLen - 1);
      lpsPWBuffer[wNullPos] = '\0';
      STRNCPY(lpsTarget, lpsPWBuffer + 1, ulTargetLen);
     }     
 return lpsTarget;
}

/*---------------------------------------------------------------------------*/

 VOID XorBuffer(LPSTR lpsBuffer, ULONG ulBufferLen, BOOL bReverse)
{
  BYTE byXorByte;
  BYTE byLastChar;
  WORD wIndex;
  byXorByte = 0xDC; /* Starting XOR byte*/
  if (bReverse)
    {
      for (wIndex = 0; wIndex < ulBufferLen; ++wIndex) /* Xor to munge it some more*/
        {
          byLastChar = lpsBuffer[wIndex];
          byXorByte ^= lpsBuffer[wIndex];
          lpsBuffer[wIndex] = byXorByte;
          byXorByte = byLastChar;
        }
    }
  else
    {
      for (wIndex = 0; wIndex < ulBufferLen; ++wIndex) /* Xor to munge it some more*/
        {
          byXorByte ^= lpsBuffer[wIndex];
          lpsBuffer[wIndex] = byXorByte;
         }
    }
}

/*---------------------------------------------------------------------------*/

/* Encode a binary stream as a bunch of ASCII characters*/
VOID ASCEncode(LPSTR lpsStr, ULONG ulInStrLen, LPSTR lpsEncodedStr, ULONG ulBufferLen)
{
  ULONG ulBits      = 0;                     /* Block of 3bytes to be encoded*/
  INT   nCharCount = 0;                      /* # ofcharacters ready to be encoded*/
  LPSTR lpsCharPtr;                          /* Pointer to current character to be encoded*/
  INT   check;
  /*ostrstream os(lpsEncodedStr, ulBufferLen);  Manages output buffer & stuff*/
  int DenCopy(LPSTR StrName1, char Addchar,ULONG ulBufferLen);
  lpsCharPtr = lpsStr;
  while (ulInStrLen--)
    {
      ulBits |= (unsigned char)*lpsCharPtr; /* Add the bits of the current character to the block (block is 3 bytes long)*/
      ++lpsCharPtr;
      nCharCount++;

      if (nCharCount == 3)  /* If we have a full block (3 bytes)...*/
        {
          check=DenCopy(lpsEncodedStr,lpsEncodeChars[(ulBits >> 18)],ulBufferLen);
	  if(check)
            check=DenCopy(lpsEncodedStr,lpsEncodeChars[(ulBits >> 12) & 0x3f],ulBufferLen);
          if(check)
            check=DenCopy(lpsEncodedStr,lpsEncodeChars[(ulBits >> 6) & 0x3f],ulBufferLen);
          if(check)
            check=DenCopy(lpsEncodedStr,lpsEncodeChars[ulBits & 0x3f],ulBufferLen);
          
	  ulBits = 0;
          nCharCount = 0;
        }
      else
        {
          ulBits <<= 8;   /* Keep adding to the block*/
        }
    }

  if (nCharCount != 0) /* Deal w/and non-multiple of 3 encodings...*/
    {
      ulBits <<= (16 - (8 * nCharCount));
      check=DenCopy(lpsEncodedStr,lpsEncodeChars[ulBits >> 18],ulBufferLen);
      if(check)
        check=DenCopy(lpsEncodedStr,lpsEncodeChars[(ulBits >> 12) & 0x3f],ulBufferLen);

      if (nCharCount == 1)
        {
          check=DenCopy(lpsEncodedStr,'=',ulBufferLen);
          if(check)
            check=DenCopy(lpsEncodedStr,'=',ulBufferLen);
	}
     else
       {
         check=DenCopy(lpsEncodedStr,lpsEncodeChars[(ulBits >> 6) & 0x3f],ulBufferLen);
         if(check)
            check=DenCopy(lpsEncodedStr,'=',ulBufferLen);
       }
    }
  check=DenCopy(lpsEncodedStr,'\0',ulBufferLen);
  if(!check)
    lpsEncodedStr[ulBufferLen - 1] = '\0'; /*Just in case of overflow, terminate the absolute last character*/
}

/*---------------------------------------------------------------------------*/

ULONG ASCDecode(LPSTR lpsEncodedStr, LPSTR lpsStr, ULONG ulBufferLen)
{
  LONG  lBits;
  INT   cCurChar;
  INT   cCharCount;
  LPSTR lpsStrPtr;
  BOOL  bResult = 1;
  ULONG ulCharsDecoded = 0;
  CHAR  lpsInEncodeChars[256];
  CHAR  lpsDecodeChars[256];
  INT   check;
  INT   nIndex;
  int DenCopy(LPSTR StrName1, char Addchar,ULONG ulBufferLen);
  /*ostrstream os(lpsStr, ulBufferLen);*/
  
  for (nIndex = (sizeof lpsEncodeChars) - 1; nIndex >= 0; nIndex--) 
    {
      lpsInEncodeChars[lpsEncodeChars[nIndex]] = 1;
      lpsDecodeChars[lpsEncodeChars[nIndex]]   = nIndex;
    }
  
  cCharCount = 0;
  lBits      = 0;
  lpsStrPtr  = lpsEncodedStr;

  
  if (ulBufferLen > 0)
    lpsStr[0] = '\0'; /*dpr*/
  else
    return 0;

  while (cCurChar = *(lpsStrPtr++))
    {
      if (cCurChar == '=') /* End of encoded stream*/
        break;

      if ((cCurChar > 255) || (!lpsInEncodeChars[cCurChar])) /*Check for invalid chars in the stream*/
        continue;

      lBits |= lpsDecodeChars[cCurChar]; /* Build block of 4 chars for decoding*/
      cCharCount++;

      if (cCharCount == 4) /* If we have a full block, decode (into 3 bytes)*/
        {
          check=DenCopy(lpsStr,(CHAR)(lBits >> 16),ulBufferLen);
          if (check)
            check=DenCopy(lpsStr,(CHAR)((lBits >> 8) & 0xFF),ulBufferLen);
	  if (check)
            check=DenCopy(lpsStr,(CHAR)(lBits & 0xFF),ulBufferLen);

          ulCharsDecoded += 3;

          lBits      = 0;
          cCharCount = 0;
        }
      else
        {
          lBits <<= 6;
        }
    }

  if (cCurChar == 0) /* If we're at the end of the input stream (NULL reached)*/
    {
      if (cCharCount) /*If there's still undecoded chars, its an error*/
        {
          ulCharsDecoded = 0;
        }
     }
  else
    {
      switch (cCharCount) /* cCurChar == '='*/
        {
          case 1: /* Shouldn't have ONLY an equal sign*/
            {
              ulCharsDecoded = 0;
              break;
            }

          case 2: /* 1 character still undecoded, decode it*/
            {
              DenCopy(lpsStr,(CHAR)(lBits >> 10),ulBufferLen);
              ++ulCharsDecoded;
              break;
            }

          case 3: /* 2 characters still undecoded, decode them*/
            {
              check=DenCopy(lpsStr,(CHAR)(lBits >> 16),ulBufferLen);
              if (check)
		DenCopy(lpsStr,(CHAR)(lBits >> 8),ulBufferLen);
              ulCharsDecoded += 2;
              break;
            }
        }
    }

  /* os << ends;*/

  return ulCharsDecoded;
}

/*---------------------------------------------------------------------------*/

VOID PadWithGarbage(LPSTR lpsTarget, WORD wCount)
{
  int nIndex;
  srand((unsigned)time(NULL));

  for (nIndex = 0; nIndex < wCount; ++nIndex)
    {
     lpsTarget[nIndex] = (rand() & 0xFF);
    }
}

/*---------------------------------------------------------------------------*/

VOID ReverseBLOB(LPSTR lpsTarget, WORD wCount)
{
  WORD wLength;
  CHAR cTemp;
  WORD wIndex;

  wLength = wCount >> 1; /* Divided by 2 (drop remainders)*/

  for (wIndex = 0; wIndex < wLength; ++wIndex)
    {
      cTemp = lpsTarget[wIndex];
      lpsTarget[wIndex] = lpsTarget[wCount - wIndex - 1];
      lpsTarget[wCount - wIndex - 1] = cTemp;
    }
}
int DenCopy(LPSTR StrName1, char Addchar,ULONG ulBufferLen)
{
  if(strlen(StrName1)+1>=ulBufferLen)
    return 0;
  strncat(StrName1,(char *)&Addchar,1);
  return 1;
}

/*---------------------------------------------------------------------------*/
