%ZRTNDEL	;M Utility;  Routine deletion utility
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/25/96 11:37:31 - CHENARD
	;     ORIG:  Dan S. Russell (2417) - 11/11/88
	;
	; Allows deletion of selected routines with entry at top,
	; or of single routine passed as parameter by:
	;
	; KEYWORDS:	Routine handling
	;
	; INPUTS:
	;	. %ZR	- Array listing routines intended to be deleted.
	;					/TYP=T/REQ
	;
	; EXAMPLE:
	;	D ^%ZRTNDEL
	;
	; LIBRARY:
	;	. DEL	  - Deletes a single routine
	;
	;	. DELFILE - Deletes a single RMS file, including all versions
	;
	;	. DELOLB  - Removes a routine from an existing object library
	; 
	;---- Revision History ------------------------------------------------
	; 02/09/06 - RussellDS - CR19489
	;	     Add coding to delete .proc files as well as .m and .o
	;	     files.
	;
	; 01/20/95 - Dan Russell
	;            Replace ZSYSTEM calls with $$SYS%$ZFUNC to prevent problems
	;            with captive accounts.
	;
	; 05/28/93 - Dan Russell
	;            Add DIRectory parameter to DEL subroutine to allow
	;            deletion from a specified directory, instead of only
	;            following the search list.
	;
	;----------------------------------------------------------------------
	N
	W !,"Routine deletion",!
	D BOTH^%RSEL Q:'%ZR
	S X=$$SEARCH^%ZFUNC("X")
	S RTN="" W !
	F I=0:1 S RTN=$O(%ZR(RTN)) Q:RTN=""  D
	.	D KILL1(RTN) 
	.	W:'(I#8)*I ! 
	.	W ?I#8*10,RTN
	Q
	;
	;----------------------------------------------------------------------
DEL(RTN,DIR)	;System; Delete routines passed in comma separated list
	;----------------------------------------------------------------------
	; A specific routine or range of routines, comma seperated, or using
	; wildcarding, will be deleted by this public sub-routine.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTN	- Routine name or names to be deleted.
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. DIR	- Directory location where the routine is to be
	;		  found.
	;					/TYP=T/NOREQ/MECH=VAL
	;
	; EXAMPLE:
	;	D DEL^%ZRTNDEL(rtn)
	;	D DEL^%ZRTNDEL(rtn,rtn1,rtn2)
	;	D DEL^%ZRTNDEL(rtn*)
	;
	;---------------------------------------------------------------------- 
	Q:$G(RTN)=""
	S DIR=$G(DIR)
	I DIR'="" D
	.	N X,DEV
	.	S DEV=$$PARSE^%ZFUNC(DIR,"DEVICE")
	.	S X=$$TRNLNM^%ZFUNC($P(DEV,":",1),1)
	.	I X'="" S DEV=X I $E(DEV,$L(DEV))'=":" S DEV=DEV_":"
	.	S DIR=DEV	;_$ZPARSE(DIR,"DIRECTORY")
	;
	N %ZI,%ZR,I,X,LIB
	F I=1:1 S X=$P(RTN,",",I) Q:X=""  S %ZI(X)=""
	I DIR="" D
	.	D BOTH^%RSEL Q:'$D(%ZR)
	.	S X=$$SEARCH^%ZFUNC("X") ; Reset $ZSEARCH
	.	S X="" F  S X=$O(%ZR(X)) Q:X=""  D KILL1(X)
	E  D
	.	S X="" F  S X=$O(%ZI(X)) Q:X=""  D KILL2(X,DIR)
	Q
	;
	;----------------------------------------------------------------------
KILL1(RTN)	;Private; Delete routine(s) w/o directory reference
	;----------------------------------------------------------------------
	D DELFILE($$FILE^%TRNLNM(RTN_".m",%ZR(RTN))) ; Delete source code
	D DELFILE($$FILE^%TRNLNM(RTN_".o",%ZR(RTN))) ; Delete object code
	D DELFILE($$FILE^%TRNLNM(RTN_".proc",%ZR(RTN)))	; Delete procedure source
	I $G(%ZRO(RTN))'="" D DELFILE($$FILE^%TRNLNM(RTN_".o",%ZRO(RTN))) ; Delete object code
	D DELOLB(RTN,%ZR(RTN))				    ; Delete from .OLB
	Q
	;
	;----------------------------------------------------------------------
KILL2(RTN,DIR)	;Private; Delete an individual routine in directory specified
	;----------------------------------------------------------------------
	I RTN="GTM$DEFAULTS" Q  ; Don't delete - not MUMPS
	;
	N I,OBJDIR,SRCDIR,HIT,ZRO,X
	S ZRO=$ZROUTINES
	;
	S HIT=0
	F I=1:1 S OBJDIR=$P(ZRO," ",I) Q:OBJDIR=""  D  Q:HIT=1
	.	I OBJDIR[".OLB" Q
	.	S SRCDIR=OBJDIR
	.	I OBJDIR["(" S SRCDIR=$P(OBJDIR,"(",2),SRCDIR=$P(SRCDIR,")",1),OBJDIR=$P(OBJDIR,"(",1)
	.	S OBJDIR=$ZPARSE(OBJDIR,"DEVICE")
	.	; Attempt to reduce SRCDIR to lowest level to match DIR 
	.	S DEV=$ZPARSE(SRCDIR,"DEVICE")
	.	S X=$$TRNLNM^%ZFUNC($P(DEV,":",1),1) 
	.	I X'="" S DEV=X I $E(DEV,$L(DEV))'=":" S DEV=DEV_":"
	.	S SRCDIR=DEV	;_$ZPARSE(SRCDIR,"DIRECTORY")
	.	I SRCDIR=DIR S HIT=1
	;
	Q:'HIT						; Directory not found
	;
	D DELFILE($$FILE^%TRNLNM(RTN_".m",SRCDIR))	; Delete source
	D DELFILE($$FILE^%TRNLNM(RTN_".o",SRCDIR))	; Just in case
	D DELFILE($$FILE^%TRNLNM(RTN_".o",OBJDIR))	; Delete object
	;
	; Delete potential object library entries
	D DELOLB(RTN,SRCDIR)
	D DELOLB(RTN,OBJDIR)
	;
	Q
	;
	;----------------------------------------------------------------------
DELFILE(FILE)	;System;Delete the specified file, if it exists
	;----------------------------------------------------------------------
	; This sub-routine will spawn a process to delete an existing RMS
	; file, including all versions.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. FILE	- RMS file name to be deleted.
	;					/TYP=T/REQ/MECH=VAL
	; EXAMPLE:
	; 	D DEPFILE^%ZRTNDEL("SCAU$SPOOL:X.X")
	; 
	;----------------------------------------------------------------------
	N X
	F  S X=$$SEARCH^%ZFUNC(FILE) Q:X=""		; Clear $ZEARCH
	I $$SEARCH^%ZFUNC(FILE)'="" S X=$$DELETE^%OSSCRPT(FILE)
	Q
	;
	;----------------------------------------------------------------------
DELOLB(RTN,OLBDIR)	;System;Delete from .OLB if exists - 
	;----------------------------------------------------------------------
	; This sub-routine will delete a routine from an object library, using
	; the command procedure %ZRTNDEL.  Object libraries will have a default
	; name of MUMPS.OLB.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTN     - Routine name to be removed from the object
	; 		    library.
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. OLBDIR  - Directory name where the object library 
	;		    exists.  
	;					/TYP=T/REQ/MECH=VAL
	;
	; EXAMPLE:
	;	D DELOLB^%ZRTNDEL(rtn,"SCA$RTNS:")
	;
	;----------------------------------------------------------------------
	N X
	F  S X=$$SEARCH^%ZFUNC(OLBDIR_"MUMPS.OLB") Q:X=""	; Clear $ZEARCH
	I $$SEARCH^%ZFUNC(OLBDIR_"MUMPS.OLB")'="" D
	.	S X=$$DELETE^%OSSCRPT("MUMPS.OLB",OBJDIR)
	Q
