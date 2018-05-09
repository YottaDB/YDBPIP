/*
*	scatype.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 01 Mar 1995
*
*	DESC:
*
*   $Id$
*   $Log:	scatype.h,v $
 * Revision 1.4  04/07/29  thoniyim (Manoj Thoniyil)
 * Changed MAX_MSG_SIZE to 1MB
 * 
 * Revision 1.3  96/04/26  15:07:56  15:07:56  zengf (Fan Zeng)
 * Vax machine fix.
 * 
 * Revision 1.2  96/03/28  10:50:57  10:50:57  zengf (Fan Zeng)
 * Generic version for VMS and UNIX
 * 
*   $Revision: 1.3 $
*
*/

#ifndef 	SCATYPE_H
#define 	SCATYPE_H


/*
*	Error detection and notification
*/
#define	MUMPS_SUCCESS			1
#define	MUMPS_FAILURE			0
#define	TRUE				1
#define	FALSE				0

#define MAX_MSG_SIZE			1048576
#define MAX_STR_LEN			MAX_MSG_SIZE
#define MAX_DOUBLE_LEN			24
#define MAX_CMD_LEN			80



/*
 * The following are platform dependent definitions
 */
#ifdef VMS
	/* 
	 * this structure is identical to the VMS descriptor structure in file
	 * descrip.h except for the element names.
	 */
	typedef long	SLONG;
	typedef struct {
		unsigned long  length;
		unsigned char   dsc_type;
		unsigned char   dsc_class;
		char            *str;
	} STR_DESCRIPTOR;

#	include <ssdef.h>
#	define	SUCCESS					SS$_NORMAL
#	define	FAILURE					1234567

#else

#	include <gtmxc_types.h>
#	define	SUCCESS					0
#	define	FAILURE					-1

#	ifdef __hpux
		typedef long	SLONG;
		typedef struct {
			SLONG	length;
			char	*str;
		} STR_DESCRIPTOR;
#	endif /* __hpux */

#	ifdef __osf__
		typedef xc_long_t	SLONG;
		typedef xc_string_t	STR_DESCRIPTOR;
#	endif /* __osf__ */

/*		typedef long	SLONG; */
typedef xc_int_t	SLONG;
typedef xc_string_t 	STR_DESCRIPTOR;
/*
typedef struct {
	long	length;
	char	*str;
} STR_DESCRIPTOR;
*/
typedef unsigned long 	ULONG;
typedef char 			CHAR;
typedef unsigned char 	UCHAR;
typedef SLONG 			RETURNSTATUS;
typedef short 			SSHORT;
typedef unsigned short 	USHORT;

#endif /* VMS */

#endif		/* SCATYPE_H */
