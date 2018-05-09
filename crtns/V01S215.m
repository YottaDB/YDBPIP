V01S215(%O,fDBTBL8,fDBTBL1)	; -  - SID= <DBTBL8> Index File Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL8 ****
	;
	; 09/14/2007 08:41 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:41 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fDBTBL8)#2) K vobj(+$G(fDBTBL8)) S fDBTBL8=$$vDbNew1("","","")
	.	I '($D(fDBTBL1)#2) K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vDbNew2("","")
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
VNEW(fDBTBL8,fDBTBL1)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL8,.fDBTBL1)
	D VLOD(.fDBTBL8,.fDBTBL1)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL8,fDBTBL1)	;
	Q:(vobj(fDBTBL8,-3)="")!(vobj(fDBTBL8,-4)="")!(vobj(fDBTBL8,-5)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL8,-3)="")!(vobj(fDBTBL8,-4)="")!(vobj(fDBTBL8,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID,INDEXNM") Q 
	 N V1,V2,V3 S V1=vobj(fDBTBL8,-3),V2=vobj(fDBTBL8,-4),V3=vobj(fDBTBL8,-5) I ($D(^DBTBL(V1,8,V2,V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL8,fDBTBL1)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL8,fDBTBL1)	; Display screen prompts
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
VDA1(fDBTBL8,fDBTBL1)	; Display screen data
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
	S VO(38)=$C(3,19,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL8,-4)),1,12)
	S VO(39)=$C(3,58,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBTBL8),$C(124),12)),"MM/DD/YEAR")
	S VO(40)=$C(3,69,10,2,0,0,0,0,0,0)_"01C"_$$TIM^%ZM($P(vobj(fDBTBL8),$C(124),16))
	S VO(41)=$C(4,58,20,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL8),$C(124),13)),1,20)
	S VO(42)=$C(6,17,16,2,0,0,0,0,0,0)_"00U"_$get(ZINDEXNM)
	S VO(43)=$C(6,71,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELFLG):"Y",1:"N")
	S VO(44)=$C(8,17,29,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL8),$C(124),5)),1,29)
	S VO(45)=$C(8,71,8,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL8),$C(124),15)),1,8)
	S VO(46)=$C(10,17,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL8),$C(124),3)),1,60)
	S VO(47)=$C(11,17,8,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL8),$C(124),2)),1,8)
	S VO(48)=$C(13,71,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL8),$C(124),14):"Y",1:"N")
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL8,fDBTBL1)	;
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
	S %TAB(5)=$C(5,16,16)_"01U|*ZINDEXNM|[*]@ZINDEXNM|^DBTBL(%LIBS,8,FID,#5|if X?1A.AN|do VP1^V01S215(.fDBTBL8,.fDBTBL1)||99"
	S %TAB(6)=$C(5,70,1)_"00L|*DELFLG|[*]@DELFLG|||do VP2^V01S215(.fDBTBL8,.fDBTBL1)"
	S %TAB(7)=$C(7,16,29)_"01T12405|1|[DBTBL8]IDXDESC|||do VP3^V01S215(.fDBTBL8,.fDBTBL1)"
	S %TAB(8)=$C(7,70,8)_"20T12415|1|[DBTBL8]PARFID"
	S %TAB(9)=$C(9,16,60)_"01T12403|1|[DBTBL8]ORDERBY|@SELDI^DBSFUN(FID,.X):LIST:NOVAL||do VP4^V01S215(.fDBTBL8,.fDBTBL1)||||||120"
	S %TAB(10)=$C(10,16,8)_"01T12402|1|[DBTBL8]GLOBAL|||do VP5^V01S215(.fDBTBL8,.fDBTBL1)||||||40"
	S %TAB(11)=$C(12,70,1)_"00L12414|1|[DBTBL8]UPCASE"
	D VTBL(.fDBTBL8,.fDBTBL1)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL8,fDBTBL1)	;Create %TAB(array)
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
VP1(fDBTBL8,fDBTBL1)	;
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
	.	N DB8 S DB8=$$vDb1("SYSDEV",PARFID,X)
	. K vobj(+$G(fDBTBL8)) S fDBTBL8=$$vReCp1(DB8)
	. S $P(vobj(fDBTBL8),$C(124),15)=PARFID ; Supertype file name
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
	I (vobj(fDBTBL8,-5)="") S vobj(fDBTBL8,-5)=INDEXNM
	;
	S X=INDEXNM
	S UX=1
	;
	D DISPLAY^DBSMACRO("ALL")
	;
	Q 
	;
ZNEWNM	;
	;
	D GOTO^DBSMACRO("DBTBL8.IDXDESC")
	;
	S RM(99)=$$^MSG(7290,INDEXNM)
	S UX=1
	;
	Q 
	;
OLDINDEX(fDBTBL8,FID,X)	;
	;
	S RM=$$^MSG(1775,INDEXNM)
	K vobj(+$G(fDBTBL8)) S fDBTBL8=$$vDb1("SYSDEV",FID,X)
	;
	Q 
VP2(fDBTBL8,fDBTBL1)	;
	I (X=1) S %O=3 D GOTO^DBSMACRO("END")
	Q 
VP3(fDBTBL8,fDBTBL1)	;
	I 'vobj(fDBTBL8,-5) D CHANGE^DBSMACRO("REQ")
	Q 
VP4(fDBTBL8,fDBTBL1)	;
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
CHKDI(di)	; Check that this is a valid DI syntax
	;
	I di=+di!("""$"[$E(di,1)) Q  ; Literal or special
	;
	I di?1AN.AN!(di?1"%"1AN.AN)!(di["_") S di=FID_"."_di ; This file
	I '$$VER^DBSDD(di) S ER=1 S RM=$$^MSG(1298,di) Q  ; Invalid data item
	;
	I $$CMP^DBSDD(di)'="" S ER=1 S RM=$$^MSG(597,di) Q  ; Reject computed data item
	;
	Q 
VP5(fDBTBL8,fDBTBL1)	;
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
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL8,.fDBTBL1)
	D VDA1(.fDBTBL8,.fDBTBL1)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL8,fDBTBL1)	;
	D VDA1(.fDBTBL8,.fDBTBL1)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL8,fDBTBL1)	;
	D VDA1(.fDBTBL8,.fDBTBL1)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL8,.fDBTBL1)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL8" D vSET1(.fDBTBL8,di,X)
	I sn="DBTBL1" D vSET2(.fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL8,di,X)	;
	D vCoInd1(fDBTBL8,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET2(fDBTBL1,di,X)	;
	D vCoInd2(fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL8" Q $$vREAD1(.fDBTBL8,di)
	I fid="DBTBL1" Q $$vREAD2(.fDBTBL1,di)
	Q ""
vREAD1(fDBTBL8,di)	;
	Q $$vCoInd3(fDBTBL8,di)
vREAD2(fDBTBL1,di)	;
	Q $$vCoInd4(fDBTBL1,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL8.setGLOBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL8.setIDXDESC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL8.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",12)
	S $P(vobj(vRec),"|",12)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL8.setORDERBY(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL8.setPARFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",15)
	S $P(vobj(vRec),"|",15)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL8.setTIME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",16)
	S $P(vobj(vRec),"|",16)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL8.setUPCASE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",14)
	S $P(vobj(vRec),"|",14)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL8.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",13)
	S $P(vobj(vRec),"|",13)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL8.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL8",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="GLOBAL" D vCoMfS1(vOid,vVal) Q 
	I vCol="IDXDESC" D vCoMfS2(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS3(vOid,vVal) Q 
	I vCol="ORDERBY" D vCoMfS4(vOid,vVal) Q 
	I vCol="PARFID" D vCoMfS5(vOid,vVal) Q 
	I vCol="TIME" D vCoMfS6(vOid,vVal) Q 
	I vCol="UPCASE" D vCoMfS7(vOid,vVal) Q 
	I vCol="USER" D vCoMfS8(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL1.setACCKEYS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,16),"|",1)
	S $P(vobj(vRec,16),"|",1)=vVal S vobj(vRec,-100,16)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL1.setAKEY1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,1),"|",1)
	S $P(vobj(vRec,1),"|",1)=vVal S vobj(vRec,-100,1)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL1.setAKEY2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,2),"|",1)
	S $P(vobj(vRec,2),"|",1)=vVal S vobj(vRec,-100,2)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBTBL1.setAKEY3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,3),"|",1)
	S $P(vobj(vRec,3),"|",1)=vVal S vobj(vRec,-100,3)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBTBL1.setAKEY4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,4),"|",1)
	S $P(vobj(vRec,4),"|",1)=vVal S vobj(vRec,-100,4)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordDBTBL1.setAKEY5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,5),"|",1)
	S $P(vobj(vRec,5),"|",1)=vVal S vobj(vRec,-100,5)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordDBTBL1.setAKEY6(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,6),"|",1)
	S $P(vobj(vRec,6),"|",1)=vVal S vobj(vRec,-100,6)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordDBTBL1.setAKEY7(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,7),"|",1)
	S $P(vobj(vRec,7),"|",1)=vVal S vobj(vRec,-100,7)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordDBTBL1.setDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",1)
	S $P(vobj(vRec,10),"|",1)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordDBTBL1.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordDBTBL1.setDFLAG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",10)
	S $P(vobj(vRec,22),"|",10)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordDBTBL1.setDFTDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",6)
	S $P(vobj(vRec,10),"|",6)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordDBTBL1.setDFTDES1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",9)
	S $P(vobj(vRec,10),"|",9)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS22(vRec,vVal)	; RecordDBTBL1.setDFTHDR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",8)
	S $P(vobj(vRec,10),"|",8)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS23(vRec,vVal)	; RecordDBTBL1.setDFTORD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",7)
	S $P(vobj(vRec,10),"|",7)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS24(vRec,vVal)	; RecordDBTBL1.setEXIST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",13)
	S $P(vobj(vRec,10),"|",13)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS25(vRec,vVal)	; RecordDBTBL1.setEXTENDLENGTH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",14)
	S $P(vobj(vRec,10),"|",14)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS26(vRec,vVal)	; RecordDBTBL1.setFDOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,13),"|",1)
	S $P(vobj(vRec,13),"|",1)=vVal S vobj(vRec,-100,13)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS27(vRec,vVal)	; RecordDBTBL1.setFILETYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",12)
	S $P(vobj(vRec,10),"|",12)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS28(vRec,vVal)	; RecordDBTBL1.setFPN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",3)
	S $P(vobj(vRec,99),"|",3)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS29(vRec,vVal)	; RecordDBTBL1.setFSN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,12),"|",1)
	S $P(vobj(vRec,12),"|",1)=vVal S vobj(vRec,-100,12)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS30(vRec,vVal)	; RecordDBTBL1.setGLOBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",1)
	S $P(vobj(vRec,0),"|",1)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS31(vRec,vVal)	; RecordDBTBL1.setGLREF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",1)
	S $P(vobj(vRec,100),"|",1)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS32(vRec,vVal)	; RecordDBTBL1.setLISTDFT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,101),"|",1)
	S $P(vobj(vRec,101),"|",1)=vVal S vobj(vRec,-100,101)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS33(vRec,vVal)	; RecordDBTBL1.setLISTREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,102),"|",1)
	S $P(vobj(vRec,102),"|",1)=vVal S vobj(vRec,-100,102)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS34(vRec,vVal)	; RecordDBTBL1.setLOG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",5)
	S $P(vobj(vRec,100),"|",5)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS35(vRec,vVal)	; RecordDBTBL1.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",10)
	S $P(vobj(vRec,10),"|",10)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS36(vRec,vVal)	; RecordDBTBL1.setMPLCTDD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",5)
	S $P(vobj(vRec,10),"|",5)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS37(vRec,vVal)	; RecordDBTBL1.setNETLOC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",3)
	S $P(vobj(vRec,10),"|",3)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS38(vRec,vVal)	; RecordDBTBL1.setPARFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",4)
	S $P(vobj(vRec,10),"|",4)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS39(vRec,vVal)	; RecordDBTBL1.setPREDAEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",5)
	S $P(vobj(vRec,22),"|",5)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS40(vRec,vVal)	; RecordDBTBL1.setPTRTIM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",8)
	S $P(vobj(vRec,100),"|",8)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS41(vRec,vVal)	; RecordDBTBL1.setPTRTIMU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",11)
	S $P(vobj(vRec,100),"|",11)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS42(vRec,vVal)	; RecordDBTBL1.setPTRTLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",4)
	S $P(vobj(vRec,100),"|",4)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS43(vRec,vVal)	; RecordDBTBL1.setPTRTLDU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",10)
	S $P(vobj(vRec,100),"|",10)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS44(vRec,vVal)	; RecordDBTBL1.setPTRUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",3)
	S $P(vobj(vRec,100),"|",3)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS45(vRec,vVal)	; RecordDBTBL1.setPTRUSERU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",9)
	S $P(vobj(vRec,100),"|",9)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS46(vRec,vVal)	; RecordDBTBL1.setPUBLISH(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",6)
	S $P(vobj(vRec,99),"|",6)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS47(vRec,vVal)	; RecordDBTBL1.setQID1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,14),"|",1)
	S $P(vobj(vRec,14),"|",1)=vVal S vobj(vRec,-100,14)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS48(vRec,vVal)	; RecordDBTBL1.setRECTYP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,100),"|",2)
	S $P(vobj(vRec,100),"|",2)=vVal S vobj(vRec,-100,100)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS49(vRec,vVal)	; RecordDBTBL1.setRFLAG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",9)
	S $P(vobj(vRec,22),"|",9)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS50(vRec,vVal)	; RecordDBTBL1.setSCREEN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",8)
	S $P(vobj(vRec,22),"|",8)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS51(vRec,vVal)	; RecordDBTBL1.setSYSSN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",2)
	S $P(vobj(vRec,10),"|",2)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS52(vRec,vVal)	; RecordDBTBL1.setUDACC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",1)
	S $P(vobj(vRec,99),"|",1)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS53(vRec,vVal)	; RecordDBTBL1.setUDFILE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",2)
	S $P(vobj(vRec,99),"|",2)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS54(vRec,vVal)	; RecordDBTBL1.setUDPOST(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",5)
	S $P(vobj(vRec,99),"|",5)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS55(vRec,vVal)	; RecordDBTBL1.setUDPRE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,99),"|",4)
	S $P(vobj(vRec,99),"|",4)=vVal S vobj(vRec,-100,99)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS56(vRec,vVal)	; RecordDBTBL1.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,10),"|",11)
	S $P(vobj(vRec,10),"|",11)=vVal S vobj(vRec,-100,10)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS57(vRec,vVal)	; RecordDBTBL1.setVAL4EXT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,22),"|",1)
	S $P(vobj(vRec,22),"|",1)=vVal S vobj(vRec,-100,22)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol,vVal)	; RecordDBTBL1.setColumn(1,0)
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
	I vCol="ACCKEYS" D vCoMfS9(vOid,vVal) Q 
	I vCol="AKEY1" D vCoMfS10(vOid,vVal) Q 
	I vCol="AKEY2" D vCoMfS11(vOid,vVal) Q 
	I vCol="AKEY3" D vCoMfS12(vOid,vVal) Q 
	I vCol="AKEY4" D vCoMfS13(vOid,vVal) Q 
	I vCol="AKEY5" D vCoMfS14(vOid,vVal) Q 
	I vCol="AKEY6" D vCoMfS15(vOid,vVal) Q 
	I vCol="AKEY7" D vCoMfS16(vOid,vVal) Q 
	I vCol="DEL" D vCoMfS17(vOid,vVal) Q 
	I vCol="DES" D vCoMfS18(vOid,vVal) Q 
	I vCol="DFLAG" D vCoMfS19(vOid,vVal) Q 
	I vCol="DFTDES" D vCoMfS20(vOid,vVal) Q 
	I vCol="DFTDES1" D vCoMfS21(vOid,vVal) Q 
	I vCol="DFTHDR" D vCoMfS22(vOid,vVal) Q 
	I vCol="DFTORD" D vCoMfS23(vOid,vVal) Q 
	I vCol="EXIST" D vCoMfS24(vOid,vVal) Q 
	I vCol="EXTENDLENGTH" D vCoMfS25(vOid,vVal) Q 
	I vCol="FDOC" D vCoMfS26(vOid,vVal) Q 
	I vCol="FILETYP" D vCoMfS27(vOid,vVal) Q 
	I vCol="FPN" D vCoMfS28(vOid,vVal) Q 
	I vCol="FSN" D vCoMfS29(vOid,vVal) Q 
	I vCol="GLOBAL" D vCoMfS30(vOid,vVal) Q 
	I vCol="GLREF" D vCoMfS31(vOid,vVal) Q 
	I vCol="LISTDFT" D vCoMfS32(vOid,vVal) Q 
	I vCol="LISTREQ" D vCoMfS33(vOid,vVal) Q 
	I vCol="LOG" D vCoMfS34(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS35(vOid,vVal) Q 
	I vCol="MPLCTDD" D vCoMfS36(vOid,vVal) Q 
	I vCol="NETLOC" D vCoMfS37(vOid,vVal) Q 
	I vCol="PARFID" D vCoMfS38(vOid,vVal) Q 
	I vCol="PREDAEN" D vCoMfS39(vOid,vVal) Q 
	I vCol="PTRTIM" D vCoMfS40(vOid,vVal) Q 
	I vCol="PTRTIMU" D vCoMfS41(vOid,vVal) Q 
	I vCol="PTRTLD" D vCoMfS42(vOid,vVal) Q 
	I vCol="PTRTLDU" D vCoMfS43(vOid,vVal) Q 
	I vCol="PTRUSER" D vCoMfS44(vOid,vVal) Q 
	I vCol="PTRUSERU" D vCoMfS45(vOid,vVal) Q 
	I vCol="PUBLISH" D vCoMfS46(vOid,vVal) Q 
	I vCol="QID1" D vCoMfS47(vOid,vVal) Q 
	I vCol="RECTYP" D vCoMfS48(vOid,vVal) Q 
	I vCol="RFLAG" D vCoMfS49(vOid,vVal) Q 
	I vCol="SCREEN" D vCoMfS50(vOid,vVal) Q 
	I vCol="SYSSN" D vCoMfS51(vOid,vVal) Q 
	I vCol="UDACC" D vCoMfS52(vOid,vVal) Q 
	I vCol="UDFILE" D vCoMfS53(vOid,vVal) Q 
	I vCol="UDPOST" D vCoMfS54(vOid,vVal) Q 
	I vCol="UDPRE" D vCoMfS55(vOid,vVal) Q 
	I vCol="USER" D vCoMfS56(vOid,vVal) Q 
	I vCol="VAL4EXT" D vCoMfS57(vOid,vVal) Q 
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
vCoInd3(vOid,vCol)	; RecordDBTBL8.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL8",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	S vPos=$P(vP,"|",4)
	N vRet
	S vRet=vobj(vOid)
	S vRet=$piece(vRet,"|",vPos)
	I '($P(vP,"|",13)="") Q $$getSf^UCCOLSF(vRet,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vCoInd4(vOid,vCol)	; RecordDBTBL1.getColumn()
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
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL8,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8"
	S vobj(vOid)=$G(^DBTBL(v1,8,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,8,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL8" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL8)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew2(v1,v2)	;	vobj()=Class.new(DBTBL1)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL8.copy: DBTBL8
	;
	Q $$copy^UCGMR(DB8)
