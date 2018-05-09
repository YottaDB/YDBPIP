/* MD5.H - header file for MD5C.C */

/* 
Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All
rights reserved.

License to copy and use this software is granted provided that it
is identified as the "RSA Data Security, Inc. MD5 Message-Digest
Algorithm" in all material mentioning or referencing this software
or this function.

License is also granted to make and use derivative works provided
that such works are identified as "derived from the RSA Data
Security, Inc. MD5 Message-Digest Algorithm" in all material
mentioning or referencing the derived work.

RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software or the suitability of this
software for any particular purpose. It is provided "as is"
without express or implied warranty of any kind.

These notices must be retained in any copies of any part of this
documentation and/or software.
*/

#ifndef _INCLUDE_MD5_H_
#define _INCLUDE_MD5_H_

#include <string.h>					

typedef unsigned char BYTE;
typedef unsigned char *PUSTR;

typedef unsigned int UINT;
/* typedef unsigned long int ULONG; */
/* typedef unsigned short int USHORT; */

/* MD5 context. */
typedef struct {
  ULONG state[4];       /* state (ABCD) */
  ULONG count[2];       /* number of bits, modulo 2^64 (lsb first) */
  BYTE buffer[64];	/* input buffer */
}MD5_CTX;

#ifdef __cplusplus
extern "C"
{
#endif

	void MD5Init(MD5_CTX *ctx);
	void MD5Update(MD5_CTX *ctx, BYTE *buf, UINT len);
	void MD5Final(BYTE digest[16], MD5_CTX *ctx);

#ifdef __cplusplus
}
#endif

#endif
