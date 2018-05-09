 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL1 ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S053(%O,fDBTBL1) ; DBS -  - SID= <DBTBL1> File Definition
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fDBTBL1)#2)  K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vcdmNew^RecordDBTBL1()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL1" S VPGM=$T(+0) S VSNAME="File Definition"
 S VFSN("DBTBL1")="zfDBTBL1"
 S vPSL=1
 S KEYS(1)=vobj(fDBTBL1,-3)
 S KEYS(2)=vobj(fDBTBL1,-4)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.fDBTBL1) D VDA1(.fDBTBL1) D ^DBSPNT() Q 
 ;
 ; Display Pre-Processor
 ;
 I '%O D VNEW(.fDBTBL1) D VDSPPRE(.fDBTBL1) Q:$get(ER)  D VPR(.fDBTBL1) D VDA1(.fDBTBL1)
 I %O D VLOD(.fDBTBL1) Q:$get(ER)  D VDSPPRE(.fDBTBL1) Q:$get(ER)  D VPR(.fDBTBL1) D VDA1(.fDBTBL1)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fDBTBL1)
 Q 
 ;
VNEW(fDBTBL1) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBTBL1)
 D VLOD(.fDBTBL1)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
 Q:(vobj(fDBTBL1,-3)="")!(vobj(fDBTBL1,-4)="") 
 Q:%O  S ER=0 I (vobj(fDBTBL1,-3)="")!(vobj(fDBTBL1,-4)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID") Q 
  N V1,V2 S V1=vobj(fDBTBL1,-3),V2=vobj(fDBTBL1,-4) I ($D(^DBTBL(V1,1,V2))) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(fDBTBL1,10),$C(124),1)=""  S:'$D(vobj(fDBTBL1,-100,10,"DEL")) vobj(fDBTBL1,-100,10,"DEL")="N001"_$P(vobj(fDBTBL1,10),$C(124),1),vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),1)=124
 I $P(vobj(fDBTBL1,10),$C(124),3)=""  S:'$D(vobj(fDBTBL1,-100,10,"NETLOC")) vobj(fDBTBL1,-100,10,"NETLOC")="N003"_$P(vobj(fDBTBL1,10),$C(124),3),vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),3)=0
 I $P(vobj(fDBTBL1,100),$C(124),2)=""  S:'$D(vobj(fDBTBL1,-100,100,"RECTYP")) vobj(fDBTBL1,-100,100,"RECTYP")="N002"_$P(vobj(fDBTBL1,100),$C(124),2),vobj(fDBTBL1,-100,100)="" S $P(vobj(fDBTBL1,100),$C(124),2)=1
 I $P(vobj(fDBTBL1,10),$C(124),2)=""  S:'$D(vobj(fDBTBL1,-100,10,"SYSSN")) vobj(fDBTBL1,-100,10,"SYSSN")="U002"_$P(vobj(fDBTBL1,10),$C(124),2),vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),2)="PBS"
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBTBL1) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBTBL1) ; Display screen prompts
 S VO="72||13|0"
 S VO(0)="|0"
 S VO(1)=$C(1,2,80,1,0,0,0,0,0,0)_"01T                        File Definition (Header Page)                           "
 S VO(2)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(3)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(4)=$C(3,8,9,0,0,0,0,0,0,0)_"01T File ID:"
 S VO(5)=$C(3,34,5,0,0,0,0,0,0,0)_"01TUser:"
 S VO(6)=$C(3,56,13,0,0,0,0,0,0,0)_"01TLast Updated:"
 S VO(7)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(8)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(9)=$C(4,4,13,1,0,0,0,0,0,0)_"01T Description:"
 S VO(10)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(11)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(14)=$C(6,9,13,1,0,0,0,0,0,0)_"01T System Name:"
 S VO(15)=$C(6,42,25,1,0,0,0,0,0,0)_"01T Documentation File Name:"
 S VO(16)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(17)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(7,9,13,0,0,0,0,0,0,0)_"01T Global Name:"
 S VO(19)=$C(7,47,20,0,0,0,0,0,0,0)_"01TSupertype File Name:"
 S VO(20)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(21)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(22)=$C(8,4,18,0,0,0,0,0,0,0)_"01T Local Array Name:"
 S VO(23)=$C(8,48,19,0,0,0,0,0,0,0)_"01TProtection Routine:"
 S VO(24)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(25)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(26)=$C(9,6,16,0,0,0,0,0,0,0)_"01TPublish Routine:"
 S VO(27)=$C(9,56,11,1,0,0,0,0,0,0)_"01T File Type:"
 S VO(28)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(29)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(30)=$C(10,55,12,0,0,0,0,0,0,0)_"01TPSL Package:"
 S VO(31)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(32)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(33)=$C(11,6,16,1,0,0,0,0,0,0)_"01T Primary Key(s):"
 S VO(34)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(35)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(37)=$C(13,4,18,1,0,0,0,0,0,0)_"01T Network Location:"
 S VO(38)=$C(13,26,16,1,0,0,0,0,0,0)_"01T Enable Logging:"
 S VO(39)=$C(13,47,13,1,0,0,0,0,0,0)_"01T Record Type:"
 S VO(40)=$C(13,64,11,0,0,0,0,0,0,0)_"01T Delimiter:"
 S VO(41)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(42)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(43)=$C(14,26,30,0,0,0,0,0,0,0)_"01T Look-Up Table Display Format "
 S VO(44)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(45)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(46)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(47)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(48)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(49)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(50)=$C(17,4,6,0,0,0,0,0,0,0)_"01TQuery:"
 S VO(51)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(52)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(53)=$C(18,4,39,0,0,0,0,0,0,0)_"01TRecord Existed Indicator (node number):"
 S VO(54)=$C(18,54,21,0,0,0,0,0,0,0)_"01TValid for Extraction:"
 S VO(55)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(56)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(57)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(58)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(59)=$C(20,4,74,0,0,0,0,0,0,0)_"01T------------ Column Names Used for Keeping Audit Information -------------"
 S VO(60)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(61)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(62)=$C(21,9,7,0,0,0,0,0,0,0)_"01TCreated"
 S VO(63)=$C(21,17,8,0,0,0,0,0,0,0)_"01TBy User:"
 S VO(64)=$C(21,40,5,0,0,0,0,0,0,0)_"01TDate:"
 S VO(65)=$C(21,60,5,0,0,0,0,0,0,0)_"01TTime:"
 S VO(66)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(67)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(68)=$C(22,9,16,0,0,0,0,0,0,0)_"01TUpdated By User:"
 S VO(69)=$C(22,40,5,0,0,0,0,0,0,0)_"01TDate:"
 S VO(70)=$C(22,60,5,0,0,0,0,0,0,0)_"01TTime:"
 S VO(71)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(72)=$C(23,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fDBTBL1) ; Display screen data
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,13)) vobj(fDBTBL1,13)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),13)),1:"")
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
  S:'$D(vobj(fDBTBL1,12)) vobj(fDBTBL1,12)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),12)),1:"")
  S:'$D(vobj(fDBTBL1,99)) vobj(fDBTBL1,99)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),99)),1:"")
  S:'$D(vobj(fDBTBL1,22)) vobj(fDBTBL1,22)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),22)),1:"")
  S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
  S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
  S:'$D(vobj(fDBTBL1,14)) vobj(fDBTBL1,14)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),14)),1:"")
 N V
 ;
 S VO="101|73|13|0"
 S VO(73)=$C(3,18,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(fDBTBL1,-4),1,12)
 S VO(74)=$C(3,40,15,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL1,10),$C(124),11),1,15)
 S VO(75)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str($P(vobj(fDBTBL1,10),$C(124),10),"MM/DD/YEAR")
 S VO(76)=$C(4,18,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1),$C(124),1),1,40)
 S VO(77)=$C(6,23,3,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,10),$C(124),2),1,3)
 S VO(78)=$C(6,68,13,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,13),$C(124),1),1,30)
 S VO(79)=$C(7,23,20,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,0),$C(124),1),1,20)
 S VO(80)=$C(7,68,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,10),$C(124),4),1,12)
 S VO(81)=$C(8,23,12,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,12),$C(124),1),1,12)
 S VO(82)=$C(8,68,4,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,99),$C(124),3),1,4)
 S VO(83)=$C(9,23,30,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,99),$C(124),6),1,30)
 S VO(84)=$C(9,68,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),12)
 S VO(85)=$C(10,68,13,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,22),$C(124),11),1,40)
 S VO(86)=$C(11,23,58,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,16),$C(124),1),1,60)
 S VO(87)=$C(13,23,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),3)
 S VO(88)=$C(13,44,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,100),$C(124),5):"Y",1:"N")
 S VO(89)=$C(13,61,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,100),$C(124),2)
 S VO(90)=$C(13,76,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),1)
 S VO(91)=$C(15,4,76,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,10),$C(124),6),1,76)
 S VO(92)=$C(16,4,76,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,10),$C(124),9),1,76)
 S VO(93)=$C(17,11,65,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,14),$C(124),1),1,65)
 S VO(94)=$C(18,44,6,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),13)
 S VO(95)=$C(18,76,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,22),$C(124),1):"Y",1:"N")
 S VO(96)=$C(21,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,100),$C(124),3),1,12)
 S VO(97)=$C(21,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,100),$C(124),4),1,12)
 S VO(98)=$C(21,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,100),$C(124),8),1,12)
 S VO(99)=$C(22,26,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,100),$C(124),9),1,12)
 S VO(100)=$C(22,46,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,100),$C(124),10),1,12)
 S VO(101)=$C(22,66,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,100),$C(124),11),1,12)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL1) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=29 S VPT=1 S VPB=23 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1"
 S OLNTB=23001
 ;
 S VFSN("DBTBL1")="zfDBTBL1"
 ;
 ;
 S %TAB(1)=$C(2,17,12)_"21U12402|1|[DBTBL1]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||25"
 S %TAB(2)=$C(2,39,15)_"20T12411|1|[DBTBL1]USER|||||||||40"
 S %TAB(3)=$C(2,69,10)_"20D12410|1|[DBTBL1]LTD"
 S %TAB(4)=$C(3,17,40)_"01T12401|1|[DBTBL1]DES"
 S %TAB(5)=$C(5,22,3)_"01U12402|1|[DBTBL1]SYSSN|[SCASYS]"
 S %TAB(6)=$C(5,67,13)_"01U12401|1|[DBTBL1]FDOC|||||||||30"
 S %TAB(7)=$C(6,22,20)_"00T12401|1|[DBTBL1]GLOBAL||if ((X?1A.AN)!(X?1""%"".AN)!(X?1""[""1E.E1""]""1E.E))|||||||31"
 S %TAB(8)=$C(6,67,12)_"00U12404|1|[DBTBL1]PARFID|[DBTBL1]||||||||25"
 S %TAB(9)=$C(7,22,12)_"00T12401|1|[DBTBL1]FSN||if X?1A.AN.E!(X?1""%"".AN.E)|do VP1^V00S053(.fDBTBL1)"
 S %TAB(10)=$C(7,67,4)_"00U12403|1|[DBTBL1]FPN"
 S %TAB(11)=$C(8,22,30)_"00T12406|1|[DBTBL1]PUBLISH"
 S %TAB(12)=$C(8,67,1)_"01N12412|1|[DBTBL1]FILETYP|[DBCTLFILETYP]||do VP2^V00S053(.fDBTBL1)"
 S %TAB(13)=$C(9,67,13)_"00T12411|1|[DBTBL1]PSLPACKAGE|||||||||40"
 S %TAB(14)=$C(10,22,58)_"01U12401|1|[DBTBL1]ACCKEYS|@SELDI^DBSFUN(FID,.X)||do VP3^V00S053(.fDBTBL1)||||||100"
 S %TAB(15)=$C(12,22,1)_"01N12403|1|[DBTBL1]NETLOC|,0#Server Only,1#Client Only,2#Both||do VP4^V00S053(.fDBTBL1)"
 S %TAB(16)=$C(12,43,1)_"00L12405|1|[DBTBL1]LOG|||do VP5^V00S053(.fDBTBL1)"
 S %TAB(17)=$C(12,60,2)_"01N12402|1|[DBTBL1]RECTYP|,0#None,1#Unsegmented,10#Node [Segmented],11#Mixed type 1&10||do VP6^V00S053(.fDBTBL1)"
 S %TAB(18)=$C(12,75,3)_"00N12401|1|[DBTBL1]DEL|[DBCTLDELIM]"
 S %TAB(19)=$C(14,3,76)_"00T12406|1|[DBTBL1]DFTDES|@SELDI^DBSFUN(FID,.X)||do VP7^V00S053(.fDBTBL1)||||||200"
 S %TAB(20)=$C(15,3,76)_"00T12409|1|[DBTBL1]DFTDES1|@SELDI^DBSFUN(FID,.X)||do VP8^V00S053(.fDBTBL1)||||||200"
 S %TAB(21)=$C(16,10,65)_"00T12401|1|[DBTBL1]QID1|||do VP9^V00S053(.fDBTBL1)||||||100"
 S %TAB(22)=$C(17,43,6)_"00N12413|1|[DBTBL1]EXIST"
 S %TAB(23)=$C(17,75,1)_"00L12401|1|[DBTBL1]VAL4EXT"
 S %TAB(24)=$C(20,25,12)_"00U12403|1|[DBTBL1]PTRUSER|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>"""
 S %TAB(25)=$C(20,45,12)_"00U12404|1|[DBTBL1]PTRTLD|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP10^V00S053(.fDBTBL1)"
 S %TAB(26)=$C(20,65,12)_"00U12408|1|[DBTBL1]PTRTIM|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP11^V00S053(.fDBTBL1)"
 S %TAB(27)=$C(21,25,12)_"00U12409|1|[DBTBL1]PTRUSERU|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>"""
 S %TAB(28)=$C(21,45,12)_"00U12410|1|[DBTBL1]PTRTLDU|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP12^V00S053(.fDBTBL1)"
 S %TAB(29)=$C(21,65,12)_"00U12411|1|[DBTBL1]PTRTIMU|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP13^V00S053(.fDBTBL1)"
 D VTBL(.fDBTBL1)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBTBL1) ; Create %TAB(array)
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
VP1(fDBTBL1) ; 
 ;
 I (X="") D  Q 
 .	;
 .	; Data required
 .	S RM=$$^MSG(741)
 .	Q 
 ;
 ; Limit new or changed entries to 8 characters
 I ($L(X)>8),(X'=V) D
 .	;
 .	S ER=1
 .	; Limit short name to ~p1 characters
 .	S RM=$$^MSG(1076,8)
 .	Q 
 ;
 Q 
VP2(fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
  S:'$D(vobj(fDBTBL1,12)) vobj(fDBTBL1,12)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),12)),1:"")
 ;
 ; Global name required except dummy files
 ;
 I (+X'=+5) D  Q:ER 
 .	;
 .	I ($P(vobj(fDBTBL1,0),$C(124),1)="") D  Q 
 ..		;
 ..		S ER=1
 ..		; Invalid global name
 ..		S RM=$$^MSG(1365)
 ..		Q 
 .	;
 .	I ($P(vobj(fDBTBL1,12),$C(124),1)="") D  Q 
 ..		;
 ..		S ER=1
 ..		; Missing posting array
 ..		S RM=$$^MSG(1765)
 ..		Q 
 .	Q 
 ; Dummy table (type 5), skip next two prompts
 E  D  Q 
 .	;
 .	D DELETE^DBSMACRO("[DBTBL1]UDACC")
 .	D DELETE^DBSMACRO("[DBTBL1]UDFILE")
 .	D GOTO^DBSMACRO("[DBTBL1]ACCKEYS")
 .	Q 
 ;
 ; Defaults for tables mapped to certain globals
 I (",CTBL,STBL,TRN,UTBL,"[(","_$P(vobj(fDBTBL1,0),$C(124),1)_",")) D
 .	;
 .	I (+X'=+5) D
 ..		;
 ..		D DEFAULT^DBSMACRO("[DBTBL1]NETLOC",2)
 ..		D DEFAULT^DBSMACRO("[DBTBL1]LOG",1)
 ..		Q 
 .	E  D
 ..		;
 ..		D DEFAULT^DBSMACRO("[DBTBL1]NETLOC",0)
 ..		D DEFAULT^DBSMACRO("[DBTBL1]LOG",0)
 ..		Q 
 .	Q 
 ;
 Q 
VP3(fDBTBL1) ; 
 ;
 N J
 N tok N XTOK
 ;
 I '%O D  Q:ER 
 .	;
 .	; $J cannot be used as a key
 .	I ($ZCONVERT(X,"U")["$J") D  Q 
 ..		;
 ..		S ER=1
 ..		; Invalid syntax ~p1
 ..		S RM=$$^MSG(1477,"$J")
 ..		Q 
 .	;
 .	; Note that we do allow literal bottom keys, but
 .	; only if numbers
 .	I ($E(X,$L(X))="""") D  Q 
 ..		;
 ..		S ER=1
 ..		; Literal key cannot be the last key
 ..		S RM=$$^MSG(4354)
 ..		Q 
 .	Q 
 ;
 ; If change access keys, issue warning
 E  I (X'=V) D
 .	;
 .	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=vobj(fDBTBL1,-4),dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1("SYSDEV",vop2,0,.vop3)
 .	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
 .	;
 .	I ($G(vop3)=1),(X'=$P(vop4,$C(124),1)) D
 ..		;
 ..		; Warning - database reorganization may be required
 ..		S RM=$$^MSG(2960)
 ..		Q 
 . Q 
 ;
 S I(3)="" ; Lookup table
 ;
 ; Tokenized to avoid issue in case of comma in literal key
 S XTOK=$$TOKEN^%ZS(X,.tok)
 F J=1:1:$L(XTOK,",") D  Q:ER 
 .	;
 .	N key
 .	;
 .	S key=$piece(XTOK,",",J)
 .	S key=$$UNTOK^%ZS(key,tok)
 .	;
 .	Q:$$isLit^UCGM(key) 
 .	;
 .	I '$$VALIDKEY^DBSGETID(key) D  Q 
 ..		;
 ..		S ER=1
 ..		; Alphanumeric format only
 ..		S RM=$$^MSG(248) Q 
 ..		Q 
 .	;
 .	N dbtbl1d,vop5 S dbtbl1d=$$vRCgetRecord1Opt^RecordDBTBL1D("SYSDEV",vobj(fDBTBL1,-4),key,0,.vop5)
 .	;
 .	I ($G(vop5)=1) S RM=$get(RM)_", "_$P(dbtbl1d,$C(124),10)
 .	; ~p1, New Primary Key  - ~p2
 .	E  S RM=$$^MSG(5177,$get(RM),key)
 . Q 
 ;
 Q 
VP4(fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
 ;
 I (+X'=+2),(+$P(vobj(fDBTBL1,10),$C(124),12)'=+5),(",CTBL,DBCTL,DBTBL1,DBTBL1D,SCATBL,STBL,TRN,UTBL,"[(","_$P(vobj(fDBTBL1,0),$C(124),1)_",")) D
 .	;
 .	S ER=1
 .	; Set network location for both client and server for ~p1 table
 .	S RM=$$^MSG(2442,vobj(fDBTBL1,-4))
 .	Q 
 ;
 Q 
VP5(fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
 ;
 I (+X'=+1),($P(vobj(fDBTBL1,10),$C(124),3)=2),(",CTBL,DBCTL,DBTBL1,DBTBL1D,SCATBL,STBL,TRN,UTBL,"[(","_$P(vobj(fDBTBL1,0),$C(124),1)_",")) D
 .	;
 .	S ER=1
 .	; Enable Automatic Logging should be on when network location is set to 2
 .	S RM=$$^MSG(2443)
 .	Q 
 ;
 Q 
VP6(fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
 ;
 I (X=0),'($P(vobj(fDBTBL1,0),$C(124),1)="") D
 .	;
 .	S ER=1
 .	; Invalid for record type ~p1
 .	S RM=$$^MSG(1348,0)
 .	Q 
 ;
 Q 
VP7(fDBTBL1) ; 
 D DFTDESCK(.fDBTBL1,1)
 Q 
 ;
DFTDESCK(fDBTBL1,chkAK) ; Check access keys flag
  S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
 ;
 N hit
 N J
 N ACCKEYS N tok N XX
 ;
 Q:(X="") 
 ;
 I (X[":") S XX=$piece(X,":",1)
 E  S XX=X
 ;
 I (XX["""") S $piece(XX,"""",2)="TMP"
 ;
 I chkAK D
 .	;
 .	S ACCKEYS=$P(vobj(fDBTBL1,16),$C(124),1)
 .	S ACCKEYS=$$TOKEN^%ZS(ACCKEYS,.tok)
 .	S hit=0
 .	F J=1:1:$L(ACCKEYS,",") D  Q:hit 
 ..		;
 ..		N key
 ..		;
 ..		S key=$$UNTOK^%ZS($piece(ACCKEYS,",",J),tok)
 ..		I $$vStrLike(XX,"%"_key_"%","") S hit=1
 ..		Q 
 .	Q 
 E  S hit=1
 ;
 I hit D
 .	;
 .	S I(3)=""
 .	;
 .	F J=1:1:$L(XX,",") D  Q:ER 
 ..		;
 ..		N isBad
 ..		N K
 ..		N elem N rem
 ..		;
 ..		S elem=$piece(XX,",",J)
 ..		S rem=""
 ..		;
 ..		I (elem["/") D
 ...			;
 ...			S rem=$piece(elem,"/",2,$L(elem))
 ...			S elem=$piece(elem,"/",1)
 ...			Q 
 ..		;
 ..		I '(elem="")  N V1,V2 S V1=vobj(fDBTBL1,-4),V2=elem I '($D(^DBTBL("SYSDEV",1,V1,9,V2))#2) D  Q 
 ...			;
 ...			S ER=1
 ...			; Invalid data item - ~p1
 ...			S RM=$$^MSG(1298,elem)
 ...			Q 
 ..		;
 ..		Q:(rem="") 
 ..		;
 ..		S isBad=0
 ..		F K=1:1:$L(rem,"/") D  Q:isBad 
 ...			;
 ...			N keyword
 ...			;
 ...			S keyword=$piece($piece(rem,"/",K),"=",1)
 ...			;
 ...			I '$$vStrLike("/LEN/TYP/RHD/ALA","%"_keyword_"%","") S isBad=1
 ...			Q 
 ..		;
 ..		I isBad D
 ...			;
 ...			S ER=1
 ...			; Invalid keyword name
 ...			S RM=$$^MSG(1386)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 E  D
 .	;
 .	S ER=1
 .	; Look_up table does not include primary key
 .	S RM=$$^MSG(1661)
 .	Q 
 ;
 Q 
VP8(fDBTBL1) ; 
 D DFTDESCK(.fDBTBL1,0)
 ;
 Q 
VP9(fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 I ((X["<<*>>")!(X["<<**>>")) S ER=1
 E  I ((X["<<")!(X[">>")) S ER=1
 ;
 I 'ER D
 .	;
 .	N FILES N Q
 .	;
 .	S FILES=vobj(fDBTBL1,-4)
 .	D ^DBSQRY
 .	I ($D(Q)=0) S ER=1
 .	Q 
 ;
 ; Invalid query syntax
 I ER S RM=$$^MSG(1434)
 ;
 Q 
VP10(fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,vobj(fDBTBL1,-4),9,X))
 ;
 I ($P(dbtbl1d,$C(124),9)'="D") D
 .	;
 .	S ER=1
 .	; Invalid data item name - ~p1
 .	S RM=$$^MSG(1300,X)
 .	Q 
 ;
 Q 
VP11(fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,vobj(fDBTBL1,-4),9,X))
 ;
 I ($P(dbtbl1d,$C(124),9)'="C") D
 .	;
 .	S ER=1
 .	; Invalid data item name - ~p1
 .	S RM=$$^MSG(1300,X)
 .	Q 
 ;
 Q 
VP12(fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,vobj(fDBTBL1,-4),9,X))
 ;
 I ($P(dbtbl1d,$C(124),9)'="D") D
 .	;
 .	S ER=1
 .	; Invalid data item name - ~p1
 .	S RM=$$^MSG(1300,X)
 .	Q 
 ;
 Q 
VP13(fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,vobj(fDBTBL1,-4),9,X))
 ;
 I ($P(dbtbl1d,$C(124),9)'="C") D
 .	;
 .	S ER=1
 .	; Invalid data item name - ~p1
 .	S RM=$$^MSG(1300,X)
 .	Q 
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fDBTBL1)
 D VDA1(.fDBTBL1)
 D ^DBSPNT()
 Q 
 ;
VW(fDBTBL1) ; 
 D VDA1(.fDBTBL1)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBTBL1) ; 
 D VDA1(.fDBTBL1)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBTBL1)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL1" D vSET1(.fDBTBL1,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBTBL1,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL1,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL1" Q $$vREAD1(.fDBTBL1,di)
 Q ""
vREAD1(fDBTBL1,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL1,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDSPPRE(fDBTBL1) ; Display Pre-Processor
 N %TAB,vtab ; Disable .MACRO. references to %TAB()
 ;
 ; Global name and file type default logic
 N tbl N ztbl
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
 Q:'($P(vobj(fDBTBL1,0),$C(124),1)="") 
 ; Default globals and other info for common, system, user tables
 F tbl="CTBL","STBL","UTBL" D
 .	I ($E(vobj(fDBTBL1,-4),1,$L(tbl))=tbl) D ZDFT(.fDBTBL1,tbl)
 .	I ($E(vobj(fDBTBL1,-4),1,$L(("Z"_tbl)))=("Z"_tbl)) D ZDFT(.fDBTBL1,tbl)
 .	Q 
 Q 
ZDFT(fDBTBL1,global) ; 
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
  S:'$D(vobj(fDBTBL1,-100,0,"GLOBAL")) vobj(fDBTBL1,-100,0,"GLOBAL")="T001"_$P(vobj(fDBTBL1,0),$C(124),1),vobj(fDBTBL1,-100,0)="" S $P(vobj(fDBTBL1,0),$C(124),1)=global
  S vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),12)=3 ; Domain
  S vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),3)=2 ; Client and server
  S vobj(fDBTBL1,-100,100)="" S $P(vobj(fDBTBL1,100),$C(124),5)=1 ; Enable logging
 Q 
 ;  #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
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
 ; ----------------
 ;  #OPTION ResultClass 1
vStrLike(object,p1,p2) ; String.isLike
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (p1="") Q (object="")
 I p2 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
 I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
 I ($E(p1,$L(p1))="%") Q ($E(object,1,$L($E(p1,1,$L(p1)-1)))=$E(p1,1,$L(p1)-1))
 Q object=p1
