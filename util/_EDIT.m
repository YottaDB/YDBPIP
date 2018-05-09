%EDIT(file)	;Public;Generic editor called from MUMPS
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/14/96 08:11:06 - CHENARD
	; ORIG:	CHENARD - 03/25/96
	; DESC:	Generic editor called from MUMPS
	;
	; KEYWORDS:	System Services
	;
	; ARGUMENTS:
	;	. file	File name to edit	/TYP=T/REQ/MECH=VAL
	;
	;
	; EXAMPLE:
	;	D ^%EDIT("/profile/prtns/XYZ.m")
	;
	;------Revision History------------------------------------------------
	;
	;----------------------------------------------------------------------
	;
	N ARRAY,buf,cmd,ET,FILE,HELP,I,key,LIST,par,RM,SCRIPT,SQLIHLP,X,x
	;
	D TERMSET^SCADRV
	;
	S FILE=$$PARSE^%ZFUNC(file)
	S X=$$FILE^%ZOPEN(FILE,"READ") I X D
	.	F I=1:1 S X=$$^%ZREAD(FILE,.ET) Q:+ET=1  D
	..		S ARRAY(I)=$$FORMAT^DBSEDT(X,1)
	.	C FILE
	S par="CODE/TYP=L,DIRECTORY,DQMODE/TYP=L,EXTENSION,FORMAT/TBL=DBTBL6E"
        S par=par_",OUTPUT,PROMPT,MATCH/TYP=N,PLAN/TYP=L,ROWS/TYP=N"
        S par=par_",PROTECTION/TYP=N,STATISTICS/TYP=L,OPTIMIZE/TYP=L,STATUS"
	S par=par_",MASK/TYP=U,TIMEOUT/TYP=N,CACHE/TYP=N,BLOCK/TYP=N"
	;
 	S SQLIHLP(1)=$$SCAU^%TRNLNM("HELP","SQLI.HLP")
 	S SQLIHLP(2)=$$SCAU^%TRNLNM("HELP","SQL.HLP")
	S HELP(1)="Editor"
	S HELP(2)="PROFILE/SQL-Commands"
        S SCRIPT=$$HOME^%TRNLNM("SQLI.INI")
	;
	S LIST("TABLES")="SELECT FID,DES,GLOBAL FROM DBTBL1"
	S LIST("COLUMNS")="SELECT DI,DES,TYP,LEN FROM DBTBL1D WHERE FID=?"
	;
	S cmd("RUN")="D RUN^SQLI(1,rec),REF^EDIT"
	S cmd("LIST")="D LIST^SQLI(1/REQ),REF^EDIT"
	S cmd("INCLUDE","PROCEDURE")="D INCPRE^SQLI(1),REF^EDIT"
	S cmd("COLUMNS")="D COLUMNS^SQLI(1/REQ)"
	S cmd("CONVERT")="D CONVERT^SQLI(1/REQ),REF^EDIT"
	S cmd("TUTORIAL")="D ^DBSTEST9,REF^EDIT"
	;
	S key("END")="RUN"
	;
	S buf=""
	I $D(ARRAY) S X="" F  S X=$O(ARRAY(X)) Q:X=""  S $P(buf,$C(13,10),X)=ARRAY(X)
	D ^EDIT(.buf,,,,,.cmd,.key,.par,FILE,.HELP,SCRIPT)
	;
	U 0 C FILE
	D CLOSE^SCADRV
	W $$MSG^%TRMVT($G(RM),0,1)
	Q 
	;
