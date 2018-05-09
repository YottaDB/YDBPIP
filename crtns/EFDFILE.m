EFDFILE(efd,vpar,vparNorm)	; EFD - Effective-Dated History File Filer
	;
	; **** Routine compiled from DATA-QWIK Filer EFD ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (10)             09/28/2005
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(efd,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(efd,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(efd,.vx,1,"|")
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
	.	I ($D(vx("EFDATE"))#2)!($D(vx("BUFF"))#2)!($D(vx("SEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("EFD",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(efd,-3),V2=vobj(efd,-4),V3=vobj(efd,-5) Q:'($D(^EFD(V1,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N efd S efd=$$vDb1(EFDATE,BUFF,SEQ)
	I (%O=2) D
	.	S vobj(efd,-2)=2
	.	;
	.	D EFDFILE(efd,vpar)
	.	Q 
	;
	K vobj(+$G(efd)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(efd,-3),V2=vobj(efd,-4),V3=vobj(efd,-5) I '(''($D(^EFD(V1,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0 S $P(vobj(efd),$C(124),11)=TJD
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(efd)) K:$D(vobj(efd,1,1)) ^EFD(vobj(efd,-3),vobj(efd,-4),vobj(efd,-5)) S ^EFD(vobj(efd,-3),vobj(efd,-4),vobj(efd,-5))=vobj(efd)
	.	;*** End of code by-passed by compiler ***
	.	; Allow global reference and M source code
	.	;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(efd,1,1)) N vS1,vS2 S vS1=0 F vS2=1:450:$L(vobj(efd,1,1)) S vS1=vS1+1,^EFD(vobj(efd,-3),vobj(efd,-4),vobj(efd,-5),vS1)=$E(vobj(efd,1,1),vS2,vS2+449)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^EFD(vobj(efd,-3),vobj(efd,-4),vobj(efd,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(efd),$C(124),9)="") S $P(vobj(efd),$C(124),9)=+$H ; curdate
	I ($P(vobj(efd),$C(124),10)="") S $P(vobj(efd),$C(124),10)=$piece(($H),",",2) ; curtime
	I ($P(vobj(efd),$C(124),4)="") S $P(vobj(efd),$C(124),4)=TLO ; tlo
	I ($P(vobj(efd),$C(124),5)="") S $P(vobj(efd),$C(124),5)=%UID ; uid
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(efd,-3)="") D vreqerr("EFDATE") Q 
	I (vobj(efd,-4)="") D vreqerr("BUFF") Q 
	I (vobj(efd,-5)="") D vreqerr("SEQ") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("EFD","MSG",1767,"EFD."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(efd,-3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("EFDATE",vRM) Q 
	S X=vobj(efd,-4) I '(X=""),X'?1.16N,X'?1"-"1.15N S vRM=$$^MSG(742,"N") D vdderr("BUFF",vRM) Q 
	S X=vobj(efd,-5) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("SEQ",vRM) Q 
	I $L($P(vobj(efd),$C(124),3))>20 S vRM=$$^MSG(1076,20) D vdderr("AKEY",vRM) Q 
	S X=$P(vobj(efd),$C(124),9) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("CURDATE",vRM) Q 
	S X=$P(vobj(efd),$C(124),10) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("CURTIME",vRM) Q 
	I $L($P(vobj(efd),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("TABLE",vRM) Q 
	S X=$P(vobj(efd),$C(124),11) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("TJD",vRM) Q 
	I $L($P(vobj(efd),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("TLO",vRM) Q 
	I $L($P(vobj(efd),$C(124),5))>20 S vRM=$$^MSG(1076,20) D vdderr("UID",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("EFD","MSG",979,"EFD."_di_" "_vRM)
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
	I ($D(vx("EFDATE"))#2) S vux("EFDATE")=vx("EFDATE")
	I ($D(vx("BUFF"))#2) S vux("BUFF")=vx("BUFF")
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	D vkey(1) S voldkey=vobj(efd,-3)_","_vobj(efd,-4)_","_vobj(efd,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(efd,-3)_","_vobj(efd,-4)_","_vobj(efd,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(efd)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("EFD",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("EFDATE"))#2) S vobj(efd,-3)=$piece(vux("EFDATE"),"|",i)
	I ($D(vux("BUFF"))#2) S vobj(efd,-4)=$piece(vux("BUFF"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(efd,-5)=$piece(vux("SEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(EFD,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordEFD"
	S vobj(vOid)=$G(^EFD(v1,v2,v3))
	I vobj(vOid)="",'$D(^EFD(v1,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,EFD" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordEFD.copy: EFD
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	. S:'$D(vobj(v1,1,1)) vobj(v1,1,1)="" N von S von="" F  S von=$O(^EFD(vobj(v1,-3),vobj(v1,-4),vobj(v1,-5),von)) quit:von=""  S vobj(v1,1,1)=vobj(v1,1,1)_^EFD(vobj(v1,-3),vobj(v1,-4),vobj(v1,-5),von)
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordEFD saveNoFiler()
	;
	S ^EFD(vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
	N vC,vS s vS=0
	F vC=1:450:$L($G(vobj(vnewrec,1,1))) S vS=vS+1,^EFD(vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5),vS)=$E(vobj(vnewrec,1,1),vC,vC+449)
	Q
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
