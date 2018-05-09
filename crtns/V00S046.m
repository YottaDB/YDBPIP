 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBSDOM ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S046(%O,fDBSDOM) ; -  - SID= <DBSDOM> User-Defined Data Types Maintenance
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ; The DBSDOM screen enables the institution to create, maintain, and delete
 ; user-defined data types.
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fDBSDOM)#2)  K vobj(+$G(fDBSDOM)) S fDBSDOM=$$vcdmNew^RecordDBSDOM()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,SYSSN,DOM,DELETE" S VSID="DBSDOM" S VPGM=$T(+0) S VSNAME="User-Defined Data Types Maintenance"
 S VFSN("DBSDOM")="zfDBSDOM"
 S vPSL=1
 S KEYS(1)=vobj(fDBSDOM,-3)
 S KEYS(2)=vobj(fDBSDOM,-4)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.fDBSDOM) D VDA1(.fDBSDOM) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.fDBSDOM) D VPR(.fDBSDOM) D VDA1(.fDBSDOM)
 I %O D VLOD(.fDBSDOM) Q:$get(ER)  D VPR(.fDBSDOM) D VDA1(.fDBSDOM)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fDBSDOM)
 Q 
 ;
VNEW(fDBSDOM) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBSDOM)
 D VLOD(.fDBSDOM)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBSDOM) ; 
  S:'$D(vobj(fDBSDOM,0)) vobj(fDBSDOM,0)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),0)),1:"")
  S:'$D(vobj(fDBSDOM,1)) vobj(fDBSDOM,1)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),1)),1:"")
 Q:(vobj(fDBSDOM,-3)="")!(vobj(fDBSDOM,-4)="") 
 Q:%O  S ER=0 I (vobj(fDBSDOM,-3)="")!(vobj(fDBSDOM,-4)="") S ER=1 S RM=$$^MSG(1767,"SYSSN,DOM") Q 
  N V1,V2 S V1=vobj(fDBSDOM,-3),V2=vobj(fDBSDOM,-4) I ($D(^DBCTL("SYS","DOM",V1,V2))>9) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(fDBSDOM,0),$C(124),19)=""  S:'$D(vobj(fDBSDOM,-100,0,"LTD")) vobj(fDBSDOM,-100,0,"LTD")="D019"_$P(vobj(fDBSDOM,0),$C(124),19),vobj(fDBSDOM,-100,0)="" S $P(vobj(fDBSDOM,0),$C(124),19)=+$H
 I $P(vobj(fDBSDOM,1),$C(124),3)=""  S:'$D(vobj(fDBSDOM,-100,1,"PRLEN")) vobj(fDBSDOM,-100,1,"PRLEN")="L003"_$P(vobj(fDBSDOM,1),$C(124),3),vobj(fDBSDOM,-100,1)="" S $P(vobj(fDBSDOM,1),$C(124),3)=1
 I $P(vobj(fDBSDOM,1),$C(124),2)=""  S:'$D(vobj(fDBSDOM,-100,1,"PRTYP")) vobj(fDBSDOM,-100,1,"PRTYP")="L002"_$P(vobj(fDBSDOM,1),$C(124),2),vobj(fDBSDOM,-100,1)="" S $P(vobj(fDBSDOM,1),$C(124),2)=1
 I $P(vobj(fDBSDOM,0),$C(124),20)=""  S:'$D(vobj(fDBSDOM,-100,0,"USER")) vobj(fDBSDOM,-100,0,"USER")="T020"_$P(vobj(fDBSDOM,0),$C(124),20),vobj(fDBSDOM,-100,0)="" S $P(vobj(fDBSDOM,0),$C(124),20)=$$USERNAM^%ZFUNC
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBSDOM) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBSDOM) ; Display screen prompts
 S VO="65||13|"
 S VO(0)="|0"
 S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(3,19,8,1,0,0,0,0,0,0)_"01T System:"
 S VO(4)=$C(3,61,8,0,0,0,0,0,0,0)_"01TUpdated:"
 S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(4,11,16,1,0,0,0,0,0,0)_"01T Data Type Name:"
 S VO(8)=$C(4,50,7,0,0,0,0,0,0,0)_"01TDelete:"
 S VO(9)=$C(4,61,8,0,0,0,0,0,0,0)_"01TBy User:"
 S VO(10)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(11)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(12)=$C(5,2,4,2,0,0,0,0,0,0)_"01TProt"
 S VO(13)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(14)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(15)=$C(6,14,13,1,0,0,0,0,0,0)_"01T Description:"
 S VO(16)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(17)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(7,6,21,1,0,0,0,0,0,0)_"01T DATA-QWIK Data Type:"
 S VO(19)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(20)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(21)=$C(8,19,8,1,0,0,0,0,0,0)_"01T Length:"
 S VO(22)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(23)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(24)=$C(9,7,20,0,0,0,0,0,0,0)_"01TScreen Display Size:"
 S VO(25)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(26)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(27)=$C(10,10,17,0,0,0,0,0,0,0)_"01T   Fixed Decimal:"
 S VO(28)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(29)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(30)=$C(11,12,15,0,0,0,0,0,0,0)_"01TColumn Heading:"
 S VO(31)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(32)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(33)=$C(12,12,15,0,0,0,0,0,0,0)_"01T Default Value:"
 S VO(34)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(35)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(13,10,17,0,0,0,0,0,0,0)_"01T Table Reference:"
 S VO(37)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(38)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(39)=$C(14,7,20,0,0,0,0,0,0,0)_"01T      Pattern Match:"
 S VO(40)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(41)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(42)=$C(15,10,17,0,0,0,0,0,0,0)_"01T Validation Expr:"
 S VO(43)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(44)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(45)=$C(16,5,22,0,0,0,0,0,0,0)_"01T        Minimum Value:"
 S VO(46)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(47)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(48)=$C(17,13,14,0,0,0,0,0,0,0)_"01TMaximum Value:"
 S VO(49)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(50)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(51)=$C(18,5,22,0,0,0,0,0,0,0)_"01T         Input Filter:"
 S VO(52)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(53)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(54)=$C(19,4,23,0,0,0,0,0,0,0)_"01T         Output Filter:"
 S VO(55)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(56)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(57)=$C(20,5,22,0,0,0,0,0,0,0)_"01T    Null Substitution:"
 S VO(58)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(59)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(60)=$C(21,10,17,0,0,0,0,0,0,0)_"01T Unit of Measure:"
 S VO(61)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(62)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(63)=$C(22,14,13,0,0,0,0,0,0,0)_"01T String Mask:"
 S VO(64)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(65)=$C(23,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fDBSDOM) ; Display screen data
  S:'$D(vobj(fDBSDOM,0)) vobj(fDBSDOM,0)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),0)),1:"")
  S:'$D(vobj(fDBSDOM,1)) vobj(fDBSDOM,1)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),1)),1:"")
 N V
 I %O=5 N DELETE,DOM,SYSSN
 I   S (DELETE,DOM,SYSSN)=""
 E  S DELETE=$get(DELETE) S DOM=$get(DOM) S SYSSN=$get(SYSSN)
 ;
 S DELETE=$get(DELETE)
 S DOM=$get(DOM)
 S SYSSN=$get(SYSSN)
 ;
 S VO="105|66|13|"
 S VO(66)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^UTLREAD($get(%FN)))
 S VO(67)=$C(3,28,3,2,0,0,0,0,0,0)_"00U"_$get(SYSSN)
 S VO(68)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str($P(vobj(fDBSDOM,0),$C(124),19),"MM/DD/YEAR")
 S VO(69)=$C(4,28,20,2,0,0,0,0,0,0)_"00U"_$get(DOM)
 S VO(70)=$C(4,58,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
 S VO(71)=$C(4,70,10,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBSDOM,0),$C(124),20),1,10)
 S VO(72)=$C(6,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),1):"Y",1:"N")
 S VO(73)=$C(6,28,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),1),1,40)
 S VO(74)=$C(7,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),2):"Y",1:"N")
 S VO(75)=$C(7,28,1,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBSDOM,0),$C(124),2),1)
 S VO(76)=$C(8,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),3):"Y",1:"N")
 S VO(77)=$C(8,28,5,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBSDOM,0),$C(124),3)
 S VO(78)=$C(9,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),4):"Y",1:"N")
 S VO(79)=$C(9,28,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBSDOM,0),$C(124),4)
 S VO(80)=$C(10,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),15):"Y",1:"N")
 S VO(81)=$C(10,28,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBSDOM,0),$C(124),15)
 S VO(82)=$C(11,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),6):"Y",1:"N")
 S VO(83)=$C(11,28,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),6),1,40)
 S VO(84)=$C(12,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),14):"Y",1:"N")
 S VO(85)=$C(12,28,52,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),14),1,52)
 S VO(86)=$C(13,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),5):"Y",1:"N")
 S VO(87)=$C(13,28,52,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),5),1,52)
 S VO(88)=$C(14,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),10):"Y",1:"N")
 S VO(89)=$C(14,28,52,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),10),1,52)
 S VO(90)=$C(15,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),13):"Y",1:"N")
 S VO(91)=$C(15,28,52,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),13),1,52)
 S VO(92)=$C(16,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),8):"Y",1:"N")
 S VO(93)=$C(16,28,25,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),8),1,25)
 S VO(94)=$C(17,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),9):"Y",1:"N")
 S VO(95)=$C(17,28,25,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),9),1,25)
 S VO(96)=$C(18,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),12):"Y",1:"N")
 S VO(97)=$C(18,28,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),12),1,40)
 S VO(98)=$C(19,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),11):"Y",1:"N")
 S VO(99)=$C(19,28,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),11),1,40)
 S VO(100)=$C(20,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),7):"Y",1:"N")
 S VO(101)=$C(20,28,20,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),7),1,20)
 S VO(102)=$C(21,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),16):"Y",1:"N")
 S VO(103)=$C(21,28,1,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),16),1)
 S VO(104)=$C(22,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),17):"Y",1:"N")
 S VO(105)=$C(22,28,20,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBSDOM,0),$C(124),17),1,20)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBSDOM) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=39 S VPT=1 S VPB=23 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBSDOM"
 S OLNTB=23001
 ;
 S VFSN("DBSDOM")="zfDBSDOM"
 ;
 ;
 S %TAB(1)=$C(2,27,3)_"01U|*SYSSN|[*]@SYSSN|[SCASYS]"
 S %TAB(2)=$C(2,69,10)_"20D12419|1|[DBSDOM]LTD"
 S %TAB(3)=$C(3,27,20)_"01U|*DOM|[*]@DOM|[DBSDOM]||do VP1^V00S046(.fDBSDOM)"
 S %TAB(4)=$C(3,57,1)_"00L|*DELETE|[*]@DELETE|||do VP2^V00S046(.fDBSDOM)"
 S %TAB(5)=$C(3,69,10)_"20T12420|1|[DBSDOM]USER|||||||||20"
 S %TAB(6)=$C(5,2,1)_"00L12401|1|[DBSDOM]PRDES"
 S %TAB(7)=$C(5,27,40)_"01T12401|1|[DBSDOM]DES|||do VP3^V00S046(.fDBSDOM)"
 S %TAB(8)=$C(6,2,1)_"00L12402|1|[DBSDOM]PRTYP"
 S %TAB(9)=$C(6,27,1)_"01U12402|1|[DBSDOM]TYP|[DBCTLDVFM]||do VP4^V00S046(.fDBSDOM)"
 S %TAB(10)=$C(7,2,1)_"00L12403|1|[DBSDOM]PRLEN"
 S %TAB(11)=$C(7,27,5)_"01N12403|1|[DBSDOM]LEN"
 S %TAB(12)=$C(8,2,1)_"00L12404|1|[DBSDOM]PRSIZ"
 S %TAB(13)=$C(8,27,3)_"00N12404|1|[DBSDOM]SIZ|||||1|80"
 S %TAB(14)=$C(9,2,1)_"00L12415|1|[DBSDOM]PRDEC"
 S %TAB(15)=$C(9,27,2)_"00N12415|1|[DBSDOM]DEC|||||0|16"
 S %TAB(16)=$C(10,2,1)_"00L12406|1|[DBSDOM]PRRHD"
 S %TAB(17)=$C(10,27,40)_"00T12406|1|[DBSDOM]RHD"
 S %TAB(18)=$C(11,2,1)_"00L12414|1|[DBSDOM]PRDFT"
 S %TAB(19)=$C(11,27,52)_"00T12414|1|[DBSDOM]DFT|||||||||58"
 S %TAB(20)=$C(12,2,1)_"00L12405|1|[DBSDOM]PRTBL"
 S %TAB(21)=$C(12,27,52)_"00T12405|1|[DBSDOM]TBL|||||||||255"
 S %TAB(22)=$C(13,2,1)_"00L12410|1|[DBSDOM]PRPTN"
 S %TAB(23)=$C(13,27,52)_"00T12410|1|[DBSDOM]PTN|||||||||60"
 S %TAB(24)=$C(14,2,1)_"00L12413|1|[DBSDOM]PRVLD"
 S %TAB(25)=$C(14,27,52)_"00T12413|1|[DBSDOM]VLD|||||||||70"
 S %TAB(26)=$C(15,2,1)_"00L12408|1|[DBSDOM]PRMIN"
 S %TAB(27)=$C(15,27,25)_"00T12408|1|[DBSDOM]MIN|||do VP5^V00S046(.fDBSDOM)"
 S %TAB(28)=$C(16,2,1)_"00L12409|1|[DBSDOM]PRMAX"
 S %TAB(29)=$C(16,27,25)_"00T12409|1|[DBSDOM]MAX|||do VP6^V00S046(.fDBSDOM)"
 S %TAB(30)=$C(17,2,1)_"00L12412|1|[DBSDOM]PRIPF"
 S %TAB(31)=$C(17,27,40)_"00T12412|1|[DBSDOM]IPF"
 S %TAB(32)=$C(18,2,1)_"00L12411|1|[DBSDOM]PROPF"
 S %TAB(33)=$C(18,27,40)_"00T12411|1|[DBSDOM]OPF"
 S %TAB(34)=$C(19,2,1)_"00L12407|1|[DBSDOM]PRNLV"
 S %TAB(35)=$C(19,27,20)_"00T12407|1|[DBSDOM]NLV"
 S %TAB(36)=$C(20,2,1)_"00L12416|1|[DBSDOM]PRMSU"
 S %TAB(37)=$C(20,27,1)_"00T12416|1|[DBSDOM]MSU|,C#Currency,D#Distance,V#Volume,W#Weight"
 S %TAB(38)=$C(21,2,1)_"00L12417|1|[DBSDOM]PRMSK"
 S %TAB(39)=$C(21,27,20)_"00T12417|1|[DBSDOM]MSK"
 D VTBL(.fDBSDOM)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBSDOM) ; Create %TAB(array)
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
VP1(fDBSDOM) ; 
 ;
 Q:(X="") 
 ;
 D CHANGE^DBSMACRO("TBL","")
 ;
 Q:(X=V) 
 ;
  K vobj(+$G(fDBSDOM)) S fDBSDOM=$$vRCgetRecord1^RecordDBSDOM(SYSSN,X,0)
 ;
 I ($G(vobj(fDBSDOM,-2))=0) D
 .	;
 .	S %O=0
 .	; Create new data item
 .	S RM=$$^MSG(639)
 .	;
 .	D GOTO^DBSMACRO("DBSDOM.DES")
 .	Q 
 E  D
 .	;
 .	S %O=1
 .	K REQ
 .	Q 
 ;
 S DELETE=0
 ;
 D DISPLAY^DBSMACRO("ALL")
 ;
 Q 
VP2(fDBSDOM) ; 
 ;
 Q:'X 
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8 S rs=$$vOpen1()
 ;
 I $$vFetch1() D
 .	;
 .	S ER=1
 .	; Domain references exist
 .	S RM=$$^MSG(851)
 .	Q 
 ;
 I 'ER D GOTO^DBSMACRO("END")
 ;
 Q 
VP3(fDBSDOM) ; 
  S:'$D(vobj(fDBSDOM,0)) vobj(fDBSDOM,0)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),0)),1:"")
 ;
 N HDR
 ;
 Q:((X="")!(X=V)) 
 ;
 ; If long description, split for report header
 S HDR=""
 I ($P(vobj(fDBSDOM,0),$C(124),3)<$L(X)),(X?1A.E1" "1E.E) D
 .	;
 .	N I N ptr
 .	;
 .	S ptr=$L(X)\2
 .	;
 .	I $E(X,ptr)=" " S HDR=$E(X,1,ptr-1)_"@"_$E(X,ptr+1,1048575)
 .	E  F I=1:1:ptr D  Q:'(HDR="") 
 ..		;
 ..		I $E(X,ptr+I)=" " S HDR=$E(X,1,ptr+I-1)_"@"_$E(X,ptr+I+1,1048575)
 ..		E  I $E(X,ptr-I)=" " S HDR=$E(X,1,ptr-I-1)_"@"_$E(X,ptr-I+1,1048575)
 ..		Q 
 .	Q 
 ;
 I (HDR="") S HDR=X
 ;
  S vobj(fDBSDOM,-100,0)="" S $P(vobj(fDBSDOM,0),$C(124),6)=HDR
 ;
 Q 
VP4(fDBSDOM) ; 
 ;
 Q:((X="")!(X=V)) 
 ;
 N dvfm S dvfm=$G(^DBCTL("SYS","DVFM",X))
 ;
 D DEFAULT^DBSMACRO("DBSDOM.LEN",$P(dvfm,$C(124),4))
 D DEFAULT^DBSMACRO("DBSDOM.SIZ",$P(dvfm,$C(124),9))
 D DEFAULT^DBSMACRO("DBSDOM.NLV",$P(dvfm,$C(124),5))
 D DEFAULT^DBSMACRO("DBSDOM.OPF",$P(dvfm,$C(124),2))
 D DEFAULT^DBSMACRO("DBSDOM.IPF",$P(dvfm,$C(124),3))
 D DEFAULT^DBSMACRO("DBSDOM.MSK",$P(dvfm,$C(124),6))
 ;
 D DISPLAY^DBSMACRO("ALL")
 ;
 Q 
VP5(fDBSDOM) ; 
  S:'$D(vobj(fDBSDOM,0)) vobj(fDBSDOM,0)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),0)),1:"")
 ;
 Q:(X="") 
 ;
 Q:(($E(X,1,2)="<<")&($E(X,$L(X)-2+1,1048575)=">>")) 
 ;
 Q:($D(^STBL("JRNFUNC",X))#2) 
 ;
 I ($L(X)>$P(vobj(fDBSDOM,0),$C(124),3)) D  Q 
 .	;
 .	S ER=1
 .	; Maximum length allowed - ~p1
 .	S RM=$$^MSG(1690,$P(vobj(fDBSDOM,0),$C(124),3))
 .	Q 
 ;
 I (($P(vobj(fDBSDOM,0),$C(124),2)="D")!($P(vobj(fDBSDOM,0),$C(124),2)="C")) D
 .	;
 .	N retval
 .	;
 .	; Validate format - will return ER/RM if bad
 .	S retval=$$INT^%ZM(X,$P(vobj(fDBSDOM,0),$C(124),2))
 .	Q 
 ;
 Q 
VP6(fDBSDOM) ; 
  S:'$D(vobj(fDBSDOM,0)) vobj(fDBSDOM,0)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),0)),1:"")
 ;
 Q:(X="") 
 ;
 Q:(($E(X,1,2)="<<")&($E(X,$L(X)-2+1,1048575)=">>")) 
 ;
 Q:($D(^STBL("JRNFUNC",X))#2) 
 ;
 I ($L(X)>$P(vobj(fDBSDOM,0),$C(124),3)) D  Q 
 .	;
 .	S ER=1
 .	; Maximum length allowed - ~p1
 .	S RM=$$^MSG(1690,$P(vobj(fDBSDOM,0),$C(124),3))
 .	Q 
 ;
 I (($P(vobj(fDBSDOM,0),$C(124),2)="D")!($P(vobj(fDBSDOM,0),$C(124),2)="C")) D
 .	;
 .	N retval
 .	;
 .	; Validate format - will return ER/RM if bad
 .	S retval=$$INT^%ZM(X,$P(vobj(fDBSDOM,0),$C(124),2))
 .	Q 
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fDBSDOM)
 D VDA1(.fDBSDOM)
 D ^DBSPNT()
 Q 
 ;
VW(fDBSDOM) ; 
 D VDA1(.fDBSDOM)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBSDOM) ; 
 D VDA1(.fDBSDOM)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBSDOM)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBSDOM" D vSET1(.fDBSDOM,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBSDOM,di,X) ; 
  D propSet^DBSDYNRA(fDBSDOM,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBSDOM" Q $$vREAD1(.fDBSDOM,di)
 Q ""
vREAD1(fDBSDOM,di) ; 
 Q $$propGet^DBSDYNRA(fDBSDOM,di)
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
 ;
vOpen1() ; DI FROM DBTBL1D,DBTBL1 WHERE %LIBS='SYSDEV' AND DOM=:DOM
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(DOM) I vos3="",'$D(DOM) G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBINDX("SYSDEV","DOM","PBS",vos3,vos4),1) I vos4="" G vL1a0
 S vos5="SYSDEV",vos6=vos4
 I '($D(^DBTBL("SYSDEV",1,vos4))) S vos5=vos2,vos6=vos2
 S vos7=0 I '(vos4=vos6) S vos7=1
 S vos8=""
vL1a9 S vos8=$O(^DBINDX("SYSDEV","DOM","PBS",vos3,vos4,vos8),1) I vos8="" G vL1a4
 I vos7 S vos5=vos2,vos6=vos2
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a9
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos8=vos2:"",1:vos8)
 ;
 Q 1
