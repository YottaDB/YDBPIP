DBSFETCH	;;DATA-QWIK Database Server
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/30/96 10:03:29 - CHIANG
	;
	; Run an interactive report if called from the top. Also contains
	; Database record access libaries.
	;
	;  LIBARY:
	;	. $$OPEN	Open a Cursor
	;	. $$FETCH	Fetch Next Record
	;       . $$CLOSE       Close a Cursor
	;
	;----------------------------------------------------------------------
	; 11/17/04 - RussellDS - CR13258
	;	     Removed call to ^DBSTBLA and moved HOSTVAR code from
	;	     that obsolete routine into this routine.
	;
	;	     Replaced use of $ZP.
	;
	; 08/30/96 - Bob Chiang - 20948
	;            Modified OPEN section to set up DQMODE qualifier.
	;
	; 01/29/96 - Bob Chiang - 17591
	;            Modified OPEN section to validate host variable name and
	;            substitute lowercase variable name with actural value.
	;
	; 01/22/96 - Bob Chiang - 17591
	;            Modified OPEN section to add a new 'prot" parameter.  SQL
	;            parser routine uses this flag to build the record level
	;            and field level protection logic in the run-time 
	;            prodedural code.
	;
	; 10/09/95 - Frank Sanchez
	;            Redesigned to be a shell over SQLM, thereby using
	;	     a common optimization & compiler logic
	;
	;----------------------------------------------------------------------
	; I18N=QUIT
	;----------------------------------------------------------------------
	;----------------------------------------------------------------------
OPEN(exe,frm,sel,Q,oby,join,fmt,tmo,mat,buf,vdd,prot)	;public; Open a MUMPS database 
	;----------------------------------------------------------------------
	;
	; Builds executable code and opens results table.  Use $$FETCH to
	; access the next row of data.
	;
	; **** Avoid and use OPEN^SQLM if poosible for forward compatibility
	;
	; KEYWORDS: database
	;
	; RELATED: $$FETCH^DBSFETCH,$$OPEN^UHFETCH,$$OPEN^SQLM
	;
	; ARGUMENTS:
	;	. exe(line)	Executable code 	/MECH=REFNAM:W
	;	. frm		File list		/REQ/DEL=44/MECH=VAL
	;	. sel		Data Item Select list	/DEL=44/MECH=VAL
	;	. Q		DATA-QWIK Query		/MECH=REFNAM:R
	;	. oby		Orderby list		/DEL=44/MECH=VAL
	;	. join		Join Expressions	/MECH=REFNAM:RW
	;	. tmo		Re-Entrant Timeout	/TYP=N/MECH=VAL
	;	. mat		Match count (records)	/TYP=N/MECH=VAL
	;	. buf		Network Buffer Count	/TYP=N/MECH=REFNAM:RW
	;	. vdd(ddref)	Data Dictionary		/MECH=REFNAM:RW
	;	. prot          Item protection logic   /TYP=L/MECH=VAL/DEF=0
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
	;  S Q(1,1)=$C(1)_"SYSDEV.DEP.BAL"_$C(1)_"|100||>||$"   ; DQ query
	;                     or
	;  Q="DEP.BAL>100"					; SQL
	;
	;  S vsql=$$OPEN^DBSFETCH(.exe,"DEP","CID,LNM,TLD,BAL",.Q)
	;  I vsql=0 Q
	;----------------------------------------------------------------------
	;
	; Define library and %TOKEN variable
	;
	I '$D(%LIBS) N %LIBS S %LIBS=$$^CUVAR("%LIBS")
	I $G(%TOKEN)="" S %TOKEN=$P($G(%LOGID),"|",6) I %TOKEN="" S %TOKEN=$J
	;
	S ER=0
	;
	K vsql,exe
	N fid,whr,par,token,z
	;
	S oby=$G(oby),sel=$G(sel)
	I sel="",oby'="" S oby=""			; Nothing to orderby
	;
	S fsn="vsql(",fid=$P(frm,",",1)			; Primary access file
	D fsn^DBSDD(.fsn,fid)				; Initialize file header
	;
	I $G(Q)'="" S whr=Q K Q				; SQL syntax
	E  S whr=$$Q2SQL^SQLCONV(.Q)			; Convert to SQL format
	I whr[":" S whr=$$HOSTVAR(whr)			; Check for lowercase host variable
	;						; *** 01/29/96 BC
	S par("DQMODE")=1
	I $G(buf) S par("BUFFER")=buf
	I $G(mat) S par("MATCH")=mat
	I $G(tmo) S par("TIMEOUT")=tmo
	S par("FORMAT")=$G(fmt)				; Format option
	S par("PROTECTION")=$G(prot)			; Protection logic
	S par("DQMODE")=1				; *** BC 08/30/96
	; 
	Q $$OPEN^SQLM(.exe,.frm,.sel,.whr,.oby,.grp,.par,.token,0,.vdd,.fmt)
	;
	;----------------------------------------------------------------------
CODE(glvn,key,klvl,exe,vxp,num,qua,tmo)	; Return Collating code for this key
	;----------------------------------------------------------------------
	;
	; Used to support M global syntax in DBSTBLA
	;
	N z,x,dsc,min,max,I
	;
	S vxp=-1
	S exe=$O(exe(""),-1)+1
	S num=$G(num)
	S tmo=$G(tmo)
	;
	S dsc=0
	I $G(qua)'="" S qua=$$UPPER^%ZFUNC(qua) F I=1:1:$L(qua,"/") D
	.	;
	.	S z=$P(qua,"/",I) I z="" Q
	.	I $E("DESCENDING",1,$L(z))=z S dsc=1 Q
	.	I $E("ASCENDING",1,$L(z))=z S dsc=1 Q
	.	; Put break-on and others here
	;
	S min=$G(MIN(klvl)),max=$G(MAX(klvl))
	S min=""""_$G(MIN(klvl))_""""
	;
	I num,max=1E18 S max="""""" Q
	I max=$C(254) S max=""
	S max=""""_max_""""
	;
	S z="S "_key_$S(dsc:"=$O(",1:"=$O(")_glvn_key_"),-1) I "_key_"="""""
	;
	I dsc S:min'="""""" z=z_"!("_$S(num:key_"<"_min,1:min_"]"_key)_")"
	E  I max'="""""" S z=z_"!("_key_$S(num:">",1:"]")_max_")"
	;
	S exe(exe)="S "_key_"="_$S(dsc:max,1:min)
	S exe=exe+1,exe(exe)=z_" S vsql="_vxp
	S vxp=exe-1
	Q
	;
	;
	;----------------------------------------------------------------------
RESULT(exe)	; Place cursor before the first row
	;----------------------------------------------------------------------
	;
	S vsql=1
	S vsql=$$FETCH(.exe,.vd,.vi)
	I vsql S vsql=exe+1,exe=$O(exe(""),-1)
	Q vsql
	;
	;----------------------------------------------------------------------
FETCH(exe,vd,vi,sqlcur)	;public; Fetch Next Record in Results Table
	;----------------------------------------------------------------------
	; Fetch the next record in the results table.
	;
	; KEYWORDS: database
	;
	; RELATED: $$OPEN^SQLM,$$FETCH^SQLM
	;
	; ARGUMENTS:
	;	. exe(line)	Executable code		/MECH=REFNAM:R
	;	. vd		Data Record		/MECH=REFNAM:W
	;	. vi		Column Indicators	/MECH=REFNAM:W
	;	. sqlcur	Cursor Name		/MECH=VAL/NOREQ
	; 
	;   INPUT:
	;	. vsql(sym)    Cursor Symbol Table	/MECH=REFNAM:RW
	;
	; RETURNS:
	;	. $$		Success code		/TYP=N
	;			0 = End of Table
	;			1-n Success
	; EXAMPLE:
	;
	;  F  S vsql=$$FETCH^DBSFETCH(.exe,.rec,.sqlind) Q:vsql=0  W rec,!
	;----------------------------------------------------------------------
	;
	I '$D(sqlcur) S sqlcur=0		; Used by sort logic
	;
	I vsql(0)=100 Q 0			; End of table
	;
	F  X exe(vsql) S vsql=vsql+1 Q:vsql=0!(vsql>exe)
	I vsql=0 S vsql(0)=100,vd="" Q 0
	S vi=$G(vi)				; Protection indicator
	Q vsql(0)				; Return status
	;
	;--------------------------------------------------------------------
FETCHBLK(sqlcur,exe,vsql,sqldta,sqlcnt,sqlind,rows)	; Fetch a block of records
	;--------------------------------------------------------------------
	;
	S sqlcnt=0,vsql=$$FETCH(.exe,.sqldta,.sqlind,.sqlcur)
	I vsql=0!sqlcnt Q
	;
	S sqlcnt=1 I $G(rows)<2!(vsql(0)=100) Q
	;
	N vd
	F sqlcnt=2:1:rows S vsql=$$FETCH(.exe,.vd,.vi,.sqlcur) Q:vsql=0  S sqldta=sqldta_$C(13,10)_v,sqlind=sqlind_$C(13,10)_vi
	;
	I vsql=0 S sqlcnt=sqlcnt-1,vsql(0)=100
	Q
	;----------------------------------------------------------------------
CLOSE(sqlcur)	; Public ; Close a cursor
	;----------------------------------------------------------------------
	; Close a cursor
	;
	; KEYWORDS: database
	;
	; RELATED: $$OPEN^SQLM,$$FETCH^UHFETCH
	;
	; ARGUMENTS:
	;	. sqlcur	Cursor Name	/TYP=T/NOREQ/MECH=VAL
	;----------------------------------------------------------------------
	;
	I $G(sqlcur)="" S sqlcur=0	
	;
	D CLOSE^SQLM(sqlcur)
	Q
	;----------------------------------------------------------------------
HOSTVAR(where)	; Validate and substitute lowercase host variable name 
	;----------------------------------------------------------------------
	; Example:  S abc=100 W $$HOSTVAR("CID=:abc") returns CID='100'
	;----------------------------------------------------------------------
	N i,v,var
	F i=1:1:$L(where,":") D  I $G(ER) Q
	.	S var=$P(where,":",i+1)			; Host variable
	.	S var=$P(var," ",1)
	.	I var="" Q
	.	I var["(" Q				; Array format
	.	X ("S v=$G("_var_")")			; Get value
	.	I v="" S ER=1,RM=$$^MSG(8592,":"_var) Q	 ; Not defined
	.	I ((var?1"%".UN)!(var?1U.UN)) Q		; Valid format
	.	;					; Replace lowercase variable
	.	S where=$P(where,":"_var,1)_"'"_v_"'"_$P(where,":"_var,2,99)
	Q where
