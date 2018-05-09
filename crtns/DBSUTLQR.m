 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSUTLQR ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
DBSUTLQR ; 
 ;
 Q  ; DO NOT CALL AT TOP.
 ;
COPY(DQSCR) ; COPY DQ DEFINITION
 N vTp
 ;
 N DBOPT N isDone N isExist N OLNTB
 N %NOPRMT N %READ N AGID N CQRID N DLIB N DQTABLE N DQREF N FID
 N FIND N IDEXCH N NAME N NQRID N OID N PID N QID N QRID N RID N SID
 N TLIB N TABLE N VFMQ
 ;
 S DQTABLE="DBTBL5Q" S DBOPT=6
 S QRID=$$FIND^DBSGETID("DBTBL5Q",0) I QRID="" Q 
 ;
 N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=DQTABLE,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",DQTABLE,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,16))
 S NAME=$P(vop3,$C(124),1)
 S NAME=$piece(NAME,",",$L(NAME,","))
 ;
 N d5q S d5q=$$vRCgetRecord0^RecordDBTBL5Q("SYSDEV",QRID,0)
 I DQSCR'="" S %O=2 S %NOPRMT="Q" D @DQSCR
 ;
 S TLIB="SYSDEV" S OLNTB=22020 S DQREF=DQTABLE
 S DQREF="["_DQREF_"]"_NAME
 S CQRID=QRID
 ;
 S (FID,SID,QID,QRID,RID,PID,AGID,IDEXCH)=""
 S %READ=DQREF_"/TBL="_$piece(DQREF,"]",1)_"]/XPP=D PP^DBSUTL"
 ;
 N dbctl S dbctl=$G(^DBCTL("SYS","DBOPT",DBOPT))
 ;
 S %READ=%READ_"/TYP=U/DES=To "_$P(dbctl,$C(124),1)_" Definition Name"
 S %NOPRMT="F" D ^UTLREAD I VFMQ'="F" K vobj(+$G(d5q)) Q 
 ;
 S DQREF=$piece(DQREF,"]",2)
 S NQRID=@DQREF
 ;
 TS (vobj):transactionid="CS"
 ;
 N d5qn S d5qn=$$vReCp1(d5q)
  S vobj(d5qn,-4)=NQRID
  S vobj(d5qn,-100,0)="" S $P(vobj(d5qn,0),$C(124),2)=""
  S vobj(d5qn,-100,0)="" S $P(vobj(d5qn,0),$C(124),3)=TJD
  S vobj(d5qn,-100,0)="" S $P(vobj(d5qn,0),$C(124),15)=$$USERNAM^%ZFUNC
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav1(d5qn) K vobj(d5qn,-100) S vobj(d5qn,-2)=1 TC:vTp  
 ;
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
 F  Q:'$$vFetch1()  D
 .	;
 . N dbtbl6f S dbtbl6f=$$vRCgetRecord1^RecordDBTBL6F($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1)
 .	N dbtbl6fn,vop4,vop5,vop6,vop7 S dbtbl6fn=$$vReCp2(dbtbl6f)
 .	;
 .  S vop5=NQRID
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^DBTBL(vop6,6,vop5,vop4)=$$RTBAR^%ZFUNC(dbtbl6fn) S vop7=1 TC:vTp  
 .	;
 . K vobj(+$G(dbtbl6f)) Q 
 ;
 N ds2,vos5,vos6,vos7,vos8 S ds2=$$vOpen2()
 F  Q:'$$vFetch2()  D
 .	;
 . N dbtblsq S dbtblsq=$$vRCgetRecord1^RecordDBTBL6SQ($P(ds2,$C(9),1),$P(ds2,$C(9),2),$P(ds2,$C(9),3),1)
 .	N dbtblsqn,vop8,vop9,vop10,vop11 S dbtblsqn=$$vReCp3(dbtblsq)
 .	;
 .  S vop9=NQRID
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^DBTBL(vop10,6,vop9,vop8)=$$RTBAR^%ZFUNC(dbtblsqn) S vop11=1 TC:vTp  
 .	;
 . K vobj(+$G(dbtblsq)) Q 
 ;
  TC:$TL 
 ;
 K vobj(+$G(d5q)),vobj(+$G(d5qn)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61116^42997^Dan Russell^2356" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:CQRID ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(CQRID) I vos3="" G vL1a0
 S vos4=100
vL1a4 S vos4=$O(^DBTBL("SYSDEV",6,vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:CQRID ORDER BY SEQ ASC
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(CQRID) I vos7="" G vL2a0
 S vos8=20
vL2a4 S vos8=$O(^DBTBL("SYSDEV",6,vos7,vos8),1) I vos8=""!(vos8'<41) G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos5=1 D vL2a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S ds2="" Q 0
 ;
 S ds2="SYSDEV"_$C(9)_vos7_$C(9)_$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBTBL5Q.copy: DBTBL5Q
 ;
 N vNod,vOid
 I $G(vobj(v1,-2)) D
 .	F vNod=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),6,vobj(v1,-4),vNod))
 S vOid=$$copy^UCGMR(v1)
 Q vOid
 ;
vReCp2(v1) ; RecordDBTBL6F.copy: DBTBL6F
 ;
 S vop4=vobj(v1,-5)
 S vop5=vobj(v1,-4)
 S vop6=vobj(v1,-3)
 S vop7=vobj(v1,-2)
 Q vobj(v1)
 ;
vReCp3(v1) ; RecordDBTBL6SQ.copy: DBTBL6SQ
 ;
 S vop8=vobj(v1,-5)
 S vop9=vobj(v1,-4)
 S vop10=vobj(v1,-3)
 S vop11=vobj(v1,-2)
 Q vobj(v1)
 ;
vReSav1(d5qn) ; RecordDBTBL5Q saveNoFiler()
 ;
 S ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4))=$$RTBAR^%ZFUNC($G(vobj(d5qn)))
 N vD,vN S vN=-1
 I '$G(vobj(d5qn,-2)) F  S vN=$O(vobj(d5qn,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(d5qn,vN)) S:vD'="" ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4),vN)=vD
 E  F  S vN=$O(vobj(d5qn,-100,vN)) Q:vN=""  I $D(vobj(d5qn,vN))#2 S vD=$$RTBAR^%ZFUNC(vobj(d5qn,vN)) S:vD'="" ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4),vN)=vD I vD="" ZWI ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4),vN)
 Q
