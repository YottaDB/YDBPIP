DBSUTLQR	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSUTLQR ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	Q  ; DO NOT CALL AT TOP.
	;
COPY(DQSCR)	; COPY DQ DEFINITION
	;
	N DBOPT N isDone N isExist N OLNTB
	N CQRID N DQTABLE N DQREF N NAME N NQRID N FIND
	N OID N QRID N TLIB N DLIB N TABLE
	;
	S DQTABLE="DBTBL5Q" S DBOPT=6
	S QRID=$$FIND^DBSGETID("DBTBL5Q",0) I QRID="" Q 
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=DQTABLE,dbtbl1=$$vDb5("SYSDEV",DQTABLE)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	S NAME=$P(vop3,$C(124),1)
	S NAME=$piece(NAME,",",$L(NAME,","))
	;
	N d5q S d5q=$$vDb2("SYSDEV",QRID)
	I DQSCR'="" S %O=2 S %NOPRMT="Q" D @DQSCR
	;
	S TLIB="SYSDEV" S OLNTB=22020 S DQREF=DQTABLE
	S DQREF="["_DQREF_"]"_NAME
	S CQRID=QRID
	;
	S (FID,SID,QID,QRID,RID,PID,AGID,IDEXCH)=""
	S %READ=DQREF_"/TBL="_$piece(DQREF,"]",1)_"]/XPP=D PP^DBSUTL"
	;
	S %READ=%READ_"/TYP=U/DES=To "_^DBCTL("SYS","DBOPT",DBOPT)_" Definition Name"
	S %NOPRMT="F" D ^UTLREAD I VFMQ'="F" K vobj(+$G(d5q)) Q 
	;
	S DQREF=$piece(DQREF,"]",2)
	S NQRID=@DQREF
	;
	Tstart (vobj):transactionid="CS"
	;
	N d5qn S d5qn=$$vReCp1(d5q)
	S vobj(d5qn,-4)=NQRID
	S vobj(d5qn,-100,0)="",$P(vobj(d5qn,0),$C(124),2)=""
	S vobj(d5qn,-100,0)="",$P(vobj(d5qn,0),$C(124),3)=TJD
	S vobj(d5qn,-100,0)="",$P(vobj(d5qn,0),$C(124),15)=$$USERNAM^%ZFUNC
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(d5qn) K vobj(d5qn,-100) S vobj(d5qn,-2)=1 Tcommit:vTp  
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	;
	.	N dbtbl6f S dbtbl6f=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	N dbtbl6fn,vop4,vop5,vop6,vop7 S dbtbl6fn=$$vReCp2(dbtbl6f)
	.	;
	. S vop5=NQRID
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop6,6,vop5,vop4)=$$RTBAR^%ZFUNC(dbtbl6fn) S vop7=1 Tcommit:vTp  
	.	;
	.	K vobj(+$G(dbtbl6f)) Q 
	;
	N ds,vos4,vos5,vos6 S ds=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	;
	.	N dbtblsq S dbtblsq=$$vDb4($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	N dbtblsqn,vop8,vop9,vop10,vop11 S dbtblsqn=$$vReCp3(dbtblsq)
	.	;
	. S vop9=NQRID
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop10,6,vop9,vop8)=$$RTBAR^%ZFUNC(dbtblsqn) S vop11=1 Tcommit:vTp  
	.	;
	.	K vobj(+$G(dbtblsq)) Q 
	;
	Tcommit:$Tlevel 
	;
	K vobj(+$G(d5q)),vobj(+$G(d5qn)) Q 
	;
DEL(DQSCR)	; COPY DQ DEFINITION
	;
	N isDone N isExist
	N NAME N DBOPT N FIND N OID N TLIB N DLIB N TABLE N PGM N RPGM
	;
	S DQTABLE="DBTBL5Q" S DBOPT=6
	S QRID=$$FIND^DBSGETID("DBTBL5Q",0) I QRID="" Q 
	S RPGM=$piece(DQSCR,"(",1)
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=DQTABLE,dbtbl1=$$vDb5("SYSDEV",DQTABLE)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	S NAME=$P(vop3,$C(124),1)
	S NAME=$piece(NAME,",",$L(NAME,","))
	;
	N d5q S d5q=$$vDb2("SYSDEV",QRID)
	 S vobj(d5q,0)=$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0))
	S PGM=$P(vobj(d5q,0),$C(124),2)
	I DQSCR'="" S %O=3 S %NOPRMT="Q" D @DQSCR
	;
	; PROMPT - ARE YOU SURE
	I $$^DBSMBAR(163)'=2 K vobj(+$G(d5q)) Q 
	;
	; DELETE FORMAT INFORMATION
	D vDbDe1()
	;
	; DELETE STATISTICS PAGE DATA
	D vDbDe2()
	;
	; change mode to delete and save.
	S vobj(d5q,-2)=3
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL5QL(d5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(d5q,-100) S vobj(d5q,-2)=1 Tcommit:vTp  
	;
	; DELETE RUN TIME CODE
	I '(PGM="") D DEL^%ZRTNDEL(PGM)
	;
	; Write done
	WRITE !,"QWIK REPORT "_QRID_" DELETED"
	;
	; hang for a sec
	HANG 1
	;
	K vobj(+$G(d5q)) Q 
	;
vSIG()	;
	Q "60558^39860^Badrinath Giridharan^2922" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL6F WHERE QRID=:QRID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,6,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL6SQ WHERE QID=:QRID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,6,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL5Q,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5Q"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,6,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5Q" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL6F,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL6F"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2,v3))
	I '(v3>100)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,6,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL6SQ,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL6SQ"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2,v3))
	I '(v3>20)
	E  I '(v3<41&(v3'=""))
	E  I vobj(vOid)="",'$D(^DBTBL(v1,6,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vOpen1()	;	LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:CQRID ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(CQRID) I vos2="" G vL1a0
	S vos3=100
vL1a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3="" G vL1a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:CQRID ORDER BY SEQ ASC
	;
	;
	S vos4=2
	D vL2a1
	Q ""
	;
vL2a0	S vos4=0 Q
vL2a1	S vos5=$G(CQRID) I vos5="" G vL2a0
	S vos6=20
vL2a3	S vos6=$O(^DBTBL("SYSDEV",6,vos5,vos6),1) I vos6=""!(vos6'<41) G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos4=1 D vL2a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos5_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen3()	;	LIBS,QRID,SEQ FROM DBTBL6F WHERE QRID=:QRID
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(QRID) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL3a0
	S vos4=100
vL3a5	S vos4=$O(^DBTBL(vos3,6,vos2,vos4),1) I vos4="" G vL3a3
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos3=$C(254):"",1:vos3)_$C(9)_vos2_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen4()	;	LIBS,QID,SEQ FROM DBTBL6SQ WHERE QID=:QRID
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(QRID) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL4a0
	S vos4=20
vL4a5	S vos4=$O(^DBTBL(vos3,6,vos2,vos4),1) I vos4=""!(vos4'<41) G vL4a3
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos3=$C(254):"",1:vos3)_$C(9)_vos2_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL5Q.copy: DBTBL5Q
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),6,vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReCp2(v1)	;	RecordDBTBL6F.copy: DBTBL6F
	;
	S vop4=vobj(v1,-5)
	S vop5=vobj(v1,-4)
	S vop6=vobj(v1,-3)
	S vop7=vobj(v1,-2)
	Q vobj(v1)
	;
vReCp3(v1)	;	RecordDBTBL6SQ.copy: DBTBL6SQ
	;
	S vop8=vobj(v1,-5)
	S vop9=vobj(v1,-4)
	S vop10=vobj(v1,-3)
	S vop11=vobj(v1,-2)
	Q vobj(v1)
	;
vReSav1(d5qn)	;	RecordDBTBL5Q saveNoFiler()
	;
	S ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4))=$$RTBAR^%ZFUNC($G(vobj(d5qn)))
	N vD,vN S vN=-1
	I '$G(vobj(d5qn,-2)) F  S vN=$O(vobj(d5qn,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(d5qn,vN)) S:vD'="" ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4),vN)=vD
	E  F  S vN=$O(vobj(d5qn,-100,vN)) Q:vN=""  I $D(vobj(d5qn,vN))#2 S vD=$$RTBAR^%ZFUNC(vobj(d5qn,vN)) S:vD'="" ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4),vN)=vD I vD="" ZWI ^DBTBL(vobj(d5qn,-3),6,vobj(d5qn,-4),vN)
	Q
