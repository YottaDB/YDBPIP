VALUEDFL(utblprodrtdt,vpar,vparNorm)	; UTBLPRODRTDT - Product Attribute Result Set Detail Filer
	;
	; **** Routine compiled from DATA-QWIK Filer UTBLPRODRTDT ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (10)             11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(utblprodrtdt,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(utblprodrtdt,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(utblprodrtdt,.vx,1,"|")
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
	.	I ($D(vx("COLNAME"))#2)!($D(vx("RESULTSID"))#2)!($D(vx("DECISION"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("UTBLPRODRTDT",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(utblprodrtdt,-3),V2=vobj(utblprodrtdt,-4),V3=vobj(utblprodrtdt,-5) Q:'($D(^UTBL("PRODRT",V1,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N utblprodrtdt S utblprodrtdt=$$vDb1(COLNAME,RESULTSID,DECISION)
	I (%O=2) D
	.	S vobj(utblprodrtdt,-2)=2
	.	;
	.	D VALUEDFL(utblprodrtdt,vpar)
	.	Q 
	;
	K vobj(+$G(utblprodrtdt)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(utblprodrtdt,-3),V2=vobj(utblprodrtdt,-4),V3=vobj(utblprodrtdt,-5) I '(''($D(^UTBL("PRODRT",V1,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(utblprodrtdt),$C(124),6)=TJD
	. S $P(vobj(utblprodrtdt),$C(124),7)=$P($H,",",2)
	. S $P(vobj(utblprodrtdt),$C(124),5)=%UID
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrtdt,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrtdt,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(utblprodrtdt)) S ^UTBL("PRODRT",vobj(utblprodrtdt,-3),vobj(utblprodrtdt,-4),vobj(utblprodrtdt,-5))=vobj(utblprodrtdt)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrtdt,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^UTBL("PRODRT",vobj(utblprodrtdt,-3),vobj(utblprodrtdt,-4),vobj(utblprodrtdt,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(utblprodrtdt,-3)="") D vreqerr("COLNAME") Q 
	I (vobj(utblprodrtdt,-4)="") D vreqerr("RESULTSID") Q 
	I (vobj(utblprodrtdt,-5)="") D vreqerr("DECISION") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRTDT","MSG",1767,"UTBLPRODRTDT."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(utblprodrtdt,-3))>25 S vRM=$$^MSG(1076,25) D vdderr("COLNAME",vRM) Q 
	S X=vobj(utblprodrtdt,-4) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("RESULTSID",vRM) Q 
	S X=vobj(utblprodrtdt,-5) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("DECISION",vRM) Q 
	I $L($P(vobj(utblprodrtdt),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("DEFAULT",vRM) Q 
	S X=$P(vobj(utblprodrtdt),$C(124),6) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LDATE",vRM) Q 
	I $L($P(vobj(utblprodrtdt),$C(124),2))>100 S vRM=$$^MSG(1076,100) D vdderr("LIST",vRM) Q 
	S X=$P(vobj(utblprodrtdt),$C(124),7) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("LTIME",vRM) Q 
	I $L($P(vobj(utblprodrtdt),$C(124),5))>20 S vRM=$$^MSG(1076,20) D vdderr("LUSER",vRM) Q 
	I $L($P(vobj(utblprodrtdt),$C(124),4))>20 S vRM=$$^MSG(1076,20) D vdderr("RANGEMAX",vRM) Q 
	I $L($P(vobj(utblprodrtdt),$C(124),3))>20 S vRM=$$^MSG(1076,20) D vdderr("RANGEMIN",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRTDT","MSG",979,"UTBLPRODRTDT."_di_" "_vRM)
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
	I ($D(vx("COLNAME"))#2) S vux("COLNAME")=vx("COLNAME")
	I ($D(vx("RESULTSID"))#2) S vux("RESULTSID")=vx("RESULTSID")
	I ($D(vx("DECISION"))#2) S vux("DECISION")=vx("DECISION")
	D vkey(1) S voldkey=vobj(utblprodrtdt,-3)_","_vobj(utblprodrtdt,-4)_","_vobj(utblprodrtdt,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(utblprodrtdt,-3)_","_vobj(utblprodrtdt,-4)_","_vobj(utblprodrtdt,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(utblprodrtdt)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("UTBLPRODRTDT",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("COLNAME"))#2) S vobj(utblprodrtdt,-3)=$piece(vux("COLNAME"),"|",i)
	I ($D(vux("RESULTSID"))#2) S vobj(utblprodrtdt,-4)=$piece(vux("RESULTSID"),"|",i)
	I ($D(vux("DECISION"))#2) S vobj(utblprodrtdt,-5)=$piece(vux("DECISION"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(UTBLPRODRTDT,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordUTBLPRODRTDT"
	S vobj(vOid)=$G(^UTBL("PRODRT",v1,v2,v3))
	I vobj(vOid)="",'$D(^UTBL("PRODRT",v1,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLPRODRTDT" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordUTBLPRODRTDT.copy: UTBLPRODRTDT
	;
	Q $$copy^UCGMR(utblprodrtdt)
	;
vReSav1(vnewrec)	;	RecordUTBLPRODRTDT saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^UTBL("PRODRT",vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
