PROCJFIL(processjnl,vpar,vparNorm)	; PROCESSJNL - Process ID Journal Filer
	;
	; **** Routine compiled from DATA-QWIK Filer PROCESSJNL ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (24)             02/21/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(processjnl,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(processjnl,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(processjnl,.vx,1,"|")
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
	.	I ($D(vx("SYSTEMDAT"))#2)!($D(vx("PID"))#2)!($D(vx("JNLSEQ"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("PROCESSJNL",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(processjnl,-3),V2=vobj(processjnl,-4),V3=vobj(processjnl,-5) Q:'($D(^PROCJNL(V1,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N processjnl S processjnl=$$vDb1(SYSTEMDAT,PID,JNLSEQ)
	I (%O=2) D
	.	S vobj(processjnl,-2)=2
	.	;
	.	D PROCJFIL(processjnl,vpar)
	.	Q 
	;
	K vobj(+$G(processjnl)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(processjnl,-3),V2=vobj(processjnl,-4),V3=vobj(processjnl,-5) I '(''($D(^PROCJNL(V1,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(processjnl)) S ^PROCJNL(vobj(processjnl,-3),vobj(processjnl,-4),vobj(processjnl,-5))=vobj(processjnl)
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
	ZWI ^PROCJNL(vobj(processjnl,-3),vobj(processjnl,-4),vobj(processjnl,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(processjnl),$C(124),12)="") D vreqerr("ACTION") Q 
	I ($P(vobj(processjnl),$C(124),16)="") D vreqerr("ISSDATE") Q 
	I ($P(vobj(processjnl),$C(124),15)="") D vreqerr("ISSPID") Q 
	I ($P(vobj(processjnl),$C(124),17)="") D vreqerr("ISSTIME") Q 
	I ($P(vobj(processjnl),$C(124),19)="") D vreqerr("ISSTLO") Q 
	I ($P(vobj(processjnl),$C(124),18)="") D vreqerr("ISSUSRNM") Q 
	I ($P(vobj(processjnl),$C(124),3)="") D vreqerr("MODE") Q 
	I ($P(vobj(processjnl),$C(124),6)="") D vreqerr("PRCTYP") Q 
	I ($P(vobj(processjnl),$C(124),1)="") D vreqerr("REGDATE") Q 
	I ($P(vobj(processjnl),$C(124),2)="") D vreqerr("REGTIME") Q 
	I ($P(vobj(processjnl),$C(124),14)="") D vreqerr("STATUS") Q 
	I ($P(vobj(processjnl),$C(124),4)="") D vreqerr("TLO") Q 
	I ($P(vobj(processjnl),$C(124),5)="") D vreqerr("USRNAM") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(processjnl,-3)="") D vreqerr("SYSTEMDAT") Q 
	I (vobj(processjnl,-4)="") D vreqerr("PID") Q 
	I (vobj(processjnl,-5)="") D vreqerr("JNLSEQ") Q 
	;
	I ($D(vx("ACTION"))#2),($P(vobj(processjnl),$C(124),12)="") D vreqerr("ACTION") Q 
	I ($D(vx("ISSDATE"))#2),($P(vobj(processjnl),$C(124),16)="") D vreqerr("ISSDATE") Q 
	I ($D(vx("ISSPID"))#2),($P(vobj(processjnl),$C(124),15)="") D vreqerr("ISSPID") Q 
	I ($D(vx("ISSTIME"))#2),($P(vobj(processjnl),$C(124),17)="") D vreqerr("ISSTIME") Q 
	I ($D(vx("ISSTLO"))#2),($P(vobj(processjnl),$C(124),19)="") D vreqerr("ISSTLO") Q 
	I ($D(vx("ISSUSRNM"))#2),($P(vobj(processjnl),$C(124),18)="") D vreqerr("ISSUSRNM") Q 
	I ($D(vx("MODE"))#2),($P(vobj(processjnl),$C(124),3)="") D vreqerr("MODE") Q 
	I ($D(vx("PRCTYP"))#2),($P(vobj(processjnl),$C(124),6)="") D vreqerr("PRCTYP") Q 
	I ($D(vx("REGDATE"))#2),($P(vobj(processjnl),$C(124),1)="") D vreqerr("REGDATE") Q 
	I ($D(vx("REGTIME"))#2),($P(vobj(processjnl),$C(124),2)="") D vreqerr("REGTIME") Q 
	I ($D(vx("STATUS"))#2),($P(vobj(processjnl),$C(124),14)="") D vreqerr("STATUS") Q 
	I ($D(vx("TLO"))#2),($P(vobj(processjnl),$C(124),4)="") D vreqerr("TLO") Q 
	I ($D(vx("USRNAM"))#2),($P(vobj(processjnl),$C(124),5)="") D vreqerr("USRNAM") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("PROCESSJNL","MSG",1767,"PROCESSJNL."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	S X=vobj(processjnl,-3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("SYSTEMDAT",vRM) Q 
	S X=vobj(processjnl,-4) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("PID",vRM) Q 
	S X=vobj(processjnl,-5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("JNLSEQ",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),12))>12 S vRM=$$^MSG(1076,12) D vdderr("ACTION",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),11))>12 S vRM=$$^MSG(1076,12) D vdderr("EVENT",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),10))>12 S vRM=$$^MSG(1076,12) D vdderr("FUNC",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),16) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ISSDATE",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),15) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("ISSPID",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),17) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("ISSTIME",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),19))>40 S vRM=$$^MSG(1076,40) D vdderr("ISSTLO",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),18))>40 S vRM=$$^MSG(1076,40) D vdderr("ISSUSRNM",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("MODE",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),20) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PRCDATE",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),21) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("PRCTIME",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),6))>10 S vRM=$$^MSG(1076,10) D vdderr("PRCTYP",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),13))>80 S vRM=$$^MSG(1076,80) D vdderr("QUALIF",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),1) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("REGDATE",vRM) Q 
	S X=$P(vobj(processjnl),$C(124),2) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("REGTIME",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),14))>12 S vRM=$$^MSG(1076,12) D vdderr("STATUS",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),7))>10 S vRM=$$^MSG(1076,10) D vdderr("SUBTYP",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("TLO",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),8))>12 S vRM=$$^MSG(1076,12) D vdderr("USERID",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),9))>12 S vRM=$$^MSG(1076,12) D vdderr("USRCLS",vRM) Q 
	I $L($P(vobj(processjnl),$C(124),5))>40 S vRM=$$^MSG(1076,40) D vdderr("USRNAM",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("PROCESSJNL","MSG",979,"PROCESSJNL."_di_" "_vRM)
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
	I ($D(vx("SYSTEMDAT"))#2) S vux("SYSTEMDAT")=vx("SYSTEMDAT")
	I ($D(vx("PID"))#2) S vux("PID")=vx("PID")
	I ($D(vx("JNLSEQ"))#2) S vux("JNLSEQ")=vx("JNLSEQ")
	D vkey(1) S voldkey=vobj(processjnl,-3)_","_vobj(processjnl,-4)_","_vobj(processjnl,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(processjnl,-3)_","_vobj(processjnl,-4)_","_vobj(processjnl,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(processjnl)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^PROCJNL(vobj(vnewrec,-3),vobj(vnewrec,-4),vobj(vnewrec,-5))=$$RTBAR^%ZFUNC(vobj(vnewrec)) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("PROCESSJNL",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("SYSTEMDAT"))#2) S vobj(processjnl,-3)=$piece(vux("SYSTEMDAT"),"|",i)
	I ($D(vux("PID"))#2) S vobj(processjnl,-4)=$piece(vux("PID"),"|",i)
	I ($D(vux("JNLSEQ"))#2) S vobj(processjnl,-5)=$piece(vux("JNLSEQ"),"|",i)
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(PROCESSJNL,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSJNL"
	S vobj(vOid)=$G(^PROCJNL(v1,v2,v3))
	I vobj(vOid)="",'$D(^PROCJNL(v1,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,PROCESSJNL" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordPROCESSJNL.copy: PROCESSJNL
	;
	Q $$copy^UCGMR(processjnl)
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
