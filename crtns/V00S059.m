 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL1F ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S059(%O,fDBTBL1D,fDBTBL1) ; DBS - DBS - SID= <DBTBL1F> Files Definition (Structure Definition)
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
VDA1(fDBTBL1D,fDBTBL1) ; Display screen data
 N V
 ;
 S VO="33|23|13|0"
 S VO(23)=$C(3,26,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(fDBTBL1D,-4),1,12)
 S VO(24)=$C(4,26,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(fDBTBL1D,-5),1,12)
 S VO(25)=$C(4,40,40,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL1D),$C(124),10),1,40)
 S VO(26)=$C(6,26,26,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),1),1,26)
 S VO(27)=$C(6,65,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1D),$C(124),21)
 S VO(28)=$C(7,26,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1D),$C(124),17):"Y",1:"N")
 S VO(29)=$C(10,2,79,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1D),$C(124),16),1,254)
 S VO(30)=$C(17,26,12,2,0,0,0,0,0,0)_"00U"_$E($P($P(vobj(fDBTBL1D),$C(124),18),$C(126),1),1,12)
 S VO(31)=$C(17,55,3,2,0,0,0,0,0,0)_"00N"_$P($P(vobj(fDBTBL1D),$C(124),18),$C(126),2)
 S VO(32)=$C(17,68,3,2,0,0,0,0,0,0)_"00N"_$P($P(vobj(fDBTBL1D),$C(124),18),$C(126),3)
 S VO(33)=$C(17,77,2,2,0,0,0,0,0,0)_"00N"_$P($P(vobj(fDBTBL1D),$C(124),18),$C(126),4)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL1D,fDBTBL1) ; 
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
 S %TAB(4)=$C(5,25,26)_"00T12401|1|[DBTBL1D]NOD|||do VP1^V00S059(.fDBTBL1D,.fDBTBL1)"
 S %TAB(5)=$C(5,64,2)_"00N12421|1|[DBTBL1D]POS|||do VP2^V00S059(.fDBTBL1D,.fDBTBL1)|do VP3^V00S059(.fDBTBL1D,.fDBTBL1)"
 S %TAB(6)=$C(6,25,1)_"00L12417|1|[DBTBL1D]ISMASTER|||do VP4^V00S059(.fDBTBL1D,.fDBTBL1)"
 S %TAB(7)=$C(9,1,79)_"00T12416|1|[DBTBL1D]CMP|||do VP5^V00S059(.fDBTBL1D,.fDBTBL1)||||||255"
 S %TAB(8)=$C(16,25,12)_"00U12418|1|[DBTBL1D]SFT|||do VP6^V00S059(.fDBTBL1D,.fDBTBL1)|||||~126~~1"
 S %TAB(9)=$C(16,54,3)_"00N12418|1|[DBTBL1D]SFD1|[DBCTLDELIM]||do VP7^V00S059(.fDBTBL1D,.fDBTBL1)||1|255||~126~~2"
 S %TAB(10)=$C(16,67,3)_"00N12418|1|[DBTBL1D]SFD2|[DBCTLDELIM]||do VP8^V00S059(.fDBTBL1D,.fDBTBL1)|||||~126~~3"
 S %TAB(11)=$C(16,76,2)_"00N12418|1|[DBTBL1D]SFP|||do VP9^V00S059(.fDBTBL1D,.fDBTBL1)|||||~126~~4"
 D VTBL(.fDBTBL1D,.fDBTBL1) D VDEPRE(.fDBTBL1D,.fDBTBL1) I $get(ER) Q 
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
VSPP ; screen post proc
 D VSPP1(.fDBTBL1D,.fDBTBL1)
 ;  #ACCEPT Date=11/05/03; pgm=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
VSPP1(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:'($P(vobj(fDBTBL1D),$C(124),18)="") 
 ;
 Q:(($P(vobj(fDBTBL1D),$C(124),1)="")!($P(vobj(fDBTBL1D),$C(124),21)=""))  ; Computed
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2,V3,V4 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21),V4=vobj(fDBTBL1D,-5) S rs=$$vOpen1()
 ;
 I $$vFetch1() D
 .	;
 .	S ER=1
 .	; Sub-record ID and column already assigned to ~p1
 . S RM=$$^MSG(251,rs)
 .	Q 
 ;
 Q 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
VDEPRE(fDBTBL1D,fDBTBL1) ; Data Entry Pre-processor
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
 I ($P(vobj(fDBTBL1,10),$C(124),1)="") D PROTECT^DBSMACRO("DBTBL1D.POS")
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
VP1(fDBTBL1D,fDBTBL1) ; 
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
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen2()
 .	;
 .	I $$vFetch2() D
 ..		;
 ..		S ER=1
 ..  S RM="Node already in use by column "_$P(rs,$C(9),1)_" data type "_$P(rs,$C(9),2)
 ..		Q 
 . Q 
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
 ..		N rs,vos8,vos9,vos10,vos11,vos13,vos12,vos14,vos15,vos16 S rs=$$vOpen3()
 ..		;
 ..  I $$vFetch3() S POS=rs+1
 ..		E  S POS=1
 ..		;
 ..	  S:'$D(vobj(fDBTBL1D,-100,"0*","POS")) vobj(fDBTBL1D,-100,"0*","POS")="N021"_$P(vobj(fDBTBL1D),$C(124),21),vobj(fDBTBL1D,-100,"0*")="" S $P(vobj(fDBTBL1D),$C(124),21)=POS
 ..		;
 ..		I (%O=0) D DEFAULT^DBSMACRO("DBTBL1D.POS",POS,1,0)
 ..  Q 
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
DFTPOS(fDBTBL1,NOD) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
 ;
 N POS
 ;
 I ($P(vobj(fDBTBL1,10),$C(124),1)="") Q ""
 I (NOD="") Q ""
 I (V["*") Q ""
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen4()
 ;
 I $$vFetch4() S POS=rs+1
 E  S POS=1
 ;
 Q POS
VP2(fDBTBL1D,fDBTBL1) ; 
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
VP3(fDBTBL1D,fDBTBL1) ; 
 ; Display columns by position
 ;
 I (X="") S X=$$DFTPOS(fDBTBL1,$P(vobj(fDBTBL1D),$C(124),1))
 ;
 K nodpos
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1 S V1=vobj(fDBTBL1,-4) S rs=$$vOpen5()
 ;
 F  Q:'$$vFetch5()  D
 .	;
 .	N DIPAD
 .	;
 . S DIPAD=$P(rs,$C(9),2)
 .	S DIPAD=DIPAD_$J("",14-$L(DIPAD))
 .	;
 . S nodpos($P(rs,$C(9),1))=DIPAD_$P(rs,$C(9),3)
 .	Q 
 ;
 S I(3)="nodpos("
 ;
 Q 
VP4(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:'X 
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen6()
 ;
 I $$vFetch6() D  Q 
 .	;
 .	S ER=1
 . S RM="Masterfield column "_rs_" already assigned to this sub-record ID and column"
 .	Q 
 ;
 D GOTO^DBSMACRO("END")
 ;
 Q 
VP5(fDBTBL1D,fDBTBL1) ; 
 N vpc
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,100)) vobj(fDBTBL1,100)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100)),1:"")
 ;
 Q:(($P(vobj(fDBTBL1D),$C(124),9)="M")!($P(vobj(fDBTBL1D),$C(124),9)="B")) 
 ;
 Q:((X="")&($P(vobj(fDBTBL1,10),$C(124),12)=5)) 
 ;
 ; See if this is an MDD file
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(fDBTBL1D,-4) S rs=$$vOpen7()
 ;
 S vpc=$$vFetch7() Q:vpc  ; Is MDD
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
VP6(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen8()
 ;
 I '$G(vos1) D
 .	;
 .	S ER=1
 .	S RM="Cannot assign a subfield to a non-masterfield column"
 .	Q 
 ;
 Q 
VP7(fDBTBL1D,fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
 ;
 I '(X="") D  Q:ER 
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen9()
 .	;
 . I '$G(vos1) D
 ..		;
 ..		S ER=1
 ..		S RM="Cannot assign a subfield to a non-masterfield column"
 ..		Q 
 . Q 
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
VP8(fDBTBL1D,fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
 ;
 N MFCOL
 ;
 I '(X="") D  Q:ER 
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen10()
 .	;
 . I '$G(vos1) D
 ..		;
 ..		S ER=1
 ..		S RM="Cannot assign a subfield to a non-masterfield column"
 ..		Q 
 . Q 
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
VP9(fDBTBL1D,fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2,V3 S V1=vobj(fDBTBL1D,-4),V2=$P(vobj(fDBTBL1D),$C(124),1),V3=$P(vobj(fDBTBL1D),$C(124),21) S rs=$$vOpen11()
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
 ;
vOpen1() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND DI<>:V4
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL1a0
 S vos5=$G(V3)
 S vos6=$G(V4) I vos6="",'$D(V4) G vL1a0
 S vos7=""
vL1a7 S vos7=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos7),1) I vos7="" G vL1a0
 I '(vos7'=vos6) G vL1a7
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
 S rs=$S(vos7=vos2:"",1:vos7)
 ;
 Q 1
 ;
vOpen10() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
 ;
 ;
 S vos1=2
 D vL10a1
 Q ""
 ;
vL10a0 S vos1=0 Q
vL10a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL10a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL10a0
 S vos5=$G(V3)
 S vos6=""
vL10a6 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL10a0
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '(+$P(vos7,"|",17)=1) G vL10a6
 Q
 ;
vFetch10() ;
 ;
 ;
 I vos1=1 D vL10a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen11() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
 ;
 ;
 S vos1=2
 D vL11a1
 Q ""
 ;
vL11a0 S vos1=0 Q
vL11a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL11a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL11a0
 S vos5=$G(V3)
 S vos6=""
vL11a6 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL11a0
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '(+$P(vos7,"|",17)=1) G vL11a6
 Q
 ;
vFetch11() ;
 ;
 ;
 I vos1=1 D vL11a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen2() ; DI,TYP FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND NOD=:X AND (TYP='B' OR TYP='M')
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL2a0
 S vos4=$G(X) I vos4="",'$D(X) G vL2a0
 S vos5=""
vL2a5 S vos5=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5),1) I vos5="" G vL2a0
 S vos6=""
vL2a7 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL2a5
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '($P(vos7,"|",9)="B"!($P(vos7,"|",9)="M")) G vL2a7
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)_$C(9)_$P(vos7,"|",9)
 ;
 Q 1
 ;
vOpen3() ; MAX(POS) FROM DBTBL1D WHERE (FID='DEP' OR FID='LN') AND NOD=:X
 ;
 ;
 S vos8=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos8=0 Q
vL3a1 S vos9=$$BYTECHAR^SQLUTL(254)
 S vos10=$G(X) I vos10="",'$D(X) G vL3a0
 S vos11=""
vL3a4 S vos11=$O(^DBINDX(vos11),1) I vos11="" G vL3a13
 S vos12=0
vL3a6 S v=vos12,vos13=$$NPC^%ZS("DEP,LN",.v,1),vos12=v I v=0 G vL3a4
 S vos14=""
vL3a8 S vos14=$O(^DBINDX(vos11,"STR",vos13,vos10,vos14),1) I vos14="" G vL3a6
 S vos15=""
vL3a10 S vos15=$O(^DBINDX(vos11,"STR",vos13,vos10,vos14,vos15),1) I vos15="" G vL3a8
 S vos16=$S($G(vos16)="":$S(vos14=vos9:"",1:vos14),vos16<$S(vos14=vos9:"",1:vos14):$S(vos14=vos9:"",1:vos14),1:vos16)
 G vL3a10
vL3a13 I $G(vos16)="" S vd="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos8=1 D vL3a13
 I vos8=2 S vos8=1
 ;
 I vos8=0 S rs="" Q 0
 ;
 S rs=$G(vos16)
 S vos8=100
 ;
 Q 1
 ;
vOpen4() ; MAX(POS) FROM DBTBL1D WHERE FID=:V1 AND NOD=:NOD
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL4a0
 S vos4=$G(NOD) I vos4="",'$D(NOD) G vL4a0
 S vos5=""
vL4a5 S vos5=$O(^DBINDX(vos5),1) I vos5="" G vL4a12
 S vos6=""
vL4a7 S vos6=$O(^DBINDX(vos5,"STR",vos3,vos4,vos6),1) I vos6="" G vL4a5
 S vos7=""
vL4a9 S vos7=$O(^DBINDX(vos5,"STR",vos3,vos4,vos6,vos7),1) I vos7="" G vL4a7
 S vos8=$S($G(vos8)="":$S(vos6=vos2:"",1:vos6),vos8<$S(vos6=vos2:"",1:vos6):$S(vos6=vos2:"",1:vos6),1:vos8)
 G vL4a9
vL4a12 I $G(vos8)="" S vd="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a12
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$G(vos8)
 S vos1=100
 ;
 Q 1
 ;
vOpen5() ; POS,DI,DES FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:NOD AND SFD IS NULL
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL5a0
 S vos4=$G(NOD) I vos4="",'$D(NOD) G vL5a0
 S vos5=""
vL5a5 S vos5=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5),1) I vos5="" G vL5a0
 S vos6=""
vL5a7 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL5a5
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '($P(vos7,"|",18)="") G vL5a7
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)_$C(9)_$P(vos7,"|",10)
 ;
 Q 1
 ;
vOpen6() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL6a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL6a0
 S vos5=$G(V3)
 S vos6=""
vL6a6 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL6a0
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '(+$P(vos7,"|",17)=1) G vL6a6
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen7() ; SYSSN FROM SCASYS WHERE DBSMDD=:V1
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL7a0
 S vos4=""
vL7a4 S vos4=$O(^SCATBL(2,vos4),1) I vos4="" G vL7a0
 S vos5=$G(^SCATBL(2,vos4))
 I '($P(vos5,"|",7)=vos3) G vL7a4
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^SCATBL(2,vos4))
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen8() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
 ;
 ;
 S vos1=2
 D vL8a1
 Q ""
 ;
vL8a0 S vos1=0 Q
vL8a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL8a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL8a0
 S vos5=$G(V3)
 S vos6=""
vL8a6 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL8a0
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '(+$P(vos7,"|",17)=1) G vL8a6
 Q
 ;
vFetch8() ;
 ;
 ;
 I vos1=1 D vL8a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen9() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND NOD=:V2 AND POS=:V3 AND ISMASTER=1
 ;
 ;
 S vos1=2
 D vL9a1
 Q ""
 ;
vL9a0 S vos1=0 Q
vL9a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL9a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL9a0
 S vos5=$G(V3)
 S vos6=""
vL9a6 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL9a0
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '(+$P(vos7,"|",17)=1) G vL9a6
 Q
 ;
vFetch9() ;
 ;
 ;
 I vos1=1 D vL9a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
