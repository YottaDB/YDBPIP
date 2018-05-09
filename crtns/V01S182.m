V01S182(%O,fDBSDOM)	; -  - SID= <DBSDOM> User-Defined Data Types Maintenance
	;
	; **** Routine compiled from DATA-QWIK Screen DBSDOM ****
	;
	; 09/14/2007 08:40 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:40 - chenardp
	; The DBSDOM screen enables the institution to create, maintain, and delete
	; user-defined data types.
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fDBSDOM)#2) K vobj(+$G(fDBSDOM)) S fDBSDOM=$$vDbNew1("","")
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
VNEW(fDBSDOM)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBSDOM)
	D VLOD(.fDBSDOM)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBSDOM)	;
	 S:'$D(vobj(fDBSDOM,0)) vobj(fDBSDOM,0)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),0)),1:"")
	 S:'$D(vobj(fDBSDOM,1)) vobj(fDBSDOM,1)=$S(vobj(fDBSDOM,-2):$G(^DBCTL("SYS","DOM",vobj(fDBSDOM,-3),vobj(fDBSDOM,-4),1)),1:"")
	Q:(vobj(fDBSDOM,-3)="")!(vobj(fDBSDOM,-4)="") 
	Q:%O  S ER=0 I (vobj(fDBSDOM,-3)="")!(vobj(fDBSDOM,-4)="") S ER=1 S RM=$$^MSG(1767,"SYSSN,DOM") Q 
	 N V1,V2 S V1=vobj(fDBSDOM,-3),V2=vobj(fDBSDOM,-4) I ($D(^DBCTL("SYS","DOM",V1,V2))>9) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fDBSDOM,0),$C(124),19)="" N vSetMf S vSetMf=$P(vobj(fDBSDOM,0),$C(124),19) S $P(vobj(fDBSDOM,0),$C(124),19)=+$H,vobj(fDBSDOM,-100,0)=""
	I $P(vobj(fDBSDOM,1),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fDBSDOM,1),$C(124),3) S $P(vobj(fDBSDOM,1),$C(124),3)=1,vobj(fDBSDOM,-100,1)=""
	I $P(vobj(fDBSDOM,1),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fDBSDOM,1),$C(124),2) S $P(vobj(fDBSDOM,1),$C(124),2)=1,vobj(fDBSDOM,-100,1)=""
	I $P(vobj(fDBSDOM,0),$C(124),20)="" N vSetMf S vSetMf=$P(vobj(fDBSDOM,0),$C(124),20) S $P(vobj(fDBSDOM,0),$C(124),20)=$$USERNAM^%ZFUNC,vobj(fDBSDOM,-100,0)=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBSDOM)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBSDOM)	; Display screen prompts
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
VDA1(fDBSDOM)	; Display screen data
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
	S VO(68)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBSDOM,0),$C(124),19)),"MM/DD/YEAR")
	S VO(69)=$C(4,28,20,2,0,0,0,0,0,0)_"00U"_$get(DOM)
	S VO(70)=$C(4,58,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
	S VO(71)=$C(4,70,10,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBSDOM,0),$C(124),20)),1,10)
	S VO(72)=$C(6,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),1):"Y",1:"N")
	S VO(73)=$C(6,28,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),1)),1,40)
	S VO(74)=$C(7,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),2):"Y",1:"N")
	S VO(75)=$C(7,28,1,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBSDOM,0),$C(124),2)),1)
	S VO(76)=$C(8,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),3):"Y",1:"N")
	S VO(77)=$C(8,28,5,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBSDOM,0),$C(124),3)
	S VO(78)=$C(9,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),4):"Y",1:"N")
	S VO(79)=$C(9,28,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBSDOM,0),$C(124),4)
	S VO(80)=$C(10,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),15):"Y",1:"N")
	S VO(81)=$C(10,28,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBSDOM,0),$C(124),15)
	S VO(82)=$C(11,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),6):"Y",1:"N")
	S VO(83)=$C(11,28,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),6)),1,40)
	S VO(84)=$C(12,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),14):"Y",1:"N")
	S VO(85)=$C(12,28,52,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),14)),1,52)
	S VO(86)=$C(13,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),5):"Y",1:"N")
	S VO(87)=$C(13,28,52,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),5)),1,52)
	S VO(88)=$C(14,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),10):"Y",1:"N")
	S VO(89)=$C(14,28,53,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),10)),1,60)
	S VO(90)=$C(15,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),13):"Y",1:"N")
	S VO(91)=$C(15,28,52,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),13)),1,52)
	S VO(92)=$C(16,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),8):"Y",1:"N")
	S VO(93)=$C(16,28,25,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),8)),1,25)
	S VO(94)=$C(17,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),9):"Y",1:"N")
	S VO(95)=$C(17,28,25,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),9)),1,25)
	S VO(96)=$C(18,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),12):"Y",1:"N")
	S VO(97)=$C(18,28,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),12)),1,40)
	S VO(98)=$C(19,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),11):"Y",1:"N")
	S VO(99)=$C(19,28,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),11)),1,40)
	S VO(100)=$C(20,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),7):"Y",1:"N")
	S VO(101)=$C(20,28,20,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),7)),1,20)
	S VO(102)=$C(21,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),16):"Y",1:"N")
	S VO(103)=$C(21,28,1,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),16)),1)
	S VO(104)=$C(22,3,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBSDOM,1),$C(124),17):"Y",1:"N")
	S VO(105)=$C(22,28,20,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBSDOM,0),$C(124),17)),1,20)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBSDOM)	;
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
	S %TAB(3)=$C(3,27,20)_"01U|*DOM|[*]@DOM|[DBSDOM]||do VP1^V01S182(.fDBSDOM)"
	S %TAB(4)=$C(3,57,1)_"00L|*DELETE|[*]@DELETE|||do VP2^V01S182(.fDBSDOM)"
	S %TAB(5)=$C(3,69,10)_"20T12420|1|[DBSDOM]USER|||||||||20"
	S %TAB(6)=$C(5,2,1)_"00L12401|1|[DBSDOM]PRDES"
	S %TAB(7)=$C(5,27,40)_"01T12401|1|[DBSDOM]DES|||do VP3^V01S182(.fDBSDOM)"
	S %TAB(8)=$C(6,2,1)_"00L12402|1|[DBSDOM]PRTYP"
	S %TAB(9)=$C(6,27,1)_"01U12402|1|[DBSDOM]TYP|[DBCTLDVFM]||do VP4^V01S182(.fDBSDOM)"
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
	S %TAB(23)=$C(13,27,53)_"00T12410|1|[DBSDOM]PTN|||||||||60"
	S %TAB(24)=$C(14,2,1)_"00L12413|1|[DBSDOM]PRVLD"
	S %TAB(25)=$C(14,27,52)_"00T12413|1|[DBSDOM]VLD|||||||||70"
	S %TAB(26)=$C(15,2,1)_"00L12408|1|[DBSDOM]PRMIN"
	S %TAB(27)=$C(15,27,25)_"00T12408|1|[DBSDOM]MIN|||do VP5^V01S182(.fDBSDOM)"
	S %TAB(28)=$C(16,2,1)_"00L12409|1|[DBSDOM]PRMAX"
	S %TAB(29)=$C(16,27,25)_"00T12409|1|[DBSDOM]MAX|||do VP6^V01S182(.fDBSDOM)"
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
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBSDOM)	;Create %TAB(array)
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
VP1(fDBSDOM)	;
	;
	Q:(X="") 
	;
	D CHANGE^DBSMACRO("TBL","")
	;
	Q:(X=V) 
	;
	K vobj(+$G(fDBSDOM)) S fDBSDOM=$$vDb1(SYSSN,X)
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
VP2(fDBSDOM)	;
	;
	Q:'X 
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen1()
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
VP3(fDBSDOM)	;
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
	S vobj(fDBSDOM,-100,0)="",$P(vobj(fDBSDOM,0),$C(124),6)=HDR
	;
	Q 
VP4(fDBSDOM)	;
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
VP5(fDBSDOM)	;
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
VP6(fDBSDOM)	;
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
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBSDOM)
	D VDA1(.fDBSDOM)
	D ^DBSPNT()
	Q 
	;
VW(fDBSDOM)	;
	D VDA1(.fDBSDOM)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBSDOM)	;
	D VDA1(.fDBSDOM)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBSDOM)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBSDOM" D vSET1(.fDBSDOM,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBSDOM,di,X)	;
	D vCoInd1(fDBSDOM,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBSDOM" Q $$vREAD1(.fDBSDOM,di)
	Q ""
vREAD1(fDBSDOM,di)	;
	Q $$vCoInd2(fDBSDOM,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
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
vCoMfS1(vRec,vVal)	; RecordDBSDOM.setDEC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",15)
	S $P(vobj(vRec,0),"|",15)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBSDOM.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",1)
	S $P(vobj(vRec,0),"|",1)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBSDOM.setDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",14)
	S $P(vobj(vRec,0),"|",14)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBSDOM.setIPF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",12)
	S $P(vobj(vRec,0),"|",12)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBSDOM.setLEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",3)
	S $P(vobj(vRec,0),"|",3)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBSDOM.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",19)
	S $P(vobj(vRec,0),"|",19)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBSDOM.setMAX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",9)
	S $P(vobj(vRec,0),"|",9)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBSDOM.setMIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",8)
	S $P(vobj(vRec,0),"|",8)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBSDOM.setMSK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",17)
	S $P(vobj(vRec,0),"|",17)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBSDOM.setMSU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",16)
	S $P(vobj(vRec,0),"|",16)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBSDOM.setNLV(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",7)
	S $P(vobj(vRec,0),"|",7)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBSDOM.setOPF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",11)
	S $P(vobj(vRec,0),"|",11)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBSDOM.setPRDEC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",15)
	S $P(vobj(vRec,1),"|",15)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordDBSDOM.setPRDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",1)
	S $P(vobj(vRec,1),"|",1)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordDBSDOM.setPRDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",14)
	S $P(vobj(vRec,1),"|",14)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordDBSDOM.setPRIPF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",12)
	S $P(vobj(vRec,1),"|",12)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordDBSDOM.setPRLEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",3)
	S $P(vobj(vRec,1),"|",3)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordDBSDOM.setPRMAX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",9)
	S $P(vobj(vRec,1),"|",9)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordDBSDOM.setPRMIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",8)
	S $P(vobj(vRec,1),"|",8)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordDBSDOM.setPRMSK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",17)
	S $P(vobj(vRec,1),"|",17)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordDBSDOM.setPRMSU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",16)
	S $P(vobj(vRec,1),"|",16)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS22(vRec,vVal)	; RecordDBSDOM.setPRNLV(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",7)
	S $P(vobj(vRec,1),"|",7)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS23(vRec,vVal)	; RecordDBSDOM.setPROPF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",11)
	S $P(vobj(vRec,1),"|",11)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS24(vRec,vVal)	; RecordDBSDOM.setPRPTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",10)
	S $P(vobj(vRec,1),"|",10)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS25(vRec,vVal)	; RecordDBSDOM.setPRRHD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",6)
	S $P(vobj(vRec,1),"|",6)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS26(vRec,vVal)	; RecordDBSDOM.setPRSIZ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",4)
	S $P(vobj(vRec,1),"|",4)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS27(vRec,vVal)	; RecordDBSDOM.setPRTBL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",5)
	S $P(vobj(vRec,1),"|",5)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS28(vRec,vVal)	; RecordDBSDOM.setPRTYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",2)
	S $P(vobj(vRec,1),"|",2)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS29(vRec,vVal)	; RecordDBSDOM.setPRVLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",13)
	S $P(vobj(vRec,1),"|",13)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS30(vRec,vVal)	; RecordDBSDOM.setPTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",10)
	S $P(vobj(vRec,0),"|",10)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS31(vRec,vVal)	; RecordDBSDOM.setRHD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",6)
	S $P(vobj(vRec,0),"|",6)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS32(vRec,vVal)	; RecordDBSDOM.setSIZ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",4)
	S $P(vobj(vRec,0),"|",4)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS33(vRec,vVal)	; RecordDBSDOM.setTBL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",5)
	S $P(vobj(vRec,0),"|",5)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS34(vRec,vVal)	; RecordDBSDOM.setTYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",2)
	S $P(vobj(vRec,0),"|",2)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS35(vRec,vVal)	; RecordDBSDOM.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",20)
	S $P(vobj(vRec,0),"|",20)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS36(vRec,vVal)	; RecordDBSDOM.setVLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",13)
	S $P(vobj(vRec,0),"|",13)=vVal S vobj(vRec,-100,0)=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBSDOM.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBSDOM",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) D
	.	I '$get(vobj(vOid,-2)) S vobj(vOid,vNod)="" Q 
	.	S vobj(vOid,vNod)=$get(^DBCTL("SYS","DOM",vobj(vOid,-3),vobj(vOid,-4),vNod))
	.	Q 
	I vCol="DEC" D vCoMfS1(vOid,vVal) Q 
	I vCol="DES" D vCoMfS2(vOid,vVal) Q 
	I vCol="DFT" D vCoMfS3(vOid,vVal) Q 
	I vCol="IPF" D vCoMfS4(vOid,vVal) Q 
	I vCol="LEN" D vCoMfS5(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS6(vOid,vVal) Q 
	I vCol="MAX" D vCoMfS7(vOid,vVal) Q 
	I vCol="MIN" D vCoMfS8(vOid,vVal) Q 
	I vCol="MSK" D vCoMfS9(vOid,vVal) Q 
	I vCol="MSU" D vCoMfS10(vOid,vVal) Q 
	I vCol="NLV" D vCoMfS11(vOid,vVal) Q 
	I vCol="OPF" D vCoMfS12(vOid,vVal) Q 
	I vCol="PRDEC" D vCoMfS13(vOid,vVal) Q 
	I vCol="PRDES" D vCoMfS14(vOid,vVal) Q 
	I vCol="PRDFT" D vCoMfS15(vOid,vVal) Q 
	I vCol="PRIPF" D vCoMfS16(vOid,vVal) Q 
	I vCol="PRLEN" D vCoMfS17(vOid,vVal) Q 
	I vCol="PRMAX" D vCoMfS18(vOid,vVal) Q 
	I vCol="PRMIN" D vCoMfS19(vOid,vVal) Q 
	I vCol="PRMSK" D vCoMfS20(vOid,vVal) Q 
	I vCol="PRMSU" D vCoMfS21(vOid,vVal) Q 
	I vCol="PRNLV" D vCoMfS22(vOid,vVal) Q 
	I vCol="PROPF" D vCoMfS23(vOid,vVal) Q 
	I vCol="PRPTN" D vCoMfS24(vOid,vVal) Q 
	I vCol="PRRHD" D vCoMfS25(vOid,vVal) Q 
	I vCol="PRSIZ" D vCoMfS26(vOid,vVal) Q 
	I vCol="PRTBL" D vCoMfS27(vOid,vVal) Q 
	I vCol="PRTYP" D vCoMfS28(vOid,vVal) Q 
	I vCol="PRVLD" D vCoMfS29(vOid,vVal) Q 
	I vCol="PTN" D vCoMfS30(vOid,vVal) Q 
	I vCol="RHD" D vCoMfS31(vOid,vVal) Q 
	I vCol="SIZ" D vCoMfS32(vOid,vVal) Q 
	I vCol="TBL" D vCoMfS33(vOid,vVal) Q 
	I vCol="TYP" D vCoMfS34(vOid,vVal) Q 
	I vCol="USER" D vCoMfS35(vOid,vVal) Q 
	I vCol="VLD" D vCoMfS36(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid,vNod),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	S vobj(vOid,-100,vOldNod)=""
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid,vNod),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid,vNod),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBSDOM.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBSDOM",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) D
	.	I '$get(vobj(vOid,-2)) S vobj(vOid,vNod)="" Q 
	.	S vobj(vOid,vNod)=$get(^DBCTL("SYS","DOM",vobj(vOid,-3),vobj(vOid,-4),vNod))
	.	Q 
	N vRet
	S vRet=vobj(vOid,vNod)
	S vRet=$piece(vRet,"|",vPos)
	I '($P(vP,"|",13)="") Q $$getSf^UCCOLSF(vRet,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBSDOM,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBSDOM"
	I '$D(^DBCTL("SYS","DOM",v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBSDOM)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBSDOM",vobj(vOid,-2)=0
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	DI FROM DBTBL1D,DBTBL1 WHERE %LIBS='SYSDEV' AND DOM=:DOM
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(DOM) I vos2="",'$D(DOM) G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBINDX("SYSDEV","DOM","PBS",vos2,vos3),1) I vos3="" G vL1a0
	S vos4="SYSDEV",vos5=vos3
	I '($D(^DBTBL("SYSDEV",1,vos3))) S vos4=$$BYTECHAR^SQLUTL(254),vos5=$$BYTECHAR^SQLUTL(254)
	S vos6=0 I '(vos3=vos5) S vos6=1
	S vos7=""
vL1a8	S vos7=$O(^DBINDX("SYSDEV","DOM","PBS",vos2,vos3,vos7),1) I vos7="" G vL1a3
	I vos6 S vos4=$$BYTECHAR^SQLUTL(254),vos5=$$BYTECHAR^SQLUTL(254)
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos7=$$BYTECHAR^SQLUTL(254):"",1:vos7)
	;
	Q 1
