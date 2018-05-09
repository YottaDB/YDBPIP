PROCAFIL(processact,vpar,vparNorm)	; PROCESSACT - Process ID Action Request Filer
	;
	; **** Routine compiled from DATA-QWIK Filer PROCESSACT ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (12)             07/12/2005
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(processact,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(processact,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(processact,.vx,1,"|")
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
	.	I ($D(vx("PID"))#2)!($D(vx("SEQNUM"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("PROCESSACT",.vx)
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
	.	  N V1,V2 S V1=vobj(processact,-3),V2=vobj(processact,-4) Q:'($D(^PROCACT(V1,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N processact S processact=$$vDb1(PID,SEQNUM)
	I (%O=2) D
	.	S vobj(processact,-2)=2
	.	;
	.	D PROCAFIL(processact,vpar)
	.	Q 
	;
	K vobj(+$G(processact)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(processact,-3),V2=vobj(processact,-4) I '(''($D(^PROCACT(V1,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(processact)) S ^PROCACT(vobj(processact,-3),vobj(processact,-4))=vobj(processact)
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
	ZWI ^PROCACT(vobj(processact,-3),vobj(processact,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(processact),$C(124),1)="") D vreqerr("ACTION") Q 
	I ($P(vobj(processact),$C(124),5)="") D vreqerr("ISSDATE") Q 
	I ($P(vobj(processact),$C(124),4)="") D vreqerr("ISSPID") Q 
	I ($P(vobj(processact),$C(124),6)="") D vreqerr("ISSTIME") Q 
	I ($P(vobj(processact),$C(124),8)="") D vreqerr("ISSTLO") Q 
	I ($P(vobj(processact),$C(124),7)="") D vreqerr("ISSUSRNM") Q 
	I ($P(vobj(processact),$C(124),3)="") D vreqerr("STATUS") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(processact,-3)="") D vreqerr("PID") Q 
	I (vobj(processact,-4)="") D vreqerr("SEQNUM") Q 
	;
	I ($D(vx("ACTION"))#2),($P(vobj(processact),$C(124),1)="") D vreqerr("ACTION") Q 
	I ($D(vx("ISSDATE"))#2),($P(vobj(processact),$C(124),5)="") D vreqerr("ISSDATE") Q 
	I ($D(vx("ISSPID"))#2),($P(vobj(processact),$C(124),4)="") D vreqerr("ISSPID") Q 
	I ($D(vx("ISSTIME"))#2),($P(vobj(processact),$C(124),6)="") D vreqerr("ISSTIME") Q 
	I ($D(vx("ISSTLO"))#2),($P(vobj(processact),$C(124),8)="") D vreqerr("ISSTLO") Q 
	I ($D(vx("ISSUSRNM"))#2),($P(vobj(processact),$C(124),7)="") D vreqerr("ISSUSRNM") Q 
	I ($D(vx("STATUS"))#2),($P(vobj(processact),$C(124),3)="") D vreqerr("STATUS") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("PROCESSACT","MSG",1767,"PROCESSACT."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(processact,-3) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("PID",vRM) Q 
	S X=vobj(processact,-4) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEQNUM",vRM) Q 
	I $L($P(vobj(processact),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("ACTION",vRM) Q 
	S X=$P(vobj(processact),$C(124),5) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ISSDATE",vRM) Q 
	S X=$P(vobj(processact),$C(124),4) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("ISSPID",vRM) Q 
	S X=$P(vobj(processact),$C(124),6) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("ISSTIME",vRM) Q 
	I $L($P(vobj(processact),$C(124),8))>40 S vRM=$$^MSG(1076,40) D vdderr("ISSTLO",vRM) Q 
	I $L($P(vobj(processact),$C(124),7))>40 S vRM=$$^MSG(1076,40) D vdderr("ISSUSRNM",vRM) Q 
	S X=$P(vobj(processact),$C(124),9) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PRCDATE",vRM) Q 
	S X=$P(vobj(processact),$C(124),10) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("PRCTIME",vRM) Q 
	I $L($P(vobj(processact),$C(124),2))>80 S vRM=$$^MSG(1076,80) D vdderr("QUALIF",vRM) Q 
	I $L($P(vobj(processact),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("STATUS",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("PROCESSACT","MSG",979,"PROCESSACT."_di_" "_vRM)
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
	I ($D(vx("PID"))#2) S vux("PID")=vx("PID")
	I ($D(vx("SEQNUM"))#2) S vux("SEQNUM")=vx("SEQNUM")
	D vkey(1) S voldkey=vobj(processact,-3)_","_vobj(processact,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(processact,-3)_","_vobj(processact,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(processact)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^PROCACT(vobj(vnewrec,-3),vobj(vnewrec,-4))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("PROCESSACT",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("PID"))#2) S vobj(processact,-3)=$piece(vux("PID"),"|",i)
	I ($D(vux("SEQNUM"))#2) S vobj(processact,-4)=$piece(vux("SEQNUM"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(PROCESSACT,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSACT"
	S vobj(vOid)=$G(^PROCACT(v1,v2))
	I vobj(vOid)="",'$D(^PROCACT(v1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,PROCESSACT" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordPROCESSACT.copy: PROCESSACT
	;
	Q $$copy^UCGMR(processact)
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
