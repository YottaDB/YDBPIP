MSGLGFL(msglog,vpar,vparNorm)	; MSGLOG - Client Message Log Filer
	;
	; **** Routine compiled from DATA-QWIK Filer MSGLOG ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (8)              01/19/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(msglog,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(msglog,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(msglog,.vx,1,"|")
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
	.	I ($D(vx("TOKEN"))#2)!($D(vx("MSGID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("MSGLOG",.vx)
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
	.	  N V1,V2 S V1=vobj(msglog,-3),V2=vobj(msglog,-4) Q:'($D(^MSGLOG(V1,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N msglog S msglog=$$vDb1(TOKEN,MSGID)
	I (%O=2) D
	.	S vobj(msglog,-2)=2
	.	;
	.	D MSGLGFL(msglog,vpar)
	.	Q 
	;
	K vobj(+$G(msglog)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(msglog,-3),V2=vobj(msglog,-4) I '(''($D(^MSGLOG(V1,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(msglog)) S ^MSGLOG(vobj(msglog,-3),vobj(msglog,-4))=vobj(msglog)
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
	ZWI ^MSGLOG(vobj(msglog,-3),vobj(msglog,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(msglog,-3)="") D vreqerr("TOKEN") Q 
	I (vobj(msglog,-4)="") D vreqerr("MSGID") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("MSGLOG","MSG",1767,"MSGLOG."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(msglog,-3))>10 S vRM=$$^MSG(1076,10) D vdderr("TOKEN",vRM) Q 
	I $L(vobj(msglog,-4))>40 S vRM=$$^MSG(1076,40) D vdderr("MSGID",vRM) Q 
	I $L($P(vobj(msglog),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("DATETIME",vRM) Q 
	I $L($P(vobj(msglog),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("PID",vRM) Q 
	I $L($P(vobj(msglog),$C(124),5))>40 S vRM=$$^MSG(1076,40) D vdderr("SERVER",vRM) Q 
	S X=$P(vobj(msglog),$C(124),4) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SRVCLS",vRM) Q 
	S X=$P(vobj(msglog),$C(124),3) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("STATUS",vRM) Q 
	I $L($P(vobj(msglog),$C(124),6))>25 S vRM=$$^MSG(1076,25) D vdderr("VZSTART",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("MSGLOG","MSG",979,"MSGLOG."_di_" "_vRM)
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
	I ($D(vx("TOKEN"))#2) S vux("TOKEN")=vx("TOKEN")
	I ($D(vx("MSGID"))#2) S vux("MSGID")=vx("MSGID")
	D vkey(1) S voldkey=vobj(msglog,-3)_","_vobj(msglog,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(msglog,-3)_","_vobj(msglog,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(msglog)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^MSGLOG(vobj(vnewrec,-3),vobj(vnewrec,-4))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("MSGLOG",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("TOKEN"))#2) S vobj(msglog,-3)=$piece(vux("TOKEN"),"|",i)
	I ($D(vux("MSGID"))#2) S vobj(msglog,-4)=$piece(vux("MSGID"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(MSGLOG,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordMSGLOG"
	S vobj(vOid)=$G(^MSGLOG(v1,v2))
	I vobj(vOid)="",'$D(^MSGLOG(v1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,MSGLOG" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordMSGLOG.copy: MSGLOG
	;
	Q $$copy^UCGMR(msglog)
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
