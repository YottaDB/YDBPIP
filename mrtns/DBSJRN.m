DBSJRN	;;DBS - UTL - V5.2 - Journal File Definition
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/08/03 18:04:45 - RUSSELL
	;     ORIG:  CHIANG -  14 MAR 1996
	;     DESC:  Related File Definition
	;
	; I18N=QUIT: Exclude from I18N standards 
	;
	;---------- Revision History -------------------------------------------
	; 10/26/05 - RussellDS - CR17834
	;	     Changed call from top of ^DBSFILER to EXT^DBSFILER.
	;
	;	     Removed old revision history.
	;
	;----------------------------------------------------------------------
INSERT	; Create new definiiton
	;----------------------------------------------------------------------
	S %O=0 D EXEC Q
	Q
	;----------------------------------------------------------------------
UPDATE	; Update definition
	;----------------------------------------------------------------------
	S %O=1 D EXEC Q
	Q
	;----------------------------------------------------------------------
COPY	; Copy Definition
	;----------------------------------------------------------------------
	N %TAB,%READ,VFMQ,FROMTJD,PRITABLE,TOJRN,di
	S %TAB("PRITABLE")=".PSFILE1/TBL=^DBTBL(%LIBS,9,/REQ"	; Define prompts
	S %TAB("FROMJRN")=".JRNID/TBL=[DBTBL9]/REQ"
	S %TAB("TOJRN")=".JRNID/TBL=[DBTBL9]:NOVAL/REQ/XPP=I $D(^DBTBL(%LIBS,9,PRITABLE,X)) S ER=1,RM=$$^MSG(252)"
	S %READ="@@%FN,,PRITABLE,FROMJRN,,TOJRN"
	D ^UTLREAD I VFMQ="Q" Q					; Get keys
	;							; Copy definition
	S ^DBTBL(%LIBS,9,PRITABLE,TOJRN)=^DBTBL(%LIBS,9,PRITABLE,FROMJRN)
	S di="" F  S di=$O(^DBTBL(%LIBS,9,PRITABLE,FROMJRN,di)) Q:di=""  D
	.	S ^DBTBL(%LIBS,9,PRITABLE,TOJRN,di)=^(di)
	Q
	;----------------------------------------------------------------------
EXEC	; Access definition screens
	;----------------------------------------------------------------------
	K Colnam,Pri2sub,Coldes,srclib
	;
	D ACCESS^DBSINDXS("DBTBL9",%O)			; Access keys
	I VFMQ="Q" Q
	;
	S srclib=$$LIB^DBSDD(PRITABLE,%LIBS)             ; Target library name 
	I $P(srclib,".",1)'=%LIBS S ER=1,RM=$$^MSG(7081,srclib) Q 
	;
	S SID="DBTBL9",UX=1 D ^USID I PGM="" Q		; Get run-time routine
	D ^@PGM						; Access header page
	I %O=0,VFMQ="Q" Q
	;
	I '%O D EXT^DBSFILER("DBTBL9",0)		; File header page
	I %O=1,$O(UX(""))'="" D EXT^DBSFILER("DBTBL9",1)
	S %PG=1
	S SID="DBTBL9D" D ^USID I PGM="" Q		; Access detail page
EXEC1	; 
	D ^@PGM						;
	I VFMQ="Q" Q					; Quit
	I VFMQ="F" D FILE Q				; File data
	S %PG=%PG+1,%MODS=%PG-1*16+1			; Calculate offset
	G EXEC1						; Next page
	Q
	;----------------------------------------------------------------------
FILE	; File data
	;----------------------------------------------------------------------
	N c,i,par,q,sql,sqldta,v,%O
	S i="",q="'",d="','"
	D DELETE				; Delete old data
	;
	S %O=0
	S i="" F  S i=$O(Colnam(i)) Q:i=""  D   ; Create new map
	. I Colnam(i)="" Q
	. S sql="INSERT DBTBL9D (%LIBS,PRITABLE,JRNID,COLNAM,MAP) VALUES ("
	. S sql=sql_q_%LIBS_d_PRITABLE_d_JRNID_d_Colnam(i)_d_Pri2sub(i)_q_")"
	. S ER=$$^SQL(sql)			; Insert new record
	;
	K Colnam,Pri2sub,Coldes
	D PARFID(PRITABLE,JRNID)		; Check supertype logic
	;					; Update DBTBL9 header record
	S ER=$$^SQL("UPDATE DBTBL9 SET TIME="_$P($H,",",2)_" WHERE PRITABLE=:PRITABLE AND JRNID=:JRNID")
	Q
	;----------------------------------------------------------------------
PARFID(FID,JRNID)	; Copy data down from supertype to subtype 
	;----------------------------------------------------------------------
	N di,sfid,v
	;
	I '$D(^DBINDX(%LIBS,"PARFID",FID)) Q
	S sfid="" F  S sfid=$O(^DBINDX(%LIBS,"PARFID",FID,sfid)) Q:sfid=""  D
	.	K ^DBTBL(%LIBS,9,sfid,JRNID)		; Delete old definition
	.	S v=^DBTBL(%LIBS,9,FID,JRNID)
	.	S $P(v,"|",13)=FID			; Supertype file name
	.	S $P(v,"|",9)=+$H			; Date
	.	S $P(v,"|",14)=$P($H,",",2)		; Time
	.	S $P(v,"|",10)=$$USERNAM^%ZFUNC		; User
	.	S ^DBTBL(%LIBS,9,sfid,JRNID)=$$CHANGE(v,FID,sfid)
	.	S di="" F  S di=$O(^DBTBL(%LIBS,9,FID,JRNID,di)) Q:di=""  D
	..		S v=^(di)
	..		S v=$$CHANGE(v,FID,sfid)	; Change table name
	..		S ^DBTBL(%LIBS,9,sfid,JRNID,di)=v
	Q
	;----------------------------------------------------------------------
CHANGE(str,ofid,nfid)	; Convert table name from ofid to nfid 
	;----------------------------------------------------------------------
	; Example:  CHANGE("ACN.CLS,ACN.BAL","ACN","DEP")
	;           returns:  DEP.CLS,DEP,BAL
	;----------------------------------------------------------------------
	N old,new
	S old=ofid_".",new=nfid_"."
	F  Q:str'[old  S str=$P(str,old,1)_new_$P(str,old,2,999)
	Q str
	;----------------------------------------------------------------------
DELETE	; Called by function DBSJRND (delete definition)
	;----------------------------------------------------------------------
	N i,q,sfid
	S i="",q="'"
	;
	; --- Get column names (select COLNAM from DBTBL9D where ...)
	;
	S sql="select COLNAM from DBTBL9D where PRITABLE="_q_PRITABLE_q
	S sql=sql_" and JRNID="_q_JRNID_q
	S par("ROWS")=999
	S ER=$$^SQL(sql,.par,,.sqldta)		; Get column names
	;
	; --- Delete old data (delete DBTBL9D where ....)
	;
	F i=1:1:$L(sqldta,$c(13,10)) D
	.	S v=$P(sqldta,$c(13,10),i)	; Column name
	.	S sql="delete DBTBL9D where PRITABLE="_q_PRITABLE_q
	.	S sql=sql_" and JRNID="_q_JRNID_q_" and COLNAM="_q_v_q
	.	S ER=$$^SQL(sql)		; Delete old data
	;
	I '$D(^DBINDX(%LIBS,"PARFID",PRITABLE)) Q
	S sfid=""
	F  S sfid=$O(^DBINDX(%LIBS,"PARFID",PRITABLE,sfid)) Q:sfid=""  D
	.	K ^DBTBL(%LIBS,9,sfid,JRNID)		; Delete old definition
	Q
