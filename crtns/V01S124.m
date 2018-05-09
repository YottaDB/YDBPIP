V01S124(%O,DBTBL2)	;DBS - DBS - SID= <DBTBL2> Screen Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL2 ****
	;
	; 09/13/2007 15:33 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/13/2007 15:33 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(DBTBL2)#2) K vobj(+$G(DBTBL2)) S DBTBL2=$$vDbNew1("","")
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
VNEW(DBTBL2)	; Initialize arrays if %O=0
	;
	D VDEF(.DBTBL2)
	D VLOD(.DBTBL2)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(DBTBL2)	;
	 S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
	Q:(vobj(DBTBL2,-3)="")!(vobj(DBTBL2,-4)="") 
	Q:%O  S ER=0 I (vobj(DBTBL2,-3)="")!(vobj(DBTBL2,-4)="") S ER=1 S RM=$$^MSG(1767,"LIBS,SID") Q 
	 N V1,V2 S V1=vobj(DBTBL2,-3),V2=vobj(DBTBL2,-4) I ($D(^DBTBL(V1,2,V2))) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(DBTBL2,0),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),3) S $P(vobj(DBTBL2,0),$C(124),3)=+$H,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),17)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),17) S $P(vobj(DBTBL2,0),$C(124),17)=1,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),14)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),14) S $P(vobj(DBTBL2,0),$C(124),14)="VT220",vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),7)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),7) S $P(vobj(DBTBL2,0),$C(124),7)=0,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),5)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),5) S $P(vobj(DBTBL2,0),$C(124),5)=0,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),16)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),16) S $P(vobj(DBTBL2,0),$C(124),16)=0,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),8)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),8) S $P(vobj(DBTBL2,0),$C(124),8)=1,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),6)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),6) S $P(vobj(DBTBL2,0),$C(124),6)=0,vobj(DBTBL2,-100,0)=""
	I $P(vobj(DBTBL2,0),$C(124),15)="" N vSetMf S vSetMf=$P(vobj(DBTBL2,0),$C(124),15) S $P(vobj(DBTBL2,0),$C(124),15)=$$USERNAM^%ZFUNC,vobj(DBTBL2,-100,0)=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(DBTBL2)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(DBTBL2)	; Display screen prompts
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
VDA1(DBTBL2)	; Display screen data
	 S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
	N V
	;
	S VO="71|54|13|"
	S VO(54)=$C(1,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($get(%FN)))
	S VO(55)=$C(3,16,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(DBTBL2,-4)),1,12)
	S VO(56)=$C(3,39,16,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(DBTBL2,0),$C(124),15)),1,16)
	S VO(57)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(DBTBL2,0),$C(124),3)),"MM/DD/YEAR")
	S VO(58)=$C(5,17,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(DBTBL2,0),$C(124),9)),1,40)
	S VO(59)=$C(5,72,8,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(DBTBL2,0),$C(124),2)),1,8)
	S VO(60)=$C(7,18,60,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(DBTBL2,0),$C(124),1)),1,60)
	S VO(61)=$C(9,32,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),22):"Y",1:"N")
	S VO(62)=$C(11,32,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),16)
	S VO(63)=$C(13,45,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),18):"Y",1:"N")
	S VO(64)=$C(15,22,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),7)
	S VO(65)=$C(15,45,2,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(DBTBL2,0),$C(124),5)),1,2)
	S VO(66)=$C(15,69,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),8)
	S VO(67)=$C(17,22,3,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(DBTBL2,0),$C(124),11)),1,3)
	S VO(68)=$C(17,45,8,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(DBTBL2,0),$C(124),12)),1,8)
	S VO(69)=$C(17,69,6,2,0,0,0,0,0,0)_"00N"_$P(vobj(DBTBL2,0),$C(124),13)
	S VO(70)=$C(19,22,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(DBTBL2,0),$C(124),6):"Y",1:"N")
	S VO(71)=$C(19,45,6,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(DBTBL2,0),$C(124),10)),1,6)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(DBTBL2)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=17 S VPT=1 S VPB=20 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL2"
	S OLNTB=20001
	;
	S VFSN("DBTBL2")="zDBTBL2"
	;
	;
	S %TAB(1)=$C(2,15,12)_"21T12402|1|[DBTBL2]SID"
	S %TAB(2)=$C(2,38,16)_"21T12415|1|[DBTBL2]UID"
	S %TAB(3)=$C(2,69,10)_"21D12403|1|[DBTBL2]DATE"
	S %TAB(4)=$C(4,16,40)_"01T12409|1|[DBTBL2]DESC"
	S %TAB(5)=$C(4,71,8)_"21T12402|1|[DBTBL2]VPGM"
	S %TAB(6)=$C(6,17,60)_"00U12401|1|[DBTBL2]PFID|[DBTBL1]||do VP1^V01S124(.DBTBL2)"
	S %TAB(7)=$C(8,31,1)_"00L12422|1|[DBTBL2]CSCMP"
	S %TAB(8)=$C(10,31,1)_"00N12416|1|[DBTBL2]RESFLG|[DBCTL]:QU ""[DBCTL]NAME=""""RESFLG"""""""
	S %TAB(9)=$C(12,44,1)_"00L12418|1|[DBTBL2]CURDSP"
	S %TAB(10)=$C(14,21,2)_"00N12407|1|[DBTBL2]REPEAT|||do VP2^V01S124(.DBTBL2)"
	S %TAB(11)=$C(14,44,2)_"00T12405|1|[DBTBL2]REPREQ|||do VP3^V01S124(.DBTBL2)"
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
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(DBTBL2)	;Create %TAB(array)
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
VP1(DBTBL2)	;
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
VP2(DBTBL2)	;
	;
	I (X=0) D GOTO^DBSMACRO("[DBTBL2]SCRCLR")
	;
	Q 
VP3(DBTBL2)	;
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
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.DBTBL2)
	D VDA1(.DBTBL2)
	D ^DBSPNT()
	Q 
	;
VW(DBTBL2)	;
	D VDA1(.DBTBL2)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(DBTBL2)	;
	D VDA1(.DBTBL2)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.DBTBL2)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL2" D vSET1(.DBTBL2,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(DBTBL2,di,X)	;
	D vCoInd1(DBTBL2,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL2" Q $$vREAD1(.DBTBL2,di)
	Q ""
vREAD1(DBTBL2,di)	;
	Q $$vCoInd2(DBTBL2,di)
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
vCoMfS1(vRec,vVal)	; RecordDBTBL2.setAPL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",11)
	S $P(vobj(vRec,0),"|",11)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL2.setCSCMP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",22)
	S $P(vobj(vRec,0),"|",22)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL2.setCURDSP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",18)
	S $P(vobj(vRec,0),"|",18)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL2.setDATE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",3)
	S $P(vobj(vRec,0),"|",3)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL2.setDESC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",9)
	S $P(vobj(vRec,0),"|",9)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL2.setLNK1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",1)
	S $P(vobj(vRec,"v1"),"|",1)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL2.setLNK10(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",10)
	S $P(vobj(vRec,"v1"),"|",10)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL2.setLNK11(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",11)
	S $P(vobj(vRec,"v1"),"|",11)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL2.setLNK12(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",12)
	S $P(vobj(vRec,"v1"),"|",12)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL2.setLNK13(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",13)
	S $P(vobj(vRec,"v1"),"|",13)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL2.setLNK14(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",14)
	S $P(vobj(vRec,"v1"),"|",14)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBTBL2.setLNK15(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",15)
	S $P(vobj(vRec,"v1"),"|",15)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBTBL2.setLNK16(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",16)
	S $P(vobj(vRec,"v1"),"|",16)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordDBTBL2.setLNK17(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",17)
	S $P(vobj(vRec,"v1"),"|",17)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordDBTBL2.setLNK18(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",18)
	S $P(vobj(vRec,"v1"),"|",18)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordDBTBL2.setLNK19(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",19)
	S $P(vobj(vRec,"v1"),"|",19)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordDBTBL2.setLNK2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",2)
	S $P(vobj(vRec,"v1"),"|",2)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordDBTBL2.setLNK20(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",20)
	S $P(vobj(vRec,"v1"),"|",20)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordDBTBL2.setLNK21(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",21)
	S $P(vobj(vRec,"v1"),"|",21)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordDBTBL2.setLNK22(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",22)
	S $P(vobj(vRec,"v1"),"|",22)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordDBTBL2.setLNK23(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",23)
	S $P(vobj(vRec,"v1"),"|",23)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS22(vRec,vVal)	; RecordDBTBL2.setLNK24(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",24)
	S $P(vobj(vRec,"v1"),"|",24)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS23(vRec,vVal)	; RecordDBTBL2.setLNK25(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",25)
	S $P(vobj(vRec,"v1"),"|",25)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS24(vRec,vVal)	; RecordDBTBL2.setLNK26(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",26)
	S $P(vobj(vRec,"v1"),"|",26)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS25(vRec,vVal)	; RecordDBTBL2.setLNK27(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",27)
	S $P(vobj(vRec,"v1"),"|",27)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS26(vRec,vVal)	; RecordDBTBL2.setLNK28(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",28)
	S $P(vobj(vRec,"v1"),"|",28)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS27(vRec,vVal)	; RecordDBTBL2.setLNK3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",3)
	S $P(vobj(vRec,"v1"),"|",3)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS28(vRec,vVal)	; RecordDBTBL2.setLNK4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",4)
	S $P(vobj(vRec,"v1"),"|",4)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS29(vRec,vVal)	; RecordDBTBL2.setLNK5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",5)
	S $P(vobj(vRec,"v1"),"|",5)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS30(vRec,vVal)	; RecordDBTBL2.setLNK6(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",6)
	S $P(vobj(vRec,"v1"),"|",6)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS31(vRec,vVal)	; RecordDBTBL2.setLNK7(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",7)
	S $P(vobj(vRec,"v1"),"|",7)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS32(vRec,vVal)	; RecordDBTBL2.setLNK8(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",8)
	S $P(vobj(vRec,"v1"),"|",8)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS33(vRec,vVal)	; RecordDBTBL2.setLNK9(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,"v1"),"|",9)
	S $P(vobj(vRec,"v1"),"|",9)=vVal S vobj(vRec,-100,"v1")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS34(vRec,vVal)	; RecordDBTBL2.setNORPC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",4)
	S $P(vobj(vRec,0),"|",4)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS35(vRec,vVal)	; RecordDBTBL2.setOOE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",17)
	S $P(vobj(vRec,0),"|",17)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS36(vRec,vVal)	; RecordDBTBL2.setOUTFMT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",14)
	S $P(vobj(vRec,0),"|",14)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS37(vRec,vVal)	; RecordDBTBL2.setPFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",1)
	S $P(vobj(vRec,0),"|",1)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS38(vRec,vVal)	; RecordDBTBL2.setPROJ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",13)
	S $P(vobj(vRec,0),"|",13)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS39(vRec,vVal)	; RecordDBTBL2.setREPEAT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",7)
	S $P(vobj(vRec,0),"|",7)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS40(vRec,vVal)	; RecordDBTBL2.setREPREQ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",5)
	S $P(vobj(vRec,0),"|",5)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS41(vRec,vVal)	; RecordDBTBL2.setRESFLG(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",16)
	S $P(vobj(vRec,0),"|",16)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS42(vRec,vVal)	; RecordDBTBL2.setSCRCLR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",8)
	S $P(vobj(vRec,0),"|",8)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS43(vRec,vVal)	; RecordDBTBL2.setSCRMOD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",6)
	S $P(vobj(vRec,0),"|",6)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS44(vRec,vVal)	; RecordDBTBL2.setSYS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",12)
	S $P(vobj(vRec,0),"|",12)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS45(vRec,vVal)	; RecordDBTBL2.setUID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",15)
	S $P(vobj(vRec,0),"|",15)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS46(vRec,vVal)	; RecordDBTBL2.setVER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",10)
	S $P(vobj(vRec,0),"|",10)=vVal S vobj(vRec,-100,0)=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS47(vRec,vVal)	; RecordDBTBL2.setVPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec,0),"|",2)
	S $P(vobj(vRec,0),"|",2)=vVal S vobj(vRec,-100,0)=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL2.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL2",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	N vNd1 S vNd1=vNod S vNod=$$getCurNode^UCXDD(vP,0)
	I vNod'="",'$D(vobj(vOid,vNod)) D
	.	I '$get(vobj(vOid,-2)) S vobj(vOid,vNod)="" Q 
	.	S vobj(vOid,vNod)=$get(^DBTBL(vobj(vOid,-3),2,vobj(vOid,-4),vNd1))
	.	Q 
	I vCol="APL" D vCoMfS1(vOid,vVal) Q 
	I vCol="CSCMP" D vCoMfS2(vOid,vVal) Q 
	I vCol="CURDSP" D vCoMfS3(vOid,vVal) Q 
	I vCol="DATE" D vCoMfS4(vOid,vVal) Q 
	I vCol="DESC" D vCoMfS5(vOid,vVal) Q 
	I vCol="LNK1" D vCoMfS6(vOid,vVal) Q 
	I vCol="LNK10" D vCoMfS7(vOid,vVal) Q 
	I vCol="LNK11" D vCoMfS8(vOid,vVal) Q 
	I vCol="LNK12" D vCoMfS9(vOid,vVal) Q 
	I vCol="LNK13" D vCoMfS10(vOid,vVal) Q 
	I vCol="LNK14" D vCoMfS11(vOid,vVal) Q 
	I vCol="LNK15" D vCoMfS12(vOid,vVal) Q 
	I vCol="LNK16" D vCoMfS13(vOid,vVal) Q 
	I vCol="LNK17" D vCoMfS14(vOid,vVal) Q 
	I vCol="LNK18" D vCoMfS15(vOid,vVal) Q 
	I vCol="LNK19" D vCoMfS16(vOid,vVal) Q 
	I vCol="LNK2" D vCoMfS17(vOid,vVal) Q 
	I vCol="LNK20" D vCoMfS18(vOid,vVal) Q 
	I vCol="LNK21" D vCoMfS19(vOid,vVal) Q 
	I vCol="LNK22" D vCoMfS20(vOid,vVal) Q 
	I vCol="LNK23" D vCoMfS21(vOid,vVal) Q 
	I vCol="LNK24" D vCoMfS22(vOid,vVal) Q 
	I vCol="LNK25" D vCoMfS23(vOid,vVal) Q 
	I vCol="LNK26" D vCoMfS24(vOid,vVal) Q 
	I vCol="LNK27" D vCoMfS25(vOid,vVal) Q 
	I vCol="LNK28" D vCoMfS26(vOid,vVal) Q 
	I vCol="LNK3" D vCoMfS27(vOid,vVal) Q 
	I vCol="LNK4" D vCoMfS28(vOid,vVal) Q 
	I vCol="LNK5" D vCoMfS29(vOid,vVal) Q 
	I vCol="LNK6" D vCoMfS30(vOid,vVal) Q 
	I vCol="LNK7" D vCoMfS31(vOid,vVal) Q 
	I vCol="LNK8" D vCoMfS32(vOid,vVal) Q 
	I vCol="LNK9" D vCoMfS33(vOid,vVal) Q 
	I vCol="NORPC" D vCoMfS34(vOid,vVal) Q 
	I vCol="OOE" D vCoMfS35(vOid,vVal) Q 
	I vCol="OUTFMT" D vCoMfS36(vOid,vVal) Q 
	I vCol="PFID" D vCoMfS37(vOid,vVal) Q 
	I vCol="PROJ" D vCoMfS38(vOid,vVal) Q 
	I vCol="REPEAT" D vCoMfS39(vOid,vVal) Q 
	I vCol="REPREQ" D vCoMfS40(vOid,vVal) Q 
	I vCol="RESFLG" D vCoMfS41(vOid,vVal) Q 
	I vCol="SCRCLR" D vCoMfS42(vOid,vVal) Q 
	I vCol="SCRMOD" D vCoMfS43(vOid,vVal) Q 
	I vCol="SYS" D vCoMfS44(vOid,vVal) Q 
	I vCol="UID" D vCoMfS45(vOid,vVal) Q 
	I vCol="VER" D vCoMfS46(vOid,vVal) Q 
	I vCol="VPGM" D vCoMfS47(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece($S(vNod'="":vobj(vOid,vNod),1:vobj(vOid)),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	S vobj(vOid,-100,vOldNod)=""
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece($S(vNod'="":vobj(vOid,vNod),1:vobj(vOid)),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I vNod'="" S $piece(vobj(vOid,vNod),"|",vPos)=vVal Q 
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL2.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL2",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	S vPos=$P(vP,"|",4)
	N vNd1 S vNd1=vNod S vNod=$$getCurNode^UCXDD(vP,0)
	I vNod'="",'$D(vobj(vOid,vNod)) D
	.	I '$get(vobj(vOid,-2)) S vobj(vOid,vNod)="" Q 
	.	S vobj(vOid,vNod)=$get(^DBTBL(vobj(vOid,-3),2,vobj(vOid,-4),vNd1))
	.	Q 
	N vRet
	I vNod'="" S vRet=vobj(vOid,vNod)
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
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL2)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
