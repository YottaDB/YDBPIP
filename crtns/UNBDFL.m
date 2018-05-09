UNBDFL(utblnbd,vpar,vparNorm)	; UTBLNBD - Non-Business Date Calendars Filer
	;
	; **** Routine compiled from DATA-QWIK Filer UTBLNBD ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (10)             11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(utblnbd,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(utblnbd,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(utblnbd,.vx,1,"|")
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
	.	I ($D(vx("NBDC"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("UTBLNBD",.vx)
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
	.	  N V1 S V1=vobj(utblnbd,-3) Q:'($D(^UTBL("NBD",V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N utblnbd S utblnbd=$$vDb1(NBDC)
	I (%O=2) D
	.	S vobj(utblnbd,-2)=2
	.	;
	.	D UNBDFL(utblnbd,vpar)
	.	Q 
	;
	K vobj(+$G(utblnbd)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(utblnbd,-3) I '(''($D(^UTBL("NBD",V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(utblnbd,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(utblnbd,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(utblnbd)) S ^UTBL("NBD",vobj(utblnbd,-3))=vobj(utblnbd)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(utblnbd,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^UTBL("NBD",vobj(utblnbd,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(utblnbd),$C(124),3)="") S $P(vobj(utblnbd),$C(124),3)=0 ; fri
	I ($P(vobj(utblnbd),$C(124),6)="") S $P(vobj(utblnbd),$C(124),6)=0 ; mon
	I ($P(vobj(utblnbd),$C(124),4)="") S $P(vobj(utblnbd),$C(124),4)=0 ; sat
	I ($P(vobj(utblnbd),$C(124),5)="") S $P(vobj(utblnbd),$C(124),5)=0 ; sun
	I ($P(vobj(utblnbd),$C(124),2)="") S $P(vobj(utblnbd),$C(124),2)=0 ; thu
	I ($P(vobj(utblnbd),$C(124),7)="") S $P(vobj(utblnbd),$C(124),7)=0 ; tue
	I ($P(vobj(utblnbd),$C(124),8)="") S $P(vobj(utblnbd),$C(124),8)=0 ; wed
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(utblnbd),$C(124),3)="") D vreqerr("FRI") Q 
	I ($P(vobj(utblnbd),$C(124),6)="") D vreqerr("MON") Q 
	I ($P(vobj(utblnbd),$C(124),4)="") D vreqerr("SAT") Q 
	I ($P(vobj(utblnbd),$C(124),5)="") D vreqerr("SUN") Q 
	I ($P(vobj(utblnbd),$C(124),2)="") D vreqerr("THU") Q 
	I ($P(vobj(utblnbd),$C(124),7)="") D vreqerr("TUE") Q 
	I ($P(vobj(utblnbd),$C(124),8)="") D vreqerr("WED") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(utblnbd,-3)="") D vreqerr("NBDC") Q 
	;
	I ($D(vx("FRI"))#2),($P(vobj(utblnbd),$C(124),3)="") D vreqerr("FRI") Q 
	I ($D(vx("MON"))#2),($P(vobj(utblnbd),$C(124),6)="") D vreqerr("MON") Q 
	I ($D(vx("SAT"))#2),($P(vobj(utblnbd),$C(124),4)="") D vreqerr("SAT") Q 
	I ($D(vx("SUN"))#2),($P(vobj(utblnbd),$C(124),5)="") D vreqerr("SUN") Q 
	I ($D(vx("THU"))#2),($P(vobj(utblnbd),$C(124),2)="") D vreqerr("THU") Q 
	I ($D(vx("TUE"))#2),($P(vobj(utblnbd),$C(124),7)="") D vreqerr("TUE") Q 
	I ($D(vx("WED"))#2),($P(vobj(utblnbd),$C(124),8)="") D vreqerr("WED") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLNBD","MSG",1767,"UTBLNBD."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(utblnbd,-3))>6 S vRM=$$^MSG(1076,6) D vdderr("NBDC",vRM) Q 
	I $L($P(vobj(utblnbd),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("CALDES",vRM) Q 
	S X=$P(vobj(utblnbd),$C(124),9) I '(X=""),'($D(^STBL("CNTRY",X))#2) S vRM=$$^MSG(1485,X) D vdderr("CNTRY",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("FRI",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("MON",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("SAT",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("SUN",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("THU",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("TUE",vRM) Q 
	I '("01"[$P(vobj(utblnbd),$C(124),8)) S vRM=$$^MSG(742,"L") D vdderr("WED",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("UTBLNBD","MSG",979,"UTBLNBD."_di_" "_vRM)
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
	S vux=vx("NBDC")
	S voldkey=$piece(vux,"|",1) S vobj(utblnbd,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(utblnbd,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(utblnbd)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("UTBLNBD",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(utblnbd,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(UTBLNBD,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordUTBLNBD"
	S vobj(vOid)=$G(^UTBL("NBD",v1))
	I vobj(vOid)="",'$D(^UTBL("NBD",v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLNBD" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordUTBLNBD.copy: UTBLNBD
	;
	Q $$copy^UCGMR(utblnbd)
	;
vReSav1(vnewrec)	;	RecordUTBLNBD saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^UTBL("NBD",vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
