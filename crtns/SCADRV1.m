SCADRV1	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV1 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	D INIT
	Q 
	;
INIT	;
	S UID=%UID
	S UCLS=%UCLS
	;
	N %UCLS
	;
	N scau S scau=$$vDb1(UID)
	I '$G(vobj(scau,-2)) K vobj(+$G(scau)) Q 
	;
	D VPG0(.scau)
	;
	K vobj(+$G(scau)) Q 
	;
VPG0(scau)	;
	;
	N ENC,PSWDAUT,PWDCHG
	;
	S PWDCHG=""
	;
	S %TAB("UID")=".UID1/HLP=[SCAU]UID/TBL=[SCAU]"
	S %TAB("PWD")=".PWD1/XPP=D PWD^SCADRV1(.scau,.ENC,.PSWDAUT,.PWDCHG)"
	;
	I $get(MGRFLG) S %READ="@@%FN,,,UID/REQ,PWD/SEC/REQ"
	E  S %READ="@@%FN,,,PWD/REQ/SEC"
	;
	D ^UTLREAD
	; No password set up
	I VFMQ="Q" S ER="W" S RM=$$^MSG(1968) Q 
	;
	; Update DB with a new password
	S:'$D(vobj(scau,-100,"0*","NEWPWDREQ")) vobj(scau,-100,"0*","NEWPWDREQ")="L004"_$P(vobj(scau),$C(124),4) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),4)=0
	S:'$D(vobj(scau,-100,"0*","PSWD")) vobj(scau,-100,"0*","PSWD")="T006"_$P(vobj(scau),$C(124),6) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),6)=ENC
	S:'$D(vobj(scau,-100,"0*","PSWDAUT")) vobj(scau,-100,"0*","PSWDAUT")="T039"_$P(vobj(scau),$C(124),39) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),39)=PSWDAUT
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCAUFILE(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scau,-100) S vobj(scau,-2)=1 Tcommit:vTp  
	;
	; New password accepted.  Change it again in ~p1 days.
	D SETERR^DBSEXECU("SCAU","MSG",1873,PWDCHG)
	S ER="W"
	;
	Q 
	;
PWD(scau,ENC,PSWDAUT,PWDCHG)	;
	N PWDLEN,UCLS
	;
	S UCLS=$P(vobj(scau),$C(124),5)
	;
	N scau0,vop1 S scau0=$$vDb3(UCLS,.vop1)
	; Invalid password
	I '$G(vop1) D SETERR^DBSEXECU("SCAU0","MSG",1419) Q 
	;
	; Password change frequency
	S PWDCHG=$P(scau0,$C(124),4)
	;
	; Password length must be at least ~p1 characters
	I $L(X)<$P(scau0,$C(124),3) D SETERR^DBSEXECU("SCAU0","MSG",2139,$P(scau0,$C(124),3)) Q 
	;
	S ENC=$$ENC^SCAENC(X)
	; Invalid password
	S ER=$$ENC^%ENCRYPT(X,.PSWDAUT) I ER D SETERR^DBSEXECU("SCAU0","MSG",1419) Q 
	;
	; Password must be changed
	I ENC=$P(vobj(scau),$C(124),6) D SETERR^DBSEXECU("SCAU","MSG",2140) Q 
	I PSWDAUT=$P(vobj(scau),$C(124),39) D SETERR^DBSEXECU("SCAU","MSG",2140) Q 
	;
	; Check Password history to prevent old passwords from being reused
	D CHKPSWH(vobj(scau,-3),ENC) Q:ER 
	D CHKPSWH(vobj(scau,-3),PSWDAUT) Q:ER 
	;
	I $get(%IPMODE)["NOINT" Q 
	D TERM^%ZUSE(0,"NOECHO")
	;
	; Reenter password to verify:
	WRITE $$BTM^%TRMVT,$$^MSG(8355) READ Z
	D TERM^%ZUSE(0,"ECHO")
	;
	; Invalid verification
	I $$ENC^SCAENC(Z)'=ENC D SETERR^DBSEXECU("SCAU","MSG",1506) Q 
	;
	Q 
	;
MGR	; Entry point for privileged user (manager)
	;
	S (UID,UCLS)=""
	S MGRFLG=1
	D INIT
	Q 
	;
CHKPSWH(UID,ENCPSWD)	;
	;
	; Password History Days
	;
	Q 
	;
VALIDATE(PWD,UID)	;
	N ENCMETH S ENCMETH=1 N VALID S VALID=0 N ER
	N ENC N PSWD
	;
	I ('($D(UID)#2)) S UID=%UID
	;
	I ((UID="")) Q 0
	;
	N scau,vop1 S scau=$$vDb4(UID,.vop1)
	I ('$G(vop1)) Q 0
	;
	I (($P(scau,$C(124),39)="")) S PSWD=$P(scau,$C(124),6) S ENCMETH=0
	E  S PSWD=$P(scau,$C(124),39)
	;
	I ENCMETH D
	.	I ($E(PWD,1)'=$char(1)) S ER=$$ENC^%ENCRYPT(PWD,.ENC)
	.	E  S ENC=$E(PWD,2,999)
	.	;
	.	I (ENC=$P(scau,$C(124),39)) S VALID=1
	.	Q 
	;
	E  D
	.	I ($E(PWD,1)'=$char(1)) S ENC=$$ENC^SCAENC(PWD)
	.	E  S ENC=$E(PWD,2,999)
	.	;
	.	I (ENC=$P(scau,$C(124),6)) S VALID=1
	.	Q 
	;
	Q VALID
	;
SCA017	; Entry Point for SCA017 function
	;
	N UCLS,UID
	;
	S UID=%UID
	S UCLS=%UCLS
	;
	N scau S scau=$$vDb1(UID)
	;
	D VPG0(.scau)
	;
	K vobj(+$G(scau)) Q 
	;
vSIG()	;
	Q "60702^61984^Irina Kin^5111" ; Signature - LTD^TIME^USER^SIZE
	;
vDb1(v1)	;	vobj()=Db.getRecord(SCAU,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU"
	S vobj(vOid)=$G(^SCAU(1,v1))
	I vobj(vOid)="",'$D(^SCAU(1,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb3(v1,v2out)	;	voXN = Db.getRecord(SCAU0,,1,-2)
	;
	N scau0
	S scau0=$G(^SCAU(0,v1))
	I scau0="",'$D(^SCAU(0,v1))
	S v2out='$T
	;
	Q scau0
	;
vDb4(v1,v2out)	;	voXN = Db.getRecord(SCAU,,1,-2)
	;
	N scau
	S scau=$G(^SCAU(1,v1))
	I scau="",'$D(^SCAU(1,v1))
	S v2out='$T
	;
	Q scau
