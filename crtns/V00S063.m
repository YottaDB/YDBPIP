 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL2 ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S063(%O,DBTBL2) ; DBS - DBS - SID= <DBTBL2> Screen Definition
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(DBTBL2)#2)  K vobj(+$G(DBTBL2)) S DBTBL2=$$vcdmNew^RecordDBTBL2()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL2" S VPGM=$T(+0) S VSNAME="Screen Definition"
 S VFSN("DBTBL2")="zDBTBL2"
 S vPSL=1
 S KEYS(1)=vobj(DBTBL2,-3)
 S KEYS(2)=vobj(DBTBL2,-4)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.DBTBL2) D VDA1(.DBTBL2) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.DBTBL2) D VPR(.DBTBL2) D VDA1(.DBTBL2)
 I %O D VLOD(.DBTBL2) Q:$get(ER)  D VPR(.DBTBL2) D VDA1(.DBTBL2)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.DBTBL2)
 Q 
 ;
VNEW(DBTBL2) ; Initialize arrays if %O=0
 ;
 D VDEF(.DBTBL2)
 D VLOD(.DBTBL2)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(DBTBL2) ; 
  S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
 Q:(vobj(DBTBL2,-3)="")!(vobj(DBTBL2,-4)="") 
 Q:%O  S ER=0 I (vobj(DBTBL2,-3)="")!(vobj(DBTBL2,-4)="") S ER=1 S RM=$$^MSG(1767,"LIBS,SID") Q 
  N V1,V2 S V1=vobj(DBTBL2,-3),V2=vobj(DBTBL2,-4) I ($D(^DBTBL(V1,2,V2))) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(DBTBL2,0),$C(124),3)=""  S:'$D(vobj(DBTBL2,-100,0,"DATE")) vobj(DBTBL2,-100,0,"DATE")="D003"_$P(vobj(DBTBL2,0),$C(124),3),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),3)=+$H
 I $P(vobj(DBTBL2,0),$C(124),17)=""  S:'$D(vobj(DBTBL2,-100,0,"OOE")) vobj(DBTBL2,-100,0,"OOE")="L017"_$P(vobj(DBTBL2,0),$C(124),17),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),17)=1
 I $P(vobj(DBTBL2,0),$C(124),14)=""  S:'$D(vobj(DBTBL2,-100,0,"OUTFMT")) vobj(DBTBL2,-100,0,"OUTFMT")="T014"_$P(vobj(DBTBL2,0),$C(124),14),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),14)="VT220"
 I $P(vobj(DBTBL2,0),$C(124),7)=""  S:'$D(vobj(DBTBL2,-100,0,"REPEAT")) vobj(DBTBL2,-100,0,"REPEAT")="N007"_$P(vobj(DBTBL2,0),$C(124),7),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),7)=0
 I $P(vobj(DBTBL2,0),$C(124),5)=""  S:'$D(vobj(DBTBL2,-100,0,"REPREQ")) vobj(DBTBL2,-100,0,"REPREQ")="T005"_$P(vobj(DBTBL2,0),$C(124),5),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),5)=0
 I $P(vobj(DBTBL2,0),$C(124),16)=""  S:'$D(vobj(DBTBL2,-100,0,"RESFLG")) vobj(DBTBL2,-100,0,"RESFLG")="N016"_$P(vobj(DBTBL2,0),$C(124),16),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),16)=0
 I $P(vobj(DBTBL2,0),$C(124),8)=""  S:'$D(vobj(DBTBL2,-100,0,"SCRCLR")) vobj(DBTBL2,-100,0,"SCRCLR")="N008"_$P(vobj(DBTBL2,0),$C(124),8),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),8)=1
 I $P(vobj(DBTBL2,0),$C(124),6)=""  S:'$D(vobj(DBTBL2,-100,0,"SCRMOD")) vobj(DBTBL2,-100,0,"SCRMOD")="L006"_$P(vobj(DBTBL2,0),$C(124),6),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),6)=0
 I $P(vobj(DBTBL2,0),$C(124),15)=""  S:'$D(vobj(DBTBL2,-100,0,"UID")) vobj(DBTBL2,-100,0,"UID")="T015"_$P(vobj(DBTBL2,0),$C(124),15),vobj(DBTBL2,-100,0)="" S $P(vobj(DBTBL2,0),$C(124),15)=$$USERNAM^%ZFUNC
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(DBTBL2) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(DBTBL2) ; Display screen prompts
 S VO="53||13|"
 S VO(0)="|0"
 S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(3,4,11,0,0,0,0,0,0,0)_"01T Screen ID:"
 S VO(4)=$C(3,33,5,0,0,0,0,0,0,0)_"01TUser:"
 S VO(5)=$C(3,56,13,0,0,0,0,0,0,0)_"01TLast Updated:"
 S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(10)=$C(5,3,13,1,0,0,0,0,0,0)_"01T Description:"
 S VO(11)=$C(5,58,13,0,0,0,0,0,0,0)_"01TProgram Name:"
 S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(16)=$C(7,3,14,0,0,0,0,0,0,0)_"01T Data File(s):"
 S VO(17)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(19)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(20)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(21)=$C(9,18,13,0,0,0,0,0,0,0)_"01TPSL Compiler:"
 S VO(22)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(23)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(24)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(25)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(26)=$C(11,3,28,0,0,0,0,0,0,0)_"01T Data Item Protection Logic:"
 S VO(27)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(28)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(29)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(30)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(31)=$C(13,5,39,0,0,0,0,0,0,0)_"01TDisplay Currency Data in Edited Format:"
 S VO(32)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(33)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(34)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(35)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(15,7,14,0,0,0,0,0,0,0)_"01TRepeat Region:"
 S VO(37)=$C(15,26,18,0,0,0,0,0,0,0)_"01T  Groups Required:"
 S VO(38)=$C(15,55,13,0,0,0,0,0,0,0)_"01TClear Option:"
 S VO(39)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(40)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(41)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(42)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(43)=$C(17,4,17,0,0,0,0,0,0,0)_"01TApplication Name:"
 S VO(44)=$C(17,32,12,0,0,0,0,0,0,0)_"01TSystem Name:"
 S VO(45)=$C(17,58,10,0,0,0,0,0,0,0)_"01TProject #:"
 S VO(46)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(47)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(48)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(49)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(50)=$C(19,5,16,0,0,0,0,0,0,0)_"01T132 Column Mode:"
 S VO(51)=$C(19,35,9,0,0,0,0,0,0,0)_"01T Version:"
 S VO(52)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(53)=$C(20,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(DBTBL2) ; Display screen data
  S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
 N V
 ;
 S VO="71|54|13|"
 S VO(54)=$C(1,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($get(%FN)))
 S VO(55)=$C(3,16,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(DBTBL2,-4),1,12)
 S VO(56)=$C(3,39,16,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(DBTBL2,0),$C(124),15),1,16)
 S VO(57)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str($P(vobj(DBTBL2,0),$C(124),3),"MM/DD/YEAR")
 S VO(58)=$C(5,17,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),9),1,40)
 S VO(59)=$C(5,72,8,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(DBTBL2,0),$C(124),2),1,8)
 S VO(60)=$C(7,18,60,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(DBTBL2,0),$C(124),1),1,60)
 S VO(61)=$C(9,32,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),22):"Y",1:"N")
 S VO(62)=$C(11,32,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),16)
 S VO(63)=$C(13,45,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),18):"Y",1:"N")
 S VO(64)=$C(15,22,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),7)
 S VO(65)=$C(15,45,2,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),5),1,2)
 S VO(66)=$C(15,69,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),8)
 S VO(67)=$C(17,22,3,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),11),1,3)
 S VO(68)=$C(17,45,8,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),12),1,8)
 S VO(69)=$C(17,69,6,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),13)
 S VO(70)=$C(19,22,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),6):"Y",1:"N")
 S VO(71)=$C(19,45,6,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL2,0),$C(124),10),1,6)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(DBTBL2) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=17 S VPT=1 S VPB=20 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL2"
 S OLNTB=20001
 ;
 S VFSN("DBTBL2")="zDBTBL2"
 ;
 ;
 S %TAB(1)=$C(2,15,12)_"21T12402|1|[DBTBL2]SID"
 S %TAB(2)=$C(2,38,16)_"21T12415|1|[DBTBL2]UID|||||||||20"
 S %TAB(3)=$C(2,69,10)_"21D12403|1|[DBTBL2]DATE"
 S %TAB(4)=$C(4,16,40)_"01T12409|1|[DBTBL2]DESC"
 S %TAB(5)=$C(4,71,8)_"21T12402|1|[DBTBL2]VPGM"
 S %TAB(6)=$C(6,17,60)_"00U12401|1|[DBTBL2]PFID|[DBTBL1]||do VP1^V00S063(.DBTBL2)"
 S %TAB(7)=$C(8,31,1)_"00L12422|1|[DBTBL2]CSCMP"
 S %TAB(8)=$C(10,31,1)_"00N12416|1|[DBTBL2]RESFLG|[DBCTL]:QU ""[DBCTL]NAME=""""RESFLG"""""""
 S %TAB(9)=$C(12,44,1)_"00L12418|1|[DBTBL2]CURDSP"
 S %TAB(10)=$C(14,21,2)_"00N12407|1|[DBTBL2]REPEAT|||do VP2^V00S063(.DBTBL2)"
 S %TAB(11)=$C(14,44,2)_"00T12405|1|[DBTBL2]REPREQ|||do VP3^V00S063(.DBTBL2)"
 S %TAB(12)=$C(14,68,1)_"00N12408|1|[DBTBL2]SCRCLR|,0#Clear to end of page,1#Clear entire page"
 S %TAB(13)=$C(16,21,3)_"00T12411|1|[DBTBL2]APL|[STBLSCASYS]"
 S %TAB(14)=$C(16,44,8)_"00T12412|1|[DBTBL2]SYS|[STBLSCASYS]"
 S %TAB(15)=$C(16,68,6)_"00N12413|1|[DBTBL2]PROJ"
 S %TAB(16)=$C(18,21,1)_"00L12406|1|[DBTBL2]SCRMOD"
 S %TAB(17)=$C(18,44,6)_"00T12410|1|[DBTBL2]VER"
 D VTBL(.DBTBL2)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(DBTBL2) ; Create %TAB(array)
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
VP1(DBTBL2) ; 
 ;
 N %MSGID N FILES
 ;
 Q:(X="") 
 ;
 D CHANGE^DBSMACRO("REQ")
 ;
 S ER=$$VALIDATE^DBSFVER(X,.RM)
 ;
 ; If error message is 2470 (Select ~p1 for primary file ID), treat
 ; as message (warning) only, not an error
 I ER,($piece($get(%MSGID),"|",1)=2470) S ER=0
 ;
 Q 
VP2(DBTBL2) ; 
 ;
 I (X=0) D GOTO^DBSMACRO("[DBTBL2]SCRCLR")
 ;
 Q 
VP3(DBTBL2) ; 
 ;
 Q:((X?.N)!(X="A")) 
 ;
 S ER=1
 ; Enter number of groups required or 'A' for all groups
 S RM=$$^MSG(946)
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.DBTBL2)
 D VDA1(.DBTBL2)
 D ^DBSPNT()
 Q 
 ;
VW(DBTBL2) ; 
 D VDA1(.DBTBL2)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(DBTBL2) ; 
 D VDA1(.DBTBL2)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.DBTBL2)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL2" D vSET1(.DBTBL2,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(DBTBL2,di,X) ; 
  D propSet^DBSDYNRA(DBTBL2,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL2" Q $$vREAD1(.DBTBL2,di)
 Q ""
vREAD1(DBTBL2,di) ; 
 Q $$propGet^DBSDYNRA(DBTBL2,di)
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
