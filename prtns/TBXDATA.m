TBXDATA	;Private;DATA UTILITIES
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 09:29:27 - KWANL
	; ORIG:	KWANL - 05/02/02
	; DESC:	DATA UTILITIES
	;
	; KEYWORDS:	
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. v1	desc of variable	/TYP=T
	;
	; RETURNS:
	;	. XX	desc of return		/TYP=T
	;
	; RELATED:
	;	. $$func^rtn - description of how related
	;
	; EXAMPLE:
	;	Text of example (line one)
	;
	;--------- Revision History ------------------------------------------
	; 03/15/2007	KWANL
	;		Modified RDB section to delete data using '/NOCASDEL' option
	;		in GTM.
	;
	; 02/03/2006	KWANL
	;		Modified GETCODE section to get several data in global format.
	;
	; 02/02/2006	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	; 01/16/2006	KWANL
	;		Modified DAT section to convert $C(9) in description.
	;		to the string "_$C(9)_" to fix issue in SCATBLDOC.
	;		Modified RDB section to support single record of SCATBL,
	;		SCATBLDOC and SCATBL3.
	;
	; 01/04/2006	KWANL
	;		Modified RDB section to prevent "ORA-00947: not enough values" 
	;		error.
	;
	; 11/25/2005 	KWANL
	;		Cleaned up RDB section.
	;
	; 11/21/2005	KWANL
	;		Added code to disable foreign key constraints and enable it
	;		after the data is added.
	;
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;
	; 28/10/2005	KWANL
	;		Rewrite ZSCATBL to remove function from ^SCATBL.
	;
	; 09/23/2005	KWANL
	;		Modified DAT section to exclude computed column and master
	;		field.
	;		Modified the RDB section as follows: 
	;		1) map the table and column name to Oracle names one by one
	;		2) change TRUNC to delete, 
	;		3) added an additional single quote to a string if the string 
	;		   contains a single quote, 
	;		4) added a where clause so that z-named data will not be removed
	;		   for SCATBL, SCATBL3 SCATBL5, and SCATBLDOC table.
	;		5) replaced SQL with DBSDYNRA to by pass filer when inserting data
	;		   to MDB.
	;		3) Modified to perform delete only when it is not in an initial env.
	;	
	; 07/21/2005	JOYCEJ
	;		Added code to detect file type before setting extension.
	;		Change is in the LOAD section. This was done to support
	;		the loading of .DAT files from Application Studio.
	;		A corresponding change was made to TBXDQSVR.
	;
	; 07/06/2005	MBUIM CR 14804
	;		Modified RDB section and added section ZSCATBL to only
	;		delete the top level of ^SCATBL(1,FN in a GTM envrnmt.
	;
	; 06/28/2005    MBUIM CR 14804
	;	        Modified RDB section to call into MAP^DBMAP with one 
	;	        column at a time. Also Modified EXTLOOP section to 
	;		quit if table is STBLMTBLS so that it's not loaded as
	;		a .DAT file.
	;
	; 06/15/2005 	MBUIM CR 14804
	;      	Removed call to FILE^DBMAP in RDB section. The ^DBTBL 
	; 	global must be defined completely for the table before
	; 	FILE^DBMAP is called
	;
	; 06/09/2005	MBUIM CR 14804
	;		Modified RDB section to map the reserved names in a 
	;		relational database and builds the DBMAP global.
	;		Also Modified GETCODE section to get .G extracts for
	;		tables that reside in M database
	;
	; 06/08/2005    MBUIM CR 14804
	;		Modified EXTLOOP section to new CODE array in the loop
	;
	; 03/15/2005 	MBUIM CR 14804
	;		Modified GETCODE section, for profile version 7.0 and
	;		above extract column names and values separated by tab
	;		delimeter as coded in new section DAT
	;		Also modified LOAD section to consider database 
	;		independence then load the extracts in TYPE(DAT)format
	;		as coded in new section RDB and ZRDB to trap errors
	;		Also included new section EXTLOOP which extract all 
	;		Profile Files in DAT format
	;
	; 11/14/2003	Terrie Dougherty     
	;		Added code to LOAD section to skip global kill on SCATBL-5-*.G
	;	
	; 08/26/2003	Terrie Dougherty
	;		Added code to LOAD section to skip global kill on STBL-XBAD.G
	;
	; 07/29/2003	Jim Joyce
	;		Added code to LOAD section to skip global kill
	;		on select data files: STBL-MSG.G and SCATBL-1-*.G
	;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	N VN
	;
	; Get profile version
	S VN=$G(^CUVAR("%VN"))
	;
	; Extract column names and values separated by tab delimeter except for
	; OBJECT and DBCTL
	I VN'<"7.0","OBJECT,DBCTL,STBL-MBAR,STBL-MTBLS,STBL-PROMPT"'[OBJECTID D  Q $$DAT(.CODE,OBJECTID)
	.	S FILENAME=OBJECTID_".DAT" 
	;
	N KEY1,KEY2,KEY3
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S KEY1=$P(OBJECTID,"-",1),KEY2=$P(OBJECTID,"-",2),KEY3=$P(OBJECTID,"-",3)
	;
	; add quotes if keys contain at least one alphabetic characters
	I $G(KEY2)?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I $G(KEY3)?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	S FILENAME=OBJECTID_".G"
	Q $$EXTRACT(.CODE,$G(KEY1),$G(KEY2),$G(KEY3))
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,HEADNAME,USER,DATE,TIME,END,CONAME,MESSAGE,KEY1,KEY2,KEY3
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S KEY1=$P(OBJECTID,"-",1),KEY2=$P(OBJECTID,"-",2),KEY3=$P(OBJECTID,"-",3)
	;
	I KEY1=OBJECTID,("SCATBL,SCATBLDOC,SCATBL3"[KEY1) Q 0_$C(13,10)_"Error: "_KEY1_" table is not allowed to update"
	;
	; add quotes if keys contain at least one alphabetic characters
	I $G(KEY2)?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I $G(KEY3)?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	I KEY1=OBJECTID S GREF=("^"_KEY1)
	I (KEY1'=OBJECTID)&(KEY2'="")&(KEY3="") S GREF=("^"_KEY1_"("_KEY2_")")
	I (KEY1'=OBJECTID)&(KEY2'="")&(KEY3'="") S GREF=("^"_KEY1_"("_KEY2_","_KEY3_")")
	I '$D(@GREF) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Data in "_CONAME
	;
	; Data exists
	S MESSAGE="Update Data : "_OBJECTID_" Modified in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Batch Def sent by client
	;-----------------------------------------------------------------------
	;
	N SEQ,CODE,FILENAME
	S SEQ=""
	;
	; Load from buffer into CODE array
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	I $E($G(CODE($O(CODE("")))))="^" S FILENAME=OBJECTID_".G"
	E  S FILENAME=OBJECTID_".DAT"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	
	;-----------------------------------------------------------------------
	; 
	Q 1
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME);	
	;-----------------------------------------------------------------------
	;
	N EXIT,SEQ,$ZT,KEY1,KEY2,KEY3,GREF,GNAME,CLEAN,RESULT
	S $ZT=$$SETZT^%ZT("ZTL^TBXDATA")
	;
	; Load FILE.DAT extracts into relational database 
	I $P(FILE,".",2)="DAT" D  Q EXIT
	.	S EXIT=1
	.	D RDB(.CODE,FILE)
	. 	I (RTYPE=1)!(RTYPE=2) d
	..		I $D(^TMPDQS($J,"phase1","data",FILE)) S ^TMPDQS($J,"phase1")=1
	..		I $D(^TMPDQS($J,"phase2","data",FILE)) S ^TMPDQS($J,"phase2")=1
	.	I ER S EXIT="0|Data file failed to load: "_$G(RM)
	;
	S GNAME=$P(FILE,".",1)
	S KEY1=$P(GNAME,"-",1),KEY2=$P(GNAME,"-",2),KEY3=$P(GNAME,"-",3)
	;
	; CLEAN flag indicates that the global should be deleted (killed) before 
	; the new data is loaded.
	S CLEAN=1
	;
	I (KEY1="STBL"),(KEY2="MSG") S CLEAN=0
	I (KEY1="STBL"),(KEY2="XBAD") S CLEAN=0
	I (KEY1="SCATBL"),(KEY2="1") S CLEAN=0
	I (KEY1="SCATBL"),(KEY2="5") S CLEAN=0
	;
	; add quotes if keys contain at least one alphabetic characters
	I $G(KEY2)?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I $G(KEY3)?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	I KEY1=GNAME S GREF=("^"_GNAME)
	I (KEY1'=GNAME)&(KEY2'="")&(KEY3="") S GREF=("^"_KEY1_"("_KEY2_")")
	I (KEY1'=GNAME)&(KEY2'="")&(KEY3'="") S GREF=("^"_KEY1_"("_KEY2_","_KEY3_")")
	;
	; Kill existing data
	I CLEAN K @GREF
	;
	; Load new data
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. ; This is to fix the end of file
	. I CODE(SEQ)="" Q						
	. S @CODE(SEQ)
	; 
	I (RTYPE=1)!(RTYPE=2) d
	.	I $D(^TMPDQS($J,"phase1","data",FILE)) S ^TMPDQS($J,"phase1")=1
	.	I $D(^TMPDQS($J,"phase2","data",FILE)) S ^TMPDQS($J,"phase2")=1
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,KEY1,KEY2,KEY3)	
	;-----------------------------------------------------------------------
	;
	N $ZT,GREF,REF,DATA
	S $ZT=$$SETZT^%ZT("ZTE^TBXDATA")
	;
	I ($G(KEY1)'="")&($G(KEY2)="")&($G(KEY3)="") S GREF="^"_KEY1 Q:'$D(@GREF) "0|Global definition "_KEY1_" does not exist"
	; 
	I ($G(KEY1)'="")&($G(KEY2)'="")&($G(KEY3)="") S GREF="^"_KEY1_"("_KEY2_")" Q:'$D(@GREF) "0|Global definition "_KEY1_"."_KEY2_" does not exist"
	;
	I ($G(KEY1)'="")&($G(KEY2)'="")&($G(KEY3)'="") S GREF="^"_KEY1_"("_KEY2_","_KEY3_")" Q:'$D(@GREF) "0|Global definition "_KEY1_"."_KEY2_"."_KEY3_" does not exist"
	;
	N REF
	S REF=$P(GREF,")",1) 
	;
	; convert control characters
	I $D(@GREF)#10 D  
	.	I @GREF="" S CODE(1)=""_GREF_"="_"""""" Q
	.	I @GREF?.N S CODE(1)=""_GREF_"="_@GREF Q
	.	I @GREF?.E1C.E S Y=@GREF,Y=$$FIXCCHR^TBXDQUTL(Y),CODE(1)=""_GREF_"="_Y Q
	.	S CODE(1)=""_GREF_"="_$$QADD^%ZS(@GREF) Q
	F  S GREF=$Q(@GREF) Q:(GREF="")!($E(GREF,1,$L(REF))'=REF)  D 
	.	I @GREF="" S CODE($O(CODE(""),-1)+1)=""_GREF_"="_"""""" Q
	.	I @GREF?.N S CODE($O(CODE(""),-1)+1)=""_GREF_"="_@GREF Q
	.	I @GREF?.E1C.E S Y=@GREF,Y=$$FIXCCHR^TBXDQUTL(Y),CODE($O(CODE(""),-1)+1)=""_GREF_"="_Y Q
	.  S CODE($O(CODE(""),-1)+1)=""_GREF_"="_$$QADD^%ZS(@GREF)
	; 
	Q 1 
	;
	;-----------------------------------------------------------------------
OBSGBL(FILE)	
	;-----------------------------------------------------------------------
	;
	N GREF,REF,NAME,KEY1,KEY2,KEY3
	;
	S NAME=$P(FILE,".",1)
	S KEY1=$P(NAME,"-",1),KEY2=$P(NAME,"-",2),KEY3=$P(NAME,"-",3)
	;
	D SYSVAR^SCADRV0()
	; Obsolete data from relational database 
	I $P(FILE,".",2)="DAT" D  Q EXIT
	.	S EXIT=$$OBSRDB(FILE)
	.	; no need to remove data from table. A drop table command
	.	; will remove the table and data.
	;
	; add quotes if keys contain at least one alphabetic characters
	I $G(KEY2)?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I $G(KEY3)?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	I ($G(KEY1)'="")&($G(KEY2)="")&($G(KEY3)="") S GREF="^"_KEY1
	; 
	I ($G(KEY1)'="")&($G(KEY2)'="")&($G(KEY3)="") S GREF="^"_KEY1_"("_KEY2_")"
	;
	I ($G(KEY1)'="")&($G(KEY2)'="")&($G(KEY3)'="") S GREF="^"_KEY1_"("_KEY2_","_KEY3_")" 
	;
	K @GREF
	Q 1 
	;
	;---------------------------------------------------------------------- 
EXTLOOP	; Extract all Profile Files in DATA format 
	;---------------------------------------------------------------------- 
	; 
	N FID,FILENAME,GBL,SEQ,VARGBL 
	; 
	S VARGBL("DBRES")=1 
	S VARGBL("GLCTL")=1 
	S VARGBL("OBJSCRIP")=1 
	S VARGBL("PACKAGE")=1 
	S VARGBL("SCATBL")=1 
	S VARGBL("SQL")=1 
	S VARGBL("STBL")=1 
	; 
	S FID="" 
	F  S FID=$O(^DBTBL("SYSDEV",1,FID)) Q:FID=""  D
	. 	S GBL=$G(^DBTBL("SYSDEV",1,FID,0))
	. 	I '$G(VARGBL(GBL))=1 Q 
	.	N CODE
	.	; For each file selected extract to output file
	.	S FILENAME=$$SCAU^%TRNLNM("SPOOL",""_FID_".DAT")
	.	I FILENAME="STBLMTBLS" Q
	. 	I +$$DAT(.CODE,FID)=0 Q       
	.	O FILENAME
	.	U FILENAME 
	.	S SEQ=""
	.	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D 
	..		W CODE(SEQ)
	..		I $O(CODE(SEQ)) W !		
	.	U 0
	.	C FILENAME
	; 
	Q  
	;
	;----------------------------------------------------------------------
DAT(CODE,FID);	Extract Profile File in DATA format 
	;----------------------------------------------------------------------
	; 
	N COLS,CMP,DATA,rowdata,rownum,SEQ,sqlcnt,sqlstat,sqlqlf,VALS,QRY,FN 
	;
	;
	S FN=$P(FID,"-",2),FID=$P(FID,"-",1)
	;
	; Verify FID is valid else quit
	Q:'$D(^DBTBL("SYSDEV",1,FID)) "0|Table does not exist"	
	;
	; Get columns into CODE(1)
	S COLS=""
	S CODE(1)=""
	F  S COLS=$O(^DBTBL("SYSDEV",1,FID,9,COLS)) Q:COLS=""  D
	.	S CMP=$G(^DBTBL("SYSDEV",1,FID,9,COLS))
	.	; Skip numbers, computed columns and literals
	.	I $$isLit^UCGM(COLS) Q
	.	I $P(CMP,"|",16)'="",($P(CMP,"|",16)'=" ") Q
	.	I $$isSfdMaster^UCXDD(FID,COLS) Q	
	.       S CODE(1)=CODE(1)_COLS_$C(9)
	;
	; Remove Trailing Tab
	S CODE(1)=$E(CODE(1),1,$L(CODE(1))-1)
	;
	; For each column get data into CODE(SEQ)
	S QRY=""
	I (FID="SCATBL")!(FID="SCATBL3")!(FID="SCATBLDOC") D
	. I FN'="" S QRY=" WHERE FN='"_FN_"'"
	. E  S QRY=" WHERE FN NOT LIKE 'Z%'"
	;
	I (FID="SCATBL5") s QRY=" WHERE MRPC NOT LIKE '$$^Z%'"
	F INC=1:1:$L(CODE(1),$C(9))  D
	.	S SEQ=1
	.	I CODE(1)="" Q
	.	S COLS=$P(CODE(1),$C(9),INC)
	.	S sqlqlf("ROWS")=20,rownum=1
	.	D OPEN^SQL("CURSOR RESULTS AS SELECT "_COLS_" FROM "_FID_QRY,.sqlqlf,.sqlstat,.rowdata,.sqlcnt) Q:ER
	.	I sqlcnt F  Q:'$$FETCH^SQLFUNCS("RESULTS",.rownum,.DATA,.sqlstat,.rowdata,.sqlcnt)  D	
	..		;; S VALS=$P(DATA,"$C(9)",1)              ; what is the prupose ????
	..		s VALS=$$cTabToS(DATA)			; convert TAB to TAB string "_$C(9)_"
	..		S SEQ=SEQ+1
	..		I '$D(CODE(SEQ)) S CODE(SEQ)=""
	..		S CODE(SEQ)=CODE(SEQ)_VALS_$C(9)
	.	D CLOSE^SQL("RESULTS")	
	;
	; Remove Trailing Tabs ($C(9))
	S SEQ=1
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D 
	.	I CODE(SEQ)="" Q
	.	S CODE(SEQ)=$E(CODE(SEQ),1,$L(CODE(SEQ))-1)	
	; 
	Q 1 
	;
	;---------------------------------------------------------------------- 
RDB(CODE,FILE)	; Relational DataBase Load 
	;---------------------------------------------------------------------- 
	; 
	N COL,COLS,COLUMN,FID,INC,OK,RDB,SEQ,SQL,VALS,QRY,len,FN 
	S $ZT=$$SETZT^%ZT("ZRDB^TBXDATA") 
	;
	S FID=$P(FILE,".",1) 
	S FN=$P(FID,"-",2),FID=$P(FID,"-",1) 
	I $G(db)="" S db=$$TRNLNM^%ZFUNC("SCAU$DB") 
	; 
	; Relational database flag 
	S RDB=$$rdb^UCDBRT(FID)
	; 
	S COLS=""
	S COLUMN=""
	;
	S FLAG=0
	;
	I RDB D
	. d dConstrt^TBXSQL(FID)	; disable table contraints
	;
	; Do not map columns in a GTM environment
	;I db="GTM" D
	I 'RDB D
	.	F COL=1:1:$L(CODE(1),$C(9)) Q:COL=""  D
	..		; This is to fix the end of file
	..		I CODE(1)="" Q
	..		S COLUMN=$P(CODE(1),$C(9),COL)
	..		S COLS=COLS_COLUMN_"," 
	E  D
	.	D MAP^DBMAP(db,.FID)
	.	F COL=1:1:$L(CODE(1),$C(9)) Q:COL=""  D
	..		; This is to fix the end of file
	..		I CODE(1)="" Q
	..		S COLUMN=$P(CODE(1),$C(9),COL)
	..		; Maps the reserved names in oracle
	.. 	D MAP^DBMAP(db,.FID,.COLUMN)
	.. 	S COLS=COLS_COLUMN_","
	; Remove trailing comma. 
	S COLS=$E(COLS,1,$L(COLS)-1) 
	; 
	; Allocate new run-time record object 
	n rec 
	i 'RDB s rec=$$new^DBSDYNRA(FID) 
	; 
	; If it is an initial environment, there is no data to delete. 
	I '$G(initEnv) D 
	. ; Delete entries except znamed items. 
	. S QRY="" 
	. I (FID="SCATBL")!(FID="SCATBL3")!(FID="SCATBLDOC") D 
	.. i FN'="" s QRY=" WHERE FN='"_FN_"'" 
	.. e  S QRY=" WHERE FN NOT LIKE 'Z%'" 
	. I (FID="SCATBL5") s QRY=" WHERE MRPC NOT LIKE '$$^Z%'" 
	. I RDB=1 D 
	.. ; Maps the reserved names in oracle
	.. S SQL=("DELETE FROM "_FID_""_QRY)
	.. D DBAPI^TBXSQL(SQL)
	.. D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_RM)
	. E  D 
	.. ; Delete top level ^SCATBL(1,FN
	.. I FID="SCATBL" D ZSCATBL Q
	..	S OK=0
	.. S OK=$$^SQL("DELETE FROM "_FID_QRY,"/NOCASDEL")
	.. W:OK "Error: "_$G(RM)    
	;
	; set the number of column based on the header to prevent 
	; "ORA-00947: not enough values " error
	s len=$L(CODE(1),$C(9))
	;
	; Load new data
	S SEQ=1
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	.	; This is to fix the end of file
	.	I CODE(SEQ)="" Q
	.	S VALS=""
	.	;F INC=1:1:$L(CODE(SEQ),$C(9)) S VALS=VALS_"'"_$$ADDQ($P(CODE(SEQ),$C(9),INC))_"',"
	.	F INC=1:1:len S VALS=VALS_"'"_$$ADDQ($$cTabStr($P(CODE(SEQ),$C(9),INC)))_"',"
	.	S VALS=$E(VALS,1,$L(VALS)-1)
	.	I RDB=1 D
	..		S SQL=("INSERT INTO "_FID_" COLUMNS ("_COLS_") VALUES ("_VALS_")")
	..		D DBAPI^TBXSQL(SQL)
	..		D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_RM)
	.	;E  S OK=$$^SQL("INSERT INTO "_FID_" ("_COLS_") VALUES ("_VALS_")","/NOVALST")
	.	E  D
	..		; code to load .DAT into MDB table:
	..		; call propSet for each Column of the record
	..		f INC=1:1:$L(COLS,",") d propSet^DBSDYNRA(rec,$P(COLS,",",INC),$$cTabStr($P(CODE(SEQ),$C(9),INC)),0)
	..		;
	..		; (bypass) save the record
	..		d bypassSave^DBSDYNRA(rec)
	..		D:ER logmsg^TBXDQUTL("SQL ERROR: "_RM)
	;
	; clean up vobj()
	i 'RDB d dispose^DBSDYNRA(rec)
	;
	I ((RDB)&(RTYPE=3)) D
	. d eConstrt^TBXSQL	; enable table constraints if it is via mrpc
	Q
	;
ZSCATBL	; Delete top level ^SCATBL(1,FN
	;
	n func,GREF
	s func=$G(FN)
	I func'="" D  Q
	. s GREF=("^SCATBL(1,"_$$QADD^%ZS(func)_")")
	. ZWI @GREF
	s func="" f  s func=$O(^SCATBL(1,func)) q:func=""  d
	.	i $E(func)="Z" Q
	.	s GREF=("^SCATBL(1,"_$$QADD^%ZS(func)_")")
	.       ZWI @GREF 
	; 
	Q 
	;
	;----------------------------------------------------------------------
ZTL	; Error trap for load 
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to load element. "_X 
	; 
	Q 0_"|"_RM 
	; 
	;---------------------------------------------------------------------- 
ZTE	; Error trap for extract 
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to extract element. "_X
	;
	Q 0_"|"_RM
	;
	;----------------------------------------------------------------------
ZRDB	; Error trap for relational database element load  
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM=X 
	; 
	Q 
	; 
	;--------------------------------------------------------------------- 
ADDQ(STR);	Double the single quote to prevent string being truncated when inserting 
	; to Oracle.
	;---------------------------------------------------------------------
	; 
	N TMPSTR,INC 
	S TMPSTR="" 
	I $F(STR,"'")=0 Q STR 
	F INC=1:1:$L(STR,"'") S TMPSTR=TMPSTR_$P(STR,"'",INC)_"''"   
	Q $E(TMPSTR,1,$L(TMPSTR)-2) 
	; 
	;--------------------------------------------------------------------- 
cTabToS(str);	Convert TAB ascii value to TAB string. ie from $C(9) to 
	; "_$C(9)_". This is to fix the issue with SCATBLDOC where the 
	; descprition column contains TABs.
	;---------------------------------------------------------------------
	;
	n inc,tmpstr
	i str'[$C(9) Q str
	s tmpstr=""
	f inc=1:1:$L(str,$c(9)) s tmpstr=tmpstr_$P(str,$C(9),inc)_"_$C(9)_"
	Q $E(tmpstr,1,$L(tmpstr)-7)
	;
	;---------------------------------------------------------------------
cTabStr(str);	Convert TAB string back to TAB. ie from "_$C(9)_" to $C(9) 
	;---------------------------------------------------------------------
	n inc,tmpstr
	i str'["_$C(9)_" Q str
	s tmpstr=""
	f inc=1:1:$L(str,"_$C(9)_") s tmpstr=tmpstr_$P(str,"_$C(9)_",inc)_$C(9)
	Q $E(tmpstr,1,$L(tmpstr)-1)
	;
	;---------------------------------------------------------------------
OBSRDB(FILE);	Obsolete single record elements. 
	;---------------------------------------------------------------------
	;
	n FID,FN,SQL
	s FID=$P(FILE,".",1),FN=$P(FID,"-",2),FID=$P(FID,"-",1)
	;
	I FN="" Q 1
	I $G(db)="" S db=$$TRNLNM^%ZFUNC("SCAU$DB")
	S RDB=$$rdb^UCDBRT(FID)
	;
	I RDB=1 D 
	. d dConstrt^TBXSQL(FID)
	. ;
	.  S SQL=("DELETE FROM "_FID_" WHERE FN='"_FN_"'")
	. D DBAPI^TBXSQL(SQL)
	. D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_RM)
	. d eConstrt^TBXSQL
	E  D 
	. ; Delete top level ^SCATBL(1,FN
	. I FID="SCATBL" D ZSCATBL Q
	. S ER=$$^SQL("DELETE FROM "_FID_" WHERE FN='"_FN_"'") 
	; 
	I ER=0 Q 1 
	Q "0|"_$G(RM) 
	Q
	
		
