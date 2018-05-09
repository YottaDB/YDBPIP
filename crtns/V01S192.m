V01S192	;; -  - 5.3 - SID= <DBTBL17> Import/Export DATA-QWIK Definitions
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:41 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,COMMENT,EXPDESC,DDTYPE,fDBTBL17",VSID="DBTBL17",VPGM=$T(+0),VSNAME="Import/Export DATA-QWIK Definitions"
	S VFSN("DBTBL17")="fDBTBL17"
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
	D VLOD^DBSDDEXP
	Q
VLODDQ	; Original VLOD section
	;
	Q
VPR	; Display screen prompts
	;
	S VO="14||13|"
	S VO(0)="|0"
	S VO(1)=$C(3,2,13,0,0,0,0,0,0,0)_"01T Export Name:"
	S VO(2)=$C(3,30,5,0,0,0,0,0,0,0)_"01TDate:"
	S VO(3)=$C(3,48,5,0,0,0,0,0,0,0)_"01TUser:"
	S VO(4)=$C(3,68,9,0,0,0,0,0,0,0)_"01TComments:"
	S VO(5)=$C(4,2,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(6)=$C(5,1,79,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqwqqqqqqwqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(7)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(6,3,4,0,0,0,0,0,0,0)_"01TType"
	S VO(9)=$C(6,13,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(6,14,6,0,0,0,0,0,0,0)_"01TDelete"
	S VO(11)=$C(6,20,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,23,44,0,0,0,0,0,0,0)_"01TName(s)     Example:  name,name1-name2,name*"
	S VO(13)=$C(6,79,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(7,1,79,0,0,0,0,0,0,0)_"11Ttqqqqqqqqqqqnqqqqqqnqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqu"
	I '$D(%MODS) S %MODS=1
	S DY=8 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR
	S VO=+VO_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,13,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+3)=$C(DY,20,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+4)=$C(DY,79,1,0,0,0,0,0,0,0)_"11Tx"
	S VO=VO+4,DY=DY+1
	Q
VDA	; Display screen data
	N V
	I %O=5 N EXPID
	I  S (EXPID)=""
	E  S EXPID=$G(EXPID)
	;
	S COMMENT=$G(COMMENT)
	S DDTYPE=$G(DDTYPE)
	S EXPDESC=$G(EXPDESC)
	S ZLTD=$G(ZLTD)
	S ZUID=$G(ZUID)
	;
	S VX=$P(VO,"|",2)
	S VO(VX+0)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($G(%FN)))
	S VO(VX+1)=$C(3,16,12,2,0,0,0,0,0,0)_"01T"_EXPID
	S VO(VX+2)=$C(3,36,10,2,0,0,0,0,0,0)_"01D"_$$DAT^%ZM($G(ZLTD))
	S VO(VX+3)=$C(3,54,12,2,0,0,0,0,0,0)_"01T"_$G(ZUID)
	S VO(VX+4)=$C(3,78,1,2,0,0,0,0,0,0)_"00L"_$S($G(COMMENT):"Y",1:"N")
	S VO(VX+5)=$C(4,16,65,2,0,0,0,0,0,0)_"00T"_$G(EXPDESC)
	; 
	S:'$D(%MODS) %MODS=1 S VX=$P(VO,"|",2)+5,DY=8 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA
	S $P(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA	; Display data %REPEAT times
	;
	I %O=5 N v1
	I  S (v1)=""
	E  N v1
	E  S (v1,DDTYPE(I))=$G(DDTYPE(I))
	;
	S VO(VX+1)=$C(DY,3,8,2,0,0,0,0,0,0)_"00U"_$P(v1,"|",1)
	S VO(VX+2)=$C(DY,16,1,2,0,0,0,0,0,0)_"00L"_$S($P(v1,"|",3):"Y",1:"N")
	S VO(VX+3)=$C(DY,23,55,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",2)
	S DY=DY+1,VX=VX+3
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=5,%MOD=3,%MAX=%MOD*%REPEAT+%MODOFF,VPT=1,VPB=7+%REPEAT,BLKSIZ=64*%REPEAT+100,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL17"
	S OLNTB=VPB*1000
	;
	S VFSN("DBTBL17")="fDBTBL17"
	;
	F I=9:1:%MAX S %TAB(I)=""
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
	S %TAB(1)=$C(2,15,12)_"21U12402|3*|[DBTBL17]EXPID"
	S %TAB(2)=$C(2,35,10)_"20D|*ZLTD|[*]@ZLTD"
	S %TAB(3)=$C(2,53,12)_"20T|*ZUID|[*]@ZUID"
	S %TAB(4)=$C(2,77,1)_"00L|*COMMENT|[*]@COMMENT|||D VP1^V01S192"
	S %TAB(5)=$C(3,15,65)_"01T|*EXPDESC|[*]@EXPDESC"
	S %TAB(6)=$C(7,2,8)_"00U12401|*DDTYPE(1)|[*]@DDTYPE|type(||D VP2^V01S192"
	S %TAB(7)=$C(7,15,1)_"00L12403|*DDTYPE(1)|[*]@DDTYPE"
	S %TAB(8)=$C(7,22,55)_"00T12402|*DDTYPE(1)|[*]@NAME|||D VP3^V01S192|D VP4^V01S192"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	N YN,K,SAVE,I
	;
	I 'V,'X Q                                      ; From N to N
	I V,'X DO  Q                                   ; From Y to N
	. S YN=$$YN^DBSMBAR("",$$^MSG(793),0)
	. I YN K COMMT Q
	. S X=1
	I V,X DO  S X=1 Q:'YN
	. S YN=$$YN^DBSMBAR("",$$^MSG(1773),0)    ; From Y to Y
	;
	F K=1:1 Q:'$D(COMMT(K))  S SAVE(K)=COMMT(K)    ; Save original comments
	D ^DBSWRITE("COMMT")                   ; VMS editor
	I VFMQ="Q" DO
	. F I=1:1 Q:'$D(SAVE(I))  S COMMT(I)=SAVE(I) ; Restore original comments
	;
	D VREPRNT^@PGM                                 ; Restore screen
	S X=1,UX=1                                 ; Change flag to Y
	Q
VP2	;
	;
	I X'="" Q
	I V'="" D DELETE^DBSMACRO("@NAME","1","0")
	D GOTO^DBSMACRO("NEXT") Q
	Q
VP3	;
	D PPNAME^DBSDDEXP
	Q
VP4	;
	D PRENAME^DBSDDEXP
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
