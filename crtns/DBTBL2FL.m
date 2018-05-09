DBTBL2FL(dbtbl2,vpar,vparNorm)	; DBTBL2 - Screen Header Definition Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL2 ****
	;
	; 11/09/2007 15:18 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:18 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (61)             07/07/2006
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl2,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl2,.vxins,11,"|")
	I %O=1 Q:'$D(vobj(dbtbl2,-100))  D AUDIT^UCUTILN(dbtbl2,.vx,11,"|")
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
	.	I ($D(vx("LIBS"))#2)!($D(vx("SID"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL2",.vx)
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
	.	  N V1,V2 S V1=vobj(dbtbl2,-3),V2=vobj(dbtbl2,-4) Q:'($D(^DBTBL(V1,2,V2)))  ; No record exists
	.	D vdelete(0)
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl2 S dbtbl2=$$vDb1(LIBS,SID)
	I (%O=2) D
	.	S vobj(dbtbl2,-2)=2
	.	;
	.	D DBTBL2FL(dbtbl2,vpar)
	.	Q 
	;
	K vobj(+$G(dbtbl2)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2 S V1=vobj(dbtbl2,-3),V2=vobj(dbtbl2,-4) I '(''($D(^DBTBL(V1,2,V2)))=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	. S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),3)=$P($H,",",1)
	.	I '+$P($G(vobj(dbtbl2,-100,0,"UID")),"|",2) S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),15)=$$USERNAM^%ZFUNC
	.	N n S n=-1
	.	N x
	.	N vn
	.	;
	.	I %O=0 F  S n=$order(vobj(dbtbl2,n)) Q:(n="")  D
	..		I n="v5" D  Q 
	...			; Allow global reference and M source code
	...			;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	...			;*** Start of code by-passed by compiler
	...			S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-5)=vobj(dbtbl2,"v5")
	...			;*** End of code by-passed by compiler ***
	...			Q 
	..		I n="v1" D  Q 
	...			; Allow global reference and M source code
	...			;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	...			;*** Start of code by-passed by compiler
	...			S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1)=vobj(dbtbl2,"v1")
	...			;*** End of code by-passed by compiler ***
	...			Q 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),n)=vobj(dbtbl2,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	E  F  S n=$order(vobj(dbtbl2,-100,n)) Q:(n="")  D
	..		I n="v5" D  Q 
	...			; Allow global reference and M source code
	...			;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	...			;*** Start of code by-passed by compiler
	...			S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-5)=vobj(dbtbl2,"v5")
	...			;*** End of code by-passed by compiler ***
	...			Q 
	..		I n="v1" D  Q 
	...			; Allow global reference and M source code
	...			;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	...			;*** Start of code by-passed by compiler
	...			S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1)=vobj(dbtbl2,"v1")
	...			;*** End of code by-passed by compiler ***
	...			Q 
	..		Q:'$D(vobj(dbtbl2,n)) 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),n)=vobj(dbtbl2,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl2)) S ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4))=vobj(dbtbl2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	Q 
	;
vload	; Record Load - force loading of unloaded data
	;
	N n S n=""
	N vn
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	for  set n=$order(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),n)) quit:n=""  s vn=$S(n<0:"v"_-n,1:n) if '$D(vobj(dbtbl2,vn)),$D(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),n))#2 set vobj(dbtbl2,vn)=^(n)
	;*** End of code by-passed by compiler ***
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I '$get(vkeychg),$D(vobj(dbtbl2,-100)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,Deleted object cannot be modified" X $ZT
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I ($P(vobj(dbtbl2,0),$C(124),22)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),22)=0 ; cscmp
	I ($P(vobj(dbtbl2,0),$C(124),18)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),18)=0 ; curdsp
	I ($P(vobj(dbtbl2,0),$C(124),3)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),3)=+$H ; date
	I ($P(vobj(dbtbl2,0),$C(124),4)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),4)=0 ; norpc
	I ($P(vobj(dbtbl2,0),$C(124),17)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),17)=1 ; ooe
	I ($P(vobj(dbtbl2,0),$C(124),14)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),14)="VT220" ; outfmt
	I ($P(vobj(dbtbl2,0),$C(124),7)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),7)=0 ; repeat
	I ($P(vobj(dbtbl2,0),$C(124),5)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),5)=0 ; repreq
	I ($P(vobj(dbtbl2,0),$C(124),16)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),16)=0 ; resflg
	I ($P(vobj(dbtbl2,0),$C(124),8)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),8)=1 ; scrclr
	I ($P(vobj(dbtbl2,0),$C(124),6)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),6)=0 ; scrmod
	I ($P(vobj(dbtbl2,0),$C(124),15)="") S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),15)=$$USERNAM^%ZFUNC ; uid
	Q 
	;
vreqn	; Validate required data items
	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I ($P(vobj(dbtbl2,0),$C(124),22)="") D vreqerr("CSCMP") Q 
	I ($P(vobj(dbtbl2,0),$C(124),18)="") D vreqerr("CURDSP") Q 
	I ($P(vobj(dbtbl2,0),$C(124),4)="") D vreqerr("NORPC") Q 
	I ($P(vobj(dbtbl2,0),$C(124),17)="") D vreqerr("OOE") Q 
	I ($P(vobj(dbtbl2,0),$C(124),6)="") D vreqerr("SCRMOD") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl2,-3)="") D vreqerr("LIBS") Q 
	I (vobj(dbtbl2,-4)="") D vreqerr("SID") Q 
	;
	I '($order(vobj(dbtbl2,-100,0,""))="") D
	.	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	.	I ($D(vx("NORPC"))#2),($P(vobj(dbtbl2,0),$C(124),4)="") D vreqerr("NORPC") Q 
	.	I ($D(vx("SCRMOD"))#2),($P(vobj(dbtbl2,0),$C(124),6)="") D vreqerr("SCRMOD") Q 
	.	I ($D(vx("OOE"))#2),($P(vobj(dbtbl2,0),$C(124),17)="") D vreqerr("OOE") Q 
	.	I ($D(vx("CURDSP"))#2),($P(vobj(dbtbl2,0),$C(124),18)="") D vreqerr("CURDSP") Q 
	.	I ($D(vx("CSCMP"))#2),($P(vobj(dbtbl2,0),$C(124),22)="") D vreqerr("CSCMP") Q 
	.	Q 
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I ($D(vx("CSCMP"))#2),($P(vobj(dbtbl2,0),$C(124),22)="") D vreqerr("CSCMP") Q 
	I ($D(vx("CURDSP"))#2),($P(vobj(dbtbl2,0),$C(124),18)="") D vreqerr("CURDSP") Q 
	I ($D(vx("NORPC"))#2),($P(vobj(dbtbl2,0),$C(124),4)="") D vreqerr("NORPC") Q 
	I ($D(vx("OOE"))#2),($P(vobj(dbtbl2,0),$C(124),17)="") D vreqerr("OOE") Q 
	I ($D(vx("SCRMOD"))#2),($P(vobj(dbtbl2,0),$C(124),6)="") D vreqerr("SCRMOD") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL2","MSG",1767,"DBTBL2."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I (%O=2) D vload
	;
	I ($D(vobj(dbtbl2,-5))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl2,"v5")) vobj(dbtbl2,"v5")=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-5)),1:"")
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),5) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("BUFFERS",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v5"),$C(124),10))>40 S vRM=$$^MSG(1076,40) D vdderr("FORMHDG",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v5"),$C(124),11))>12 S vRM=$$^MSG(1076,12) D vdderr("LASTFID",vRM) Q 
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),9) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("PX",vRM) Q 
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),8) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("PY",vRM) Q 
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),13) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("RHTMAR",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v5"),$C(124),3))>1 S vRM=$$^MSG(1076,1) D vdderr("RULER",vRM) Q 
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),12) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("STATUS",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v5"),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("VIDEO",vRM) Q 
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),2) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("XORIGIN",vRM) Q 
	.	S X=$P(vobj(dbtbl2,"v5"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("YORIGIN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl2,-1))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl2,"v1")) vobj(dbtbl2,"v1")=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1)),1:"")
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK1",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),10))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK10",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),11))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK11",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),12))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK12",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),13))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK13",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),14))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK14",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),15))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK15",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),16))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK16",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),17))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK17",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),18))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK18",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),19))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK19",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK2",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),20))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK20",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),21))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK21",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),22))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK22",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),23))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK23",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),24))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK24",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),25))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK25",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),26))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK26",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),27))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK27",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),28))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK28",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK3",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK4",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),5))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK5",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),6))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK6",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),7))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK7",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),8))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK8",vRM) Q 
	.	I $L($P(vobj(dbtbl2,"v1"),$C(124),9))>12 S vRM=$$^MSG(1076,12) D vdderr("LNK9",vRM) Q 
	.	Q 
	;
	I ($D(vobj(dbtbl2,0))#2) D
	.	;
	.	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	.	S X=$P(vobj(dbtbl2,0),$C(124),11) I '(X=""),'($D(^STBL("SCASYS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("APL",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl2,0),$C(124),22)) S vRM=$$^MSG(742,"L") D vdderr("CSCMP",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl2,0),$C(124),18)) S vRM=$$^MSG(742,"L") D vdderr("CURDSP",vRM) Q 
	.	S X=$P(vobj(dbtbl2,0),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("DATE",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),9))>40 S vRM=$$^MSG(1076,40) D vdderr("DESC",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl2,0),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("NORPC",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl2,0),$C(124),17)) S vRM=$$^MSG(742,"L") D vdderr("OOE",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),14))>20 S vRM=$$^MSG(1076,20) D vdderr("OUTFMT",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),1))>60 S vRM=$$^MSG(1076,60) D vdderr("PFID",vRM) Q 
	.	S X=$P(vobj(dbtbl2,0),$C(124),13) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("PROJ",vRM) Q 
	.	S X=$P(vobj(dbtbl2,0),$C(124),7) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("REPEAT",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),5))>2 S vRM=$$^MSG(1076,2) D vdderr("REPREQ",vRM) Q 
	.	S X=$P(vobj(dbtbl2,0),$C(124),16) I '(X=""),'($D(^DBCTL("SYS","RESFLG",X))#2) S vRM=$$^MSG(1485,X) D vdderr("RESFLG",vRM) Q 
	.	S X=$P(vobj(dbtbl2,0),$C(124),8) I '(X=""),'(",0,1,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("SCRCLR",vRM) Q 
	.	I '("01"[$P(vobj(dbtbl2,0),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("SCRMOD",vRM) Q 
	.	S X=$P(vobj(dbtbl2,0),$C(124),12) I '(X=""),'($D(^STBL("SCASYS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("SYS",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),15))>16 S vRM=$$^MSG(1076,16) D vdderr("UID",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),10))>6 S vRM=$$^MSG(1076,6) D vdderr("VER",vRM) Q 
	.	I $L($P(vobj(dbtbl2,0),$C(124),2))>8 S vRM=$$^MSG(1076,8) D vdderr("VPGM",vRM) Q 
	.	Q 
	I $L(vobj(dbtbl2,-3))>10 S vRM=$$^MSG(1076,10) D vdderr("LIBS",vRM) Q 
	I $L(vobj(dbtbl2,-4))>12 S vRM=$$^MSG(1076,12) D vdderr("SID",vRM) Q 
	;
	I ($D(vobj(dbtbl2))#2)!'($order(vobj(dbtbl2,""))="") D
	.	;
	.	I $L($P(vobj(dbtbl2),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("DESC2",vRM) Q 
	.	Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL2","MSG",979,"DBTBL2."_di_" "_vRM)
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
	I ($D(vx("SID"))#2) S vux("SID")=vx("SID")
	D vkey(1) S voldkey=vobj(dbtbl2,-3)_","_vobj(dbtbl2,-4) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	D vload ; Make sure all data is loaded locally
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl2,-3)_","_vobj(dbtbl2,-4) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(dbtbl2)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL2",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	D vkey(1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vkey(i)	; Restore access keys
	;
	I ($D(vux("LIBS"))#2) S vobj(dbtbl2,-3)=$piece(vux("LIBS"),"|",i)
	I ($D(vux("SID"))#2) S vobj(dbtbl2,-4)=$piece(vux("SID"),"|",i)
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL2.copy: DBTBL2
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	. S:'$D(vobj(v1,"v1")) vobj(v1,"v1")=$G(^DBTBL(vobj(v1,-3),2,vobj(v1,-4),-1))
	. S:'$D(vobj(v1,"v5")) vobj(v1,"v5")=$G(^DBTBL(vobj(v1,-3),2,vobj(v1,-4),-5))
	.	F vNod=0 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),2,vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordDBTBL2 saveNoFiler()
	;
	S ^DBTBL(vobj(vnewrec,-3),2,vobj(vnewrec,-4))=$$RTBAR^%ZFUNC($G(vobj(vnewrec)))
	N vD,vN S vN=-1
	I '$G(vobj(vnewrec,-2)) F  S vN=$O(vobj(vnewrec,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBTBL(vobj(vnewrec,-3),2,vobj(vnewrec,-4),$S($E(vN)="v":-$E(vN,2,99),1:vN))=vD
	E  F  S vN=$O(vobj(vnewrec,-100,vN)) Q:vN=""  I $D(vobj(vnewrec,vN))#2 S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^DBTBL(vobj(vnewrec,-3),2,vobj(vnewrec,-4),$S($E(vN)="v":-$E(vN,2,99),1:vN))=vD I vD="" ZWI ^DBTBL(vobj(vnewrec,-3),2,vobj(vnewrec,-4),$S($E(vN)="v":-$E(vN,2,99),1:vN))
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
