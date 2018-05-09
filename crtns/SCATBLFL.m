SCATBLFL(scatbl,vpar,vparNorm)	; SCATBL - System Function Table Filer
	;
	; **** Routine compiled from DATA-QWIK Filer SCATBL ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (18)             03/08/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(scatbl,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(scatbl,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(scatbl,.vx,1,"|")
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
	.	I ($D(vx("FN"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("SCATBL",.vx)
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
	.	  N V1 S V1=vobj(scatbl,-3) Q:'($D(^SCATBL(1,V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N scatbl S scatbl=$$vDb1(FN)
	I (%O=2) D
	.	S vobj(scatbl,-2)=2
	.	;
	.	D SCATBLFL(scatbl,vpar)
	.	Q 
	;
	K vobj(+$G(scatbl)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(scatbl,-3) I '(''($D(^SCATBL(1,V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(scatbl,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(scatbl,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(scatbl)) S ^SCATBL(1,vobj(scatbl,-3))=vobj(scatbl)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(scatbl,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^SCATBL(1,vobj(scatbl,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(scatbl),$C(124),11)="") S $P(vobj(scatbl),$C(124),11)="PBS" ; %sn
	I ($P(vobj(scatbl),$C(124),17)="") S $P(vobj(scatbl),$C(124),17)=0 ; bpsflg
	I ($P(vobj(scatbl),$C(124),15)="") S $P(vobj(scatbl),$C(124),15)=0 ; break
	I ($P(vobj(scatbl),$C(124),5)="") S $P(vobj(scatbl),$C(124),5)=0 ; ddp
	I ($P(vobj(scatbl),$C(124),16)="") S $P(vobj(scatbl),$C(124),16)=0 ; nohost
	I ($P(vobj(scatbl),$C(124),19)="") S $P(vobj(scatbl),$C(124),19)=0 ; norepost
	I ($P(vobj(scatbl),$C(124),18)="") S $P(vobj(scatbl),$C(124),18)=0 ; queue
	I ($P(vobj(scatbl),$C(124),14)="") S $P(vobj(scatbl),$C(124),14)=0 ; restore
	I ($P(vobj(scatbl),$C(124),6)="") S $P(vobj(scatbl),$C(124),6)=0 ; salon
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(scatbl),$C(124),17)="") D vreqerr("BPSFLG") Q 
	I ($P(vobj(scatbl),$C(124),15)="") D vreqerr("BREAK") Q 
	I ($P(vobj(scatbl),$C(124),5)="") D vreqerr("DDP") Q 
	I ($P(vobj(scatbl),$C(124),16)="") D vreqerr("NOHOST") Q 
	I ($P(vobj(scatbl),$C(124),19)="") D vreqerr("NOREPOST") Q 
	I ($P(vobj(scatbl),$C(124),18)="") D vreqerr("QUEUE") Q 
	I ($P(vobj(scatbl),$C(124),14)="") D vreqerr("RESTORE") Q 
	I ($P(vobj(scatbl),$C(124),6)="") D vreqerr("SALON") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(scatbl,-3)="") D vreqerr("FN") Q 
	;
	I ($D(vx("BPSFLG"))#2),($P(vobj(scatbl),$C(124),17)="") D vreqerr("BPSFLG") Q 
	I ($D(vx("BREAK"))#2),($P(vobj(scatbl),$C(124),15)="") D vreqerr("BREAK") Q 
	I ($D(vx("DDP"))#2),($P(vobj(scatbl),$C(124),5)="") D vreqerr("DDP") Q 
	I ($D(vx("NOHOST"))#2),($P(vobj(scatbl),$C(124),16)="") D vreqerr("NOHOST") Q 
	I ($D(vx("NOREPOST"))#2),($P(vobj(scatbl),$C(124),19)="") D vreqerr("NOREPOST") Q 
	I ($D(vx("QUEUE"))#2),($P(vobj(scatbl),$C(124),18)="") D vreqerr("QUEUE") Q 
	I ($D(vx("RESTORE"))#2),($P(vobj(scatbl),$C(124),14)="") D vreqerr("RESTORE") Q 
	I ($D(vx("SALON"))#2),($P(vobj(scatbl),$C(124),6)="") D vreqerr("SALON") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("SCATBL","MSG",1767,"SCATBL."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(scatbl,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("FN",vRM) Q 
	I $L($P(vobj(scatbl),$C(124),10))>20 S vRM=$$^MSG(1076,20) D vdderr("%LIBS",vRM) Q 
	S X=$P(vobj(scatbl),$C(124),11) I '(X=""),'($D(^SCATBL(2,X))#2) S vRM=$$^MSG(1485,X) D vdderr("%SN",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),17)) S vRM=$$^MSG(742,"L") D vdderr("BPSFLG",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),15)) S vRM=$$^MSG(742,"L") D vdderr("BREAK",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("DDP",vRM) Q 
	I $L($P(vobj(scatbl),$C(124),1))>50 S vRM=$$^MSG(1076,50) D vdderr("DESC",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),16)) S vRM=$$^MSG(742,"L") D vdderr("NOHOST",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),19)) S vRM=$$^MSG(742,"L") D vdderr("NOREPOST",vRM) Q 
	I $L($P(vobj(scatbl),$C(124),4))>200 S vRM=$$^MSG(1076,200) D vdderr("PGM",vRM) Q 
	I $L($P(vobj(scatbl),$C(124),3))>255 S vRM=$$^MSG(1076,255) D vdderr("POP",vRM) Q 
	I $L($P(vobj(scatbl),$C(124),2))>255 S vRM=$$^MSG(1076,255) D vdderr("PRP",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),18)) S vRM=$$^MSG(742,"L") D vdderr("QUEUE",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("RESTORE",vRM) Q 
	I '("01"[$P(vobj(scatbl),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("SALON",vRM) Q 
	I $L($P(vobj(scatbl),$C(124),12))>12 S vRM=$$^MSG(1076,12) D vdderr("TFK",vRM) Q 
	S X=$P(vobj(scatbl),$C(124),7) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIMBEG",vRM) Q 
	S X=$P(vobj(scatbl),$C(124),8) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIMEND",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("SCATBL","MSG",979,"SCATBL."_di_" "_vRM)
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
	S vux=vx("FN")
	S voldkey=$piece(vux,"|",1) S vobj(scatbl,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(scatbl,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(scatbl)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("SCATBL",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(scatbl,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(SCATBL,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL"
	S vobj(vOid)=$G(^SCATBL(1,v1))
	I vobj(vOid)="",'$D(^SCATBL(1,v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCATBL" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordSCATBL.copy: SCATBL
	;
	Q $$copy^UCGMR(scatbl)
	;
vReSav1(vnewrec)	;	RecordSCATBL saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^SCATBL(1,vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
