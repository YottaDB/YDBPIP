DBS5PRFL(dbtbl5pr,vpar,vparNorm)	; DBTBL5PR - Report Definition (Processor sections) Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL5PR ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (4)              11/22/2003
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl5pr,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl5pr,.vxins,1,$char(12))
	I %O=1 D AUDIT^UCUTILN(dbtbl5pr,.vx,1,$char(12))
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("RID"))#2)!($D(vx("SEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL5PR",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl5pr,-3),V2=vobj(dbtbl5pr,-4),V3=vobj(dbtbl5pr,-5) Q:'$$vDbEx1()  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl5pr S dbtbl5pr=$$vDb1(LIBS,RID,SEQ)
	I (%O=2) D
	.	S vobj(dbtbl5pr,-2)=2
	.	;
	.	D DBS5PRFL(dbtbl5pr,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl5pr)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl5pr,-3),V2=vobj(dbtbl5pr,-4),V3=vobj(dbtbl5pr,-5) I '(''$$vDbEx2()=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl5pr)) S ^DBTBL(vobj(dbtbl5pr,-3),5,vobj(dbtbl5pr,-4),vobj(dbtbl5pr,-5))=vobj(dbtbl5pr)
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
	ZWI ^DBTBL(vobj(dbtbl5pr,-3),5,vobj(dbtbl5pr,-4),vobj(dbtbl5pr,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl5pr,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl5pr,-4)="") D vreqerr("RID") Q 
	I (vobj(dbtbl5pr,-5)="") D vreqerr("SEQ") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5PR","MSG",1767,"DBTBL5PR."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl5pr,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl5pr,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("RID",vRM) Q 
	I $L(vobj(dbtbl5pr,-5))>33 S vRM=$$^MSG(1076,33) D vdderr("SEQ",vRM) Q 
	I $L($P(vobj(dbtbl5pr),$C(12),1))>400 S vRM=$$^MSG(1076,400) D vdderr("DATA",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5PR","MSG",979,"DBTBL5PR."_di_" "_vRM)
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
	I ($D(vx("SEQ"))#2) S vux("SEQ")=vx("SEQ")
	D vkey(1) S voldkey=vobj(dbtbl5pr,-3)_","_vobj(dbtbl5pr,-4)_","_vobj(dbtbl5pr,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl5pr,-3)_","_vobj(dbtbl5pr,-4)_","_vobj(dbtbl5pr,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl5pr)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(vnewrec,-3),5,vobj(vnewrec,-4),vobj(vnewrec,-5))=vobj(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL5PR",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl5pr,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("RID"))#2) S vobj(dbtbl5pr,-4)=$piece(vux("RID"),"|",i)
	I ($D(vux("SEQ"))#2) S vobj(dbtbl5pr,-5)=$piece(vux("SEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL5PR,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5PR"
	S vobj(vOid)=$G(^DBTBL(v1,5,v2,v3))
	I '(v3]]30.999)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,5,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5PR" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbEx1()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS = :V1 and RID = :V2 and SEQ = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3]]30.999) Q 0
	I '($D(^DBTBL(V1,5,V2,V3))#2) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS = :V1 and RID = :V2 and SEQ = :V3
	;
	; No vsql* lvns needed
	;
	;
	;
	I '(V3]]30.999) Q 0
	I '($D(^DBTBL(V1,5,V2,V3))#2) Q 0
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL5PR.copy: DBTBL5PR
	;
	Q $$copy^UCGMR(dbtbl5pr)
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
