V01S086	;; -  - 5.3 - SID= <DBTBL1R> Rename Data Items
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/13/2007 14:40 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,FID,SCANDD,A,B,C,D",VSID="DBTBL1R",VPGM=$T(+0),VSNAME="Rename Data Items"
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
	;
	I ($G(%LIBS)="")!($G(FID)="") Q
	I $D(^DBTBL(%LIBS,1,FID)) Q  ; Already created
	S fDBTBL1=$G(fDBTBL1)
	S fDBTBL1(10)=$G(fDBTBL1(10)),fDBTBL1(12)=$G(fDBTBL1(12)),fDBTBL1(100)=$G(fDBTBL1(100))
	I $P(fDBTBL1(10),"|",1)="" S $P(fDBTBL1(10),"|",1)=124   ; DBTBL1.DEL
	I $P(fDBTBL1(12),"|",1)="" S $P(fDBTBL1(12),"|",1)="f"_$E($TR(FID,"_","z"),1,7)   ; DBTBL1.FSN
	I $P(fDBTBL1(10),"|",3)="" S $P(fDBTBL1(10),"|",3)=0   ; DBTBL1.NETLOC
	I $P(fDBTBL1(100),"|",2)="" S $P(fDBTBL1(100),"|",2)=1   ; DBTBL1.RECTYP
	I $P(fDBTBL1(10),"|",2)="" S $P(fDBTBL1(10),"|",2)="PBS"   ; DBTBL1.SYSSN
	Q
	Q
VNEWDQ	; Original VNEW section
	;
	Q
VLOD	; User defined access section
	;
	I '$D(%REPEAT) S %REPEAT=17
	I '$D(%MODS) S %MODS=1
	;
	Q
VLODDQ	; Original VLOD section
	;
	Q
VPR	; Display screen prompts
	;
	S VO="4||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,1,80,1,0,0,0,0,0,0)_"01T                           Rename Data Items                                    "
	S VO(2)=$C(3,6,11,1,0,0,0,0,0,0)_"01T File Name:"
	S VO(3)=$C(3,44,22,1,0,0,0,0,0,0)_"01T Scan & Replace DBTBL:"
	S VO(4)=$C(5,1,80,2,0,0,0,0,0,0)_"01TOld Name         New Name               Old Name         New Name               "
	Q
VDA	; Display screen data
	N V
	S A=$G(A)
	S B=$G(B)
	S C=$G(C)
	S D=$G(D)
	S FID=$G(FID)
	S SCANDD=$G(SCANDD)
	;
	S VO="6|5|13|"
	S VO(5)=$C(3,18,12,2,0,0,0,0,0,0)_"00U"_$G(FID)
	S VO(6)=$C(3,67,1,2,0,0,0,0,0,0)_"00L"_$S($G(SCANDD):"Y",1:"N")
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+1,DY=6 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v1,v2,v3,v4
	I  S (v1,v2,v3,v4)=""
	E  N v1,v2,v3,v4
	E  S (v1,A(I))=$G(A(I)),(v2,B(I))=$G(B(I)),(v3,C(I))=$G(C(I)),(v4,D(I))=$G(D(I))
	;
	S VO(VX+1)=$C(DY,1,12,2,0,0,0,0,0,0)_"00U"_v1
	S VO(VX+2)=$C(DY,18,12,2,0,0,0,0,0,0)_"00U"_v2
	S VO(VX+3)=$C(DY,41,12,2,0,0,0,0,0,0)_"00U"_v3
	S VO(VX+4)=$C(DY,58,12,2,0,0,0,0,0,0)_"00U"_v4
	S DY=DY+1,VX=VX+4
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=2,%MOD=4,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=5+%REPEAT,BLKSIZ=48*%REPEAT+13,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL1"
	S OLNTB=VPB*1000
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
	S %TAB(1)=$C(2,17,12)_"01U|*FID|[*]@FID|[DBTBL1]"
	S %TAB(2)=$C(2,66,1)_"00L|*SCANDD|[*]@SCANDD"
	S %TAB(3)=$C(5,0,12)_"00U|*A(1)|[*]@OOE7|@SELDI^DBSFUN(FID,.X)||D VP1^V01S086"
	S %TAB(4)=$C(5,17,12)_"00U|*B(1)|[*]@ooe8|||D VP2^V01S086"
	S %TAB(5)=$C(5,40,12)_"00U|*C(1)|[*]@OOE9|@SELDI^DBSFUN(FID,.X)||D VP3^V01S086"
	S %TAB(6)=$C(5,57,12)_"00U|*D(1)|[*]@ooe10|||D VP4^V01S086"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	D CHANGE^DBSMACRO("TBL","[DBTBL1D]")
	Q
VP2	;
	I X="" Q
	I $D(^DBTBL(%LIBS,1,FID,9,X)) S ER=1,RM=$$^MSG(253)
	Q
VP3	;
	D CHANGE^DBSMACRO("TBL","[DBTBL1D]")
	Q
VP4	;
	I X="" Q
	I $D(^DBTBL(%LIBS,1,FID,9,X)) S ER=1,RM=$$^MSG(253)
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
