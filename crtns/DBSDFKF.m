DBSDFKF(dbtbl1f,vpar,vparNorm)	; DBTBL1F - Data Dictionary Foreign Keys Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL1F ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (11)             11/22/2003
	; Trigger Definition (2)                      05/17/2004
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl1f,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl1f,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl1f,.vx,1,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	; Define local variables for access keys for legacy triggers
	N %LIBS S %LIBS=vobj(dbtbl1f,-3)
	N FID S FID=vobj(dbtbl1f,-4)
	N FKEYS S FKEYS=vobj(dbtbl1f,-5)
	;
	I %O=0 D  Q  ; Create record control block
	.	D vinit ; Initialize column values
	.	I vpar["/TRIGBEF/" D VBI ; Before insert triggers
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I ($D(vx("%LIBS"))#2)!($D(vx("FID"))#2)!($D(vx("FKEYS"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/TRIGBEF/" D VBU ; Before update triggers
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL1F",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl1f,-3),V2=vobj(dbtbl1f,-4),V3=vobj(dbtbl1f,-5) Q:'($D(^DBTBL(V1,19,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl1f S dbtbl1f=$$vDb1(%LIBS,FID,FKEYS)
	I (%O=2) D
	.	S vobj(dbtbl1f,-2)=2
	.	;
	.	D DBSDFKF(dbtbl1f,vpar)
	.	Q 
	E  D VINDEX(dbtbl1f)
	;
	K vobj(+$G(dbtbl1f)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl1f,-3),V2=vobj(dbtbl1f,-4),V3=vobj(dbtbl1f,-5) I '(''($D(^DBTBL(V1,19,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	I vpar["/VALFK/" D CHKFKS ; Check foreign keys
	I vpar["/VALRI/" D VFKEYS ; Foreign key definition
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl1f)) S ^DBTBL(vobj(dbtbl1f,-3),19,vobj(dbtbl1f,-4),vobj(dbtbl1f,-5))=vobj(dbtbl1f)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	I vpar["/INDEX/",'(%O=1)!'($order(vx(""))="") D VINDEX(.dbtbl1f) ; Update Index files
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar["/INDEX/" D VINDEX(.dbtbl1f) ; Delete index entries
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^DBTBL(vobj(dbtbl1f,-3),19,vobj(dbtbl1f,-4),vobj(dbtbl1f,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl1f),$C(124),3)="") S $P(vobj(dbtbl1f),$C(124),3)=0 ; del
	I ($P(vobj(dbtbl1f),$C(124),6)="") S $P(vobj(dbtbl1f),$C(124),6)=0 ; rcfrmin
	I ($P(vobj(dbtbl1f),$C(124),2)="") S $P(vobj(dbtbl1f),$C(124),2)=1 ; rctomax
	I ($P(vobj(dbtbl1f),$C(124),1)="") S $P(vobj(dbtbl1f),$C(124),1)=1 ; rctomin
	I ($P(vobj(dbtbl1f),$C(124),4)="") S $P(vobj(dbtbl1f),$C(124),4)=0 ; upd
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl1f),$C(124),3)="") D vreqerr("DEL") Q 
	I ($P(vobj(dbtbl1f),$C(124),5)="") D vreqerr("TBLREF") Q 
	I ($P(vobj(dbtbl1f),$C(124),4)="") D vreqerr("UPD") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl1f,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl1f,-4)="") D vreqerr("FID") Q 
	I (vobj(dbtbl1f,-5)="") D vreqerr("FKEYS") Q 
	;
	I ($D(vx("DEL"))#2),($P(vobj(dbtbl1f),$C(124),3)="") D vreqerr("DEL") Q 
	I ($D(vx("TBLREF"))#2),($P(vobj(dbtbl1f),$C(124),5)="") D vreqerr("TBLREF") Q 
	I ($D(vx("UPD"))#2),($P(vobj(dbtbl1f),$C(124),4)="") D vreqerr("UPD") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1F","MSG",1767,"DBTBL1F."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VFKEYS	; Foreign keys
	;
	I '(vobj(dbtbl1f,-4)="") S vfkey("^DBTBL("_""""_vobj(dbtbl1f,-3)_""""_","_1_","_""""_vobj(dbtbl1f,-4)_""""_")")="DBTBL1F(%LIBS,FID) -> DBTBL1"
	I '($P(vobj(dbtbl1f),$C(124),5)="") S vfkey("^DBTBL("_""""_vobj(dbtbl1f,-3)_""""_","_1_","_""""_$P(vobj(dbtbl1f),$C(124),5)_""""_")")="DBTBL1F(%LIBS,TBLREF) -> DBTBL1"
	Q 
	;
CHKFKS	; Check foreign keys when not under buffer
	;
	N vERRMSG
	;
	 N V1,V2 S V1=vobj(dbtbl1f,-3),V2=vobj(dbtbl1f,-4) I '($D(^DBTBL(V1,1,V2))) S vERRMSG=$$^MSG(8563,"DBTBL1F(%LIBS,FID) -> DBTBL1") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	 N V3,V4 S V3=vobj(dbtbl1f,-3),V4=$P(vobj(dbtbl1f),$C(124),5) I '($D(^DBTBL(V3,1,V4))) S vERRMSG=$$^MSG(8563,"DBTBL1F(%LIBS,TBLREF) -> DBTBL1") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	Q 
	;
VBI	;
	 S ER=0
	D vbi1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VBU	;
	 S ER=0
	I ($order(vx(""))="") D AUDIT^UCUTILN(dbtbl1f,.vx,1,"|") Q 
	I ($D(vx("TBLREF"))#2) D vbu1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	D AUDIT^UCUTILN(dbtbl1f,.vx,1,"|")
	Q 
	;
vbi1	; Trigger BEFORE_INSERT - Calculate PKEYS
	;
	; Insert referenced table access keys
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=$P(vobj(dbtbl1f),$C(124),5),dbtbl1=$$vDb4("SYSDEV",vop2)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	;
	S $P(vobj(dbtbl1f),$C(124),8)=$P(vop3,$C(124),1)
	;
	Q 
	;
vbu1	; Trigger BEFORE_UPDATE - Calculate PKEYS field value
	;
	; Insert referenced table access keys
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=$P(vobj(dbtbl1f),$C(124),5),dbtbl1=$$vDb4("SYSDEV",vop2)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	;
	S:'$D(vobj(dbtbl1f,-100,"0*","PKEYS")) vobj(dbtbl1f,-100,"0*","PKEYS")="T008"_$P(vobj(dbtbl1f),$C(124),8) S vobj(dbtbl1f,-100,"0*")="",$P(vobj(dbtbl1f),$C(124),8)=$P(vop3,$C(124),1)
	;
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl1f,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl1f,-4))>256 S vRM=$$^MSG(1076,256) D vdderr("FID",vRM) Q 
	I $L(vobj(dbtbl1f,-5))>60 S vRM=$$^MSG(1076,60) D vdderr("FKEYS",vRM) Q 
	S X=$P(vobj(dbtbl1f),$C(124),3) I '(X=""),'($D(^STBL("FKOPT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("DEL",vRM) Q 
	I $L($P(vobj(dbtbl1f),$C(124),8))>40 S vRM=$$^MSG(1076,40) D vdderr("PKEYS",vRM) Q 
	S X=$P(vobj(dbtbl1f),$C(124),7) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("RCFRMAX",vRM) Q 
	S X=$P(vobj(dbtbl1f),$C(124),6) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("RCFRMIN",vRM) Q 
	S X=$P(vobj(dbtbl1f),$C(124),2) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("RCTOMAX",vRM) Q 
	S X=$P(vobj(dbtbl1f),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("RCTOMIN",vRM) Q 
	S X=$P(vobj(dbtbl1f),$C(124),5) I '(X="") S vRM=$$VAL^DBSVER("U",256,1,,"X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1F.TBLREF"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=$P(vobj(dbtbl1f),$C(124),4) I '(X=""),'($D(^STBL("FKOPT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("UPD",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1F","MSG",979,"DBTBL1F."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VINDEX(dbtbl1f)	; Update index entries
	;
	I %O=1 D  Q 
	.	I ($D(vx("TBLREF"))#2) D vi1(.dbtbl1f)
	.	Q 
	D vi1(.dbtbl1f)
	;
	Q 
	;
vi1(dbtbl1f)	; Maintain FKPTR index entries (Foreign Key Pointer)
	;
	N vdelete S vdelete=0
	N v1 S v1=vobj(dbtbl1f,-3)
	N v3 S v3=$P(vobj(dbtbl1f),$C(124),5)
	I (v3="") S v3=$char(254)
	N v4 S v4=vobj(dbtbl1f,-4)
	N v5 S v5=vobj(dbtbl1f,-5)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(^DBTBL(vobj(dbtbl1f,-3),19,vobj(dbtbl1f,-4),vobj(dbtbl1f,-5)))#2,'$D(^DBINDX(v1,"FKPTR",v3,v4,v5)) do vidxerr("FKPTR")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^DBINDX(v1,"FKPTR",v3,v4,v5)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("TBLREF"))#2) S v3=$piece(vx("TBLREF"),"|",1) S:(v3="") v3=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBINDX(v1,"FKPTR",v3,v4,v5)
	;*** End of code by-passed by compiler ***
	Q 
	;
VIDXBLD(vlist)	; Rebuild index files (External call)
	;
	N %O S %O=0 ; Create mode
	N i
	;
	I ($get(vlist)="") S vlist="VINDEX" ; Build all
	;
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	N dbtbl1f S dbtbl1f=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	I ((","_vlist_",")[",VINDEX,") D VINDEX(.dbtbl1f) K vobj(+$G(dbtbl1f)) Q 
	.	I ((","_vlist_",")[",FKPTR,") D vi1(.dbtbl1f)
	.	K vobj(+$G(dbtbl1f)) Q 
	;
	Q 
	;
VIDXBLD1(dbtbl1f,vlist)	; Rebuild index files for one record (External call)
	;
	N i
	;
	I ((","_vlist_",")[",VINDEX,") D VINDEX(.dbtbl1f) Q 
	I ((","_vlist_",")[",FKPTR,") D vi1(.dbtbl1f)
	;
	Q 
	;
vidxerr(di)	; Error message
	;
	D SETERR^DBSEXECU("DBTBL1F","MSG",1225,"DBTBL1F."_di)
	;
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
	I ($D(vx("FKEYS"))#2) S vux("FKEYS")=vx("FKEYS")
	D vkey(1) S voldkey=vobj(dbtbl1f,-3)_","_vobj(dbtbl1f,-4)_","_vobj(dbtbl1f,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/TRIGBEF/" D VBU
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl1f,-3)_","_vobj(dbtbl1f,-4)_","_vobj(dbtbl1f,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl1f)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFKF(vnewrec,"/NOCASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/",1) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL1F",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl1f,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("FID"))#2) S vobj(dbtbl1f,-4)=$piece(vux("FID"),"|",i)
	I ($D(vux("FKEYS"))#2) S vobj(dbtbl1f,-5)=$piece(vux("FKEYS"),"|",i)
	Q 
	;
VIDXPGM()	;
	Q "DBSDFKF" ; Location of index program
	;
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1F,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1F"
	S vobj(vOid)=$G(^DBTBL(v1,19,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,19,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1F" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1F,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1F"
	S vobj(vOid)=$G(^DBTBL(v1,19,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,19,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb4(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,1)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	;
	Q dbtbl1
	;
vOpen1()	;	%LIBS,FID,FKEYS FROM DBTBL1F
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^DBTBL(vos2),1) I vos2="" G vL1a0
	S vos3=""
vL1a4	S vos3=$O(^DBTBL(vos2,19,vos3),1) I vos3="" G vL1a2
	S vos4=""
vL1a6	S vos4=$O(^DBTBL(vos2,19,vos3,vos4),1) I vos4="" G vL1a4
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL1F.copy: DBTBL1F
	;
	Q $$copy^UCGMR(dbtbl1f)
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
