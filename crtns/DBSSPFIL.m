DBSSPFIL(dbtblsp,vpar,vparNorm)	; DBTBLSP - SQL Stored Procedure Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBLSP ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (9)              12/12/2005
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtblsp,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtblsp,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtblsp,.vx,1,"|")
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
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBLSP",.vx)
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
	.	  N V1 S V1=vobj(dbtblsp,-3) Q:'($D(^DBTBLSP(V1))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtblsp S dbtblsp=$$vDb1(PID)
	I (%O=2) D
	.	S vobj(dbtblsp,-2)=2
	.	;
	.	D DBSSPFIL(dbtblsp,vpar)
	.	Q 
	;
	K vobj(+$G(dbtblsp)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(dbtblsp,-3) I '(''($D(^DBTBLSP(V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0 S $P(vobj(dbtblsp),$C(124),6)=$P($H,",",1)
	.	I %O=0 S $P(vobj(dbtblsp),$C(124),7)=$P($H,",",2)
	.	I %O=0 I '+$P($G(vobj(dbtblsp,-100,"0*","USER")),"|",2) S $P(vobj(dbtblsp),$C(124),5)=$$USERNAM^%ZFUNC
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtblsp)) K:$D(vobj(dbtblsp,1,1)) ^DBTBLSP(vobj(dbtblsp,-3)) S ^DBTBLSP(vobj(dbtblsp,-3))=vobj(dbtblsp)
	.	;*** End of code by-passed by compiler ***
	.	; Allow global reference and M source code
	.	;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtblsp,1,1)) N vS1,vS2 S vS1=0 F vS2=1:450:$L(vobj(dbtblsp,1,1)) S vS1=vS1+1,^DBTBLSP(vobj(dbtblsp,-3),vS1)=$E(vobj(dbtblsp,1,1),vS2,vS2+449)
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
	kill ^DBTBLSP(vobj(dbtblsp,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtblsp,-3)="") D vreqerr("PID") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBLSP","MSG",1767,"DBTBLSP."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtblsp,-3))>40 S vRM=$$^MSG(1076,40) D vdderr("PID",vRM) Q 
	I $L($P(vobj(dbtblsp),$C(124),3))>25 S vRM=$$^MSG(1076,25) D vdderr("HASHKEY",vRM) Q 
	I $L($P(vobj(dbtblsp),$C(124),2))>255 S vRM=$$^MSG(1076,255) D vdderr("HVARS",vRM) Q 
	S X=$P(vobj(dbtblsp),$C(124),6) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	I $L($P(vobj(dbtblsp),$C(124),4))>80 S vRM=$$^MSG(1076,80) D vdderr("PARS",vRM) Q 
	I $L($P(vobj(dbtblsp),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("PGM",vRM) Q 
	I $L($P(vobj(dbtblsp),$C(124),8))>6 S vRM=$$^MSG(1076,6) D vdderr("SPTYPE",vRM) Q 
	S X=$P(vobj(dbtblsp),$C(124),7) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIME",vRM) Q 
	I $L($P(vobj(dbtblsp),$C(124),5))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBLSP","MSG",979,"DBTBLSP."_di_" "_vRM)
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
	S voldkey=$piece(vux,"|",1) S vobj(dbtblsp,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(dbtblsp,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtblsp)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBLSP",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(dbtblsp,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(DBTBLSP,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBLSP"
	S vobj(vOid)=$G(^DBTBLSP(v1))
	I vobj(vOid)="",'$D(^DBTBLSP(v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBLSP" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBLSP.copy: DBTBLSP
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	. S:'$D(vobj(v1,1,1)) vobj(v1,1,1)="" N von S von="" F  S von=$O(^DBTBLSP(vobj(v1,-3),von)) quit:von=""  S vobj(v1,1,1)=vobj(v1,1,1)_^DBTBLSP(vobj(v1,-3),von)
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordDBTBLSP saveNoFiler()
	;
	S ^DBTBLSP(vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
	N vC,vS s vS=0
	F vC=1:450:$L($G(vobj(vnewrec,1,1))) S vS=vS+1,^DBTBLSP(vobj(vnewrec,-3),vS)=$E(vobj(vnewrec,1,1),vC,vC+449)
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
