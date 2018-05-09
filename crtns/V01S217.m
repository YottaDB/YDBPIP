V01S217	;; -  - 5.3 - SID= <DBTBL9D> Journal File Mapping Definition
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:41 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,Pri2sub,fDBTBL9,fDBTBL9D",VSID="DBTBL9D",VPGM=$T(+0),VSNAME="Journal File Mapping Definition"
	S VFSN("DBTBL9")="fDBTBL9",VFSN("DBTBL9D")="fDBTBL9D"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=16 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
	;
	S ER=0 D VSCRPRE I ER Q  ; Screen Pre-Processor
	;
	; Display Pre-Processor
	;
	I '%O D VNEW,VDSPPRE Q:$G(ER)  D VPR,VDA
	I %O D VLOD Q:$G(ER)  D VDSPPRE Q:$G(ER)  D VPR,VDA
	;
	; ====================  Display Form
	;
	D ^DBSPNT()
	;
	I %O=2!(%O=3) D ^DBSCRT8A X:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	;
	; ====================  Set up data entry control table
	;
vTBL	I %O<2 D VTAB
	Q
	;
VNEW	; Initialize arrays if %O=0
	;
	D VLOD
	;
	S fDBTBL9=$G(fDBTBL9)
	;
VDEF	;
	Q
	;
VLOD	; Load data from disc - %O = (1-5)
	I '$D(%REPEAT) S %REPEAT=16
	I '$D(%MODS) S %MODS=1
	S fDBTBL9=^DBTBL(%LIBS,9,PRITABLE,JRNID)
	Q
VPR	; Display screen prompts
	;
	S VO="18||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,1,77,0,52,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,10,13,0,0,0,0,0,0,0)_"01TJournal Name:"
	S VO(4)=$C(2,77,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(3,1,77,0,52,0,0,0,0,0)_"11Ttqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqwqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqu"
	S VO(6)=$C(4,1,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,4,14,0,0,0,0,0,0,0)_"01TJournal Table:"
	S VO(8)=$C(4,43,1,0,52,52,0,0,0,0)_"11Tx"
	S VO(9)=$C(4,44,15,0,0,0,0,0,0,0)_"01T Primary Table:"
	S VO(10)=$C(4,73,2,0,52,52,0,0,0,0)_"01Tto"
	S VO(11)=$C(4,77,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(5,1,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(5,3,11,2,0,0,0,0,0,0)_"01TColumn Name"
	S VO(14)=$C(5,17,11,2,0,0,0,0,0,0)_"01TDescription"
	S VO(15)=$C(5,43,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(5,45,32,2,0,0,0,0,0,0)_"01TJournal Table Mapping Definition"
	S VO(17)=$C(5,77,1,0,52,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(6,1,77,0,52,0,0,0,0,0)_"11Ttqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqnqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqu"
	I '$D(%MODS) S %MODS=1
	S DY=7 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
	S VO=+VO_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,43,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+3)=$C(DY,77,1,0,52,0,0,0,0,0)_"11Tx"
	S VO=VO+3,DY=DY+1
	Q
VDA	; Display screen data
	N V
	I %O=5 N JRNID,PRITABLE,fDBTBL9
	I  S (JRNID,PRITABLE,fDBTBL9)=""
	E  S JRNID=$G(JRNID),PRITABLE=$G(PRITABLE),fDBTBL9=$G(fDBTBL9)
	;
	S Coldes=$G(Coldes)
	S Colnam=$G(Colnam)
	S Pri2sub=$G(Pri2sub)
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(2,24,20,2,0,0,0,0,0,0)_"01T"_JRNID
	S VO(VX+1)=$C(4,19,12,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL9,"|",2)
	S VO(VX+2)=$C(4,60,12,2,0,0,0,0,0,0)_"01T"_PRITABLE
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+2,DY=7 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v2,v1,v3
	I  S (v2,v1,v3)=""
	E  N v2,v1,v3
	E  S (v2,Coldes(I))=$G(Coldes(I)),(v1,Colnam(I))=$G(Colnam(I)),(v3,Pri2sub(I))=$G(Pri2sub(I))
	;
	S VO(VX+1)=$C(DY,3,12,2,0,0,0,0,0,0)_"01T"_v1
	S VO(VX+2)=$C(DY,17,25,2,0,0,0,0,0,0)_"01T"_v2
	S VO(VX+3)=$C(DY,45,31,2,0,0,0,0,0,0)_"00T"_v3
	S DY=DY+1,VX=VX+3
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=3,%MOD=3,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=6+%REPEAT,BLKSIZ=68*%REPEAT+44,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL9D"
	S OLNTB=VPB*1000
	;
	S VFSN("DBTBL9")="fDBTBL9",VFSN("DBTBL9D")="fDBTBL9D"
	;
	F I=7:1:%MAX S %TAB(I)=""
	;
	;
	; ===============  Set up entry/error checking control table
	;
VTAB1	D VTBL
	;
	D ^DBSCRT8 Q  ; data entry
	;
	Q
VREQ	; Create REQ() array
	;
	;
	Q
	;
VTBL	; Create %TAB(array)
	;
	; 1 2 3  4 5   6   7-9 10-11
	;
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	S %TAB(1)=$C(1,23,20)_"20T12403|4*|[DBTBL9D]JRNID"
	S %TAB(2)=$C(3,18,12)_"20U12402||[DBTBL9]SUBTABLE|[DBTBL1]FID,DES:QU ""[DBTBL1]FILETYP=6"""
	S %TAB(3)=$C(3,59,12)_"20U12402|3*|[DBTBL9D]PRITABLE|||||||||25"
	S %TAB(4)=$C(6,2,12)_"20T|*Colnam(1)|[*]@COLNAM"
	S %TAB(5)=$C(6,16,25)_"20T|*Coldes(1)|[*]@Coldes"
	S %TAB(6)=$C(6,44,31)_"00T|*Pri2sub(1)|[*]@[DBTBL9D]MAP|[STBLJRNFUNC]DES:NOVAL||D VP1^V01S217|D VP2^V01S217|||||200"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	N table,zdi
	;
	D CHANGE^DBSMACRO("TBL","")
	I X="",$E(Coldes(z1))="*" D  Q              ; Access key
	. D CHANGE^DBSMACRO("REQ","")
	I X="" Q
	I $E(X,1,2)="$$" Q                          ; Function call
	I X?.N!(X?1N.N1"."1N.N) Q                   ; Numeric data
	I $E(X)="""",$E(X,$L(X))="""" Q             ; Text literal
	I X?1A.AN1".NEXTVAL" Q                      ; Calculate next value
	I $P(X,".",2)="CURRVAL" Q                   ; Current key value of another journal file
	I X?1A.AN1"."1A.AN!(X["_") D  Q             ; table.column syntax   ;6/12/2000 mas
	 . S table=PRITABLE              ; Journal table name
	 . S zdi=X
	 . I $P(X,".",1)="NEW"!($P(X,".",1)="OLD") S zdi=table_"."_$P(X,".",2)
	 . S RM=$$DES^DBSDD(zdi)
	 . I RM="" S ER=1,RM=$$^MSG(1300,X)
	;
	S zv="[STBLJRNFUNC]DES"               D CHANGE^DBSMACRO("TBL",zv)
	Q
VP2	;
	; Supertype file linkage
	;
	I $P(fDBTBL9,"|",13)'="" D PROTECT^DBSMACRO("ALL")
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
	;
VSCRPRE	; Screen Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	S %O=1
	S COLMAN=" "
	Q
	;
VDSPPRE	; Display Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	I $D(Colnam) Q                                    ; Already loaded
	N subtable,list,i,column,count
	K Colnam,Coldes,Pri2sub
	S subtable=$P(fDBTBL9,"|",2)                       ; Sub Table Name
	S list=$$LIST^DBSDD(subtable)                     ; Data item list
	S count=$L(list,",")                              ; Number of columns
	;
	F i=1:1:count D
	. S column=$P(list,",",i)                         ; Get column from list
	. S Colnam(i)=column                              ; Column name
	. S Coldes(i)=$$DES^DBSDD(subtable_"."_column)    ; Column description
	. I $$NOD^DBSDD(subtable_"."_column)["*" s Coldes(i)="*"_Coldes(i)
	. S Pri2sub(i)=$G(^DBTBL(%LIBS,9,PRITABLE,JRNID,column)) ; Mapping info
	;
	S %PAGE=count-1\16+1                              ; Calculate page number
	I count<17 S %REPEAT=count                        ; Repeat region
	Q
	Q
