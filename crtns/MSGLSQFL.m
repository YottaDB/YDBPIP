MSGLSQFL(msglogseq,vpar,vparNorm)	; MSGLOGSEQ - Client Messages/Server Replies Filer
	;
	; **** Routine compiled from DATA-QWIK Filer MSGLOGSEQ ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (3)              11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(msglogseq,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(msglogseq,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(msglogseq,.vx,1,"|")
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
	.	I ($D(vx("TOKEN"))#2)!($D(vx("MSGID"))#2)!($D(vx("MSGTYP"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("MSGLOGSEQ",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(msglogseq,-3),V2=vobj(msglogseq,-4),V3=vobj(msglogseq,-5) Q:'($D(^MSGLOG(V1,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N msglogseq S msglogseq=$$vDb1(TOKEN,MSGID,MSGTYP)
	I (%O=2) D
	.	S vobj(msglogseq,-2)=2
	.	;
	.	D MSGLSQFL(msglogseq,vpar)
	.	Q 
	;
	K vobj(+$G(msglogseq)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(msglogseq,-3),V2=vobj(msglogseq,-4),V3=vobj(msglogseq,-5) I '(''($D(^MSGLOG(V1,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(msglogseq)) K:$D(vobj(msglogseq,1,1)) ^MSGLOG(vobj(msglogseq,-3),vobj(msglogseq,-4),vobj(msglogseq,-5)) S ^MSGLOG(vobj(msglogseq,-3),vobj(msglogseq,-4),vobj(msglogseq,-5))=vobj(msglogseq)
	.	;*** End of code by-passed by compiler ***
	.	; Allow global reference and M source code
	.	;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(msglogseq,1,1)) N vS1,vS2 S vS1=0 F vS2=1:450:$L(vobj(msglogseq,1,1)) S vS1=vS1+1,^MSGLOG(vobj(msglogseq,-3),vobj(msglogseq,-4),vobj(msglogseq,-5),vS1)=$E(vobj(msglogseq,1,1),vS2,vS2+449)
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
	kill ^MSGLOG(vobj(msglogseq,-3),vobj(msglogseq,-4),vobj(msglogseq,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(msglogseq,-3)="") D vreqerr("TOKEN") Q 
	I (vobj(msglogseq,-4)="") D vreqerr("MSGID") Q 
	I (vobj(msglogseq,-5)="") D vreqerr("MSGTYP") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("MSGLOGSEQ","MSG",1767,"MSGLOGSEQ."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(msglogseq,-3))>10 S vRM=$$^MSG(1076,10) D vdderr("TOKEN",vRM) Q 
	I $L(vobj(msglogseq,-4))>40 S vRM=$$^MSG(1076,40) D vdderr("MSGID",vRM) Q 
	S X=vobj(msglogseq,-5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("MSGTYP",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("MSGLOGSEQ","MSG",979,"MSGLOGSEQ."_di_" "_vRM)
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
	I ($D(vx("MSGTYP"))#2) S vux("MSGTYP")=vx("MSGTYP")
	D vkey(1) S voldkey=vobj(msglogseq,-3)_","_vobj(msglogseq,-4)_","_vobj(msglogseq,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(msglogseq,-3)_","_vobj(msglogseq,-4)_","_vobj(msglogseq,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(msglogseq)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("MSGLOGSEQ",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("TOKEN"))#2) S vobj(msglogseq,-3)=$piece(vux("TOKEN"),"|",i)
	I ($D(vux("MSGID"))#2) S vobj(msglogseq,-4)=$piece(vux("MSGID"),"|",i)
	I ($D(vux("MSGTYP"))#2) S vobj(msglogseq,-5)=$piece(vux("MSGTYP"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(MSGLOGSEQ,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordMSGLOGSEQ"
	S vobj(vOid)=$G(^MSGLOG(v1,v2,v3))
	I vobj(vOid)="",'$D(^MSGLOG(v1,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,MSGLOGSEQ" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordMSGLOGSEQ.copy: MSGLOGSEQ
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	. S:'$D(vobj(v1,1,1)) vobj(v1,1,1)="" N von S von="" F  S von=$O(^MSGLOG(vobj(v1,-3),vobj(v1,-4),vobj(v1,-5),von)) quit:von=""  S vobj(v1,1,1)=vobj(v1,1,1)_^MSGLOG(vobj(v1,-3),vobj(v1,-4),vobj(v1,-5),von)
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordMSGLOGSEQ saveNoFiler()
	;
	S ^MSGLOG(vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
	N vC,vS s vS=0
	F vC=1:450:$L($G(vobj(vnewrec,1,1))) S vS=vS+1,^MSGLOG(vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5),vS)=$E(vobj(vnewrec,1,1),vC,vC+449)
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
