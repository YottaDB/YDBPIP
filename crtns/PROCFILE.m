PROCFILE(processid,vpar,vparNorm)	; PROCESSID - M Process ID Filer
	;
	; **** Routine compiled from DATA-QWIK Filer PROCESSID ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (12)             07/12/2005
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(processid,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(processid,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(processid,.vx,1,"|")
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
	.	I ($D(vx("PID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("PROCESSID",.vx)
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
	.	  N V1 S V1=vobj(processid,-3) Q:'($D(^PROCID(V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N processid S processid=$$vDb1(PID)
	I (%O=2) D
	.	S vobj(processid,-2)=2
	.	;
	.	D PROCFILE(processid,vpar)
	.	Q 
	;
	K vobj(+$G(processid)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(processid,-3) I '(''($D(^PROCID(V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(processid)) S ^PROCID(vobj(processid,-3))=vobj(processid)
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
	ZWI ^PROCID(vobj(processid,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(processid),$C(124),3)="") D vreqerr("MODE") Q 
	I ($P(vobj(processid),$C(124),6)="") D vreqerr("PRCTYP") Q 
	I ($P(vobj(processid),$C(124),1)="") D vreqerr("REGDATE") Q 
	I ($P(vobj(processid),$C(124),2)="") D vreqerr("REGTIME") Q 
	I ($P(vobj(processid),$C(124),4)="") D vreqerr("TLO") Q 
	I ($P(vobj(processid),$C(124),5)="") D vreqerr("USRNAM") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(processid,-3)="") D vreqerr("PID") Q 
	;
	I ($D(vx("MODE"))#2),($P(vobj(processid),$C(124),3)="") D vreqerr("MODE") Q 
	I ($D(vx("PRCTYP"))#2),($P(vobj(processid),$C(124),6)="") D vreqerr("PRCTYP") Q 
	I ($D(vx("REGDATE"))#2),($P(vobj(processid),$C(124),1)="") D vreqerr("REGDATE") Q 
	I ($D(vx("REGTIME"))#2),($P(vobj(processid),$C(124),2)="") D vreqerr("REGTIME") Q 
	I ($D(vx("TLO"))#2),($P(vobj(processid),$C(124),4)="") D vreqerr("TLO") Q 
	I ($D(vx("USRNAM"))#2),($P(vobj(processid),$C(124),5)="") D vreqerr("USRNAM") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("PROCESSID","MSG",1767,"PROCESSID."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(processid,-3) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("PID",vRM) Q 
	S X=$P(vobj(processid),$C(124),11) I '(X=""),'($D(^UTBL("EVENT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("EVENT",vRM) Q 
	I $L($P(vobj(processid),$C(124),10))>12 S vRM=$$^MSG(1076,12) D vdderr("FUNC",vRM) Q 
	I $L($P(vobj(processid),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("MODE",vRM) Q 
	I $L($P(vobj(processid),$C(124),6))>10 S vRM=$$^MSG(1076,10) D vdderr("PRCTYP",vRM) Q 
	S X=$P(vobj(processid),$C(124),1) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("REGDATE",vRM) Q 
	S X=$P(vobj(processid),$C(124),2) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("REGTIME",vRM) Q 
	I $L($P(vobj(processid),$C(124),7))>20 S vRM=$$^MSG(1076,20) D vdderr("SUBTYP",vRM) Q 
	I $L($P(vobj(processid),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("TLO",vRM) Q 
	I $L($P(vobj(processid),$C(124),8))>12 S vRM=$$^MSG(1076,12) D vdderr("USERID",vRM) Q 
	I $L($P(vobj(processid),$C(124),9))>12 S vRM=$$^MSG(1076,12) D vdderr("USRCLS",vRM) Q 
	I $L($P(vobj(processid),$C(124),5))>40 S vRM=$$^MSG(1076,40) D vdderr("USRNAM",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("PROCESSID","MSG",979,"PROCESSID."_di_" "_vRM)
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
	S vux=vx("PID")
	S voldkey=$piece(vux,"|",1) S vobj(processid,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(processid,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(processid)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^PROCID(vobj(vnewrec,-3))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("PROCESSID",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(processid,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(PROCESSID,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSID"
	S vobj(vOid)=$G(^PROCID(v1))
	I vobj(vOid)="",'$D(^PROCID(v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,PROCESSID" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordPROCESSID.copy: PROCESSID
	;
	Q $$copy^UCGMR(processid)
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
