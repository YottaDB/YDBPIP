V01S286(%O,DBTBL6F)	;DBS - DBS - SID= <DBTBL6FF> QWIK Report Format Definition (Linked)
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL6FF ****
	;
	; 09/14/2007 09:23 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 09:23 - chenardp
	;
	N KVAR N VPG N vPSL N VSID
	S VSID="DBTBL6FF"
	S KVAR="kill %A,%TAB,vtab,VFSN,%OLD,%NEW,%FILE,%INDEX,%PAGE,%PG,UX,MULSCR"
	S:'($D(%PG)#2) %PG=1 S %PAG=%PG+1 S %PAGE=$S(($D(%PAGE)#2):%PAGE-1,1:0)+2
	S vPSL=1 ;compiled for PSL
	;
	S VPG(%PG+0)="QWIK Report Display Format Definition|DBTBL6F"
	S VPG(%PG+1)="QWIK Report Display Format Definition|DBTBL6F"
	S:'($D(%PG)#2) %PG=1 S %PGSV=%PG S MULSCR=""
	I '%O D VNEW(.DBTBL6F)
	I %O D VLOD(.DBTBL6F) I $get(ER) S VFMQ="Q" Q 
	D VPG(.DBTBL6F)
	Q 
	;
VNEW(DBTBL6F)	;
	;
	D VLOD(.DBTBL6F)
	Q 
VNEWDQ(DBTBL6F)	; Original VNEW section
	;
	Q 
	;
	;
VLOD(DBTBL6F)	; User defined access section
	Q 
VLODDQ(DBTBL6F)	; Original VLOD section
	;
	Q 
	;
VPG(DBTBL6F)	;
	N vDONE
	S vDONE=0
	F  D  Q:vDONE 
	.	I %PG=(%PGSV+0) D VPG1(.DBTBL6F) D VPG0(.DBTBL6F) Q:vDONE 
	.	I %PG=(%PGSV+1) D VPG2(.DBTBL6F) D VPG0(.DBTBL6F) Q:vDONE 
	.	Q 
	Q 
	;
VPG0(DBTBL6F)	;
	N %LINK
	S %LINK=""
	I %O=2!(%O=3)!(%O=4) D VBTM(.DBTBL6F) I $get(VFMQ)="D" S vDONE=1 Q 
	I '($D(%PAGE)#2) S vDONE=1 Q 
	I %PG'<%PAG K %PAG,%PGSV,VPG S vDONE=1 Q 
	S %PG=%PG+1
	Q 
	;
VPG1(DBTBL6F)	; QWIK Report Display Format Definition
	N DFID N PGM
	S SID="DBTBL6F" S DFID="DBTBL6F"
	D ^USID I PGM="" S ET="INVLDSCR" D ^UTLERR Q 
	S %MODS=1 I '($D(%REPEAT)#2) S %REPEAT=18
	K VPTBL
	S VPGM=PGM
	D VREPRNT^V01S285
	I %O>1 Q 
	D VTAB^V01S285(.DBTBL6F)
	Q 
	;
VPG2(DBTBL6F)	; QWIK Report Display Format Definition
	N DFID N PGM
	S SID="DBTBL6F" S DFID="DBTBL6F"
	D ^USID I PGM="" S ET="INVLDSCR" D ^UTLERR Q 
	S %MODS=19 S %REPEAT=zzREPEAT#18
	K VPTBL
	S VPGM=PGM
	D VREPRNT^V01S285
	I %O>1 Q 
	D VTAB^V01S285(.DBTBL6F)
	Q 
	;
VBTM(DBTBL6F)	;
	I %O=4,IO'=$P Q 
	D ^DBSCRT8A
	Q 
