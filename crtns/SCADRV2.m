SCADRV2	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV2 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	Q 
	;
FIND(x)	; Find beginning with x
	;
	N E67,X,TOP,BTM,ER
	S E67=20
	S TOP=MENU+5
	S X=$$^DBSTBL("[SCATBL]",x,"T","","",.TOP,.BTM,"[SCATBL3]")
	I $get(ER) D PNTRM^SCADRV0() S STATLIN=1 Q ""
	;
	; Leave page up until next entry, unless too deep
	I TOP=(MENU+5) S STATLIN=1 S %MSGS(TOP)="" S %MSGS(BTM)=""
	E  S DISPLAY=1
	I X'="" S X="@"_X
	Q X
	;
SELECT(x)	; Select - Display menu, menu w/functions, or all functions
	;
	N menuarr
	N E67 N X N TOP N BTM N ER
	;
	S E67=3
	I $E(x,1)="@" S x=$E(x,2,99)
	;
	; Select on function
	I "??"'[x Q $$FIND($piece(x,"?",1))
	;
	S TOP=MENU+5
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	I x="??" S menuarr($P(rs,$C(9),1))=$P(rs,$C(9),2)
	.	E  S menuarr($P(rs,$C(9),1))=$P(rs,$C(9),3)
	.	Q 
	;
	S X=$$^DBSTBL("menuarr(","","N","","",.TOP,.BTM,,"")
	;
	I $get(ER) D PNTRM^SCADRV0() S STATLIN=1 Q ""
	;
	; Leave page up until next entry, unless too deep
	I TOP=(MENU+5) S STATLIN=1 S %MSGS(TOP)="" S %MSGS(BTM)=""
	E  S DISPLAY=1
	;
	Q X
	;
KYB	; Emulate control keys
	;
	N ZB
	S ZB=$$EMULATE^DBSMBAR
	I ZB="" S %fkey="ENT"
	E  S %fkey=%fkey(ZB)
	;
	Q 
	;
HELP(x)	; Display help, if available
	;
	; MENU must be defined
	;
	N FN,N,GEN,QUIT,HELP,TOP
	D HELPWHAT
	I FN="" D PNTRM^SCADRV0() Q 
	;
	I FN'="@",'($D(^SCATBL(3,FN,1))#2) D NOHELP Q 
	;
	; DBSTBL.m requires global refernce if used with keys
	I '$D(HELP) S HELP="^SCATBL(3,"""_FN_""","
	;
	; Display
	S TOP=MENU+5
	D ^DBSHLP(HELP,.TOP)
	;
	; Clear page, redisplay only if necessary
	I TOP=(MENU+5) WRITE $$CUP^%TRMVT(1,TOP),$$CLP^%TRMVT S STATLIN=1
	E  S DISPLAY=1
	;
	Q 
	;
NOHELP	; Handle no help available message
	;
	; Help documentation for ~p1 is not available
	S RM=$$^MSG("1175",FN)
	D PNTRM^SCADRV0()
	Q 
	;
HELPWHAT	; Find the function or menu for which to print help
	;
	; Return FN as name and HELP as table
	I "@"[x S FN="SCADRV" Q  ; Driver help
	I $E(x,1)="@" D HELPAT Q 
	;
	N scamenu,vop1 S scamenu=$$vDb2(MENUNO,x,.vop1)
	I $G(vop1) S FN=$P(scamenu,$C(124),2) Q 
	;
	S N=$$STRMTCH^SCADRV0(MENUNO,x)
	;
	;Invalid function name
	I N="" S FN="" S RM=$$^MSG(1359) Q 
	;
	N scamenu,vop2 S scamenu=$$vDb2(MENUNO,N,.vop2)
	I $G(vop2) S FN=$P(scamenu,$C(124),2)
	;
	Q 
	;
HELPAT	; Handle @xxx
	;
	S FN=$E(x,2,99)
	;
	; Invalid menu number
	I FN?.N,('($D(^SCATBL(0,FN))#2)) S FN="" S RM=$$^MSG(1403)
	;
	; Invalid function name
	I 'FN?.N,('($D(^SCATBL(1,FN))#2)) S FN="" S RM=$$^MSG(1359)
	;
	Q 
	;
DUMMY	; Private - Tied to function SCADRV
	Q 
	;
vSIG()	;
	Q "60243^25879^Sanjay Chhrabria^3973" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1,v2,v2out)	;	voXN = Db.getRecord(SCAMENU,,1,-2)
	;
	N scamenu
	S scamenu=$G(^SCATBL(0,v1,v2))
	I scamenu="",'$D(^SCATBL(0,v1,v2))
	S v2out='$T
	;
	Q scamenu
	;
vOpen1()	;	SNUMB,FUNMENU,MDESC FROM SCAMENU WHERE MNUMB=:MENUNO ORDER BY SNUMB
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(MENUNO) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^SCATBL(0,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^SCATBL(0,vos2,vos3))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",2)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
