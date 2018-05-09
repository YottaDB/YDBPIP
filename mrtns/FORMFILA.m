FORMFILA	;; -  - V3.6 - SID= <FORMFILL> Form System Batch Fill
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/21/94 08:36:39 - XUS
	;
        ; I18N=QUIT: Excleded from I18N standards.
	;----------Revision History ------------------------------------------
	; 09/16/94 - Fan Zeng - 14465
	;            Replaced %MODE with %IPMODE as %MODE was phased out.
	;
	;  08/18/94 - Shaodong Tony Xu ARQ 10174
	;              Review and Retrofit V4.4 and Prior Version Bugs Resolved.
	;	
	;----------------------------------------------------------------------
	K VO
	;
V0	;
	;
	S KVAR="K %A,%TAB,VFSN,%OLD,%NEW,%FILE,%INDEX,UX,VPTBL,%A",VSID="FORMFILL",VPGM=$T(+0)
	;
	;
	I %O D VLOD I 1 ; Existing record, load data from disk
	E  D VNEW ; Initialize data
	;
	I '$D(%NOFORM) D VPR ; Load form image into VO(1) - VO(n)
	I '$D(%NODATA) D VDA ; Load data into VO(n+1) - VO(n+nnn)
	;
	D ^DBSPNT() ; Output form
	I %O<2,$G(%IPMODE)'["NOINT" D VTAB,^DBSCRT8 ; Dedicated (Time share) data entry
	Q
	;
VNEW	; Initialize arrays if %O=0
	;
VLOD	; Load data from disc - %O = (1-5)
	;
	S ASK(0)=$G(LASTFID)
	F I=1:1:9 S ASK(I)="ALL"
	S ASK(10)=PY_","_PX
	;
VPR	; Display screen prompts
	;
	S VO=10
	S VO(0)="|0"
	S VO(1)=$C(1,1,79,1,0)_"01                Select Batch Criteria From Options Below                        "
	S VO(2)=$C(3,24,10,0,0)_"01 File Name:"
	S VO(3)=$C(4,24,10,0,0)_"01 Data Item:"
	S VO(4)=$C(5,22,12,0,0)_"01 Description:"
	S VO(5)=$C(6,15,19,0,0)_"01 Data Type <TN$DCF>:"
	S VO(6)=$C(7,25,9,0,0)_"01 Field Id:"
	S VO(7)=$C(8,15,19,0,0)_"01 Required Indicator:"
	S VO(8)=$C(9,19,15,0,0)_"01 Maximum Length:"
	S VO(9)=$C(10,16,18,0,0)_"01 Decimal Precision:"
	S VO(10)=$C(11,15,19,0,0)_"01 Computed Operation:"
	S VO(11)=$C(12,20,14,0,0)_"01 Pattern Check:"
	S VO(12)=$C(13,17,17,0,0)_"01 Starting Cursor:"
	Q
VDA	; Display screen data
	;
	S VO="23|13"
	S VO(13)=$C(3,35,40,2,0)_"00T"_$E(ASK(0),1,40)
	S VO(14)=$C(4,35,40,2,0)_"00T"_$E(ASK(1),1,40)
	S VO(15)=$C(5,35,40,2,0)_"00T"_$E(ASK(2),1,40)
	S VO(16)=$C(6,35,40,2,0)_"00T"_$E(ASK(3),1,40)
	S VO(17)=$C(7,35,40,2,0)_"00T"_$E(ASK(4),1,40)
	S VO(18)=$C(8,35,40,2,0)_"00T"_$E(ASK(5),1,40)
	S VO(19)=$C(9,35,40,2,0)_"00T"_$E(ASK(6),1,40)
	S VO(20)=$C(10,35,40,2,0)_"00T"_$E(ASK(7),1,40)
	S VO(21)=$C(11,35,40,2,0)_"00T"_$E(ASK(8),1,40)
	S VO(22)=$C(12,35,40,2,0)_"00T"_$E(ASK(9),1,40)
	S VO(23)=$C(13,35,12,2,0)_"00T"_ASK(10)
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ
	S %MAX=10,VPT=1,VPB=14,BLKSIZ=320,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL1D",%VERSN=2
	S OLNTB=14035
	;
	;
VTBL	; Create %TAB(array)
	;
	S %TAB(1)="0234040T|*ASK(0)|[SYSDEV,DBTBL1D]FID|^DBTBL(%LIBS,1,||D EXT^DBSQRY"
	S %TAB(2)="0334040T|*ASK(1)|[SYSDEV,DBTBL1D]DI|||D EXT^DBSQRY"
	S %TAB(3)="0434040T|*ASK(2)|[SYSDEV,DBTBL1D]DES|||D EXT^DBSQRY"
	S %TAB(4)="0534040T|*ASK(3)|[SYSDEV,DBTBL1D]TYPE|^DBCTL(""SYS"",""DVFM"",||D EXT^DBSQRY"
	S %TAB(5)="0634040T|*ASK(4)|[SYSDEV,DBTBL1D]NODE|||D EXT^DBSQRY"
	S %TAB(6)="0734040T|*ASK(5)|[SYSDEV,DBTBL1D]REQ|||D EXT^DBSQRY"
	S %TAB(7)="0834040T|*ASK(6)|[SYSDEV,DBTBL1D]LEN|||D EXT^DBSQRY"
	S %TAB(8)="0934040T|*ASK(7)|[SYSDEV,DBTBL1D]DEC|||D EXT^DBSQRY"
	S %TAB(9)="1034040T|*ASK(8)|[SYSDEV,DBTBL1D]COMP|||D EXT^DBSQRY"
	S %TAB(10)="1134040T|*ASK(9)|[SYSDEV,DBTBL1D]FMT|||D EXT^DBSQRY"
	S %TAB(11)="1234012T|*ASK(10)|[]ASK(10)"
	Q
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
