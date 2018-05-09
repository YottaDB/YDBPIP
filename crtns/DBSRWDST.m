DBSRWDST	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRWDST ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; Can't call from top
	;
EXEC	; Public - Run report in distribution mode (called by function DBSEXERDIST)
	;
	N %FRAME N OLNTB N VMODE
	N %NOPRMT N QRY N %READ N RID N %TAB N VFMQ
	;
	S QRY="[DBTBL5H]DISTKEY'="""""
	;
	S %TAB("RID")=".RID2/TBL=[DBTBL5H]RID,DESC:QU QRY"
	S %TAB("VMODE")=".TABFMT"
	;
	S OLNTB=40 S %FRAME=2
	S %READ="@@%FN,,RID/REQ,VMODE/REQ" S %NOPRMT="F"
	;
	D ^UTLREAD
	Q:VFMQ="Q" 
	;
	D EXT(RID,VMODE)
	;
	Q 
	;
EXT(RID,VMODE)	;
	;
	N DISTKEY N PGM N POP N VRWOPT N VTBLNAM
	;
	N dbtbl5h,vop1,vop2,vop3 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vDb3("SYSDEV",RID)
	 S vop3=$G(^DBTBL(vop1,5,vop2,0))
	;
	S PGM=$P(vop3,$C(124),2) ; Run-time name
	I PGM="" D  Q 
	.	S ER=1
	.	; ~p1 Missing run-time routine name ~p2
	.	S RM=$$^MSG(3056,RID)
	.	Q 
	;
	S DISTKEY=$P(vop3,$C(124),20)
	I DISTKEY="" D  Q 
	.	S ER=1
	.	; Invalid function ~p1
	.	S RM=$$^MSG(1361,"DBSEXERDIST")
	.	Q 
	;
	; Delete any old data
	K ^TMPRPTDS($J)
	;
	USE 0
	S POP=0 D ^SCAIO ; Set device to 0
	S VRWOPT("NOOPEN")=1 ; Don't open it
	S VTBLNAM=RID ; Distribution mode
	;
	D ^@PGM ; Create result set
	K VTBLNAM ; Clear signal
	;
	; Produce individual reports by the distribution key values
	S DISTKEY=$piece(DISTKEY,".",2) ; Just use column name
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$J S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N IO N VDISTKEY N VRWOPT
	.	;
	.	S VDISTKEY=rs ; Value of column
	.	;
	.	; Set up output device
	.	D
	..		N IODEL N POP
	..		S IODEL=$$IODEL^%ZFUNC() ; Platform specific device delimiter
	..		S POP=RID_".RPT"_IODEL_"DATE/RDIST="_DISTKEY_"_"_$TR(VDISTKEY,",","Z")
	..		D ^SCAIO
	..		Q 
	.	;
	.	I $get(VMODE) D  ; Raw data
	..		N HEADER N MAP
	..		;
	..		S MAP=$$VMAP^@PGM ; SELECT list
	..		;
	..		S HEADER=$TR(MAP,",",$char(9)) ; Column names
	..		USE IO
	..		WRITE HEADER
	..		;
	..		N ds,vos4,vos5,vos6,vos7  N V2 S V2=$J S ds=$$vOpen2()
	..		;
	..		F  Q:'($$vFetch2())  D
	...			N vo1,vop4,vop5,vop6,vop7 S vop4=$P(ds,$C(9),1),vop5=$P(ds,$C(9),2),vop6=$P(ds,$C(9),3),vo1=$$vDb4(vop4,vop5,vop6)
	...			 S vop7="" N von S von="" F  S von=$O(^TMPRPTDS(vop4,vop5,vop6,von)) quit:von=""  S vop7=vop7_^TMPRPTDS(vop4,vop5,vop6,von)
	...			WRITE !,vop7
	...			Q 
	..		CLOSE IO
	..		Q 
	.	;
	.	E  D  ; Report format
	..		N VRWOPT
	..		;
	..		S VRWOPT("NOBANNER")=1 ; Skip banner page
	..		D V0^@PGM
	..		Q 
	.	Q 
	;
	; Delete temporary table
	K ^TMPRPTDS($J)
	;
	Q 
	;
BBMBIO(RID,DISTKEY,VALUE)	;
	;
	N IO N IODEL N PATH N POP
	;
	S IODEL=$$IODEL^%ZFUNC() ; Platform specific device delimiter
	;
	I (DISTKEY="BOO")!(DISTKEY="BRCD")!(DISTKEY="CC") D
	.	S PATH=$$TRNLNM^%ZFUNC("/sp"_VALUE_"ibs")
	.	I PATH'="" S PATH=$$BLDPATH^%TRNLNM(PATH,RID_".RPT"_IODEL_"DATE")
	.	Q 
	;
	I $get(PATH)'="" S POP=PATH
	E  S POP=RID_".RPT"_IODEL_"DATE/RDIST="_DISTKEY_"_"_$TR(VALUE,".","Z")
	;
	D ^SCAIO
	Q IO
	;
vSIG()	;
	Q "60107^24092^sviji^4238" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL5H,,1)
	;
	N dbtbl5h
	S dbtbl5h=$G(^DBTBL(v1,5,v2))
	I dbtbl5h="",'$D(^DBTBL(v1,5,v2))
	;
	Q dbtbl5h
	;
vDb4(v1,v2,v3)	;	voXN = Db.getRecord(TMPRPTDS,,1)
	;
	N vo1
	S vo1=$G(^TMPRPTDS(v1,v2,v3))
	I vo1="",'$D(^TMPRPTDS(v1,v2,v3))
	;
	Q vo1
	;
vOpen1()	;	DISTINCT DISTKEY FROM TMPRPTDS WHERE JOBNO=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TMPRPTDS(vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	JOBNO,DISTKEY,SEQ FROM TMPRPTDS WHERE JOBNO=:V2 AND DISTKEY=:VDISTKEY ORDER BY SEQ ASC
	;
	;
	S vos4=2
	D vL2a1
	Q ""
	;
vL2a0	S vos4=0 Q
vL2a1	S vos5=$G(V2) I vos5="" G vL2a0
	S vos6=$G(VDISTKEY) I vos6="" G vL2a0
	S vos7=""
vL2a4	S vos7=$O(^TMPRPTDS(vos5,vos6,vos7),1) I vos7="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos4=1 D vL2a4
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S ds=vos5_$C(9)_vos6_$C(9)_$S(vos7=$C(254):"",1:vos7)
	;
	Q 1
