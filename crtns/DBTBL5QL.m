DBTBL5QL(dbtbl5q,vpar,vparNorm)	; DBTBL5Q - QWIK Report Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL5Q ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (36)             09/20/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl5q,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl5q,.vxins,11,"|")
	I %O=1 Q:'$D(vobj(dbtbl5q,-100))  D AUDIT^UCUTILN(dbtbl5q,.vx,11,"|")
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("QRID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL5Q",.vx)
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
	.	  N V1,V2 S V1=vobj(dbtbl5q,-3),V2=vobj(dbtbl5q,-4) Q:'($D(^DBTBL(V1,6,V2)))  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl5q S dbtbl5q=$$vDb1(LIBS,QRID)
	I (%O=2) D
	.	S vobj(dbtbl5q,-2)=2
	.	;
	.	D DBTBL5QL(dbtbl5q,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl5q)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(dbtbl5q,-3),V2=vobj(dbtbl5q,-4) I '(''($D(^DBTBL(V1,6,V2)))=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	N n S n=-1
	.	N x
	.	;
	.	I %O=0 F  S n=$order(vobj(dbtbl5q,n)) Q:(n="")  D
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),n)=vobj(dbtbl5q,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	E  F  S n=$order(vobj(dbtbl5q,-100,n)) Q:(n="")  D
	..		Q:'$D(vobj(dbtbl5q,n)) 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),n)=vobj(dbtbl5q,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl5q)) S ^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4))=vobj(dbtbl5q)
	.	;*** End of code by-passed by compiler ***
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
	for  set n=$order(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),n)) quit:n=""  if '$D(vobj(dbtbl5q,n)),$D(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),n))#2 set vobj(dbtbl5q,n)=^(n)
	;*** End of code by-passed by compiler ***
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I '$get(vkeychg),$D(vobj(dbtbl5q,-100)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,Deleted object cannot be modified" X $ZT
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	 S:'$D(vobj(dbtbl5q,0)) vobj(dbtbl5q,0)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0)),1:"")
	I ($P(vobj(dbtbl5q,0),$C(124),12)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),12)=1 ; banner
	I ($P(vobj(dbtbl5q,0),$C(124),14)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),14)=1 ; cscmp
	I ($P(vobj(dbtbl5q,0),$C(124),4)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),4)=1 ; dtl
	I ($P(vobj(dbtbl5q,0),$C(124),3)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),3)=+$piece(($H),",",1) ; ltd
	I ($P(vobj(dbtbl5q,0),$C(124),13)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),13)=0 ; msql
	I ($P(vobj(dbtbl5q,0),$C(124),5)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),5)=80 ; rsize
	I ($P(vobj(dbtbl5q,0),$C(124),8)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),8)=0 ; stat
	I ($P(vobj(dbtbl5q,0),$C(124),15)="") S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),15)=$$USERNAM^%ZFUNC ; uid
	Q 
	;
vreqn	; Validate required data items
	;
	 S:'$D(vobj(dbtbl5q,0)) vobj(dbtbl5q,0)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0)),1:"")
	I ($P(vobj(dbtbl5q,0),$C(124),12)="") D vreqerr("BANNER") Q 
	I ($P(vobj(dbtbl5q,0),$C(124),14)="") D vreqerr("CSCMP") Q 
	I ($P(vobj(dbtbl5q,0),$C(124),4)="") D vreqerr("DTL") Q 
	I ($P(vobj(dbtbl5q,0),$C(124),13)="") D vreqerr("MSQL") Q 
	I ($P(vobj(dbtbl5q,0),$C(124),8)="") D vreqerr("STAT") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl5q,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl5q,-4)="") D vreqerr("QRID") Q 
	;
	I '($order(vobj(dbtbl5q,-100,0,""))="") D
	.	 S:'$D(vobj(dbtbl5q,0)) vobj(dbtbl5q,0)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0)),1:"")
	.	I ($D(vx("DTL"))#2),($P(vobj(dbtbl5q,0),$C(124),4)="") D vreqerr("DTL") Q 
	.	I ($D(vx("STAT"))#2),($P(vobj(dbtbl5q,0),$C(124),8)="") D vreqerr("STAT") Q 
	.	I ($D(vx("BANNER"))#2),($P(vobj(dbtbl5q,0),$C(124),12)="") D vreqerr("BANNER") Q 
	.	I ($D(vx("MSQL"))#2),($P(vobj(dbtbl5q,0),$C(124),13)="") D vreqerr("MSQL") Q 
	.	I ($D(vx("CSCMP"))#2),($P(vobj(dbtbl5q,0),$C(124),14)="") D vreqerr("CSCMP") Q 
	.	Q 
	 S:'$D(vobj(dbtbl5q,0)) vobj(dbtbl5q,0)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0)),1:"")
	I ($D(vx("BANNER"))#2),($P(vobj(dbtbl5q,0),$C(124),12)="") D vreqerr("BANNER") Q 
	I ($D(vx("CSCMP"))#2),($P(vobj(dbtbl5q,0),$C(124),14)="") D vreqerr("CSCMP") Q 
	I ($D(vx("DTL"))#2),($P(vobj(dbtbl5q,0),$C(124),4)="") D vreqerr("DTL") Q 
	I ($D(vx("MSQL"))#2),($P(vobj(dbtbl5q,0),$C(124),13)="") D vreqerr("MSQL") Q 
	I ($D(vx("STAT"))#2),($P(vobj(dbtbl5q,0),$C(124),8)="") D vreqerr("STAT") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5Q","MSG",1767,"DBTBL5Q."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I (%O=2) D vload
	;
	I ($D(vobj(dbtbl5q,0))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,0)) vobj(dbtbl5q,0)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0)),1:"")
	.	I '("01"[$P(vobj(dbtbl5q,0),$C(124),12)) S vRM=$$^MSG(742,"L") D vdderr("BANNER",vRM) Q 
	.	I $L($P(vobj(dbtbl5q,0),$C(124),11))>60 S vRM=$$^MSG(1076,60) D vdderr("BREAKON",vRM) Q 
	.	S X=$P(vobj(dbtbl5q,0),$C(124),7) I '(X=""),X'?1.8N,X'?1"-"1.7N S vRM=$$^MSG(742,"N") D vdderr("CNTMATCH",vRM) Q 
	.	S X=$P(vobj(dbtbl5q,0),$C(124),6) I '(X=""),X'?1.8N,X'?1"-"1.7N S vRM=$$^MSG(742,"N") D vdderr("CNTREC",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5q,0),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("CSCMP",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5q,0),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("DTL",vRM) Q 
	.	S X=$P(vobj(dbtbl5q,0),$C(124),9) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("LABOPT",vRM) Q 
	.	S X=$P(vobj(dbtbl5q,0),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5q,0),$C(124),13)) S vRM=$$^MSG(742,"L") D vdderr("MSQL",vRM) Q 
	.	I $L($P(vobj(dbtbl5q,0),$C(124),10))>100 S vRM=$$^MSG(1076,100) D vdderr("ORDERBY",vRM) Q 
	.	I $L($P(vobj(dbtbl5q,0),$C(124),1))>60 S vRM=$$^MSG(1076,60) D vdderr("PFID",vRM) Q 
	.	I $L($P(vobj(dbtbl5q,0),$C(124),2))>8 S vRM=$$^MSG(1076,8) D vdderr("PGM",vRM) Q 
	.	I $L($P(vobj(dbtbl5q,0),$C(124),20))>6 S vRM=$$^MSG(1076,6) D vdderr("REPTYPE",vRM) Q 
	.	S X=$P(vobj(dbtbl5q,0),$C(124),5) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("RSIZE",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl5q,0),$C(124),8)) S vRM=$$^MSG(742,"L") D vdderr("STAT",vRM) Q 
	.	I $L($P(vobj(dbtbl5q,0),$C(124),15))>20 S vRM=$$^MSG(1076,20) D vdderr("UID",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,1))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,1)) vobj(dbtbl5q,1)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),1)),1:"")
	.	I $L($P(vobj(dbtbl5q,1),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID1",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,2))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,2)) vobj(dbtbl5q,2)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),2)),1:"")
	.	I $L($P(vobj(dbtbl5q,2),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID2",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,3))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,3)) vobj(dbtbl5q,3)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),3)),1:"")
	.	I $L($P(vobj(dbtbl5q,3),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID3",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,4))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,4)) vobj(dbtbl5q,4)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),4)),1:"")
	.	I $L($P(vobj(dbtbl5q,4),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID4",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,5))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,5)) vobj(dbtbl5q,5)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),5)),1:"")
	.	I $L($P(vobj(dbtbl5q,5),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID5",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,6))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,6)) vobj(dbtbl5q,6)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),6)),1:"")
	.	I $L($P(vobj(dbtbl5q,6),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID6",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,7))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,7)) vobj(dbtbl5q,7)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),7)),1:"")
	.	I $L($P(vobj(dbtbl5q,7),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID7",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,8))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,8)) vobj(dbtbl5q,8)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),8)),1:"")
	.	I $L($P(vobj(dbtbl5q,8),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID8",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,9))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,9)) vobj(dbtbl5q,9)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),9)),1:"")
	.	I $L($P(vobj(dbtbl5q,9),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID9",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,10))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,10)) vobj(dbtbl5q,10)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),10)),1:"")
	.	I $L($P(vobj(dbtbl5q,10),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("QID10",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,11))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,11)) vobj(dbtbl5q,11)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),11)),1:"")
	.	S X=$P(vobj(dbtbl5q,11),$C(124),1) I '(X=""),'($D(^STBL("TFMT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TRANS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,12))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,12)) vobj(dbtbl5q,12)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),12)),1:"")
	.	I $L($P(vobj(dbtbl5q,12),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("FLD1",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,13))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,13)) vobj(dbtbl5q,13)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),13)),1:"")
	.	I $L($P(vobj(dbtbl5q,13),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("FLD2",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,14))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,14)) vobj(dbtbl5q,14)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),14)),1:"")
	.	I $L($P(vobj(dbtbl5q,14),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("FLD3",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,15))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,15)) vobj(dbtbl5q,15)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),15)),1:"")
	.	I $L($P(vobj(dbtbl5q,15),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("FLD4",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,16))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,16)) vobj(dbtbl5q,16)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),16)),1:"")
	.	I $L($P(vobj(dbtbl5q,16),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("FLD5",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl5q,17))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl5q,17)) vobj(dbtbl5q,17)=$S(vobj(dbtbl5q,-2):$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),17)),1:"")
	.	I $L($P(vobj(dbtbl5q,17),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("FLD6",vRM) Q 
	.	Q 
	I $L(vobj(dbtbl5q,-3))>10 S vRM=$$^MSG(1076,10) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl5q,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("QRID",vRM) Q 
	;
	I ($D(vobj(dbtbl5q))#2)!'($order(vobj(dbtbl5q,""))="") D
	.	;
	.	I $L($P(vobj(dbtbl5q),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DESC",vRM) Q 
	.	Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL5Q","MSG",979,"DBTBL5Q."_di_" "_vRM)
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
	I ($D(vx("QRID"))#2) S vux("QRID")=vx("QRID")
	D vkey(1) S voldkey=vobj(dbtbl5q,-3)_","_vobj(dbtbl5q,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	D vload ; Make sure all data is loaded locally
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl5q,-3)_","_vobj(dbtbl5q,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl5q)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL5Q",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl5q,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("QRID"))#2) S vobj(dbtbl5q,-4)=$piece(vux("QRID"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL5Q,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5Q"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,6,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5Q" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL5Q.copy: DBTBL5Q
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),6,vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordDBTBL5Q saveNoFiler()
	;
	S ^DBTBL(vobj(vnewrec,-3),6,vobj(vnewrec,-4))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
	N vD,vN S vN=-1
	I '$G(vobj(vnewrec,-2)) F  S vN=$O(vobj(vnewrec,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBTBL(vobj(vnewrec,-3),6,vobj(vnewrec,-4),vN)=vD
	E  F  S vN=$O(vobj(vnewrec,-100,vN)) Q:vN=""  I $D(vobj(vnewrec,vN))#2 S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBTBL(vobj(vnewrec,-3),6,vobj(vnewrec,-4),vN)=vD I vD="" ZWI ^DBTBL(vobj(vnewrec,-3),6,vobj(vnewrec,-4),vN)
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
