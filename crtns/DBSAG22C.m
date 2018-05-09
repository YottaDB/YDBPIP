DBSAG22C(dbtbl22c,vpar,vparNorm)	; DBTBL22C - DATA-QWIK Aggregate Column Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL22C ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (12)             12/08/2005
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl22c,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl22c,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl22c,.vx,1,"|")
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
	.	I ($D(vx("%LIBS"))#2)!($D(vx("AGID"))#2)!($D(vx("COL"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL22C",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl22c,-3),V2=vobj(dbtbl22c,-4),V3=vobj(dbtbl22c,-5) Q:'($D(^DBTBL(V1,22,V2,"C",V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl22c S dbtbl22c=$$vDb1(%LIBS,AGID,COL)
	I (%O=2) D
	.	S vobj(dbtbl22c,-2)=2
	.	;
	.	D DBSAG22C(dbtbl22c,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl22c)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl22c,-3),V2=vobj(dbtbl22c,-4),V3=vobj(dbtbl22c,-5) I '(''($D(^DBTBL(V1,22,V2,"C",V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl22c)) S ^DBTBL(vobj(dbtbl22c,-3),22,vobj(dbtbl22c,-4),"C",vobj(dbtbl22c,-5))=vobj(dbtbl22c)
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
	ZWI ^DBTBL(vobj(dbtbl22c,-3),22,vobj(dbtbl22c,-4),"C",vobj(dbtbl22c,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl22c),$C(124),3)="") S $P(vobj(dbtbl22c),$C(124),3)="SUM" ; fun
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl22c,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl22c,-4)="") D vreqerr("AGID") Q 
	I (vobj(dbtbl22c,-5)="") D vreqerr("COL") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL22C","MSG",1767,"DBTBL22C."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl22c,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl22c,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("AGID",vRM) Q 
	S X=vobj(dbtbl22c,-5) I '(X="") S vRM=$$VAL^DBSVER("U",4,1,,"X?1A.A",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL22C.COL"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	I $L($P(vobj(dbtbl22c),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),4))>255 S vRM=$$^MSG(1076,255) D vdderr("EXP",vRM) Q 
	S X=$P(vobj(dbtbl22c),$C(124),3) I '(X=""),'(",SUM,MIN,MAX,AVG,CNT,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("FUN",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),6))>4 S vRM=$$^MSG(1076,4) D vdderr("LNK",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),9))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR1",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),10))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR2",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),11))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR3",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),12))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR4",vRM) Q 
	I $L($P(vobj(dbtbl22c),$C(124),13))>80 S vRM=$$^MSG(1076,80) D vdderr("WHR5",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL22C","MSG",979,"DBTBL22C."_di_" "_vRM)
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
	I ($D(vx("COL"))#2) S vux("COL")=vx("COL")
	D vkey(1) S voldkey=vobj(dbtbl22c,-3)_","_vobj(dbtbl22c,-4)_","_vobj(dbtbl22c,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl22c,-3)_","_vobj(dbtbl22c,-4)_","_vobj(dbtbl22c,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl22c)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),22,vobj(vnewrec,-4),"C",vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL22C",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl22c,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("AGID"))#2) S vobj(dbtbl22c,-4)=$piece(vux("AGID"),"|",i)
	I ($D(vux("COL"))#2) S vobj(dbtbl22c,-5)=$piece(vux("COL"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL22C,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22C"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2,"C",v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2,"C",v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL22C" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL22C.copy: DBTBL22C
	;
	Q $$copy^UCGMR(dbtbl22c)
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
