V01S153	;; -  - 5.3 - SID= <DBTBL13> Pre/Post Processor Library
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/13/2007 15:47 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,%A",VSID="DBTBL13",VPGM=$T(+0),VSNAME="Pre/Post Processor Library"
	S VFSN("DBTBL13")="%A"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
V5	I %O=5 D VPR,VDA,V5^DBSPNT Q
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
	I ($G(LIBS)="")!($G(PID)="") Q
	I $D(^DBTBL(LIBS,13,PID)) Q  ; Already created
	S %A=$G(%A)
	S %A(0)=$G(%A(0))
	I $P(%A(0),"|",3)="" S $P(%A(0),"|",3)=+$H   ; DBTBL13.DATE
	I $P(%A(0),"|",1)="" S $P(%A(0),"|",1)=1   ; DBTBL13.MODFLG
	I $P(%A(0),"|",15)="" S $P(%A(0),"|",15)=%UID   ; DBTBL13.UID
	Q
	Q
VNEWDQ	; Original VNEW section
	;
	S %A(0)=$G(%A(0)),%A=$G(%A)
	Q
VLOD	; User defined access section
	;
	S %REPEAT=20,%A=$G(^DBTBL(%LIBS,13,PID))
	;
	S X=-0.001
	F I=0:1 S %A(I)="" S X=$O(^DBTBL(%LIBS,13,PID,X)) Q:X=""  S %A(I)=^(X)
	Q
VLODDQ	; Original VLOD section
	;
	S %A(0)=^DBTBL(LIBS,13,PID,0)
	S %A=^DBTBL(LIBS,13,PID)
	Q
VPR	; Display screen prompts
	;
	S VO="27||13|"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(4)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(5)=$C(4,4,6,0,0,0,0,0,0,0)_"01T Name:"
	S VO(6)=$C(4,28,6,0,0,0,0,0,0,0)_"01T Date:"
	S VO(7)=$C(4,48,9,0,0,0,0,0,0,0)_"01T User ID:"
	S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,4,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(13)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(16)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,30,15,1,0,0,0,0,0,0)_"01T Documentation "
	S VO(18)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(19)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(13,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	Q
VDA	; Display screen data
	N V
	I %O=5 N %A,v1,PID
	I  S (%A,v1,PID)=""
	E  N v1
	E  S %A=$G(%A),v1=$G(%A(0)),PID=$G(PID)
	;
	;
	S VO="35|28|13|"
	S VO(28)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($G(%FN)))
	S VO(29)=$C(4,11,12,2,0,0,0,0,0,0)_"01T"_PID
	S VO(30)=$C(4,35,10,2,0,0,0,0,0,0)_"01D"_$$DAT^%ZM($P(v1,"|",3))
	S VO(31)=$C(4,58,20,2,0,0,0,0,0,0)_"01T"_$P(v1,"|",15)
	S VO(32)=$C(6,18,40,2,0,0,0,0,0,0)_"00T"_$P(%A,"|",1)
	S VO(33)=$C(10,4,75,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",4)
	S VO(34)=$C(11,4,75,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",5)
	S VO(35)=$C(12,4,75,2,0,0,0,0,0,0)_"00T"_$P(v1,"|",6)
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=7,VPT=1,VPB=13,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL13"
	S OLNTB=13001
	;
	S VFSN("DBTBL13")="%A"
	;
	; 
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
	S %TAB(1)=$C(3,10,12)_"21U12402|3*|[DBTBL13]PID"
	S %TAB(2)=$C(3,34,10)_"21D12403|0|[DBTBL13]DATE"
	S %TAB(3)=$C(3,57,20)_"21T12415|0|[DBTBL13]UID"
	S %TAB(4)=$C(5,17,40)_"01T12401||[DBTBL13]DESC|||D VP1^V01S153"
	S %TAB(5)=$C(9,3,75)_"00T12404|0|[DBTBL13]DOC"
	S %TAB(6)=$C(10,3,75)_"00T12405|0|[DBTBL13]DOC2"
	S %TAB(7)=$C(11,3,75)_"00T12406|0|[DBTBL13]DOC3"
	;
	Q
	;
	;
VPOS	; User defined post processor's
	;
VP1	;
	S UX=1
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
