DBSDOMF(dbsdom,vpar,vparNorm)	; DBSDOM - User-Defined Data Types Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBSDOM ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (38)             06/09/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbsdom,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbsdom,.vxins,10,"|")
	I %O=1 Q:'$D(vobj(dbsdom,-100))  D AUDIT^UCUTILN(dbsdom,.vx,10,"|")
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
	.	I ($D(vx("SYSSN"))#2)!($D(vx("DOM"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBSDOM",.vx)
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
	.	  N V1,V2 S V1=vobj(dbsdom,-3),V2=vobj(dbsdom,-4) Q:'($D(^DBCTL("SYS","DOM",V1,V2))>9)  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbsdom S dbsdom=$$vDb1(SYSSN,DOM)
	I (%O=2) D
	.	S vobj(dbsdom,-2)=2
	.	;
	.	D DBSDOMF(dbsdom,vpar)
	.	Q 
	;
	K vobj(+$G(dbsdom)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(dbsdom,-3),V2=vobj(dbsdom,-4) I '(''($D(^DBCTL("SYS","DOM",V1,V2))>9)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(dbsdom,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(dbsdom,%O,.vx)
	.	;
	.	N n S n=-1
	.	N x
	.	;
	.	I %O=0 F  S n=$order(vobj(dbsdom,n)) Q:(n="")  D
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),n)=vobj(dbsdom,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	E  F  S n=$order(vobj(dbsdom,-100,n)) Q:(n="")  D
	..		Q:'$D(vobj(dbsdom,n)) 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),n)=vobj(dbsdom,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	Q 
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
	for  set n=$order(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),n)) quit:n=""  if '$D(vobj(dbsdom,n)),$D(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),n))#2 set vobj(dbsdom,n)=^(n)
	;*** End of code by-passed by compiler ***
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I '$get(vkeychg),$D(vobj(dbsdom,-100)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,Deleted object cannot be modified" X $ZT
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(dbsdom,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	 S:'$D(vobj(dbsdom,0)) vobj(dbsdom,0)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),0)),1:"")
	I ($P(vobj(dbsdom,0),$C(124),19)="") S vobj(dbsdom,-100,0)="",$P(vobj(dbsdom,0),$C(124),19)=+$H ; ltd
	 S:'$D(vobj(dbsdom,1)) vobj(dbsdom,1)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),1)),1:"")
	I ($P(vobj(dbsdom,1),$C(124),15)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),15)=0 ; prdec
	I ($P(vobj(dbsdom,1),$C(124),1)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),1)=0 ; prdes
	I ($P(vobj(dbsdom,1),$C(124),14)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),14)=0 ; prdft
	I ($P(vobj(dbsdom,1),$C(124),12)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),12)=0 ; pripf
	I ($P(vobj(dbsdom,1),$C(124),3)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),3)=1 ; prlen
	I ($P(vobj(dbsdom,1),$C(124),9)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),9)=0 ; prmax
	I ($P(vobj(dbsdom,1),$C(124),8)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),8)=0 ; prmin
	I ($P(vobj(dbsdom,1),$C(124),17)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),17)=0 ; prmsk
	I ($P(vobj(dbsdom,1),$C(124),16)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),16)=0 ; prmsu
	I ($P(vobj(dbsdom,1),$C(124),7)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),7)=0 ; prnlv
	I ($P(vobj(dbsdom,1),$C(124),11)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),11)=0 ; propf
	I ($P(vobj(dbsdom,1),$C(124),10)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),10)=0 ; prptn
	I ($P(vobj(dbsdom,1),$C(124),6)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),6)=0 ; prrhd
	I ($P(vobj(dbsdom,1),$C(124),4)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),4)=0 ; prsiz
	I ($P(vobj(dbsdom,1),$C(124),5)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),5)=0 ; prtbl
	I ($P(vobj(dbsdom,1),$C(124),2)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),2)=1 ; prtyp
	I ($P(vobj(dbsdom,1),$C(124),13)="") S vobj(dbsdom,-100,1)="",$P(vobj(dbsdom,1),$C(124),13)=0 ; prvld
	I ($P(vobj(dbsdom,0),$C(124),20)="") S vobj(dbsdom,-100,0)="",$P(vobj(dbsdom,0),$C(124),20)=$$USERNAM^%ZFUNC ; user
	Q 
	;
vreqn	; Validate required data items
	;
	 S:'$D(vobj(dbsdom,0)) vobj(dbsdom,0)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),0)),1:"")
	I ($P(vobj(dbsdom,0),$C(124),1)="") D vreqerr("DES") Q 
	 S:'$D(vobj(dbsdom,1)) vobj(dbsdom,1)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),1)),1:"")
	I ($P(vobj(dbsdom,1),$C(124),15)="") D vreqerr("PRDEC") Q 
	I ($P(vobj(dbsdom,1),$C(124),1)="") D vreqerr("PRDES") Q 
	I ($P(vobj(dbsdom,1),$C(124),14)="") D vreqerr("PRDFT") Q 
	I ($P(vobj(dbsdom,1),$C(124),12)="") D vreqerr("PRIPF") Q 
	I ($P(vobj(dbsdom,1),$C(124),3)="") D vreqerr("PRLEN") Q 
	I ($P(vobj(dbsdom,1),$C(124),9)="") D vreqerr("PRMAX") Q 
	I ($P(vobj(dbsdom,1),$C(124),8)="") D vreqerr("PRMIN") Q 
	I ($P(vobj(dbsdom,1),$C(124),17)="") D vreqerr("PRMSK") Q 
	I ($P(vobj(dbsdom,1),$C(124),16)="") D vreqerr("PRMSU") Q 
	I ($P(vobj(dbsdom,1),$C(124),7)="") D vreqerr("PRNLV") Q 
	I ($P(vobj(dbsdom,1),$C(124),11)="") D vreqerr("PROPF") Q 
	I ($P(vobj(dbsdom,1),$C(124),10)="") D vreqerr("PRPTN") Q 
	I ($P(vobj(dbsdom,1),$C(124),6)="") D vreqerr("PRRHD") Q 
	I ($P(vobj(dbsdom,1),$C(124),4)="") D vreqerr("PRSIZ") Q 
	I ($P(vobj(dbsdom,1),$C(124),5)="") D vreqerr("PRTBL") Q 
	I ($P(vobj(dbsdom,1),$C(124),2)="") D vreqerr("PRTYP") Q 
	I ($P(vobj(dbsdom,1),$C(124),13)="") D vreqerr("PRVLD") Q 
	I ($P(vobj(dbsdom,0),$C(124),2)="") D vreqerr("TYP") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbsdom,-3)="") D vreqerr("SYSSN") Q 
	I (vobj(dbsdom,-4)="") D vreqerr("DOM") Q 
	;
	I '($order(vobj(dbsdom,-100,0,""))="") D
	.	 S:'$D(vobj(dbsdom,0)) vobj(dbsdom,0)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),0)),1:"")
	.	I ($D(vx("DES"))#2),($P(vobj(dbsdom,0),$C(124),1)="") D vreqerr("DES") Q 
	.	I ($D(vx("TYP"))#2),($P(vobj(dbsdom,0),$C(124),2)="") D vreqerr("TYP") Q 
	.	Q 
	I '($order(vobj(dbsdom,-100,1,""))="") D
	.	 S:'$D(vobj(dbsdom,1)) vobj(dbsdom,1)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),1)),1:"")
	.	I ($D(vx("PRDES"))#2),($P(vobj(dbsdom,1),$C(124),1)="") D vreqerr("PRDES") Q 
	.	I ($D(vx("PRTYP"))#2),($P(vobj(dbsdom,1),$C(124),2)="") D vreqerr("PRTYP") Q 
	.	I ($D(vx("PRLEN"))#2),($P(vobj(dbsdom,1),$C(124),3)="") D vreqerr("PRLEN") Q 
	.	I ($D(vx("PRSIZ"))#2),($P(vobj(dbsdom,1),$C(124),4)="") D vreqerr("PRSIZ") Q 
	.	I ($D(vx("PRTBL"))#2),($P(vobj(dbsdom,1),$C(124),5)="") D vreqerr("PRTBL") Q 
	.	I ($D(vx("PRRHD"))#2),($P(vobj(dbsdom,1),$C(124),6)="") D vreqerr("PRRHD") Q 
	.	I ($D(vx("PRNLV"))#2),($P(vobj(dbsdom,1),$C(124),7)="") D vreqerr("PRNLV") Q 
	.	I ($D(vx("PRMIN"))#2),($P(vobj(dbsdom,1),$C(124),8)="") D vreqerr("PRMIN") Q 
	.	I ($D(vx("PRMAX"))#2),($P(vobj(dbsdom,1),$C(124),9)="") D vreqerr("PRMAX") Q 
	.	I ($D(vx("PRPTN"))#2),($P(vobj(dbsdom,1),$C(124),10)="") D vreqerr("PRPTN") Q 
	.	I ($D(vx("PROPF"))#2),($P(vobj(dbsdom,1),$C(124),11)="") D vreqerr("PROPF") Q 
	.	I ($D(vx("PRIPF"))#2),($P(vobj(dbsdom,1),$C(124),12)="") D vreqerr("PRIPF") Q 
	.	I ($D(vx("PRVLD"))#2),($P(vobj(dbsdom,1),$C(124),13)="") D vreqerr("PRVLD") Q 
	.	I ($D(vx("PRDFT"))#2),($P(vobj(dbsdom,1),$C(124),14)="") D vreqerr("PRDFT") Q 
	.	I ($D(vx("PRDEC"))#2),($P(vobj(dbsdom,1),$C(124),15)="") D vreqerr("PRDEC") Q 
	.	I ($D(vx("PRMSU"))#2),($P(vobj(dbsdom,1),$C(124),16)="") D vreqerr("PRMSU") Q 
	.	I ($D(vx("PRMSK"))#2),($P(vobj(dbsdom,1),$C(124),17)="") D vreqerr("PRMSK") Q 
	.	Q 
	 S:'$D(vobj(dbsdom,0)) vobj(dbsdom,0)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),0)),1:"")
	I ($D(vx("DES"))#2),($P(vobj(dbsdom,0),$C(124),1)="") D vreqerr("DES") Q 
	 S:'$D(vobj(dbsdom,1)) vobj(dbsdom,1)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),1)),1:"")
	I ($D(vx("PRDEC"))#2),($P(vobj(dbsdom,1),$C(124),15)="") D vreqerr("PRDEC") Q 
	I ($D(vx("PRDES"))#2),($P(vobj(dbsdom,1),$C(124),1)="") D vreqerr("PRDES") Q 
	I ($D(vx("PRDFT"))#2),($P(vobj(dbsdom,1),$C(124),14)="") D vreqerr("PRDFT") Q 
	I ($D(vx("PRIPF"))#2),($P(vobj(dbsdom,1),$C(124),12)="") D vreqerr("PRIPF") Q 
	I ($D(vx("PRLEN"))#2),($P(vobj(dbsdom,1),$C(124),3)="") D vreqerr("PRLEN") Q 
	I ($D(vx("PRMAX"))#2),($P(vobj(dbsdom,1),$C(124),9)="") D vreqerr("PRMAX") Q 
	I ($D(vx("PRMIN"))#2),($P(vobj(dbsdom,1),$C(124),8)="") D vreqerr("PRMIN") Q 
	I ($D(vx("PRMSK"))#2),($P(vobj(dbsdom,1),$C(124),17)="") D vreqerr("PRMSK") Q 
	I ($D(vx("PRMSU"))#2),($P(vobj(dbsdom,1),$C(124),16)="") D vreqerr("PRMSU") Q 
	I ($D(vx("PRNLV"))#2),($P(vobj(dbsdom,1),$C(124),7)="") D vreqerr("PRNLV") Q 
	I ($D(vx("PROPF"))#2),($P(vobj(dbsdom,1),$C(124),11)="") D vreqerr("PROPF") Q 
	I ($D(vx("PRPTN"))#2),($P(vobj(dbsdom,1),$C(124),10)="") D vreqerr("PRPTN") Q 
	I ($D(vx("PRRHD"))#2),($P(vobj(dbsdom,1),$C(124),6)="") D vreqerr("PRRHD") Q 
	I ($D(vx("PRSIZ"))#2),($P(vobj(dbsdom,1),$C(124),4)="") D vreqerr("PRSIZ") Q 
	I ($D(vx("PRTBL"))#2),($P(vobj(dbsdom,1),$C(124),5)="") D vreqerr("PRTBL") Q 
	I ($D(vx("PRTYP"))#2),($P(vobj(dbsdom,1),$C(124),2)="") D vreqerr("PRTYP") Q 
	I ($D(vx("PRVLD"))#2),($P(vobj(dbsdom,1),$C(124),13)="") D vreqerr("PRVLD") Q 
	I ($D(vx("TYP"))#2),($P(vobj(dbsdom,0),$C(124),2)="") D vreqerr("TYP") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBSDOM","MSG",1767,"DBSDOM."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I (%O=2) D vload
	;
	I ($D(vobj(dbsdom,0))#2) D
	.	;
	.	 S:'$D(vobj(dbsdom,0)) vobj(dbsdom,0)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),0)),1:"")
	.	S X=$P(vobj(dbsdom,0),$C(124),15) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("DEC",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),14))>58 S vRM=$$^MSG(1076,58) D vdderr("DFT",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),12))>40 S vRM=$$^MSG(1076,40) D vdderr("IPF",vRM) Q 
	.	S X=$P(vobj(dbsdom,0),$C(124),3) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("LEN",vRM) Q 
	.	S X=$P(vobj(dbsdom,0),$C(124),19) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),9))>25 S vRM=$$^MSG(1076,25) D vdderr("MAX",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),8))>25 S vRM=$$^MSG(1076,25) D vdderr("MIN",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),17))>20 S vRM=$$^MSG(1076,20) D vdderr("MSK",vRM) Q 
	.	S X=$P(vobj(dbsdom,0),$C(124),16) I '(X=""),'(",C,D,V,W,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("MSU",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),7))>20 S vRM=$$^MSG(1076,20) D vdderr("NLV",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),11))>40 S vRM=$$^MSG(1076,40) D vdderr("OPF",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),10))>60 S vRM=$$^MSG(1076,60) D vdderr("PTN",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),6))>40 S vRM=$$^MSG(1076,40) D vdderr("RHD",vRM) Q 
	.	S X=$P(vobj(dbsdom,0),$C(124),4) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("SIZ",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),5))>255 S vRM=$$^MSG(1076,255) D vdderr("TBL",vRM) Q 
	.	S X=$P(vobj(dbsdom,0),$C(124),2) I '(X=""),'($D(^DBCTL("SYS","DVFM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TYP",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),20))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	.	I $L($P(vobj(dbsdom,0),$C(124),13))>70 S vRM=$$^MSG(1076,70) D vdderr("VLD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbsdom,1))#2) D
	.	;
	.	 S:'$D(vobj(dbsdom,1)) vobj(dbsdom,1)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),1)),1:"")
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),15)) S vRM=$$^MSG(742,"L") D vdderr("PRDEC",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("PRDES",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("PRDFT",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),12)) S vRM=$$^MSG(742,"L") D vdderr("PRIPF",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("PRLEN",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),9)) S vRM=$$^MSG(742,"L") D vdderr("PRMAX",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),8)) S vRM=$$^MSG(742,"L") D vdderr("PRMIN",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),17)) S vRM=$$^MSG(742,"L") D vdderr("PRMSK",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),16)) S vRM=$$^MSG(742,"L") D vdderr("PRMSU",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("PRNLV",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),11)) S vRM=$$^MSG(742,"L") D vdderr("PROPF",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),10)) S vRM=$$^MSG(742,"L") D vdderr("PRPTN",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("PRRHD",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("PRSIZ",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("PRTBL",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("PRTYP",vRM) Q 
	.	I '("01"[$P(vobj(dbsdom,1),$C(124),13)) S vRM=$$^MSG(742,"L") D vdderr("PRVLD",vRM) Q 
	.	Q 
	S X=vobj(dbsdom,-3) I '(X=""),'($D(^SCATBL(2,X))#2) S vRM=$$^MSG(1485,X) D vdderr("SYSSN",vRM) Q 
	I $L(vobj(dbsdom,-4))>20 S vRM=$$^MSG(1076,20) D vdderr("DOM",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBSDOM","MSG",979,"DBSDOM."_di_" "_vRM)
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
	I ($D(vx("SYSSN"))#2) S vux("SYSSN")=vx("SYSSN")
	I ($D(vx("DOM"))#2) S vux("DOM")=vx("DOM")
	D vkey(1) S voldkey=vobj(dbsdom,-3)_","_vobj(dbsdom,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	D vload ; Make sure all data is loaded locally
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbsdom,-3)_","_vobj(dbsdom,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbsdom)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBSDOM",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("SYSSN"))#2) S vobj(dbsdom,-3)=$piece(vux("SYSSN"),"|",i)
	I ($D(vux("DOM"))#2) S vobj(dbsdom,-4)=$piece(vux("DOM"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBSDOM,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBSDOM"
	I '$D(^DBCTL("SYS","DOM",v1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBSDOM" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordDBSDOM.copy: DBSDOM
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=0,1 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBCTL("SYS","DOM",vobj(v1,-3),vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordDBSDOM saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	N vD,vN S vN=-1
	I '$G(vobj(vnewrec,-2)) F  S vN=$O(vobj(vnewrec,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBCTL("SYS","DOM",vobj(vnewrec,-3),vobj(vnewrec,-4),vN)=vD
	E  F  S vN=$O(vobj(vnewrec,-100,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBCTL("SYS","DOM",vobj(vnewrec,-3),vobj(vnewrec,-4),vN)=vD I vD="" ZWI ^DBCTL("SYS","DOM",vobj(vnewrec,-3),vobj(vnewrec,-4),vN)
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
