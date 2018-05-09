V00S050	;; -  - 5.3 - SID= <DBSQCONV> Training-convert query to SQL
	;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,FILE,QRY",VSID="DBSQCONV",VPGM=$T(+0),VSNAME="Training-convert query to SQL"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=18 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
	;
	S ER=0 D VSCRPRE I ER Q  ; Screen Pre-Processor
	;
	I '%O D VNEW,VPR,VDA
	I %O D VLOD Q:$G(ER)  D VPR,VDA
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
	;
VDEF	;
	;
	I ($G(%LIBS)="")!($G(FID)="") Q
	I $D(^DBTBL(%LIBS,1,FID)) Q  ; Already created
	S fDBTBL1=$G(fDBTBL1)
	S fDBTBL1(10)=$G(fDBTBL1(10)),fDBTBL1(100)=$G(fDBTBL1(100))
	I $P(fDBTBL1(10),"|",1)="" S $P(fDBTBL1(10),"|",1)=124   ; DBTBL1.DEL
	I $P(fDBTBL1(10),"|",3)="" S $P(fDBTBL1(10),"|",3)=0   ; DBTBL1.NETLOC
	I $P(fDBTBL1(100),"|",2)="" S $P(fDBTBL1(100),"|",2)=1   ; DBTBL1.RECTYP
	I $P(fDBTBL1(10),"|",2)="" S $P(fDBTBL1(10),"|",2)="PBS"   ; DBTBL1.SYSSN
	Q
	;
VLOD	; Load data from disc - %O = (1-5)
	I '$D(%REPEAT) S %REPEAT=18
	I '$D(%MODS) S %MODS=1
	Q
VPR	; Display screen prompts
	;
	S VO="9||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(2,22,33,0,0,0,0,0,0,0)_"01TDATA-QWIK to SQL query conversion"
	S VO(4)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(3,3,11,1,0,0,0,0,0,0)_"01T File Name:"
	S VO(7)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	I '$D(%MODS) S %MODS=1
	S DY=5 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
	S VO=+VO_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO=VO+2,DY=DY+1
	Q
VDA	; Display screen data
	N V
	S FILE=$G(FILE)
	S QRY=$G(QRY)
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(3,16,60,2,0,0,0,0,0,0)_"00T"_$G(FILE)
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+0,DY=5 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v1
	I  S (v1)=""
	E  N v1
	E  S (v1,QRY(I))=$G(QRY(I))
	;
	S VO(VX+1)=$C(DY,3,76,2,0,0,0,0,0,0)_"00T"_v1
	S DY=DY+1,VX=VX+1
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %REPREQ=2 S %MODGRP=1
	S %MODOFF=1,%MOD=1,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=4+%REPEAT,BLKSIZ=76*%REPEAT+60,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL1",VSCRPP=1
	S OLNTB=VPB*1000
	;
	F I=3:1:%MAX S %TAB(I)=""
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
	S %TAB(1)=$C(2,15,60)_"01T|*FILE|[*]@FILE|[DBTBL1]||D VP1^V00S050"
	S %TAB(2)=$C(4,2,76)_"00T|*QRY(1)|[*]@QRY|||D VP2^V00S050"
	;
	Q
	;
	;
VSPP	; Screen Post-Processor
	;
	N WHERE,i,TMP1,QUIT,XVAL
	S WHERE=$$WHERE^SQLCONV(.QRY,FILES)   ; SQL WHERE statement
	S ER=1,RM=""
	I WHERE="" Q
	S XVAL=15
	S QUIT=0
	F  D WRITEQRY  Q:QUIT=1
	Q
WRITEQRY	
	I $L(WHERE)<81 W $$CUP^%TRMVT(1,XVAL),WHERE S QUIT=1 Q
	S TMP1=$E(WHERE,1,80)  F i=80:-1:1 Q:$E(TMP1,i)=" "
	W $$CUP^%TRMVT(1,XVAL)
	I i=1 W WHERE S QUIT=1 Q
	W $E(TMP1,1,i)
	S WHERE=$E(WHERE,i+1,$l(WHERE))
	S XVAL=XVAL+1
	Q
	Q
	Q
	;
VPOS	; User defined post processor's
	;
VP1	;
	S FILES=X
	Q
VP2	;
	; DATA-QWIK query syntax
	;
	I X="" Q
	;
	;
	S ZX=X N X
	S X=ZX
	D ^DBSQRY
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
	S %O=0,%REPEAT=10,FID="",%FRAME=2
	N I
	F I=1:1:%REPEAT S QRY(I)=""
	Q
