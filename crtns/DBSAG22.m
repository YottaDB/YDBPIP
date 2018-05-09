DBSAG22(dbtbl22,vpar,vparNorm)	; DBTBL22 - DATA-QWIK Aggregate Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL22 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (13)             10/14/2005
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl22,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl22,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl22,.vx,1,"|")
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
	.	I ($D(vx("%LIBS"))#2)!($D(vx("AGID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL22",.vx)
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
	.	  N V1,V2 S V1=vobj(dbtbl22,-3),V2=vobj(dbtbl22,-4) Q:'($D(^DBTBL(V1,22,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl22 S dbtbl22=$$vDb1(%LIBS,AGID)
	I (%O=2) D
	.	S vobj(dbtbl22,-2)=2
	.	;
	.	D DBSAG22(dbtbl22,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl22)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(dbtbl22,-3),V2=vobj(dbtbl22,-4) I '(''($D(^DBTBL(V1,22,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl22)) S ^DBTBL(vobj(dbtbl22,-3),22,vobj(dbtbl22,-4))=vobj(dbtbl22)
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
	ZWI ^DBTBL(vobj(dbtbl22,-3),22,vobj(dbtbl22,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl22),$C(124),5)="") S $P(vobj(dbtbl22),$C(124),5)=0 ; dtl
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl22),$C(124),5)="") D vreqerr("DTL") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl22,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl22,-4)="") D vreqerr("AGID") Q 
	;
	I ($D(vx("DTL"))#2),($P(vobj(dbtbl22),$C(124),5)="") D vreqerr("DTL") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL22","MSG",1767,"DBTBL22."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl22,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl22,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("AGID",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I '("01"[$P(vobj(dbtbl22),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("DTL",vRM) Q 
	S X=$P(vobj(dbtbl22),$C(124),6) I '(X=""),'(",0,1,2,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("DTP",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),3))>40 S vRM=$$^MSG(1076,40) D vdderr("FRM",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),7))>40 S vRM=$$^MSG(1076,40) D vdderr("GRP",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),4))>8 S vRM=$$^MSG(1076,8) D vdderr("RTN",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),9))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR1",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),10))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR2",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),11))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR3",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),12))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR4",vRM) Q 
	I $L($P(vobj(dbtbl22),$C(124),13))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR5",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL22","MSG",979,"DBTBL22."_di_" "_vRM)
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
	I ($D(vx("%LIBS"))#2) S vux("%LIBS")=vx("%LIBS")
	I ($D(vx("AGID"))#2) S vux("AGID")=vx("AGID")
	D vkey(1) S voldkey=vobj(dbtbl22,-3)_","_vobj(dbtbl22,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl22,-3)_","_vobj(dbtbl22,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl22)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),22,vobj(vnewrec,-4))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL22",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl22,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("AGID"))#2) S vobj(dbtbl22,-4)=$piece(vux("AGID"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL22,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL22" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL22.copy: DBTBL22
	;
	Q $$copy^UCGMR(dbtbl22)
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
