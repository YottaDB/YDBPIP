V01S226(%O,fDBTBL1)	;DBS -  - SID= <DBTBL1> File Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL1 ****
	;
	; 09/14/2007 09:15 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 09:15 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fDBTBL1)#2) K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vDbNew1("","")
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
VNEW(fDBTBL1)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL1)
	D VLOD(.fDBTBL1)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL1)	;
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	 S:'$D(vobj(fDBTBL1,12)) vobj(fDBTBL1,12)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),12)),1:"")
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	Q:(vobj(fDBTBL1,-3)="")!(vobj(fDBTBL1,-4)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL1,-3)="")!(vobj(fDBTBL1,-4)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID") Q 
	 N V1,V2 S V1=vobj(fDBTBL1,-3),V2=vobj(fDBTBL1,-4) I ($D(^DBTBL(V1,1,V2))) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fDBTBL1,10),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1,10),$C(124),1) S $P(vobj(fDBTBL1,10),$C(124),1)=124,vobj(fDBTBL1,-100,10)=""
	I $P(vobj(fDBTBL1,12),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1,12),$C(124),1) S $P(vobj(fDBTBL1,12),$C(124),1)="f"_$E(($TR(FID,"_","z")),1,7),vobj(fDBTBL1,-100,12)=""
	I $P(vobj(fDBTBL1,10),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1,10),$C(124),3) S $P(vobj(fDBTBL1,10),$C(124),3)=0,vobj(fDBTBL1,-100,10)=""
	I $P(vobj(fDBTBL1,100),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1,100),$C(124),2) S $P(vobj(fDBTBL1,100),$C(124),2)=1,vobj(fDBTBL1,-100,100)=""
	I $P(vobj(fDBTBL1,10),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1,10),$C(124),2) S $P(vobj(fDBTBL1,10),$C(124),2)="PBS",vobj(fDBTBL1,-100,10)=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL1)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL1)	; Display screen prompts
	S VO="73||13|0"
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
	S VO(30)=$C(10,7,15,0,0,0,0,0,0,0)_"01TAccess Routine:"
	S VO(31)=$C(10,53,14,0,0,0,0,0,0,0)_"01TFiler Routine:"
	S VO(32)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(34)=$C(11,6,16,1,0,0,0,0,0,0)_"01T Primary Key(s):"
	S VO(35)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(37)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(13,4,18,1,0,0,0,0,0,0)_"01T Network Location:"
	S VO(39)=$C(13,26,16,1,0,0,0,0,0,0)_"01T Enable Logging:"
	S VO(40)=$C(13,47,13,1,0,0,0,0,0,0)_"01T Record Type:"
	S VO(41)=$C(13,64,11,0,0,0,0,0,0,0)_"01T Delimiter:"
	S VO(42)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(43)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(14,26,30,0,0,0,0,0,0,0)_"01T Look-Up Table Display Format "
	S VO(45)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(46)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(49)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(50)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(51)=$C(17,4,6,0,0,0,0,0,0,0)_"01TQuery:"
	S VO(52)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(53)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(54)=$C(18,4,39,0,0,0,0,0,0,0)_"01TRecord Existed Indicator (node number):"
	S VO(55)=$C(18,54,21,0,0,0,0,0,0,0)_"01TValid for Extraction:"
	S VO(56)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(57)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(58)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(59)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(60)=$C(20,4,74,0,0,0,0,0,0,0)_"01T------------ Column Names Used for Keeping Audit Information -------------"
	S VO(61)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(62)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(63)=$C(21,9,7,0,0,0,0,0,0,0)_"01TCreated"
	S VO(64)=$C(21,17,8,0,0,0,0,0,0,0)_"01TBy User:"
	S VO(65)=$C(21,40,5,0,0,0,0,0,0,0)_"01TDate:"
	S VO(66)=$C(21,60,5,0,0,0,0,0,0,0)_"01TTime:"
	S VO(67)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(68)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(69)=$C(22,9,16,0,0,0,0,0,0,0)_"01TUpdated By User:"
	S VO(70)=$C(22,40,5,0,0,0,0,0,0,0)_"01TDate:"
	S VO(71)=$C(22,60,5,0,0,0,0,0,0,0)_"01TTime:"
	S VO(72)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(73)=$C(23,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL1)	; Display screen data
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	 S:'$D(vobj(fDBTBL1,13)) vobj(fDBTBL1,13)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),13)),1:"")
	 S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
	 S:'$D(vobj(fDBTBL1,12)) vobj(fDBTBL1,12)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),12)),1:"")
	 S:'$D(vobj(fDBTBL1,99)) vobj(fDBTBL1,99)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),99)),1:"")
	 S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	 S:'$D(vobj(fDBTBL1,14)) vobj(fDBTBL1,14)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),14)),1:"")
	 S:'$D(vobj(fDBTBL1,22)) vobj(fDBTBL1,22)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),22)),1:"")
	N V
	;
	S VO="103|74|13|0"
	S VO(74)=$C(3,18,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL1,-4)),1,12)
	S VO(75)=$C(3,40,15,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL1,10),$C(124),11)),1,15)
	S VO(76)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBTBL1,10),$C(124),10)),"MM/DD/YEAR")
	S VO(77)=$C(4,18,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1),$C(124),1)),1,40)
	S VO(78)=$C(6,23,3,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,10),$C(124),2)),1,3)
	S VO(79)=$C(6,68,13,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,13),$C(124),1)),1,30)
	S VO(80)=$C(7,23,8,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,0),$C(124),1)),1,8)
	S VO(81)=$C(7,68,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,10),$C(124),4)),1,12)
	S VO(82)=$C(8,23,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,12),$C(124),1)),1,12)
	S VO(83)=$C(8,68,4,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,99),$C(124),3)),1,4)
	S VO(84)=$C(9,23,30,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,99),$C(124),6)),1,30)
	S VO(85)=$C(9,68,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),12)
	S VO(86)=$C(10,23,8,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,99),$C(124),1)),1,8)
	S VO(87)=$C(10,68,8,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,99),$C(124),2)),1,8)
	S VO(88)=$C(11,23,58,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,16),$C(124),1)),1,60)
	S VO(89)=$C(13,23,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),3)
	S VO(90)=$C(13,44,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,100),$C(124),5):"Y",1:"N")
	S VO(91)=$C(13,61,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,100),$C(124),2)
	S VO(92)=$C(13,76,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),1)
	S VO(93)=$C(15,4,76,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,10),$C(124),6)),1,76)
	S VO(94)=$C(16,4,76,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,10),$C(124),9)),1,76)
	S VO(95)=$C(17,11,65,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,14),$C(124),1)),1,65)
	S VO(96)=$C(18,44,6,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1,10),$C(124),13)
	S VO(97)=$C(18,76,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,22),$C(124),1):"Y",1:"N")
	S VO(98)=$C(21,26,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,100),$C(124),3)),1,12)
	S VO(99)=$C(21,46,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,100),$C(124),4)),1,12)
	S VO(100)=$C(21,66,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,100),$C(124),8)),1,12)
	S VO(101)=$C(22,26,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,100),$C(124),9)),1,12)
	S VO(102)=$C(22,46,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,100),$C(124),10)),1,12)
	S VO(103)=$C(22,66,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,100),$C(124),11)),1,12)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL1)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=30 S VPT=1 S VPB=23 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1"
	S OLNTB=23001
	;
	S VFSN("DBTBL1")="zfDBTBL1"
	;
	;
	S %TAB(1)=$C(2,17,12)_"21U12402|1|[DBTBL1]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||256"
	S %TAB(2)=$C(2,39,15)_"20T12411|1|[DBTBL1]USER|||||||||20"
	S %TAB(3)=$C(2,69,10)_"20D12410|1|[DBTBL1]LTD"
	S %TAB(4)=$C(3,17,40)_"01T12401|1|[DBTBL1]DES"
	S %TAB(5)=$C(5,22,3)_"01U12402|1|[DBTBL1]SYSSN|[SCASYS]"
	S %TAB(6)=$C(5,67,13)_"01U12401|1|[DBTBL1]FDOC|||||||||30"
	S %TAB(7)=$C(6,22,8)_"00T12401|1|[DBTBL1]GLOBAL||if ((X?1A.AN)!(X?1""%"".AN)!(X?1""[""1E.E1""]""1E.E))"
	S %TAB(8)=$C(6,67,12)_"00U12404|1|[DBTBL1]PARFID|[DBTBL1]"
	S %TAB(9)=$C(7,22,12)_"00T12401|1|[DBTBL1]FSN||if X?1A.AN.E!(X?1""%"".AN.E)|do VP1^V01S226(.fDBTBL1)"
	S %TAB(10)=$C(7,67,4)_"00U12403|1|[DBTBL1]FPN"
	S %TAB(11)=$C(8,22,30)_"00T12406|1|[DBTBL1]PUBLISH"
	S %TAB(12)=$C(8,67,1)_"01N12412|1|[DBTBL1]FILETYP|[DBCTLFILETYP]||do VP2^V01S226(.fDBTBL1)"
	S %TAB(13)=$C(9,22,8)_"00U12401|1|[DBTBL1]UDACC"
	S %TAB(14)=$C(9,67,8)_"00U12402|1|[DBTBL1]UDFILE|||do VP3^V01S226(.fDBTBL1)"
	S %TAB(15)=$C(10,22,58)_"01U12401|1|[DBTBL1]ACCKEYS|@SELDI^DBSFUN(FID,.X)||do VP4^V01S226(.fDBTBL1)||||||100"
	S %TAB(16)=$C(12,22,1)_"01N12403|1|[DBTBL1]NETLOC|,0#Server Only,1#Client Only,2#Both||do VP5^V01S226(.fDBTBL1)"
	S %TAB(17)=$C(12,43,1)_"00L12405|1|[DBTBL1]LOG|||do VP6^V01S226(.fDBTBL1)"
	S %TAB(18)=$C(12,60,2)_"01N12402|1|[DBTBL1]RECTYP|,0#None,1#Unsegmented,10#Node [Segmented],11#Mixed type 1&10||do VP7^V01S226(.fDBTBL1)"
	S %TAB(19)=$C(12,75,3)_"00N12401|1|[DBTBL1]DEL|[DBCTLDELIM]"
	S %TAB(20)=$C(14,3,76)_"00T12406|1|[DBTBL1]DFTDES|@SELDI^DBSFUN(FID,.X)||do VP8^V01S226(.fDBTBL1)||||||200"
	S %TAB(21)=$C(15,3,76)_"00T12409|1|[DBTBL1]DFTDES1|@SELDI^DBSFUN(FID,.X)||do VP9^V01S226(.fDBTBL1)||||||200"
	S %TAB(22)=$C(16,10,65)_"00T12401|1|[DBTBL1]QID1|||do VP10^V01S226(.fDBTBL1)||||||100"
	S %TAB(23)=$C(17,43,6)_"00N12413|1|[DBTBL1]EXIST"
	S %TAB(24)=$C(17,75,1)_"00L12401|1|[DBTBL1]VAL4EXT"
	S %TAB(25)=$C(20,25,12)_"00U12403|1|[DBTBL1]PTRUSER|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>"""
	S %TAB(26)=$C(20,45,12)_"00U12404|1|[DBTBL1]PTRTLD|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP11^V01S226(.fDBTBL1)"
	S %TAB(27)=$C(20,65,12)_"00U12408|1|[DBTBL1]PTRTIM|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP12^V01S226(.fDBTBL1)"
	S %TAB(28)=$C(21,25,12)_"00U12409|1|[DBTBL1]PTRUSERU|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>"""
	S %TAB(29)=$C(21,45,12)_"00U12410|1|[DBTBL1]PTRTLDU|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP13^V01S226(.fDBTBL1)"
	S %TAB(30)=$C(21,65,12)_"00U12411|1|[DBTBL1]PTRTIMU|[DBTBL1D]:QU ""[DBTBL1D]FID=<<FID>>""||do VP14^V01S226(.fDBTBL1)"
	D VTBL(.fDBTBL1)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL1)	;Create %TAB(array)
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
VP1(fDBTBL1)	;
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
VP2(fDBTBL1)	;
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
VP3(fDBTBL1)	;
	;
	Q:(X="") 
	;
	; Validate routine name
	I (V'=X) S ER=$$VALPGM^DBSCDI(X) Q:ER 
	;
	; Make sure name isn't already used as a filer
	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen1()
	;
	I $$vFetch1() D
	.	;
	.	S ER=1
	.	; ~p1 already exists
	.	S RM=$$^MSG(3019,X)_" - "_rs
	.	Q 
	;
	Q 
VP4(fDBTBL1)	;
	;
	N J
	N tok N XTOK
	;
	I '%O D  Q:ER 
	.	;
	.	; $J cannot be used as a key
	.	I ($$vStrUC(X)["$J") D  Q 
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
	.	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=vobj(fDBTBL1,-4),dbtbl1=$$vDb3("SYSDEV",vop2,.vop3)
	.	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	.	;
	.	I ($G(vop3)=1),(X'=$P(vop4,$C(124),1)) D
	..		;
	..		; Warning - database reorganization may be required
	..		S RM=$$^MSG(2960)
	..		Q 
	.	Q 
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
	.	N dbtbl1d,vop5 S dbtbl1d=$$vDb4("SYSDEV",vobj(fDBTBL1,-4),key,.vop5)
	.	;
	.	I ($G(vop5)=1) S RM=$get(RM)_", "_$P(dbtbl1d,$C(124),10)
	.	; ~p1, New Primary Key  - ~p2
	.	E  S RM=$$^MSG(5177,$get(RM),key)
	.	Q 
	;
	Q 
VP5(fDBTBL1)	;
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
VP6(fDBTBL1)	;
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
VP7(fDBTBL1)	;
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
VP8(fDBTBL1)	;
	D DFTDESCK(.fDBTBL1,1)
	Q 
	;
DFTDESCK(fDBTBL1,chkAK)	;
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
VP9(fDBTBL1)	;
	D DFTDESCK(.fDBTBL1,0)
	;
	Q 
VP10(fDBTBL1)	;
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
VP11(fDBTBL1)	;
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
VP12(fDBTBL1)	;
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
VP13(fDBTBL1)	;
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
VP14(fDBTBL1)	;
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
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL1)
	D VDA1(.fDBTBL1)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL1)	;
	D VDA1(.fDBTBL1)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL1)	;
	D VDA1(.fDBTBL1)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL1)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL1" D vSET1(.fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL1,di,X)	;
	D vCoInd1(fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL1" Q $$vREAD1(.fDBTBL1,di)
	Q ""
vREAD1(fDBTBL1,di)	;
	Q $$vCoInd2(fDBTBL1,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDSPPRE(fDBTBL1)	; Display Pre-Processor
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
ZDFT(fDBTBL1,global)	;
	 S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	N vSetMf S vSetMf=$P(vobj(fDBTBL1,0),$C(124),1) S $P(vobj(fDBTBL1,0),$C(124),1)=global,vobj(fDBTBL1,-100,0)="" D DEFAULT^DBSMACRO("[DBTBL1]GLOBAL",global)
	S vobj(fDBTBL1,-100,10)="",$P(vobj(fDBTBL1,10),$C(124),12)=3 D DEFAULT^DBSMACRO("[DBTBL1]FILETYP",3) ; Domain
	S vobj(fDBTBL1,-100,10)="",$P(vobj(fDBTBL1,10),$C(124),3)=2 D DEFAULT^DBSMACRO("[DBTBL1]NETLOC",2) ; Client and server
	S vobj(fDBTBL1,-100,100)="",$P(vobj(fDBTBL1,100),$C(124),5)=1 D DEFAULT^DBSMACRO("[DBTBL1]LOG",1) ; Enable logging
	Q 
	;  #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLike(object,p1,p2)	; String.isLike
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (p1="") Q (object="")
	I p2 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
	I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
	I ($E(p1,$L(p1))="%") Q ($E(object,1,$L(($E(p1,1,$L(p1)-1))))=($E(p1,1,$L(p1)-1)))
	Q object=p1
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL1.setACCKEYS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,16),"|",1)
	S $P(vobj(vRec,16),"|",1)=vVal S vobj(vRec,-100,16)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL1.setAKEY1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",1)
	S $P(vobj(vRec,1),"|",1)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL1.setAKEY2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,2),"|",1)
	S $P(vobj(vRec,2),"|",1)=vVal S vobj(vRec,-100,2)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL1.setAKEY3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,3),"|",1)
	S $P(vobj(vRec,3),"|",1)=vVal S vobj(vRec,-100,3)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL1.setAKEY4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,4),"|",1)
	S $P(vobj(vRec,4),"|",1)=vVal S vobj(vRec,-100,4)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL1.setAKEY5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,5),"|",1)
	S $P(vobj(vRec,5),"|",1)=vVal S vobj(vRec,-100,5)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL1.setAKEY6(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,6),"|",1)
	S $P(vobj(vRec,6),"|",1)=vVal S vobj(vRec,-100,6)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL1.setAKEY7(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,7),"|",1)
	S $P(vobj(vRec,7),"|",1)=vVal S vobj(vRec,-100,7)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL1.setDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",1)
	S $P(vobj(vRec,10),"|",1)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL1.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL1.setDFLAG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",10)
	S $P(vobj(vRec,22),"|",10)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBTBL1.setDFTDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",6)
	S $P(vobj(vRec,10),"|",6)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBTBL1.setDFTDES1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",9)
	S $P(vobj(vRec,10),"|",9)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordDBTBL1.setDFTHDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",8)
	S $P(vobj(vRec,10),"|",8)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordDBTBL1.setDFTORD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",7)
	S $P(vobj(vRec,10),"|",7)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordDBTBL1.setEXIST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",13)
	S $P(vobj(vRec,10),"|",13)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordDBTBL1.setEXTENDLENGTH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",14)
	S $P(vobj(vRec,10),"|",14)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordDBTBL1.setFDOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,13),"|",1)
	S $P(vobj(vRec,13),"|",1)=vVal S vobj(vRec,-100,13)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordDBTBL1.setFILETYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",12)
	S $P(vobj(vRec,10),"|",12)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordDBTBL1.setFPN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",3)
	S $P(vobj(vRec,99),"|",3)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordDBTBL1.setFSN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,12),"|",1)
	S $P(vobj(vRec,12),"|",1)=vVal S vobj(vRec,-100,12)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS22(vRec,vVal)	; RecordDBTBL1.setGLOBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",1)
	S $P(vobj(vRec,0),"|",1)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS23(vRec,vVal)	; RecordDBTBL1.setGLREF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",1)
	S $P(vobj(vRec,100),"|",1)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS24(vRec,vVal)	; RecordDBTBL1.setLISTDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,101),"|",1)
	S $P(vobj(vRec,101),"|",1)=vVal S vobj(vRec,-100,101)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS25(vRec,vVal)	; RecordDBTBL1.setLISTREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,102),"|",1)
	S $P(vobj(vRec,102),"|",1)=vVal S vobj(vRec,-100,102)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS26(vRec,vVal)	; RecordDBTBL1.setLOG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",5)
	S $P(vobj(vRec,100),"|",5)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS27(vRec,vVal)	; RecordDBTBL1.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",10)
	S $P(vobj(vRec,10),"|",10)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS28(vRec,vVal)	; RecordDBTBL1.setMPLCTDD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",5)
	S $P(vobj(vRec,10),"|",5)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS29(vRec,vVal)	; RecordDBTBL1.setNETLOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",3)
	S $P(vobj(vRec,10),"|",3)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS30(vRec,vVal)	; RecordDBTBL1.setPARFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",4)
	S $P(vobj(vRec,10),"|",4)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS31(vRec,vVal)	; RecordDBTBL1.setPREDAEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",5)
	S $P(vobj(vRec,22),"|",5)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS32(vRec,vVal)	; RecordDBTBL1.setPTRTIM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",8)
	S $P(vobj(vRec,100),"|",8)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS33(vRec,vVal)	; RecordDBTBL1.setPTRTIMU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",11)
	S $P(vobj(vRec,100),"|",11)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS34(vRec,vVal)	; RecordDBTBL1.setPTRTLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",4)
	S $P(vobj(vRec,100),"|",4)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS35(vRec,vVal)	; RecordDBTBL1.setPTRTLDU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",10)
	S $P(vobj(vRec,100),"|",10)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS36(vRec,vVal)	; RecordDBTBL1.setPTRUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",3)
	S $P(vobj(vRec,100),"|",3)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS37(vRec,vVal)	; RecordDBTBL1.setPTRUSERU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",9)
	S $P(vobj(vRec,100),"|",9)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS38(vRec,vVal)	; RecordDBTBL1.setPUBLISH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",6)
	S $P(vobj(vRec,99),"|",6)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS39(vRec,vVal)	; RecordDBTBL1.setQID1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,14),"|",1)
	S $P(vobj(vRec,14),"|",1)=vVal S vobj(vRec,-100,14)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS40(vRec,vVal)	; RecordDBTBL1.setRECTYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",2)
	S $P(vobj(vRec,100),"|",2)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS41(vRec,vVal)	; RecordDBTBL1.setRFLAG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",9)
	S $P(vobj(vRec,22),"|",9)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS42(vRec,vVal)	; RecordDBTBL1.setSCREEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",8)
	S $P(vobj(vRec,22),"|",8)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS43(vRec,vVal)	; RecordDBTBL1.setSYSSN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",2)
	S $P(vobj(vRec,10),"|",2)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS44(vRec,vVal)	; RecordDBTBL1.setUDACC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",1)
	S $P(vobj(vRec,99),"|",1)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS45(vRec,vVal)	; RecordDBTBL1.setUDFILE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",2)
	S $P(vobj(vRec,99),"|",2)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS46(vRec,vVal)	; RecordDBTBL1.setUDPOST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",5)
	S $P(vobj(vRec,99),"|",5)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS47(vRec,vVal)	; RecordDBTBL1.setUDPRE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",4)
	S $P(vobj(vRec,99),"|",4)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS48(vRec,vVal)	; RecordDBTBL1.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",11)
	S $P(vobj(vRec,10),"|",11)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS49(vRec,vVal)	; RecordDBTBL1.setVAL4EXT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",1)
	S $P(vobj(vRec,22),"|",1)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrGSub(object,tag,del1,del2,pos)	; String.getSub passing Numbers
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (pos="") S pos=1
	I (tag=""),(del1="") Q $E(object,pos)
	S del1=$CHAR(del1)
	I (tag="") Q $piece(object,del1,pos)
	S del2=$CHAR(del2)
	I del1=del2,pos>1 S $ZS="-1,"_$ZPOS_","_"%PSL-E-STRGETSUB" X $ZT
	Q $piece($piece($piece((del1_object),del1_tag_del2,2),del1,1),del2,pos)
	; ----------------
	;  #OPTION ResultClass 0
vStrPSub(object,ins,tag,del1,del2,pos)	; String.putSub passing Numbers
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (pos="") S pos=1
	I (tag=""),(del1="") S $E(object,pos)=ins Q object
	S del1=$CHAR(del1)
	I (tag="") S $piece(object,del1,pos)=ins Q $$RTCHR^%ZFUNC(object,del1)
	S del2=$CHAR(del2)
	I del1=del2,pos>1 S $ZS="-1,"_$ZPOS_","_"%PSL-E-STRPUTSUB" X $ZT
	I (object="") S $piece(object,del2,pos)=ins Q tag_del2_object
	N field S field=$piece($piece((del1_object),(del1_tag_del2),2),del1,1)
	I '(field="") D
	.	N z S z=del1_tag_del2_field
	.	S object=$piece((del1_object),z,1)_$piece((del1_object),z,2)
	.	I $E(object,1)=del1 S object=$E(object,2,1048575)
	.	Q 
	S $piece(field,del2,pos)=ins
	I (object="") Q tag_del2_field
	Q object_del1_tag_del2_field
	; ----------------
	;  #OPTION ResultClass 0
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL1.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL1",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vNod'="FID",'$D(vobj(vOid,vNod)) D
	.	I '$get(vobj(vOid,-2)) S vobj(vOid,vNod)="" Q 
	.	S vobj(vOid,vNod)=$get(^DBTBL(vobj(vOid,-3),1,vobj(vOid,-4),vNod))
	.	Q 
	I vCol="ACCKEYS" D vCoMfS1(vOid,vVal) Q 
	I vCol="AKEY1" D vCoMfS2(vOid,vVal) Q 
	I vCol="AKEY2" D vCoMfS3(vOid,vVal) Q 
	I vCol="AKEY3" D vCoMfS4(vOid,vVal) Q 
	I vCol="AKEY4" D vCoMfS5(vOid,vVal) Q 
	I vCol="AKEY5" D vCoMfS6(vOid,vVal) Q 
	I vCol="AKEY6" D vCoMfS7(vOid,vVal) Q 
	I vCol="AKEY7" D vCoMfS8(vOid,vVal) Q 
	I vCol="DEL" D vCoMfS9(vOid,vVal) Q 
	I vCol="DES" D vCoMfS10(vOid,vVal) Q 
	I vCol="DFLAG" D vCoMfS11(vOid,vVal) Q 
	I vCol="DFTDES" D vCoMfS12(vOid,vVal) Q 
	I vCol="DFTDES1" D vCoMfS13(vOid,vVal) Q 
	I vCol="DFTHDR" D vCoMfS14(vOid,vVal) Q 
	I vCol="DFTORD" D vCoMfS15(vOid,vVal) Q 
	I vCol="EXIST" D vCoMfS16(vOid,vVal) Q 
	I vCol="EXTENDLENGTH" D vCoMfS17(vOid,vVal) Q 
	I vCol="FDOC" D vCoMfS18(vOid,vVal) Q 
	I vCol="FILETYP" D vCoMfS19(vOid,vVal) Q 
	I vCol="FPN" D vCoMfS20(vOid,vVal) Q 
	I vCol="FSN" D vCoMfS21(vOid,vVal) Q 
	I vCol="GLOBAL" D vCoMfS22(vOid,vVal) Q 
	I vCol="GLREF" D vCoMfS23(vOid,vVal) Q 
	I vCol="LISTDFT" D vCoMfS24(vOid,vVal) Q 
	I vCol="LISTREQ" D vCoMfS25(vOid,vVal) Q 
	I vCol="LOG" D vCoMfS26(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS27(vOid,vVal) Q 
	I vCol="MPLCTDD" D vCoMfS28(vOid,vVal) Q 
	I vCol="NETLOC" D vCoMfS29(vOid,vVal) Q 
	I vCol="PARFID" D vCoMfS30(vOid,vVal) Q 
	I vCol="PREDAEN" D vCoMfS31(vOid,vVal) Q 
	I vCol="PTRTIM" D vCoMfS32(vOid,vVal) Q 
	I vCol="PTRTIMU" D vCoMfS33(vOid,vVal) Q 
	I vCol="PTRTLD" D vCoMfS34(vOid,vVal) Q 
	I vCol="PTRTLDU" D vCoMfS35(vOid,vVal) Q 
	I vCol="PTRUSER" D vCoMfS36(vOid,vVal) Q 
	I vCol="PTRUSERU" D vCoMfS37(vOid,vVal) Q 
	I vCol="PUBLISH" D vCoMfS38(vOid,vVal) Q 
	I vCol="QID1" D vCoMfS39(vOid,vVal) Q 
	I vCol="RECTYP" D vCoMfS40(vOid,vVal) Q 
	I vCol="RFLAG" D vCoMfS41(vOid,vVal) Q 
	I vCol="SCREEN" D vCoMfS42(vOid,vVal) Q 
	I vCol="SYSSN" D vCoMfS43(vOid,vVal) Q 
	I vCol="UDACC" D vCoMfS44(vOid,vVal) Q 
	I vCol="UDFILE" D vCoMfS45(vOid,vVal) Q 
	I vCol="UDPOST" D vCoMfS46(vOid,vVal) Q 
	I vCol="UDPRE" D vCoMfS47(vOid,vVal) Q 
	I vCol="USER" D vCoMfS48(vOid,vVal) Q 
	I vCol="VAL4EXT" D vCoMfS49(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece($S(vNod'="FID":vobj(vOid,vNod),1:vobj(vOid)),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	S vobj(vOid,-100,vOldNod)=""
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece($S(vNod'="FID":vobj(vOid,vNod),1:vobj(vOid)),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I vNod'="FID" S $piece(vobj(vOid,vNod),"|",vPos)=vVal Q 
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL1.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL1",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	S vPos=$P(vP,"|",4)
	I vNod'="FID",'$D(vobj(vOid,vNod)) D
	.	I '$get(vobj(vOid,-2)) S vobj(vOid,vNod)="" Q 
	.	S vobj(vOid,vNod)=$get(^DBTBL(vobj(vOid,-3),1,vobj(vOid,-4),vNod))
	.	Q 
	N vRet
	I vNod'="FID" S vRet=vobj(vOid,vNod)
	E  S vRet=vobj(vOid)
	S vRet=$piece(vRet,"|",vPos)
	I '($P(vP,"|",13)="") Q $$getSf^UCCOLSF(vRet,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	Q vRet
	;
vDb3(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL1,,1,-2)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	S v2out='$T
	;
	Q dbtbl1
	;
vDb4(v1,v2,v3,v2out)	;	voXN = Db.getRecord(DBTBL1D,,1,-2)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	S v2out='$T
	;
	Q dbtbl1d
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL1)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	FID FROM DBTBL1 WHERE FID<>:V1 AND UDFILE=:X
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="",'$D(V1) G vL1a0
	S vos3=$G(X) I vos3="",'$D(X) G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^XDBREF("DBTBL1.UDFILE",vos4),1) I vos4="" G vL1a0
	S vos5=""
vL1a6	S vos5=$O(^XDBREF("DBTBL1.UDFILE",vos4,vos3,vos5),1) I vos5="" G vL1a4
	I '(vos5'=vos2) G vL1a6
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
