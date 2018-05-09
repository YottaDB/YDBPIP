 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL22R ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S066(%O,dbtbl22r) ; -  - SID= <DBTBL22R> DATA-QWIK Row Definition
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(dbtbl22r)#2)  K vobj(+$G(dbtbl22r)) S dbtbl22r=$$vcdmNew^RecordDBTBL22R()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,ROW,DELETE" S VSID="DBTBL22R" S VPGM=$T(+0) S VSNAME="DATA-QWIK Row Definition"
 S VFSN("DBTBL22R")="zdbtbl22r"
 S vPSL=1
 S KEYS(1)=vobj(dbtbl22r,-3)
 S KEYS(2)=vobj(dbtbl22r,-4)
 S KEYS(3)=vobj(dbtbl22r,-5)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.dbtbl22r) D VDA1(.dbtbl22r) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.dbtbl22r) D VPR(.dbtbl22r) D VDA1(.dbtbl22r)
 I %O D VLOD(.dbtbl22r) Q:$get(ER)  D VPR(.dbtbl22r) D VDA1(.dbtbl22r)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.dbtbl22r)
 Q 
 ;
VNEW(dbtbl22r) ; Initialize arrays if %O=0
 ;
 D VDEF(.dbtbl22r)
 D VLOD(.dbtbl22r)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(dbtbl22r) ; 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(dbtbl22r) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(dbtbl22r) ; Display screen prompts
 S VO="4||13|0"
 S VO(0)="|0"
 S VO(1)=$C(2,17,12,1,0,0,0,0,0,0)_"01T Row Number:"
 S VO(2)=$C(2,43,7,0,0,0,0,0,0,0)_"01TDelete:"
 S VO(3)=$C(3,16,13,1,0,0,0,0,0,0)_"01T Description:"
 S VO(4)=$C(6,19,35,0,0,0,0,0,0,0)_"01TEnter SQL Row Selection Query Below"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(dbtbl22r) ; Display screen data
 N V
 I %O=5 N DELETE,ROW
 I   S (DELETE,ROW)=""
 E  S DELETE=$get(DELETE) S ROW=$get(ROW)
 ;
 S DELETE=$get(DELETE)
 S ROW=$get(ROW)
 ;
 S VO="12|5|13|0"
 S VO(5)=$C(2,30,4,2,0,0,0,0,0,0)_"00N"_$get(ROW)
 S VO(6)=$C(2,51,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
 S VO(7)=$C(3,30,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(dbtbl22r),$C(124),1),1,40)
 S VO(8)=$C(8,1,80,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(dbtbl22r),$C(124),3),1,80)
 S VO(9)=$C(9,1,80,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(dbtbl22r),$C(124),4),1,80)
 S VO(10)=$C(10,1,80,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(dbtbl22r),$C(124),5),1,80)
 S VO(11)=$C(11,1,80,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(dbtbl22r),$C(124),6),1,80)
 S VO(12)=$C(12,1,80,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(dbtbl22r),$C(124),7),1,80)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(dbtbl22r) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=8 S VPT=2 S VPB=12 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL22R"
 S OLNTB=12001
 ;
 S VFSN("DBTBL22R")="zdbtbl22r"
 ;
 ;
 S %TAB(1)=$C(1,29,4)_"01N|*ROW|[*]@ROW|[DBTBL22R]ROW,DES/LE=30,WHR1/LE=20:NOVAL:QU ""AGID=<<AGID>>""||do VP1^V00S066(.dbtbl22r)"
 S %TAB(2)=$C(1,50,1)_"00L|*DELETE|[*]@DELETE|,0#Insert,1#Modify,3#Delete||do VP2^V00S066(.dbtbl22r)"
 S %TAB(3)=$C(2,29,40)_"01T12401|1|[DBTBL22R]DES"
 S %TAB(4)=$C(7,0,80)_"00T12403|1|[DBTBL22R]WHR1"
 S %TAB(5)=$C(8,0,80)_"00T12404|1|[DBTBL22R]WHR2"
 S %TAB(6)=$C(9,0,80)_"00T12405|1|[DBTBL22R]WHR3"
 S %TAB(7)=$C(10,0,80)_"00T12406|1|[DBTBL22R]WHR4"
 S %TAB(8)=$C(11,0,80)_"00T12407|1|[DBTBL22R]WHR5"
 D VTBL(.dbtbl22r)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(dbtbl22r) ; Create %TAB(array)
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
VP1(dbtbl22r) ; 
 ;
 Q:(X="") 
 ;
 N load22r S load22r=$$vRCgetRecord1^RecordDBTBL22R("SYSDEV",vobj(dbtbl22r,-4),X,0)
 ;
 I ($G(vobj(load22r,-2))=1) D
 .	;
 .  K vobj(+$G(dbtbl22r)) S dbtbl22r=$$vReCp1(load22r)
 .	S vobj(dbtbl22r,-2)=1
 .	;
 .	D UNPROT^DBSMACRO("@DELETE")
 .	;
 .	D DISPLAY^DBSMACRO("ALL")
 .	Q 
 ;
 E  D  ; New row
 .	;
 .  S vobj(dbtbl22r,-5)=X
 .	S vobj(dbtbl22r,-2)=0
 .	;
 .	D PROTECT^DBSMACRO("@DELETE")
 .	;
 .	D GOTO^DBSMACRO("[DBTBL22R]DES")
 .	Q 
 ;
 K vobj(+$G(load22r)) Q 
VP2(dbtbl22r) ; 
 ;
 Q:(X=0) 
 ;
 D GOTO^DBSMACRO("END")
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.dbtbl22r)
 D VDA1(.dbtbl22r)
 D ^DBSPNT()
 Q 
 ;
VW(dbtbl22r) ; 
 D VDA1(.dbtbl22r)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(dbtbl22r) ; 
 D VDA1(.dbtbl22r)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.dbtbl22r)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL22R" D vSET1(.dbtbl22r,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(dbtbl22r,di,X) ; 
  D propSet^DBSDYNRA(dbtbl22r,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL22R" Q $$vREAD1(.dbtbl22r,di)
 Q ""
vREAD1(dbtbl22r,di) ; 
 Q $$propGet^DBSDYNRA(dbtbl22r,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vReCp1(v1) ; RecordDBTBL22R.copy: DBTBL22R
 ;
 Q $$copy^UCGMR(load22r)
