V01S318	;; -  - 5.3 - SID= <DBTBL5H> Report Definition - Header
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,%A",VSID="DBTBL5H",VPGM=$T(+0),VSNAME="Report Definition - Header"
	S VFSN("DBTBL5H")="%A"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
V5	I %O=5 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
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
	S %A(0)=$G(%A(0)),%A=$G(%A)
	Q
VLOD	; User defined access section
	;
	S %REPEAT=15 I '%O Q
	S %A=^DBTBL(%LIBS,5,RID)
	F I=-4,0:1:11 S %A(I)="" I $D(^DBTBL(%LIBS,5,RID,I)) S %A(I)=^(I)
	Q
VLODDQ	; Original VLOD section
	;
	S %A(0)=^DBTBL(LIBS,5,RID,0)
	S %A=^DBTBL(LIBS,5,RID)
	Q
VPR	; Display screen prompts
	;
	S VO="56||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(4)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(3,17,51,2,0,0,0,0,0,0)_"01TR E P O R T   W R I T E R   C O N T R O L   P A G E"
	S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,3,11,0,0,0,0,0,0,0)_"01T Report ID:"
	S VO(11)=$C(5,28,5,0,0,0,0,0,0,0)_"01TUser:"
	S VO(12)=$C(5,56,13,0,0,0,0,0,0,0)_"01TLast Updated:"
	S VO(13)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(7,6,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(18)=$C(7,61,8,0,0,0,0,0,0,0)_"01TProgram:"
	S VO(19)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(9,3,16,1,0,0,0,0,0,0)_"01T Access File(s):"
	S VO(24)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(11,5,14,1,0,0,0,0,0,0)_"01T Report Width:"
	S VO(29)=$C(11,26,11,1,0,0,0,0,0,0)_"01T Page Size:"
	S VO(30)=$C(11,47,13,0,0,0,0,0,0,0)_"01T Banner Page:"
	S VO(31)=$C(11,63,9,0,0,0,0,0,0,0)_"01T Version:"
	S VO(32)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(34)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(13,4,14,0,0,0,0,0,0,0)_"01T Fixed Length:"
	S VO(37)=$C(13,25,22,0,0,0,0,0,0,0)_"01TDisable Field Browser:"
	S VO(38)=$C(13,54,19,0,0,0,0,0,0,0)_"01T Alignment Pattern:"
	S VO(39)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(40)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(43)=$C(15,4,28,0,0,0,0,0,0,0)_"01T Data Item Protection Logic:"
	S VO(44)=$C(15,56,17,0,0,0,0,0,0,0)_"01TSQL Query Syntax:"
	S VO(45)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(46)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(49)=$C(17,5,71,0,0,0,0,0,0,0)_"01T------------------------- Report Distribution -------------------------"
	S VO(50)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(51)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(52)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(53)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(54)=$C(19,6,26,0,0,0,0,0,0,0)_"01T Distribution Column Name:"
	S VO(55)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(56)=$C(20,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	Q
VDA	; Display screen data
	N V
	I %O=5 N %A,v1,RID
	I  S (%A,v1,RID)=""
	E  N v1
	E  S %A=$G(%A),v1=$G(%A(0)),RID=$G(RID)
	;
	;
	S VO="72|57|13|"
	S VO(57)=$C(5,15,12,2,0,0,0,0,0,0)_"01T"_RID
	S VO(58)=$C(5,34,20,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",15)
	S VO(59)=$C(5,70,10,2,0,0,0,0,0,0)_"01D"_$$DAT^%ZM($P(v1,"|",3))
	S VO(60)=$C(7,20,40,2,0,0,0,0,0,0)_"00T"_$P(%A,"|",1)
	S VO(61)=$C(7,70,8,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",2)
	S VO(62)=$C(9,20,60,2,0,0,0,0,0,0)_"00U"_$P(v1,"|",1)
	S VO(63)=$C(11,20,4,2,0,0,0,0,0,0)_"00N"_$P(v1,"|",5)
	S VO(64)=$C(11,38,8,2,0,0,0,0,0,0)_"00N"_$P(v1,"|",6)
	S VO(65)=$C(11,61,1,2,0,0,0,0,0,0)_"00L"_$S($P(v1,"|",16):"Y",1:"N")
	S VO(66)=$C(11,73,6,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",10)
	S VO(67)=$C(13,19,1,2,0,0,0,0,0,0)_"00L"_$S($P(v1,"|",8):"Y",1:"N")
	S VO(68)=$C(13,48,1,2,0,0,0,0,0,0)_"00L"_$S($P(v1,"|",9):"Y",1:"N")
	S VO(69)=$C(13,74,1,2,0,0,0,0,0,0)_"00L"_$S($P(v1,"|",17):"Y",1:"N")
	S VO(70)=$C(15,33,1,2,0,0,0,0,0,0)_"00N"_$P(v1,"|",7)
	S VO(71)=$C(15,74,1,2,0,0,0,0,0,0)_"00L"_$S($P(v1,"|",13):"Y",1:"N")
	S VO(72)=$C(19,33,30,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",20)
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=16,VPT=1,VPB=20,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL5H"
	S OLNTB=20001
	;
	S VFSN("DBTBL5H")="%A"
	;
	; 
	;
	;
	; ===============  Set up entry/error checking control table
	;
VTAB1	D VTBL
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
	S %TAB(1)=$C(4,14,12)_"21T12402|3*|[DBTBL5H]RID"
	S %TAB(2)=$C(4,33,20)_"21T12415|0|[DBTBL5H]UID"
	S %TAB(3)=$C(4,69,10)_"21D12403|0|[DBTBL5H]DATE"
	S %TAB(4)=$C(6,19,40)_"01T12401||[DBTBL5H]DESC"
	S %TAB(5)=$C(6,69,8)_"21T12402|0|[DBTBL5H]PGM"
	S %TAB(6)=$C(8,19,60)_"01U12401|0|[DBTBL5H]PFID|[DBTBL1]||D VP1^V01S318"
	S %TAB(7)=$C(10,19,4)_"01N12405|0|[DBTBL5H]RSIZE|||D VP2^V01S318||10|9999"
	S %TAB(8)=$C(10,37,8)_"01N12406|0|[DBTBL5H]PSIZE|||D VP3^V01S318||1|99999999"
	S %TAB(9)=$C(10,60,1)_"00L12416|0|[DBTBL5H]BANNER"
	S %TAB(10)=$C(10,72,6)_"00T12410|0|[DBTBL5H]VER"
	S %TAB(11)=$C(12,18,1)_"00L12408|0|[DBTBL5H]FIXLEN|||D VP4^V01S318"
	S %TAB(12)=$C(12,47,1)_"00L12409|0|[DBTBL5H]NORB"
	S %TAB(13)=$C(12,73,1)_"00L12417|0|[DBTBL5H]ALIGN"
	S %TAB(14)=$C(14,32,1)_"00N12407|0|[DBTBL5H]RESFLG|[DBCTL]CODE,DESC:QU ""[DBCTL]NAME=""""RWPROT"""""""
	S %TAB(15)=$C(14,73,1)_"00L12413|0|[DBTBL5H]MSQL"
	S %TAB(16)=$C(18,32,30)_"00T12420|0|[DBTBL5H]DISTKEY|||D VP5^V01S318"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	; ----- Revision History
	;
	;            Modified to pull code from pre/post-processor library DBSFILES
	;	      into this section.
	;
	;	      Eliminated checking for implicits.
	;
	;	      Removed literal keys from SEQBY
	;
	I X="" Q
	;
	N IX,IY,IZ,SAVX
	;
	I X["," S I(3)=""
	S FILES=X D ^DBSFVER I ER Q
	S (PFID,FID)=$P(FILES,",",1)
	;
	S SEQBY="",IX=^DBTBL("SYSDEV",1,FID,16)
	F IZ=1:1:$L(IX,",") D
	.	S IY=$P(IX,",",IZ)
	.	; Don't include literals
	.	Q:$E(IY)=""""
	.	Q:IY?1N.N
	.	Q:IY?.N1".".N
	.	S SEQBY=SEQBY_"[SYSDEV,"_FID_"]"_IY_"|"
	S SEQBY=$E(SEQBY,1,$L(SEQBY)-1)
	Q
	;
	Q
VP2	;
	;
	I X?1N.N S RSIZE=X
	;
	I X<81 Q
	;
	; DISABLE BPS MODE
	;
	D DEFAULT^DBSMACRO("[DBTBL5H]BURMODE",0,"1","0","0")
	Q
VP3	;
	;
	; skip banner page , turn on alignment pattern option
	;
	I $G(%O) Q
	;
	I X<100 Q
	I $P(%A(0),"|",8) Q
	;
	D DEFAULT^DBSMACRO("[DBTBL5H]BANNER",0,"1","0","0")
	D DEFAULT^DBSMACRO("[DBTBL5H]ALIGN",1,"1","0","0")
	Q
VP4	;
	;
	; Skip alignment pattern if fixed length record
	;
	I $G(%O) Q
	;
	I X D DEFAULT^DBSMACRO("[DBTBL5H]ALIGN",0,"1","0","0")
	Q
VP5	;
	Q:X=""
	N Z
	S Z=$$CVTREF^DBSDD(X,$P(%A(0),"|",1)) Q:ER
	S X=$P(Z,".",2,3)
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
