V01S306(%O,fDBTBL1D,fDBTBL1)	;DBS - DBS - SID= <DBTBL1F> Files Definition (Structure Definition)
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL1F ****
	;
	; 09/14/2007 10:48 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:48 - chenardp
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
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL1F" S VPGM=$T(+0) S VSNAME="Files Definition (Structure Definition)"
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
	S VO="22||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,1,0,0,0,0,0,0)_"01T                 Data Item Definition (Structure Definition)                    "
	S VO(2)=$C(3,15,10,0,0,0,0,0,0,0)_"01TFile Name:"
	S VO(3)=$C(4,15,10,0,0,0,0,0,0,0)_"01TData Item:"
	S VO(4)=$C(6,11,14,0,0,0,0,0,0,0)_"01TSub Record ID:"
	S VO(5)=$C(6,57,7,0,0,0,0,0,0,0)_"01TColumn:"
	S VO(6)=$C(7,12,13,0,0,0,0,0,0,0)_"01TMaster Field:"
	S VO(7)=$C(8,18,30,2,0,0,0,0,0,0)_"01T           Computed Expression"
	S VO(8)=$C(13,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(9)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(14,25,29,2,0,0,0,0,0,0)_"01TSpecial Sub-Field Definitions"
	S VO(11)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(16,47,32,1,0,0,0,0,0,0)_"01T      Delimiters        Position"
	S VO(16)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(17,11,14,0,0,0,0,0,0,0)_"01TSub-field Tag:"
	S VO(19)=$C(17,47,7,0,0,0,0,0,0,0)_"01TPrefix:"
	S VO(20)=$C(17,60,7,0,0,0,0,0,0,0)_"01TSuffix:"
	S VO(21)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(18,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL1D,fDBTBL1)	; Display screen data
	N V
	;
	S VO="33|23|13|0"
	S VO(23)=$C(3,26,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL1D,-4)),1,12)
	S VO(24)=$C(4,26,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL1D,-5)),1,12)
	S VO(25)=$C(4,40,40,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL1D),$C(124),10)),1,40)
	S VO(26)=$C(6,26,26,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),1)),1,26)
	S VO(27)=$C(6,65,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),21)
	S VO(28)=$C(7,26,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),17):"Y",1:"N")
	S VO(29)=$C(10,2,79,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1D),$C(124),16)),1,254)
	S VO(30)=$C(17,26,12,2,0,0,0,0,0,0)_"00U"_$E(($P($P(vobj(fDBTBL1D),$C(124),18),$C(126),1)),1,12)
	S VO(31)=$C(17,55,3,2,0,0,0,0,0,0)_"00N"_$P($P(vobj(fDBTBL1D),$C(124),18),$C(126),2)
	S VO(32)=$C(17,68,3,2,0,0,0,0,0,0)_"00N"_$P($P(vobj(fDBTBL1D),$C(124),18),$C(126),3)
	S VO(33)=$C(17,77,2,2,0,0,0,0,0,0)_"00N"_$P($P(vobj(fDBTBL1D),$C(124),18),$C(126),4)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL1D,fDBTBL1)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=11 S VPT=1 S VPB=18 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1D,DBTBL1" S VSCRPP=1 S VSCRPP=1
	S OLNTB=18001
	;
	S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1D")="zfDBTBL1D"
	;
	;
	S %TAB(1)=$C(2,25,12)_"21U12402|1|[DBTBL1D]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||256"
	S %TAB(2)=$C(3,25,12)_"21U12403|1|[DBTBL1D]DI||if X?1""%"".AN!(X?.A.""_"".E)|||||||256"
	S %TAB(3)=$C(3,39,40)_"21T12410|1|[DBTBL1D]DES"
	S %TAB(4)=$C(5,25,26)_"00T12401|1|[DBTBL1D]NOD|||do VP1^V01S306(.fDBTBL1D,.fDBTBL1)"
	S %TAB(5)=$C(5,64,2)_"00N12421|1|[DBTBL1D]POS|||do VP2^V01S306(.fDBTBL1D,.fDBTBL1)|do VP3^V01S306(.fDBTBL1D,.fDBTBL1)"
	S %TAB(6)=$C(6,25,1)_"00L12417|1|[DBTBL1D]ISMASTER|||do VP4^V01S306(.fDBTBL1D,.fDBTBL1)"
	S %TAB(7)=$C(9,1,79)_"00T12416|1|[DBTBL1D]CMP|||do VP5^V01S306(.fDBTBL1D,.fDBTBL1)||||||255"
	S %TAB(8)=$C(16,25,12)_"00U12418|1|[DBTBL1D]SFT|||do VP6^V01S306(.fDBTBL1D,.fDBTBL1)|||||~126~~1"
	S %TAB(9)=$C(16,54,3)_"00N12418|1|[DBTBL1D]SFD1|[DBCTLDELIM]||do VP7^V01S306(.fDBTBL1D,.fDBTBL1)||1|255||~126~~2"
	S %TAB(10)=$C(16,67,3)_"00N12418|1|[DBTBL1D]SFD2|[DBCTLDELIM]||do VP8^V01S306(.fDBTBL1D,.fDBTBL1)|||||~126~~3"
	S %TAB(11)=$C(16,76,2)_"00N12418|1|[DBTBL1D]SFP|||do VP9^V01S306(.fDBTBL1D,.fDBTBL1)|||||~126~~4"
	D VTBL(.fDBTBL1D,.fDBTBL1) D VDEPRE(.fDBTBL1D,.fDBTBL1) I $get(ER) Q 
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
VSPP	; screen post proc
	D VSPP1(.fDBTBL1D,.fDBTBL1)
	;  #ACCEPT Date=11/05/03; pgm=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
VSPP1(fDBTBL1D,fDBTBL1)	;
	;
	Q:'($P(vobj(fDBTBL1D),$C(124),18)="") 
	;
	Q:(($P(vobj(fDBTBL1D),$C(124),1)="")!($P(vobj(fDBTBL1D),$C(124),21)=""))  ; Computed
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2,V3,V4 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21),V4=vobj(fDBTBL1D,-5) S rs=$$vOpen1()
	;
	I $$vFetch1() D
	.	;
	.	S ER=1
	.	; Sub-record ID and column already assigned to ~p1
	.	S RM=$$^MSG(251,rs)
	.	Q 
	;
	Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
VDEPRE(fDBTBL1D,fDBTBL1)	; Data Entry Pre-processor
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	 S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	I ($P(vobj(fDBTBL1D),$C(124),1)["*") D PROTECT^DBSMACRO("ALL") Q 
	I ($P(vobj(fDBTBL1D),$C(124),9)="M")!($P(vobj(fDBTBL1D),$C(124),9)="B") D  Q 
	.	D PROTECT^DBSMACRO("DBTBL1D.POS")
	.	D PROTECT^DBSMACRO("DBTBL1D.ISMASTER")
	.	D PROTECT^DBSMACRO("DBTBL1D.CMP")
	.	D PROTECT^DBSMACRO("DBTBL1D.SFT")
	.	D PROTECT^DBSMACRO("DBTBL1D.SFD1")
	.	D PROTECT^DBSMACRO("DBTBL1D.SFD2")
	.	D PROTECT^DBSMACRO("DBTBL1D.SFP")
	.	I (%O=0),($P(vobj(fDBTBL1,100),$C(124),2)=1) D
	..		;
	..		N key N keys
	..		;
	..		S keys=$P(vobj(fDBTBL1,16),$C(124),1)
	..		S key=$piece(keys,",",$L(keys,","))
	..		;
	..		D DEFAULT^DBSMACRO("DBTBL1D.NOD",key)
	..		Q 
	.	Q 
	I (+$P(vobj(fDBTBL1,100),$C(124),2)=0) D PROTECT^DBSMACRO("ALL") Q 
	;
	I (($P(vobj(fDBTBL1,10),$C(124),1)="")) D PROTECT^DBSMACRO("DBTBL1D.POS")
	;
	I '($P(vobj(fDBTBL1,10),$C(124),4)="")  N V1,V2 S V1=$P(vobj(fDBTBL1,10),$C(124),4),V2=vobj(fDBTBL1D,-5) I ($D(^DBTBL("SYSDEV",1,V1,9,V2))#2) D  Q 
	.	;
	.	D PROTECT^DBSMACRO("DBTBL1D.NOD")
	.	Q 
	;
	I (%O=0),($P(vobj(fDBTBL1,100),$C(124),2)=1) D
	.	;
	.	N key N keys
	.	;
	.	S keys=$P(vobj(fDBTBL1,16),$C(124),1)
	.	S key=$piece(keys,",",$L(keys,","))
	.	;
	.	D DEFAULT^DBSMACRO("DBTBL1D.NOD",key)
	.	Q 
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(fDBTBL1D,fDBTBL1)	;
	;
	N isMB
	N FID
	;
	I (($P(vobj(fDBTBL1D),$C(124),9)="M")!($P(vobj(fDBTBL1D),$C(124),9)="B")) S isMB=1
	E  S isMB=0
	S FID=vobj(fDBTBL1D,-4)
	;
	; For memo/blob, ensure only one per node
	I isMB D  Q:ER 
	.	;
	.	I (X="") D  Q 
	..		;
	..		S ER=1
	..		; Data required
	..		S RM=$$^MSG(741)
	..		Q 
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen2()
	.	;
	.	I $$vFetch2() D
	..		;
	..		S ER=1
	..		S RM="Node already in use by column "_$P(rs,$C(9),1)_" data type "_$P(rs,$C(9),2)
	..		Q 
	.	Q 
	;
	I 'isMB,'(X=""),($P(vobj(fDBTBL1D),$C(124),21)="") D DEFAULT^DBSMACRO("DBTBL1D.POS",$$DFTPOS(fDBTBL1,X))
	;
	; Reserved for Z data items (NODE>999)
	I ($E(vobj(fDBTBL1D,-5),1)="Z"),(X?1N.N),(X<999) D  Q 
	.	;
	.	S ER=1
	.	; Option not available for this field
	.	S RM=$$^MSG(4913)_" "_DI
	.	Q 
	;
	I (X="") D  Q 
	.	;
	.	D DELETE^DBSMACRO("DBTBL1D.POS",1)
	.	D PROTECT^DBSMACRO("DBTBL1D.POS")
	.	D PROTECT^DBSMACRO("DBTBL1D.FCR")
	.	D PROTECT^DBSMACRO("DBTBL1D.LEN")
	.	D PROTECT^DBSMACRO("DBTBL1D.ISMASTER")
	.	D UNPROT^DBSMACRO("DBTBL1D.CMP")
	.	Q 
	;
	I 'isMB D
	.	;
	.	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	.	I '($P(vobj(fDBTBL1,10),$C(124),1)="") D UNPROT^DBSMACRO("DBTBL1D.POS")
	.	;
	.	D UNPROT^DBSMACRO("DBTBL1D.FCR")
	.	D UNPROT^DBSMACRO("DBTBL1D.LEN")
	.	D UNPROT^DBSMACRO("DBTBL1D.ISMASTER")
	.	D PROTECT^DBSMACRO("DBTBL1D.CMP")
	.	;
	.	; Find default position for this node
	.	I (FID="ACN") D
	..		;
	..		N POS
	..		;
	..		N rs,vos7,vos8,vos9,vos11,vos10,vos12,vos13,vos14 S rs=$$vOpen3()
	..		;
	..		I $$vFetch3() S POS=rs+1
	..		E  S POS=1
	..		;
	..	 N vSetMf S vSetMf=$P(vobj(fDBTBL1D),$C(124),21) S $P(vobj(fDBTBL1D),$C(124),21)=POS,vobj(fDBTBL1D,-100,"0*")=""
	..		;
	..		I (%O=0) D DEFAULT^DBSMACRO("DBTBL1D.POS",POS,1,0)
	..		Q 
	.	Q 
	;
	I (FID'="ACN") D
	.	;
	.	N RECTYP
	.	;
	.	I (X?1N1"*") D GOTO^DBSMACRO("END") Q 
	.	;
	.	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	.	S RECTYP=$P(vobj(fDBTBL1,100),$C(124),2)
	.	;
	.	I (+RECTYP=0) D  Q 
	..		;
	..		S ER=1
	..		; Invalid for record type ~p1
	..		S RM=$$^MSG(1348,RECTYP)
	..		Q 
	.	;
	.	I (RECTYP=1) D  Q:ER 
	..		;
	..		N key N keys
	..		;
	..		 S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
	..		S keys=$P(vobj(fDBTBL1,16),$C(124),1)
	..		;
	..		Q:(keys["""") 
	..		;
	..		S key=$piece(keys,",",$L(keys,","))
	..		;
	..		I (X'=key) D
	...			;
	...			S ER=1
	...			; Invalid for record type ~p1, use ~p2
	...			S RM=$$^MSG(1349,RECTYP,key)
	...			Q 
	..		Q 
	.	;
	.	I ($E(X,1)="[") D  Q:ER 
	..		;
	..		N di N fid
	..		;
	..		S fid=$piece($piece(X,"[",2),"]",1)
	..		S di=$piece(X,"]",2)
	..		;
	..		I ((fid="")!(di="")) S ER=1
	..		E   N V1,V2 S V1=fid,V2=di I '($D(^DBTBL("SYSDEV",1,V1,9,V2))#2) S ER=1
	..		;
	..		; Invalid syntax
	..		I ER S RM=$$^MSG(1475)
	..		Q 
	.	;
	.	S RM=$P(vobj(fDBTBL1,100),$C(124),1)
	.	I (X?1N.E) S RM=RM_","_X_")"
	.	E  S RM=RM_")"
	.	;
	.	I '($E(X,1)="%"),(X?.E1C.E) D  Q 
	..		;
	..		S ER=1
	..		; Alphanumeric format only
	..		S RM=$$^MSG(248)
	..		Q 
	.	;
	.	I 'isMB,'($P(vobj(fDBTBL1D),$C(124),16)="") D DELETE^DBSMACRO("DBTBL1D.CMP",0)
	.	;
	.	I 'isMB,(%O=0) D DEFAULT^DBSMACRO("DBTBL1D.POS",$$DFTPOS(fDBTBL1,X),1,0)
	.	Q 
	;
	Q 
	;
DFTPOS(fDBTBL1,NOD)	;
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	N POS
	;
	I ($P(vobj(fDBTBL1,10),$C(124),1)="") Q ""
	I (NOD="") Q ""
	I (V["*") Q ""
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen4()
	;
	I $$vFetch4() S POS=rs+1
	E  S POS=1
	;
	Q POS
VP2(fDBTBL1D,fDBTBL1)	;
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	Q:(($P(vobj(fDBTBL1D),$C(124),9)="M")!($P(vobj(fDBTBL1D),$C(124),9)="B")) 
	;
	Q:($P(vobj(fDBTBL1D),$C(124),1)="") 
	;
	I '($P(vobj(fDBTBL1,10),$C(124),1)=""),(X="") D
	.	;
	.	S ER=1
	.	; Data required
	.	S RM=$$^MSG(741)
	.	Q 
	;
	D CHANGE^DBSMACRO("TBL","")
	;
	Q 
VP3(fDBTBL1D,fDBTBL1)	;
	; Display columns by position
	;
	I (X="") S X=$$DFTPOS(fDBTBL1,$P(vobj(fDBTBL1D),$C(124),1))
	;
	K nodpos
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen5()
	;
	F  Q:'($$vFetch5())  D
	.	;
	.	N DIPAD
	.	;
	.	S DIPAD=$P(rs,$C(9),2)
	.	S DIPAD=DIPAD_$J("",14-$L(DIPAD))
	.	;
	.	S nodpos($P(rs,$C(9),1))=DIPAD_$P(rs,$C(9),3)
	.	Q 
	;
	S I(3)="nodpos("
	;
	Q 
VP4(fDBTBL1D,fDBTBL1)	;
	;
	Q:'X 
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen6()
	;
	I $$vFetch6() D  Q 
	.	;
	.	S ER=1
	.	S RM="Masterfield column "_rs_" already assigned to this sub-record ID and column"
	.	Q 
	;
	D GOTO^DBSMACRO("END")
	;
	Q 
VP5(fDBTBL1D,fDBTBL1)	;
	N vpc
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	 S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
	;
	Q:(($P(vobj(fDBTBL1D),$C(124),9)="M")!($P(vobj(fDBTBL1D),$C(124),9)="B")) 
	;
	Q:((X="")&($P(vobj(fDBTBL1,10),$C(124),12)=5)) 
	;
	; See if this is an MDD file
	N rs,vos1,vos2,vos3,vos4  N V1 S V1=vobj(fDBTBL1D,-4) S rs=$$vOpen7()
	;
	S vpc=($$vFetch7()) Q:vpc  ; Is MDD
	;
	I (X=""),($P(vobj(fDBTBL1D),$C(124),1)=""),($P(vobj(fDBTBL1,100),$C(124),2)>0) D CHANGE^DBSMACRO("REQ")
	;
	; Validate computed expression
	S ER=$$VALIDCMP^DBSDF(vobj(fDBTBL1D,-4),vobj(fDBTBL1D,-5),.X,.RM)
	;
	I '(X="") D
	.	;
	.	I ($L(vobj(fDBTBL1D,-5))>8) D
	..		;
	..		S ER=1
	..		; Computed column name must be 8 characters or less
	..		S RM=$$^MSG(4476)
	..		Q 
	.	;
	.	I (vobj(fDBTBL1D,-5)["_") D
	..		;
	..		S ER=1
	..		; Computed column name cannot contain an "_"
	..		S RM=$$^MSG(4477)
	..		Q 
	.	Q 
	;
	Q 
VP6(fDBTBL1D,fDBTBL1)	;
	;
	Q:(X="") 
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen8()
	;
	I '$G(vos1) D
	.	;
	.	S ER=1
	.	S RM="Cannot assign a subfield to a non-masterfield column"
	.	Q 
	;
	Q 
VP7(fDBTBL1D,fDBTBL1)	;
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	I '(X="") D  Q:ER 
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen9()
	.	;
	.	I '$G(vos1) D
	..		;
	..		S ER=1
	..		S RM="Cannot assign a subfield to a non-masterfield column"
	..		Q 
	.	Q 
	;
	I (X=""),'($P($P(vobj(fDBTBL1D),$C(124),18),$C(126),1)="") D  Q 
	.	;
	.	S ER=1
	.	; Data required
	.	S RM=$$^MSG(741)
	.	Q 
	;
	I '(X=""),(X=$P(vobj(fDBTBL1,10),$C(124),1)) D  Q 
	.	;
	.	S ER=1
	.	; Invalid file delimiter (i.e., cannot be file delimiter)
	.	S RM=$$^MSG(416)
	.	Q 
	;
	Q 
VP8(fDBTBL1D,fDBTBL1)	;
	 S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
	;
	N MFCOL
	;
	I '(X="") D  Q:ER 
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen10()
	.	;
	.	I '$G(vos1) D
	..		;
	..		S ER=1
	..		S RM="Cannot assign a subfield to a non-masterfield column"
	..		Q 
	.	Q 
	;
	I (X=""),'($P($P(vobj(fDBTBL1D),$C(124),18),$C(126),1)="") D  Q 
	.	;
	.	S ER=1
	.	; Data required
	.	S RM=$$^MSG(741)
	.	Q 
	;
	I '(X=""),(X=$P(vobj(fDBTBL1,10),$C(124),1)) D  Q 
	.	;
	.	S ER=1
	.	; Invalid file delimiter (i.e., cannot be file delimiter)
	.	S RM=$$^MSG(416)
	.	Q 
	;
	Q 
VP9(fDBTBL1D,fDBTBL1)	;
	;
	Q:(X="") 
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen11()
	;
	I '$G(vos1) D
	.	;
	.	S ER=1
	.	S RM="Cannot assign a subfield to a non-masterfield column"
	.	Q 
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
vOpen1()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND DI<>:V4
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL1a0
	S vos4=$G(V3) I vos4="",'$D(V3) G vL1a0
	S vos5=$G(V4) I vos5="",'$D(V4) G vL1a0
	S vos6=""
vL1a6	S vos6=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos6),1) I vos6="" G vL1a0
	I '(vos6'=vos5) G vL1a6
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
	S rs=$S(vos6=$$BYTECHAR^SQLUTL(254):"",1:vos6)
	;
	Q 1
	;
vOpen10()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
	;
	;
	S vos1=2
	D vL10a1
	Q ""
	;
vL10a0	S vos1=0 Q
vL10a1	S vos2=$G(V1) I vos2="" G vL10a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL10a0
	S vos4=$G(V3) I vos4="",'$D(V3) G vL10a0
	S vos5=""
vL10a5	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL10a0
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '(+$P(vos6,"|",17)=1) G vL10a5
	Q
	;
vFetch10()	;
	;
	;
	I vos1=1 D vL10a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen11()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
	;
	;
	S vos1=2
	D vL11a1
	Q ""
	;
vL11a0	S vos1=0 Q
vL11a1	S vos2=$G(V1) I vos2="" G vL11a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL11a0
	S vos4=$G(V3) I vos4="",'$D(V3) G vL11a0
	S vos5=""
vL11a5	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL11a0
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '(+$P(vos6,"|",17)=1) G vL11a5
	Q
	;
vFetch11()	;
	;
	;
	I vos1=1 D vL11a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen2()	;	DI,TYP FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND NOD=:X AND (TYP='B' OR TYP='M')
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FID) I vos2="" G vL2a0
	S vos3=$G(X) I vos3="",'$D(X) G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4),1) I vos4="" G vL2a0
	S vos5=""
vL2a6	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL2a4
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '($P(vos6,"|",9)="B"!($P(vos6,"|",9)="M")) G vL2a6
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)_$C(9)_$P(vos6,"|",9)
	;
	Q 1
	;
vOpen3()	;	MAX(POS) FROM DBTBL1D WHERE (FID='DEP' OR FID='LN') AND NOD=:X
	;
	;
	S vos7=2
	D vL3a1
	Q ""
	;
vL3a0	S vos7=0 Q
vL3a1	S vos8=$G(X) I vos8="",'$D(X) G vL3a0
	S vos9=""
vL3a3	S vos9=$O(^DBINDX(vos9),1) I vos9="" G vL3a12
	S vos10=0
vL3a5	S v=vos10,vos11=$$NPC^%ZS("DEP,LN",.v,1),vos10=v I v=0 G vL3a3
	S vos12=""
vL3a7	S vos12=$O(^DBINDX(vos9,"STR",vos11,vos8,vos12),1) I vos12="" G vL3a5
	S vos13=""
vL3a9	S vos13=$O(^DBINDX(vos9,"STR",vos11,vos8,vos12,vos13),1) I vos13="" G vL3a7
	S vos14=$S('$D(vos14):$S(vos12=$$BYTECHAR^SQLUTL(254):"",1:vos12),vos14<$S(vos12=$$BYTECHAR^SQLUTL(254):"",1:vos12):$S(vos12=$$BYTECHAR^SQLUTL(254):"",1:vos12),1:vos14)
	G vL3a9
vL3a12	I $G(vos14)="" S vd="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos7=1 D vL3a12
	I vos7=2 S vos7=1
	;
	I vos7=0 Q 0
	;
	S rs=$G(vos14)
	S vos14=""
	S vos7=100
	;
	Q 1
	;
vOpen4()	;	MAX(POS) FROM DBTBL1D WHERE FID=:V1 AND NOD=:NOD
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V1) I vos2="" G vL4a0
	S vos3=$G(NOD) I vos3="",'$D(NOD) G vL4a0
	S vos4=""
vL4a4	S vos4=$O(^DBINDX(vos4),1) I vos4="" G vL4a11
	S vos5=""
vL4a6	S vos5=$O(^DBINDX(vos4,"STR",vos2,vos3,vos5),1) I vos5="" G vL4a4
	S vos6=""
vL4a8	S vos6=$O(^DBINDX(vos4,"STR",vos2,vos3,vos5,vos6),1) I vos6="" G vL4a6
	S vos7=$S('$D(vos7):$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5),vos7<$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5):$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5),1:vos7)
	G vL4a8
vL4a11	I $G(vos7)="" S vd="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a11
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$G(vos7)
	S vos7=""
	S vos1=100
	;
	Q 1
	;
vOpen5()	;	POS,DI,DES FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:NOD AND SFD IS NULL
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=$G(NOD) I vos3="",'$D(NOD) G vL5a0
	S vos4=""
vL5a4	S vos4=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4),1) I vos4="" G vL5a0
	S vos5=""
vL5a6	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL5a4
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '($P(vos6,"|",18)="") G vL5a6
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)_$C(9)_$P(vos6,"|",10)
	;
	Q 1
	;
vOpen6()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V1) I vos2="" G vL6a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL6a0
	S vos4=$G(V3) I vos4="",'$D(V3) G vL6a0
	S vos5=""
vL6a5	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL6a0
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '(+$P(vos6,"|",17)=1) G vL6a5
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen7()	;	SYSSN FROM SCASYS WHERE DBSMDD=:V1
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(V1) I vos2="",'$D(V1) G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^SCATBL(2,vos3),1) I vos3="" G vL7a0
	S vos4=$G(^SCATBL(2,vos3))
	I '($P(vos4,"|",7)=vos2) G vL7a3
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen8()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(V1) I vos2="" G vL8a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL8a0
	S vos4=$G(V3) I vos4="",'$D(V3) G vL8a0
	S vos5=""
vL8a5	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL8a0
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '(+$P(vos6,"|",17)=1) G vL8a5
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen9()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(V1) I vos2="" G vL9a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL9a0
	S vos4=$G(V3) I vos4="",'$D(V3) G vL9a0
	S vos5=""
vL9a5	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL9a0
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '(+$P(vos6,"|",17)=1) G vL9a5
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
