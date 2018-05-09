DBSEXE5	;;DBS - U - V4.4 - LIST REPORT DEFINITIONS
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/99 08:23:45 - CHIANG
	; ORIG:  CHIANG - 3/25/86
	;
	;  I18N=QUIT: Excluded from I18N standards 
	;---------- Revision History -------------------------------------------
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS with new procedure
	;	     DBSGETID.
	;
	; 02/23/99  -  Chiang - 31754 
	;              Modified to use +$H (system date) as the input value 
	;              for the ^%ZM date utility. 
	; 
	;              Replaced $ZP function call with $O.
	;              Removed old revision history. 
	;-----------------------------------------------------------------------
LIST	;
	;
	; LIST REPORT DEFINITIONS
	N CNT,IO
	S PN=1,QUIT=""
	;
	S CNT=$$LIST^DBSGETID("DBTBL5H","List",.IO) Q:'CNT
	;
	D OPEN^SCAIO
	;
	S %BLK="/,"_IO,RID="DBSRPTLST" D DRV^URID
	Q
	;
	; DISPLAY REPORT IN PRINT IMAGE
	;
PNT	;
	I $G(%EXT),$G(RID)'="" K ^TEMP($J) S ^TEMP($J,RID)="" G PNTEXT
	;
	N CNT,IO
	S CNT=$$LIST^DBSGETID("DBTBL5H","Print",.IO) Q:'CNT
	;
	;
	; External entry
	;
PNTEXT	;
	;
	I '$D(LS) S LS=1			; Documentation print flag
	I '$D(IO) S IO=$I
	I '$D(ER) S ER=0
	D OPEN^SCAIO
	;
	S PN=1 U IO
	;
	N XGRP,ZGRP,RID,%HI,PN,VRN,RN,ZLIBS,UL,VPN,GRP,XGRP,Z,ZZZ,ZHDR
	;
	S RID=0 F LIST=1:1 S RID=$O(^TEMP($J,RID)) Q:RID=""  D PNT0   ;  *** 9/27/94 XUS
	W ! S %HI="",PN=-1 D @IOHDG Q
	;
PNT0	;
	S VRN=^DBTBL(%LIBS,5,RID),RN=VRN_" ("_RID_")"
	S ZLIBS=%LIBS I $D(^DBTBL(%LIBS,5,RID,-3)) S ZLIBS=^(-3)
	S UL="",$P(UL,"X",132)=""
	S OLN=1,PFLG=0,XDL="["_ZLIBS_","
	;
	S vsysdate="",vrundate=$$DAT^%ZM(+$H),%TIM=$$TIM^%ZM,VPN="nn"
	S %ED=$$DAT^%ZM($$^CUVAR("TJD"))
	;
	S RSIZE=$P(^DBTBL(ZLIBS,5,RID,0),"|",5)
	S PN=1,IORM=RSIZE
	U IO I IOTYP'="TRM" W #				; Form Feed
	E  D				
	.	I RSIZE<81 W $$SCR80^%TRMVT		; 80-column mode
	.	E  D TERM^%ZUSE(IO,"WIDTH=133") W $$SCR132^%TRMVT			; 132-column mode
	;
	W !,$J("",RSIZE-$L(RN)\2),RN,!!			; Report Description
	S RN=VRN
	;
	I LS D						; Documentation
	.	N i					; *** 08/02/94 BC
	.	S i=91 
	.	F  S i=$O(^DBTBL(ZLIBS,5,RID,i)) Q:i=""!(i>111)!(+i=0)  W !,^(i)
	;
	W !! F I=1:1:RSIZE W "."
	W !
	S ZHDR=1 ; print header & detail only
	;
	S ZCNT=$O(^DBTBL(ZLIBS,5,RID,11),-1),ZGRP=$P(^(ZCNT),"|",1)
	S GRP="@PH" D PNTX W !
	;
	F ZZZ=1:1:ZCNT S GRP=$P(^DBTBL(ZLIBS,5,RID,ZZZ),"|",1) D PNTX
	;
	S ZHDR=0 ; print summary section
	;
	S GRP="@PH" D PNTX
	;
	F ZZZ=ZCNT:-1:1 S GRP=$P(^DBTBL(ZLIBS,5,RID,ZZZ),"|",1) D PNTX
	;
	S ZHDR=1
	S GRP="@RS" D PNTX
	W ! F I=1:1:RSIZE W "."
	Q
	;
PNTX	;
	;
	I $O(^DBTBL(ZLIBS,5,RID,GRP,99))="" Q
	;
	I GRP="@RS" W ! F I=1:1:RSIZE-10 W "."	; *** 05/30/95 BC
	I  W "  SUMMARY"			; *** Replaced MSG call
	S XGRP=GRP		
	;
	I ZHDR G PNTHD
	;
	; trailer section
	;
	S ZMIN=^(0)+$P(^(0),",",2)+2*1000,ZMAX=99999
	D PNTACC Q
PNTHD	;
	;
	; header section
	;
	S ZMIN=1000,ZMAX=^(0)+1*1000 D PNTACC
	;
	; detail section
	;
	S ZMIN=^(0)+2*1000,ZMAX=^(0)+$P(^(0),",",2)+2*1000 D PNTACC
	Q
	;
PNTACC	;
	;
	S LN=99,OLN=ZMIN\1000-1
	;
	F I=1:1 S LN=$O(^DBTBL(ZLIBS,5,RID,GRP,LN)) Q:LN=""  D PNT1
	Q
	;
PNT1	;
	S X=^(LN)
	I X<ZMIN!(X>ZMAX) Q
	;
	S LINE=+X,XHD=$P(X,"|",7),DY=LINE\1000,DX=LINE#1000-1
	S XLEN=$P(X,"|",3)
	I $E($P(X,"|",2))'="@"!(XHD?1"["1E.E1"]"1E.E) D FORMAT
	;
	I XHD?.E1"<<".E1">>".E S Y=0 D
	.	I GRP="@PH" D VARSUB Q
	.	D FORMAT
	;
PNT1A	;
	;
	I XHD["@CNT" S XHD="",$P(XHD,"9",XLEN+1)=""
	I XHD?1"@TOT(".E!(XHD?1"@MIN(".E)!(XHD?1"@MAX(".E)!(XHD?1"@AVG(".E) S XHD=$E("999,999,999,999,999,999.99",27-XLEN,26)
	;
	I XHD'["@CHR" G PNT2
	;
	; @CHR
	;
	S Z1=$P(XHD,"@CHR(",2),Z1=$P(Z1,")",1),Z2=$P(Z1,",",2),Z1=$P(Z1,",",1)
	I 'Z2 S Z2=RSIZE-DX
	S Z2=Z2+DX
	S XHD="" F I=DX+1:1:Z2 S XHD=XHD_Z1
	;
PNT2	;
	;
	I '$D(OLN) S OLN=DY
	I DY>OLN S SKIP=DY-OLN F I=1:1:SKIP W !
	S OLN=DY W ?DX,XHD
	Q
	;
FORMAT	;
	S TYPE=$P(X,"|",4),XHD=""
	I TYPE["," F I=1:1 S Y=$P(TYPE,",",I) Q:Y=""  I "NECDT"[Y S TYPE=Y Q
	I TYPE="E" S XHD=$E("999,999,999,999,999,999.99",27-XLEN,26) Q
	I TYPE="N" S $P(XHD,"9",XLEN+1)="" Q
	I TYPE="D" S XHD=$E("DD/MM/YYYY",1,XLEN) Q
	I TYPE="C" S XHD=$E("HH:MM PM",1,XLEN) Q
	I TYPE="$" S $P(XHD,"9",XLEN-2)="",XHD=XHD_".99" Q
	I TYPE?.E1"RD"1N.N.E S ZZ=$P(TYPE,"RD",2)+0,XHD=$E("99999999999999999999",1,XLEN-ZZ-1)_"."_$E("999999999999",1,ZZ) Q
	S $P(XHD,"X",XLEN+1)="" Q
	;
VARSUB	;
	S Y=$F(XHD,"<<",Y) I Y=0 Q
	S X=$P($E(XHD,Y,999),">>",1) I X="" G VARSUB
	I X="GRP" Q
	D VARSUBX
	I 'ER S XHD=$E(XHD,1,Y-3)_X_$P($E(XHD,Y+2,999),">>",2,999)
	G VARSUB
	;
VARSUBX	; Xecute variable substitution
	;
	I X="VPN"!(X?1"VPN,".E)!(X="$J(VPN,3)") S X="" Q
	I X'?1"$G("1A.AN1")",'((X?1A.AN)!(X?1"%".AN)) S ER=1 Q
	I X'?1"$G("1A.AN1")",'$D(@X) S ER=1 Q
	S ER=0
	X "S X="_X
	Q
	;
VARSUBER	; Undefined variable
	;
	S ER=1 Q
	;
VER	;
	S ZLIBS=%LIBS
	S DESC=^DBTBL(ZLIBS,5,RID),STS=^(RID,0),$P(STS,"|",3)=+$H
	K %A S N=0 F I=1:1 S N=$O(^(N)) Q:N<0!(+N=0)  S %A(N)=^(N)
	;
	; Delete old index
	;
	S DQFUN="D",ID=RID,DBOPT=5 D ^DBSUTL3
	;
	K ^DBTBL(ZLIBS,5,RID),TT S ^DBTBL(ZLIBS,5,RID)=DESC,^(RID,0)=STS
	S X=0 F I=1:1 S X=$O(%A(X)) Q:X=""  S ^(X)=%A(X)   ;  *** 9/27/94  XUS
	S BLK="" F I=1:1:132 S BLK=BLK_" "
	S KSTS=0,RSEQ=100 K HD
	;
	S GRP="" F J=1:1 S GRP=$O(^DBTMP(PIO,GRP)) Q:GRP=""  D SET  ; *** 9/27/954 XUS
	K ^DBTMP(PIO) K XS
	;
	; Create index
	;
	S DQFUN="A",ID=RID D ^DBSUTL3
	;  *** 9/27/94  XUS
	S GRP=999 F J=1:1 S GRP=$O(^DBTBL(ZLIBS,5,RID,GRP)) Q:GRP=""  S X="" F I=1:1 S X=$O(^DBTBL(ZLIBS,5,RID,GRP,X)) Q:X=""  S ^DBTMP(PIO,GRP,X)=^(X) D PP
	Q
SET	;
	K TT
	;
	S REGION=^DBTMP(PIO,GRP,0),RSEQ=100
	;  *** 9/27/94  XUS
	S X=0 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:((X="")!(X>99))  S ^DBTBL(ZLIBS,5,RID,GRP,X)=^(X)
	S X=99 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  S TT(^(X)+0)=X ; SORT
	S X=$O(TT(100)) S OLL=X\1000,L=0
	;
	S ^DBTBL(ZLIBS,5,RID,GRP,0)=REGION
NL	S L=$O(TT(L)) I L="" Q     ;  *** 9/27/94  XUS
	S RSEQ=RSEQ+1,^DBTBL(ZLIBS,5,RID,GRP,RSEQ)=^DBTMP(PIO,GRP,TT(L))
	S PP=0
NPP	S PP=$O(^DBTMP(PIO,GRP,TT(L),PP)) I PP="" G NL      ;  *** 9/27/94  XUS
	I ^(PP)="" G NPP
	S ^DBTBL(ZLIBS,5,RID,GRP,RSEQ,PP)=^(PP) G NPP
	;
PP	;
	S Y=0 F K=1:1 S Y=$O(^DBTBL(ZLIBS,5,RID,GRP,X,Y)) Q:Y=""  S ^DBTMP(PIO,GRP,X,Y)=^(Y)     ;  *** 9/27/94  XUS
	Q
