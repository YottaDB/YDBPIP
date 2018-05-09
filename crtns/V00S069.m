 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL33B ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S069(%O,fDBTBL33) ; DBS -  - SID= <DBTBL33B> Batch Definition (HTM)
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fDBTBL33)#2)  K vobj(+$G(fDBTBL33)) S fDBTBL33=$$vcdmNew^RecordDBTBL33()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL33B" S VPGM=$T(+0) S VSNAME="Batch Definition (HTM)"
 S VFSN("DBTBL33")="zfDBTBL33"
 S vPSL=1
 S KEYS(1)=vobj(fDBTBL33,-3)
 S KEYS(2)=vobj(fDBTBL33,-4)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.fDBTBL33) D VDA1(.fDBTBL33) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.fDBTBL33) D VPR(.fDBTBL33) D VDA1(.fDBTBL33)
 I %O D VLOD(.fDBTBL33) Q:$get(ER)  D VPR(.fDBTBL33) D VDA1(.fDBTBL33)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fDBTBL33)
 Q 
 ;
VNEW(fDBTBL33) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBTBL33)
 D VLOD(.fDBTBL33)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBTBL33) ; 
 Q:(vobj(fDBTBL33,-3)="")!(vobj(fDBTBL33,-4)="") 
 Q:%O  S ER=0 I (vobj(fDBTBL33,-3)="")!(vobj(fDBTBL33,-4)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,BCHID") Q 
  N V1,V2 S V1=vobj(fDBTBL33,-3),V2=vobj(fDBTBL33,-4) I ($D(^DBTBL(V1,33,V2))#2) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(fDBTBL33),$C(124),3)=""  S:'$D(vobj(fDBTBL33,-100,"0*","LTD")) vobj(fDBTBL33,-100,"0*","LTD")="D003"_$P(vobj(fDBTBL33),$C(124),3),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),3)=+$H
 I $P(vobj(fDBTBL33),$C(124),12)=""  S:'$D(vobj(fDBTBL33,-100,"0*","MAXSIZE")) vobj(fDBTBL33,-100,"0*","MAXSIZE")="N012"_$P(vobj(fDBTBL33),$C(124),12),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),12)=32000
 I $P(vobj(fDBTBL33),$C(124),11)=""  S:'$D(vobj(fDBTBL33,-100,"0*","MSGBUFS")) vobj(fDBTBL33,-100,"0*","MSGBUFS")="N011"_$P(vobj(fDBTBL33),$C(124),11),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),11)=100
 I $P(vobj(fDBTBL33),$C(124),17)=""  S:'$D(vobj(fDBTBL33,-100,"0*","SCHTIMR")) vobj(fDBTBL33,-100,"0*","SCHTIMR")="N017"_$P(vobj(fDBTBL33),$C(124),17),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),17)=10
 I $P(vobj(fDBTBL33),$C(124),18)=""  S:'$D(vobj(fDBTBL33,-100,"0*","THRTIMR")) vobj(fDBTBL33,-100,"0*","THRTIMR")="N018"_$P(vobj(fDBTBL33),$C(124),18),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),18)=10
 I $P(vobj(fDBTBL33),$C(124),5)=""  S:'$D(vobj(fDBTBL33,-100,"0*","TIME")) vobj(fDBTBL33,-100,"0*","TIME")="C005"_$P(vobj(fDBTBL33),$C(124),5),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),5)=$piece($H,",",2)
 I $P(vobj(fDBTBL33),$C(124),4)=""  S:'$D(vobj(fDBTBL33,-100,"0*","USER")) vobj(fDBTBL33,-100,"0*","USER")="T004"_$P(vobj(fDBTBL33),$C(124),4),vobj(fDBTBL33,-100,"0*")="" S $P(vobj(fDBTBL33),$C(124),4)=%UID
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBTBL33) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBTBL33) ; Display screen prompts
 S VO="46||13|0"
 S VO(0)="|0"
 S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(4)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(5)=$C(4,24,19,0,0,0,0,0,0,0)_"01T Number of Threads:"
 S VO(6)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(8)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(9)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(10)=$C(6,16,27,0,0,0,0,0,0,0)_"01T Number of Message Buffers:"
 S VO(11)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(12)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(13)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(14)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(15)=$C(8,22,21,0,0,0,0,0,0,0)_"01T Message Buffer Size:"
 S VO(16)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(17)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(19)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(20)=$C(10,2,16,0,0,0,0,0,0,0)_"01T Thread Context:"
 S VO(21)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(22)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(23)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(24)=$C(12,16,27,0,0,0,0,0,0,0)_"01T Non-Random Message Access:"
 S VO(25)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(26)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(27)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(28)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(29)=$C(14,2,41,0,0,0,0,0,0,0)_"01T Job Monitor Update Interval - Scheduler:"
 S VO(30)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(31)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(32)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(33)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(34)=$C(16,4,39,0,0,0,0,0,0,0)_"01T Job Monitor Update Interval - Threads:"
 S VO(35)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(37)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(38)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(39)=$C(18,14,29,0,0,0,0,0,0,0)_"01T Scheduler Timeout (seconds):"
 S VO(40)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(41)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(42)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(43)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(44)=$C(20,27,16,0,0,0,0,0,0,0)_"01T Thread Timeout:"
 S VO(45)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(46)=$C(21,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fDBTBL33) ; Display screen data
 N V
 ;
 S VO="56|47|13|0"
 S VO(47)=$C(1,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^UTLREAD($get(%FN)))
 S VO(48)=$C(4,44,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),10)
 S VO(49)=$C(6,44,4,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),11)
 S VO(50)=$C(8,44,5,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),12)
 S VO(51)=$C(10,19,62,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL33),$C(124),13),1,80)
 S VO(52)=$C(12,44,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL33),$C(124),14):"Y",1:"N")
 S VO(53)=$C(14,44,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),15)
 S VO(54)=$C(16,44,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),16)
 S VO(55)=$C(18,44,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),17)
 S VO(56)=$C(20,44,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL33),$C(124),18)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL33) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=9 S VPT=1 S VPB=21 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL33"
 S OLNTB=21001
 ;
 S VFSN("DBTBL33")="zfDBTBL33"
 ;
 ;
 S %TAB(1)=$C(3,43,2)_"00N12410|1|[DBTBL33]THREADS"
 S %TAB(2)=$C(5,43,4)_"00N12411|1|[DBTBL33]MSGBUFS"
 S %TAB(3)=$C(7,43,5)_"00N12412|1|[DBTBL33]MAXSIZE"
 S %TAB(4)=$C(9,18,62)_"00T12413|1|[DBTBL33]THRLVAR|||||||||80"
 S %TAB(5)=$C(11,43,1)_"00L12414|1|[DBTBL33]NONRAND"
 S %TAB(6)=$C(13,43,12)_"00N12415|1|[DBTBL33]SCHRCNT"
 S %TAB(7)=$C(15,43,12)_"00N12416|1|[DBTBL33]THRRCNT"
 S %TAB(8)=$C(17,43,2)_"00N12417|1|[DBTBL33]SCHTIMR"
 S %TAB(9)=$C(19,43,2)_"00N12418|1|[DBTBL33]THRTIMR"
 D VTBL(.fDBTBL33)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBTBL33) ; Create %TAB(array)
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
 D VPR(.fDBTBL33)
 D VDA1(.fDBTBL33)
 D ^DBSPNT()
 Q 
 ;
VW(fDBTBL33) ; 
 D VDA1(.fDBTBL33)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBTBL33) ; 
 D VDA1(.fDBTBL33)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBTBL33)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL33" D vSET1(.fDBTBL33,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBTBL33,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL33,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL33" Q $$vREAD1(.fDBTBL33,di)
 Q ""
vREAD1(fDBTBL33,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL33,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
