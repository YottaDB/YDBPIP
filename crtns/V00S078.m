 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL6S ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S078(%O,fDBTBL6S) ; DBS - DBS - SID= <DBTBL6S> QWIK Definition - Statistics
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fDBTBL6S(1))#2)  K vobj(+$G(fDBTBL6S(1))) S fDBTBL6S(1)=$$vcdmNew^RecordDBTBL6SQ()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL6S" S VPGM=$T(+0) S VSNAME="QWIK Definition - Statistics"
 S VFSN("DBTBL6SQ")="zfDBTBL6S"
 S vPSL=1
 S KEYS(1)=$get(vobj(fDBTBL6S(1),-3))
 S KEYS(2)=$get(vobj(fDBTBL6S(1),-4))
 S KEYS(3)=$get(vobj(fDBTBL6S(1),-5))
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 S %MODS=1 S %REPEAT=19 D VPR(.fDBTBL6S) D VDA1(.fDBTBL6S) D V5^DBSPNT Q 
 ;
 I '%O D VNEW(.fDBTBL6S) D VPR(.fDBTBL6S) D VDA1(.fDBTBL6S)
 I %O D VLOD(.fDBTBL6S) Q:$get(ER)  D VPR(.fDBTBL6S) D VDA1(.fDBTBL6S)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fDBTBL6S)
 N ptr
 S ptr=""
 F  S ptr=$order(fDBTBL6S(ptr)) Q:(ptr="")  D
 .	I vobj(fDBTBL6S(ptr),-5)="" K vobj(+$G(fDBTBL6S(ptr))) K fDBTBL6S(ptr)
 .	Q 
 Q 
 ;
VNEW(fDBTBL6S) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBTBL6S)
 D VLOD(.fDBTBL6S)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBTBL6S) ; 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBTBL6S) ; Load data from disc - %O = (1-5)
 I '$D(%REPEAT) S %REPEAT=19
 I '$D(%MODS) S %MODS=1
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBTBL6S) ; Display screen prompts
 S VO="8||13|0"
 S VO(0)="|0"
 S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(2,6,11,1,0,0,0,0,0,0)_"01T Data Item "
 S VO(4)=$C(2,35,10,1,0,0,0,0,0,0)_"01T Based on "
 S VO(5)=$C(2,54,23,1,0,0,0,0,0,0)_"01T Statistics Increments "
 S VO(6)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(8)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 I '($D(%MODS)#2) S %MODS=1
 S DY=4 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR(.fDBTBL6S)
 S VO=(+VO)_"|"_(VO+1)_"|13" Q  ; BOD pointer
 ;
VRPR(fDBTBL6S) ; Display prompts %REPEAT times
 ;
 S VO(VO+1)=$C(DY,1,1,37,52,52,0,0,0,0)_"11Tx"
 S VO(VO+2)=$C(DY,80,1,38,52,0,0,0,0,0)_"11Tx"
 S VO=VO+2 S DY=DY+1
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fDBTBL6S) ; Display screen data
 N V
 ;
 S VX=$piece(VO,"|",2)
 ;
 S:'($D(%MODS)#2) %MODS=1 S VX=$piece(VO,"|",2)+-1 S DY=4 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA(.fDBTBL6S)
 S $piece(VO,"|",1)=VX Q  ; EOD pointer
 ;
VRDA(fDBTBL6S) ; Display data %REPEAT times
 ;instantiate new object if necessary
 ;   #ACCEPT;DATE=08/08/06; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEPRECATED
 I '$G(fDBTBL6S(I)) D
 .  K vobj(+$G(fDBTBL6S(I))) S fDBTBL6S(I)=$$vcdmNew^RecordDBTBL6SQ() S vobj(fDBTBL6S(I),-3)=$get(KEYS(1)) S vobj(fDBTBL6S(I),-4)=$get(KEYS(2))
 .	Q 
 S VO(VX+1)=$C(DY,2,25,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL6S(I)),$C(124),4),1,25)
 S VO(VX+2)=$C(DY,28,25,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL6S(I)),$C(124),1),1,25)
 S VO(VX+3)=$C(DY,54,26,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL6S(I)),$C(124),5),1,26)
 S DY=DY+1 S VX=VX+3
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL6S) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
 S %MODOFF=0 S %MOD=3 S %MAX=(%MOD*%REPEAT)+%MODOFF S VPT=1 S VPB=3+%REPEAT S BLKSIZ=(76*%REPEAT)+0 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL6SQ"
 S OLNTB=VPB*1000
 ;
 S VFSN("DBTBL6SQ")="zfDBTBL6S"
 ;
 F I=4:1:%MAX S %TAB(I)=""
 ;
 S %TAB(1)=$C(3,1,25)_"00T12404|1|[DBTBL6SQ]QDI|||do VP1^V00S078(.fDBTBL6S)|do VP2^V00S078(.fDBTBL6S)|||||40"
 S %TAB(2)=$C(3,27,25)_"00T12401|1|[DBTBL6SQ]QBASE|||do VP3^V00S078(.fDBTBL6S)||||||40"
 S %TAB(3)=$C(3,53,26)_"00T12405|1|[DBTBL6SQ]QINCR|||do VP4^V00S078(.fDBTBL6S)||||||40"
 D VTBL(.fDBTBL6S)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBTBL6S) ; Create %TAB(array)
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
VP1(fDBTBL6S) ; 
 N FILES
 ;
 S ER=0
 I X="",V'="" D  Q 
 .	D DELETE^DBSMACRO("DBTBL6SQ.QDI")
 .	D DELETE^DBSMACRO("DBTBL6SQ.QINCR")
 .	D GOTO^DBSMACRO("NEXT")
 .	Q 
 ;
 I X="" D GOTO^DBSMACRO("NEXT") Q 
 ;
 N d5q,vop1,vop2,vop3 S vop1="SYSDEV",vop2=QRID,d5q=$$vRCgetRecord0Opt^RecordDBTBL5Q("SYSDEV",QRID,0,"")
  S vop3=$G(^DBTBL(vop1,6,vop2,0))
 S FILES=$P(vop3,$C(124),1)
 ;
 I X'["[" S X="[SYSDEV,"_$piece(FILES,",",1)_"]"_X ; Convert to {lib,fi}di
 ;
 I '($D(ZTBL(X))#2) Q 
 ;
 Q 
VP2(fDBTBL6S) ; 
 N FILES N DFID N DINAM N DLIB
 ;
 N d5q,vop1,vop2,vop3 S vop1="SYSDEV",vop2=QRID,d5q=$$vRCgetRecord0Opt^RecordDBTBL5Q("SYSDEV",QRID,0,"")
  S vop3=$G(^DBTBL(vop1,6,vop2,0))
 S FILES=$P(vop3,$C(124),1)
 S DFID=$piece(FILES,",",1)
 S DLIB="SYSDEV"
 ;
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
 F  Q:'$$vFetch1()  D
 . N d6f S d6f=$$vRCgetRecord1Opt^RecordDBTBL6F($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1,"")
 .	S X=$P(d6f,$C(124),1)
 .	D ^DBSDI
 .	S ZTBL(DINAM)="     "_$translate($P(d6f,$C(124),2),"@"," ")
 . Q 
 ;
 S I(3)="ZTBL("
 S RM=""
 ;
 Q 
VP3(fDBTBL6S) ; 
 N DLIB N DFID N DINAM N PFID
 ;
 I X="",($P(vobj(fDBTBL6S(I(1))),$C(124),4)="") Q 
 I X="",'($P(vobj(fDBTBL6S(I(1))),$C(124),4)="") S E5=1 Q 
 ;
 N d5q,vop1,vop2,vop3 S vop1="SYSDEV",vop2=QRID,d5q=$$vRCgetRecord0Opt^RecordDBTBL5Q("SYSDEV",QRID,0,"")
  S vop3=$G(^DBTBL(vop1,6,vop2,0))
 ;
 S PFID=$piece($P(vop3,$C(124),1),",",1)
 ;
 S DLIB="SYSDEV"
 S DFID=PFID
 ;
 D ^DBSDI
 Q:ER 
 ;
 S X=DINAM
 ;
 I X=$P(vobj(fDBTBL6S(I(1))),$C(124),4),"TUFL"'[DI(9) Q 
 ;
 D DELETE^DBSMACRO("DBTBL5SQ.QINCR")
 ;
 S NI=NI+1
 ;
 Q 
 ;
VP4(fDBTBL6S) ; 
 I (X="") Q 
 I X=0 S X="" Q 
 ;
 S X2=-99999999
 ;
 F Z1=1:1 D  Q:ER!((Z="")&(Z99="")) 
 .	S Z=$piece(X,",",Z1)
 .	S Z99=$piece(X,",",Z1+1,999)
 .	I ((Z="")&(Z99="")) Q 
 .	D INCCHK
 .	Q 
 ;
 Q 
 ;
INCCHK ; 
 ;
 I Z="" D INCCHKX Q 
 ;
 I Z<X2 S ER=1 S RM=$$^MSG(943) Q 
 ;
 S X2=Z
 I Z?."-"1N.N Q 
 ;
 I Z?."-"1N.N1".".N Q 
 ;
 D INCCHKX
 ;
 Q 
 ;
INCCHKX ; 
 S ER=1
 S RM=$$^MSG(961)
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fDBTBL6S)
 D VDA1(.fDBTBL6S)
 D ^DBSPNT()
 Q 
 ;
VW(fDBTBL6S) ; 
 D VDA1(.fDBTBL6S)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBTBL6S) ; 
 D VDA1(.fDBTBL6S)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBTBL6S)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL6SQ" D vSET1(fDBTBL6S(I(1)),di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBTBL6S,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL6S,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL6SQ" Q $$vREAD1(fDBTBL6S(I(1)),di)
 Q ""
vREAD1(fDBTBL6S,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL6S,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vOpen1() ; LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL1a0
 S vos4=100
vL1a4 S vos4=$O(^DBTBL("SYSDEV",6,vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
