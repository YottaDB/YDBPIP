DBSHLP(DINAM,VPT,VPB,VALUE,HDR)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSHLP ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	 ; Bottom most line of screen
	;
	N doPrint N isDone
	N DSPROWS N RECORDS N zcx N zcy N zseq
	N vZDOC
	;
	S ER=0
	;
	S HDR=$get(HDR)
	;
	I (DINAM?1"[*]@["1AN.AN1"]"1A.AN) S DINAM=$piece(DINAM,"@",2)
	;
	; Load from DBTBL11D
	I ($E(DINAM,1)="[") D
	.	;
	.	N COLUMN N DOCCOL N DOCTBL N TABLE
	.	;
	.	I (DINAM[",") S DINAM="["_$piece(DINAM,",",2,$L(DINAM))
	.	;
	.	I '$$VER^DBSDD(.DINAM) D HDR(.HDR) Q 
	.	;
	.	S TABLE=$piece(DINAM,".",2)
	.	S COLUMN=$piece(DINAM,".",3)
	.	;
	.	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vDb5("SYSDEV",TABLE)
	.	 S vop3=$G(^DBTBL(vop1,1,vop2,13))
	.	;
	.	I '($P(vop3,$C(124),1)="") S DOCTBL=$P(vop3,$C(124),1)
	.	E  S DOCTBL=TABLE
	.	;
	.	S DOCCOL=COLUMN
	.	;
	.	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	.	;
	.	I '$G(vos1) D
	..		;
	..		N MDDDI N MDDFID
	..		;
	..		I '($D(^DBTBL("SYSDEV",1,DOCTBL))) S MDDFID=""
	..		E  S MDDFID=$$MDD^DBSDF(DOCTBL)
	..		;
	..		N mdddi S mdddi=$G(^DBTBL("SYSDEV",1,TABLE,9,COLUMN))
	..		S MDDDI=$P(mdddi,$C(124),27)
	..		;
	..		I ((MDDFID="")!(MDDDI="")) D
	...			;
	...			S DOCTBL=""
	...			D HDR(DINAM,.HDR)
	...			;
	...			Q 
	..		;
	..		E  D
	...			;
	...			S DOCTBL=MDDFID
	...			S DOCCOL=MDDDI
	...			Q 
	..		Q 
	.	;
	.	I '(DOCTBL="") D
	..		;
	..		N SEQ
	..		;
	..		N ds,vos5,vos6,vos7,vos8 S ds=$$vOpen2()
	..		;
	..		S SEQ=3
	..		F  Q:'($$vFetch2())  D
	...			;
	...			N dbtbl11d S dbtbl11d=$G(^DBTBL($P(ds,$C(9),1),11,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	...			;
	...			S vZDOC(SEQ)=$P(dbtbl11d,$C(1),1)
	...			S SEQ=SEQ+1
	...			Q 
	..		;
	..		; Define standard header - [FID]DI  description  format  size  table
	..		N hdrrec S hdrrec=$$vDb6("SYSDEV",DOCTBL,DOCCOL)
	..		S HDR="["_DOCTBL_"]"_DOCCOL_"="_$P(hdrrec,$C(124),10)
	..		S HDR=HDR_"  Format="_$P(hdrrec,$C(124),9)
	..		S HDR=HDR_"  Size="_$P(hdrrec,$C(124),19)
	..		S HDR=HDR_"  Table="
	..		I ($P(hdrrec,$C(124),5)="") S HDR=HDR_"N"
	..		E  S HDR=HDR_"Y"
	..		Q 
	.	;
	.	Q 
	;
	; Load from a system file
	E  I (DINAM?1E.E1"."1E.E) D
	.	N voZT set voZT=$ZT
	.	;
	.	N I
	.	;
	.	N io S io=$$vClNew("IO")
	.	;
	.	S $P(vobj(io,1),"|",1)=DINAM
	.	S $P(vobj(io,1),"|",3)="READ"
	.	S $P(vobj(io,1),"|",4)=5
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	D open^UCIO(io,$T(+0),"DBSHLP","io")
	.	;
	.	F I=3:1 S vZDOC(I)=$$read^UCIO(io)
	.	K vobj(+$G(io)) Q 
	;
	; Otherwise, dealing with an array, load it into vZDOC()
	E  I '(DINAM="") D
	.	;
	.	N I
	.	N array N N
	.	;
	.	I ($get(VALUE)="") S array=DINAM_"N)"
	.	E  S array=DINAM_VALUE_",N)"
	.	;
	.	S N=""
	.	F I=3:1 S N=$order(@array) Q:(N="")  S vZDOC(I)=@array
	.	Q 
	;
	Q:ER 
	;
	; No documentation
	I '$D(vZDOC) D  Q 
	.	;
	.	S ER=1
	.	S RM=HDR
	.	Q 
	;
	I '(HDR="") D
	.	;
	.	S vZDOC(1)=HDR
	.	S vZDOC(2)=""
	.	S RECORDS=$order(vZDOC(""),-1)
	.	Q 
	E  S RECORDS=$order(vZDOC(""),-1)-2
	;
	I '$D(%fkey) D ZBINIT^%TRMVT(.%fkey)
	;
	I (+$get(VPT)=0) D
	.	;
	.	I ($D(OLNTB)#2) S VPT=(OLNTB\1000)+1
	.	E  S VPT=10
	.	Q 
	I (+$get(VPB)=0) S VPB=23
	;
	S DSPROWS=VPB-VPT
	;
	I (RECORDS>DSPROWS) D
	.	;
	.	S VPT=VPB-RECORDS
	.	I (VPT<1) S VPT=1
	.	Q 
	;
	;Clear display window and display underline
	D TERM^%ZUSE(0,"NOECHO/NOWRAP")
	WRITE $$SCRAWOFF^%TRMVT
	WRITE $$GREN^%TRMVT
	I (VPT=1) WRITE $$CLEAR^%TRMVT
	E  D
	.	;
	.	WRITE $$CUP^%TRMVT(1,VPT)
	.	WRITE $$VIDOFF^%TRMVT
	.	WRITE $$LINE^%TRMVT(80)
	.	S VPT=VPT+1
	.	Q 
	WRITE $$LOCK^%TRMVT(VPT,VPB)
	;
	S DSPROWS=VPB-VPT
	S zcy=VPT
	S zcx=1
	S zseq=$order(vZDOC(""))
	;
	S isDone=0
	S doPrint=1
	F  D  Q:isDone 
	.	;
	.	N ZB
	.	N Z
	.	;
	.	I doPrint D
	..		;
	..		D PRINT
	..		WRITE $$CUP^%TRMVT(zcx,zcy)
	..		S doPrint=0
	..		Q 
	.	;
	.	READ Z#1
	.	D ZB^%ZREAD
	.	;
	.	; Display keyboard menu and choose option
	.	I (%fkey="KYB") D
	..		;
	..		S ZB=$$EMULATE^DBSMBAR
	..		I (ZB="") D
	...			;
	...			S ZB=13
	...			S %fkey="ENT"
	...			Q 
	..		E  S %fkey=%fkey(ZB)
	..		Q 
	.	;
	.	I (%fkey="ESC") S isDone=1 Q 
	.	;
	.	I (%fkey="PDN") D PDN WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="PUP") D PUP WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="CUU") D CUU WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="CUD") D CUD WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="CUF") D CUF WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="CUB") D CUB WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="FND") D FND WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	I (%fkey="PRN") D PRN WRITE $$CUP^%TRMVT(zcx,zcy) Q 
	.	;
	.	I (%fkey="TOP") D  Q 
	..		;
	..		S zseq=1
	..		S doPrint=1
	..		Q 
	.	;
	.	I (%fkey="BOT") D  Q 
	..		;
	..		S zseq=$order(vZDOC(""),-1)
	..		S doPrint=1
	..		Q 
	.	;
	.	I (%fkey="DSP") S doPrint=1 Q 
	.	;
	.	WRITE $char(7)
	.	Q 
	;
	; Exit function - Erase table display - redisplay original form
	D TERM^%ZUSE(0,"ECHO")
	;
	WRITE $$LOCK^%TRMVT
	;
	I (VPT>1) S VPT=VPT-1
	;
	Q 
	;
PRINT	; Print a window
	;
	N I
	;
	S zend=zseq+DSPROWS
	;
	I '($D(vZDOC(zend))#2) D
	.	;
	.	S zend=$order(vZDOC(zend),-1)
	.	S zseq=zend-DSPROWS
	.	Q 
	I '($D(vZDOC(zseq))#2) D
	.	;
	.	S zseq=$order(vZDOC(zseq))
	.	S zend=$order(vZDOC(zseq+DSPROWS+1),-1)
	.	Q 
	;
	WRITE $$CLR^%TRMVT(VPT,VPB+1)
	;
	F I=zseq:1:zend D
	.	;
	.	WRITE $char(13),vZDOC(I)
	.	;
	.	I ($X>80) WRITE $$GRON^%TRMVT_$char(96)_$$GROFF^%TRMVT
	.	;
	.	WRITE $$CUD^%TRMVT
	.	Q 
	;
	D KEY
	;
	Q 
	;
KEY	;
	;
	N D
	;
	I ($D(vZDOC(zseq-1))#2) S D(1)="PUP"
	I ($D(vZDOC(zend+1))#2) S D(2)="PDN"
	S D(3)="FND"
	S D(4)="PRN"
	S D(5)="ESC"
	;
	WRITE $$SHOWKEY^%TRMVT(.D)
	;
	Q 
	;
PDN	;
	;
	I '($D(vZDOC(zend+1))#2) D
	.	;
	.	S zcy=VPT+zend-zseq
	.	D WRITE(zend,zcy)
	.	Q 
	E  D
	.	;
	.	S zseq=zend+1
	.	D PRINT
	.	Q 
	;
	Q 
	;
PUP	;
	;
	I '($D(vZDOC(zseq-1))#2) D
	.	;
	.	S zcy=VPT
	.	D WRITE(zseq,zcy)
	.	Q 
	E  D
	.	;
	.	S zseq=zseq-DSPROWS
	.	D PRINT
	.	Q 
	;
	Q 
	;
CUU	; Insert 1 line at the top of the window
	;
	I (zcy>VPT) D
	.	;
	.	S zcy=zcy-1
	.	WRITE $$CUU^%TRMVT
	.	D WRITE(zseq+zcy-VPT)
	.	Q 
	E  I ($D(vZDOC(zseq-1))#2) D
	.	;
	.	S zseq=zseq-1
	.	S zend=zend-1
	.	WRITE $$CUP^%TRMVT(1,VPT)
	.	WRITE $$LININS^%TRMVT
	.	D WRITE(zseq)
	.	;
	.	I '($D(vZDOC(zseq-1))#2) D KEY
	.	Q 
	;
	Q 
	;
CUD	; Insert 1 line at the bottom of the window
	;
	I (zcy<VPB) D
	.	;
	.	I ($D(vZDOC(zseq+zcy-VPT+1))#2) D
	..		;
	..		S zcy=zcy+1
	..		WRITE $$CUD^%TRMVT
	..		D WRITE(zseq+zcy-VPT)
	..		Q 
	.	Q 
	E  I ($D(vZDOC(zend+1))#2) D
	.	;
	.	S zseq=zseq+1
	.	S zend=zend+1
	.	WRITE $$CUP^%TRMVT(1,VPT+zend-zseq)
	.	WRITE $char(10)
	.	D WRITE(zend)
	.	Q 
	;
	Q 
	;
CUF	; Move cursor forward one position
	;
	I (zcx<80),(zcx<$L(vZDOC(zseq+zcy-VPT))) D
	.	;
	.	S zcx=zcx+1
	.	WRITE $$CUF^%TRMVT
	.	Q 
	E  D
	.	;
	.	S zcx=1
	.	D CUD
	.	Q 
	;
	Q 
	;
CUB	; Insert 1 line at the bottom of the window
	;
	I (zcx>1) D
	.	;
	.	S zcx=zcx-1
	.	WRITE $$CUB^%TRMVT
	.	Q 
	E  D
	.	;
	.	S zcx=9999
	.	D CUU
	.	Q 
	;
	Q 
	;
WRITE(seq,Y)	;
	;
	I ($D(Y)#2) WRITE $$CUP^%TRMVT(1,Y)
	;
	WRITE $char(13)
	WRITE vZDOC(seq)
	;
	I ($X>80) WRITE $$GRON^%TRMVT_$char(96)_$$GROFF^%TRMVT
	;
	I (zcx>$X) S zcx=$X
	;
	Q 
	;
FND	; Find a string in the help documentation
	;
	N I
	N Y N Z
	;
	; Find:
	S zfnd=$$PROMPT($$^MSG(1111),$get(zfnd))
	;
	WRITE $$CUON^%TRMVT
	;
	Q:(zfnd="") 
	;
	S Z=$$vStrUC(zfnd)
	S Y=zcx+1
	;
	F I=zseq+zcy-VPT:1 Q:'($D(vZDOC(I))#2)  S Y=$F($$vStrUC(vZDOC(I)),Z,Y) I (Y>0) Q 
	;
	; Not found
	I (Y=0) WRITE $$MSG^%TRMVT($$^MSG(2042),0,1)
	E  D
	.	;
	.	S zcx=Y-$L(zfnd)
	.	I (I-zseq'>DSPROWS) S zcy=VPT+I-zseq ; In window
	.	E  D
	..		;
	..		S zseq=I
	..		D PRINT ; Move window
	..		S zcy=VPT+I-zseq
	..		Q 
	.	Q 
	;
	Q 
	;
PROMPT(prompt,default)	;
	;
	D TERM^%ZUSE(0,"ECHO")
	;
	WRITE $$BTM^%TRMVT
	WRITE prompt,default
	;
	I '(default="") WRITE $$CUB^%TRMVT($L(default))
	;
	S default=$$TERM^%ZREAD(default)
	I (%fkey="ESC") S default=""
	;
	WRITE $$BTM^%TRMVT
	;
	D TERM^%ZUSE(0,"NOECHO")
	;
	Q default
	;
PRN	; Print documentation to a device
	;
	N IOSL
	N IO N N
	;
	D ^DBSIO Q:(IO="") 
	;
	USE IO
	;
	I '($get(HDR)="") D
	.	;
	.	WRITE !," ; "_HDR
	.	WRITE !," ;",!
	.	Q 
	E  WRITE !,#,"Help Documentation Listing",!!
	;
	S N=""
	F  S N=$order(vZDOC(N)) Q:(N="")  D
	.	;
	.	WRITE vZDOC(N),!
	.	I ($Y>IOSL) WRITE #,!
	.	Q 
	;
	D CLOSE^SCAIO
	;
	; Done
	WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
	;
	Q 
	;
SEL(DINAM,VPT,VPB,VALUE,ZREF)	;
	;
	N OP
	N MASK
	;
	I (($get(I(1))?1"*"1A.E)!$get(ZREF)) S MASK(6)=""
	;
	I ($get(%FN)="") S MASK(4)=""
	E  D
	.	;
	.	N rs,vos1,vos2,vos3 S rs=$$vOpen3()
	.	;
	.	I '$G(vos1) S MASK(4)=""
	.	Q 
	;
	S OP=$$^DBSMBAR(22,"",.MASK)
	;
	I (OP="") S VPT=0
	E  I (OP=1) D DBSHLP(DINAM,.VPT,VPB,$get(VALUE))
	E  I (OP=2) D
	.	;
	.	D DIHELP^DBSCRT8C(DINAM)
	.	S VPT=1
	.	S VPB=24
	.	Q 
	E  I (OP=3) D
	.	;
	.	D STATUS^DBSCRT8C
	.	S VPT=24
	.	S VPB=24
	.	Q 
	E  I (OP=4) D
	.	;
	.	N SEQ
	.	N FUNCDOC
	.	;
	.	; Load function documentation then display
	.	N rs,vos4,vos5,vos6,vos7 S rs=$$vOpen4()
	.	;
	.	S SEQ=1
	.	F  Q:'($$vFetch4())  D
	..		;
	..		S FUNCDOC(SEQ)=$P(rs,$C(9),2)
	..		S SEQ=SEQ+1
	..		Q 
	.	;
	.	D DBSHLP("FUNCDOC(")
	.	S VPT=1
	.	S VPB=24
	.	Q 
	E  I (OP=5) D FKLIST()
	E  I (OP=6) D REF(DINAM)
	;
	Q 
	;
REF(DINAM)	;
	N vpc
	;
	N COLUMN N DQL N DOC N TABLE N txt N UL N X N zdoc
	;
	S X=$$DI^DBSDD(.DINAM,"") Q:(X="") 
	;
	S TABLE=$piece(DINAM,".",2)
	S COLUMN=$piece(DINAM,".",3)
	;
	S UL=""
	S $piece(UL,"-",80)=""
	;
	S DQL(2)="Screen"
	S DQL(5)="Report"
	S DQL(6)="QWIK Report"
	;
	S txt="Cross Reference Report for "_TABLE_"."_COLUMN_" ("_$piece(X,"|",10)_")"
	;
	D ADD($$CJ^%ZTEXT(txt,80))
	D ADD("")
	;
	S DQL=""
	F  S DQL=$order(DQL(DQL)) Q:(DQL="")  D
	.	;
	.	N NAM N txt
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen5()
	.	;
	.	S vpc=('$G(vos1)) Q:vpc 
	.	;
	.	S NAM=""
	.	S txt=$J(DQL(DQL),15)_": "
	.	D ADD(txt)
	.	;
	.	F  Q:'($$vFetch5())  D
	..		;
	..		S txt="                  "_$J($P(rs,$C(9),1),20)
	..		S txt=txt_$P(rs,$C(9),2)
	..		D ADD(txt)
	..		Q 
	.	Q 
	;
	D ADD("")
	;
	D DBSHLP("DOC(",.VPT,VPB)
	;
	Q 
	;
ADD(X)	;
	;
	S DOC($order(DOC(""),-1)+1)=X
	;
	Q 
	;
FKLIST()	;
	;
	N C N I
	N KBD N KBL N KBP N X N zfk
	;
	S KBL=$$KBL^%TRMVT
	S KBP=$$KBP^%TRMVT
	S KBD=$$KBD^%TRMVT
	;
	S zfk(1)="Name  Keyboard            Description"
	S zfk(2)="----  --------            -----------"
	S C=3
	;
	; Build display string based on logical keyname
	F I=1:2 S X=$piece(KBL,"|",I) Q:(X="")  D
	.	;
	.	N ALT N DES N KEY
	.	;
	.	S KEY=X
	.	S ALT=""
	.	S X=$$ZBL(KEY)
	.	;
	.	I ($E(X,1)="*") D
	..		;
	..		S X=$E(X,2,1048575)
	..		S ALT="["_$$FKP($$ZBL("ALT"))_"]"
	..		Q 
	.	;
	.	S X=$$FKP(X)
	.	S DES=$piece($piece(KBD,KEY_"|",2),"|",1)
	.	I (DES=KEY) S DES=""
	.	S ALT=ALT_"["_X_"]"
	.	S zfk(C)=KEY_$J("",6-$L(KEY))_ALT_$J("",21-$L(ALT))
	.	I '(DES="") S zfk(C)=zfk(C)_DES
	.	S C=C+1
	.	Q 
	;
	D DBSHLP("zfk(",$get(VPT),$get(VPB))
	;
	Q 
	;
ZBL(X)	;
	;
	Q $piece($piece(KBL,X_"|",2),"|",1)
	;
FKP(X)	;
	;
	Q $piece(KBP,"|",$L($piece(KBP,"|"_X,1),"|"))
	;
HDR(DINAM,HDR)	;
	;
	I ($E(DINAM,1,10)="SYSDEV.*.@") S HDR="<"_$piece(DINAM,"@",2)_">"
	E  S HDR="<"_DINAM_">"
	;
	S HDR=HDR_"  Format="
	I ($D(E8)#2) S HDR=HDR_E8
	E  S HDR=HDR_"T"
	S HDR=HDR_"  Size="_$get(E67)
	S HDR=HDR_"  Table="
	I ($get(I(3))="") S HDR=HDR_"N"
	E  S HDR=HDR_"Y"
	Q 
	;
vSIG()	;
	Q "60789^58377^Pete Chenard^14122" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vClNew(vCls)	;	Create a new object
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls
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
vDb6(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N hdrrec
	S hdrrec=$G(^DBTBL(v1,1,v2,9,v3))
	I hdrrec="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q hdrrec
	;
vOpen1()	;	SEQ FROM DBTBL11D WHERE %LIBS='SYSDEV' AND FID=:DOCTBL AND DI=:DOCCOL
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(DOCTBL) I vos2="" G vL1a0
	S vos3=$G(DOCCOL) I vos3="" G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBTBL("SYSDEV",11,vos2,vos3,vos4),1) I vos4="" G vL1a0
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
	S rs=$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	%LIBS,FID,DI,SEQ FROM DBTBL11D WHERE %LIBS='SYSDEV' AND FID=:DOCTBL AND DI=:DOCCOL ORDER BY SEQ ASC
	;
	;
	S vos5=2
	D vL2a1
	Q ""
	;
vL2a0	S vos5=0 Q
vL2a1	S vos6=$G(DOCTBL) I vos6="" G vL2a0
	S vos7=$G(DOCCOL) I vos7="" G vL2a0
	S vos8=""
vL2a4	S vos8=$O(^DBTBL("SYSDEV",11,vos6,vos7,vos8),1) I vos8="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos5=1 D vL2a4
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos6_$C(9)_vos7_$C(9)_$S(vos8=$C(254):"",1:vos8)
	;
	Q 1
	;
vOpen3()	;	SEQ FROM SCATBLDOC WHERE FN=:%FN
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(%FN) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^SCATBL(3,vos2,vos3),1) I vos3="" G vL3a0
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
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	SEQ,DOC FROM SCATBLDOC WHERE FN=:%FN ORDER BY SEQ ASC
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=$G(%FN) I vos5="" G vL4a0
	S vos6=""
vL4a3	S vos6=$O(^SCATBL(3,vos5,vos6),1) I vos6="" G vL4a0
	Q
	;
vFetch4()	;
	;
	I vos4=1 D vL4a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S vos7=$G(^SCATBL(3,vos5,vos6))
	S rs=$S(vos6=$C(254):"",1:vos6)_$C(9)_$P(vos7,"|",1)
	;
	Q 1
	;
vOpen5()	;	INDEXID,IDNAME FROM DBINDX WHERE LIBS='SYSDEV' AND DBOPT=:DQL AND FID=:TABLE AND DINAM=:COLUMN ORDER BY INDEXID ASC
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(DQL) I vos2="" G vL5a0
	S vos3=$G(TABLE) I vos3="" G vL5a0
	S vos4=$G(COLUMN) I vos4="" G vL5a0
	S vos5=""
vL5a5	S vos5=$O(^DBINDX("SYSDEV","DI",vos2,vos3,vos4,vos5),1) I vos5="" G vL5a0
	Q
	;
vFetch5()	;
	;
	I vos1=1 D vL5a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos6=$$OBJDESC^DBSCDI(vos2,vos5)
	S rs=$S(vos5=$C(254):"",1:vos5)_$C(9)_vos6
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N ioxcpt S ioxcpt=$ZS
	;
	; if device has been opened, close it
	I '($P(vobj(io,1),"|",6)="") D close^UCIO(io)
	;
	; if not an IO exception, it's not for us
	I '($P(ioxcpt,",",3)["%PSL-E-IO") S $ZS=ioxcpt X voZT
	;
	; handle the IO exceptions
	I ($P(ioxcpt,",",3)["IOEOF") Q 
	;
	I ($P(ioxcpt,",",3)["IOOPEN") D
	.			;
	.			S ER=1
	.			; Error opening device ~p1
	.			S RM=$$^MSG(7878,DINAM)
	.			Q 
	;
	E  D
	.			;
	.			S ER=1
	.			; Error reading data
	.			S RM=$$^MSG(994)
	.			Q 
	Q 
