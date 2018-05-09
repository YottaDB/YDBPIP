DBS5DGFL(dbtbl5dgc,vpar,vparNorm)	; DBTBL5DGC - Report Definition (Group Control) Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL5DGC ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (16)             11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl5dgc,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl5dgc,.vxins,10,"|")
	I %O=1 Q:'$D(vobj(dbtbl5dgc,-100))  D AUDIT^UCUTILN(dbtbl5dgc,.vx,10,"|")
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("RID"))#2)!($D(vx("GRP"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL5DGC",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl5dgc,-3),V2=vobj(dbtbl5dgc,-4),V3=vobj(dbtbl5dgc,-5) Q:'$$vDbEx1()  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl5dgc S dbtbl5dgc=$$vDb1(LIBS,RID,GRP)
	I (%O=2) D
	.	S vobj(dbtbl5dgc,-2)=2
	.	;
	.	D DBS5DGFL(dbtbl5dgc,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl5dgc)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl5dgc,-3),V2=vobj(dbtbl5dgc,-4),V3=vobj(dbtbl5dgc,-5) I '(''$$vDbEx2()=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	N n S n=-1
	.	N x
	.	;
	.	I %O=0 F  S n=$order(vobj(dbtbl5dgc,n)) Q:(n="")  D
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),n)=vobj(dbtbl5dgc,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	E  F  S n=$order(vobj(dbtbl5dgc,-100,n)) Q:(n="")  D
	..		Q:'$D(vobj(dbtbl5dgc,n)) 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),n)=vobj(dbtbl5dgc,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	Q 
	;
	Q 
	;
vload	; Record Load - force loading of unloaded data
	;
	N n S n=""
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	for  set n=$order(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),n)) quit:n=""  if '$D(vobj(dbtbl5dgc,n)),$D(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),n))#2 set vobj(dbtbl5dgc,n)=^(n)
	;*** End of code by-passed by compiler ***
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I '$get(vkeychg),$D(vobj(dbtbl5dgc,-100)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,Deleted object cannot be modified" X $ZT
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	 S:'$D(vobj(dbtbl5dgc,28)) vobj(dbtbl5dgc,28)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),28)),1:"")
	I ($P(vobj(dbtbl5dgc,28),$C(124),1)="") S vobj(dbtbl5dgc,-100,28)="",$P(vobj(dbtbl5dgc,28),$C(124),1)=0 ; udrc
	I ($P(vobj(dbtbl5dgc,28),$C(124),5)="") S vobj(dbtbl5dgc,-100,28)="",$P(vobj(dbtbl5dgc,28),$C(124),5)=0 ; udrpp
	I ($P(vobj(dbtbl5dgc,28),$C(124),3)="") S vobj(dbtbl5dgc,-100,28)="",$P(vobj(dbtbl5dgc,28),$C(124),3)=0 ; udrra
	I ($P(vobj(dbtbl5dgc,28),$C(124),2)="") S vobj(dbtbl5dgc,-100,28)="",$P(vobj(dbtbl5dgc,28),$C(124),2)=0 ; udsc
	I ($P(vobj(dbtbl5dgc,28),$C(124),6)="") S vobj(dbtbl5dgc,-100,28)="",$P(vobj(dbtbl5dgc,28),$C(124),6)=0 ; udspp
	I ($P(vobj(dbtbl5dgc,28),$C(124),4)="") S vobj(dbtbl5dgc,-100,28)="",$P(vobj(dbtbl5dgc,28),$C(124),4)=0 ; udsra
	Q 
	;
vreqn	; Validate required data items
	;
	 S:'$D(vobj(dbtbl5dgc,28)) vobj(dbtbl5dgc,28)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),28)),1:"")
	I ($P(vobj(dbtbl5dgc,28),$C(124),1)="") D vreqerr("UDRC") Q 
	I ($P(vobj(dbtbl5dgc,28),$C(124),5)="") D vreqerr("UDRPP") Q 
	I ($P(vobj(dbtbl5dgc,28),$C(124),3)="") D vreqerr("UDRRA") Q 
	I ($P(vobj(dbtbl5dgc,28),$C(124),2)="") D vreqerr("UDSC") Q 
	I ($P(vobj(dbtbl5dgc,28),$C(124),6)="") D vreqerr("UDSPP") Q 
	I ($P(vobj(dbtbl5dgc,28),$C(124),4)="") D vreqerr("UDSRA") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl5dgc,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl5dgc,-4)="") D vreqerr("RID") Q 
	I (vobj(dbtbl5dgc,-5)="") D vreqerr("GRP") Q 
	;
	I '($order(vobj(dbtbl5dgc,-100,28,""))="") D
	.	 S:'$D(vobj(dbtbl5dgc,28)) vobj(dbtbl5dgc,28)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),28)),1:"")
	.	I ($D(vx("UDRC"))#2),($P(vobj(dbtbl5dgc,28),$C(124),1)="") D vreqerr("UDRC") Q 
	.	I ($D(vx("UDSC"))#2),($P(vobj(dbtbl5dgc,28),$C(124),2)="") D vreqerr("UDSC") Q 
	.	I ($D(vx("UDRRA"))#2),($P(vobj(dbtbl5dgc,28),$C(124),3)="") D vreqerr("UDRRA") Q 
	.	I ($D(vx("UDSRA"))#2),($P(vobj(dbtbl5dgc,28),$C(124),4)="") D vreqerr("UDSRA") Q 
	.	I ($D(vx("UDRPP"))#2),($P(vobj(dbtbl5dgc,28),$C(124),5)="") D vreqerr("UDRPP") Q 
	.	I ($D(vx("UDSPP"))#2),($P(vobj(dbtbl5dgc,28),$C(124),6)="") D vreqerr("UDSPP") Q 
	.	Q 
	 S:'$D(vobj(dbtbl5dgc,28)) vobj(dbtbl5dgc,28)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),28)),1:"")
	I ($D(vx("UDRC"))#2),($P(vobj(dbtbl5dgc,28),$C(124),1)="") D vreqerr("UDRC") Q 
	I ($D(vx("UDRPP"))#2),($P(vobj(dbtbl5dgc,28),$C(124),5)="") D vreqerr("UDRPP") Q 
	I ($D(vx("UDRRA"))#2),($P(vobj(dbtbl5dgc,28),$C(124),3)="") D vreqerr("UDRRA") Q 
	I ($D(vx("UDSC"))#2),($P(vobj(dbtbl5dgc,28),$C(124),2)="") D vreqerr("UDSC") Q 
	I ($D(vx("UDSPP"))#2),($P(vobj(dbtbl5dgc,28),$C(124),6)="") D vreqerr("UDSPP") Q 
	I ($D(vx("UDSRA"))#2),($P(vobj(dbtbl5dgc,28),$C(124),4)="") D vreqerr("UDSRA") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5DGC","MSG",1767,"DBTBL5DGC."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I (%O=2) D vload
	;
	I ($D(vobj(dbtbl5dgc,0))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5dgc,0)) vobj(dbtbl5dgc,0)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),0)),1:"")
	.	I $L($P(vobj(dbtbl5dgc,0),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("REGINFO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5dgc,25))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5dgc,25)) vobj(dbtbl5dgc,25)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),25)),1:"")
	.	S X=$P(vobj(dbtbl5dgc,25),$C(124),4) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("RPTCNT",vRM) Q 
	.	S X=$P(vobj(dbtbl5dgc,25),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("RPTFROM",vRM) Q 
	.	S X=$P(vobj(dbtbl5dgc,25),$C(124),3) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("RPTSIZE",vRM) Q 
	.	S X=$P(vobj(dbtbl5dgc,25),$C(124),2) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("RPTTO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5dgc,26))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5dgc,26)) vobj(dbtbl5dgc,26)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),26)),1:"")
	.	I $L($P(vobj(dbtbl5dgc,26),$C(124),1))>80 S vRM=$$^MSG(1076,80) D vdderr("BLNKSUPR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5dgc,27))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5dgc,27)) vobj(dbtbl5dgc,27)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),27)),1:"")
	.	I $L($P(vobj(dbtbl5dgc,27),$C(124),1))>80 S vRM=$$^MSG(1076,80) D vdderr("LFSUPR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5dgc,28))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5dgc,28)) vobj(dbtbl5dgc,28)=$S(vobj(dbtbl5dgc,-2):$G(^DBTBL(vobj(dbtbl5dgc,-3),5,vobj(dbtbl5dgc,-4),vobj(dbtbl5dgc,-5),28)),1:"")
	.	I '("01"[$P(vobj(dbtbl5dgc,28),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("UDRC",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5dgc,28),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("UDRPP",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5dgc,28),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("UDRRA",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5dgc,28),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("UDSC",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5dgc,28),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("UDSPP",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5dgc,28),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("UDSRA",vRM) Q 
	.	Q 
	I $L(vobj(dbtbl5dgc,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl5dgc,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("RID",vRM) Q 
	I $L(vobj(dbtbl5dgc,-5))>33 S vRM=$$^MSG(1076,33) D vdderr("GRP",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5DGC","MSG",979,"DBTBL5DGC."_di_" "_vRM)
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
	I ($D(vx("RID"))#2) S vux("RID")=vx("RID")
	I ($D(vx("GRP"))#2) S vux("GRP")=vx("GRP")
	D vkey(1) S voldkey=vobj(dbtbl5dgc,-3)_","_vobj(dbtbl5dgc,-4)_","_vobj(dbtbl5dgc,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	D vload ; Make sure all data is loaded locally
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl5dgc,-3)_","_vobj(dbtbl5dgc,-4)_","_vobj(dbtbl5dgc,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl5dgc)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL5DGC",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl5dgc,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("RID"))#2) S vobj(dbtbl5dgc,-4)=$piece(vux("RID"),"|",i)
	I ($D(vux("GRP"))#2) S vobj(dbtbl5dgc,-5)=$piece(vux("GRP"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL5DGC,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5DGC"
	I '(v3]]"@")
	E  I '$D(^DBTBL(v1,5,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5DGC" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbEx1()	;	min(1): DISTINCT LIBS,RID,GRP FROM DBTBL5DGC WHERE LIBS = :V1 and RID = :V2 and GRP = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3]]"@") Q 0
	I '($D(^DBTBL(V1,5,V2,V3))>9) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,RID,GRP FROM DBTBL5DGC WHERE LIBS = :V1 and RID = :V2 and GRP = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3]]"@") Q 0
	I '($D(^DBTBL(V1,5,V2,V3))>9) Q 0
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL5DGC.copy: DBTBL5DGC
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=0,25,26,27,28 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),5,vobj(v1,-4),vobj(v1,-5),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordDBTBL5DGC saveNoFiler()
	;
	N vD,vN S vN=-1
	I '$G(vobj(vnewrec,-2)) F  S vN=$O(vobj(vnewrec,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBTBL(vobj(vnewrec,-3),5,vobj(vnewrec,-4),vobj(vnewrec,-5),vN)=vD
	E  F  S vN=$O(vobj(vnewrec,-100,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBTBL(vobj(vnewrec,-3),5,vobj(vnewrec,-4),vobj(vnewrec,-5),vN)=vD I vD="" ZWI ^DBTBL(vobj(vnewrec,-3),5,vobj(vnewrec,-4),vobj(vnewrec,-5),vN)
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
