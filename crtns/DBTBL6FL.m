DBTBL6FL(dbtbl6f,vpar,vparNorm)	; DBTBL6F - QWIK Report Format Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL6F ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (10)             02/06/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl6f,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl6f,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl6f,.vx,1,"|")
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("QRID"))#2)!($D(vx("SEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL6F",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl6f,-3),V2=vobj(dbtbl6f,-4),V3=vobj(dbtbl6f,-5) Q:'$$vDbEx1()  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl6f S dbtbl6f=$$vDb1(LIBS,QRID,SEQ)
	I (%O=2) D
	.	S vobj(dbtbl6f,-2)=2
	.	;
	.	D DBTBL6FL(dbtbl6f,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl6f)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl6f,-3),V2=vobj(dbtbl6f,-4),V3=vobj(dbtbl6f,-5) I '(''$$vDbEx2()=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl6f)) S ^DBTBL(vobj(dbtbl6f,-3),6,vobj(dbtbl6f,-4),vobj(dbtbl6f,-5))=vobj(dbtbl6f)
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
	ZWI ^DBTBL(vobj(dbtbl6f,-3),6,vobj(dbtbl6f,-4),vobj(dbtbl6f,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl6f,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl6f,-4)="") D vreqerr("QRID") Q 
	I (vobj(dbtbl6f,-5)="") D vreqerr("SEQ") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL6F","MSG",1767,"DBTBL6F."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl6f,-3))>10 S vRM=$$^MSG(1076,10) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl6f,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("QRID",vRM) Q 
	S X=vobj(dbtbl6f,-5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEQ",vRM) Q 
	I $L($P(vobj(dbtbl6f),$C(124),2))>35 S vRM=$$^MSG(1076,35) D vdderr("FORMDESC",vRM) Q 
	I $L($P(vobj(dbtbl6f),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("FORMDI",vRM) Q 
	S X=$P(vobj(dbtbl6f),$C(124),5) I '(X=""),'($D(^DBCTL("SYS","RFMT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FORMFMT",vRM) Q 
	S X=$P(vobj(dbtbl6f),$C(124),6) I '(X=""),'($D(^DBCTL("SYS","QWIKFUN",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FORMFUN",vRM) Q 
	S X=$P(vobj(dbtbl6f),$C(124),3) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("FORMIDN",vRM) Q 
	S X=$P(vobj(dbtbl6f),$C(124),7) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("FORMLF",vRM) Q 
	S X=$P(vobj(dbtbl6f),$C(124),4) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("FORMSIZE",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL6F","MSG",979,"DBTBL6F."_di_" "_vRM)
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
	I ($D(vx("LIBS"))#2) S vux("LIBS")=vx("LIBS")
	I ($D(vx("QRID"))#2) S vux("QRID")=vx("QRID")
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	D vkey(1) S voldkey=vobj(dbtbl6f,-3)_","_vobj(dbtbl6f,-4)_","_vobj(dbtbl6f,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl6f,-3)_","_vobj(dbtbl6f,-4)_","_vobj(dbtbl6f,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl6f)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),6,vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL6F",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl6f,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("QRID"))#2) S vobj(dbtbl6f,-4)=$piece(vux("QRID"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(dbtbl6f,-5)=$piece(vux("SEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL6F,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL6F"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2,v3))
	I '(v3>100)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,6,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL6F" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbEx1()	;	min(1): DISTINCT LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS = :V1 and QRID = :V2 and SEQ = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3>100) Q 0
	I '($D(^DBTBL(V1,6,V2,V3))#2) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS = :V1 and QRID = :V2 and SEQ = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3>100) Q 0
	I '($D(^DBTBL(V1,6,V2,V3))#2) Q 0
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL6F.copy: DBTBL6F
	;
	Q $$copy^UCGMR(dbtbl6f)
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
