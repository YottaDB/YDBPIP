MAPPPROP(sysmappropdata,vpar,vparNorm)	; SYSMAPPROPDATA - System Map of PSL property read/sets  Filer
	;
	; **** Routine compiled from DATA-QWIK Filer SYSMAPPROPDATA ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (6)              01/21/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(sysmappropdata,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(sysmappropdata,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(sysmappropdata,.vx,1,"|")
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
	.	I ($D(vx("TARGET"))#2)!($D(vx("LABEL"))#2)!($D(vx("TABLE"))#2)!($D(vx("COLUMN"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("SYSMAPPROPDATA",.vx)
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
	.	  N V1,V2,V3,V4 S V1=vobj(sysmappropdata,-3),V2=vobj(sysmappropdata,-4),V3=vobj(sysmappropdata,-5),V4=vobj(sysmappropdata,-6) Q:'($D(^SYSMAP("DATA",V1,V2,"P",V3,V4))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N sysmappropdata S sysmappropdata=$$vDb1(TARGET,LABEL,TABLE,COLUMN)
	I (%O=2) D
	.	S vobj(sysmappropdata,-2)=2
	.	;
	.	D MAPPPROP(sysmappropdata,vpar)
	.	Q 
	E  D VINDEX(sysmappropdata)
	;
	K vobj(+$G(sysmappropdata)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3,V4 S V1=vobj(sysmappropdata,-3),V2=vobj(sysmappropdata,-4),V3=vobj(sysmappropdata,-5),V4=vobj(sysmappropdata,-6) I '(''($D(^SYSMAP("DATA",V1,V2,"P",V3,V4))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(sysmappropdata)) S ^SYSMAP("DATA",vobj(sysmappropdata,-3),vobj(sysmappropdata,-4),"P",vobj(sysmappropdata,-5),vobj(sysmappropdata,-6))=vobj(sysmappropdata)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	I vpar["/INDEX/",'(%O=1)!'($order(vx(""))="") D VINDEX(.sysmappropdata) ; Update Index files
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar["/INDEX/" D VINDEX(.sysmappropdata) ; Delete index entries
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^SYSMAP("DATA",vobj(sysmappropdata,-3),vobj(sysmappropdata,-4),"P",vobj(sysmappropdata,-5),vobj(sysmappropdata,-6))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(sysmappropdata,-3)="") D vreqerr("TARGET") Q 
	I (vobj(sysmappropdata,-4)="") D vreqerr("LABEL") Q 
	I (vobj(sysmappropdata,-5)="") D vreqerr("TABLE") Q 
	I (vobj(sysmappropdata,-6)="") D vreqerr("COLUMN") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("SYSMAPPROPDATA","MSG",1767,"SYSMAPPROPDATA."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(sysmappropdata,-3))>31 S vRM=$$^MSG(1076,31) D vdderr("TARGET",vRM) Q 
	I $L(vobj(sysmappropdata,-4))>40 S vRM=$$^MSG(1076,40) D vdderr("LABEL",vRM) Q 
	I $L(vobj(sysmappropdata,-5))>20 S vRM=$$^MSG(1076,20) D vdderr("TABLE",vRM) Q 
	I $L(vobj(sysmappropdata,-6))>20 S vRM=$$^MSG(1076,20) D vdderr("COLUMN",vRM) Q 
	S X=$P(vobj(sysmappropdata),$C(124),1) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("COUNTREAD",vRM) Q 
	S X=$P(vobj(sysmappropdata),$C(124),2) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("COUNTSET",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("SYSMAPPROPDATA","MSG",979,"SYSMAPPROPDATA."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VINDEX(sysmappropdata)	; Update index entries
	;
	I %O=1 D  Q 
	.	Q 
	D vi1(.sysmappropdata)
	;
	Q 
	;
vi1(sysmappropdata)	; Maintain TABLECOL index entries (Table Column Index)
	;
	N vdelete S vdelete=0
	N v2 S v2=vobj(sysmappropdata,-5)
	N v3 S v3=vobj(sysmappropdata,-6)
	N v4 S v4=vobj(sysmappropdata,-3)
	N v5 S v5=vobj(sysmappropdata,-4)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(^SYSMAP("DATA",vobj(sysmappropdata,-3),vobj(sysmappropdata,-4),"P",vobj(sysmappropdata,-5),vobj(sysmappropdata,-6)))#2,'$D(^SYSMAPX("PROPDATA-TC",v2,v3,v4,v5)) do vidxerr("TABLECOL")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^SYSMAPX("PROPDATA-TC",v2,v3,v4,v5)="" quit
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^SYSMAPX("PROPDATA-TC",v2,v3,v4,v5)
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
	N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	N sysmappropdata S sysmappropdata=$$vDb2($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4))
	.	I ((","_vlist_",")[",VINDEX,") D VINDEX(.sysmappropdata) K vobj(+$G(sysmappropdata)) Q 
	.	I ((","_vlist_",")[",TABLECOL,") D vi1(.sysmappropdata)
	.	K vobj(+$G(sysmappropdata)) Q 
	;
	Q 
	;
VIDXBLD1(sysmappropdata,vlist)	; Rebuild index files for one record (External call)
	;
	N i
	;
	I ((","_vlist_",")[",VINDEX,") D VINDEX(.sysmappropdata) Q 
	I ((","_vlist_",")[",TABLECOL,") D vi1(.sysmappropdata)
	;
	Q 
	;
vidxerr(di)	; Error message
	;
	D SETERR^DBSEXECU("SYSMAPPROPDATA","MSG",1225,"SYSMAPPROPDATA."_di)
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
	I ($D(vx("TARGET"))#2) S vux("TARGET")=vx("TARGET")
	I ($D(vx("LABEL"))#2) S vux("LABEL")=vx("LABEL")
	I ($D(vx("TABLE"))#2) S vux("TABLE")=vx("TABLE")
	I ($D(vx("COLUMN"))#2) S vux("COLUMN")=vx("COLUMN")
	D vkey(1) S voldkey=vobj(sysmappropdata,-3)_","_vobj(sysmappropdata,-4)_","_vobj(sysmappropdata,-5)_","_vobj(sysmappropdata,-6) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(sysmappropdata,-3)_","_vobj(sysmappropdata,-4)_","_vobj(sysmappropdata,-5)_","_vobj(sysmappropdata,-6) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(sysmappropdata)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPPPROP(vnewrec,"/NOCASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/",1) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("SYSMAPPROPDATA",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("TARGET"))#2) S vobj(sysmappropdata,-3)=$piece(vux("TARGET"),"|",i)
	I ($D(vux("LABEL"))#2) S vobj(sysmappropdata,-4)=$piece(vux("LABEL"),"|",i)
	I ($D(vux("TABLE"))#2) S vobj(sysmappropdata,-5)=$piece(vux("TABLE"),"|",i)
	I ($D(vux("COLUMN"))#2) S vobj(sysmappropdata,-6)=$piece(vux("COLUMN"),"|",i)
	Q 
	;
VIDXPGM()	;
	Q "MAPPPROP" ; Location of index program
	;
	;
vDb1(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPPROPDATA,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPPROPDATA"
	S vobj(vOid)=$G(^SYSMAP("DATA",v1,v2,"P",v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("DATA",v1,v2,"P",v3,v4))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SYSMAPPROPDATA" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb2(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPPROPDATA,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPPROPDATA"
	S vobj(vOid)=$G(^SYSMAP("DATA",v1,v2,"P",v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("DATA",v1,v2,"P",v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vOpen1()	;	TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^SYSMAP("DATA",vos2),1) I vos2="" G vL1a0
	S vos3=""
vL1a4	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL1a2
	S vos4=""
vL1a6	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4),1) I vos4="" G vL1a4
	S vos5=""
vL1a8	S vos5=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4,vos5),1) I vos5="" G vL1a6
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vReCp1(v1)	;	RecordSYSMAPPROPDATA.copy: SYSMAPPROPDATA
	;
	Q $$copy^UCGMR(sysmappropdata)
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
