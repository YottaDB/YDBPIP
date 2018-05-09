DBSUTL5	;
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/07/03 12:01:03 - GRAY
	;     ORIG:  MARTY RONKY (3623) - 04/21/87
	;     DESC:  Remove run-time routine name from screen/report definitions
	;
	;---------- Revision History -------------------------------------------
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	;  07/07/03 - GRAY - 51351
	;	      Removed references to DBTBL level 16 since the data
	;	      exchange functionality was obsoleted.
	;
	;-----------------------------------------------------------------------
START	;
	; I18N=QUIT
	;
	N NAME,CNT,XN,SID,RID,QRID,AGID
	K OLNTB
	S %FN=$G(%FN)
	I $G(%LIBS)="" S %LIBS=^CUVAR("%LIBS")
	;
	S %TAB("SID")="[DBTBL2]SID/TYP=L/LEN=1"	; *** 09/12/97
	S %TAB("RID")="[DBTBL5H]RID/TYP=L/LEN=1"
	S %TAB("QRID")="[DBTBL5Q]QRID/TYP=L/LEN=1"
	S %TAB("AGID")="[DBTBL22]AGID/TYP=L/LEN=1"
	;
	S %READ="@@%FN,SID/NOREQ,RID/NOREQ,QRID/NOREQ,AGID/NOREQ"	; ***
	S %FRAME=2 D ^UTLREAD I VFMQ="Q" Q	; frame option
	;
	I SID S DBOPT=2 D DELETE("DBTBL2")		; Remove screen names
	I RID S DBOPT=5 D DELETE("DBTBL5H")		; Remove report names
	I QRID S DBOPT=6 D DELETE("DBTBL5Q")		; remove QWIK report name
	I AGID S DBOPT=22 D DELETE("DBTBL22")		; Aggregate name
	Q
	;
DELETE(FID)	;
	K ZSEL
	S CNT=$$LIST^DBSGETID(FID) Q:'CNT
	S CNT=0
	S KEY="" F  S KEY=$O(^TEMP($J,KEY)) Q:KEY=""  D
	.	;
	.	I DBOPT=22 D AGG Q
	.	I '$D(^DBTBL(%LIBS,DBOPT,KEY,0)) Q
	.	S $P(^(0),"|",2)="",CNT=CNT+1
	.	I $G(^DBTBL(%LIBS,DBOPT,KEY,-3))="" Q	; Remove names from
	.	S LIB=^(-3) I '$D(^DBTBL(LIB,DBOPT,KEY,0)) Q	; target library
	.	S $P(^(0),"|",2)="" D MSG1
	;
	S Z=CNT_" routine name(s) removed"
	W !!,$$MSG^%TRMVT(Z,"",1)
	Q
AGG	;
	S $P(^DBTBL(%LIBS,22,KEY),"|",4)="",CNT=CNT+1
	Q
	;
	;   
MSG1	W " and also from library:",LIB Q
	Q
