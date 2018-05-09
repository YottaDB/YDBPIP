V01S307(%O,fDBTBL1F,fDBTBL1)	;DBS - DBS - SID= <DBTBL1K> Foreign Key Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL1K ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	; The DBTBL1K screen enables the institution to establish referential
	; relationships between data item values in multiple files.  For example, the
	; institution may indicate that a user cannot delete a data item value if another
	; file depends on the existence of that value.
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fDBTBL1F)#2) K vobj(+$G(fDBTBL1F)) S fDBTBL1F=$$vDbNew1("","","")
	.	I '($D(fDBTBL1)#2) K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vDbNew2("","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,FKEYS,DELETE" S VSID="DBTBL1K" S VPGM=$T(+0) S VSNAME="Foreign Key Definition"
	S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1F")="zfDBTBL1F"
	S vPSL=1
	S KEYS(1)=vobj(fDBTBL1,-3)
	S KEYS(2)=vobj(fDBTBL1,-4)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fDBTBL1F,.fDBTBL1) D VDA1(.fDBTBL1F,.fDBTBL1) D ^DBSPNT() Q 
	;
	S ER=0 D VSCRPRE(.fDBTBL1F,.fDBTBL1) I ER Q  ; Screen Pre-Processor
	;
	I '%O D VNEW(.fDBTBL1F,.fDBTBL1) D VPR(.fDBTBL1F,.fDBTBL1) D VDA1(.fDBTBL1F,.fDBTBL1)
	I %O D VLOD(.fDBTBL1F,.fDBTBL1) Q:$get(ER)  D VPR(.fDBTBL1F,.fDBTBL1) D VDA1(.fDBTBL1F,.fDBTBL1)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fDBTBL1F,.fDBTBL1)
	Q 
	;
VNEW(fDBTBL1F,fDBTBL1)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL1F,.fDBTBL1)
	D VLOD(.fDBTBL1F,.fDBTBL1)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL1F,fDBTBL1)	;
	Q:(vobj(fDBTBL1F,-3)="")!(vobj(fDBTBL1F,-4)="")!(vobj(fDBTBL1F,-5)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL1F,-3)="")!(vobj(fDBTBL1F,-4)="")!(vobj(fDBTBL1F,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID,FKEYS") Q 
	 N V1,V2,V3 S V1=vobj(fDBTBL1F,-3),V2=vobj(fDBTBL1F,-4),V3=vobj(fDBTBL1F,-5) I ($D(^DBTBL(V1,19,V2,V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fDBTBL1F),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1F),$C(124),3) S $P(vobj(fDBTBL1F),$C(124),3)=0,vobj(fDBTBL1F,-100,"0*")=""
	I $P(vobj(fDBTBL1F),$C(124),6)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1F),$C(124),6) S $P(vobj(fDBTBL1F),$C(124),6)=0,vobj(fDBTBL1F,-100,"0*")=""
	I $P(vobj(fDBTBL1F),$C(124),2)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1F),$C(124),2) S $P(vobj(fDBTBL1F),$C(124),2)=1,vobj(fDBTBL1F,-100,"0*")=""
	I $P(vobj(fDBTBL1F),$C(124),1)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1F),$C(124),1) S $P(vobj(fDBTBL1F),$C(124),1)=1,vobj(fDBTBL1F,-100,"0*")=""
	I $P(vobj(fDBTBL1F),$C(124),4)="" N vSetMf S vSetMf=$P(vobj(fDBTBL1F),$C(124),4) S $P(vobj(fDBTBL1F),$C(124),4)=0,vobj(fDBTBL1F,-100,"0*")=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL1F,fDBTBL1)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL1F,fDBTBL1)	; Display screen prompts
	S VO="24||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,1,81,1,0,0,0,0,0,0)_"01T                           Foreign Key Definition                                "
	S VO(2)=$C(3,11,9,0,0,0,0,0,0,0)_"01TFilename:"
	S VO(3)=$C(4,3,16,1,0,0,0,0,0,0)_"01T Foreign Key(s):"
	S VO(4)=$C(6,13,7,0,0,0,0,0,0,0)_"01TDelete:"
	S VO(5)=$C(8,2,18,1,0,0,0,0,0,0)_"01T Related Filename:"
	S VO(6)=$C(9,7,12,0,0,0,0,0,0,0)_"01TAccess Keys:"
	S VO(7)=$C(12,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(8)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(13,3,14,0,0,0,0,0,0,0)_"01TEach record in"
	S VO(10)=$C(13,31,9,0,0,0,0,0,0,0)_"01Trefers to"
	S VO(11)=$C(13,41,3,1,0,0,0,0,0,0)_"01Tmin"
	S VO(12)=$C(13,48,1,0,0,0,0,0,0,0)_"01T&"
	S VO(13)=$C(13,50,3,1,0,0,0,0,0,0)_"01Tmax"
	S VO(14)=$C(13,57,10,0,0,0,0,0,0,0)_"01Trecords in"
	S VO(15)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(14,3,15,0,0,0,0,0,0,0)_"01TEach record in "
	S VO(18)=$C(14,31,13,0,0,0,0,0,0,0)_"01Trefers to min"
	S VO(19)=$C(14,48,5,0,0,0,0,0,0,0)_"01T& max"
	S VO(20)=$C(14,57,10,0,0,0,0,0,0,0)_"01Trecords in"
	S VO(21)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(15,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	S VO(23)=$C(17,2,19,1,0,0,0,0,0,0)_"01T Update Constraint:"
	S VO(24)=$C(17,48,20,1,0,0,0,0,0,0)_"01T  Delete Constraint:"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL1F,fDBTBL1)	; Display screen data
	N V
	I %O=5 N DELETE,DES,DESR1,DESR2,FID,FKEYS,PKEYS
	I   S (DELETE,DES,DESR1,DESR2,FID,FKEYS,PKEYS)=""
	E  S DELETE=$get(DELETE) S DES=$get(DES) S DESR1=$get(DESR1) S DESR2=$get(DESR2) S FID=$get(FID) S FKEYS=$get(FKEYS) S PKEYS=$get(PKEYS)
	;
	S DELETE=$get(DELETE)
	S DES=$get(DES)
	S DESR1=$get(DESR1)
	S DESR2=$get(DESR2)
	S FID=$get(FID)
	S FKEYS=$get(FKEYS)
	S PKEYS=$get(PKEYS)
	;
	S VO="41|25|13|"
	S VO(25)=$C(3,21,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL1,-4)),1,12)
	S VO(26)=$C(3,35,40,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL1),$C(124),1)),1,40)
	S VO(27)=$C(4,20,60,2,0,0,0,0,0,0)_"00U"_$get(FKEYS)
	S VO(28)=$C(6,21,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
	S VO(29)=$C(8,21,12,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL1F),$C(124),5)),1,12)
	S VO(30)=$C(8,35,40,2,0,0,0,0,0,0)_"01T"_$get(DES)
	S VO(31)=$C(9,20,60,2,0,0,0,0,0,0)_"01T"_$get(PKEYS)
	S VO(32)=$C(13,18,12,2,0,0,0,0,0,0)_"01T"_$get(FID)
	S VO(33)=$C(13,45,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1F),$C(124),1)
	S VO(34)=$C(13,54,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1F),$C(124),2)
	S VO(35)=$C(13,68,12,2,0,0,0,0,0,0)_"01T"_$get(DESR1)
	S VO(36)=$C(14,18,12,2,0,0,0,0,0,0)_"01T"_$get(DESR2)
	S VO(37)=$C(14,45,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1F),$C(124),6)
	S VO(38)=$C(14,54,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1F),$C(124),7)
	S VO(39)=$C(14,68,12,2,0,0,0,0,0,0)_"01T"_$get(FID)
	S VO(40)=$C(17,22,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1F),$C(124),4)
	S VO(41)=$C(17,69,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fDBTBL1F),$C(124),3)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL1F,fDBTBL1)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=17 S VPT=1 S VPB=17 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1F,DBTBL1" S VSCRPP=1 S VSCRPP=1
	S OLNTB=17069
	;
	S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1F")="zfDBTBL1F"
	;
	;
	S %TAB(1)=$C(2,20,12)_"20U12402|1|[DBTBL1]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||256"
	S %TAB(2)=$C(2,34,40)_"20T12401|1|[DBTBL1]DES"
	S %TAB(3)=$C(3,19,60)_"01U|*FKEYS|[*]@OOE8|[DBTBL1F]:NOVAL||do VP1^V01S307(.fDBTBL1F,.fDBTBL1)|do VP2^V01S307(.fDBTBL1F,.fDBTBL1)"
	S %TAB(4)=$C(5,20,1)_"00L|*DELETE|[*]@DELETE|||do VP3^V01S307(.fDBTBL1F,.fDBTBL1)"
	S %TAB(5)=$C(7,20,12)_"01U12405|1|[DBTBL1F]TBLREF|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|do VP4^V01S307(.fDBTBL1F,.fDBTBL1)||||||256"
	S %TAB(6)=$C(7,34,40)_"20T|*DES|[*]@DES"
	S %TAB(7)=$C(8,19,60)_"20T|*PKEYS|[*]@PKEYS"
	S %TAB(8)=$C(12,17,12)_"20T|*FID|[*]@FID"
	S %TAB(9)=$C(12,44,2)_"01N12401|1|[DBTBL1F]RCTOMIN|||||0|1"
	S %TAB(10)=$C(12,53,2)_"01N12402|1|[DBTBL1F]RCTOMAX|||||0"
	S %TAB(11)=$C(12,67,12)_"20T|*DESR1|[*]@DESR1"
	S %TAB(12)=$C(13,17,12)_"20T|*DESR2|[*]@DESR2"
	S %TAB(13)=$C(13,44,2)_"00N12406|1|[DBTBL1F]RCFRMIN|||||0"
	S %TAB(14)=$C(13,53,2)_"00N12407|1|[DBTBL1F]RCFRMAX|||||0"
	S %TAB(15)=$C(13,67,12)_"20T|*FID|[*]@FID"
	S %TAB(16)=$C(16,21,1)_"01N12404|1|[DBTBL1F]UPD|[STBLFKOPT]||do VP5^V01S307(.fDBTBL1F,.fDBTBL1)"
	S %TAB(17)=$C(16,68,1)_"01N12403|1|[DBTBL1F]DEL|[STBLFKOPT]||do VP6^V01S307(.fDBTBL1F,.fDBTBL1)"
	D VTBL(.fDBTBL1F,.fDBTBL1)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL1F,fDBTBL1)	;Create %TAB(array)
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VSPP	; screen post proc
	D VSPP1(.fDBTBL1F,.fDBTBL1)
	;  #ACCEPT Date=11/05/03; pgm=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
VSPP1(fDBTBL1F,fDBTBL1)	;
	; Compare field attributes between two data items
	N J
	N fid2
	S fid2=$P(vobj(fDBTBL1F),$C(124),5)
	F J=1:1:$L(FKEYS,",") D
	.	N column N dd1 N dd2
	.	S column=$piece(FKEYS,",",J)
	.	N colrec S colrec=$$getSchCln^UCXDD(FID,column)
	.	S dd1=$P(colrec,"|",6)_" "_$P(colrec,"|",7)
	.	I ($P(colrec,"|",8)>0) S dd1=dd1_"."_$P(colrec,"|",8)
	.	N colrec2 S colrec2=$$getSchCln^UCXDD(fid2,column)
	.	S dd2=$P(colrec2,"|",6)_" "_$P(colrec2,"|",7)
	.	I ($P(colrec2,"|",8)>0) S dd2=dd2_"."_$P(colrec2,"|",8)
	.	I (dd1'=dd2) D
	..		;
	..		S ER=1
	..		; Mismatch between Data Item ~p1 in files ~p2 and ~p3
	..		S RM=$$^MSG(8263,column,FID,fid2)
	..		Q 
	.	Q 
	Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(fDBTBL1F,fDBTBL1)	;
	;
	N J
	N badcols
	;
	Q:($translate(X," ","")="") 
	;
	D CHANGE^DBSMACRO("TBL","")
	;
	S badcols=""
	F J=1:1:$L(X,",") D
	.	;
	.	N column
	.	;
	.	S column=$piece(X,",",J)
	.	;
	.	Q:$$isLit^UCGM(column) 
	.	Q:($E(column,1)="$") 
	.	Q:$$isColumn^UCXDD(FID,column) 
	.	;
	.	S badcols=badcols_column_","
	.	Q 
	;
	I '(badcols="") D  Q 
	.	;
	.	S ER=1
	.	; Invalid reference(s) , ~p1
	.	S RM=$$^MSG(1440,$E(badcols,1,$L(badcols)-1))
	.	;
	.	I ($D(^DBTBL("SYSDEV",19,FID,X))#2) D vDbDe1()
	.	Q 
	;
	D UNPROT^DBSMACRO("@DELETE")
	;
	S DELETE=0
	S DES=""
	;
	N recload S recload=$$vDb1("SYSDEV",FID,X)
	K vobj(+$G(fDBTBL1F)) S fDBTBL1F=$$vReCp1(recload)
	;
	I ($G(vobj(fDBTBL1F,-2))=0) D
	.	;
	.	S OPTION=0
	.	S (PKEYS,DESR1,DESR2)=""
	.	;
	. S $P(vobj(fDBTBL1F),$C(124),2)=1
	. S $P(vobj(fDBTBL1F),$C(124),1)=1
	. S $P(vobj(fDBTBL1F),$C(124),3)=0
	. S $P(vobj(fDBTBL1F),$C(124),6)=0
	. S $P(vobj(fDBTBL1F),$C(124),4)=0
	.	;
	.	D PROTECT^DBSMACRO("@DELETE")
	.	D DISPLAY^DBSMACRO("ALL")
	.	Q 
	;
	E  D
	.	;
	.	N PARFID N TBLREF
	.	;
	.	S OPTION=1
	.	;
	.	S TBLREF=$P(vobj(fDBTBL1F),$C(124),5)
	.	;
	.	N tblrec S tblrec=$$getSchTbl^UCXDD(TBLREF)
	.	;
	.	S DES=$P(tblrec,"|",31)
	.	;
	.	S PKEYS=$P(tblrec,"|",3)
	.	S (DESR1,DESR2)=TBLREF
	.	;
	.	D DISPLAY^DBSMACRO("ALL")
	.	;
	.	; If this points to a parent file, it can only be edited there
	.	S PARFID=$P(tblrec,"|",7)
	.	I '(PARFID=""),($D(^DBTBL("SYSDEV",19,PARFID,X))#2) D
	..		;
	..		S OPTION=2
	..		S %NOPRMT="N"
	..		;
	..		D GOTO^DBSMACRO("END")
	..		;
	..		; Exists in Supertype Entity ~p1
	..		WRITE $$MSG^%TRMVT($$^MSG(7294,PARFID),0,1)
	..		Q 
	.	Q 
	;
	K vobj(+$G(recload)) Q 
VP2(fDBTBL1F,fDBTBL1)	;
	;
	D CHANGE^DBSMACRO("TBL","[DBTBL1F]:QU ""[DBTBL1F]FID=<<FID>>""")
	;
	Q 
VP3(fDBTBL1F,fDBTBL1)	;
	;
	I X D GOTO^DBSMACRO("END")
	;
	Q 
VP4(fDBTBL1F,fDBTBL1)	;
	;
	N lendiff
	;
	Q:(X="") 
	;
	I (FID=X) D  Q 
	.	;
	.	S ER=1
	.	; Invalid file
	.	S RM=$$^MSG(1332)
	.	Q 
	;
	Q:(+OPTION'=+0) 
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(X)
	;
	I ($P(tblrec,"|",6)="") D  Q 
	.	;
	.	S ER=1
	.	; Create run-time filer routine first
	.	S RM=$$^MSG(645)
	.	Q 
	;
	S PKEYS=$P(tblrec,"|",3)
	S DES=$P(tblrec,"|",31)
	;
	D DISPLAY^DBSMACRO("@PKEYS",PKEYS)
	D DISPLAY^DBSMACRO("@DES",DES)
	D DISPLAY^DBSMACRO("@DESR1",X)
	D DISPLAY^DBSMACRO("@DESR2",X)
	;
	S lendiff=$L(PKEYS,",")-$L(FKEYS,",")
	;
	I (lendiff>0) D
	.	;
	.	S ER=1
	.	; Too few keys in reference ~p1
	.	S RM=$$^MSG(2663,lendiff)
	.	Q 
	E  I (lendiff<0) D
	.	;
	.	S ER=1
	.	; Too many keys in reference ~p1
	.	S RM=$$^MSG(2664,lendiff)
	.	Q 
	;
	Q 
VP5(fDBTBL1F,fDBTBL1)	;
	;
	Q:(X="") 
	;
	D CONSTR
	;
	Q 
	;
CONSTR	; Verify Constraint Parameters
	;
	N J
	;
	I (X=1) F J=1:1:$L(FKEYS,",") D
	.	;
	.	N key
	.	;
	.	S key=$piece(FKEYS,",",J)
	.	;
	.	Q:$$isLit^UCGM(key) 
	.	Q:($E(key,1)="$") 
	.	;
	.	N colrec S colrec=$$getSchCln^UCXDD(FID,key)
	.	;
	.	I ($P(colrec,"|",28)!($P(colrec,"|",3)["*")) D
	..		;
	..		S ER=1
	..		; Required fields cannot be null - ~p1
	..		S RM=$$^MSG(2388,key)
	..		Q 
	.	Q 
	;
	Q 
VP6(fDBTBL1F,fDBTBL1)	;
	;
	I '(X="") D CONSTR
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL1F,.fDBTBL1)
	D VDA1(.fDBTBL1F,.fDBTBL1)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL1F,fDBTBL1)	;
	D VDA1(.fDBTBL1F,.fDBTBL1)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL1F,fDBTBL1)	;
	D VDA1(.fDBTBL1F,.fDBTBL1)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL1F,.fDBTBL1)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL1F" D vSET1(.fDBTBL1F,di,X)
	I sn="DBTBL1" D vSET2(.fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL1F,di,X)	;
	D vCoInd1(fDBTBL1F,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET2(fDBTBL1,di,X)	;
	D vCoInd2(fDBTBL1,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL1F" Q $$vREAD1(.fDBTBL1F,di)
	I fid="DBTBL1" Q $$vREAD2(.fDBTBL1,di)
	Q ""
vREAD1(fDBTBL1F,di)	;
	Q $$vCoInd3(fDBTBL1F,di)
vREAD2(fDBTBL1,di)	;
	Q $$vCoInd4(fDBTBL1,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VSCRPRE(fDBTBL1F,fDBTBL1)	; Screen Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	K DES,DESR1,DESR2,PKEYS
	;  #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL1F WHERE %LIBS='SYSDEV' AND FID=:FID AND FKEYS=:X
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb1("SYSDEV",FID,X)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBSDFKF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL1F.setDEL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL1F.setPKEYS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",8)
	S $P(vobj(vRec),"|",8)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL1F.setRCFRMAX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",7)
	S $P(vobj(vRec),"|",7)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL1F.setRCFRMIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL1F.setRCTOMAX(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL1F.setRCTOMIN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL1F.setTBLREF(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL1F.setUPD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL1F.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL1F",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="DEL" D vCoMfS1(vOid,vVal) Q 
	I vCol="PKEYS" D vCoMfS2(vOid,vVal) Q 
	I vCol="RCFRMAX" D vCoMfS3(vOid,vVal) Q 
	I vCol="RCFRMIN" D vCoMfS4(vOid,vVal) Q 
	I vCol="RCTOMAX" D vCoMfS5(vOid,vVal) Q 
	I vCol="RCTOMIN" D vCoMfS6(vOid,vVal) Q 
	I vCol="TBLREF" D vCoMfS7(vOid,vVal) Q 
	I vCol="UPD" D vCoMfS8(vOid,vVal) Q 
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
vCoInd3(vOid,vCol)	; RecordDBTBL1F.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL1F",$$vStrUC(vCol))
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
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1F,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1F"
	S vobj(vOid)=$G(^DBTBL(v1,19,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,19,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL1F)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1F",vobj(vOid,-2)=0,vobj(vOid)=""
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
vReCp1(v1)	;	RecordDBTBL1F.copy: DBTBL1F
	;
	Q $$copy^UCGMR(recload)
