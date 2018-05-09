RULEDTFL(utblprodrldt,vpar,vparNorm)	; UTBLPRODRLDT - Product Attribute Rule Detail Filer
	;
	; **** Routine compiled from DATA-QWIK Filer UTBLPRODRLDT ****
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
	N %O S %O=$G(vobj(utblprodrldt,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(utblprodrldt,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(utblprodrldt,.vx,1,"|")
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
	.	I ($D(vx("RULEID"))#2)!($D(vx("DECISION"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("UTBLPRODRLDT",.vx)
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
	.	  N V1,V2 S V1=vobj(utblprodrldt,-3),V2=vobj(utblprodrldt,-4) Q:'($D(^UTBL("PRODRL",V1,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N utblprodrldt S utblprodrldt=$$vDb1(RULEID,DECISION)
	I (%O=2) D
	.	S vobj(utblprodrldt,-2)=2
	.	;
	.	D RULEDTFL(utblprodrldt,vpar)
	.	Q 
	;
	K vobj(+$G(utblprodrldt)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(utblprodrldt,-3),V2=vobj(utblprodrldt,-4) I '(''($D(^UTBL("PRODRL",V1,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(utblprodrldt),$C(124),3)=TJD
	. S $P(vobj(utblprodrldt),$C(124),4)=$P($H,",",2)
	. S $P(vobj(utblprodrldt),$C(124),2)=%UID
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrldt,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrldt,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(utblprodrldt)) S ^UTBL("PRODRL",vobj(utblprodrldt,-3),vobj(utblprodrldt,-4))=vobj(utblprodrldt)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrldt,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^UTBL("PRODRL",vobj(utblprodrldt,-3),vobj(utblprodrldt,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(utblprodrldt,-3)="") D vreqerr("RULEID") Q 
	I (vobj(utblprodrldt,-4)="") D vreqerr("DECISION") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRLDT","MSG",1767,"UTBLPRODRLDT."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(utblprodrldt,-3) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("RULEID",vRM) Q 
	S X=vobj(utblprodrldt,-4) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("DECISION",vRM) Q 
	S X=$P(vobj(utblprodrldt),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LDATE",vRM) Q 
	S X=$P(vobj(utblprodrldt),$C(124),4) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("LTIME",vRM) Q 
	I $L($P(vobj(utblprodrldt),$C(124),2))>20 S vRM=$$^MSG(1076,20) D vdderr("LUSER",vRM) Q 
	I $L($P(vobj(utblprodrldt),$C(124),1))>250 S vRM=$$^MSG(1076,250) D vdderr("TEST",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRLDT","MSG",979,"UTBLPRODRLDT."_di_" "_vRM)
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
	I ($D(vx("RULEID"))#2) S vux("RULEID")=vx("RULEID")
	I ($D(vx("DECISION"))#2) S vux("DECISION")=vx("DECISION")
	D vkey(1) S voldkey=vobj(utblprodrldt,-3)_","_vobj(utblprodrldt,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(utblprodrldt,-3)_","_vobj(utblprodrldt,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(utblprodrldt)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("UTBLPRODRLDT",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("RULEID"))#2) S vobj(utblprodrldt,-3)=$piece(vux("RULEID"),"|",i)
	I ($D(vux("DECISION"))#2) S vobj(utblprodrldt,-4)=$piece(vux("DECISION"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(UTBLPRODRLDT,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordUTBLPRODRLDT"
	S vobj(vOid)=$G(^UTBL("PRODRL",v1,v2))
	I vobj(vOid)="",'$D(^UTBL("PRODRL",v1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLPRODRLDT" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordUTBLPRODRLDT.copy: UTBLPRODRLDT
	;
	Q $$copy^UCGMR(utblprodrldt)
	;
vReSav1(vnewrec)	;	RecordUTBLPRODRLDT saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^UTBL("PRODRL",vobj(vnewrec,-3),vobj(vnewrec,-4))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
