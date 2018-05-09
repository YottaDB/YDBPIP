SQLCACHE	;private;SQL Cache library
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/17/02 03:05:07 - SPIER
	; DESC:	Library of SQL cache subroutines
	;
	; KEYWORDS:	DATABASE
	;
	;--------------- Revision History -------------------------------------
	; 07/10/07 - Pete Chenard - CR28171
	;	     Modified usage of $C, $E, $A, and $L to use SQLUTL utilities
	;	     in order to be unicode compliant.
	;
	; 12/05/05 - Pete Chenard - CR 18258
	;	     Modified FNDSP to set par="" if on RDB.  Corrects a problem
	;	     where the wrong hash key was being generated. 
	;
	; 01/06/05 - Pete Chenard - 13875
	;	     Modified to support > 1mb strings.
	;
	; 05/06/04 - Pete Chenard - CR11361
	;            Retrofitted changes made to the Profile01 version by Pete
	;            Chenard.
	;            SQL statement type is now passed in via par("_sqltype"),
	;            and stored in ^TMPCACHE(,,i+.4).
	;            Added tying of ^TMPCACHE(,,i), ^(i+.4), and ^(i+.5):
	;            Created public procedure KILL() that kills all related
	;            cache entries. Modified procedures PURGE and MAKESP() to
	;            call KILL().
	;            Some minor fixes in $$FLT(), MAKESP() and SAV()
	;            (see 05/06/04, FSCW).
	;            Added documentation (mostly INPUT / OUTPUT descriptions)
	;
	; 01/21/04 - GIRIDHARANB - 7979
	;	     Modified section MAKESP to correct a issue that corrupts the
	;	     TMPCAHCE global after a dayend.
	;
	; 01/02/03 - GIRIDHARANB - 7741
	;            Modified PURGE section to add tp around the call to MAKESP
	;            Its possible that not using TP in a very active environment
	;	     may cause TMPCACHE to be corrupted.
	;
	; 05/29/03 - THONIYIM - 1139 
	;            Change the reference from ^DBTBL("SYSDEV",18,spnam) 
	;            to ^DBTBLSP(spnam) 
	;
	; 06/17/02 - SPIER - 50450
	;	     Inserts and Updates cause error in stored procedure
	;	     execution, therfore they will be removed from cache
	;	     rather then creating them.
	;
	; 06/11/02 - SPIER - 50450
	;            Correct additional hard coded 1 in Purge section.
	;	     Also added $Gon that access of the global, prior
	;	     versions experienced undefineds on the global
	;	     because lower nodes existed but not the higher level.
	;
	; 05/18/02 - SPIER - 50450
	;            Modified PURGE section to be aware of 3rd key's value
	;	     rather then assuming it is one. 
	;
	;----------------------------------------------------------------------
PACK(vsql,exe)	; Pack vsql() and exe() into a string
	;----------------------------------------------------------------------
	;
	N i,c,d
	;
	S ER=0
	S d=$$LVW($G(vsql))
	I $G(vsql("K")) F i=0:1:vsql("K") S d=d_$$LVW($G(vsql(i)))
	S d=$$LVW(d)				; Wrap data section
	;
	S c=""
	;F i=1:1 Q:'$D(exe(i))  S c=c_$$LVW(exe(i)) I $L(c)>30000 S ER=1 Q
	S i="" F  S i=$O(exe(i)) Q:i=""  S c=c_$$LVW(exe(i)) I $$BSL^SQLUTL(c)>1022000 S ER=1 Q
	I ER Q ""				; Too much data
	S c=$$LVW(c)			; Wrap code section
	;
	S c=c_$$LVW($G(vsql("D")))	; Column type and length
	S c=c_$$LVW($G(vsql("F")))	; Format
	S c=c_$$LVW($G(vsql("T")))	; 
	;
	Q d_c
	;
	;----------------------------------------------------------------------
UNPACK(z,vsql,exe)	; Create vsql() & exe() from z
	;----------------------------------------------------------------------
	;
	N c,d,i,ptr,x
	;
	S ptr=0,d=$$LVP(z,3),c=$$LVP(z,4)
	;
	S x=$$LVP(z,5) I x'="" S vsql("D")=x	; Type_len
	S x=$$LVP(z,6) I x'="" S vsql("F")=x	; Format
	S x=$$LVP(z,7) I x'="" S vsql("T")=x	; temporary tables
	;
	S vsql=$$LVU(d,.ptr) F i=0:1 S vsql(i)=$$LVU(d,.ptr) Q:ptr=0
	S vsql("K")=i
	;
	I c'="" F exe=1:1 S exe(exe)=$$LVU(c,.ptr) Q:ptr=0
	Q
	;
	;--------------------------------------------------------------------
FLT(expr,tok,par)	; Return dynamic cache statement
	;--------------------------------------------------------------------
	I $$rdb^UCDB() Q 0
	;
	I expr[$C(0) S expr=$$UNTOK^%ZS(expr,.tok)
	;
	N hk,i,z,odbc
	;
	S z=$$LOD(expr,.par,.hk,.i,.odbc)
	;
	I z=""  D					; Not in Cache - try SP
	.	;
	.	N spnam
	.	S spnam=$$FNDSP(expr,.par) I spnam="" Q
	.	S exe=1,exe(1)=$P(^DBTBLSP($P(spnam,"-",1)),"|",1)
	.	D SAV(expr,.par)
	;
	E  D
	.	D UNPACK(z,.vsql,.exe)		; Unpack vsql() and exe() array
	.	S vsql("A")=$G(odbc)		; ODBC prepare information
	;
	I '$G(exe) Q 0
	;
	;
	I exe=1 D  Q 1				; Stored procedure
	.	S z=exe(1)			; Routine name
	.	I $G(par("PREPARE")) X "S vsql(""A"")=$$PREPARE^"_z_"()"	; ODBC prepare attributes
	.	; 05/06/04, FSCW: execute only if mode allows it
	.	I $G(mode)'<0 D RTN^SQL		; Execute run-time routine
	;
	S ^TMPCACHE("SYSDEV",hk,i)=($G(^TMPCACHE("SYSDEV",hk,i))+1)_"|"_$H
	I $G(par("FORMAT"))'="" S vsql("F")=$$VSQLF^SQLCOL(.par)
	;
	S vsql("P")=$g(vsql(1)),vsql(1)=""
	I '$D(%TOKEN) S %TOKEN=$J		;04/26/01
	I $G(mode)'<0 S vsql=$$RESULT^SQLM
	Q 1
	;
	;--------------------------------------------------------------------
SAV(expr,par,hk)	; Save dynamic cache statement
	;--------------------------------------------------------------------
	; ARGUMENTS:
	; . expr	SQL expression to be cached	/TYP=T/REQ/MECH=VAL
	; . par		parameter array			/TYP=T/NOREQ/MECH=REF:R
	;		Only the parameters returned by $$PARS() and the
	;		parameter "_sqltype" are used by this procedure.
	;		All other parametes are ignored.
	; . hk		hash key to use			/TYP=N/NOREQ/MECH=REF:RW
	;		If supplied, it specifies the forced hashkey
	;		(as opposed to calculated by $$LOD())
	;
	; INPUTS:
	; . exe()	code to be executed
	;		will be packed into the cache entry
	; . vsql()	vsql, vsql(0), vsql("P"), vsql("D"), vsql("K"), and
	;		vsql("T") will be packed packed into the cache entry.
	;		vsql("A") (the ODBC prepare info), will be stored in
	;		^TMPCACHE("SYSDEV",hk,i+.5), if defined
	;
	;
	I $G(exe(1))["D RPCF^SQLC" Q			; Client Stub
	;
	N i,j,x,z,zz
	S hk=$G(hk)
	;						; *** 
	I $G(vsql(0))=100 Q				; Not valid expression
	S z=$G(vsql)
	I $D(vsql)>1 D
	.	;
	.	S z(0)=vsql(0)
	.	S z(1)=$G(vsql("P"))
	.	S z("D")=$G(vsql("D"))
	.	S z("K")=$G(vsql("K"))
	.	S z("T")=$G(vsql("T"))
	.	F i=2:1:z("K") S z(i)=""
	;
	S z=$$PACK(.z,.exe) I $G(ER) S ER=0 Q			; Too much data
	S z=$$LVW(expr)_$$LVW($$PARS(.par))_z
	;
	S zz=$$LOD(expr,.par,.hk,.i)
	;
	L +^TMPCACHE("SYSDEV",hk,i):5 E  Q
	;
	I zz'="" K ^TMPCACHE("SYSDEV",hk,i)
	S ^TMPCACHE("SYSDEV",hk,i)="|"_$H			; Initial time stamp
	F j=1:1 S ^TMPCACHE("SYSDEV",hk,i,j)=$$BSE^SQLUTL(z,1,255),z=$$BSE^SQLUTL(z,256,$$BSL^SQLUTL(z)) Q:z=""
	;
	; 05/06/04, FSCW, store SQL statement type
	S ^TMPCACHE("SYSDEV",hk,i+.4)=$G(par("_sqltype"),"unknown")
	S x=$G(vsql("A"))				; ODBC prepare information 04/15/99
	;
	; 05/06/04, FSCW, added KILL ^TMPCACHE("SYSDEV",hk,i+.5) before recreating it
	I x'="" K ^TMPCACHE("SYSDEV",hk,i+.5) F j=1:1 S ^TMPCACHE("SYSDEV",hk,i+.5,j)=$$BSE^SQLUTL(x,1,255),x=$$BSE^SQLUTL(x,256,$$BSL^SQLUTL(x)) Q:x=""
	;
	L -^TMPCACHE("SYSDEV",hk,i)
	Q
	;
	;--------------------------------------------------------------------
LOD(expr,par,hk,i,odbc)	; Return cache expression
	;--------------------------------------------------------------------
	; ARGUMENTS:
	;
	; . expr	SQL select statement		/TYP=T/REQ/MECH=VAL
	; . par		Qualifiers			/TYP=T/MECH=REF:R
	; . hk		Hash key			/TYP=N/MECH=REF:RW
	;		if present, it will be used,
	;		otherwise, it will be calculated
	; . i		slot number			/TYP=N/MECH=REF:W
	; . odbc	ODBC PREPARE information	/TYP=T/MECH=REF:W
	;
	; A match is returned if and only if ALL of the following conditions are
	; satisfied:
	; * the expr supplied equals the expr in cache
	; * the presence and values of the qualifiers /PROTECTION=v1, /DQMODE,
	;   /INDEX=v2, and /PREPARE=v3 in the supplied .par() match those stored
	;   in cache (see $$PARS()).
	; ODBC PREPARE information is returned if ALL of the following
	; conditions are satisfied (otherwise odbc=""):
	; * the caller requested prepare information ($GET(par("PREPARE")))
	; * prepare information is present in ^TMPCACHE("SYSDEV",hk,i+.5)
	;----------------------------------------------------------------------
	I $G(hk)="" S hk=$$ELFHASH^%ZFUNC(expr_$$PARS(.par))	; Hash key
	;
	N j,z,zz
	;
	S z="",odbc=""
	F i=1:1 D  Q:z=""  I expr=$$LVP(z,1),$$PARS(.par)=$$LVP(z,2) Q
	.	;
	.	S z=$G(^TMPCACHE("SYSDEV",hk,i,1))  I z="" Q
	.	F j=2:1 S zz=$g(^TMPCACHE("SYSDEV",hk,i,j)) Q:zz=""  S z=z_zz
	.	I '$G(par("PREPARE")) Q
	.	F j=1:1 Q:'$D(^TMPCACHE("SYSDEV",hk,i+.5,j))  S odbc=odbc_^(j)	; ODBC prepare information
	.	;
	Q z
	;
	;--------------------------------------------------------------------
DMP	; Dump cache in formatted output
	;--------------------------------------------------------------------
	;
	S %LIBS="SYSDEV"
	S RID="DBCACHE" D DRV^URID
	Q
	;
	;--------------------------------------------------------------------
SP(curnam,expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	; Run Procedure cache 
	;--------------------------------------------------------------------
	;
	I expr[$C(0) S expr=$$UNTOK^%ZS(expr,.tok)
	;
	N spnam
	S spnam=$$FNDSP(expr,.par)
	; 
	I spnam="" D					; Not on file
	.	K par("SPCREATE")			; Not required
	.	D SPSEL^SQLCRE(expr,,.par)		; Create stored procedure
	.	S spnam=RM				; SP name
	I ER Q ""
	;
	D RUNSP^SQL(.curnam,spnam,.par) I ER Q $G(RM)	; *** 03/07/96
	Q spnam
	;
	;--------------------------------------------------------------------
FNDSP(expr,par)	; Return stored procedure associated with SQL expression
	;--------------------------------------------------------------------
	;
	N sphk,spnam
	I $$rdb^UCDBRT() new par set par=""
	S sphk=$$ELFHASH^%ZFUNC(expr_$$PARS(.par)),spnam=""
	;
	F  S spnam=$O(^DBINDX("SYSDEV","SPHK",sphk,spnam)) Q:spnam=""  I $$SPSQL(spnam)=expr Q
	I spnam="" Q spnam
	S z=$G(^DBTBLSP(spnam))
	I spnam?1"S".N S spnam=spnam_"-"_$p(z,"|",6)_"-"_$p(z,"|",7)
	Q spnam
	;
	;--------------------------------------------------------------------
SPSQL(spnam)	; Return SQL expression associated with procedure spnam
	;--------------------------------------------------------------------
	;
	N i,spsql,z
	;
	S spsql=$G(^DBTBLSP(spnam,1))
	I spsql'="" F i=2:1 S z=$G(^(i)) Q:z=""  S spsql=spsql_z
	Q spsql
	;
	;----------------------------------------------------------------------
SPCLI(expr,par,sqlsta,sqldta,sqlcnt,sqlind)	;public; Run stored procedure
	;----------------------------------------------------------------------
	; 'Black box' for client dynamic stored procedure handling.  This
	; function will look up a stored procedure name locally based on
	; the input select statement.  If found, it will call the remote
	; procedure directly with the execute command.  Otherwise, it will
	; create a remote procedure.
	;
	; KEYWORDS: Database
	;
	; RELATED: SETVAL^DBSDD,$$RETVAL^DBSDD
	;
	; ARGUMENTS:
	;	. expr		SQL Select expression	/REQ
	;	. par		Input Parameters
	;	. sqlsta	Return Code		/REF
	;	. sqldta	Return Code		/REF
	;	. sqlcnt	Record Count		/REF
	;	. sqlind	Column Indicators	/REF
	;
	;   RETURNS:
	;	. ER    (0,1) Error Flag
	;       . RM    Error message message (If ER=1)
	;
	;----------------------------------------------------------------------
	; I18N=OFF: Excluded from I18N standards. 
	;----------------------------------------------------------------------
	I $E(expr,1,7)'="SELECT " S RM=$$^MSG(8045) Q 1
	S expr=$E(expr,8,$L(expr))
	;
	I $D(par)=1 D PARSPAR^%ZS(par,.par)
	;
	N spnam,z,zexpr,zpar,ER
	;
	S zpar=$$PARS(.par)
	S spnam=$$FNDSP(expr,.par)			; Locate SP name
	;						;
	S zexpr="SELECT "_expr,zpar=zpar_"/SPCREATE"	; Original statement
	I spnam="" S expr=zexpr				; Create new stored procedure
	E  S expr="EXECUTE "_spnam,zpar=$P(zpar,"/SPCREATE",1)_$P(zpar,"/SPCREATE",2) ; Execute it
	;
	I $G(par("USING"))'="" S zpar=zpar_"/USING=("_par("USING")_")"
	;						; 
	D SPEXEC					; Execute SQL statement
	;						; *** 02/29/96
	I $G(sqlsta)=50001,expr["EXECUTE",spnam'="" D	; Invalid SP name
	.	D DELSP(spnam)				; Delete index entries
	.	S expr=zexpr,spnam="",zpar=zpar_"/SPCREATE"
	.	D SPEXEC				; Try to create it again
	.	
	I ER Q 1					; Other errors
	;
	I spnam'="" Q 0					; SP executed
	I spnam="",$G(RM)="" Q 0
	I '$G(%LOGID) Q 0				; HOST - already created
	;						; Update SP table
	;						; RM is the SP name returned by the server
	N args,i,rtn,sphk
	S expr=$E(expr,8,$L(expr)),sphk=$$ELFHASH^%ZFUNC(expr_$$PARS(.par))
	;
	S ^DBINDX("SYSDEV","SPHK",sphk,RM)=""		; Hask key index file
	S args=$$HOSTVAR^SQLCRE(expr) 		; Host variables
	S par="" 				; Parameters
	I $G(par("PROTECTION")) S par=par_"/PROTECTION="_par("PROTECTION") 
	I $G(par("INDEX"))'="" S par=par_"/INDEX="_par("INDEX") 
	;
	S z="|"_args_"|"_sphk_"|"_par_"||"_+$H_"|"_$P($H,",",2) 
	S ^DBTBLSP(RM)=z 			; Stored procedure header
	F i=1:1 S ^DBTBLSP(RM,i)=$E(expr,1,255),expr=$E(expr,256,$L(expr)) Q:expr=""
	;
	Q 0
	;
	;----------------------------------------------------------------------
SPEXEC	; Execute SQL statement
	;----------------------------------------------------------------------
	;
	S ER=0
	S ER=$$^SQL(expr,zpar,.sqlsta,.sqldta,.sqlcnt,.sqlind) Q
	Q
	;----------------------------------------------------------------------
DELSP(spnam)	; Remove stored procedure index entries
	;----------------------------------------------------------------------
	N i
	K ^DBTBLSP(spnam)
	S i="" F  S i=$O(^DBINDX("SYSDEV","SPHK",i)) q:i=""  K ^(i,spnam)
	Q
	;--------------------------------------------------------------------
PARS(par)	; Return code modifying parameters (only) in a string
	;--------------------------------------------------------------------
	; ARGUMENTS:
	; . par()	parameter array			TYPE=T/REQ/MECH=REF:R
	;		Only the following parameters
	;		are included in the quit value:
	;		* PROTECTION=v1
	;		* DQMODE
	;		* INDEX=v2
	;		* PREPARE=v3
	;
	N z
	S z=""
	I $G(par("PROTECTION")) S z=z_"/PROTECTION="_par("PROTECTION")
	I $G(par("DQMODE")) S z=z_"/DQMODE"
	I $G(par("INDEX"))'="" S z=z_"/INDEX="_par("INDEX")
	I $G(par("PREPARE"))'="" S z=z_"/PREPARE="_par("PREPARE")	; 02/09/2000
	Q z
	;
	;----------------------------------------------------------------------
LVP(str,pc)	; Return position of pc
	;----------------------------------------------------------------------
	;
	I $G(pc)<2 Q $$LVU(str)
	;
	N i,ptr
	S ptr=0 F i=1:1:pc-1 S ptr=$$BSASCII^SQLUTL(str,ptr+1)*256+$$BSASCII^SQLUTL(str,ptr+2)+ptr
	Q $$LVU(str,ptr)
	;
	;----------------------------------------------------------------------
LVU(str,ptr)	; Unwrap string and remove header
	;----------------------------------------------------------------------
	;
	I '$D(ptr) S ptr=0
	;
	N len,z
	S len=$$BSASCII^SQLUTL(str,ptr+1)*256+$$BSASCII^SQLUTL(str,ptr+2),ptr=ptr+len
	S z=$$BSE^SQLUTL(str,ptr-len+3,ptr)
	I ptr=$$BSL^SQLUTL(str)!(len<0) S ptr=0
	Q z
	;
	;----------------------------------------------------------------------
LVW(str)	; Length-value wrap string with 2 byte header (include header)
	;----------------------------------------------------------------------
	;
	N len
	S len=$$BSL^SQLUTL(str)+2
	I len<256 Q $$BYTECHAR^SQLUTL(0,len)_str
	Q $$BYTECHAR^SQLUTL((len\256),(len#256))_str
	;
	;----------------------------------------------------------------------
COBJ(hk,i)	; Return Cache object
	;----------------------------------------------------------------------
	;
	N j,z,zz
	;
	S z=$G(^TMPCACHE("SYSDEV",hk,i,1)) I z="" Q ""
	F j=2:1 S zz=$g(^(j)) Q:zz=""  S z=z_zz
	Q z
	;----------------------------------------------------------------------
CASHCOMP(hk,i);	;PUBLIC; Return computed items 
	;----------------------------------------------------------------------
	N return,vsql,exe,z
	S return=""
	S z=$$COBJ(hk,i)
	I z="" Q "" 
	S size=$L(z)
	D UNPACK(z,.vsql,.exe)
	S return=size_$c(0)_$g(vsql(1))_$c(0)_$g(vsql("K"))_$C(0)
	f i=1:1 q:'$d(exe(i))  s return=return_exe(i)_$c(7)
	Q return
	;
	;----------------------------------------------------------------------
PURGE	; Purge SQL statement cache table (called by function DBSCACHEP
	;----------------------------------------------------------------------
	N ER,hk,key,seq,spnam
	;
	S spnam="" 
	F  S spnam=$O(^DBTBLSP(spnam)) Q:spnam=""  D
	.	S key=$p(^DBTBLSP(spnam),"|",3)  ; Stored proc hash key
	.	I key'="" S hk(key)=""  		; Save it
	;
	S (key,seq)=""
	F  S key=$O(^TMPCACHE("SYSDEV",key)) Q:key=""  F  S seq=$O(^TMPCACHE("SYSDEV",key,seq)) Q:seq=""  D
	.	;
	.	set ER=0
	.	;use cs instead of batch to harden immediately
	.	tstart ():transactionid="CS"
	.	; create stored procedure when counter exceeds 50, if a stored procedure
	.	; already exists map tempcache to it as well.
	.	I $D(hk(key))!($P($G(^TMPCACHE("SYSDEV",key,seq)),"|",1)>50) D
	..		D MAKESP(key,seq)
	.	; 05/06/04, FSCW, repaced by call to KILL()
	.	;E  K ^TMPCACHE("SYSDEV",key,seq)
	.	E  D KILL(key,seq)
	.	I 'ER tcommit:$tlevel
	.	trollback:$tlevel
	;
	S ER="W",RM=$$^MSG(2288)
	Q
	;
MAKESP(hk,i)	;
	;
	; Create stored procedure since the SQL being used has
	; hit 50 times this day.
	;
	N %LIBS,RM,exe,expr,fsn,j,par,sqldta,sphk,spnam,tok,vsql,z,zpar,zz
	;
	; Retrieve saved sql
	S z=$G(^TMPCACHE("SYSDEV",hk,i,1))  I z="" Q
	F j=2:1 S zz=$g(^TMPCACHE("SYSDEV",hk,i,j)) Q:zz=""  S z=z_zz
	;
	; Break into components exe and vsql
	D UNPACK(z,.vsql,.exe)		; Unpack vsql()
	I $G(exe(1))="" Q
	; Already converted
	I exe(1)?1"S"7N D  Q		
	.	; If stored procedures were purged, get rid of this entry also.
	.	;
	.	I '$D(^DBTBLSP(exe(1))) D KILL(hk,i)  ; 05/06/04, FSCW, replaced by call to KILL()
	;
	S expr=$$LVP(z,1)
	S par=$$LVP(z,2)
	D PARSPAR^%ZS(par,.zpar)
	;
	; Create SP for SELECT.
	; If one exists, this procedure will use the existing one
	;D SPSEL^SQLCRE(expr,,.par)
	S z=$G(^TMPCACHE("SYSDEV",hk,i+.4)),RM=""
	I z="SELECT" D SPSEL^SQLCRE(expr,,.zpar,,,z,hk)
	S CNT=$P(^TMPCACHE("SYSDEV",hk,i),"|",1)
	;
	; SP not created
	; 05/06/04, FSCW, replaced by call to KILL()
	; SP not created
	;I $G(RM)=""!$G(ER) K ^TMPCACHE("SYSDEV",hk,i) Q
	I $G(RM)=""!$G(ER) D KILL(hk,i) Q
	;
	; change the exe saved to now call the SP
	k exe
	S exe=1,exe(1)=$P(^DBTBLSP($P(RM,"-",1)),"|",1)
	D SAV(expr,.par,hk)
	;
	; save count of hits that caused creation of SP
	; This counter will not be incremented after SP is created.
	S $P(^TMPCACHE("SYSDEV",hk,i),"|",1)=CNT
	Q
	;
	;--------------------------------------------------------------------
KILL(hk,i)	;private; kill a cache entry, and its related nodes
	;--------------------------------------------------------------------
	; This procedure deletes zero or more related entries from ^TMPCACHE.
	; If the value of i is non-integer, then ^TMPCACHE(,,i) will only
	; be killed if ^TMPCACHE(,,i\1) does not exist.
	; If the value of i is an integer, then ^TMPCACHE(,,i), ^(i+.4), and
	; ^(i+.5) are all killed.
	; This behaviour enables that PURGE() can call KILL() for each node
	; it encounters. So if other pieces of code did not call KILL^SQLCACH()
	; to get rid of a node, and only killed ^TMPCAHCE(,,i), PURGE() will
	; clean-up after them.
	;
	; When other tied non-integer nodes are introduced, including them
	; in this procedure will help keep the system clean.
	;
	; ARGUMENTS:
	;	. hk		hash key		/TYPE=N/REQ
	;	. i		sequence number		/TYPE=N/REQ
	;
	n parent
	s parent=i\1
	i i'=parent d			; "child" node, only if "parent" died
	.	i '$d(^TMPCACHE("SYSDEV",hk,parent)) k ^(i)
	e  d				; "parent" node, kill related nodes
	.	k ^TMPCACHE("SYSDEV",hk,i),^(i+.4),^(i+.5)
	q
