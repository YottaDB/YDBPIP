 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL6F ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S076(%O,DBTBL6F) ; -  - SID= <DBTBL6F> QWIK Report Display Format Definition
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(DBTBL6F(1))#2)  K vobj(+$G(DBTBL6F(1))) S DBTBL6F(1)=$$vcdmNew^RecordDBTBL6F()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL6F" S VPGM=$T(+0) S VSNAME="QWIK Report Display Format Definition"
 S VFSN("DBTBL6F")="zDBTBL6F"
 S vPSL=1
 S KEYS(1)=$get(vobj(DBTBL6F(1),-3))
 S KEYS(2)=$get(vobj(DBTBL6F(1),-4))
 S KEYS(3)=$get(vobj(DBTBL6F(1),-5))
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 S %MODS=1 S %REPEAT=18 D VPR(.DBTBL6F) D VDA1(.DBTBL6F) D V5^DBSPNT Q 
 ;
 I '%O D VNEW(.DBTBL6F) D VPR(.DBTBL6F) D VDA1(.DBTBL6F)
 I %O D VLOD(.DBTBL6F) Q:$get(ER)  D VPR(.DBTBL6F) D VDA1(.DBTBL6F)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.DBTBL6F)
 N ptr
 S ptr=""
 F  S ptr=$order(DBTBL6F(ptr)) Q:(ptr="")  D
 .	I vobj(DBTBL6F(ptr),-5)="" K vobj(+$G(DBTBL6F(ptr))) K DBTBL6F(ptr)
 .	Q 
 Q 
 ;
VNEW(DBTBL6F) ; Initialize arrays if %O=0
 ;
 D VLOD(.DBTBL6F)
 D VDEF(.DBTBL6F)
 D VLOD(.DBTBL6F)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(DBTBL6F) ; 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
VNEWDQ(DBTBL6F) ; Original VNEW section
 ;
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
VLOD(DBTBL6F) ; User defined access section
 ;
 I '$D(%REPEAT) S %REPEAT=18
 I '$D(%MODS) S %MODS=1
 Q 
 ;  #ACCEPT date=11/05/03;pgm=Screen compiler;CR=UNKNOWN;GROUP=SYNTAX
VLODDQ(DBTBL6F) ; Original VLOD section
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(DBTBL6F) ; Display screen prompts
 S VO="19||13|0"
 S VO(0)="|0"
 S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(2,2,5,2,0,0,0,0,0,0)_"01TField"
 S VO(4)=$C(2,13,16,2,0,0,0,0,0,0)_"01T Column Heading "
 S VO(5)=$C(2,30,12,1,0,0,0,0,0,0)_"01TReport Width"
 S VO(6)=$C(2,49,6,2,0,0,0,0,0,0)_"01TSpaces"
 S VO(7)=$C(2,60,7,2,0,0,0,0,0,0)_"01TDisplay"
 S VO(8)=$C(2,75,5,2,0,0,0,0,0,0)_"01TLines"
 S VO(9)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(10)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(11)=$C(3,2,4,2,0,0,0,0,0,0)_"01TName"
 S VO(12)=$C(3,14,35,2,0,0,0,0,0,0)_"01T----+---10----+---20----+---30----+"
 S VO(13)=$C(3,50,4,2,0,0,0,0,0,0)_"01TSkip"
 S VO(14)=$C(3,54,6,2,0,0,0,0,0,0)_"01T Size "
 S VO(15)=$C(3,60,6,2,0,0,0,0,0,0)_"01TFormat"
 S VO(16)=$C(3,69,6,2,0,0,0,0,0,0)_"01T  Math"
 S VO(17)=$C(3,76,4,2,0,0,0,0,0,0)_"01TSkip"
 S VO(18)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(19)=$C(4,1,80,0,0,0,0,0,0,0)_"11Ttqqqqqqqqqqqqwqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqwqqqwqqqqwqqqqqqqqqqqwqqqqwqqqu"
 I '($D(%MODS)#2) S %MODS=1
 S DY=5 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR(.DBTBL6F)
 S VO=(+VO)_"|"_(VO+1)_"|13" Q  ; BOD pointer
 ;
VRPR(DBTBL6F) ; Display prompts %REPEAT times
 ;
 S VO(VO+1)=$C(DY,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+2)=$C(DY,14,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+3)=$C(DY,50,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+4)=$C(DY,54,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+5)=$C(DY,59,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+6)=$C(DY,71,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+7)=$C(DY,76,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(VO+8)=$C(DY,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO=VO+8 S DY=DY+1
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(DBTBL6F) ; Display screen data
 N V
 ;
 S VX=$piece(VO,"|",2)
 ;
 S:'($D(%MODS)#2) %MODS=1 S VX=$piece(VO,"|",2)+-1 S DY=5 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA(.DBTBL6F)
 S $piece(VO,"|",1)=VX Q  ; EOD pointer
 ;
VRDA(DBTBL6F) ; Display data %REPEAT times
 ;instantiate new object if necessary
 ;   #ACCEPT;DATE=08/08/06; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEPRECATED
 I '$G(DBTBL6F(I)) D
 .  K vobj(+$G(DBTBL6F(I))) S DBTBL6F(I)=$$vcdmNew^RecordDBTBL6F() S vobj(DBTBL6F(I),-3)=$get(KEYS(1)) S vobj(DBTBL6F(I),-4)=$get(KEYS(2))
 .	Q 
 S VO(VX+1)=$C(DY,2,12,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(DBTBL6F(I)),$C(124),1),1,12)
 S VO(VX+2)=$C(DY,15,35,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL6F(I)),$C(124),2),1,35)
 S VO(VX+3)=$C(DY,51,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL6F(I)),$C(124),3)
 S VO(VX+4)=$C(DY,55,3,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL6F(I)),$C(124),4)
 S VO(VX+5)=$C(DY,60,11,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL6F(I)),$C(124),5),1,11)
 S VO(VX+6)=$C(DY,72,3,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(DBTBL6F(I)),$C(124),6),1,3)
 S VO(VX+7)=$C(DY,77,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL6F(I)),$C(124),7)
 S DY=DY+1 S VX=VX+7
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(DBTBL6F) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
 S %MODOFF=0 S %MOD=7 S %MAX=(%MOD*%REPEAT)+%MODOFF S VPT=1 S VPB=4+%REPEAT S BLKSIZ=(69*%REPEAT)+0 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL6F"
 S OLNTB=VPB*1000
 ;
 S VFSN("DBTBL6F")="zDBTBL6F"
 ;
 F I=8:1:%MAX S %TAB(I)=""
 ;
 S %TAB(1)=$C(4,1,12)_"20T12401|1|[DBTBL6F]FORMDI|||||||||55"
 S %TAB(2)=$C(4,14,35)_"00T12402|1|[DBTBL6F]FORMDESC|||do VP1^V00S076(.DBTBL6F)"
 S %TAB(3)=$C(4,50,3)_"01N12403|1|[DBTBL6F]FORMIDN|||||0|508"
 S %TAB(4)=$C(4,54,3)_"01N12404|1|[DBTBL6F]FORMSIZE|||do VP2^V00S076(.DBTBL6F)||1|508"
 S %TAB(5)=$C(4,59,11)_"01T12405|1|[DBTBL6F]FORMFMT|[DBCTLRFMT]:NOVAL||do VP3^V00S076(.DBTBL6F)||||||20"
 S %TAB(6)=$C(4,71,3)_"00T12406|1|[DBTBL6F]FORMFUN|[DBCTLQFUN]"
 S %TAB(7)=$C(4,76,2)_"00N12407|1|[DBTBL6F]FORMLF|||do VP4^V00S076(.DBTBL6F)||1|99"
 D VTBL(.DBTBL6F)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(DBTBL6F) ; Create %TAB(array)
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
VP1(DBTBL6F) ; 
 N LEN N Z N Z1 N Z2
 ;
 I (X="") Q 
 ;
 S LEN=0
 S Z1=$L(X,"@")
 ;
 ; Calculate column heading size
 ;
 F Z=1:1:Z1 S Z2=$L($piece(X,"@",Z)) I Z2>LEN S LEN=Z2
 ;
 S RM=$$^MSG(400,LEN)
 I $P(vobj(DBTBL6F(I(1))),$C(124),4)<LEN S RM=$$^MSG(2974,RM)
 ;
 Q 
VP2(DBTBL6F) ; 
 N J N Z1 N Z2
 N Z N Z3 N Z4
 ;
 S Z=$P(vobj(DBTBL6F(I(1))),$C(124),2)
 I $L(Z)'>X Q 
 ;
 ; Heading will be truncated
 ;
 I Z'["@" S RM=$$^MSG(1172,$E(Z,1,X)) Q 
 ;
 S Z1=0
 S Z2=$L(Z,"@")
 ;
 F J=1:1:Z2 D
 .	S Z3=$piece(Z,"@",J)
 .	I $L(Z3)>Z1 S Z1=$L(Z3) S Z4=Z3
 .	Q 
 ;
 I Z1>X S RM=$$^MSG(1172,$E(Z4,1,X)) Q 
 ;
 Q 
VP3(DBTBL6F) ; 
 D PP^DBSEXEP
 Q 
VP4(DBTBL6F) ; 
 ;
 ; Calculate column width
 ;
 N L N MXLIN N Z N Z1 N Z9
 ;
 S L=1
 S Z9=0
 S MXLIN=0
 S MXLIN=$order(DBTBL6F(""),-1)
 ;
 D ZLINE(.DBTBL6F,1,MXLIN,0)
 ;
 Q 
 ;
ZLINE(DBTBL6F,L,MXLIN,Z9) ; 
 ;
 N IDN N J N SIZE N Z
 ;
 S Z=0
 F J=L:1:MXLIN D  Q:$P(vobj(DBTBL6F(J)),$C(124),7) 
 .	S IDN=$P(vobj(DBTBL6F(J)),$C(124),3)
 .	S SIZE=$P(vobj(DBTBL6F(J)),$C(124),4)
 .	S Z=Z+IDN+SIZE
 .	Q 
 ;
 I J=MXLIN D  Q 
 .	I Z>Z9 S Z9=Z
 .	S RM=Z9_$J("",5-$L(Z9))_"|1042"
 .	Q 
 ;
 ; ========== MULTI-LINE REPORT
 ;
 I Z>Z9 S Z9=Z
 S L=J+1
 ;
 D ZLINE(.DBTBL6F,L,MXLIN,Z9)
 ;
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.DBTBL6F)
 D VDA1(.DBTBL6F)
 D ^DBSPNT()
 Q 
 ;
VW(DBTBL6F) ; 
 D VDA1(.DBTBL6F)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(DBTBL6F) ; 
 D VDA1(.DBTBL6F)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.DBTBL6F)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL6F" D vSET1(DBTBL6F(I(1)),di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(DBTBL6F,di,X) ; 
  D propSet^DBSDYNRA(DBTBL6F,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL6F" Q $$vREAD1(DBTBL6F(I(1)),di)
 Q ""
vREAD1(DBTBL6F,di) ; 
 Q $$propGet^DBSDYNRA(DBTBL6F,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
