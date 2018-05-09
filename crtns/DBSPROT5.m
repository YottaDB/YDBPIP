 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSPROT5 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSPROT5 ; 
 N vTp
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
 .	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
 .	;
 .	F  Q:'$$vFetch1()  D
 ..		;
 ..		N isOK S isOK=1
 ..		;
 ..  N dbtbl2,vop1,vop2,vop3 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),dbtbl2=$$vRCgetRecord1Opt^RecordDBTBL2(vop1,vop2,1,"")
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
 ...			N tmpdq S tmpdq=$$vcdmNew^RecordTMPDQ() S vobj(tmpdq,-3)=$J S vobj(tmpdq,-4)=vop2
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTMPDQ(tmpdq,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tmpdq,-100) S vobj(tmpdq,-2)=1 TC:vTp  
 ...			;
 ...			S CNT=CNT+1
 ...			K vobj(+$G(tmpdq)) Q 
 ..  Q 
 .	;
 .	I (+CNT'=+0) D EXT^DBSDSMC ; Compile them
 . Q 
 ;
 I doRpts D
 .	;
 .	N CNT S CNT=0
 .	;
 .	 N V1 S V1=$J D vDbDe2()
 .	;
 .	N ds,vos5,vos6,vos7,vos8 S ds=$$vOpen2()
 .	;
 .	F  Q:'$$vFetch2()  D
 ..		;
 ..		N isOK S isOK=1
 ..		;
 ..  N dbtbl5h,vop4,vop5,vop6 S vop4=$P(ds,$C(9),1),vop5=$P(ds,$C(9),2),dbtbl5h=$$vRCgetRecord1Opt^RecordDBTBL5H(vop4,vop5,1,"")
 ..		 S vop6=$G(^DBTBL(vop4,5,vop5,0))
 ..		;
 ..		I (FID'="ALL") D
 ...			;
 ...			N pfid S pfid=$P(vop6,$C(124),1)
 ...			;
 ...			I '((","_pfid_",")[(","_FID_",")) S isOK=0
 ...			Q 
 ..		;
 ..		I isOK D
 ...			;
 ...			N tmpdq S tmpdq=$$vcdmNew^RecordTMPDQ() S vobj(tmpdq,-3)=$J S vobj(tmpdq,-4)=vop5
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTMPDQ(tmpdq,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tmpdq,-100) S vobj(tmpdq,-2)=1 TC:vTp  
 ...			;
 ...			S CNT=CNT+1
 ...			K vobj(+$G(tmpdq)) Q 
 ..  Q 
 .	;
 .	I (+CNT'=+0) D EXT^DBSRWDRV ; Compile them
 . Q 
 ;
  N V1 S V1=$J D vDbDe3()
 ;
 Q 
 ;
PPFID ; Post processor for FID
 ;
 I (X="ALL") S I(3)=""
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60257^34992^Dan Russell^2020" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM TMPDQ WHERE PID = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM TMPDQ WHERE PID = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM TMPDQ WHERE PID = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; LIBS,SID FROM DBTBL2 WHERE LIBS='SYSDEV' AND RESFLG>0
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^DBTBL("SYSDEV",2,vos3),1) I vos3="" G vL1a0
 S vos4=$G(^DBTBL("SYSDEV",2,vos3,0))
 I '($P(vos4,"|",16)>0) G vL1a3
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S vos4=$G(^DBTBL("SYSDEV",2,vos3,0))
 S ds="SYSDEV"_$C(9)_$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; LIBS,RID FROM DBTBL5H WHERE LIBS='SYSDEV' AND RESFLG>0 AND NOT RID LIKE 'QWIK_%'
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=""
vL2a3 S vos7=$O(^DBTBL("SYSDEV",5,vos7),1) I vos7="" G vL2a0
 I '(vos7'?1"QWIK"1E1"".E) G vL2a3
 S vos8=$G(^DBTBL("SYSDEV",5,vos7,0))
 I '($P(vos8,"|",7)>0) G vL2a3
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos5=1 D vL2a3
 I vos5=2 S vos5=1
 ;
 I vos5=0 S ds="" Q 0
 ;
 S vos8=$G(^DBTBL("SYSDEV",5,vos7,0))
 S ds="SYSDEV"_$C(9)_$S(vos7=vos6:"",1:vos7)
 ;
 Q 1
 ;
vOpen3() ; PID,ELEMENT FROM TMPDQ WHERE PID = :V1
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL3a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen4() ; PID,ELEMENT FROM TMPDQ WHERE PID = :V1
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL4a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; PID,ELEMENT FROM TMPDQ WHERE PID = :V1
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL5a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
