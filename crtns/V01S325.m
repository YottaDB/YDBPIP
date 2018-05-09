V01S325(%O,fDBTBL7)	;DBS -  - SID= <DBTBL7> Trigger Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL7 ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fDBTBL7)#2) K vobj(+$G(fDBTBL7)) S fDBTBL7=$$vDbNew1("","","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL7" S VPGM=$T(+0) S VSNAME="Trigger Definition"
	S VFSN("DBTBL7")="zfDBTBL7"
	S vPSL=1
	S KEYS(1)=vobj(fDBTBL7,-3)
	S KEYS(2)=vobj(fDBTBL7,-4)
	S KEYS(3)=vobj(fDBTBL7,-5)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fDBTBL7) D VDA1(.fDBTBL7) D ^DBSPNT() Q 
	;
	S ER=0 D VSCRPRE(.fDBTBL7) I ER Q  ; Screen Pre-Processor
	;
	I '%O D VNEW(.fDBTBL7) D VPR(.fDBTBL7) D VDA1(.fDBTBL7)
	I %O D VLOD(.fDBTBL7) Q:$get(ER)  D VPR(.fDBTBL7) D VDA1(.fDBTBL7)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fDBTBL7)
	Q 
	;
VNEW(fDBTBL7)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL7)
	D VLOD(.fDBTBL7)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL7)	;
	Q:(vobj(fDBTBL7,-3)="")!(vobj(fDBTBL7,-4)="")!(vobj(fDBTBL7,-5)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL7,-3)="")!(vobj(fDBTBL7,-4)="")!(vobj(fDBTBL7,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,TABLE,TRGID") Q 
	 N V1,V2,V3 S V1=vobj(fDBTBL7,-3),V2=vobj(fDBTBL7,-4),V3=vobj(fDBTBL7,-5) I ($D(^DBTBL(V1,7,V2,V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL7)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL7)	; Display screen prompts
	S VO="50||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,9,11,0,0,0,0,0,0,0)_"01TTable Name:"
	S VO(4)=$C(3,44,13,0,0,0,0,0,0,0)_"01TLast Updated:"
	S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,7,13,0,0,0,0,0,0,0)_"01TTrigger Name:"
	S VO(8)=$C(4,49,8,0,0,0,0,0,0,0)_"01TBy User:"
	S VO(9)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,7,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(8,12,57,0,0,0,0,0,0,0)_"01T-------------------- Trigger Actions --------------------"
	S VO(19)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(10,12,14,0,0,0,0,0,0,0)_"01TBefore INSERT:"
	S VO(24)=$C(10,32,14,0,0,0,0,0,0,0)_"01TBefore UPDATE:"
	S VO(25)=$C(10,53,14,0,0,0,0,0,0,0)_"01TBefore DELETE:"
	S VO(26)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(11,13,13,0,0,0,0,0,0,0)_"01TAfter INSERT:"
	S VO(29)=$C(11,33,13,0,0,0,0,0,0,0)_"01TAfter UPDATE:"
	S VO(30)=$C(11,54,13,0,0,0,0,0,0,0)_"01TAfter DELETE:"
	S VO(31)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(32)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(33)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(34)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(35)=$C(13,14,56,0,0,0,0,0,0,0)_"01TA list of column names associated with the UPDATE action"
	S VO(36)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(37)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(39)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(40)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(41)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(43)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(44)=$C(17,14,58,0,0,0,0,0,0,0)_"01TExecute trigger only if the following condition is true   "
	S VO(45)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(46)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(19,1,2,0,0,0,0,0,0,0)_"11Tx "
	S VO(49)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(50)=$C(20,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL7)	; Display screen data
	N V
	;
	S VO="65|51|13|0"
	S VO(51)=$C(1,1,80,2,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($get(%FN)))
	S VO(52)=$C(3,21,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL7,-4)),1,12)
	S VO(53)=$C(3,58,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBTBL7),$C(124),9)),"MM/DD/YEAR")
	S VO(54)=$C(3,69,10,2,0,0,0,0,0,0)_"01C"_$$TIM^%ZM($P(vobj(fDBTBL7),$C(124),11))
	S VO(55)=$C(4,21,20,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL7,-5)),1,20)
	S VO(56)=$C(4,58,20,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL7),$C(124),10)),1,20)
	S VO(57)=$C(6,21,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL7),$C(124),1)),1,40)
	S VO(58)=$C(10,27,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL7),$C(124),2):"Y",1:"N")
	S VO(59)=$C(10,47,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL7),$C(124),3):"Y",1:"N")
	S VO(60)=$C(10,68,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL7),$C(124),4):"Y",1:"N")
	S VO(61)=$C(11,27,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL7),$C(124),5):"Y",1:"N")
	S VO(62)=$C(11,47,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL7),$C(124),6):"Y",1:"N")
	S VO(63)=$C(11,68,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fDBTBL7),$C(124),7):"Y",1:"N")
	S VO(64)=$C(15,3,76,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL7),$C(124),8)),1,76)
	S VO(65)=$C(19,3,76,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL7),$C(124),12)),1,76)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL7)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=14 S VPT=1 S VPB=20 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL7" S VSCRPP=1 S VSCRPP=1
	S OLNTB=20001
	;
	S VFSN("DBTBL7")="zfDBTBL7"
	;
	;
	S %TAB(1)=$C(2,20,12)_"20U12402|1|[DBTBL7]TABLE|[DBTBL1]||||||||25"
	S %TAB(2)=$C(2,57,10)_"20D12409|1|[DBTBL7]TLD"
	S %TAB(3)=$C(2,68,10)_"20C12411|1|[DBTBL7]TIME"
	S %TAB(4)=$C(3,20,20)_"20T12403|1|[DBTBL7]TRGID"
	S %TAB(5)=$C(3,57,20)_"20T12410|1|[DBTBL7]USER"
	S %TAB(6)=$C(5,20,40)_"01T12401|1|[DBTBL7]DES"
	S %TAB(7)=$C(9,26,1)_"00L12402|1|[DBTBL7]ACTBI|||do VP1^V01S325(.fDBTBL7)"
	S %TAB(8)=$C(9,46,1)_"00L12403|1|[DBTBL7]ACTBU"
	S %TAB(9)=$C(9,67,1)_"00L12404|1|[DBTBL7]ACTBD|||do VP2^V01S325(.fDBTBL7)"
	S %TAB(10)=$C(10,26,1)_"00L12405|1|[DBTBL7]ACTAI|||do VP3^V01S325(.fDBTBL7)"
	S %TAB(11)=$C(10,46,1)_"00L12406|1|[DBTBL7]ACTAU"
	S %TAB(12)=$C(10,67,1)_"00L12407|1|[DBTBL7]ACTAD|||do VP4^V01S325(.fDBTBL7)"
	S %TAB(13)=$C(14,2,76)_"00U12408|1|[DBTBL7]COLUMNS|||do VP5^V01S325(.fDBTBL7)||||||255"
	S %TAB(14)=$C(18,2,76)_"00T12412|1|[DBTBL7]IFCOND|||||||||255"
	D VTBL(.fDBTBL7)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL7)	;Create %TAB(array)
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VSPP	; screen post proc
	D VSPP1(.fDBTBL7)
	;  #ACCEPT Date=11/05/03; pgm=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
VSPP1(fDBTBL7)	;
	N code N i N seq N TABLE N TRGID N zux1
	S TABLE=vobj(fDBTBL7,-4)
	S TRGID=vobj(fDBTBL7,-5)
	S $P(vobj(fDBTBL7),$C(124),11)=$piece(($H),",",2)
	S $P(vobj(fDBTBL7),$C(124),9)=+$H
	S zux1=0
	I %O=0 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL7FL(fDBTBL7,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL7,-100) S vobj(fDBTBL7,-2)=1 Tcommit:vTp  
	I %O>0,($D(vobj(fDBTBL7,-100))) S zux1=1 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL7FL(fDBTBL7,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL7,-100) S vobj(fDBTBL7,-2)=1 Tcommit:vTp  
	S seq=0
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N dbtbl7d S dbtbl7d=$G(^DBTBL($P(ds,$C(9),1),7,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	.	S seq=seq+1
	.	S code(seq)=dbtbl7d
	.	Q 
	D ^DBSWRITE("code")
	I VFMQ="Q",zux1 Q 
	I VFMQ="Q" S ER=1 S RM=$$^MSG(6710,TRGID) D VREPRNT Q 
	; delete source code from disk and replace it with code()
	D vDbDe1()
	S i=""
	F  S i=$order(code(i)) Q:(i="")  D
	.	N rec S rec=$$vDbNew2("SYSDEV",TABLE,TRGID,i)
	. S:'$D(vobj(rec,-100,"0*","CODE")) vobj(rec,-100,"0*","CODE")="T000"_vobj(rec) S vobj(rec,-100,"0*")="",vobj(rec)=code(i)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL7DF(rec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(rec,-100) S vobj(rec,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(rec)) Q 
	;
	S filed=1 ; Avoid call to filer again
	K VFSN
	Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(fDBTBL7)	;
	;
	I 'X Q 
	I '($D(TMP(2))#2) Q 
	;
	N trgid
	S trgid=$order(TMP(2,"")) ; Trigger name
	I trgid=vobj(fDBTBL7,-5) Q  ; Current triggger name
	;
	I $E(vobj(fDBTBL7,-5),1)="Z",$E(trgid,1)'="Z" Q  ; User-defined trigger
	S ER=1 S RM="Already defined by trigger "_trgid ; Duplicate definition
	Q 
VP2(fDBTBL7)	;
	;
	I 'X Q 
	I '($D(TMP(4))#2) Q 
	;
	N trgid
	S trgid=$order(TMP(4,"")) ; Trigger name
	I trgid=vobj(fDBTBL7,-5) Q  ; Current triggger name
	I $E(vobj(fDBTBL7,-5),1)="Z",$E(trgid,1)'="Z" Q  ; User-defined triger
	S ER=1 S RM="Already defined by trigger "_trgid ; Duplicate definition
	Q 
VP3(fDBTBL7)	;
	;
	I 'X Q 
	I '($D(TMP(5))#2) Q 
	;
	N trgid
	S trgid=$order(TMP(5,"")) ; Trigger name
	I trgid=vobj(fDBTBL7,-5) Q  ; Current triggger name
	I $E(vobj(fDBTBL7,-5),1)="Z",$E(trgid,1)'="Z" Q  ; User-defined tr$
	S ER=1 S RM="Already defined by trigger "_trgid ; Duplicate definition
	Q 
VP4(fDBTBL7)	;
	;
	D chk0(.fDBTBL7) I ER Q 
	D chk1(.fDBTBL7) I ER Q 
	D chk2(.fDBTBL7)
	Q 
	;
chk0(fDBTBL7)	; Check missing required field
	;
	I X Q 
	I $P(vobj(fDBTBL7),$C(124),2) Q 
	I $P(vobj(fDBTBL7),$C(124),3) Q 
	I $P(vobj(fDBTBL7),$C(124),4) Q 
	I $P(vobj(fDBTBL7),$C(124),5) Q 
	I $P(vobj(fDBTBL7),$C(124),6) Q 
	;
	S ER=1 S RM=$$^MSG(1768)
	Q 
	;
chk1(fDBTBL7)	; Check duplicate trigger action
	;
	I 'X Q 
	I '($D(TMP(7))#2) Q 
	N trgid
	S trgid=$order(TMP(7,"")) ; Trigger name
	I trgid=vobj(fDBTBL7,-5) Q 
	I $E(vobj(fDBTBL7,-5),1)="Z",$E(trgid,1)'="Z" Q 
	S ER=1 S RM="Already defined by trigger "_trgid ; Duplicate definition
	Q 
	;
chk2(fDBTBL7)	;
	; Skip column name prompt if not BU or AU actions
	;
	I $P(vobj(fDBTBL7),$C(124),3)!$P(vobj(fDBTBL7),$C(124),6) Q  ; UPDATE action defined
	I '($P(vobj(fDBTBL7),$C(124),8)="") D DELETE^DBSMACRO("[DBTBL7]COLUMNS","1","0")
	D GOTO^DBSMACRO("NEXT")
	Q 
VP5(fDBTBL7)	;
	I X="" Q 
	;
	; Validate column names
	N col N column N i
	;
	F i=1:1:$L(X,",") D  I $get(ER) Q 
	.	S col=$piece(X,",",i)
	.	S column=vobj(fDBTBL7,-4)_"."_col
	.	I '$$VER^DBSDD(column) S ER=1 S RM=$$^MSG(1286,column) Q 
	.	I '$D(TMP1(col)) Q 
	.	I $E(vobj(fDBTBL7,-5),1)="Z" Q 
	.	I $P(vobj(fDBTBL7),$C(124),3) D chk3(3,fDBTBL7) I $get(ER) Q 
	.	I $P(vobj(fDBTBL7),$C(124),6) D chk3(6,fDBTBL7) I $get(ER) Q 
	.	Q 
	Q 
	;
chk3(opt,fDBTBL7)	;
	;
	N ER
	;
	S trgid=$order(TMP1(col,opt,""))
	I trgid="" Q 
	I trgid=vobj(fDBTBL7,-5) Q 
	S ER=1 S RM="Column "_col_" already defined by trigger "_trgid
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL7)
	D VDA1(.fDBTBL7)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL7)	;
	D VDA1(.fDBTBL7)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL7)	;
	D VDA1(.fDBTBL7)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL7)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL7" D vSET1(.fDBTBL7,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL7,di,X)	;
	D vCoInd1(fDBTBL7,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL7" Q $$vREAD1(.fDBTBL7,di)
	Q ""
vREAD1(fDBTBL7,di)	;
	Q $$vCoInd2(fDBTBL7,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VSCRPRE(fDBTBL7)	; Screen Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	; Restrict implicit definitions
	N srclib N TABLE
	S TABLE=vobj(fDBTBL7,-4)
	S srclib=$$LIB^DBSDD(TABLE,%LIBS)
	I $piece(srclib,".",1)'=%LIBS S ER=1 S RM=$$^MSG(7081,srclib) Q 
	S UX=1 ; Force <f>ile action
	S TABLE=vobj(fDBTBL7,-4)
	; Build temporary index file TMP(ACTION,TRGID) and TMP1()
	N col N column N i N j N status N trgid
	K TMP,TMP1 ; Delete temp file
	N ds,vos1,vos2,vos3 S ds=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	N record,vop1 S vop1=$P(ds,$C(9),3),record=$G(^DBTBL($P(ds,$C(9),1),7,$P(ds,$C(9),2),vop1))
	.	I $P(record,$C(124),2) S TMP(2,vop1)=""
	.	I $P(record,$C(124),4) S TMP(4,vop1)=""
	.	I $P(record,$C(124),5) S TMP(5,vop1)=""
	.	I $P(record,$C(124),7) S TMP(7,vop1)=""
	.	I $P(record,$C(124),3) D
	..		I ($P(record,$C(124),8)="") Q 
	..		F i=1:1:$L($P(record,$C(124),8)) D
	...			S col=$piece($P(record,$C(124),8),",",i)
	...			S TMP1(col,3,vop1)=""
	...			Q 
	..		I $P(record,$C(124),6) D
	...			I ($P(record,$C(124),8)="") Q 
	...			F i=1:1:$L($P(record,$C(124),8)) D
	....				S col=$piece($P(record,$C(124),8),",",i)
	....				S TMP1(col,6,vop1)=""
	....				Q 
	...			;
	...			Q 
	..		Q 
	..		;  #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	..		Q 
	..		; ----------------
	..		;  #OPTION ResultClass 0
	..		Q
	.	Q 
	Q 
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
vDbDe1()	; DELETE FROM DBTBL7D WHERE %LIBS='SYSDEV' AND TABLE=:TABLE AND TRGID=:TRGID AND SEQ>0
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,7,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL7.setACTAD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",7)
	S $P(vobj(vRec),"|",7)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL7.setACTAI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL7.setACTAU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL7.setACTBD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL7.setACTBI(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL7.setACTBU(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL7.setCOLUMNS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",8)
	S $P(vobj(vRec),"|",8)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL7.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL7.setIFCOND(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",12)
	S $P(vobj(vRec),"|",12)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL7.setPROCMODE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",13)
	S $P(vobj(vRec),"|",13)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL7.setTIME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",11)
	S $P(vobj(vRec),"|",11)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS12(vRec,vVal)	; RecordDBTBL7.setTLD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",9)
	S $P(vobj(vRec),"|",9)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS13(vRec,vVal)	; RecordDBTBL7.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",10)
	S $P(vobj(vRec),"|",10)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL7.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL7",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="ACTAD" D vCoMfS1(vOid,vVal) Q 
	I vCol="ACTAI" D vCoMfS2(vOid,vVal) Q 
	I vCol="ACTAU" D vCoMfS3(vOid,vVal) Q 
	I vCol="ACTBD" D vCoMfS4(vOid,vVal) Q 
	I vCol="ACTBI" D vCoMfS5(vOid,vVal) Q 
	I vCol="ACTBU" D vCoMfS6(vOid,vVal) Q 
	I vCol="COLUMNS" D vCoMfS7(vOid,vVal) Q 
	I vCol="DES" D vCoMfS8(vOid,vVal) Q 
	I vCol="IFCOND" D vCoMfS9(vOid,vVal) Q 
	I vCol="PROCMODE" D vCoMfS10(vOid,vVal) Q 
	I vCol="TIME" D vCoMfS11(vOid,vVal) Q 
	I vCol="TLD" D vCoMfS12(vOid,vVal) Q 
	I vCol="USER" D vCoMfS13(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL7.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL7",$$vStrUC(vCol))
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
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL7)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew2(v1,v2,v3,v4)	;	vobj()=Class.new(DBTBL7D)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7D",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vOpen1()	;	%LIBS,TABLE,TRGID,SEQ FROM DBTBL7D WHERE %LIBS='SYSDEV' AND TABLE=:TABLE AND TRGID=:TRGID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(TABLE) I vos2="" G vL1a0
	S vos3=$G(TRGID) I vos3="" G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBTBL("SYSDEV",7,vos2,vos3,vos4),1) I vos4="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	%LIBS,TABLE,TRGID FROM DBTBL7 WHERE %LIBS='SYSDEV' AND TABLE=:TABLE
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(TABLE) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",7,vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	%LIBS,TABLE,TRGID,SEQ FROM DBTBL7D WHERE %LIBS='SYSDEV' AND TABLE=:TABLE AND TRGID=:TRGID AND SEQ>0
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(TABLE) I vos2="" G vL3a0
	S vos3=$G(TRGID) I vos3="" G vL3a0
	S vos4=0
vL3a4	S vos4=$O(^DBTBL("SYSDEV",7,vos2,vos3,vos4),1) I vos4="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
