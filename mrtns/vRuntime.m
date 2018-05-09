	;=%UserName;=%FileMod; M run-time code for PSL class Runtime
	; Copyright(c)2007 Fidelity National Information Services, Inc.  All Rights Reserved
	;
	; ORIG: Frans S.C. Witte - 2007-12-04
	; DESC: M run-time code for PSL class Runtime
	;
	; I18N=QUIT
	;
	;---- Comments ---------------------------------------------------------
	; This routine contains the GT.M runtime code for the PSL class Runtime
	; that cannot be generated as inline M code. Most methods deal with the
	; RDB interface.
	;
	;
	;---- Revision History -------------------------------------------------
	; 2008-11-06, Frans S.C. Witte, CRs 35741/36391/?
	;	* Modified garbageCollect() to ignore exceptions from close
	;	  cursor.
	;
	; 2008-10-20, Frans S.C. Witte, CRs 35741/35918/35922
	;	* Added garbageCollect() to close out-of-scope cursors.
	;	* Modified startInline() and restartInline() to be used for both
	;	  Runtime.start() and Record.save().
	;	* Modified commit() and commitInline() to do an RDB commit before
	;	  an ISO-M TCOMMIT.
	;
	; 2007-12-04 - Frans S.C. Witte - CR: 30811
	;	Original routine contains methods commit(), commitF(),
	;	database(), delayCmt(), isRdb(), rollback(), start(), and
	;	throw().
	;
	;---- Properties -------------------------------------------------------
	; The following ISO-M unscoped variables are considered properties of
	; the vRuntime class:
	;
	; #PROPERTY %DB /class=String/private/static
	;	This variable contains the name of the underlying database
	;	system. One call to vRuntime.database() will garantee that the
	;	property is correctly assigned.
	;
	; #PROPERTY NONRDBNAME = "GTM" /class=String/private/literal
	;	This literal defines the name of the MDB implementation of PSL.
	;	Note that this implies that there can only be one non-rdb data-
	;	store.
	;
	; #PROPERTYDEF vRunCmCt /class=Number/private/static
	;	This variable contains the number of delayed commits (i.e. the
	;	number of Runtime.commits() at transaction level zero that have
	;	not yet been committed to the RDB.
	;
	; #PROPERTYDEF vRunDlay /class=Boolean/private/static
	;	This variable indicates if commits shall be delayed (true) or
	;	not (false)
	;
	; #PROPERTYDEF vRunSvPt /class=Boolean/private/static
	;	This variable indicates if there are delayed commits at all:
	;	true indicates there are delayed commits, false indicates that
	;	there are no delayed commits.
	;	The property is used to decide if a Runtime.rollback() on an RDB
	;	can do ROLLBACK (vRunSvPt = false) or needs to do ROLLBACK TO
	;	save_point_0.
	;
	;-----------------------------------------------------------------------
byte(vB) ; public static ByteString(Number); return a single octet ByteString
	;-----------------------------------------------------------------------
	; This function can be used as the runtime implementation of the method
	; Number.byte(). It returns $CHAR(vB) or $ZCHAR(vB) based on the actual
	; value of $$charsetName().
	;
	; PSL source code shall use Number.byte() instead of $$byte^vRuntime().
	; This function shall only be called by framework modules that need a
	; byte value before the compiler bootstrap has completed.
	;
	; NOTES:
	; . The runtime reference to $ZCHAR is hidden in M indirection to
	;	prevent %GTM-E- messages when the routine is ZLINKed in an
	;	environment based on GT.M V5.1 or below.
	; . The code generated for Number.byteString() will probably not call
	;	this method, because the compiler can insert either "$CHAR" or
	;	"$ZCHAR" as appropriate.
	;
	QUIT:$$charsetName="M" $CHAR(vB) QUIT @"$ZCHAR(vB)"
	;
	;-----------------------------------------------------------------------
charsetName() ; public static String(); return the characterset name
	;-----------------------------------------------------------------------
	; This function returns the value "M" if the GT.M version is less than
	; 5.2, else it returns $ZCHSET.
	;
	; PSL source code shall use the Runtime.charsetName property instead of
	; $$charsetName^vRuntime().
	;
	; NOTES:
	; . The runtime reference to $ZCHSET is hidden in M indirection to
	;	prevent %GTM-E- messages when the routine is ZLINKed in an
	;	environment based on GT.M V5.1 or below.
	; . The code generated for Runtime.charsetName() will probably not call
	;	this method, because the compiler can insert the correct literal
	;	at compile-time.
	;
	QUIT:$PIECE($ZVERSION,"GT.M V",2)<5.2 "M"  QUIT @"$ZCHSET"
	;
	;-----------------------------------------------------------------------
commit(vCmtMax) ; public static void(Number); Commit or delayed commit
	;-----------------------------------------------------------------------
	; Commit a transaction using the supplied commit count.
	; If commiting a "BA" transaction, vCmtMax shall be the maximum number
	; of delayed commits. If committing a "CS" transaction, vCmtMax shall be
	; zero.
	; If this.vRunCmCt is less than vCmtMax, this.vRunCmCt will be
	; incremented, this.vRunSvPt will be set to indicate that there are
	; pending commits, and the Orcale zero-level savepoint will be advanced
	; to the current location.
	; If this.vRunCmCt is equal to or greater than vCmtMax, an Oracle commit
	; will be performed, and this.vRunCmCt and this.vRunSvPt will both be
	; reset to zero.
	;
	; The ISO-M TCOMMIT will follow the code that does the RDB commit. Thus
	; the API can issue an ISO-M TRESTART if the RDB returns a potentially
	; recoverable error.
	;
	; ARGUMENTS:
	; . Number vCmtMax
	;	The maximum number of delayed commits or zero if committing a
	;	"CS" transaction.
	;
	SET:$GET(%DB)="" %DB=$$database()
	IF %DB'="GTM",$TLEVEL=1 DO
	.	;
	.	; RDB part:
	.	; If maximum not yet reached, increment count and advance the zero-level
	.	; savepoint.
	.	IF $GET(vRunCmCt)<vCmtMax NEW vIgn SET vRunCmCt=$GET(vRunCmCt)+1,vRunSvPt=1,vIgn=$$EXECUTESQL^%DBAPI(0,"SAVEPOINT save_point_0","|","") QUIT
	.	;
	.	; commit count reached (or CS commit): reset counter and indicator, and
	.	; tell the RDB.
	.	SET (vRunCmCt,vRunSvPt)=0 IF $$COMMITTRAN^%DBAPI(0)
	;
	; Common part:
	TCOMMIT:$TLEVEL
	QUIT
	;
	;-----------------------------------------------------------------------
commitF(this) ; public void(); Final commit at DO-level
	;-----------------------------------------------------------------------
	; If the call occurs when there are no uncommitted transactions, one or
	; more delayed transactions, and delayed commits no longer in effect,
	; then this method commits the delayed transactions to the RDB.
	; Else it is a no-op.
	;
	; ARGUMENTS:
	; . this = "this" pointer of Runtime class
	;	The value is inserted by UCGM (see UCRUNTIM.m), and is ignored
	;	here.
	;
	IF $TLEVEL=0,$GET(vRunCmCt),'$GET(vRunDlay) DO commit(0)
	QUIT
	;
	;-----------------------------------------------------------------------
commitInline(vCmtMax) ; static String(String); Return the in-line code to commit
	;-----------------------------------------------------------------------
	; This function returns the in-line M code for the PSL Runtime.commit()
	; method for both MDB and RDB.
	; The ISO-M TCOMMIT will follow the code that does the RDB commit. Thus
	; the API can issue an ISO-M TRESTART if the RDB returns a potentially
	; recoverable error.
	;
	; ARGUMENTS:
	; . String vCmtMax
	;	The string to insert in the code as the maximum number of
	;	(delayed) commits.
	;
	; NOTES:
	; . Unlike commit(), the code returned by this function will commit to
	;	the RDB before issuing the M TCOMMIT.
	; . Because TCOMMIT is an argumentless command, the last character of
	;	the return value is a SPACE.
	;
	NEW val
	IF $$isRdb DO
	.	IF vCmtMax=0 SET val=" S:$TL=1 (vRunCmCt,vRunSvPt)=0,vIgn=$$COMMITTRAN^%DBAPI(0)" QUIT
	.	SET val=" S:$TL=1 vRunCmCt=$G(vRunCmCt)+1,vRunSvPt=1 S:$G(vRunCmCt)>"_vCmtMax_"&($TL=1) (vRunCmCt,vRunSvPt)=0,vIgn=$$COMMITTRAN^%DBAPI(0) S:$G(vRunSvPt)&($TL=1) vIgn=$$EXECUTESQL^%DBAPI(0,""SAVEPOINT save_point_0"",""|"","""")"
	ELSE  SET val=""
	QUIT val_" TC:$TL "
	;
	;-----------------------------------------------------------------------
database() ; public static String(); return the name of the underlying database system
	;-----------------------------------------------------------------------
	; This function returns the value of %DB, forcing that public variable
	; to exist after the call.
	;
	; OUTPUTS:
	; . %DB property initialized
	;
	IF $GET(%DB)="" SET %DB=$ZTRNLNM("SCAU_DB") IF %DB="" SET %DB="GTM"
	QUIT %DB
	;
	;-----------------------------------------------------------------------
garbageCollect(vS) ; public static void(Integer); run the garbage collection
	;-----------------------------------------------------------------------
	; This method can be used to run the NLL "garbage collection".
	; It will be called by UCGMR to clean-up open RDB cursors.
	;
	; ARGUMENTS:
	; req noret Integer vS = Stack level
	;	All RDB cursors with a stacklevel greater than or equal to the
	;	supplied level will be closed (and the vobjCurs() entry will be
	;	killed by vColeRDBOpt^vResultSet()).
	;
	; NOTES:
	; . The removal of vobj() entries beyond the high-water-mark could be
	;	moved in here too.
	; . This subroutine simulates a PSL catch block that completely ignores
	;	the exception thrown by vCloseRDBOpt^vResultSet. This assumes
	;	knowledge about the implementation of PSL runtime exceptions.
	;
	NEW vCid
	SET vCid=""
	FOR  SET vCid=$ORDER(vobjCurs(vCid)) QUIT:vCid=""  DO
	.	;
	.	; Simulate a catch-block that completely ignores the exception
	.	NEW $ET,$ES,$ZYER S $ZE="",$EC="",$ET="Q:$Q&$ES """" Q:$ES  S $EC="""",$ZE="""""
	.	IF vobjCurs(vCid)'<vS DO vCloseRDBOpt^vResultSet(vCid,1)
	QUIT
	;
	;----------------------------------------------------------------------
isMdb() ; public static Boolean(); return if the underlying database system is an MDB
	;----------------------------------------------------------------------
	;
	SET:$GET(%DB)="" %DB=$$database() QUIT %DB="GTM"
	;
	;----------------------------------------------------------------------
isRdb() ; public static Boolean(); return if the underlying database system is an RDB
	;----------------------------------------------------------------------
	;
	SET:$GET(%DB)="" %DB=$$database() QUIT %DB'="GTM"
	;
	;-----------------------------------------------------------------------
restart() ; public static void(); Restart a transaction at the RDB side
	;-----------------------------------------------------------------------
	; When GT.M does a TRESTART, it rolls back the M side, but not the RDB
	; side. This subroutine will be called if the restart is detected (i.e.
	; when $TELVEL=1, and $TRESTART>0) to perform the RDB rollback.
	;
	; NOTES:
	; . restart() is the same as rollback(0) without the TROLLBACK
	;
	; If at level zero, and no pending delayed commits, do an unconditional
	; rollback, else do a rollback to save_point_0
	IF '$GET(vRunSvPt) NEW vIgn SET vIgn=$$ROLLBACK^%DBAPI(0) QUIT
	IF $$EXECUTESQL^%DBAPI(0,"ROLLBACK TO save_point_0","|","")
	QUIT
	;
	;-----------------------------------------------------------------------
restartInline(vSp) ; static String(); Return the in-line code for the RDB side of a restart
	;-----------------------------------------------------------------------
	; This function returns the in-line version of subroutine restart().
	; Like start(), the caller must prepend the ISO-M TSTART, as the code
	; returned by this function checks $TLEVEL=1&$TRESTART.
	;
	; ARGUMENTS:
	; . Boolean vSp
	;	If vSp=true, then the code returned by the function will include
	;	the code that distinguishes between ROLLBACK and ROLLBACK TO
	;	SAVEPOINT based on vRunSvPt
	;	If vSp=false, then the code returned by the function will always
	;	do a ROLLBACK.
	;	startInline() is the only caller. See that function for callers
	;	with vSp=true and callers with vSp=false.
	;
	; NOTES:
	; . The code returned by this function assigns the (empty) return value
	;	of the call to ^%DBAPI to the ISO-M lvn vIgn. It is the caller's
	;	responsibility to NEW this lvn.
	;
	IF vSp QUIT " S:$TL=1&$TR vIgn=$S('$G(vRunSvPt):$$ROLLBACK^%DBAPI(0),1:$$EXECUTESQL^%DBAPI(0,""ROLLBACK TO save_point_0"",""|"",""""))"
	QUIT " S:$TL=1&$TR vIgn=$$ROLLBACK^%DBAPI(0)"
	;
	;-----------------------------------------------------------------------
rollback(vLvl) ; public static void(Number); Rollback a transaction to a specified $TLEVEL
	;-----------------------------------------------------------------------
	; Rollback the MDB/RDB transaction to a specified "savepoint" ($TLEVEL).
	;
	; NOTES:
	; . vRuntime.rollback() and vRuntime.start() are not symmetric.
	;	The former handles both the ISO-M side and the RDB side whereas
	;	the latter only deals with the RDB side.
	;
	; ISO-M part:
	QUIT:$TLEVEL'>vLvl  TROLLBACK vLvl
	SET:$GET(%DB)="" %DB=$$database() QUIT:%DB="GTM"
	;
	; RDB part:
	; If at level zero, and no pending delayed commits, do an unconditional
	; rollback, else do a rollback to savepoint
	IF vLvl=0,'$GET(vRunSvPt) NEW vIgn SET vIgn=$$ROLLBACK^%DBAPI(0) QUIT
	IF $$EXECUTESQL^%DBAPI(0,"ROLLBACK TO save_point_"_vLvl,"|","")
	QUIT
	;
	;-----------------------------------------------------------------------
rollbackInline(vLvl) ; static String(String); return the in-line version of rollback()
	;-----------------------------------------------------------------------
	; This function returns the in-line M code that performs a PSL rollback
	;
	; ARGUMENTS:
	; . String vLvl
	;	The string to insert in the code as the rollback level.
	;
	; NOTES:
	; . The code returned by this function assigns the (empty) return value
	;	of the call to ^%DBAPI to the ISO-M lvn vIgn. It is the caller's
	;	responsibility to NEW this lvn.
	;
	NEW val
	SET val=" TRO:$TL>"_vLvl_" "_$SELECT(vLvl=0:"",1:vLvl)
	IF $$isRdb SET val=" S:$TL>"_vLvl_" vIgn=$S("_$SELECT(vLvl=0:"",1:vLvl_"=0&")_"'$G(vRunSvPt):$$ROLLBACK^%DBAPI(0),1:$$EXECUTESQL^%DBAPI(0,""ROLLBACK TO save_point_""_"_vLvl_",""|"",""""))"_val
	QUIT val
	;
	;-----------------------------------------------------------------------
start() ; public static void(); Begin an RDB transaction fence
	;-----------------------------------------------------------------------
	; As ISO-M requires $TLEVEL=0 when leaving a subroutine, the caller must
	; increment $TLEVEL. This method only performs the RDB part of the
	; Runtime.start().
	; Because this subroutine has to synchronize GT.M TRESTARTs with RDB
	; rollbacks, the call to this subroutine must be made AFTER $TLEVEL is
	; incremented in order to correctly deal with this and with other RDB
	; specific behavior such as the delayed commits and the increment of the
	; PSL Transaction Number.
	;
	; NOTES:
	; . This function only sets a savepoint if $TLEVEL is greater than 1,
	;	even if delayed commits are in effect. This is correct because
	;	the level zero savepoint will be have been created by the commit
	;	of the previous transaction.
	; . vRuntime.rollback() and vRuntime.start() are not symmetric.
	;	The former handles both the ISO-M side and the RDB side whereas
	;	the latter only deals with the RDB side.
	;
	; If $TLEVEL=1 and $TRESTART>0, we need to synchronize the GT.M restart
	; with the RDB transaction: call restart() to rollback the RDB (either
	; completely or to save_point_0).
	; Additional save-points need only be set for $TLEVEL>1.
	IF $TLEVEL=1 DO:$TRESTART restart() QUIT
	;
	; Need to create a savepoint (because of $TLEVEL).
	; Note that the application savepoints refer to the value of $TLEVEL
	; BEFORE the ISO-M TSTART, so we have to compensate here.
	IF $$EXECUTESQL^%DBAPI(0,"SAVEPOINT save_point_"_($TLEVEL-1),"|","")
	QUIT
	;
	;-----------------------------------------------------------------------
startInline(vSp) ;static String(); Return the in-line version of start()
	;-----------------------------------------------------------------------
	; This function returns the in-line version of subroutine start().
	; Like start(), the caller must prepend the ISO-M TSTART.
	;
	; ARGUMENTS:
	; . Boolean vSp
	;	This value indicates if the code returned by the function needs
	;	to include the code that sets a new savepoint to mark the start.
	;	Code generated for Runtime.start() always supplies true.
	;	Code generated for the implied Runtime.start() that preceeds a
	;	Record.save() will supply false.
	;
	; NOTES:
	; . The vSp parameter is passed to restartInline(). There it has a
	;	slightly different meaning: It suppresses the distinction
	;	between ROLLBACK and ROLLBACK TO SAVEPOINT (for delayed commit).
	;	The reasoning is that vSp=true indicates that the "start" does
	;	not participate in savepoint manipulation (even if delayed
	;	delayed commits are in effect). The assumption is that a
	;	Record.save() outside any PSL Transaction is unlikely to use
	;	or rely on delayed commits.
	; . The code returned by this function includes code to deal with
	;	savepointer, the generated code only sets a savepoint if $TLEVEL
	;	greater than 1, even if delayed commits are in effect. This is
	;	correct because the level zero savepoint will be have been
	;	created by the commit of the previous transaction.
	; . The code returned by this function assigns the (empty) return value
	;	of the call to ^%DBAPI to the ISO-M lvn vIgn. It is the caller's
	;	responsibility to NEW this lvn.
	;
	IF $$isRdb QUIT $$restartInline(vSp)_$SELECT(vSp:" S:$TL>1 vIgn=$$EXECUTESQL^%DBAPI(0,""SAVEPOINT save_point_""_($TL-1),""|"","""")",1:"")
	QUIT ""
	;
	;-----------------------------------------------------------------------
throw(vA,vI,vD,vC) ; public static void(String,String,String,String); throw %PSL-E-vI runtime exception
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; . String vA = Error.thrownAt
	; . String vI = Error.ident
	; . String vD = Error.description
	; . String vC = Error.context
	;
	SET $ZERROR="0,"_vA_",%PSL-E-"_vI_","_$TRANSLATE(vD,$CHAR(44,9,10,13),"~   ")_","_vC
	SET $ECODE=",U1001,"
	;
	; never get here ...
	QUIT