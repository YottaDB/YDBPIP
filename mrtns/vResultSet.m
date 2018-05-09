vResultSet ;=%UserName;=%FileMod; NLL M code for PSL class ResultSet
	; Copyright(c)2008 Fidelity National Information Services, Inc.  All Rights Reserved
	;
	; ORIG: Frans S.C. Witte - 2008-10-04
	; DESC: NLL M code for PSL class ResultSet
	;
	; I18N=QUIT
	;
	;---- Comments ---------------------------------------------------------
	; This routine contains the NLL GT.M code for the PSL class ResultSet.
	; It deals with both MDB and RDB ResultSets
	;
	; The NLL M ResultSet uses the following vobj() nodes (using 'rs' as
	; object id):
	; * vobj(rs) = ResultSet Row
	; * vobj(rs,0) = state indicator:
	;	0 = end-of-result (including empty) and closed
	;	1 = after one or more fetches, and before end-of-result
	;	2 = immediately after open, and before first fetch
	; * vobj(rs,-1) = "ResultSet"
	; * vobj(rs,-2) = extref of fetch function
	; * vobj(rs,-3) = SQL SELECT list
	;	Contains the select-clause of the SQL select statement. Spaces
	;	and quotes will have been removed. The representation of compound
	;	value expressions for RDB selects differs from the representation
	;	for MDB selects. Simple column names will always represented by
	;	their DQ name, regardless of the underlying DB.
	; * vobj(rs,-4) = value of vsql("D") (or its RDB equivalent)
	;	This value will be used by the Row class to construct the return
	;	value fo Row.getColumns() at runtime (e.g. for dynamic selects)
	; * vobj(rs,-5) = DB indicator
	;	This node is only created when the unit is compiled in an RDB
	;	environment, or when the Db.select() specifies the /PSLBOOT
	;	qualifier:
	;	0 = underlying tables are from MDB
	;	1 = underlying tables are from RDB
	;	2 = underlying tables are from file
	; * vobj(rs,-6) = RDB version of DQ SELECT
	;	This node is only created for an RDB ResultSet
	; * vobj(rs,-7) = M SET-argument to construct list of HOSTVAR values
	;	This node is only created for an RDB ResultSet
	; * vobj(rs,.1) = data item protection value (value of vi)
	; * vobj(rs,.1,p) = data item protection XECUTE strings (RDB only)
	;	For MDB, the code returned by the SQL engine will already
	;	contain the line of code that deals with data item protection.
	;	For RDB, this code must be executed before the result row is
	;	returned by vFetch().
	; * vobj(rs,n) (n>0) = "row pointer" variables and others variables needed
	;	to construct the cursor and access the result (the PSL equivalent
	;	of vsql()).
	; 	For RDB: vobj(rs,1) = cursor ID
	; * vobj(rs,"exe",*) = exe array for dynamic select
	; * vobj(rs,"vsql",*) = vsql array for dynamic select
	;
	; This module contains multiple closely related subroutines, that
	; contain substantial blocks of almost identical code. The performance
	; gain of specialized code is favored over the additional effort and
	; risk of maintaining redundant code.
	; The maintainers of this module shall ensure that the code in the
	; subroutine groups listed below are kept in-sync. Code reviewers shall
	; verify that this is indeed the case.
	; The following subroutine groups need to be kept in-sync:
	; - vCloseRDB, vCloseRDBOpt
	; - vFetch, vFetchDIP, vFetchMDB, vFetchRDB, vFetchRDBOpt
	; - vNewOpen, vNewOpenDIP, vNewOpenMDB, vNewOpenRDB
	;
	; The signatures of the runtime subroutines in this module shall be
	; carefully coordinated with the code generators in UCDB and UCDBR.
	;
	;---------- Revision History -------------------------------------------
	; 2008-10-20, Frans S.C. Witte, CR 35741/35918/35922
	;	Added vCloseRDB, vCloseRDBOpt and code to maintain vobjCurs().
	;
	; 2008-10-04, Frans S.C. Witte, CR 35741/35918/36013
	;	New module
	;
	;-----------------------------------------------------------------------
vCloseRDB(this) ; Close an RDB ResultSet
	;-----------------------------------------------------------------------
	; NOTES:
	; . This code can potentially be optimized to QUIT if vobjCurs() is no
	;	longer defined, because that should be a safe indication that
	;	the ResultSet has already been closed.
	; . The cursor state indicator (vobj(this,0)) cannot be used as an early
	;	quit indicator. It must be set by the caller to prevent a call
	;	to CLOSECUR^%DBAPI() for a cursor that has already been closed
	;	automatically (when end-of-result is reached). But even if the
	;	RDB cursor is already closed, we need to force the KILL of the
	;	indicator.
	; . This code must be prepared to handle this=0 (zero) when called to
	;	close the "previous resultset" when the ResultSet variable is
	;	re-assigned: D vCloseRDB^vResultSet(+$G(vRESULT))
	;
	NEW vEr,vRm
	QUIT:$GET(vobj(this,-5))'=1	; not an RDB ResultSet (or this=0)
	KILL vobjCurs(vobj(this,1))	; remove indicator
	IF vobj(this,0)'=0 SET vEr=$$CLOSECUR^%DBAPI(0,vobj(this,1),.vRm),vobj(this,0)=0 IF vEr<0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	QUIT
	;
	;-----------------------------------------------------------------------
vCloseRDBOpt(vCurID,vState) ; Close optimized RDB ResultSet
	;-----------------------------------------------------------------------
	;
	NEW vEr,vRm
	KILL vobjCurs(vCurID)	; remove indicator
	IF vState'=0 SET vEr=$$CLOSECUR^%DBAPI(0,vCurID,.vRm),vState=0 IF vEr<0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	QUIT
	;
	;-----------------------------------------------------------------------
vFetch(this) ; dynamic FETCH - all variants
	;-----------------------------------------------------------------------
	;
	; If we are already at end-of-result clear data (ie move to AfterLast)
	IF vobj(this,0)=0 SET vobj(this)="" QUIT 0	; common ALL: AfterLast
	;
	IF vobj(this,-5)=0 QUIT $$vFetchMDB(this)	; MDB ResultSet
	;
	; RDB common code
	IF vobj(this,0)=2 SET vobj(this,0)=1 QUIT 1
	;
	NEW vEr,vRm,vd,vi
	SET vEr=$$FETCH^%DBAPI(0,vobj(this,1),1,$CHAR(9),.vd,.vRm)
	IF vEr=100 SET vobj(this,0)=0 DO vCloseRDB(this) QUIT 0
	IF vEr<0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	;
	; RDB with DIP
	IF $DATA(vobj(this,.1))>1 DO
	.	NEW v0 FOR v0=1:1:$ORDER(vobj(this,.1,""),-1) XECUTE vobj(this,.1,v0)
	.	SET vobj(this,.1)=$GET(vi)
	;
	; RDB common exit
	SET vobj(this)=vd
	QUIT 1
	;
	;-----------------------------------------------------------------------
vFetchDIP(this) ; Fetch Row for RDB ResulSet with data-item protection
	;-----------------------------------------------------------------------
	; This method implements the general RDB fetch with DIP.
	; It can be called for dynamic and non-dynamic RDB ResultSets because
	; all relevant cursor-specific information is maintained by the RDB.
	; Note that it can also be called for RDB fetch without DIP at the cost
	; of one $ORDER(vobj(this,.1,""),-1) and the assignment
	; of vobj(this,.1)=$GET(vi).
	;
	IF vobj(this,0)=0 SET vobj(this)="" QUIT 0	; afterLast
	IF vobj(this,0)=2 SET vobj(this,0)=1 QUIT 1
	NEW vEr,vRm,v0,vd,vi
	SET vEr=$$FETCH^%DBAPI(0,vobj(this,1),1,$C(9),.vd,.vRm)
	IF vEr=100 SET vobj(this,0)=0 DO vCloseRDB(this) QUIT 0
	IF vEr<0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	;
	; Apply DIP
	FOR v0=1:1:$ORDER(vobj(this,.1,""),-1) XECUTE vobj(this,.1,v0)
	SET vobj(this,.1)=$GET(vi)
	;
	SET vobj(this)=vd
	QUIT 1
	;
	;-----------------------------------------------------------------------
vFetchMDB(this) ; Fetch Row for MDB dynamic ResultSet
	;-----------------------------------------------------------------------
	;
	; In addition to the formal parameters, $$SQLF needs the vsql() array
	; load exe() and vsql() from object
	IF vobj(this,0)=0 SET vobj(this)="" QUIT 0	; afterLast
	;
	NEW vd,vExe,vi,vsql
	MERGE vExe=vobj(this,"exe"),vsql=vobj(this,"vsql")
	SET vsql=$$^SQLF(.vExe,.vd,.vi,this)
	SET vobj(this)=vd
	SET vobj(this,0)=vsql
	SET vobj(this,.1)=$G(vi)
	;
	; save vsql() (we assume that exe() is static)
	KILL vobj(this,"vsql") MERGE vobj(this,"vsql")=vsql
	QUIT vsql
	;
	;-----------------------------------------------------------------------
vFetchRDB(this) ; Fetch Row for RDB ResulSet without data-item protection
	;-----------------------------------------------------------------------
	; This method implements the general RDB fetch without DIP.
	; It can be called for dynamic and non-dynamic RDB ResultSets because
	; all relevant cursor-specific information is maintained by the RDB.
	;
	IF vobj(this,0)=0 SET vobj(this)="" QUIT 0	; afterLast
	IF vobj(this,0)=2 SET vobj(this,0)=1 QUIT 1
	;
	NEW vEr,vRm,vd,vi
	SET vEr=$$FETCH^%DBAPI(0,vobj(this,1),1,$C(9),.vd,.vRm)
	IF vEr=100 SET vobj(this,0)=0 DO vCloseRDB(this) QUIT 0
	IF vEr<0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	SET vobj(this)=vd
	QUIT 1
	;
	;-----------------------------------------------------------------------
vFetchRDBOpt(vCurID,vState,vRow) ; Fetch Row from optimized RDB ResulSet
	;-----------------------------------------------------------------------
	; This method implements the general RDB fetch (without DIP) of an
	; "optimized" ResultSet. By definition this will not apply to ResultSets
	; that require DIP, because the DIP code resides in thevobj() array.
	;
	; ARGUMENTS:
	; req String vCurID
	;	The RDB cursor ID. Will be passed to FETCH^%DBAPI().
	; req ret Number vState
	;	The current state of the ReusltSet. Will be updated by this
	;	method
	; req ret Row vRow
	;	The row that was fetched. An output only parameter
	;
	IF vState=0 SET vRow="" QUIT 0		; afterlast
	IF vState=2 SET vState=1 QUIT 1
	;
	NEW vEr,vRm
	SET vEr=$$FETCH^%DBAPI(0,vCurID,1,$C(9),.vRow,.vRm)
	IF vEr=100 SET vState=0,vRow="" DO vCloseRDBOpt(vCurID,.vState) QUIT 0
	IF vEr<0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	QUIT 1
	;
	;-----------------------------------------------------------------------
vIsEmpty(this) ; ResultSet.isEmpty
	;-----------------------------------------------------------------------
	QUIT 'vobj(this,0)
	;
	;-----------------------------------------------------------------------
vNewOpen(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; dynamic OPEN CURSOR dispatcher
	;-----------------------------------------------------------------------
	; The general open distinguishes three cases: MDB, RDB with DIP, and RDB
	; without DIP. For MDB queries (dynamic or not), the DP code is included
	; in the exe() array, and will be executed automatically. However for
	; RDB queries, the DIP logic must be handled on the PSL side. This
	; includes a call to getExe^SQLPROT() to obtain the code to execute at
	; runtime, and above all it includes a FOR-loop to XECUTE these strings.
	;
	; ARGUMENTS:
	; . req String vSelect
	;	The select-clause
	; . req String vFrom
	;	The from-clause
	; . req String vWhere
	;	The where-clause (or "" if no restriction)
	; . req String vOrderby
	;	the orderby-clause (or "" if arbitrary order)
	; . req String vGroupby
	;	the groupby-clause (or "" if not applicable)
	; . req String vParlist
	;	the SQL qaulifiers ("" if none)
	; . Integer vOff
	;	The number of DO-levels that this cursor is in scope.
	;	For cursors that are opened at the same level where the variable
	;	is declared the value is one.
	;
	; NOTES:
	; . The 'vOff' parameter may need to be reconsidered. In FWK_v30 and up
	;	the code generated for Class.new() will have a formal parameter
	;	that expects the $STACK instead of an offset. That has the
	;	advantage that it can be passed unchanged to nested calls (as
	;	is needed here), and it also hides the exact meaning of the
	;	tracking value. For example $STACK will not be used in Java,
	;	but a mechanism will still be needed.
	;
	IF '$$RsRdb^UCDBRT(vFrom) QUIT $$vNewOpenMDB(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)
	IF "/"_vParlist["/PROT" QUIT $$vNewOpenDIP(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)
	QUIT $$vNewOpenRDB(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)
	;
	;-----------------------------------------------------------------------
vNewOpenDIP(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; RDB with DIP
	;-----------------------------------------------------------------------
	; Note that data-item protection may result in a modified select-clause.
	; So we need to call SQLPROT before preparing the SELECT
	;
	NEW this,vDipx
	IF ("/"_vParlist)["/PROT" NEW vQual DO PARSPAR^%ZS(vParlist,.vQual),getExe^SQLPROT(vFrom,.vSelect,.vDipx,.vQual) ;=noOpti
	;
	; create new ResultSet, prepare, and open (inc vOff, see vNewOpen)
	SET this=$$vNewOpenRDB(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)
	;
	; Apply DIP to first row and copy xecute strings into vobj(this,.1,)
	IF $DATA(vDipx) DO
	.	NEW v0,v1,vi
	.	SET v0="" FOR v1=1:1 SET v0=$ORDER(vDipx(v0)) QUIT:v0=""  SET vobj(this,.1,v1)=vDipx(v0) XECUTE vDipx(v0)
	.	SET vobj(this,.1)=$GET(vi)
	;
	; Overwrite node set by vNewOpenRDB
	SET vobj(this,-2)="$$vFetchDIP^vResultSet"
	QUIT this
	;
	;-----------------------------------------------------------------------
vNewOpenMDB(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
	;-----------------------------------------------------------------------
	; Return a new ResultSet instance for the specified query, OPEN the
	; cursor, and position the row pointer before the first row.
	;
	; NOTES:
	; . The lvns ER, mode, RM, and vsql() do not conform to PSL
	;	naming conventions, but these names are used by SQL* as public
	;	vars.
	;
	NEW ER,mode,RM,this,vsql,vExe,vExpr,vTok
	SET ER=0
	;
	SET vExpr="SELECT "_vSelect_" FROM "_vFrom
	I vWhere'="" SET vExpr=vExpr_" WHERE "_vWhere
	I vOrderby'="" SET vExpr=vExpr_" ORDER BY "_vOrderby
	I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
	;
	; Standardize on uppercase keywords and names
	S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
	;
	S this=$O(vobj(""),-1)+1
	;
	I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
	ELSE  SET vsql=$$OPEN^SQLM(.vExe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,this) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)
	IF ER DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(RM),"")
	;
	S vobj(this,0)=vsql
	S vobj(this,-1)="ResultSet"
	S vobj(this,-2)="$$vFetchMDB^vResultSet"
	S vobj(this,-3)=$$RsSelList^UCDBRT(vSelect)
	S vobj(this,-4)=$G(vsql("D"))
	S vobj(this,-5)=0
	;
	; save exe() and vsql()
	MERGE vobj(this,"exe")=vExe,vobj(this,"vsql")=vsql
	QUIT this
	;
	;-----------------------------------------------------------------------
vNewOpenRDB(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic RDB ResultSet without dataprotection
	;-----------------------------------------------------------------------
	;
	; Instantiate new object
	NEW this,vCurID,vd,vEr,vi,vList,vRm
	SET this=$O(vobj(""),-1)+1,vobj(this,-1)="ResultSet"
	;
	; Prepare the SELECT statement
	DO vPrepare(this,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)
	;
	; Open the cursor
	SET @("vList="_vobj(this,-7))
	SET vEr=$$OPENCUR^%DBAPI(0,vobj(this,-6),$CHAR(9),vList,.vCurID,.vd,.vRm)
	IF vEr<0 S vobj(this,0)=0 DO throw^vRuntime($ZPOSITION,"SQLFAIL",$GET(vRm),"")
	IF vEr=100 DO vCloseRDB(this) QUIT this
	;
	SET vobj(this)=vd
	SET vobj(this,0)=2
	SET vobj(this,1)=vCurID
	SET vobj(this,-2)="$$vFetchRDB^vResultSet"
	SET vobjCurs(vCurID)=$STACK-$GET(vOff)
	QUIT this
	;
	;-----------------------------------------------------------------------
vPrepare(this,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist) ; Prepare SELECT statement
	;-----------------------------------------------------------------------
	;
	NEW vExpr,vMap
	SET vExpr=$$RsDyRT^UCDBRT(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,.vMap)
	SET vobj(this,-7)=$$RsMsXV^UCDBRT(.vMap,.vExpr)
	SET vobj(this,-6)=vExpr
	SET vobj(this,-5)=1
	SET vobj(this,-4)=vMap("SELTYP")
	SET vobj(this,-3)=vMap("SELNAM")
	SET vobj(this,0)=0
	QUIT
	