TBLDOCFL(dbtbl1tbldoc,vpar,vparNorm)	; DBTBL1TBLDOC - Detailed Description of the Table Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL1TBLDOC ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (4)              08/25/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl1tbldoc,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl1tbldoc,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl1tbldoc,.vx,1,"|")
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
	.	I ($D(vx("%LIBS"))#2)!($D(vx("FID"))#2)!($D(vx("SEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL1TBLDOC",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl1tbldoc,-3),V2=vobj(dbtbl1tbldoc,-4),V3=vobj(dbtbl1tbldoc,-5) Q:'($D(^DBTBL(V1,1,V2,0,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl1tbldoc S dbtbl1tbldoc=$$vDb1(%LIBS,FID,SEQ)
	I (%O=2) D
	.	S vobj(dbtbl1tbldoc,-2)=2
	.	;
	.	D TBLDOCFL(dbtbl1tbldoc,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl1tbldoc)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl1tbldoc,-3),V2=vobj(dbtbl1tbldoc,-4),V3=vobj(dbtbl1tbldoc,-5) I '(''($D(^DBTBL(V1,1,V2,0,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1tbldoc,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1tbldoc,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl1tbldoc)) S ^DBTBL(vobj(dbtbl1tbldoc,-3),1,vobj(dbtbl1tbldoc,-4),0,vobj(dbtbl1tbldoc,-5))=vobj(dbtbl1tbldoc)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1tbldoc,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^DBTBL(vobj(dbtbl1tbldoc,-3),1,vobj(dbtbl1tbldoc,-4),0,vobj(dbtbl1tbldoc,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl1tbldoc,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl1tbldoc,-4)="") D vreqerr("FID") Q 
	I (vobj(dbtbl1tbldoc,-5)="") D vreqerr("SEQ") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1TBLDOC","MSG",1767,"DBTBL1TBLDOC."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl1tbldoc,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	S X=vobj(dbtbl1tbldoc,-4) I '(X="") S vRM=$$VAL^DBSVER("U",25,1,,"X?1A.AN!(X?1""%"".AN)",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1TBLDOC.FID"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=vobj(dbtbl1tbldoc,-5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("SEQ",vRM) Q 
	I $L($P(vobj(dbtbl1tbldoc),$C(124),1))>80 S vRM=$$^MSG(1076,80) D vdderr("DES",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1TBLDOC","MSG",979,"DBTBL1TBLDOC."_di_" "_vRM)
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
	I ($D(vx("FID"))#2) S vux("FID")=vx("FID")
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	D vkey(1) S voldkey=vobj(dbtbl1tbldoc,-3)_","_vobj(dbtbl1tbldoc,-4)_","_vobj(dbtbl1tbldoc,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl1tbldoc,-3)_","_vobj(dbtbl1tbldoc,-4)_","_vobj(dbtbl1tbldoc,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl1tbldoc)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL1TBLDOC",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl1tbldoc,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("FID"))#2) S vobj(dbtbl1tbldoc,-4)=$piece(vux("FID"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(dbtbl1tbldoc,-5)=$piece(vux("SEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1TBLDOC,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1TBLDOC"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2,0,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2,0,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1TBLDOC" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL1TBLDOC.copy: DBTBL1TBLDOC
	;
	Q $$copy^UCGMR(dbtbl1tbldoc)
	;
vReSav1(vnewrec)	;	RecordDBTBL1TBLDOC saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^DBTBL(vobj(vnewrec,-3),1,vobj(vnewrec,-4),0,vobj(vnewrec,-5))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
