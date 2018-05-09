%ZUPGRRI	;Private;Release routine input utility
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:38:54 - SYSRUSSELL
	; ORIG:  pmc - 05/19/89
	;
	; This utility allows routines to be read in from a %RO RMS file w/o 
	; prompts and screen messages.  This will load all routines, and 
	; overlay existing versions.
	;
	; INPUTS:
	;	. IO		RMS file name containing the 
	;			directory reference
	;
	;	. RTNDIR	Routine directory name	
	;
	N (IO,RTNDIR)
	U IO R X,Y	; read in first two records before calling EXT^%RI
	D EXT^%RI(IO,RTNDIR,"A",1,1)
	C IO
	Q
