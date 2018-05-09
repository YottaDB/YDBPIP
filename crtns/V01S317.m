V01S317	;; -  - 5.3 - SID= <DBTBL4> Query Definition
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,QRY,%A",VSID="DBTBL4",VPGM=$T(+0),VSNAME="Query Definition"
	S VFSN("DBTBL4")="%A"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=16 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
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
	I ($G(LIBS)="")!($G(QID)="") Q
	I $D(^DBTBL(LIBS,4,QID)) Q  ; Already created
	S %A=$G(%A)
	S %A(0)=$G(%A(0))
	I $P(%A(0),"|",3)="" S $P(%A(0),"|",3)=+$H   ; DBTBL4.DATE
	I $P(%A(0),"|",15)="" S $P(%A(0),"|",15)=$$USERNAM^%ZFUNC   ; DBTBL4.UID
	I $P(%A(0),"|",4)="" S $P(%A(0),"|",4)="V2.0"   ; DBTBL4.VERSION
	Q
	Q
VNEWDQ	; Original VNEW section
	;
	S %A(0)=$G(%A(0)),%A=$G(%A)
	Q
VLOD	; User defined access section
	;
	I '$D(%REPEAT) S %REPEAT=16
	I '$D(%MODS) S %MODS=1
	S %REPEAT=16 I %O=0 S %A("QID")="" F I=1:1:%REPEAT S fDBTBL4D(I)=""
	S %A=$G(^DBTBL(%LIBS,4,QID)),%A(0)=$G(^(QID,0))
	F I=1:1:%REPEAT S QRY(I)=$G(^DBTBL(%LIBS,4,QID,I))
	Q
VLODDQ	; Original VLOD section
	;
	S %A(0)=^DBTBL(LIBS,4,QID,0)
	S %A=^DBTBL(LIBS,4,QID)
	Q
VPR	; Display screen prompts
	;
	S VO="15||13|"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,8,9,0,0,0,0,0,0,0)_"01TQuery ID:"
	S VO(4)=$C(3,28,5,0,0,0,0,0,0,0)_"01TUser:"
	S VO(5)=$C(3,53,14,0,0,0,0,0,0,0)_"01T Last Updated:"
	S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,4,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(9)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(5,3,14,1,0,0,0,0,0,0)_"01T Data File(s):"
	S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,20,19,1,0,0,0,0,0,0)_"01T Query Definitions "
	S VO(15)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	I '$D(%MODS) S %MODS=1
	S DY=7 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
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
	I %O=5 N %A,v1,QID
	I  S (%A,v1,QID)=""
	E  N v1
	E  S %A=$G(%A),v1=$G(%A(0)),QID=$G(QID)
	;
	S QRY=$G(QRY)
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($G(%FN)))
	S VO(VX+1)=$C(3,18,8,2,0,0,0,0,0,0)_"01T"_QID
	S VO(VX+2)=$C(3,34,16,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",15)
	S VO(VX+3)=$C(3,68,10,2,0,0,0,0,0,0)_"01D"_$$DAT^%ZM($P(v1,"|",3))
	S VO(VX+4)=$C(4,18,40,2,0,0,0,0,0,0)_"00T"_$P(%A,"|",1)
	S VO(VX+5)=$C(5,18,60,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",1)
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+5,DY=7 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v2
	I  S (v2)=""
	E  N v2
	E  S (v2,QRY(I))=$G(QRY(I))
	;
	S VO(VX+1)=$C(DY,3,75,2,0,0,0,0,0,0)_"00T"_v2
	S DY=DY+1,VX=VX+1
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=5,%MOD=1,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=6+%REPEAT,BLKSIZ=75*%REPEAT+134,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL4",VSCRPP=1
	S OLNTB=VPB*1000
	;
	S VFSN("DBTBL4")="%A"
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
	S %TAB(1)=$C(2,17,8)_"21T12402|3*|[DBTBL4]QID|||||||||12"
	S %TAB(2)=$C(2,33,16)_"21T12415|0|[DBTBL4]UID"
	S %TAB(3)=$C(2,67,10)_"21D12403|0|[DBTBL4]DATE"
	S %TAB(4)=$C(3,17,40)_"01T12401||[DBTBL4]DESC"
	S %TAB(5)=$C(4,17,60)_"01T12401|0|[DBTBL4]PFID|[DBTBL1]||D VP1^V01S317"
	S %TAB(6)=$C(6,2,75)_"00T|*QRY(1)|[*]@QRY|||D VP2^V01S317"
	;
	Q
	;
	;
VSPP	; Screen Post-Processor
	;
	;
	; Check query syntax 12/05/95 BC
	;
	N (%LIBS,%A,ER,RM)
	S FILES=$P(%A(0),"|",1),ER=0
	F NI=1:1 Q:'$D(QRY(NI))  S X=QRY(NI) D ^DBSQRY I ER Q
	;
	;
	Q
	Q
	Q
	;
VPOS	; User defined post processor's
	;
VP1	;
	S I(3)=""
	D VPO1
	I ER Q
	Q
VPO1	; user library DBSFILES
	;
	N IX,IY,IZ,SAVX
REG	;
	I X="" Q
	I X["," S I(3)=""
	S FILES=X D ^DBSFVER I ER Q
	S (PFID,FID)=$P(FILES,",",1)
	;
	S DLIB=%LIBS,DFID=$P(FILES,",",1),LIB=DLIB,FID=DFID
	;
	S SEQBY="",IX=^DBTBL(LIB,1,FID,16)
	F IZ=1:1:$L(IX,",") S SEQBY=SEQBY_"["_%LIBS_","_FID_"]"_$P(IX,",",IZ)_"|"
	S SEQBY=$E(SEQBY,1,$L(SEQBY)-1)
	Q
	;
	Q
VP2	;
	I X="" Q
	;
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
