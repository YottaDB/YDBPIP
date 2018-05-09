V01S210	;; -  - 5.3 - SID= <DBTBL5SQ> Report Definition - Statistics
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:41 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,%A",VSID="DBTBL5SQ",VPGM=$T(+0),VSNAME="Report Definition - Statistics"
	S VFSN("DBTBL5H")="%A"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
V5	I %O=5 D VPR,VDA,V5^DBSPNT Q
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
	;
	S %A(11)=$G(%A(11)),%A(12)=$G(%A(12)),%A(13)=$G(%A(13)),%A(14)=$G(%A(14))
	S %A(15)=$G(%A(15)),%A(16)=$G(%A(16)),%A(17)=$G(%A(17)),%A(18)=$G(%A(18))
	S %A(19)=$G(%A(19)),%A(20)=$G(%A(20)),%A(21)=$G(%A(21)),%A(22)=$G(%A(22))
	S %A(23)=$G(%A(23)),%A(24)=$G(%A(24)),%A(25)=$G(%A(25)),%A(26)=$G(%A(26))
	S %A(27)=$G(%A(27)),%A(28)=$G(%A(28)),%A(29)=$G(%A(29)),%A(30)=$G(%A(30))
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
	;
VLOD	; Load data from disc - %O = (1-5)
	;
	I $G(%LOGID) D  Q
	. ;
	. D STUB^DBSCLI("VLOD^V01S210",61,,LIBS_$C(28)_RID,,"v") I ER K %RPC Q
	. I '$$ONLINE^DBSCLI() D VNEW Q   ;  init if offline
	. S %A(11)=$P(v,$C(28),1),%A(12)=$P(v,$C(28),2),%A(13)=$P(v,$C(28),3)
	. S %A(14)=$P(v,$C(28),4),%A(15)=$P(v,$C(28),5),%A(16)=$P(v,$C(28),6)
	. S %A(17)=$P(v,$C(28),7),%A(18)=$P(v,$C(28),8),%A(19)=$P(v,$C(28),9)
	. S %A(20)=$P(v,$C(28),10),%A(21)=$P(v,$C(28),11),%A(22)=$P(v,$C(28),12)
	. S %A(23)=$P(v,$C(28),13),%A(24)=$P(v,$C(28),14),%A(25)=$P(v,$C(28),15)
	. S %A(26)=$P(v,$C(28),16),%A(27)=$P(v,$C(28),17),%A(28)=$P(v,$C(28),18)
	. S %A(29)=$P(v,$C(28),19),%A(30)=$P(v,$C(28),20)
	;
	;
	I $D(%RPC) S LIBS=$P(%RPC,$C(28),1),RID=$P(%RPC,$C(28),2),%RPC="61,%A(11),%A(12),%A(13),%A(14),%A(15),%A(16),%A(17),%A(18),%A(19),%A(20)" D
	. S %RPC=%RPC_",%A(21),%A(22),%A(23),%A(24),%A(25),%A(26),%A(27),%A(28),%A(29),%A(30)"
	;
	S %A(11)=^DBTBL(LIBS,5,RID,11)
	S %A(12)=^DBTBL(LIBS,5,RID,12)
	S %A(13)=^DBTBL(LIBS,5,RID,13)
	S %A(14)=^DBTBL(LIBS,5,RID,14)
	S %A(15)=^DBTBL(LIBS,5,RID,15)
	S %A(16)=^DBTBL(LIBS,5,RID,16)
	S %A(17)=^DBTBL(LIBS,5,RID,17)
	S %A(18)=^DBTBL(LIBS,5,RID,18)
	S %A(19)=^DBTBL(LIBS,5,RID,19)
	S %A(20)=^DBTBL(LIBS,5,RID,20)
	S %A(21)=^DBTBL(LIBS,5,RID,21)
	S %A(22)=^DBTBL(LIBS,5,RID,22)
	S %A(23)=^DBTBL(LIBS,5,RID,23)
	S %A(24)=^DBTBL(LIBS,5,RID,24)
	S %A(25)=^DBTBL(LIBS,5,RID,25)
	S %A(26)=^DBTBL(LIBS,5,RID,26)
	S %A(27)=^DBTBL(LIBS,5,RID,27)
	S %A(28)=^DBTBL(LIBS,5,RID,28)
	S %A(29)=^DBTBL(LIBS,5,RID,29)
	S %A(30)=^DBTBL(LIBS,5,RID,30)
	Q
VPR	; Display screen prompts
	;
	S VO="48||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,6,11,1,0,0,0,0,0,0)_"01T Data Item "
	S VO(4)=$C(2,35,10,1,0,0,0,0,0,0)_"01T Based on "
	S VO(5)=$C(2,54,23,1,0,0,0,0,0,0)_"01T Statistics Increments "
	S VO(6)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(19)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(30)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(31)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(32)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(34)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(37)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(39)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(40)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(43)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(45)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(46)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(23,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(23,80,1,0,0,0,0,0,0,0)_"11Tx"
	Q
VDA	; Display screen data
	N V
	I %O=5 N v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
	I  S (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20)=""
	E  N v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20
	E  S v1=$G(%A(11)),v2=$G(%A(12)),v3=$G(%A(13)),v4=$G(%A(14)),v5=$G(%A(15)),v6=$G(%A(16)),v7=$G(%A(17)),v8=$G(%A(18)),v9=$G(%A(19)),v10=$G(%A(20)),v11=$G(%A(21)),v12=$G(%A(22)),v13=$G(%A(23)),v14=$G(%A(24)),v15=$G(%A(25)),v16=$G(%A(26)),v17=$G(%A(27)),v18=$G(%A(28)),v19=$G(%A(29)),v20=$G(%A(30))
	;
	;
	S VO="108|49|13|"
	S VO(49)=$C(4,2,25,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",4)
	S VO(50)=$C(4,28,25,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",1)
	S VO(51)=$C(4,54,26,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",5)
	S VO(52)=$C(5,2,25,2,0,0,0,0,0,0)_"00T"_$P(v2,"|",4)
	S VO(53)=$C(5,28,25,2,0,0,0,0,0,0)_"00T"_$P(v2,"|",1)
	S VO(54)=$C(5,54,26,2,0,0,0,0,0,0)_"00T"_$P(v2,"|",5)
	S VO(55)=$C(6,2,25,2,0,0,0,0,0,0)_"00T"_$P(v3,"|",4)
	S VO(56)=$C(6,28,25,2,0,0,0,0,0,0)_"00T"_$P(v3,"|",1)
	S VO(57)=$C(6,54,26,2,0,0,0,0,0,0)_"00T"_$P(v3,"|",5)
	S VO(58)=$C(7,2,25,2,0,0,0,0,0,0)_"00T"_$P(v4,"|",4)
	S VO(59)=$C(7,28,25,2,0,0,0,0,0,0)_"00T"_$P(v4,"|",1)
	S VO(60)=$C(7,54,26,2,0,0,0,0,0,0)_"00T"_$P(v4,"|",5)
	S VO(61)=$C(8,2,25,2,0,0,0,0,0,0)_"00T"_$P(v5,"|",4)
	S VO(62)=$C(8,28,25,2,0,0,0,0,0,0)_"00T"_$P(v5,"|",1)
	S VO(63)=$C(8,54,26,2,0,0,0,0,0,0)_"00T"_$P(v5,"|",5)
	S VO(64)=$C(9,2,25,2,0,0,0,0,0,0)_"00T"_$P(v6,"|",4)
	S VO(65)=$C(9,28,25,2,0,0,0,0,0,0)_"00T"_$P(v6,"|",1)
	S VO(66)=$C(9,54,26,2,0,0,0,0,0,0)_"00T"_$P(v6,"|",5)
	S VO(67)=$C(10,2,25,2,0,0,0,0,0,0)_"00T"_$P(v7,"|",4)
	S VO(68)=$C(10,28,25,2,0,0,0,0,0,0)_"00T"_$P(v7,"|",1)
	S VO(69)=$C(10,54,26,2,0,0,0,0,0,0)_"00T"_$P(v7,"|",5)
	S VO(70)=$C(11,2,25,2,0,0,0,0,0,0)_"00T"_$P(v8,"|",4)
	S VO(71)=$C(11,28,25,2,0,0,0,0,0,0)_"00T"_$P(v8,"|",1)
	S VO(72)=$C(11,54,26,2,0,0,0,0,0,0)_"00T"_$P(v8,"|",5)
	S VO(73)=$C(12,2,25,2,0,0,0,0,0,0)_"00T"_$P(v9,"|",4)
	S VO(74)=$C(12,28,25,2,0,0,0,0,0,0)_"00T"_$P(v9,"|",1)
	S VO(75)=$C(12,54,26,2,0,0,0,0,0,0)_"00T"_$P(v9,"|",5)
	S VO(76)=$C(13,2,25,2,0,0,0,0,0,0)_"00T"_$P(v10,"|",4)
	S VO(77)=$C(13,28,25,2,0,0,0,0,0,0)_"00T"_$P(v10,"|",1)
	S VO(78)=$C(13,54,26,2,0,0,0,0,0,0)_"00T"_$P(v10,"|",5)
	S VO(79)=$C(14,2,25,2,0,0,0,0,0,0)_"00T"_$P(v11,"|",4)
	S VO(80)=$C(14,28,25,2,0,0,0,0,0,0)_"00T"_$P(v11,"|",1)
	S VO(81)=$C(14,54,26,2,0,0,0,0,0,0)_"00T"_$P(v11,"|",5)
	S VO(82)=$C(15,2,25,2,0,0,0,0,0,0)_"00T"_$P(v12,"|",4)
	S VO(83)=$C(15,28,25,2,0,0,0,0,0,0)_"00T"_$P(v12,"|",1)
	S VO(84)=$C(15,54,26,2,0,0,0,0,0,0)_"00T"_$P(v12,"|",5)
	S VO(85)=$C(16,2,25,2,0,0,0,0,0,0)_"00T"_$P(v13,"|",4)
	S VO(86)=$C(16,28,25,2,0,0,0,0,0,0)_"00T"_$P(v13,"|",1)
	S VO(87)=$C(16,54,26,2,0,0,0,0,0,0)_"00T"_$P(v13,"|",5)
	S VO(88)=$C(17,2,25,2,0,0,0,0,0,0)_"00T"_$P(v14,"|",4)
	S VO(89)=$C(17,28,25,2,0,0,0,0,0,0)_"00T"_$P(v14,"|",1)
	S VO(90)=$C(17,54,26,2,0,0,0,0,0,0)_"00T"_$P(v14,"|",5)
	S VO(91)=$C(18,2,25,2,0,0,0,0,0,0)_"00T"_$P(v15,"|",4)
	S VO(92)=$C(18,28,25,2,0,0,0,0,0,0)_"00T"_$P(v15,"|",1)
	S VO(93)=$C(18,54,26,2,0,0,0,0,0,0)_"00T"_$P(v15,"|",5)
	S VO(94)=$C(19,2,25,2,0,0,0,0,0,0)_"00T"_$P(v16,"|",4)
	S VO(95)=$C(19,28,25,2,0,0,0,0,0,0)_"00T"_$P(v16,"|",1)
	S VO(96)=$C(19,54,26,2,0,0,0,0,0,0)_"00T"_$P(v16,"|",5)
	S VO(97)=$C(20,2,25,2,0,0,0,0,0,0)_"00T"_$P(v17,"|",4)
	S VO(98)=$C(20,28,25,2,0,0,0,0,0,0)_"00T"_$P(v17,"|",1)
	S VO(99)=$C(20,54,26,2,0,0,0,0,0,0)_"00T"_$P(v17,"|",5)
	S VO(100)=$C(21,2,25,2,0,0,0,0,0,0)_"00T"_$P(v18,"|",4)
	S VO(101)=$C(21,28,25,2,0,0,0,0,0,0)_"00T"_$P(v18,"|",1)
	S VO(102)=$C(21,54,26,2,0,0,0,0,0,0)_"00T"_$P(v18,"|",5)
	S VO(103)=$C(22,2,25,2,0,0,0,0,0,0)_"00T"_$P(v19,"|",4)
	S VO(104)=$C(22,28,25,2,0,0,0,0,0,0)_"00T"_$P(v19,"|",1)
	S VO(105)=$C(22,54,26,2,0,0,0,0,0,0)_"00T"_$P(v19,"|",5)
	S VO(106)=$C(23,2,25,2,0,0,0,0,0,0)_"00T"_$P(v20,"|",4)
	S VO(107)=$C(23,28,25,2,0,0,0,0,0,0)_"00T"_$P(v20,"|",1)
	S VO(108)=$C(23,54,26,2,0,0,0,0,0,0)_"00T"_$P(v20,"|",5)
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=60,VPT=1,VPB=23,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL5H",VSCRPP=1
	S OLNTB=23080
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
	S %TAB(1)=$C(3,1,25)_"00T12404|11|[DBTBL5H]STATTRGT1|||D VP1^V01S210|D VP2^V01S210"
	S %TAB(2)=$C(3,27,25)_"00T12401|11|[DBTBL5H]STATSRC1|||D VP3^V01S210|D VP4^V01S210"
	S %TAB(3)=$C(3,53,26)_"00T12405|11|[DBTBL5H]STATINC1|||D VP5^V01S210"
	S %TAB(4)=$C(4,1,25)_"00T12404|12|[DBTBL5H]STATTRGT2|||D VP6^V01S210|D VP7^V01S210"
	S %TAB(5)=$C(4,27,25)_"00T12401|12|[DBTBL5H]STATSRC2|||D VP8^V01S210|D VP9^V01S210"
	S %TAB(6)=$C(4,53,26)_"00T12405|12|[DBTBL5H]STATINC2|||D VP10^V01S210"
	S %TAB(7)=$C(5,1,25)_"00T12404|13|[DBTBL5H]STATTRGT3|||D VP11^V01S210|D VP12^V01S210"
	S %TAB(8)=$C(5,27,25)_"00T12401|13|[DBTBL5H]STATSRC3|||D VP13^V01S210|D VP14^V01S210"
	S %TAB(9)=$C(5,53,26)_"00T12405|13|[DBTBL5H]STATINC3|||D VP15^V01S210"
	S %TAB(10)=$C(6,1,25)_"00T12404|14|[DBTBL5H]STATTRGT4|||D VP16^V01S210|D VP17^V01S210"
	S %TAB(11)=$C(6,27,25)_"00T12401|14|[DBTBL5H]STATSRC4|||D VP18^V01S210|D VP19^V01S210"
	S %TAB(12)=$C(6,53,26)_"00T12405|14|[DBTBL5H]STATINC4|||D VP20^V01S210"
	S %TAB(13)=$C(7,1,25)_"00T12404|15|[DBTBL5H]STATTRGT5|||D VP21^V01S210|D VP22^V01S210"
	S %TAB(14)=$C(7,27,25)_"00T12401|15|[DBTBL5H]STATSRC5|||D VP23^V01S210|D VP24^V01S210"
	S %TAB(15)=$C(7,53,26)_"00T12405|15|[DBTBL5H]STATINC5|||D VP25^V01S210"
	S %TAB(16)=$C(8,1,25)_"00T12404|16|[DBTBL5H]STATTRGT6|||D VP26^V01S210|D VP27^V01S210"
	S %TAB(17)=$C(8,27,25)_"00T12401|16|[DBTBL5H]STATSRC6|||D VP28^V01S210|D VP29^V01S210"
	S %TAB(18)=$C(8,53,26)_"00T12405|16|[DBTBL5H]STATINC6|||D VP30^V01S210"
	S %TAB(19)=$C(9,1,25)_"00T12404|17|[DBTBL5H]STATTRGT7|||D VP31^V01S210|D VP32^V01S210"
	S %TAB(20)=$C(9,27,25)_"00T12401|17|[DBTBL5H]STATSRC7|||D VP33^V01S210|D VP34^V01S210"
	S %TAB(21)=$C(9,53,26)_"00T12405|17|[DBTBL5H]STATINC7|||D VP35^V01S210"
	S %TAB(22)=$C(10,1,25)_"00T12404|18|[DBTBL5H]STATTRGT8|||D VP36^V01S210|D VP37^V01S210"
	S %TAB(23)=$C(10,27,25)_"00T12401|18|[DBTBL5H]STATSRC8|||D VP38^V01S210|D VP39^V01S210"
	S %TAB(24)=$C(10,53,26)_"00T12405|18|[DBTBL5H]STATINC8|||D VP40^V01S210"
	S %TAB(25)=$C(11,1,25)_"00T12404|19|[DBTBL5H]STATTRGT9|||D VP41^V01S210|D VP42^V01S210"
	S %TAB(26)=$C(11,27,25)_"00T12401|19|[DBTBL5H]STATSRC9|||D VP43^V01S210|D VP44^V01S210"
	S %TAB(27)=$C(11,53,26)_"00T12405|19|[DBTBL5H]STATINC9|||D VP45^V01S210"
	S %TAB(28)=$C(12,1,25)_"00T12404|20|[DBTBL5H]STATTRGT10|||D VP46^V01S210|D VP47^V01S210"
	S %TAB(29)=$C(12,27,25)_"00T12401|20|[DBTBL5H]STATSRC10|||D VP48^V01S210|D VP49^V01S210"
	S %TAB(30)=$C(12,53,26)_"00T12405|20|[DBTBL5H]STATINC10|||D VP50^V01S210"
	S %TAB(31)=$C(13,1,25)_"00T12404|21|[DBTBL5H]STATTRGT11|||D VP51^V01S210|D VP52^V01S210"
	S %TAB(32)=$C(13,27,25)_"00T12401|21|[DBTBL5H]STATSRC11|||D VP53^V01S210|D VP54^V01S210"
	S %TAB(33)=$C(13,53,26)_"00T12405|21|[DBTBL5H]STATINC11|||D VP55^V01S210"
	S %TAB(34)=$C(14,1,25)_"00T12404|22|[DBTBL5H]STATTRGT12|||D VP56^V01S210|D VP57^V01S210"
	S %TAB(35)=$C(14,27,25)_"00T12401|22|[DBTBL5H]STATSRC12|||D VP58^V01S210|D VP59^V01S210"
	S %TAB(36)=$C(14,53,26)_"00T12405|22|[DBTBL5H]STATINC12|||D VP60^V01S210"
	S %TAB(37)=$C(15,1,25)_"00T12404|23|[DBTBL5H]STATTRGT13|||D VP61^V01S210|D VP62^V01S210"
	S %TAB(38)=$C(15,27,25)_"00T12401|23|[DBTBL5H]STATSRC13|||D VP63^V01S210|D VP64^V01S210"
	S %TAB(39)=$C(15,53,26)_"00T12405|23|[DBTBL5H]STATINC13|||D VP65^V01S210"
	S %TAB(40)=$C(16,1,25)_"00T12404|24|[DBTBL5H]STATTRGT14|||D VP66^V01S210|D VP67^V01S210"
	S %TAB(41)=$C(16,27,25)_"00T12401|24|[DBTBL5H]STATSRC14|||D VP68^V01S210|D VP69^V01S210"
	S %TAB(42)=$C(16,53,26)_"00T12405|24|[DBTBL5H]STATINC14|||D VP70^V01S210"
	S %TAB(43)=$C(17,1,25)_"00T12404|25|[DBTBL5H]STATTRGT15|||D VP71^V01S210|D VP72^V01S210"
	S %TAB(44)=$C(17,27,25)_"00T12401|25|[DBTBL5H]STATSRC15|||D VP73^V01S210|D VP74^V01S210"
	S %TAB(45)=$C(17,53,26)_"00T12405|25|[DBTBL5H]STATINC15|||D VP75^V01S210"
	S %TAB(46)=$C(18,1,25)_"00T12404|26|[DBTBL5H]STATTRGT16|||D VP76^V01S210|D VP77^V01S210"
	S %TAB(47)=$C(18,27,25)_"00T12401|26|[DBTBL5H]STATSRC16|||D VP78^V01S210|D VP79^V01S210"
	S %TAB(48)=$C(18,53,26)_"00T12405|26|[DBTBL5H]STATINC16|||D VP80^V01S210"
	S %TAB(49)=$C(19,1,25)_"00T12404|27|[DBTBL5H]STATTRGT17|||D VP81^V01S210|D VP82^V01S210"
	S %TAB(50)=$C(19,27,25)_"00T12401|27|[DBTBL5H]STATSRC17|||D VP83^V01S210|D VP84^V01S210"
	S %TAB(51)=$C(19,53,26)_"00T12405|27|[DBTBL5H]STATINC17|||D VP85^V01S210"
	S %TAB(52)=$C(20,1,25)_"00T12404|28|[DBTBL5H]STATTRGT18|||D VP86^V01S210|D VP87^V01S210"
	S %TAB(53)=$C(20,27,25)_"00T12401|28|[DBTBL5H]STATSRC18|||D VP88^V01S210|D VP89^V01S210"
	S %TAB(54)=$C(20,53,26)_"00T12405|28|[DBTBL5H]STATINC18|||D VP90^V01S210"
	S %TAB(55)=$C(21,1,25)_"00T12404|29|[DBTBL5H]STATTRGT19|||D VP91^V01S210|D VP92^V01S210"
	S %TAB(56)=$C(21,27,25)_"00T12401|29|[DBTBL5H]STATSRC19|||D VP93^V01S210|D VP94^V01S210"
	S %TAB(57)=$C(21,53,26)_"00T12405|29|[DBTBL5H]STATINC19|||D VP95^V01S210"
	S %TAB(58)=$C(22,1,25)_"00T12404|30|[DBTBL5H]STATTRGT20|||D VP96^V01S210|D VP97^V01S210"
	S %TAB(59)=$C(22,27,25)_"00T12401|30|[DBTBL5H]STATSRC20|||D VP98^V01S210|D VP99^V01S210"
	S %TAB(60)=$C(22,53,26)_"00T12405|30|[DBTBL5H]STATINC20|||D VP100^V01S210"
	;
	Q
	;
	;
	;
	Q
	;
VSPP	;
	;
VSPPREQ	;
	;_______________________________________________________
	;  User Defined Required Data Item Definitions
	;_______________________________________________________
	;
	S ER=0
	;
	D VR1 I ER S NI=2 Q
	;
	D VR2 I ER S NI=5 Q
	;
	D VR3 I ER S NI=8 Q
	;
	D VR4 I ER S NI=11 Q
	;
	D VR5 I ER S NI=14 Q
	;
	D VR6 I ER S NI=17 Q
	;
	D VR7 I ER S NI=20 Q
	;
	D VR8 I ER S NI=23 Q
	;
	D VR9 I ER S NI=26 Q
	;
	D VR10 I ER S NI=29 Q
	;
	D VR11 I ER S NI=32 Q
	;
	D VR12 I ER S NI=35 Q
	;
	D VR13 I ER S NI=38 Q
	;
	D VR14 I ER S NI=41 Q
	;
	D VR15 I ER S NI=44 Q
	;
	D VR16 I ER S NI=47 Q
	;
	D VR17 I ER S NI=50 Q
	;
	D VR18 I ER S NI=53 Q
	;
	D VR19 I ER S NI=56 Q
	;
	D VR20 I ER S NI=59 Q
	Q
	;
VR1	;
	;
	; (STATSRC1,STATTRGT1)
	;
	I ($P(%A(11),"|",1)'=""),($P(%A(11),"|",4)'="") Q
	;
	;
	; (STATSRC1-,STATTRGT1-)
	;
	I ($P(%A(11),"|",1)=""),($P(%A(11),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR2	;
	;
	; (STATSRC2,STATTRGT2)
	;
	I ($P(%A(12),"|",1)'=""),($P(%A(12),"|",4)'="") Q
	;
	;
	; (STATSRC2-,STATTRGT2-)
	;
	I ($P(%A(12),"|",1)=""),($P(%A(12),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR3	;
	;
	; (STATSRC3,STATTRGT3)
	;
	I ($P(%A(13),"|",1)'=""),($P(%A(13),"|",4)'="") Q
	;
	;
	; (STATSRC3-,STATTRGT3-)
	;
	I ($P(%A(13),"|",1)=""),($P(%A(13),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR4	;
	;
	; (STATSRC4,STATTRGT4)
	;
	I ($P(%A(14),"|",1)'=""),($P(%A(14),"|",4)'="") Q
	;
	;
	; (STATSRC4-,STATTRGT4-)
	;
	I ($P(%A(14),"|",1)=""),($P(%A(14),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR5	;
	;
	; (STATSRC5,STATTRGT5)
	;
	I ($P(%A(15),"|",1)'=""),($P(%A(15),"|",4)'="") Q
	;
	;
	; (STATSRC5-,STATTRGT5-)
	;
	I ($P(%A(15),"|",1)=""),($P(%A(15),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR6	;
	;
	; (STATSRC6,STATTRGT6)
	;
	I ($P(%A(16),"|",1)'=""),($P(%A(16),"|",4)'="") Q
	;
	;
	; (STATSRC6-,STATTRGT6-)
	;
	I ($P(%A(16),"|",1)=""),($P(%A(16),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR7	;
	;
	; (STATSRC7,STATTRGT7)
	;
	I ($P(%A(17),"|",1)'=""),($P(%A(17),"|",4)'="") Q
	;
	;
	; (STATSRC7-,STATTRGT7-)
	;
	I ($P(%A(17),"|",1)=""),($P(%A(17),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR8	;
	;
	; (STATSRC8,STATTRGT8)
	;
	I ($P(%A(18),"|",1)'=""),($P(%A(18),"|",4)'="") Q
	;
	;
	; (STATSRC8-,STATTRGT8-)
	;
	I ($P(%A(18),"|",1)=""),($P(%A(18),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR9	;
	;
	; (STATSRC9,STATTRGT9)
	;
	I ($P(%A(19),"|",1)'=""),($P(%A(19),"|",4)'="") Q
	;
	;
	; (STATSRC9-,STATTRGT9-)
	;
	I ($P(%A(19),"|",1)=""),($P(%A(19),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR10	;
	;
	; (STATSRC10,STATTRGT10)
	;
	I ($P(%A(20),"|",1)'=""),($P(%A(20),"|",4)'="") Q
	;
	;
	; (STATSRC10-,STATTRGT10-)
	;
	I ($P(%A(20),"|",1)=""),($P(%A(20),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR11	;
	;
	; (STATSRC11,STATTRGT11)
	;
	I ($P(%A(21),"|",1)'=""),($P(%A(21),"|",4)'="") Q
	;
	;
	; (STATSRC11-,STATTRGT11-)
	;
	I ($P(%A(21),"|",1)=""),($P(%A(21),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR12	;
	;
	; (STATSRC12,STATTRGT12)
	;
	I ($P(%A(22),"|",1)'=""),($P(%A(22),"|",4)'="") Q
	;
	;
	; (STATSRC12-,STATTRGT12-)
	;
	I ($P(%A(22),"|",1)=""),($P(%A(22),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR13	;
	;
	; (STATSRC13,STATTRGT13)
	;
	I ($P(%A(23),"|",1)'=""),($P(%A(23),"|",4)'="") Q
	;
	;
	; (STATSRC13-,STATTRGT13-)
	;
	I ($P(%A(23),"|",1)=""),($P(%A(23),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR14	;
	;
	; (STATSRC14,STATTRGT14)
	;
	I ($P(%A(24),"|",1)'=""),($P(%A(24),"|",4)'="") Q
	;
	;
	; (STATSRC14-,STATTRGT14-)
	;
	I ($P(%A(24),"|",1)=""),($P(%A(24),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR15	;
	;
	; (STATSRC15,STATTRGT15)
	;
	I ($P(%A(25),"|",1)'=""),($P(%A(25),"|",4)'="") Q
	;
	;
	; (STATSRC15-,STATTRGT15-)
	;
	I ($P(%A(25),"|",1)=""),($P(%A(25),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR16	;
	;
	; (STATSRC16,STATTRGT16)
	;
	I ($P(%A(26),"|",1)'=""),($P(%A(26),"|",4)'="") Q
	;
	;
	; (STATSRC16-,STATTRGT16-)
	;
	I ($P(%A(26),"|",1)=""),($P(%A(26),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR17	;
	;
	; (STATSRC17,STATTRGT17)
	;
	I ($P(%A(27),"|",1)'=""),($P(%A(27),"|",4)'="") Q
	;
	;
	; (STATSRC17-,STATTRGT17-)
	;
	I ($P(%A(27),"|",1)=""),($P(%A(27),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR18	;
	;
	; (STATSRC18,STATTRGT18)
	;
	I ($P(%A(28),"|",1)'=""),($P(%A(28),"|",4)'="") Q
	;
	;
	; (STATSRC18-,STATTRGT18-)
	;
	I ($P(%A(28),"|",1)=""),($P(%A(28),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR19	;
	;
	; (STATSRC19,STATTRGT19)
	;
	I ($P(%A(29),"|",1)'=""),($P(%A(29),"|",4)'="") Q
	;
	;
	; (STATSRC19-,STATTRGT19-)
	;
	I ($P(%A(29),"|",1)=""),($P(%A(29),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
	;
VR20	;
	;
	; (STATSRC20,STATTRGT20)
	;
	I ($P(%A(30),"|",1)'=""),($P(%A(30),"|",4)'="") Q
	;
	;
	; (STATSRC20-,STATTRGT20-)
	;
	I ($P(%A(30),"|",1)=""),($P(%A(30),"|",4)="") Q
	;
	S ER=1 D VR99 Q
	;
VR99	S RM="Missing required field(s)/data item set definition error"
	S ER=1 Q
VPOS	; User defined post processor's
	;
VP1	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC1","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC1","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP2	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP3	;
	I X'="" S I(3)=""
	I X="",$P(%A(11),"|",4)="" Q
	I X="",$P(%A(11),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(11),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC1","1","0")
	S NI=NI+1
	Q
VP4	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP5	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP6	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC2","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC2","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP7	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP8	;
	I X'="" S I(3)=""
	I X="",$P(%A(12),"|",4)="" Q
	I X="",$P(%A(12),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(12),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC2","1","0")
	S NI=NI+1
	Q
VP9	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP10	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP11	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC3","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC3","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP12	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP13	;
	I X'="" S I(3)=""
	I X="",$P(%A(13),"|",4)="" Q
	I X="",$P(%A(13),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(13),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC3","1","0")
	S NI=NI+1
	Q
VP14	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP15	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP16	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC4","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC4","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP17	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP18	;
	I X'="" S I(3)=""
	I X="",$P(%A(14),"|",4)="" Q
	I X="",$P(%A(14),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(14),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC4","1","0")
	S NI=NI+1
	Q
VP19	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP20	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP21	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC5","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC5","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP22	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP23	;
	I X'="" S I(3)=""
	I X="",$P(%A(15),"|",4)="" Q
	I X="",$P(%A(15),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(15),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC5","1","0")
	S NI=NI+1
	Q
VP24	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP25	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP26	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC6","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC6","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP27	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP28	;
	I X'="" S I(3)=""
	I X="",$P(%A(16),"|",4)="" Q
	I X="",$P(%A(16),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(16),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC6","1","0")
	S NI=NI+1
	Q
VP29	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP30	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP31	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC7","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC7","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP32	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP33	;
	I X'="" S I(3)=""
	I X="",$P(%A(17),"|",4)="" Q
	I X="",$P(%A(17),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(17),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC7","1","0")
	S NI=NI+1
	Q
VP34	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP35	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP36	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC8","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC8","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP37	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP38	;
	I X'="" S I(3)=""
	I X="",$P(%A(18),"|",4)="" Q
	I X="",$P(%A(18),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(18),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC8","1","0")
	S NI=NI+1
	Q
VP39	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP40	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP41	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC9","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC9","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP42	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP43	;
	I X'="" S I(3)=""
	I X="",$P(%A(19),"|",4)="" Q
	I X="",$P(%A(19),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(19),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC9","1","0")
	S NI=NI+1
	Q
VP44	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP45	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP46	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC10","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC10","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP47	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP48	;
	I X'="" S I(3)=""
	I X="",$P(%A(20),"|",4)="" Q
	I X="",$P(%A(20),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(20),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC10","1","0")
	S NI=NI+1
	Q
VP49	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP50	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP51	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC11","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC11","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP52	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP53	;
	I X'="" S I(3)=""
	I X="",$P(%A(21),"|",4)="" Q
	I X="",$P(%A(21),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(21),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC11","1","0")
	S NI=NI+1
	Q
VP54	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP55	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP56	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC12","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC12","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP57	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP58	;
	I X'="" S I(3)=""
	I X="",$P(%A(22),"|",4)="" Q
	I X="",$P(%A(22),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(22),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC12","1","0")
	S NI=NI+1
	Q
VP59	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP60	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP61	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC13","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC13","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP62	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP63	;
	I X'="" S I(3)=""
	I X="",$P(%A(23),"|",4)="" Q
	I X="",$P(%A(23),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(23),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC13","1","0")
	S NI=NI+1
	Q
VP64	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP65	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP66	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC14","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC14","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP67	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP68	;
	I X'="" S I(3)=""
	I X="",$P(%A(24),"|",4)="" Q
	I X="",$P(%A(24),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(24),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC14","1","0")
	S NI=NI+1
	Q
VP69	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP70	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP71	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC15","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC15","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP72	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP73	;
	I X'="" S I(3)=""
	I X="",$P(%A(25),"|",4)="" Q
	I X="",$P(%A(25),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(25),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC15","1","0")
	S NI=NI+1
	Q
VP74	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP75	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP76	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC16","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC16","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP77	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP78	;
	I X'="" S I(3)=""
	I X="",$P(%A(26),"|",4)="" Q
	I X="",$P(%A(26),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(26),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC16","1","0")
	S NI=NI+1
	Q
VP79	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP80	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP81	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC17","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC17","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP82	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP83	;
	I X'="" S I(3)=""
	I X="",$P(%A(27),"|",4)="" Q
	I X="",$P(%A(27),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(27),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC17","1","0")
	S NI=NI+1
	Q
VP84	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP85	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP86	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC18","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC18","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP87	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP88	;
	I X'="" S I(3)=""
	I X="",$P(%A(28),"|",4)="" Q
	I X="",$P(%A(28),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(28),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC18","1","0")
	S NI=NI+1
	Q
VP89	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP90	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP91	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC19","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC19","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP92	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP93	;
	I X'="" S I(3)=""
	I X="",$P(%A(29),"|",4)="" Q
	I X="",$P(%A(29),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(29),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC19","1","0")
	S NI=NI+1
	Q
VP94	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP95	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
	Q
VP96	;
	S ER=0
	I X'="" S I(3)="" ; Skip table look-up
	I X="",V'="" D
	.  D DELETE^DBSMACRO("[DBTBL5H]STATSRC20","1","0")
	.  D DELETE^DBSMACRO("[DBTBL5H]STATINC20","1","0")
	;
	I X'="" D
	.  I X'["[" S X="["_%LIBS_","_PFID_"]"_X
	.  S DLIB=%LIBS,DFID=PFID D ^DBSDI
	.  I 'ER S X=DINAM
	;
	E  D GOTO^DBSMACRO("NEXT") Q
	Q
VP97	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP98	;
	I X'="" S I(3)=""
	I X="",$P(%A(30),"|",4)="" Q
	I X="",$P(%A(30),"|",4)'="" S E5=1 Q  ; Required
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER Q
	S X=DINAM
	I X=$P(%A(30),"|",4),"TUFL"'[DI(9) Q
	D DELETE^DBSMACRO("[DBTBL5H]STATINC20","1","0")
	S NI=NI+1
	Q
VP99	;
	S DLIB=%LIBS,DFID=PFID,X="" D ^DBSDI
	Q
VP100	;
	I X="" Q
	I X=0 S X="" Q
	S X2=-99999999
	F Z1=1:1 S Z=$P(X,",",Z1),Z99=$P(X,",",Z1+1,999) Q:((Z="")&(Z99=""))  D INCCHK
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
	S PFID=$P($G(^DBTBL(%LIBS,5,RID,0)),"|",1)
	S PFID=$P(PFID,",",1)
	Q
	;
	;
INCCHK	; Called by other post-processors
	I Z="" S ER=1,RM=$$^MSG(961)
	E  I Z<X2 S ER=1,RM=$$^MSG(943)
	E  I '((Z?."-"1N.N)!(Z?."-"1N.N1".".N)) S ER=1,RM=$$^MSG(961)
	Q
	Q
