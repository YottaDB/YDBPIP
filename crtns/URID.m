 ; 
 ; **** Routine compiled from DATA-QWIK Procedure URID ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
URID ; 
 ;
 D GET
 ;
 Q 
 ;
GET ; 
 ;
 K %LINK
 ;
 N dbtbl5h,vop1,vop2,vop3 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vRCgetRecord1Opt^RecordDBTBL5H("SYSDEV",RID,0,"")
  S vop3=$G(^DBTBL(vop1,5,vop2,0))
 S PGM=$P(vop3,$C(124),2)
 ;
 Q 
 ;
DRV ; 
 ;
 D RPT
 Q 
 ;
RPT ; 
 ;
 N PGM
 ;
 I '$D(RID) D ERR Q 
 D GET I PGM="" D ERR Q 
 ;
 D ^@PGM
 ;
 Q 
 ;
QRPT ; 
 ;
 N ER S ER=0
 N PGM
 ;
 Q:'$D(QRID) 
 ;
 N dbtbl5q,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=QRID,dbtbl5q=$$vRCgetRecord1Opt^RecordDBTBL5Q("SYSDEV",QRID,0,.vop3)
  S vop4=$G(^DBTBL(vop1,6,vop2,0))
 I '$G(vop3) D ERR Q 
 ;
 S PGM=$P(vop4,$C(124),2)
 ;
 ; If no program, compile and try again
 I PGM="" D
 .	D COMPILE^DBSEXEQ(QRID) Q:ER 
 .	;
 .	N dbtbl5q2,vop5,vop6,vop7 S vop5="SYSDEV",vop6=QRID,dbtbl5q2=$$vRCgetRecord0Opt^RecordDBTBL5Q("SYSDEV",QRID,0,"")
 .	 S vop7=$G(^DBTBL(vop5,6,vop6,0))
 .	;
 .	S PGM=$P(vop7,$C(124),2)
 . Q 
 ;
 I ER!(PGM="") D ERR Q 
 ;
 D ^@PGM
 ;
 Q 
 ;
ERR ; Private
 ;
 N ER S ER=1
 N ET S ET="INVLDRPT"
 ;
 D DSP^UTLERR
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "59973^70888^Chad Smith^2790" ; Signature - LTD^TIME^USER^SIZE
