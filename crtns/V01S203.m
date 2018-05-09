V01S203(%O,fDBTBL33)	;DBS -  - SID= <DBTBL33> Batch Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL33 ****
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
	.	I '($D(fDBTBL33)#2) K vobj(+$G(fDBTBL33)) S fDBTBL33=$$vDbNew1("","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,zproc" S VSID="DBTBL33" S VPGM=$T(+0) S VSNAME="Batch Definition"
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
VNEW(fDBTBL33)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL33)
	D VLOD(.fDBTBL33)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL33)	;
	Q:(vobj(fDBTBL33,-3)="")!(vobj(fDBTBL33,-4)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL33,-3)="")!(vobj(fDBTBL33,-4)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,BCHID") Q 
	 N V1,V2 S V1=vobj(fDBTBL33,-3),V2=vobj(fDBTBL33,-4) I ($D(^DBTBL(V1,33,V2))#2) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fDBTBL33),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),3) S $P(vobj(fDBTBL33),$C(124),3)=+$H,vobj(fDBTBL33,-100,"0*")=""
	I $P(vobj(fDBTBL33),$C(124),12)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),12) S $P(vobj(fDBTBL33),$C(124),12)=32000,vobj(fDBTBL33,-100,"0*")=""
	I $P(vobj(fDBTBL33),$C(124),11)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),11) S $P(vobj(fDBTBL33),$C(124),11)=100,vobj(fDBTBL33,-100,"0*")=""
	I $P(vobj(fDBTBL33),$C(124),17)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),17) S $P(vobj(fDBTBL33),$C(124),17)=10,vobj(fDBTBL33,-100,"0*")=""
	I $P(vobj(fDBTBL33),$C(124),18)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),18) S $P(vobj(fDBTBL33),$C(124),18)=10,vobj(fDBTBL33,-100,"0*")=""
	I $P(vobj(fDBTBL33),$C(124),5)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),5) S $P(vobj(fDBTBL33),$C(124),5)=$piece(($H),",",2),vobj(fDBTBL33,-100,"0*")=""
	I $P(vobj(fDBTBL33),$C(124),4)="" N vSetMf S vSetMf=$P(vobj(fDBTBL33),$C(124),4) S $P(vobj(fDBTBL33),$C(124),4)=%UID,vobj(fDBTBL33,-100,"0*")=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL33)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL33)	; Display screen prompts
	S VO="54||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,16,12,1,0,0,0,0,0,0)_"01T Batch Name:"
	S VO(4)=$C(3,42,15,1,0,0,0,0,0,0)_"01T Last Modified:"
	S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,10,18,1,0,0,0,0,0,0)_"01T Run-time Routine:"
	S VO(10)=$C(5,48,9,1,0,0,0,0,0,0)_"01T By User:"
	S VO(11)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,15,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(19)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(9,15,13,1,0,0,0,0,0,0)_"01T Access File:"
	S VO(21)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(10,11,17,0,0,0,0,0,0,0)_"01TSQL Where Clause:"
	S VO(24)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(11,8,20,0,0,0,0,0,0,0)_"01TSQL Distinct Clause:"
	S VO(27)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(30)=$C(13,1,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(31)=$C(13,8,20,0,0,0,0,0,0,0)_"01TEXEC Parameter List:"
	S VO(32)=$C(13,80,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(14,1,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(34)=$C(14,80,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(15,1,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(36)=$C(15,7,21,0,52,0,0,0,0,0)_"01TInsert Restart Logic:"
	S VO(37)=$C(15,80,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(39)=$C(16,2,26,0,0,0,0,0,0,0)_"01TAllow M Global References:"
	S VO(40)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(43)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(18,5,23,0,0,0,0,0,0,0)_"01TModify Procedural Code:"
	S VO(45)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(46)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(49)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(50)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(51)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(52)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(53)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(54)=$C(23,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL33)	; Display screen data
	N V
	I %O=5 N zproc
	I   S (zproc)=""
	E  S zproc=$get(zproc)
	;
	S zproc=$get(zproc)
	;
	S VO="68|55|13|0"
	S VO(55)=$C(1,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^UTLREAD($get(%FN)))
	S VO(56)=$C(3,29,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL33,-4)),1,12)
	S VO(57)=$C(3,58,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBTBL33),$C(124),3)),"MM/DD/YEAR")
	S VO(58)=$C(3,70,10,2,0,0,0,0,0,0)_"01C"_$$TIM^%ZM($P(vobj(fDBTBL33),$C(124),5))
	S VO(59)=$C(5,29,8,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL33),$C(124),2)),1,8)
	S VO(60)=$C(5,58,20,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL33),$C(124),4)),1,20)
	S VO(61)=$C(7,29,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL33),$C(124),1)),1,40)
	S VO(62)=$C(9,29,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL33),$C(124),8)),1,12)
	S VO(63)=$C(10,29,50,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL33),$C(124),9)),1,50)
	S VO(64)=$C(11,29,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL33),$C(124),22)),1,40)
	S VO(65)=$C(13,29,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL33),$C(124),24)),1,40)
	S VO(66)=$C(15,29,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL33),$C(124),21):"Y",1:"N")
	S VO(67)=$C(16,29,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL33),$C(124),23):"Y",1:"N")
	S VO(68)=$C(18,29,1,2,0,0,0,0,0,0)_"00L"_$S($get(zproc):"Y",1:"N")
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL33)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=13 S VPT=1 S VPB=23 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL33"
	S OLNTB=23001
	;
	S VFSN("DBTBL33")="zfDBTBL33"
	;
	;
	S %TAB(1)=$C(2,28,12)_"20U12402|1|[DBTBL33]BCHID"
	S %TAB(2)=$C(2,57,10)_"20D12403|1|[DBTBL33]LTD"
	S %TAB(3)=$C(2,69,10)_"20C12405|1|[DBTBL33]TIME"
	S %TAB(4)=$C(4,28,8)_"01U12402|1|[DBTBL33]PGM|||do VP1^V01S203(.fDBTBL33)|do VP2^V01S203(.fDBTBL33)"
	S %TAB(5)=$C(4,57,20)_"20T12404|1|[DBTBL33]USER"
	S %TAB(6)=$C(6,28,40)_"01T12401|1|[DBTBL33]DES"
	S %TAB(7)=$C(8,28,12)_"01U12408|1|[DBTBL33]PFID|[DBTBL1]"
	S %TAB(8)=$C(9,28,50)_"00T12409|1|[DBTBL33]WHERE|||do VP3^V01S203(.fDBTBL33)||||||100"
	S %TAB(9)=$C(10,28,40)_"00T12422|1|[DBTBL33]DISTINCT|||do VP4^V01S203(.fDBTBL33)"
	S %TAB(10)=$C(12,28,40)_"00T12424|1|[DBTBL33]FORMAL"
	S %TAB(11)=$C(14,28,1)_"00L12421|1|[DBTBL33]RESTIND"
	S %TAB(12)=$C(15,28,1)_"00L12423|1|[DBTBL33]MGLOBAL"
	S %TAB(13)=$C(17,28,1)_"00L|*zproc|[*]@zproc"
	D VTBL(.fDBTBL33)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL33)	;Create %TAB(array)
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
VP1(fDBTBL33)	;
	; Validate routine name
	;
	I (V'=X) S ER=$$VALPGM^DBSCDI(X) Q:ER 
	;
	Q 
VP2(fDBTBL33)	;
	;
	I ($get(zproc)=""),(%O<2) D DEFAULT^DBSMACRO("@zproc",1)
	;
	Q 
VP3(fDBTBL33)	;
	;
	; I18N=OFF
	I (X["""") S RM="Use ' instead of "" for literal string reference"
	; I18N=ON
	;
	Q 
VP4(fDBTBL33)	;
	;
	N keys
	N I
	;
	Q:(X="") 
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD($P(vobj(fDBTBL33),$C(124),8))
	;
	S keys=($P(tblrec,"|",3))
	;
	F I=1:1:$L(X,",") D  Q:ER 
	.	;
	.	I '((","_keys_",")[(","_$piece(X,",",I)_",")) D
	..		;
	..		S ER=1
	..		; I18N=OFF
	..		; Invalid qualifier - ~p1
	..		S RM=$$^MSG(1430,"DISTINCT "_X)
	..		; I18N=ON
	..		Q 
	.	Q 
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL33)
	D VDA1(.fDBTBL33)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL33)	;
	D VDA1(.fDBTBL33)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL33)	;
	D VDA1(.fDBTBL33)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL33)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL33" D vSET1(.fDBTBL33,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL33,di,X)	;
	D vCoInd1(fDBTBL33,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL33" Q $$vREAD1(.fDBTBL33,di)
	Q ""
vREAD1(fDBTBL33,di)	;
	Q $$vCoInd2(fDBTBL33,di)
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
vCoMfS1(vRec,vVal)	; RecordDBTBL33.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL33.setDISTINCT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",22)
	S $P(vobj(vRec),"|",22)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL33.setFORMAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",24)
	S $P(vobj(vRec),"|",24)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL33.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL33.setMAXSIZE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",12)
	S $P(vobj(vRec),"|",12)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL33.setMGLOBAL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",23)
	S $P(vobj(vRec),"|",23)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL33.setMSGBUFS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",11)
	S $P(vobj(vRec),"|",11)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL33.setMTZ(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",19)
	S $P(vobj(vRec),"|",19)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL33.setNONRAND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",14)
	S $P(vobj(vRec),"|",14)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL33.setPFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",8)
	S $P(vobj(vRec),"|",8)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL33.setPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBTBL33.setRESTIND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",21)
	S $P(vobj(vRec),"|",21)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBTBL33.setSCHRCNT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",15)
	S $P(vobj(vRec),"|",15)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS14(vRec,vVal)	; RecordDBTBL33.setSCHTIMR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",17)
	S $P(vobj(vRec),"|",17)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS15(vRec,vVal)	; RecordDBTBL33.setTHREADS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",10)
	S $P(vobj(vRec),"|",10)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS16(vRec,vVal)	; RecordDBTBL33.setTHRLVAR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",13)
	S $P(vobj(vRec),"|",13)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS17(vRec,vVal)	; RecordDBTBL33.setTHRRCNT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",16)
	S $P(vobj(vRec),"|",16)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS18(vRec,vVal)	; RecordDBTBL33.setTHRTIMR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",18)
	S $P(vobj(vRec),"|",18)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS19(vRec,vVal)	; RecordDBTBL33.setTIME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS20(vRec,vVal)	; RecordDBTBL33.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS21(vRec,vVal)	; RecordDBTBL33.setWHERE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",9)
	S $P(vobj(vRec),"|",9)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL33.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL33",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="DES" D vCoMfS1(vOid,vVal) Q 
	I vCol="DISTINCT" D vCoMfS2(vOid,vVal) Q 
	I vCol="FORMAL" D vCoMfS3(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS4(vOid,vVal) Q 
	I vCol="MAXSIZE" D vCoMfS5(vOid,vVal) Q 
	I vCol="MGLOBAL" D vCoMfS6(vOid,vVal) Q 
	I vCol="MSGBUFS" D vCoMfS7(vOid,vVal) Q 
	I vCol="MTZ" D vCoMfS8(vOid,vVal) Q 
	I vCol="NONRAND" D vCoMfS9(vOid,vVal) Q 
	I vCol="PFID" D vCoMfS10(vOid,vVal) Q 
	I vCol="PGM" D vCoMfS11(vOid,vVal) Q 
	I vCol="RESTIND" D vCoMfS12(vOid,vVal) Q 
	I vCol="SCHRCNT" D vCoMfS13(vOid,vVal) Q 
	I vCol="SCHTIMR" D vCoMfS14(vOid,vVal) Q 
	I vCol="THREADS" D vCoMfS15(vOid,vVal) Q 
	I vCol="THRLVAR" D vCoMfS16(vOid,vVal) Q 
	I vCol="THRRCNT" D vCoMfS17(vOid,vVal) Q 
	I vCol="THRTIMR" D vCoMfS18(vOid,vVal) Q 
	I vCol="TIME" D vCoMfS19(vOid,vVal) Q 
	I vCol="USER" D vCoMfS20(vOid,vVal) Q 
	I vCol="WHERE" D vCoMfS21(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL33.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL33",$$vStrUC(vCol))
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL33)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
