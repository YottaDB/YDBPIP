 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBSDBE ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S045(%O,fDBTBL1) ; -  - SID= <DBSDBE> Data Entry Definition Screen
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
VDA1(fDBTBL1) ; Display screen data
  S:'$D(vobj(fDBTBL1,22)) vobj(fDBTBL1,22)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),22)),1:"")
 N V
 ;
 S VO="35|29|13|0"
 S VO(29)=$C(1,13,30,2,0,0,0,0,0,0)_"01T"_$E(vobj(fDBTBL1,-4),1,30)
 S VO(30)=$C(1,58,8,2,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$TIM^%ZM)
 S VO(31)=$C(2,20,40,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL1),$C(124),1),1,40)
 S VO(32)=$C(7,27,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1,22),$C(124),8),1,12)
 S VO(33)=$C(7,75,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,22),$C(124),9):"Y",1:"N")
 S VO(34)=$C(8,75,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL1,22),$C(124),10):"Y",1:"N")
 S VO(35)=$C(11,3,78,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL1,22),$C(124),5),1,255)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL1) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=6 S VPT=1 S VPB=14 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1"
 S OLNTB=14001
 ;
 S VFSN("DBTBL1")="zfDBTBL1"
 ;
 ;
 S %TAB(1)=$C(0,12,30)_"21U12402|1|[DBTBL1]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)"
 S %TAB(2)=$C(1,19,40)_"21T12401|1|[DBTBL1]DES"
 S %TAB(3)=$C(6,26,12)_"00U12408|1|[DBTBL1]SCREEN|[DBTBL2]"
 S %TAB(4)=$C(6,74,1)_"00L12409|1|[DBTBL1]RFLAG"
 S %TAB(5)=$C(7,74,1)_"00L12410|1|[DBTBL1]DFLAG"
 S %TAB(6)=$C(10,2,78)_"00T12405|1|[DBTBL1]PREDAEN|||||||||255"
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
