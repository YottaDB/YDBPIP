DBSIMP(%LIBS,FID,ZLIB,ZFID,ER)	;;DBS - U - V3.6 - IMPLICIT FILE DEFINITION UTILITY ; 17 Apr 89  8:57 AM - 8447
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/27/94 15:28:15 - CHIANG
	;     ORIG:  BOB CHIANG (8447) - 04/17/89
	;
	;    INPUT:  p1   -  input library name
	;            p2   -  input file name
	;
	;   OUTPUT:  p3   -  source library name
	;            P4   -  source file name
	;            p5   -  error flag
	;
	;           ^DBSIMP("PRD","DEP",.ZLIB,.ZFID,.ER)
	;
	;           will return ZLIB="SYSDEV"
	;                       ZFID="DEP"
	;                       ZR  =0
	;
	; I18N=QUIT: Excluded from I18N standards. 
	;
START	;
	N X
	;
	S ER=0,FID=$P(FID,",",1)
	;
	I '$D(^DBTBL(%LIBS,1,FID)) S ER=1 Q
	;
	S ZLIB=%LIBS,ZFID=FID
	;
	; ^DBTBL(%LIBS,1,FID,10)="||||[SRCLIB,SRCFID]"
	;
	S X=$P($G(^DBTBL(%LIBS,1,FID,10)),"|",5)
	I X="" Q
	;
	S ZLIB=$E($P(X,",",1),2,20)
	S ZFID=$P($P(X,",",2),"]",1)
	Q
	;
	; other DQ implicit definitions
	;
	;   p1    - input library name
	;   DQOPT - DQ definition option ( 2 - screen  5 - report  6 -QWIK rpt )
	;   ID    - DQ definition name
	;   ZLIBS - source library name
	;
	;   DQ("PRD",2,"LTYPE",.ZLIB) will return ZLIB="SYSDEV"
	;
DQ(%LIBS,DQOPT,ID,ZLIB)	;
	;
	S ZLIB=%LIBS I $G(^DBTBL(%LIBS,DQOPT,ID,-3))'="" S ZLIB=^(-3)
	Q
	;
