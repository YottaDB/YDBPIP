DBSDF1F(dbtbl1,vpar,vparNorm)	; DBTBL1 - Data Dictionary File Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL1 ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (52)             01/11/2006
	; Trigger Definition (7)                      07/31/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl1,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl1,.vxins,11,"|")
	I %O=1 Q:'$D(vobj(dbtbl1,-100))  D AUDIT^UCUTILN(dbtbl1,.vx,11,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	; Define local variables for access keys for legacy triggers
	N %LIBS S %LIBS=vobj(dbtbl1,-3)
	N FID S FID=vobj(dbtbl1,-4)
	;
	I %O=0 D  Q  ; Create record control block
	.	D vinit ; Initialize column values
	.	I vpar["/TRIGBEF/" D VBI ; Before insert triggers
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	I vpar["/TRIGAFT/" D VAI ; After insert triggers
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I ($D(vx("%LIBS"))#2)!($D(vx("FID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/TRIGBEF/" D VBU ; Before update triggers
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL1",.vx)
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
	.	  N V1,V2 S V1=vobj(dbtbl1,-3),V2=vobj(dbtbl1,-4) Q:'($D(^DBTBL(V1,1,V2)))  ; No record exists
	.	I vpar["/TRIGBEF/" D VBD ; Before delete triggers
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl1 S dbtbl1=$$vDb1(%LIBS,FID)
	I (%O=2) D
	.	S vobj(dbtbl1,-2)=2
	.	;
	.	D DBSDF1F(dbtbl1,vpar)
	.	Q 
	E  D VINDEX(dbtbl1)
	;
	K vobj(+$G(dbtbl1)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(dbtbl1,-3),V2=vobj(dbtbl1,-4) I '(''($D(^DBTBL(V1,1,V2)))=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	. S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),10)=$P($H,",",1)
	.	I '+$P($G(vobj(dbtbl1,-100,10,"USER")),"|",2) S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),11)=$$USERNAM^%ZFUNC
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1,%O,.vx)
	.	;
	.	N n S n=-1
	.	N x
	.	;
	.	I %O=0 F  S n=$order(vobj(dbtbl1,n)) Q:(n="")  D
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),n)=vobj(dbtbl1,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	E  F  S n=$order(vobj(dbtbl1,-100,n)) Q:(n="")  D
	..		Q:'$D(vobj(dbtbl1,n)) 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),n)=vobj(dbtbl1,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl1)) S ^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4))=vobj(dbtbl1)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	I vpar["/INDEX/",'(%O=1)!'($order(vx(""))="") D VINDEX(.dbtbl1) ; Update Index files
	;
	Q 
	;
vload	; Record Load - force loading of unloaded data
	;
	N n S n=""
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	for  set n=$order(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),n)) quit:n=""  if '$D(vobj(dbtbl1,n)),$D(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),n))#2 set vobj(dbtbl1,n)=^(n)
	;*** End of code by-passed by compiler ***
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I '$get(vkeychg),$D(vobj(dbtbl1,-100)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,Deleted object cannot be modified" X $ZT
	;
	I vpar["/CASDEL/" D VCASDEL ; Cascade delete
	I vpar["/INDEX/" D VINDEX(.dbtbl1) ; Delete index entries
	I vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	I ($P(vobj(dbtbl1,10),$C(124),1)="") S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),1)=124 ; del
	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
	I ($P(vobj(dbtbl1,22),$C(124),10)="") S vobj(dbtbl1,-100,22)="",$P(vobj(dbtbl1,22),$C(124),10)=0 ; dflag
	I ($P(vobj(dbtbl1,10),$C(124),7)="") S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),7)=0 ; dftord
	I ($P(vobj(dbtbl1,10),$C(124),14)="") S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),14)=0 ; extendlength
	 S:'$D(vobj(dbtbl1,12)) vobj(dbtbl1,12)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),12)),1:"")
	I ($P(vobj(dbtbl1,12),$C(124),1)="") S:'$D(vobj(dbtbl1,-100,12,"FSN")) vobj(dbtbl1,-100,12,"FSN")="T001"_$P(vobj(dbtbl1,12),$C(124),1) S vobj(dbtbl1,-100,12)="",$P(vobj(dbtbl1,12),$C(124),1)="f"_$E(($TR(FID,"_","z")),1,7) ; fsn
	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	I ($P(vobj(dbtbl1,100),$C(124),5)="") S vobj(dbtbl1,-100,100)="",$P(vobj(dbtbl1,100),$C(124),5)=0 ; log
	I ($P(vobj(dbtbl1,10),$C(124),3)="") S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),3)=0 ; netloc
	I ($P(vobj(dbtbl1,100),$C(124),2)="") S vobj(dbtbl1,-100,100)="",$P(vobj(dbtbl1,100),$C(124),2)=1 ; rectyp
	I ($P(vobj(dbtbl1,22),$C(124),9)="") S vobj(dbtbl1,-100,22)="",$P(vobj(dbtbl1,22),$C(124),9)=0 ; rflag
	I ($P(vobj(dbtbl1,10),$C(124),2)="") S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),2)="PBS" ; syssn
	I ($P(vobj(dbtbl1,22),$C(124),1)="") S vobj(dbtbl1,-100,22)="",$P(vobj(dbtbl1,22),$C(124),1)=0 ; val4ext
	Q 
	;
vreqn	; Validate required data items
	;
	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	I ($P(vobj(dbtbl1,16),$C(124),1)="") D vreqerr("ACCKEYS") Q 
	I ($P(vobj(dbtbl1),$C(124),1)="") D vreqerr("DES") Q 
	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
	I ($P(vobj(dbtbl1,22),$C(124),10)="") D vreqerr("DFLAG") Q 
	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	I ($P(vobj(dbtbl1,10),$C(124),7)="") D vreqerr("DFTORD") Q 
	I ($P(vobj(dbtbl1,10),$C(124),14)="") D vreqerr("EXTENDLENGTH") Q 
	 S:'$D(vobj(dbtbl1,13)) vobj(dbtbl1,13)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),13)),1:"")
	I ($P(vobj(dbtbl1,13),$C(124),1)="") D vreqerr("FDOC") Q 
	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	I ($P(vobj(dbtbl1,100),$C(124),5)="") D vreqerr("LOG") Q 
	I ($P(vobj(dbtbl1,22),$C(124),9)="") D vreqerr("RFLAG") Q 
	I ($P(vobj(dbtbl1,22),$C(124),1)="") D vreqerr("VAL4EXT") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl1,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl1,-4)="") D vreqerr("FID") Q 
	;
	I '($order(vobj(dbtbl1,-100,10,""))="") D
	.	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	.	I ($D(vx("DFTORD"))#2),($P(vobj(dbtbl1,10),$C(124),7)="") D vreqerr("DFTORD") Q 
	.	I ($D(vx("EXTENDLENGTH"))#2),($P(vobj(dbtbl1,10),$C(124),14)="") D vreqerr("EXTENDLENGTH") Q 
	.	Q 
	I '($order(vobj(dbtbl1,-100,13,""))="") D
	.	 S:'$D(vobj(dbtbl1,13)) vobj(dbtbl1,13)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),13)),1:"")
	.	I ($D(vx("FDOC"))#2),($P(vobj(dbtbl1,13),$C(124),1)="") D vreqerr("FDOC") Q 
	.	Q 
	I '($order(vobj(dbtbl1,-100,16,""))="") D
	.	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	.	I ($D(vx("ACCKEYS"))#2),($P(vobj(dbtbl1,16),$C(124),1)="") D vreqerr("ACCKEYS") Q 
	.	Q 
	I '($order(vobj(dbtbl1,-100,22,""))="") D
	.	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
	.	I ($D(vx("VAL4EXT"))#2),($P(vobj(dbtbl1,22),$C(124),1)="") D vreqerr("VAL4EXT") Q 
	.	I ($D(vx("RFLAG"))#2),($P(vobj(dbtbl1,22),$C(124),9)="") D vreqerr("RFLAG") Q 
	.	I ($D(vx("DFLAG"))#2),($P(vobj(dbtbl1,22),$C(124),10)="") D vreqerr("DFLAG") Q 
	.	Q 
	I '($order(vobj(dbtbl1,-100,100,""))="") D
	.	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	.	I ($D(vx("LOG"))#2),($P(vobj(dbtbl1,100),$C(124),5)="") D vreqerr("LOG") Q 
	.	Q 
	I '($order(vobj(dbtbl1,-100,"0*",""))="") D
	.	I ($D(vx("DES"))#2),($P(vobj(dbtbl1),$C(124),1)="") D vreqerr("DES") Q 
	.	Q 
	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	I ($D(vx("ACCKEYS"))#2),($P(vobj(dbtbl1,16),$C(124),1)="") D vreqerr("ACCKEYS") Q 
	I ($D(vx("DES"))#2),($P(vobj(dbtbl1),$C(124),1)="") D vreqerr("DES") Q 
	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
	I ($D(vx("DFLAG"))#2),($P(vobj(dbtbl1,22),$C(124),10)="") D vreqerr("DFLAG") Q 
	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	I ($D(vx("DFTORD"))#2),($P(vobj(dbtbl1,10),$C(124),7)="") D vreqerr("DFTORD") Q 
	I ($D(vx("EXTENDLENGTH"))#2),($P(vobj(dbtbl1,10),$C(124),14)="") D vreqerr("EXTENDLENGTH") Q 
	 S:'$D(vobj(dbtbl1,13)) vobj(dbtbl1,13)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),13)),1:"")
	I ($D(vx("FDOC"))#2),($P(vobj(dbtbl1,13),$C(124),1)="") D vreqerr("FDOC") Q 
	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	I ($D(vx("LOG"))#2),($P(vobj(dbtbl1,100),$C(124),5)="") D vreqerr("LOG") Q 
	I ($D(vx("RFLAG"))#2),($P(vobj(dbtbl1,22),$C(124),9)="") D vreqerr("RFLAG") Q 
	I ($D(vx("VAL4EXT"))#2),($P(vobj(dbtbl1,22),$C(124),1)="") D vreqerr("VAL4EXT") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1","MSG",1767,"DBTBL1."_di)
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
	I ($D(vx("ACCKEYS"))#2) D vau1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	I ($D(vx("PARFID"))#2) D vau2 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
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
	D vbu1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	I ($order(vx(""))="") D AUDIT^UCUTILN(dbtbl1,.vx,11,"|") Q 
	I ($D(vx("GLOBAL"))#2) D vbu2 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	D AUDIT^UCUTILN(dbtbl1,.vx,11,"|")
	Q 
	;
vai1	; Trigger AFTER_INSERT - After Insert
	;
	N i
	N ACCKEYS N FID N KEY
	;
	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	S ACCKEYS=$P(vobj(dbtbl1,16),$C(124),1)
	S FID=vobj(dbtbl1,-4)
	;
	; Create missing access keys in DBTBL1D
	;
	F i=1:1:$L(ACCKEYS,",") D
	.	;
	.	S KEY=$piece(ACCKEYS,",",i)
	.	;
	.	N dbtbl1d S dbtbl1d=$$vDbNew1("SYSDEV",FID,KEY)
	.	;
	. S:'$D(vobj(dbtbl1d,-100,"0*","NOD")) vobj(dbtbl1d,-100,"0*","NOD")="T001"_$P(vobj(dbtbl1d),$C(124),1) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),1)=i_"*"
	. S $P(vobj(dbtbl1d),$C(124),10)=KEY
	. S $P(vobj(dbtbl1d),$C(124),22)=KEY
	. S $P(vobj(dbtbl1d),$C(124),2)=12
	. S $P(vobj(dbtbl1d),$C(124),9)="N"
	. S $P(vobj(dbtbl1d),$C(124),15)=1
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(dbtbl1d)) Q 
	;
	Q 
	;
vau1	; Trigger AU_ACCKEYS - After update accecc keys
	;
	N KEYNUM
	N GBLREF N KEYNAME N NEWKEYS N OLDKEYS
	;
	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	S OLDKEYS=$S($D(vobj(dbtbl1,-100,16,"ACCKEYS")):$P($E(vobj(dbtbl1,-100,16,"ACCKEYS"),5,9999),$C(124)),1:$P(vobj(dbtbl1,16),$C(124),1)) ; Old access keys
	S NEWKEYS=$P(vobj(dbtbl1,16),$C(124),1) ; New access keys
	;
	; Reset global reference
	 S:'$D(vobj(dbtbl1,0)) vobj(dbtbl1,0)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0)),1:"")
	S GBLREF="^"_$P(vobj(dbtbl1,0),$C(124),1)_"("_NEWKEYS
	D vUpd1
	;
	F KEYNUM=1:1:$L(NEWKEYS,",") S NEWKEYS($piece(NEWKEYS,",",KEYNUM))=KEYNUM
	;
	; If old key is no longer new key, delete it
	F KEYNUM=1:1:$L(OLDKEYS,",") D
	.	S KEYNAME=$piece(OLDKEYS,",",KEYNUM)
	.	I '($D(NEWKEYS(KEYNAME))#2) D vDbDe1()
	.	Q 
	;
	; For new keys, if already existed, update key number, otherwise add key
	S KEYNAME=""
	F  S KEYNAME=$order(NEWKEYS(KEYNAME)) Q:(KEYNAME="")  D
	.	S KEYNUM=NEWKEYS(KEYNAME)
	.	;
	.	N dbtbl1d S dbtbl1d=$$vDb2("SYSDEV",FID,KEYNAME)
	.	;
	.	I $P(vobj(dbtbl1d),$C(124),1)'=(KEYNUM_"*") D
	..		;
	..	 S:'$D(vobj(dbtbl1d,-100,"0*","NOD")) vobj(dbtbl1d,-100,"0*","NOD")="T001"_$P(vobj(dbtbl1d),$C(124),1) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),1)=KEYNUM_"*"
	..		;
	..		I '$G(vobj(dbtbl1d,-2)) D  ; New key
	...		 S $P(vobj(dbtbl1d),$C(124),9)="N"
	...		 S $P(vobj(dbtbl1d),$C(124),2)=12
	...		 S $P(vobj(dbtbl1d),$C(124),10)=KEYNAME
	...		 S $P(vobj(dbtbl1d),$C(124),22)=KEYNAME
	...		 S $P(vobj(dbtbl1d),$C(124),15)=1
	...			Q 
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 Tcommit:vTp  
	..		Q 
	.	K vobj(+$G(dbtbl1d)) Q 
	;
	Q 
	;
vau2	; Trigger AU_PARFID - After update supertype information
	;
	;----------------------------------------------------------------------
	; Copy data item info from supertype file to descendant files
	;----------------------------------------------------------------------
	;
	N nparfid N oparfid
	;
	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	S nparfid=$P(vobj(dbtbl1,10),$C(124),4) ; Supertype file name
	S oparfid=$S($D(vobj(dbtbl1,-100,10,"PARFID")):$P($E(vobj(dbtbl1,-100,10,"PARFID"),5,9999),$C(124)),1:$P(vobj(dbtbl1,10),$C(124),4)) ; Original name
	I oparfid'="" D PARDEL^DBSDF(oparfid,FID) ; Delete old data
	I nparfid'="" D PARCOPY^DBSDF(nparfid,FID) ; Create new data
	;
	Q 
	;
vbd1	; Trigger BEFORE_DELETE - Before Delete
	;
	; Delete data items
	;
	D vDbDe2()
	;
	Q 
	;
vbi1	; Trigger BEFORE_INSERT - Before Insert
	;
	; Default global name
	;
	 S:'$D(vobj(dbtbl1,0)) vobj(dbtbl1,0)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0)),1:"")
	I ($P(vobj(dbtbl1,0),$C(124),1)="") D
	.	;
	.	I $E((vobj(dbtbl1,-4)),1,4)="UTBL"!($E((vobj(dbtbl1,-4)),1,5)="ZUTBL") S:'$D(vobj(dbtbl1,-100,0,"GLOBAL")) vobj(dbtbl1,-100,0,"GLOBAL")="T001"_$P(vobj(dbtbl1,0),$C(124),1) S vobj(dbtbl1,-100,0)="",$P(vobj(dbtbl1,0),$C(124),1)="UTBL"
	.	E  I $E((vobj(dbtbl1,-4)),1,4)="STBL"!($E((vobj(dbtbl1,-4)),1,5)="ZSTBL") S:'$D(vobj(dbtbl1,-100,0,"GLOBAL")) vobj(dbtbl1,-100,0,"GLOBAL")="T001"_$P(vobj(dbtbl1,0),$C(124),1) S vobj(dbtbl1,-100,0)="",$P(vobj(dbtbl1,0),$C(124),1)="STBL"
	.	E  I $E((vobj(dbtbl1,-4)),1,4)="CTBL"!($E((vobj(dbtbl1,-4)),1,5)="ZCTBL") S:'$D(vobj(dbtbl1,-100,0,"GLOBAL")) vobj(dbtbl1,-100,0,"GLOBAL")="T001"_$P(vobj(dbtbl1,0),$C(124),1) S vobj(dbtbl1,-100,0)="",$P(vobj(dbtbl1,0),$C(124),1)="CTBL"
	.	Q 
	;
	; Reset full global reference
	;
	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	S vobj(dbtbl1,-100,100)="",$P(vobj(dbtbl1,100),$C(124),1)="^"_$P(vobj(dbtbl1,0),$C(124),1)_"("_$P(vobj(dbtbl1,16),$C(124),1)
	;
	Q 
	;
vbu1	; Trigger BEFORE_UPDATE - Before  Update
	;
	Q 
	;
vbu2	; Trigger BU_GLOBAL - Change GLREF field
	;
	N gbl
	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	S gbl=$P(vobj(dbtbl1,100),$C(124),1) ; Old reference
	 S:'$D(vobj(dbtbl1,0)) vobj(dbtbl1,0)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0)),1:"")
	S:'$D(vobj(dbtbl1,-100,100,"GLREF")) vobj(dbtbl1,-100,100,"GLREF")="T001"_$P(vobj(dbtbl1,100),$C(124),1) S vobj(dbtbl1,-100,100)="",$P(vobj(dbtbl1,100),$C(124),1)=$char(94)_$P(vobj(dbtbl1,0),$C(124),1)_"("_$piece(gbl,"(",2) ; New reference
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I (%O=2) D vload
	;
	I ($D(vobj(dbtbl1,0))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,0)) vobj(dbtbl1,0)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0)),1:"")
	.	S X=$P(vobj(dbtbl1,0),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("T",8,0,,"((X?1A.AN)!(X?1""%"".AN)!(X?1""[""1E.E1""]""1E.E))",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1.GLOBAL"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(dbtbl1,1))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,1)) vobj(dbtbl1,1)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),1)),1:"")
	.	I $L($P(vobj(dbtbl1,1),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY1",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,2))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,2)) vobj(dbtbl1,2)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),2)),1:"")
	.	I $L($P(vobj(dbtbl1,2),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY2",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,3))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,3)) vobj(dbtbl1,3)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),3)),1:"")
	.	I $L($P(vobj(dbtbl1,3),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY3",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,4))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,4)) vobj(dbtbl1,4)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),4)),1:"")
	.	I $L($P(vobj(dbtbl1,4),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY4",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,5))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,5)) vobj(dbtbl1,5)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),5)),1:"")
	.	I $L($P(vobj(dbtbl1,5),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY5",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,6))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,6)) vobj(dbtbl1,6)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),6)),1:"")
	.	I $L($P(vobj(dbtbl1,6),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY6",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,7))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,7)) vobj(dbtbl1,7)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),7)),1:"")
	.	I $L($P(vobj(dbtbl1,7),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("AKEY7",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,10))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	.	S X=$P(vobj(dbtbl1,10),$C(124),16) I '(X=""),'(",GTM,ORACLE,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("DBASE",vRM) Q 
	.	S X=$P(vobj(dbtbl1,10),$C(124),1) I '(X=""),'($D(^DBCTL("SYS","DELIM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("DEL",vRM) Q 
	.	I $L($P(vobj(dbtbl1,10),$C(124),6))>200 S vRM=$$^MSG(1076,200) D vdderr("DFTDES",vRM) Q 
	.	I $L($P(vobj(dbtbl1,10),$C(124),9))>200 S vRM=$$^MSG(1076,200) D vdderr("DFTDES1",vRM) Q 
	.	I $L($P(vobj(dbtbl1,10),$C(124),8))>78 S vRM=$$^MSG(1076,78) D vdderr("DFTHDR",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl1,10),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("DFTORD",vRM) Q 
	.	S X=$P(vobj(dbtbl1,10),$C(124),13) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("EXIST",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl1,10),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("EXTENDLENGTH",vRM) Q 
	.	S X=$P(vobj(dbtbl1,10),$C(124),12) I '(X=""),'($D(^DBCTL("SYS","FILETYP",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FILETYP",vRM) Q 
	.	S X=$P(vobj(dbtbl1,10),$C(124),10) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	.	I $L($P(vobj(dbtbl1,10),$C(124),5))>25 S vRM=$$^MSG(1076,25) D vdderr("MPLCTDD",vRM) Q 
	.	S X=$P(vobj(dbtbl1,10),$C(124),3) I '(X=""),'(",0,1,2,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("NETLOC",vRM) Q 
	.	I $L($P(vobj(dbtbl1,10),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("PARFID",vRM) Q 
	.	S X=$P(vobj(dbtbl1,10),$C(124),2) I '(X=""),'($D(^SCATBL(2,X))#2) S vRM=$$^MSG(1485,X) D vdderr("SYSSN",vRM) Q 
	.	I $L($P(vobj(dbtbl1,10),$C(124),11))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,12))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,12)) vobj(dbtbl1,12)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),12)),1:"")
	.	S X=$P(vobj(dbtbl1,12),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("T",12,0,,"X?1A.AN.E!(X?1""%"".AN.E)",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1.FSN"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(dbtbl1,13))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,13)) vobj(dbtbl1,13)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),13)),1:"")
	.	I $L($P(vobj(dbtbl1,13),$C(124),1))>30 S vRM=$$^MSG(1076,30) D vdderr("FDOC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,14))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,14)) vobj(dbtbl1,14)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),14)),1:"")
	.	I $L($P(vobj(dbtbl1,14),$C(124),1))>100 S vRM=$$^MSG(1076,100) D vdderr("QID1",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,16))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
	.	I $L($P(vobj(dbtbl1,16),$C(124),1))>100 S vRM=$$^MSG(1076,100) D vdderr("ACCKEYS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,22))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
	.	I '("01"[$P(vobj(dbtbl1,22),$C(124),10)) S vRM=$$^MSG(742,"L") D vdderr("DFLAG",vRM) Q 
	.	I $L($P(vobj(dbtbl1,22),$C(124),5))>255 S vRM=$$^MSG(1076,255) D vdderr("PREDAEN",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl1,22),$C(124),9)) S vRM=$$^MSG(742,"L") D vdderr("RFLAG",vRM) Q 
	.	I $L($P(vobj(dbtbl1,22),$C(124),8))>12 S vRM=$$^MSG(1076,12) D vdderr("SCREEN",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl1,22),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("VAL4EXT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,99))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,99)) vobj(dbtbl1,99)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),99)),1:"")
	.	I $L($P(vobj(dbtbl1,99),$C(124),3))>4 S vRM=$$^MSG(1076,4) D vdderr("FPN",vRM) Q 
	.	I $L($P(vobj(dbtbl1,99),$C(124),6))>30 S vRM=$$^MSG(1076,30) D vdderr("PUBLISH",vRM) Q 
	.	I $L($P(vobj(dbtbl1,99),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("UDACC",vRM) Q 
	.	I $L($P(vobj(dbtbl1,99),$C(124),2))>8 S vRM=$$^MSG(1076,8) D vdderr("UDFILE",vRM) Q 
	.	I $L($P(vobj(dbtbl1,99),$C(124),5))>20 S vRM=$$^MSG(1076,20) D vdderr("UDPOST",vRM) Q 
	.	I $L($P(vobj(dbtbl1,99),$C(124),4))>20 S vRM=$$^MSG(1076,20) D vdderr("UDPRE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,100))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	.	I $L($P(vobj(dbtbl1,100),$C(124),1))>100 S vRM=$$^MSG(1076,100) D vdderr("GLREF",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl1,100),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("LOG",vRM) Q 
	.	I $L($P(vobj(dbtbl1,100),$C(124),8))>12 S vRM=$$^MSG(1076,12) D vdderr("PTRTIM",vRM) Q 
	.	I $L($P(vobj(dbtbl1,100),$C(124),11))>12 S vRM=$$^MSG(1076,12) D vdderr("PTRTIMU",vRM) Q 
	.	I $L($P(vobj(dbtbl1,100),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("PTRTLD",vRM) Q 
	.	I $L($P(vobj(dbtbl1,100),$C(124),10))>12 S vRM=$$^MSG(1076,12) D vdderr("PTRTLDU",vRM) Q 
	.	I $L($P(vobj(dbtbl1,100),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("PTRUSER",vRM) Q 
	.	I $L($P(vobj(dbtbl1,100),$C(124),9))>12 S vRM=$$^MSG(1076,12) D vdderr("PTRUSERU",vRM) Q 
	.	S X=$P(vobj(dbtbl1,100),$C(124),2) I '(X=""),'(",0,1,10,11,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("RECTYP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,101))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,101)) vobj(dbtbl1,101)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),101)),1:"")
	.	I $L($P(vobj(dbtbl1,101),$C(124),1))>450 S vRM=$$^MSG(1076,450) D vdderr("LISTDFT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl1,102))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl1,102)) vobj(dbtbl1,102)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102)),1:"")
	.	I $L($P(vobj(dbtbl1,102),$C(124),1))>500 S vRM=$$^MSG(1076,500) D vdderr("LISTREQ",vRM) Q 
	.	Q 
	I $L(vobj(dbtbl1,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	S X=vobj(dbtbl1,-4) I '(X="") S vRM=$$VAL^DBSVER("U",256,1,,"X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1.FID"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	;
	I ($D(vobj(dbtbl1))#2)!'($order(vobj(dbtbl1,""))="") D
	.	;
	.	I $L($P(vobj(dbtbl1),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	.	Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1","MSG",979,"DBTBL1."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VINDEX(dbtbl1)	; Update index entries
	;
	I %O=1 D  Q 
	.	I ($D(vx("FSN"))#2) D vi1(.dbtbl1)
	.	I ($D(vx("GLOBAL"))#2) D vi2(.dbtbl1)
	.	I ($D(vx("PARFID"))#2) D vi3(.dbtbl1)
	.	I ($D(vx("UDFILE"))#2) D vi4(.dbtbl1)
	.	Q 
	D vi1(.dbtbl1)
	D vi2(.dbtbl1)
	D vi3(.dbtbl1)
	D vi4(.dbtbl1)
	;
	Q 
	;
vi1(dbtbl1)	; Maintain FSN index entries (File Short Name)
	 S:'$D(vobj(dbtbl1,12)) vobj(dbtbl1,12)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),12)),1:"")
	;
	N vdelete S vdelete=0
	N v2 S v2=vobj(dbtbl1,-3)
	N v3 S v3=$P(vobj(dbtbl1,12),$C(124),1)
	I (v3="") S v3=$char(254)
	N v4 S v4=vobj(dbtbl1,-4)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if '$D(^XDBREF("DBTBL1.FSN",v2,v3,v4)) do vidxerr("FSN")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^XDBREF("DBTBL1.FSN",v2,v3,v4)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("FSN"))#2) S v3=$piece(vx("FSN"),"|",1) S:(v3="") v3=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^XDBREF("DBTBL1.FSN",v2,v3,v4)
	;*** End of code by-passed by compiler ***
	Q 
	;
vi2(dbtbl1)	; Maintain GLOBAL index entries (Global Name)
	 S:'$D(vobj(dbtbl1,0)) vobj(dbtbl1,0)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0)),1:"")
	;
	N vdelete S vdelete=0
	N v2 S v2=vobj(dbtbl1,-3)
	N v3 S v3=$P(vobj(dbtbl1,0),$C(124),1)
	I (v3="") S v3=$char(254)
	N v4 S v4=vobj(dbtbl1,-4)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if '$D(^XDBREF("DBTBL1.GLOBAL",v2,v3,v4)) do vidxerr("GLOBAL")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^XDBREF("DBTBL1.GLOBAL",v2,v3,v4)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("GLOBAL"))#2) S v3=$piece(vx("GLOBAL"),"|",1) S:(v3="") v3=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^XDBREF("DBTBL1.GLOBAL",v2,v3,v4)
	;*** End of code by-passed by compiler ***
	Q 
	;
vi3(dbtbl1)	; Maintain PARFID index entries (Inheritance Filename)
	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	;
	N vdelete S vdelete=0
	N v1 S v1=vobj(dbtbl1,-3)
	N v3 S v3=$P(vobj(dbtbl1,10),$C(124),4)
	I (v3="") S v3=$char(254)
	N v4 S v4=vobj(dbtbl1,-4)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if '$D(^DBINDX(v1,"PARFID",v3,v4)) do vidxerr("PARFID")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^DBINDX(v1,"PARFID",v3,v4)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("PARFID"))#2) S v3=$piece(vx("PARFID"),"|",1) S:(v3="") v3=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBINDX(v1,"PARFID",v3,v4)
	;*** End of code by-passed by compiler ***
	Q 
	;
vi4(dbtbl1)	; Maintain UDFILE index entries (Record Filer Routine)
	 S:'$D(vobj(dbtbl1,99)) vobj(dbtbl1,99)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),99)),1:"")
	;
	N vdelete S vdelete=0
	N v2 S v2=vobj(dbtbl1,-3)
	N v3 S v3=$P(vobj(dbtbl1,99),$C(124),2)
	I (v3="") S v3=$char(254)
	N v4 S v4=vobj(dbtbl1,-4)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if '$D(^XDBREF("DBTBL1.UDFILE",v2,v3,v4)) do vidxerr("UDFILE")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^XDBREF("DBTBL1.UDFILE",v2,v3,v4)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("UDFILE"))#2) S v3=$piece(vx("UDFILE"),"|",1) S:(v3="") v3=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^XDBREF("DBTBL1.UDFILE",v2,v3,v4)
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
	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	N dbtbl1 S dbtbl1=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2))
	.	I ((","_vlist_",")[",VINDEX,") D VINDEX(.dbtbl1) K vobj(+$G(dbtbl1)) Q 
	.	I ((","_vlist_",")[",FSN,") D vi1(.dbtbl1)
	.	I ((","_vlist_",")[",GLOBAL,") D vi2(.dbtbl1)
	.	I ((","_vlist_",")[",PARFID,") D vi3(.dbtbl1)
	.	I ((","_vlist_",")[",UDFILE,") D vi4(.dbtbl1)
	.	K vobj(+$G(dbtbl1)) Q 
	;
	Q 
	;
VIDXBLD1(dbtbl1,vlist)	; Rebuild index files for one record (External call)
	;
	N i
	;
	I ((","_vlist_",")[",VINDEX,") D VINDEX(.dbtbl1) Q 
	I ((","_vlist_",")[",FSN,") D vi1(.dbtbl1)
	I ((","_vlist_",")[",GLOBAL,") D vi2(.dbtbl1)
	I ((","_vlist_",")[",PARFID,") D vi3(.dbtbl1)
	I ((","_vlist_",")[",UDFILE,") D vi4(.dbtbl1)
	;
	Q 
	;
vidxerr(di)	; Error message
	;
	D SETERR^DBSEXECU("DBTBL1","MSG",1225,"DBTBL1."_di)
	;
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
	I ($D(vx("%LIBS"))#2) S vux("%LIBS")=vx("%LIBS")
	I ($D(vx("FID"))#2) S vux("FID")=vx("FID")
	D vkey(1) S voldkey=vobj(dbtbl1,-3)_","_vobj(dbtbl1,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	D vload ; Make sure all data is loaded locally
	I vpar["/VALREQ/" D vrequ
	I vpar["/TRIGBEF/" D VBU
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl1,-3)_","_vobj(dbtbl1,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl1)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(vnewrec,"/NOCASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/",1) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL1",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	S vpar=voldpar
	I vpar["/TRIGAFT/" D VAU
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl1,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("FID"))#2) S vobj(dbtbl1,-4)=$piece(vux("FID"),"|",i)
	Q 
	;
VCASDEL	; Cascade delete logic
	;
	 N V1,V2 S V1=vobj(dbtbl1,-3),V2=vobj(dbtbl1,-4) D vDbDe3() ; Cascade delete
	;
	 N V3,V4 S V3=vobj(dbtbl1,-3),V4=vobj(dbtbl1,-4) D vDbDe4() ; Cascade delete
	;
	 N V5,V6 S V5=vobj(dbtbl1,-3),V6=vobj(dbtbl1,-4) D vDbDe5() ; Cascade delete
	;
	 N V7,V8 S V7=vobj(dbtbl1,-3),V8=vobj(dbtbl1,-4) D vDbDe6() ; Cascade delete
	;
	 N V9,V10 S V9=vobj(dbtbl1,-3),V10=vobj(dbtbl1,-4) D vDbDe7() ; Cascade delete
	;
	 N V11,V12 S V11=vobj(dbtbl1,-3),V12=vobj(dbtbl1,-4) D vDbDe8() ; Cascade delete
	;
	Q 
	;
VIDXPGM()	;
	Q "DBSDF1F" ; Location of index program
	;
	;  #OPTION ResultClass 0
vUpd1	;
	N updset,vos1,vos2 S updset=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	N updRow S updRow=$$vDb3($P(updset,$C(9),1),$P(updset,$C(9),2))
	.	 S vobj(updRow,100)=$G(^DBTBL(vobj(updRow,-3),1,vobj(updRow,-4),100))
	. S:'$D(vobj(updRow,-100,100,"GLREF")) vobj(updRow,-100,100,"GLREF")="T001"_$P(vobj(updRow,100),$C(124),1) S vobj(updRow,-100,100)="",$P(vobj(updRow,100),$C(124),1)=GBLREF
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(updRow,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(updRow,-100) S vobj(updRow,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(updRow)) Q 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND DI=:KEYNAME
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb2("SYSDEV",FID,KEYNAME)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBSDFF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3 S vDs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	N vRec S vRec=$$vDb2($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSDFF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM DBTBL1D WHERE %LIBS=:V1 AND FID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	N vRec S vRec=$$vDb2($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSDFF(vRec,$$initPar^UCUTILN(vpar),1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe4()	; DELETE FROM DBTBL1F WHERE %LIBS=:V3 AND FID=:V4
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	N vRec S vRec=$$vDb4($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSDFKF(vRec,$$initPar^UCUTILN(vpar),1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe5()	; DELETE FROM DBTBL1F WHERE %LIBS=:V5 AND TBLREF=:V6
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4,vos5 S vDs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	N vRec S vRec=$$vDb4($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSDFKF(vRec,$$initPar^UCUTILN(vpar),1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe6()	; DELETE FROM DBTBL7 WHERE %LIBS=:V7 AND TABLE=:V8
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	N vRec S vRec=$$vDb5($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBTBL7FL(vRec,$$initPar^UCUTILN(vpar),1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe7()	; DELETE FROM DBTBL8 WHERE %LIBS=:V9 AND FID=:V10
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen8()
	F  Q:'($$vFetch8())  D
	.	N vRec S vRec=$$vDb6($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSINDXF(vRec,$$initPar^UCUTILN(vpar),1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe8()	; DELETE FROM DBTBL9 WHERE %LIBS=:V11 AND PRITABLE=:V12
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen9()
	F  Q:'($$vFetch9())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,9,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2,9,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2,9,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1F,,1)
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
vDb5(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL7,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7"
	S vobj(vOid)=$G(^DBTBL(v1,7,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,7,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb6(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL8,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8"
	S vobj(vOid)=$G(^DBTBL(v1,8,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,8,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL1D)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	%LIBS,FID FROM DBTBL1
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
vL1a4	S vos3=$O(^DBTBL(vos2,1,vos3),1) I vos3="" G vL1a2
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	%LIBS,FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FID) I vos2="" G vL2a0
	I '($D(^DBTBL("SYSDEV",1,vos2))) G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S updset="SYSDEV"_$C(9)_vos2
	S vos1=0
	;
	Q 1
	;
vOpen3()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(FID) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS=:V1 AND FID=:V2
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V1) I vos2="" G vL4a0
	S vos3=$G(V2) I vos3="" G vL4a0
	S vos4=""
vL4a4	S vos4=$O(^DBTBL(vos2,1,vos3,9,vos4),1) I vos4="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen5()	;	%LIBS,FID,FKEYS FROM DBTBL1F WHERE %LIBS=:V3 AND FID=:V4
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V3) I vos2="" G vL5a0
	S vos3=$G(V4) I vos3="" G vL5a0
	S vos4=""
vL5a4	S vos4=$O(^DBTBL(vos2,19,vos3,vos4),1) I vos4="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen6()	;	%LIBS,FID,FKEYS FROM DBTBL1F WHERE %LIBS=:V5 AND TBLREF=:V6
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V5) I vos2="" G vL6a0
	S vos3=$G(V6) I vos3="",'$D(V6) G vL6a0
	S vos4=""
vL6a4	S vos4=$O(^DBINDX(vos2,"FKPTR",vos3,vos4),1) I vos4="" G vL6a0
	S vos5=""
vL6a6	S vos5=$O(^DBINDX(vos2,"FKPTR",vos3,vos4,vos5),1) I vos5="" G vL6a4
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen7()	;	%LIBS,TABLE,TRGID FROM DBTBL7 WHERE %LIBS=:V7 AND TABLE=:V8
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(V7) I vos2="" G vL7a0
	S vos3=$G(V8) I vos3="" G vL7a0
	S vos4=""
vL7a4	S vos4=$O(^DBTBL(vos2,7,vos3,vos4),1) I vos4="" G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen8()	;	%LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS=:V9 AND FID=:V10
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(V9) I vos2="" G vL8a0
	S vos3=$G(V10) I vos3="" G vL8a0
	S vos4=""
vL8a4	S vos4=$O(^DBTBL(vos2,8,vos3,vos4),1) I vos4="" G vL8a0
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen9()	;	%LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS=:V11 AND PRITABLE=:V12
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(V11) I vos2="" G vL9a0
	S vos3=$G(V12) I vos3="" G vL9a0
	S vos4=""
vL9a4	S vos4=$O(^DBTBL(vos2,9,vos3,vos4),1) I vos4="" G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL1.copy: DBTBL1
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=0,1,2,3,4,5,6,7,10,12,13,14,16,22,99,100,101,102 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),1,vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
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
