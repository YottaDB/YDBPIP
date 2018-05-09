FORMDQ5(RID)	;FORMDQ; -  - V5.0 - Forms system Report driver
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/27/97 12:59:14 - CHIANG
	;     ORIG:  CHIANG - 01/23/90  based on FORMDQ2
	;     DESC:  CREATE/MODIFY REPORT LAYOUT
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR20048
	;	     Replaced $C(128) reference with $$BYTECHAR^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 02/22/05 - Anna Vertlib - CR14530
	;	     Modified START and INDEX sections to add %DB to the 
	;	     exclusive New command to avoid an undefined error.
	;
	; 01/27/97 - Bob Chiang - 23631
	;            Modified LOAD section when in modify mode, reset cusor
	;            position at column 1.
	;
	; 08/15/96 - Bob Chiang - 20948
	;            Modified TYPE section to display memo field as x (text)
	;            instead of 9 (numeric).
	;
	;            Removed old revision history.
	;-----------------------------------------------------------------------
START	;
	;
	L
	I $G(RID)="" Q
	N (%DB,%LIBS,RID,%UCLS,%UID)
	;
	I $G(%LIBS)="" S %LIBS=^CUVAR("%LIBS") I %LIBS="" Q
	;
	D INIT^%ZM()
	D ^FORMINIT
	D ^FORMDQ2B(5)
	S MAINPGM=$T(+0)
	;
	S PAGE(1)="FORMVAR5|6;40"
	S LIBS=%LIBS,EDITED=0,ORGRID=RID,%TO=$$TO^FORMVAR
	;
	L +^DBTBL(%LIBS,5,RID):3 
	E  W $$MSG^FORM("Report in use",1) Q	; *** BC - 11/02/93
	;
	D LOAD(ORGRID)
	D PUTRGN^FORMFUN()
	D ^FORM(9999,9999)	; *** BC - Increase frame size 10/26/93
	Q
	;
LOAD(ORGRID)	; Load a report information from ^DBTBL level 5
	;
	I $D(M)>1,'$$SAVE Q
	K A,D,M,P,OLNTB,ZMARKER
	N N,P,X,Z,y,x,HEADER,OPTION
	S DBOPT=5,dl=$C(0)
	;
	I RID'?1"z".E S RID="z"_ORGRID D ^FORMSAV(ORGRID,5)
	;
	; ---------- Set states to last used ----------
	;
	S ST8=$G(^DBTBL(%LIBS,5,RID,-5)),HEADER=^(0),OPTION=$O(^(99999))
	S $P(ST8,"|",2)=1				; Reset cusor position
	I OPTION=""!(ST8="") S $P(ST8,"|",3)=2,$P(ST8,"|",12)=1 ; Ruler, Status
	E  S $P(ST8,"|",12)=0 ; Turn off status option
	;
	I $P(HEADER,"|",5)>80 S $P(ST8,"|",13)=132
	E  S $P(ST8,"|",13)=80
	;
	D REST8^FORMINIT
	;
	S RPTSIZE=+$P(HEADER,"|",5),FILES=$P(HEADER,"|",1)
	S ZFID=$P(FILES,",",1),LIB=%LIBS
	;
	S LEVEL=1,N=999,y=1
	;
	I OPTION'="" G OLD
	;
	; New report
	;
	I $P(HEADER,"|",6)<100 S FORMHDG="3;3;0" ; Turn on column heading option
	;
	S ID="PAGE-HEADER" D LINE(ID) S LEVEL=LEVEL+4
	S X=$ZP(^DBTBL(%LIBS,5,RID,11))			; Last key level
	F I=1:1:10 I $D(^DBTBL(%LIBS,5,RID,I)) D	; Display each level
	.	;
	.	S ID=$P(^(I),"|",1)
	.	I I'=X,'$D(^DBTBL(%LIBS,5,RID,ID)) Q	; Skip levels without
	.	S ID="["_$P(ID,",",2)			; data (except DETAIL	
	.	D LINE(ID) S LEVEL=LEVEL+2		; level)
	;
	; Page Trailer 
	;
	S ID="PAGE-TRAILER" D LINE(ID) S LEVEL=LEVEL+2
	;
	S ID="SUMMARY" D LINE(ID) S LEVEL=LEVEL+1
	;
	S H=$$HEADER^FORMINIT(0) ; all attributes off
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	Q
	;
OLD	;
	;
	I $O(^DBTBL(%LIBS,5,RID,"@PH",100)) D DSP("@PH",1)
	;
	; Header & Detail section for all levels
	;
	F I=1:1:10 Q:'$D(^DBTBL(%LIBS,5,RID,I))  S N=$P(^(I),"|",1) D DSP(N,1),DSP(N,2)
	;
	; Trailer section
	;
	F I=10:-1:1 I $D(^DBTBL(%LIBS,5,RID,I)) S N=$P(^(I),"|",1) D DSP(N,3)
	;
	; Page Trailer (@PT)
	;
	I $O(^DBTBL(%LIBS,5,RID,"@PH",100)) D DSP("@PH",3)
	;
	; Report Summary (@RS)
	;
	I $ZP(M(""))'<LEVEL S LEVEL=$ZP(M(""))+1
	;
	D DSP("@RS",1)
	Q
	;
	;
DSP(N,REG)	; Build the OOE internal display format M() and D()
	;
	; N   = report section @PH , groups , @PH , @RS
	; REG = Section region 1 (header) 2 (detail) 3(trailer)
	;
	N I,REGION
	;
	S REGION=$G(^DBTBL(%LIBS,DBOPT,RID,N,0)) ; header,detail,summary
	S MK=N I MK["[" S MK="["_$P(MK,",",2)
	;
	I MK="@RS" S MK="SUMMARY"
	I MK="@PH",REG=1 S MK="PAGE-HEADER"
	I MK="@PH",REG=3 S MK="PAGE-TRAILER"
	;
	; Page Header Marker
	;
	I $O(^DBTBL(%LIBS,DBOPT,RID,N,100))'="" G BLD
	;
	; Repeat field or suppress line option ON ?
	;
	I N["@",N'="@PT",'$G(ZMARKER(MK)) D LINE(MK) S LEVEL=LEVEL+1
	Q
	;
BLD	;
	;
	N MKZ
	I REG[1 D BLDHDR
	I REG[2 D BLDDTL
	I REG[3 D BLDTRL
	Q
	;
BLDHDR	;
	;
	S zmin=1000,zmax=REGION*1000+999,zoff=0
	;
	S Z123=LEVEL,MKZ=MK I MKZ["[" S MKZ=MKZ_"-H"
	;
	I $G(^(27)) S zslf(MK_"-H")=LEVEL_","_(^(27)+LEVEL)
	;
	S OLD=$G(^(26)) I $$SL D ADJBL(OLD,.NEW,Z123) S zsbl(MKZ)=LEVEL_","_NEW
	;
	I '$$DATA Q
	;
	I MK["[" D LINE(MK_"-H")
	E  D LINE(MK)
	;
	S ER=0 F SEQ=101:1 Q:'$D(^DBTBL(%LIBS,5,RID,N,SEQ))  D BUILD I ER Q
	;
	S LEVEL=y+1 S LEVEL=LEVEL+(zmax\1000)-(XP1\1000)
	Q
	;
BLDDTL	;
	;
	; Group Detail
	;
	S zmin=REGION+2*1000,zmax=$P(REGION,",",2)*1000+zmin-1,zoff=REGION+1
	;
	;
	S Z123=LEVEL-^(0)-1
	;
	I $G(^DBTBL(%LIBS,5,RID,N,25))'="" S zrf(MK)=$P(^(25),"|",3,4)
	;
	I '$$DATA Q
	;
	S OLD=$G(^(26)) I $$SL D ADJBL(OLD,.NEW,Z123) S zsbl(MK)=LEVEL_","_NEW
	;
	D LINE(MK)
	;
	S ER=0 F SEQ=101:1 Q:'$D(^DBTBL(%LIBS,5,RID,N,SEQ))  D BUILD I ER Q
	;
	S LEVEL=y+1,LEVEL=LEVEL+(zmax\1000)-(XP1\1000)
	;	
	Q
	;
BLDTRL	;
	; Trailer Section
	;
	;
	;I $P($G(D(LEVEL-1,1)),dl,1)?1"#"1E.E S LEVEL=LEVEL-1
	;
	S MKZ=MK I MKZ["[" S MKZ=MKZ_"-T"
	;
	S Z123=LEVEL-^(0)-$P(^(0),",",2)-2
	;
	S zmin=REGION+$P(REGION,",",2)+3*1000,zoff=zmin\1000
	S zmax=$P(REGION,",",3)*1000+zmin-1
	;
	I '$$DATA Q
	;
	S OLD=$G(^(26))
	I $$SL D ADJBL(OLD,.NEW,Z123) S zsbl(MKZ)=LEVEL_","_NEW
	;
	I MK["[" D LINE(MK_"-T")
	E  D LINE(MK)
	;
	S LEVEL=LEVEL+1,y=LEVEL
	;
	S ER=0 F SEQ=101:1 Q:'$D(^DBTBL(%LIBS,5,RID,N,SEQ))  D BUILD I ER  Q
	;
	S ER=0
	S LEVEL=y+1,LEVEL=LEVEL+(zmax\1000)-(P(1)\1000)
	;
	Q
	;
DATA()	;
	N ON
	S ON=0
	F I=101:1 Q:'$D(^DBTBL(%LIBS,5,RID,N,I))  I ^(I)'<zmin,^(I)'>zmax S ON=1 Q
	Q ON
	;
SL()	;
	;
	N ON,I,L,J,K
	I OLD="" Q 0
	S ON=0,L=$L(OLD,",")
	;
	F I=1:1:L D SL1
	;
	F I=zmin\1000:1:(zmax+1\1000) I $D(J(I)) S ON=1,J(I)=1
	I 'ON Q 0
	;
	; Create new SL status
	;
	S I="" F  S I=$O(J(I)) Q:I=""  I 'J(I) K J(I)
	S I=$O(J("")),J=$ZP(J("")),K=I,OLD=""
	F L=I:1:J I '$G(J(L)) S OLD=OLD_K_"-"_(L-1)_",",K=L
	I K'=J S OLD=OLD_K_"-"_J
	I OLD="" S OLD=K
	I $E(OLD,$L(OLD))="," S OLD=$E(OLD,1,$L(OLD)-1)
	Q 1
	;
SL1	;
	S Z=$P(OLD,",",I),Z1=$P(Z,"-",2),Z=+Z I Z1="" S Z1=Z
	;
	F J=Z:1:Z1 S J(J)=""
	Q
	;
BUILD	;
	;
	S X=$TR(^(SEQ),$C(124)_$$BYTECHAR^SQLUTL(128),$C(0,124))
	F I=1:1:15 S P(I)=$P(X,$C(0),I)
	;
	I P(1)<zmin Q
	I P(1)>zmax S ER=SEQ Q
	;
	K DQP
	;
	; Trailer section
	;
	S XP1=P(1)
	;
	S y=P(1)\1000+LEVEL-zoff,x=P(1)#1000 S:x<1 x=1
	S ox=x+$L(P(11)) Q:y<1
	S X=$F(P(5),("["_%LIBS)) I X S P(5)="["_$E(P(5),X+1,9999) ; Strip %LIBS
	;
	; Prompt
	;
	S M(y,x)=$C(64,0,0,0,0,0)_P(7)
	;
	; Convert TEXT data with PRE/POST PROC into <<"TEXT">> variable syntax
	;
	I P(8)+P(9),$E(P(6))="@",P(7)'?1"<<"1E.E1">>",$E(P(7))'="@"
	E  G BUILD9
	;
	D VARNAM1
	S Z="",$P(Z,"x",P(3)+1)="",M(y,x)=$C(64,0,0,0,0,0)_Z Q
	;
BUILD9	;
	I $E(P(6))="@","<@"'[$E(P(7)),P(7)'?.E1"["1E.E1"]"1E.E Q  ; This is not a data item
	I $E(P(6))="@",$E(P(7))="<",P(7)'["<<" Q
	;
	; Define data objects
	;
	S X=$F(P(6),("["_%LIBS)) I X S P(6)="["_$E(P(6),X+1,9999) ; Strip %LIBS
	I $E(P(6))'="@" S $P(DQP,dl,1)=P(6) ;  Data item
	E  S $P(DQP,dl,1)=P(7) ; <<var>>
	S $P(DQP,dl,2)=P(4) ;  Print edit
	;
	S $P(DQP,dl,3)=P(3) ;  Field length
	;
	I P(7)?1"<<"1E.E1">>",$L(P(7),">>")=2 D VARNAM		; <<VAR>>
	I $E(P(7))="@" D FUNSTAT
	;
	; Data item pre/post processor
	;
	I P(8)+P(9) D LOADPP S $P(DQP,dl,13)=PR,$P(DQP,dl,14)=PO
	;
	I P(7)'?1"@CHR".E G BUILD1
	;
	; Convert @CHR to string format
	;
	S zc=$E($P(P(7),")",1),6,99),zs=$P(zc,",",2),zc=$P(zc,",",1)
	I zs="" s zs=RPTSIZE
	s z="",$P(z,zc,zs+1)=""
	S M(y,ox)=$C(64,0,0,0,0,0)_z,D(y,ox)=DQP
	;
	;
	K zc,zs,z
	;
	Q
VARNAM	; <<VAR,FMT,LEN>>
	;
	N Z,Z1
	S Z=$E($P(P(7),">>",1),3,99)
	I Z["$P(" Q
	I Z["$L(" Q
	I Z["_" Q
	I Z["$E(" Q
	I Z["^" Q
	I Z["$J(" Q
	I Z["[" Q
	;
	; <<var,fmt1,fmt2,size)
	;
	S Z1=$$FNDVAR(Z)
	S $P(DQP,dl,1)="<<"_Z1_">>" ; Variable name
	;
	S Z=$P(Z,Z1,2,99)
	I Z'="" S Z1=$L(Z,","),$P(DQP,dl,3)=$P(Z,",",Z1),$P(DQP,dl,2)=$P(Z,",",2,Z1-1)
	;
	G VARNAM2
VARNAM1	;
	; Patch for text data with pre/post processor
	;
	N z
	S $P(z,"x",P(3)+1)=""
	S DQP=P(7)_dl_"T"_dl_P(3)
VARNAM2	; 
	D LOADPP S $P(DQP,dl,13)=PR,$P(DQP,dl,14)=PO
	S D(y,ox)=DQP
	S M(y,ox)=$C(64,0,0,0,0,0)_P(7)
	Q
FUNSTAT	;
	; @TOT , @MIN  , @MAX  , @AVG
	;
	N z,L,CALC
	;
	; Computed Operation  	@TOT([FID]DI)/@TOT([FID]DI,...)
	;
	S CALC=0
	F I="+","-","*","\","/","#" I P(7)[I S CALC=1 Q
	;
	; @FUN(ITEM,GRP,FMT,SIZE)
	;
	I $E(P(7))="@" S $P(DQP,dl,1)=$P(P(7),"(",1) ; @FUN
	;
	I $P(DQP,dl,1)="@CNT" D FUNCNT Q
	I $P(DQP,dl,1)="@CHR" D FUNCHR Q
	I $P(DQP,dl,1)="@TBL" D FUNTBL Q
	;
	S L=$L(P(7),",")
	;
	; @FUN(ITEM,GRP,FMT1,FMT2,...,LEN)
	;
	I L>3 S $P(DQP,dl,2)=$P(P(7),",",3,L-1),$P(DQP,dl,3)=$P(P(7),",",L)+0
	;
	S z=$P($P(P(7),",",1),"(",2,9) ; Stat on data item
	;-----------------------------------------------------------------------
	; *** BC - 02/28/94  convert @FUN(var) and @FUN([fid]di) from v3.5 to 4.1 OOE format
	;
	I $E(z)'="(",$E(z,$L(z))=")" S z=$E(z,1,$L(z)-1)
	;-----------------------------------------------------------------------
	S $P(DQP,dl,4)=z
	S $P(DQP,dl,5)=$S($P(P(7),",",2)=0:"R",1:"G")
	;
	I 'CALC Q			; 05/27/93 BC
	I z?1"<<"1E.E1">>" Q		; @FUN(<<...>>,,fmt,size)
	S $P(DQP,dl,1)=P(7),$P(DQP,dl,4)="",$P(DQP,dl,5)=""
	Q
FUNCNT	;
	; @CNT  @CNT()  @CNT(0)  @CNT(0,FMT,LEN)
	;
	S $P(DQP,dl,2)="N"
	I $L(P(7),",")=3 S $P(DQP,dl,2)=$P(P(7),",",2),$P(DQP,dl,3)=$P(P(7),",",3)+0
	S z=$E($P(P(7),"(",2)),$P(DQP,dl,5)=$S(z=0:"R",1:"G")
	Q
FUNCHR	;
	S z=$P($P(P(7),",",1),"(",2) ; Character
	S z=$P(z,",",1),$P(DQP,dl,4)=$P(z,")",1)
	S z=$P(P(7),",",2)+0 I z>0 S $P(DQP,dl,3)=z
	E  S $P(DQP,dl,3)=$P(^DBTBL(%LIBS,5,RID,0),"|",5) ; Report Width
	S $P(DQP,dl,2)="T"
	Q
FUNTBL	;
	S z=$P($P(P(7),",",1),"(",2) ; Table Name
	S z=$P(z,",",1),$P(DQP,dl,4)=$P(z,")",1)
	;
	Q
BUILD1	;
	;
	I $E(DQP)'="@" G BUILD2
	;
	;S z=$P(DQP,",",1),z=$P(z,"(",2) I z'?1"["1E.E1"]".E G BUILD2
	;
	;S z2=$P(DQP,",",2),$P(DQP,dl,1)=$P(DQP,"(",1),$P(DQP,dl,4)=z
	;S $P(DQP,dl,5)=$S(z2=0:"R",1:"G")
	;
BUILD2	;
	;
	D OBJ(DQP)
	;
	I '$D(a) S H=$$HEADER^FORMINIT(0)
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	;
	S D(y,ox)=DQP,M(y,ox)=H_m
	;
	Q
	;
MAPV	; Map DQ video options into VT220 escapes
	;
	K Z
	F I=1:1 S Z=$P(X,",",I) Q:Z=""  S Z=$P("|1|7|4|5|#6","|",$F("012345",Z)-1) I Z'="" S Z(Z)=""
	S X="",Z="" F I=2:1 S Z=$O(Z(Z)) Q:Z=""  S $P(X,";",I)=Z
	Q
	;
SAVE(ZMSG)	; Prompt to file Yes or No
	;
	;
	N N
	K DBTBL5
	;
	S DBTBL5=^DBTBL(%LIBS,5,RID)
	;
	I $G(%LIBS)="" S %LIBS=$G(^CUVAR("%LIBS")) I %LIBS="" S %LIBS="SYSDEV"
	;
	N OPTION,MENUID
	;
	S OPTION(1)=ORGRID
	S MENUID=105 I $G(ZMSG)'="" S MENUID=106	; *** BC - save option 10/25/93
	S OPTION=$$^DBSMBAR(MENUID,"","","",.OPTION) I 'OPTION Q -1	; ***
	;
	; ========== Save report control page information
	;
	S SAVRID=RID,N=""
	;
	F  S N=$ZP(^DBTBL(%LIBS,5,RID,N)) Q:N=""  S:$D(^(N))#10 DBTBL5(N)=^(N) D SAVE0
	;
	I OPTION=1 G SAVE1
	I OPTION=2 I '$$GETNAME() Q 0
	G SAVE1
SAVE0	;
	S Z=""
	F  S Z=$O(^DBTBL(%LIBS,5,RID,N,Z)) Q:Z=""!(Z>99)  D SAV0A
	Q
SAV0A	;
	I Z=25!(Z=26)!(Z=27) Q
	S DBTBL5(N,Z)=^(Z)
	Q
	;
SAVE1	;
	;
	S $P(DBTBL5(0),"|",3)=+$H
	S $P(DBTBL5(0),"|",15)=$$USERNAM^%ZFUNC	; Last Updated (date and user)
	D ST8^FORMINIT
	S DBTBL5(-5)=ST8 ; Save current screen status
	;
	I OPTION=2 S $P(DBTBL5(0),"|",2)="" ; Remove PGM name
	;
	E  S RID=ORGRID
	;
	; Remove old DATA ITEM index information
	;
	I $D(^DBTBL(%LIBS,5,RID)) D INDEX(RID,"D")
	;
	D ^FORMDQ5A
	;
	W $$MSG^FORM(RID_" Saved")	; *** BC - 11/02/93
	;
	; Create new DATA ITEM x-ref file ^DBSINDX
	;
	D INDEX(RID,"A")
	;
	;
	S RID=SAVRID
	Q 1
	;
	;
INDEX(ID,DQFUN)	;
	;
	; ADD/DELETE index information
	;
	N (%DB,%LIBS,ID,DQFUN)
	;
	S DBOPT=5
	;
	D ^DBSUTL3
	Q
	;
OBJ(VAR)	;
	;
	K a,d,m
	;
	N F,L,Z
	;
	S d=$P(VAR,dl,1),F=$P(VAR,dl,2),L=$P(VAR,dl,3)
	I 'L S L=1
	;
	; Object
	;
	; @FUN
	;
	I $E(d)="@" S Z=$$TYPE(F,L) D ADJ Q
	;
	; <<...>>
	;
	I $E(d,1,2)="<<" S Z=$$TYPE(F,L) D ADJ Q
	; [FID]D
	;
	I "[+-"[$E(d) S Z=$$TYPE(F,L) D ADJ Q
	;
	; #marker
	;
	I $E(d)="#" D MARKER Q
	;
	S m=d
	Q
	;
ADJ	;
	S H=$$HEADER^FORMINIT(0) ; Normal Image
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	S m=Z
	Q
	;
MARKER	;
	; #marker
	;
	N Z1,Z2,Z3,GROUP
	I '$D(zline) S zline="",$P(zline,"qqqqqqqqqq",13)=""
	S Z=$E(d,2,99) I Z'["[" S ZMARKER(Z)=1,ZNM=""
	E  S ZMARKER($P(Z,"]",2))=1
	;
	S GROUP=Z
	S m=$$MRKDSP^FORMDQ5D(Z)
	;
	;
	I $D(zsbl(GROUP)) s m=$E(m,1,2)_"h"_$E(m,4,999)
	I $D(zslf(GROUP)) s m=$E(m,1,3)_"e"_$E(m,5,999)
	I '$D(zrf(GROUP)) Q
	S Z2=$P(zrf(GROUP),"|",1),Z3=$P(zrf(GROUP),"|",2)*Z2+1
	F Z1=Z2:Z2:Z3 S m=$E(m,1,Z1)_"x"_$E(m,Z1+2,999)
	;
	Q
	;
TYPE(FMT,LEN)	;
	;
	N Z,Z1
	I $G(d)="@CHR" S Z="" F Z1=1:1:LEN S Z=Z_$P(DQP,dl,4)
	I  Q Z
	I (FMT="D") Q $E("mm/dd/yyyy",1,LEN) ;		Date
	I FMT["DD"!(FMT["MM")!(FMT["YY") Q FMT
	;
	I FMT="C" Q $E("hh:mm AM",1,LEN) ;		Time
	;						; *** 08/15/96
	I "TUFLM"[FMT S $P(Z,"x",LEN+1)="" Q Z ;	Text (xxx)
	I FMT="T,JR"!(FMT="JR,T") S $P(Z,"x",LEN+1)="" Q Z ; *** BC - Change display fromat to text (xxxx) 09/17/93
	I FMT="TW" S $P(Z,"T",LEN+1)="" Q Z ;		Text wrap option (TTT) 
	;
	S $P(Z,9,LEN+1)="" ;				Numeric (999)
	I FMT="N" Q Z
	;
	I FMT?1"RD"1N.N S Z1=$P(FMT,"RD",2),Z=$J(Z,LEN,Z1)
	I FMT["$" S Z=$J(Z,LEN,2)
	I FMT["RI",FMT["E" S Z=$FN(Z,",",0)
	I FMT["E",FMT'["EM",FMT'["RI" S Z=$FN(Z,",",2)
	I Z[0 S Z=$TR(Z,0,9)
	S Z=$E(Z,$L(Z)-LEN+1,999)
	Q Z
	;
CTLPAG	; Load the control page in screen ^DBTBL5
	;
	I '$D(%UID) S %UID=1
	;
	S SCRCLR(0)="Clear to end of page"
	S SCRCLR(1)="Clear entire page"
	;
	S %O=0,PGM=$$GETPGM("DBTBL5") Q:PGM=""  D ^@PGM
	D TRMSET^FORMINIT
	Q
	;
GETPGM(RID)	; Access run-time routine name
	;
	D ^URID Q PGM
	Q ""
	;
	;
GETNAME()	; Get a new name
	;
GETRID	;
	;
	;---------- Convert to uppercase report name (RFSB)
	W BTMPAG
	S X=$$^FORMREAD("",12,"Report Name","U") I X="" Q 0	; *** BC - 11/02/93
	I X'=RID,$D(^DBTBL(%LIBS,5,X)) W $$MSG^FORM("Report already exists",1) G GETRID		; *** BC - 11/02/93
	S RID=X Q 1
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H"
	;
	; ---------------------------------
	;
	; Build single object
	;
	;  INPUT:  VAR = name | fmt | size
	;
	; OUTPUT:    D   object id
	;            M   display image
	;            A   display attribute
	;
LINE(MESSAGE)	;
	;
	S DQP="#"_MESSAGE_dl_"T"_dl_120
	;
	I MESSAGE?1"@"1E.E S ZMARKER(MESSAGE)=1
	;
	D OBJ(DQP)
	;
	S D(LEVEL,1)=DQP,M(LEVEL,1)=H_m,y=LEVEL
	Q
	;
LOADPP	; Load pre processors & Post processors if necessary
	;
	N I,M
	S PR=$ZP(PP(""))+1,PO=PR+1 ; Pre & Post processor keys
	S M="" ; Load the pre processor if there is one
	F I=1:1 S M=$O(^DBTBL(%LIBS,5,RID,N,SEQ,M)) Q:M=""!(M>20.99)  S PP(PR,I)=^(M)
	S M=20.99 ; Load the post processor if there is one
	F I=1:1 S M=$O(^DBTBL(%LIBS,5,RID,N,SEQ,M)) Q:M=""  S PP(PO,I)=^(M)
	I $D(PP(PR))=0 S PR=""
	I $D(PP(PO))=0 S PO=""
	Q
ADJBL(OLD,NEW,OFFSET)	; 
	;
	N S1,S2,S3,I,X
	S S1=$L(OLD,","),NEW=""
	F I=1:1:S1 D ADJ1
	I $E(NEW,$L(NEW))="," S NEW=$E(NEW,1,$L(NEW)-1)
	Q
ADJ1	;
	S X=$P(OLD,",",I) I X="" Q
	S NEW=NEW_(X+OFFSET)
	I X["-" S NEW=NEW_"-"_($P(X,"-",2)+OFFSET)
	S NEW=NEW_","
	Q
	;
FNDVAR(X)	; Prse variable syntax  <<var,fmt,size>>
	;
	N L
	I X'["(" Q $P(X,",",1)
	S L=$L(X,")"),L=$P(X,")",1,L-1) Q L_$P($P(X,L,2),",",1)
	;
