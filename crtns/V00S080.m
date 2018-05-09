 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL8 ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S080(%O,fDBTBL8,fDBTBL1) ; -  - SID= <DBTBL8> Index File Definition
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fDBTBL8)#2)  K vobj(+$G(fDBTBL8)) S fDBTBL8=$$vcdmNew^RecordDBTBL8()
 .	I '($D(fDBTBL1)#2)  K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vcdmNew^RecordDBTBL1()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,ZINDEXNM,DELFLG" S VSID="DBTBL8" S VPGM=$T(+0) S VSNAME="Index File Definition"
 S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL8")="zfDBTBL8"
 S vPSL=1
 S KEYS(1)=vobj(fDBTBL1,-3)
 S KEYS(2)=vobj(fDBTBL1,-4)
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.fDBTBL8,.fDBTBL1) D VDA1(.fDBTBL8,.fDBTBL1) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.fDBTBL8,.fDBTBL1) D VPR(.fDBTBL8,.fDBTBL1) D VDA1(.fDBTBL8,.fDBTBL1)
 I %O D VLOD(.fDBTBL8,.fDBTBL1) Q:$get(ER)  D VPR(.fDBTBL8,.fDBTBL1) D VDA1(.fDBTBL8,.fDBTBL1)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fDBTBL8,.fDBTBL1)
 Q 
 ;
VNEW(fDBTBL8,fDBTBL1) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBTBL8,.fDBTBL1)
 D VLOD(.fDBTBL8,.fDBTBL1)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBTBL8,fDBTBL1) ; 
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBTBL8,fDBTBL1) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBTBL8,fDBTBL1) ; Display screen prompts
 S VO="36||13|0"
 S VO(0)="|0"
 S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(3,4,14,0,0,0,0,0,0,0)_"01T Primary File:"
 S VO(4)=$C(3,44,13,0,0,0,0,0,0,0)_"01TLast Updated:"
 S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(4,49,8,0,0,0,0,0,0,0)_"01TBy User:"
 S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(10)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(11)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(12)=$C(6,4,12,1,0,0,0,0,0,0)_"01T Index Name:"
 S VO(13)=$C(6,46,24,0,0,0,0,0,0,0)_"01TDelete Index Definition:"
 S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(8,3,13,1,0,0,0,0,0,0)_"01T Description:"
 S VO(19)=$C(8,50,20,0,0,0,0,0,0,0)_"01TSupertype File Name:"
 S VO(20)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(21)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(22)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(23)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(24)=$C(10,6,10,1,0,0,0,0,0,0)_"01T Order by:"
 S VO(25)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(26)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(27)=$C(11,3,13,1,0,0,0,0,0,0)_"01T Global Name:"
 S VO(28)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(29)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(30)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(31)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(32)=$C(13,32,38,0,0,0,0,0,0,0)_"01TStore Index Value in Uppercase Format:"
 S VO(33)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(34)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(35)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(15,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fDBTBL8,fDBTBL1) ; Display screen data
 N V
 I %O=5 N DELFLG,ZINDEXNM
 I   S (DELFLG,ZINDEXNM)=""
 E  S DELFLG=$get(DELFLG) S ZINDEXNM=$get(ZINDEXNM)
 ;
 S DELFLG=$get(DELFLG)
 S ZINDEXNM=$get(ZINDEXNM)
 ;
 S VO="48|37|13|0"
 S VO(37)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID(%FN))
 S VO(38)=$C(3,19,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(fDBTBL8,-4),1,12)
 S VO(39)=$C(3,58,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str($P(vobj(fDBTBL8),$C(124),12),"MM/DD/YEAR")
 S VO(40)=$C(3,69,10,2,0,0,0,0,0,0)_"01C"_$$TIM^%ZM($P(vobj(fDBTBL8),$C(124),16))
 S VO(41)=$C(4,58,20,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL8),$C(124),13),1,20)
 S VO(42)=$C(6,17,16,2,0,0,0,0,0,0)_"00U"_$get(ZINDEXNM)
 S VO(43)=$C(6,71,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELFLG):"Y",1:"N")
 S VO(44)=$C(8,17,29,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL8),$C(124),5),1,29)
 S VO(45)=$C(8,71,8,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL8),$C(124),15),1,8)
 S VO(46)=$C(10,17,60,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL8),$C(124),3),1,60)
 S VO(47)=$C(11,17,8,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fDBTBL8),$C(124),2),1,8)
 S VO(48)=$C(13,71,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL8),$C(124),14):"Y",1:"N")
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fDBTBL8,fDBTBL1) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=11 S VPT=1 S VPB=15 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL8,DBTBL1"
 S OLNTB=15001
 ;
 S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL8")="zfDBTBL8"
 ;
 ;
 S %TAB(1)=$C(2,18,12)_"21U12402|1|[DBTBL8]FID|[DBTBL1]||||||||25"
 S %TAB(2)=$C(2,57,10)_"20D12412|1|[DBTBL8]LTD"
 S %TAB(3)=$C(2,68,10)_"20C12416|1|[DBTBL8]TIME"
 S %TAB(4)=$C(3,57,20)_"20T12413|1|[DBTBL8]USER"
 S %TAB(5)=$C(5,16,16)_"01U|*ZINDEXNM|[*]@ZINDEXNM|^DBTBL(%LIBS,8,FID,#5|if X?1A.AN|do VP1^V00S080(.fDBTBL8,.fDBTBL1)||99"
 S %TAB(6)=$C(5,70,1)_"00L|*DELFLG|[*]@DELFLG|||do VP2^V00S080(.fDBTBL8,.fDBTBL1)"
 S %TAB(7)=$C(7,16,29)_"01T12405|1|[DBTBL8]IDXDESC|||do VP3^V00S080(.fDBTBL8,.fDBTBL1)"
 S %TAB(8)=$C(7,70,8)_"20T12415|1|[DBTBL8]PARFID"
 S %TAB(9)=$C(9,16,60)_"01T12403|1|[DBTBL8]ORDERBY|@SELDI^DBSFUN(FID,.X):LIST:NOVAL||do VP4^V00S080(.fDBTBL8,.fDBTBL1)||||||120"
 S %TAB(10)=$C(10,16,8)_"01T12402|1|[DBTBL8]GLOBAL|||do VP5^V00S080(.fDBTBL8,.fDBTBL1)||||||40"
 S %TAB(11)=$C(12,70,1)_"00L12414|1|[DBTBL8]UPCASE"
 D VTBL(.fDBTBL8,.fDBTBL1)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBTBL8,fDBTBL1) ; Create %TAB(array)
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
VP1(fDBTBL8,fDBTBL1) ; 
  S:'$D(vobj(fDBTBL1,10)) vobj(fDBTBL1,10)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10)),1:"")
  S:'$D(vobj(fDBTBL1,0)) vobj(fDBTBL1,0)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),0)),1:"")
  S:'$D(vobj(fDBTBL1,16)) vobj(fDBTBL1,16)=$S(vobj(fDBTBL1,-2):$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),16)),1:"")
 S INDEXNM=X
 S ZINDEXNM=X
 ;
 N J N PARFID N OLDX N Z N ZORD N ZDESC N ZHDG N ZLIB N ZFID
 ;
 S OLDX=X
  S vobj(fDBTBL8,-5)=INDEXNM
 ;
 D CHANGE^DBSMACRO("TBL","")
 ;
 Q:(X="") 
 Q:X=V 
 ;
 ; .LOAD. ALL
 D DISPLAY^DBSMACRO("ALL")
 ;
 ; If this points to a parent file, it can only be edited there
 S X=OLDX
 S PARFID=$P(vobj(fDBTBL1,10),$C(124),4)
 ;
 ; Copy supertype index def
 I '(PARFID=""),($D(^DBTBL("SYSDEV",8,PARFID,X))#2) D  Q 
 .	N DB8 S DB8=$$vRCgetRecord0^RecordDBTBL8("SYSDEV",PARFID,X,0)
 .  K vobj(+$G(fDBTBL8)) S fDBTBL8=$$vReCp1(DB8)
 .  S $P(vobj(fDBTBL8),$C(124),15)=PARFID ; Supertype file name
 .	D DISPLAY^DBSMACRO("ALL")
 .	D GOTO^DBSMACRO("END")
 .	K vobj(+$G(DB8)) Q 
 ;
 S FID=vobj(fDBTBL8,-4)
 S INDEXNM=OLDX
  S vobj(fDBTBL8,-5)=INDEXNM
 ;
 I ($D(^DBTBL("SYSDEV",8,FID,INDEXNM))#2) D  Q 
 .	D OLDINDEX(.fDBTBL8,FID,X)
 .	D DISPLAY^DBSMACRO("ALL")
 .	Q 
 ;
 I '($D(^DBTBL("SYSDEV",8,FID,INDEXNM))#2) D ZNEWNM
 ;
 ; ---------- If a valid data item name, try to default in ORDERBY and IDXDESC
 I '$$VER^DBSDD(FID_"."_INDEXNM) Q 
 S Z=$$DI^DBSDD(FID_"."_INDEXNM)
 ;
 I $piece(Z,"|",1)="" Q  ; Computed
 I $piece(Z,"|",1)?1N1"*" Q  ; Access key
 ;
 S ZORD=""
 S ZDESC=$piece(Z,"|",10)
 S ZDESC=$E(ZDESC,1,30)
 ;
 S Z="X"_$P(vobj(fDBTBL1,0),$C(124),1) ; Index global name
 ;
 S ZORD=$P(vobj(fDBTBL1,16),$C(124),1)
 ;
 I ($P(vobj(fDBTBL8),$C(124),5)="") D DEFAULT^DBSMACRO("DBTBL8.IDXDESC",$E(ZDESC,1,29),"1","0","0")
 I ($P(vobj(fDBTBL8),$C(124),3)="") D DEFAULT^DBSMACRO("DBTBL8.ORDERBY",""""_X_""""_","_X_","_ZORD,"1","0","0")
 I ($P(vobj(fDBTBL8),$C(124),2)="") D DEFAULT^DBSMACRO("DBTBL8.GLOBAL",Z,"1","0","0")
 I (vobj(fDBTBL8,-5)="")  S vobj(fDBTBL8,-5)=INDEXNM
 ;
 S X=INDEXNM
 S UX=1
 ;
 D DISPLAY^DBSMACRO("ALL")
 ;
 Q 
 ;
ZNEWNM ; 
 ;
 D GOTO^DBSMACRO("DBTBL8.IDXDESC")
 ;
 S RM(99)=$$^MSG(7290,INDEXNM)
 S UX=1
 ;
 Q 
 ;
OLDINDEX(fDBTBL8,FID,X) ; 
 ;
 S RM=$$^MSG(1775,INDEXNM)
  K vobj(+$G(fDBTBL8)) S fDBTBL8=$$vRCgetRecord0^RecordDBTBL8("SYSDEV",FID,X,0)
 ;
 Q 
VP2(fDBTBL8,fDBTBL1) ; 
 I (X=1) S %O=3 D GOTO^DBSMACRO("END")
 Q 
VP3(fDBTBL8,fDBTBL1) ; 
 I 'vobj(fDBTBL8,-5) D CHANGE^DBSMACRO("REQ")
 Q 
VP4(fDBTBL8,fDBTBL1) ; 
 N i N zvar
 N di N keylist N keys
 ;
 I X["=" S RM=$$^MSG(1475) S RM=$$^MSG(2974,RM) ; Invalid syntax
 S zvar=0
 ;
 D CHANGE^DBSMACRO("TBL","")
 ;
 S keylist=$piece(X,"=",1)
 ;
 F i=1:1:$L(keylist,",") D  Q:ER 
 .	I $piece(keylist,",",i)="" S ER=1 S RM=$$^MSG(2076) Q  ; Invalid syntax
 .	D CHKDI($piece(keylist,",",i)) ; Validate data item
 .	Q 
 ;
 ; Make sure all primary keys are in the index
 ;
 I '($D(vfsn(FID))#2) D fsn^DBSDD(.vfsn,FID)
 ;
 S keys=$piece(vfsn(FID),"|",3) ; Access keys
 ;
 I zvar Q  ; User-defined <<var>> syntax
 ;
 F i=1:1:$L(keys,",") D
 .	S key=$piece(keys,",",i)
 .	I ","_keylist_","[(","_key_",") Q 
 .	S keylist=keylist_","_key
 .	I $piece(X,"=",2)'="" S X=keylist_"="_$piece(X,"=",2,999) Q 
 .	S X=keylist
 .	Q 
 ;
 Q 
 ;
CHKDI(di) ; Check that this is a valid DI syntax
 ;
 I di=+di!("""$"[$E(di,1)) Q  ; Literal or special
 ;
 I di?1AN.AN!(di?1"%"1AN.AN)!(di["_") S di=FID_"."_di ; This file
 I '$$VER^DBSDD(di) S ER=1 S RM=$$^MSG(1298,di) Q  ; Invalid data item
 ;
 I $$CMP^DBSDD(di)'="" S ER=1 S RM=$$^MSG(597,di) Q  ; Reject computed data item
 ;
 Q 
VP5(fDBTBL8,fDBTBL1) ; 
 N GBL,ORD,DELGBL
 ;
 I X="DAYEND",$P(vobj(fDBTBL8),$C(124),3)'[$char(34) D  Q 
 .	S ER=1
 .	S RM=$$^MSG(1411)
 .	Q 
 ;
 I $E(X,1)="^" S ER=1 S RM=$$^MSG(2567) Q  ; syntax error
 ;
 S ORD=$P(vobj(fDBTBL8),$C(124),3)
 ;
 I '(X="") D
 .	S GBL="^"_X_"("
 .	S RM=GBL_$piece(ORD,"=",1)_")"
 .	I ORD["=" S RM=RM_"="_$piece(ORD,"=",2)
 .	S RM=$$^MSG(1164,RM)
 .	Q 
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fDBTBL8,.fDBTBL1)
 D VDA1(.fDBTBL8,.fDBTBL1)
 D ^DBSPNT()
 Q 
 ;
VW(fDBTBL8,fDBTBL1) ; 
 D VDA1(.fDBTBL8,.fDBTBL1)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBTBL8,fDBTBL1) ; 
 D VDA1(.fDBTBL8,.fDBTBL1)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBTBL8,.fDBTBL1)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL8" D vSET1(.fDBTBL8,di,X)
 I sn="DBTBL1" D vSET2(.fDBTBL1,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBTBL8,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL8,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET2(fDBTBL1,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL1,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL8" Q $$vREAD1(.fDBTBL8,di)
 I fid="DBTBL1" Q $$vREAD2(.fDBTBL1,di)
 Q ""
vREAD1(fDBTBL8,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL8,di)
vREAD2(fDBTBL1,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL1,di)
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
 ;
vReCp1(v1) ; RecordDBTBL8.copy: DBTBL8
 ;
 Q $$copy^UCGMR(DB8)
