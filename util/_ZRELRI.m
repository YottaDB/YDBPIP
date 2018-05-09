%ZRELRI	;Private;Release routine input utility
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/03/95 09:03:29 - JOYNER
	; ORIG:  Marty Ronky (3623) - 05/19/88
	;
	; This utility allows routines to be read in from a %RO RMS file w/o 
	; prompts and screen messages. This will load all routines, and overlay
	; existing versions.
	;
	; INPUTS:
	;	. IO		RMS file name containing the 
	;			directory reference
	;
	;	. RTNDIR	Routine directory name	
	;
	;	. RTNLIST	List of routines to load, containing the
	;			directory name to load into.
	;
	;------Revision History------------------------------------------------
	; 05/16/94 - Phil Chenard
	;            Added new variable to save list to be passed to EXT^%RI
	;            that allows for a new input option for loading routines.
	;            This variable, RTNLIST must be defined outside of this
	;            utility and is structured to contain the directory name
	;            to load in to for each routine in the list.
	;
	;----------------------------------------------------------------------
	N (IO,RTNDIR,RTNLIST)
	U IO R X,Y	; read in first two records before calling EXT^%RI
	; *** Phil Chenard 05/16/94
	I $D(RTNLIST)>1 D EXT^%RI(IO,RTNDIR,"D",0,1,.RTNLIST) C IO Q
	D EXT^%RI(IO,RTNDIR,"A",0,1)
	C IO
	Q
