DAYXBCFL(dayendxbadc,vpar,vparNorm)	; DAYENDXBADC - CIF Integrity Override File Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DAYENDXBADC ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (7)              06/26/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dayendxbadc,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dayendxbadc,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dayendxbadc,.vx,1,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	I %O=0 D  Q  ; Create record control block
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I ($D(vx("TJD"))#2)!($D(vx("%UID"))#2)!($D(vx("ACN"))#2)!($D(vx("SEQ"))#2)!($D(vx("ET"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DAYENDXBADC",.vx)
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
	.	  N V1,V2,V3,V4,V5 S V1=vobj(dayendxbadc,-3),V2=vobj(dayendxbadc,-4),V3=vobj(dayendxbadc,-5),V4=vobj(dayendxbadc,-6),V5=vobj(dayendxbadc,-7) Q:'($D(^DAYEND(V1,"XBADC",V2,V3,V4,V5))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dayendxbadc S dayendxbadc=$$vDb1(TJD,%UID,ACN,SEQ,ET)
	I (%O=2) D
	.	S vobj(dayendxbadc,-2)=2
	.	;
	.	D DAYXBCFL(dayendxbadc,vpar)
	.	Q 
	;
	K vobj(+$G(dayendxbadc)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3,V4,V5 S V1=vobj(dayendxbadc,-3),V2=vobj(dayendxbadc,-4),V3=vobj(dayendxbadc,-5),V4=vobj(dayendxbadc,-6),V5=vobj(dayendxbadc,-7) I '(''($D(^DAYEND(V1,"XBADC",V2,V3,V4,V5))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dayendxbadc)) S ^DAYEND(vobj(dayendxbadc,-3),"XBADC",vobj(dayendxbadc,-4),vobj(dayendxbadc,-5),vobj(dayendxbadc,-6),vobj(dayendxbadc,-7))=vobj(dayendxbadc)
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
	ZWI ^DAYEND(vobj(dayendxbadc,-3),"XBADC",vobj(dayendxbadc,-4),vobj(dayendxbadc,-5),vobj(dayendxbadc,-6),vobj(dayendxbadc,-7))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dayendxbadc,-3)="") D vreqerr("TJD") Q 
	I (vobj(dayendxbadc,-4)="") D vreqerr("%UID") Q 
	I (vobj(dayendxbadc,-5)="") D vreqerr("ACN") Q 
	I (vobj(dayendxbadc,-6)="") D vreqerr("SEQ") Q 
	I (vobj(dayendxbadc,-7)="") D vreqerr("ET") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DAYENDXBADC","MSG",1767,"DAYENDXBADC."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(dayendxbadc,-3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("TJD",vRM) Q 
	I $L(vobj(dayendxbadc,-4))>20 S vRM=$$^MSG(1076,20) D vdderr("%UID",vRM) Q 
	S X=vobj(dayendxbadc,-5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("ACN",vRM) Q 
	S X=vobj(dayendxbadc,-6) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("SEQ",vRM) Q 
	I $L(vobj(dayendxbadc,-7))>12 S vRM=$$^MSG(1076,12) D vdderr("ET",vRM) Q 
	I $L($P(vobj(dayendxbadc),$C(124),2))>75 S vRM=$$^MSG(1076,75) D vdderr("IDENT",vRM) Q 
	I $L($P(vobj(dayendxbadc),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("UID",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DAYENDXBADC","MSG",979,"DAYENDXBADC."_di_" "_vRM)
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
	I ($D(vx("TJD"))#2) S vux("TJD")=vx("TJD")
	I ($D(vx("%UID"))#2) S vux("%UID")=vx("%UID")
	I ($D(vx("ACN"))#2) S vux("ACN")=vx("ACN")
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	I ($D(vx("ET"))#2) S vux("ET")=vx("ET")
	D vkey(1) S voldkey=vobj(dayendxbadc,-3)_","_vobj(dayendxbadc,-4)_","_vobj(dayendxbadc,-5)_","_vobj(dayendxbadc,-6)_","_vobj(dayendxbadc,-7) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dayendxbadc,-3)_","_vobj(dayendxbadc,-4)_","_vobj(dayendxbadc,-5)_","_vobj(dayendxbadc,-6)_","_vobj(dayendxbadc,-7) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dayendxbadc)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DAYEND(vobj(vnewrec,-3),"XBADC",vobj(vnewrec,-4),vobj(vnewrec,-5),vobj(vnewrec,-6),vobj(vnewrec,-7))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DAYENDXBADC",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("TJD"))#2) S vobj(dayendxbadc,-3)=$piece(vux("TJD"),"|",i)
	I ($D(vux("%UID"))#2) S vobj(dayendxbadc,-4)=$piece(vux("%UID"),"|",i)
	I ($D(vux("ACN"))#2) S vobj(dayendxbadc,-5)=$piece(vux("ACN"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(dayendxbadc,-6)=$piece(vux("SEQ"),"|",i)
	I ($D(vux("ET"))#2) S vobj(dayendxbadc,-7)=$piece(vux("ET"),"|",i)
	Q 
	;
vDb1(v1,v2,v3,v4,v5)	;	vobj()=Db.getRecord(DAYENDXBADC,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDAYENDXBADC"
	S vobj(vOid)=$G(^DAYEND(v1,"XBADC",v2,v3,v4,v5))
	I vobj(vOid)="",'$D(^DAYEND(v1,"XBADC",v2,v3,v4,v5))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DAYENDXBADC" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	S vobj(vOid,-7)=v5
	Q vOid
	;
vReCp1(v1)	;	RecordDAYENDXBADC.copy: DAYENDXBADC
	;
	Q $$copy^UCGMR(dayendxbadc)
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
