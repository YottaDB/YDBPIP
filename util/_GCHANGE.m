%GCHANGE	;M Utility;Change specified string within global	
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/18/00 14:44:13 - CARROLLJ
	; ORIG:  Dan S. Russell (2417) - 06 NOV 1989
	;
	; Search a global for a specified string and change to new value.
	;
	; Allows selection of portions or ranges of global nodes (ala %G).
	;
	; KEYWORDS:	Global handling
	;
	;------Revision History------------------------------------------------
	; 10/18/00 - CARROLLJ - 40553:001
	;	     Modified the call to %TRNLNM because the change report was
	;	     not being generated on UNIX.
	;
	; 07/10/00 - CARROLLJ - 40553
	;	     Added section SAVEGLB and REV to audit database changes
	;	     made through gchange.
	;----------------------------------------------------------------------
	;
	;
START	N (READ)
	W !,"%GCHANGE change string within global",!
	;	
GLOBAL	S GBL=$$PROMPT^%READ("       Global:  ","")
	I GBL="" Q
	D VALID^%G(GBL) I ER U 0 W "  ",RM S ER=0 G GLOBAL
	;
FROM	S FROM=$$PROMPT^%READ("Change string:  ","")
	I FROM="" G GLOBAL
	S FROML=$L(FROM)
	;
TO	S TO=$$PROMPT^%READ("    To string:  ","")
	;
	S REASON=$$PROMPT^%READ("Reason for Global Change:  ","")
	W !!,"Output results to "
	D ^%SCAIO Q:$G(ER)
	S %LIBS="SYSDEV"
	;
	S (CNTNODES,CNT,ALL)=0
	U 0:(CEN:CTRAP=$C(3):EXC="ZG "_$ZL_":CTRAP^%GCHANGE") W !
	U IO W !,"For ",GBL," change all occurrences of ",FROM," to ",TO,!!
	;
	; Log changes made through %GCHANGE
	S CDT=$P($H,",",1)
	S UNAM=$$USERNAM^%ZFUNC
	S TIME=$P($H,",",2)
	S SEQ=$O(^GCHGLOG(CDT,""),-1)+1
	L +^GCHGLOG(CDT,SEQ):2
	S $P(^GCHGLOG(CDT,SEQ),"|",1)=TIME
	S $P(^GCHGLOG(CDT,SEQ),"|",2)=UNAM
	S $P(^GCHGLOG(CDT,SEQ),"|",3)=REASON
	S $P(^GCHGLOG(CDT,SEQ),"|",4)=GBL
	S $P(^GCHGLOG(CDT,SEQ),"|",5)=FROM
	S $P(^GCHGLOG(CDT,SEQ),"|",6)=TO
	L -^GCHGLOG(CDT,SEQ)
	;
	D OUTPUT^%G(GBL,"X","CHANGE^%GCHANGE")
	;
EXIT	I CNTNODES=0 K ^GCHGLOG(CDT,SEQ)
	I IO'=$P D CLOSE^%SCAIO
	I CNTNODES>0  D
	.	U 0 W !,"Report has been filed in spool directory.  GCHANGE.USERNAME",!
	.	U 0 W !!,CNTNODES," nodes changed.  Total of ",CNT," occurrences.",!
	.	S IO1=$$SCAU^%TRNLNM("SPOOL","GCHANGE."_UNAM)
	.	S %BLK="/,"_IO1_","_CDT_","_SEQ
	.	S RID="GCHANGE"
	.	D DRV^URID
	U $P:EXC=""
	Q
	;
CTRAP	; Trap if control-C
	U IO W !!,"Change interrupted...not completed",!
	G EXIT
	;
CHANGE	; Check data for string, change if found
	Q:%DATA'[FROM
	I 'ALL Q:'$$OK
	N X,F,OF
	S CNTNODES=CNTNODES+1
	U IO W %NODE,!
	W " Old:  ",%DATA,!
	S X="",(F,OF)=0
	F  S F=$F(%DATA,FROM,F) Q:'F  S X=X_$E(%DATA,OF,F-FROML-1)_TO,OF=F,CNT=CNT+1
	S X=X_$E(%DATA,OF,$L(%DATA))
	W " New:  ",X,!!
	D SAVEGLB
	S @%NODE=X
	Q
	;
OK()	; See if ok to change
	U 0 W !,%NODE,"=",%DATA,!
OK1	R "Change:  Yes, No, All, Quit?  ",X,!!
	S X=$TR($E(X),"ynaq","YNAQ")
	I X="A" S ALL=1 Q 1
	I X="Y" Q 1
	I X="N" Q 0
	I X="Q" S %STOP=1 Q 0
	G OK1
	;
SAVEGLB	; Save Old and New values of changes made through %GCHANGE
	;
	N RECSEQ
	;
	S RECSEQ=$O(^GCHGLOG(CDT,SEQ,""),-1)+1
	S ^GCHGLOG(CDT,SEQ,RECSEQ,1)=%NODE
	S ^GCHGLOG(CDT,SEQ,RECSEQ,2)=%DATA
	S ^GCHGLOG(CDT,SEQ,RECSEQ,3)=X
	Q
	;
REV	; Reverse changes made by %GCHANGE
	;
	N
	;
	S REV=1
	S HDR="Reverse changes made through GCHANGE"
	S %TAB("CDT")="/TYP=D/LEN=10/DES=Date of GCHANGE/TBL=^GCHGLOG("
	S %TAB("SEQ")="/TYP=N/LEN=12/DES=GCHANGE Sequence/TBL=[GCHGLOGHDR]:QU ""[GCHGLOGHDR]CDT=<<CDT>>"""
	S %READ="@HDR/REV/CEN,,CDT,SEQ"
	D ^UTLREAD
	I VFMQ="Q" Q
	;	
	S OLDCDT=CDT
	S UNAM=$$USERNAM^%ZFUNC
	S OLDSEQ=SEQ
	;
	; Check if sequence has already been reversed
	I $P(^GCHGLOG(OLDCDT,OLDSEQ),"|",7) W !,"Sequence has already been reversed",!  Q
	;
	S RECSEQ=""
	S %STOP=""
	S GBL=$P(^GCHGLOG(OLDCDT,OLDSEQ),"|",4)
	W " Global change being reversed:  ",GBL,!
	;
	; Set value to be reversed
	S FROMREV=$P(^GCHGLOG(OLDCDT,OLDSEQ),"|",5)
	;
	; Set original value
	S TOREV=$P(^GCHGLOG(OLDCDT,OLDSEQ),"|",6)
	S TO=$P(^GCHGLOG(OLDCDT,OLDSEQ),"|",6)
	;
	W !!,"Output results to "
	D ^%SCAIO Q:$G(ER)
	;
	W !,"For ",GBL," reverse all occurrences of ",TO," to ",FROMREV,!!
	;
	S (CNTNODES,CNT,ALL)=0
	;
	; Create top level of GCHGLOG
	S CDT=$P($H,",",1)
	S SEQ=$O(^GCHGLOG(CDT,""),-1)+1
	I $P(^GCHGLOG(OLDCDT,OLDSEQ),"|",7) Q
	L +^GCHGLOG(CDT,SEQ):2	
	S ^GCHGLOG(CDT,SEQ)=^GCHGLOG(OLDCDT,OLDSEQ)
	S $P(^GCHGLOG(CDT,SEQ),"|",5)=$P(^GCHGLOG(OLDCDT,OLDSEQ),"|",6)
	S $P(^GCHGLOG(CDT,SEQ),"|",6)=$P(^GCHGLOG(OLDCDT,OLDSEQ),"|",5)
	S $P(^GCHGLOG(OLDCDT,OLDSEQ),"|",7)=CDT
	S $P(^GCHGLOG(CDT,SEQ),"|",3)="Reversed sequence "_OLDSEQ
	L -^GCHGLOG(CDT,SEQ)
	;
	; Loop through ^GCHGLOG 
	F  S RECSEQ=$O(^GCHGLOG(OLDCDT,OLDSEQ,RECSEQ)) Q:RECSEQ=""  D
	.	I %STOP=1 Q
	.	S %NODE=^GCHGLOG(OLDCDT,OLDSEQ,RECSEQ,1)
	.	S %DATA=^GCHGLOG(OLDCDT,OLDSEQ,RECSEQ,3)
	.	S FROM=TOREV
	.	S TO=FROMREV
	.	S FROML=$L(FROM)
	.	I @%NODE'=%DATA D  Q
	..		S Y=@%NODE
	..		W !,"For ",GBL,"",!		
	..		W !,"",Y," does not match ",%DATA,". Cannot reverse.",!
	.	D CHANGE
	;
	; Do not file if reversal is not completed
	I CNTNODES=0 K ^GCHGLOG(CDT,SEQ)
	;
	D CLOSE^%SCAIO
	I CNTNODES>0  D 
	.	U 0 W !,"Report has been filed in spool directory.  GCHANGE.USERNAME",!
	.	U 0 W !!,CNTNODES," nodes reversed.  Total of ",CNT," occurrences.",!
	.	S IO1=$$SCAU^%TRNLNM("SPOOL","GCHANGE."_UNAM)
	.	S %BLK="/,"_IO1_","_CDT_","_SEQ
	.	S RID="GCHANGE"
	.	D DRV^URID
	E  U 0 W !!,CNTNODES," nodes reversed",!
	Q
	;
