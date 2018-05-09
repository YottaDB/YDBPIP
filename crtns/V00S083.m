 ; 
 ; **** Routine compiled from DATA-QWIK Screen SCAUR ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S083(%O,fSCAU) ; -  - SID= <SCAUR> User Related CIF Input
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fSCAU)#2)  K vobj(+$G(fSCAU)) S fSCAU=$$vcdmNew^RecordSCAU()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,RELCIF,CIFNAM" S VSID="SCAUR" S VPGM=$T(+0) S VSNAME="User Related CIF Input"
 S VFSN("SCAU")="zfSCAU"
 S vPSL=1
 S KEYS(1)=vobj(fSCAU,-3)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 S %MODS=1 S %REPEAT=16 D VPR(.fSCAU) D VDA1(.fSCAU) D V5^DBSPNT Q 
 ;
 I '%O D VNEW(.fSCAU) D VPR(.fSCAU) D VDA1(.fSCAU)
 I %O D VLOD(.fSCAU) Q:$get(ER)  D VPR(.fSCAU) D VDA1(.fSCAU)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fSCAU)
 Q 
 ;
VNEW(fSCAU) ; Initialize arrays if %O=0
 ;
 D VDEF(.fSCAU)
 D VLOD(.fSCAU)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fSCAU) ; 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fSCAU) ; Load data from disc - %O = (1-5)
 I '$D(%REPEAT) S %REPEAT=16
 I '$D(%MODS) S %MODS=1
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fSCAU) ; Display screen prompts
 S VO="7||13|"
 S VO(0)="|0"
 S VO(1)=$C(1,24,33,2,0,0,0,0,0,0)_"01TUser ""Related"" CIF Input Screen"
 S VO(2)=$C(3,1,47,0,0,0,0,0,0,0)_"01TCIF's entered on this screen will be considered"
 S VO(3)=$C(3,49,19,0,0,0,0,0,0,0)_"01T""related"" to user"
 S VO(4)=$C(4,1,62,0,0,0,0,0,0,0)_"01TThis User will be restricted from posting transactions to asso"
 S VO(5)=$C(4,63,16,0,0,0,0,0,0,0)_"01Tciated accounts."
 S VO(6)=$C(6,1,15,0,0,0,0,0,0,0)_"01TCustomer Number"
 S VO(7)=$C(6,20,13,0,0,0,0,0,0,0)_"01TCustomer Name"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fSCAU) ; Display screen data
 N V
 S CIFNAM=$get(CIFNAM)
 S RELCIF=$get(RELCIF)
 ;
 S VO="8|8|13|"
 S VO(8)=$C(3,68,6,2,0,0,0,0,0,0)_"01T"_$E(vobj(fSCAU,-3),1,6)
 ;
 S:'($D(%MODS)#2) %MODS=1 S VX=8+0 S DY=7 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA(.fSCAU)
 S $piece(VO,"|",1)=VX Q  ; EOD pointer
 ;
VRDA(fSCAU) ; Display data %REPEAT times
 ;instantiate new object if necessary
 I %O=5 N v2,v1
 I   S (v2,v1)=""
 E  N v2,v1
 E  S (v2,CIFNAM(I))=$get(CIFNAM(I)) S (v1,RELCIF(I))=$get(RELCIF(I))
 ;
 S VO(VX+1)=$C(DY,4,12,2,0,0,0,0,0,0)_"00N"_v1
 S VO(VX+2)=$C(DY,20,40,2,0,0,0,0,0,0)_"00T"_v2
 S DY=DY+1 S VX=VX+2
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fSCAU) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
 S %MODOFF=1 S %MOD=2 S %MAX=(%MOD*%REPEAT)+%MODOFF S VPT=1 S VPB=6+%REPEAT S BLKSIZ=(52*%REPEAT)+6 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="SCAU"
 S OLNTB=VPB*1000
 ;
 S VFSN("SCAU")="zfSCAU"
 ;
 F I=4:1:%MAX S %TAB(I)=""
 ;
 S %TAB(1)=$C(2,67,6)_"21T12401|1|[SCAU]UID|||||||||20"
 S %TAB(2)=$C(6,3,12)_"00N|*RELCIF(1)|[*]@RELCIF|||do VP1^V00S083(.fSCAU)"
 S %TAB(3)=$C(6,19,40)_"00T|*CIFNAM(1)|[*]@CIFNAM"
 D VTBL(.fSCAU) D VDEPRE(.fSCAU) I $get(ER) Q 
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fSCAU) ; Create %TAB(array)
 ; 1 2 3  4 5   6   7-9 10-11
 ; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDEPRE(fSCAU) ; Data Entry Pre-processor
 ;
 ; CIF entry on this screen will disallow ~p1
 S VAR1=$$^MSG(6195,UID)
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
 ;user-defined post procs
 ;
VP1(fSCAU) ; 
 I X="",V="" D GOTO^DBSMACRO("NEXT") Q 
 I X="" D  Q 
 .	S NAM=""
 .	F W=1:1:40 S NAM=NAM_"_"
 .	D DEF
 .	Q 
 S ER=0 D CUS^UACN1 Q:ER 
 ;
 N cif S cif=$$vRCgetRecord0Opt^RecordCIF(X,0,"")
 S NAM=$P(cif,$C(124),1)
 D DEF
 Q 
 ;
DEF ; 
 D DEFAULT^DBSMACRO("@CIFNAM",NAM,"1","0","0")
 D GOTO^DBSMACRO("NEXT")
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fSCAU)
 D VDA1(.fSCAU)
 D ^DBSPNT()
 Q 
 ;
VW(fSCAU) ; 
 D VDA1(.fSCAU)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fSCAU) ; 
 D VDA1(.fSCAU)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fSCAU)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="SCAU" D vSET1(.fSCAU,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fSCAU,di,X) ; 
  D propSet^DBSDYNRA(fSCAU,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="SCAU" Q $$vREAD1(.fSCAU,di)
 Q ""
vREAD1(fSCAU,di) ; 
 Q $$propGet^DBSDYNRA(fSCAU,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
