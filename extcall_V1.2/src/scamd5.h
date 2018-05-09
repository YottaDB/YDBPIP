/*******************************************************************************
*	File		:	scamd5.h	
*	Author		:	Lian Chen
*	Created		:	September 21, 1998
*	Modified	:	12/24/98 - Add descriptor for used GT.M calling
*				external routines.
*	Purpose		:	Header file for scamd5.cpp (UNIX and VMS version)
********************************************************************************/

#ifndef _INCLUDE_SCAMD5_H_
#define _INCLUDE_SCAMD5_H_

#include "md5.h"

#ifdef __cplusplus
extern "C"
{
#endif

void ProfileENC(int count, STR_DESCRIPTOR  *, STR_DESCRIPTOR *, SLONG *, STR_DESCRIPTOR *, SLONG *);

#ifdef __cplusplus
}
#endif

#endif
