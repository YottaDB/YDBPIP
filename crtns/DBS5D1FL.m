DBS5D1FL(dbtbl5d1,vpar,vparNorm)	; DBTBL5D1 - Report Definition (Pre/Post-Proc) Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL5D1 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (6)              11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl5d1,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl5d1,.vxins,1,$char(12))
	I %O=1 D AUDIT^UCUTILN(dbtbl5d1,.vx,1,$char(12))
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("RID"))#2)!($D(vx("GRP"))#2)!($D(vx("ITMSEQ"))#2)!($D(vx("SEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL5D1",.vx)
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
	.	  N V1,V2,V3,V4,V5 S V1=vobj(dbtbl5d1,-3),V2=vobj(dbtbl5d1,-4),V3=vobj(dbtbl5d1,-5),V4=vobj(dbtbl5d1,-6),V5=vobj(dbtbl5d1,-7) Q:'$$vDbEx1()  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl5d1 S dbtbl5d1=$$vDb1(LIBS,RID,GRP,ITMSEQ,SEQ)
	I (%O=2) D
	.	S vobj(dbtbl5d1,-2)=2
	.	;
	.	D DBS5D1FL(dbtbl5d1,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl5d1)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3,V4,V5 S V1=vobj(dbtbl5d1,-3),V2=vobj(dbtbl5d1,-4),V3=vobj(dbtbl5d1,-5),V4=vobj(dbtbl5d1,-6),V5=vobj(dbtbl5d1,-7) I '(''$$vDbEx2()=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl5d1)) S ^DBTBL(vobj(dbtbl5d1,-3),5,vobj(dbtbl5d1,-4),vobj(dbtbl5d1,-5),vobj(dbtbl5d1,-6),vobj(dbtbl5d1,-7))=vobj(dbtbl5d1)
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
	ZWI ^DBTBL(vobj(dbtbl5d1,-3),5,vobj(dbtbl5d1,-4),vobj(dbtbl5d1,-5),vobj(dbtbl5d1,-6),vobj(dbtbl5d1,-7))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl5d1,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl5d1,-4)="") D vreqerr("RID") Q 
	I (vobj(dbtbl5d1,-5)="") D vreqerr("GRP") Q 
	I (vobj(dbtbl5d1,-6)="") D vreqerr("ITMSEQ") Q 
	I (vobj(dbtbl5d1,-7)="") D vreqerr("SEQ") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5D1","MSG",1767,"DBTBL5D1."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl5d1,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl5d1,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("RID",vRM) Q 
	I $L(vobj(dbtbl5d1,-5))>33 S vRM=$$^MSG(1076,33) D vdderr("GRP",vRM) Q 
	S X=vobj(dbtbl5d1,-6) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("ITMSEQ",vRM) Q 
	S X=vobj(dbtbl5d1,-7) I '(X="") S vRM=$$VAL^DBSVER("N",12,1,,,,,3) I '(vRM="") S vRM=$$^MSG(979,"DBTBL5D1.SEQ"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	I $L($P(vobj(dbtbl5d1),$C(12),1))>400 S vRM=$$^MSG(1076,400) D vdderr("DATA",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5D1","MSG",979,"DBTBL5D1."_di_" "_vRM)
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
	I ($D(vx("LIBS"))#2) S vux("LIBS")=vx("LIBS")
	I ($D(vx("RID"))#2) S vux("RID")=vx("RID")
	I ($D(vx("GRP"))#2) S vux("GRP")=vx("GRP")
	I ($D(vx("ITMSEQ"))#2) S vux("ITMSEQ")=vx("ITMSEQ")
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	D vkey(1) S voldkey=vobj(dbtbl5d1,-3)_","_vobj(dbtbl5d1,-4)_","_vobj(dbtbl5d1,-5)_","_vobj(dbtbl5d1,-6)_","_vobj(dbtbl5d1,-7) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl5d1,-3)_","_vobj(dbtbl5d1,-4)_","_vobj(dbtbl5d1,-5)_","_vobj(dbtbl5d1,-6)_","_vobj(dbtbl5d1,-7) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl5d1)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),5,vobj(vnewrec,-4),vobj(vnewrec,-5),vobj(vnewrec,-6),vobj(vnewrec,-7))=vobj(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL5D1",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl5d1,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("RID"))#2) S vobj(dbtbl5d1,-4)=$piece(vux("RID"),"|",i)
	I ($D(vux("GRP"))#2) S vobj(dbtbl5d1,-5)=$piece(vux("GRP"),"|",i)
	I ($D(vux("ITMSEQ"))#2) S vobj(dbtbl5d1,-6)=$piece(vux("ITMSEQ"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(dbtbl5d1,-7)=$piece(vux("SEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3,v4,v5)	;	vobj()=Db.getRecord(DBTBL5D1,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5D1"
	S vobj(vOid)=$G(^DBTBL(v1,5,v2,v3,v4,v5))
	I '(v4>100)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,5,v2,v3,v4,v5))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5D1" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	S vobj(vOid,-7)=v5
	Q vOid
	;
vDbEx1()	;	min(1): DISTINCT LIBS,RID,GRP,ITMSEQ,SEQ FROM DBTBL5D1 WHERE LIBS = :V1 and RID = :V2 and GRP = :V3 and ITMSEQ = :V4 and SEQ = :V5
	;
	; No vsql* lvns needed
	;
	;
	;
	;
	;
	S V5=+V5
	I '(V4>100) Q 0
	I '($D(^DBTBL(V1,5,V2,V3,V4,V5))#2) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,RID,GRP,ITMSEQ,SEQ FROM DBTBL5D1 WHERE LIBS = :V1 and RID = :V2 and GRP = :V3 and ITMSEQ = :V4 and SEQ = :V5
	;
	; No vsql* lvns needed
	;
	;
	;
	;
	;
	S V5=+V5
	I '(V4>100) Q 0
	I '($D(^DBTBL(V1,5,V2,V3,V4,V5))#2) Q 0
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL5D1.copy: DBTBL5D1
	;
	Q $$copy^UCGMR(dbtbl5d1)
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
