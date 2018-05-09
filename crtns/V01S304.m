V01S304(%O,fDBTBL1D,fDBTBL1)	; -  - SID= <DBTBL1D> Data Item Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL1D ****
	;
	; 09/14/2007 10:48 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:48 - chenardp
	;
	N KVAR N VPG N vPSL N VSID
	S VSID="DBTBL1D"
	S KVAR="kill %A,%TAB,vtab,VFSN,%OLD,%NEW,%FILE,%INDEX,%PAGE,%PG,UX,MULSCR"
	S:'($D(%PG)#2) %PG=1 S %PAG=%PG+1 S %PAGE=$S(($D(%PAGE)#2):%PAGE-1,1:0)+2
	S vPSL=1 ;compiled for PSL
	;
	S VPG(%PG+0)="Files Definition - Detail|DBTBL1E"
	S VPG(%PG+1)="Files Definition (Structure Definition)|DBTBL1F"
	S:'($D(%PG)#2) %PG=1 S %PGSV=%PG S MULSCR=""
	I '%O D VNEW(.fDBTBL1D,.fDBTBL1)
	I %O D VLOD(.fDBTBL1D,.fDBTBL1) I $get(ER) S VFMQ="Q" Q 
	D VPG(.fDBTBL1D,.fDBTBL1)
	Q 
	;
VNEW(fDBTBL1D,fDBTBL1)	;
	;
	D VLOD(.fDBTBL1D,.fDBTBL1)
	Q 
VNEWDQ(fDBTBL1D,fDBTBL1)	; Original VNEW section
	;
	Q 
	;
	;
VLOD(fDBTBL1D,fDBTBL1)	; User defined access section
	Q 
VLODDQ(fDBTBL1D,fDBTBL1)	; Original VLOD section
	;
	Q 
	;
VPG(fDBTBL1D,fDBTBL1)	;
	N vDONE
	S vDONE=0
	F  D  Q:vDONE 
	.	I %PG=(%PGSV+0) D VPG1(.fDBTBL1D,.fDBTBL1) D VPG0(.fDBTBL1D,.fDBTBL1) Q:vDONE 
	.	I %PG=(%PGSV+1) D VPG2(.fDBTBL1D,.fDBTBL1) D VPG0(.fDBTBL1D,.fDBTBL1) Q:vDONE 
	.	Q 
	Q 
	;
VPG0(fDBTBL1D,fDBTBL1)	;
	N %LINK
	S %LINK=""
	I %O=2!(%O=3)!(%O=4) D VBTM(.fDBTBL1D,.fDBTBL1) I $get(VFMQ)="D" S vDONE=1 Q 
	I '($D(%PAGE)#2) S vDONE=1 Q 
	I %PG'<%PAG K %PAG,%PGSV,VPG S vDONE=1 Q 
	S %PG=%PG+1
	Q 
	;
VPG1(fDBTBL1D,fDBTBL1)	; Files Definition - Detail
	N DFID N PGM
	S SID="DBTBL1E" S DFID="DBTBL1D"
	D ^USID I PGM="" S ET="INVLDSCR" D ^UTLERR Q 
	K VPTBL
	S VPGM=PGM
	D VREPRNT^V01S305
	I %O>1 Q 
	D VTAB^V01S305(.fDBTBL1D,.fDBTBL1)
	Q 
	;
VPG2(fDBTBL1D,fDBTBL1)	; Files Definition (Structure Definition)
	N DFID N PGM
	S SID="DBTBL1F" S DFID="DBTBL1D"
	D ^USID I PGM="" S ET="INVLDSCR" D ^UTLERR Q 
	K VPTBL
	S VPGM=PGM
	D VREPRNT^V01S306
	I %O>1 Q 
	D VTAB^V01S306(.fDBTBL1D,.fDBTBL1)
	Q 
	;
VBTM(fDBTBL1D,fDBTBL1)	;
	I %O=4,IO'=$P Q 
	D ^DBSCRT8A
	Q 
