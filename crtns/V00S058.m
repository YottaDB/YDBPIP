 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL1E ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S058(%O,fDBTBL1D,fDBTBL1) ; DBS -  - SID= <DBTBL1E> Files Definition - Detail
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fDBTBL1D)#2)  K vobj(+$G(fDBTBL1D)) S fDBTBL1D=$$vcdmNew^RecordDBTBL1D()
 .	I '($D(fDBTBL1)#2)  K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vcdmNew^RecordDBTBL1()
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
VNEW(fDBTBL1D,fDBTBL1) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBTBL1D,.fDBTBL1)
 D VLOD(.fDBTBL1D,.fDBTBL1)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBTBL1D,fDBTBL1) ; 
 Q:(vobj(fDBTBL1D,-3)="")!(vobj(fDBTBL1D,-4)="")!(vobj(fDBTBL1D,-5)="") 
 Q:%O  S ER=0 I (vobj(fDBTBL1D,-3)="")!(vobj(fDBTBL1D,-4)="")!(vobj(fDBTBL1D,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID,DI") Q 
  N V1,V2,V3 S V1=vobj(fDBTBL1D,-3),V2=vobj(fDBTBL1D,-4),V3=vobj(fDBTBL1D,-5) I ($D(^DBTBL(V1,1,V2,9,V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(fDBTBL1D),$C(124),11)=""  S:'$D(vobj(fDBTBL1D,-100,"0*","ITP")) vobj(fDBTBL1D,-100,"0*","ITP")="T011"_$P(vobj(fDBTBL1D),$C(124),11),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),11)="S"
 I $P(vobj(fDBTBL1D),$C(124),31)=""  S:'$D(vobj(fDBTBL1D,-100,"0*","NULLIND")) vobj(fDBTBL1D,-100,"0*","NULLIND")="L031"_$P(vobj(fDBTBL1D),$C(124),31),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),31)=0
 I $P(vobj(fDBTBL1D),$C(124),9)=""  S:'$D(vobj(fDBTBL1D,-100,"0*","TYP")) vobj(fDBTBL1D,-100,"0*","TYP")="U009"_$P(vobj(fDBTBL1D),$C(124),9),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),9)="T"
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBTBL1D,fDBTBL1) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBTBL1D,fDBTBL1) ; Display screen prompts
 S VO="68||13|0"
 S VO(0)="|0"
 S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(3,2,11,1,0,0,0,0,0,0)_"01T Data Item:"
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
VDA1(fDBTBL1D,fDBTBL1) ; Display screen data
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
 S VO(72)=$C(3,59,10,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL1D),$C(124),26),1,10)
 S VO(73)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str($P(vobj(fDBTBL1D),$C(124),25),"MM/DD/YEAR")
 S VO(74)=$C(4,59,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1D),$C(124),27),1,12)
 S VO(75)=$C(5,59,20,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1D),$C(124),4),1,20)
 S VO(76)=$C(7,20,1,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1D),$C(124),9),1)
 S VO(77)=$C(7,35,5,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),2)
 S VO(78)=$C(7,59,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),19)
 S VO(79)=$C(7,74,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),14)
 S VO(80)=$C(8,20,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),10),1,40)
 S VO(81)=$C(9,20,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),22),1,40)
 S VO(82)=$C(11,20,60,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),5),1,60)
 S VO(83)=$C(12,20,60,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),6),1,60)
 S VO(84)=$C(13,20,58,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),3),1,58)
 S VO(85)=$C(14,20,25,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),12),1,25)
 S VO(86)=$C(15,20,25,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),13),1,25)
 S VO(87)=$C(17,20,58,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),8),1,58)
 S VO(88)=$C(18,20,58,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),7),1,58)
 S VO(89)=$C(20,20,58,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),29),1,58)
 S VO(90)=$C(21,20,58,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),30),1,58)
 S VO(91)=$C(22,12,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),15):"Y",1:"N")
 S VO(92)=$C(22,37,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),28):"Y",1:"N")
 S VO(93)=$C(22,66,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),23):"Y",1:"N")
 S VO(94)=$C(22,75,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),31):"Y",1:"N")
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL1D,fDBTBL1) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=25 S VPT=1 S VPB=23 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1D,DBTBL1"
 S OLNTB=23001
 ;
 S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1D")="zfDBTBL1D"
 ;
 ;
 S %TAB(1)=$C(2,13,12)_"01U|*DI|[*]@DI|@SELDI^DBSFUN(FID,.X)||do VP1^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(2)=$C(2,43,1)_"00L|*DELETE|[*]@DELETE|||do VP2^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(3)=$C(2,58,10)_"20T12426|1|[DBTBL1D]USER|||||||||40"
 S %TAB(4)=$C(2,69,10)_"20D12425|1|[DBTBL1D]LTD"
 S %TAB(5)=$C(3,58,12)_"00U12427|1|[DBTBL1D]MDD|@SELDI^DBSFUN($$MDD^DBSDF(FID),.X)||do VP3^V00S058(.fDBTBL1D,.fDBTBL1)|do VP4^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(6)=$C(4,58,20)_"00U12404|1|[DBTBL1D]DOM|[DBSDOM]||do VP5^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(7)=$C(6,19,1)_"01U12409|1|[DBTBL1D]TYP|[DBCTLDVFM]||do VP6^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(8)=$C(6,34,5)_"01N12402|1|[DBTBL1D]LEN|||do VP7^V00S058(.fDBTBL1D,.fDBTBL1)||||||7"
 S %TAB(9)=$C(6,58,3)_"00N12419|1|[DBTBL1D]SIZ|||do VP8^V00S058(.fDBTBL1D,.fDBTBL1)||1"
 S %TAB(10)=$C(6,73,2)_"00N12414|1|[DBTBL1D]DEC|||||0|18"
 S %TAB(11)=$C(7,19,40)_"01T12410|1|[DBTBL1D]DES|||do VP9^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(12)=$C(8,19,40)_"01T12422|1|[DBTBL1D]RHD"
 S %TAB(13)=$C(10,19,60)_"00T12405|1|[DBTBL1D]TBL|||do VP10^V00S058(.fDBTBL1D,.fDBTBL1)||||||255"
 S %TAB(14)=$C(11,19,60)_"00T12406|1|[DBTBL1D]PTN|||do VP11^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(15)=$C(12,19,58)_"00T12403|1|[DBTBL1D]DFT|||do VP12^V00S058(.fDBTBL1D,.fDBTBL1)|do VP13^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(16)=$C(13,19,25)_"00T12412|1|[DBTBL1D]MIN|||do VP14^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(17)=$C(14,19,25)_"00T12413|1|[DBTBL1D]MAX|||do VP15^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(18)=$C(16,19,58)_"00T12408|1|[DBTBL1D]XPR"
 S %TAB(19)=$C(17,19,58)_"00T12407|1|[DBTBL1D]XPO"
 S %TAB(20)=$C(19,19,58)_"00T12429|1|[DBTBL1D]DEPREP|||||||||255"
 S %TAB(21)=$C(20,19,58)_"00T12430|1|[DBTBL1D]DEPOSTP|||||||||255"
 S %TAB(22)=$C(21,11,1)_"00L12415|1|[DBTBL1D]REQ|||do VP16^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(23)=$C(21,36,1)_"00L12428|1|[DBTBL1D]VAL4EXT|||do VP17^V00S058(.fDBTBL1D,.fDBTBL1)|do VP18^V00S058(.fDBTBL1D,.fDBTBL1)"
 S %TAB(24)=$C(21,65,1)_"00L12423|1|[DBTBL1D]SRL"
 S %TAB(25)=$C(21,74,1)_"00L12431|1|[DBTBL1D]NULLIND"
 D VTBL(.fDBTBL1D,.fDBTBL1)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBTBL1D,fDBTBL1) ; Create %TAB(array)
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
VP1(fDBTBL1D,fDBTBL1) ; 
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
 D CHANGE^DBSMACRO("TBL","")
 D UNPROT^DBSMACRO("ALL")
 ;
 S DI=X
 ;
  K vobj(+$G(fDBTBL1D)) S fDBTBL1D=$$vRCgetRecord1^RecordDBTBL1D("SYSDEV",FID,DI,0)
 ;
 I ($G(vobj(fDBTBL1D,-2))=0) D
 .	;
 .	I ($P(vobj(fDBTBL1,100),$C(124),2)=1) D
 ..		;
 ..		N keys S keys=$P(vobj(fDBTBL1,16),$C(124),1)
 ..		;
 ..	  S:'$D(vobj(fDBTBL1D,-100,"0*","NOD")) vobj(fDBTBL1D,-100,"0*","NOD")="T001"_$P(vobj(fDBTBL1D),$C(124),1),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),1)=$piece(keys,",",$L(keys,","))
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
ZSUPRTYP(fDBTBL1,DI,PARFID) ; Supertype table name /MECH=REFNAM:W
 N vpc
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
 ;
 S PARFID=$P(vobj(fDBTBL1,10),$C(124),4)
 Q:(PARFID="") 
 ;
 N pardi,vop1 S pardi=$$vRCgetRecord1Opt^RecordDBTBL1D("SYSDEV",PARFID,DI,0,.vop1)
 ;
 S vpc=($G(vop1)=0) Q:vpc  ; Not in parent table
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
ZPROT1(fDBTBL1,MDDFID,DOMREQ,MDDREQ) ; SCASYS.DBSMDDREQ  /MECH=REFNAM:W
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
VP2(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:'X 
 ;
 ; Don't allow delete if the column is in use
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen1()
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
VP3(fDBTBL1D,fDBTBL1) ; 
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
 N mdddi,vop1 S mdddi=$$vRCgetRecord1Opt^RecordDBTBL1D("SYSDEV",MDDFID,X,0,.vop1)
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
VP4(fDBTBL1D,fDBTBL1) ; 
 ;
 I (PARFID="") D UNPROT^DBSMACRO("ALL")
 ;
 D ZPROT1(fDBTBL1,.MDDFID,.DOMREQ,.MDDREQ) ; In post-processor for DI
 ;
 Q 
VP5(fDBTBL1D,fDBTBL1) ; 
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
 N dbsdom S dbsdom=$$vRCgetRecord1^RecordDBSDOM(SYSSN,X,0)
 S vpc=($G(vobj(dbsdom,-2))=0) K:vpc vobj(+$G(dbsdom)) Q:vpc 
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
ZPROT(dbsdom) ; 
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
VP6(fDBTBL1D,fDBTBL1) ; 
 N vpc
  S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
 ;
 Q:(X="") 
 ;
 I ((X="M")!(X="B")) D  Q:ER 
 .	;
 .	I ($P(vobj(fDBTBL1,100),$C(124),2)=1) D  Q:ER 
 ..		;
 ..		N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen2()
 ..		;
 ..  I $$vFetch2() D  Q 
 ...			;
 ...			S ER=1
 ...			; Memo or binary field already assigned to ~p1
 ...   S RM=$$^MSG(800,rs)
 ...			Q 
 ..  Q 
 .	;
 .	; Create default computed expression for memo/blob fields
 .  S:'$D(vobj(fDBTBL1D,-100,"0*","NOD")) vobj(fDBTBL1D,-100,"0*","NOD")="T001"_$P(vobj(fDBTBL1D),$C(124),1),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),1)=""
 .  S:'$D(vobj(fDBTBL1D,-100,"0*","POS")) vobj(fDBTBL1D,-100,"0*","POS")="N021"_$P(vobj(fDBTBL1D),$C(124),21),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),21)=""
 .  S $P(vobj(fDBTBL1D),$C(124),16)=" "
 .	Q 
 ;
 N dvfm,vop1 S dvfm=$$vRCgetRecord1Opt^RecordDBCTLDVFM(X,0,.vop1)
 ;
 S vpc=($G(vop1)=0) Q:vpc 
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
VP7(fDBTBL1D,fDBTBL1) ; 
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
VP8(fDBTBL1D,fDBTBL1) ; 
 D CHANGE^DBSMACRO("MAX",$P(vobj(fDBTBL1D),$C(124),2))
 ;
 Q 
VP9(fDBTBL1D,fDBTBL1) ; 
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
VP10(fDBTBL1D,fDBTBL1) ; 
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
VP11(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 I '(X["X?") S X="X?"_X
 ;
 Q 
VP12(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:(X="") 
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
 .	I ((%O=0)!($D(vobj(fDBTBL1D,-100,"0*","TYP"))&($P($E($G(vobj(fDBTBL1D,-100,"0*","TYP")),5,9999),$C(124))'=$P(vobj(fDBTBL1D),$C(124),9)))) D
 ..		;
 ..		S ER=1
 ..		S RM="Logical data type must have a default of either 0 or 1"
 ..		Q 
 .	Q 
 ;
 Q 
VP13(fDBTBL1D,fDBTBL1) ; 
 D CHANGE^DBSMACRO("TBL","[STBLJRNFUNC]:NOVAL")
 ;
 Q 
VP14(fDBTBL1D,fDBTBL1) ; 
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
VP15(fDBTBL1D,fDBTBL1) ; 
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
VP16(fDBTBL1D,fDBTBL1) ; 
 ;
 I 'X,($P(vobj(fDBTBL1D),$C(124),9)="L") D
 .	;
 .	; Only apply check on insert or if changing to a logical
 .	I ((%O=0)!($D(vobj(fDBTBL1D,-100,"0*","TYP"))&($P($E($G(vobj(fDBTBL1D,-100,"0*","TYP")),5,9999),$C(124))'=$P(vobj(fDBTBL1D),$C(124),9)))) D
 ..		;
 ..		S ER=1
 ..		S RM="Logical data type must be required"
 ..		Q 
 .	Q 
 ;
 Q 
VP17(fDBTBL1D,fDBTBL1) ; 
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
VP18(fDBTBL1D,fDBTBL1) ; 
 I '$P(vobj(fDBTBL1D),$C(124),15),($P(vobj(fDBTBL1D),$C(124),1)?1N1"*") D DEFAULT^DBSMACRO("DBTBL1D.REQ",1)
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fDBTBL1D,.fDBTBL1)
 D VDA1(.fDBTBL1D,.fDBTBL1)
 D ^DBSPNT()
 Q 
 ;
VW(fDBTBL1D,fDBTBL1) ; 
 D VDA1(.fDBTBL1D,.fDBTBL1)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBTBL1D,fDBTBL1) ; 
 D VDA1(.fDBTBL1D,.fDBTBL1)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBTBL1D,.fDBTBL1)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL1D" D vSET1(.fDBTBL1D,di,X)
 I sn="DBTBL1" D vSET2(.fDBTBL1,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBTBL1D,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL1D,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET2(fDBTBL1,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL1,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL1D" Q $$vREAD1(.fDBTBL1D,di)
 I fid="DBTBL1" Q $$vREAD2(.fDBTBL1,di)
 Q ""
vREAD1(fDBTBL1D,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL1D,di)
vREAD2(fDBTBL1,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL1,di)
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
vOpen1() ; DINAM FROM DBINDX WHERE LIBS='SYSDEV' AND FID=:V1 AND DINAM=:DI
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=$G(DI) I vos4="" G vL1a0
 S vos5=""
vL1a5 S vos5=$O(^DBINDX("SYSDEV","DI",vos5),1) I vos5="" G vL1a0
 S vos6=""
vL1a7 S vos6=$O(^DBINDX("SYSDEV","DI",vos5,vos3,vos4,vos6),1) I vos6="" G vL1a5
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=vos4
 ;
 Q 1
 ;
vOpen2() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND (TYP='M' OR TYP='B') AND DI <> :DI
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL2a0
 S vos4=$G(DI) I vos4="",'$D(DI) G vL2a0
 S vos5=""
vL2a5 S vos5=$O(^DBTBL("SYSDEV",1,vos3,9,vos5),1) I vos5="" G vL2a0
 I '(vos5'=vos4) G vL2a5
 S vos6=$G(^DBTBL("SYSDEV",1,vos3,9,vos5))
 I '($P(vos6,"|",9)="M"!($P(vos6,"|",9)="B")) G vL2a5
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos6=$G(^DBTBL("SYSDEV",1,vos3,9,vos5))
 S rs=$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
