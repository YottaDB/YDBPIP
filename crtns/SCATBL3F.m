SCATBL3F(scatbl3,vpar,vparNorm)	; SCATBL3 - SCA Menu - Userclass Level Filer
	;
	; **** Routine compiled from DATA-QWIK Filer SCATBL3 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (3)              05/23/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(scatbl3,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(scatbl3,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(scatbl3,.vx,1,"|")
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
	.	I ($D(vx("FN"))#2)!($D(vx("UCLS"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("SCATBL3",.vx)
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
	.	  N V1,V2 S V1=vobj(scatbl3,-3),V2=vobj(scatbl3,-4) Q:'($D(^SCATBL(1,V1,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N scatbl3 S scatbl3=$$vDb1(FN,UCLS)
	I (%O=2) D
	.	S vobj(scatbl3,-2)=2
	.	;
	.	D SCATBL3F(scatbl3,vpar)
	.	Q 
	;
	K vobj(+$G(scatbl3)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(scatbl3,-3),V2=vobj(scatbl3,-4) I '(''($D(^SCATBL(1,V1,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(scatbl3,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(scatbl3,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(scatbl3)) S ^SCATBL(1,vobj(scatbl3,-3),vobj(scatbl3,-4))=vobj(scatbl3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(scatbl3,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^SCATBL(1,vobj(scatbl3,-3),vobj(scatbl3,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(scatbl3),$C(124),1)="") S $P(vobj(scatbl3),$C(124),1)=1 ; auth
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(scatbl3),$C(124),1)="") D vreqerr("AUTH") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(scatbl3,-3)="") D vreqerr("FN") Q 
	I (vobj(scatbl3,-4)="") D vreqerr("UCLS") Q 
	;
	I ($D(vx("AUTH"))#2),($P(vobj(scatbl3),$C(124),1)="") D vreqerr("AUTH") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("SCATBL3","MSG",1767,"SCATBL3."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(scatbl3,-3) I '(X=""),'($D(^SCATBL(1,X))#2) S vRM=$$^MSG(1485,X) D vdderr("FN",vRM) Q 
	S X=vobj(scatbl3,-4) I '(X=""),'($D(^SCAU(0,X))#2) S vRM=$$^MSG(1485,X) D vdderr("UCLS",vRM) Q 
	I '("01"[$P(vobj(scatbl3),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("AUTH",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("SCATBL3","MSG",979,"SCATBL3."_di_" "_vRM)
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
	I ($D(vx("FN"))#2) S vux("FN")=vx("FN")
	I ($D(vx("UCLS"))#2) S vux("UCLS")=vx("UCLS")
	D vkey(1) S voldkey=vobj(scatbl3,-3)_","_vobj(scatbl3,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(scatbl3,-3)_","_vobj(scatbl3,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(scatbl3)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("SCATBL3",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("FN"))#2) S vobj(scatbl3,-3)=$piece(vux("FN"),"|",i)
	I ($D(vux("UCLS"))#2) S vobj(scatbl3,-4)=$piece(vux("UCLS"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(SCATBL3,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL3"
	S vobj(vOid)=$G(^SCATBL(1,v1,v2))
	I vobj(vOid)="",'$D(^SCATBL(1,v1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCATBL3" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordSCATBL3.copy: SCATBL3
	;
	Q $$copy^UCGMR(scatbl3)
	;
vReSav1(vnewrec)	;	RecordSCATBL3 saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^SCATBL(1,vobj(vnewrec,-3),vobj(vnewrec,-4))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
