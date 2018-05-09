RULEFILE(utblprodrl,vpar,vparNorm)	; UTBLPRODRL - Product Attribute Rule Set Filer
	;
	; **** Routine compiled from DATA-QWIK Filer UTBLPRODRL ****
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
	N %O S %O=$G(vobj(utblprodrl,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(utblprodrl,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(utblprodrl,.vx,1,"|")
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
	.	I ($D(vx("RULEID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("UTBLPRODRL",.vx)
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
	.	  N V1 S V1=vobj(utblprodrl,-3) Q:'($D(^UTBL("PRODRL",V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N utblprodrl S utblprodrl=$$vDb1(RULEID)
	I (%O=2) D
	.	S vobj(utblprodrl,-2)=2
	.	;
	.	D RULEFILE(utblprodrl,vpar)
	.	Q 
	;
	K vobj(+$G(utblprodrl)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(utblprodrl,-3) I '(''($D(^UTBL("PRODRL",V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrl,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrl,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(utblprodrl)) S ^UTBL("PRODRL",vobj(utblprodrl,-3))=vobj(utblprodrl)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(utblprodrl,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^UTBL("PRODRL",vobj(utblprodrl,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(utblprodrl),$C(124),2)="") D vreqerr("MARSEG") Q 
	I ($P(vobj(utblprodrl),$C(124),3)="") D vreqerr("SEGID") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(utblprodrl,-3)="") D vreqerr("RULEID") Q 
	;
	I ($D(vx("MARSEG"))#2),($P(vobj(utblprodrl),$C(124),2)="") D vreqerr("MARSEG") Q 
	I ($D(vx("SEGID"))#2),($P(vobj(utblprodrl),$C(124),3)="") D vreqerr("SEGID") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRL","MSG",1767,"UTBLPRODRL."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(utblprodrl,-3) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("RULEID",vRM) Q 
	I $L($P(vobj(utblprodrl),$C(124),5))>200 S vRM=$$^MSG(1076,200) D vdderr("COLNAMES",vRM) Q 
	I $L($P(vobj(utblprodrl),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(utblprodrl),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("FILES",vRM) Q 
	S X=$P(vobj(utblprodrl),$C(124),2) I '(X=""),'($D(^UTBL("MARSEG",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MARSEG",vRM) Q 
	S X=$P(vobj(utblprodrl),$C(124),3) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEGID",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLPRODRL","MSG",979,"UTBLPRODRL."_di_" "_vRM)
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
	S vux=vx("RULEID")
	S voldkey=$piece(vux,"|",1) S vobj(utblprodrl,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(utblprodrl,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(utblprodrl)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("UTBLPRODRL",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(utblprodrl,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(UTBLPRODRL,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordUTBLPRODRL"
	S vobj(vOid)=$G(^UTBL("PRODRL",v1))
	I vobj(vOid)="",'$D(^UTBL("PRODRL",v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLPRODRL" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordUTBLPRODRL.copy: UTBLPRODRL
	;
	Q $$copy^UCGMR(utblprodrl)
	;
vReSav1(vnewrec)	;	RecordUTBLPRODRL saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^UTBL("PRODRL",vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
