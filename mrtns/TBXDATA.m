TBXDATA	;Private;DATA UTILITIES
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 09:29:27 - KWANL
	; ORIG:	KWANL - 05/02/02
	; DESC:	DATA UTILITIES
	;
	;-------- Comment ------------------------------------------------------
	; Before DBI, the data files contained M set-arguments, much like the
	; GT.M ZWRITE format. These files used the extension ".G". Obviously
	; this format was not suited to deliver data for an Oracle database.
	; For that reason a database independent format was implemented: a TAB
	; delimited string of values. This is basically the same format as used
	; for ResultSet Rows returned by our SQL engine.
	;
	; There are still a number of tables that are always stored in GT.M.
	; These tables are listed in STBLMTBLS. There are even some M global
	; structures that do not have a table definition.
	; In order to confine the knowledge about ".DAT" and ".G" in a single
	; place the following has been implemented:
	; - GETCODE() is called by MRPC121 based on an OBJECTID and an OBJTYPE
	;	of "Data". The function will derive whether a ".G" or ".DAT"
	;	file needs to be constructed, and has a ret-parameter that
	;	passes the filename including the extension back to the caller.
	; - CHECKOBJ(), and SAVEOBJ() are called by MRPC121 based on the
	;	extension of the LOCFILE parameter. The MRPC and all other
	;	callers are supposed to call these functions only for ".DAT"
	;	files (and call the corresponding entries in ^TBXG for ".G"
	;	files).
	; - CHECK(), LOAD(), and OBSOBJ() are called by TBXSPIN and TBXFPIN
	;	based on the extension of the file name, and will therefore only
	;	be called to process ".DAT" files.
	;
	; The functions in this module can extract an entire table, or a subset
	; of the table. The OBJECTID/FILENAME is used to code the subset. Each
	; part of the name specifies a column value as if the table as a
	; hierarchical structure based on the order of the primary key columns.
	;
	; The tilde ('~') and dash ('-') are recognized as delimiters. Their
	; order is relevant, and the behavior is not symmetric:
	;  - If the tilde is used, then the dash can be used to specify a column
	;	value.
	; - If the dash is used, then the tilde cannot be used to specify a
	;	column value.
	; Note that the underscore ('_') cannot be used as a delimiter becuase
	;	it is already used for another special purpose. In SCATBL5, it
	;	is used as the replacement character of the "^" in the RPCID.
	;
	;-------- Revision History ---------------------------------------------
	; 2008-12-22, CR 37328, Frans S.C. Witte
	;	* Corrected LOAD to initiate ER
	;
	; 2008-11-29, CR36017, Frans S.C. Witte
	;	* Major rewrite to consistently support TABLE[-KEY1[-KEY2[...]]]
	;	  names.
	;	* Moved code that deals with .G files to TBXG.
	;
	; 10/23/2008 - RussellDS - CR36293
	;	Added use of SAVECUR parameter in DAT section.  Needed due
	;	to recent changes to ^SQL.
	;
	; 01/29/08	KWANL
	;	Fixed incorrect column specified for SCATBL5A in OBSRDB.
	;
	; 01/23/08	KWANL
	;	Modified OBSRDB section to remove all records if there
	;	is no second key.
	;		
	; 01/03/08	KWANL
	;	Modified DAT section to extract SCATBL5 and SCATBL5A 
	;	to individual record if the key RPCID is provided. The
	;	naming convention for the individal record is SCATBL5-RPCID.DAT.
	;	If RPCID is in the form of method^procedureName translate the ^
	;	to _
	;	Modified the RDB section to load individual record for SCATBL5*.
	;	If RPCID contains "_" translate the "_" to "^".	
	;
	; 08/31/07	KWANL
	;		Fixed issue with values containing comma in RDB section
	;
	; 08/30/2007	KWANL
	;		Fixed issue with not resetting the COLS after calling removeNull
	;
	; 08/29/2007	KWANL
	;		Remove Null from insert instead of explicitly setting as ''
	;
	; 07/20/2007	KWANL/GIRIDHARANB
	;		Removed call to SYSVAR^SCADRV0 in OBSGBL section to prevent
	;		wrong data returned from OCI. 
	;	
	; 05/15/2007	KWANL
	;		Per Laura H. modified the RDB section to delete SCA user before
	;		installing SCATBL3 or SCATBL5A.
	;
	; 04/23/2007	KWANL
	;		Modified RDB section not to delete userclass if FID is 
	;		either SCATBL5A or SCATBL3.
	;
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
        ;	     	Removed call to FILE^DBMAP in RDB section. The ^DBTBL 
        ;		global must be defined completely for the table before
        ;		FILE^DBMAP is called
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
CHECK(FILE,RUSER,RDATE,RTIME) ; TBXSPIN/TBXFPIN
	;-----------------------------------------------------------------------
	; 
	Q 1
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID) ; MRPC121 CHECKOBJ request
	;-----------------------------------------------------------------------
	; Return a message for update or create prompt
	;
	; ARGUMENTS:
	; . req String TOK
	;	The token used to pass the data from the client to the host.
	;	Used to see if there is data at all.
	; . req String OBJECTID
	;	The name of the object being uploaded to the host.
	;	This function shall only be called if a ".DAT" file is requested 
	;
	N CNT,CONAME,END,KEYVAL,MESSAGE,QRY,RDB,RM,SQL
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S MESSAGE=$$getFilter(OBJECTID,.RDB,.QRY,.KEYVAL)
	Q:'MESSAGE 0_$C(13,10)_$P(MESSAGE,"|",2)
	;
	; Use the SQL statement
	;	SELECT COUNT(*) FROM <table><query>
	; to see if there are satisfying rows
	S SQL="SELECT COUNT(*) FROM "_KEYVAL(-1)_QRY
	I RDB S MESSAGE=$$SELECT^%DBAPI(0,SQL,$C(9),"",.CNT,.RM)
	E  D
	.	; FSCW 2008-12-02: There is a problem with SELECT COUNT(*)
	.	; if all keys are supplied. So use UCXDD to construct a global
	.	; reference that we can use with $D() and indirection.
	.	I '$D(KEYVAL(1)) S MESSAGE=$$^SQL(SQL,,,.CNT) Q
	.	N gbl,k,lvpm,td
	.	F k=1:1 Q:'$d(KEYVAL(k))  S lvpm(k_"*")="KEYVAL("_k_")"
	.	S td=$$getPslTbl^UCXDD(KEYVAL(0),0),MESSAGE=0
	.	S gbl=$$getGbl^UCXDD(td,"",.lvpm),gbl=$e(gbl,1,$l(gbl)-1)
	.	S CNT=$D(@(gbl_")")) ; at least one KEYVAL() is present
	I MESSAGE Q 0_$C(13,10)_"Unexpected error while checking data: "_$G(RM)
	;
	Q 1_$C(13,10)_$S(CNT>0:"Update Data : "_OBJECTID_" modified",1:"Create new Data")_" in "_CONAME
	;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	; Called for MRPC121 INITOBJ request.
	;
	; Extract rows from table in TAB-delimited "spreadsheet" format or GT.M
	; ZWRITE format.
	; The data selected for the extract, and the filename returned by the
	; function, depend on the supplied OBJECTID as follows:
	; - if OBJECTID in (OBJECT, DBCTL, STBL-MBAR, STBL-MTBLS, STBL-PROMPT)
	;	then $$GETCODE^TBXG(OBJECTID,.CODE,.FILENAME)
	; - else if OBJECTID is like 'SCATBL-2-%'
	;	then $$GETCODE^TBXG(OBJECTID,.CODE,.FILENAME)
	; - else based on standard filter returned by $$getFileter():
	;	select <collist> from TABLE <$$getFilter())
	;
	; Unfortunately, the .DAT format suffers from the same problem that is
	; inherent to ResultSets: a TAB in one of the columns will screw up the
	; data. The extraction deals with this as follows:
	; - In the first round, all rows are retrieved using an equivalent of
	;	SELECT * FROM table
	;	For each row returned by our SQL engine, we count the number of
	;	TAB characters. If this is equal to the number of columns, there
	;	are no embedded TABs. As soon as we find a deviation, the cursor
	;	is closed and we switch to the alternative approach
	; - The alternative approach uses SELECT colname FROM table for each
	;	individual column, in which we can replace every TAB in the
	;	returned data by a placeholder. The risk of this approach is
	;	that the contents of the table is changed during this operation.
	;	Because the data in thse kind of tables is relatively stable,
	;	this seems a reasonable approach.
	;
	; ARGUMENTS:
	; . req String OBJECTID
	;	Identification of data to be extracted. Shall NOT contain the
	;	file extension. See above for the distinction between ".G" and
	;	".DAT" and the interpretation of the pieces in OBJECTID.
	;	The delimited pieces define the tablename and one or more values
	;	for primary key columns (TABLE-KEY1-KEY2...).
	; . ret void CODE(String)
	;	data extracted from table
	;	CODE(1) = header row (column names)
	;	CODE(2++) = data, TAB-delimited
	; . ret String FILENAME
	;	OBJECTID_".G" or OBJECTID_".DAT", depending on value of OBJECTID
	;	(see above)
	;
	; NOTES:
	; . The calling MRPC121 passes an OBJECTID that lacks the extension.
	;	So unfortunaltely the decision between ".DAT" and ".G" is ard-
	;	coded here. 
	; . The algorithm used to construct the rows is highly inefficient and
	;	dangerous! It iterates over the entire table for each individual
	;	column. This is done to deal with TABs inside column values, but
	;	it has its own risks:
	;	- the assumption is that the SELECT will return the rows in
	;		the same order regardless of the column that is being
	;		selected
	;	- even if that is the case, INSERTs to the table or DELETEs from
	;		the table will cause the data to "shift".
	;
	; Get Profile version (assumes MDB, so pick 7 for RDB)
	N VN
	S VN=$G(^CUVAR("%VN"),7)
	I VN<7 Q $$GETCODE^TBXG(OBJECTID,.CODE,.FILENAME)
	I ",OBJECT,DBCTL,STBL-MBAR,STBL-MTBLS,STBL-PROMPT,"[(","_OBJECTID_",") Q $$GETCODE^TBXG(OBJECTID,.CODE,.FILENAME)
	I $P(OBJECTID,"-",1,2)="SCATBL-2" Q $$GETCODE^TBXG(OBJECTID,.CODE,.FILENAME)
	S FILENAME=OBJECTID_".DAT"
	;
	N CARD,COLS,CMP,DATA,ER,FID,KEYVAL,QRY,RDB,RM,rowdata,rownum,SELLIST,SEQ,sqlcnt,sqlstat,sqlqlf,VALS
	;
	; Decompose OBJECTID and create the filter query
	; Verify table is valid, and that there is a filter on SCATBL, SCATBL3,
	; SCATBL5, SCATBL5A or SCATBLDOC.
	S DATA=$$getFilter(OBJECTID,.RDB,.QRY,.KEYVAL)
	Q:'DATA DATA
	;
	; Extract column names and values separated by TAB delimeter in DAT.
	; Get columns into CODE(1)
	S (COLS,CODE(1),SELLIST)="",FID=KEYVAL(0)
	F  S COLS=$O(^DBTBL("SYSDEV",1,FID,9,COLS)) Q:COLS=""  D
	.	S CMP=^DBTBL("SYSDEV",1,FID,9,COLS)
	.	;
	.	; Skip literals, computed columns (except if "space"),
	.	; and masterfields
	.	I $$isLit^UCGM(COLS) Q
	.	I $P(CMP,"|",16)'="",($P(CMP,"|",16)'=" ") Q
	.	I $P(CMP,"|",17) Q
	.       S CODE(1)=CODE(1)_COLS_$C(9),SELLIST=SELLIST_$$getColumn(RDB,FID,COLS)_","
	;
	; Remove trailing TAB and trailing comma
	S CODE(1)=$E(CODE(1),1,$L(CODE(1))-1),CARD=$L(CODE(1),$C(9))
	S SELLIST=$E(SELLIST,1,$L(SELLIST)-1)
	I RDB D  ; RDB can use %DBAPI to avoid delimiter problem
	.	n curID,DLM
	.	S DLM=$P(^DBTBL("SYSDEV",1,FID,10),"|",1) ; DBTBL1.DEL
	.	S DLM=$S(DLM="":$C(124),1:$C(DLM))
	.	;
	.	; Note that $$OPENCUR^%DBAPI() returns the first row in DATA
	.	S ER=$$OPENCUR^%DBAPI(0,"SELECT "_SELLIST_" FROM "_KEYVAL(-1)_QRY,DLM,"",.curID,.DATA,.RM)
	.	Q:ER
	.	F SEQ=1:1 S CODE(SEQ)=$$row2tsv(DATA,DLM),ER=$$FETCH^%DBAPI(0,curID,1,DLM,.DATA,.RM) Q:ER
	E  D  ; MDB always uses TAB, so we may be in trouble
	.	;
	.	; First try: normal SELECT
	.	S sqlqlf("ROWS")=20,rownum=1,ER=0
	.	S sqlqlf("SAVECUR")=""
	.	D OPEN^SQL("CURSOR RESULTS AS SELECT "_SELLIST_" FROM "_FID_QRY,.sqlqlf,.sqlstat,.rowdata,.sqlcnt) I ER Q 1
	.	I sqlcnt F  Q:'$$FETCH^SQLFUNCS("RESULTS",.rownum,.DATA,.sqlstat,.rowdata,.sqlcnt)  D  Q:ER
	.	.	I $L(DATA,$C(9))>CARD S ER=1 Q
	.	.	S CODE($O(CODE(""),-1)+1)=DATA
	.	D CLOSE^SQL("RESULTS")	
	.	;
	.	; If ER=0, we are done, else we need to do it the hard and dangerous
	.	; way: extract data on a column-by-column basis ... (SEE NOTES !!!!)
	.	Q:'ER
	.	SET CMP=CODE(1) K CODE SET CODE(1)=CMP
	.	N INC
	.	F INC=1:1:CARD  D
	.	.	S SEQ=1
	.	.	I CODE(1)="" Q
	.	.	S COLS=$P(CODE(1),$C(9),INC)
	.	.	S sqlqlf("ROWS")=20,rownum=1
	.	.	S sqlqlf("SAVECUR")=""
	.	.	D OPEN^SQL("CURSOR RESULTS AS SELECT "_COLS_" FROM "_FID_QRY,.sqlqlf,.sqlstat,.rowdata,.sqlcnt) Q:ER
	.	.	I sqlcnt F  Q:'$$FETCH^SQLFUNCS("RESULTS",.rownum,.DATA,.sqlstat,.rowdata,.sqlcnt)  D	
	.	.	.	S VALS=$$cTab2Str(DATA)			; convert TAB to TAB string "_$C(9)_"
	.	.	.	S SEQ=SEQ+1
	.	.	.	I '$D(CODE(SEQ)) S CODE(SEQ)=""
	.	.	.	S CODE(SEQ)=CODE(SEQ)_VALS_$C(9)
	.	.	D CLOSE^SQL("RESULTS")	
	.	;
	.	; Remove Trailing Tabs ($C(9))
	.	F SEQ=2:1:$O(CODE(""),-1) D
	.	.	I CODE(SEQ)="" Q
	.	.	S CODE(SEQ)=$E(CODE(SEQ),1,$L(CODE(SEQ))-1)	
        Q 1
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME) ; Load a .DAT file
	;-----------------------------------------------------------------------
	; Called directly by TBXSPIN and TNBXFPIN.
	; Called by MRPC121 via SAVEOBJ()
	;
	N COL,COLS,ER,FID,KEYVAL,OK,QRY,RDB,RM,SQL
	N $ZT S $ZT=$$SETZT^%ZT("ZTL^TBXDATA")
	;
	S OK=$$getFilter($P(FILE,"."),.RDB,.QRY,.KEYVAL),FID=KEYVAL(0),ER=0
	I 'OK Q OK
        ;
	D:RDB dConstrt^TBXSQL(KEYVAL(-1))	; disable RDB table contraints
	S COLS=""
	F COL=1:1:$L(CODE(1),$C(9)) Q:COL=""  D
	.	; This is to fix the end of file
	.	I CODE(1)="" Q
	.	S COLS=COLS_$$getColumn(RDB,FID,$P(CODE(1),$C(9),COL))_","
	;
	; Remove trailing comma.
	S COLS=$E(COLS,1,$L(COLS)-1)
	;
	; If it is an initial environment, there is no data to delete.
	I '$G(initEnv) D
	.	; Delete entries except znamed items.
	.	; This also provides backward compatibilty for loading
	.	; SP where SCATBL5 and SCATBL5A are not split into
	.	; individual records.
	.	S SQL="DELETE FROM "_KEYVAL(-1)_QRY
	.	I RDB D
	.	.	D DBAPI^TBXSQL(SQL)
	.	.	D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(RM))
	.	E  D
	.	.	; Delete top level ^SCATBL(1,FN
	.	.	I FID="SCATBL" D ZSCATBL($G(KEYVAL(1))) Q
	.	.	S OK=$$^SQL(SQL,"/NOCASDEL")
	.	.	D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(RM))
	;
	; Allocate new run-time record object
	N nCols,nVals,rec,SEQ
	I 'RDB S rec=$$new^DBSDYNRA(FID)
	;
	; Load new data
	S SEQ=1
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	.	; This is to fix the end of file
	.	I CODE(SEQ)="" Q
	.	;; save the current COLS and VALS
	.	I RDB D
	.	.	S nCols=COLS,nVals=CODE(SEQ)
	.	.	D removeNull(.nCols,.nVals)	; strip NULL values
	.	.	D DBAPI^TBXSQL("INSERT INTO "_KEYVAL(-1)_" COLUMNS ("_nCols_") VALUES ("_nVals_")")
	.	.	D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_RM)
	.	E  D
	.	.	; code to load .DAT into MDB table:
	.	.	; call propSet for each Column of the record
	.	.	; This code re-uses the same Record object for each
	.	.	; insert. It relies on the fact that every column will
	.	.	; be overwritten!
	.	.	f COL=1:1:$L(COLS,",") d propSet^DBSDYNRA(rec,$P(COLS,",",COL),$$cStr2Tab($P(CODE(SEQ),$C(9),COL)),0)
	.	.	;
	.	.	; (bypass) save the record.
	.	.	; This may fail if the environment uses AccessRights:
	.	.	; - if the table is new, there will be no filer to return
	.	.	;	the access rights to chack for, and the default
	.	.	;	amounts to "check all".
	.	.	; - if this is an exisitng table, the current user may
	.	.	;	not have access to the table
	.	.	D bypassSave^DBSDYNRA(rec)
	.	.	D:ER logmsg^TBXDQUTL("SQL ERROR: "_RM)
	;
	; clean up vobj()
	I 'RDB D dispose^DBSDYNRA(rec)
	;
	I RDB,RTYPE=3 D eConstrt^TBXSQL	; enable table constraints if it is via mrpc
	I (RTYPE=1)!(RTYPE=2) D
	.	I $D(^TMPDQS($J,"phase1","data",FILE)) S ^TMPDQS($J,"phase1")=1
	.	I $D(^TMPDQS($J,"phase2","data",FILE)) S ^TMPDQS($J,"phase2")=1
	I ER Q "0|Data file failed to load: "_$G(RM)
	Q 1
	;
	;-----------------------------------------------------------------------
OBSOBJ(FILE) ; Obsolete data object
	;-----------------------------------------------------------------------
	; Called by TBXSPIN and TBXFPIN to obsolete data that used to be
	; distributed via a ".DAT" file.
	;
	; This function will "obsolete" a subset of the data of a table or the
	; entire contents by supplying a SQL DELETE statement.
	; The actual DELETE statement depends on the filter.
	;
	N KEYVAL,OK,QRY,RDB
	S OK=$$getFilter($P(FILE,"."),.RDB,.QRY,.KEYVAL)
	I 'OK Q OK
	S SQL="DELETE FROM "_KEYVAL(-1)_QRY
	;
	I RDB D
	.	D dConstrt^TBXSQL(KEYVAL(-1))	; disable contraints for this table
	.	D DBAPI^TBXSQL(SQL)
	.	D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_RM)
	.	D eConstrt^TBXSQL		; enable all contraints
	E  D
	.	; Delete top level ^SCATBL(1,FN
	.	I KEYVAL(0)="SCATBL" D ZSCATBL($G(KEYVAL(1))) Q
	.	S ER=$$^SQL(SQL)	; FSCW 2008-11-27: $$LOAD uses /NOCASDEL !!
	.	D:ER logmsg^TBXDQUTL("SQL ERROR: "_RM)
	;
	I ER Q "0|"_$G(RM)
	Q 1
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER) ; MRPC121 SAVEOBJ request
	;-----------------------------------------------------------------------
	; Save data sent by client.
	; TBXDQSVR will call this only for .DAT files.
	; Copies the data from ^TMP(TOK) into a local array and calls $$LOAD().
	;
	; ARGUMENTS:
	; . req String TOK
	;	token that points to the ^TMP() subtree that contains the data
	; . req String OBJECTID
	;	identification of table or subset of table.
	; . req String USER
	;	The name of the user performing the save.
	;
	; Copy into local and delete buffer
	N CODE
	M CODE=^TMP(TOK)
	K ^TMP(TOK)
	;
	Q $$LOAD(.CODE,OBJECTID,3,USER,+$H,$P($H,",",2))
	;
	;=======================================================================
	; Local support methods.
	;
	; All methods below are private, and shall not be called by other
	; routines.
	;
	;-----------------------------------------------------------------------
getColumn(RDB,TBL,COL) ; String(Boolean,String,String); translate column name
	;-----------------------------------------------------------------------
	; Support function to translate DQ column name to column name in the
	; internal schema.
	;
	D:RDB MAP^DBMAP(%DB,TBL,.COL)
	Q COL
	;-----------------------------------------------------------------------
getFilter(OBJECTID,RDB,QRY,KEYVAL) ; String(String,Boolean,String,void(String)); decompose OBJECTID
	;-----------------------------------------------------------------------
	; This subroutine decomposes the OBJECTID to create a filter on the data
	; to be loaded or extracted.
	;
	; ARGUMENTS:
	; . req String OBJECTID
	;	Name of file. Encodes the table name and possibly one or more
	;	primary key values, delimited by '-' or '~'.
	; . req ret String QRY
	;	where-clause to apply to table in internal schema format
	; 	- if no key values are supplied: ""
	;	- else "where <keycol1>=KEY1 and <keycol2>=KEY2 ..."
	; . req ret void KEYVAL(String)
	;	table names and primary key values
	;	KEYVAL(-1) = table name (internal schema)
	;	KEYVAL(0)  = table name (DQ)
	;	KEYVAL(1)  = value of first primary key
	;	etc.
	;
	; OUTPUTS:
	; . $$ = 1 (decomposition successful) or 0|cause (error)
	;	The following causes may be reported:
	;	- Table does not exist
	;	- Table requires a filter (for tables SCATBL, SCATBL3, SCATBL5,
	;		SCATBL5A, and SCATBLDOC)
	;	- Wide table not supported (e.g. DEP, DEPSEG, LN, LNSEG)
	; . %DB
	;	database name (ORACLE, GTM), initialized due to call to
	;	$$rtIsRdb^UCXDD()
	;
	; NOTES:
	; . The following OBJECTIDs are treated specially (they have additional
	;	hard-coded filters):
	;	SCATBL3-xxx	where FN='xxx' and UCLS='SCA'
	;	SCATBL5A-xxx	where RPCID='xxx' and UCLS='SCA'
	;	SCATBL5-x_y	where RPCID='x^y'
	;	SCATBL5A-x_y	where RPCID='x^y' and UCLS='SCA'
	; . Adding UCLS to the query can be removed if all FIS supplied .DAT
	;	files would follow the naming convention (SCATBLn-xxx-SCA).
	;
	N d,k,td,TBL
	F d="~","-" Q:OBJECTID[d				; find delimiter
	F k=1:1:$L(OBJECTID,d) S KEYVAL(k-1)=$P(OBJECTID,d,k)	; decompose
	S TBL=KEYVAL(0),QRY="",RDB=0
	Q:'$D(^DBTBL("SYSDEV",1,TBL)) "0|Table "_TBL_" does not exist"
	;
	S td=$$getPslTbl^UCXDD(TBL,0)
	S RDB=$$mpPslTbl^UCXDD(td,"isRdb")
	S KEYVAL(-1)=$$mpPslTbl^UCXDD(td,"internalNames")
	Q:KEYVAL(-1)["," "0|Wide table "_TBL_" not supported"
	;
	I k>1 D		; construct where-clause filter
	.	N pk
	.	S pk=$$mpPslTbl^UCXDD(td,"primaryKeys")
	.	;
	.	; translate x_y to x^y for SCATBL5 and SCATBL5A
	.	I ",SCATBL5,SCATBL5A,"[(","_TBL_",") S KEYVAL(1)=$TR(KEYVAL(1),"_","^")
	.	S QRY=" WHERE "_$$getColumn(RDB,TBL,$P(pk,","))_"="_$$QADD^%ZS(KEYVAL(1),"'")
	.	F k=2:1:$O(KEYVAL(""),-1) S QRY=QRY_" AND "_$$getColumn(RDB,TBL,$P(pk,",",k))_"="_$$QADD^%ZS(KEYVAL(k),"'")
	;
	; The following tables MUST specify a filter
	I QRY="","SCATBL,SCATBL3,SCATBL5,SCATBL5A,SCATBLDOC,"[(","_TBL_",") Q:"0|Table "_TBL_" requires filter"
	;
	; - SCATBL3 and SCATBL5A:
	;	limit to UCLS = 'SCA' if not explicitly specified
	I TBL="SCATBL3"!(TBL="SCATBL5A"),'$D(KEYVAL(2)) S QRY=QRY_" AND "_$$getColumn(RDB,TBL,"UCLS")_"='SCA'"
	Q 1
	;
	;-----------------------------------------------------------------------
row2tsv(data,dlm) ; String(String,String); translate row
	;-----------------------------------------------------------------------
	; Support function to translate RDB row data into TAB delimited string
	;
	Q:data'[$C(9) $TR(data,dlm,$C(9))
	Q:dlm=$C(9) data
	Q $TR($$cTab2Str(data),dlm,$C(9))
	;
	;----------------------------------------------------------------------
ZSCATBL(FN)	; Delete top level ^SCATBL(1,FN
	;----------------------------------------------------------------------
	; NOTES:
	; . This is a very strange and dangerous function in this context. It
	;	kills M Global entries even though it deals with a .DAT file.
	;
	I FN'="" ZWI ^SCATBL(1,FN) Q
	F  S FN=$O(^SCATBL(1,FN)) Q:FN=""  I $E(FN)'="Z" ZWI ^SCATBL(1,FN)
	Q
	;
	;----------------------------------------------------------------------
ZTL	; Error trap for load 
        ;----------------------------------------------------------------------
        ;
	S RM=$ZSTATUS
	S:RM["%GTM-E-SETECODE" RM=$ZERROR
	S ER=1
        Q "0|"_RM
        ;
        ;-----------------------------------------------------------------------
ADDQ(STR) ; Double the single quote to prevent string being truncated when inserting
	; to Oracle.
	;-----------------------------------------------------------------------
	;
	Q:$F(STR,"'")=0 STR
	N TMPSTR,INC
	S TMPSTR=""
	F INC=1:1:$L(STR,"'") S TMPSTR=TMPSTR_$P(STR,"'",INC)_"''"
	Q $E(TMPSTR,1,$L(TMPSTR)-2)
	;
	;-----------------------------------------------------------------------
cTab2Str(str) ; Convert TAB ascii value to TAB string.
	;-----------------------------------------------------------------------
	; ie from $C(9) to "_$C(9)_". This is to fix the issue with SCATBLDOC
	; (and other tables) where the column value contains TABs.
	;
	n inc,tmpstr
	i str'[$C(9) Q str
	s tmpstr=""
	f inc=1:1:$L(str,$c(9)) s tmpstr=tmpstr_$P(str,$C(9),inc)_"_$C(9)_"
	Q $E(tmpstr,1,$L(tmpstr)-7)
	;
	;---------------------------------------------------------------------
cStr2Tab(str) ; Convert TAB string back to TAB. ie from "_$C(9)_" to $C(9)
	;---------------------------------------------------------------------
	;
	i str'["_$C(9)_" Q str
	n inc,tmpstr
	s tmpstr=""
	f inc=1:1:$L(str,"_$C(9)_") s tmpstr=tmpstr_$P(str,"_$C(9)_",inc)_$C(9)
	Q $E(tmpstr,1,$L(tmpstr)-1)
	;
	;----------------------------------------------------------------------
removeNull(COLS,VALS) ; remove null value from insert 
	;----------------------------------------------------------------------
	;
	N index,len,nVal,nCol,val
	S len=$L(COLS,","),(nVal,nCol)=""
	F index=1:1:len D
	.	S val=$P(VALS,$C(9),index)
	.	I val="" Q
	.	S nVal=nVal_"'"_$$ADDQ($$cStr2Tab(val))_"',"
	.	S nCol=nCol_$P(COLS,",",index)_","
	S nVal=$E(nVal,1,$L(nVal)-1)
	S nCol=$E(nCol,1,$L(nCol)-1)
	S VALS=nVal,COLS=nCol
	Q