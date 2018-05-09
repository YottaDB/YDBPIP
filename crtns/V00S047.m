 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBSDSMP ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S047(%O,DBTBL2) ; DBS - DBS - SID= <DBSDSMP> Screen Definition - Multiple
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(DBTBL2)#2)  K vobj(+$G(DBTBL2)) S DBTBL2=$$vcdmNew^RecordDBTBL2()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBSDSMP" S VPGM=$T(+0) S VSNAME="Screen Definition - Multiple"
 S VFSN("DBTBL2")="zDBTBL2"
 S vPSL=1
 S KEYS(1)=vobj(DBTBL2,-3)
 S KEYS(2)=vobj(DBTBL2,-4)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.DBTBL2) D VDA1(.DBTBL2) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.DBTBL2) D VPR(.DBTBL2) D VDA1(.DBTBL2)
 I %O D VLOD(.DBTBL2) Q:$get(ER)  D VPR(.DBTBL2) D VDA1(.DBTBL2)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.DBTBL2)
 Q 
 ;
VNEW(DBTBL2) ; Initialize arrays if %O=0
 ;
 D VDEF(.DBTBL2)
 D VLOD(.DBTBL2)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(DBTBL2) ; 
  S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
 Q:(vobj(DBTBL2,-3)="")!(vobj(DBTBL2,-4)="") 
 Q:%O  S ER=0 I (vobj(DBTBL2,-3)="")!(vobj(DBTBL2,-4)="") S ER=1 S RM=$$^MSG(1767,"LIBS,SID") Q 
  N V1,V2 S V1=vobj(DBTBL2,-3),V2=vobj(DBTBL2,-4) I ($D(^DBTBL(V1,2,V2))) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(DBTBL2,0),$C(124),3)=""  S:'$D(vobj(DBTBL2,-100,0,"DATE")) vobj(DBTBL2,-100,0,"DATE")="D003"_$P(vobj(DBTBL2,0),$C(124),3),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),3)=+$H
 I $P(vobj(DBTBL2,0),$C(124),17)=""  S:'$D(vobj(DBTBL2,-100,0,"OOE")) vobj(DBTBL2,-100,0,"OOE")="L017"_$P(vobj(DBTBL2,0),$C(124),17),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),17)=1
 I $P(vobj(DBTBL2,0),$C(124),14)=""  S:'$D(vobj(DBTBL2,-100,0,"OUTFMT")) vobj(DBTBL2,-100,0,"OUTFMT")="T014"_$P(vobj(DBTBL2,0),$C(124),14),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),14)="VT220"
 I $P(vobj(DBTBL2,0),$C(124),7)=""  S:'$D(vobj(DBTBL2,-100,0,"REPEAT")) vobj(DBTBL2,-100,0,"REPEAT")="N007"_$P(vobj(DBTBL2,0),$C(124),7),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),7)=0
 I $P(vobj(DBTBL2,0),$C(124),5)=""  S:'$D(vobj(DBTBL2,-100,0,"REPREQ")) vobj(DBTBL2,-100,0,"REPREQ")="T005"_$P(vobj(DBTBL2,0),$C(124),5),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),5)=0
 I $P(vobj(DBTBL2,0),$C(124),16)=""  S:'$D(vobj(DBTBL2,-100,0,"RESFLG")) vobj(DBTBL2,-100,0,"RESFLG")="N016"_$P(vobj(DBTBL2,0),$C(124),16),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),16)=0
 I $P(vobj(DBTBL2,0),$C(124),8)=""  S:'$D(vobj(DBTBL2,-100,0,"SCRCLR")) vobj(DBTBL2,-100,0,"SCRCLR")="N008"_$P(vobj(DBTBL2,0),$C(124),8),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),8)=1
 I $P(vobj(DBTBL2,0),$C(124),6)=""  S:'$D(vobj(DBTBL2,-100,0,"SCRMOD")) vobj(DBTBL2,-100,0,"SCRMOD")="L006"_$P(vobj(DBTBL2,0),$C(124),6),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),6)=0
 I $P(vobj(DBTBL2,0),$C(124),15)=""  S:'$D(vobj(DBTBL2,-100,0,"UID")) vobj(DBTBL2,-100,0,"UID")="T015"_$P(vobj(DBTBL2,0),$C(124),15),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),15)=$$USERNAM^%ZFUNC
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(DBTBL2) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(DBTBL2) ; Display screen prompts
 S VO="79||13|0"
 S VO(0)="|0"
 S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(3,5,11,0,0,0,0,0,0,0)_"01T Screen ID:"
 S VO(4)=$C(3,31,13,0,0,0,0,0,0,0)_"01TProgram Name:"
 S VO(5)=$C(3,56,13,0,0,0,0,0,0,0)_"01TLast Updated:"
 S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(10)=$C(5,3,13,1,0,0,0,0,0,0)_"01T Description:"
 S VO(11)=$C(5,59,5,0,0,0,0,0,0,0)_"01TUser:"
 S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(16)=$C(7,2,14,1,0,0,0,0,0,0)_"01T Data File(s):"
 S VO(17)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(19)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(20)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(21)=$C(9,17,13,0,0,0,0,0,0,0)_"01TPSL Compiler:"
 S VO(22)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(23)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(24)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(25)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(26)=$C(11,4,12,0,0,0,0,0,0,0)_"01TApplication:"
 S VO(27)=$C(11,23,7,0,0,0,0,0,0,0)_"01TSystem:"
 S VO(28)=$C(11,41,8,0,0,0,0,0,0,0)_"01TVersion:"
 S VO(29)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(30)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(31)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(32)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(33)=$C(13,15,47,2,0,0,0,0,0,0)_"01T--------  L I N K E D   S C R E E N S  --------"
 S VO(34)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(35)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(37)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(38)=$C(15,4,2,1,0,0,0,0,0,0)_"01T1 "
 S VO(39)=$C(15,23,2,1,0,0,0,0,0,0)_"01T2 "
 S VO(40)=$C(15,43,3,0,0,0,0,0,0,0)_"01T3) "
 S VO(41)=$C(15,63,3,0,0,0,0,0,0,0)_"01T4) "
 S VO(42)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(43)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(44)=$C(16,4,3,0,0,0,0,0,0,0)_"01T5) "
 S VO(45)=$C(16,23,3,0,0,0,0,0,0,0)_"01T6) "
 S VO(46)=$C(16,43,3,0,0,0,0,0,0,0)_"01T7) "
 S VO(47)=$C(16,63,3,0,0,0,0,0,0,0)_"01T8) "
 S VO(48)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(49)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(50)=$C(17,4,3,0,0,0,0,0,0,0)_"01T9) "
 S VO(51)=$C(17,22,4,0,0,0,0,0,0,0)_"01T10) "
 S VO(52)=$C(17,42,4,0,0,0,0,0,0,0)_"01T11) "
 S VO(53)=$C(17,62,4,0,0,0,0,0,0,0)_"01T12) "
 S VO(54)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(55)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(56)=$C(18,3,4,0,0,0,0,0,0,0)_"01T13) "
 S VO(57)=$C(18,22,4,0,0,0,0,0,0,0)_"01T14) "
 S VO(58)=$C(18,42,4,0,0,0,0,0,0,0)_"01T15) "
 S VO(59)=$C(18,62,4,0,0,0,0,0,0,0)_"01T16) "
 S VO(60)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(61)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(62)=$C(19,3,4,0,0,0,0,0,0,0)_"01T17) "
 S VO(63)=$C(19,22,4,0,0,0,0,0,0,0)_"01T18) "
 S VO(64)=$C(19,42,4,0,0,0,0,0,0,0)_"01T19) "
 S VO(65)=$C(19,62,4,0,0,0,0,0,0,0)_"01T20) "
 S VO(66)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(67)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(68)=$C(20,3,4,0,0,0,0,0,0,0)_"01T21) "
 S VO(69)=$C(20,22,4,0,0,0,0,0,0,0)_"01T22) "
 S VO(70)=$C(20,42,4,0,0,0,0,0,0,0)_"01T23) "
 S VO(71)=$C(20,62,4,0,0,0,0,0,0,0)_"01T24) "
 S VO(72)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(73)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(74)=$C(21,3,3,0,0,0,0,0,0,0)_"01T25)"
 S VO(75)=$C(21,22,4,0,0,0,0,0,0,0)_"01T26) "
 S VO(76)=$C(21,42,4,0,0,0,0,0,0,0)_"01T27) "
 S VO(77)=$C(21,62,4,0,0,0,0,0,0,0)_"01T28) "
 S VO(78)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(79)=$C(22,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(DBTBL2) ; Display screen data
  S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
  S:'$D(vobj(DBTBL2,"v1")) vobj(DBTBL2,"v1")=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),-1)),1:"")
 N V
 ;
 S VO="117|80|13|0"
 S VO(80)=$C(3,17,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(DBTBL2,-4),1,12)
 S VO(81)=$C(3,45,8,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(DBTBL2,0),$C(124),2),1,8)
 S VO(82)=$C(3,69,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str($P(vobj(DBTBL2,0),$C(124),3),"MM/DD/YEAR")
 S VO(83)=$C(5,17,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),9),1,40)
 S VO(84)=$C(5,65,15,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(DBTBL2,0),$C(124),15),1,15)
 S VO(85)=$C(7,17,60,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,0),$C(124),1),1,60)
 S VO(86)=$C(9,31,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),22):"Y",1:"N")
 S VO(87)=$C(11,17,3,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),11),1,3)
 S VO(88)=$C(11,31,8,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),12),1,8)
 S VO(89)=$C(11,50,6,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),10),1,6)
 S VO(90)=$C(15,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),1),1,12)
 S VO(91)=$C(15,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),2),1,12)
 S VO(92)=$C(15,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),3),1,12)
 S VO(93)=$C(15,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),4),1,12)
 S VO(94)=$C(16,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),5),1,12)
 S VO(95)=$C(16,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),6),1,12)
 S VO(96)=$C(16,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),7),1,12)
 S VO(97)=$C(16,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),8),1,12)
 S VO(98)=$C(17,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),9),1,12)
 S VO(99)=$C(17,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),10),1,12)
 S VO(100)=$C(17,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),11),1,12)
 S VO(101)=$C(17,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),12),1,12)
 S VO(102)=$C(18,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),13),1,12)
 S VO(103)=$C(18,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),14),1,12)
 S VO(104)=$C(18,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),15),1,12)
 S VO(105)=$C(18,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),16),1,12)
 S VO(106)=$C(19,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),17),1,12)
 S VO(107)=$C(19,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),18),1,12)
 S VO(108)=$C(19,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),19),1,12)
 S VO(109)=$C(19,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),20),1,12)
 S VO(110)=$C(20,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),21),1,12)
 S VO(111)=$C(20,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),22),1,12)
 S VO(112)=$C(20,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),23),1,12)
 S VO(113)=$C(20,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),24),1,12)
 S VO(114)=$C(21,7,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),25),1,12)
 S VO(115)=$C(21,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),26),1,12)
 S VO(116)=$C(21,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),27),1,12)
 S VO(117)=$C(21,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,"v1"),$C(124),28),1,12)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(DBTBL2) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=38 S VPT=1 S VPB=22 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL2"
 S OLNTB=22001
 ;
 S VFSN("DBTBL2")="zDBTBL2"
 ;
 ;
 S %TAB(1)=$C(2,16,12)_"21T12402|1|[DBTBL2]SID"
 S %TAB(2)=$C(2,44,8)_"21T12402|1|[DBTBL2]VPGM"
 S %TAB(3)=$C(2,68,10)_"21D12403|1|[DBTBL2]DATE"
 S %TAB(4)=$C(4,16,40)_"01T12409|1|[DBTBL2]DESC"
 S %TAB(5)=$C(4,64,15)_"20T12415|1|[DBTBL2]UID|||||||||20"
 S %TAB(6)=$C(6,16,60)_"01U12401|1|[DBTBL2]PFID|[DBTBL1]||do VP1^V00S047(.DBTBL2)"
 S %TAB(7)=$C(8,30,1)_"00L12422|1|[DBTBL2]CSCMP"
 S %TAB(8)=$C(10,16,3)_"00T12411|1|[DBTBL2]APL|[STBLSCASYS]"
 S %TAB(9)=$C(10,30,8)_"00T12412|1|[DBTBL2]SYS|[STBLSCASYS]"
 S %TAB(10)=$C(10,49,6)_"00T12410|1|[DBTBL2]VER"
 S %TAB(11)=$C(14,6,12)_"01U12401|1|[DBTBL2]LNK1|[DBTBL2]||do VP2^V00S047(.DBTBL2)"
 S %TAB(12)=$C(14,25,12)_"01U12402|1|[DBTBL2]LNK2|[DBTBL2]||do VP3^V00S047(.DBTBL2)"
 S %TAB(13)=$C(14,45,12)_"00U12403|1|[DBTBL2]LNK3|[DBTBL2]||do VP4^V00S047(.DBTBL2)"
 S %TAB(14)=$C(14,65,12)_"00U12404|1|[DBTBL2]LNK4|[DBTBL2]||do VP5^V00S047(.DBTBL2)"
 S %TAB(15)=$C(15,6,12)_"00U12405|1|[DBTBL2]LNK5|[DBTBL2]||do VP6^V00S047(.DBTBL2)"
 S %TAB(16)=$C(15,25,12)_"00U12406|1|[DBTBL2]LNK6|[DBTBL2]||do VP7^V00S047(.DBTBL2)"
 S %TAB(17)=$C(15,45,12)_"00U12407|1|[DBTBL2]LNK7|[DBTBL2]||do VP8^V00S047(.DBTBL2)"
 S %TAB(18)=$C(15,65,12)_"00U12408|1|[DBTBL2]LNK8|[DBTBL2]||do VP9^V00S047(.DBTBL2)"
 S %TAB(19)=$C(16,6,12)_"00U12409|1|[DBTBL2]LNK9|[DBTBL2]||do VP10^V00S047(.DBTBL2)"
 S %TAB(20)=$C(16,25,12)_"00U12410|1|[DBTBL2]LNK10|[DBTBL2]||do VP11^V00S047(.DBTBL2)"
 S %TAB(21)=$C(16,45,12)_"00U12411|1|[DBTBL2]LNK11|[DBTBL2]||do VP12^V00S047(.DBTBL2)"
 S %TAB(22)=$C(16,65,12)_"00U12412|1|[DBTBL2]LNK12|[DBTBL2]||do VP13^V00S047(.DBTBL2)"
 S %TAB(23)=$C(17,6,12)_"00U12413|1|[DBTBL2]LNK13|[DBTBL2]||do VP14^V00S047(.DBTBL2)"
 S %TAB(24)=$C(17,25,12)_"00U12414|1|[DBTBL2]LNK14|[DBTBL2]||do VP15^V00S047(.DBTBL2)"
 S %TAB(25)=$C(17,45,12)_"00U12415|1|[DBTBL2]LNK15|[DBTBL2]||do VP16^V00S047(.DBTBL2)"
 S %TAB(26)=$C(17,65,12)_"00U12416|1|[DBTBL2]LNK16|[DBTBL2]||do VP17^V00S047(.DBTBL2)"
 S %TAB(27)=$C(18,6,12)_"00U12417|1|[DBTBL2]LNK17|[DBTBL2]||do VP18^V00S047(.DBTBL2)"
 S %TAB(28)=$C(18,25,12)_"00U12418|1|[DBTBL2]LNK18|[DBTBL2]||do VP19^V00S047(.DBTBL2)"
 S %TAB(29)=$C(18,45,12)_"00U12419|1|[DBTBL2]LNK19|[DBTBL2]||do VP20^V00S047(.DBTBL2)"
 S %TAB(30)=$C(18,65,12)_"00U12420|1|[DBTBL2]LNK20|[DBTBL2]||do VP21^V00S047(.DBTBL2)"
 S %TAB(31)=$C(19,6,12)_"00U12421|1|[DBTBL2]LNK21|[DBTBL2]||do VP22^V00S047(.DBTBL2)"
 S %TAB(32)=$C(19,25,12)_"00U12422|1|[DBTBL2]LNK22|[DBTBL2]||do VP23^V00S047(.DBTBL2)"
 S %TAB(33)=$C(19,45,12)_"00U12423|1|[DBTBL2]LNK23|[DBTBL2]||do VP24^V00S047(.DBTBL2)"
 S %TAB(34)=$C(19,65,12)_"00U12424|1|[DBTBL2]LNK24|[DBTBL2]||do VP25^V00S047(.DBTBL2)"
 S %TAB(35)=$C(20,6,12)_"00U12425|1|[DBTBL2]LNK25|[DBTBL2]"
 S %TAB(36)=$C(20,25,12)_"00U12426|1|[DBTBL2]LNK26|[DBTBL2]"
 S %TAB(37)=$C(20,45,12)_"00U12427|1|[DBTBL2]LNK27|[DBTBL2]"
 S %TAB(38)=$C(20,65,12)_"00U12428|1|[DBTBL2]LNK28|[DBTBL2]"
 D VTBL(.DBTBL2)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(DBTBL2) ; Create %TAB(array)
 ; 1 2 3  4 5   6   7-9 10-11
 ; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
 ;user-defined post procs
 ;
VP1(DBTBL2) ; 
 ;
 Q:(X="") 
 ;
 I (X[",") S I(3)=""
 ;
 S ER=$$VALIDATE^DBSFVER(X,.RM)
 ;
 I 'ER S PFID=X
 ;
 Q 
VP2(DBTBL2) ; 
 D tblck
 ;
 Q 
 ;
tblck ; Validate that tables in screen are in PFID list
 N vpc
 ;
 ; Called by post processor on each link field
 ;
 N J
 N tables
 ;
 Q:(X="") 
 ;
 I ($E(X,1)="@") D  Q 
 .	;
 .	I ($L(X)>1) S I(3)=""
 .	Q 
 ;
 N dbtbl2,vop1,vop2,vop3,vop4,vop5 S vop1="SYSDEV",vop2=X,dbtbl2=$$vRCgetRecord1Opt^RecordDBTBL2("SYSDEV",X,0,.vop3)
  S vop5=$G(^DBTBL(vop1,2,vop2,-1))
  S vop4=$G(^DBTBL(vop1,2,vop2,0))
 ;
 S vpc=($G(vop3)=0) Q:vpc 
 ;
 I '($P(vop5,$C(124),1)="") D  Q 
 .	;
 .	N ET
 .	;
 .	S ER=1
 .	; A link screen may not be linked to another link screen
 .	S ET="DBSLSE"
 .	D ^UTLERR
 .	Q 
 ;
 S tables=$P(vop4,$C(124),1)
 F J=1:1:$L(tables,",") I '((","_PFID_",")[(","_$piece(tables,",",J)_",")) S ER=1
 ;
 I ER D
 .	;
 .	N ET
 .	;
 .	; A link screen may not be linked to another link screen
 .	S ET="DBSILF"
 .	D ^UTLERR
 .	Q 
 ;
 Q 
VP3(DBTBL2) ; 
 D tblck
 Q 
VP4(DBTBL2) ; 
 D tblck
 Q 
VP5(DBTBL2) ; 
 D tblck
 Q 
VP6(DBTBL2) ; 
 D tblck
 Q 
VP7(DBTBL2) ; 
 D tblck
 Q 
VP8(DBTBL2) ; 
 D tblck
 Q 
VP9(DBTBL2) ; 
 D tblck
 Q 
VP10(DBTBL2) ; 
 D tblck
 Q 
VP11(DBTBL2) ; 
 D tblck
 Q 
VP12(DBTBL2) ; 
 D tblck
 Q 
VP13(DBTBL2) ; 
 D tblck
 Q 
VP14(DBTBL2) ; 
 D tblck
 Q 
VP15(DBTBL2) ; 
 D tblck
 Q 
VP16(DBTBL2) ; 
 D tblck
 Q 
VP17(DBTBL2) ; 
 D tblck
 Q 
VP18(DBTBL2) ; 
 D tblck
 Q 
VP19(DBTBL2) ; 
 D tblck
 Q 
VP20(DBTBL2) ; 
 D tblck
 Q 
VP21(DBTBL2) ; 
 D tblck
 Q 
VP22(DBTBL2) ; 
 D tblck
 Q 
VP23(DBTBL2) ; 
 D tblck
 Q 
VP24(DBTBL2) ; 
 D tblck
 Q 
VP25(DBTBL2) ; 
 D tblck
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.DBTBL2)
 D VDA1(.DBTBL2)
 D ^DBSPNT()
 Q 
 ;
VW(DBTBL2) ; 
 D VDA1(.DBTBL2)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(DBTBL2) ; 
 D VDA1(.DBTBL2)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.DBTBL2)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL2" D vSET1(.DBTBL2,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(DBTBL2,di,X) ; 
  D propSet^DBSDYNRA(DBTBL2,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL2" Q $$vREAD1(.DBTBL2,di)
 Q ""
vREAD1(DBTBL2,di) ; 
 Q $$propGet^DBSDYNRA(DBTBL2,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ; ----------------
 ;  #OPTION ResultClass 1
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
