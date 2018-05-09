SCADRV11	; Function/MRPC Userclass Authorization
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV11 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
ADD(LV)	; Add authorization
	;
	N HDRMSG N OPT
	;
	S OPT="A"
	;
	; The following authorization will be added:
	S HDRMSG=$$^MSG(6271)
	;
	D INIT
	;
	Q 
	;
DEL(LV)	;
	;
	N HDRMSG N OPT
	;
	S OPT="D"
	;
	; The following authorization will be deleted:
	S HDRMSG=$$^MSG(6272)
	;
	D INIT
	;
	Q 
	;
INIT	; Initialize query screen
	N vpc
	;
	N SEC
	N CNT N I N N
	N FNARR N HDG N MSG N OLNTB N PRM1 N PRM2 N %READ N UCLSARR N %UX N VFMQ
	;
	N scau0 S scau0=$$vDb5(%UCLS)
	N scatbl S scatbl=$$vDb6(%FN)
	;
	; Define current user's class as secure (SEC=1) or not secured (SEC=0)
	S SEC=$P(scau0,$C(124),6)
	;
	; Function description
	S HDG=$P(scatbl,$C(124),1)
	;
	D FN S vpc=('$D(FNARR)) Q:vpc  S vpc=(VFMQ="Q") Q:vpc 
	D UCLS S vpc=('$D(UCLSARR)) Q:vpc 
	;
	S vpc=(VFMQ="Q") Q:vpc 
	;
	S MSG(1)=PRM1
	S MSG(2)=""
	S CNT=2
	;
	S N=""
	F  S N=$order(FNARR(N)) Q:(N="")  D MSG(N)
	;
	S MSG(CNT+1)=""
	S MSG(CNT+2)=PRM2
	S MSG(CNT+3)=""
	S CNT=CNT+3
	;
	S N=""
	F  S N=$order(UCLSARR(N)) Q:(N="")  D MSG(N)
	;
	S %READ="@@%FN,,@HDRMSG,"
	;
	F I=1:1 Q:'$D(MSG(I))  S %READ=%READ_",@MSG("_I_")"
	;
	K OLNTB
	;
	S %UX=""
	;
	D ^UTLREAD Q:ER 
	;
	D VER
	;
	Q 
	;
VER	; Page control
	;
	I VFMQ'="Q" D FILE
	;
	D END
	;
	Q 
	;
FILE	; File data
	;
	N LOGIT
	N RPCID
	N FID N FN N SCATBL3 N SCATBL5A N UCLS N UX
	;
	S FN=""
	S UCLS=""
	;
	I LV=1 S FID="SCATBL3"
	I LV=5 S FID="SCATBL5A"
	;
	F  S FN=$order(FNARR(FN)) Q:(FN="")  D
	.	F  S UCLS=$order(UCLSARR(UCLS)) Q:(UCLS="")  D
	..		;
	..		S LOGIT=0
	..		;
	..		I LV=1,OPT="A" D  ; Add func. auth.
	...			N scatbl3 S scatbl3=$$vDb3(FN,UCLS)
	...			I $G(vobj(scatbl3,-2)) S $P(vobj(scatbl3),$C(124),1)=1
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCATBL3F(scatbl3,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scatbl3,-100) S vobj(scatbl3,-2)=1 Tcommit:vTp  
	...			S %O=0
	...			S SCATBL3=""
	...			S LOGIT=1
	...			K vobj(+$G(scatbl3)) Q 
	..		E  I LV=1,OPT="D" D  ; Delete func. auth.
	...			I '($D(^SCATBL(1,FN,UCLS))#2) Q 
	...			I $$SECURE(UCLS) D vDbDe1()
	...			S %O=3
	...			S LOGIT=1
	...			Q 
	..		E  I LV=5,OPT="A" D  ; Add MRPC auth.
	...			N scatbl5a S scatbl5a=$$vDb4(FN,UCLS)
	...			I $G(vobj(scatbl5a,-2)) K vobj(+$G(scatbl5a)) Q 
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(scatbl5a) S vobj(scatbl5a,-2)=1 Tcommit:vTp  
	...			S %O=0
	...			S SCATBL5A=""
	...			S LOGIT=1
	...			S RPCID=FN
	...			K vobj(+$G(scatbl5a)) Q 
	..		E  I LV=5,OPT="D" D  ; Delete MRPC auth.
	...			I '($D(^SCATBL(5,FN,UCLS))#2) Q 
	...			I $$SECURE(UCLS) D vDbDe2()
	...			S %O=3
	...			S LOGIT=1
	...			S RPCID=FN
	...			Q 
	..		;
	..		I LOGIT D ^DBSLOG(FID,%O,.UX)
	..		Q 
	.	Q 
	Q 
	;
SECURE(UCLS)	; Check for unsecured user deleting a secure userclass
	;
	I SEC Q 1
	;
	N scau0 S scau0=$$vDb5(UCLS)
	;
	I '$P(scau0,$C(124),6) Q 1
	;
	Q 0
	;
FN	; Create function input list
	;
	N FID
	;
	I LV=1 D
	.	S FID="[SCATBL]"
	.	S PRM1=$$DES^DBSDD("SCATBL.FN")
	.	Q 
	E  D
	.	S FID="[SCATBL5]"
	.	S PRM1=$$DES^DBSDD("SCATBL5.RPCID")
	.	Q 
	;
	D ^UTLLIST(FID,"FNARR",PRM1,HDG)
	;
	I 'ER K RM
	;
	Q 
	;
UCLS	; Create userclass input list
	;
	S PRM2=$$DES^DBSDD("SCAU0.UCLS")
	;
	D ^UTLLIST("[SCAU0]","UCLSARR",PRM2,HDG)
	;
	I 'ER K RM
	;
	Q 
	;
MSG(N)	; Build messages for display
	;
	I ($L(MSG(CNT))+$L(N))>79 S CNT=CNT+1
	;
	S MSG(CNT)=$get(MSG(CNT))_N_" "
	;
	Q 
	;
ERR	;
	;
	S ER=1
	D ^UTLERR
	S VFMQ="Q"
	;
	Q 
	;
END	;
	;
	Q:ER 
	;
	; Authorization not modified
	I VFMQ="Q" S RM=$$^MSG(312)
	; Authorization modified
	E  S RM=$$^MSG(311)
	;
	S ER="W"
	;
	Q 
	;
vSIG()	;
	Q "60773^54317^Aries Beltran^4776" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SCATBL3 WHERE FN=:FN AND UCLS=:UCLS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb3(FN,UCLS)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^SCATBL3F(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM SCATBL5A WHERE RPCID=:FN AND UCLS=:UCLS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCATBL(5,v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb3(v1,v2)	;	vobj()=Db.getRecord(SCATBL3,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL3"
	S vobj(vOid)=$G(^SCATBL(1,v1,v2))
	I vobj(vOid)="",'$D(^SCATBL(1,v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb4(v1,v2)	;	vobj()=Db.getRecord(SCATBL5A,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL5A"
	S vobj(vOid)=$G(^SCATBL(5,v1,v2))
	I vobj(vOid)="",'$D(^SCATBL(5,v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb5(v1)	;	voXN = Db.getRecord(SCAU0,,0)
	;
	N scau0
	S scau0=$G(^SCAU(0,v1))
	I scau0="",'$D(^SCAU(0,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU0" X $ZT
	Q scau0
	;
vDb6(v1)	;	voXN = Db.getRecord(SCATBL,,0)
	;
	N scatbl
	S scatbl=$G(^SCATBL(1,v1))
	I scatbl="",'$D(^SCATBL(1,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCATBL" X $ZT
	Q scatbl
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(SCATBL5A)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL5A",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	RPCID,UCLS FROM SCATBL5A WHERE RPCID=:FN AND UCLS=:UCLS
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FN) I vos2="" G vL1a0
	S vos3=$G(UCLS) I vos3="" G vL1a0
	I '($D(^SCATBL(5,vos2,vos3))#2) G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vRs=vos2_$C(9)_vos3
	S vos1=0
	;
	Q 1
	;
vReSav1(scatbl5a)	;	RecordSCATBL5A saveNoFiler(LOG)
	;
	D ^DBSLOGIT(scatbl5a,vobj(scatbl5a,-2))
	S ^SCATBL(5,vobj(scatbl5a,-3),vobj(scatbl5a,-4))=$$RTBAR^%ZFUNC($G(vobj(scatbl5a)))
	Q
