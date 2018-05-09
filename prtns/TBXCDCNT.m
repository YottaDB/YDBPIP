TBXCDCNT	;	Count lines of code
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/19/02 21:12:41 - SPIER
	;
	; Utilities to count the number of lines of code 
	; for Batch definitions, Procedure definitions,
	; Triggers and Routines.
	;
	Q
	;
BATCH	;Public ;; Batch entry point to prompt for batch definition 
	N hdg,%O,%TAB,%READ,OLNTB,vdd,VFMQ
	S hdg="Batch code Count Utility"
	S %TAB("BCHID")="[DBTBL33]BCHID/TBL=[DBTBL33]"
	S %READ="@hdg/CEN/REV,,BCHID/REQ"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD
	D CNTBATCH(BCHID)
	ZWRITE COMLINE,CODELINE,WHITESPC
	Q
	;
CNTBATCH(BATCH)	;Public; Count code for batch programs
	;	Count comments,white space and lines of code
	;
	;	Input
	;		BATCH - Name of the Batch definition	/REQ/VAL
	;
	;	Output
	;		COMLINE	 - Number of Comment lines
	;		CODELINE - Lines of Code
	;		WHITESPC - Lines of white space
	;
	N CODELINE,COMLINE,MULTI,SEQ,TYPE,WHITESPC
	S (COMLINE,CODELINE,MULTI,WHITESPC)=0
	S (TYPE,SEQ)=""
	F  S TYPE=$O(^DBTBL("SYSDEV",33,BATCH,TYPE)) Q:TYPE=""  D
	.	F  S SEQ=$O(^DBTBL("SYSDEV",33,BATCH,TYPE,SEQ)) Q:SEQ=""  D
	..		S LINE=^DBTBL("SYSDEV",33,BATCH,TYPE,SEQ)
	..		D CBATCH(LINE,TYPE)
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	;	
EXT(CODE)	
	K sec 
	N CODELINE,COMLINE,MULTI,SEQ,WHITESPC
	S (COMLINE,CODELINE,WHITESPC,MULTI)=0
	S i="",j="" F  S i=$O(CODE(i)) Q:i=""  D 
	.       S x=CODE(i) 
	.       I $E(x,1,11)="---------- " S TYPE=$E(x,12,20),TYPE=$P(TYPE," ",1) I TYPE'="" S sec=TYPE,seq=1,j=0 Q  ; Section name 
	.       I x'="" S j=1 
	.       I 'j,x="" Q                             ; Remove blank lines 
	.       I '$D(sec) Q 
	.	D CBATCH(x,TYPE)
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	Q
CBATCH(LINE,TYPE)	
	I TYPE="REVHIST" S COMLINE=COMLINE+1 Q
	S SRC=$$WHITESPC(LINE)
	I $E(SRC)=";" S COMLINE=COMLINE+1 Q
	I $E(SRC,1,2)="//" S COMLINE=COMLINE+1 Q
	I $E(SRC,1,2)="/*" S COMLINE=COMLINE+1,MULTI=1 Q
	I MULTI,SRC["*/" S COMLINE=COMLINE+1,MULTI=0 Q
	I MULTI S COMLINE=COMLINE+1 Q
	I $E(SRC,1,2)="--" Q
	I SRC'="" S CODELINE=CODELINE+1 Q
	S WHITESPC=WHITESPC+1
	Q
	;
	;
PROC	;Public; Prompt for individual procedure
	;
	N hdg,%O,%TAB,%READ,OLNTB,vdd,VFMQ
	S hdg="Procedure Code Count Utility"
	S %TAB("PROCNAM")=".PROCNAM/TBL=[DBTBL25]"
	S %READ="@hdg/CEN/REV,,PROCNAM/REQ"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD
	S X=CNTPROC(PROCNAM)
	ZWRITE X
	Q
	;
CNTPROC(PROCID)	;Public; Count code for procedures
	;
	;	Count comments,white space and lines of code
	;
	;	Input
	;		PROCID	- Procedure Name	/REQ/VAL
	;	Output
	;		COMLINE	 - Number of Comment lines
	;		CODELINE - Lines of Code
	;		WHITESPC - Lines of white space
	;
	N CODELINE,COMLINE,MULTI,SEQ,WHITESPC
	S SEQ=""
	S (COMLINE,CODELINE,WHITESPC,MULTI)=0
	S MPLUS=$P($G(^DBTBL("SYSDEV",25,PROCID)),"|",9)
	F  S SEQ=$O(^DBTBL("SYSDEV",25,PROCID,SEQ)) Q:SEQ=""  D
	.	S LINE=^DBTBL("SYSDEV",25,PROCID,SEQ)
	.	D COUNTPRC(LINE,MPLUS)
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	;
	;
EXTPROC(CODE,MPLUS)	
	N CODELINE,COMLINE,MULTI,SEQ,WHITESPC
	S SEQ=""
	S (COMLINE,CODELINE,MULTI,WHITESPC)=0
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	.	S LINE=CODE(SEQ)
	.	D COUNTPRC(LINE,.MPLUS)
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	;
	;
COUNTPRC(LINE,MPLUS)	; Public ; Evaluate single line of code from a procedure
	S MPLUS=+$G(MPLUS)
	S SRC=$$WHITESPC(LINE)
	I 'MPLUS D  Q
	.	I $E(SRC)=";" S COMLINE=COMLINE+1 Q
	.	I SRC'="" S CODELINE=CODELINE+1 Q
	.	S WHITESPC=WHITESPC+1
	E  D 
	.	I $E(SRC,1,2)="//" S COMLINE=COMLINE+1 Q
	.	I $E(SRC,1,2)="/*" S COMLINE=COMLINE+1,MULTI=1 Q
	.	I MULTI,SRC["*/" S COMLINE=COMLINE+1,MULTI=0 Q
	.	I MULTI S COMLINE=COMLINE+1 Q
	.	I SRC="" S WHITESPC=WHITESPC+1 Q
	.	S CODELINE=CODELINE+1
	Q
	;
TRIG	;Public;Prompt for table potentially the trigger associated with it
	;
	N hdg,%O,%TAB,%READ,OLNTB,vdd,VFMQ
	S hdg="Trigger Code Count Utility"
	S %TAB("TABLE")=".FID1/TBL=[DBTBL7]TABLE:DISTINCT/LEN=20"
	S %TAB("TRIG")="/DES=Trigger ID/LEN=20/TYP=T/TBL=[DBTBL7]:QU ""[DBTBL7]TABLE=<<TABLE>>"""
	S %READ="@hdg/CEN,,TABLE/REQ,TRIG"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD
	S X=$$CNTTRIG(TABLE,TRIG)
	ZWRITE X
	Q
	;
CNTTRIG(TABLE,TRIG)	;Public; Return count for triggers
	;	Count comments,white space and lines of code
	;
	;	Input
	;		TABLE - Name of the Table		/REQ/VAL
	;		TRIG  - Individual trigger name 	/NOREQ/VAL
	;	Output
	;		COMLINE	 - Number of Comment lines
	;		CODELINE - Lines of Code
	;		WHITESPC - Lines of white space
	;
	N CODELINE,COMLINE,MULTI,SEQ,WHITESPC
	S (COMLINE,CODELINE,MULTI,WHITESPC)=0
	N SEQ
	S SEQ=""
	F  S SEQ=$O(^DBTBL("SYSDEV",7,TABLE,TRIG,SEQ)) Q:SEQ=""  D
	.	S LINE=^DBTBL("SYSDEV",7,TABLE,TRIG,SEQ)
	.	D COUNTTRG(LINE)
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	;
	;
EXTTRG(CODE)	
	N CODELINE,COMLINE,MULTI,SEQ,WHITESPC
	S SEQ=""
	S (COMLINE,CODELINE,MULTI,WHITESPC)=0
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	.	S LINE=CODE(SEQ)
	.	D COUNTTRG(LINE)
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	;
COUNTTRG(LINE)	
	S SRC=$$WHITESPC(LINE)
	I $E(SRC)=";" S COMLINE=COMLINE+1 Q
	I $E(SRC,1,2)="//" S COMLINE=COMLINE+1 Q
	I $E(SRC,1,2)="/*" S COMLINE=COMLINE+1,MULTI=1 Q
	I MULTI,SRC["*/" S COMLINE=COMLINE+1,MULTI=0 Q
	I MULTI S COMLINE=COMLINE+1 Q
	I SRC'="" S CODELINE=CODELINE+1 Q
	S WHITESPC=WHITESPC+1
	Q
	;
	;Labels to deal with counting code in a M program
	;
ROUTINE	;Public; Prompt for routine 
	;
	N CODELINE,COMLINE,hdg,%O,%TAB,%READ,OLNTB,vdd,VFMQ,WHITESPC
	S hdg="Routine Code Count Utility"
	S %TAB("ROUTINE")=".FLG1/LEN=20/TYP=T"
	S %READ="@hdg/CEN,,ROUTINE/REQ"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD
	S MRTNS=$$SCAU^%TRNLNM("MRTNS")
	I ROUTINE'["." S ROUTINE=ROUTINE_".m"
	S IO=$$FILE^%TRNLNM(ROUTINE,MRTNS)
	S X=$$CNTROU(IO)
	ZWRITE X
	Q
	;
EXTMROUT(ROUTINE)	
	N CODELINE,COMLINE,IO,MRTNS,WHITESPC,X
	S MRTNS=$$SCAU^%TRNLNM("MRTNS")
	I ROUTINE'["." S ROUTINE=ROUTINE_".m"
	S IO=$$FILE^%TRNLNM(ROUTINE,MRTNS)
	S X=$$CNTROU(IO)
	Q X
	;
CNTROU(IO)	;Public; Count Code in a mrtn program
	;
	;	Input
	;		ROUTINE	- Routine Name (assumed mrtns)	/REQ/VAL/TYP=T
	;	Output
	;		COMLINE	 - Number of Comment lines
	;		CODELINE - Lines of Code
	;		WHITESPC - Lines of white space
	;
	N CODELINE,COMLINE,EOT,MULTI,SEQ,WHITESPC,Z
	S (COMLINE,CODELINE,WHITESPC,MULTI)=0
	S Z=$$FILE^%ZOPEN(IO,"READ",2)
	I +Z=0 S RM=$P(Z,"|",2),ER=1 Q
	F  S SRC=$$^%ZREAD(IO,.EOT) Q:EOT  D
	.	S SRC=$$WHITESPC(SRC)
	.	I $E(SRC)=";" S COMLINE=COMLINE+1 Q
	.	i SRC="" S WHITESPC=WHITESPC+1
	.	S CODELINE=CODELINE+1
	C IO
	Q COMLINE_"|"_CODELINE_"|"_WHITESPC
	;
	;
CHECK(LINE,SRC)	;Public; Return logical indicating comments and code on line
	;
	I LINE'["//" Q 0
	I $E(SRC,1,2)="//" Q 0
	I $E(LINE,1,2)=$E(SRC,1,2) Q 0
	Q 1
	;
	;
WHITESPC(CODE);Public;	Return line of code without spaces or tabs 
	;
	S src=$TR($TR(CODE," ",""),$C(9),"")
	Q src
	;
