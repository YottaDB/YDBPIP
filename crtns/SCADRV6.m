SCADRV6	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV6 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
UPD	;
	D INIT(1)
	Q 
	;
INQ	;
	;
	D INIT(2)
	Q 
	;
INIT(%O)	; init variables
	N FINISH S FINISH=0
	N %PG S %PG=0 N %PAGE S %PAGE=10
	N SEC
	;
	N scau0 S scau0=$$vDb5(%UCLS)
	S SEC=$P(scau0,$C(124),6)
	;
	N fSCATBL
	N fSCATBL3
	;
	F  D  Q:FINISH 
	.	I %PG=0 D VPG00(.fSCATBL,.fSCATBL3) I VFMQ="Q" S FINISH=1 Q 
	.	;
	.	I %PG>0 D VPG01(.fSCATBL,.fSCATBL3)
	.	;
	.	I "DFQ"[VFMQ D VER(.fSCATBL3) S FINISH=1 Q 
	.	;
	.	S %PG=%PG+1
	.	Q 
	;
	D vKill1("") K vobj(+$G(fSCATBL)) Q 
	;
VPG00(fSCATBL,fSCATBL3)	;
	;
	N I
	;
	S %TAB("FUN")=".FUN1/TBL=[SCATBL]"
	I %O=2 S %TAB("IO")=$$IO^SCATAB($I)
	;
	S %READ="@@%FN,,,FUN/REQ"
	S %NOPRMT="N"
	I %O=2 S %READ=%READ_",IO/REQ"
	;
	D ^UTLREAD
	I VFMQ="Q" S ER=1 Q 
	;
	K vobj(+$G(fSCATBL)) S fSCATBL=$$vDb2(FUN)
	;
	S I=0
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N scau0,vop1 S vop1=rs,scau0=$G(^SCAU(0,vop1))
	.	I 'SEC,$P(scau0,$C(124),6) Q 
	.	S I=I+1
	. K vobj(+$G(fSCATBL3(I))) S fSCATBL3(I)=$$vDb4(FUN,vop1)
	.	Q 
	;
	Q 
	;
VPG01(fSCATBL,fSCATBL3)	; actual authorize info
	;
	N %MODS
	;
	I '($D(%REPEAT)#2) S %REPEAT=14
	;
	S %MODS=((%PG*%REPEAT)-%REPEAT)+1
	;
	I %O=2 D OPEN^SCAIO I ER S VFMQ="Q" Q 
	;
	N vo1 N vo2 N vo3 D DRV^USID(%O,"SCADRV6",.fSCATBL,.fSCATBL3,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3))
	;
	I "DFQ"[VFMQ D VER(.fSCATBL3)
	;
	Q 
	;
VER(fSCATBL3)	; verify and process
	;
	I %O=2!(%O=4)!(VFMQ="Q") D VEXIT Q 
	;
	D FILE(.fSCATBL3)
	;
	D VEXIT
	Q 
	;
FILE(fSCATBL3)	;
	;
	N I
	;
	S (I,N)=""
	;
	F  S I=$order(fSCATBL3(I)) Q:(I="")  D
	.	S N=vobj(fSCATBL3(I),-4)
	.	;
	.	; Check for an unsecured user deleting a secured userclass
	.	N scau0 S scau0=$G(^SCAU(0,N))
	.	I 'SEC,$P(scau0,$C(124),6) Q 
	.	;
	.	I ALL S $P(vobj(fSCATBL3(I)),$C(124),1)=1
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(fSCATBL3(I)) K vobj(fSCATBL3(I),-100) S vobj(fSCATBL3(I),-2)=1 Tcommit:vTp  
	.	Q 
	;
	Q 
	;
VEXIT	;
	;
	I ER!(%O=2)!(%O=4) Q 
	;
	; Authorization not modified
	I VFMQ="Q" S RM=$$^MSG("312")
	;
	; Authorization modified
	E  S RM=$$^MSG("311")
	S ER="W"
	Q 
	;
vSIG()	;
	Q "60620^27431^Renga SP^3566" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1)	;	vobj()=Db.getRecord(SCATBL,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL"
	S vobj(vOid)=$G(^SCATBL(1,v1))
	I vobj(vOid)="",'$D(^SCATBL(1,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb4(v1,v2)	;	vobj()=Db.getRecord(SCATBL3,,1)
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
vDb5(v1)	;	voXN = Db.getRecord(SCAU0,,0)
	;
	N scau0
	S scau0=$G(^SCAU(0,v1))
	I scau0="",'$D(^SCAU(0,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU0" X $ZT
	Q scau0
	;
vKill1(ex1)	;	Delete objects fSCATBL3()
	;
	N n1 S (n1)=""
	F  S n1=$O(fSCATBL3(n1)) Q:n1=""  K:'((n1=ex1)) vobj(fSCATBL3(n1))
	Q
	;
vOpen1()	;	UCLS FROM SCAU0
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^SCAU(0,vos2),1) I vos2="" G vL1a0
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
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vReSav1(vOid)	;	RecordSCATBL3 saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vOid,vobj(vOid,-2))
	S ^SCATBL(1,vobj(vOid,-3),vobj(vOid,-4))=$$RTBAR^%ZFUNC($G(vobj(vOid)))
	Q
