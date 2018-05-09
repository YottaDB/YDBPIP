V00S049	;; -  - 5.3 - SID= <DBSFMTDAY> Days Of The Week/Months Of The Year Def
	;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,ZTYPE",VSID="DBSFMTDAY",VPGM=$T(+0),VSNAME="Days Of The Week/Months Of The Year Def"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=14 D VPR,VDA,V5^DBSPNT Q
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
	;
VLOD	; Load data from disc - %O = (1-5)
	I '$D(%REPEAT) S %REPEAT=14
	I '$D(%MODS) S %MODS=1
	Q
VPR	; Display screen prompts
	;
	S VO="13||13|"
	S VO(0)="|0"
	S VO(1)=$C(4,14,49,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"
	S VO(2)=$C(4,63,1,0,0,0,0,0,0,0)_"11Tk"
	S VO(3)=$C(5,14,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(4)=$C(5,63,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(6,14,28,0,0,0,0,0,0,0)_"11Ttqqqqqqqqqqqqqqqqqqqqqqqqqqq"
	S VO(6)=$C(6,42,19,0,0,0,0,0,0,0)_"11Twqqqqqqqqqqqqqqqqqq"
	S VO(7)=$C(6,61,3,0,0,0,0,0,0,0)_"11Tqqu"
	S VO(8)=$C(7,14,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(7,16,11,1,0,0,0,0,0,0)_"01T Full Name "
	S VO(10)=$C(7,42,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(7,44,18,1,0,0,0,0,0,0)_"01T Abbreviated Name "
	S VO(12)=$C(7,63,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(8,14,50,0,0,0,0,0,0,0)_"11Ttqqqqqqqqqqqqqqqqqqqqqqqqqqqnqqqqqqqqqqqqqqqqqqqqu"
	I '$D(%MODS) S %MODS=1
	S DY=9 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
	S VO=+VO_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,14,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,42,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+3)=$C(DY,63,1,0,0,0,0,0,0,0)_"11Tx"
	S VO=VO+3,DY=DY+1
	Q
VDA	; Display screen data
	N V
	S DAYMONTH=$G(DAYMONTH)
	S ZTYPE=$G(ZTYPE)
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(1,1,0,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID("",ZHDR))
	S VO(VX+1)=$C(5,27,20,1,0,0,0,0,0,0)_"01T"_$$VRV($G(DAYMONTH),20)
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+1,DY=9 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v1
	I  S (v1)=""
	E  N v1
	E  S (v1,ZTYPE(I))=$G(ZTYPE(I))
	;
	S VO(VX+1)=$C(DY,10,2,2,0,0,0,0,0,0)_"01N"_$P(v1,"|",1)
	S VO(VX+2)=$C(DY,16,25,0,0,0,0,0,0,0)_"00T"_$P(v1,"|",2)
	S VO(VX+3)=$C(DY,44,18,0,0,0,0,0,0,0)_"00T"_$P(v1,"|",3)
	S DY=DY+1,VX=VX+3
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=1,%MOD=3,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=8+%REPEAT,BLKSIZ=45*%REPEAT+20,PGM=$T(+0),DLIB="SYSDEV",DFID=""
	S OLNTB=VPB*1000
	;
	F I=5:1:%MAX S %TAB(I)=""
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
	S %TAB(1)=$C(4,26,20)_"20T|*DAYMONTH|[*]@DAYMONTH"
	S %TAB(2)=$C(8,9,2)_"20N12401|*ZTYPE(1)|[*]@DN"
	S %TAB(3)=$C(8,15,25)_"01T12402|*ZTYPE(1)|[*]@DL"
	S %TAB(4)=$C(8,43,18)_"01T12403|*ZTYPE(1)|[*]@DS"
	;
	Q
	;
	;
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
