OBJMETFL(objectmet,vpar,vparNorm)	; OBJECTMET - Class Methods Filer
	;
	; **** Routine compiled from DATA-QWIK Filer OBJECTMET ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (9)              11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(objectmet,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(objectmet,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(objectmet,.vx,1,"|")
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
	.	I ($D(vx("CLASS"))#2)!($D(vx("METHOD"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("OBJECTMET",.vx)
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
	.	  N V1,V2 S V1=vobj(objectmet,-3),V2=vobj(objectmet,-4) Q:'($D(^OBJECT(V1,1,V2))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N objectmet S objectmet=$$vDb1(CLASS,METHOD)
	I (%O=2) D
	.	S vobj(objectmet,-2)=2
	.	;
	.	D OBJMETFL(objectmet,vpar)
	.	Q 
	;
	K vobj(+$G(objectmet)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(objectmet,-3),V2=vobj(objectmet,-4) I '(''($D(^OBJECT(V1,1,V2))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(objectmet)) S ^OBJECT(vobj(objectmet,-3),1,vobj(objectmet,-4))=vobj(objectmet)
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
	ZWI ^OBJECT(vobj(objectmet,-3),1,vobj(objectmet,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(objectmet),$C(124),9)="") S $P(vobj(objectmet),$C(124),9)=0 ; vallit
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(objectmet),$C(124),9)="") D vreqerr("VALLIT") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(objectmet,-3)="") D vreqerr("CLASS") Q 
	I (vobj(objectmet,-4)="") D vreqerr("METHOD") Q 
	;
	I ($D(vx("VALLIT"))#2),($P(vobj(objectmet),$C(124),9)="") D vreqerr("VALLIT") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("OBJECTMET","MSG",1767,"OBJECTMET."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(objectmet,-3))>20 S vRM=$$^MSG(1076,20) D vdderr("CLASS",vRM) Q 
	I $L(vobj(objectmet,-4))>14 S vRM=$$^MSG(1076,14) D vdderr("METHOD",vRM) Q 
	I $L($P(vobj(objectmet),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(objectmet),$C(124),6))>12 S vRM=$$^MSG(1076,12) D vdderr("ERRCODE",vRM) Q 
	I $L($P(vobj(objectmet),$C(124),2))>250 S vRM=$$^MSG(1076,250) D vdderr("PARAMETERS",vRM) Q 
	I $L($P(vobj(objectmet),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("RETURN",vRM) Q 
	I $L($P(vobj(objectmet),$C(124),3))>40 S vRM=$$^MSG(1076,40) D vdderr("ROU",vRM) Q 
	I $L($P(vobj(objectmet),$C(124),7))>14 S vRM=$$^MSG(1076,14) D vdderr("SCRIPT",vRM) Q 
	I '("01"[$P(vobj(objectmet),$C(124),9)) S vRM=$$^MSG(742,"L") D vdderr("VALLIT",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("OBJECTMET","MSG",979,"OBJECTMET."_di_" "_vRM)
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
	I ($D(vx("CLASS"))#2) S vux("CLASS")=vx("CLASS")
	I ($D(vx("METHOD"))#2) S vux("METHOD")=vx("METHOD")
	D vkey(1) S voldkey=vobj(objectmet,-3)_","_vobj(objectmet,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(objectmet,-3)_","_vobj(objectmet,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(objectmet)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^OBJECT(vobj(vnewrec,-3),1,vobj(vnewrec,-4))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("OBJECTMET",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("CLASS"))#2) S vobj(objectmet,-3)=$piece(vux("CLASS"),"|",i)
	I ($D(vux("METHOD"))#2) S vobj(objectmet,-4)=$piece(vux("METHOD"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(OBJECTMET,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordOBJECTMET"
	S vobj(vOid)=$G(^OBJECT(v1,1,v2))
	I vobj(vOid)="",'$D(^OBJECT(v1,1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,OBJECTMET" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordOBJECTMET.copy: OBJECTMET
	;
	Q $$copy^UCGMR(objectmet)
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
