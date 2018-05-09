 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV1 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV1 ; 
 ;
 D INIT
 Q 
 ;
INIT ; 
 S UID=%UID
 S UCLS=%UCLS
 ;
 N %UCLS
 ;
 N scau S scau=$$vRCgetRecord1^RecordSCAU(UID,0)
 I '$G(vobj(scau,-2)) K vobj(+$G(scau)) Q 
 ;
 D VPG0(.scau)
 ;
 K vobj(+$G(scau)) Q 
 ;
VPG0(scau) ; 
 N vTp
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
  S:'$D(vobj(scau,-100,"0*","NEWPWDREQ")) vobj(scau,-100,"0*","NEWPWDREQ")="L004"_$P(vobj(scau),$C(124),4),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),4)=0
  S:'$D(vobj(scau,-100,"0*","PSWD")) vobj(scau,-100,"0*","PSWD")="T006"_$P(vobj(scau),$C(124),6),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),6)=ENC
  S:'$D(vobj(scau,-100,"0*","PSWDAUT")) vobj(scau,-100,"0*","PSWDAUT")="T039"_$P(vobj(scau),$C(124),39),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),39)=PSWDAUT
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp  
 ;
 ; New password accepted.  Change it again in ~p1 days.
 D SETERR^DBSEXECU("SCAU","MSG",1873,PWDCHG)
 S ER="W"
 ;
 Q 
 ;
PWD(scau,ENC,PSWDAUT,PWDCHG) ; 
 N PWDLEN,UCLS
 ;
 S UCLS=$P(vobj(scau),$C(124),5)
 ;
 N scau0,vop1 S scau0=$$vRCgetRecord1Opt^RecordSCAU0(UCLS,0,.vop1)
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
 WRITE $$BTM^%TRMVT,$$^MSG(8355) R Z
 D TERM^%ZUSE(0,"ECHO")
 ;
 ; Invalid verification
 I $$ENC^SCAENC(Z)'=ENC D SETERR^DBSEXECU("SCAU","MSG",1506) Q 
 ;
 Q 
 ;
MGR ; Entry point for privileged user (manager)
 ;
 S (UID,UCLS)=""
 S MGRFLG=1
 D INIT
 Q 
 ;
CHKPSWH(UID,ENCPSWD) ; 
 ;
 ; Password History Days
 ;
 Q 
 ;
VALIDATE(PWD,UID) ; SCAU User ID    MECH=VAL/NOREQ
 N ENCMETH S ENCMETH=1 N VALID S VALID=0 N ER
 N ENC N PSWD
 ;
 I ('($D(UID)#2)) S UID=%UID
 ;
 I (UID="") Q 0
 ;
 N scau,vop1 S scau=$$vRCgetRecord1Opt^RecordSCAU(UID,0,.vop1)
 I ('$G(vop1)) Q 0
 ;
 I ($P(scau,$C(124),39)="") S PSWD=$P(scau,$C(124),6) S ENCMETH=0
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
SCA017 ; Entry Point for SCA017 function
 ;
 N UCLS,UID
 ;
 S UID=%UID
 S UCLS=%UCLS
 ;
 N scau S scau=$$vRCgetRecord1^RecordSCAU(UID,0)
 ;
 D VPG0(.scau)
 ;
 K vobj(+$G(scau)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60702^61984^Irina Kin^5118" ; Signature - LTD^TIME^USER^SIZE
