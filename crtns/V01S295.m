V01S295	;; -  - 5.3 - SID= <DBSFMT> DQ Format Type Definition
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:48 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,DESC,ZTYPE",VSID="DBSFMT",VPGM=$T(+0),VSNAME="DQ Format Type Definition"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=15 D VPR,VDA,V5^DBSPNT Q
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
	Q
	Q
VNEWDQ	; Original VNEW section
	;
	Q
VLOD	; User defined access section
	;
	I '$D(%REPEAT) S %REPEAT=15
	I '$D(%MODS) S %MODS=1
	Q
	Q
VLODDQ	; Original VLOD section
	;
	Q
VPR	; Display screen prompts
	;
	S VO="16||13|"
	S VO(0)="|1"
	S VO(1)=$C(3,38,12,1,0,0,0,0,0,0)_"01TDescription:"
	S VO(2)=$C(5,2,124,0,0,0,0,0,0,0)_"11Tlqqqqqwqqqqqqqqqqqqqqwqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqwqqqqqqqqqqqqwqqqqqqqqqqqqqqqqqwqqqqqqqqqqqqqqqqqk"
	S VO(3)=$C(6,2,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(4)=$C(6,3,4,0,0,0,0,0,0,0)_"01TType"
	S VO(5)=$C(6,8,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(6,10,11,0,0,0,0,0,0,0)_"01TDescription"
	S VO(7)=$C(6,23,1,0,52,52,0,0,0,0)_"11Tx"
	S VO(8)=$C(6,25,27,0,0,0,0,0,0,0)_"01TExternal Display Expression"
	S VO(9)=$C(6,76,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(6,79,4,0,0,0,0,0,0,0)_"01TMask"
	S VO(11)=$C(6,89,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,92,12,0,0,0,0,0,0,0)_"01TJustify(Rpt)"
	S VO(13)=$C(6,107,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,109,15,0,0,0,0,0,0,0)_"01TSize (Display) "
	S VO(15)=$C(6,125,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(7,2,124,0,0,0,0,0,0,0)_"11Ttqqqqqnqqqqqqqqqqqqqqnqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqnqqqqqqqqqqqqnqqqqqqqqqqqqqqqqqnqqqqqqqqqqqqqqqqqu"
	I '$D(%MODS) S %MODS=1
	S DY=8 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
	S VO=+VO_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,2,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,8,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+3)=$C(DY,23,1,0,52,52,0,0,0,0)_"11Tx"
	S VO(VO+4)=$C(DY,76,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+5)=$C(DY,89,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+6)=$C(DY,107,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+7)=$C(DY,125,1,0,0,0,0,0,0,0)_"11Tx"
	S VO=VO+7,DY=DY+1
	Q
VDA	; Display screen data
	N V
	S DESC=$G(DESC)
	S ZTYPE=$G(ZTYPE)
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(1,1,0,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID("",ZHDR))
	S VO(VX+1)=$C(3,53,20,2,0,0,0,0,0,0)_"00T"_$G(DESC)
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+1,DY=8 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v1
	I  S (v1)=""
	E  N v1
	E  S (v1,ZTYPE(I))=$G(ZTYPE(I))
	;
	S VO(VX+1)=$C(DY,4,1,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",15)
	S VO(VX+2)=$C(DY,10,12,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",1)
	S VO(VX+3)=$C(DY,25,50,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",2)
	S VO(VX+4)=$C(DY,78,10,2,0,0,0,0,0,0)_"00U"_$P(v1,"|",6)
	S VO(VX+5)=$C(DY,96,3,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",4)
	S VO(VX+6)=$C(DY,114,3,2,0,0,0,0,0,0)_"00N"_$P(v1,"|",9)
	S DY=DY+1,VX=VX+6
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=1,%MOD=6,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=7+%REPEAT,BLKSIZ=79*%REPEAT+20,PGM=$T(+0),DLIB="SYSDEV",DFID="DBCTLDVFM"
	S OLNTB=VPB*1000
	;
	F I=8:1:%MAX S %TAB(I)=""
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
	S %TAB(1)=$C(2,52,20)_"00T|*DESC|[*]@DESC"
	S %TAB(2)=$C(7,3,1)_"20T12415|*ZTYPE(1)|[*]@TYPE"
	S %TAB(3)=$C(7,9,12)_"01T12401|*ZTYPE(1)|[*]@DESC"
	S %TAB(4)=$C(7,24,50)_"00T12402|*ZTYPE(1)|[*]@DISP"
	S %TAB(5)=$C(7,77,10)_"00U12406|*ZTYPE(1)|[*]@MASK"
	S %TAB(6)=$C(7,95,3)_"20T12404|*ZTYPE(1)|[*]@ZTYPE"
	S %TAB(7)=$C(7,113,3)_"00N12409|*ZTYPE(1)|[*]@ZTYPE||||D VP1^V01S295"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	I $G(OPTION)="Screen" D
	. D CHANGE^DBSMACRO("REQ","")
	. D CHANGE^DBSMACRO("MIN",1)
	. D CHANGE^DBSMACRO("MAX",999)
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
