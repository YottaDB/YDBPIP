SQLM	;;SQL Cursor Code Generator for DATA-QWIK
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/08/03 09:29:06 - CHENARDP
	;
	; Run an interactive report if called from the top.
	;
	;  LIBARY:
	;----------------------------------------------------------------------
        ; I18N=QUIT: Excluded from I18N standards.
	;----------------------------------------------------------------------
	;---------- Revision History ------------------------------------------
	;
	; 2009-31-07- Sha Mirza, CR 41833
	;	* Modified OPEN section in which exe() was not building all its
	;	  vsql(..) elements for query which has computed column in it and
	;	  group by clause.
	;
	; 2009-01-06- Sha Mirza, CR 40332
	;	* Modified SORT to deal with SQL DISTINCT combined with ORDER BY 
	;	  does not return expected results.
	;	* Modified SORT to deal with $ZCHAR(254).  
	;
	; 04/29/09 - Pete Chenard
	;	* Modified VIEW to pass in the last parameter into ^SQLO based
	;	  on whether the table is part of a join or not.  This change is
	;	  made in conjunction with a change in RANGE^SQLQ that kills the
	;	  join array entry when appropriate.
	;
	; 04/06/09 - Pete Chenard
	;	* Corrected logic in RESETlvn that sets the lvn value for each access 
	;	  key into the vsub array.  It was setting the same lvn for each key.
	;	* Modified COLLATE to append vsub(ddref) to the gbref variable prior
	;	  to quitting from the section.
	;
	; 02/23/09 - Pete Chenard
	;	* Modified VIEW to correctly deal with table aliases.
	;	* Modified OPEN to expect the variable ojqry to be an array
	;	  keyed by table name rather than a single variable.  This 
	;	  corrects an issue with left outer joins.  See SQLA and SQLQ
	;	  for corresponding changes.
	;	* Added vAlias to New list at the top of OPEN.
	;
	; 02/18/09 - Pete Chenard
	;	* Added code to optimize DISTINCT queries.  After a match is found
	;	  we can potentially quit collating at that key level.  See SQLO
	;	  for corresponding modifications.
	;
	; 01/22/09 - Pete Chenard
	;	* Modified OPEN to check if the table name in the 'frm' variable
	;	  is an alias for an actual table.  If so, use the real table.
	;
	; 01/19/09 - Pete Chenard
	;	* Modified SORT to correct problem with DISTINCT clause when
	;	  2 or more tables are in the FROM clause.
	;
	; 01/07/2009 - RussellDS - CR37511
	;	* Modified CLOSE to restore vsql to be able to close cursor
	;	  on RDB side.
	;	* Removed old revision history.
	;	
	; 01/01/2009 - RussellDS - CRs 37432/35741
	;	* Modified OPEN section to set SELECT statement into variable
	;	  and break long ones into pieces to avoid problems with audit
	;	  logging checking for very long SELECT statement due to GT.M
	;	  error on length of execute.
	;
	; 11/14/2008 - RussellDS - CRs 36716/35741
	;	* Modified RDBvsql to add vpack to the "new" list to prevent
	;	  problems when lying around from a prior set of $$PREPARE
	;	  calls, as can happen with aggregate messages.
	;
	; 11/13/2008 - RussellDS - CRs 36391/35741
	;	Modified use of substitute null character to set it up at the
	;	beginning of the exe() array so that it is determined at
	;	runtime, but with only one call.  This avoids problems in
	;	code generated for PSL that is distributed to Unicode
	;	environments.
	;
	; 09/29/08 - giridharanb - CR35828
	;	* Modified section CLOSE to clean out entries in sqlcur table.
	;
	; 03/12/2008 - RussellDS - CR30801
	;	* Modified archive handling to use new getArchiveFile method for
	;	  appropriate RecordTABLE.
	;	* Modified OPEN and ACCESS, added GETSELRTS and ACCESSRTS to deal
	;	  with select access rights 
	;	* Modified OPEN to deal with select audit logging
	;	* Modified SORT section to correct an issue that caused
	;	  unnecessary sorting to take place in some cases.
	;	* Removed old revision history.
	;	* Modified RDB and CLOSE sections to eliminate the use
	;	  of ^ORACACHE global.
	;	* Modified SORT section to assign variable name to computed
	;	  to avoid errors on attempt to deal with nulls when using
	;	  expression directly.
	;----------------------------------------------------------------------
	Q
	;----------------------------------------------------------------------
OPEN(exe,sqlfrm,sel,sqlwhr,sqloby,grp,par,tok,mode,vdd,sqlcur,subqry)	;public; Open a MUMPS Database	
	;----------------------------------------------------------------------
	;
	; Builds executable code and opens results table.  Use $$FETCH to
	; access the next row of data.
	;
	; KEYWORDS: database
	;
	; RELATED: $$FETCH^SQLM,$$OPEN^UHFETCH
	;
	; ARGUMENTS:
	;	. exe(line)	Executable code 	/MECH=REFNAM:W
	;	. frm		File list		/REQ/DEL=$C(44)/MECH=VAL
	;	. sel		Data Item Select list	/DEL=$C(44)/MECH=VAL
	;	. whr		DATA-QWIK Query		/MECH=REFNAM:RW
	;	. oby		Order by list		/DEL=$C(44)/MECH=VAL
	;	. grp		Group by list		/DEL=$C(44)/MECH=VAL
	;	. par		Parameters		/MECH=VAL
	;			BLOCK=Array_Count
	;			DQMODE=Data Qwik Mode	/DFT=0
	;			OPTIMIZE=Index Optimize	/DFT=1
	;			TIMEOUT=Seconds
	;	. mode		Process mode
	;		               -2 - Subquery
	;			       -1 - Generate compiler code
	;				0 - Interactive
	;				1 - Interactive (Cursor Open)
	;
	;	. vdd(ddref)	Data Dictionary		/MECH=REFNAM:RW
	;	. sqlcur	Cursor Name		/NOREQ/DFT=" "
	; 
	; RETURNS:
	;	. $$	Success code			/TYP=N
	;		0 = No records in database
	;		1-n Success
	;
	;	. vsql(sym)	Cursor's Private Symbol Table
	;	. ER		Error processing parameters
	;	. RM		Error message
	;
	; EXAMPLE:
 	;
	;S vsql=$$OPEN^SQLM(.exe,"DEP","CID,LNM,TLD,BAL","DEP.BAL>100")
	;I vsql=0 Q
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	I '$D(%LIBS) S %LIBS="SYSDEV"
	; Define TOKEN variable 
	I $G(%TOKEN)="" S %TOKEN=$P($G(%LOGID),"|",6) I %TOKEN="" S %TOKEN=$J
	;
	N access,all,cmp,ddref,dlevel,dqm,expr,fma,file,flist,fnum,frm,fsn,gbref,gbsel,i,I
	N inclaccrts,j,jfiles,jkeys,join,keynum,keys,lib,min,max,num,oby,ojflg,ojqry
	N null,nullsymbl,p,plan,rng,rtbl,selcols,sok,symbl,v,vAlias,v255,vsub,vxp,whr,z,zrng
	;
	S selcols=sel
	;
	S mode=$G(mode)
	I mode<0=0 K vsql,exe
	;
 	N isRdb
 	S isRdb=$$RsRdb^UCDBRT(sqlfrm)
 	;
 	; Deal with access rights.  Patch FROM and WHERE if possible ($$ACCESSRTS)
 	I mode=-1 S inclaccrts=1	; Always include in generated code
	E  S inclaccrts=0
 	I 'isRdb,'inclaccrts D
 	.	N fsn			; Do not want to affect later fsn usage
 	.	S inclaccrts=$$ACCESSRTS(.sqlfrm,.sqlwhr,mode,sel)
 	;
	; Substitution of system key words is based on upper-case match since
	; SQL expression is always upper-cased.
	;
	I $G(sqlwhr)[":" D
	.	N atom,delim,kwds,n,nwhere,ptr,syskwds
	.	D STBLSKWD^DBSDI(.kwds)
	.	S n=""
	.	F  S n=$O(kwds(n)) Q:n=""  S syskwds($$UPPER^UCGMR(n))=kwds(n)
	.	;
	.	S nwhere=sqlwhr
	.	S delim="*/+-|,()<=>"
	.	S (cnt,ptr)=0
	.	F  S atom=$$ATOM^%ZS(sqlwhr,.ptr,delim,,1) D  Q:'ptr
	..		I $E(atom)=":",$D(syskwds($$UPPER^UCGMR($E(atom,2,999)))) D
	...			N newvar,oldvar
	...			S oldvar=$E(atom,2,999)
	...			S exe=$G(vsql("V"))+1,vsql("V")=exe
	...			S newvar="V"_exe
	...			S exe(exe)="S "_newvar_"="_syskwds($$UPPER^UCGMR(oldvar))
	...			S nwhere=$$replace(nwhere,oldvar,newvar)
	.	S sqlwhr=nwhere
 	;
 	I isRdb Q $$RDB(.exe,sqlfrm,sel,$g(sqlwhr),$g(sqloby),$g(grp),.par,$g(tok),$g(mode),.vdd,$g(sqlcur),$g(subqry))
 	;
	I $D(par)=1 D PARSPAR^%ZS(par,.par)		; Back Compatible
	;
	I $G(tok)="" N tok D  I ER Q 0
	.	;
	.	S sel=$$SQL^%ZS($g(sel),.tok) I ER Q
	.	S sqlwhr=$$SQL^%ZS($g(sqlwhr),.tok) I ER Q
	.	S sqloby=$$SQL^%ZS($g(sqloby),.tok)
	;
	I $G(HAVING)'="" D
	.	N select S select=","_sel_","
	.	S vsql("HAVING","sel")=sel
	.	;
	.	I HAVING[" NOT" d  Q
	..		I select'[$P(HAVING," NOT",1) S sel=sel_","_$P(HAVING," NOT",1),vsql("HAVING","sel",$P(HAVING," NOT",1))="" Q
	.	I HAVING[">",select'[$P(HAVING,">",1) S sel=sel_","_$P(HAVING,">",1),vsql("HAVING","sel",$P(HAVING,">",1))=""
	.	I HAVING["<",select'[$P(HAVING,"<",1) S sel=sel_","_$P(HAVING,"<",1),vsql("HAVING","sel",$P(HAVING,"<",1))=""
	.	I HAVING["=",select'[$P(HAVING,"=",1) S sel=sel_","_$P(HAVING,"=",1),vsql("HAVING","sel",$P(HAVING,"=",1))=""
	S fsn="vsql("
	S dqm=$G(par("DQMODE"))				; Data Qwik Mode
	;
	I $G(sqlcur)="" S sqlcur=0
	;
	S vsql=0,ojflg="",ojqry="",fsn="vsql(",rng=""
	S exe=+$G(exe),vxp=-1,jfiles="",access=""
	S null=$$BYTECODE^SQLUTL(254)
	S nullsymbl="vsql("_$$NXTSYM^SQLM_")"
	S exe=exe+1,exe(exe)="S "_nullsymbl_"=$$BYTECHAR^SQLUTL(254)"
	;
	I $G(HAVING)'="" D HOSTVAR^SQLG
	I $G(grp)'="" D INIT^SQLG Q:ER 0
	;
	S frm=$$^SQLJ(sqlfrm,.whr,.fsn,.join,.tok) I ER Q 0	; Process FROM
	I $G(par("PROTECTION")) D PROT(frm,.sel) I ER Q 0
	;
	S oby=$$ORDERBY(.sqloby,sel,frm)
	;
	F I=1:1:$L(frm,",") D VIEW($P(frm,",",I),.whr,.fsn)
	I $G(sqlwhr)'="" D ^SQLQ(sqlwhr,.frm,.whr,.rng,.mode,.tok,.fsn,.vdd) I ER Q 0
	;
	I $E(sel,1,9)="DISTINCT " S all=0,sel=$E(sel,10,$L(sel))
  	E  S all=1 I $E(sel,1,4)="ALL " S sel=$E(sel,5,$L(sel))
	;
	;;I $G(grp)'="" D ^SQLG() I ER Q 0  	; Not implemented yet
	;
	I $$usingAuditLog^SQLAUDIT D
	.	N cols,statement,symbl
	.	; Treat DbSet as *; replace class with PSL.class when convert to PSL
	.	I $G(class)="DbSet" S cols="*"
	.	E  S cols=$$QSUB^%ZS($$UNTOK^%ZS(selcols,tok))
	.	S statement="SELECT "_cols_" FROM "_sqlfrm
	.	I $G(sqlwhr)'="" S statement=statement_" WHERE "_$$UNTOK^%ZS(sqlwhr,tok)
	.	I $G(sqloby)'="" S statement=statement_" ORDER BY "_sqloby
	.	S symbl="vsql("_$$NXTSYM^SQLM_")"
	.	S exe=exe+1,exe(exe)="S "_symbl_"="
	.	I $L(statement)<1900 S exe(exe)=exe(exe)_$$QADD^%ZS(statement)
	.	E  D
	..		S exe(exe)=exe(exe)_$$QADD^%ZS($E(statement,1,1900))
	..		S statement=$E(statement,1901,$L(statement))
	..		F  D  Q:statement=""
	...			S exe=exe+1
	...			S exe(exe)="S "_symbl_"="_symbl_"_"_$$QADD^%ZS($E(statement,1,1900))
	...			S statement=$E(statement,1901,$L(statement))	
	.	F I=1:1:$L(frm,",") D
	..		N code
	..		S code="N vauditseq S vauditseq=$$vlogSelect^Record"_$P(frm,",",I)
	..		S code=code_"("_symbl_","
	..		I $G(vsql("hostVars"))'="" S code=code_vsql("hostVars")_")"
	..		E  S code=code_""""")"
	..		S exe=exe+1,exe(exe)=code_" ;=noOpti"
	;
	D ^SQLO(frm,.sel,.oby,.all,.vsql,.rng,.par,.tok,.fsn,.vdd) I ER Q 0
	;
	S zrng=(rng[1)					; 11/11/98 BC
	I zrng D QUERY I ER Q 0
	;
	; Set up archive info
	F I=1:1:$L(frm,",") D
	.	; archinfo = archive table | archive key name 
	.	;            | keys up to archive key | archive table class
	.	;            | archive directory variable name
	.	;            | using index
	.	;            | $$getArchiveFile^RecordTABLE code if using index (for LOAD^SQLDD)
	.	N archinfo,archkey,archTbl,gbl,keys,table,td
	.	S table=$P(frm,",",I) I $D(vAlias(table)) S table=vAlias(table)
	.	S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
	.	S archTbl=$$getArchiveTable^DBARCHIVE(td)
	.	Q:archTbl=""
	.	S archinfo=archTbl
	.	S archkey=$$getArchiveKey^DBARCHIVE(td,1)		; Archive key #
	.	S keys=$P(td,"|",3)
	.	S $P(archinfo,"|",2)=$P(keys,",",archkey)
	.	S $P(archinfo,"|",3)=$P(keys,",",1,archkey-1)
	.	S $P(archinfo,"|",4)="Record"_archTbl
	.	S gbl=$P($P(td,"|",2),"(",1)
	.	; Using index?
	.	I gbl'=$P(vsql("I",table),"(",1) S $P(archinfo,"|",6)=1
	.	E  S $P(archinfo,"|",6)=0
	.	S vsql("ARCH",table)=archinfo
	;
	S plan=vsql("I")
	F I=1:1:$L(plan,",") D ACCESS($P(plan,",",I),"") I ER Q
	I ER Q 0
	;
	I zrng D QUERY I ER Q 0
	;
	I ojflg'="" D					; Outer flag pointer
	.	;
	.	N expr1,expr2
	.	S exe=exe+1,exe(exe)="S "_ojflg_"=1"
	.	S ojqry=""
	.	;
	.	F i=1:1:$L(frm,",") S file=$P(frm,",",i) I $D(join(file,1)) D
	..		;
	..		S (expr1,expr2)=""
	..		D MAPVSQL(.expr1,.expr2,file,.jkeys,.vsub)
	..		I expr1'="" S exe=exe+1,exe(exe)="S "_expr1
	..		S exe=exe+1,exe(exe)="I "_join(file,1)_"="_nullsymbl_" S "_expr2
	;
	I $D(ojqry)>9 D OUTJOIN^SQLA(.exe,.fsn,.join,.vsub,.ojqry)
	;
	S vsql("P")=exe					; Access Pointer
	;
	I vxp<0 D					; Max one record will match
	.	;
	.	S oby="",all=1				; Hard to sort one record
	.	I mode<0 S vsql("O")=1			; Compile mode only 03/10/2000
	.	I mode'=-2 S exe=exe+1,exe(exe)="S vsql(0)=100"
	;
	S vsql("K")=$O(vsql(999),-1) 			; Last key variable
	;
	D EXEC^SQLG 
	;
	; ^SQLCOL was called from EXEC^SQLG if query contains group by clause, so 
	; it requires to kill/clean fma and cmp before it calls again ^SQLCOL 
	; as they will be set/generated by SQLCOL again.
	;
	K vsql("AG"),fma,cmp
	;
  	D ^SQLCOL(.exe,,frm,.sel,"vd",,.tok,.fsn,.fma,.cmp,.vsub,.vdd,,.subqry)
	I ER Q 0					; Select Error
	;
	S vsql(0)=vxp+1 I vsql(0)=0 S vsql(0)=1		; Bottom key return
	;
	I oby'=""!'all,mode>-2 D SORT I ER Q 0		; Build Sort code
	;
	D ADDCODE^SQLAGFUN				; Add aggregate function code
	D ADDCODE^SQLG					; Add "group By" code to executable routine
	;
  	I $D(vsql("prot")) D CHGEXEC^SQLPROT(.exe,$G(par("PROTECTION")))
	I $G(par("SAVSYM"))'="" D SAVSYM		; Save symbols!!
	I $G(par("FORMAT"))'="" S vsql("F")=$$VSQLF^SQLCOL(.par)
	;
	I mode<0 Q 1					; Don't process
	Q $$RESULT					; Interactive
	;
	;----------------------------------------------------------------------
ACCESSRTS(sqlfrm,sqlwhr,sel,mode)
	;----------------------------------------------------------------------
	; If not generating compiler code (mode = -1), attempt to patch the FROM
	; and WHERE clause for any table using selectRestrict.  Do not patch if
	; any of the following conditions are true:
	;
	;	- there is already a join and at least one selectRestrict
	;	  uses a join
	;
	;	- DQMODE is set and at least one selectRestrict uses a join
	;
	;	- the select list has MAX or MIN and there is a join
	;
	; In these cases, use the compiler code generation access rights checking
	; method.
	;
	; Note that if we are not generating compiler code we are generating this
	; code for a specific userclass, which is what the selectRestrict clause
	; will be related to.
	;
	; ARGUMENTS:
	;	. sqlfrm - From clause			/MECH=RW
	;		   Will be modified if able to
	;		   patch with selectRestrict joins
	;
	;	. sqlwhr - Where clause			/MECH=RW
	;		   Will be modified to include
	;		   selectRestrict clauses, if possible
	;
	; RETURN:
	;	. $$	0 = patched, so don't include access rights checking
	;		    in generated code
	;		1 = not patched, include access rights checking in
	;		    generated code (see ACCESS section)
	;
	;
	N fpatched,frm,hasAGfun,hasJoin,I,isDone,isDQmode,joinclause,newfrm
	N newwhr,origwhr,patched,restrict,rights,tbl,wpatched
	;
	S hasAGfun=((sel["MAX(")!(sel["MIN("))
	S hasJoin=(sqlfrm[" JOIN ")
	S isDQmode=$G(par("DQMODE"))
	S (isDone,fpatched,wpatched)=0
	;
	; Get all tables involved
	S frm=$$^SQLJ(sqlfrm,"",.fsn,"",.tok)
	;
	; Since the only time we'll patch the from clause is if it's a simple
	; list of table (no joins), we will build newfrm and use it at the
	; end, if we can.  We'll add restrict clauses as AND conditions to
	; the where clause
	S newfrm=""
	S newwhr=$G(sqlwhr)
	F I=1:1:$L(frm,",") D  Q:isDone
	.	S tbl=$P(frm,",",I)
	.	S vsql("SELRTS",tbl)=$$GETSELRTS(tbl)
	.	I vsql("SELRTS",tbl)'="selectRestrict" S newfrm=newfrm_tbl_"," Q
	.	; The following will throw an error if the RecordTABLE code
	.	; is not generated.  This is appropriate since it must be if
	.	; there is a selectRestrict clause
	.	X "S rights=$$vselectAccess^Record"_tbl_"(%UCLS,.restrict,.joinclause)"
	.	; Not selectRestrict for this userclass
	.	I rights'=2 S newfrm=newfrm_tbl_"," Q
	.	; Otherwise, it is, so try to patch from and where, as appropriate.
	.	; These are conditions that don't allow us to patch
	.	I joinclause'="",hasJoin!isDQmode!hasAGfun S isDone=1 Q
	.	I joinclause'="" S newfrm=newfrm_joinclause_",",fpatched=1
	.	E  S newfrm=newfrm_tbl_","
	.	; Add restrict clause to where
	.	I newwhr="" S newwhr=$$SQL^%ZS(restrict,.tok)
	.	E  S newwhr="("_newwhr_") AND ("_$$SQL^%ZS(restrict,.tok)_") "
	.	S wpatched=1
	;
	; If isDone there is a selectRestrict with join we could not patch,
	; so return 1 to ensure 
	I isDone Q 1
	;
	; If from patched there are selectRestricts with joins were were able
	; to patch.  Otherwise, just use the original from.
	I fpatched S sqlfrm=$E(newfrm,1,$L(newfrm)-1)
	I wpatched S sqlwhr=newwhr
	; If we didn't do any patching, no selectRestricts, so no need to
	; consider to include in compiler code.
	; 
	Q 0
	;
	;----------------------------------------------------------------------
GETSELRTS(table)	; Get SELECT access rights for this table
	;----------------------------------------------------------------------
	; Wrapper for calling vcheckAccessRights^RecordTABLE and returning
	; only select related right
	;
	; RETURN:
	;	. $$	"" = no select restrictions
	;		select = has select restrictions
	;		selectRestrict = has selectRestrict restrictions
	;
	N rights,td
	;
	I $D(vAlias(table)) S table=vAlias(table)
	S td=$$getPslTbl^UCXDD(table,0)
	S rights=$$checkAccessRights^UCXDD(td,0)
	;
	I rights["selectRestrict" Q "selectRestrict"
	I rights["select" Q "select"
	Q ""
	;	
	;----------------------------------------------------------------------
RDB(exe,sqlfrm,sel,sqlwhr,sqloby,grp,par,tok,mode,vdd,sqlcur,subqry)
	;----------------------------------------------------------------------
	; Process Select on RDB
	;
	N ddref,maxNum,sqlx,vExpr,vList,vMap,vStatus
	S maxNum=1900	; Maximum string size permitted for indirection
	I $G(par("PROTECTION")) D PROT(sqlfrm,.sel) I ER Q 0
	S sel=$$QSUB^%ZS($$UNTOK^%ZS(sel,.tok))	;Untokenize and remove quotes.
	S ddref=sel I $E(ddref,1,9)="DISTINCT " S ddref=$E(ddref,10,$L(ddref))
	S sqlwhr=$$QSUB^%ZS($$UNTOK^%ZS($G(sqlwhr),.tok))
	S sqlfrm=$$QSUB^%ZS($$UNTOK^%ZS($G(sqlfrm),.tok))
	S sqloby=$$QSUB^%ZS($$UNTOK^%ZS($G(sqloby),.tok))
	S grp=$$QSUB^%ZS($$UNTOK^%ZS($G(grp),.tok))
	I $E(sqloby,1,3)="BY " S sqloby=$E(sqloby,4,$L(sqloby))
	I sel="" S sel="*"
	S vStatus=1
	S vsql(0)=0
	I $G(par("FORMAT"))'="" S vsql("F")=$$VSQLF^SQLCOL(.par)
	D RDBvsql(sqlfrm,sel)	;set up vsql("D") and vsql("A")
	S exe=$g(exe)+1
	S exe(exe)="N vER,vExpr,vList,vRM",exe=exe+1
	S vExpr=$$RsDyRT^UCDBRT(sel,sqlfrm,$G(sqlwhr),$G(sqloby),$G(grp),$G(par),.vMap)
	S vList=$$RsMsXV^UCDBRT(.vMap,.vExpr,1)
	I $L(vList)<maxNum S exe(exe)="S vList="_vList,exe=exe+1
	E  D vList(vList,.exe,maxNum)  ; split up large strings into multiple exe entries
	S exe(exe)="set vExpr="""_$E(vExpr,1,maxNum)_"""",exe=exe+1
	F i=maxNum:maxNum:$l(vExpr) set exe(exe)="set vExpr=vExpr_"""_$E(vExpr,i+1,i+maxNum)_"""",exe=exe+1
	;
	S exe(exe)="I $G(sqlcur)="""" S sqlcur=0",exe=exe+1
	S exe(exe)="S vER=$$OPENCUR^%DBAPI("""",vExpr,$C(9),vList,.vCurID,.vd,.vRM)",exe=exe+1
	S exe(exe)="I 'vER S vsql(""vCurID"")=vCurID",exe=exe+1
	S exe(exe)="I vER S vsql=-1",exe=exe+1
	S exe(exe)="S vsql(""Z"")=1",exe=exe+1
	S exe(exe)="S vCurID=$G(vsql(""vCurID""))",exe=exe+1
	S exe(exe)="S:'$G(vsql(""Z"")) vER=$$FETCH^%DBAPI("""",vCurID,1,$C(9),.vd,.vRM) S vsql(""Z"")=0",exe=exe+1
	S exe(exe)="S vsql(0)="_(exe-2),exe=exe+1	; set vsql(0) to point to fetch for the next record
	S exe(exe)="I vER S vsql=-1"
	I $D(vsql("prot")) D CHGEXEC^SQLPROT(.exe,$G(par("PROTECTION")))
	S vsql("K")=$O(vsql(999),-1)
	Q vStatus
	;
vList(vList,exe,maxNum)
	N del,i,segments
	S del="_$C(9)_"
	S segments=$L(vList,del)
	S exe(exe)="S vList="_$P(vList,del,1,(segments\2)),exe=exe+1
	S exe(exe)="S vList=vList"_del_$P(vList,del,segments\2+1,segments),exe=exe+1
	Q
	;----------------------------------------------------------------------
RDBvsql(frm,sel)	;Set up vsql array entries "A" and "D" for RDB
	;----------------------------------------------------------------------
	N ddref,dec,i,prepare,ret,typ,vpack,x
	;
	S vsql("D")="",vsql("A")=""
	S prepare=$G(par("PREPARE"))  			; ODBC/JDBC qualifier
	I $E(sel,1,9)["DISTINCT " S sel=$E(sel,10,$L(sel))
	I sel="*" S sel=$$COLLIST^DBSDD(frm,0,1,0)
	F i=1:1 S ddref=$$TRIM^%ZS($P(sel,",",i)) Q:ddref=""  D
	.	N di,cmp,dec,fid,len,x
	.	S (typ,dec)=""
	.	I ddref["(" S ddref=$P($P(ddref,"(",2),")",1)
	.	I ddref?.N!(ddref?1"."1N.N)!(ddref?1N.N1".".N) S fid=""  ;num lit - leave it alone.
	.	E  I ddref["." D
	..		S fid=$P(ddref,".",1)
	..		S ddref=$P(ddref,".",2)
	.	E  D RDBcol(frm,ddref,.fid)
	.	;
	.	S ret=$$MCOL^SQLCOL(ddref,fid,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok)
	.	Q:ER
	.	I typ="" S typ="T"
	.	I dec="" S dec=0
	.	S vsql("D")=vsql("D")_typ_+dec
	.	I prepare=1 D  I ER Q
	..		N z1 S z1=$$PREPARE^SQLODBC(ddref,fid,.vpack)	; attributes
	..		I $$BSL^SQLUTL(z1)+$$BSL^SQLUTL(vsql("A"))<1022000 S vsql("A")=vsql("A")_z1_$$BYTECHAR^SQLUTL(255) Q
	..		S ER=1,RM=$$^MSG(2079)				; Buffer overflow
	I prepare=3 S vsql("A")=$$COLATT^SQLODBC(frm,vsql("D")) ; Column formats and access keys (PFW/PIA)
	Q
	;
	;-----------------------------------------------------------------------
RDBcol(frm,di,fid)	; Resolve table/column pair
	;-----------------------------------------------------------------------
	; For a given column, locate the table that it belongs to from the 
	; from clause.   
	N i
	S fid=""
	F i=1:1:$L(frm,",") I $D(^DBTBL("SYSDEV",1,$P(frm,",",i),9,di)) S fid=$P(frm,",",i) Q
	Q	
	;
	;-----------------------------------------------------------------------
ACCESS(file,pfile)	;
	;----------------------------------------------------------------------
	;
	I $$CONTAIN(jfiles,file) Q
	;
	N I,fcollate,gbref,hload,kcollate,keys,sok,z
	;
	S z=vsql("I",file)
	;
	S gbref=$P(z,"|",1),sok=$P(z,"|",7),dlevel=$P(z,"|",9)
	S keys=$P(gbref,"(",2,999),gbref=$P(gbref,"(",1)_"("
	;
	I keys="" S gbref=$P(gbref,"(",1) Q
	;
	S fcollate=0,hload=0
	F I=1:1:$L(keys,",") D  Q:ER  I pfile'="",fcollate Q
	.	;
	.	I I>1 S gbref=gbref_","
	.	;
	.	; Add archive file if now active and not using index
	.	I $P($G(vsql("ARCH",file)),"|",5)'="",'$P(vsql("ARCH",file),"|",6),$E(gbref,1,2)'="^|" S gbref="^|"_$P(vsql("ARCH",file),"|",5)_"|"_$E(gbref,2,$L(gbref))
	.	S ddref=$P(keys,",",I),kcollate=0
	.	I $$LITKEY(ddref) S gbref=gbref_ddref S:dlevel dlevel=dlevel-1 Q	;save distict level
	.	I $L(gbref,"""")#2=0 S gbref=gbref_ddref Q
	.	;
	.	S ddref=file_"."_ddref
	.	D COLLATE Q:ER  I pfile'="",fcollate Q
	.	I $G(zrng) D QUERY 
	.	I $D(join) D JOIN(file,pfile)
	Q:ER
	I pfile'="",fcollate Q
	I '(fcollate&kcollate) D TOGGLE			; $D toggle
	;
	I jfiles="" S jfiles=file
	E  I '$$CONTAIN(jfiles,file) S jfiles=jfiles_","_file
	;
	; If we are generating compiler code and there is selectRestrict access,
	; set up check for access to this record.  Need to load base node to pass
	; to vselectOptmOK.  Note that we only need to call the check if this
	; userclass has a restrict clause.
	I inclaccrts,$P(vsql("SELRTS",file),"|",1)="selectRestrict",'$P(vsql("SELRTS",file),"|",3) D
	.	N code,expr,key,nod,outer,rectyp,symbl
	.	S symbl="vsql("_$$NXTSYM_")"
	.	S rectyp=$P(fsn(file),"|",4)
	.	I rectyp'=10 S nod=" "
	.	E  S nod=$P(fsn(file),"|",12)		; Exists node
	.	I nod'="" D
	..		S fsn(file,nod)=symbl
	..		S outer=$G(join(file))
	..		D LOAD^SQLDD(file,.fsn,.exe,1,.fma,outer,.vsub,.cmp)
	.	E  S exe=exe+1,exe(exe)="S "_symbl_"="""""
	.	S code=symbl
	.	F I=1:1:$L(keys,",") S key=$P(keys,",",I) I '$$LITKEY(key) S code=code_","_vsub(file_"."_key)
	.	S exe=exe+1,exe(exe)="I "_$P(vsql("SELRTS",file),"|",2)_",'$$vselectOptmOK^Record"_file_"(%UCLS,"_code_") S vsql="_vxp
	.	S $P(vsql("SELRTS",file),"|",3)=1	; Flag that we've already done this
	;
	I $G(zrng) D QUERY 
	I $D(join) D JOIN(file,pfile)
	Q
	;
	;----------------------------------------------------------------------
COLLATE	; Build collating section
	;----------------------------------------------------------------------
	;
	N I,archfile,archinfo,archtbl,archkey,archlast,arfilcod,col,eof1,eof2
	N gtail,lvn,lvnval,min,max,opmin,opmax,ord,tbl,type,vxparch
	;
	I $D(join(ddref)),$$JOINED(ddref,.join,.vsub) Q
	I $D(vsub(ddref)) S gbref=gbref_vsub(ddref) Q 	; this key has already been processed
	;
	I pfile="" S access=$$ADDVAL(access,ddref)
	;
	S v=$$GETVAL(ddref,"=",.rng)
	;
	I v[$C(1) S v=$$SUBDINAM(.v,.vsub)
	;
	I v'="" D  Q		; String Literal
	.	;
	.	I sok S access=$$SUBVAL(access,ddref)
	.	E  S vsub(ddref)=v,rng=$$QRYB(ddref,"=",.rng)
	.	S gbref=gbref_$S(v="""""":nullsymbl,1:v)
	.	I $G(dlevel) S dlevel=dlevel-1
	.	; May be direct access to archive key level, handle that here
	.	S tbl=$P(ddref,".",1)
	.	S archinfo=$G(vsql("ARCH",tbl))
	.	Q:archinfo=""
	.	N isindex
	.	S archkey=$P(archinfo,"|",2)
	.	S archtbl=$P(archinfo,"|",1)
	.	S isindex=$P(archinfo,"|",6)		; Using index
	.	;
	.	I archkey=$P(ddref,".",2) D
	..		N i,joined,key,keys
	..		S archfile="vsql("_$$NXTSYM_")"
	..		; Save archive file pointer for use by other collation levels and LOAD^SQLDD
	..		S $P(archinfo,"|",5)=archfile
	..		S vsql("ARCH",tbl)=archinfo
	..		; Update any joined files as well
	..		S joined=$G(join(ddref))
	..		F i=1:1 S jddref=$P(joined,",",i) Q:jddref=""  D
	...			N jtbl
	...			S jtbl=$P(jddref,".",1)
	...			I $D(vsql("ARCH",jtbl)),$P(vsql("ARCH",jtbl),"|",1)=archtbl,$P(vsql("ARCH",jtbl),"|",2)=archkey S $P(vsql("ARCH",jtbl),"|",5)=archfile
	..		; Build code for $$NEXTARCH
	..		S keys=$P(archinfo,"|",3)
	..		S arfilcod="$$getArchiveFile^"_$P(archinfo,"|",4)_"("""_tbl_""",0,"
	..		; Add keys up to archive key
	..		F i=1:1 S key=$P(keys,",",i) Q:key=""  S arfilcod=arfilcod_vsub(tbl_"."_key)_","
	..		; Add archive key
	..		S arfilcod=arfilcod_$S(v="""""":nullsymbl,1:v)_")"
	..		S exe=exe+1
	..		S exe(exe)="S "_archfile_"="_arfilcod
	..		;I isindex S $P(vsql("ARCH",tbl),"|",7)=arfilcod
	.	; Consider archive from here on in collation sequence
	.	if 'isindex,$P(archinfo,"|",5)'="",gbref'["^|" S gbref="^|"_$P(archinfo,"|",5)_"|"_$E(gbref,2,$L(gbref))
 	;
	S (fcollate,kcollate)=1
	;
	I pfile'="" Q
	;
	I jfiles'="",'hload D FINDINAM^SQLCOL(.exe,jfiles,.sel,.tok,.fsn,.fma,.cmp,.vsub,.vdd) S hload=1
	;
	S ord=$S($P($P(oby,ddref,2),",",1)[" DESC":-1,1:1)
	I oby'[ddref,oby[" DESC",$P($$DI^SQLDD($P(oby," ",1)),"|",23)=1 S ord=-1
	;
	F opmin=">","'<" S min=$$GETVAL(ddref,opmin,.rng) S:min[$C(1) min=$$SUBDINAM(.min,.vsub) I min'="" I 'sok S rng=$$QRYB(ddref,opmin,.rng) Q
	F opmax="<","'>" S max=$$GETVAL(ddref,opmax,.rng) S:max[$C(1) max=$$SUBDINAM(.max,.vsub) I max'="" I 'sok S rng=$$QRYB(ddref,opmax,.rng) Q
 	;
	I $G(rng(ddref))="" S num=(min=+min&(max=+max))
	E  S num="N$DCL"[rng(ddref)
	;
	I $D(rng(ddref,"I"))!$D(rng(ddref,"=ANY")) D LIST Q
	;
	S lvn="vsql("_$$NXTSYM_")",vsub(ddref)=lvn,v255(lvn)=""
	S gbref=gbref_lvn
	;
	S tbl=$P(ddref,".",1)
	; archkey'="" acts as indicator that dealing with archive key level
	S archinfo=$G(vsql("ARCH",tbl))
	I archinfo="" S archkey=""
	E  D
	.	N isindex
	.	S archtbl=$P(archinfo,"|",1)
	.	S archkey=$P(archinfo,"|",2)
	.	S isindex=$P(archinfo,"|",6)		; Using index
	.	I archkey'=$P(ddref,".",2) S archkey=""
	.	E  D
	..		N i,joined,key,keys
	..		S archlast="vsql("_$$NXTSYM_")"
	..		S archfile="vsql("_$$NXTSYM_")"
	..		; Save archive file pointer for use by other collation levels and LOAD^SQLDD
	..		S $P(archinfo,"|",5)=archfile
	..		S vsql("ARCH",tbl)=archinfo
	..		; Update any joined files as well
	..		S joined=$G(join(ddref))
	..		F i=1:1 S jddref=$P(joined,",",i) Q:jddref=""  D
	...			N jtbl
	...			S jtbl=$P(jddref,".",1)
	...			I $D(vsql("ARCH",jtbl)),$P(vsql("ARCH",jtbl),"|",1)=archtbl,$P(vsql("ARCH",jtbl),"|",2)=archkey S $P(vsql("ARCH",jtbl),"|",5)=archfile
	..		; Build code for $$NEXTARCH
	..		S keys=$P(archinfo,"|",3)
	..		S arfilcod="$$getArchiveFile^"_$P(archinfo,"|",4)_"("""_tbl_""",0,"
	..		; Add keys up to archive key
	..		F i=1:1 S key=$P(keys,",",i) Q:key=""  S arfilcod=arfilcod_vsub(tbl_"."_key)_","
	..		; Add archive key
	..		S arfilcod=arfilcod_$S('isindex:archlast,1:lvn)_")"
	..		I isindex D
	...			S $P(vsql("ARCH",tbl),"|",7)=arfilcod
	...			S archkey=""		; Signal not to add archive info
	.	; Consider archive from here on in collation sequence
	.	if 'isindex,$P(archinfo,"|",5)'="",gbref'["^|" S gbref="^|"_$P(archinfo,"|",5)_"|"_$E(gbref,2,$L(gbref))
	;
	S col="S "
	I archkey'="" S col=col_archlast_"="_lvn_","
	S col=col_lvn_"=$O("_gbref_"),"_ord_")"
	S eof1=" I "_lvn_"=""""",eof2=""
	;
	; Set up code to stop collating when reach min or max value
	; Note that may be applied at archive file collation if archive key
	I ord<0,min'="" D
	.	I opmin=">" S eof2="("_$S(num:lvn_"'>"_min,1:lvn_"']]"_min)_")"
	.	I opmin="'<" S eof2="("_$S(num:lvn_"<"_min,1:min_"]]"_lvn)_")"
	I ord>0,max'="" D
	.	I opmax="<" S eof2="("_$S(num:lvn_"'<"_max,1:max_"']]"_lvn)_")"
	.	I opmax="'>" S eof2="("_$S(num:lvn_">"_max,1:lvn_"]]"_max)_")"
	;
	S lvnval=$S(ord<0:$S(max="":"""""",1:max),1:$S(min="":"""""",1:min))
	S exe=exe+1,exe(exe)="S "_lvn_"="_lvnval
	;
	; Determine starting archive directory.  If going forward and starting
	; from null, start in primary
	;
 	I $D(join(file))#2,$$DROPTHRU
	;
	E  D
	.	; Deal with starting point that includes an equals test
	.	; If match equals, skip collation line
	.	; Set up for archiving to start with right archive file
	.	; If archiving, need to skip archive file collation too
	.	I ((ord<0)&(max'="")&(opmax="'>"))!((ord>0)&(min'="")&(opmin="'<")) D
	..		; Add code to get archive file for equals test
	..		I archkey'="" S exe(exe)=exe(exe)_","_archlast_"="_lvn_","_archfile_"="_arfilcod
	..		S exe=exe+1
	..		S exe(exe)="I $D("_gbref_"))"
	..		; We need to add the Where condition to the $D check as well.  
	..		; Otherwise we could have a situation where we have a row
	..		; in the result set that doesn't match the Where clause criteria.
	..		S exe(exe)=exe(exe)_$S(eof2'="":",'"_eof2,1:"")_" S vsql=vsql+"_$S(archkey="":1,1:3)
	..		I archkey'="" D
	...			S exe=exe+1
	...			S exe(exe)="E  S vsql=vsql+1"
	.	E  I archkey'="" D
	..		; Add code to get first archive file and skip collating line
	..		N code
	..		; Reverse, from null, start in primary file, else find file
	..		I ord<0 D
	...			I lvnval="""""" S code=archfile_"="""""
	...			E  S code=archlast_"="_lvn_","_archfile_"="_arfilcod
	..		; Forward, from null, find first archive, else find file
	..		E  D
	...			I lvnval="""""" S code=archlast_"="""","_archfile_"="_arfilcod
	...			E  S code=archlast_"="_lvn_","_archfile_"="_arfilcod
	..		set exe(exe)=exe(exe)_","_code_" S vsql=vsql+1"
	.	;
	.	; Set up archive file collation
	.	I archkey'="" D
	..		N lstarfil
	..		S exe=exe+1
	..		S $P(arfilcod,",",2)=ord	; Set order
	..		S exe(exe)="S "
	..		; If in forward order, can't stop when get to archive file
	..		; = null since that's the primary.  Need to go through that
	..		; and then stop on next iteration against archive files
	..		I ord>0 D
	...			S lstarfil="vsql("_$$NXTSYM_")"
	...			S exe(exe)=exe(exe)_lstarfil_"="_archfile_","
	..		S exe(exe)=exe(exe)_archfile_"="_arfilcod_" I "_$S(ord<0:archfile,1:lstarfil)_"="""""
	..		S exe(exe)=exe(exe)_" S vsql="_vxp
	..		S vxparch=vxp
	..		S vxp=exe-1
	.	; Now, add collation line
	.	S exe=exe+1
	.	S exe(exe)=col_eof1_$S(archkey=""&(eof2'=""):"!"_eof2,1:"")_" S vsql="_vxp
	.	S vxp=exe-1
	.	S vsql("COL",exe)=""  ;keep track of collating sequence for each key - pc 6/20/01
	.	;
	.	; If on archive key and have early stop (eof2), add code for that
	.	I archkey'="",eof2'="" D
	..		S exe=exe+1
	..		S exe(exe)="I "_eof2_" S vsql="_vxparch
	;
	I $g(zrng) D QUERY		; 02/15/2000
	Q
	;
	;----------------------------------------------------------------------
JOINED(ddref,join,vsub)	; Merge on key if joined
	;----------------------------------------------------------------------
	;
	N v
	S v=$$VSUBREF(ddref,.vsub,.join) I v="" Q 0		; Not joined
	S gbref=gbref_v,vsub(ddref)=v
	S jkeys(ddref)=$L(access,",")
	S rng=$$QRYB(ddref,"J",.rng)
	Q 1
	;
	;----------------------------------------------------------------------
VSUBREF(ddref,vsub,join)	; Return vsub(ddref) or joined reference
	;----------------------------------------------------------------------
	;
	I $D(vsub(ddref)) Q vsub(ddref)
	;
	N i,v,z
	S z=$G(join(ddref))
	F i=1:1:$L(z,",") S v=$G(vsub($P(z,",",i))) I v'="" Q
	Q v
	;
	;----------------------------------------------------------------------
DROPTHRU()	; Drop through to print if nothing at this key level
	;----------------------------------------------------------------------
	;
	N flag
	S flag=1					; Drop through flag
	;
	I $D(rng(ddref)) D  				; Check for JOIN ON
	.	;
	.	N oprelat,list,i,ptr,v
	.	S oprelat="",list="",flag=0
	.	F  S oprelat=$O(rng(ddref,oprelat)) Q:oprelat=""  D
	..		;
	..		S ptr=rng(ddref,oprelat)
	..		I $P(whr(ptr),$C(9),5)=1 S flag=1
	..		E  S list=$$ADDVAL(list,ptr)
	.	;
	.	I flag=1 F i=1:1:$L(list,",") D		; Add WHERE queries back
	..		;
	..		S v=$P(list,",",i)
	..		S rng=$E(rng,1,v-1)_1_$E(rng,v+1,$L(rng))
	;
	I flag=0 Q 0					; No JOIN ON
	;b
	N eof3,init,v,vxpo
	I ojflg="" D
	.	S ojflg="vsql("_$$NXTSYM_")"
	.	S init="S "_ojflg_"=0 " ; ,ojqry=ojflg
	.	I file=$P(vsql("I"),",",1) S eof3="!1"
	;
 	S v="vsql("_$$NXTSYM_")"		; EOF indicator
	S exe=exe+1,exe(exe)=$G(init)_"S "_v_"=0"
	S exe=exe+1,exe(exe)="I "_v_" S vsql="_vxp
	S vxpo=vxp,vxp=exe-1
	;
	I $D(join(file,1)) D			; Multi-key
	.	;
	.	S exe=exe+1
	.	S exe(exe)="I "_join(file,1)_"="""" S "_v_"=1"
	.	S col="E  "_col
	;
	S join(file,1)=lvn
	S eof=eof1_$S(eof2'="":"!"_eof2,1:"")
	I ord<0 S:min'="" eof=eof_" S "_lvn_"="""""
	E  S:max'="" eof=eof_" S "_lvn_"="""""
	S exe=exe+1,exe(exe)=col_eof_" S "_v_"=1 I "_ojflg_$G(eof3)_" S vsql="_vxpo
	N dd,keys
	S dd=$P(ddref,".",2)
	S keys=$P(fsn(file),"|",3)
	;;I dd=$P(keys,",",$L(keys,",")) D
	S exe=exe+1
	S exe(exe)="I "_lvn_"="""" S "_lvn_"=$$BYTECHAR^SQLUTL(254)"
	;
	Q 1
	;
	;----------------------------------------------------------------------
RESULT()	; Place cursor before the first row
	;----------------------------------------------------------------------
	;
	I $G(vsql("T")) K ^DBTMP(%TOKEN,sqlcur)
	I '$G(vsql("P")) Q 1				; CUVAR
	;
	S vsql=1
	F  X exe(vsql) S vsql=vsql+1 Q:vsql=0!(vsql>vsql("P"))
 	I vsql=0 S vsql(0)=100 Q 0
	Q (vsql("P")+1)
	;
	;----------------------------------------------------------------------
JOIN(file,pfiles)	; Join Files bases on current collating level
	;----------------------------------------------------------------------
	;
	N I,ddref,flag,jdata,jddref,maxCharV,zddref
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	;
	S ddref=file_".",zddref=ddref_$C(maxCharV)
	;
	S flag=0
	;
	F  S ddref=$O(join(ddref)) Q:ddref=""!(ddref]zddref)  D  Q:ER
	.	;
	.	;I $$CONTAIN(access,ddref) Q
	.	;I $D(jkeys(ddref)) Q
	.	;
	.	S jdata=join(ddref)
	.	F I=1:1:$L(jdata,",") D  I ER Q
	..		;
	..		S jddref=$P(jdata,",",I)
	..		I '$$CONTAIN(pfiles,$P(jddref,".",1)) D JDATA(ddref,jddref,.flag)
	;
	I flag,rng D QUERY
	Q
	;
	;----------------------------------------------------------------------
JDATA(ddref,jddref,flag)	; Substitute a database reference for key expression
	;----------------------------------------------------------------------
	;
	I '$D(vsub(ddref)),'$$CONTAIN(jfiles,$P(ddref,".",1)) Q
	;
	N I,gbref,jfile,ok,z
	;
	S jfile=$P(jddref,".",1),jkeys=$P(vsql("I",jfile),"|",2)
	;
	I '$$CONTAIN(jkeys,$P(jddref,".",2)) Q		; Non-key join
	;
	S jkeys(jddref)=$L(access,",")
	S flag=1
	;
	S rng=$$QRYB(ddref,"J",.rng)
	;
	I $D(vsub(ddref)) D ACCESS(jfile,file_","_pfile) Q
	;
	N NS,v0,x
	S NS=$$PARSE^SQLDD(.ddref,.x,.cmp,.fsn,.frm,.vdd,,.vsub) I ER Q
	;
	D LOAD
	;
	S v0="vsql("_$$NXTSYM_")"
	S vsub(jddref)=v0
	S v255(v0)=""
	;
	S z="S "_v0_"="_NS_" I "_v0_"="""" S "_v0_"="_nullsymbl
	;
	S exe=exe+1
	S exe(exe)=z
	;
	D ACCESS(jfile,file_","_pfile)
	Q
	;
	;----------------------------------------------------------------------
TOGGLE	; Toggle logic for bottom level literal to avoid infiloop
	;----------------------------------------------------------------------
	;
	;
	S z=gbref
	;
	I $P(fsn(file),"|",12)'="",$P(z,"(",1)=$P($P(fsn(file),"|",2),"(",1) S z=z_","_$P(fsn(file),"|",12)
	;
	; If archive enabled file, but global missing extended reference, add it
	I $D(vsql("ARCH",file)),z'["^|" D
	.	N archinfo,ext,i,key,keys
	.	S archinfo=vsql("ARCH",file)
	.	; Call ARCHFILE to get archive file this record would be in
	.	S ext="^|$$getArchiveFile^"_$P(archinfo,"|",4)_"("""_file_""",0,"
	.	; Construct keys up to archive key
	.	S keys=$P(archinfo,"|",3)
	.	F i=1:1 S key=$P(keys,",",i) Q:key=""  S ext=ext_vsub(file_"."_key)_","
	.	; Add archive key
	.	S ext=ext_vsub(file_"."_$P(archinfo,"|",2))_")|"
	.	S z=ext_$E(z,2,$L(z))
	;
	S z="I '($D("_z_$S($P(z,"(",2)'="":"))",1:")")
	;
	; The #2 or >9 check is only valid if the expression contains equality checks
	; for all keys in the table.
	I ($L(z,",")=$L($P(fsn(file),"|",2),",")) D
	.	I $P(fsn(file),"|",4)=1 S z=z_"#2"	; record type 1
	.	E  I $P(fsn(file),"|",4)=10 S z=z_">9"	; record type 10
	S z=z_")"
	;
	I $D(join(file))#2 D
	.	;
	.	N expr1,expr2
	.	S expr1="",expr2=""
	.	D MAPVSQL(.expr1,.expr2,file,.jkeys,.vsub)
	.	I expr1'="" S exe=exe+1,exe(exe)="S "_expr1
	.	I expr2'="" S z=z_" S "_expr2
	.	;
	.	I $D(join(file,1)) D
	..		;
	..		S exe=exe+1
	..		S exe(exe)="I "_join(file,1)_"="_nullsymbl_" S "_expr2
	..		S z="E  "_z
	;
	E  S z=z_" S vsql="_vxp
	;
	S exe=exe+1,exe(exe)=z
	Q
	;--------------------------------------------------------------------
MAPVSQL(expr1,expr2,alias,jkeys,vsub,fsn,fma)	; Re-Map keys 
	;--------------------------------------------------------------------
	;
	N ddref,gblref,maxCharV,nod,zddref,v,v0
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	S ddref=alias_".",zddref=ddref_$C(maxCharV),gblref=""
	;
	F  S ddref=$O(vsub(ddref)) Q:ddref=""!(ddref]zddref)  D
  	.	;
	.	S v=vsub(ddref)
	.	;I $D(v255(v)) Q
	.	I $E(v,1,4)="vsql",$G(jkeys(ddref))=$L(access,",") D  I v="" Q
	..		;
	..		N z S z=""
	..		F  S z=$O(vsub(z)) Q:z=""  I z'=ddref,vsub(z)=v Q
	..		E  S expr2=$$ADDVAL(expr2,v_"="_nullsymbl),v=""
	.	;
	.	S v0="vsql("_$$NXTSYM_")"
	.	S expr1=$$ADDVAL(expr1,v0_"="_v)
	.	S expr2=$$ADDVAL(expr2,v0_"="_nullsymbl),v255(v0)=""
	.	S vsub(ddref)=v0
	.	;
	.	F  S gblref=$O(fma(gblref)) Q:gblref=""  I gblref[v D
	..		;
	..		S z=$P(gblref,v,1)_v0_$P(gblref,v,2,99)
	..		K fma(gblref)
	..		S fma(z)=""
	;
	S v="" 
	F  S v=$O(fsn(alias,v)) Q:v=""  S expr2=$$ADDVAL(expr2,$P(fsn(alias,v),"|",1)_"=""""")
	Q
	;
	;----------------------------------------------------------------------
LIST	; Key is in a list or array format OPTIMIZE!
	;----------------------------------------------------------------------
	;
	N arg,expr,glvn,i,keys,lvn,I,v,v0,v1,v2,zrng
	;
	I $D(rng(ddref,"I")) S expr=$$GETVAL(ddref,"I",.rng),zrng=rng(ddref,"I")	; save whr sequence for LISTB section
	E  I $D(rng(ddref,"=ANY")) S expr=$$GETVAL(ddref,"=ANY",.rng),zrng=rng(ddref,"=ANY")
	I $D(vsub(ddref)) S expr=""	; this key has already been processed
	I expr="" Q
	;
	I 'sok D
	.	I $D(rng(ddref,"I")) S rng=$$QRYB(ddref,"I",.rng)
	.	E  I $D(rng(ddref,"=ANY")) S rng=$$QRYB(ddref,"=ANY",.rng)
	;
	S lvn="vsql("_$$NXTSYM_")"
	;
	I $L(expr,",")=1 S expr=$$UNTOK^%ZS(expr,.tok)
	E  I "^:"[$E(expr),expr?.e1"(".e1"#)"
	E  D  Q
	.	;
	.	S v0="vsql("_$$NXTSYM_")"
	.	;
	.	I expr[$C(0) S expr=$$UNTOK^%ZS(expr,.tok)
	.	I expr["'" S expr=$TR(expr,"'","""")
	.	;					; 06/26/98 BC
	.	I $E(expr)?1A!(expr?.E1":"1A.E) D	; Host variable syntax
	..		S v1="",v2=0
	..		F i=1:1:$L(expr,",") D
	...			S v=$P(expr,",",i)
	...			I $E(v)=":" S v="$G("_$E(v,2,99)_")",v2=1
	...			E  S v2=0
	...			S v1=v1_v_"_"",""_"
	..		S expr="vsql("_$$NXTSYM_")"	; next vsql sequence
	..		S exe=exe+1			; sort list in order
	..		S exe(exe)="S "_expr_"=$$STRSORT^SQLM("_$E(v1,1,$L(v1)-5)_","_ord_")"
	..		I v2 S exe=exe+1,exe(exe)="I "_expr_"="""" S vsql="_vxp	; Check Null value
	..		;
	.	E  D					; numeric or literal
	..		S expr=$$STRSORT(expr,ord,.min,.max)
	..		S expr=$$QADD^%ZS(expr)
	.	S expr="$$NPC^%ZS("_expr_",.v,1)"
	.	;
	.	S exe=exe+1
	.	S exe(exe)="S "_v0_"=0"
	.	S exe=exe+1
	.	S exe(exe)="S v="_v0_","_lvn_"="_expr_","_v0_"=v I v=0 S vsql="_vxp
	.	S vxp=exe-1
	.	S vsql("COL",exe)=""  ;keep track of collating sequence for each key - mk 05/03/04
	.	D LISTB Q
	;
	I "^:"[$E(expr)=0,expr'["#)" S ER=1,RM=$$^MSG(336,expr) Q
	;
	S keys=$P($P(expr,"(",2,999),"#)",1),glvn=$P(expr,"(",1)_"("
	I $E(glvn)=":" S glvn=$E(glvn,2,$L(glvn))	; local array
	;
	F I=1:1:$L(keys,",")-1 D
	.	;
	.	N lvn
	.	S key=$P(keys,",",I)
	.	I $$LITKEY(key) S glvn=glvn_key_"," Q
	.	S lvn="vsql("_$$NXTSYM_")"
	.	D CODE(.glvn,lvn,1)
	;
	D CODE(.glvn,lvn,ord,.min,.max)
	;
LISTB	;
	I $D(join(ddref)) D				; Project over joins 
	.	;
	.	S v=join(ddref)
	.	F I=1:1:$L(v,",") S vsub($P(v,",",I))=lvn
	;
	S vsub(ddref)=lvn
	S gbref=gbref_lvn
	S kcollate=0
	;
	if $G(zrng)'="" D RESETlvn
	Q
	;
RESETlvn  ; If the IN clause contains a subquery with more than one column in the select list,
	; then these columns are concatenated together (delimited by <tab>) to form a single composite
	; key into ^DBTMP.  In order to reference the record in the base table, the
	; value of the lvn variable needs to be reset to pull out of the composite key
	; just the portion that corresponds to the base table's primary key.
	; This is done by matching the name of the ddref with the position of that
	; ddref in piece 1 of the whr array.  For example, if ddref="ZCIDA.CID", then based
	; on the whr array entry below, the value of that column is taken from piece
	; 1 of the composite lvn value that was returned from the ^DBTMP collating code.
	; whr(1)=$C(1)_"ZCIDA.CID"_$C(1,0,1)_"ZCIDA.DESC"_$C(1,9)_"^DBTMP(%TOKEN,sqlcur,1#)"_$C(9)_"I"_$C(9)_"N"_$C(0)_"T"_$C(9)
	; In this case, add code in exe to set lvn to piece 1.
	; S exe(exe)="S "_lvn_"=$P("_lvn_",$C(9),"_i_")"
	N di,i,zlvn,zwhr
	;
	S zwhr=$P(whr(zrng),$C(9),1)
	I zwhr'[$C(0) Q		; only a single column, no special processing necessary
	I $E(zwhr)="(",$E(zwhr,$L(zwhr))=")" S zwhr=$E(zwhr,2,$L(zwhr)-1)	; Strip off parens
	F i=1:1:$L(zwhr,$C(0)) D
	.	S zlvn="vsql("_$$NXTSYM_")"
	.	S exe=exe+1,exe(exe)="S "_zlvn_"=$P("_lvn_",$C(9),"_i_")"
	.	I $TR($P(zwhr,$C(0),i),$C(1))=ddref S vsub(ddref)=zlvn
	.	E  S di=$TR($P(zwhr,$C(0),i),$C(1)) S vsub(di)=zlvn
	;
	S gbref=$P(gbref,lvn,1)_vsub(ddref)	; replace the key variable with the one we just replaced.
	;
	Q
	;----------------------------------------------------------------------
STRSORT(expr,ord,min,max)	; Public ; Sort expression and return
	;----------------------------------------------------------------------
	;
 	N ptr,tmp,exe,vsql,vxp
	S ptr=0,exe=0,vxp=-1
	;
	F  S v=$$NPC^%ZS(expr,.ptr,1) q:ptr=0  I v'="" S tmp(v)=""
 	;
	D CODE("tmp(","v",ord,.min,.max)
	;
	S vsql=1,expr=""
	;
	X exe(1)
	F  X exe(2) Q:vsql=-1  S expr=expr_","_$S(v[","!(v[""""):$$QADD^%ZS(v),1:v)
 	;
	Q $E(expr,2,$L(expr))
	;
	;----------------------------------------------------------------------
QUERY	; Place query expressions into executable
	;----------------------------------------------------------------------
	;
	N mcode,I
	;
 	S ER=0
	;
	D QUERY^SQLA(.rng,.whr,.mcode,.vsub,.jfiles,.fsn,dqm,.ojqry)
	I '$D(mcode)!ER Q
	;
 	D LOADALL I ER Q
	;
	F I=1:1:$G(mcode) S exe=exe+1,exe(exe)=mcode(I)
	Q
	;
	;----------------------------------------------------------------------
SUBDINAM(expr,vsub)	; Replace data item references with data references
	;----------------------------------------------------------------------
	;
	N I,ddref
	;
	F  S ddref=$P(expr,$C(1),2) Q:ddref=""  D
	.	;
	.	I '$$CONTAIN(jfiles,$P(ddref,".",1)) S expr="" Q
	.	I $D(vsub(ddref)) D  I ddref="" Q
	..		;
	..		S ddref=vsub(ddref)
	..		I $A(ddref)=1 S ddref=$P(ddref,$C(1),2) Q
	..		S expr=$P(expr,$C(1),1)_ddref_$P(expr,$C(1),3,999),ddref=""
	.	;
	.	S expr=$P(expr,$C(1),1)_$$PARSE^SQLDD(.ddref,"",.cmp,.fsn,.frm,.vdd,,.vsub)_$P(expr,$C(1),3,999)
	.	I ER S expr="" Q
	;
 	I expr'="" D LOADALL
	Q expr
	;
	;----------------------------------------------------------------------
FETCH(exe,vd,vi,sqlcur)	;public; Fetch Next Record in Results Table
	;----------------------------------------------------------------------
	;
	Q $$^SQLF(.exe,.vd,.vi,.sqlcur)
	;
	;--------------------------------------------------------------------
FETCHBLK(sqlcur,exe,vsql,sqldta,sqlcnt,sqlind,rows)	; Fetch a block of records
	;--------------------------------------------------------------------
	;
	D FETCHBLK^SQLF(.sqlcur,.exe,.vsql,.sqldta,.sqlcnt,.sqlind,.rows) Q
	;
	;----------------------------------------------------------------------
LOADALL	; Load database from multiple tables database
	;----------------------------------------------------------------------
	;
	I $D(exe)#2=0 S exe=$O(exe(""),-1)
	;
	I $G(frm)="" Q
	;
	N file,I
	F I=1:1:$L(frm,",") S file=$P(frm,",",I) D LOAD
	Q
	;
	;----------------------------------------------------------------------
LOAD	; Load database from a single table
	;----------------------------------------------------------------------
	;
	I $D(fsn(file))<10,'$D(cmp(file)) Q
	;
	N expr,outer,I
	S outer=$G(join(file))
	D LOAD^SQLDD(file,.fsn,.exe,1,.fma,outer,.vsub,.cmp)
	Q
	;
	;----------------------------------------------------------------------
SORT	; Sort a Results table
 	;----------------------------------------------------------------------
	;
	N I,NS
	N arg,n,di,ddref,expr,fid,gbl,sort,null,nullchr,keys,key,tmptbl,varnum,z
	;
	S sort=0
	;
	F I=1:1:$L(access,",") S di=$P(access,",",I) I $D(rng(di,"=")) D SUBLIST(di,.access) S I=I-1
	;
	I 'all D  I 'sort S exe=exe+1,exe(exe)="S vsql(0)=100" Q
	.	;
	.	I oby="" S oby=sel			; *****
	.	E  F I=1:1:$L(sel,",") I '$$CONTAIN^SQLM(oby,$P(sel,",",I)) S oby=oby_","_$P(sel,",",I)
	.	;
	.	F I=1:1:$L(sel,",") I '$D(rng($P(sel,",",I),"=")) S sort=1 Q
	;
	S fid=$P(frm,",",1),keys=$P(fsn(fid),"|",3)
	;
        F I=1:1:$L(oby,",") D  I keys="" S oby=$P(oby,",",1,I) Q
        .       ;
        .       S ddref=$P($P(oby,",",I)," ",1)
        .	Q:ddref=""
        .       I $D(rng(ddref,"=")) D SUBLIST(ddref,.oby) S I=I-1 Q
        .       I $P(access,",",I)=ddref Q
	.	I $P($G(vdd(ddref)),"|",23),$P($G(vdd(ddref)),"|",1)=$P($P(access,",",I),".",2) Q		;serial key
        .       I $G(join(ddref))=$P(access,",",I) Q
        .       S sort=1
	;
	I mode=-2,'sort S vsql("O")=-1 Q
	;
	I oby=""!'sort Q
	;
	I all D ADDKEYS(.oby,frm,.fsn,.join) 	; Add Primary Keys
	;
	S tmptbl=$$TMPTBL,gbl=tmptbl
	;
	S expr="",null=""
	;
	F I=1:1:$L(oby,",") S di=$P(oby,",",I) D  I ER Q
	.	;
	.	N isCmp,typ,x
	.	S arg=$P(di," ",2) I arg'="" S di=$P(di," ",1),arg=" "_arg
	.	;
	.	;Commentd to fix the issue :$ZCHAR(254)is displayed insted of empty,so
	.	;comented 2 lines and added 1 line below.
	.	;;I di=sel S NS="vd"
	.	;;E  S NS=$$PARSE^SQLDD(.di,.x,.cmp,.fsn,.frm,.vdd,"",.vsub) Q:ER
	.	S NS=$$PARSE^SQLDD(.di,.x,.cmp,.fsn,.frm,.vdd,"",.vsub) Q:ER
	.	S typ=$$TYP^SQLDD(di,.x,.vdd)
	.	S isCmp=($$CMP^SQLDD(di,.x,.vdd)'="")
	.	;
	.	S nullchr=$S('dqm:nullsymbl,"N$DCL"[typ:0,1:""" """)	
	.	;
	.	I ($E(NS)="$")!isCmp D
	..		;
	..		S z="vsql("_$$NXTSYM_")"
	..		S expr=expr_" S "_z_"="_NS
	..		S NS=z
	.	;
	.	I "$L"[typ S NS="+"_NS			; MUMPS NULL default
	.	S gbl=gbl_","_NS
	.	I  Q
	.	;
	.	I $D(rng(di)),$$GETVAL(di,"=",.rng)'="""" Q
	.	I $$CONTAIN(access,di),$P(di,".",1)=fid Q
	.	;
	.	; 01/19/2009 Pete Chenard
	.	; Treat 'all' versus 'distinct' the same in terms of whether or not
	.	; the row will be returned.  Always replace nulls with $C(254)
	.	;
	.	S null=null_" S:"_NS_"="""" "_NS_"="_nullchr Q
	.	I $$GETVAL(di,"=",.rng)="""" S exe=exe+1,exe(exe)="S vsql=-1"
	;
	I ER S vsql=0 Q
	;
	D LOADALL I ER S vsql=0 Q  ; Load sort data
	;
	I 'all,null'="" D
	.	S expr=expr_null
	.	;
	.	I $E(expr)=" " S expr=$E(expr,2,$L(expr))
	.	S exe=exe+1,exe(exe)=expr
	.	S expr="",null=""
	;
	S expr=expr_null_" S "_gbl_")=vd"
	I $E(expr)=" " S expr=$E(expr,2,$L(expr))
	;
	S exe=exe+1,exe(exe)=expr
	;
	S varnum=0
	N zvxp
	F I=1:1:exe I exe(I)["S vsql=-1",exe(I)["$O"!(exe(I)["$N") S exe(I)=$P(exe(I),"S vsql=-1",1)_"S vsql="_(exe+1) Q
	I $G(dlevel) S zvxp="" F i=1:1:dlevel S zvxp=$O(vsql("COL",zvxp)) Q:zvxp=""
	I $G(zvxp) S vxp=zvxp-1
	S exe=exe+1,exe(exe)="S vsql="_vxp
	;
	S gbl=tmptbl_",",vxp=-1
	;
	F I=1:1:$L(oby,",") D
	.	;
	.	S key=$P(oby,",",I)
	.	S arg=$s($P(key," ",2)="DESC":-1,1:1)
	.	S varnum=varnum+1,key="vsql("_varnum_")"
	.	D CODE(.gbl,.key,arg)
	;
	S vsql(0)=vxp+1,vsql("P")=exe,vsql("K")=varnum,vsql("T")=1
	;
	S exe=exe+1,exe(exe)="S vd="_$E(gbl,1,$L(gbl)-1)_")"
	Q
	;
	;----------------------------------------------------------------------
ADDKEYS(oby,frm,fsn,join)	; Add primary keys required to mantain 1NF
	;----------------------------------------------------------------------
	;
	N ddref,fid,i,j,k,keys
	;
	F I=1:1:$L(frm,",") D
	.	;
	. 	S fid=$P(frm,",",I),keys=$P(fsn(fid),"|",3)
	.	F j=1:1:$L(keys,",") D
	..		;
	..		S ddref=fid_"."_$P(keys,",",j)
	..		I $D(rng(ddref,"=")) Q
	..		I $D(join(ddref)) F k=1:1:$L(oby,",") I $$CONTAIN(join(ddref),$P($P(oby,",",k)," ",1)) Q
	..		E  I oby'[ddref S oby=oby_","_ddref
	;
	Q
	;----------------------------------------------------------------------
CLOSE(sqlcur)	
	; Close a Results Table
	; If on an RDB environment also close the open oracle cursor, vCurID
	; denotes the cursor ID associated with the database cursor. If it is
	; not defined then we are either operating in a M enviroment or the sql
	; cursor was opened on a table that resides in a global.
	;----------------------------------------------------------------------
	I $G(sqlcur)="" S ER=1,RM=$$^MSG(8564,"CLOSE") Q  	; *** 04/25/97
	I $D(vsql("vCurID")) D
	.	N ER,RM			; Ignore cursor not opened error
	.	S ER=$$CLOSECUR^%DBAPI("",vsql("vCurID"))
	E  I $$isRdb^vRuntime() D
	.	N ER,RM			; Ignore cursor not opened error
	.	N exe,vsql		; Only need to load to allow RDB close
	.	N sqlcnt,sqldta		; Do not want RESTORE to modify these
	.	D RESTORE^SQLUTL(sqlcur,.vsql,.exe)
	.	I $D(vsql("vCurID")) S ER=$$CLOSECUR^%DBAPI("",vsql("vCurID"))
	I $G(%TOKEN)="" N %TOKEN S %TOKEN=$J
	K ^DBTMP(%TOKEN,sqlcur)			; Delete temp sort file
	D CLOSE^SQLUTL(%TOKEN,sqlcur)		; Procedural code associated
	Q					; with this cursor
	;
	;----------------------------------------------------------------------
CONTAIN(P1,P2)	; Returns position of string P2 in P1
	;----------------------------------------------------------------------
	;
	S P1=","_P1_",",P2=","_P2_","
	I P1[P2 Q $L($P(P1,P2,1),",")
	Q 0
	;
	;-----------------------------------------------------------------------
SUBLIST(DI,SEL)	; Subtract a Data Item frm a sel
	;-----------------------------------------------------------------------
	;
	N I,z
	F I=1:1:$L(SEL,",") I $P($P(SEL,",",I)," ",1)=DI D  Q
	. S z=$P(SEL,",",I+1,999)
	. S SEL=$P(SEL,",",1,I-1)
	. I SEL'="",z'="" S SEL=SEL_","
	. S SEL=SEL_z
	Q
	;
	;----------------------------------------------------------------------
VIEW(fid,whr,fsn)	; Process file view query
	;----------------------------------------------------------------------
	;
	N tbl,X
	;
	S lib="SYSDEV"
	S tbl=$S($D(vAlias(fid)):vAlias(fid),1:fid)
	S X=$P($G(^DBTBL(lib,1,tbl,14)),"|",1)      ; File control page 
	;
	I X'="" D
	.	;
	.	set X=$TR(X,"""","'") 			; Patch untill in SQL
	.	set X=$$SQL^%ZS(X,.tok)
	.	;
	.	new ls
	.	set ls=$O(whr(""),-1)+1
	.	do ^SQLQ(X,fid,.whr,.rng,.mode,.tok,.fsn,.vdd,($D(join(fid))#2))
	.	if $O(whr(""),-1)=ls set join(0,fid)=ls
	;
	I $G(par("PROTECTION")),$D(^DBTBL(lib,14,tbl,"*")) D 
	.	;
	.	S X=$$VIEW1^SQLPROT(fid)
	.	S X=$$SQL^%ZS(X,.tok)
	.	D ^SQLQ(X,fid,.whr,.rng,.mode,.tok,.fsn,.vdd,($D(join(fid))#2))
	;
	Q
	;
NXTSYM()	N z S z=$O(vsql(1E18),-1)+1,vsql(z)="" Q z
	;----------------------------------------------------------------------
CODE(glvn,lvn,ord,min,max)	; Return Collating code for this key
	;----------------------------------------------------------------------
	;
	N col,eof
	;
	S min=$G(min),max=$G(max)
	;
	S col="S "_lvn_"=$O("_glvn_lvn_"),"_ord_")"
	S eof=" I "_lvn_"="""""
	;
	I ord<0 S:min'="" eof=eof_"!("_$S(num:lvn_"<"_min,1:min_"]]"_lvn)_")"
	E  I max'="" S eof=eof_"!("_lvn_$S(num:">",1:"]]")_max_")"
	;
	S exe=exe+1,exe(exe)="S "_lvn_"="_$S(ord<0:$S(max="":"""""",1:max),1:$S(min="":"""""",1:min))
	S exe=exe+1,exe(exe)=col_eof_" S vsql="_vxp
    	S glvn=glvn_lvn_","
	S vxp=exe-1
	Q
	;
	;----------------------------------------------------------------------
ORDERBY(oby,sel,frm)	; Build internal orderby syntax
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	I $G(sel)=""!($G(oby)="") Q ""
	;
	I $E(oby,1,3)="BY " S oby=$E(oby,4,$L(oby)) I oby="" Q ""
	;
	N I,ddref,arg,z
	F I=1:1:$L(oby,",") D  Q:ER
	.	;
	.	S z=$P(oby,",",I) I z[$C(0) S z=$$UNTOK^%ZS(z,.tok)
	.	S ddref=$P(z," ",1),arg=$P(z," ",2,99)
	.	I arg'="",'$$CONTAIN("ASC,DESC",$P(arg," ",1)) D ERROR() Q
	.	I ddref=+ddref D
	..		S ddref=$P($P(sel,",",ddref),"/",1)
	..		I $E(ddref,1,9)="DISTINCT " S ddref=$E(ddref,10,$L(ddref))
	.	I ddref="" D ERROR() Q
	.	I '(ddref[".") S ddref=$$CVTREF^SQLDD(ddref,frm,.fsn,.vdd) Q:ER
	.	I arg'="" S ddref=ddref_" "_arg
	.	S $P(oby,",",I)=ddref
	Q oby
	;
	;----------------------------------------------------------------------
ERROR(M,P)	; Error
	;----------------------------------------------------------------------
	;
	S ER=1
	Q
	;
	;-----------------------------------------------------------------------
TMPTBL()	; Return the next available table in ^DBTMP(%TOKEN,cur,seq
	;-----------------------------------------------------------------------
	;
	S vsql("T")=$G(vsql("T"))+1
	Q "^DBTMP(%TOKEN,sqlcur,"_vsql("T")
	;
	;----------------------------------------------------------------------
PROT(frm,sel)	; Data item protection logic
	;----------------------------------------------------------------------
	; Replace original frm and sel with new one after checking with the
	; protection routine
	;----------------------------------------------------------------------
	N column,from,grp,i,table,zsel			; pc 06/29/01
	S zsel=$$UNTOK^%ZS(sel,.tok)			; *** 06/25/96
	S zsel=$TR(zsel,"""")				; ***
	S frm=$$UNTOK^%ZS(frm,.tok)			; *** 
	S frm=$TR(frm,"""")				; ***
	S sel=$$NEWLIST^SQLPROT(frm,sel) I ER Q		; Return new SELECT list
	I zsel=sel S sel=$$SQL^%ZS(sel,.tok) Q  	; *** no need to continue
	S from=","_frm_","
	S zsel=$S($E(sel,1,9)="DISTINCT ":$E(sel,10,$L(sel)),1:sel) ;pc 10/2/03
	F i=1:1:$L(zsel,",") D
	.	S column=$P(zsel,",",i)			; Column name
	.	I column'["." Q				; Token format
	.	S table=$P(column,".",1)		; Table name
	.	I from[(","_table_",") Q		; Already in the list
	.	S from=from_table_","			; Add it to the list
	.	D fsn^SQLDD(.fsn,table)			; Create file attributes
	S frm=$E(from,2,$L(from)-1)			; Remove comma
	Q
        ;
        ;--------------------------------------------------------------------
ADDVAL(str,val) ; Add Value to String
        ;--------------------------------------------------------------------
        ;
        I $G(str)="" Q $G(val)
        Q str_","_$G(val)
	;
        ;--------------------------------------------------------------------
SUBVAL(str,val) ; Subtract Value from String
        ;--------------------------------------------------------------------
	;
	N s,v
	S s=","_str_",",v=","_val_","
	I s'[v Q str
	;
	S val=$P(s,v,2,999),str=$E($P(s,v,1),2,$L(s))
	;
	I val'="" Q str_$S(str="":"",1:",")_$E(val,1,$L(val)-1)
	Q str
	;
        ;--------------------------------------------------------------------
QRYB(ddref,oprelat,rng)	; Set flag in rng
        ;--------------------------------------------------------------------
	;
	N v
	S v=$g(rng(ddref,oprelat)) I v<1 Q rng
	;
	Q $E(rng,1,v-1)_0_$E(rng,v+1,$L(rng))
	;
        ;--------------------------------------------------------------------
GETVAL(ddref,oprelat,rng)	; Return value from whr based on rng pointer
        ;--------------------------------------------------------------------
	;
	N v
	S v=$G(rng(ddref,oprelat))
	I v="" Q ""
	;
	Q $P(whr(v),$C(9),2)
	;
	;----------------------------------------------------------------------
SAVSYM	; Save some arrays to vsql
	;----------------------------------------------------------------------
	;
	N I,lvn,lvns,z
	;
	S lvns=$G(par("SAVSYM"))
	;
	F I=1:1:$L(lvns,",") D
	.	;
	.	S lvn=$P(lvns,",",I),z=lvn
	.	I $D(@z)#2 S vsql("S",z)=@z
	.	F  S z=$Q(@z) Q:z=""!($E(z,1,$L(lvn))'=lvn)  S vsql("S",z)=@z
	Q
	;
LITKEY(z) ;
	I z="$J" Q 1
	Q (z=+z!($E(z)="""")!(z="%TOKEN")!(z="sqlcur")!(z["vsql("))
	;
replace(STRING,OLD,NEW) ;       Replace OLD with NEW in STRING
        ;
        N PTR S PTR=0
        ;
        F  S PTR=$F(STRING,OLD,PTR) Q:PTR=0  S STRING=$E(STRING,1,PTR-$L(OLD)-1)_NEW_$E(STRING,PTR,1024000) S PTR=PTR+$L(NEW)-$L(OLD)
        Q STRING
