%ZSYS()	;Public;Extrinsic variable to return operating system (GT.M)
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/28/97 07:52:59 - SYSCHENARD
	;     ORIG:  Dan S. Russell (2417) - 6/21/88
	;
	; Extrinsic variable function to return system type GT.M
	;
	; KEYWORDS: System services
	;
	; RETURNS:
	;     . $$	Operating system		/TYP=T
	;
	; EXAMPLE:
	;     S %SYS=$$^%ZSYS
	;
	;-----Revision History-------------------------------------------------
	; 06/13/01 - Harsha Lakshmikantha - 45731
	;            Added quits for Linux and Solaris platforms.
	;
	; 03/28/97 - Phil Chenard
	;            Added quits for all M platforms currently supported.
	;
	;----------------------------------------------------------------------
	;
	N SYS
	S SYS=$ZVERSION
	I SYS["VMS" Q "VMS"
	E  I SYS["HP-UX" Q "HPUX"
	E  I SYS["AIX" Q "AIX"
	E  I SYS["OSF1" Q "OSF1"
	E  I SYS["Linux" Q "LINUX"
	E  I SYS["Solaris" Q "SOLARIS"
	Q ""
	;
