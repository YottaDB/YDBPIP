SVTYPFL(ctblsvtyp,vpar,vparNorm)	; CTBLSVTYP - PROFILE Service Types Filer
	;
	; **** Routine compiled from DATA-QWIK Filer CTBLSVTYP ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (13)             11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(ctblsvtyp,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(ctblsvtyp,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(ctblsvtyp,.vx,1,"|")
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
	.	I ($D(vx("SVTYP"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("CTBLSVTYP",.vx)
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
	.	  N V1 S V1=vobj(ctblsvtyp,-3) Q:'($D(^CTBL("SVTYP",V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N ctblsvtyp S ctblsvtyp=$$vDb1(SVTYP)
	I (%O=2) D
	.	S vobj(ctblsvtyp,-2)=2
	.	;
	.	D SVTYPFL(ctblsvtyp,vpar)
	.	Q 
	;
	K vobj(+$G(ctblsvtyp)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(ctblsvtyp,-3) I '(''($D(^CTBL("SVTYP",V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(ctblsvtyp,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(ctblsvtyp,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(ctblsvtyp)) S ^CTBL("SVTYP",vobj(ctblsvtyp,-3))=vobj(ctblsvtyp)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(ctblsvtyp,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^CTBL("SVTYP",vobj(ctblsvtyp,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(ctblsvtyp),$C(124),6)="") S $P(vobj(ctblsvtyp),$C(124),6)=0 ; logmsg
	I ($P(vobj(ctblsvtyp),$C(124),7)="") S $P(vobj(ctblsvtyp),$C(124),7)=0 ; logreply
	I ($P(vobj(ctblsvtyp),$C(124),11)="") S $P(vobj(ctblsvtyp),$C(124),11)="MTM" ; mtname
	I ($P(vobj(ctblsvtyp),$C(124),4)="") S $P(vobj(ctblsvtyp),$C(124),4)="SVCNCT^PBSSRV" ; svrpgm
	I ($P(vobj(ctblsvtyp),$C(124),8)="") S $P(vobj(ctblsvtyp),$C(124),8)=45 ; timeout
	I ($P(vobj(ctblsvtyp),$C(124),10)="") S $P(vobj(ctblsvtyp),$C(124),10)=0 ; trapmsg
	I ($P(vobj(ctblsvtyp),$C(124),3)="") S $P(vobj(ctblsvtyp),$C(124),3)=0 ; trust
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(ctblsvtyp),$C(124),1)="") D vreqerr("DESC") Q 
	I ($P(vobj(ctblsvtyp),$C(124),6)="") D vreqerr("LOGMSG") Q 
	I ($P(vobj(ctblsvtyp),$C(124),7)="") D vreqerr("LOGREPLY") Q 
	I ($P(vobj(ctblsvtyp),$C(124),8)="") D vreqerr("TIMEOUT") Q 
	I ($P(vobj(ctblsvtyp),$C(124),10)="") D vreqerr("TRAPMSG") Q 
	I ($P(vobj(ctblsvtyp),$C(124),3)="") D vreqerr("TRUST") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(ctblsvtyp,-3)="") D vreqerr("SVTYP") Q 
	;
	I ($D(vx("DESC"))#2),($P(vobj(ctblsvtyp),$C(124),1)="") D vreqerr("DESC") Q 
	I ($D(vx("LOGMSG"))#2),($P(vobj(ctblsvtyp),$C(124),6)="") D vreqerr("LOGMSG") Q 
	I ($D(vx("LOGREPLY"))#2),($P(vobj(ctblsvtyp),$C(124),7)="") D vreqerr("LOGREPLY") Q 
	I ($D(vx("TIMEOUT"))#2),($P(vobj(ctblsvtyp),$C(124),8)="") D vreqerr("TIMEOUT") Q 
	I ($D(vx("TRAPMSG"))#2),($P(vobj(ctblsvtyp),$C(124),10)="") D vreqerr("TRAPMSG") Q 
	I ($D(vx("TRUST"))#2),($P(vobj(ctblsvtyp),$C(124),3)="") D vreqerr("TRUST") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("CTBLSVTYP","MSG",1767,"CTBLSVTYP."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(ctblsvtyp,-3))>20 S vRM=$$^MSG(1076,20) D vdderr("SVTYP",vRM) Q 
	I $L($P(vobj(ctblsvtyp),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DESC",vRM) Q 
	S X=$P(vobj(ctblsvtyp),$C(124),2) I '(X=""),'($D(^CTBL("FAP",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FAP",vRM) Q 
	S X=$P(vobj(ctblsvtyp),$C(124),9) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("GETMSG",vRM) Q 
	I '("01"[$P(vobj(ctblsvtyp),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("LOGMSG",vRM) Q 
	I '("01"[$P(vobj(ctblsvtyp),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("LOGREPLY",vRM) Q 
	I $L($P(vobj(ctblsvtyp),$C(124),12))>40 S vRM=$$^MSG(1076,40) D vdderr("MSGPGM",vRM) Q 
	S X=$P(vobj(ctblsvtyp),$C(124),11) I '(X=""),'($D(^STBL("MTNAME",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MTNAME",vRM) Q 
	S X=$P(vobj(ctblsvtyp),$C(124),5) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("STATTIM",vRM) Q 
	I $L($P(vobj(ctblsvtyp),$C(124),4))>20 S vRM=$$^MSG(1076,20) D vdderr("SVRPGM",vRM) Q 
	S X=$P(vobj(ctblsvtyp),$C(124),8) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("TIMEOUT",vRM) Q 
	I '("01"[$P(vobj(ctblsvtyp),$C(124),10)) S vRM=$$^MSG(742,"L") D vdderr("TRAPMSG",vRM) Q 
	I '("01"[$P(vobj(ctblsvtyp),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("TRUST",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("CTBLSVTYP","MSG",979,"CTBLSVTYP."_di_" "_vRM)
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
	S vux=vx("SVTYP")
	S voldkey=$piece(vux,"|",1) S vobj(ctblsvtyp,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(ctblsvtyp,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(ctblsvtyp)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("CTBLSVTYP",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(ctblsvtyp,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(CTBLSVTYP,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCTBLSVTYP"
	S vobj(vOid)=$G(^CTBL("SVTYP",v1))
	I vobj(vOid)="",'$D(^CTBL("SVTYP",v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CTBLSVTYP" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordCTBLSVTYP.copy: CTBLSVTYP
	;
	Q $$copy^UCGMR(ctblsvtyp)
	;
vReSav1(vnewrec)	;	RecordCTBLSVTYP saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^CTBL("SVTYP",vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
