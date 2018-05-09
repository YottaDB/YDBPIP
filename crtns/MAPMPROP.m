MAPMPROP(sysmapmprops,vpar,vparNorm)	; SYSMAPMPROPS - Mapping of M properties read or set Filer
	;
	; **** Routine compiled from DATA-QWIK Filer SYSMAPMPROPS ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (5)              01/21/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(sysmapmprops,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(sysmapmprops,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(sysmapmprops,.vx,1,"|")
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
	.	I ($D(vx("TARGET"))#2)!($D(vx("LABEL"))#2)!($D(vx("GLOBALREF"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("SYSMAPMPROPS",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(sysmapmprops,-3),V2=vobj(sysmapmprops,-4),V3=vobj(sysmapmprops,-5) Q:'($D(^SYSMAP("DATA",V1,V2,"G",V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N sysmapmprops S sysmapmprops=$$vDb1(TARGET,LABEL,GLOBALREF)
	I (%O=2) D
	.	S vobj(sysmapmprops,-2)=2
	.	;
	.	D MAPMPROP(sysmapmprops,vpar)
	.	Q 
	;
	K vobj(+$G(sysmapmprops)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(sysmapmprops,-3),V2=vobj(sysmapmprops,-4),V3=vobj(sysmapmprops,-5) I '(''($D(^SYSMAP("DATA",V1,V2,"G",V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(sysmapmprops)) S ^SYSMAP("DATA",vobj(sysmapmprops,-3),vobj(sysmapmprops,-4),"G",vobj(sysmapmprops,-5))=vobj(sysmapmprops)
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
	ZWI ^SYSMAP("DATA",vobj(sysmapmprops,-3),vobj(sysmapmprops,-4),"G",vobj(sysmapmprops,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(sysmapmprops,-3)="") D vreqerr("TARGET") Q 
	I (vobj(sysmapmprops,-4)="") D vreqerr("LABEL") Q 
	I (vobj(sysmapmprops,-5)="") D vreqerr("GLOBALREF") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("SYSMAPMPROPS","MSG",1767,"SYSMAPMPROPS."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(sysmapmprops,-3))>31 S vRM=$$^MSG(1076,31) D vdderr("TARGET",vRM) Q 
	I $L(vobj(sysmapmprops,-4))>40 S vRM=$$^MSG(1076,40) D vdderr("LABEL",vRM) Q 
	I $L(vobj(sysmapmprops,-5))>30 S vRM=$$^MSG(1076,30) D vdderr("GLOBALREF",vRM) Q 
	S X=$P(vobj(sysmapmprops),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("COUNTREAD",vRM) Q 
	S X=$P(vobj(sysmapmprops),$C(124),2) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("COUNTSET",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("SYSMAPMPROPS","MSG",979,"SYSMAPMPROPS."_di_" "_vRM)
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
	I ($D(vx("TARGET"))#2) S vux("TARGET")=vx("TARGET")
	I ($D(vx("LABEL"))#2) S vux("LABEL")=vx("LABEL")
	I ($D(vx("GLOBALREF"))#2) S vux("GLOBALREF")=vx("GLOBALREF")
	D vkey(1) S voldkey=vobj(sysmapmprops,-3)_","_vobj(sysmapmprops,-4)_","_vobj(sysmapmprops,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(sysmapmprops,-3)_","_vobj(sysmapmprops,-4)_","_vobj(sysmapmprops,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(sysmapmprops)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^SYSMAP("DATA",vobj(vnewrec,-3),vobj(vnewrec,-4),"G",vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("SYSMAPMPROPS",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("TARGET"))#2) S vobj(sysmapmprops,-3)=$piece(vux("TARGET"),"|",i)
	I ($D(vux("LABEL"))#2) S vobj(sysmapmprops,-4)=$piece(vux("LABEL"),"|",i)
	I ($D(vux("GLOBALREF"))#2) S vobj(sysmapmprops,-5)=$piece(vux("GLOBALREF"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(SYSMAPMPROPS,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPMPROPS"
	S vobj(vOid)=$G(^SYSMAP("DATA",v1,v2,"G",v3))
	I vobj(vOid)="",'$D(^SYSMAP("DATA",v1,v2,"G",v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SYSMAPMPROPS" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordSYSMAPMPROPS.copy: SYSMAPMPROPS
	;
	Q $$copy^UCGMR(sysmapmprops)
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
