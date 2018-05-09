V00S060	;; -  - 5.3 - SID= <DBTBL1H> Files Definition - Detail (HELP)
	;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,DI,fDBTBL1D",VSID="DBTBL1H",VPGM=$T(+0),VSNAME="Files Definition - Detail (HELP)"
	S VFSN("DBTBL1D")="fDBTBL1D"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
V5	I %O=5 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
	;
	I '%O D VNEW,VPR,VDA
	I %O D VLOD Q:$G(ER)  D VPR,VDA
	;
	; ====================  Display Form
	;
	D ^DBSPNT()
	;
	I %O=2!(%O=3) D ^DBSCRT8A X:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	;
	; ====================  Set up data entry control table
	;
vTBL	I %O<2 D VTAB
	Q
	;
VNEW	; Initialize arrays if %O=0
	;
	D VLOD
	;
	;
VDEF	;
	;
	I ($G(%LIBS)="")!($G(FID)="")!($G(DI)="") Q
	I $G(^DBTBL(%LIBS,1,FID,9,DI))'="" Q  ; Already created
	S fDBTBL1D=$G(fDBTBL1D)
	I $P(fDBTBL1D,"|",11)="" S $P(fDBTBL1D,"|",11)="S"   ; DBTBL1D.ITP
	I $P(fDBTBL1D,"|",31)="" S $P(fDBTBL1D,"|",31)=0   ; DBTBL1D.NULLIND
	I $P(fDBTBL1D,"|",9)="" S $P(fDBTBL1D,"|",9)="T"   ; DBTBL1D.TYP
	Q
	Q
VNEWDQ	; Original VNEW section
	;
	S fDBTBL1D=$G(fDBTBL1D)
	Q
VLOD	; User defined access section
	;
	;
	Q
VLODDQ	; Original VLOD section
	;
	S fDBTBL1D=^DBTBL(%LIBS,1,FID,9,DI)
	Q
VPR	; Display screen prompts
	;
	S VO="59||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,1,79,2,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(4)=$C(3,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(3,14,11,1,0,0,0,0,0,0)_"01T Data Item:"
	S VO(6)=$C(3,41,6,0,54,0,0,0,0,0)_"01T File:"
	S VO(7)=$C(3,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(4,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(5,12,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(12)=$C(5,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,8,17,1,0,0,0,0,0,0)_"01T Type <TN$DCLUF>:"
	S VO(17)=$C(7,38,16,1,0,0,0,0,0,0)_"01T Maximum Length:"
	S VO(18)=$C(7,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(19)=$C(8,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(8,15,10,0,0,0,0,0,0,0)_"01T Field ID:"
	S VO(21)=$C(8,45,9,0,0,0,0,0,0,0)_"01TPosition:"
	S VO(22)=$C(8,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(9,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(9,2,23,0,0,0,0,0,0,0)_"01T Report Column Heading:"
	S VO(25)=$C(9,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(10,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(10,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(11,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(11,30,19,0,0,0,0,0,0,0)_"01T Computed Operation"
	S VO(30)=$C(11,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(31)=$C(12,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(32)=$C(12,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(13,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(34)=$C(13,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(14,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(14,6,19,0,0,0,0,0,0,0)_"01TLook-up Table Name:"
	S VO(37)=$C(14,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(15,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(39)=$C(15,11,14,0,0,0,0,0,0,0)_"01TPattern Check:"
	S VO(40)=$C(15,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(16,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(16,11,14,0,0,0,0,0,0,0)_"01TDefault Value:"
	S VO(43)=$C(16,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(17,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(45)=$C(17,11,14,0,0,0,0,0,0,0)_"01TMinimum Value:"
	S VO(46)=$C(17,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(18,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(18,11,14,0,0,0,0,0,0,0)_"01TMaximum Value:"
	S VO(49)=$C(18,57,18,0,0,0,0,0,0,0)_"01TDecimal Precision:"
	S VO(50)=$C(18,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(51)=$C(19,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(52)=$C(19,11,14,0,0,0,0,0,0,0)_"01TPre Processor:"
	S VO(53)=$C(19,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(54)=$C(20,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(55)=$C(20,10,15,0,0,0,0,0,0,0)_"01TPost Processor:"
	S VO(56)=$C(20,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(57)=$C(21,1,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(58)=$C(21,79,1,2,0,0,0,0,0,0)_"11Tx"
	S VO(59)=$C(22,1,79,2,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	Q
VDA	; Display screen data
	N V
	I %O=5 N fDBTBL1D
	I  S (fDBTBL1D)=""
	E  S fDBTBL1D=$G(fDBTBL1D)
	;
	S %FID=$G(%FID)
	S DI=$G(DI)
	;
	S VO="76|60|13|0"
	S VO(60)=$C(3,26,12,2,0,0,0,0,0,0)_"00U"_$G(DI)
	S VO(61)=$C(3,48,0,2,0,0,0,0,0,0)_"01T"_$G(%FID)
	S VO(62)=$C(5,26,40,2,0,0,0,0,0,0)_"00T"_$P(fDBTBL1D,"|",10)
	S VO(63)=$C(7,26,1,2,0,0,0,0,0,0)_"00U"_$P(fDBTBL1D,"|",9)
	S VO(64)=$C(7,55,5,2,0,0,0,0,0,0)_"00N"_$P(fDBTBL1D,"|",2)
	S VO(65)=$C(8,26,12,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",1)
	S VO(66)=$C(8,58,2,2,0,0,0,0,0,0)_"01N"_$P(fDBTBL1D,"|",21)
	S VO(67)=$C(9,26,40,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",22)
	S VO(68)=$C(12,5,70,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",16)
	S VO(69)=$C(14,26,50,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",5)
	S VO(70)=$C(15,26,50,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",6)
	S VO(71)=$C(16,26,50,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",3)
	S VO(72)=$C(17,26,30,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",12)
	S VO(73)=$C(18,26,30,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",13)
	S VO(74)=$C(18,76,2,2,0,0,0,0,0,0)_"00N"_$P(fDBTBL1D,"|",14)
	S VO(75)=$C(19,26,50,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",8)
	S VO(76)=$C(20,26,50,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL1D,"|",7)
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=17,VPT=1,VPB=22,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL1D"
	S OLNTB=22001
	;
	S VFSN("DBTBL1D")="fDBTBL1D"
	;
	; 
	;
	;
	; ===============  Set up entry/error checking control table
	;
VTAB1	D VTBL
	;
	D ^DBSCRT8 Q  ; data entry
	;
	Q
VREQ	; Create REQ() array
	;
	;
	Q
	;
VTBL	; Create %TAB(array)
	;
	; 1 2 3  4 5   6   7-9 10-11
	;
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	S %TAB(1)=$C(2,25,12)_"01U|*DI|[*]@DI|^DBTBL(%LIBS,1,FID,9,#10"
	S %TAB(2)=$C(2,47,0)_"20T|*%FID|[*]@ooe8"
	S %TAB(3)=$C(4,25,40)_"01T12410||[DBTBL1D]DES"
	S %TAB(4)=$C(6,25,1)_"01U12409||[DBTBL1D]TYP|[DBCTLDVFM]"
	S %TAB(5)=$C(6,54,5)_"01N12402||[DBTBL1D]LEN|||||||||7"
	S %TAB(6)=$C(7,25,12)_"20T12401||[DBTBL1D]NOD|||||||||26"
	S %TAB(7)=$C(7,57,2)_"20N12421||[DBTBL1D]POS"
	S %TAB(8)=$C(8,25,40)_"21T12422||[DBTBL1D]RHD"
	S %TAB(9)=$C(11,4,70)_"20T12416||[DBTBL1D]CMP|||||||||255"
	S %TAB(10)=$C(13,25,50)_"20T12405||[DBTBL1D]TBL|||||||||255"
	S %TAB(11)=$C(14,25,50)_"20T12406||[DBTBL1D]PTN|||||||||60"
	S %TAB(12)=$C(15,25,50)_"20T12403||[DBTBL1D]DFT|||||||||58"
	S %TAB(13)=$C(16,25,30)_"20T12412||[DBTBL1D]MIN"
	S %TAB(14)=$C(17,25,30)_"20T12413||[DBTBL1D]MAX"
	S %TAB(15)=$C(17,75,2)_"00N12414||[DBTBL1D]DEC|||||0|18"
	S %TAB(16)=$C(18,25,50)_"20T12408||[DBTBL1D]XPR|||||||||58"
	S %TAB(17)=$C(19,25,50)_"20T12407||[DBTBL1D]XPO|||||||||58"
	;
	Q
	;
	;
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
