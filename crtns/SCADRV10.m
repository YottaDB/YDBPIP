SCADRV10	;;Create/Modify Sub-menus
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV10 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	D INIT
	Q 
	;
INIT	;
	;
	S %PG=0
	S %PAGE=1
	S %O=0
	D VPG
	Q 
	;
VPG	; Page control
	;
	N FINISH
	N FN
	;
	S FN=""
	;
	S FINISH=0
	F  D  Q:FINISH 
	.	I %PG=0 D VPG00(.FN) I ER!(VFMQ="Q") S FINISH=1 Q 
	.	I %PG>0 D VPG01(FN)
	.	I "DFQ"[VFMQ D VER(FN) S FINISH=1 Q 
	.	S %PG=%PG+1
	.	Q 
	Q 
	;
VPG00(FN)	; Set up
	;
	S %TAB("FN")=".FN1/TBL=[SCATBL]"
	S %READ="@@%FN,,,FN/REQ"
	S %NOPRMT="N"
	;
	D ^UTLREAD
	I VFMQ="Q" Q 
	;
	N scatbl S scatbl=$$vDb3(FN)
	S DESC=$P(scatbl,$C(124),1)
	D PPG00(FN)
	Q 
	;
VPG01(FN)	; Call screen
	;
	N fSCATBL4 S fSCATBL4=$$vDbNew1("","")
	S vobj(fSCATBL4,-3)=FN
	;
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCATBL4",.fSCATBL4,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	K vobj(+$G(fSCATBL4)) Q 
	;
PPG00(FN)	; Set up repeat fields
	;
	N I
	N N
	;
	S N=""
	S I=1
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N scatbl4,vop1 S vop1=$P(rs,$C(9),2),scatbl4=$G(^SCATBL(4,$P(rs,$C(9),1),vop1))
	.	S N=vop1
	.	S LINK(I)=$TR($P(scatbl4,$C(124),2),"@")
	.	S DSC(I)=$P(scatbl4,$C(124),1)
	.	S I=I+1
	.	Q 
	;
	F I=I:1:15 D
	.	S LINK(I)=""
	.	S DSC(I)=""
	.	Q 
	S %REPEAT=15
	Q 
	;
ERR	;
	;
	S ER=1
	D ^UTLERR
	S VFMQ="Q"
	Q 
	;
VER(FN)	;
	;
	I VFMQ="Q" D END(FN) Q 
	D FILE(FN)
	I ER D ERR
	D END(FN)
	Q 
	;
FILE(FN)	; File data
	;
	N L N N N M
	N I
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	N scatbl4,vop1 S vop1=$P(rs,$C(9),2),scatbl4=$G(^SCATBL(4,$P(rs,$C(9),1),vop1))
	.	S OLDARR(vop1)=$P(scatbl4,$C(124),1)_"|"_$P(scatbl4,$C(124),2)
	.	 N V1 S V1=vop1 D vDbDe1()
	.	Q 
	;
	S N=""
	F I=1:1 S N=$order(LINK(N)) Q:N=""  D
	.	I LINK(N)="" Q 
	.	S NEWARR(I)=DSC(N)_"|@"_LINK(N)
	.	Q 
	;
	S (L,M)=""
	F  S M=$order(OLDARR(M)) Q:M=""  D
	.	S %O=3
	.	S SNAME=OLDARR(M)
	.	D vDbDe2()
	.	Q 
	;
	F  S L=$order(NEWARR(L)) Q:L=""  D
	.	S %O=0
	.	N fSCATBL4 S fSCATBL4=$$vDb2(FN,L)
	.	;
	. S $P(vobj(fSCATBL4),$C(124),1)=$piece(NEWARR(L),"|",1)
	. S $P(vobj(fSCATBL4),$C(124),2)=$piece(NEWARR(L),"|",2)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(fSCATBL4) S vobj(fSCATBL4,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(fSCATBL4)) Q 
	Q 
	;
END(FN)	;
	;
	I ER Q 
	I '($D(FN)#2) Q 
	;
	; Sub-menu for function ~p1 not modified
	I VFMQ="Q" S RM=$$^MSG(2564,FN)
	;
	; Sub-menu for function ~p1 modified
	E  S RM=$$^MSG(2563,FN)
	S ER="W"
	Q 
	;
vSIG()	;
	Q "60582^20585^SChhabria^4571" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SCATBL4 WHERE FN='FN' AND SEQ=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCATBL(4,v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM SCATBL4 WHERE FN=:FN AND SEQ=:M
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCATBL(4,v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(SCATBL4,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL4"
	S vobj(vOid)=$G(^SCATBL(4,v1,v2))
	I vobj(vOid)="",'$D(^SCATBL(4,v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1)	;	voXN = Db.getRecord(SCATBL,,0)
	;
	N scatbl
	S scatbl=$G(^SCATBL(1,v1))
	I scatbl="",'$D(^SCATBL(1,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCATBL" X $ZT
	Q scatbl
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(SCATBL4)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL4",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	FN,SEQ FROM SCATBL4 WHERE FN=:FN
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FN) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^SCATBL(4,vos2,vos3),1) I vos3="" G vL1a0
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
	S rs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	FN,SEQ FROM SCATBL4 WHERE FN=:FN
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FN) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^SCATBL(4,vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	FN,SEQ FROM SCATBL4 WHERE FN='FN' AND SEQ=:V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	I '($D(^SCATBL(4,"FN",vos2))#2) G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vRs="FN"_$C(9)_vos2
	S vos1=0
	;
	Q 1
	;
vOpen4()	;	FN,SEQ FROM SCATBL4 WHERE FN=:FN AND SEQ=:M
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(FN) I vos2="" G vL4a0
	S vos3=$G(M) I vos3="" G vL4a0
	I '($D(^SCATBL(4,vos2,vos3))#2) G vL4a0
	Q
	;
vFetch4()	;
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
vReSav1(fSCATBL4)	;	RecordSCATBL4 saveNoFiler(LOG)
	;
	D ^DBSLOGIT(fSCATBL4,vobj(fSCATBL4,-2))
	S ^SCATBL(4,vobj(fSCATBL4,-3),vobj(fSCATBL4,-4))=$$RTBAR^%ZFUNC($G(vobj(fSCATBL4)))
	Q
