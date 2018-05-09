V01S231(%O,fDBTBL1D,fDBTBL1)	;DBS -  - SID= <DBTBL1E> Files Definition - Detail
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL1E ****
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
	.	I '($D(fDBTBL1D)#2) K vobj(+$G(fDBTBL1D)) S fDBTBL1D=$$vDbNew1("","","")
	.	I '($D(fDBTBL1)#2) K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vDbNew2("","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,DI,DELETE" S VSID="DBTBL1E" S VPGM=$T(+0) S VSNAME="Files Definition - Detail"
	S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1D")="zfDBTBL1D"
	S vPSL=1
	S KEYS(1)=vobj(fDBTBL1,-3)
	S KEYS(2)=vobj(fDBTBL1,-4)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fDBTBL1D,.fDBTBL1) D VDA1(.fDBTBL1D,.fDBTBL1) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.fDBTBL1D,.fDBTBL1) D VPR(.fDBTBL1D,.fDBTBL1) D VDA1(.fDBTBL1D,.fDBTBL1)
	I %O D VLOD(.fDBTBL1D,.fDBTBL1) Q:$get(ER)  D VPR(.fDBTBL1D,.fDBTBL1) D VDA1(.fDBTBL1D,.fDBTBL1)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fDBTBL1D,.fDBTBL1)
	Q 
	;
VNEW(fDBTBL1D,fDBTBL1)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL1D,.fDBTBL1)
	D VLOD(.fDBTBL1D,.fDBTBL1)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL1D,fDBTBL1)	;
	Q:(vobj(fDBTBL1D,-3)="")!(vobj(fDBTBL1D,-4)="")!(vobj(fDBTBL1D,-5)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL1D,-3)="")!(vobj(fDBTBL1D,-4)="")!(vobj(fDBTBL1D,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID,DI") Q 
	 N V1,V2,V3 S V1=vobj(fDBTBL1D,-3),V2=vobj(fDBTBL1D,-4),V3=vobj(fDBTBL1D,-5) I ($D(^DBTBL(V1,1,V2,9,V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fDBTBL1D),$C(124),11)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),11) S $P(vobj(fDBTBL1D),$C(124),11)="S",vobj(fDBTBL1D,-100,"0*")=""
	I $P(vobj(fDBTBL1D),$C(124),31)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),31) S $P(vobj(fDBTBL1D),$C(124),31)=0,vobj(fDBTBL1D,-100,"0*")=""
	I $P(vobj(fDBTBL1D),$C(124),9)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),9) S $P(vobj(fDBTBL1D),$C(124),9)="T",vobj(fDBTBL1D,-100,"0*")=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL1D,fDBTBL1)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL1D,fDBTBL1)	; Display screen prompts
	S VO="68||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,2,12,1,0,0,0,0,0,0)_"01T Data Item:"
	S VO(4)=$C(3,36,7,0,0,0,0,0,0,0)_"01TDelete:"
	S VO(5)=$C(3,47,11,0,0,0,0,0,0,0)_"01TUpdated By:"
	S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,49,9,0,0,0,0,0,0,0)_"01TMDD Name:"
	S VO(9)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(5,43,15,0,0,0,0,0,0,0)_"01TData Type Name:"
	S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,8,11,1,0,0,0,0,0,0)_"01T Data Type:"
	S VO(17)=$C(7,26,8,1,0,0,0,0,0,0)_"01T Length:"
	S VO(18)=$C(7,45,13,0,0,0,0,0,0,0)_"01TDisplay Size:"
	S VO(19)=$C(7,65,8,0,0,0,0,0,0,0)_"01TDecimal:"
	S VO(20)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(8,6,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(23)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(9,3,16,1,0,0,0,0,0,0)_"01T Column Heading:"
	S VO(26)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(30)=$C(11,8,11,0,0,0,0,0,0,0)_"01TTable Name:"
	S VO(31)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(32)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(12,5,14,0,0,0,0,0,0,0)_"01TPattern Check:"
	S VO(34)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(13,5,14,0,0,0,0,0,0,0)_"01TDefault Value:"
	S VO(37)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(39)=$C(14,5,14,0,0,0,0,0,0,0)_"01TMinimum Value:"
	S VO(40)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(15,5,14,0,0,0,0,0,0,0)_"01TMaximum Value:"
	S VO(43)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(45)=$C(16,31,25,0,0,0,0,0,0,0)_"01TDefault Screen Processors"
	S VO(46)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(17,5,14,0,0,0,0,0,0,0)_"01TPre-Processor:"
	S VO(49)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(50)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(51)=$C(18,4,15,0,0,0,0,0,0,0)_"01TPost-Processor:"
	S VO(52)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(53)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(54)=$C(19,25,46,0,0,0,0,0,0,0)_"01TData Entry (UTBL001,STBL001,CTBL001 functions)"
	S VO(55)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(56)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(57)=$C(20,5,14,0,0,0,0,0,0,0)_"01TPre-Processor:"
	S VO(58)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(59)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(60)=$C(21,4,15,0,0,0,0,0,0,0)_"01TPost-Processor:"
	S VO(61)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(62)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(63)=$C(22,2,9,0,0,0,0,0,0,0)_"01TRequired:"
	S VO(64)=$C(22,15,21,0,0,0,0,0,0,0)_"01TValid for Extraction:"
	S VO(65)=$C(22,40,25,0,0,0,0,0,0,0)_"01TSame Order as Access Key:"
	S VO(66)=$C(22,69,5,0,0,0,0,0,0,0)_"01TNull:"
	S VO(67)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(68)=$C(23,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL1D,fDBTBL1)	; Display screen data
	N V
	I %O=5 N DELETE,DI
	I   S (DELETE,DI)=""
	E  S DELETE=$get(DELETE) S DI=$get(DI)
	;
	S DELETE=$get(DELETE)
	S DI=$get(DI)
	;
	S VO="94|69|13|0"
	S VO(69)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^UTLREAD($get(%FN)))
	S VO(70)=$C(3,14,12,2,0,0,0,0,0,0)_"00U"_$get(DI)
	S VO(71)=$C(3,44,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
	S VO(72)=$C(3,59,10,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL1D),$C(124),26)),1,10)
	S VO(73)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBTBL1D),$C(124),25)),"MM/DD/YEAR")
	S VO(74)=$C(4,59,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1D),$C(124),27)),1,12)
	S VO(75)=$C(5,59,20,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1D),$C(124),4)),1,20)
	S VO(76)=$C(7,20,1,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1D),$C(124),9)),1)
	S VO(77)=$C(7,35,5,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),2)
	S VO(78)=$C(7,59,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),19)
	S VO(79)=$C(7,74,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),14)
	S VO(80)=$C(8,20,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),10)),1,40)
	S VO(81)=$C(9,20,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),22)),1,40)
	S VO(82)=$C(11,20,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),5)),1,60)
	S VO(83)=$C(12,20,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),6)),1,60)
	S VO(84)=$C(13,20,58,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),3)),1,58)
	S VO(85)=$C(14,20,25,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),12)),1,25)
	S VO(86)=$C(15,20,25,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),13)),1,25)
	S VO(87)=$C(17,20,58,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),8)),1,58)
	S VO(88)=$C(18,20,58,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),7)),1,58)
	S VO(89)=$C(20,20,58,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),29)),1,58)
	S VO(90)=$C(21,20,58,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),30)),1,58)
	S VO(91)=$C(22,12,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),15):"Y",1:"N")
	S VO(92)=$C(22,37,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),28):"Y",1:"N")
	S VO(93)=$C(22,66,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),23):"Y",1:"N")
	S VO(94)=$C(22,75,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),31):"Y",1:"N")
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL1D,fDBTBL1)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=25 S VPT=1 S VPB=23 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1D,DBTBL1"
	S OLNTB=23001
	;
	S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1D")="zfDBTBL1D"
	;
	;
	S %TAB(1)=$C(2,13,12)_"01U|*DI|[*]@DI|@SELDI^DBSFUN(FID,.X)||do VP1^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(2)=$C(2,43,1)_"00L|*DELETE|[*]@DELETE|||do VP2^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(3)=$C(2,58,10)_"20T12426|1|[DBTBL1D]USER|||||||||20"
	S %TAB(4)=$C(2,69,10)_"20D12425|1|[DBTBL1D]LTD"
	S %TAB(5)=$C(3,58,12)_"00U12427|1|[DBTBL1D]MDD|@SELDI^DBSFUN($$MDD^DBSDF(FID),.X)||do VP3^V01S231(.fDBTBL1D,.fDBTBL1)|do VP4^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(6)=$C(4,58,20)_"00U12404|1|[DBTBL1D]DOM|[DBSDOM]||do VP5^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(7)=$C(6,19,1)_"01U12409|1|[DBTBL1D]TYP|[DBCTLDVFM]||do VP6^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(8)=$C(6,34,5)_"01N12402|1|[DBTBL1D]LEN|||do VP7^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(9)=$C(6,58,3)_"00N12419|1|[DBTBL1D]SIZ|||do VP8^V01S231(.fDBTBL1D,.fDBTBL1)||1"
	S %TAB(10)=$C(6,73,2)_"00N12414|1|[DBTBL1D]DEC|||||0|18"
	S %TAB(11)=$C(7,19,40)_"01T12410|1|[DBTBL1D]DES|||do VP9^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(12)=$C(8,19,40)_"01T12422|1|[DBTBL1D]RHD"
	S %TAB(13)=$C(10,19,60)_"00T12405|1|[DBTBL1D]TBL|||do VP10^V01S231(.fDBTBL1D,.fDBTBL1)||||||255"
	S %TAB(14)=$C(11,19,60)_"00T12406|1|[DBTBL1D]PTN|||do VP11^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(15)=$C(12,19,58)_"00T12403|1|[DBTBL1D]DFT|||do VP12^V01S231(.fDBTBL1D,.fDBTBL1)|do VP13^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(16)=$C(13,19,25)_"00T12412|1|[DBTBL1D]MIN|||do VP14^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(17)=$C(14,19,25)_"00T12413|1|[DBTBL1D]MAX|||do VP15^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(18)=$C(16,19,58)_"00T12408|1|[DBTBL1D]XPR"
	S %TAB(19)=$C(17,19,58)_"00T12407|1|[DBTBL1D]XPO"
	S %TAB(20)=$C(19,19,58)_"00T12429|1|[DBTBL1D]DEPREP|||||||||255"
	S %TAB(21)=$C(20,19,58)_"00T12430|1|[DBTBL1D]DEPOSTP|||||||||255"
	S %TAB(22)=$C(21,11,1)_"00L12415|1|[DBTBL1D]REQ|||do VP16^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(23)=$C(21,36,1)_"00L12428|1|[DBTBL1D]VAL4EXT|||do VP17^V01S231(.fDBTBL1D,.fDBTBL1)|do VP18^V01S231(.fDBTBL1D,.fDBTBL1)"
	S %TAB(24)=$C(21,65,1)_"00L12423|1|[DBTBL1D]SRL"
	S %TAB(25)=$C(21,74,1)_"00L12431|1|[DBTBL1D]NULLIND"
	D VTBL(.fDBTBL1D,.fDBTBL1)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL1D,fDBTBL1)	;Create %TAB(array)
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
VP1(fDBTBL1D,fDBTBL1)	;
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	 S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
	;
	N FID
	;
	Q:(X="") 
	;
	S FID=vobj(fDBTBL1,-4)
	;
	; Don't allow new column name that is reserved word
	I '($E(FID,1)="Z"),'($E(X,1)="Z"),'($D(^DBTBL("SYSDEV",1,FID,9,X))#2),($D(^STBL("RESERVED",X))#2) D  Q 
	.	;
	.	S ER=1
	.	; SQL reserved word - not permitted for use
	.	S RM=$$^MSG(5259)
	.	Q 
	;
	I (X=V) D  Q 
	.	;
	.	D CHANGE^DBSMACRO("TBL","")
	.	D ZSUPRTYP(fDBTBL1,X,.PARFID)
	.	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100))
	.	 S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16))
	.	Q 
	;
	I '$$VALIDKEY^DBSGETID(X) D  Q 
	.	;
	.	S ER=1
	.	; Alphanumeric format only
	.	S RM=$$^MSG(248)
	.	Q 
	;
	I (X["_") D  Q 
	.	;
	.	S ER=1
	.	; Alphanumeric format only
	.	S RM=$$^MSG(248)
	.	Q 
	;
	D CHANGE^DBSMACRO("TBL","")
	D UNPROT^DBSMACRO("ALL")
	;
	S DI=X
	;
	K vobj(+$G(fDBTBL1D)) S fDBTBL1D=$$vDb1("SYSDEV",FID,DI)
	;
	I ($G(vobj(fDBTBL1D,-2))=0) D
	.	;
	.	I ($P(vobj(fDBTBL1,100),$C(124),2)=1) D
	..		;
	..		N keys S keys=$P(vobj(fDBTBL1,16),$C(124),1)
	..		;
	..	 N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),1) S $P(vobj(fDBTBL1D),$C(124),1)=$piece(keys,",",$L(keys,",")),vobj(fDBTBL1D,-100,"0*")=""
	..		Q 
	.	;
	.	S %O=0
	.	; Create new data item
	.	S RM=$$^MSG(639)
	.	;
	.	D GOTO^DBSMACRO("DBTBL1D.MDD") ; Skip Delete prompt field
	.	Q 
	E  S %O=1
	;
	S DELETE=0
	;
	D DISPLAY^DBSMACRO("ALL")
	;
	D ZSUPRTYP(fDBTBL1,DI,.PARFID)
	D ZPROT1(fDBTBL1,.MDDFID,.DOMREQ,.MDDREQ)
	;
	Q 
	;
ZSUPRTYP(fDBTBL1,DI,PARFID)	;
	N vpc
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	S PARFID=$P(vobj(fDBTBL1,10),$C(124),4)
	Q:(PARFID="") 
	;
	N pardi,vop1 S pardi=$$vDb5("SYSDEV",PARFID,DI,.vop1)
	;
	S vpc=(($G(vop1)=0)) Q:vpc  ; Not in parent table
	;
	; Copy and display Supertype attributes
	D DEFAULT^DBSMACRO("DBTBL1D.NOD",$P(pardi,$C(124),1))
	D PROTECT^DBSMACRO("DBTBL1D.NOD")
	D DEFAULT^DBSMACRO("DBTBL1D.LEN",$P(pardi,$C(124),2))
	D PROTECT^DBSMACRO("DBTBL1D.LEN")
	D DEFAULT^DBSMACRO("DBTBL1D.DFT",$P(pardi,$C(124),3))
	D PROTECT^DBSMACRO("DBTBL1D.DFT")
	D DEFAULT^DBSMACRO("DBTBL1D.DOM",$P(pardi,$C(124),4))
	D PROTECT^DBSMACRO("DBTBL1D.DOM")
	D DEFAULT^DBSMACRO("DBTBL1D.TYP",$P(pardi,$C(124),9))
	D PROTECT^DBSMACRO("DBTBL1D.TYP")
	D DEFAULT^DBSMACRO("DBTBL1D.DES",$P(pardi,$C(124),10))
	D PROTECT^DBSMACRO("DBTBL1D.DES")
	D DEFAULT^DBSMACRO("DBTBL1D.ITP",$P(pardi,$C(124),11))
	D PROTECT^DBSMACRO("DBTBL1D.ITP")
	D DEFAULT^DBSMACRO("DBTBL1D.DEC",$P(pardi,$C(124),14))
	D PROTECT^DBSMACRO("DBTBL1D.DEC")
	D DEFAULT^DBSMACRO("DBTBL1D.ISMASTER",$P(pardi,$C(124),17))
	D PROTECT^DBSMACRO("DBTBL1D.ISMASTER")
	D DEFAULT^DBSMACRO("DBTBL1D.SFD",$P(pardi,$C(124),18))
	D PROTECT^DBSMACRO("DBTBL1D.SFD")
	D DEFAULT^DBSMACRO("DBTBL1D.SIZ",$P(pardi,$C(124),19))
	D PROTECT^DBSMACRO("DBTBL1D.SIZ")
	D DEFAULT^DBSMACRO("DBTBL1D.POS",$P(pardi,$C(124),21))
	D PROTECT^DBSMACRO("DBTBL1D.POS")
	D DEFAULT^DBSMACRO("DBTBL1D.RHD",$P(pardi,$C(124),22))
	D PROTECT^DBSMACRO("DBTBL1D.RHD")
	D DEFAULT^DBSMACRO("DBTBL1D.SRL",$P(pardi,$C(124),23))
	D PROTECT^DBSMACRO("DBTBL1D.SRL")
	D DEFAULT^DBSMACRO("DBTBL1D.CNV",$P(pardi,$C(124),24))
	D PROTECT^DBSMACRO("DBTBL1D.CNV")
	D DEFAULT^DBSMACRO("DBTBL1D.MDD",$P(pardi,$C(124),27))
	D PROTECT^DBSMACRO("DBTBL1D.MDD")
	D DEFAULT^DBSMACRO("DBTBL1D.VAL4EXT",$P(pardi,$C(124),28))
	D PROTECT^DBSMACRO("DBTBL1D.VAL4EXT")
	;
	D DISPLAY^DBSMACRO("ALL","",0)
	;
	; Exists in Supertype Entity ~p1
	S RM=$$^MSG(7294,PARFID)
	;
	Q 
	;
ZPROT1(fDBTBL1,MDDFID,DOMREQ,MDDREQ)	;
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	N SYSSN
	;
	S SYSSN=$P(vobj(fDBTBL1,10),$C(124),2)
	;
	I (SYSSN="") S SYSSN="PBS"
	;
	N scasys S scasys=$G(^SCATBL(2,SYSSN))
	;
	S MDDFID=$P(scasys,$C(124),7)
	S DOMREQ=$P(scasys,$C(124),5)
	S MDDREQ=$P(scasys,$C(124),6)
	;
	I ((vobj(fDBTBL1,-4)=MDDFID)!(MDDFID="")) D PROTECT^DBSMACRO("DBTBL1D.MDD")
	;
	Q 
VP2(fDBTBL1D,fDBTBL1)	;
	;
	Q:'X 
	;
	; Don't allow delete if the column is in use
	;
	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen1()
	;
	I $$vFetch1() D
	.	;
	.	S ER=1
	.	; Remove data item references first
	.	S RM=$$^MSG(2363)
	.	Q 
	;
	E  D GOTO^DBSMACRO("END")
	;
	Q 
VP3(fDBTBL1D,fDBTBL1)	;
	;
	Q:((X="")&(V="")) 
	;
	I MDDREQ D CHANGE^DBSMACRO("REQ")
	;
	D CHANGE^DBSMACRO("TBL","")
	;
	; Remove old MDD reference
	I (X=""),(PARFID="") D UNPROT^DBSMACRO("ALL")
	;
	Q:(X="") 
	;
	I ((vobj(fDBTBL1,-4)=MDDFID)!(MDDFID="")) D  Q 
	.	;
	.	S ER=1
	.	; Invalid master dictionary name for this system
	.	S RM=$$^MSG(1402)
	.	Q 
	;
	N mdddi,vop1 S mdddi=$$vDb5("SYSDEV",MDDFID,X,.vop1)
	;
	I ($G(vop1)=0) D  Q 
	.	;
	.	S ER=1
	.	; Invalid master dictionary name
	.	S RM=$$^MSG(1401)
	.	Q 
	;
	D DEFAULT^DBSMACRO("DBTBL1D.DES",$P(mdddi,$C(124),10))
	D DEFAULT^DBSMACRO("DBTBL1D.RHD",$P(mdddi,$C(124),22))
	D DEFAULT^DBSMACRO("DBTBL1D.LEN",$P(mdddi,$C(124),2))
	D DEFAULT^DBSMACRO("DBTBL1D.TYP",$P(mdddi,$C(124),9))
	D DEFAULT^DBSMACRO("DBTBL1D.SIZ",$P(mdddi,$C(124),19))
	D DEFAULT^DBSMACRO("DBTBL1D.DEC",$P(mdddi,$C(124),14))
	;
	D PROTECT^DBSMACRO("DBTBL1D.DES")
	D PROTECT^DBSMACRO("DBTBL1D.RHD")
	D PROTECT^DBSMACRO("DBTBL1D.LEN")
	D PROTECT^DBSMACRO("DBTBL1D.TYP")
	D PROTECT^DBSMACRO("DBTBL1D.SIZ")
	D PROTECT^DBSMACRO("DBTBL1D.DEC")
	;
	Q 
VP4(fDBTBL1D,fDBTBL1)	;
	;
	I (PARFID="") D UNPROT^DBSMACRO("ALL")
	;
	D ZPROT1(fDBTBL1,.MDDFID,.DOMREQ,.MDDREQ) ; In post-processor for DI
	;
	Q 
VP5(fDBTBL1D,fDBTBL1)	;
	N vpc
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	N SYSSN
	;
	I DOMREQ D CHANGE^DBSMACRO("REQ")
	;
	Q:(X="") 
	;
	S SYSSN=$P(vobj(fDBTBL1,10),$C(124),2)
	;
	N dbsdom S dbsdom=$$vDb3(SYSSN,X)
	S vpc=(($G(vobj(dbsdom,-2))=0)) K:vpc vobj(+$G(dbsdom)) Q:vpc 
	;
	I (X=V) D ZPROT(dbsdom) K vobj(+$G(dbsdom)) Q 
	;
	 S:'$D(vobj(dbsdom,0)) vobj(dbsdom,0)=$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),0))
	D DEFAULT^DBSMACRO("DBTBL1D.DES",$P(vobj(dbsdom,0),$C(124),1))
	D DEFAULT^DBSMACRO("DBTBL1D.TYP",$P(vobj(dbsdom,0),$C(124),2))
	D DEFAULT^DBSMACRO("DBTBL1D.SIZ",$P(vobj(dbsdom,0),$C(124),4))
	D DEFAULT^DBSMACRO("DBTBL1D.LEN",$P(vobj(dbsdom,0),$C(124),3))
	D DEFAULT^DBSMACRO("DBTBL1D.TBL",$P(vobj(dbsdom,0),$C(124),5))
	D DEFAULT^DBSMACRO("DBTBL1D.RHD",$P(vobj(dbsdom,0),$C(124),6))
	D DEFAULT^DBSMACRO("DBTBL1D.MIN",$P(vobj(dbsdom,0),$C(124),8))
	D DEFAULT^DBSMACRO("DBTBL1D.MAX",$P(vobj(dbsdom,0),$C(124),9))
	D DEFAULT^DBSMACRO("DBTBL1D.PTN",$P(vobj(dbsdom,0),$C(124),10))
	D DEFAULT^DBSMACRO("DBTBL1D.DFT",$P(vobj(dbsdom,0),$C(124),14))
	D DEFAULT^DBSMACRO("DBTBL1D.DEC",$P(vobj(dbsdom,0),$C(124),15))
	;
	D ZPROT(dbsdom)
	D DISPLAY^DBSMACRO("ALL")
	;
	K vobj(+$G(dbsdom)) Q 
	;
ZPROT(dbsdom)	;
	 S:'$D(vobj(dbsdom,1)) vobj(dbsdom,1)=$S(vobj(dbsdom,-2):$G(^DBCTL("SYS","DOM",vobj(dbsdom,-3),vobj(dbsdom,-4),1)),1:"")
	;
	I $P(vobj(dbsdom,1),$C(124),1) D PROTECT^DBSMACRO("DBTBL1D.DES")
	I $P(vobj(dbsdom,1),$C(124),2) D PROTECT^DBSMACRO("DBTBL1D.TYP")
	I $P(vobj(dbsdom,1),$C(124),4) D PROTECT^DBSMACRO("DBTBL1D.SIZ")
	I $P(vobj(dbsdom,1),$C(124),3) D PROTECT^DBSMACRO("DBTBL1D.LEN")
	I $P(vobj(dbsdom,1),$C(124),5) D PROTECT^DBSMACRO("DBTBL1D.TBL")
	I $P(vobj(dbsdom,1),$C(124),6) D PROTECT^DBSMACRO("DBTBL1D.RHD")
	I $P(vobj(dbsdom,1),$C(124),8) D PROTECT^DBSMACRO("DBTBL1D.MIN")
	I $P(vobj(dbsdom,1),$C(124),9) D PROTECT^DBSMACRO("DBTBL1D.MAX")
	I $P(vobj(dbsdom,1),$C(124),10) D PROTECT^DBSMACRO("DBTBL1D.PTN")
	I $P(vobj(dbsdom,1),$C(124),14) D PROTECT^DBSMACRO("DBTBL1D.DFT")
	I $P(vobj(dbsdom,1),$C(124),15) D PROTECT^DBSMACRO("DBTBL1D.DEC")
	;
	Q 
VP6(fDBTBL1D,fDBTBL1)	;
	N vpc
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	;
	Q:(X="") 
	;
	I ((X="M")!(X="B")) D  Q:ER 
	.	;
	.	I ($P(vobj(fDBTBL1,100),$C(124),2)=1) D  Q:ER 
	..		;
	..		N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen2()
	..		;
	..		I $$vFetch2() D  Q 
	...			;
	...			S ER=1
	...			; Memo or binary field already assigned to ~p1
	...			S RM=$$^MSG(800,rs)
	...			Q 
	..		Q 
	.	;
	.	; Create default computed expression for memo/blob fields
	. N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),1) S $P(vobj(fDBTBL1D),$C(124),1)="",vobj(fDBTBL1D,-100,"0*")=""
	. N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),21) S $P(vobj(fDBTBL1D),$C(124),21)="",vobj(fDBTBL1D,-100,"0*")=""
	. S $P(vobj(fDBTBL1D),$C(124),16)=" "
	.	Q 
	;
	N dvfm,vop1 S dvfm=$$vDb6(X,.vop1)
	;
	S vpc=(($G(vop1)=0)) Q:vpc 
	;
	D UNPROT^DBSMACRO("DBTBL1D.DEC")
	;
	I (%O=0) D
	.	;
	.	I ($P(vobj(fDBTBL1D),$C(124),11)="") D DEFAULT^DBSMACRO("DBTBL1D.ITP",$P(dvfm,$C(124),8))
	.	I ($P(vobj(fDBTBL1D),$C(124),2)="") D DEFAULT^DBSMACRO("DBTBL1D.LEN",$P(dvfm,$C(124),4))
	.	I ($P(vobj(fDBTBL1D),$C(124),6)="") D DEFAULT^DBSMACRO("DBTBL1D.PTN",$P(dvfm,$C(124),7))
	.	Q 
	;
	I (X="$"),($P(vobj(fDBTBL1D),$C(124),4)=""),(+$P(vobj(fDBTBL1D),$C(124),14)'=+2) D DEFAULT^DBSMACRO("DBTBL1D.DEC",2)
	;
	I '((X="N")!(X="$")) D DELETE^DBSMACRO("DBTBL1D.DEC")
	;
	I (X'="N") D PROTECT^DBSMACRO("DBTBL1D.DEC")
	;
	I (X="L") D
	.	;
	.	D DEFAULT^DBSMACRO("DBTBL1D.LEN",1)
	.	D DEFAULT^DBSMACRO("DBTBL1D.SIZ",1)
	.	;
	.	Q:(V="L")  ; Already defined as logical
	.	;
	.	I ($P(vobj(fDBTBL1D),$C(124),3)="") D DEFAULT^DBSMACRO("DBTBL1D.DFT",0)
	.	D CHANGE^DBSMACRO("DBTBL1D.DFT","REQ")
	.	D DEFAULT^DBSMACRO("DBTBL1D.REQ",1)
	.	Q 
	;
	Q 
	;
VP7(fDBTBL1D,fDBTBL1)	;
	;
	I ($P(vobj(fDBTBL1D),$C(124),9)="D"),(X<10) D  Q 
	.	;
	.	S ER=1
	.	; Length must be at least ~p1
	.	S RM=$$^MSG(1602,10)
	.	Q 
	;
	I ($P(vobj(fDBTBL1D),$C(124),9)="L"),(+X'=+1) D  Q 
	.	;
	.	S ER=1
	.	; Length cannot exceed ~p1
	.	S RM=$$^MSG(1601,1)
	.	Q 
	;
	Q 
VP8(fDBTBL1D,fDBTBL1)	;
	D CHANGE^DBSMACRO("MAX",$P(vobj(fDBTBL1D),$C(124),2))
	;
	Q 
VP9(fDBTBL1D,fDBTBL1)	;
	;
	N HDR
	;
	Q:'(V="") 
	Q:(X="") 
	Q:(X=V) 
	;
	S HDR=""
	;
	; Split heading into two lines  LINE1@LINE2
	I ($P(vobj(fDBTBL1D),$C(124),2)<$L(X)),(X?1A.E1" "1E.E) D
	.	;
	.	N I N ptr
	.	;
	.	S ptr=$L(X)\2
	.	;
	.	I $E(X,ptr)=" " S HDR=$E(X,1,ptr-1)_"@"_$E(X,ptr+1,1048575)
	.	;
	.	E  F I=1:1:ptr D  Q:'($E(HDR,I)="") 
	..		;
	..		I $E(X,ptr+I)=" " S HDR=$E(X,1,ptr+I-1)_"@"_$E(X,ptr+I+1,1048575)
	..		E  I $E(X,ptr-I)=" " S HDR=$E(X,1,ptr-I-1)_"@"_$E(X,ptr-I+1,1048575)
	..		Q 
	.	Q 
	;
	I (HDR="") S HDR=X
	;
	D DEFAULT^DBSMACRO("DBTBL1D.RHD",HDR,1,0)
	;
	Q 
VP10(fDBTBL1D,fDBTBL1)	;
	;
	Q:(X="") 
	Q:(X=V) 
	;
	I ($E(X,1)="^") D  Q 
	.	;
	.	S ER=1
	.	; Invalid syntax ~p1
	.	S RM=$$^MSG(1477,"^")
	.	Q 
	;
	I ($E(X,1)="[") D  Q:ER 
	.	;
	.	N FID
	.	;
	.	S FID=$piece($piece(X,"[",2),"]",1)
	.	;
	.	I (FID="") D  Q 
	..		;
	..		S ER=1
	..		; Invalid syntax
	..		S RM=$$^MSG(1475)
	..		Q 
	.	;
	.	I '($D(^DBTBL("SYSDEV",1,FID))) D  Q 
	..		;
	..		S ER=1
	..		; Invalid file ~p1
	..		S RM=$$^MSG(1334,FID)
	..		Q 
	.	Q 
	;
	Q 
VP11(fDBTBL1D,fDBTBL1)	;
	;
	Q:(X="") 
	;
	I '(X["X?") S X="X?"_X
	;
	Q 
VP12(fDBTBL1D,fDBTBL1)	;
	 S:'$D(vobj(fDBTBL1,99)) vobj(fDBTBL1,99)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),99)),1:"")
	;
	Q:(X="") 
	;
	I '$$isLit^UCGM(X),($P(vobj(fDBTBL1,99),$C(124),2)="") D  Q 
	.	;
	.	S ER=1
	.	S RM="Non-literal default values require a filer for the table"
	.	Q 
	;
	I ($E(X,1,2)="<<"),($E(X,$L(X)-2+1,1048575)=">>") D
	.	;
	.	; Variable format
	.	S RM=$$^MSG(2929)
	.	Q 
	;
	I ($E(X,1)="["),($E(X,$L(X))="]") D  Q 
	.	;
	.	S ER=1
	.	; Invalid syntax
	.	S RM=$$^MSG(1475)
	.	Q 
	;
	I ($P(vobj(fDBTBL1D),$C(124),9)="L"),'((X=0)!(X=1)) D
	.	;
	.	; Only apply check on insert or if changing to a logical
	.	I ((%O=0)!$D(vobj(fDBTBL1D,-100,"0*","TYP"))) D
	..		;
	..		S ER=1
	..		S RM="Logical data type must have a default of either 0 or 1"
	..		Q 
	.	Q 
	;
	Q 
VP13(fDBTBL1D,fDBTBL1)	;
	D CHANGE^DBSMACRO("TBL","[STBLJRNFUNC]:NOVAL")
	;
	Q 
VP14(fDBTBL1D,fDBTBL1)	;
	;
	Q:(X="") 
	;
	Q:(($E(X,1,2)="<<")&($E(X,$L(X)-2+1,1048575)=">>")) 
	;
	Q:($D(^STBL("JRNFUNC",X))#2) 
	;
	I ($L(X)>$P(vobj(fDBTBL1D),$C(124),2)) D  Q 
	.	;
	.	S ER=1
	.	; Maximum length allowed - ~p1
	.	S RM=$$^MSG(1690,$P(vobj(fDBTBL1D),$C(124),2))
	.	Q 
	;
	I (($P(vobj(fDBTBL1D),$C(124),9)="D")!($P(vobj(fDBTBL1D),$C(124),9)="C")) D
	.	;
	.	N retval
	.	;
	.	; Validate format - will return ER/RM if bad
	.	S retval=$$INT^%ZM(X,$P(vobj(fDBTBL1D),$C(124),9))
	.	Q 
	;
	Q 
VP15(fDBTBL1D,fDBTBL1)	;
	;
	Q:(X="") 
	;
	Q:(($E(X,1,2)="<<")&($E(X,$L(X)-2+1,1048575)=">>")) 
	;
	Q:($D(^STBL("JRNFUNC",X))#2) 
	;
	I ($L(X)>$P(vobj(fDBTBL1D),$C(124),2)) D  Q 
	.	;
	.	S ER=1
	.	; Maximum length allowed - ~p1
	.	S RM=$$^MSG(1690,$P(vobj(fDBTBL1D),$C(124),2))
	.	Q 
	;
	I (($P(vobj(fDBTBL1D),$C(124),9)="D")!($P(vobj(fDBTBL1D),$C(124),9)="C")) D
	.	;
	.	N retval
	.	;
	.	; Validate format - will return ER/RM if bad
	.	S retval=$$INT^%ZM(X,$P(vobj(fDBTBL1D),$C(124),9))
	.	Q 
	;
	Q 
VP16(fDBTBL1D,fDBTBL1)	;
	;
	I 'X,($P(vobj(fDBTBL1D),$C(124),9)="L") D
	.	;
	.	; Only apply check on insert or if changing to a logical
	.	I ((%O=0)!$D(vobj(fDBTBL1D,-100,"0*","TYP"))) D
	..		;
	..		S ER=1
	..		S RM="Logical data type must be required"
	..		Q 
	.	Q 
	;
	Q 
VP17(fDBTBL1D,fDBTBL1)	;
	;
	I X D  Q:ER 
	.	;
	.	I ($P(vobj(fDBTBL1D),$C(124),9)'="T") D  Q 
	..		;
	..		S ER=1
	..		S RM="Text Fields Only"
	..		Q 
	.	;
	.	E  I ($P(vobj(fDBTBL1D),$C(124),1)["*") D
	..		;
	..		S ER=1
	..		S RM="Can not translated key fields"
	..		Q 
	.	Q 
	;
	; Skip next prompt
	I ($P(vobj(fDBTBL1D),$C(124),9)'="D") D GOTO^DBSMACRO("NEXT")
	;
	Q 
VP18(fDBTBL1D,fDBTBL1)	;
	I '$P(vobj(fDBTBL1D),$C(124),15),($P(vobj(fDBTBL1D),$C(124),1)?1N1"*") D DEFAULT^DBSMACRO("DBTBL1D.REQ",1)
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL1D,.fDBTBL1)
	D VDA1(.fDBTBL1D,.fDBTBL1)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL1D,fDBTBL1)	;
	D VDA1(.fDBTBL1D,.fDBTBL1)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL1D,fDBTBL1)	;
	D VDA1(.fDBTBL1D,.fDBTBL1)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL1D,.fDBTBL1)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL1D" D vSET1(.fDBTBL1D,di,X)
	I sn="DBTBL1" D vSET2(.fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL1D,di,X)	;
	D vCoInd1(fDBTBL1D,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET2(fDBTBL1,di,X)	;
	D vCoInd2(fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL1D" Q $$vREAD1(.fDBTBL1D,di)
	I fid="DBTBL1" Q $$vREAD2(.fDBTBL1,di)
	Q ""
vREAD1(fDBTBL1D,di)	;
	Q $$vCoInd3(fDBTBL1D,di)
vREAD2(fDBTBL1,di)	;
	Q $$vCoInd4(fDBTBL1,di)
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
vCoMfS1(vRec,vVal)	; RecordDBTBL1D.setCMP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",16)
	S $P(vobj(vRec),"|",16)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL1D.setCNV(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",24)
	S $P(vobj(vRec),"|",24)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL1D.setDEC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",14)
	S $P(vobj(vRec),"|",14)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL1D.setDEPOSTP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",30)
	S $P(vobj(vRec),"|",30)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL1D.setDEPREP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",29)
	S $P(vobj(vRec),"|",29)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL1D.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",10)
	S $P(vobj(vRec),"|",10)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL1D.setDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL1D.setDOM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL1D.setISMASTER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",17)
	S $P(vobj(vRec),"|",17)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL1D.setITP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",11)
	S $P(vobj(vRec),"|",11)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL1D.setLEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBTBL1D.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",25)
	S $P(vobj(vRec),"|",25)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBTBL1D.setMAX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",13)
	S $P(vobj(vRec),"|",13)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordDBTBL1D.setMDD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",27)
	S $P(vobj(vRec),"|",27)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordDBTBL1D.setMIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",12)
	S $P(vobj(vRec),"|",12)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordDBTBL1D.setNOD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordDBTBL1D.setNULLIND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",31)
	S $P(vobj(vRec),"|",31)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordDBTBL1D.setPOS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",21)
	S $P(vobj(vRec),"|",21)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordDBTBL1D.setPTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordDBTBL1D.setREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",15)
	S $P(vobj(vRec),"|",15)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordDBTBL1D.setRHD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",22)
	S $P(vobj(vRec),"|",22)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS22(vRec,vVal)	; RecordDBTBL1D.setSFD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",18)
	S $P(vobj(vRec),"|",18)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS23(vRec,vVal)	; RecordDBTBL1D.setSIZ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",19)
	S $P(vobj(vRec),"|",19)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS24(vRec,vVal)	; RecordDBTBL1D.setSRL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",23)
	S $P(vobj(vRec),"|",23)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS25(vRec,vVal)	; RecordDBTBL1D.setTBL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS26(vRec,vVal)	; RecordDBTBL1D.setTYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",9)
	S $P(vobj(vRec),"|",9)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS27(vRec,vVal)	; RecordDBTBL1D.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",26)
	S $P(vobj(vRec),"|",26)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS28(vRec,vVal)	; RecordDBTBL1D.setVAL4EXT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",28)
	S $P(vobj(vRec),"|",28)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS29(vRec,vVal)	; RecordDBTBL1D.setXPO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",7)
	S $P(vobj(vRec),"|",7)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS30(vRec,vVal)	; RecordDBTBL1D.setXPR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",8)
	S $P(vobj(vRec),"|",8)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL1D.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL1D",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF" X $ZT
	;
	S vPos=$P(vP,"|",4)
	I vCol="CMP" D vCoMfS1(vOid,vVal) Q 
	I vCol="CNV" D vCoMfS2(vOid,vVal) Q 
	I vCol="DEC" D vCoMfS3(vOid,vVal) Q 
	I vCol="DEPOSTP" D vCoMfS4(vOid,vVal) Q 
	I vCol="DEPREP" D vCoMfS5(vOid,vVal) Q 
	I vCol="DES" D vCoMfS6(vOid,vVal) Q 
	I vCol="DFT" D vCoMfS7(vOid,vVal) Q 
	I vCol="DOM" D vCoMfS8(vOid,vVal) Q 
	I vCol="ISMASTER" D vCoMfS9(vOid,vVal) Q 
	I vCol="ITP" D vCoMfS10(vOid,vVal) Q 
	I vCol="LEN" D vCoMfS11(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS12(vOid,vVal) Q 
	I vCol="MAX" D vCoMfS13(vOid,vVal) Q 
	I vCol="MDD" D vCoMfS14(vOid,vVal) Q 
	I vCol="MIN" D vCoMfS15(vOid,vVal) Q 
	I vCol="NOD" D vCoMfS16(vOid,vVal) Q 
	I vCol="NULLIND" D vCoMfS17(vOid,vVal) Q 
	I vCol="POS" D vCoMfS18(vOid,vVal) Q 
	I vCol="PTN" D vCoMfS19(vOid,vVal) Q 
	I vCol="REQ" D vCoMfS20(vOid,vVal) Q 
	I vCol="RHD" D vCoMfS21(vOid,vVal) Q 
	I vCol="SFD" D vCoMfS22(vOid,vVal) Q 
	I vCol="SIZ" D vCoMfS23(vOid,vVal) Q 
	I vCol="SRL" D vCoMfS24(vOid,vVal) Q 
	I vCol="TBL" D vCoMfS25(vOid,vVal) Q 
	I vCol="TYP" D vCoMfS26(vOid,vVal) Q 
	I vCol="USER" D vCoMfS27(vOid,vVal) Q 
	I vCol="VAL4EXT" D vCoMfS28(vOid,vVal) Q 
	I vCol="XPO" D vCoMfS29(vOid,vVal) Q 
	I vCol="XPR" D vCoMfS30(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS31(vRec,vVal)	; RecordDBTBL1.setACCKEYS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,16),"|",1)
	S $P(vobj(vRec,16),"|",1)=vVal S vobj(vRec,-100,16)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS32(vRec,vVal)	; RecordDBTBL1.setAKEY1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",1)
	S $P(vobj(vRec,1),"|",1)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS33(vRec,vVal)	; RecordDBTBL1.setAKEY2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,2),"|",1)
	S $P(vobj(vRec,2),"|",1)=vVal S vobj(vRec,-100,2)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS34(vRec,vVal)	; RecordDBTBL1.setAKEY3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,3),"|",1)
	S $P(vobj(vRec,3),"|",1)=vVal S vobj(vRec,-100,3)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS35(vRec,vVal)	; RecordDBTBL1.setAKEY4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,4),"|",1)
	S $P(vobj(vRec,4),"|",1)=vVal S vobj(vRec,-100,4)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS36(vRec,vVal)	; RecordDBTBL1.setAKEY5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,5),"|",1)
	S $P(vobj(vRec,5),"|",1)=vVal S vobj(vRec,-100,5)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS37(vRec,vVal)	; RecordDBTBL1.setAKEY6(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,6),"|",1)
	S $P(vobj(vRec,6),"|",1)=vVal S vobj(vRec,-100,6)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS38(vRec,vVal)	; RecordDBTBL1.setAKEY7(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,7),"|",1)
	S $P(vobj(vRec,7),"|",1)=vVal S vobj(vRec,-100,7)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS39(vRec,vVal)	; RecordDBTBL1.setDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",1)
	S $P(vobj(vRec,10),"|",1)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS40(vRec,vVal)	; RecordDBTBL1.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS41(vRec,vVal)	; RecordDBTBL1.setDFLAG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",10)
	S $P(vobj(vRec,22),"|",10)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS42(vRec,vVal)	; RecordDBTBL1.setDFTDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",6)
	S $P(vobj(vRec,10),"|",6)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS43(vRec,vVal)	; RecordDBTBL1.setDFTDES1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",9)
	S $P(vobj(vRec,10),"|",9)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS44(vRec,vVal)	; RecordDBTBL1.setDFTHDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",8)
	S $P(vobj(vRec,10),"|",8)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS45(vRec,vVal)	; RecordDBTBL1.setDFTORD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",7)
	S $P(vobj(vRec,10),"|",7)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS46(vRec,vVal)	; RecordDBTBL1.setEXIST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",13)
	S $P(vobj(vRec,10),"|",13)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS47(vRec,vVal)	; RecordDBTBL1.setEXTENDLENGTH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",14)
	S $P(vobj(vRec,10),"|",14)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS48(vRec,vVal)	; RecordDBTBL1.setFDOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,13),"|",1)
	S $P(vobj(vRec,13),"|",1)=vVal S vobj(vRec,-100,13)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS49(vRec,vVal)	; RecordDBTBL1.setFILETYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",12)
	S $P(vobj(vRec,10),"|",12)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS50(vRec,vVal)	; RecordDBTBL1.setFPN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",3)
	S $P(vobj(vRec,99),"|",3)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS51(vRec,vVal)	; RecordDBTBL1.setFSN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,12),"|",1)
	S $P(vobj(vRec,12),"|",1)=vVal S vobj(vRec,-100,12)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS52(vRec,vVal)	; RecordDBTBL1.setGLOBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",1)
	S $P(vobj(vRec,0),"|",1)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS53(vRec,vVal)	; RecordDBTBL1.setGLREF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",1)
	S $P(vobj(vRec,100),"|",1)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS54(vRec,vVal)	; RecordDBTBL1.setLISTDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,101),"|",1)
	S $P(vobj(vRec,101),"|",1)=vVal S vobj(vRec,-100,101)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS55(vRec,vVal)	; RecordDBTBL1.setLISTREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,102),"|",1)
	S $P(vobj(vRec,102),"|",1)=vVal S vobj(vRec,-100,102)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS56(vRec,vVal)	; RecordDBTBL1.setLOG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",5)
	S $P(vobj(vRec,100),"|",5)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS57(vRec,vVal)	; RecordDBTBL1.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",10)
	S $P(vobj(vRec,10),"|",10)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS58(vRec,vVal)	; RecordDBTBL1.setMPLCTDD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",5)
	S $P(vobj(vRec,10),"|",5)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS59(vRec,vVal)	; RecordDBTBL1.setNETLOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",3)
	S $P(vobj(vRec,10),"|",3)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS60(vRec,vVal)	; RecordDBTBL1.setPARFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",4)
	S $P(vobj(vRec,10),"|",4)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS61(vRec,vVal)	; RecordDBTBL1.setPREDAEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",5)
	S $P(vobj(vRec,22),"|",5)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS62(vRec,vVal)	; RecordDBTBL1.setPTRTIM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",8)
	S $P(vobj(vRec,100),"|",8)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS63(vRec,vVal)	; RecordDBTBL1.setPTRTIMU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",11)
	S $P(vobj(vRec,100),"|",11)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS64(vRec,vVal)	; RecordDBTBL1.setPTRTLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",4)
	S $P(vobj(vRec,100),"|",4)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS65(vRec,vVal)	; RecordDBTBL1.setPTRTLDU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",10)
	S $P(vobj(vRec,100),"|",10)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS66(vRec,vVal)	; RecordDBTBL1.setPTRUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",3)
	S $P(vobj(vRec,100),"|",3)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS67(vRec,vVal)	; RecordDBTBL1.setPTRUSERU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",9)
	S $P(vobj(vRec,100),"|",9)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS68(vRec,vVal)	; RecordDBTBL1.setPUBLISH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",6)
	S $P(vobj(vRec,99),"|",6)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS69(vRec,vVal)	; RecordDBTBL1.setQID1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,14),"|",1)
	S $P(vobj(vRec,14),"|",1)=vVal S vobj(vRec,-100,14)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS70(vRec,vVal)	; RecordDBTBL1.setRECTYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",2)
	S $P(vobj(vRec,100),"|",2)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS71(vRec,vVal)	; RecordDBTBL1.setRFLAG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",9)
	S $P(vobj(vRec,22),"|",9)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS72(vRec,vVal)	; RecordDBTBL1.setSCREEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",8)
	S $P(vobj(vRec,22),"|",8)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS73(vRec,vVal)	; RecordDBTBL1.setSYSSN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",2)
	S $P(vobj(vRec,10),"|",2)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS74(vRec,vVal)	; RecordDBTBL1.setUDACC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",1)
	S $P(vobj(vRec,99),"|",1)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS75(vRec,vVal)	; RecordDBTBL1.setUDFILE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",2)
	S $P(vobj(vRec,99),"|",2)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS76(vRec,vVal)	; RecordDBTBL1.setUDPOST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",5)
	S $P(vobj(vRec,99),"|",5)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS77(vRec,vVal)	; RecordDBTBL1.setUDPRE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",4)
	S $P(vobj(vRec,99),"|",4)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS78(vRec,vVal)	; RecordDBTBL1.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",11)
	S $P(vobj(vRec,10),"|",11)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS79(vRec,vVal)	; RecordDBTBL1.setVAL4EXT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",1)
	S $P(vobj(vRec,22),"|",1)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol,vVal)	; RecordDBTBL1.setColumn(1,0)
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
	I vCol="ACCKEYS" D vCoMfS31(vOid,vVal) Q 
	I vCol="AKEY1" D vCoMfS32(vOid,vVal) Q 
	I vCol="AKEY2" D vCoMfS33(vOid,vVal) Q 
	I vCol="AKEY3" D vCoMfS34(vOid,vVal) Q 
	I vCol="AKEY4" D vCoMfS35(vOid,vVal) Q 
	I vCol="AKEY5" D vCoMfS36(vOid,vVal) Q 
	I vCol="AKEY6" D vCoMfS37(vOid,vVal) Q 
	I vCol="AKEY7" D vCoMfS38(vOid,vVal) Q 
	I vCol="DEL" D vCoMfS39(vOid,vVal) Q 
	I vCol="DES" D vCoMfS40(vOid,vVal) Q 
	I vCol="DFLAG" D vCoMfS41(vOid,vVal) Q 
	I vCol="DFTDES" D vCoMfS42(vOid,vVal) Q 
	I vCol="DFTDES1" D vCoMfS43(vOid,vVal) Q 
	I vCol="DFTHDR" D vCoMfS44(vOid,vVal) Q 
	I vCol="DFTORD" D vCoMfS45(vOid,vVal) Q 
	I vCol="EXIST" D vCoMfS46(vOid,vVal) Q 
	I vCol="EXTENDLENGTH" D vCoMfS47(vOid,vVal) Q 
	I vCol="FDOC" D vCoMfS48(vOid,vVal) Q 
	I vCol="FILETYP" D vCoMfS49(vOid,vVal) Q 
	I vCol="FPN" D vCoMfS50(vOid,vVal) Q 
	I vCol="FSN" D vCoMfS51(vOid,vVal) Q 
	I vCol="GLOBAL" D vCoMfS52(vOid,vVal) Q 
	I vCol="GLREF" D vCoMfS53(vOid,vVal) Q 
	I vCol="LISTDFT" D vCoMfS54(vOid,vVal) Q 
	I vCol="LISTREQ" D vCoMfS55(vOid,vVal) Q 
	I vCol="LOG" D vCoMfS56(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS57(vOid,vVal) Q 
	I vCol="MPLCTDD" D vCoMfS58(vOid,vVal) Q 
	I vCol="NETLOC" D vCoMfS59(vOid,vVal) Q 
	I vCol="PARFID" D vCoMfS60(vOid,vVal) Q 
	I vCol="PREDAEN" D vCoMfS61(vOid,vVal) Q 
	I vCol="PTRTIM" D vCoMfS62(vOid,vVal) Q 
	I vCol="PTRTIMU" D vCoMfS63(vOid,vVal) Q 
	I vCol="PTRTLD" D vCoMfS64(vOid,vVal) Q 
	I vCol="PTRTLDU" D vCoMfS65(vOid,vVal) Q 
	I vCol="PTRUSER" D vCoMfS66(vOid,vVal) Q 
	I vCol="PTRUSERU" D vCoMfS67(vOid,vVal) Q 
	I vCol="PUBLISH" D vCoMfS68(vOid,vVal) Q 
	I vCol="QID1" D vCoMfS69(vOid,vVal) Q 
	I vCol="RECTYP" D vCoMfS70(vOid,vVal) Q 
	I vCol="RFLAG" D vCoMfS71(vOid,vVal) Q 
	I vCol="SCREEN" D vCoMfS72(vOid,vVal) Q 
	I vCol="SYSSN" D vCoMfS73(vOid,vVal) Q 
	I vCol="UDACC" D vCoMfS74(vOid,vVal) Q 
	I vCol="UDFILE" D vCoMfS75(vOid,vVal) Q 
	I vCol="UDPOST" D vCoMfS76(vOid,vVal) Q 
	I vCol="UDPRE" D vCoMfS77(vOid,vVal) Q 
	I vCol="USER" D vCoMfS78(vOid,vVal) Q 
	I vCol="VAL4EXT" D vCoMfS79(vOid,vVal) Q 
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
vCoInd3(vOid,vCol)	; RecordDBTBL1D.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL1D",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S vCmp=$$getCurExpr^UCXDD(vP,"vOid",0) Q @vCmp
	;
	S vPos=$P(vP,"|",4)
	N vRet
	S vRet=vobj(vOid)
	S vRet=$piece(vRet,"|",vPos)
	I '($P(vP,"|",13)="") Q $$getSf^UCCOLSF(vRet,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vCoInd4(vOid,vCol)	; RecordDBTBL1.getColumn()
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
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2,9,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2,9,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2)	;	vobj()=Db.getRecord(DBSDOM,,1)
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
vDb5(v1,v2,v3,v2out)	;	voXN = Db.getRecord(DBTBL1D,,1,-2)
	;
	N pardi
	S pardi=$G(^DBTBL(v1,1,v2,9,v3))
	I pardi="",'$D(^DBTBL(v1,1,v2,9,v3))
	S v2out='$T
	;
	Q pardi
	;
vDb6(v1,v2out)	;	voXN = Db.getRecord(DBCTLDVFM,,1,-2)
	;
	N dvfm
	S dvfm=$G(^DBCTL("SYS","DVFM",v1))
	I dvfm="",'$D(^DBCTL("SYS","DVFM",v1))
	S v2out='$T
	;
	Q dvfm
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL1D)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew2(v1,v2)	;	vobj()=Class.new(DBTBL1)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	DINAM FROM DBINDX WHERE LIBS='SYSDEV' AND FID=:V1 AND DINAM=:DI
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=$G(DI) I vos3="" G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBINDX("SYSDEV","DI",vos4),1) I vos4="" G vL1a0
	S vos5=""
vL1a6	S vos5=$O(^DBINDX("SYSDEV","DI",vos4,vos2,vos3,vos5),1) I vos5="" G vL1a4
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
	S rs=vos3
	;
	Q 1
	;
vOpen2()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND (TYP='M' OR TYP='B') AND DI <> :DI
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=$G(DI) I vos3="",'$D(DI) G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^DBTBL("SYSDEV",1,vos2,9,vos4),1) I vos4="" G vL2a0
	I '(vos4'=vos3) G vL2a4
	S vos5=$G(^DBTBL("SYSDEV",1,vos2,9,vos4))
	I '($P(vos5,"|",9)="M"!($P(vos5,"|",9)="B")) G vL2a4
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
