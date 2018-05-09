DBS33FIL(dbtbl33,vpar,vparNorm)	; DBTBL33 - Batch Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL33 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (23)             06/09/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl33,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl33,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl33,.vx,1,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	I %O=0 D  Q  ; Create record control block
	.	D vinit ; Initialize column values
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I ($D(vx("%LIBS"))#2)!($D(vx("BCHID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL33",.vx)
	.	S %O=1 D vexec
	.	Q 
	;
	I %O=2 D  Q  ; Verify record control block
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	S vpar=$$setPar^UCUTILN(vpar,"NOJOURNAL/NOUPDATE")
	.	D vexec
	.	Q 
	;
	I %O=3 D  Q  ; Delete record control block
	.	  N V1,V2 S V1=vobj(dbtbl33,-3),V2=vobj(dbtbl33,-4) Q:'($D(^DBTBL(V1,33,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl33 S dbtbl33=$$vDb1(%LIBS,BCHID)
	I (%O=2) D
	.	S vobj(dbtbl33,-2)=2
	.	;
	.	D DBS33FIL(dbtbl33,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl33)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(dbtbl33,-3),V2=vobj(dbtbl33,-4) I '(''($D(^DBTBL(V1,33,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(dbtbl33),$C(124),3)=$P($H,",",1)
	. S $P(vobj(dbtbl33),$C(124),5)=$P($H,",",2)
	.	I '+$P($G(vobj(dbtbl33,-100,"0*","USER")),"|",2) S $P(vobj(dbtbl33),$C(124),4)=$$USERNAM^%ZFUNC
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl33)) S ^DBTBL(vobj(dbtbl33,-3),33,vobj(dbtbl33,-4))=vobj(dbtbl33)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar["/CASDEL/" D VCASDEL ; Cascade delete
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^DBTBL(vobj(dbtbl33,-3),33,vobj(dbtbl33,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl33),$C(124),3)="") S $P(vobj(dbtbl33),$C(124),3)=+$H ; ltd
	I ($P(vobj(dbtbl33),$C(124),12)="") S $P(vobj(dbtbl33),$C(124),12)=32000 ; maxsize
	I ($P(vobj(dbtbl33),$C(124),23)="") S $P(vobj(dbtbl33),$C(124),23)=0 ; mglobal
	I ($P(vobj(dbtbl33),$C(124),11)="") S $P(vobj(dbtbl33),$C(124),11)=100 ; msgbufs
	I ($P(vobj(dbtbl33),$C(124),19)="") S $P(vobj(dbtbl33),$C(124),19)=0 ; mtz
	I ($P(vobj(dbtbl33),$C(124),14)="") S $P(vobj(dbtbl33),$C(124),14)=0 ; nonrand
	I ($P(vobj(dbtbl33),$C(124),21)="") S $P(vobj(dbtbl33),$C(124),21)=0 ; restind
	I ($P(vobj(dbtbl33),$C(124),17)="") S $P(vobj(dbtbl33),$C(124),17)=10 ; schtimr
	I ($P(vobj(dbtbl33),$C(124),18)="") S $P(vobj(dbtbl33),$C(124),18)=10 ; thrtimr
	I ($P(vobj(dbtbl33),$C(124),5)="") S $P(vobj(dbtbl33),$C(124),5)=$piece(($H),",",2) ; time
	I ($P(vobj(dbtbl33),$C(124),4)="") S $P(vobj(dbtbl33),$C(124),4)=%UID ; user
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl33),$C(124),1)="") D vreqerr("DES") Q 
	I ($P(vobj(dbtbl33),$C(124),23)="") D vreqerr("MGLOBAL") Q 
	I ($P(vobj(dbtbl33),$C(124),19)="") D vreqerr("MTZ") Q 
	I ($P(vobj(dbtbl33),$C(124),14)="") D vreqerr("NONRAND") Q 
	I ($P(vobj(dbtbl33),$C(124),21)="") D vreqerr("RESTIND") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl33,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl33,-4)="") D vreqerr("BCHID") Q 
	;
	I ($D(vx("DES"))#2),($P(vobj(dbtbl33),$C(124),1)="") D vreqerr("DES") Q 
	I ($D(vx("MGLOBAL"))#2),($P(vobj(dbtbl33),$C(124),23)="") D vreqerr("MGLOBAL") Q 
	I ($D(vx("MTZ"))#2),($P(vobj(dbtbl33),$C(124),19)="") D vreqerr("MTZ") Q 
	I ($D(vx("NONRAND"))#2),($P(vobj(dbtbl33),$C(124),14)="") D vreqerr("NONRAND") Q 
	I ($D(vx("RESTIND"))#2),($P(vobj(dbtbl33),$C(124),21)="") D vreqerr("RESTIND") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL33","MSG",1767,"DBTBL33."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl33,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl33,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("BCHID",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),22))>40 S vRM=$$^MSG(1076,40) D vdderr("DISTINCT",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),24))>40 S vRM=$$^MSG(1076,40) D vdderr("FORMAL",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),12) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("MAXSIZE",vRM) Q 
	I '("01"[$P(vobj(dbtbl33),$C(124),23)) S vRM=$$^MSG(742,"L") D vdderr("MGLOBAL",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),11) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("MSGBUFS",vRM) Q 
	I '("01"[$P(vobj(dbtbl33),$C(124),19)) S vRM=$$^MSG(742,"L") D vdderr("MTZ",vRM) Q 
	I '("01"[$P(vobj(dbtbl33),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("NONRAND",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),8))>12 S vRM=$$^MSG(1076,12) D vdderr("PFID",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),2))>8 S vRM=$$^MSG(1076,8) D vdderr("PGM",vRM) Q 
	I '("01"[$P(vobj(dbtbl33),$C(124),21)) S vRM=$$^MSG(742,"L") D vdderr("RESTIND",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),15) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SCHRCNT",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),17) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("SCHTIMR",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),10) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("THREADS",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),13))>80 S vRM=$$^MSG(1076,80) D vdderr("THRLVAR",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),16) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("THRRCNT",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),18) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("THRTIMR",vRM) Q 
	S X=$P(vobj(dbtbl33),$C(124),5) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIME",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),4))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	I $L($P(vobj(dbtbl33),$C(124),9))>100 S vRM=$$^MSG(1076,100) D vdderr("WHERE",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL33","MSG",979,"DBTBL33."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vkchged	; Access key changed
	;
	 S ER=0
	;
	N %O S %O=1
	N vnewkey N voldkey N vux
	;
	I ($D(vx("%LIBS"))#2) S vux("%LIBS")=vx("%LIBS")
	I ($D(vx("BCHID"))#2) S vux("BCHID")=vx("BCHID")
	D vkey(1) S voldkey=vobj(dbtbl33,-3)_","_vobj(dbtbl33,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl33,-3)_","_vobj(dbtbl33,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl33)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBS33FIL(vnewrec,"/NOCASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/",1) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL33",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl33,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("BCHID"))#2) S vobj(dbtbl33,-4)=$piece(vux("BCHID"),"|",i)
	Q 
	;
VCASDEL	; Cascade delete logic
	;
	 N V1,V2 S V1=vobj(dbtbl33,-3),V2=vobj(dbtbl33,-4) D vDbDe1() ; Cascade delete
	;
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL33D WHERE %LIBS=:V1 AND BCHID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4,vos5 S vDs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N vRec S vRec=$$vDb2($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4))
	.	S vobj(vRec,-2)=3
	.	D ^DBS33FL(vRec,$$initPar^UCUTILN(vpar),1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL33,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33"
	S vobj(vOid)=$G(^DBTBL(v1,33,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,33,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL33" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2,v3,v4)	;	vobj()=Db.getRecord(DBTBL33D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33D"
	S vobj(vOid)=$G(^DBTBL(v1,33,v2,v3,v4))
	I vobj(vOid)="",'$D(^DBTBL(v1,33,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vOpen1()	;	%LIBS,BCHID,LABEL,SEQ FROM DBTBL33D WHERE %LIBS=:V1 AND BCHID=:V2
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=$G(V2) I vos3="" G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBTBL(vos2,33,vos3,vos4),1) I vos4="" G vL1a0
	S vos5=""
vL1a6	S vos5=$O(^DBTBL(vos2,33,vos3,vos4,vos5),1) I vos5="" G vL1a4
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL33.copy: DBTBL33
	;
	Q $$copy^UCGMR(dbtbl33)
	;
vtrap1	;	Error trap
	;
	N fERROR S fERROR=$ZS
	I $P(fERROR,",",3)="%PSL-E-DBFILER" D
	.		S ER=1
	.		S RM=$P(fERROR,",",4)
	.		Q 
	E  S $ZS=fERROR X voZT
	Q 
