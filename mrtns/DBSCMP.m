DBSCMP(rtn,zarray,nolink)	;;DBS - UTL - V4.4 - DQ Compiler source code library interface
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/10/94 10:37:26 - CHIANG
	;     ORIG:  CHIANG - 13 FEB 1992
	;CALLED BY:  
	;    CALLS:  ^%ZRTNCMP
	;     DESC:  DQ compiler
	;
	;------ Revision History -----------------------------------------------
	; 11/10/94  Bob Chiang - 10174
	;           Modified to use SCAU$CRTNS as the default directory name
	;           for all DQ generated run-time routines.
	;
	; 04/16/93  Bob Chiang
	;
	;           Modified to use SCAU$CRTNS as the default directory name
	;           for compiled DQ screens, reports and filers (except
	;           core software DBS screens and reports).
	;
	; 12/31/92  Bob Chiang
	;
	;           Modified to use SCAU$MRTNS as the default directory name
	;           for compiled DQ screens and reports.
	;-----------------------------------------------------------------------
	N zzdir
	I $G(rtn)="" Q
	;
	D ^%ZRTNCMP(rtn,$G(zarray),$G(nolink),"")
	Q
