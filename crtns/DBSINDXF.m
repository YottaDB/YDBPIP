DBSINDXF(dbtbl8,vpar,vparNorm)	; DBTBL8 - Index File Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL8 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (11)             03/19/2007
	; Trigger Definition (2)                      05/17/2004
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl8,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl8,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl8,.vx,1,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	; Define local variables for access keys for legacy triggers
	N %LIBS S %LIBS=vobj(dbtbl8,-3)
	N FID S FID=vobj(dbtbl8,-4)
	N INDEXNM S INDEXNM=vobj(dbtbl8,-5)
	;
	I %O=0 D  Q  ; Create record control block
	.	D vinit ; Initialize column values
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	I vpar["/TRIGAFT/" D VAI ; After insert triggers
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I ($D(vx("%LIBS"))#2)!($D(vx("FID"))#2)!($D(vx("INDEXNM"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL8",.vx)
	.	S %O=1 D vexec
	.	I vpar["/TRIGAFT/" D VAU ; After update triggers
	.	Q 
	;
	I %O=2 D  Q  ; Verify record control block
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	S vpar=$$setPar^UCUTILN(vpar,"NOJOURNAL/NOUPDATE")
	.	D vexec
	.	I vpar["/TRIGAFT/" D VAI ; After insert triggers
	.	Q 
	;
	I %O=3 D  Q  ; Delete record control block
	.	  N V1,V2,V3 S V1=vobj(dbtbl8,-3),V2=vobj(dbtbl8,-4),V3=vobj(dbtbl8,-5) Q:'($D(^DBTBL(V1,8,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	I vpar["/TRIGAFT/" D VAD ; After delete triggers
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl8 S dbtbl8=$$vDb1(%LIBS,FID,INDEXNM)
	I (%O=2) D
	.	S vobj(dbtbl8,-2)=2
	.	;
	.	D DBSINDXF(dbtbl8,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl8)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl8,-3),V2=vobj(dbtbl8,-4),V3=vobj(dbtbl8,-5) I '(''($D(^DBTBL(V1,8,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	I vpar["/VALFK/" D CHKFKS ; Check foreign keys
	I vpar["/VALRI/" D VFKEYS ; Foreign key definition
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(dbtbl8),$C(124),12)=$P($H,",",1)
	. S $P(vobj(dbtbl8),$C(124),16)=$P($H,",",2)
	.	I '+$P($G(vobj(dbtbl8,-100,"0*","USER")),"|",2) S $P(vobj(dbtbl8),$C(124),13)=$$USERNAM^%ZFUNC
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl8)) S ^DBTBL(vobj(dbtbl8,-3),8,vobj(dbtbl8,-4),vobj(dbtbl8,-5))=vobj(dbtbl8)
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
	ZWI ^DBTBL(vobj(dbtbl8,-3),8,vobj(dbtbl8,-4),vobj(dbtbl8,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl8),$C(124),14)="") S $P(vobj(dbtbl8),$C(124),14)=0 ; upcase
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl8),$C(124),5)="") D vreqerr("IDXDESC") Q 
	I ($P(vobj(dbtbl8),$C(124),14)="") D vreqerr("UPCASE") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl8,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl8,-4)="") D vreqerr("FID") Q 
	I (vobj(dbtbl8,-5)="") D vreqerr("INDEXNM") Q 
	;
	I ($D(vx("IDXDESC"))#2),($P(vobj(dbtbl8),$C(124),5)="") D vreqerr("IDXDESC") Q 
	I ($D(vx("UPCASE"))#2),($P(vobj(dbtbl8),$C(124),14)="") D vreqerr("UPCASE") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL8","MSG",1767,"DBTBL8."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VFKEYS	; Foreign keys
	;
	I '(vobj(dbtbl8,-4)="") S vfkey("^DBTBL("_""""_vobj(dbtbl8,-3)_""""_","_1_","_""""_vobj(dbtbl8,-4)_""""_")")="DBTBL8(%LIBS,FID) -> DBTBL1"
	Q 
	;
CHKFKS	; Check foreign keys when not under buffer
	;
	N vERRMSG
	;
	 N V1,V2 S V1=vobj(dbtbl8,-3),V2=vobj(dbtbl8,-4) I '($D(^DBTBL(V1,1,V2))) S vERRMSG=$$^MSG(8563,"DBTBL8(%LIBS,FID) -> DBTBL1") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	Q 
	;
VAD	;
	 S ER=0
	D vad1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VAI	;
	 S ER=0
	D vai1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VAU	;
	 S ER=0
	D vau1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vad1	; Trigger AFTER_DELETE - After delete
	;
	N ZFID N IDXNM N SUBFID
	;
	S ZFID=vobj(dbtbl8,-4)
	S IDXNM=vobj(dbtbl8,-5)
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	I '$G(vos1) Q 
	F  Q:'($$vFetch1())  D
	.	S SUBFID=rs
	.	D vDbDe1()
	.	Q 
	Q 
	;
vai1	; Trigger AFTER_UPDATE - After insert/update
	;
	D vau1
	;
	Q 
	;
vau1	; Trigger AFTER_UPDATE - After insert/update
	;
	N ZFID N IDXNM N subfid
	;
	S ZFID=vobj(dbtbl8,-4)
	S IDXNM=vobj(dbtbl8,-5)
	;
	; Copy super type index information into sub type file
	;
	N sub S sub=$$vReCp1(dbtbl8)
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen2()
	I '$G(vos1) K vobj(+$G(sub)) Q 
	F  Q:'($$vFetch2())  D
	.	S subfid=rs
	. S vobj(sub,-4)=subfid
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSINDXF(sub,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sub,-100) S vobj(sub,-2)=1 Tcommit:vTp  
	.	Q 
	K vobj(+$G(sub)) Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl8,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl8,-4))>25 S vRM=$$^MSG(1076,25) D vdderr("FID",vRM) Q 
	S X=vobj(dbtbl8,-5) I '(X="") S vRM=$$VAL^DBSVER("U",16,1,,"X?1A.AN",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL8.INDEXNM"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	I $L($P(vobj(dbtbl8),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("GLOBAL",vRM) Q 
	I $L($P(vobj(dbtbl8),$C(124),5))>29 S vRM=$$^MSG(1076,29) D vdderr("IDXDESC",vRM) Q 
	S X=$P(vobj(dbtbl8),$C(124),12) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	I $L($P(vobj(dbtbl8),$C(124),3))>120 S vRM=$$^MSG(1076,120) D vdderr("ORDERBY",vRM) Q 
	I $L($P(vobj(dbtbl8),$C(124),15))>8 S vRM=$$^MSG(1076,8) D vdderr("PARFID",vRM) Q 
	S X=$P(vobj(dbtbl8),$C(124),16) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIME",vRM) Q 
	I '("01"[$P(vobj(dbtbl8),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("UPCASE",vRM) Q 
	I $L($P(vobj(dbtbl8),$C(124),13))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL8","MSG",979,"DBTBL8."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vkchged	; Access key changed
	;
	 S ER=0
	;
	N %O S %O=1
	N vnewkey N voldkey N vux
	N voldpar S voldpar=$get(vpar) ; Save filer switches
	;
	I ($D(vx("%LIBS"))#2) S vux("%LIBS")=vx("%LIBS")
	I ($D(vx("FID"))#2) S vux("FID")=vx("FID")
	I ($D(vx("INDEXNM"))#2) S vux("INDEXNM")=vx("INDEXNM")
	D vkey(1) S voldkey=vobj(dbtbl8,-3)_","_vobj(dbtbl8,-4)_","_vobj(dbtbl8,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl8,-3)_","_vobj(dbtbl8,-4)_","_vobj(dbtbl8,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp2(dbtbl8)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),8,vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL8",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	S vpar=voldpar
	I vpar["/TRIGAFT/" D VAU
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl8,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("FID"))#2) S vobj(dbtbl8,-4)=$piece(vux("FID"),"|",i)
	I ($D(vux("INDEXNM"))#2) S vobj(dbtbl8,-5)=$piece(vux("INDEXNM"),"|",i)
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:SUBFID AND INDEXNM=:IDXNM
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb2("SYSDEV",SUBFID,IDXNM)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBSINDXF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL8,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8"
	S vobj(vOid)=$G(^DBTBL(v1,8,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,8,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL8" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL8,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8"
	S vobj(vOid)=$G(^DBTBL(v1,8,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,8,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:ZFID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(ZFID) I vos2="",'$D(ZFID) G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBINDX("SYSDEV","PARFID",vos2,vos3),1) I vos3="" G vL1a0
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
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:ZFID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(ZFID) I vos2="",'$D(ZFID) G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBINDX("SYSDEV","PARFID",vos2,vos3),1) I vos3="" G vL2a0
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
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL8.copy: DBTBL8
	;
	Q $$copy^UCGMR(dbtbl8)
	;
vReCp2(v1)	;	RecordDBTBL8.copy: DBTBL8
	;
	Q $$copy^UCGMR(dbtbl8)
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
