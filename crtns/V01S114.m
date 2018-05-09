V01S114(%O,fCUVAR)	; -  - SID= <DBSVAR> DATA-QWIK Control Table Maintenance
	;
	; **** Routine compiled from DATA-QWIK Screen DBSVAR ****
	;
	; 09/13/2007 15:33 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/13/2007 15:32 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fCUVAR)#2) K vobj(+$G(fCUVAR)) S fCUVAR=$$vDbNew1()
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,ZMSKOPT" S VSID="DBSVAR" S VPGM=$T(+0) S VSNAME="DATA-QWIK Control Table Maintenance"
	S VFSN("CUVAR")="zfCUVAR"
	S vPSL=1
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fCUVAR) D VDA1(.fCUVAR) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.fCUVAR) D VPR(.fCUVAR) D VDA1(.fCUVAR)
	I %O D VLOD(.fCUVAR) Q:$get(ER)  D VPR(.fCUVAR) D VDA1(.fCUVAR)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fCUVAR)
	Q 
	;
VNEW(fCUVAR)	; Initialize arrays if %O=0
	;
	D VDEF(.fCUVAR)
	D VLOD(.fCUVAR)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fCUVAR)	;
	 S:'$D(vobj(fCUVAR,"%ET")) vobj(fCUVAR,"%ET")=$S(vobj(fCUVAR,-2):$G(^CUVAR("%ET")),1:"")
	 S:'$D(vobj(fCUVAR,"%HELP")) vobj(fCUVAR,"%HELP")=$S(vobj(fCUVAR,-2):$G(^CUVAR("%HELP")),1:"")
	 S:'$D(vobj(fCUVAR,"ALCOUNT")) vobj(fCUVAR,"ALCOUNT")=$S(vobj(fCUVAR,-2):$G(^CUVAR("ALCOUNT")),1:"")
	 S:'$D(vobj(fCUVAR,"BANNER")) vobj(fCUVAR,"BANNER")=$S(vobj(fCUVAR,-2):$G(^CUVAR("BANNER")),1:"")
	 S:'$D(vobj(fCUVAR,"BOBR")) vobj(fCUVAR,"BOBR")=$S(vobj(fCUVAR,-2):$G(^CUVAR("BOBR")),1:"")
	 S:'$D(vobj(fCUVAR,"DBS")) vobj(fCUVAR,"DBS")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DBS")),1:"")
	 S:'$D(vobj(fCUVAR,"EUR")) vobj(fCUVAR,"EUR")=$S(vobj(fCUVAR,-2):$G(^CUVAR("EUR")),1:"")
	 S:'$D(vobj(fCUVAR,"IRAHIST")) vobj(fCUVAR,"IRAHIST")=$S(vobj(fCUVAR,-2):$G(^CUVAR("IRAHIST")),1:"")
	 S:'$D(vobj(fCUVAR,"LN")) vobj(fCUVAR,"LN")=$S(vobj(fCUVAR,-2):$G(^CUVAR("LN")),1:"")
	 S:'$D(vobj(fCUVAR,"CIF")) vobj(fCUVAR,"CIF")=$S(vobj(fCUVAR,-2):$G(^CUVAR("CIF")),1:"")
	 S:'$D(vobj(fCUVAR,"REGCC")) vobj(fCUVAR,"REGCC")=$S(vobj(fCUVAR,-2):$G(^CUVAR("REGCC")),1:"")
	 S:'$D(vobj(fCUVAR,"ODP")) vobj(fCUVAR,"ODP")=$S(vobj(fCUVAR,-2):$G(^CUVAR("ODP")),1:"")
	 S:'$D(vobj(fCUVAR,"USERNAME")) vobj(fCUVAR,"USERNAME")=$S(vobj(fCUVAR,-2):$G(^CUVAR("USERNAME")),1:"")
	I $D(^CUVAR) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fCUVAR,"%ET"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"%ET"),$C(124),1) S $P(vobj(fCUVAR,"%ET"),$C(124),1)="ZE^UTLERR",vobj(fCUVAR,-100,"%ET")=""
	I $P(vobj(fCUVAR,"%HELP"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"%HELP"),$C(124),1) S $P(vobj(fCUVAR,"%HELP"),$C(124),1)=0,vobj(fCUVAR,-100,"%HELP")=""
	I $P(vobj(fCUVAR,"%HELP"),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"%HELP"),$C(124),2) S $P(vobj(fCUVAR,"%HELP"),$C(124),2)=0,vobj(fCUVAR,-100,"%HELP")=""
	I $P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"ALCOUNT"),$C(124),1) S $P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)=5,vobj(fCUVAR,-100,"ALCOUNT")=""
	I $P(vobj(fCUVAR,"BANNER"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"BANNER"),$C(124),1) S $P(vobj(fCUVAR,"BANNER"),$C(124),1)=1,vobj(fCUVAR,-100,"BANNER")=""
	I $P(vobj(fCUVAR,"BOBR"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"BOBR"),$C(124),1) S $P(vobj(fCUVAR,"BOBR"),$C(124),1)=0,vobj(fCUVAR,-100,"BOBR")=""
	I $P(vobj(fCUVAR,"DBS"),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"DBS"),$C(124),3) S $P(vobj(fCUVAR,"DBS"),$C(124),3)="SCAU$HELP:OOE_SCA132.EXP",vobj(fCUVAR,-100,"DBS")=""
	I $P(vobj(fCUVAR,"DBS"),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"DBS"),$C(124),2) S $P(vobj(fCUVAR,"DBS"),$C(124),2)="SCAU$HELP:OOE_SCA80.EXP",vobj(fCUVAR,-100,"DBS")=""
	I $P(vobj(fCUVAR,"DBS"),$C(124),6)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"DBS"),$C(124),6) S $P(vobj(fCUVAR,"DBS"),$C(124),6)="US",vobj(fCUVAR,-100,"DBS")=""
	I $P(vobj(fCUVAR,"EUR"),$C(124),17)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"EUR"),$C(124),17) S $P(vobj(fCUVAR,"EUR"),$C(124),17)=9,vobj(fCUVAR,-100,"EUR")=""
	I $P(vobj(fCUVAR,"IRAHIST"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"IRAHIST"),$C(124),1) S $P(vobj(fCUVAR,"IRAHIST"),$C(124),1)=365,vobj(fCUVAR,-100,"IRAHIST")=""
	I $P(vobj(fCUVAR,"LN"),$C(124),37)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"LN"),$C(124),37) S $P(vobj(fCUVAR,"LN"),$C(124),37)=0,vobj(fCUVAR,-100,"LN")=""
	I $P(vobj(fCUVAR,"LN"),$C(124),34)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"LN"),$C(124),34) S $P(vobj(fCUVAR,"LN"),$C(124),34)=0,vobj(fCUVAR,-100,"LN")=""
	I $P(vobj(fCUVAR,"LN"),$C(124),36)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"LN"),$C(124),36) S $P(vobj(fCUVAR,"LN"),$C(124),36)=0,vobj(fCUVAR,-100,"LN")=""
	I $P(vobj(fCUVAR,"LN"),$C(124),35)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"LN"),$C(124),35) S $P(vobj(fCUVAR,"LN"),$C(124),35)=0,vobj(fCUVAR,-100,"LN")=""
	I $P(vobj(fCUVAR,"CIF"),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"CIF"),$C(124),2) S $P(vobj(fCUVAR,"CIF"),$C(124),2)=12,vobj(fCUVAR,-100,"CIF")=""
	I $P(vobj(fCUVAR,"CIF"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"CIF"),$C(124),1) S $P(vobj(fCUVAR,"CIF"),$C(124),1)=1,vobj(fCUVAR,-100,"CIF")=""
	I $P(vobj(fCUVAR,"REGCC"),$C(124),11)="" S:'$D(vobj(fCUVAR,-100,"REGCC","OBDE")) vobj(fCUVAR,-100,"REGCC","OBDE")="L011"_$P(vobj(fCUVAR,"REGCC"),$C(124),11) S vobj(fCUVAR,-100,"REGCC")="",$P(vobj(fCUVAR,"REGCC"),$C(124),11)=0
	I $P(vobj(fCUVAR,"ODP"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"ODP"),$C(124),1) S $P(vobj(fCUVAR,"ODP"),$C(124),1)=0,vobj(fCUVAR,-100,"ODP")=""
	I $P(vobj(fCUVAR,"CIF"),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"CIF"),$C(124),3) S $P(vobj(fCUVAR,"CIF"),$C(124),3)=1,vobj(fCUVAR,-100,"CIF")=""
	I $P(vobj(fCUVAR,"ODP"),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"ODP"),$C(124),2) S $P(vobj(fCUVAR,"ODP"),$C(124),2)=0,vobj(fCUVAR,-100,"ODP")=""
	I $P(vobj(fCUVAR,"CIF"),$C(124),5)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"CIF"),$C(124),5) S $P(vobj(fCUVAR,"CIF"),$C(124),5)=1,vobj(fCUVAR,-100,"CIF")=""
	I $P(vobj(fCUVAR,"USERNAME"),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fCUVAR,"USERNAME"),$C(124),1) S $P(vobj(fCUVAR,"USERNAME"),$C(124),1)=0,vobj(fCUVAR,-100,"USERNAME")=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fCUVAR)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fCUVAR)	; Display screen prompts
	S VO="52||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(4)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,15,14,1,0,0,0,0,0,0)_"01T Company Name:"
	S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,7,25,0,0,0,0,0,0,0)_"01TDirect VMS Access Option:"
	S VO(13)=$C(6,47,19,1,0,0,0,0,0,0)_"01T Format Table Name:"
	S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(8,2,17,1,0,0,0,0,0,0)_"01T Login Message(s)"
	S VO(19)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(11,36,16,1,0,0,0,0,0,0)_"01T Driver Message "
	S VO(26)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(30)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(31)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(32)=$C(14,15,22,0,0,0,0,0,0,0)_"01TAlignment Print Count:"
	S VO(33)=$C(14,64,1,0,0,0,0,0,0,0)_"01Tx"
	S VO(34)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(15,17,20,0,0,0,0,0,0,0)_"01TDisplay Banner Page:"
	S VO(37)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(39)=$C(16,15,22,0,0,0,0,0,0,0)_"01TField Overflow Option:"
	S VO(40)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(17,13,24,0,0,0,0,0,0,0)_"01T80 Column Report Header:"
	S VO(43)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(45)=$C(18,12,25,0,0,0,0,0,0,0)_"01T132 Column Report Header:"
	S VO(46)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(49)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(50)=$C(20,2,35,0,0,0,0,0,0,0)_"01TScreen Header Name (CTRL/P option):"
	S VO(51)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(52)=$C(21,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fCUVAR)	; Display screen data
	 S:'$D(vobj(fCUVAR,"CONAM")) vobj(fCUVAR,"CONAM")=$S(vobj(fCUVAR,-2):$G(^CUVAR("CONAM")),1:"")
	 S:'$D(vobj(fCUVAR,"USERNAME")) vobj(fCUVAR,"USERNAME")=$S(vobj(fCUVAR,-2):$G(^CUVAR("USERNAME")),1:"")
	 S:'$D(vobj(fCUVAR,"LOGINMSG")) vobj(fCUVAR,"LOGINMSG")=$S(vobj(fCUVAR,-2):$G(^CUVAR("LOGINMSG")),1:"")
	 S:'$D(vobj(fCUVAR,"DRVMSG")) vobj(fCUVAR,"DRVMSG")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DRVMSG")),1:"")
	 S:'$D(vobj(fCUVAR,"ALCOUNT")) vobj(fCUVAR,"ALCOUNT")=$S(vobj(fCUVAR,-2):$G(^CUVAR("ALCOUNT")),1:"")
	 S:'$D(vobj(fCUVAR,"BANNER")) vobj(fCUVAR,"BANNER")=$S(vobj(fCUVAR,-2):$G(^CUVAR("BANNER")),1:"")
	 S:'$D(vobj(fCUVAR,"DBS")) vobj(fCUVAR,"DBS")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DBS")),1:"")
	N V
	I %O=5 N ZMSKOPT
	I   S (ZMSKOPT)=""
	E  S ZMSKOPT=$get(ZMSKOPT)
	;
	S ZMSKOPT=$get(ZMSKOPT)
	;
	S VO="66|53|13|"
	S VO(53)=$C(2,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($get(%FN)))
	S VO(54)=$C(4,30,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"CONAM"),$C(124),1)),1,40)
	S VO(55)=$C(6,33,7,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"USERNAME"),$C(124),1)),1,7)
	S VO(56)=$C(6,67,10,2,0,0,0,0,0,0)_"00T"_$get(ZMSKOPT)
	S VO(57)=$C(8,20,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"LOGINMSG"),$C(124),1)),1,60)
	S VO(58)=$C(9,20,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"LOGINMSG"),$C(124),2)),1,60)
	S VO(59)=$C(10,20,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"LOGINMSG"),$C(124),3)),1,60)
	S VO(60)=$C(12,2,78,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"DRVMSG"),$C(124),1)),1,78)
	S VO(61)=$C(14,38,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)
	S VO(62)=$C(15,38,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fCUVAR,"BANNER"),$C(124),1):"Y",1:"N")
	S VO(63)=$C(16,38,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fCUVAR,"DBS"),$C(124),1):"Y",1:"N")
	S VO(64)=$C(17,38,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"DBS"),$C(124),2)),1,40)
	S VO(65)=$C(18,38,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"DBS"),$C(124),3)),1,40)
	S VO(66)=$C(20,38,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"DBS"),$C(124),5)),1,12)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fCUVAR)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=13 S VPT=1 S VPB=21 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="CUVAR"
	S OLNTB=21001
	;
	S VFSN("CUVAR")="zfCUVAR"
	;
	;
	S %TAB(1)=$C(3,29,40)_"01T12401|1|[CUVAR]CONAM"
	S %TAB(2)=$C(5,32,7)_"00T12401|1|[CUVAR]USERNAME"
	S %TAB(3)=$C(5,66,10)_"01T|*ZMSKOPT|[*]@ZMSKOPT|^DBCTL(""SYS"",""*RFMT"","
	S %TAB(4)=$C(7,19,60)_"00T12401|1|[CUVAR]LOGINMSG1"
	S %TAB(5)=$C(8,19,60)_"00T12402|1|[CUVAR]LOGINMSG2"
	S %TAB(6)=$C(9,19,60)_"00T12403|1|[CUVAR]LOGINMSG3"
	S %TAB(7)=$C(11,1,78)_"00T12401|1|[CUVAR]DRVMSG"
	S %TAB(8)=$C(13,37,2)_"00N12401|1|[CUVAR]ALCOUNT|||||1|20"
	S %TAB(9)=$C(14,37,1)_"00L12401|1|[CUVAR]BANNER"
	S %TAB(10)=$C(15,37,1)_"00L12401|1|[CUVAR]FLDOVF"
	S %TAB(11)=$C(16,37,40)_"00T12402|1|[CUVAR]DBSPH80"
	S %TAB(12)=$C(17,37,40)_"00T12403|1|[CUVAR]DBSPH132"
	S %TAB(13)=$C(19,37,12)_"00T12405|1|[CUVAR]DBSHDR|[DBTBL2]"
	D VTBL(.fCUVAR)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fCUVAR)	;Create %TAB(array)
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fCUVAR)
	D VDA1(.fCUVAR)
	D ^DBSPNT()
	Q 
	;
VW(fCUVAR)	;
	D VDA1(.fCUVAR)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fCUVAR)	;
	D VDA1(.fCUVAR)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fCUVAR)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="CUVAR" D vSET1(.fCUVAR,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fCUVAR,di,X)	;
	D vCoInd1(fCUVAR,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="CUVAR" Q $$vREAD1(.fCUVAR,di)
	Q ""
vREAD1(fCUVAR,di)	;
	Q $$vCoInd2(fCUVAR,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordCUVAR.set%ATM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%ATM"),"|",1)
	S $P(vobj(vRec,"%ATM"),"|",1)=vVal S vobj(vRec,-100,"%ATM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordCUVAR.set%BWPCT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%BWPCT"),"|",1)
	S $P(vobj(vRec,"%BWPCT"),"|",1)=vVal S vobj(vRec,-100,"%BWPCT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordCUVAR.set%CC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CC"),"|",1)
	S $P(vobj(vRec,"%CC"),"|",1)=vVal S vobj(vRec,-100,"%CC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordCUVAR.set%CRCD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",1)
	S $P(vobj(vRec,"%CRCD"),"|",1)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordCUVAR.set%ET(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%ET"),"|",1)
	S $P(vobj(vRec,"%ET"),"|",1)=vVal S vobj(vRec,-100,"%ET")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordCUVAR.set%HELP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%HELP"),"|",1)
	S $P(vobj(vRec,"%HELP"),"|",1)=vVal S vobj(vRec,-100,"%HELP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordCUVAR.set%HELPCNT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%HELP"),"|",2)
	S $P(vobj(vRec,"%HELP"),"|",2)=vVal S vobj(vRec,-100,"%HELP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordCUVAR.set%KEYS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%KEYS"),"|",1)
	S $P(vobj(vRec,"%KEYS"),"|",1)=vVal S vobj(vRec,-100,"%KEYS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordCUVAR.set%LIBS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%LIBS"),"|",1)
	S $P(vobj(vRec,"%LIBS"),"|",1)=vVal S vobj(vRec,-100,"%LIBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordCUVAR.set%MCP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%MCP"),"|",1)
	S $P(vobj(vRec,"%MCP"),"|",1)=vVal S vobj(vRec,-100,"%MCP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordCUVAR.set%TO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%TO"),"|",1)
	S $P(vobj(vRec,"%TO"),"|",1)=vVal S vobj(vRec,-100,"%TO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordCUVAR.set%TOHALT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%TOHALT"),"|",1)
	S $P(vobj(vRec,"%TOHALT"),"|",1)=vVal S vobj(vRec,-100,"%TOHALT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordCUVAR.set%VN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%VN"),"|",1)
	S $P(vobj(vRec,"%VN"),"|",1)=vVal S vobj(vRec,-100,"%VN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordCUVAR.setAAF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",3)
	S $P(vobj(vRec,"LN"),"|",3)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordCUVAR.setAALD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",2)
	S $P(vobj(vRec,"LN"),"|",2)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordCUVAR.setAAND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",1)
	S $P(vobj(vRec,"LN"),"|",1)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordCUVAR.setACNMRPC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ACNMRPC"),"|",1)
	S $P(vobj(vRec,"ACNMRPC"),"|",1)=vVal S vobj(vRec,-100,"ACNMRPC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordCUVAR.setADRSCR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADSCR"),"|",1)
	S $P(vobj(vRec,"ADSCR"),"|",1)=vVal S vobj(vRec,-100,"ADSCR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordCUVAR.setADRSCRI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADSCR"),"|",3)
	S $P(vobj(vRec,"ADSCR"),"|",3)=vVal S vobj(vRec,-100,"ADSCR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordCUVAR.setADRSCRM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADSCR"),"|",2)
	S $P(vobj(vRec,"ADSCR"),"|",2)=vVal S vobj(vRec,-100,"ADSCR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordCUVAR.setAGE1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"AGEMS"),"|",34)
	S $P(vobj(vRec,"AGEMS"),"|",34)=vVal S vobj(vRec,-100,"AGEMS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS22(vRec,vVal)	; RecordCUVAR.setAGE2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"AGEMS"),"|",35)
	S $P(vobj(vRec,"AGEMS"),"|",35)=vVal S vobj(vRec,-100,"AGEMS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS23(vRec,vVal)	; RecordCUVAR.setAGE3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"AGEMS"),"|",36)
	S $P(vobj(vRec,"AGEMS"),"|",36)=vVal S vobj(vRec,-100,"AGEMS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS24(vRec,vVal)	; RecordCUVAR.setAGE4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"AGEMS"),"|",37)
	S $P(vobj(vRec,"AGEMS"),"|",37)=vVal S vobj(vRec,-100,"AGEMS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS25(vRec,vVal)	; RecordCUVAR.setALCOUNT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ALCOUNT"),"|",1)
	S $P(vobj(vRec,"ALCOUNT"),"|",1)=vVal S vobj(vRec,-100,"ALCOUNT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS26(vRec,vVal)	; RecordCUVAR.setALPHI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ALP"),"|",1)
	S $P(vobj(vRec,"ALP"),"|",1)=vVal S vobj(vRec,-100,"ALP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS27(vRec,vVal)	; RecordCUVAR.setANAOFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ANAOFF"),"|",1)
	S $P(vobj(vRec,"ANAOFF"),"|",1)=vVal S vobj(vRec,-100,"ANAOFF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS28(vRec,vVal)	; RecordCUVAR.setAROFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",6)
	S $P(vobj(vRec,"DAYEND"),"|",6)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS29(vRec,vVal)	; RecordCUVAR.setATMOPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",10)
	S $P(vobj(vRec,"DEP"),"|",10)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS30(vRec,vVal)	; RecordCUVAR.setAUTOAUTH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"AUTOAUTH"),"|",1)
	S $P(vobj(vRec,"AUTOAUTH"),"|",1)=vVal S vobj(vRec,-100,"AUTOAUTH")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS31(vRec,vVal)	; RecordCUVAR.setBALCCLC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",20)
	S $P(vobj(vRec,"DEP"),"|",20)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS32(vRec,vVal)	; RecordCUVAR.setBALCLGC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",19)
	S $P(vobj(vRec,"DEP"),"|",19)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS33(vRec,vVal)	; RecordCUVAR.setBAMTMOD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",13)
	S $P(vobj(vRec,"%CRCD"),"|",13)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS34(vRec,vVal)	; RecordCUVAR.setBANNER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BANNER"),"|",1)
	S $P(vobj(vRec,"BANNER"),"|",1)=vVal S vobj(vRec,-100,"BANNER")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS35(vRec,vVal)	; RecordCUVAR.setBATRESTART(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%BATCH"),"|",1)
	S $P(vobj(vRec,"%BATCH"),"|",1)=vVal S vobj(vRec,-100,"%BATCH")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS36(vRec,vVal)	; RecordCUVAR.setBINDEF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BINDEF"),"|",1)
	S $P(vobj(vRec,"BINDEF"),"|",1)=vVal S vobj(vRec,-100,"BINDEF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS37(vRec,vVal)	; RecordCUVAR.setBOBR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BOBR"),"|",1)
	S $P(vobj(vRec,"BOBR"),"|",1)=vVal S vobj(vRec,-100,"BOBR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS38(vRec,vVal)	; RecordCUVAR.setBORIG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ACHORIG"),"|",3)
	S $P(vobj(vRec,"ACHORIG"),"|",3)=vVal S vobj(vRec,-100,"ACHORIG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS39(vRec,vVal)	; RecordCUVAR.setBRKNBDC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INV"),"|",1)
	S $P(vobj(vRec,"INV"),"|",1)=vVal S vobj(vRec,-100,"INV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS40(vRec,vVal)	; RecordCUVAR.setBSA(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BSA"),"|",1)
	S $P(vobj(vRec,"BSA"),"|",1)=vVal S vobj(vRec,-100,"BSA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS41(vRec,vVal)	; RecordCUVAR.setBSEMOD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",11)
	S $P(vobj(vRec,"%CRCD"),"|",11)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS42(vRec,vVal)	; RecordCUVAR.setBTTJOB(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BTTJOB"),"|",1)
	S $P(vobj(vRec,"BTTJOB"),"|",1)=vVal S vobj(vRec,-100,"BTTJOB")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS43(vRec,vVal)	; RecordCUVAR.setBWAPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BWAPGM"),"|",1)
	S $P(vobj(vRec,"BWAPGM"),"|",1)=vVal S vobj(vRec,-100,"BWAPGM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS44(vRec,vVal)	; RecordCUVAR.setBWO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"BWO"),"|",1)
	S $P(vobj(vRec,"BWO"),"|",1)=vVal S vobj(vRec,-100,"BWO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS45(vRec,vVal)	; RecordCUVAR.setCAC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",14)
	S $P(vobj(vRec,1099),"|",14)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS46(vRec,vVal)	; RecordCUVAR.setCAD1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",4)
	S $P(vobj(vRec,"ADDR"),"|",4)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS47(vRec,vVal)	; RecordCUVAR.setCAD2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",5)
	S $P(vobj(vRec,"ADDR"),"|",5)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS48(vRec,vVal)	; RecordCUVAR.setCAD3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",6)
	S $P(vobj(vRec,"ADDR"),"|",6)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS49(vRec,vVal)	; RecordCUVAR.setCATSUP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CNTRY"),"|",2)
	S $P(vobj(vRec,"CNTRY"),"|",2)=vVal S vobj(vRec,-100,"CNTRY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS50(vRec,vVal)	; RecordCUVAR.setCCITY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",1)
	S $P(vobj(vRec,"ADDR"),"|",1)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS51(vRec,vVal)	; RecordCUVAR.setCCMOD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",12)
	S $P(vobj(vRec,"%CRCD"),"|",12)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS52(vRec,vVal)	; RecordCUVAR.setCCNTRY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",8)
	S $P(vobj(vRec,"ADDR"),"|",8)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS53(vRec,vVal)	; RecordCUVAR.setCECR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",3)
	S $P(vobj(vRec,"%CRCD"),"|",3)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS54(vRec,vVal)	; RecordCUVAR.setCEDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",2)
	S $P(vobj(vRec,"%CRCD"),"|",2)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS55(vRec,vVal)	; RecordCUVAR.setCEMAIL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",17)
	S $P(vobj(vRec,1099),"|",17)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS56(vRec,vVal)	; RecordCUVAR.setCERTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",6)
	S $P(vobj(vRec,"%CRCD"),"|",6)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS57(vRec,vVal)	; RecordCUVAR.setCHKHLDRTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CHKHLDRTN"),"|",1)
	S $P(vobj(vRec,"CHKHLDRTN"),"|",1)=vVal S vobj(vRec,-100,"CHKHLDRTN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS58(vRec,vVal)	; RecordCUVAR.setCHKIMG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CHK"),"|",1)
	S $P(vobj(vRec,"CHK"),"|",1)=vVal S vobj(vRec,-100,"CHK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS59(vRec,vVal)	; RecordCUVAR.setCHKPNT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CHKPNT"),"|",1)
	S $P(vobj(vRec,"CHKPNT"),"|",1)=vVal S vobj(vRec,-100,"CHKPNT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS60(vRec,vVal)	; RecordCUVAR.setCIDBLK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIDBLK"),"|",1)
	S $P(vobj(vRec,"CIDBLK"),"|",1)=vVal S vobj(vRec,-100,"CIDBLK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS61(vRec,vVal)	; RecordCUVAR.setCIDLOWLM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIDLOWLM"),"|",1)
	S $P(vobj(vRec,"CIDLOWLM"),"|",1)=vVal S vobj(vRec,-100,"CIDLOWLM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS62(vRec,vVal)	; RecordCUVAR.setCIFALLOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",13)
	S $P(vobj(vRec,"CIF"),"|",13)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS63(vRec,vVal)	; RecordCUVAR.setCIFEXTI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"MFUND"),"|",5)
	S $P(vobj(vRec,"MFUND"),"|",5)=vVal S vobj(vRec,-100,"MFUND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS64(vRec,vVal)	; RecordCUVAR.setCIFMRPC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIFMRPC"),"|",1)
	S $P(vobj(vRec,"CIFMRPC"),"|",1)=vVal S vobj(vRec,-100,"CIFMRPC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS65(vRec,vVal)	; RecordCUVAR.setCIFPRGD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",4)
	S $P(vobj(vRec,"CIF"),"|",4)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS66(vRec,vVal)	; RecordCUVAR.setCIFVER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIFVER"),"|",1)
	S $P(vobj(vRec,"CIFVER"),"|",1)=vVal S vobj(vRec,-100,"CIFVER")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS67(vRec,vVal)	; RecordCUVAR.setCMSACOPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",17)
	S $P(vobj(vRec,"DEP"),"|",17)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS68(vRec,vVal)	; RecordCUVAR.setCMSAVALR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",18)
	S $P(vobj(vRec,"DEP"),"|",18)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS69(vRec,vVal)	; RecordCUVAR.setCNAME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",7)
	S $P(vobj(vRec,"ADDR"),"|",7)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS70(vRec,vVal)	; RecordCUVAR.setCNFRMHIS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SWIFT"),"|",2)
	S $P(vobj(vRec,"SWIFT"),"|",2)=vVal S vobj(vRec,-100,"SWIFT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS71(vRec,vVal)	; RecordCUVAR.setCNTRY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CNTRY"),"|",1)
	S $P(vobj(vRec,"CNTRY"),"|",1)=vVal S vobj(vRec,-100,"CNTRY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS72(vRec,vVal)	; RecordCUVAR.setCO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CO"),"|",1)
	S $P(vobj(vRec,"CO"),"|",1)=vVal S vobj(vRec,-100,"CO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS73(vRec,vVal)	; RecordCUVAR.setCONAM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CONAM"),"|",1)
	S $P(vobj(vRec,"CONAM"),"|",1)=vVal S vobj(vRec,-100,"CONAM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS74(vRec,vVal)	; RecordCUVAR.setCONTACT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",13)
	S $P(vobj(vRec,1099),"|",13)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS75(vRec,vVal)	; RecordCUVAR.setCONTRA(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",38)
	S $P(vobj(vRec,"LN"),"|",38)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS76(vRec,vVal)	; RecordCUVAR.setCORPID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",16)
	S $P(vobj(vRec,1099),"|",16)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS77(vRec,vVal)	; RecordCUVAR.setCOURTMSG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"COURTMSG"),"|",1)
	S $P(vobj(vRec,"COURTMSG"),"|",1)=vVal S vobj(vRec,-100,"COURTMSG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS78(vRec,vVal)	; RecordCUVAR.setCPRTLN1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"COPY"),"|",1)
	S $P(vobj(vRec,"COPY"),"|",1)=vVal S vobj(vRec,-100,"COPY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS79(vRec,vVal)	; RecordCUVAR.setCPRTLN2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"COPY"),"|",2)
	S $P(vobj(vRec,"COPY"),"|",2)=vVal S vobj(vRec,-100,"COPY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS80(vRec,vVal)	; RecordCUVAR.setCPRTLN3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"COPY"),"|",3)
	S $P(vobj(vRec,"COPY"),"|",3)=vVal S vobj(vRec,-100,"COPY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS81(vRec,vVal)	; RecordCUVAR.setCPRTLN4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"COPY"),"|",4)
	S $P(vobj(vRec,"COPY"),"|",4)=vVal S vobj(vRec,-100,"COPY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS82(vRec,vVal)	; RecordCUVAR.setCRCDTHR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRCDTHR"),"|",1)
	S $P(vobj(vRec,"CRCDTHR"),"|",1)=vVal S vobj(vRec,-100,"CRCDTHR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS83(vRec,vVal)	; RecordCUVAR.setCRCTRL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",3)
	S $P(vobj(vRec,"CRTRW"),"|",3)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS84(vRec,vVal)	; RecordCUVAR.setCRID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",5)
	S $P(vobj(vRec,"CRTRW"),"|",5)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS85(vRec,vVal)	; RecordCUVAR.setCRLRD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",6)
	S $P(vobj(vRec,"CRTRW"),"|",6)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS86(vRec,vVal)	; RecordCUVAR.setCRNTAP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",1)
	S $P(vobj(vRec,"CRTRW"),"|",1)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS87(vRec,vVal)	; RecordCUVAR.setCRREP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",7)
	S $P(vobj(vRec,"CRTRW"),"|",7)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS88(vRec,vVal)	; RecordCUVAR.setCRSHRT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",2)
	S $P(vobj(vRec,"CRTRW"),"|",2)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS89(vRec,vVal)	; RecordCUVAR.setCRSTUD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTRW"),"|",4)
	S $P(vobj(vRec,"CRTRW"),"|",4)=vVal S vobj(vRec,-100,"CRTRW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS90(vRec,vVal)	; RecordCUVAR.setCRTDSP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTDSP"),"|",1)
	S $P(vobj(vRec,"CRTDSP"),"|",1)=vVal S vobj(vRec,-100,"CRTDSP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS91(vRec,vVal)	; RecordCUVAR.setCRTMSGD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTMSGD"),"|",1)
	S $P(vobj(vRec,"CRTMSGD"),"|",1)=vVal S vobj(vRec,-100,"CRTMSGD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS92(vRec,vVal)	; RecordCUVAR.setCRTMSGL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRTMSGL"),"|",1)
	S $P(vobj(vRec,"CRTMSGL"),"|",1)=vVal S vobj(vRec,-100,"CRTMSGL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS93(vRec,vVal)	; RecordCUVAR.setCSTATE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",2)
	S $P(vobj(vRec,"ADDR"),"|",2)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS94(vRec,vVal)	; RecordCUVAR.setCSTFMTRTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CSTFMTRTN"),"|",1)
	S $P(vobj(vRec,"CSTFMTRTN"),"|",1)=vVal S vobj(vRec,-100,"CSTFMTRTN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS95(vRec,vVal)	; RecordCUVAR.setCTELE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",15)
	S $P(vobj(vRec,1099),"|",15)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS96(vRec,vVal)	; RecordCUVAR.setCTOF1098(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",8)
	S $P(vobj(vRec,1099),"|",8)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS97(vRec,vVal)	; RecordCUVAR.setCTOF1099(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",9)
	S $P(vobj(vRec,1099),"|",9)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS98(vRec,vVal)	; RecordCUVAR.setCURRENV(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CURRENV"),"|",1)
	S $P(vobj(vRec,"CURRENV"),"|",1)=vVal S vobj(vRec,-100,"CURRENV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS99(vRec,vVal)	; RecordCUVAR.setCVSCR1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCNV"),"|",1)
	S $P(vobj(vRec,"LNCNV"),"|",1)=vVal S vobj(vRec,-100,"LNCNV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAA(vRec,vVal)	; RecordCUVAR.setCVSCR2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCNV"),"|",2)
	S $P(vobj(vRec,"LNCNV"),"|",2)=vVal S vobj(vRec,-100,"LNCNV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAB(vRec,vVal)	; RecordCUVAR.setCZIP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",3)
	S $P(vobj(vRec,"ADDR"),"|",3)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAC(vRec,vVal)	; RecordCUVAR.setDARCDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",28)
	S $P(vobj(vRec,"LN"),"|",28)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAD(vRec,vVal)	; RecordCUVAR.setDARCDFLG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",31)
	S $P(vobj(vRec,"LN"),"|",31)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAE(vRec,vVal)	; RecordCUVAR.setDARCFREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",24)
	S $P(vobj(vRec,"LN"),"|",24)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAF(vRec,vVal)	; RecordCUVAR.setDARCLPDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",27)
	S $P(vobj(vRec,"LN"),"|",27)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAG(vRec,vVal)	; RecordCUVAR.setDARCNPDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",25)
	S $P(vobj(vRec,"LN"),"|",25)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAH(vRec,vVal)	; RecordCUVAR.setDARCOFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",26)
	S $P(vobj(vRec,"LN"),"|",26)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAI(vRec,vVal)	; RecordCUVAR.setDAYEND2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",2)
	S $P(vobj(vRec,"DAYEND"),"|",2)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAJ(vRec,vVal)	; RecordCUVAR.setDAYEND4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",4)
	S $P(vobj(vRec,"DAYEND"),"|",4)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAK(vRec,vVal)	; RecordCUVAR.setDAYEND5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",5)
	S $P(vobj(vRec,"DAYEND"),"|",5)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAL(vRec,vVal)	; RecordCUVAR.setDBIMBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INS"),"|",3)
	S $P(vobj(vRec,"INS"),"|",3)=vVal S vobj(vRec,-100,"INS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAM(vRec,vVal)	; RecordCUVAR.setDBSHDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",5)
	S $P(vobj(vRec,"DBS"),"|",5)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAN(vRec,vVal)	; RecordCUVAR.setDBSLIST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",4)
	S $P(vobj(vRec,"DBS"),"|",4)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAO(vRec,vVal)	; RecordCUVAR.setDBSLSTEXP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBSLSTEXP"),"|",1)
	S $P(vobj(vRec,"DBSLSTEXP"),"|",1)=vVal S vobj(vRec,-100,"DBSLSTEXP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAP(vRec,vVal)	; RecordCUVAR.setDBSPH132(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",3)
	S $P(vobj(vRec,"DBS"),"|",3)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAQ(vRec,vVal)	; RecordCUVAR.setDBSPH80(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",2)
	S $P(vobj(vRec,"DBS"),"|",2)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAR(vRec,vVal)	; RecordCUVAR.setDCCRCD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",8)
	S $P(vobj(vRec,"CRT"),"|",8)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAS(vRec,vVal)	; RecordCUVAR.setDCL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INS"),"|",1)
	S $P(vobj(vRec,"INS"),"|",1)=vVal S vobj(vRec,-100,"INS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAT(vRec,vVal)	; RecordCUVAR.setDDPACND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INQBAL"),"|",3)
	S $P(vobj(vRec,"INQBAL"),"|",3)=vVal S vobj(vRec,-100,"INQBAL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAU(vRec,vVal)	; RecordCUVAR.setDDPACNL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INQBAL"),"|",4)
	S $P(vobj(vRec,"INQBAL"),"|",4)=vVal S vobj(vRec,-100,"INQBAL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAV(vRec,vVal)	; RecordCUVAR.setDEALPURG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEAL"),"|",2)
	S $P(vobj(vRec,"DEAL"),"|",2)=vVal S vobj(vRec,-100,"DEAL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAW(vRec,vVal)	; RecordCUVAR.setDEBAUT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",16)
	S $P(vobj(vRec,"EFTPAY"),"|",16)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAX(vRec,vVal)	; RecordCUVAR.setDEFDREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",14)
	S $P(vobj(vRec,"CIF"),"|",14)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAY(vRec,vVal)	; RecordCUVAR.setDEFLREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",15)
	S $P(vobj(vRec,"CIF"),"|",15)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSAZ(vRec,vVal)	; RecordCUVAR.setDELDIS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELDIS"),"|",1)
	S $P(vobj(vRec,"DELDIS"),"|",1)=vVal S vobj(vRec,-100,"DELDIS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBA(vRec,vVal)	; RecordCUVAR.setDENFLG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DENFLG"),"|",1)
	S $P(vobj(vRec,"DENFLG"),"|",1)=vVal S vobj(vRec,-100,"DENFLG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBB(vRec,vVal)	; RecordCUVAR.setDEPVER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEPVER"),"|",1)
	S $P(vobj(vRec,"DEPVER"),"|",1)=vVal S vobj(vRec,-100,"DEPVER")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBC(vRec,vVal)	; RecordCUVAR.setDEVIO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%IO"),"|",1)
	S $P(vobj(vRec,"%IO"),"|",1)=vVal S vobj(vRec,-100,"%IO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBD(vRec,vVal)	; RecordCUVAR.setDEVPTR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%IO"),"|",2)
	S $P(vobj(vRec,"%IO"),"|",2)=vVal S vobj(vRec,-100,"%IO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBE(vRec,vVal)	; RecordCUVAR.setDFTCHTRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",4)
	S $P(vobj(vRec,"CRT"),"|",4)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBF(vRec,vVal)	; RecordCUVAR.setDFTCI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",5)
	S $P(vobj(vRec,"CRT"),"|",5)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBG(vRec,vVal)	; RecordCUVAR.setDFTCKTRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",3)
	S $P(vobj(vRec,"CRT"),"|",3)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBH(vRec,vVal)	; RecordCUVAR.setDFTCO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",6)
	S $P(vobj(vRec,"CRT"),"|",6)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBI(vRec,vVal)	; RecordCUVAR.setDFTENV(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DFTENV"),"|",1)
	S $P(vobj(vRec,"DFTENV"),"|",1)=vVal S vobj(vRec,-100,"DFTENV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBJ(vRec,vVal)	; RecordCUVAR.setDFTSPVUCLS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",1)
	S $P(vobj(vRec,"CRT"),"|",1)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBK(vRec,vVal)	; RecordCUVAR.setDFTSTFUCLS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",2)
	S $P(vobj(vRec,"CRT"),"|",2)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBL(vRec,vVal)	; RecordCUVAR.setDFTTHRC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",6)
	S $P(vobj(vRec,"EUR"),"|",6)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBM(vRec,vVal)	; RecordCUVAR.setDFTTHRR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",7)
	S $P(vobj(vRec,"EUR"),"|",7)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBN(vRec,vVal)	; RecordCUVAR.setDIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",7)
	S $P(vobj(vRec,"DRMT"),"|",7)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBO(vRec,vVal)	; RecordCUVAR.setDISBRST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",22)
	S $P(vobj(vRec,"CIF"),"|",22)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBP(vRec,vVal)	; RecordCUVAR.setDISTNAM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SYSDRV"),"|",2)
	S $P(vobj(vRec,"SYSDRV"),"|",2)=vVal S vobj(vRec,-100,"SYSDRV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBQ(vRec,vVal)	; RecordCUVAR.setDLQNT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",4)
	S $P(vobj(vRec,"LN"),"|",4)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBR(vRec,vVal)	; RecordCUVAR.setDODRST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",21)
	S $P(vobj(vRec,"CIF"),"|",21)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBS(vRec,vVal)	; RecordCUVAR.setDPREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PRELID"),"|",2)
	S $P(vobj(vRec,"PRELID"),"|",2)=vVal S vobj(vRec,-100,"PRELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBT(vRec,vVal)	; RecordCUVAR.setDRC1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",6)
	S $P(vobj(vRec,"DELQ"),"|",6)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBU(vRec,vVal)	; RecordCUVAR.setDRC10(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",15)
	S $P(vobj(vRec,"DELQ"),"|",15)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBV(vRec,vVal)	; RecordCUVAR.setDRC11(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",16)
	S $P(vobj(vRec,"DELQ"),"|",16)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBW(vRec,vVal)	; RecordCUVAR.setDRC12(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",17)
	S $P(vobj(vRec,"DELQ"),"|",17)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBX(vRec,vVal)	; RecordCUVAR.setDRC13(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",18)
	S $P(vobj(vRec,"DELQ"),"|",18)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBY(vRec,vVal)	; RecordCUVAR.setDRC14(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",19)
	S $P(vobj(vRec,"DELQ"),"|",19)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSBZ(vRec,vVal)	; RecordCUVAR.setDRC15(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",20)
	S $P(vobj(vRec,"DELQ"),"|",20)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCA(vRec,vVal)	; RecordCUVAR.setDRC16(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",21)
	S $P(vobj(vRec,"DELQ"),"|",21)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCB(vRec,vVal)	; RecordCUVAR.setDRC17(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",22)
	S $P(vobj(vRec,"DELQ"),"|",22)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCC(vRec,vVal)	; RecordCUVAR.setDRC18(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",23)
	S $P(vobj(vRec,"DELQ"),"|",23)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCD(vRec,vVal)	; RecordCUVAR.setDRC19(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",24)
	S $P(vobj(vRec,"DELQ"),"|",24)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCE(vRec,vVal)	; RecordCUVAR.setDRC2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",7)
	S $P(vobj(vRec,"DELQ"),"|",7)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCF(vRec,vVal)	; RecordCUVAR.setDRC20(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",25)
	S $P(vobj(vRec,"DELQ"),"|",25)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCG(vRec,vVal)	; RecordCUVAR.setDRC3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",8)
	S $P(vobj(vRec,"DELQ"),"|",8)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCH(vRec,vVal)	; RecordCUVAR.setDRC4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",9)
	S $P(vobj(vRec,"DELQ"),"|",9)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCI(vRec,vVal)	; RecordCUVAR.setDRC5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",10)
	S $P(vobj(vRec,"DELQ"),"|",10)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCJ(vRec,vVal)	; RecordCUVAR.setDRC6(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",11)
	S $P(vobj(vRec,"DELQ"),"|",11)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCK(vRec,vVal)	; RecordCUVAR.setDRC7(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",12)
	S $P(vobj(vRec,"DELQ"),"|",12)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCL(vRec,vVal)	; RecordCUVAR.setDRC8(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",13)
	S $P(vobj(vRec,"DELQ"),"|",13)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCM(vRec,vVal)	; RecordCUVAR.setDRC9(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",14)
	S $P(vobj(vRec,"DELQ"),"|",14)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCN(vRec,vVal)	; RecordCUVAR.setDREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RELID"),"|",2)
	S $P(vobj(vRec,"RELID"),"|",2)=vVal S vobj(vRec,-100,"RELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCO(vRec,vVal)	; RecordCUVAR.setDRMT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",1)
	S $P(vobj(vRec,"DRMT"),"|",1)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCP(vRec,vVal)	; RecordCUVAR.setDRVMSG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRVMSG"),"|",1)
	S $P(vobj(vRec,"DRVMSG"),"|",1)=vVal S vobj(vRec,-100,"DRVMSG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCQ(vRec,vVal)	; RecordCUVAR.setDUPTIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",23)
	S $P(vobj(vRec,"CIF"),"|",23)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCR(vRec,vVal)	; RecordCUVAR.setEADHS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ESCROW"),"|",4)
	S $P(vobj(vRec,"ESCROW"),"|",4)=vVal S vobj(vRec,-100,"ESCROW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCS(vRec,vVal)	; RecordCUVAR.setEAPPS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ESCROW"),"|",2)
	S $P(vobj(vRec,"ESCROW"),"|",2)=vVal S vobj(vRec,-100,"ESCROW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCT(vRec,vVal)	; RecordCUVAR.setEAPS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ESCROW"),"|",1)
	S $P(vobj(vRec,"ESCROW"),"|",1)=vVal S vobj(vRec,-100,"ESCROW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCU(vRec,vVal)	; RecordCUVAR.setEDITMASK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",6)
	S $P(vobj(vRec,"DBS"),"|",6)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCV(vRec,vVal)	; RecordCUVAR.setEFD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFD"),"|",1)
	S $P(vobj(vRec,"EFD"),"|",1)=vVal S vobj(vRec,-100,"EFD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCW(vRec,vVal)	; RecordCUVAR.setEFDFTFLG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFD"),"|",2)
	S $P(vobj(vRec,"EFD"),"|",2)=vVal S vobj(vRec,-100,"EFD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCX(vRec,vVal)	; RecordCUVAR.setEFTARCDIR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",14)
	S $P(vobj(vRec,"EFTPAY"),"|",14)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCY(vRec,vVal)	; RecordCUVAR.setEFTCCIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",12)
	S $P(vobj(vRec,"EFTPAY"),"|",12)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSCZ(vRec,vVal)	; RecordCUVAR.setEFTCCOUT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",13)
	S $P(vobj(vRec,"EFTPAY"),"|",13)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDA(vRec,vVal)	; RecordCUVAR.setEFTCOM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",8)
	S $P(vobj(vRec,"EFTPAY"),"|",8)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDB(vRec,vVal)	; RecordCUVAR.setEFTDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",7)
	S $P(vobj(vRec,"EFTPAY"),"|",7)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDC(vRec,vVal)	; RecordCUVAR.setEFTMEMO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",19)
	S $P(vobj(vRec,"EFTPAY"),"|",19)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDD(vRec,vVal)	; RecordCUVAR.setEFTREFNO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",15)
	S $P(vobj(vRec,"EFTPAY"),"|",15)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDE(vRec,vVal)	; RecordCUVAR.setEFTREJ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",10)
	S $P(vobj(vRec,"EFTPAY"),"|",10)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDF(vRec,vVal)	; RecordCUVAR.setEFTRICO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",11)
	S $P(vobj(vRec,"EFTPAY"),"|",11)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDG(vRec,vVal)	; RecordCUVAR.setEFTSUP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",20)
	S $P(vobj(vRec,"EFTPAY"),"|",20)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDH(vRec,vVal)	; RecordCUVAR.setEHDS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ESCROW"),"|",3)
	S $P(vobj(vRec,"ESCROW"),"|",3)=vVal S vobj(vRec,-100,"ESCROW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDI(vRec,vVal)	; RecordCUVAR.setEIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EIN"),"|",1)
	S $P(vobj(vRec,"EIN"),"|",1)=vVal S vobj(vRec,-100,"EIN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDJ(vRec,vVal)	; RecordCUVAR.setEMU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",1)
	S $P(vobj(vRec,"EUR"),"|",1)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDK(vRec,vVal)	; RecordCUVAR.setEMUCRCD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",16)
	S $P(vobj(vRec,"EUR"),"|",16)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDL(vRec,vVal)	; RecordCUVAR.setEMURND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",17)
	S $P(vobj(vRec,"EUR"),"|",17)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDM(vRec,vVal)	; RecordCUVAR.setERBRES1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ERBRES"),"|",1)
	S $P(vobj(vRec,"ERBRES"),"|",1)=vVal S vobj(vRec,-100,"ERBRES")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDN(vRec,vVal)	; RecordCUVAR.setERBRES2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ERBRES"),"|",2)
	S $P(vobj(vRec,"ERBRES"),"|",2)=vVal S vobj(vRec,-100,"ERBRES")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDO(vRec,vVal)	; RecordCUVAR.setERBRES3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ERBRES"),"|",3)
	S $P(vobj(vRec,"ERBRES"),"|",3)=vVal S vobj(vRec,-100,"ERBRES")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDP(vRec,vVal)	; RecordCUVAR.setERRMAIL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%ET"),"|",3)
	S $P(vobj(vRec,"%ET"),"|",3)=vVal S vobj(vRec,-100,"%ET")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDQ(vRec,vVal)	; RecordCUVAR.setERRMDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%ET"),"|",2)
	S $P(vobj(vRec,"%ET"),"|",2)=vVal S vobj(vRec,-100,"%ET")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDR(vRec,vVal)	; RecordCUVAR.setESCCHK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",16)
	S $P(vobj(vRec,"LN"),"|",16)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDS(vRec,vVal)	; RecordCUVAR.setESCGL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",17)
	S $P(vobj(vRec,"LN"),"|",17)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDT(vRec,vVal)	; RecordCUVAR.setESCH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",2)
	S $P(vobj(vRec,"DRMT"),"|",2)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDU(vRec,vVal)	; RecordCUVAR.setESCHEAT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ESCHEAT"),"|",1)
	S $P(vobj(vRec,"ESCHEAT"),"|",1)=vVal S vobj(vRec,-100,"ESCHEAT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDV(vRec,vVal)	; RecordCUVAR.setEURBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",3)
	S $P(vobj(vRec,"EUR"),"|",3)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDW(vRec,vVal)	; RecordCUVAR.setEURCNVDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",13)
	S $P(vobj(vRec,"EUR"),"|",13)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDX(vRec,vVal)	; RecordCUVAR.setEURINTEG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",18)
	S $P(vobj(vRec,"EUR"),"|",18)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDY(vRec,vVal)	; RecordCUVAR.setEURRNDCR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",4)
	S $P(vobj(vRec,"EUR"),"|",4)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSDZ(vRec,vVal)	; RecordCUVAR.setEURRNDDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",5)
	S $P(vobj(vRec,"EUR"),"|",5)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEA(vRec,vVal)	; RecordCUVAR.setEXPREP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",20)
	S $P(vobj(vRec,"CIF"),"|",20)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEB(vRec,vVal)	; RecordCUVAR.setEXTREM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SWIFT"),"|",5)
	S $P(vobj(vRec,"SWIFT"),"|",5)=vVal S vobj(vRec,-100,"SWIFT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEC(vRec,vVal)	; RecordCUVAR.setEXTVAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",25)
	S $P(vobj(vRec,"CIF"),"|",25)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSED(vRec,vVal)	; RecordCUVAR.setFAILWAIT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%BATCH"),"|",2)
	S $P(vobj(vRec,"%BATCH"),"|",2)=vVal S vobj(vRec,-100,"%BATCH")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEE(vRec,vVal)	; RecordCUVAR.setFCVMEMO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"FCVMEMO"),"|",1)
	S $P(vobj(vRec,"FCVMEMO"),"|",1)=vVal S vobj(vRec,-100,"FCVMEMO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEF(vRec,vVal)	; RecordCUVAR.setFDEST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ACHORIG"),"|",2)
	S $P(vobj(vRec,"ACHORIG"),"|",2)=vVal S vobj(vRec,-100,"ACHORIG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEG(vRec,vVal)	; RecordCUVAR.setFEEICRTC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",12)
	S $P(vobj(vRec,"LN"),"|",12)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEH(vRec,vVal)	; RecordCUVAR.setFEEIDRTC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",13)
	S $P(vobj(vRec,"LN"),"|",13)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEI(vRec,vVal)	; RecordCUVAR.setFEPXALL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"FEPXALL"),"|",1)
	S $P(vobj(vRec,"FEPXALL"),"|",1)=vVal S vobj(vRec,-100,"FEPXALL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEJ(vRec,vVal)	; RecordCUVAR.setFINYE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",8)
	S $P(vobj(vRec,"DAYEND"),"|",8)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEK(vRec,vVal)	; RecordCUVAR.setFINYEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",11)
	S $P(vobj(vRec,"DAYEND"),"|",11)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEL(vRec,vVal)	; RecordCUVAR.setFLDOVF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",1)
	S $P(vobj(vRec,"DBS"),"|",1)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEM(vRec,vVal)	; RecordCUVAR.setFNCRATE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",2)
	S $P(vobj(vRec,"EUR"),"|",2)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEN(vRec,vVal)	; RecordCUVAR.setFORIG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ACHORIG"),"|",1)
	S $P(vobj(vRec,"ACHORIG"),"|",1)=vVal S vobj(vRec,-100,"ACHORIG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEO(vRec,vVal)	; RecordCUVAR.setFTPTIME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"FTPTIME"),"|",1)
	S $P(vobj(vRec,"FTPTIME"),"|",1)=vVal S vobj(vRec,-100,"FTPTIME")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEP(vRec,vVal)	; RecordCUVAR.setFUTBLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",17)
	S $P(vobj(vRec,"EFTPAY"),"|",17)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEQ(vRec,vVal)	; RecordCUVAR.setFX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",24)
	S $P(vobj(vRec,"%CRCD"),"|",24)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSER(vRec,vVal)	; RecordCUVAR.setFXLOSS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",18)
	S $P(vobj(vRec,"%CRCD"),"|",18)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSES(vRec,vVal)	; RecordCUVAR.setFXPOSL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",16)
	S $P(vobj(vRec,"%CRCD"),"|",16)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSET(vRec,vVal)	; RecordCUVAR.setFXPOSPL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",15)
	S $P(vobj(vRec,"%CRCD"),"|",15)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEU(vRec,vVal)	; RecordCUVAR.setFXPOSRT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",14)
	S $P(vobj(vRec,"%CRCD"),"|",14)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEV(vRec,vVal)	; RecordCUVAR.setFXPROFIT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",17)
	S $P(vobj(vRec,"%CRCD"),"|",17)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEW(vRec,vVal)	; RecordCUVAR.setFXRATEDF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"FXRATEDF"),"|",1)
	S $P(vobj(vRec,"FXRATEDF"),"|",1)=vVal S vobj(vRec,-100,"FXRATEDF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEX(vRec,vVal)	; RecordCUVAR.setGLCCRO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLCC"),"|",2)
	S $P(vobj(vRec,"GLCC"),"|",2)=vVal S vobj(vRec,-100,"GLCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEY(vRec,vVal)	; RecordCUVAR.setGLEFDBCH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLEFD"),"|",1)
	S $P(vobj(vRec,"GLEFD"),"|",1)=vVal S vobj(vRec,-100,"GLEFD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSEZ(vRec,vVal)	; RecordCUVAR.setGLEFDCR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLEFD"),"|",3)
	S $P(vobj(vRec,"GLEFD"),"|",3)=vVal S vobj(vRec,-100,"GLEFD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFA(vRec,vVal)	; RecordCUVAR.setGLEFDDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLEFD"),"|",2)
	S $P(vobj(vRec,"GLEFD"),"|",2)=vVal S vobj(vRec,-100,"GLEFD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFB(vRec,vVal)	; RecordCUVAR.setGLPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLSETPGM"),"|",1)
	S $P(vobj(vRec,"GLSETPGM"),"|",1)=vVal S vobj(vRec,-100,"GLSETPGM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFC(vRec,vVal)	; RecordCUVAR.setGLS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLS"),"|",1)
	S $P(vobj(vRec,"GLS"),"|",1)=vVal S vobj(vRec,-100,"GLS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFD(vRec,vVal)	; RecordCUVAR.setGLSBO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLSBO"),"|",1)
	S $P(vobj(vRec,"GLSBO"),"|",1)=vVal S vobj(vRec,-100,"GLSBO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFE(vRec,vVal)	; RecordCUVAR.setGLTS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLTS"),"|",1)
	S $P(vobj(vRec,"GLTS"),"|",1)=vVal S vobj(vRec,-100,"GLTS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFF(vRec,vVal)	; RecordCUVAR.setGLTSFP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLTSFP"),"|",1)
	S $P(vobj(vRec,"GLTSFP"),"|",1)=vVal S vobj(vRec,-100,"GLTSFP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFG(vRec,vVal)	; RecordCUVAR.setGLTSTO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLTSTO"),"|",1)
	S $P(vobj(vRec,"GLTSTO"),"|",1)=vVal S vobj(vRec,-100,"GLTSTO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFH(vRec,vVal)	; RecordCUVAR.setGLTSTS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLTSTS"),"|",1)
	S $P(vobj(vRec,"GLTSTS"),"|",1)=vVal S vobj(vRec,-100,"GLTSTS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFI(vRec,vVal)	; RecordCUVAR.setGLXFR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLXFR"),"|",1)
	S $P(vobj(vRec,"GLXFR"),"|",1)=vVal S vobj(vRec,-100,"GLXFR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFJ(vRec,vVal)	; RecordCUVAR.setGRACE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GRACE"),"|",1)
	S $P(vobj(vRec,"GRACE"),"|",1)=vVal S vobj(vRec,-100,"GRACE")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFK(vRec,vVal)	; RecordCUVAR.setHANG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"HANG"),"|",1)
	S $P(vobj(vRec,"HANG"),"|",1)=vVal S vobj(vRec,-100,"HANG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFL(vRec,vVal)	; RecordCUVAR.setHBTYPE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",26)
	S $P(vobj(vRec,"CIF"),"|",26)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFM(vRec,vVal)	; RecordCUVAR.setHISTRPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"HISTRPT"),"|",1)
	S $P(vobj(vRec,"HISTRPT"),"|",1)=vVal S vobj(vRec,-100,"HISTRPT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFN(vRec,vVal)	; RecordCUVAR.setHOTLIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"HOTLIN"),"|",1)
	S $P(vobj(vRec,"HOTLIN"),"|",1)=vVal S vobj(vRec,-100,"HOTLIN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFO(vRec,vVal)	; RecordCUVAR.setIAD1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",4)
	S $P(vobj(vRec,1099),"|",4)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFP(vRec,vVal)	; RecordCUVAR.setIAD2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",5)
	S $P(vobj(vRec,1099),"|",5)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFQ(vRec,vVal)	; RecordCUVAR.setIAD3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",6)
	S $P(vobj(vRec,1099),"|",6)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFR(vRec,vVal)	; RecordCUVAR.setIBILFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",14)
	S $P(vobj(vRec,"LN"),"|",14)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFS(vRec,vVal)	; RecordCUVAR.setICCFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",23)
	S $P(vobj(vRec,"INCK"),"|",23)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFT(vRec,vVal)	; RecordCUVAR.setICCFR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",20)
	S $P(vobj(vRec,"INCK"),"|",20)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFU(vRec,vVal)	; RecordCUVAR.setICCLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",22)
	S $P(vobj(vRec,"INCK"),"|",22)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFV(vRec,vVal)	; RecordCUVAR.setICCND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",21)
	S $P(vobj(vRec,"INCK"),"|",21)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFW(vRec,vVal)	; RecordCUVAR.setICCNF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",24)
	S $P(vobj(vRec,"INCK"),"|",24)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFX(vRec,vVal)	; RecordCUVAR.setICDFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",5)
	S $P(vobj(vRec,"INCK"),"|",5)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFY(vRec,vVal)	; RecordCUVAR.setICDFR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",1)
	S $P(vobj(vRec,"INCK"),"|",1)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSFZ(vRec,vVal)	; RecordCUVAR.setICDLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",3)
	S $P(vobj(vRec,"INCK"),"|",3)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGA(vRec,vVal)	; RecordCUVAR.setICDND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",2)
	S $P(vobj(vRec,"INCK"),"|",2)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGB(vRec,vVal)	; RecordCUVAR.setICDNF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",6)
	S $P(vobj(vRec,"INCK"),"|",6)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGC(vRec,vVal)	; RecordCUVAR.setICDRF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",7)
	S $P(vobj(vRec,"INCK"),"|",7)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGD(vRec,vVal)	; RecordCUVAR.setICDTF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",4)
	S $P(vobj(vRec,"INCK"),"|",4)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGE(vRec,vVal)	; RecordCUVAR.setICITY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",1)
	S $P(vobj(vRec,1099),"|",1)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGF(vRec,vVal)	; RecordCUVAR.setICLFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",14)
	S $P(vobj(vRec,"INCK"),"|",14)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGG(vRec,vVal)	; RecordCUVAR.setICLFR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",10)
	S $P(vobj(vRec,"INCK"),"|",10)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGH(vRec,vVal)	; RecordCUVAR.setICLLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",12)
	S $P(vobj(vRec,"INCK"),"|",12)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGI(vRec,vVal)	; RecordCUVAR.setICLND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",11)
	S $P(vobj(vRec,"INCK"),"|",11)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGJ(vRec,vVal)	; RecordCUVAR.setICLNF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",15)
	S $P(vobj(vRec,"INCK"),"|",15)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGK(vRec,vVal)	; RecordCUVAR.setICLRF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",16)
	S $P(vobj(vRec,"INCK"),"|",16)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGL(vRec,vVal)	; RecordCUVAR.setICLTF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INCK"),"|",13)
	S $P(vobj(vRec,"INCK"),"|",13)=vVal S vobj(vRec,-100,"INCK")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGM(vRec,vVal)	; RecordCUVAR.setICNTRY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",12)
	S $P(vobj(vRec,1099),"|",12)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGN(vRec,vVal)	; RecordCUVAR.setIEDS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ESCROW"),"|",5)
	S $P(vobj(vRec,"ESCROW"),"|",5)=vVal S vobj(vRec,-100,"ESCROW")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGO(vRec,vVal)	; RecordCUVAR.setIEIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TCC"),"|",3)
	S $P(vobj(vRec,"TCC"),"|",3)=vVal S vobj(vRec,-100,"TCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGP(vRec,vVal)	; RecordCUVAR.setIMAGE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"IMAGE"),"|",1)
	S $P(vobj(vRec,"IMAGE"),"|",1)=vVal S vobj(vRec,-100,"IMAGE")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGQ(vRec,vVal)	; RecordCUVAR.setIMAGESYMBL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"IAMGESYMBL"),"|",1)
	S $P(vobj(vRec,"IAMGESYMBL"),"|",1)=vVal S vobj(vRec,-100,"IAMGESYMBL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGR(vRec,vVal)	; RecordCUVAR.setINAME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",7)
	S $P(vobj(vRec,1099),"|",7)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGS(vRec,vVal)	; RecordCUVAR.setINAME2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",11)
	S $P(vobj(vRec,1099),"|",11)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGT(vRec,vVal)	; RecordCUVAR.setINQBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INQBAL"),"|",1)
	S $P(vobj(vRec,"INQBAL"),"|",1)=vVal S vobj(vRec,-100,"INQBAL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGU(vRec,vVal)	; RecordCUVAR.setINTPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INTPGM"),"|",1)
	S $P(vobj(vRec,"INTPGM"),"|",1)=vVal S vobj(vRec,-100,"INTPGM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGV(vRec,vVal)	; RecordCUVAR.setINTPOS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INTPOS"),"|",1)
	S $P(vobj(vRec,"INTPOS"),"|",1)=vVal S vobj(vRec,-100,"INTPOS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGW(vRec,vVal)	; RecordCUVAR.setINVPCTMIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",14)
	S $P(vobj(vRec,"DEP"),"|",14)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGX(vRec,vVal)	; RecordCUVAR.setIPCID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLACN"),"|",1)
	S $P(vobj(vRec,"GLACN"),"|",1)=vVal S vobj(vRec,-100,"GLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGY(vRec,vVal)	; RecordCUVAR.setIPD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"IPD"),"|",1)
	S $P(vobj(vRec,"IPD"),"|",1)=vVal S vobj(vRec,-100,"IPD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSGZ(vRec,vVal)	; RecordCUVAR.setIPETC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLACN"),"|",2)
	S $P(vobj(vRec,"GLACN"),"|",2)=vVal S vobj(vRec,-100,"GLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHA(vRec,vVal)	; RecordCUVAR.setIPYADJ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",12)
	S $P(vobj(vRec,"DEP"),"|",12)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHB(vRec,vVal)	; RecordCUVAR.setIRAAUT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",8)
	S $P(vobj(vRec,"DEP"),"|",8)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHC(vRec,vVal)	; RecordCUVAR.setIRACON(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",2)
	S $P(vobj(vRec,"DEP"),"|",2)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHD(vRec,vVal)	; RecordCUVAR.setIRADIS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",3)
	S $P(vobj(vRec,"DEP"),"|",3)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHE(vRec,vVal)	; RecordCUVAR.setIRAHIST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"IRAHIST"),"|",1)
	S $P(vobj(vRec,"IRAHIST"),"|",1)=vVal S vobj(vRec,-100,"IRAHIST")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHF(vRec,vVal)	; RecordCUVAR.setIRAINT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",4)
	S $P(vobj(vRec,"DEP"),"|",4)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHG(vRec,vVal)	; RecordCUVAR.setIRAIPO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",7)
	S $P(vobj(vRec,"DEP"),"|",7)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHH(vRec,vVal)	; RecordCUVAR.setIRAIWH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",6)
	S $P(vobj(vRec,"DEP"),"|",6)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHI(vRec,vVal)	; RecordCUVAR.setIRAPEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",5)
	S $P(vobj(vRec,"DEP"),"|",5)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHJ(vRec,vVal)	; RecordCUVAR.setIRAPRGD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",21)
	S $P(vobj(vRec,"DEP"),"|",21)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHK(vRec,vVal)	; RecordCUVAR.setISO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ISO"),"|",1)
	S $P(vobj(vRec,"ISO"),"|",1)=vVal S vobj(vRec,-100,"ISO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHL(vRec,vVal)	; RecordCUVAR.setISTATE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",2)
	S $P(vobj(vRec,1099),"|",2)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHM(vRec,vVal)	; RecordCUVAR.setITSPOSPL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",19)
	S $P(vobj(vRec,"%CRCD"),"|",19)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHN(vRec,vVal)	; RecordCUVAR.setIWUOCC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",10)
	S $P(vobj(vRec,"LN"),"|",10)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHO(vRec,vVal)	; RecordCUVAR.setIWUODC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",11)
	S $P(vobj(vRec,"LN"),"|",11)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHP(vRec,vVal)	; RecordCUVAR.setIZIP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",3)
	S $P(vobj(vRec,1099),"|",3)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHQ(vRec,vVal)	; RecordCUVAR.setLCCADR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",4)
	S $P(vobj(vRec,"DRMT"),"|",4)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHR(vRec,vVal)	; RecordCUVAR.setLCCPU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",6)
	S $P(vobj(vRec,"DRMT"),"|",6)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHS(vRec,vVal)	; RecordCUVAR.setLCCTIT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",5)
	S $P(vobj(vRec,"DRMT"),"|",5)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHT(vRec,vVal)	; RecordCUVAR.setLCL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INS"),"|",2)
	S $P(vobj(vRec,"INS"),"|",2)=vVal S vobj(vRec,-100,"INS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHU(vRec,vVal)	; RecordCUVAR.setLCNBDC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LCNBDC"),"|",1)
	S $P(vobj(vRec,"LCNBDC"),"|",1)=vVal S vobj(vRec,-100,"LCNBDC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHV(vRec,vVal)	; RecordCUVAR.setLEAD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ACHORIG"),"|",4)
	S $P(vobj(vRec,"ACHORIG"),"|",4)=vVal S vobj(vRec,-100,"ACHORIG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHW(vRec,vVal)	; RecordCUVAR.setLETDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LETTER"),"|",2)
	S $P(vobj(vRec,"LETTER"),"|",2)=vVal S vobj(vRec,-100,"LETTER")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHX(vRec,vVal)	; RecordCUVAR.setLETFIX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LETTER"),"|",1)
	S $P(vobj(vRec,"LETTER"),"|",1)=vVal S vobj(vRec,-100,"LETTER")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHY(vRec,vVal)	; RecordCUVAR.setLIMPRO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",16)
	S $P(vobj(vRec,"CIF"),"|",16)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSHZ(vRec,vVal)	; RecordCUVAR.setLNCC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",37)
	S $P(vobj(vRec,"LN"),"|",37)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIA(vRec,vVal)	; RecordCUVAR.setLNCFP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",34)
	S $P(vobj(vRec,"LN"),"|",34)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIB(vRec,vVal)	; RecordCUVAR.setLNCPI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",36)
	S $P(vobj(vRec,"LN"),"|",36)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIC(vRec,vVal)	; RecordCUVAR.setLNCPP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",35)
	S $P(vobj(vRec,"LN"),"|",35)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSID(vRec,vVal)	; RecordCUVAR.setLNCSCBL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCON"),"|",6)
	S $P(vobj(vRec,"LNCON"),"|",6)=vVal S vobj(vRec,-100,"LNCON")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIE(vRec,vVal)	; RecordCUVAR.setLNCSCOM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCON"),"|",1)
	S $P(vobj(vRec,"LNCON"),"|",1)=vVal S vobj(vRec,-100,"LNCON")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIF(vRec,vVal)	; RecordCUVAR.setLNCSDM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCON"),"|",5)
	S $P(vobj(vRec,"LNCON"),"|",5)=vVal S vobj(vRec,-100,"LNCON")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIG(vRec,vVal)	; RecordCUVAR.setLNCSLN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCON"),"|",3)
	S $P(vobj(vRec,"LNCON"),"|",3)=vVal S vobj(vRec,-100,"LNCON")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIH(vRec,vVal)	; RecordCUVAR.setLNCSMTG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCON"),"|",2)
	S $P(vobj(vRec,"LNCON"),"|",2)=vVal S vobj(vRec,-100,"LNCON")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSII(vRec,vVal)	; RecordCUVAR.setLNCSRC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LNCON"),"|",4)
	S $P(vobj(vRec,"LNCON"),"|",4)=vVal S vobj(vRec,-100,"LNCON")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIJ(vRec,vVal)	; RecordCUVAR.setLNDRBY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",1)
	S $P(vobj(vRec,"DELQ"),"|",1)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIK(vRec,vVal)	; RecordCUVAR.setLNDRM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",2)
	S $P(vobj(vRec,"DELQ"),"|",2)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIL(vRec,vVal)	; RecordCUVAR.setLNPROJREP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",39)
	S $P(vobj(vRec,"LN"),"|",39)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIM(vRec,vVal)	; RecordCUVAR.setLNRENDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",32)
	S $P(vobj(vRec,"LN"),"|",32)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIN(vRec,vVal)	; RecordCUVAR.setLNSUSEXT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",29)
	S $P(vobj(vRec,"LN"),"|",29)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIO(vRec,vVal)	; RecordCUVAR.setLNSUSTP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",30)
	S $P(vobj(vRec,"LN"),"|",30)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIP(vRec,vVal)	; RecordCUVAR.setLOGINMSG1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LOGINMSG"),"|",1)
	S $P(vobj(vRec,"LOGINMSG"),"|",1)=vVal S vobj(vRec,-100,"LOGINMSG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIQ(vRec,vVal)	; RecordCUVAR.setLOGINMSG2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LOGINMSG"),"|",2)
	S $P(vobj(vRec,"LOGINMSG"),"|",2)=vVal S vobj(vRec,-100,"LOGINMSG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIR(vRec,vVal)	; RecordCUVAR.setLOGINMSG3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LOGINMSG"),"|",3)
	S $P(vobj(vRec,"LOGINMSG"),"|",3)=vVal S vobj(vRec,-100,"LOGINMSG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIS(vRec,vVal)	; RecordCUVAR.setLPCO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",9)
	S $P(vobj(vRec,"LN"),"|",9)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIT(vRec,vVal)	; RecordCUVAR.setLPFRE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",6)
	S $P(vobj(vRec,"LN"),"|",6)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIU(vRec,vVal)	; RecordCUVAR.setLPLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",8)
	S $P(vobj(vRec,"LN"),"|",8)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIV(vRec,vVal)	; RecordCUVAR.setLPND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",7)
	S $P(vobj(vRec,"LN"),"|",7)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIW(vRec,vVal)	; RecordCUVAR.setLRNCPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CUSPGM"),"|",2)
	S $P(vobj(vRec,"CUSPGM"),"|",2)=vVal S vobj(vRec,-100,"CUSPGM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIX(vRec,vVal)	; RecordCUVAR.setLSP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LSP"),"|",1)
	S $P(vobj(vRec,"LSP"),"|",1)=vVal S vobj(vRec,-100,"LSP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIY(vRec,vVal)	; RecordCUVAR.setLTCL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"INS"),"|",4)
	S $P(vobj(vRec,"INS"),"|",4)=vVal S vobj(vRec,-100,"INS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSIZ(vRec,vVal)	; RecordCUVAR.setMAGCTRY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TCC"),"|",2)
	S $P(vobj(vRec,"TCC"),"|",2)=vVal S vobj(vRec,-100,"TCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJA(vRec,vVal)	; RecordCUVAR.setMAXCIFL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",2)
	S $P(vobj(vRec,"CIF"),"|",2)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJB(vRec,vVal)	; RecordCUVAR.setMAXCOL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",5)
	S $P(vobj(vRec,"EFTPAY"),"|",5)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJC(vRec,vVal)	; RecordCUVAR.setMAXEXT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",7)
	S $P(vobj(vRec,"CIF"),"|",7)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJD(vRec,vVal)	; RecordCUVAR.setMAXLOGFAILS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ECOMM"),"|",1)
	S $P(vobj(vRec,"ECOMM"),"|",1)=vVal S vobj(vRec,-100,"ECOMM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJE(vRec,vVal)	; RecordCUVAR.setMAXPAY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",2)
	S $P(vobj(vRec,"EFTPAY"),"|",2)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJF(vRec,vVal)	; RecordCUVAR.setMAXPM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"MAXPM"),"|",1)
	S $P(vobj(vRec,"MAXPM"),"|",1)=vVal S vobj(vRec,-100,"MAXPM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJG(vRec,vVal)	; RecordCUVAR.setMDO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",3)
	S $P(vobj(vRec,"DAYEND"),"|",3)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJH(vRec,vVal)	; RecordCUVAR.setMICR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"MICR"),"|",1)
	S $P(vobj(vRec,"MICR"),"|",1)=vVal S vobj(vRec,-100,"MICR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJI(vRec,vVal)	; RecordCUVAR.setMINAMT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",4)
	S $P(vobj(vRec,"DELQ"),"|",4)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJJ(vRec,vVal)	; RecordCUVAR.setMINCIFL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",1)
	S $P(vobj(vRec,"CIF"),"|",1)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJK(vRec,vVal)	; RecordCUVAR.setMINCMAMT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"COM"),"|",1)
	S $P(vobj(vRec,"COM"),"|",1)=vVal S vobj(vRec,-100,"COM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJL(vRec,vVal)	; RecordCUVAR.setMINCOL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",4)
	S $P(vobj(vRec,"EFTPAY"),"|",4)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJM(vRec,vVal)	; RecordCUVAR.setMINPAY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",1)
	S $P(vobj(vRec,"EFTPAY"),"|",1)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJN(vRec,vVal)	; RecordCUVAR.setMPSCERT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",22)
	S $P(vobj(vRec,"DEP"),"|",22)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJO(vRec,vVal)	; RecordCUVAR.setMRPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",33)
	S $P(vobj(vRec,"LN"),"|",33)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJP(vRec,vVal)	; RecordCUVAR.setMT900INT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SWIFT"),"|",3)
	S $P(vobj(vRec,"SWIFT"),"|",3)=vVal S vobj(vRec,-100,"SWIFT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJQ(vRec,vVal)	; RecordCUVAR.setMT910INT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SWIFT"),"|",4)
	S $P(vobj(vRec,"SWIFT"),"|",4)=vVal S vobj(vRec,-100,"SWIFT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJR(vRec,vVal)	; RecordCUVAR.setMULTIITSID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"MULTIITSID"),"|",1)
	S $P(vobj(vRec,"MULTIITSID"),"|",1)=vVal S vobj(vRec,-100,"MULTIITSID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJS(vRec,vVal)	; RecordCUVAR.setMXTRLM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"MXTRLM"),"|",1)
	S $P(vobj(vRec,"MXTRLM"),"|",1)=vVal S vobj(vRec,-100,"MXTRLM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJT(vRec,vVal)	; RecordCUVAR.setNOREGD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"NOREGD"),"|",1)
	S $P(vobj(vRec,"NOREGD"),"|",1)=vVal S vobj(vRec,-100,"NOREGD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJU(vRec,vVal)	; RecordCUVAR.setNOSEGMENTS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"OPTIMIZE"),"|",1)
	S $P(vobj(vRec,"OPTIMIZE"),"|",1)=vVal S vobj(vRec,-100,"OPTIMIZE")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJV(vRec,vVal)	; RecordCUVAR.setNOSTPURG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"NOSTPURG"),"|",1)
	S $P(vobj(vRec,"NOSTPURG"),"|",1)=vVal S vobj(vRec,-100,"NOSTPURG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJW(vRec,vVal)	; RecordCUVAR.setNOTP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DBS"),"|",7)
	S $P(vobj(vRec,"DBS"),"|",7)=vVal S vobj(vRec,-100,"DBS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJX(vRec,vVal)	; RecordCUVAR.setNR4BRAMT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",4)
	S $P(vobj(vRec,"TAXCA"),"|",4)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJY(vRec,vVal)	; RecordCUVAR.setODP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ODP"),"|",1)
	S $P(vobj(vRec,"ODP"),"|",1)=vVal S vobj(vRec,-100,"ODP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSJZ(vRec,vVal)	; RecordCUVAR.setODPE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ODPE"),"|",1)
	S $P(vobj(vRec,"ODPE"),"|",1)=vVal S vobj(vRec,-100,"ODPE")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKA(vRec,vVal)	; RecordCUVAR.setORCIFN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",3)
	S $P(vobj(vRec,"CIF"),"|",3)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKB(vRec,vVal)	; RecordCUVAR.setORIGCRCD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",12)
	S $P(vobj(vRec,"EUR"),"|",12)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKC(vRec,vVal)	; RecordCUVAR.setOTC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",23)
	S $P(vobj(vRec,"%CRCD"),"|",23)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKD(vRec,vVal)	; RecordCUVAR.setPAYERNAM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PAYERNAM"),"|",1)
	S $P(vobj(vRec,"PAYERNAM"),"|",1)=vVal S vobj(vRec,-100,"PAYERNAM")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKE(vRec,vVal)	; RecordCUVAR.setPBALRTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PBALRTN"),"|",1)
	S $P(vobj(vRec,"PBALRTN"),"|",1)=vVal S vobj(vRec,-100,"PBALRTN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKF(vRec,vVal)	; RecordCUVAR.setPBKIRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PBKIRN"),"|",1)
	S $P(vobj(vRec,"PBKIRN"),"|",1)=vVal S vobj(vRec,-100,"PBKIRN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKG(vRec,vVal)	; RecordCUVAR.setPCTCAP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",18)
	S $P(vobj(vRec,"CIF"),"|",18)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKH(vRec,vVal)	; RecordCUVAR.setPENREVGL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPRI"),"|",5)
	S $P(vobj(vRec,"EFTPRI"),"|",5)=vVal S vobj(vRec,-100,"EFTPRI")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKI(vRec,vVal)	; RecordCUVAR.setPLACN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PLACN"),"|",1)
	S $P(vobj(vRec,"PLACN"),"|",1)=vVal S vobj(vRec,-100,"PLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKJ(vRec,vVal)	; RecordCUVAR.setPLFEE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PLACN"),"|",2)
	S $P(vobj(vRec,"PLACN"),"|",2)=vVal S vobj(vRec,-100,"PLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKK(vRec,vVal)	; RecordCUVAR.setPMTHIS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SWIFT"),"|",1)
	S $P(vobj(vRec,"SWIFT"),"|",1)=vVal S vobj(vRec,-100,"SWIFT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKL(vRec,vVal)	; RecordCUVAR.setPOINST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"POINST"),"|",1)
	S $P(vobj(vRec,"POINST"),"|",1)=vVal S vobj(vRec,-100,"POINST")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKM(vRec,vVal)	; RecordCUVAR.setPRELID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PRELID"),"|",1)
	S $P(vobj(vRec,"PRELID"),"|",1)=vVal S vobj(vRec,-100,"PRELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKN(vRec,vVal)	; RecordCUVAR.setPROVFREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",18)
	S $P(vobj(vRec,"LN"),"|",18)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKO(vRec,vVal)	; RecordCUVAR.setPROVLPDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",23)
	S $P(vobj(vRec,"LN"),"|",23)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKP(vRec,vVal)	; RecordCUVAR.setPROVNPDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",19)
	S $P(vobj(vRec,"LN"),"|",19)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKQ(vRec,vVal)	; RecordCUVAR.setPROVOFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",20)
	S $P(vobj(vRec,"LN"),"|",20)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKR(vRec,vVal)	; RecordCUVAR.setPROVRCDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",21)
	S $P(vobj(vRec,"LN"),"|",21)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKS(vRec,vVal)	; RecordCUVAR.setPROVRPDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"LN"),"|",22)
	S $P(vobj(vRec,"LN"),"|",22)=vVal S vobj(vRec,-100,"LN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKT(vRec,vVal)	; RecordCUVAR.setPROWNR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCA"),"|",1)
	S $P(vobj(vRec,"SCA"),"|",1)=vVal S vobj(vRec,-100,"SCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKU(vRec,vVal)	; RecordCUVAR.setPRYRBKD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",16)
	S $P(vobj(vRec,"DEP"),"|",16)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKV(vRec,vVal)	; RecordCUVAR.setPSWAUT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SEC"),"|",15)
	S $P(vobj(vRec,"SEC"),"|",15)=vVal S vobj(vRec,-100,"SEC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKW(vRec,vVal)	; RecordCUVAR.setPSWDH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PSWDH"),"|",1)
	S $P(vobj(vRec,"PSWDH"),"|",1)=vVal S vobj(vRec,-100,"PSWDH")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKX(vRec,vVal)	; RecordCUVAR.setPTMDIRID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PTMDIRID"),"|",1)
	S $P(vobj(vRec,"PTMDIRID"),"|",1)=vVal S vobj(vRec,-100,"PTMDIRID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKY(vRec,vVal)	; RecordCUVAR.setPUBLISH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PUBLISH"),"|",1)
	S $P(vobj(vRec,"PUBLISH"),"|",1)=vVal S vobj(vRec,-100,"PUBLISH")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSKZ(vRec,vVal)	; RecordCUVAR.setRECEIPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RECPT"),"|",2)
	S $P(vobj(vRec,"RECPT"),"|",2)=vVal S vobj(vRec,-100,"RECPT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLA(vRec,vVal)	; RecordCUVAR.setRECPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RECPT"),"|",1)
	S $P(vobj(vRec,"RECPT"),"|",1)=vVal S vobj(vRec,-100,"RECPT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLB(vRec,vVal)	; RecordCUVAR.setREGCC1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",1)
	S $P(vobj(vRec,"REGCC"),"|",1)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLC(vRec,vVal)	; RecordCUVAR.setREGCC2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",2)
	S $P(vobj(vRec,"REGCC"),"|",2)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLD(vRec,vVal)	; RecordCUVAR.setREGCC3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",3)
	S $P(vobj(vRec,"REGCC"),"|",3)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLE(vRec,vVal)	; RecordCUVAR.setREGCC4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",4)
	S $P(vobj(vRec,"REGCC"),"|",4)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLF(vRec,vVal)	; RecordCUVAR.setREGCC5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",5)
	S $P(vobj(vRec,"REGCC"),"|",5)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLG(vRec,vVal)	; RecordCUVAR.setREGCC6(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",6)
	S $P(vobj(vRec,"REGCC"),"|",6)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLH(vRec,vVal)	; RecordCUVAR.setREGCCNAM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",9)
	S $P(vobj(vRec,"REGCC"),"|",9)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLI(vRec,vVal)	; RecordCUVAR.setREGCCOPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",7)
	S $P(vobj(vRec,"REGCC"),"|",7)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLJ(vRec,vVal)	; RecordCUVAR.setREGCCRO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGCC"),"|",8)
	S $P(vobj(vRec,"REGCC"),"|",8)=vVal S vobj(vRec,-100,"REGCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLK(vRec,vVal)	; RecordCUVAR.setREGFLG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REGFLG"),"|",1)
	S $P(vobj(vRec,"REGFLG"),"|",1)=vVal S vobj(vRec,-100,"REGFLG")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLL(vRec,vVal)	; RecordCUVAR.setREKEY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEAL"),"|",1)
	S $P(vobj(vRec,"DEAL"),"|",1)=vVal S vobj(vRec,-100,"DEAL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLM(vRec,vVal)	; RecordCUVAR.setRELID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RELID"),"|",1)
	S $P(vobj(vRec,"RELID"),"|",1)=vVal S vobj(vRec,-100,"RELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLN(vRec,vVal)	; RecordCUVAR.setREPLY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"REPLY"),"|",1)
	S $P(vobj(vRec,"REPLY"),"|",1)=vVal S vobj(vRec,-100,"REPLY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLO(vRec,vVal)	; RecordCUVAR.setRESPROC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RESPROC"),"|",1)
	S $P(vobj(vRec,"RESPROC"),"|",1)=vVal S vobj(vRec,-100,"RESPROC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLP(vRec,vVal)	; RecordCUVAR.setRESTRICT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RESTRICT"),"|",1)
	S $P(vobj(vRec,"RESTRICT"),"|",1)=vVal S vobj(vRec,-100,"RESTRICT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLQ(vRec,vVal)	; RecordCUVAR.setRETOPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",9)
	S $P(vobj(vRec,"DEP"),"|",9)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLR(vRec,vVal)	; RecordCUVAR.setRFC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",10)
	S $P(vobj(vRec,"EUR"),"|",10)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLS(vRec,vVal)	; RecordCUVAR.setRFR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",11)
	S $P(vobj(vRec,"EUR"),"|",11)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLT(vRec,vVal)	; RecordCUVAR.setRLCID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLACN"),"|",3)
	S $P(vobj(vRec,"GLACN"),"|",3)=vVal S vobj(vRec,-100,"GLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLU(vRec,vVal)	; RecordCUVAR.setRLETC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLACN"),"|",4)
	S $P(vobj(vRec,"GLACN"),"|",4)=vVal S vobj(vRec,-100,"GLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLV(vRec,vVal)	; RecordCUVAR.setRMC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",8)
	S $P(vobj(vRec,"EUR"),"|",8)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLW(vRec,vVal)	; RecordCUVAR.setRMR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",9)
	S $P(vobj(vRec,"EUR"),"|",9)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLX(vRec,vVal)	; RecordCUVAR.setRPAFEE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",13)
	S $P(vobj(vRec,"DEP"),"|",13)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLY(vRec,vVal)	; RecordCUVAR.setRPANET(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",11)
	S $P(vobj(vRec,"DEP"),"|",11)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSLZ(vRec,vVal)	; RecordCUVAR.setRPTNAM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DELQ"),"|",3)
	S $P(vobj(vRec,"DELQ"),"|",3)=vVal S vobj(vRec,-100,"DELQ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMA(vRec,vVal)	; RecordCUVAR.setRSPPLID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RSPPLID"),"|",1)
	S $P(vobj(vRec,"RSPPLID"),"|",1)=vVal S vobj(vRec,-100,"RSPPLID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMB(vRec,vVal)	; RecordCUVAR.setRT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RT"),"|",1)
	S $P(vobj(vRec,"RT"),"|",1)=vVal S vobj(vRec,-100,"RT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMC(vRec,vVal)	; RecordCUVAR.setRTNFPGL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RTNFPGL"),"|",1)
	S $P(vobj(vRec,"RTNFPGL"),"|",1)=vVal S vobj(vRec,-100,"RTNFPGL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMD(vRec,vVal)	; RecordCUVAR.setSBACQTO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SBN"),"|",3)
	S $P(vobj(vRec,"SBN"),"|",3)=vVal S vobj(vRec,-100,"SBN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSME(vRec,vVal)	; RecordCUVAR.setSBI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1099),"|",10)
	S $P(vobj(vRec,1099),"|",10)=vVal S vobj(vRec,-100,1099)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMF(vRec,vVal)	; RecordCUVAR.setSBINSTNO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SBINSTNO"),"|",1)
	S $P(vobj(vRec,"SBINSTNO"),"|",1)=vVal S vobj(vRec,-100,"SBINSTNO")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMG(vRec,vVal)	; RecordCUVAR.setSBSTDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SBN"),"|",1)
	S $P(vobj(vRec,"SBN"),"|",1)=vVal S vobj(vRec,-100,"SBN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMH(vRec,vVal)	; RecordCUVAR.setSCAUREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCAUREL"),"|",1)
	S $P(vobj(vRec,"SCAUREL"),"|",1)=vVal S vobj(vRec,-100,"SCAUREL")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMI(vRec,vVal)	; RecordCUVAR.setSCDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",14)
	S $P(vobj(vRec,"EUR"),"|",14)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMJ(vRec,vVal)	; RecordCUVAR.setSCHRCC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",1)
	S $P(vobj(vRec,"SCHRC"),"|",1)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMK(vRec,vVal)	; RecordCUVAR.setSCHRCE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",7)
	S $P(vobj(vRec,"SCHRC"),"|",7)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSML(vRec,vVal)	; RecordCUVAR.setSCHRCJ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",2)
	S $P(vobj(vRec,"SCHRC"),"|",2)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMM(vRec,vVal)	; RecordCUVAR.setSCHRCK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",3)
	S $P(vobj(vRec,"SCHRC"),"|",3)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMN(vRec,vVal)	; RecordCUVAR.setSCHRCL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",4)
	S $P(vobj(vRec,"SCHRC"),"|",4)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMO(vRec,vVal)	; RecordCUVAR.setSCHRCN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",5)
	S $P(vobj(vRec,"SCHRC"),"|",5)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMP(vRec,vVal)	; RecordCUVAR.setSCHRI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SCHRC"),"|",6)
	S $P(vobj(vRec,"SCHRC"),"|",6)=vVal S vobj(vRec,-100,"SCHRC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMQ(vRec,vVal)	; RecordCUVAR.setSCOVR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EUR"),"|",15)
	S $P(vobj(vRec,"EUR"),"|",15)=vVal S vobj(vRec,-100,"EUR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMR(vRec,vVal)	; RecordCUVAR.setSDRIFTRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",8)
	S $P(vobj(vRec,"TAXCA"),"|",8)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMS(vRec,vVal)	; RecordCUVAR.setSDRSPTRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",7)
	S $P(vobj(vRec,"TAXCA"),"|",7)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMT(vRec,vVal)	; RecordCUVAR.setSFEEOPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ODP"),"|",2)
	S $P(vobj(vRec,"ODP"),"|",2)=vVal S vobj(vRec,-100,"ODP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMU(vRec,vVal)	; RecordCUVAR.setSLDGLTC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"GLACN"),"|",5)
	S $P(vobj(vRec,"GLACN"),"|",5)=vVal S vobj(vRec,-100,"GLACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMV(vRec,vVal)	; RecordCUVAR.setSPLDIR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SPLDIR"),"|",1)
	S $P(vobj(vRec,"SPLDIR"),"|",1)=vVal S vobj(vRec,-100,"SPLDIR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMW(vRec,vVal)	; RecordCUVAR.setSPLITDAY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SPLITDAY"),"|",1)
	S $P(vobj(vRec,"SPLITDAY"),"|",1)=vVal S vobj(vRec,-100,"SPLITDAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMX(vRec,vVal)	; RecordCUVAR.setSTFREJ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STFREJ"),"|",1)
	S $P(vobj(vRec,"STFREJ"),"|",1)=vVal S vobj(vRec,-100,"STFREJ")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMY(vRec,vVal)	; RecordCUVAR.setSTMLCC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DRMT"),"|",3)
	S $P(vobj(vRec,"DRMT"),"|",3)=vVal S vobj(vRec,-100,"DRMT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSMZ(vRec,vVal)	; RecordCUVAR.setSTMTCDSKIP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STMTSRT"),"|",3)
	S $P(vobj(vRec,"STMTSRT"),"|",3)=vVal S vobj(vRec,-100,"STMTSRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNA(vRec,vVal)	; RecordCUVAR.setSTMTCUMUL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STMTSRT"),"|",6)
	S $P(vobj(vRec,"STMTSRT"),"|",6)=vVal S vobj(vRec,-100,"STMTSRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNB(vRec,vVal)	; RecordCUVAR.setSTMTINTRTC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STMTSRT"),"|",4)
	S $P(vobj(vRec,"STMTSRT"),"|",4)=vVal S vobj(vRec,-100,"STMTSRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNC(vRec,vVal)	; RecordCUVAR.setSTMTLNSKIP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STMTSRT"),"|",5)
	S $P(vobj(vRec,"STMTSRT"),"|",5)=vVal S vobj(vRec,-100,"STMTSRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSND(vRec,vVal)	; RecordCUVAR.setSTMTSRTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STMTSRT"),"|",1)
	S $P(vobj(vRec,"STMTSRT"),"|",1)=vVal S vobj(vRec,-100,"STMTSRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNE(vRec,vVal)	; RecordCUVAR.setSTMTSRTL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"STMTSRT"),"|",2)
	S $P(vobj(vRec,"STMTSRT"),"|",2)=vVal S vobj(vRec,-100,"STMTSRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNF(vRec,vVal)	; RecordCUVAR.setSTPOF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DEP"),"|",1)
	S $P(vobj(vRec,"DEP"),"|",1)=vVal S vobj(vRec,-100,"DEP")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNG(vRec,vVal)	; RecordCUVAR.setSWIFTADD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SWIFTADD"),"|",1)
	S $P(vobj(vRec,"SWIFTADD"),"|",1)=vVal S vobj(vRec,-100,"SWIFTADD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNH(vRec,vVal)	; RecordCUVAR.setSYSABR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SYSDRV"),"|",1)
	S $P(vobj(vRec,"SYSDRV"),"|",1)=vVal S vobj(vRec,-100,"SYSDRV")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNI(vRec,vVal)	; RecordCUVAR.setT4RIFTRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",2)
	S $P(vobj(vRec,"TAXCA"),"|",2)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNJ(vRec,vVal)	; RecordCUVAR.setT4RSPTRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",1)
	S $P(vobj(vRec,"TAXCA"),"|",1)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNK(vRec,vVal)	; RecordCUVAR.setT5FID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",5)
	S $P(vobj(vRec,"TAXCA"),"|",5)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNL(vRec,vVal)	; RecordCUVAR.setT5RAMT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",3)
	S $P(vobj(vRec,"TAXCA"),"|",3)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNM(vRec,vVal)	; RecordCUVAR.setT5TRN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TAXCA"),"|",6)
	S $P(vobj(vRec,"TAXCA"),"|",6)=vVal S vobj(vRec,-100,"TAXCA")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNN(vRec,vVal)	; RecordCUVAR.setTAXREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",5)
	S $P(vobj(vRec,"CIF"),"|",5)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNO(vRec,vVal)	; RecordCUVAR.setTAXYE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",9)
	S $P(vobj(vRec,"DAYEND"),"|",9)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNP(vRec,vVal)	; RecordCUVAR.setTAXYEOFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",10)
	S $P(vobj(vRec,"DAYEND"),"|",10)=vVal S vobj(vRec,-100,"DAYEND")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNQ(vRec,vVal)	; RecordCUVAR.setTBLS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%TBLS"),"|",1)
	S $P(vobj(vRec,"%TBLS"),"|",1)=vVal S vobj(vRec,-100,"%TBLS")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNR(vRec,vVal)	; RecordCUVAR.setTCC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"TCC"),"|",1)
	S $P(vobj(vRec,"TCC"),"|",1)=vVal S vobj(vRec,-100,"TCC")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNS(vRec,vVal)	; RecordCUVAR.setTCECR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",5)
	S $P(vobj(vRec,"%CRCD"),"|",5)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNT(vRec,vVal)	; RecordCUVAR.setTCEDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",4)
	S $P(vobj(vRec,"%CRCD"),"|",4)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNU(vRec,vVal)	; RecordCUVAR.setTCPVER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"FTPTIME"),"|",2)
	S $P(vobj(vRec,"FTPTIME"),"|",2)=vVal S vobj(vRec,-100,"FTPTIME")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNV(vRec,vVal)	; RecordCUVAR.setTELEPHONE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"ADDR"),"|",9)
	S $P(vobj(vRec,"ADDR"),"|",9)=vVal S vobj(vRec,-100,"ADDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNW(vRec,vVal)	; RecordCUVAR.setTFS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",25)
	S $P(vobj(vRec,"%CRCD"),"|",25)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNX(vRec,vVal)	; RecordCUVAR.setTFSL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",22)
	S $P(vobj(vRec,"%CRCD"),"|",22)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNY(vRec,vVal)	; RecordCUVAR.setTFSP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",21)
	S $P(vobj(vRec,"%CRCD"),"|",21)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSNZ(vRec,vVal)	; RecordCUVAR.setTFSPOSPL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"%CRCD"),"|",20)
	S $P(vobj(vRec,"%CRCD"),"|",20)=vVal S vobj(vRec,-100,"%CRCD")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOA(vRec,vVal)	; RecordCUVAR.setTINCO(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",24)
	S $P(vobj(vRec,"CIF"),"|",24)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOB(vRec,vVal)	; RecordCUVAR.setTJD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,2),"|",1)
	S $P(vobj(vRec,2),"|",1)=vVal S vobj(vRec,-100,2)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOC(vRec,vVal)	; RecordCUVAR.setTLOPRE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PRELID"),"|",5)
	S $P(vobj(vRec,"PRELID"),"|",5)=vVal S vobj(vRec,-100,"PRELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOD(vRec,vVal)	; RecordCUVAR.setTLOREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RELID"),"|",5)
	S $P(vobj(vRec,"RELID"),"|",5)=vVal S vobj(vRec,-100,"RELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOE(vRec,vVal)	; RecordCUVAR.setTMSRSND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"SBN"),"|",2)
	S $P(vobj(vRec,"SBN"),"|",2)=vVal S vobj(vRec,-100,"SBN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOF(vRec,vVal)	; RecordCUVAR.setTOTASS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",19)
	S $P(vobj(vRec,"CIF"),"|",19)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOG(vRec,vVal)	; RecordCUVAR.setTOTCAP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CIF"),"|",17)
	S $P(vobj(vRec,"CIF"),"|",17)=vVal S vobj(vRec,-100,"CIF")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOH(vRec,vVal)	; RecordCUVAR.setTPREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PRELID"),"|",3)
	S $P(vobj(vRec,"PRELID"),"|",3)=vVal S vobj(vRec,-100,"PRELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOI(vRec,vVal)	; RecordCUVAR.setTREF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"CRT"),"|",7)
	S $P(vobj(vRec,"CRT"),"|",7)=vVal S vobj(vRec,-100,"CRT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOJ(vRec,vVal)	; RecordCUVAR.setTREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RELID"),"|",3)
	S $P(vobj(vRec,"RELID"),"|",3)=vVal S vobj(vRec,-100,"RELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOK(vRec,vVal)	; RecordCUVAR.setUACND1F(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"UACND1F"),"|",1)
	S $P(vobj(vRec,"UACND1F"),"|",1)=vVal S vobj(vRec,-100,"UACND1F")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOL(vRec,vVal)	; RecordCUVAR.setUACNL1F(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"UACNL1F"),"|",1)
	S $P(vobj(vRec,"UACNL1F"),"|",1)=vVal S vobj(vRec,-100,"UACNL1F")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOM(vRec,vVal)	; RecordCUVAR.setUCID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"UCID"),"|",1)
	S $P(vobj(vRec,"UCID"),"|",1)=vVal S vobj(vRec,-100,"UCID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSON(vRec,vVal)	; RecordCUVAR.setUCIF1F(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"UCIF1F"),"|",1)
	S $P(vobj(vRec,"UCIF1F"),"|",1)=vVal S vobj(vRec,-100,"UCIF1F")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOO(vRec,vVal)	; RecordCUVAR.setUCSSERV(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PUBLISH"),"|",2)
	S $P(vobj(vRec,"PUBLISH"),"|",2)=vVal S vobj(vRec,-100,"PUBLISH")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOP(vRec,vVal)	; RecordCUVAR.setUDRC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"EFTPAY"),"|",18)
	S $P(vobj(vRec,"EFTPAY"),"|",18)=vVal S vobj(vRec,-100,"EFTPAY")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOQ(vRec,vVal)	; RecordCUVAR.setUSEGOPT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"USEGOPT"),"|",1)
	S $P(vobj(vRec,"USEGOPT"),"|",1)=vVal S vobj(vRec,-100,"USEGOPT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOR(vRec,vVal)	; RecordCUVAR.setUSERNAME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"USERNAME"),"|",1)
	S $P(vobj(vRec,"USERNAME"),"|",1)=vVal S vobj(vRec,-100,"USERNAME")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOS(vRec,vVal)	; RecordCUVAR.setUSERPREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"PRELID"),"|",4)
	S $P(vobj(vRec,"PRELID"),"|",4)=vVal S vobj(vRec,-100,"PRELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOT(vRec,vVal)	; RecordCUVAR.setUSERREL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"RELID"),"|",4)
	S $P(vobj(vRec,"RELID"),"|",4)=vVal S vobj(vRec,-100,"RELID")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOU(vRec,vVal)	; RecordCUVAR.setUSRESTAT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"USRESTAT"),"|",1)
	S $P(vobj(vRec,"USRESTAT"),"|",1)=vVal S vobj(vRec,-100,"USRESTAT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOV(vRec,vVal)	; RecordCUVAR.setVADDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",2)
	S $P(vobj(vRec,"VNDR"),"|",2)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOW(vRec,vVal)	; RecordCUVAR.setVAT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VAT"),"|",1)
	S $P(vobj(vRec,"VAT"),"|",1)=vVal S vobj(vRec,-100,"VAT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOX(vRec,vVal)	; RecordCUVAR.setVCCODE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",7)
	S $P(vobj(vRec,"VNDR"),"|",7)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOY(vRec,vVal)	; RecordCUVAR.setVCITY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",3)
	S $P(vobj(vRec,"VNDR"),"|",3)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSOZ(vRec,vVal)	; RecordCUVAR.setVCNAME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",6)
	S $P(vobj(vRec,"VNDR"),"|",6)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPA(vRec,vVal)	; RecordCUVAR.setVDT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VDT"),"|",1)
	S $P(vobj(vRec,"VDT"),"|",1)=vVal S vobj(vRec,-100,"VDT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPB(vRec,vVal)	; RecordCUVAR.setVDTFWD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VDT"),"|",2)
	S $P(vobj(vRec,"VDT"),"|",2)=vVal S vobj(vRec,-100,"VDT")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPC(vRec,vVal)	; RecordCUVAR.setVEMAIL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",9)
	S $P(vobj(vRec,"VNDR"),"|",9)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPD(vRec,vVal)	; RecordCUVAR.setVNAME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",1)
	S $P(vobj(vRec,"VNDR"),"|",1)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPE(vRec,vVal)	; RecordCUVAR.setVPHONE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",8)
	S $P(vobj(vRec,"VNDR"),"|",8)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPF(vRec,vVal)	; RecordCUVAR.setVSTATE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",4)
	S $P(vobj(vRec,"VNDR"),"|",4)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPG(vRec,vVal)	; RecordCUVAR.setVZIP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"VNDR"),"|",5)
	S $P(vobj(vRec,"VNDR"),"|",5)=vVal S vobj(vRec,-100,"VNDR")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPH(vRec,vVal)	; RecordCUVAR.setXACN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"XACN"),"|",1)
	S $P(vobj(vRec,"XACN"),"|",1)=vVal S vobj(vRec,-100,"XACN")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfSPI(vRec,vVal)	; RecordCUVAR.setYEOFF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"DAYEND"),"|",7)
	S $P(vobj(vRec,"DAYEND"),"|",7)=vVal S vobj(vRec,-100,"DAYEND")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordCUVAR.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("CUVAR",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF" X $ZT
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) S vobj(vOid,vNod)=$get(^CUVAR(vNod))
	I vCol="%ATM" D vCoMfS1(vOid,vVal) Q 
	I vCol="%BWPCT" D vCoMfS2(vOid,vVal) Q 
	I vCol="%CC" D vCoMfS3(vOid,vVal) Q 
	I vCol="%CRCD" D vCoMfS4(vOid,vVal) Q 
	I vCol="%ET" D vCoMfS5(vOid,vVal) Q 
	I vCol="%HELP" D vCoMfS6(vOid,vVal) Q 
	I vCol="%HELPCNT" D vCoMfS7(vOid,vVal) Q 
	I vCol="%KEYS" D vCoMfS8(vOid,vVal) Q 
	I vCol="%LIBS" D vCoMfS9(vOid,vVal) Q 
	I vCol="%MCP" D vCoMfS10(vOid,vVal) Q 
	I vCol="%TO" D vCoMfS11(vOid,vVal) Q 
	I vCol="%TOHALT" D vCoMfS12(vOid,vVal) Q 
	I vCol="%VN" D vCoMfS13(vOid,vVal) Q 
	I vCol="AAF" D vCoMfS14(vOid,vVal) Q 
	I vCol="AALD" D vCoMfS15(vOid,vVal) Q 
	I vCol="AAND" D vCoMfS16(vOid,vVal) Q 
	I vCol="ACNMRPC" D vCoMfS17(vOid,vVal) Q 
	I vCol="ADRSCR" D vCoMfS18(vOid,vVal) Q 
	I vCol="ADRSCRI" D vCoMfS19(vOid,vVal) Q 
	I vCol="ADRSCRM" D vCoMfS20(vOid,vVal) Q 
	I vCol="AGE1" D vCoMfS21(vOid,vVal) Q 
	I vCol="AGE2" D vCoMfS22(vOid,vVal) Q 
	I vCol="AGE3" D vCoMfS23(vOid,vVal) Q 
	I vCol="AGE4" D vCoMfS24(vOid,vVal) Q 
	I vCol="ALCOUNT" D vCoMfS25(vOid,vVal) Q 
	I vCol="ALPHI" D vCoMfS26(vOid,vVal) Q 
	I vCol="ANAOFF" D vCoMfS27(vOid,vVal) Q 
	I vCol="AROFF" D vCoMfS28(vOid,vVal) Q 
	I vCol="ATMOPT" D vCoMfS29(vOid,vVal) Q 
	I vCol="AUTOAUTH" D vCoMfS30(vOid,vVal) Q 
	I vCol="BALCCLC" D vCoMfS31(vOid,vVal) Q 
	I vCol="BALCLGC" D vCoMfS32(vOid,vVal) Q 
	I vCol="BAMTMOD" D vCoMfS33(vOid,vVal) Q 
	I vCol="BANNER" D vCoMfS34(vOid,vVal) Q 
	I vCol="BATRESTART" D vCoMfS35(vOid,vVal) Q 
	I vCol="BINDEF" D vCoMfS36(vOid,vVal) Q 
	I vCol="BOBR" D vCoMfS37(vOid,vVal) Q 
	I vCol="BORIG" D vCoMfS38(vOid,vVal) Q 
	I vCol="BRKNBDC" D vCoMfS39(vOid,vVal) Q 
	I vCol="BSA" D vCoMfS40(vOid,vVal) Q 
	I vCol="BSEMOD" D vCoMfS41(vOid,vVal) Q 
	I vCol="BTTJOB" D vCoMfS42(vOid,vVal) Q 
	I vCol="BWAPGM" D vCoMfS43(vOid,vVal) Q 
	I vCol="BWO" D vCoMfS44(vOid,vVal) Q 
	I vCol="CAC" D vCoMfS45(vOid,vVal) Q 
	I vCol="CAD1" D vCoMfS46(vOid,vVal) Q 
	I vCol="CAD2" D vCoMfS47(vOid,vVal) Q 
	I vCol="CAD3" D vCoMfS48(vOid,vVal) Q 
	I vCol="CATSUP" D vCoMfS49(vOid,vVal) Q 
	I vCol="CCITY" D vCoMfS50(vOid,vVal) Q 
	I vCol="CCMOD" D vCoMfS51(vOid,vVal) Q 
	I vCol="CCNTRY" D vCoMfS52(vOid,vVal) Q 
	I vCol="CECR" D vCoMfS53(vOid,vVal) Q 
	I vCol="CEDR" D vCoMfS54(vOid,vVal) Q 
	I vCol="CEMAIL" D vCoMfS55(vOid,vVal) Q 
	I vCol="CERTN" D vCoMfS56(vOid,vVal) Q 
	I vCol="CHKHLDRTN" D vCoMfS57(vOid,vVal) Q 
	I vCol="CHKIMG" D vCoMfS58(vOid,vVal) Q 
	I vCol="CHKPNT" D vCoMfS59(vOid,vVal) Q 
	I vCol="CIDBLK" D vCoMfS60(vOid,vVal) Q 
	I vCol="CIDLOWLM" D vCoMfS61(vOid,vVal) Q 
	I vCol="CIFALLOC" D vCoMfS62(vOid,vVal) Q 
	I vCol="CIFEXTI" D vCoMfS63(vOid,vVal) Q 
	I vCol="CIFMRPC" D vCoMfS64(vOid,vVal) Q 
	I vCol="CIFPRGD" D vCoMfS65(vOid,vVal) Q 
	I vCol="CIFVER" D vCoMfS66(vOid,vVal) Q 
	I vCol="CMSACOPT" D vCoMfS67(vOid,vVal) Q 
	I vCol="CMSAVALR" D vCoMfS68(vOid,vVal) Q 
	I vCol="CNAME" D vCoMfS69(vOid,vVal) Q 
	I vCol="CNFRMHIS" D vCoMfS70(vOid,vVal) Q 
	I vCol="CNTRY" D vCoMfS71(vOid,vVal) Q 
	I vCol="CO" D vCoMfS72(vOid,vVal) Q 
	I vCol="CONAM" D vCoMfS73(vOid,vVal) Q 
	I vCol="CONTACT" D vCoMfS74(vOid,vVal) Q 
	I vCol="CONTRA" D vCoMfS75(vOid,vVal) Q 
	I vCol="CORPID" D vCoMfS76(vOid,vVal) Q 
	I vCol="COURTMSG" D vCoMfS77(vOid,vVal) Q 
	I vCol="CPRTLN1" D vCoMfS78(vOid,vVal) Q 
	I vCol="CPRTLN2" D vCoMfS79(vOid,vVal) Q 
	I vCol="CPRTLN3" D vCoMfS80(vOid,vVal) Q 
	I vCol="CPRTLN4" D vCoMfS81(vOid,vVal) Q 
	I vCol="CRCDTHR" D vCoMfS82(vOid,vVal) Q 
	I vCol="CRCTRL" D vCoMfS83(vOid,vVal) Q 
	I vCol="CRID" D vCoMfS84(vOid,vVal) Q 
	I vCol="CRLRD" D vCoMfS85(vOid,vVal) Q 
	I vCol="CRNTAP" D vCoMfS86(vOid,vVal) Q 
	I vCol="CRREP" D vCoMfS87(vOid,vVal) Q 
	I vCol="CRSHRT" D vCoMfS88(vOid,vVal) Q 
	I vCol="CRSTUD" D vCoMfS89(vOid,vVal) Q 
	I vCol="CRTDSP" D vCoMfS90(vOid,vVal) Q 
	I vCol="CRTMSGD" D vCoMfS91(vOid,vVal) Q 
	I vCol="CRTMSGL" D vCoMfS92(vOid,vVal) Q 
	I vCol="CSTATE" D vCoMfS93(vOid,vVal) Q 
	I vCol="CSTFMTRTN" D vCoMfS94(vOid,vVal) Q 
	I vCol="CTELE" D vCoMfS95(vOid,vVal) Q 
	I vCol="CTOF1098" D vCoMfS96(vOid,vVal) Q 
	I vCol="CTOF1099" D vCoMfS97(vOid,vVal) Q 
	I vCol="CURRENV" D vCoMfS98(vOid,vVal) Q 
	I vCol="CVSCR1" D vCoMfS99(vOid,vVal) Q 
	I vCol="CVSCR2" D vCoMfSAA(vOid,vVal) Q 
	I vCol="CZIP" D vCoMfSAB(vOid,vVal) Q 
	I vCol="DARCDEL" D vCoMfSAC(vOid,vVal) Q 
	I vCol="DARCDFLG" D vCoMfSAD(vOid,vVal) Q 
	I vCol="DARCFREQ" D vCoMfSAE(vOid,vVal) Q 
	I vCol="DARCLPDT" D vCoMfSAF(vOid,vVal) Q 
	I vCol="DARCNPDT" D vCoMfSAG(vOid,vVal) Q 
	I vCol="DARCOFF" D vCoMfSAH(vOid,vVal) Q 
	I vCol="DAYEND2" D vCoMfSAI(vOid,vVal) Q 
	I vCol="DAYEND4" D vCoMfSAJ(vOid,vVal) Q 
	I vCol="DAYEND5" D vCoMfSAK(vOid,vVal) Q 
	I vCol="DBIMBAL" D vCoMfSAL(vOid,vVal) Q 
	I vCol="DBSHDR" D vCoMfSAM(vOid,vVal) Q 
	I vCol="DBSLIST" D vCoMfSAN(vOid,vVal) Q 
	I vCol="DBSLSTEXP" D vCoMfSAO(vOid,vVal) Q 
	I vCol="DBSPH132" D vCoMfSAP(vOid,vVal) Q 
	I vCol="DBSPH80" D vCoMfSAQ(vOid,vVal) Q 
	I vCol="DCCRCD" D vCoMfSAR(vOid,vVal) Q 
	I vCol="DCL" D vCoMfSAS(vOid,vVal) Q 
	I vCol="DDPACND" D vCoMfSAT(vOid,vVal) Q 
	I vCol="DDPACNL" D vCoMfSAU(vOid,vVal) Q 
	I vCol="DEALPURG" D vCoMfSAV(vOid,vVal) Q 
	I vCol="DEBAUT" D vCoMfSAW(vOid,vVal) Q 
	I vCol="DEFDREL" D vCoMfSAX(vOid,vVal) Q 
	I vCol="DEFLREL" D vCoMfSAY(vOid,vVal) Q 
	I vCol="DELDIS" D vCoMfSAZ(vOid,vVal) Q 
	I vCol="DENFLG" D vCoMfSBA(vOid,vVal) Q 
	I vCol="DEPVER" D vCoMfSBB(vOid,vVal) Q 
	I vCol="DEVIO" D vCoMfSBC(vOid,vVal) Q 
	I vCol="DEVPTR" D vCoMfSBD(vOid,vVal) Q 
	I vCol="DFTCHTRN" D vCoMfSBE(vOid,vVal) Q 
	I vCol="DFTCI" D vCoMfSBF(vOid,vVal) Q 
	I vCol="DFTCKTRN" D vCoMfSBG(vOid,vVal) Q 
	I vCol="DFTCO" D vCoMfSBH(vOid,vVal) Q 
	I vCol="DFTENV" D vCoMfSBI(vOid,vVal) Q 
	I vCol="DFTSPVUCLS" D vCoMfSBJ(vOid,vVal) Q 
	I vCol="DFTSTFUCLS" D vCoMfSBK(vOid,vVal) Q 
	I vCol="DFTTHRC" D vCoMfSBL(vOid,vVal) Q 
	I vCol="DFTTHRR" D vCoMfSBM(vOid,vVal) Q 
	I vCol="DIN" D vCoMfSBN(vOid,vVal) Q 
	I vCol="DISBRST" D vCoMfSBO(vOid,vVal) Q 
	I vCol="DISTNAM" D vCoMfSBP(vOid,vVal) Q 
	I vCol="DLQNT" D vCoMfSBQ(vOid,vVal) Q 
	I vCol="DODRST" D vCoMfSBR(vOid,vVal) Q 
	I vCol="DPREL" D vCoMfSBS(vOid,vVal) Q 
	I vCol="DRC1" D vCoMfSBT(vOid,vVal) Q 
	I vCol="DRC10" D vCoMfSBU(vOid,vVal) Q 
	I vCol="DRC11" D vCoMfSBV(vOid,vVal) Q 
	I vCol="DRC12" D vCoMfSBW(vOid,vVal) Q 
	I vCol="DRC13" D vCoMfSBX(vOid,vVal) Q 
	I vCol="DRC14" D vCoMfSBY(vOid,vVal) Q 
	I vCol="DRC15" D vCoMfSBZ(vOid,vVal) Q 
	I vCol="DRC16" D vCoMfSCA(vOid,vVal) Q 
	I vCol="DRC17" D vCoMfSCB(vOid,vVal) Q 
	I vCol="DRC18" D vCoMfSCC(vOid,vVal) Q 
	I vCol="DRC19" D vCoMfSCD(vOid,vVal) Q 
	I vCol="DRC2" D vCoMfSCE(vOid,vVal) Q 
	I vCol="DRC20" D vCoMfSCF(vOid,vVal) Q 
	I vCol="DRC3" D vCoMfSCG(vOid,vVal) Q 
	I vCol="DRC4" D vCoMfSCH(vOid,vVal) Q 
	I vCol="DRC5" D vCoMfSCI(vOid,vVal) Q 
	I vCol="DRC6" D vCoMfSCJ(vOid,vVal) Q 
	I vCol="DRC7" D vCoMfSCK(vOid,vVal) Q 
	I vCol="DRC8" D vCoMfSCL(vOid,vVal) Q 
	I vCol="DRC9" D vCoMfSCM(vOid,vVal) Q 
	I vCol="DREL" D vCoMfSCN(vOid,vVal) Q 
	I vCol="DRMT" D vCoMfSCO(vOid,vVal) Q 
	I vCol="DRVMSG" D vCoMfSCP(vOid,vVal) Q 
	I vCol="DUPTIN" D vCoMfSCQ(vOid,vVal) Q 
	I vCol="EADHS" D vCoMfSCR(vOid,vVal) Q 
	I vCol="EAPPS" D vCoMfSCS(vOid,vVal) Q 
	I vCol="EAPS" D vCoMfSCT(vOid,vVal) Q 
	I vCol="EDITMASK" D vCoMfSCU(vOid,vVal) Q 
	I vCol="EFD" D vCoMfSCV(vOid,vVal) Q 
	I vCol="EFDFTFLG" D vCoMfSCW(vOid,vVal) Q 
	I vCol="EFTARCDIR" D vCoMfSCX(vOid,vVal) Q 
	I vCol="EFTCCIN" D vCoMfSCY(vOid,vVal) Q 
	I vCol="EFTCCOUT" D vCoMfSCZ(vOid,vVal) Q 
	I vCol="EFTCOM" D vCoMfSDA(vOid,vVal) Q 
	I vCol="EFTDEL" D vCoMfSDB(vOid,vVal) Q 
	I vCol="EFTMEMO" D vCoMfSDC(vOid,vVal) Q 
	I vCol="EFTREFNO" D vCoMfSDD(vOid,vVal) Q 
	I vCol="EFTREJ" D vCoMfSDE(vOid,vVal) Q 
	I vCol="EFTRICO" D vCoMfSDF(vOid,vVal) Q 
	I vCol="EFTSUP" D vCoMfSDG(vOid,vVal) Q 
	I vCol="EHDS" D vCoMfSDH(vOid,vVal) Q 
	I vCol="EIN" D vCoMfSDI(vOid,vVal) Q 
	I vCol="EMU" D vCoMfSDJ(vOid,vVal) Q 
	I vCol="EMUCRCD" D vCoMfSDK(vOid,vVal) Q 
	I vCol="EMURND" D vCoMfSDL(vOid,vVal) Q 
	I vCol="ERBRES1" D vCoMfSDM(vOid,vVal) Q 
	I vCol="ERBRES2" D vCoMfSDN(vOid,vVal) Q 
	I vCol="ERBRES3" D vCoMfSDO(vOid,vVal) Q 
	I vCol="ERRMAIL" D vCoMfSDP(vOid,vVal) Q 
	I vCol="ERRMDFT" D vCoMfSDQ(vOid,vVal) Q 
	I vCol="ESCCHK" D vCoMfSDR(vOid,vVal) Q 
	I vCol="ESCGL" D vCoMfSDS(vOid,vVal) Q 
	I vCol="ESCH" D vCoMfSDT(vOid,vVal) Q 
	I vCol="ESCHEAT" D vCoMfSDU(vOid,vVal) Q 
	I vCol="EURBAL" D vCoMfSDV(vOid,vVal) Q 
	I vCol="EURCNVDT" D vCoMfSDW(vOid,vVal) Q 
	I vCol="EURINTEG" D vCoMfSDX(vOid,vVal) Q 
	I vCol="EURRNDCR" D vCoMfSDY(vOid,vVal) Q 
	I vCol="EURRNDDR" D vCoMfSDZ(vOid,vVal) Q 
	I vCol="EXPREP" D vCoMfSEA(vOid,vVal) Q 
	I vCol="EXTREM" D vCoMfSEB(vOid,vVal) Q 
	I vCol="EXTVAL" D vCoMfSEC(vOid,vVal) Q 
	I vCol="FAILWAIT" D vCoMfSED(vOid,vVal) Q 
	I vCol="FCVMEMO" D vCoMfSEE(vOid,vVal) Q 
	I vCol="FDEST" D vCoMfSEF(vOid,vVal) Q 
	I vCol="FEEICRTC" D vCoMfSEG(vOid,vVal) Q 
	I vCol="FEEIDRTC" D vCoMfSEH(vOid,vVal) Q 
	I vCol="FEPXALL" D vCoMfSEI(vOid,vVal) Q 
	I vCol="FINYE" D vCoMfSEJ(vOid,vVal) Q 
	I vCol="FINYEL" D vCoMfSEK(vOid,vVal) Q 
	I vCol="FLDOVF" D vCoMfSEL(vOid,vVal) Q 
	I vCol="FNCRATE" D vCoMfSEM(vOid,vVal) Q 
	I vCol="FORIG" D vCoMfSEN(vOid,vVal) Q 
	I vCol="FTPTIME" D vCoMfSEO(vOid,vVal) Q 
	I vCol="FUTBLD" D vCoMfSEP(vOid,vVal) Q 
	I vCol="FX" D vCoMfSEQ(vOid,vVal) Q 
	I vCol="FXLOSS" D vCoMfSER(vOid,vVal) Q 
	I vCol="FXPOSL" D vCoMfSES(vOid,vVal) Q 
	I vCol="FXPOSPL" D vCoMfSET(vOid,vVal) Q 
	I vCol="FXPOSRT" D vCoMfSEU(vOid,vVal) Q 
	I vCol="FXPROFIT" D vCoMfSEV(vOid,vVal) Q 
	I vCol="FXRATEDF" D vCoMfSEW(vOid,vVal) Q 
	I vCol="GLCCRO" D vCoMfSEX(vOid,vVal) Q 
	I vCol="GLEFDBCH" D vCoMfSEY(vOid,vVal) Q 
	I vCol="GLEFDCR" D vCoMfSEZ(vOid,vVal) Q 
	I vCol="GLEFDDR" D vCoMfSFA(vOid,vVal) Q 
	I vCol="GLPGM" D vCoMfSFB(vOid,vVal) Q 
	I vCol="GLS" D vCoMfSFC(vOid,vVal) Q 
	I vCol="GLSBO" D vCoMfSFD(vOid,vVal) Q 
	I vCol="GLTS" D vCoMfSFE(vOid,vVal) Q 
	I vCol="GLTSFP" D vCoMfSFF(vOid,vVal) Q 
	I vCol="GLTSTO" D vCoMfSFG(vOid,vVal) Q 
	I vCol="GLTSTS" D vCoMfSFH(vOid,vVal) Q 
	I vCol="GLXFR" D vCoMfSFI(vOid,vVal) Q 
	I vCol="GRACE" D vCoMfSFJ(vOid,vVal) Q 
	I vCol="HANG" D vCoMfSFK(vOid,vVal) Q 
	I vCol="HBTYPE" D vCoMfSFL(vOid,vVal) Q 
	I vCol="HISTRPT" D vCoMfSFM(vOid,vVal) Q 
	I vCol="HOTLIN" D vCoMfSFN(vOid,vVal) Q 
	I vCol="IAD1" D vCoMfSFO(vOid,vVal) Q 
	I vCol="IAD2" D vCoMfSFP(vOid,vVal) Q 
	I vCol="IAD3" D vCoMfSFQ(vOid,vVal) Q 
	I vCol="IBILFF" D vCoMfSFR(vOid,vVal) Q 
	I vCol="ICCFF" D vCoMfSFS(vOid,vVal) Q 
	I vCol="ICCFR" D vCoMfSFT(vOid,vVal) Q 
	I vCol="ICCLD" D vCoMfSFU(vOid,vVal) Q 
	I vCol="ICCND" D vCoMfSFV(vOid,vVal) Q 
	I vCol="ICCNF" D vCoMfSFW(vOid,vVal) Q 
	I vCol="ICDFF" D vCoMfSFX(vOid,vVal) Q 
	I vCol="ICDFR" D vCoMfSFY(vOid,vVal) Q 
	I vCol="ICDLD" D vCoMfSFZ(vOid,vVal) Q 
	I vCol="ICDND" D vCoMfSGA(vOid,vVal) Q 
	I vCol="ICDNF" D vCoMfSGB(vOid,vVal) Q 
	I vCol="ICDRF" D vCoMfSGC(vOid,vVal) Q 
	I vCol="ICDTF" D vCoMfSGD(vOid,vVal) Q 
	I vCol="ICITY" D vCoMfSGE(vOid,vVal) Q 
	I vCol="ICLFF" D vCoMfSGF(vOid,vVal) Q 
	I vCol="ICLFR" D vCoMfSGG(vOid,vVal) Q 
	I vCol="ICLLD" D vCoMfSGH(vOid,vVal) Q 
	I vCol="ICLND" D vCoMfSGI(vOid,vVal) Q 
	I vCol="ICLNF" D vCoMfSGJ(vOid,vVal) Q 
	I vCol="ICLRF" D vCoMfSGK(vOid,vVal) Q 
	I vCol="ICLTF" D vCoMfSGL(vOid,vVal) Q 
	I vCol="ICNTRY" D vCoMfSGM(vOid,vVal) Q 
	I vCol="IEDS" D vCoMfSGN(vOid,vVal) Q 
	I vCol="IEIN" D vCoMfSGO(vOid,vVal) Q 
	I vCol="IMAGE" D vCoMfSGP(vOid,vVal) Q 
	I vCol="IMAGESYMBL" D vCoMfSGQ(vOid,vVal) Q 
	I vCol="INAME" D vCoMfSGR(vOid,vVal) Q 
	I vCol="INAME2" D vCoMfSGS(vOid,vVal) Q 
	I vCol="INQBAL" D vCoMfSGT(vOid,vVal) Q 
	I vCol="INTPGM" D vCoMfSGU(vOid,vVal) Q 
	I vCol="INTPOS" D vCoMfSGV(vOid,vVal) Q 
	I vCol="INVPCTMIN" D vCoMfSGW(vOid,vVal) Q 
	I vCol="IPCID" D vCoMfSGX(vOid,vVal) Q 
	I vCol="IPD" D vCoMfSGY(vOid,vVal) Q 
	I vCol="IPETC" D vCoMfSGZ(vOid,vVal) Q 
	I vCol="IPYADJ" D vCoMfSHA(vOid,vVal) Q 
	I vCol="IRAAUT" D vCoMfSHB(vOid,vVal) Q 
	I vCol="IRACON" D vCoMfSHC(vOid,vVal) Q 
	I vCol="IRADIS" D vCoMfSHD(vOid,vVal) Q 
	I vCol="IRAHIST" D vCoMfSHE(vOid,vVal) Q 
	I vCol="IRAINT" D vCoMfSHF(vOid,vVal) Q 
	I vCol="IRAIPO" D vCoMfSHG(vOid,vVal) Q 
	I vCol="IRAIWH" D vCoMfSHH(vOid,vVal) Q 
	I vCol="IRAPEN" D vCoMfSHI(vOid,vVal) Q 
	I vCol="IRAPRGD" D vCoMfSHJ(vOid,vVal) Q 
	I vCol="ISO" D vCoMfSHK(vOid,vVal) Q 
	I vCol="ISTATE" D vCoMfSHL(vOid,vVal) Q 
	I vCol="ITSPOSPL" D vCoMfSHM(vOid,vVal) Q 
	I vCol="IWUOCC" D vCoMfSHN(vOid,vVal) Q 
	I vCol="IWUODC" D vCoMfSHO(vOid,vVal) Q 
	I vCol="IZIP" D vCoMfSHP(vOid,vVal) Q 
	I vCol="LCCADR" D vCoMfSHQ(vOid,vVal) Q 
	I vCol="LCCPU" D vCoMfSHR(vOid,vVal) Q 
	I vCol="LCCTIT" D vCoMfSHS(vOid,vVal) Q 
	I vCol="LCL" D vCoMfSHT(vOid,vVal) Q 
	I vCol="LCNBDC" D vCoMfSHU(vOid,vVal) Q 
	I vCol="LEAD" D vCoMfSHV(vOid,vVal) Q 
	I vCol="LETDEL" D vCoMfSHW(vOid,vVal) Q 
	I vCol="LETFIX" D vCoMfSHX(vOid,vVal) Q 
	I vCol="LIMPRO" D vCoMfSHY(vOid,vVal) Q 
	I vCol="LNCC" D vCoMfSHZ(vOid,vVal) Q 
	I vCol="LNCFP" D vCoMfSIA(vOid,vVal) Q 
	I vCol="LNCPI" D vCoMfSIB(vOid,vVal) Q 
	I vCol="LNCPP" D vCoMfSIC(vOid,vVal) Q 
	I vCol="LNCSCBL" D vCoMfSID(vOid,vVal) Q 
	I vCol="LNCSCOM" D vCoMfSIE(vOid,vVal) Q 
	I vCol="LNCSDM" D vCoMfSIF(vOid,vVal) Q 
	I vCol="LNCSLN" D vCoMfSIG(vOid,vVal) Q 
	I vCol="LNCSMTG" D vCoMfSIH(vOid,vVal) Q 
	I vCol="LNCSRC" D vCoMfSII(vOid,vVal) Q 
	I vCol="LNDRBY" D vCoMfSIJ(vOid,vVal) Q 
	I vCol="LNDRM" D vCoMfSIK(vOid,vVal) Q 
	I vCol="LNPROJREP" D vCoMfSIL(vOid,vVal) Q 
	I vCol="LNRENDEL" D vCoMfSIM(vOid,vVal) Q 
	I vCol="LNSUSEXT" D vCoMfSIN(vOid,vVal) Q 
	I vCol="LNSUSTP" D vCoMfSIO(vOid,vVal) Q 
	I vCol="LOGINMSG1" D vCoMfSIP(vOid,vVal) Q 
	I vCol="LOGINMSG2" D vCoMfSIQ(vOid,vVal) Q 
	I vCol="LOGINMSG3" D vCoMfSIR(vOid,vVal) Q 
	I vCol="LPCO" D vCoMfSIS(vOid,vVal) Q 
	I vCol="LPFRE" D vCoMfSIT(vOid,vVal) Q 
	I vCol="LPLD" D vCoMfSIU(vOid,vVal) Q 
	I vCol="LPND" D vCoMfSIV(vOid,vVal) Q 
	I vCol="LRNCPGM" D vCoMfSIW(vOid,vVal) Q 
	I vCol="LSP" D vCoMfSIX(vOid,vVal) Q 
	I vCol="LTCL" D vCoMfSIY(vOid,vVal) Q 
	I vCol="MAGCTRY" D vCoMfSIZ(vOid,vVal) Q 
	I vCol="MAXCIFL" D vCoMfSJA(vOid,vVal) Q 
	I vCol="MAXCOL" D vCoMfSJB(vOid,vVal) Q 
	I vCol="MAXEXT" D vCoMfSJC(vOid,vVal) Q 
	I vCol="MAXLOGFAILS" D vCoMfSJD(vOid,vVal) Q 
	I vCol="MAXPAY" D vCoMfSJE(vOid,vVal) Q 
	I vCol="MAXPM" D vCoMfSJF(vOid,vVal) Q 
	I vCol="MDO" D vCoMfSJG(vOid,vVal) Q 
	I vCol="MICR" D vCoMfSJH(vOid,vVal) Q 
	I vCol="MINAMT" D vCoMfSJI(vOid,vVal) Q 
	I vCol="MINCIFL" D vCoMfSJJ(vOid,vVal) Q 
	I vCol="MINCMAMT" D vCoMfSJK(vOid,vVal) Q 
	I vCol="MINCOL" D vCoMfSJL(vOid,vVal) Q 
	I vCol="MINPAY" D vCoMfSJM(vOid,vVal) Q 
	I vCol="MPSCERT" D vCoMfSJN(vOid,vVal) Q 
	I vCol="MRPT" D vCoMfSJO(vOid,vVal) Q 
	I vCol="MT900INT" D vCoMfSJP(vOid,vVal) Q 
	I vCol="MT910INT" D vCoMfSJQ(vOid,vVal) Q 
	I vCol="MULTIITSID" D vCoMfSJR(vOid,vVal) Q 
	I vCol="MXTRLM" D vCoMfSJS(vOid,vVal) Q 
	I vCol="NOREGD" D vCoMfSJT(vOid,vVal) Q 
	I vCol="NOSEGMENTS" D vCoMfSJU(vOid,vVal) Q 
	I vCol="NOSTPURG" D vCoMfSJV(vOid,vVal) Q 
	I vCol="NOTP" D vCoMfSJW(vOid,vVal) Q 
	I vCol="NR4BRAMT" D vCoMfSJX(vOid,vVal) Q 
	I vCol="ODP" D vCoMfSJY(vOid,vVal) Q 
	I vCol="ODPE" D vCoMfSJZ(vOid,vVal) Q 
	I vCol="ORCIFN" D vCoMfSKA(vOid,vVal) Q 
	I vCol="ORIGCRCD" D vCoMfSKB(vOid,vVal) Q 
	I vCol="OTC" D vCoMfSKC(vOid,vVal) Q 
	I vCol="PAYERNAM" D vCoMfSKD(vOid,vVal) Q 
	I vCol="PBALRTN" D vCoMfSKE(vOid,vVal) Q 
	I vCol="PBKIRN" D vCoMfSKF(vOid,vVal) Q 
	I vCol="PCTCAP" D vCoMfSKG(vOid,vVal) Q 
	I vCol="PENREVGL" D vCoMfSKH(vOid,vVal) Q 
	I vCol="PLACN" D vCoMfSKI(vOid,vVal) Q 
	I vCol="PLFEE" D vCoMfSKJ(vOid,vVal) Q 
	I vCol="PMTHIS" D vCoMfSKK(vOid,vVal) Q 
	I vCol="POINST" D vCoMfSKL(vOid,vVal) Q 
	I vCol="PRELID" D vCoMfSKM(vOid,vVal) Q 
	I vCol="PROVFREQ" D vCoMfSKN(vOid,vVal) Q 
	I vCol="PROVLPDT" D vCoMfSKO(vOid,vVal) Q 
	I vCol="PROVNPDT" D vCoMfSKP(vOid,vVal) Q 
	I vCol="PROVOFF" D vCoMfSKQ(vOid,vVal) Q 
	I vCol="PROVRCDT" D vCoMfSKR(vOid,vVal) Q 
	I vCol="PROVRPDT" D vCoMfSKS(vOid,vVal) Q 
	I vCol="PROWNR" D vCoMfSKT(vOid,vVal) Q 
	I vCol="PRYRBKD" D vCoMfSKU(vOid,vVal) Q 
	I vCol="PSWAUT" D vCoMfSKV(vOid,vVal) Q 
	I vCol="PSWDH" D vCoMfSKW(vOid,vVal) Q 
	I vCol="PTMDIRID" D vCoMfSKX(vOid,vVal) Q 
	I vCol="PUBLISH" D vCoMfSKY(vOid,vVal) Q 
	I vCol="RECEIPT" D vCoMfSKZ(vOid,vVal) Q 
	I vCol="RECPT" D vCoMfSLA(vOid,vVal) Q 
	I vCol="REGCC1" D vCoMfSLB(vOid,vVal) Q 
	I vCol="REGCC2" D vCoMfSLC(vOid,vVal) Q 
	I vCol="REGCC3" D vCoMfSLD(vOid,vVal) Q 
	I vCol="REGCC4" D vCoMfSLE(vOid,vVal) Q 
	I vCol="REGCC5" D vCoMfSLF(vOid,vVal) Q 
	I vCol="REGCC6" D vCoMfSLG(vOid,vVal) Q 
	I vCol="REGCCNAM" D vCoMfSLH(vOid,vVal) Q 
	I vCol="REGCCOPT" D vCoMfSLI(vOid,vVal) Q 
	I vCol="REGCCRO" D vCoMfSLJ(vOid,vVal) Q 
	I vCol="REGFLG" D vCoMfSLK(vOid,vVal) Q 
	I vCol="REKEY" D vCoMfSLL(vOid,vVal) Q 
	I vCol="RELID" D vCoMfSLM(vOid,vVal) Q 
	I vCol="REPLY" D vCoMfSLN(vOid,vVal) Q 
	I vCol="RESPROC" D vCoMfSLO(vOid,vVal) Q 
	I vCol="RESTRICT" D vCoMfSLP(vOid,vVal) Q 
	I vCol="RETOPT" D vCoMfSLQ(vOid,vVal) Q 
	I vCol="RFC" D vCoMfSLR(vOid,vVal) Q 
	I vCol="RFR" D vCoMfSLS(vOid,vVal) Q 
	I vCol="RLCID" D vCoMfSLT(vOid,vVal) Q 
	I vCol="RLETC" D vCoMfSLU(vOid,vVal) Q 
	I vCol="RMC" D vCoMfSLV(vOid,vVal) Q 
	I vCol="RMR" D vCoMfSLW(vOid,vVal) Q 
	I vCol="RPAFEE" D vCoMfSLX(vOid,vVal) Q 
	I vCol="RPANET" D vCoMfSLY(vOid,vVal) Q 
	I vCol="RPTNAM" D vCoMfSLZ(vOid,vVal) Q 
	I vCol="RSPPLID" D vCoMfSMA(vOid,vVal) Q 
	I vCol="RT" D vCoMfSMB(vOid,vVal) Q 
	I vCol="RTNFPGL" D vCoMfSMC(vOid,vVal) Q 
	I vCol="SBACQTO" D vCoMfSMD(vOid,vVal) Q 
	I vCol="SBI" D vCoMfSME(vOid,vVal) Q 
	I vCol="SBINSTNO" D vCoMfSMF(vOid,vVal) Q 
	I vCol="SBSTDT" D vCoMfSMG(vOid,vVal) Q 
	I vCol="SCAUREL" D vCoMfSMH(vOid,vVal) Q 
	I vCol="SCDFT" D vCoMfSMI(vOid,vVal) Q 
	I vCol="SCHRCC" D vCoMfSMJ(vOid,vVal) Q 
	I vCol="SCHRCE" D vCoMfSMK(vOid,vVal) Q 
	I vCol="SCHRCJ" D vCoMfSML(vOid,vVal) Q 
	I vCol="SCHRCK" D vCoMfSMM(vOid,vVal) Q 
	I vCol="SCHRCL" D vCoMfSMN(vOid,vVal) Q 
	I vCol="SCHRCN" D vCoMfSMO(vOid,vVal) Q 
	I vCol="SCHRI" D vCoMfSMP(vOid,vVal) Q 
	I vCol="SCOVR" D vCoMfSMQ(vOid,vVal) Q 
	I vCol="SDRIFTRN" D vCoMfSMR(vOid,vVal) Q 
	I vCol="SDRSPTRN" D vCoMfSMS(vOid,vVal) Q 
	I vCol="SFEEOPT" D vCoMfSMT(vOid,vVal) Q 
	I vCol="SLDGLTC" D vCoMfSMU(vOid,vVal) Q 
	I vCol="SPLDIR" D vCoMfSMV(vOid,vVal) Q 
	I vCol="SPLITDAY" D vCoMfSMW(vOid,vVal) Q 
	I vCol="STFREJ" D vCoMfSMX(vOid,vVal) Q 
	I vCol="STMLCC" D vCoMfSMY(vOid,vVal) Q 
	I vCol="STMTCDSKIP" D vCoMfSMZ(vOid,vVal) Q 
	I vCol="STMTCUMUL" D vCoMfSNA(vOid,vVal) Q 
	I vCol="STMTINTRTC" D vCoMfSNB(vOid,vVal) Q 
	I vCol="STMTLNSKIP" D vCoMfSNC(vOid,vVal) Q 
	I vCol="STMTSRTD" D vCoMfSND(vOid,vVal) Q 
	I vCol="STMTSRTL" D vCoMfSNE(vOid,vVal) Q 
	I vCol="STPOF" D vCoMfSNF(vOid,vVal) Q 
	I vCol="SWIFTADD" D vCoMfSNG(vOid,vVal) Q 
	I vCol="SYSABR" D vCoMfSNH(vOid,vVal) Q 
	I vCol="T4RIFTRN" D vCoMfSNI(vOid,vVal) Q 
	I vCol="T4RSPTRN" D vCoMfSNJ(vOid,vVal) Q 
	I vCol="T5FID" D vCoMfSNK(vOid,vVal) Q 
	I vCol="T5RAMT" D vCoMfSNL(vOid,vVal) Q 
	I vCol="T5TRN" D vCoMfSNM(vOid,vVal) Q 
	I vCol="TAXREQ" D vCoMfSNN(vOid,vVal) Q 
	I vCol="TAXYE" D vCoMfSNO(vOid,vVal) Q 
	I vCol="TAXYEOFF" D vCoMfSNP(vOid,vVal) Q 
	I vCol="TBLS" D vCoMfSNQ(vOid,vVal) Q 
	I vCol="TCC" D vCoMfSNR(vOid,vVal) Q 
	I vCol="TCECR" D vCoMfSNS(vOid,vVal) Q 
	I vCol="TCEDR" D vCoMfSNT(vOid,vVal) Q 
	I vCol="TCPVER" D vCoMfSNU(vOid,vVal) Q 
	I vCol="TELEPHONE" D vCoMfSNV(vOid,vVal) Q 
	I vCol="TFS" D vCoMfSNW(vOid,vVal) Q 
	I vCol="TFSL" D vCoMfSNX(vOid,vVal) Q 
	I vCol="TFSP" D vCoMfSNY(vOid,vVal) Q 
	I vCol="TFSPOSPL" D vCoMfSNZ(vOid,vVal) Q 
	I vCol="TINCO" D vCoMfSOA(vOid,vVal) Q 
	I vCol="TJD" D vCoMfSOB(vOid,vVal) Q 
	I vCol="TLOPRE" D vCoMfSOC(vOid,vVal) Q 
	I vCol="TLOREL" D vCoMfSOD(vOid,vVal) Q 
	I vCol="TMSRSND" D vCoMfSOE(vOid,vVal) Q 
	I vCol="TOTASS" D vCoMfSOF(vOid,vVal) Q 
	I vCol="TOTCAP" D vCoMfSOG(vOid,vVal) Q 
	I vCol="TPREL" D vCoMfSOH(vOid,vVal) Q 
	I vCol="TREF" D vCoMfSOI(vOid,vVal) Q 
	I vCol="TREL" D vCoMfSOJ(vOid,vVal) Q 
	I vCol="UACND1F" D vCoMfSOK(vOid,vVal) Q 
	I vCol="UACNL1F" D vCoMfSOL(vOid,vVal) Q 
	I vCol="UCID" D vCoMfSOM(vOid,vVal) Q 
	I vCol="UCIF1F" D vCoMfSON(vOid,vVal) Q 
	I vCol="UCSSERV" D vCoMfSOO(vOid,vVal) Q 
	I vCol="UDRC" D vCoMfSOP(vOid,vVal) Q 
	I vCol="USEGOPT" D vCoMfSOQ(vOid,vVal) Q 
	I vCol="USERNAME" D vCoMfSOR(vOid,vVal) Q 
	I vCol="USERPREL" D vCoMfSOS(vOid,vVal) Q 
	I vCol="USERREL" D vCoMfSOT(vOid,vVal) Q 
	I vCol="USRESTAT" D vCoMfSOU(vOid,vVal) Q 
	I vCol="VADDR" D vCoMfSOV(vOid,vVal) Q 
	I vCol="VAT" D vCoMfSOW(vOid,vVal) Q 
	I vCol="VCCODE" D vCoMfSOX(vOid,vVal) Q 
	I vCol="VCITY" D vCoMfSOY(vOid,vVal) Q 
	I vCol="VCNAME" D vCoMfSOZ(vOid,vVal) Q 
	I vCol="VDT" D vCoMfSPA(vOid,vVal) Q 
	I vCol="VDTFWD" D vCoMfSPB(vOid,vVal) Q 
	I vCol="VEMAIL" D vCoMfSPC(vOid,vVal) Q 
	I vCol="VNAME" D vCoMfSPD(vOid,vVal) Q 
	I vCol="VPHONE" D vCoMfSPE(vOid,vVal) Q 
	I vCol="VSTATE" D vCoMfSPF(vOid,vVal) Q 
	I vCol="VZIP" D vCoMfSPG(vOid,vVal) Q 
	I vCol="XACN" D vCoMfSPH(vOid,vVal) Q 
	I vCol="YEOFF" D vCoMfSPI(vOid,vVal) Q 
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
vCoInd2(vOid,vCol)	; RecordCUVAR.getColumn()
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("CUVAR",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" D  Q @vCmp
	.	N vpt
	.	D parseCmp^UCXDD(vCmp,.vpt)
	.	N vCnt S vCnt=$order(vpt(""),-1)
	.	N vVal
	.	N vElm
	.	S vCmp=""
	.	F vElm=2:2:vCnt S vCmp=vCmp_vpt(vElm-1)_$$QADD^%ZS(($$vCoInd2(vOid,vpt(vElm))),"""")
	.	S vCmp=vCmp_vpt(vCnt)
	.	Q 
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) S vobj(vOid,vNod)=$get(^CUVAR(vNod))
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
vDbNew1()	;	vobj()=Class.new(CUVAR)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCUVAR",vobj(vOid,-2)=0
	Q vOid
