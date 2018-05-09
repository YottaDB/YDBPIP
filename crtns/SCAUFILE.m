SCAUFILE(scau,vpar,vparNorm)	; SCAU - User Identification Filer
	;
	; **** Routine compiled from DATA-QWIK Filer SCAU ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (46)             08/23/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(scau,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(scau,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(scau,.vx,1,"|")
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
	.	I ($D(vx("UID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("SCAU",.vx)
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
	.	  N V1 S V1=vobj(scau,-3) Q:'($D(^SCAU(1,V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N scau S scau=$$vDb1(UID)
	I (%O=2) D
	.	S vobj(scau,-2)=2
	.	;
	.	D SCAUFILE(scau,vpar)
	.	Q 
	;
	K vobj(+$G(scau)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(scau,-3) I '(''($D(^SCAU(1,V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(scau,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(scau,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(scau)) S ^SCAU(1,vobj(scau,-3))=vobj(scau)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(scau,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^SCAU(1,vobj(scau,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(scau),$C(124),2)="") S $P(vobj(scau),$C(124),2)=0 ; automenu
	I ($P(vobj(scau),$C(124),36)="") S $P(vobj(scau),$C(124),36)=0 ; emulim
	I ($P(vobj(scau),$C(124),44)="") S $P(vobj(scau),$C(124),44)=0 ; mrstat
	I ($P(vobj(scau),$C(124),4)="") S $P(vobj(scau),$C(124),4)=0 ; newpwdreq
	I ($P(vobj(scau),$C(124),46)="") S $P(vobj(scau),$C(124),46)=0 ; retbrcd
	I ($P(vobj(scau),$C(124),31)="") S $P(vobj(scau),$C(124),31)=0 ; sdrty
	I ($P(vobj(scau),$C(124),18)="") S $P(vobj(scau),$C(124),18)=0 ; tpm
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(scau),$C(124),2)="") D vreqerr("AUTOMENU") Q 
	I ($P(vobj(scau),$C(124),36)="") D vreqerr("EMULIM") Q 
	I ($P(vobj(scau),$C(124),44)="") D vreqerr("MRSTAT") Q 
	I ($P(vobj(scau),$C(124),4)="") D vreqerr("NEWPWDREQ") Q 
	I ($P(vobj(scau),$C(124),46)="") D vreqerr("RETBRCD") Q 
	I ($P(vobj(scau),$C(124),31)="") D vreqerr("SDRTY") Q 
	I ($P(vobj(scau),$C(124),18)="") D vreqerr("TPM") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(scau,-3)="") D vreqerr("UID") Q 
	;
	I ($D(vx("AUTOMENU"))#2),($P(vobj(scau),$C(124),2)="") D vreqerr("AUTOMENU") Q 
	I ($D(vx("EMULIM"))#2),($P(vobj(scau),$C(124),36)="") D vreqerr("EMULIM") Q 
	I ($D(vx("MRSTAT"))#2),($P(vobj(scau),$C(124),44)="") D vreqerr("MRSTAT") Q 
	I ($D(vx("NEWPWDREQ"))#2),($P(vobj(scau),$C(124),4)="") D vreqerr("NEWPWDREQ") Q 
	I ($D(vx("RETBRCD"))#2),($P(vobj(scau),$C(124),46)="") D vreqerr("RETBRCD") Q 
	I ($D(vx("SDRTY"))#2),($P(vobj(scau),$C(124),31)="") D vreqerr("SDRTY") Q 
	I ($D(vx("TPM"))#2),($P(vobj(scau),$C(124),18)="") D vreqerr("TPM") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("SCAU","MSG",1767,"SCAU."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(scau,-3))>20 S vRM=$$^MSG(1076,20) D vdderr("UID",vRM) Q 
	S X=$P(vobj(scau),$C(124),5) I '(X=""),'($D(^SCAU(0,X))#2) S vRM=$$^MSG(1485,X) D vdderr("%UCLS",vRM) Q 
	I $L($P(vobj(scau),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("%UFN",vRM) Q 
	S X=$P(vobj(scau),$C(124),14) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("ACN",vRM) Q 
	I '("01"[$P(vobj(scau),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("AUTOMENU",vRM) Q 
	S X=$P(vobj(scau),$C(124),17) I '(X=""),'($D(^STBL("BATREJ",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BATREJ",vRM) Q 
	S X=$P(vobj(scau),$C(124),22) I '(X=""),'($D(^UTBL("BRCD",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BRCD",vRM) Q 
	S X=$P(vobj(scau),$C(124),26) I '(X=""),'($D(^UTBL("BSC",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BRROSC",vRM) Q 
	S X=$P(vobj(scau),$C(124),25) I '(X=""),'($D(^UTBL("BSC",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BRRWSC",vRM) Q 
	S X=$P(vobj(scau),$C(124),11) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("CSOVR",vRM) Q 
	S X=$P(vobj(scau),$C(124),12) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("CSSHRT",vRM) Q 
	S X=$P(vobj(scau),$C(124),29) I '(X=""),'($D(^STBL("CURRENV",X))#2) S vRM=$$^MSG(1485,X) D vdderr("CURRENV",vRM) Q 
	I $L($P(vobj(scau),$C(124),48))>55 S vRM=$$^MSG(1076,55) D vdderr("EADDR",vRM) Q 
	S X=$P(vobj(scau),$C(124),21) I '(X=""),'($D(^DBCTL("SYS","EDITOR",X))#2) S vRM=$$^MSG(1485,X) D vdderr("EDITOR",vRM) Q 
	I '("01"[$P(vobj(scau),$C(124),36)) S vRM=$$^MSG(742,"L") D vdderr("EMULIM",vRM) Q 
	S X=$P(vobj(scau),$C(124),3) I '(X=""),'($D(^UTBL("LANG",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LANG",vRM) Q 
	S X=$P(vobj(scau),$C(124),8) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LSGN",vRM) Q 
	S X=$P(vobj(scau),$C(124),37) I '(X=""),'($D(^UTBL("MARSEG",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MARSEG",vRM) Q 
	S X=$P(vobj(scau),$C(124),20) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("MARTY",vRM) Q 
	S X=$P(vobj(scau),$C(124),45) I '(X=""),'($D(^UTBL("MREASON",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MREASON",vRM) Q 
	I '("01"[$P(vobj(scau),$C(124),44)) S vRM=$$^MSG(742,"L") D vdderr("MRSTAT",vRM) Q 
	I '("01"[$P(vobj(scau),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("NEWPWDREQ",vRM) Q 
	S X=$P(vobj(scau),$C(124),34) I '(X="") S vRM=$$VAL^DBSVER("$",12,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"SCAU.OACMAX"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=$P(vobj(scau),$C(124),35) I '(X="") S vRM=$$VAL^DBSVER("$",12,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"SCAU.OACMIN"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=$P(vobj(scau),$C(124),32) I '(X=""),'($D(^STBL("PATODP",X))#2) S vRM=$$^MSG(1485,X) D vdderr("ODP",vRM) Q 
	S X=$P(vobj(scau),$C(124),33) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("ODPRET",vRM) Q 
	S X=$P(vobj(scau),$C(124),7) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PEXPR",vRM) Q 
	I $L($P(vobj(scau),$C(124),6))>12 S vRM=$$^MSG(1076,12) D vdderr("PSWD",vRM) Q 
	I $L($P(vobj(scau),$C(124),39))>32 S vRM=$$^MSG(1076,32) D vdderr("PSWDAUT",vRM) Q 
	S X=$P(vobj(scau),$C(124),43) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("PWDFAIL",vRM) Q 
	S X=$P(vobj(scau),$C(124),24) I '(X=""),'($D(^UTBL("RSC",X))#2) S vRM=$$^MSG(1485,X) D vdderr("REGROSC",vRM) Q 
	S X=$P(vobj(scau),$C(124),23) I '(X=""),'($D(^UTBL("RSC",X))#2) S vRM=$$^MSG(1485,X) D vdderr("REGRWSC",vRM) Q 
	S X=$P(vobj(scau),$C(124),40) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"SCAU.RETBALLIM"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	I '("01"[$P(vobj(scau),$C(124),46)) S vRM=$$^MSG(742,"L") D vdderr("RETBRCD",vRM) Q 
	S X=$P(vobj(scau),$C(124),41) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"SCAU.RETCOLLIM"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=$P(vobj(scau),$C(124),42) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"SCAU.RETFEELIM"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=$P(vobj(scau),$C(124),16) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("ROCR",vRM) Q 
	S X=$P(vobj(scau),$C(124),15) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("RODR",vRM) Q 
	I $L($P(vobj(scau),$C(124),19))>20 S vRM=$$^MSG(1076,20) D vdderr("RTUID",vRM) Q 
	I '("01"[$P(vobj(scau),$C(124),31)) S vRM=$$^MSG(742,"L") D vdderr("SDRTY",vRM) Q 
	S X=$P(vobj(scau),$C(124),38) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEGID",vRM) Q 
	I $L($P(vobj(scau),$C(124),27))>12 S vRM=$$^MSG(1076,12) D vdderr("TFKDEF",vRM) Q 
	I '("01"[$P(vobj(scau),$C(124),18)) S vRM=$$^MSG(742,"L") D vdderr("TPM",vRM) Q 
	S X=$P(vobj(scau),$C(124),47) I '(X=""),'($D(^STBL("TRNSRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TRNSRT",vRM) Q 
	S X=$P(vobj(scau),$C(124),10) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("TSCR",vRM) Q 
	S X=$P(vobj(scau),$C(124),9) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("TSDR",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("SCAU","MSG",979,"SCAU."_di_" "_vRM)
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
	S vux=vx("UID")
	S voldkey=$piece(vux,"|",1) S vobj(scau,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(scau,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(scau)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("SCAU",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(scau,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(SCAU,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU"
	S vobj(vOid)=$G(^SCAU(1,v1))
	I vobj(vOid)="",'$D(^SCAU(1,v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordSCAU.copy: SCAU
	;
	Q $$copy^UCGMR(scau)
	;
vReSav1(vnewrec)	;	RecordSCAU saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^SCAU(1,vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
