TBXRJL	;Public; Rejected element loader
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/09/02 15:44:13 - JOYCEJ
	;
	;-----------------------------------------------------------------------
	;
	; DATA QWIK elements rejected during the installation of a Service or
	; Fix Pack can be loaded individually with this function
	;
	;
	;---------- Revision History -------------------------------------------
	; 02/13/2007	KWANL
	;		Fixed a typo.
	;
	; 08/24/2004	Lik Kwan
	;		Modified to allow M routine to be installed to a different 
	;		directory. The default is MRTNS.
	;	
	; 12/22/2003	Lik Kwan
	;		Add GETCODE section to read a file content into an array. If 
	;		the DQ content is not stored in ^TBXREJ global.
	;
	; 08/29/2003	Lik Kwan
	;		New variable CODE in PROC section.		
	;
	; 01/24/2003	Lik Kwan
	;		Make % routine directory as an optional but will require 
	;		when install a % routine.
	;		Use TBXSFILE to install system files.
	;
	;
	S %LOGID=$$LOGID^SCADRV
	S %="|"
	;-----------------------------------------------------------------------
MAIN	; Function entry point
	;-----------------------------------------------------------------------
	N %TAB,HDR,%READ,OK,FOLDER,FILE,PCNTDIR,ER,RM,zlogf,RTNDIR,dqv,dqvn7,db
	S RTNDIR="MRTNS"
	S RTNDIRS("CRTNS")=""
	S RTNDIRS("MRTNS")=""
	S RTNDIRS("PRTNS")=""
	S RTNDIRS("SRTNS")=""
	S RTNDIRS("ZRTNS")=""		
	;
	S %TAB("FOLDER")="/LEN=20/TYP=T/DES=Element Type/TBL=^TBXREJ(" 
	S %TAB("FILE")="/LEN=40/TYP=T/DES=File(enter * for ALL))/TBL=^TBXREJ(FOLDER,/XPP=D POSTP^TBXRJL" 
	S %TAB("RTNDIR")=".RTNDIR/REQ/DES=Directory to install M routines/TYP=T/LEN=40/TBL=RTNDIRS(" 
	S %TAB("PCNTDIR")=".PCNTDIR/NOREQ/DES=Percent Routine Directory/TYP=T/LEN=20/XPP=D POSTDIR^TBXRJL"
	S HDR="Load Rejected Elements" 
	; 
	S %READ="@HDR/CEN/REV,,FOLDER/REQ,FILE/REQ,RTNDIR/REQ,PCNTDIR/REQ" 
	; 
	D ^UTLREAD 
	I VFMQ="Q" Q 
	; 
	W $$MSG^%TRMVT("You are about to overlay the selected element(s)",0,0,1,23) 
	S OK=$$YN^DBSMBAR("","Do you want to continue?",1) 
	; 
	I OK=0 S ER="W",RM="Installation cancelled." Q 
	; 
	s zlogf=0
	;
	s dqvn7=0
	s dqv=$$GETVN^TBXDQUTL()				; set Profile version.
	Q:ER
	S:dqv'<"7" dqvn7=1
	;
	s db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	; 
	I FILE'="*" D PROC(FOLDER,FILE) Q:ER 
	I FILE="*" D  Q:ER 
	. S FILE="" 
	.	F  S FILE=$O(^TBXREJ(FOLDER,FILE)) Q:FILE=""  D PROC(FOLDER,FILE)
	; 
	i (db'="GTM") d 
	. d CRTABLE^TBXSQL,MODIFYTB^TBXSQL,UPDRDB^TBXSQL,eConstrt^TBXSQL,ALL^DBMAP(db) 
	; 
	D COMPALL^TBXDQUTL 
	Q 
	;---------------------------------------------------------------------- 
PROC(FOLDER,FILE)	; Load DQ element 
	;---------------------------------------------------------------------- 
	W $$MSG^%TRMVT(FILE) 
	;
	N USER,DATE,TIME,RTN,VIEW,BUILD,PROJECT,REVISION,PVB,CODE
	;
	S REVISION=$P(^TBXREJ(FOLDER,FILE),"|",1)
	S USER=$P(^TBXREJ(FOLDER,FILE),"|",2)
	S DATE=$P(^TBXREJ(FOLDER,FILE),"|",3)
	S TIME=$P(^TBXREJ(FOLDER,FILE),"|",4)
	S PVB("PROJECT")=$P(^TBXREJ(FOLDER,FILE),"|",5)
	S PVB("VIEW")=$P(^TBXREJ(FOLDER,FILE),"|",6)
	S PVB("CR")=$P(^TBXREJ(FOLDER,FILE),"|",7)
	S RTN=$P(^TBXREJ(FOLDER,FILE),"|",8)
	;
	; Load file contents into the CODE array.
	N SEQ S SEQ=""
	F  S SEQ=$O(^TBXREJ(FOLDER,FILE,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TBXREJ(FOLDER,FILE,SEQ)
	;
	I '$D(CODE) D GETCODE(FOLDER,.CODE) I ER U 0 W !,RM,! Q
	;
	I FOLDER="table" D  Q
	.	I $P(FILE,".",2)="COL" S X=$$LOAD^TBXCOL(.CODE,FILE,2,USER,DATE,TIME)
	.	I $P(FILE,".",2)="TBL" S X=$$LOAD^TBXTBL(.CODE,FILE,2,USER,DATE,TIME)
	.	I +X=0 D  Q
	..		S ER=1
	..		S RM="Not Loaded: "_$P(X,"|",2)
	..		w !,RM,!
	..		D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,RM)
	.	I X D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded from reject table")
	.	K ^TBXREJ(FOLDER,FILE)
	.	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	.	;
	I (FOLDER="routine") D  Q
	.	S X=$$LOAD^TBXRTN(FILE,"",CODE(1),RTNDIR,1,1)
	.	I X=1 D  Q
	..		S ER=1
	..		w !,RM,!
	..		D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,RM)
	.	I X D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded from reject table")
	.	K ^TBXREJ(FOLDER,FILE)
	.	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	.	;
	I (FOLDER="percent_routine")!(FOLDER="unix")!(FOLDER="vms") D  Q
	. 	S X=$$LOADPRTN^TBXRTN(FILE,"",CODE(1),PCNTDIR,1,1)
	.	I X=1 D  Q
	..		S ER=1
	..		w !,RM,!
	..		D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,RM)
	.	I X D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded from reject table")
	.	K ^TBXREJ(FOLDER,FILE)
	.	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	.	;
	I "com,doc,exp,gog,help,uxscrpt"[FOLDER D  Q
	.	S X=$$LOAD^TBXSFILE(FILE,CODE(1),2)
	.	I X=1 D  Q
	..		S ER=1
	..		; S RM="Not Loaded: "_$P(X,"|",2)
	..		w !,RM,!
	..		D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,RM)
	.	I X D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded from reject table")
	.	K ^TBXREJ(FOLDER,FILE)
	.	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	.	;
	.	; All other element types
	E  D
	.	S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,2,USER,DATE,TIME)"
	.	X CMD
	.	;
	.	I +X=0 D  Q
	..		S ER=1
	..		S RM="Not Loaded: "_$P(X,"|",2)
	..		w !,RM,!
	..		D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,RM)
	.	;
	.	D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded from reject table")
	.	K ^TBXREJ(FOLDER,FILE)
	.	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	.	;
	Q 
	;---------------------------------------------------------------------- 
POSTP	; File prompt post processor
	;---------------------------------------------------------------------- 
	I X="*" D CHANGE^DBSMACRO("TBL","") 
	Q 
	;
POSTDIR	;
	;
	I ((FOLDER="percent_routine")!(FOLDER="unix")!(FOLDER="vms"))&(X="") D
	.	S ER=1,RM="% rotuine direcotry is required to install % routine"
	Q
	;
	;----------------------------------------------------------------------
GETCODE(FOLDER,CODE);	
	; Get dataqwik content into array CODE. This happens when table name 
	; does not match the folder name in StarTeam.
	;	
	;----------------------------------------------------------------------
	;
	N X,Z,FILE,LINE,SEQ
	S READ("PROMPT")="Source file : "
	D ^%READ I X="" S ER=1,RM="Source File is missing" Q
	;
	S FILE=X
	;
	S Z=""
	S Z=$ZSEARCH(FILE)
	I Z="" S ER=1,RM="File "_FILE_" is not found" Q
	;
	I "com,doc,exp,gog,help,uxscrpt,routine,percent_routine"[FOLDER D  Q
	. S CODE(1)=X
	E  D
	. S X=$$FILE^%ZOPEN(FILE,"READ")
	. I 'X S ER=1,RM=$P(X,"|",2) Q
	. ;
	. F  U FILE R LINE q:$ZEOF  D
	.. I $ZEOF Q 
	.. S CODE($O(CODE(""),-1)+1)=LINE
	. C FILE
	Q
