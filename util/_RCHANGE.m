%RCHANGE	;M Utility;Change specified string within selected routines
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/20/96 13:22:09 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 06 NOV 1989
	;
	; Search a set of routines for a specified string and change to new 
	; value.
	;
	; KEYWORDS:	Routine Handling
	;
	;---- Revision History ------------------------------------------------
	; 01/20/95 - Dan Russell
	;            Replace ZSYSTEM calls with $$SYS%$ZFUNC to prevent problems
	;            with captive accounts.
	;
	; 06/17/93 - Dan Russell
	;            Modified U FILE:EXC="" to do only once per file.  Caused
	;            problems if in FOR loop due to GT.M not releasing
	;            memory properly.
	;
	;----------------------------------------------------------------------
	;
START	N (READ)
	W !,"%RCHANGE change string within selected routines",!
	;	
	D ^%RSEL Q:'$G(%ZR)
	;
FROM	S FROM=$$PROMPT^%READ("Change string:  ","")
	I FROM="" Q
	S FROML=$L(FROM)
	;
TO	S TO=$$PROMPT^%READ("    To string:  ","")
	;
	K CMPLIST
	S X=$$PROMPT^%READ("Compile routines?  Yes=> ","") I X="" S X="Y"
	S COMPILE=$E($TR(X,"y","Y"))="Y"
	I COMPILE W !!,"...Routines will be compiled after all changes...",!
	;
	W !!,"Output results to "
	D ^%SCAIO Q:$G(ER)
	S TERM=($P=IO!(IO=0))
	S (CNTSRCHD,CNTRTNS,CNT)=0
	S DASH="",$P(DASH,"-",IORM)="",TOPLEVL=$ZL
	U 0:(CEN:CTRAP=$C(3):EXC="ZG "_$ZL_":CTRAP^%RCHANGE":WIDTH=510) W !
	U IO W !!,"Change all occurrences of ",FROM," to ",TO,!!
	;
	S RTN=""
RTN	S RTN=$O(%ZR(RTN)) I RTN="" D:COMPILE COMPILE G EXIT
	S NEWFILE="",LINECNT=1 K RTNLINES
	U 0 I IO'=$I W:$X>70 ! W RTN,?$X\10+1*10
	S FILE=%ZR(RTN)_$TR(RTN,"%","_")_".M",HIT=0,TAG=RTN,OFFSET=0,CNTSRCHD=CNTSRCHD+1
	O FILE:(READ:EXC="G NOOPEN")
	U FILE:EXC=""
	F  U FILE R LINE Q:$ZEOF  D LINE
	C FILE
	I NEWFILE'="" C NEWFILE
	G RTN
	;
LINE	; Evaluate each line
	I $P(LINE,$C(9),1)'="" S TAG=$P(LINE,$C(9),1),OFFSET=0
	E  S OFFSET=OFFSET+1
	I LINE'[FROM D WRTLINE Q
	U IO
	I 'HIT D NEWFILE
	I OFFSET W TAG,"+",OFFSET,!
	W "Old:  ",$$FORMAT^%RO(LINE),!
	S X="",(F,OF)=0
	F  S F=$F(LINE,FROM,F) Q:'F  S X=X_$E(LINE,OF,F-FROML-1)_TO,OF=F,CNT=CNT+1
	S X=X_$E(LINE,OF,$L(LINE)),LINE=X
	W "New:  ",$$FORMAT^%RO(LINE),!!
	D WRTLINE
	Q
	;
WRTLINE	I HIT U NEWFILE W LINE,!
	E  S RTNLINES(LINECNT)=LINE,LINECNT=LINECNT+1
	Q
	;
NEWFILE	; Open new routine file for changes
	S NEWFILE=$ZSEARCH("X") ; Clear $ZSEARCH
	S NEWFILE=$ZSEARCH(FILE)
	S NEWFILE=$P(NEWFILE,";",1)_";"_($P(NEWFILE,";",2)+1)
	O NEWFILE:(WRITE:NEWV:EXC="ZG "_TOPLEVL_":NONEW^%RCHANGE")
	U NEWFILE:EXC="" F I=1:1:LINECNT-1 W RTNLINES(I),!
	U IO
	S CMPLIST(NEWFILE)=RTN
	W !,DASH,!,"^",RTN,!
	S HIT=1,CNTRTNS=CNTRTNS+1
	Q
	;
COMPILE	; Compile routines, if compile option selected
	N X
	U 0 W !!,"Compiling routines",!
	S FILE=""
CLOOP	S FILE=$O(CMPLIST(FILE)) Q:FILE=""
	W:$X>70 ! W CMPLIST(FILE),?$X\10+1*10
	S X=$$SYS^%ZFUNC("@SCA$RTNS:SCA_COMPILE "_FILE_" """" 1")
	G CLOOP
	;
CTRAP	; Trap if control-C
	I $G(FILE)'="" C FILE
	I $G(NEWFILE)'="" C NEWFILE:DELETE
	G EXIT
	;
NONEW	; Unable to open new file
	U 0 W !!,"Unable to open new file ",NEWFILE," for changes.  Process aborted.",!
	C FILE
	G EXIT
	;
NOOPEN	; Unable to open file
	U 0 W !!,"Unable to open file ",FILE,".  Process aborted.",!
	;
EXIT	U IO W !!,CNTSRCHD," routines searched.",!
	W CNTRTNS," routines with a total of ",CNT," changes made.",!
	I IO'=$P D CLOSE^%SCAIO
	U $P:(EXC="":WIDTH=80)
	Q
