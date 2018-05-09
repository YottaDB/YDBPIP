V00S051	;; -  - 5.3 - SID= <DBSRDS> Required Data Item Set Screen
	;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,MPG,KEYNAME,DITEMLST",VSID="DBSRDS",VPGM=$T(+0),VSNAME="Required Data Item Set Screen"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1,%REPEAT=17 D VPR,VDA,V5^DBSPNT Q
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
	I '$D(%REPEAT) S %REPEAT=17
	I '$D(%MODS) S %MODS=1
	Q
VPR	; Display screen prompts
	;
	S VO="7||13|"
	S VO(0)="1|0"
	S VO(1)=$C(1,27,19,0,0,0,0,0,0,0)_"01TRequired Data Items"
	S VO(2)=$C(2,58,12,0,0,0,0,0,0,0)_"01TMore Pages? "
	S VO(3)=$C(3,8,7,0,0,0,0,0,0,0)_"01TKeyword"
	S VO(4)=$C(3,37,13,0,0,0,0,0,0,0)_"01TData Item Set"
	S VO(5)=$C(4,4,15,0,0,0,0,0,0,0)_"01T---------------"
	S VO(6)=$C(4,29,8,0,0,0,0,0,0,0)_"01T--------"
	S VO(7)=$C(4,37,42,0,0,0,0,0,0,0)_"01T------------------------------------------"
	Q
VDA	; Display screen data
	N V
	S DITEMLST=$G(DITEMLST)
	S KEYNAME=$G(KEYNAME)
	S MPG=$G(MPG)
	;
	S VO="8|8|13|"
	S VO(8)=$C(2,70,1,2,0,0,0,0,0,0)_"00L"_$S($G(MPG):"Y",1:"N")
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+0,DY=6 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v2,v1
	I  S (v2,v1)=""
	E  N v2,v1
	E  S (v2,DITEMLST(I))=$G(DITEMLST(I)),(v1,KEYNAME(I))=$G(KEYNAME(I))
	;
	S VO(VX+1)=$C(DY,5,12,2,0,0,0,0,0,0)_"00T"_v1
	S VO(VX+2)=$C(DY,29,52,2,0,0,0,0,0,0)_"00T"_v2
	S DY=DY+1,VX=VX+2
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %REPREQ=31 S %MODGRP=1
	S %MODOFF=1,%MOD=2,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=5+%REPEAT,BLKSIZ=123*%REPEAT+1,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL7"
	S OLNTB=VPB*1000
	;
	F I=4:1:%MAX S %TAB(I)=""
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
	S %TAB(1)=$C(1,69,1)_"00L|*MPG|[*]@MPG|||D VP1^V00S051"
	S %TAB(2)=$C(5,4,12)_"00T|*KEYNAME(1)|[*]@KEYNAME"
	S %TAB(3)=$C(5,28,52)_"00T|*DITEMLST(1)|[*]@DITEMLST|@SELDI^DBSFUN(FID,.X):LIST:NOVAL||D VP2^V00S051||||||111"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	I X=V Q
	I X,%PG=%PAGE S %PAGE=%PAGE+1
	I 'X S %PAGE=%PAGE-1
	Q
VP2	;
	;
	;  Parse and verify each data Item entered.
	;
	S DITEM=""
	S ER=0
	F I=1:1  S DITEM=$P(X,",",I) Q:DITEM=""  D  Q:ER
	. S DITEM=FID_"."_DITEM
	. I $$VER^DBSDD(DITEM)=0 D
	..     S ER=1
	..     S RM1=DITEM  ; Return message
	..     S RM=$$^MSG(1298,RM1)
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
