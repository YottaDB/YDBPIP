DBARCHFL(dbutarchive,vpar,vparNorm)	; DBUTARCHIVE - Archived Enabled Journals Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBUTARCHIVE ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (3)              04/30/2007
	; Trigger Definition (5)                      04/16/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbutarchive,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbutarchive,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbutarchive,.vx,1,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	; Define local variables for access keys for legacy triggers
	N ARCHTBL S ARCHTBL=vobj(dbutarchive,-3)
	;
	I %O=0 D  Q  ; Create record control block
	.	I vpar["/TRIGBEF/" D VBI ; Before insert triggers
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	I vpar["/TRIGAFT/" D VAI ; After insert triggers
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I ($D(vx("ARCHTBL"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/TRIGBEF/" D VBU ; Before update triggers
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBUTARCHIVE",.vx)
	.	S %O=1 D vexec
	.	I vpar["/TRIGAFT/" D VAU ; After update triggers
	.	Q 
	;
	I %O=2 D  Q  ; Verify record control block
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	S vpar=$$setPar^UCUTILN(vpar,"NOJOURNAL/NOUPDATE")
	.	D vexec
	.	I vpar["/TRIGAFT/" D VAI ; After insert triggers
	.	Q 
	;
	I %O=3 D  Q  ; Delete record control block
	.	  N V1 S V1=vobj(dbutarchive,-3) Q:'($D(^UTBL("DBARCHIVE",V1))#2)  ; No record exists
	.	I vpar["/TRIGBEF/" D VBD ; Before delete triggers
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbutarchive S dbutarchive=$$vDb1(ARCHTBL)
	I (%O=2) D
	.	S vobj(dbutarchive,-2)=2
	.	;
	.	D DBARCHFL(dbutarchive,vpar)
	.	Q 
	;
	K vobj(+$G(dbutarchive)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1 S V1=vobj(dbutarchive,-3) I '(''($D(^UTBL("DBARCHIVE",V1))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(dbutarchive,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(dbutarchive,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbutarchive)) S ^UTBL("DBARCHIVE",vobj(dbutarchive,-3))=vobj(dbutarchive)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(dbutarchive,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^UTBL("DBARCHIVE",vobj(dbutarchive,-3))
	;*** End of code by-passed by compiler ***
	Q 
	;
vreqn	; Validate required data items
	;
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbutarchive,-3)="") D vreqerr("ARCHTBL") Q 
	;
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBUTARCHIVE","MSG",1767,"DBUTARCHIVE."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VAI	;
	 S ER=0
	D vai1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VAU	;
	 S ER=0
	I ($order(vx(""))="") Q 
	I ($D(vx("ARCHTBL"))#2)!($D(vx("INCLUDED"))#2) D vau1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VBD	;
	 S ER=0
	D vbd1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VBI	;
	 S ER=0
	D vbi1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VBU	;
	 S ER=0
	I ($order(vx(""))="") D AUDIT^UCUTILN(dbutarchive,.vx,1,"|") Q 
	I ($D(vx("ARCHWITH"))#2) D vbu1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	D AUDIT^UCUTILN(dbutarchive,.vx,1,"|")
	Q 
	;
vai1	; Trigger AFTER_INSERT - After Insert Trigger
	;
	; DBUTARCHIVE After Insert Trigger
	;
	N i
	N tbl
	;
	D COMPILE^DBSFILB(vobj(dbutarchive,-3))
	;
	F i=1:1 S tbl=$piece($P(vobj(dbutarchive),$C(124),1),",",i) Q:(tbl="")  D COMPILE^DBSFILB(tbl)
	;
	D COMPILE^DBSPROC("DBARCHIVE")
	;
	Q 
	;
vau1	; Trigger AU_TBLS - After Update ARCHTBL or INCLUDED
	;
	; DBUTARCHIVE After Update Trigger on ARCHTBL and INCLUDED
	;
	N wasChange S wasChange=0
	N newTbls N oldTbls
	N i
	;
	I vobj(dbutarchive,-3)'=$S($D(vobj(dbutarchive,-100,"1*","ARCHTBL")):$P($E(vobj(dbutarchive,-100,"1*","ARCHTBL"),5,9999),$C(124)),1:vobj(dbutarchive,-3)) D
	.	;
	.	D COMPILE^DBSFILB(vobj(dbutarchive,-3))
	.	S wasChange=1
	.	Q 
	;
	S newTbls=($P(vobj(dbutarchive),$C(124),1))
	S oldTbls=($S($D(vobj(dbutarchive,-100,"0*","INCLUDED")):$P($E(vobj(dbutarchive,-100,"0*","INCLUDED"),5,9999),$C(124)),1:$P(vobj(dbutarchive),$C(124),1)))
	;
	F i=1:1:$S((newTbls=""):0,1:$L(newTbls,",")) D
	.	;
	.	N TBL
	.	;
	.	S TBL=$piece(newTbls,",",i)
	.	;
	.	I '((","_oldTbls_",")[(","_TBL_",")) D
	..		;
	..		D COMPILE^DBSFILB(TBL)
	..		S wasChange=1
	..		Q 
	.	Q 
	;
	I wasChange D COMPILE^DBSPROC("DBARCHIVE")
	;
	Q 
	;
vbd1	; Trigger BEFORE_DELETE - Before Delete
	;
	; Before Delete trigger
	;
	N ARCHTBL S ARCHTBL=vobj(dbutarchive,-3)
	;
	;  #ACCEPT Date=03/08/07; Pgm=RussellDS; CR=25675; Group=BYPASS
	;*** Start of code by-passed by compiler
	if $D(^DBARCHX(ARCHTBL)) set ER=1
	;*** End of code by-passed by compiler ***
	;
	; Cannot delete ~p1 - already has archived data
	I ER S RM=$$^MSG(6899,ARCHTBL)
	;
	Q 
	;
vbi1	; Trigger BEFORE_INSERT - Before Insert Trigger
	;
	; DBUTARCHIVE Before Insert Trigger
	;
	S RM=$$ARCHTBLCHK^DBARCHIVE(vobj(dbutarchive,-3))
	;
	I (RM=""),'($P(vobj(dbutarchive),$C(124),1)="") S RM=$$INCLUDEDCHK^DBARCHIVE(vobj(dbutarchive,-3),$P(vobj(dbutarchive),$C(124),1))
	;
	I '(RM="") S ER=1
	;
	Q 
	;
vbu1	; Trigger BU_INCLUDED - Before Update on INCLUDED
	;
	; Before Update Trigger on INCLUDED
	;
	I '($P(vobj(dbutarchive),$C(124),1)="") S RM=$$INCLUDEDCHK^DBARCHIVE(vobj(dbutarchive,-3),$P(vobj(dbutarchive),$C(124),1))
	;
	I '(RM="") S ER=1
	;
	; Check any deleted tables
	I 'ER D
	.	;
	.	N newTbls N oldTbls
	.	N i
	.	;
	.	S newTbls=($P(vobj(dbutarchive),$C(124),1))
	.	S oldTbls=($P(vobj(dbutarchive),$C(124),1))
	.	;
	.	F i=1:1:$S((oldTbls=""):0,1:$L(oldTbls,",")) D  Q:'(RM="") 
	..		;
	..		N TBL
	..		;
	..		S TBL=$piece(oldTbls,",",i)
	..		;
	..		I '((","_newTbls_",")[(","_TBL_",")) D
	...			;
	...			;     #ACCEPT Date=03/08/07; Pgm=RussellDS; CR=25675; Group=BYPASS
	...			;*** Start of code by-passed by compiler
	...			if $D(^DBARCHX(TBL)) set ER=1
	...			;*** End of code by-passed by compiler ***
	...			;
	...			; Cannot delete ~p1 - already has archived data
	...			I ER S RM=$$^MSG(6899,TBL)
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbutarchive,-3))>256 S vRM=$$^MSG(1076,256) D vdderr("ARCHTBL",vRM) Q 
	I $L($P(vobj(dbutarchive),$C(124),1))>256 S vRM=$$^MSG(1076,256) D vdderr("INCLUDED",vRM) Q 
	I $L($P(vobj(dbutarchive),$C(124),2))>20 S vRM=$$^MSG(1076,20) D vdderr("SRLCOL",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBUTARCHIVE","MSG",979,"DBUTARCHIVE."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vkchged	; Access key changed
	;
	 S ER=0
	;
	N %O S %O=1
	N vnewkey N voldkey N vux
	N voldpar S voldpar=$get(vpar) ; Save filer switches
	;
	S vux=vx("ARCHTBL")
	S voldkey=$piece(vux,"|",1) S vobj(dbutarchive,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/TRIGBEF/" D VBU
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(dbutarchive,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbutarchive)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBUTARCHIVE",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	S vpar=voldpar
	I vpar["/TRIGAFT/" D VAU
	;
	S vobj(dbutarchive,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(DBUTARCHIVE,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBUTARCHIVE"
	S vobj(vOid)=$G(^UTBL("DBARCHIVE",v1))
	I vobj(vOid)="",'$D(^UTBL("DBARCHIVE",v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBUTARCHIVE" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReCp1(v1)	;	RecordDBUTARCHIVE.copy: DBUTARCHIVE
	;
	Q $$copy^UCGMR(dbutarchive)
	;
vReSav1(vnewrec)	;	RecordDBUTARCHIVE saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	S ^UTBL("DBARCHIVE",vobj(vnewrec,-3))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
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
