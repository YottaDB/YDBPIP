DBSPROT5	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSPROT5 ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N doRpts N doScrns
	N %FRAME N OLNTB
	N %READ N %TAB N FID N VFMQ
	;
	S %TAB("FID")=".FID1/TBL=[DBTBL1]/XPP=D PPFID^DBSPROT5"
	S %TAB("doScrns")=".ZSCREEN1"
	S %TAB("doRpts")=".ZREPORT1"
	;
	S FID="ALL"
	S (doRpts,doScrns)=1
	;
	S %FRAME=2
	S %READ="@@%FN,,FID/REQ,,doScrns/REQ,,doRpts/REQ,"
	;
	D ^UTLREAD Q:(VFMQ="Q") 
	;
	; Select screen/report ID
	;
	I doScrns D
	.	;
	.	N CNT S CNT=0
	.	;
	.	 N V1 S V1=$J D vDbDe1()
	.	;
	.	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
	.	;
	.	F  Q:'($$vFetch1())  D
	..		;
	..		N isOK S isOK=1
	..		;
	..		N dbtbl2,vop1,vop2,vop3 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),dbtbl2=$G(^DBTBL(vop1,2,vop2))
	..		 S vop3=$G(^DBTBL(vop1,2,vop2,0))
	..		;
	..		I (FID'="ALL") D
	...			;
	...			N pfid S pfid=$P(vop3,$C(124),1)
	...			;
	...			I '((","_pfid_",")[(","_FID_",")) S isOK=0
	...			Q 
	..		;
	..		I isOK D
	...			;
	...			N tmpdq,vop4,vop5,vop6 S tmpdq="",vop5=$J,vop4=vop2,vop6=0
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TEMP(vop5,vop4)=tmpdq S vop6=1 Tcommit:vTp  
	...			;
	...			S CNT=CNT+1
	...			Q 
	..		Q 
	.	;
	.	I (+CNT'=+0) D EXT^DBSDSMC ; Compile them
	.	Q 
	;
	I doRpts D
	.	;
	.	N CNT S CNT=0
	.	;
	.	 N V1 S V1=$J D vDbDe2()
	.	;
	.	N ds,vos4,vos5,vos6 S ds=$$vOpen2()
	.	;
	.	F  Q:'($$vFetch2())  D
	..		;
	..		N isOK S isOK=1
	..		;
	..		N dbtbl5h,vop7,vop8,vop9 S vop7=$P(ds,$C(9),1),vop8=$P(ds,$C(9),2),dbtbl5h=$G(^DBTBL(vop7,5,vop8))
	..		 S vop9=$G(^DBTBL(vop7,5,vop8,0))
	..		;
	..		I (FID'="ALL") D
	...			;
	...			N pfid S pfid=$P(vop9,$C(124),1)
	...			;
	...			I '((","_pfid_",")[(","_FID_",")) S isOK=0
	...			Q 
	..		;
	..		I isOK D
	...			;
	...			N tmpdq,vop10,vop11,vop12 S tmpdq="",vop11=$J,vop10=vop8,vop12=0
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TEMP(vop11,vop10)=tmpdq S vop12=1 Tcommit:vTp  
	...			;
	...			S CNT=CNT+1
	...			Q 
	..		Q 
	.	;
	.	I (+CNT'=+0) D EXT^DBSRWDRV ; Compile them
	.	Q 
	;
	 N V1 S V1=$J D vDbDe3()
	;
	Q 
	;
PPFID	; Post processor for FID
	;
	I (X="ALL") S I(3)=""
	;
	Q 
	;
vSIG()	;
	Q "60257^34981^Dan Russell^2011" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID = :V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM TMPDQ WHERE PID = :V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM TMPDQ WHERE PID = :V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vOpen1()	;	LIBS,SID FROM DBTBL2 WHERE LIBS='SYSDEV' AND RESFLG>0
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^DBTBL("SYSDEV",2,vos2),1) I vos2="" G vL1a0
	S vos3=$G(^DBTBL("SYSDEV",2,vos2,0))
	I '($P(vos3,"|",16)>0) G vL1a2
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	LIBS,RID FROM DBTBL5H WHERE LIBS='SYSDEV' AND RESFLG>0 AND NOT RID LIKE 'QWIK_%'
	;
	;
	S vos4=2
	D vL2a1
	Q ""
	;
vL2a0	S vos4=0 Q
vL2a1	S vos5=""
vL2a2	S vos5=$O(^DBTBL("SYSDEV",5,vos5),1) I vos5="" G vL2a0
	I '(vos5'?1"QWIK"1E1"".E) G vL2a2
	S vos6=$G(^DBTBL("SYSDEV",5,vos5,0))
	I '($P(vos6,"|",7)>0) G vL2a2
	Q
	;
vFetch2()	;
	;
	;
	I vos4=1 D vL2a2
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen3()	;	PID,ELEMENT FROM TMPDQ WHERE PID = :V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	PID,ELEMENT FROM TMPDQ WHERE PID = :V1
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V1) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen5()	;	PID,ELEMENT FROM TMPDQ WHERE PID = :V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
