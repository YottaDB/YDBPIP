 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRWDST ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRWDST ; 
 ;
 Q  ; Can't call from top
 ;
EXEC ; Public - Run report in distribution mode (called by function DBSEXERDIST)
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
EXT(RID,VMODE) ; 
 ;
 N DISTKEY N PGM N POP N VRWOPT N VTBLNAM
 ;
 N dbtbl5h,vop1,vop2,vop3 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vRCgetRecord1Opt^RecordDBTBL5H("SYSDEV",RID,0,"")
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
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=$J S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 .	N IO N VDISTKEY N VRWOPT
 .	;
 . S VDISTKEY=rs ; Value of column
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
 ..		N ds,vos5,vos6,vos7,vos8,vos9  N V2 S V2=$J S ds=$$vOpen2()
 ..		;
 ..		F  Q:'$$vFetch2()  D
 ...   N vo1,vop4,vop5,vop6,vop7 S vop4=$P(ds,$C(9),1),vop5=$P(ds,$C(9),2),vop6=$P(ds,$C(9),3),vo1=$$vRCgetRecord1Opt^RecordTMPRPTDS(vop4,vop5,vop6,1,"")
 ...			 S vop7="" N von S von="" F  S von=$O(^TMPRPTDS(vop4,vop5,vop6,von)) quit:von=""  S vop7=vop7_^TMPRPTDS(vop4,vop5,vop6,von)
 ...			WRITE !,vop7
 ...   Q 
 ..		CLOSE IO
 ..  Q 
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
BBMBIO(RID,DISTKEY,VALUE) ; 
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
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60107^27446^Viji Skariah^4296" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; DISTINCT DISTKEY FROM TMPRPTDS WHERE JOBNO=:V1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL1a4 S vos4=$O(^TMPRPTDS(vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; JOBNO,DISTKEY,SEQ FROM TMPRPTDS WHERE JOBNO=:V2 AND DISTKEY=:VDISTKEY ORDER BY SEQ ASC
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(V2)
 S vos8=$G(VDISTKEY) I vos8="" G vL2a0
 S vos9=""
vL2a5 S vos9=$O(^TMPRPTDS(vos7,vos8,vos9),1) I vos9="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos5=1 D vL2a5
 I vos5=2 S vos5=1
 ;
 I vos5=0 S ds="" Q 0
 ;
 S ds=vos7_$C(9)_vos8_$C(9)_$S(vos9=vos6:"",1:vos9)
 ;
 Q 1
