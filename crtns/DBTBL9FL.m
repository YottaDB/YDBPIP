DBTBL9FL(dbtbl9,vpar,vparNorm)	; DBTBL9 - Journal File Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL9 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (18)             03/19/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl9,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl9,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl9,.vx,1,"|")
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
	.	I ($D(vx("%LIBS"))#2)!($D(vx("PRITABLE"))#2)!($D(vx("JRNID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL9",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl9,-3),V2=vobj(dbtbl9,-4),V3=vobj(dbtbl9,-5) Q:'($D(^DBTBL(V1,9,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl9 S dbtbl9=$$vDb1(%LIBS,PRITABLE,JRNID)
	I (%O=2) D
	.	S vobj(dbtbl9,-2)=2
	.	;
	.	D DBTBL9FL(dbtbl9,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl9)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl9,-3),V2=vobj(dbtbl9,-4),V3=vobj(dbtbl9,-5) I '(''($D(^DBTBL(V1,9,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	I vpar["/VALFK/" D CHKFKS ; Check foreign keys
	I vpar["/VALRI/" D VFKEYS ; Foreign key definition
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(dbtbl9),$C(124),9)=$P($H,",",1)
	. S $P(vobj(dbtbl9),$C(124),14)=$P($H,",",2)
	.	I '+$P($G(vobj(dbtbl9,-100,"0*","USER")),"|",2) S $P(vobj(dbtbl9),$C(124),10)=$$USERNAM^%ZFUNC
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl9)) S ^DBTBL(vobj(dbtbl9,-3),9,vobj(dbtbl9,-4),vobj(dbtbl9,-5))=vobj(dbtbl9)
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
	ZWI ^DBTBL(vobj(dbtbl9,-3),9,vobj(dbtbl9,-4),vobj(dbtbl9,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl9),$C(124),8)="") S $P(vobj(dbtbl9),$C(124),8)=1 ; seq
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl9),$C(124),1)="") D vreqerr("DES") Q 
	I ($P(vobj(dbtbl9),$C(124),2)="") D vreqerr("SUBTABLE") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl9,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl9,-4)="") D vreqerr("PRITABLE") Q 
	I (vobj(dbtbl9,-5)="") D vreqerr("JRNID") Q 
	;
	I ($D(vx("DES"))#2),($P(vobj(dbtbl9),$C(124),1)="") D vreqerr("DES") Q 
	I ($D(vx("SUBTABLE"))#2),($P(vobj(dbtbl9),$C(124),2)="") D vreqerr("SUBTABLE") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL9","MSG",1767,"DBTBL9."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VFKEYS	; Foreign keys
	;
	I '(vobj(dbtbl9,-4)="") S vfkey("^DBTBL("_""""_vobj(dbtbl9,-3)_""""_","_1_","_""""_vobj(dbtbl9,-4)_""""_")")="DBTBL9(%LIBS,PRITABLE) -> DBTBL1"
	Q 
	;
CHKFKS	; Check foreign keys when not under buffer
	;
	N vERRMSG
	;
	 N V1,V2 S V1=vobj(dbtbl9,-3),V2=vobj(dbtbl9,-4) I '($D(^DBTBL(V1,1,V2))) S vERRMSG=$$^MSG(8563,"DBTBL9(%LIBS,PRITABLE) -> DBTBL1") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl9,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl9,-4))>25 S vRM=$$^MSG(1076,25) D vdderr("PRITABLE",vRM) Q 
	I $L(vobj(dbtbl9,-5))>14 S vRM=$$^MSG(1076,14) D vdderr("JRNID",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),3))>5 S vRM=$$^MSG(1076,5) D vdderr("EFD",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),6))>250 S vRM=$$^MSG(1076,250) D vdderr("EXCOLUMN",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),15))>255 S vRM=$$^MSG(1076,255) D vdderr("IFCOND",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),7))>250 S vRM=$$^MSG(1076,250) D vdderr("INCOLUMN",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),5))>10 S vRM=$$^MSG(1076,10) D vdderr("MODE",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),13))>12 S vRM=$$^MSG(1076,12) D vdderr("PARFID",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),11))>100 S vRM=$$^MSG(1076,100) D vdderr("QUERY1",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),12))>100 S vRM=$$^MSG(1076,100) D vdderr("QUERY2",vRM) Q 
	S X=$P(vobj(dbtbl9),$C(124),8) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("SEQ",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("SUBTABLE",vRM) Q 
	S X=$P(vobj(dbtbl9),$C(124),14) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIME",vRM) Q 
	S X=$P(vobj(dbtbl9),$C(124),9) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("TLD",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),4))>10 S vRM=$$^MSG(1076,10) D vdderr("TRANTYPE",vRM) Q 
	I $L($P(vobj(dbtbl9),$C(124),10))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL9","MSG",979,"DBTBL9."_di_" "_vRM)
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
	I ($D(vx("PRITABLE"))#2) S vux("PRITABLE")=vx("PRITABLE")
	I ($D(vx("JRNID"))#2) S vux("JRNID")=vx("JRNID")
	D vkey(1) S voldkey=vobj(dbtbl9,-3)_","_vobj(dbtbl9,-4)_","_vobj(dbtbl9,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl9,-3)_","_vobj(dbtbl9,-4)_","_vobj(dbtbl9,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl9)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),9,vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL9",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl9,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("PRITABLE"))#2) S vobj(dbtbl9,-4)=$piece(vux("PRITABLE"),"|",i)
	I ($D(vux("JRNID"))#2) S vobj(dbtbl9,-5)=$piece(vux("JRNID"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL9,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL9"
	S vobj(vOid)=$G(^DBTBL(v1,9,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,9,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL9" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL9.copy: DBTBL9
	;
	Q $$copy^UCGMR(dbtbl9)
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
