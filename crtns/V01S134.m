V01S134	;; -  - 5.3 - SID= <DBTBL5H1> Report Definition - Header (part 2)
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/13/2007 15:33 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,%A",VSID="DBTBL5H1",VPGM=$T(+0),VSNAME="Report Definition - Header (part 2)"
	S VFSN("DBTBL5H")="%A"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=12 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
	;
	S ER=0 D VSCRPRE I ER Q  ; Screen Pre-Processor
	;
	I '%O D VNEW,VPR,VDA
	I %O D VLOD Q:$G(ER)  D VPR,VDA
	;
	; ====================  Display Form
	;
	D ^DBSPNT()
	;
	I %O=2!(%O=3) D ^DBSCRT8A X:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	;
	; ====================  Set up data entry control table
	;
vTBL	I %O<2 D VTAB
	Q
	;
VNEW	; Initialize arrays if %O=0
	;
	D VLOD
	;
	;
VDEF	;
	;
	I ($G(LIBS)="")!($G(RID)="") Q
	I $D(^DBTBL(LIBS,5,RID)) Q  ; Already created
	S %A=$G(%A)
	S %A(0)=$G(%A(0)),%A(1)=$G(%A(1)),%A(2)=$G(%A(2)),%A(3)=$G(%A(3)),%A(4)=$G(%A(4)),%A(5)=$G(%A(5)),%A(6)=$G(%A(6)),%A(7)=$G(%A(7)),%A(8)=$G(%A(8)),%A(9)=$G(%A(9)),%A(10)=$G(%A(10))
	I $P(%A(0),"|",17)="" S $P(%A(0),"|",17)=0   ; DBTBL5H.ALIGN
	I $P(%A(0),"|",16)="" S $P(%A(0),"|",16)=1   ; DBTBL5H.BANNER
	I $P(%A(0),"|",4)="" S $P(%A(0),"|",4)=0   ; DBTBL5H.BURMODE
	I $P(%A(0),"|",3)="" S $P(%A(0),"|",3)=+$H   ; DBTBL5H.DATE
	I $P(%A(0),"|",8)="" S $P(%A(0),"|",8)=0   ; DBTBL5H.FIXLEN
	I $P(%A(0),"|",18)="" S $P(%A(0),"|",18)=1   ; DBTBL5H.NEWCOMP
	I $P(%A(1),"|",4)="" S $P(%A(1),"|",4)="*"   ; DBTBL5H.PRNG
	I $P(%A(10),"|",4)="" S $P(%A(10),"|",4)="*"   ; DBTBL5H.PRNG10
	I $P(%A(2),"|",4)="" S $P(%A(2),"|",4)="*"   ; DBTBL5H.PRNG2
	I $P(%A(3),"|",4)="" S $P(%A(3),"|",4)="*"   ; DBTBL5H.PRNG3
	I $P(%A(4),"|",4)="" S $P(%A(4),"|",4)="*"   ; DBTBL5H.PRNG4
	I $P(%A(5),"|",4)="" S $P(%A(5),"|",4)="*"   ; DBTBL5H.PRNG5
	I $P(%A(6),"|",4)="" S $P(%A(6),"|",4)="*"   ; DBTBL5H.PRNG6
	I $P(%A(7),"|",4)="" S $P(%A(7),"|",4)="*"   ; DBTBL5H.PRNG7
	I $P(%A(8),"|",4)="" S $P(%A(8),"|",4)="*"   ; DBTBL5H.PRNG8
	I $P(%A(9),"|",4)="" S $P(%A(9),"|",4)="*"   ; DBTBL5H.PRNG9
	I $P(%A(0),"|",6)="" S $P(%A(0),"|",6)=60   ; DBTBL5H.PSIZE
	I $P(%A(0),"|",7)="" S $P(%A(0),"|",7)=0   ; DBTBL5H.RESFLG
	I $P(%A(0),"|",5)="" S $P(%A(0),"|",5)=80   ; DBTBL5H.RSIZE
	I $P(%A(1),"|",5)="" S $P(%A(1),"|",5)="A"   ; DBTBL5H.SORTORD
	I $P(%A(10),"|",5)="" S $P(%A(10),"|",5)="A"   ; DBTBL5H.SORTORD10
	I $P(%A(2),"|",5)="" S $P(%A(2),"|",5)="A"   ; DBTBL5H.SORTORD2
	I $P(%A(3),"|",5)="" S $P(%A(3),"|",5)="A"   ; DBTBL5H.SORTORD3
	I $P(%A(4),"|",5)="" S $P(%A(4),"|",5)="A"   ; DBTBL5H.SORTORD4
	I $P(%A(5),"|",5)="" S $P(%A(5),"|",5)="A"   ; DBTBL5H.SORTORD5
	I $P(%A(6),"|",5)="" S $P(%A(6),"|",5)="A"   ; DBTBL5H.SORTORD6
	I $P(%A(7),"|",5)="" S $P(%A(7),"|",5)="A"   ; DBTBL5H.SORTORD7
	I $P(%A(8),"|",5)="" S $P(%A(8),"|",5)="A"   ; DBTBL5H.SORTORD8
	I $P(%A(9),"|",5)="" S $P(%A(9),"|",5)="A"   ; DBTBL5H.SORTORD9
	I $P(%A(0),"|",15)="" S $P(%A(0),"|",15)=$$USERNAM^%ZFUNC   ; DBTBL5H.UID
	I $P(%A(0),"|",10)="" S $P(%A(0),"|",10)=$$VERSION^DBSRWDRV   ; DBTBL5H.VER
	Q
	Q
VNEWDQ	; Original VNEW section
	;
	S %A(0)=$G(%A(0)),%A(1)=$G(%A(1))
	Q
VLOD	; User defined access section
	;
	I '$D(%REPEAT) S %REPEAT=12
	I '$D(%MODS) S %MODS=1
	S %REPEAT=10 I '%O Q
	S %A("RID")=^DBTBL(%LIBS,5,RID)
	F I=0:1:10 S %A(I)="" I $D(^DBTBL(%LIBS,5,RID,I)) S %A(I)=^(I)
	Q
VLODDQ	; Original VLOD section
	;
	S %A(0)=^DBTBL(LIBS,5,RID,0)
	S %A(1)=^DBTBL(LIBS,5,RID,1)
	Q
VPR	; Display screen prompts
	;
	S VO="30||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,19,51,2,0,0,0,0,0,0)_"01TR E P O R T   S E Q U E N C E   D E F I N I T I O N"
	S VO(4)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,2,15,0,0,0,0,0,0,0)_"01TAccess File(s):"
	S VO(11)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,4,13,1,0,0,0,0,0,0)_"01T Sequence by "
	S VO(18)=$C(8,29,13,1,0,0,0,0,0,0)_"01T New Page At "
	S VO(19)=$C(8,43,18,1,0,0,0,0,0,0)_"01T   Print Header   "
	S VO(20)=$C(8,62,12,1,0,0,0,0,0,0)_"01T   Minimum  "
	S VO(21)=$C(8,75,5,1,0,0,0,0,0,0)_"01TOrder"
	S VO(22)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(9,29,13,1,0,0,0,0,0,0)_"01T Key Breaks  "
	S VO(25)=$C(9,43,18,1,0,0,0,0,0,0)_"01T After Page Break "
	S VO(26)=$C(9,62,12,1,0,0,0,0,0,0)_"01T Print Lines"
	S VO(27)=$C(9,75,5,1,0,0,0,0,0,0)_"01T A/D "
	S VO(28)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(30)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	I '$D(%MODS) S %MODS=1
	S DY=11 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
	S VO=+VO_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO=VO+2,DY=DY+1
	Q
VDA	; Display screen data
	N V
	I %O=5 N v1
	I  S (v1)=""
	E  N v1
	E  S v1=$G(%A(0))
	;
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(5,18,59,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",1)
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+0,DY=11 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v2
	I  S (v2)=""
	E  N v2
	E  S (v2,%A(I))=$G(%A(I))
	;
	S VO(VX+1)=$C(DY,2,33,2,0,0,0,0,0,0)_"00U"_$P(v2,"|",1)
	S VO(VX+2)=$C(DY,38,1,2,0,0,0,0,0,0)_"00L"_$S($P(v2,"|",2):"Y",1:"N")
	S VO(VX+3)=$C(DY,51,1,2,0,0,0,0,0,0)_"00L"_$S($P(v2,"|",3):"Y",1:"N")
	S VO(VX+4)=$C(DY,68,2,2,0,0,0,0,0,0)_"00T"_$P(v2,"|",4)
	S VO(VX+5)=$C(DY,78,1,2,0,0,0,0,0,0)_"00U"_$P(v2,"|",5)
	S DY=DY+1,VX=VX+5
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=1,%MOD=5,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=10+%REPEAT,BLKSIZ=38*%REPEAT+59,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL5H",VSCRPP=1
	S OLNTB=VPB*1000
	;
	S VFSN("DBTBL5H")="%A"
	;
	F I=7:1:%MAX S %TAB(I)=""
	;
	;
	; ===============  Set up entry/error checking control table
	;
	D VTBL,VDEPRE I $G(ER) Q
	;
	D ^DBSCRT8 Q  ; data entry
	;
	Q
VREQ	; Create REQ() array
	;
	;
	Q
	;
VTBL	; Create %TAB(array)
	;
	; 1 2 3  4 5   6   7-9 10-11
	;
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	S %TAB(1)=$C(4,17,59)_"21U12401|0|[DBTBL5H]PFID|[DBTBL1]||||||||60"
	S %TAB(2)=$C(10,1,33)_"00U12401|1|[DBTBL5H]SEQ|[DBTBL1D]:QU ""[DBTBL1D]FID=<<XFID>>""||D VP1^V01S134|D VP2^V01S134"
	S %TAB(3)=$C(10,37,1)_"00L12402|1|[DBTBL5H]PGBK"
	S %TAB(4)=$C(10,50,1)_"00L12403|1|[DBTBL5H]PHDR"
	S %TAB(5)=$C(10,67,2)_"00T12404|1|[DBTBL5H]PRNG"
	S %TAB(6)=$C(10,77,1)_"00U12405|1|[DBTBL5H]SORTORD"
	;
	Q
	;
	;
VSPP	; Screen Post-Processor
	;
	; ----- Revision History -----------------------------------------------------
	; 08/16/05 - RussellDS - CR16908
	;	      Modify code so literal keys aren't required
	; ----------------------------------------------------------------------------
	;
	N X,Y,Z,DLIB,AKEYS,I
	I '$D(FILES) S FILES=$P(^DBTBL(%LIBS,5,RID,0),"|",1)
	;
	S DLIB=%LIBS,X="["_$P(FILES,",",1)_"]" D ^DBSDI I ER Q
	;
	; Keys required			; *** 10/16/96
	;
	S AKEYS=^DBTBL(LIB,1,FID,16)
	F I=1:1:$L(AKEYS,",") D
	.	S X=$P(AKEYS,",",I)
	.	Q:X?1N.N!($E(X)="""")		; Literal key
	.	S Z("["_%LIBS_","_FID_"]"_X)=""
	;
	F I=1:1:10 S X=$P($G(%A(I)),"|",1) I X'="" K Z(X)
	;
	; Missing Keys
	;
	I $O(Z(""))="" Q
	;
	I $P(%A(0),"|",18) Q           ; Client/Server RW
	S ER=1,RM=$$^MSG(7962)
	S X="" F  S X=$O(Z(X)) Q:X=""  S RM=RM_"["_$P(X,",",2)_" "
	Q
	Q
VDEPRE	; Data Entry Pre-processor
	;
	S PFID=$P(%A(0),"|",1)
	Q
	Q
	;
VPOS	; User defined post processor's
	;
VP1	;
	;----- Revision History ------------------------------------------------------
	;
	; 05/01/06 - RussellDS - CR20967
	;	      Moved code from DI^DBSFVER here since this is the only user
	;
	;-----------------------------------------------------------------------------
	;
	I X="",V="" D GOTO^DBSMACRO("NEXT") Q
	I  Q
	I X="" G DELETE
	;
	N vOLDX S vOLDX=X
	I X'="" D DIVER I ER S X=vOLDX Q
	;
	I z1=1 Q
	F I=1:1:z1-1 I $P(%A(I),"|",1)=X S ER=1 Q
	I ER=1 S RM=$$^MSG(871,X) Q
	;
	I $P(%A(I(1)),"|",4)="" D DEFAULT^DBSMACRO("[DBTBL5H]PRNG","*","1","0","0")
	I $P(%A(I(1)),"|",5)="" D DEFAULT^DBSMACRO("[DBTBL5H]SORTORD","A","1","0","0")
	Q
DELETE	;
	D DELETE^DBSMACRO("[DBTBL5H]PRNG","1","0")
	D DELETE^DBSMACRO("[DBTBL5H]SORTORD","1","0")
	D GOTO^DBSMACRO("NEXT") Q
	Q
	;
DIVER	
	S ER=0,RM=""
	I X="" Q
	I X[","!(X["[") S I(3)=""
	;
	I FILES[",",X'?1"[".E S X="["_$P(FILES,",",1)_"]"_X
	I X["[" S XF=$E($P(X,"]",1),2,99),XD=$P(X,"]",2)
	E  S XF=FILES,XD=X
	I XF["," S DLIB=$P(XF,",",1),XF=$P(XF,",",2)
	S ER=1 F I=1:1 S Z=$P(FILES,",",I) Q:Z=""  I Z=XF S ER=0 Q
	; Select valid file ID from list - ~p1
	I ER S RM=$$^MSG(2469,FILES) Q
	I XD="" S ER=2 Q
	S LIB=%LIBS,FID=XF
	; Invalid data item - ~p1
	I '$D(^DBTBL(LIB,1,FID,9,XD)) S ER=1,RM=$$^MSG(1298,XD) Q
	S RM=$P(^(XD),"|",10)
	S I(3)=""
	Q
VP2	;
	S FILES=$P(%A(0),"|",1)
	S XFID=$P(FILES,",",1)		; For table lookup
	;
	N I,II,J,K,X1,Z
	;
	S Z=FILES_"," ; FILES
	;
	I $P(%A(1),"|",1)'="" D  I $P(%A(1),"|",1)'="" Q
	.	; REMOVE OLD SEQUENCE BY INFORMATION
	.	S I=0
	.	F  S I=$O(%A(I)) Q:I=""  D
	..		I %A(I)="" Q
	..		S X1=$P(%A(I),"|",1),X1=$E($P(X1,"]",1),2,99)
	..		I X1["," S X1=$P(X1,",",2)
	..		I Z[(X1_",") Q  	 ; SAME FILE ID
	..		S %A(I)=""
	;
	S UX=""
	F I=1:1:10 S X=$P(SEQBY,"|",I) S:X'="" II=I D
	.	S J=I-1*10+1,K=9+I*1000
	.	S RM(J)=X_$E("_________________________________",1,33-$L(X))_"|"_(K+1) ; SEQBY 05/03/93 BC
	.	S RM(J+1)=$S(X'="":"Y",1:"_")_"|"_(K+37) ; KEY BREAK OPTION
	.	S RM(J+2)=$S(X'="":"Y",1:"_")_"|"_(K+50) ;  PRINT HEADER OPTION
	.	S RM(J+3)=$S(X'="":"* ",1:"__")_"|"_(K+67) ; MIN PRINT LINES
	.	S RM(J+4)=$S(X'="":"A",1:"_")_"|"_(K+77) ; A/D ORDER
	.	;
	.	I X'="" S %A(I)=X_"|1|1|*|A"
	.	E  S %A(I)=""
	;
	; CHANGE DEFAULT KEY BREAK OPTION TO "N" FOR LAST LEVEL KEY
	;
	S RM(99)="N|"_(9+II*1000+37),$P(%A(II),"|",2)=0
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
	;
VSCRPRE	; Screen Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	;
	S FILES=$P($G(^DBTBL(%LIBS,5,RID,0)),"|",1)
	;
	Q
