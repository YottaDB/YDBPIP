V01S218(%O,fDBTBL1)	; -  - SID= <DBSDBE> Data Entry Definition Screen
	;
	; **** Routine compiled from DATA-QWIK Screen DBSDBE ****
	;
	; 09/14/2007 09:14 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 09:14 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fDBTBL1)#2) K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vDbNew1("","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBSDBE" S VPGM=$T(+0) S VSNAME="Data Entry Definition Screen"
	S VFSN("DBTBL1")="zfDBTBL1"
	S vPSL=1
	S KEYS(1)=vobj(fDBTBL1,-3)
	S KEYS(2)=vobj(fDBTBL1,-4)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fDBTBL1) D VDA1(.fDBTBL1) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.fDBTBL1) D VPR(.fDBTBL1) D VDA1(.fDBTBL1)
	I %O D VLOD(.fDBTBL1) Q:$get(ER)  D VPR(.fDBTBL1) D VDA1(.fDBTBL1)
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
	S VO="28||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,1,11,0,0,0,0,0,0,0)_"01T File Name:"
	S VO(2)=$C(2,2,17,0,0,0,0,0,0,0)_"01TFile Description:"
	S VO(3)=$C(3,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(4)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(4,28,22,0,0,0,0,0,0,0)_"01TData Entry Definitions"
	S VO(6)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(7,7,19,0,0,0,0,0,0,0)_"01TData Entry Screen :"
	S VO(13)=$C(7,45,29,0,0,0,0,0,0,0)_"01TMaintenance Restriction Flag:"
	S VO(14)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(8,48,26,0,0,0,0,0,0,0)_"01TDeletion Restriction Flag:"
	S VO(17)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(19)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(10,26,24,0,0,0,0,0,0,0)_"01TData Entry Pre-Processor"
	S VO(22)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(14,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL1)	; Display screen data
	 S:'$D(vobj(fDBTBL1,22)) vobj(fDBTBL1,22)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),22)),1:"")
	N V
	;
	S VO="35|29|13|0"
	S VO(29)=$C(1,13,30,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL1,-4)),1,30)
	S VO(30)=$C(1,58,8,2,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$TIM^%ZM)
	S VO(31)=$C(2,20,40,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL1),$C(124),1)),1,40)
	S VO(32)=$C(7,27,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1,22),$C(124),8)),1,12)
	S VO(33)=$C(7,75,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,22),$C(124),9):"Y",1:"N")
	S VO(34)=$C(8,75,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,22),$C(124),10):"Y",1:"N")
	S VO(35)=$C(11,3,78,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL1,22),$C(124),5)),1,255)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL1)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=6 S VPT=1 S VPB=14 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1"
	S OLNTB=14001
	;
	S VFSN("DBTBL1")="zfDBTBL1"
	;
	;
	S %TAB(1)=$C(0,12,30)_"21U12402|1|[DBTBL1]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||256"
	S %TAB(2)=$C(1,19,40)_"21T12401|1|[DBTBL1]DES"
	S %TAB(3)=$C(6,26,12)_"00U12408|1|[DBTBL1]SCREEN|[DBTBL2]"
	S %TAB(4)=$C(6,74,1)_"00L12409|1|[DBTBL1]RFLAG"
	S %TAB(5)=$C(7,74,1)_"00L12410|1|[DBTBL1]DFLAG"
	S %TAB(6)=$C(10,2,78)_"00T12405|1|[DBTBL1]PREDAEN|||||||||255"
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
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL1)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
