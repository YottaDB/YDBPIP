DTBL6SQL(dbtbl6sq,vpar,vparNorm)	; DBTBL6SQ - QWIK Report Statistics Page DATA Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL6SQ ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (6)              02/06/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl6sq,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl6sq,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl6sq,.vx,1,"|")
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("QID"))#2)!($D(vx("SEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL6SQ",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl6sq,-3),V2=vobj(dbtbl6sq,-4),V3=vobj(dbtbl6sq,-5) Q:'$$vDbEx1()  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl6sq S dbtbl6sq=$$vDb1(LIBS,QID,SEQ)
	I (%O=2) D
	.	S vobj(dbtbl6sq,-2)=2
	.	;
	.	D DTBL6SQL(dbtbl6sq,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl6sq)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl6sq,-3),V2=vobj(dbtbl6sq,-4),V3=vobj(dbtbl6sq,-5) I '(''$$vDbEx2()=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl6sq)) S ^DBTBL(vobj(dbtbl6sq,-3),6,vobj(dbtbl6sq,-4),vobj(dbtbl6sq,-5))=vobj(dbtbl6sq)
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
	ZWI ^DBTBL(vobj(dbtbl6sq,-3),6,vobj(dbtbl6sq,-4),vobj(dbtbl6sq,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl6sq,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl6sq,-4)="") D vreqerr("QID") Q 
	I (vobj(dbtbl6sq,-5)="") D vreqerr("SEQ") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL6SQ","MSG",1767,"DBTBL6SQ."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl6sq,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl6sq,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("QID",vRM) Q 
	S X=vobj(dbtbl6sq,-5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEQ",vRM) Q 
	I $L($P(vobj(dbtbl6sq),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("QBASE",vRM) Q 
	I $L($P(vobj(dbtbl6sq),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("QDI",vRM) Q 
	I $L($P(vobj(dbtbl6sq),$C(124),5))>40 S vRM=$$^MSG(1076,40) D vdderr("QINCR",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL6SQ","MSG",979,"DBTBL6SQ."_di_" "_vRM)
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
	I ($D(vx("QID"))#2) S vux("QID")=vx("QID")
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	D vkey(1) S voldkey=vobj(dbtbl6sq,-3)_","_vobj(dbtbl6sq,-4)_","_vobj(dbtbl6sq,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl6sq,-3)_","_vobj(dbtbl6sq,-4)_","_vobj(dbtbl6sq,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl6sq)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),6,vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL6SQ",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl6sq,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("QID"))#2) S vobj(dbtbl6sq,-4)=$piece(vux("QID"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(dbtbl6sq,-5)=$piece(vux("SEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL6SQ,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL6SQ"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2,v3))
	I '(v3>20)
	E  I '(v3<41&(v3'=""))
	E  I vobj(vOid)="",'$D(^DBTBL(v1,6,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL6SQ" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbEx1()	;	min(1): DISTINCT LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS = :V1 and QID = :V2 and SEQ = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3>20) Q 0
	I '(V3<41&(V3'="")) Q 0
	I '($D(^DBTBL(V1,6,V2,V3))#2) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS = :V1 and QID = :V2 and SEQ = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3>20) Q 0
	I '(V3<41&(V3'="")) Q 0
	I '($D(^DBTBL(V1,6,V2,V3))#2) Q 0
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL6SQ.copy: DBTBL6SQ
	;
	Q $$copy^UCGMR(dbtbl6sq)
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
