DBTBL7FL(dbtbl7,vpar,vparNorm)	; DBTBL7 - Trigger Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL7 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (16)             03/19/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl7,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl7,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl7,.vx,1,"|")
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
	.	I ($D(vx("%LIBS"))#2)!($D(vx("TABLE"))#2)!($D(vx("TRGID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL7",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl7,-3),V2=vobj(dbtbl7,-4),V3=vobj(dbtbl7,-5) Q:'($D(^DBTBL(V1,7,V2,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl7 S dbtbl7=$$vDb1(%LIBS,TABLE,TRGID)
	I (%O=2) D
	.	S vobj(dbtbl7,-2)=2
	.	;
	.	D DBTBL7FL(dbtbl7,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl7)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl7,-3),V2=vobj(dbtbl7,-4),V3=vobj(dbtbl7,-5) I '(''($D(^DBTBL(V1,7,V2,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	I vpar["/VALFK/" D CHKFKS ; Check foreign keys
	I vpar["/VALRI/" D VFKEYS ; Foreign key definition
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(dbtbl7),$C(124),9)=$P($H,",",1)
	. S $P(vobj(dbtbl7),$C(124),11)=$P($H,",",2)
	.	I '+$P($G(vobj(dbtbl7,-100,"0*","USER")),"|",2) S $P(vobj(dbtbl7),$C(124),10)=$$USERNAM^%ZFUNC
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl7)) S ^DBTBL(vobj(dbtbl7,-3),7,vobj(dbtbl7,-4),vobj(dbtbl7,-5))=vobj(dbtbl7)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar["/CASDEL/" D VCASDEL ; Cascade delete
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^DBTBL(vobj(dbtbl7,-3),7,vobj(dbtbl7,-4),vobj(dbtbl7,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl7),$C(124),7)="") S $P(vobj(dbtbl7),$C(124),7)=0 ; actad
	I ($P(vobj(dbtbl7),$C(124),5)="") S $P(vobj(dbtbl7),$C(124),5)=0 ; actai
	I ($P(vobj(dbtbl7),$C(124),6)="") S $P(vobj(dbtbl7),$C(124),6)=0 ; actau
	I ($P(vobj(dbtbl7),$C(124),4)="") S $P(vobj(dbtbl7),$C(124),4)=0 ; actbd
	I ($P(vobj(dbtbl7),$C(124),2)="") S $P(vobj(dbtbl7),$C(124),2)=0 ; actbi
	I ($P(vobj(dbtbl7),$C(124),3)="") S $P(vobj(dbtbl7),$C(124),3)=0 ; actbu
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl7),$C(124),7)="") D vreqerr("ACTAD") Q 
	I ($P(vobj(dbtbl7),$C(124),5)="") D vreqerr("ACTAI") Q 
	I ($P(vobj(dbtbl7),$C(124),6)="") D vreqerr("ACTAU") Q 
	I ($P(vobj(dbtbl7),$C(124),4)="") D vreqerr("ACTBD") Q 
	I ($P(vobj(dbtbl7),$C(124),2)="") D vreqerr("ACTBI") Q 
	I ($P(vobj(dbtbl7),$C(124),3)="") D vreqerr("ACTBU") Q 
	I ($P(vobj(dbtbl7),$C(124),1)="") D vreqerr("DES") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl7,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl7,-4)="") D vreqerr("TABLE") Q 
	I (vobj(dbtbl7,-5)="") D vreqerr("TRGID") Q 
	;
	I ($D(vx("ACTAD"))#2),($P(vobj(dbtbl7),$C(124),7)="") D vreqerr("ACTAD") Q 
	I ($D(vx("ACTAI"))#2),($P(vobj(dbtbl7),$C(124),5)="") D vreqerr("ACTAI") Q 
	I ($D(vx("ACTAU"))#2),($P(vobj(dbtbl7),$C(124),6)="") D vreqerr("ACTAU") Q 
	I ($D(vx("ACTBD"))#2),($P(vobj(dbtbl7),$C(124),4)="") D vreqerr("ACTBD") Q 
	I ($D(vx("ACTBI"))#2),($P(vobj(dbtbl7),$C(124),2)="") D vreqerr("ACTBI") Q 
	I ($D(vx("ACTBU"))#2),($P(vobj(dbtbl7),$C(124),3)="") D vreqerr("ACTBU") Q 
	I ($D(vx("DES"))#2),($P(vobj(dbtbl7),$C(124),1)="") D vreqerr("DES") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL7","MSG",1767,"DBTBL7."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VFKEYS	; Foreign keys
	;
	I '(vobj(dbtbl7,-4)="") S vfkey("^DBTBL("_""""_vobj(dbtbl7,-3)_""""_","_1_","_""""_vobj(dbtbl7,-4)_""""_")")="DBTBL7(%LIBS,TABLE) -> DBTBL1"
	Q 
	;
CHKFKS	; Check foreign keys when not under buffer
	;
	N vERRMSG
	;
	 N V1,V2 S V1=vobj(dbtbl7,-3),V2=vobj(dbtbl7,-4) I '($D(^DBTBL(V1,1,V2))) S vERRMSG=$$^MSG(8563,"DBTBL7(%LIBS,TABLE) -> DBTBL1") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl7,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	I $L(vobj(dbtbl7,-4))>25 S vRM=$$^MSG(1076,25) D vdderr("TABLE",vRM) Q 
	I $L(vobj(dbtbl7,-5))>20 S vRM=$$^MSG(1076,20) D vdderr("TRGID",vRM) Q 
	I '("01"[$P(vobj(dbtbl7),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("ACTAD",vRM) Q 
	I '("01"[$P(vobj(dbtbl7),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("ACTAI",vRM) Q 
	I '("01"[$P(vobj(dbtbl7),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("ACTAU",vRM) Q 
	I '("01"[$P(vobj(dbtbl7),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("ACTBD",vRM) Q 
	I '("01"[$P(vobj(dbtbl7),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("ACTBI",vRM) Q 
	I '("01"[$P(vobj(dbtbl7),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("ACTBU",vRM) Q 
	I $L($P(vobj(dbtbl7),$C(124),8))>255 S vRM=$$^MSG(1076,255) D vdderr("COLUMNS",vRM) Q 
	I $L($P(vobj(dbtbl7),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(dbtbl7),$C(124),12))>255 S vRM=$$^MSG(1076,255) D vdderr("IFCOND",vRM) Q 
	I $L($P(vobj(dbtbl7),$C(124),13))>10 S vRM=$$^MSG(1076,10) D vdderr("PROCMODE",vRM) Q 
	S X=$P(vobj(dbtbl7),$C(124),11) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TIME",vRM) Q 
	S X=$P(vobj(dbtbl7),$C(124),9) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("TLD",vRM) Q 
	I $L($P(vobj(dbtbl7),$C(124),10))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL7","MSG",979,"DBTBL7."_di_" "_vRM)
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
	I ($D(vx("TABLE"))#2) S vux("TABLE")=vx("TABLE")
	I ($D(vx("TRGID"))#2) S vux("TRGID")=vx("TRGID")
	D vkey(1) S voldkey=vobj(dbtbl7,-3)_","_vobj(dbtbl7,-4)_","_vobj(dbtbl7,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl7,-3)_","_vobj(dbtbl7,-4)_","_vobj(dbtbl7,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl7)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL7FL(vnewrec,"/NOCASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/",1) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL7",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl7,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("TABLE"))#2) S vobj(dbtbl7,-4)=$piece(vux("TABLE"),"|",i)
	I ($D(vux("TRGID"))#2) S vobj(dbtbl7,-5)=$piece(vux("TRGID"),"|",i)
	Q 
	;
VCASDEL	; Cascade delete logic
	;
	 N V1,V2,V3 S V1=vobj(dbtbl7,-3),V2=vobj(dbtbl7,-4),V3=vobj(dbtbl7,-5) D vDbDe1() ; Cascade delete
	;
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL7D WHERE %LIBS=:V1 AND TABLE=:V2 AND TRGID=:V3
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,7,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL7,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7"
	S vobj(vOid)=$G(^DBTBL(v1,7,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,7,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL7" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	%LIBS,TABLE,TRGID,SEQ FROM DBTBL7D WHERE %LIBS=:V1 AND TABLE=:V2 AND TRGID=:V3
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=$G(V2) I vos3="" G vL1a0
	S vos4=$G(V3) I vos4="" G vL1a0
	S vos5=""
vL1a5	S vos5=$O(^DBTBL(vos2,7,vos3,vos4,vos5),1) I vos5="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL7.copy: DBTBL7
	;
	Q $$copy^UCGMR(dbtbl7)
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
