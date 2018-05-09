DBSDFF(dbtbl1d,vpar,vparNorm)	; DBTBL1D - Data Dictionary Data Items Filer
	;
	; **** Routine compiled from DATA-QWIK Filer DBTBL1D ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (39)             09/19/2006
	; Trigger Definition (4)                      07/31/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(dbtbl1d,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(dbtbl1d,.vxins,1,"|")
	I %O=1 D AUDIT^UCUTILN(dbtbl1d,.vx,1,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	; Define local variables for access keys for legacy triggers
	N %LIBS S %LIBS=vobj(dbtbl1d,-3)
	N FID S FID=vobj(dbtbl1d,-4)
	N DI S DI=vobj(dbtbl1d,-5)
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
	.	I ($D(vx("%LIBS"))#2)!($D(vx("FID"))#2)!($D(vx("DI"))#2) D vkchged Q  ; Primary key changed
	.	I vpar["/TRIGBEF/" D VBU ; Before update triggers
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("DBTBL1D",.vx)
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
	.	  N V1,V2,V3 S V1=vobj(dbtbl1d,-3),V2=vobj(dbtbl1d,-4),V3=vobj(dbtbl1d,-5) Q:'($D(^DBTBL(V1,1,V2,9,V3))#2)  ; No record exists
	.	D vdelete(0)
	.	I vpar["/TRIGAFT/" D VAD ; After delete triggers
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N dbtbl1d S dbtbl1d=$$vDb1(%LIBS,FID,DI)
	I (%O=2) D
	.	S vobj(dbtbl1d,-2)=2
	.	;
	.	D DBSDFF(dbtbl1d,vpar)
	.	Q 
	E  D VINDEX(dbtbl1d)
	;
	K vobj(+$G(dbtbl1d)) Q 
	;
vLITCHK()	;
	Q 0 ; Table does not have columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/"  N V1,V2,V3 S V1=vobj(dbtbl1d,-3),V2=vobj(dbtbl1d,-4),V3=vobj(dbtbl1d,-5) I '(''($D(^DBTBL(V1,1,V2,9,V3))#2)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	I vpar["/VALFK/" D CHKFKS ; Check foreign keys
	I vpar["/VALRI/" D VFKEYS ; Foreign key definition
	;
	I vpar'["/NOUPDATE/" D
	.	;
	. S $P(vobj(dbtbl1d),$C(124),25)=$P($H,",",1)
	.	I '+$P($G(vobj(dbtbl1d,-100,"0*","USER")),"|",2) S $P(vobj(dbtbl1d),$C(124),26)=$$USERNAM^%ZFUNC
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1d,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1d,%O,.vx)
	.	;
	.	; Allow global reference and M source code
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(vobj(dbtbl1d)) S ^DBTBL(vobj(dbtbl1d,-3),1,vobj(dbtbl1d,-4),9,vobj(dbtbl1d,-5))=vobj(dbtbl1d)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	I vpar["/INDEX/",'(%O=1)!'($order(vx(""))="") D VINDEX(.dbtbl1d) ; Update Index files
	;
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I vpar["/INDEX/" D VINDEX(.dbtbl1d) ; Delete index entries
	I vpar'["/NOLOG/" D ^DBSLOGIT(dbtbl1d,3)
	;
	; Allow global reference - Delete record
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	ZWI ^DBTBL(vobj(dbtbl1d,-3),1,vobj(dbtbl1d,-4),9,vobj(dbtbl1d,-5))
	;*** End of code by-passed by compiler ***
	Q 
	;
vinit	; Initialize default values
	;
	; Type local variables for access keys for defaults
	;
	I ($P(vobj(dbtbl1d),$C(124),17)="") S $P(vobj(dbtbl1d),$C(124),17)=0 ; ismaster
	I ($P(vobj(dbtbl1d),$C(124),11)="") S $P(vobj(dbtbl1d),$C(124),11)="S" ; itp
	I ($P(vobj(dbtbl1d),$C(124),31)="") S $P(vobj(dbtbl1d),$C(124),31)=0 ; nullind
	I ($P(vobj(dbtbl1d),$C(124),15)="") S $P(vobj(dbtbl1d),$C(124),15)=0 ; req
	I ($P(vobj(dbtbl1d),$C(124),23)="") S $P(vobj(dbtbl1d),$C(124),23)=0 ; srl
	I ($P(vobj(dbtbl1d),$C(124),9)="") S $P(vobj(dbtbl1d),$C(124),9)="T" ; typ
	I ($P(vobj(dbtbl1d),$C(124),28)="") S $P(vobj(dbtbl1d),$C(124),28)=0 ; val4ext
	Q 
	;
vreqn	; Validate required data items
	;
	I ($P(vobj(dbtbl1d),$C(124),10)="") D vreqerr("DES") Q 
	I ($P(vobj(dbtbl1d),$C(124),17)="") D vreqerr("ISMASTER") Q 
	I ($P(vobj(dbtbl1d),$C(124),31)="") D vreqerr("NULLIND") Q 
	I ($P(vobj(dbtbl1d),$C(124),15)="") D vreqerr("REQ") Q 
	I ($P(vobj(dbtbl1d),$C(124),23)="") D vreqerr("SRL") Q 
	I ($P(vobj(dbtbl1d),$C(124),9)="") D vreqerr("TYP") Q 
	I ($P(vobj(dbtbl1d),$C(124),28)="") D vreqerr("VAL4EXT") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I (vobj(dbtbl1d,-3)="") D vreqerr("%LIBS") Q 
	I (vobj(dbtbl1d,-4)="") D vreqerr("FID") Q 
	I (vobj(dbtbl1d,-5)="") D vreqerr("DI") Q 
	;
	I ($D(vx("DES"))#2),($P(vobj(dbtbl1d),$C(124),10)="") D vreqerr("DES") Q 
	I ($D(vx("ISMASTER"))#2),($P(vobj(dbtbl1d),$C(124),17)="") D vreqerr("ISMASTER") Q 
	I ($D(vx("NULLIND"))#2),($P(vobj(dbtbl1d),$C(124),31)="") D vreqerr("NULLIND") Q 
	I ($D(vx("REQ"))#2),($P(vobj(dbtbl1d),$C(124),15)="") D vreqerr("REQ") Q 
	I ($D(vx("SRL"))#2),($P(vobj(dbtbl1d),$C(124),23)="") D vreqerr("SRL") Q 
	I ($D(vx("TYP"))#2),($P(vobj(dbtbl1d),$C(124),9)="") D vreqerr("TYP") Q 
	I ($D(vx("VAL4EXT"))#2),($P(vobj(dbtbl1d),$C(124),28)="") D vreqerr("VAL4EXT") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1D","MSG",1767,"DBTBL1D."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VFKEYS	; Foreign keys
	;
	I '(vobj(dbtbl1d,-4)="") S vfkey("^DBTBL("_""""_vobj(dbtbl1d,-3)_""""_","_1_","_""""_vobj(dbtbl1d,-4)_""""_")")="DBTBL1D(%LIBS,FID) -> DBTBL1"
	Q 
	;
CHKFKS	; Check foreign keys when not under buffer
	;
	N vERRMSG
	;
	 N V1,V2 S V1=vobj(dbtbl1d,-3),V2=vobj(dbtbl1d,-4) I '($D(^DBTBL(V1,1,V2))) S vERRMSG=$$^MSG(8563,"DBTBL1D(%LIBS,FID) -> DBTBL1") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	Q 
	;
VAD	;
	 S ER=0
	D vad1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VAI	;
	 S ER=0
	D vai1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VAU	;
	 S ER=0
	D vau1 I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
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
	D AUDIT^UCUTILN(dbtbl1d,.vx,1,"|")
	Q 
	;
vad1	; Trigger AFTER_DELETE - After Delete (remove reqd and dft index)
	;
	; Delete this data item from its descendants
	;
	N ZVAL
	;
	Q:(vobj(dbtbl1d,-5)=" ") 
	;
	; Remove entry from required and default list
	N dbtbl1 S dbtbl1=$$vDb2("SYSDEV",vobj(dbtbl1d,-4))
	 S vobj(dbtbl1,102)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102))
	 S vobj(dbtbl1,101)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),101))
	 S vobj(dbtbl1,10)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10))
	;
	I $P(vobj(dbtbl1d),$C(124),15)!($P(vobj(dbtbl1d),$C(124),9)="L") D
	.	;
	.	S ZVAL=$P(vobj(dbtbl1,102),$C(124),1)
	. N vo33 D remitem(vobj(dbtbl1d,-5),.ZVAL,.vo33) K vobj(+$G(vo33))
	. S vobj(dbtbl1,-100,102)="",$P(vobj(dbtbl1,102),$C(124),1)=ZVAL
	.	Q 
	;
	I '($P(vobj(dbtbl1d),$C(124),3)="")!($P(vobj(dbtbl1d),$C(124),9)="L") D
	.	;
	.	S ZVAL=$P(vobj(dbtbl1,101),$C(124),1)
	. N vo35 D remitem(vobj(dbtbl1d,-5),.ZVAL,.vo35) K vobj(+$G(vo35))
	. S vobj(dbtbl1,-100,101)="",$P(vobj(dbtbl1,101),$C(124),1)=ZVAL
	.	Q 
	;
	S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),10)=$P($H,",",1)
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 Tcommit:vTp  
	;
	; Delete this data item from its descendants
	N rs,vos1,vos2,vos3  N V1 S V1=vobj(dbtbl1d,-4) S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N SUBFID
	.	;
	.	S SUBFID=rs
	.	;
	.	 N V2 S V2=vobj(dbtbl1d,-5) D vDbDe1()
	.	Q 
	;
	K vobj(+$G(dbtbl1)) Q 
	;
vai1	; Trigger AFTER_INSERT - After Insert
	N vpc
	;
	; If this is a Master Dictionary, distribute changes to everyone
	N ZDI N ZFID N ZVAL
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen2()
	;
	I $$vFetch2() D DSTMDD^DBSDF(FID,DI)
	;
	; Copy this data item to its descendants
	S ZFID=vobj(dbtbl1d,-4)
	S ZDI=vobj(dbtbl1d,-5)
	;
	N sub S sub=$$vReCp1(dbtbl1d)
	;
	N rs2,vos7,vos8,vos9 S rs2=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	; copy data item to sub file
	. S vobj(sub,-4)=rs2
	.	;
	.	S vobj(sub,-2)=0
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(sub,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sub,-100) S vobj(sub,-2)=1 Tcommit:vTp  
	.	Q 
	;
	; Check required indicator (node 102)
	S vpc=((vobj(dbtbl1d,-5)=" ")) K:vpc vobj(+$G(sub)) Q:vpc 
	;
	I $P(vobj(dbtbl1d),$C(124),15) D
	.	;
	.	; Dummy key
	.	Q:(($E(DI,1)="""")!(DI?1N.E)) 
	.	;
	.	N dbtbl1 S dbtbl1=$$vDb3("SYSDEV",FID)
	.	 S vobj(dbtbl1,102)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102))
	.	;
	.	S ZVAL=$P(vobj(dbtbl1,102),$C(124),1)
	.	;
	.	; Add it to the list
	.	D additem(vobj(dbtbl1d,-5),.ZVAL,.dbtbl1d)
	.	;
	. S vobj(dbtbl1,-100,102)="",$P(vobj(dbtbl1,102),$C(124),1)=ZVAL
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(dbtbl1)) Q 
	;
	; Check items with default value (node 101)
	I '($P(vobj(dbtbl1d),$C(124),3)="") D
	.	;
	.	N dbtbl1 S dbtbl1=$$vDb3("SYSDEV",FID)
	.	 S vobj(dbtbl1,101)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),101))
	.	;
	.	S ZVAL=$P(vobj(dbtbl1,101),$C(124),1)
	.	;
	.	D additem(vobj(dbtbl1d,-5),.ZVAL,.dbtbl1d)
	.	;
	. S vobj(dbtbl1,-100,101)="",$P(vobj(dbtbl1,101),$C(124),1)=ZVAL
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(dbtbl1)) Q 
	;
	K vobj(+$G(sub)) Q 
	;
additem(item,list,dbtbl1d)	;
	;
	N i
	N z
	;
	I (list="") S list=item Q 
	;
	; Already in the list
	I ((","_list_",")[(","_item_",")) Q 
	;
	F i=1:1:$L(list,",") S z($piece(list,",",i))=""
	;
	; Add it to the list
	S z(item)=""
	S (i,list)=""
	F  S i=$order(z(i)) Q:(i="")  S list=list_","_i
	S list=$E(list,2,1048575)
	;
	Q 
	;
remitem(item,list,dbtbl1d)	;
	;
	; Not in the list
	I '((","_list_",")[(","_item_",")) Q 
	;
	S list=","_list_","
	S item=","_item_","
	;
	; Remove it from the list
	S list=$piece(list,item,1)_","_$piece(list,item,2,99)
	;
	; Remove extra comma
	S list=$E(list,2,$L(list)-1)
	;
	Q 
	;
vau1	; Trigger AFTER_UPDATE - After Update
	;
	N ZDI N ZFID N ZVAL
	;
	N dbtbl1 S dbtbl1=$$vDb3("SYSDEV",FID)
	 S vobj(dbtbl1,10)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10))
	 S vobj(dbtbl1,102)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102))
	 S vobj(dbtbl1,101)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),101))
	;
	S vobj(dbtbl1,-100,10)="",$P(vobj(dbtbl1,10),$C(124),10)=$P($H,",",1)
	;
	; Add or remove from the required data item list
	I (vobj(dbtbl1d,-5)'=" "),($S($D(vobj(dbtbl1d,-100,"0*","REQ")):$P($E(vobj(dbtbl1d,-100,"0*","REQ"),5,9999),$C(124)),1:$P(vobj(dbtbl1d),$C(124),15))'=$P(vobj(dbtbl1d),$C(124),15)) D
	.	;
	.	; Required list
	.	S ZVAL=$P(vobj(dbtbl1,102),$C(124),1)
	.	;
	.	I $P(vobj(dbtbl1d),$C(124),15)!($P(vobj(dbtbl1d),$C(124),9)="L") D
	..		;
	..	 N vo37 D additem(vobj(dbtbl1d,-5),.ZVAL,.vo37) K vobj(+$G(vo37))
	..		Q 
	.	E  N vo38 D remitem(vobj(dbtbl1d,-5),.ZVAL,.vo38) K vobj(+$G(vo38))
	.	;
	. S vobj(dbtbl1,-100,102)="",$P(vobj(dbtbl1,102),$C(124),1)=ZVAL
	.	Q 
	;
	; Add or remove from the default list
	I (vobj(dbtbl1d,-5)'=" "),($S($D(vobj(dbtbl1d,-100,"0*","DFT")):$P($E(vobj(dbtbl1d,-100,"0*","DFT"),5,9999),$C(124)),1:$P(vobj(dbtbl1d),$C(124),3))'=$P(vobj(dbtbl1d),$C(124),3)) D
	.	;
	.	S ZVAL=$P(vobj(dbtbl1,101),$C(124),1)
	.	;
	.	I '($P(vobj(dbtbl1d),$C(124),3)="")!($P(vobj(dbtbl1d),$C(124),9)="L") D
	..		;
	..	 N vo40 D additem(vobj(dbtbl1d,-5),.ZVAL,.vo40) K vobj(+$G(vo40))
	..		Q 
	.	E  N vo41 D remitem(vobj(dbtbl1d,-5),.ZVAL,.vo41) K vobj(+$G(vo41))
	.	;
	. S vobj(dbtbl1,-100,101)="",$P(vobj(dbtbl1,101),$C(124),1)=ZVAL
	.	Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 Tcommit:vTp  
	;
	; If this is a Master Dictionary, distribute changes to everyone
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen4()
	;
	I $$vFetch4() D DSTMDD^DBSDF(FID,DI)
	;
	; Copy this data item to its descendants
	;
	S ZFID=vobj(dbtbl1d,-4)
	S ZDI=vobj(dbtbl1d,-5)
	;
	N sub S sub=$$vReCp2(dbtbl1d)
	;
	N rs2,vos7,vos8,vos9 S rs2=$$vOpen5()
	;
	F  Q:'($$vFetch5())  D
	.	;
	. S vobj(sub,-4)=rs2 ; copy data item to sub file
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(sub,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sub,-100) S vobj(sub,-2)=1 Tcommit:vTp  
	.	Q 
	;
	K vobj(+$G(dbtbl1)),vobj(+$G(sub)) Q 
	;
vbi1	; Trigger BEFORE_UPDATE - Before Insert/Update
	;
	D vbu1
	;
	Q 
	;
vbu1	; Trigger BEFORE_UPDATE - Before Insert/Update
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb5("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,99))
	;
	I ($S($D(vobj(dbtbl1d,-100,"0*","TYP")):$P($E(vobj(dbtbl1d,-100,"0*","TYP"),5,9999),$C(124)),1:$P(vobj(dbtbl1d),$C(124),9))'=$P(vobj(dbtbl1d),$C(124),9))!(($S($D(vobj(dbtbl1d,-100,"0*","LEN")):$P($E(vobj(dbtbl1d,-100,"0*","LEN"),5,9999),$C(124)),1:$P(vobj(dbtbl1d),$C(124),2))'=$P(vobj(dbtbl1d),$C(124),2))) N vo42 D FKEYCHK(.dbtbl1d,.vo42) K vobj(+$G(vo42)) Q:ER 
	;
	I ($P(vobj(dbtbl1d),$C(124),9)="L"),((%O=0)!($S($D(vobj(dbtbl1d,-100,"0*","TYP")):$P($E(vobj(dbtbl1d,-100,"0*","TYP"),5,9999),$C(124)),1:$P(vobj(dbtbl1d),$C(124),9))'="L")) D
	.	;
	. S:'$D(vobj(dbtbl1d,-100,"0*","REQ")) vobj(dbtbl1d,-100,"0*","REQ")="L015"_$P(vobj(dbtbl1d),$C(124),15) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),15)=1
	.	I ($P(vobj(dbtbl1d),$C(124),3)="") S:'$D(vobj(dbtbl1d,-100,"0*","DFT")) vobj(dbtbl1d,-100,"0*","DFT")="T003"_$P(vobj(dbtbl1d),$C(124),3) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),3)=0
	.	Q 
	;
	I '($P(vobj(dbtbl1d),$C(124),3)=""),'$$isLit^UCGM($P(vobj(dbtbl1d),$C(124),3)),($P(vop3,$C(124),2)="") D
	.	;
	.	S ER=1
	.	S RM="Non-literal default values require a filer for the table"
	.	Q 
	;
	Q 
	;
FKEYCHK(dbtbl1d,dbtbl1)	; check foreign key relationship
	;
	N FKEYS N TESTDI N X
	;
	S TESTDI=","_DI_","
	;
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen6()
	;
	F  Q:'($$vFetch6())  S FKEYS=rs D  Q:ER 
	.	S FKEYS=","_$TR(FKEYS,$char(9),",")_","
	.	I FKEYS'[TESTDI Q 
	.	S ER=1
	.	I $piece(FKEYS,",",2)'=FID S RM=$$^MSG(3963,$piece(FKEYS,",",2))
	.	E  S RM=$$^MSG(3963,$piece(FKEYS,",",3))
	.	Q 
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I $L(vobj(dbtbl1d,-3))>12 S vRM=$$^MSG(1076,12) D vdderr("%LIBS",vRM) Q 
	S X=vobj(dbtbl1d,-4) I '(X="") S vRM=$$VAL^DBSVER("U",256,1,,"X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1D.FID"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	S X=vobj(dbtbl1d,-5) I '(X="") S vRM=$$VAL^DBSVER("U",256,1,,"X?1""%"".AN!(X?.A.""_"".E)",,,0) I '(vRM="") S vRM=$$^MSG(979,"DBTBL1D.DI"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	I $L($P(vobj(dbtbl1d),$C(124),32))>40 S vRM=$$^MSG(1076,40) D vdderr("ALIAS",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),16))>255 S vRM=$$^MSG(1076,255) D vdderr("CMP",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),24) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("CNV",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),14) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("DEC",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),20) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("DEL",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),30))>255 S vRM=$$^MSG(1076,255) D vdderr("DEPOSTP",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),29))>255 S vRM=$$^MSG(1076,255) D vdderr("DEPREP",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),10))>40 S vRM=$$^MSG(1076,40) D vdderr("DES",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),3))>58 S vRM=$$^MSG(1076,58) D vdderr("DFT",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),4))>20 S vRM=$$^MSG(1076,20) D vdderr("DOM",vRM) Q 
	I '("01"[$P(vobj(dbtbl1d),$C(124),17)) S vRM=$$^MSG(742,"L") D vdderr("ISMASTER",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),11) I '(X=""),'(",S,N,B1,B2,B3,B4,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("ITP",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),2) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("LEN",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),25) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LTD",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),13))>25 S vRM=$$^MSG(1076,25) D vdderr("MAX",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),27))>12 S vRM=$$^MSG(1076,12) D vdderr("MDD",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),12))>25 S vRM=$$^MSG(1076,25) D vdderr("MIN",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),1))>26 S vRM=$$^MSG(1076,26) D vdderr("NOD",vRM) Q 
	I '("01"[$P(vobj(dbtbl1d),$C(124),31)) S vRM=$$^MSG(742,"L") D vdderr("NULLIND",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),21) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("POS",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),6))>60 S vRM=$$^MSG(1076,60) D vdderr("PTN",vRM) Q 
	I '("01"[$P(vobj(dbtbl1d),$C(124),15)) S vRM=$$^MSG(742,"L") D vdderr("REQ",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),22))>40 S vRM=$$^MSG(1076,40) D vdderr("RHD",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),18))>20 S vRM=$$^MSG(1076,20) D vdderr("SFD",vRM) Q 
	S X=$P($P(vobj(dbtbl1d),$C(124),18),$C(126),2) I '(X=""),'($D(^DBCTL("SYS","DELIM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("SFD1",vRM) Q 
	S X=$P($P(vobj(dbtbl1d),$C(124),18),$C(126),3) I '(X=""),'($D(^DBCTL("SYS","DELIM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("SFD2",vRM) Q 
	S X=$P($P(vobj(dbtbl1d),$C(124),18),$C(126),4) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("SFP",vRM) Q 
	I $L($P($P(vobj(dbtbl1d),$C(124),18),$C(126),1))>12 S vRM=$$^MSG(1076,12) D vdderr("SFT",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),19) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("SIZ",vRM) Q 
	I '("01"[$P(vobj(dbtbl1d),$C(124),23)) S vRM=$$^MSG(742,"L") D vdderr("SRL",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),5))>255 S vRM=$$^MSG(1076,255) D vdderr("TBL",vRM) Q 
	S X=$P(vobj(dbtbl1d),$C(124),9) I '(X=""),'($D(^DBCTL("SYS","DVFM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TYP",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),26))>20 S vRM=$$^MSG(1076,20) D vdderr("USER",vRM) Q 
	I '("01"[$P(vobj(dbtbl1d),$C(124),28)) S vRM=$$^MSG(742,"L") D vdderr("VAL4EXT",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),7))>58 S vRM=$$^MSG(1076,58) D vdderr("XPO",vRM) Q 
	I $L($P(vobj(dbtbl1d),$C(124),8))>58 S vRM=$$^MSG(1076,58) D vdderr("XPR",vRM) Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("DBTBL1D","MSG",979,"DBTBL1D."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
VINDEX(dbtbl1d)	; Update index entries
	;
	I %O=1 D  Q 
	.	I ($D(vx("DOM"))#2) D vi1(.dbtbl1d)
	.	I ($D(vx("MDD"))#2) D vi2(.dbtbl1d)
	.	I ($D(vx("NOD"))#2)!($D(vx("POS"))#2) D vi3(.dbtbl1d)
	.	Q 
	D vi1(.dbtbl1d)
	D vi2(.dbtbl1d)
	D vi3(.dbtbl1d)
	;
	Q 
	;
vi1(dbtbl1d)	; Maintain DOMAIN index entries (Domain Name)
	;
	N vdelete S vdelete=0
	N v1 S v1=vobj(dbtbl1d,-3)
	N v4 S v4=$P(vobj(dbtbl1d),$C(124),4)
	I (v4="") S v4=$char(254)
	N v5 S v5=vobj(dbtbl1d,-4)
	N v6 S v6=vobj(dbtbl1d,-5)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(^DBTBL(vobj(dbtbl1d,-3),1,vobj(dbtbl1d,-4),9,vobj(dbtbl1d,-5)))#2,'$D(^DBINDX(v1,"DOM","PBS",v4,v5,v6)) do vidxerr("DOMAIN")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^DBINDX(v1,"DOM","PBS",v4,v5,v6)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("DOM"))#2) S v4=$piece(vx("DOM"),"|",1) S:(v4="") v4=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBINDX(v1,"DOM","PBS",v4,v5,v6)
	;*** End of code by-passed by compiler ***
	Q 
	;
vi2(dbtbl1d)	; Maintain MDD index entries (Master Dictionary Pointer)
	;
	N vdelete S vdelete=0
	N v1 S v1=vobj(dbtbl1d,-3)
	N v3 S v3=$P(vobj(dbtbl1d),$C(124),27)
	I (v3="") S v3=$char(254)
	N v4 S v4=vobj(dbtbl1d,-4)
	N v5 S v5=vobj(dbtbl1d,-5)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(^DBTBL(vobj(dbtbl1d,-3),1,vobj(dbtbl1d,-4),9,vobj(dbtbl1d,-5)))#2,'$D(^DBINDX(v1,"MDD",v3,v4,v5)) do vidxerr("MDD")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^DBINDX(v1,"MDD",v3,v4,v5)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("MDD"))#2) S v3=$piece(vx("MDD"),"|",1) S:(v3="") v3=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBINDX(v1,"MDD",v3,v4,v5)
	;*** End of code by-passed by compiler ***
	Q 
	;
vi3(dbtbl1d)	; Maintain NODEPOS index entries (Node/Position )
	;
	N vdelete S vdelete=0
	N v1 S v1=vobj(dbtbl1d,-3)
	N v3 S v3=vobj(dbtbl1d,-4)
	N v4 S v4=$P(vobj(dbtbl1d),$C(124),1)
	I (v4="") S v4=$char(254)
	N v5 S v5=$P(vobj(dbtbl1d),$C(124),21)
	I (v5="") S v5=$char(254)
	N v6 S v6=vobj(dbtbl1d,-5)
	;
	I %O=2 D  Q 
	.	;
	.	; Allow global reference
	.	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	.	;*** Start of code by-passed by compiler
	.	if $D(^DBTBL(vobj(dbtbl1d,-3),1,vobj(dbtbl1d,-4),9,vobj(dbtbl1d,-5)))#2,'$D(^DBINDX(v1,"STR",v3,v4,v5,v6)) do vidxerr("NODEPOS")
	.	;*** End of code by-passed by compiler ***
	.	Q 
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	if %O<2 set ^DBINDX(v1,"STR",v3,v4,v5,v6)="" 
	;*** End of code by-passed by compiler ***
	Q:%O=0 
	;
	I %O=3 S vdelete=1
	I ($D(vx("NOD"))#2) S v4=$piece(vx("NOD"),"|",1) S:(v4="") v4=$char(254)
	I ($D(vx("POS"))#2) S v5=$piece(vx("POS"),"|",1) S:(v5="") v5=$char(254)
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	kill ^DBINDX(v1,"STR",v3,v4,v5,v6)
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
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen7()
	;
	F  Q:'($$vFetch7())  D
	.	N dbtbl1d S dbtbl1d=$$vDb4($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	I ((","_vlist_",")[",VINDEX,") D VINDEX(.dbtbl1d) K vobj(+$G(dbtbl1d)) Q 
	.	I ((","_vlist_",")[",DOMAIN,") D vi1(.dbtbl1d)
	.	I ((","_vlist_",")[",MDD,") D vi2(.dbtbl1d)
	.	I ((","_vlist_",")[",NODEPOS,") D vi3(.dbtbl1d)
	.	K vobj(+$G(dbtbl1d)) Q 
	;
	Q 
	;
VIDXBLD1(dbtbl1d,vlist)	; Rebuild index files for one record (External call)
	;
	N i
	;
	I ((","_vlist_",")[",VINDEX,") D VINDEX(.dbtbl1d) Q 
	I ((","_vlist_",")[",DOMAIN,") D vi1(.dbtbl1d)
	I ((","_vlist_",")[",MDD,") D vi2(.dbtbl1d)
	I ((","_vlist_",")[",NODEPOS,") D vi3(.dbtbl1d)
	;
	Q 
	;
vidxerr(di)	; Error message
	;
	D SETERR^DBSEXECU("DBTBL1D","MSG",1225,"DBTBL1D."_di)
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
	I ($D(vx("DI"))#2) S vux("DI")=vx("DI")
	D vkey(1) S voldkey=vobj(dbtbl1d,-3)_","_vobj(dbtbl1d,-4)_","_vobj(dbtbl1d,-5) ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	I vpar["/VALREQ/" D vrequ
	I vpar["/TRIGBEF/" D VBU
	I vpar["/VALDD/" D vddver
	D vexec
	;
	D vkey(2) S vnewkey=vobj(dbtbl1d,-3)_","_vobj(dbtbl1d,-4)_","_vobj(dbtbl1d,-5) ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp3(dbtbl1d)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(vnewrec,"/NOCASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/",1) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("DBTBL1D",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
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
	I ($D(vux("%LIBS"))#2) S vobj(dbtbl1d,-3)=$piece(vux("%LIBS"),"|",i)
	I ($D(vux("FID"))#2) S vobj(dbtbl1d,-4)=$piece(vux("FID"),"|",i)
	I ($D(vux("DI"))#2) S vobj(dbtbl1d,-5)=$piece(vux("DI"),"|",i)
	Q 
	;
VIDXPGM()	;
	Q "DBSDFF" ; Location of index program
	;
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:SUBFID AND DI=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb4("SYSDEV",SUBFID,V2)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBSDFF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1D,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2,9,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2,9,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,1)
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
vDb3(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,0)
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
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1D,,1)
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
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vOpen1()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="",'$D(V1) G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBINDX("SYSDEV","PARFID",vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	MDD FROM DBTBL1D WHERE %LIBS='SYSDEV' AND MDDFID=:FID AND MDD=:DI
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FID) I vos2="",'$D(FID) G vL2a0
	S vos3=$G(DI) I vos3="",'$D(DI) G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^DBINDX("SYSDEV","MDD",vos3,vos4),1) I vos4="" G vL2a0
	S vos5=""
vL2a6	S vos5=$O(^DBINDX("SYSDEV","MDD",vos3,vos4,vos5),1) I vos5="" G vL2a4
	S vos6=$$MDD^DBSDF(vos4)
	I '(vos6=vos2) G vL2a6
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos3
	;
	Q 1
	;
vOpen3()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:ZFID
	;
	;
	S vos7=2
	D vL3a1
	Q ""
	;
vL3a0	S vos7=0 Q
vL3a1	S vos8=$G(ZFID) I vos8="",'$D(ZFID) G vL3a0
	S vos9=""
vL3a3	S vos9=$O(^DBINDX("SYSDEV","PARFID",vos8,vos9),1) I vos9="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos7=1 D vL3a3
	I vos7=2 S vos7=1
	;
	I vos7=0 Q 0
	;
	S rs2=$S(vos9=$C(254):"",1:vos9)
	;
	Q 1
	;
vOpen4()	;	MDD FROM DBTBL1D WHERE %LIBS='SYSDEV' AND MDDFID=:FID AND MDD=:DI
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(FID) I vos2="",'$D(FID) G vL4a0
	S vos3=$G(DI) I vos3="",'$D(DI) G vL4a0
	S vos4=""
vL4a4	S vos4=$O(^DBINDX("SYSDEV","MDD",vos3,vos4),1) I vos4="" G vL4a0
	S vos5=""
vL4a6	S vos5=$O(^DBINDX("SYSDEV","MDD",vos3,vos4,vos5),1) I vos5="" G vL4a4
	S vos6=$$MDD^DBSDF(vos4)
	I '(vos6=vos2) G vL4a6
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos3
	;
	Q 1
	;
vOpen5()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:ZFID
	;
	;
	S vos7=2
	D vL5a1
	Q ""
	;
vL5a0	S vos7=0 Q
vL5a1	S vos8=$G(ZFID) I vos8="",'$D(ZFID) G vL5a0
	S vos9=""
vL5a3	S vos9=$O(^DBINDX("SYSDEV","PARFID",vos8,vos9),1) I vos9="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos7=1 D vL5a3
	I vos7=2 S vos7=1
	;
	I vos7=0 Q 0
	;
	S rs2=$S(vos9=$C(254):"",1:vos9)
	;
	Q 1
	;
vOpen6()	;	FID,TBLREF,FKEYS FROM DBTBL1F WHERE ( TBLREF=:FID OR FID=:FID ) AND %LIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(FID) I vos2="",'$D(FID) G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^DBTBL("SYSDEV",19,vos3),1) I vos3="" G vL6a0
	S vos4=""
vL6a5	S vos4=$O(^DBTBL("SYSDEV",19,vos3,vos4),1) I vos4="" G vL6a3
	S vos5=$G(^DBTBL("SYSDEV",19,vos3,vos4))
	I '(($P(vos5,"|",5)=vos2!(vos3=vos2))) G vL6a5
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos5,"|",5)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen7()	;	%LIBS,FID,DI FROM DBTBL1D
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=""
vL7a2	S vos2=$O(^DBTBL(vos2),1) I vos2="" G vL7a0
	S vos3=""
vL7a4	S vos3=$O(^DBTBL(vos2,1,vos3),1) I vos3="" G vL7a2
	S vos4=""
vL7a6	S vos4=$O(^DBTBL(vos2,1,vos3,9,vos4),1) I vos4="" G vL7a4
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL1D.copy: DBTBL1D
	;
	Q $$copy^UCGMR(dbtbl1d)
	;
vReCp2(v1)	;	RecordDBTBL1D.copy: DBTBL1D
	;
	Q $$copy^UCGMR(dbtbl1d)
	;
vReCp3(v1)	;	RecordDBTBL1D.copy: DBTBL1D
	;
	Q $$copy^UCGMR(dbtbl1d)
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
