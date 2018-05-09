 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBTBL33L ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S070(%O,fDBTBL33) ; DBS -  - SID= <DBTBL33L> Batch Compilation Attributes
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KVAR N PGM N VPG N vPSL N VSID
 S VSID="DBTBL33L"
 S KVAR="kill %A,%TAB,vtab,VFSN,%OLD,%NEW,%FILE,%INDEX,%PAGE,%PG,UX,MULSCR"
 S:'($D(%PG)#2) %PG=1 S %PAG=%PG+1 S %PAGE=$S(($D(%PAGE)#2):%PAGE-1,1:0)+2
 S vPSL=1 ;compiled for PSL
 ;
 S VPG(%PG+0)="Batch Definition|DBTBL33"
 S VPG(%PG+1)="Batch Definition (HTM)|DBTBL33B"
 S:'($D(%PG)#2) %PG=1 S %PGSV=%PG S MULSCR=""
 I '%O D VNEW(.fDBTBL33)
 I %O D VLOD(.fDBTBL33) I $get(ER) S VFMQ="Q" Q 
 D VPG(.fDBTBL33)
 Q 
 ;
VNEW(fDBTBL33) ; 
 ;
 Q 
 ;
 ;
VLOD(fDBTBL33) ; User defined access section
 Q 
 ;
VPG(fDBTBL33) ; 
 N vDONE
 S vDONE=0
 F  D  Q:vDONE 
 .	I %PG=(%PGSV+0) D VPG1(.fDBTBL33) D VPG0(.fDBTBL33) Q:vDONE 
 .	I %PG=(%PGSV+1) D VPG2(.fDBTBL33) D VPG0(.fDBTBL33) Q:vDONE 
 .	Q 
 Q 
 ;
VPG0(fDBTBL33) ; 
 N %LINK
 S %LINK=""
 I %O=2!(%O=3)!(%O=4) D VBTM(.fDBTBL33) I $get(VFMQ)="D" S vDONE=1 Q 
 I '($D(%PAGE)#2) S vDONE=1 Q 
 I %PG'<%PAG K %PAG,%PGSV,VPG S vDONE=1 Q 
 S %PG=%PG+1
 Q 
 ;
VPG1(fDBTBL33) ; Batch Definition
 N DFID
 S SID="DBTBL33" S DFID="DBTBL33"
 D ^USID I PGM="" S ET="INVLDSCR" D ^UTLERR Q 
 K VPTBL
 S VPGM=PGM
 D VREPRNT^V00S068
 I %O>1 Q 
 D VTAB^V00S068(.fDBTBL33)
 Q 
 ;
VPG2(fDBTBL33) ; Batch Definition (HTM)
 N DFID
 S SID="DBTBL33B" S DFID="DBTBL33"
 D ^USID I PGM="" S ET="INVLDSCR" D ^UTLERR Q 
 K VPTBL
 S VPGM=PGM
 D VREPRNT^V00S069
 I %O>1 Q 
 D VTAB^V00S069(.fDBTBL33)
 Q 
 ;
VBTM(fDBTBL33) ; 
 I %O=4,IO'=$P Q 
 D ^DBSCRT8A
 Q 
