MAPMETHO(sysmapm,vpar,vparNorm)	; SYSMAPM - System map of PSL method usage Filer
	;
	; **** Routine compiled from DATA-QWIK Filer SYSMAPM ****
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
	N %O S %O=$G(vobj(sysmapm,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(sysmapm,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(sysmapm,.vx,1,"|")
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
	.	I ($D(vx("TARGET"))#2)!($D(vx("LABEL"))#2)!($D(vx("CLASS"))#2)!($D(vx("METHOD"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("SYSMAPM",.vx)
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
	.	  N V1,V2,V3,V4 S V1=vobj(sysmapm,-3),V2=vobj(sysmapm,-4),V3=vobj(sysmapm,-5),V4=vobj(sysmapm,-6) Q:'($D(^SYSMAP("METHOD",V1,V2,V3,V4))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N sysmapm S sysmapm=$$vDb1(TARGET,LABEL,CLASS,METHOD)
	I (%O=2) D
	.	S vobj(sysmapm,-2)=2
	.	;
	.	D MAPMETHO(sysmapm,vpar)
	.	Q 
	;
	K vobj(+$G(sysmapm)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3,V4 S V1=vobj(sysmapm,-3),V2=vobj(sysmapm,-4),V3=vobj(sysmapm,-5),V4=vobj(sysmapm,-6) I '(''($D(^SYSMAP("METHOD",V1,V2,V3,V4))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(sysmapm)) S ^SYSMAP("METHOD",vobj(sysmapm,-3),vobj(sysmapm,-4),vobj(sysmapm,-5),vobj(sysmapm,-6))=vobj(sysmapm)
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
	ZWI ^SYSMAP("METHOD",vobj(sysmapm,-3),vobj(sysmapm,-4),vobj(sysmapm,-5),vobj(sysmapm,-6))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(sysmapm,-3)="") D vreqerr("TARGET") Q 
	I (vobj(sysmapm,-4)="") D vreqerr("LABEL") Q 
	I (vobj(sysmapm,-5)="") D vreqerr("CLASS") Q 
	I (vobj(sysmapm,-6)="") D vreqerr("METHOD") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("SYSMAPM","MSG",1767,"SYSMAPM."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(sysmapm,-3))>31 S vRM=$$^MSG(1076,31) D vdderr("TARGET",vRM) Q 
	I $L(vobj(sysmapm,-4))>40 S vRM=$$^MSG(1076,40) D vdderr("LABEL",vRM) Q 
	I $L(vobj(sysmapm,-5))>20 S vRM=$$^MSG(1076,20) D vdderr("CLASS",vRM) Q 
	I $L(vobj(sysmapm,-6))>20 S vRM=$$^MSG(1076,20) D vdderr("METHOD",vRM) Q 
	S X=$P(vobj(sysmapm),$C(124),1) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("COUNT",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("SYSMAPM","MSG",979,"SYSMAPM."_di_" "_vRM)
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
	I ($D(vx("CLASS"))#2) S vux("CLASS")=vx("CLASS")
	I ($D(vx("METHOD"))#2) S vux("METHOD")=vx("METHOD")
	D vkey(1) S voldkey=vobj(sysmapm,-3)_","_vobj(sysmapm,-4)_","_vobj(sysmapm,-5)_","_vobj(sysmapm,-6) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(sysmapm,-3)_","_vobj(sysmapm,-4)_","_vobj(sysmapm,-5)_","_vobj(sysmapm,-6) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(sysmapm)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^SYSMAP("METHOD",vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5),vobj(vnewrec,-6))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("SYSMAPM",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("TARGET"))#2) S vobj(sysmapm,-3)=$piece(vux("TARGET"),"|",i)
	I ($D(vux("LABEL"))#2) S vobj(sysmapm,-4)=$piece(vux("LABEL"),"|",i)
	I ($D(vux("CLASS"))#2) S vobj(sysmapm,-5)=$piece(vux("CLASS"),"|",i)
	I ($D(vux("METHOD"))#2) S vobj(sysmapm,-6)=$piece(vux("METHOD"),"|",i)
	Q 
	;
vDb1(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPM,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPM"
	S vobj(vOid)=$G(^SYSMAP("METHOD",v1,v2,v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("METHOD",v1,v2,v3,v4))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SYSMAPM" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vReCp1(v1)	;	RecordSYSMAPM.copy: SYSMAPM
	;
	Q $$copy^UCGMR(sysmapm)
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
