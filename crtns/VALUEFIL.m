VALUEFIL(utblprodrt,vpar,vparNorm)	; UTBLPRODRT - Product Attribute Results Set Filer
	;
	; **** Routine compiled from DATA-QWIK Filer UTBLPRODRT ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (6)              11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(utblprodrt,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(utblprodrt,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(utblprodrt,.vx,1,"|")
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
	.	I ($D(vx("COLNAME"))#2)!($D(vx("RESULTSID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("UTBLPRODRT",.vx)
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
	.	  N V1,V2 S V1=vobj(utblprodrt,-3),V2=vobj(utblprodrt,-4) Q:'($D(^UTBL("PRODRT",V1,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N utblprodrt S utblprodrt=$$vDb1(COLNAME,RESULTSID)
	I (%O=2) D
	.	S vobj(utblprodrt,-2)=2
	.	;
	.	D VALUEFIL(utblprodrt,vpar)
	.	Q 
	;
	K vobj(+$G(utblprodrt)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(utblprodrt,-3),V2=vobj(utblprodrt,-4) I '(''($D(^UTBL("PRODRT",V1,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrt,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrt,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(utblprodrt)) S ^UTBL("PRODRT",vobj(utblprodrt,-3),vobj(utblprodrt,-4))=vobj(utblprodrt)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrt,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^UTBL("PRODRT",vobj(utblprodrt,-3),vobj(utblprodrt,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(utblprodrt),$C(124),2)="") D vreqerr("MARSEG") Q 
	I ($P(vobj(utblprodrt),$C(124),3)="") D vreqerr("SEGID") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(utblprodrt,-3)="") D vreqerr("COLNAME") Q 
	I (vobj(utblprodrt,-4)="") D vreqerr("RESULTSID") Q 
	;
	I ($D(vx("MARSEG"))#2),($P(vobj(utblprodrt),$C(124),2)="") D vreqerr("MARSEG") Q 
	I ($D(vx("SEGID"))#2),($P(vobj(utblprodrt),$C(124),3)="") D vreqerr("SEGID") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRT","MSG",1767,"UTBLPRODRT."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(utblprodrt,-3))>25 S vRM=$$^MSG(1076,25) D vdderr("COLNAME",vRM) Q 
	S X=vobj(utblprodrt,-4) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("RESULTSID",vRM) Q 
	I $L($P(vobj(utblprodrt),$C(124),4))>1 S vRM=$$^MSG(1076,1) D vdderr("DATATYPE",vRM) Q 
	I $L($P(vobj(utblprodrt),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	S X=$P(vobj(utblprodrt),$C(124),2) I '(X=""),'($D(^UTBL("MARSEG",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MARSEG",vRM) Q 
	S X=$P(vobj(utblprodrt),$C(124),3) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEGID",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRT","MSG",979,"UTBLPRODRT."_di_" "_vRM)
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
	D vkey(1) S voldkey=vobj(utblprodrt,-3)_","_vobj(utblprodrt,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(utblprodrt,-3)_","_vobj(utblprodrt,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(utblprodrt)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("UTBLPRODRT",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("COLNAME"))#2) S vobj(utblprodrt,-3)=$piece(vux("COLNAME"),"|",i)
	I ($D(vux("RESULTSID"))#2) S vobj(utblprodrt,-4)=$piece(vux("RESULTSID"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(UTBLPRODRT,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordUTBLPRODRT"
	S vobj(vOid)=$G(^UTBL("PRODRT",v1,v2))
	I vobj(vOid)="",'$D(^UTBL("PRODRT",v1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLPRODRT" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordUTBLPRODRT.copy: UTBLPRODRT
	;
	Q $$copy^UCGMR(utblprodrt)
	;
vReSav1(vnewrec)	;	RecordUTBLPRODRT saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^UTBL("PRODRT",vobj(vnewrec,-3),vobj(vnewrec,-4))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
