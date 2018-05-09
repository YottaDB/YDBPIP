 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL1K ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S061(%O,fDBTBL1F,fDBTBL1) ; DBS - DBS - SID= <DBTBL1K> Foreign Key Definition
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
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
 .	I '($D(fDBTBL1F)#2)  K vobj(+$G(fDBTBL1F)) S fDBTBL1F=$$vcdmNew^RecordDBTBL1F()
 .	I '($D(fDBTBL1)#2)  K vobj(+$G(fDBTBL1)) S fDBTBL1=$$vcdmNew^RecordDBTBL1()
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
VNEW(fDBTBL1F,fDBTBL1) ; Initialize arrays if %O=0
 ;
 D VDEF(.fDBTBL1F,.fDBTBL1)
 D VLOD(.fDBTBL1F,.fDBTBL1)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fDBTBL1F,fDBTBL1) ; 
 Q:(vobj(fDBTBL1F,-3)="")!(vobj(fDBTBL1F,-4)="")!(vobj(fDBTBL1F,-5)="") 
 Q:%O  S ER=0 I (vobj(fDBTBL1F,-3)="")!(vobj(fDBTBL1F,-4)="")!(vobj(fDBTBL1F,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,FID,FKEYS") Q 
  N V1,V2,V3 S V1=vobj(fDBTBL1F,-3),V2=vobj(fDBTBL1F,-4),V3=vobj(fDBTBL1F,-5) I ($D(^DBTBL(V1,19,V2,V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(fDBTBL1F),$C(124),3)=""  S:'$D(vobj(fDBTBL1F,-100,"0*","DEL")) vobj(fDBTBL1F,-100,"0*","DEL")="N003"_$P(vobj(fDBTBL1F),$C(124),3)_"||||||||||[STBLFKOPT]REST",vobj(fDBTBL1F,-100,"0*")="" S $P(vobj(fDBTBL1F),$C(124),3)=0
 I $P(vobj(fDBTBL1F),$C(124),6)=""  S:'$D(vobj(fDBTBL1F,-100,"0*","RCFRMIN")) vobj(fDBTBL1F,-100,"0*","RCFRMIN")="N006"_$P(vobj(fDBTBL1F),$C(124),6),vobj(fDBTBL1F,-100,"0*")="" S $P(vobj(fDBTBL1F),$C(124),6)=0
 I $P(vobj(fDBTBL1F),$C(124),2)=""  S:'$D(vobj(fDBTBL1F,-100,"0*","RCTOMAX")) vobj(fDBTBL1F,-100,"0*","RCTOMAX")="N002"_$P(vobj(fDBTBL1F),$C(124),2),vobj(fDBTBL1F,-100,"0*")="" S $P(vobj(fDBTBL1F),$C(124),2)=1
 I $P(vobj(fDBTBL1F),$C(124),1)=""  S:'$D(vobj(fDBTBL1F,-100,"0*","RCTOMIN")) vobj(fDBTBL1F,-100,"0*","RCTOMIN")="N001"_$P(vobj(fDBTBL1F),$C(124),1),vobj(fDBTBL1F,-100,"0*")="" S $P(vobj(fDBTBL1F),$C(124),1)=1
 I $P(vobj(fDBTBL1F),$C(124),4)=""  S:'$D(vobj(fDBTBL1F,-100,"0*","UPD")) vobj(fDBTBL1F,-100,"0*","UPD")="N004"_$P(vobj(fDBTBL1F),$C(124),4)_"||||||||||[STBLFKOPT]REST",vobj(fDBTBL1F,-100,"0*")="" S $P(vobj(fDBTBL1F),$C(124),4)=0
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fDBTBL1F,fDBTBL1) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fDBTBL1F,fDBTBL1) ; Display screen prompts
 S VO="24||13|0"
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
VDA1(fDBTBL1F,fDBTBL1) ; Display screen data
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
 S VO="41|25|13|0"
 S VO(25)=$C(3,21,12,2,0,0,0,0,0,0)_"01T"_$E(vobj(fDBTBL1,-4),1,12)
 S VO(26)=$C(3,35,40,2,0,0,0,0,0,0)_"01T"_$E($P(vobj(fDBTBL1),$C(124),1),1,40)
 S VO(27)=$C(4,20,60,2,0,0,0,0,0,0)_"00U"_$get(FKEYS)
 S VO(28)=$C(6,21,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
 S VO(29)=$C(8,21,12,2,0,0,0,0,0,0)_"00U"_$E($P(vobj(fDBTBL1F),$C(124),5),1,12)
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
VTAB(fDBTBL1F,fDBTBL1) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=17 S VPT=1 S VPB=17 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL1F,DBTBL1" S VSCRPP=1 S VSCRPP=1
 S OLNTB=17069
 ;
 S VFSN("DBTBL1")="zfDBTBL1" S VFSN("DBTBL1F")="zfDBTBL1F"
 ;
 ;
 S %TAB(1)=$C(2,20,12)_"20U12402|1|[DBTBL1]FID|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||25"
 S %TAB(2)=$C(2,34,40)_"20T12401|1|[DBTBL1]DES"
 S %TAB(3)=$C(3,19,60)_"01U|*FKEYS|[*]@OOE8|[DBTBL1F]:NOVAL||do VP1^V00S061(.fDBTBL1F,.fDBTBL1)|do VP2^V00S061(.fDBTBL1F,.fDBTBL1)"
 S %TAB(4)=$C(5,20,1)_"00L|*DELETE|[*]@DELETE|||do VP3^V00S061(.fDBTBL1F,.fDBTBL1)"
 S %TAB(5)=$C(7,20,12)_"01U12405|1|[DBTBL1F]TBLREF|[DBTBL1]|if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|do VP4^V00S061(.fDBTBL1F,.fDBTBL1)||||||25"
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
 S %TAB(16)=$C(16,21,1)_"01N12404|1|[DBTBL1F]UPD|[STBLFKOPT]||do VP5^V00S061(.fDBTBL1F,.fDBTBL1)"
 S %TAB(17)=$C(16,68,1)_"01N12403|1|[DBTBL1F]DEL|[STBLFKOPT]||do VP6^V00S061(.fDBTBL1F,.fDBTBL1)"
 D VTBL(.fDBTBL1F,.fDBTBL1)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fDBTBL1F,fDBTBL1) ; Create %TAB(array)
 ; 1 2 3  4 5   6   7-9 10-11
 ; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VSPP ; screen post proc
 D VSPP1(.fDBTBL1F,.fDBTBL1)
 ;  #ACCEPT Date=11/05/03; pgm=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
VSPP1(fDBTBL1F,fDBTBL1) ; 
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
VP1(fDBTBL1F,fDBTBL1) ; 
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
 N recload S recload=$$vRCgetRecord1^RecordDBTBL1F("SYSDEV",FID,X,0)
  K vobj(+$G(fDBTBL1F)) S fDBTBL1F=$$vReCp1(recload)
 ;
 I ($G(vobj(fDBTBL1F,-2))=0) D
 .	;
 .	S OPTION=0
 .	S (PKEYS,DESR1,DESR2)=""
 .	;
 .  S $P(vobj(fDBTBL1F),$C(124),2)=1
 .  S $P(vobj(fDBTBL1F),$C(124),1)=1
 .  S $P(vobj(fDBTBL1F),$C(124),3)=0
 .  S $P(vobj(fDBTBL1F),$C(124),6)=0
 .  S $P(vobj(fDBTBL1F),$C(124),4)=0
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
VP2(fDBTBL1F,fDBTBL1) ; 
 ;
 D CHANGE^DBSMACRO("TBL","[DBTBL1F]:QU ""[DBTBL1F]FID=<<FID>>""")
 ;
 Q 
VP3(fDBTBL1F,fDBTBL1) ; 
 ;
 I X D GOTO^DBSMACRO("END")
 ;
 Q 
VP4(fDBTBL1F,fDBTBL1) ; 
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
VP5(fDBTBL1F,fDBTBL1) ; 
 ;
 Q:(X="") 
 ;
 D CONSTR
 ;
 Q 
 ;
CONSTR ; Verify Constraint Parameters
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
 .	I ($P(colrec,"|",29)!($P(colrec,"|",3)["*")) D
 ..		;
 ..		S ER=1
 ..		; Required fields cannot be null - ~p1
 ..		S RM=$$^MSG(2388,key)
 ..		Q 
 .	Q 
 ;
 Q 
VP6(fDBTBL1F,fDBTBL1) ; 
 ;
 I '(X="") D CONSTR
 ;
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fDBTBL1F,.fDBTBL1)
 D VDA1(.fDBTBL1F,.fDBTBL1)
 D ^DBSPNT()
 Q 
 ;
VW(fDBTBL1F,fDBTBL1) ; 
 D VDA1(.fDBTBL1F,.fDBTBL1)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fDBTBL1F,fDBTBL1) ; 
 D VDA1(.fDBTBL1F,.fDBTBL1)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fDBTBL1F,.fDBTBL1)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="DBTBL1F" D vSET1(.fDBTBL1F,di,X)
 I sn="DBTBL1" D vSET2(.fDBTBL1,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fDBTBL1F,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL1F,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET2(fDBTBL1,di,X) ; 
  D propSet^DBSDYNRA(fDBTBL1,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="DBTBL1F" Q $$vREAD1(.fDBTBL1F,di)
 I fid="DBTBL1" Q $$vREAD2(.fDBTBL1,di)
 Q ""
vREAD1(fDBTBL1F,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL1F,di)
vREAD2(fDBTBL1,di) ; 
 Q $$propGet^DBSDYNRA(fDBTBL1,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VSCRPRE(fDBTBL1F,fDBTBL1) ; Screen Pre-Processor
 N %TAB,vtab ; Disable .MACRO. references to %TAB()
 ;
 K DES,DESR1,DESR2,PKEYS
 ;  #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL1F WHERE %LIBS='SYSDEV' AND FID=:FID AND FKEYS=:X
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1F("SYSDEV",FID,X,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1F(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ;
vReCp1(v1) ; RecordDBTBL1F.copy: DBTBL1F
 ;
 Q $$copy^UCGMR(recload)
