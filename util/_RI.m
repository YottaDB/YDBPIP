%RI	;M Utility;Routine input utility
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/22/96 11:06:45 - CHENARD
	; ORIG:  RUSSELL -  4 NOV 1989
	;
	; Routine input which can be used in place of MUPIP CONVERT.
	;
	; Inputs %RO formated routine output file, with options to load all or 
	; selected routines, or only list routines in the input file.
	;
	; Note that MUPIP CONVERT may be used instead and will be faster.
	;
	; NOTE:  EXT(DEVICE,DIR,OPT,DISP,CMP,LOADLIST,ERROR) will load 
	;        routines without prompting.
	;        See EXT section for details.
	;
	; KEYWORDS:	Routine handling
	;
	;---- Revision History ------------------------------------------------
	;
	; 12/16/98 - Phil Chenard - 31142
	;            Modified COMPILE section to remove the extra "" placed
	;            at the end of the ZSY command string.  Some shells ignore
	;            this syntax while others, (/bin/bash), have problems.
	;
	; 01/16/96 - Phil Chenard - 13005
	;            Modified routine to support UNIX platform
	;
	;----------------------------------------------------------------------
	;
	N (READ)
	W !!,"%RI routine input.  (MUPIP may provide faster routine input)",!
	S DIRDEF=$$SCAU^%TRNLNM("MRTNS")
	S IMAGE=$G(^CUVAR("IMAGE"))
	I IMAGE=1 S DIRDEF=$$SCAU^%TRNLNM("PRTNS")
	I DIRDEF="" S DIRDEF=$$SCAU^%TRNLNM("MRTNS")  ; running images
	S DIR=$$PROMPT^%READ("Restore routines to directory:  ",DIRDEF)
	Q:$TR(DIR,"q","Q")="Q"
	I DIR="" Q
	S DIR=$P($ZPARSE(DIR,"","*"),"*",1)
	;
	S X=$$PROMPT^%READ("Compile routines?  Yes=> ","") I X="" S X="Y"
	S COMPILE=$E($TR(X,"y","Y"))="Y"
	I COMPILE W !!,"...Routines will be compiled after all changes...",!
	;
	W !,"Load routines from "
	D READ^%SCAIO Q:ER
	U IO R DESC,DATE
	U 0 W !!,"Routines saved on ",DATE,!,"Description:  ",DESC,!
	;
	W !!,"Restore routines to directory ",DIR," with",!!
OPT	S OPT=$$PROMPT^%READ("Input option:  ","")
	I "?"[OPT D OPTHELP G OPT
	S OPT=$TR(OPT,"aslq","ASLQ")
	I OPT="Q" C IO Q
	I OPT="E" D GETLIST
	U 0:(CEN:CTRAP=$C(3):EXC="D CTRAP1 ZG "_$ZL_":CTRAP^%RI")
	D EXT(IO,DIR,OPT,1,COMPILE,.LOADLIST)
	C IO
	U 0:EXC=""
	W !!,"Routine load complete",!
	Q
	;
CTRAP	U 0:EXC="" W !!,"Routine load interrupted",!
	C IO
	Q
	;
CTRAP1	I $G(FILE)'="" C FILE:DELETE U 0 W !,"Routine ",FILE," not loaded",!
	Q
	;
	;----------------------------------------------------------------------
EXT(DEVICE,DIR,OPT,DISP,COMPILE,LOADLIST,ERROR)	;M Utility;Load routines 
	;----------------------------------------------------------------------
	;
	; External call to load routines without prompting, through parameters
	; passed.
	;
	; If want to allow interrupt, should set exception to D CTRAP1^%RI to
	; keep any partially created files from remaining.  See top section of
	; %RI (direct call).  If no CTRAP is set when EXT is called, an 
	; interrupt may leave .M files only partially built.  Best bet on
	; external interfaces is to disable interrupts.
	;
	; Also, since ZSY to compile, if interrupted, only stops current 
	; routine from compiling, then continue with next routine.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. DEV		Input device			/TYP=T
	;			Must already be opened 
	;			and first two records read
	;
	;	. DIR		Directory to load 		/TYP=T/NOREQ
	;			routines into			/DEF=""
	;
	;	. OPT		Input option			/TYP=T/NOREQ
	;			  A - All routines		/DEF="A"
	;			  E - Enter list of routines to restore
	;			  S - Select routines during load
	;			  L - List routine names
	;			  D - Directory to load into
	;
	;	. DISP		Routine display option		/TYP=L/NOREQ
	;			  0 => don't display as load	/DEF=1
	;			  1 => display them
	;
	;	. COMPILE	Compile option			/TYP=L/NOREQ
	;			  0 => don't compile		/DEF=1
	;			  1 => compile routines
	;
	;	. LOADLIST	Array of executable statements	/TYP=T/NOREQ
	;			to be used during the load.	/MECH=REF:R
	;			With option "E", LOADLIST is used
	;			to determine if routine in input 
	;			file should be loaded.  Each 
	;			element must produce truth value,
	;			e.g. I @LOADLIST(1) 1 says load, 
	;			0 says don't.  Test is against 
	;			routine name RTN.  With option "D",
	;			LOADLIST is used to define the directory
	;			to load the routine into.
	;
	;	. ERROR		Return message if error		/TYP=T
	;			in loading (null if no error)	/MECH=REF:W
	;
	; EXAMPLE:
	;	D EXT^%RI(DEVICE,DIR,OPT,DISP,COMPILE,.LOADLIST,.ERROR)
	;
	;----------------------------------------------------------------------
	N (DEVICE,DIR,OPT,DISP,COMPILE,LOADLIST,ERROR)
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%RI"
	I '$D(DIR) S DIR="" ; Default to current directory
	I '$D(OPT) S OPT="A" ; Default to All option
	I '$D(DISP) S DISP=1 ; Default to display
	I '$D(COMPILE) S COMPILE=1 ; Default to compile
	S X=$E(DIR,$L(DIR))
	I X'="/" S DIR=DIR_"/"
	S OBJDIR=DIR_"obj/"
	I OPT="S" S DISP=0
	I DISP U 0 W !!,"'+' indicates routine loaded, '-' indicates routine skipped",!
NEXT	; Load next routine
	U DEVICE R RTN I RTN=""!$ZEOF D:COMPILE COMPILE U 0 Q
	I OPT="L" D SKIP
	I OPT="A" D LOAD
	I OPT="E" S OK=$$CHECK D LOAD:OK,SKIP:'OK
	I OPT="S" S OK=$$SELECT D LOAD:OK,SKIP:'OK
	I OPT="D" S OK=$$DIROPT(.DIR) D LOAD:OK,SKIP:'OK
	G NEXT
	;
	;----------------------------------------------------------------------
LOAD	; Load this routine
	;----------------------------------------------------------------------
	D DISP("+")
	I $E(RTN)="%" S RTN="_"_$E(RTN,2,99)
	S CFILE=DIR_"/"_RTN,FILE=DIR_"/"_RTN_".m"
	O FILE:(NEWV:RECORDSIZE=512)
	F  U DEVICE R LINE Q:LINE=""!$ZEOF  U FILE W $$FORMAT(LINE),!
	C FILE
	S CMPLIST(CFILE)=RTN ; Compile list
	S FILE="" ; Null file to indicate complete for this rtn in case of error
	Q
	;
	;----------------------------------------------------------------------
FORMAT(LINE)	; Replace all leading spaces or spaces past line tag with a tab
	;----------------------------------------------------------------------
	N I
	S X=$P(LINE," ",1)_$C(9),Y=$P(LINE," ",2,999)
	F I=1:1 Q:" "'=$E(Y,I)
	Q X_$E(Y,I,999)
	;
	;----------------------------------------------------------------------
SKIP	; Skip past this routine
	;----------------------------------------------------------------------
	D DISP("-")
	U DEVICE F  R LINE Q:LINE=""!$ZEOF
	Q
	;
	;----------------------------------------------------------------------
DISP(SIGN)	; Display routine being loaded
	;----------------------------------------------------------------------
	I DISP U 0 W:$X>70 ! W RTN,SIGN,?$X\10+1*10 U DEVICE
	Q
	;
	;----------------------------------------------------------------------
SELECT()	; Ask if want to restore routine
	;----------------------------------------------------------------------
	U 0 W !,RTN
	R ?40," Restore?  ",YN
	U DEVICE
	I $E($TR(YN,"y","Y"))="Y" Q 1 ; Yes
	Q 0 ; No
	;
	;----------------------------------------------------------------------
CHECK()	; See if routine should be loaded based on load list
	;----------------------------------------------------------------------
	S N=""
	I 0 ; Set $T to false
	F  S N=$O(LOADLIST(N)) Q:N=""  I @LOADLIST(N) Q
	Q $T
	;
	;----------------------------------------------------------------------
DIROPT(DIR)	;Private; Return directory to load into
	;----------------------------------------------------------------------
	N X
	I '$D(LOADLIST(RTN)) Q 0
	I LOADLIST(RTN)'="" S DIR=LOADLIST(RTN)
	;S X=$E(DIR,$L(DIR))
	;I X'="/" S DIR=DIR_"/"
	Q 1
	;
	;----------------------------------------------------------------------
COMPILE	; Compile routines, if compile option selected
	;----------------------------------------------------------------------
	U 0
	I DISP W !!,"Compiling routines",!
	S FILE=""
CLOOP	S FILE=$O(CMPLIST(FILE)) Q:FILE=""
	S RTN=CMPLIST(FILE)
	I DISP U 0 W:$X>70 ! W CMPLIST(FILE),?$X\10+1*10
	ZSY "${SCA_RTNS}/sca_compile.sh 1 "_DIR_" "_OBJDIR_" "_RTN_".m"
	G CLOOP
	;
ERR	U 0:EXC="" W !!,"Error loading routine",!,$P($ZS,",",2,999),!
	I $G(FILE)'="" C FILE:DELETE W !,"Routine ",FILE," not loaded",!
	S ERROR=$P($ZS,",",2,999)
	Q
	;
	;----------------------------------------------------------------------
GETLIST	; Get list of routines to enter for option "E"
	;----------------------------------------------------------------------
	K LOADLIST
	W !!,"Enter single routine or use wildcard, e.g., XYZ*",!
	S CNT=0
GLIST1	S X=$$PROMPT^%READ("Routine:  ","") Q:X=""
	I X="*" S OPT="A" K LOADLIST W " ...using option A" Q
	I X?1"%".7AN!(X?1A.7AN) S LOADLIST(CNT)="RTN="""_X_"""",CNT=CNT+1 G GLIST1
	I X?1"%".7AN1"*"!(X?1A.7AN1"*") S LOADLIST(CNT)="RTN?1"""_$E(X,1,$L(X)-1)_""".E",CNT=CNT+1 G GLIST1
	W " ... invalid format"
	G GLIST1
	;
OPTHELP	W !
	W !?5,"A - All routines"
	W !?5,"E - Enter list of routines to restore"
	W !?5,"S - Select routines during load"
	W !?5,"L - List routine names"
	W !?5,"Q - Quit",!!
	Q
