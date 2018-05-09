SQL(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;public;SQL Interpretor
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/24/03 09:49:43 - VERTLIBA
	; ORIG:	FSANCHEZ - 12/16/94
	; DESC:	Interprets and runs SQL Expressions
	;
	; KEYWORDS:	DATABASE
	;
	;  PARAMS:
	;	. expr	SQL expression 			/TYP=T/REQ/MECH=VAL
	;	. par  Input Parameter Array		/TYP=T/MECH=REFNAM:R
	;
	;		ROWS=Fetch Array Count		/DEF=1
	;		FORMAT=Format			/TBL=[STBLTFMT]
	;
	;	.sqlsta	SQL Code			/TYPE=N/MECH=REF:W
	;	.sqldta	SQL return data			/TYPE=T/MECH=REF:W
	;	.sqlcnt	SQL record count		/TYPE=N/MECH=REF:W
	;	.sqlind	SQL column indicators		/TYPE=T/MECH=REF:W
	;
	;	Column protection indicator $C(0) Format attributes
	;          Format attributes
	;               (used by ODBC/JDBC driver to format raw data /PREPARE=3)
	;
	;             Type					Output
	;             ----					------
	;		N	Numeric without decimal		0
	;               $	Currency (2 decimal)		$
	;               N	Numeric with decimal		1-9
	;		TUBM	Text				T
	;               F       Freqnency			F
	;		D	Date				D
	;		C	Time				C
	;		L	Logical				L
	;
	;	.tok	Token string			/NOREQ
	;
	;       SQL statement:  	select cid,bal,irn,lnm,tld from dep
	;       Return attributes:	N$5TD
	;       
	; RETURNS:
	;	. $$	Error code			/TYP=T
	;
	; RELATED:
	;	. SQLI - Interactive SQL Shell
	;
	; EXAMPLE:
	;	S ER=$$SQL("SELECT CID,LNM FROM DEP WHERE BAL>100")
	;
	; LIBRARY:
	;	. SELECT - Process SELECT statement
	;
	;----------------------------------------------------------------------
	; I18N=QUIT: Exculded from I18N standards.
	;----------------------------------------------------------------------
	;---- Revision History ------------------------------------------------
	; 07/13/07 - Pete Chenard - CR 28171
	;	     Replaced calls to $E and $L with their wrapper
	;	     functions in SQLUTL where necessary to be unicode
	;	     compliant.
	;
	; 04/18/07 - RussellDS - CR26360
	;	     Modified SELECT section to fix removal of leading BY on
	;	     GROUP and ORDER to not truncate record.
	;
	;	     Throughout, changed $E expressions that used an arbitrary
	;	     length to use $L() to ensure no truncation.
	;
	; 04/06/07 - GIRIDHARANB - CR26108
	;	     Modified section ZTSQL to correct setting of Error message
	;	     and Error type (ET)
	;
	; 03/12/07 - GIRIDHARANB - CR25824
	;	     Modified CNTRL section to not add quotes.
	;
	; 02/19/07 - Pete Chenard - CR25515/25514
	;	     Added support for NOMETA parameter in OPEN section.
	;
	; 09/15/06 - Pete Chenard - 20049
	;	     Retrofit of SQL from Profile04 to keep in sunc with PSL.
	;
	; 03/28/06 - Allan Mattson - CR20048
	;            Modified subroutine ODBC1 to call $$ROWS^SQLUTL to compute
	;            the row count ($$ROWS^SQLUTL is "Unicode compliant").
	;
	;            Modified subroutine ODBC2 to call SQLDTA^SQLUTL to build
	;            'sqldta' ($$SQLDTA^SQLUTL is "Unicode compliant").
	;
	;            Modified subroutines EXECUTE, OPEN and SELECT to replace
	;            'Q 1' with 'Q'.
	;
	;            Retrofitted V6.4 changes for 1Mb string support (CR13875).
	;
	;            Retrofitted V6.4 changes to resolve %GTM-E-NOTEXTRINSIC
	;            errors (CR11361).
	;
	;            Miscellaneous changes to improve readability and
	;            conformance to standards.
	;
	;            Deleted pre-2004 revision history.
	; 03/15/06 - RussellDS - CR20159
	;	* Modified ZTFUNC to log error and return standard message;
	;	* Removed code in SELECT that stripped BY from ORDER BY - this
	;	  is handled elsewhere
	;	* Modified rollback code in RUN section to only issue call to
	;	  %DBAPI if RDB
	;
	; 01/25/06 - Pete Chenard - CR19046
	;	* Modified CNTRL section to not add quotes.  The data should be
	;	  quoted by the application.
	;
	; 08/16/05 - CHENARDP/GIRIDHARANB - CR16791
	;	* Modified sections SELECT,FETCH,ONEROW to remove rdb related code. See 
	;	  associated changes to SQLM.m.
	;
	; 07/12/05 - Pete Chenard - CR16582
	;	     Modified FILERPAR section to include VALST.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Added changes from Profile01 to move stored procedure table
	;	     from DBTBL18 to DBTBLSP.
	;
	; 09/01/04 - GIRIDHARANB - CR11003
	;	     Modifed section SELECT, FETCH and SELEF to add support for 
	;	     a relational database.
	;----------------------------------------------------------------------
	N z
	S ER=0
	;
	I $G(tok)="" S expr=$$SQL^%ZS(expr,.tok) I ER Q ER
	I $D(par)=1 D PARSPAR^%ZS(par,.par)
	;
	I $G(par("DEBUG")) S RM=$$DEBUG^SQLTESTS(expr,.par,.tok) I ER Q 1
	; 
	S z=$P(expr," ",1),expr=$E(expr,$L(z)+2,$L(expr))
	S par("_sqltype")=$S(z="OPEN":"SELECT",1:z)			; 05/06/04, FSCW, pass statement type
	;
	I z="FETCH" D FETCH(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="EXECUTE" D EXECUTE(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="SELECT" D SELECT(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="INSERT" D INSERT(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="UPDATE" D UPDATE(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="BUFFER" D ^SQLBUF(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="DELETE" D DELETE(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="OPEN" D OPEN(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="DROP" D DROP(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok) Q ER
	I z="CREATE" D ^SQLCRE(expr,.par,.sqlsta,.sqldta,.tok) Q ER
	I z="ALTER" D ALTER^SQLTBL(expr) Q ER
	I z="CLOSE" D CLOSE(expr) Q ER
	I z="DESCRIBE" D DESCRIBE^SQLODBC(expr,.sqlsta,.sqldta,.sqlcnt) Q ER
	S ER=1,RM=$$^MSG(8564,z)
	Q ER
	;
	;--------------------------------------------------------------------
EXECUTE(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;private; Parse SQL EXECUTE command
	;--------------------------------------------------------------------
	;
	; EXECUTE Procedure_Name [USING HostVar-list] | $M Function
	;
	S ER=0
	;
	I $G(par("EFD"))'="" N EFD S EFD=$G(par("EFD")) I EFD S EFD=$S(EFD=$G(TJD):"",1:$$FDAT^%ZM(EFD)) I ER Q
	;
	N USING
	S expr=$$TOK(expr,"USING",.tok)
	;
	I expr="" S ER=1,RM=$$^MSG(8568) Q
	I $E(expr)="$" G FUNC				; Call M routine  EXECUTE $$^pgm(p1,p2,...)
	;
	N rows,exe,vsql
	;
	S rows=$G(par("ROWS")) I 'rows S rows=1
	;
	D RUNSP(0,expr,.par,.USING) I ER Q  		; Execute stored procedure
	D SELEF
	I $G(par("PREPARE"))=3 D COLFMT($G(vsql("A")))	; Column format attributes
	Q
	;
	;--------------------------------------------------------------------
FUNC	;private; Execute a M function or extrinsic function
	;--------------------------------------------------------------------
	; Example: EXECUTE $$^ABC(var)
	;
	N hostvar
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr
	;
	S expr=$$UNTOK^%ZS(expr,.tok)			; Parse function
	I expr[$C(0) S expr=$$UNTOK^%ZS(expr,.tok)
	;
	N $ZT						; Set up error trap
	S @$$SET^%ZT("ZTFUNC^SQL") 		; Invalid function
	;
	D 
	.	I $L(expr)>2000 D XINDIRECT(expr) Q	; Execute Mumps routine after reducing the size of the expression
	.	X "S sqldta="_expr			; Execute MUMPS routine
	S sqlcnt=1					; Row count
	S sqlsta=100					; Status
	I $G(par("PREPARE"))=1 D  Q			; /Prepare qualifier
	.	N b1,b2,len,v,vpack
	. S v=$$CONSTANT^SQLODBC(32000,"M"),len=$L(v)	; prepare information
	.	S b1=len\255,b2=len#255			; prepare length
	.	S sqldta=$C(b1,b2)_v_sqldta		; return data
	Q
	;--------------------------------------------------------------------------------------------------------
XINDIRECT(line)	;xecute function calls that are too long for indirection by moving data into variables 
	;--------------------------------------------------------------------------------------------------------
	;
	; This label will process execute function commands that contain data>2000. Current GTM limitations
	; limit the indirect execution of routines to have a length no greater then 2K.
	; The label removes the limitation by assigning the parameters of the line into an array  and passing
	; the individual levels of the array into the function being executed.
	;
	N MRPC
	S MRPC=$P(line,"(",1)
	;
	; This functionality is expected to be required only for Remote procedure calls
	;
	I MRPC["^MRPC"!(MRPC["^ZRPC") D
	.	N i,execline,rec,parfield,tok,tokstr
	.	; tokeize the string based on double quotes
	.	S rec=$$TOKEN^%ZS(line,.tok,"""")
	.	;
	.	; Rebuild the function call line 
	.	S execline="$$"_$P($P(line,"(",1),"$$",2)_"("
	.	;
	.       ; Loop through the tokenized data and assign to the array
	.       ; and append the array and pointer to the executable line
	.	S tokstr=$P(rec,$C(0),2,999),tokstr=$P(tokstr,")",1) ;pc 3/25/02
	.	S tokstr=$TR(tokstr,$C(0),"")
	.	F i=1:1:$L(tokstr,",") do
	..		S pos=$P(tokstr,",",i)
	..		S parfield(i)=$$QSUB^%ZS($P(tok,$C(1),pos))  ;pc 3/25/02
	..		S execline=execline_"parfield("_i_"),"
	.	;
	.	; Adjust the end of the line by removing the extra , and adding the closing )
	.	S execline="S sqldta="_$E(execline,1,$L(execline)-1)_")"
	.	; Excute the new code
	.	X execline
	Q	
ZTFUNC	;
	I $P($ZS,",",3)="%PSL-E-DBFILER" D
	.	N ET
	.	S ET=$P($ZS,",",3)
	.	D ^UTLERR
	E  D ZE^UTLERR
	S ER=1
	; Host error number ~p1. Contact system manager.
	S RM=$$^MSG(1191,$G(%ZTSEQ))
	S sqldta=""
	Q
	;
	;--------------------------------------------------------------------
OPEN(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok,loc)	;public; Open a Cursor or procedure
	;--------------------------------------------------------------------
	;
	; OPEN [CURSOR] cursor_name [USING HostVar-list] AS select_statement | 
	;		PROCEDURE procedure
	N hostvar,USING
	S ER=0
	;
	I $G(par("EFD"))'="" N EFD S EFD=$G(par("EFD")) I EFD S EFD=$S(EFD=$G(TJD):"",1:$$FDAT^%ZM(EFD)) I ER Q
	; 
	I $G(%TOKEN)="" N %TOKEN S %TOKEN=$J
	;
	I $G(tok)="" S expr=$$SQL^%ZS(.expr,.tok) I ER Q
	;
	I $E(expr,1,7)="CURSOR " S expr=$E(expr,8,$L(expr))	; Noise
	;
	I '$G(loc) N exe,vsql
	N AS,command,sqlcur,vdd
	;
	S sqlcur=$$TOK(expr,"AS,USING",.tok)
	;
	I sqlcur="" S ER=1,RM=$$^MSG(8559) Q	; missing cursor name
	;
	K ^DBTMP(%TOKEN,sqlcur)			; delete old cursor information
	;
	I $G(AS)="" S ER=1,RM="AS (SELECT...) or (PROCEDURE name) Required" Q
	;
	S command=$P(AS," ",1),expr=$E(AS,$L(command)+2,$L(AS))
	;
	D
	.	I command="PROCEDURE" D RUNSP(sqlcur,expr,.par,.USING) Q
	.	I command="SELECT" D SELECT(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok,1,sqlcur) Q
	.	D ERROR("Invalid OPEN parameter "_command)
	;
	I ER Q
	S sqlsta=vsql(0) I sqlsta=100 D ODBC2 Q		; Return data
	I '$G(loc) D SAVE(sqlcur,.vsql,.exe)
	;
	I $G(par("PREPARE"))=1,$G(par("ROWS")) D ODBC2 Q  ; Combination of /PREPARE and /ROWS
	I $G(par("PREPARE"))=1 D ODBC1			; Calculate row count
	I $G(par("PREPARE"))=3 D COLFMT(vsql("A")) ; Column format attributes
	I $G(par("PREPARE"))=3,$G(par("ROWS")),command'="PROCEDURE" Q	; Data already fetched
	I '$G(par("PREPARE")),command'="PROCEDURE" Q ; OPEN cursor statement
	I '$G(par("ROWS")) Q  				; Do not return data
	;
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr
	D FETCH(sqlcur,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind)
	I $G(par("PREPARE"))=3 D COLFMT(vsql("A")) Q    ; Column format attributes 
	I $G(par("PREPARE"))=1 D ODBC2			; return data
	Q
ODBC1	;
	I $G(vsql("A"))="" Q				; No prepare information
	I '$G(par("ROWS")) set par("ROWS")=$$ROWS^SQLUTL(vsql("A"))	; Calculate row count
	I sqlcur="*" S sqlcur=$O(^SQLCUR(%TOKEN,999999),-1)+1		; Assign next cursor #
	Q
ODBC2	;
	I $G(vsql("A"))="" Q
	I $G(par("NOMETA"))=1 Q				; Don't add metadata
	I $G(par("META"))=0 Q
	I $G(par("PREPARE"))=3 D COLFMT(vsql("A")) Q		; PFW/PIA
	S sqldta=$$SQLDTA^SQLUTL(vsql("A"),sqlcur,$G(sqldta))	; ODBC/JDBC
	Q
	;
	;--------------------------------------------------------------------
FETCH(sqlcur,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;public; Fetch result row(s)
	;--------------------------------------------------------------------
	;
	; FETCH [FROM] cursor_name
	;
	;----------------------------------------------------------------------
	;
	I $G(%TOKEN)="" N %TOKEN S %TOKEN=$J
	;
	I $E(sqlcur,1,5)="FROM " S sqlcur=$E(sqlcur,6,$L(sqlcur))	; Noise
	;
	I $A(sqlcur)=0 S sqlcur=$$UNTOK^%ZS(sqlcur,.tok)
	;
	S ER=0
	;
	N exe,vsql
	;
	D RESTORE(sqlcur,.vsql,.exe) Q:ER
	D FETCHBLK^SQLF(sqlcur,.exe,.vsql,.sqldta,.sqlcnt,.sqlind,$G(par("ROWS")))
	;
	I $G(par("PREPARE"))=3 D COLFMT($$COLATT^SQLODBC("",vsql("D")))	; column format information
	;
	S sqlsta=vsql(0) I sqlsta=100 D CLOSE^SQLM(sqlcur) Q
	D SAVE(sqlcur,.vsql,.exe)
	Q
	;
	;--------------------------------------------------------------------
SAVE(name,vsql,exe)	;private; Save context into ^SQLCUR
	;--------------------------------------------------------------------
	; Saves vsql and exe arrays into ^SQLCUR(%TOKEN,object_name)
	; Maximum total array size is 32K due to GTM string limit
	; String is broken into 255 byte global strings
	;
	I '$D(vsql("K")) Q
	;
	N i,z
	;
	S z=$C(0,2,0,2)_$$PACK^SQLCACHE(.vsql,.exe)
	F i=0:1 S ^SQLCUR(%TOKEN,name,i)=$$BSE^SQLUTL(z,1,255),z=$$BSE^SQLUTL(z,256,$$BSL^SQLUTL(z)) Q:z=""
	Q
	;
	;----------------------------------------------------------------------
RESTORE(name,vsql,exe)	; Restore symbol table for server fetch
	;----------------------------------------------------------------------
	; Restore exe and vsql arrays from ^SQLCUR(%TOKEN,object_name)
	;
	N i,z,zz
	;
	S z=$G(^SQLCUR(%TOKEN,name,0))
	I z="" S ER=1,RM="Cursor "_name_" is not OPEN",sqlcnt=0,sqldta="" Q	; 04/20/2000
	F i=1:1 S zz=$G(^SQLCUR(%TOKEN,name,i)) Q:zz=""  S z=z_zz
	D UNPACK^SQLCACHE(z,.vsql,.exe)
	Q
	;
	;--------------------------------------------------------------------
SELECT(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok,mode,sqlcur)	;public; Parse SQL SELECT command and return executable code
	;--------------------------------------------------------------------
	;
	N hostvar
	S ER=0
	;
	I $D(par)=1 D PARSPAR^%ZS(par,.par) S par("_sqltype")="SELECT"
	;
	I $G(par("EFD"))'="" N EFD S EFD=$G(par("EFD")) I EFD S EFD=$S(EFD=$G(TJD):"",1:$$FDAT^%ZM(EFD)) I ER Q
	;
	I $G(sqlcur)="" S sqlcur=0
	;
	N FROM,SELECT,WHERE,ORDER,GROUP,HAVING,CACHE,rows,z
	;
	S mode=+$G(mode) 
	I mode=0 N exe,vdd,vsql
	;
	S rows=$G(par("ROWS")) I rows="" S rows='mode
	S CACHE=$G(par("CACHE")) I CACHE="" S CACHE=1
	;
	I mode=-2 S CACHE=0					; Compile mode
	; Protect host variables
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr
	;							; 
	I $G(par("SPCREATE")) D  Q				; Create stored procedure
	.	I '$G(par("ROWS")) S par("ROWS")=1		; Fetch now
	.	S RM=$$SP^SQLCACHE(.sqlcur,expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok)
	.	I ER Q						; Error on create
	.	K par("SPCREATE")				; Remove create SP flag
	.	S expr="EXECUTE "_RM				; Execute stored procedure
	.	S ER=$$^SQL(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok)
	;
	I CACHE,$$FLT^SQLCACHE(expr,.tok,.par) G SELEF
	;
	S SELECT=$$TOK(expr,"FROM,WHERE,ORDER,GROUP,HAVING",.tok)
	I $G(FROM)="" S ER=1,RM=$$^MSG(8561) Q
	I $G(GROUP)'="",$E(GROUP,1,3)="BY " S GROUP=$E(GROUP,4,$L(GROUP))
	I $G(ORDER)'="",$E(ORDER,1,3)="BY " S ORDER=$E(ORDER,4,$L(ORDER))
	;
	S vsql=$$OPEN^SQLM(.exe,.FROM,.SELECT,.WHERE,.ORDER,.GROUP,.par,tok,mode,.vdd,.sqlcur)
	I ER Q
	;
	I $G(par("PREPARE"))=3 D COLFMT(vsql("A"))		; Column format attributes
	I CACHE D SAV^SQLCACHE($$UNTOK^%ZS(expr,.tok),.par)
	I mode<0 Q
	;
SELEF	; Fetch rows
	I vsql=0 S sqlsta=100,sqlcnt=0,sqldta="" Q
	I rows=0 S sqlsta=vsql,sqlcnt=0,sqldta="" Q
	;
	D FETCHBLK^SQLF(.sqlcur,.exe,.vsql,.sqldta,.sqlcnt,.sqlind,rows)
	S sqlsta=$G(vsql(0))
	Q
	;
	;--------------------------------------------------------------------
RUNSP(sqlcur,spnam,par,using)	; Run a Stored Procedure
	;--------------------------------------------------------------------
	;
	I '$D(%LIBS) S %LIBS="SYSDEV"
	I '$D(%TOKEN) S %TOKEN=$J
	;
	I $G(sqlcur)="" S sqlcur=0
	;
	N hostvar,hostvars,rtn,z,z1
	;
	S ER=0
	;
	;format will be Snnnnnnn-56000-12351 which represents rtn name-date-time
	;
	I $P(spnam,"-",1)?1"S".N D	
	.	n datechk,timechk
	.	S datechk=$P(spnam,"-",2)		; date
	.	S timechk=$P(spnam,"-",3)		; time
	.	S spnam=$P(spnam,"-",1)			; routine
	.	I datechk="" S ER=1,RM=$$^MSG(8573,spnam),sqlsta=50001 Q
	.	S z=$G(^DBTBLSP(spnam))
	.	I $P(z,"|",6)'=datechk!($P(z,"|",7)'=timechk) S ER=1,RM=$$^MSG(8573,spnam),sqlsta=50001 Q
	I ER Q
	I $L(spnam)>20 S ER=1,RM=$$^MSG(8573,$E(spnam,1,20)) Q
	I '$D(z) S z=$G(^DBTBLSP(spnam))
	I z="" S ER=1,RM=$$^MSG(8573,spnam),sqlsta=50001 Q  ; Invalid SP name
	;
	S hostvars=$P(z,"|",2)
	I hostvars'="",$G(using)'="" N @hostvars D
	.	N i,v
	.	F i=1:1:$L(hostvars,",") D		; Assign host variables
	..		S v=$$UNTOK^%ZS($P(using,",",i),.tok)
	..		I $E(v)="'" S v=$E(v,2,$L(v)-1)	; Remove quotes
	..		S @$P(hostvars,",",i)=v
	;
RTN	; entry linetag for FLT^SQLCACHE if cache maps to a procedure
	;
	N rtn,z1
	I $G(sqlcur)="" S sqlcur=0
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr
	I $G(par("FORMAT"))'="" S vsql("F")=$$VSQLF^SQLCOL(.par)
	;
	S rtn="^"_$P(z,"|",1)				; Run-time routine name
	;						; 06/07/99 BC
	I $P(z,"|",8)'="",$P(z,"|",8)'="SELECT" D  Q				; Insert/Update/Delete stored procedure
	.	S z=rtn D EXECSP			; Execute SP
	.	S vsql=0,vsql(0)=100,vsql("A")=""	; return status
	;
	S z="OPEN"_rtn_"(sqlcur,.vsql)"			; Select stored procedure
	I $G(par("PREPARE"))=1 S z1="S vsql(""A"")=$$PREPARE"_rtn_"()"		; get ODBC/JDBC prepare information
	I $G(par("PREPARE"))=3 S z1="S vsql(""A"")=$$PREPARE3"_rtn_"()"		; get format information (PFW/PIA)
	;
	D EXECSP					; Execute SP routine
	;
	S exe=1
	S exe(1)="D FETCH"_rtn_"(.sqlcur,.vsql,.vd,.vi)"
	Q
EXECSP	;						; Handle replication logic
	N $ZT						; Set up error trap
	S @$$SET^%ZT("ZSPERR^SQL") 			; for missing routine
	D @z
	I $D(z1),$G(par("PREPARE")) X z1		; Prepare information form ODBC driver
	Q
ZSPERR	;
	;;I $ZS'["ZLINKFILE" S ER=1,RM=$$^MSG(8573,expr) Q  ; Other run-time errors
	I $ZS'["ZLINKFILE" S ER=1,RM=$ZS Q  		; Other run-time errors
	D BUILDONE^SQLCRE($P(expr,"-",1))		; Rebuild SP run-time routine 06/02/99
	D @z						; Execute it again
	Q
	;----------------------------------------------------------------------
ZTT	; Error trap on invalid USING qualifier
	;----------------------------------------------------------------------
	S ER=1,RM=$$^MSG(1430,$G(par))
	Q
	;----------------------------------------------------------------------
ZT	; Error trap on invalid routine name
	;----------------------------------------------------------------------
	D DELSP Q
	;----------------------------------------------------------------------
DELSP	; Remove bad stored procedure index files
	;----------------------------------------------------------------------
	K ^DBTBLSP(spnam)				; Delete index entry
	S sqlsta=50001					; 
	S ER=1,RM=$$^MSG(1454,rtn)			; Bad routine name
	Q
	;-------------------------------------------------------------------- 
INSERT(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;private; Parse SQL INSERT 
	;-------------------------------------------------------------------- 
	; 
	; INSERT [INTO] table_name [(column_list)] VALUES (value_list) 
	; INSERT [INTO] RECORD record_name [(column_list)] VALUES (value_list) 
	; 
	N hostvar
	I $G(ER) S sqlcnt=0 Q
	S ER=0,RM="",sqlcnt=0 
	; 
	I $G(par("EFD"))'="" N EFD S EFD=$G(par("EFD")) I EFD S EFD=$S(EFD=$G(TJD):"",1:$$FDAT^%ZM(EFD)) I ER Q 
	I $G(par("DEC"))'="" S (%MSKE,%MSKN)=par("DEC") ; Precision 
	; 
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr 
	; 
	N INTO,VALUES,X,columns,exe,fsn,i,map,table,v,values,vblob,vexe,vmemo,vsub,vdd,vsql,exe,vobj,x,z 
	; 
	S x=$$TOK(expr,"INTO,VALUES",.tok) 
	; 
	I $G(VALUES)="" D ERROR("Values Parameter Required") Q 
	I $G(INTO)="" S INTO=x I INTO="" D ERROR("Into Parameter Required") Q 
	; 
	S table=$$FUN(INTO,.columns,tok) 
	I table="" S ER=1,RM=$$^MSG(1484) Q     ; Missing table name 
	; 
	I $G(columns)="" S ER=1,RM=$$^MSG(1286) Q       ; Missing column name 
	;	
	I $G(par("CACHE"))'=0,$G(par("USING"))'="",$$FLT^SQLCACHE(expr,.tok) D  Q 
	.       I $G(ER) Q                      ; Missing host variable 
	.       I $G(exe)=1 Q 		; Stored procedure
	.	D RUN(.exe)
	.	I '$G(ER) S sqlcnt=1
	;
	D CACHE("INSERT",.vexe)			; Run-time M code
	I $G(ER) Q 			; Compile error
	D RUN(.vexe)                            ; Insert record 
	I ER Q 				; Runtime error
	D SAVCACHE("INSERT",.vexe)  	; Save M code in cache table
	S sqlcnt=1				; Record count
	Q 
	; 
	;-------------------------------------------------------------------- 
UPDATE(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;private; Parse SQL UPDATE 
	;-------------------------------------------------------------------- 
	; 
	; UPDATE table_name SET column_name = expression [,column_name = 
	;        expression]... [WHERE search_condition] 
	; 
	N hostvar
	I $G(ER) S sqlcnt=0 Q
	S ER=0,RM="",sqlcnt=0 
	; 
	;1/10/00 mas create array to assure that set of par(Format) does not lose parameters
	I $D(par)=1 D PARSPAR^%ZS(par,.par)					
	S par("FORMAT")="" 
	I $G(par("EFD"))'="" N EFD S EFD=$G(par("EFD")) I EFD S EFD=$S(EFD=$G(TJD):"",1:$$FDAT^%ZM(EFD)) I ER Q 
	I $G(par("DEC"))'="" S (%MSKE,%MSKN)=par("DEC") 
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr 
	; 
	N I,SET,VALUES,VKEY1,VKEY2,VKEY3,VKEY4,VKEY5,VKEY6,VKEY7,VKEY8,VKEY9,VKEY10,WHERE 
	N col,exprcol,exe,fsn,i,inscols,insexpr 
	N keys,map,ptr,qrycols,table,v,v1,val,values,vc,vcurval,vexe,vmemo,vobj,vsql,vsub,x,z,zexpr 
	; 
	I $G(tok)="" S expr=$$SQL^%ZS(expr,.tok) I ER Q 	; If called into UPDATE directly
	;
	I $G(par("CACHE"))'=0,$G(par("USING"))'="",$$FLT^SQLCACHE(expr,.tok) D  Q 
	.	I $G(ER) Q					; Missing host variable
	.	I $G(exe)=1 Q					; Stored procedure
	.	D CHG1ROW("UPDATE",1)				; Update single row?
	;
	S table=$$RET($$TOK(expr,"SET,WHERE",.tok),.tok) ; parse SET and WHERE keywords
	I $G(SET)="" S sqlcnt=0,ER=1,RM=$$^MSG(8564) Q          ; Nothing to update 
	; 
	I table["""" S table=$$QSUB^%ZS(table)           ; Remove quotes from table name
	;
	I $G(WHERE)'="",$$ONEROW(table,WHERE) D CHG1ROW("UPDATE") Q		; Update single row
	;
	D fsn^SQLDD(.fsn,table) I ER Q 
	; 09/27/99 
	S qrycols="",keys=$P(fsn(table),"|",3) I keys'="" S qrycols=$$STRDD(keys,table,.tok) 
	S inscols=keys 
	;                                       ; S value(1)=$p(v,tab,1),value(2)=.... 
	S insexpr="" F i=1:1:$L(inscols,",") D 
	.       S insexpr=insexpr_",VKEY"_i_"=$P(v,$C(9),"_i_")" 
	S insexpr="S "_$E(insexpr,2,$L(insexpr)) 
	; 
	F I=1:1:$L(SET,",") D  Q:ER 
	.       S x=$$POP^%ZS($P(SET,",",I)) 
	.       S col=$$RET($P(x,"=",1),.tok) 
	.       S col=$$TRIM^%ZS(col)                   ; column name 
	.       I col["." S col=$P(col,".",2)		;
	.       I inscols="" S inscols=col              ; *** 09/27/99 
	.       E  S inscols=inscols_","_col            ; Column list 
	.       S val=$P(x,"=",2,999) 
	.       S val=$$TRIM^%ZS(val)
	.       S ptr=0 
	.       I $E(val)=":" D  I $G(ER) Q 
	..		I '$D(@$E(val,2,$L(val))) S ER=1,RM=$$^MSG(8592,val) Q
	..		S exprcol=@$E(val,2,$L(val))   ; Remove : from host variable name
	.       E  S exprcol=$$NATOM(val,.ptr,.qrycols,.tok,table) 
	.       ; 
	; 
	; Remove quotes from column names 
	S inscols=$TR(inscols,$C(34),"") 
	; 
	S zexpr=keys_" FROM "_table 
	I $D(WHERE) S zexpr=zexpr_" WHERE "_WHERE 
	; 
	D  I ER Q 							; In cache table?
	.       I $G(par("USING"))'="",$$FLT^SQLCACHE(zexpr,.tok,.par) Q ; Get the M code
	.       S vsql=$$OPEN^SQLM(.exe,table,qrycols,.WHERE,,,.par,tok) I ER Q 
	.       I $G(par("USING"))'="" S par("_sqltype")="SELECT" D SAV^SQLCACHE(zexpr,.par) S par("_sqltype")="UPDATE"
	S sqlcnt=0 
	; 
	S v="" I keys'="" F i=1:1:$L(keys,",") S v=v_" AND "_$P(keys,",",i)_"=:VKEY"_i 
	I v'="" S expr=$P(expr," WHERE ",1)_" WHERE "_$E(v,6,$L(v)) 
	; 
	D CACHE("UPDATE",.vexe)			; Generate run-time M code
	;
	I $G(ER) Q 
	; 
	F sqlcnt=0:1 S vsql=$$^SQLF(.exe,.v) Q:vsql=0  D  I ER Q 
	.       ; 
	.       I keys'="" X insexpr          ; Define access keys
	.       D RUN(.vexe) Q 
	; 
	S sqlsta=0 
	D SAVCACHE("UPDATE",.vexe) 	 	; Save M code in cache table
	Q 
	;----------------------------------------------------------------------
CHG1ROW(exprtyp,cacheflg)	; Single row update/delete 
	;----------------------------------------------------------------------
	I '$G(cacheflg) D  I $G(ER) Q		; Compile SQL statement
	.	I $D(par)=1 D PARSPAR^%ZS(par,.par)	; convert par string to par array
	.	S expr=expr_$C(9)_$$FILERPAR(.par)	; run-time parameters
	.	I exprtyp="UPDATE" D UPDATE^SQLCMP(expr,1,.exe,1,1) Q ; Compile run-time code
	.	D DELETE^SQLCMP(expr,1,.exe,1) Q ; Compile run-time code
	;
	K sqlcnt
	S sqlcnt=1                              ; *** EWS ***
	D RUN(.exe) 			; Update/delete single record
	; 
	S sqlsta=0 
	I $G(ER) S sqlcnt=0 Q			; Record count
	S sqlcnt=+$G(sqlcnt)
	I $G(cacheflg) Q			; Already cached
	D SAVCACHE(exprtyp,.exe) 	; Save M code in cache table
	Q 
	;----------------------------------------------------------------------
CACHE(opt,exe)	; 
	;----------------------------------------------------------------------
	N mode,vsql
	S mode=-1					; Fetch M code only (don't execute)
	K exe
	; M code from cache table if available
	; Parse it
	S expr=expr_$C(9)_$$FILERPAR(.par)		; Run-time qualifiers
	I opt="INSERT" D INSERT^SQLCMP(expr,1,.exe,1) Q ; Compile run-time code
	I opt="UPDATE" D UPDATE^SQLCMP(expr,1,.exe,1) Q ; Compile run-time code
	I opt="DELETE" D DELETE^SQLCMP(expr,1,.exe,1) Q ; Compile run-time code
	Q
	;----------------------------------------------------------------------
RUN(vexe)	; Execute SQL INSERT/UPDATE/DELETE statement 
	;----------------------------------------------------------------------
	; 
	I $G(ER) Q					;5/12/2000 mas do not reset ER if one has occurred
	K RM
	TStart *                                        ; Start TP 
	N $ZT 		                        ;
	S @$$SET^%ZT("ZTSQL^SQL")                       ; Define error trap 
	; 
	; vexe(n)	- M run-time procedure code
	;		- rely on first entry for New list
	N vvz,v,vfsn 
	S ER=0
	S v=$O(vexe("")) I v,$E(vexe(v),1,3)=" N " N @$E(vexe(v),4,$L(vexe(v)))	; New variables,short name
	;
	S vvz="" F  S vvz=$O(vexe(vvz)) Q:vvz=""  X vexe(vvz) Q:$G(ER) 
	;
	I '$Tlevel Q 				; Not under TP
	I $G(ER) D  Q 
	.	Trollback
	.	I $$rdb^UCDBRT() D
	..		S vER=$$EXECUTE^%DBAPI("","ROLLBACK WORK",$C(124),"",.vRM)
	..		I vER S ER=vER,RM=vRM_"|"_RM	; Rollback transaction
	; Only commit if at outermost fence
	I $$rdb^UCDBRT(),$TLevel=1 S ER=$$COMMIT^%DBAPI()	; Commit transaction
	TCommit 
	Q 
ZTSQL	; 
	D ZE^UTLERR 				; Log error
	I '$D(RM) S ET=$$ETLOC^%ZT 
	Q 
	; 
	;-------------------------------------------------------------------- 
DELETE(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;private; Parse SQL DELETE 
	;-------------------------------------------------------------------- 
	; 
	; DELETE [FROM] table_name [WHERE search_condition] 
	N hostvar
	; 
	I $G(ER) S sqlcnt=0 Q
	S ER=0,RM="",sqlcnt=0 
	; 
	N FROM,WHERE,VKEY1,VKEY2,VKEY3,VKEY4,VKEY5,VKEY6,VKEY7,X 
	N delexpr,exe,fsn,i,keys,map,mode,qrykeys,table,v,vdd,vexe,vexpr,vsql,z,zexpr 
	; 
	I $G(tok)="" S expr=$$SQL^%ZS(expr,.tok) I ER Q		; If called by P/A routines directly
	;
	; 05/06/04, FSCW: commented out (to obtain symmetry with UPDATE)
	;S mode=-1
	;
	I $G(par("EFD"))'="" N EFD S EFD=$G(par("EFD")) I EFD S EFD=$S(EFD=$G(TJD):"",1:$$FDAT^%ZM(EFD)) I ER Q 
	; 
	I $G(par("USING"))'="" N new,setexpr D USING(par("USING"),.new,.setexpr,.hostvar) Q:ER  N @new X setexpr 
	; 
	I $G(par("CACHE"))'=0,$G(par("USING"))'="",$$FLT^SQLCACHE(expr,.tok) D  Q 
	.	I $G(ER) Q
	.	I $g(exe)=1 Q				; Stored procedure
	.	D CHG1ROW("DELETE",1) Q			; Delete single row?
	;
	S X=$$TOK(expr,"FROM,WHERE",.tok) 
	; 
	I $G(FROM)="" S FROM=X I FROM="" D ERROR("FROM Parameter Required") Q 
	; 
	S table=$$FUN(FROM,,tok) 
	I table["""" S table=$$QSUB^%ZS(table) 
	; 
	I '$D(WHERE),$P($P(expr,table,2,99)," ",3)'="" S ER=1,RM=$$^MSG(8564,"DELETE "_expr) Q
	;
	; abv - 6/18/03
	; Invalid WHERE statement ~p1
	I $D(WHERE),WHERE="" S ER=1,RM=$$^MSG(1507,WHERE) Q	; abv-6/18/03
	;
	D fsn^SQLDD(.fsn,table) I ER Q 
	; 
	I $$ONEROW(table,$G(WHERE)) D CHG1ROW("DELETE") Q	; Delete single row
	;
	S keys=$P(fsn(table),"|",3),qrykeys=$$STRDD(keys,table,.tok) 
	; 
	; Return internal data format 
	S par("FORMAT")="" 
	; 
	S zexpr=keys_" FROM "_table
	I $D(WHERE) S zexpr=zexpr_" WHERE "_WHERE
	;
	D  I ER Q
	.	;
	.	; 05/06/04, FSCW: modified to behave excactly as in UPDATE()
	. ;I $G(par("USING"))'="",$$FLT^SQLCACHE(zexpr,.tok,.par) S vsql=$$RESULT^SQLM Q	; In cache table  pc 5/23/01
	. I $G(par("USING"))'="",$$FLT^SQLCACHE(zexpr,.tok,.par) Q	;OPENed by cache
	. S vsql=$$OPEN^SQLM(.exe,table,qrykeys,.WHERE,,,.par,tok) I ER Q
	. ;
	. ; 05/06/04, FSCW: mark WHERE-part as SELECT when saving it in cache
	.	I $G(par("USING"))'="" S par("_sqltype")="SELECT" D SAV^SQLCACHE(zexpr,.par) S par("_sqltype")="DELETE"
	; 
	S v="",delexpr="" 
	F i=1:1:$L(keys,",") D 
	.       I i>1 S v=v_" AND " 
	.       S v=v_$P(keys,",",i)_"=:VKEY"_i ; Assign key to :VKEYn 
	.       S delexpr=delexpr_",VKEY"_i_"=$P(v,$C(9),"_i_")" 
	I v'="" D 
	.       S expr=$P(expr," WHERE ",1)_" WHERE "_v 
	.       S delexpr="S "_$e(delexpr,2,$L(delexpr)) 
	; 
	D CACHE("DELETE",.vexe)
	I $G(ER) Q
	; 
	F sqlcnt=0:1 S vsql=$$^SQLF(.exe,.v) Q:vsql=0  D 
	.       I delexpr'="" X delexpr         ; Define VKEYn variables 
	.       D RUN(.vexe)                    ; Delete a single record 
	S sqlsta=$G(vsql(0)) 
	D SAVCACHE("DELETE",.vexe) 	; Save M code in cache table
	Q 
	;--------------------------------------------------------------------
DROP(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	; Parse the DROP statement 
	;--------------------------------------------------------------------
	; DROP PROCEDURE Procedure_name
	; DROP TABLE table_name
	; DROP INDEX index_name
	;----------------------------------------------------------------------
	N cmd,fid,prname,x	
	S cmd=$P(expr," ",1)
	I cmd="PROCEDURE" D  Q
	.	S prname=$P(expr," ",2)			; Procedure name
	.	I prname="" S ER=1,RM=$$^MSG(1287,expr) Q
	.	D DELETE^SQLCRE(prname)
	;
	I cmd="TABLE" D  Q				; Delete only if type 7
	.	S fid=$P(expr," ",2)			; Table name
	.	I fid="" S ER=1,RM=$$^MSG(1287,expr) Q	; Invalid table name
	.	S x=$$SQL("select FID FROM DBTBL1 where FILETYP=7 where FID='"_fid_"'",,.sqlsta,.sqldta,.sqlcnt)
	.	I sqldta="" Q				; Not a valid table (not created by GUI client)
	.	S x=$$SQL("delete "_fid,,.sqlsta,.sqldta,.sqlcnt)	; Delete data
	.	S x=$$SQL("delete DBTBL8 where FID="_"'"_fid_"'")	; Delete index files
	.	;							; Delete table
	.	S x=$$SQL("delete DBTBL1 where FILETYP=7 and FID='"_fid_"'",,.sqlsta,.sqldta,.sqlcnt)
	;
	; other DROP command not enabled
	S ER=1,RM=$$^MSG(8560)
	Q
	;
	;--------------------------------------------------------------------
TOK(expr,keywords,tok)	;public; Return command tok
	;--------------------------------------------------------------------
	;
	S ER=0
	;
	I $G(expr)="" Q ""
	I $G(tok)="" S expr=$$SQL^%ZS(.expr,.tok) I ER Q ""
	;
	N I,keyword,lvn,return,y,ys
	;
	S lvn="return",y=0,ys=1
	;
	F I=1:1:$L(keywords,",") D
	.	;
	.	S keyword=$P(keywords,",",I)
	.	F  S y=$F(expr,keyword,y) Q:y=0  D 
	..		;
	..		I '(" "[$E(expr,y-$L(keyword)-1)&(" ("[$E(expr,y))) Q
	..		S z=$E(expr,ys,y-$L(keyword)-2)
	..		I $L(z,"(")'=$L(z,")") Q
	..		;
	..		S @lvn=$$POP^%ZS(z)
	..		S lvn=keyword,ys=y+($E(expr,y)=" ")
	;
	S @lvn=$$POP^%ZS($E(expr,ys,$L(expr)))
	Q return
	;
	;--------------------------------------------------------------------
FUN(expr,args,tok)	;private; Parse function syntax ...	NAME(args)
	;--------------------------------------------------------------------
	;
	N return
	I expr'[" " S return=$P(expr,"(",1),args=$E(expr,$L($P(expr,"(",1))+1,$L(expr))
	E  S return=$P(expr," ",1),args=$P(expr," ",2,9999)
	I return[$C(0) D
	.	;
	.	S args=$C(0)_$P(return,$C(0),2,9999)
	.	S return=$P(return,$C(0),1) I return'="" Q
	.	S return=$$UNTOK^%ZS($C(0)_$P(args,$C(0),2)_$C(0),tok)
	.	S args=$C(0)_$P(args,$C(0),4,9999)
	;
	S args=$$POP^%ZS(args)
	I $E(return)="""" S return=$$QSUB^%ZS(return)
	Q return
	;
	;----------------------------------------------------------------------
RET(str,tok)	; Return string value (replace tokized values) 
	;----------------------------------------------------------------------
	;
	I str'[$C(0) Q str
	Q $$UNTOK^%ZS(str,tok)
	;
	;-----------------------------------------------------------------------
STRDD(str,table,tok)	; Return SQL string
	;-----------------------------------------------------------------------
	;
	N return,I
	S return=""
	F I=1:1:$L(str,",") S $P(return,",",I)=""""_table_"""."""_$P(str,",",I)_""""
	Q $$TOKEN^%ZS(return,.tok)
	;
	;-----------------------------------------------------------------------
NATOM(str,ptr,cols,tok,frm)	; Next Column Expresson Atom for UPDATE
	;-----------------------------------------------------------------------
	;
	N v,z
	S z=str
	;
	I z[$C(0) S z=$$UNTOK^%ZS(z,.tok)
	;			
	I $E(z)="'" Q $$QSWP^%ZS(z,"'","""")	; Replace ' with "
	S z=$$ATOM^%ZS(z,.ptr,"+-/*|",.tok)
	I $E(z)="(" N expr,ptr,str D  Q expr
	.	;
	.	S expr="(",ptr=0,str=$E(z,2,$L(z)-1)
	.	F  S expr=expr_$$NATOM(str,.ptr,.cols,.tok,frm) Q:ptr=0!ER
	.	S expr=expr_")"
	;
	I z="NULL" Q """"
	I z[""""!($E(z)?1A) D  Q z
	.	;
	.	I '$$CONTAIN(cols,z) S cols=cols_","_z
	.	S z="$P(v,$C(9),"_$L($P(","_cols_",",","_z_",",1),",")_")"
	;
	I z?.N!(z?.N1".".N) Q z
	I $E(z)=":" Q $E(z,2,$L(z))
	I z="|",$E(str,ptr+1)="|" S ptr=ptr+1 Q "_"
	I "+-/*|"[z Q z
	;
	; Unexpected Expression ~p1
	S ER=1,RM=$$^MSG(8572,z) Q z
	;
	;----------------------------------------------------------------------
CTLCHR(str)	; Replace control characters with $C() 
	;----------------------------------------------------------------------
	N i,vs
	S vs=""
	F i=1:1:$L(str) S v=$E(str,i) D
	.	I v'?1C S vs=vs_v Q
	.	S vs=vs_""""_"_$C("_$A(v)_")_"_""""
	Q vs
	;----------------------------------------------------------------------
CONTAIN(A,B)	Q (","_A_",")[(","_B_",")
	;----------------------------------------------------------------------
	;
ERROR(M)	; Return Error from message table
	;
	S RM=$G(M)
	S ER=1
	Q
	;
	;----------------------------------------------------------------------
USING(expr,new,setexpr,hostvar)	; Define host variables
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	; . expr	USING expression		/TYP=T/REQ/MECH=VAL
	; . newv	A list of variable names	/TYP=T/MECH=REF:W
	; . setexpr   	Execution procedural code	/TYP=T/MECH=REF:W
	; . hostvar     Host var references when val>2000 bytes
	;						/TYP=T/MECH=REF:W
	;
	; OUTPUT:
	;
	;	ER	Error flag
	;
	; EXAMPLE:
	;
	;  D USING("A='abc,xyz',B=12,C='SMITH'",.variable,.code)
	;  I ER Q
	;  N @variable
	;  X code
	;
	;  Returns:  varibale = A,B,C
	;            code     = S A="abc,xyz",B=12,C="SMITH"
	;
	;----------------------------------------------------------------------
	I expr[$C(0) S ER=1,RM=$$^MSG(1477,$G(par)) Q 	; Invalid /USING syntax
	;
	N i,tok,vptr,v,val,var
	S ER=0,new="",setexpr=""
	S v=expr
	S vptr=0					; 04/19/99
	I expr["'" S expr=$$TOKEN^%ZS(expr,.tok,"'") ; protect '
	I expr["""" S expr=$$TOKEN^%ZS(expr,.tok) ; protect "
	; 
	F i=1:1:$L(expr,",") D 	Q:$G(ER)		; process each variable
	.	S v=$P(expr,",",i)			; variable=value
	.	S var=$P(v,"=",1)			; name
	.	S val=$P(v,"=",2,999)			; value
	. 	I $E(val)="(" S val=$E(val,2,$L(val)-1)	; Remove ()
	.  	I val[$C(0) S val=$$UNTOK^%ZS(val,.tok) I $E(val)="'" S val=$$QSUB^%ZS(val,"'")
	. 	I val["""" S val=$$QADD^%ZS(val)
	.	E  S val=""""_val_""""
	.	S val=$$CNTRL(val)	; Xlate control characters in host vars
	.	;
	.	I var[":" S var=$TR(var,":","")		; remove : (old client syntax)
	.	I var'?1A.AN!(var?1"%".AN) S ER=1,RM=$$^MSG(1477,expr) Q
	.	S new=new_","_var
	.	I $l(val)>2000 do
	..		S hostvar(i)=$$QSUB^%ZS(val)
	..		S setexpr=setexpr_var_"=hostvar("_i_"),"
	.	E  S setexpr=setexpr_var_"="_val_","
	I ER K new,code Q
	S new=$E(new,2,$L(new))				; Variables to be protected
	I new="" S ER=1,RM=$$^MSG(1477,expr) K new,code Q
	;                                           
	S setexpr=" S "_$E(setexpr,1,$L(setexpr)-1)	; S var=val,var=...
	I $E(setexpr,$L(setexpr))="," S ER=1,RM=$$^MSG(1477,expr) Q
	Q
	;
	;----------------------------------------------------------------
CNTRL(str)	; Replace embedded cntl chars with concatenation of $C()	
	;----------------------------------------------------------------
	new ch,i,str1
	set str1=""
	for i=1:1:$L(str) do
	.	set ch=$E(str,i)
	.	; if not control char, append to output string and go get next char
	.	if $A(ch)>31,$A(ch)<127 set str1=str1_ch quit
	.	;
	.	; control character
	.	set str1=str1_"""_$C("_$A(ch)_")_"""
	quit str1
	Q
	;----------------------------------------------------------------------
CLOSE(expr)	; Close cursor
	;----------------------------------------------------------------------
	N sqlcur
	S sqlcur=$P(expr," ",1)				; Cursor name
	I sqlcur="CURSOR" S sqlcur=$P(expr," ",2)	; Skip keyword CURSOR
	D CLOSE^SQLM(sqlcur)
	Q
	;----------------------------------------------------------------------
SAVCACHE(opt,exe)	; Save INSERT/UPDATE/DELETE logic in cache table 
	;----------------------------------------------------------------------
	N vsql 
	I $G(ER) Q
	I $G(exe) Q				; Don't cache it (memo/blob columns referenced)
	I '$D(par("USING")) Q			; Host variable not defined
	I $G(par("CACHE"))=0 Q			; Option disabled
	S expr=$$UNTOK^%ZS(expr,.tok)  	; Save M code in cache table
	S expr=$P(expr,$C(9),1)			; Don't save qualifiers
	D SAV^SQLCACHE(expr) 	
	Q 
	;----------------------------------------------------------------------
ONEROW(fid,whr)	; Update/Delete single row?
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	; . fid		Table Name		/TYP=T/REQ/REF=VAL
	; . whr		WHERE Clause		/TYP=T/REF=VAL
	;
	; RETURNS:
	;
	; $$		Single row status	/TYP=L
	;
	; EXAMPLE:
	;
	; $$ONERWO("DEP","CID=:A")			return 1
	; $$ONERWO("DEP","CID>:A")			return 0
	; $$ONERWO("DEP","CID=:A AND BAL=:B")		return 0
	; $$ONERWO("HIST","CID=:A")			return 0
	; $$ONERWO("HIST","CID=:A AND TSEQ>:B")		return 0
	; $$ONERWO("HIST","CID=:A AND TSEQ=:B")		return 1
	;	
	;----------------------------------------------------------------------
	N col,i,keys,ER
	S ER=0
	I whr[" OR "!(whr'["=")!(whr["<")!(whr[">")!(whr["=(")!(whr["= (") Q 0		;6/20/00 mas sub-query
	I '$D(fsn(fid)) D fsn^SQLDD(.fsn,fid) I ER Q 0	; Table attributes
	S keys=$P(fsn(fid),"|",3)		; Access keys
	F i=1:1:$L(keys,",") S keys($P(keys,",",i))=""
	F i=1:1:$L(whr," AND ") D  I ER Q
	.	S col=$P($P(whr," AND ",i),"=",1)
	.	S col=$$TRIM^%ZS(col)		; Remove blanks
	.	I '$D(keys(col)) S ER=1 Q	; Non-key column reference
	.	K keys(col)
	I ER Q 0
	I $O(keys(""))'="" Q 0			; Not all access keys referenced
	Q 1
	;----------------------------------------------------------------------
FILERPAR(par)	; Valid filer qualifiers 
	;----------------------------------------------------------------------
	N i,name,zpar
	S zpar=""
	S i="" F  S i=$O(par(i)) Q:i=""  D
	.	I ",VALST,VALDD,VALREQ,VALRI,UPDATE,INDEX,JOURNAL,TRIGBEF,TRIGAFT,SAVEUX,CASDEL,NOFKCHK,"'[(","_i_",") Q
	.	S name=$S(i="NOFKCHK":i,$E(i,1,2)="NO":$E(i,3,20),1:i) 			;1/10/00 mas
	.	I $G(par(i))'="" S name=name_"="_$S(par(i)<0:"",1:par(i))		;1/10/00 mas
	.	S zpar=zpar_"/"_name
	Q zpar
	;
COLFMT(v)	; 
	S $P(sqlind,$C(0),2)=v			; Column format (PIA/PFW)
	Q
