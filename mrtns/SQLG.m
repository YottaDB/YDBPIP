SQLG	;Private;SQL GROUP BY , functions to handle group by and having clauses 
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/11/01 16:12:18 - CHENARDP
	; ORIG:	SPIER - 11/06/00
	; DESC:	SQL group by 
	;
	; KEYWORDS:	
	;
	;----------------------------------------------------------------------
	;I18N=QUIT: Excluded from I18N standards.
	;---- Comments ---------------------------------------------------------
	; Use of all lvns that deal with AGGREGATEs and GROUP BY
	; * vsql("GB")= contians expression for GROUP BY. 
	; * vsql("GB","GB") = original list of columns in GROUP BY clause
	; * vsql("AG",*)= contains the expression that constructs the SELECT list
	; 		  
	;
	;------- Revision History ---------------------------------------------
	;
	; 2009-07-01 - Sha Mirza, CR 41643
	;	* Modified ADDCODE section for incorrect value of vsql("P") when getting into ^SQLF.
	;	* Modified AGONLY section to make sure all vsql() entries allocated(vsql("K")). 
	;
	; 2009-06-19 - Sha Mirza, CR 41162
	;	* Modified group to support individual columns can appear either left of 
	;	  aggregate function or right of aggregate function in the select list.
	;	* Modified AGG(str) section which check for AGG function ending with "(".
	;
	; 04/07/09 - Pete Chenard
	;	     Modified RESULT section to dealwith cases were there are more 
	;	     than 1 entry in vsql("AG","expr",seq).  the code assumed there
	;	     was only 1 sequence.  Most of the time, that is true, but for long
	;	     queries (usually with 3 or more aggregate functions in it), additional
	;	     sequences are needed.
	;
	; 03/18/09 - Pete Chenard
	;	     Modified AGONLY to protect against undef on vsql("AGCOUNT").
	;
	; 01/21/09 - Pete Chenard
	;	     Modified AGONLY to remove the code that comments out the
	;	     key collation code for MIN and MAX.  The key reading logic
	;	     is necessary to load other nodes required by the query.
	;
	; 12/01/2008 - RussellDS - CRs 35741/36952/36954
	;	* Modified AGONLY section to correctly handle COUNT when table
	;	  is empty.
	;	* Removed old revision history.
	;
	; 04/21/08 - Suzanne Palmer - CR33498
	;	     Modified section ADDCODE to set vsql(0)=exe.  This allows 
	;	     the exe array to be called to the correct line.  This will 
	;	     prevent NULSUBSC and GVUNDEF errors from occurring for 
	;	     each of the SQL statements.
	;
	;----------------------------------------------------------------------
	;
	Q
	;----------------------------------------------------------------------
INIT	; Initialize vsql("GB" to create references to group by columns
	;----------------------------------------------------------------------
	;
	; type public String grp
	; type public String sel
	; type public String vsql()
	; type public String RM
	; type public Boolean ER
	;
	I $G(grp)="" Q
	N gbsel,aggfunc
	S aggfunc=",MIN,MAX,COUNT,AVG,SUM,"
	S vsql("GB","GB")=grp
	F I=1:1:$l(grp,",") S vsql("GB",I)=$P(grp,",",I)
	S gbsel=","_grp_","
	;
	;The code below is doing the following:
	; $P($P(sel,",",I),"(",1)'="" means this is in the format of an agg function eg:  COUNT(GRP)
	; aggfunc'[$P($P(sel,",",I),"(",1) means it's in the format of an agg function, but is not a valid one.  eg: ABC(GRP)
	; gbsel'[$P(sel,",",I) means the group by clause contains a column that is not in the select clause
	;
	F I=1:1:$L(sel,",") D
	.	S:$P($P(sel,",",I),"(",1)'=""&(aggfunc'[$P($P(sel,",",I),"(",1))&(gbsel'[$P(sel,",",I)) ER=1,RM="Selected items must be in group by list"
	Q
	;
	;----------------------------------------------------------------------
group(grp); Build group by information and column extract information 
	;----------------------------------------------------------------------
	N i,seq,v
	F i=1:1:$L(grp,",") D  Q:ER
	.	S expr=$$MCOL^SQLCOL($p(grp,",",i),FROM,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,.nop)
	.	I $G(ER) Q
	.	S v=$o(vsql(99999),-1)+1			; next variable
	.	S vsql("GB")=$S(i=1:"vsql("_v_")",1:vsql("GB")_"_$C(1)_"_"vsql("_v_")")		; group by reference
	.	S vsql("GB",i)="vsql("_v_")"
	.	S vsql(v)=""
	.	S seq=$O(vsql("AG",""),-1)+1			; next sequence
	.	S vsql("AG",seq)="S vsql("_v_")="_expr		; key value
	Q
	;----------------------------------------------------------------------
EXEC	;
	;----------------------------------------------------------------------
	I $D(vsql("GB")) d
	.	N X,vsub
	.	S X="vsub"
	.	F  S X=$O(vsql("S",X)) Q:X'["vsub"  S @X=vsql("S",X)
	.	D ^SQLCOL(.exe,,frm,.sel,"vd",,.tok,.fsn,.fma,.cmp,.vsub,.vdd,,.subqry)
	Q
	;----------------------------------------------------------------------
ADDCODE	; Add group By code to executable routine
	;----------------------------------------------------------------------
	; Sample Output of ADDCODE, AGONLY, HAVING, and RESULT sections
	; SELECT GRP,COUNT(GRP) FROM DEP GROUP BY GRP HAVING (GRP)='DDA'
	; S vsql(1)=""
	; S vsql(1)=$O(^XCLSACN("D",vsql(1)),1) I vsql(1)="" S vsql=6
	; S vsql(2)=$G(^ACN(vsql(1),50))
	; S vsql(4)=$P(vsql(2),"|",3)
	; I vsql(4)'="" S ^DBTMP(%TOKEN,sqlcur,vsql(4),"GRP","COUNT")=$G(^DBTMP(%TOKEN,sqlcur,vsql(4),"GRP","COUNT"))+$S($P(vsql(2),"|",3^
	; S vsql=1
	; S vsql(5)=""
	; S vsql(5)=$O(^DBTMP(%TOKEN,sqlcur,vsql(5))) I vsql(5)="" S vsql=-1
	; I '((vsql(5))="DDA") S vsql=7
	; S vd=$P(vsql(5),$C(1),1)_$C(9)_^DBTMP(%TOKEN,sqlcur,vsql(5),"GRP","COUNT")
	;---------------------------------------------------------------------
	N vrescol,z
	S z=$G(vsql("GB"))
	I z="" D AGONLY Q
	S z=$O(vsql(999999),-1)+1,vsql(z)=""
	S z="vsql("_z_")"
	; GROUP BY key
	I $D(vsql("GB","GB")) set vsub(sqlfrm_"."_vsql("GB","GB"))=z
	S exe=exe+1,exe(exe)="S vsql="_vxp	; return to collating logic
	S exe=exe+1,exe(exe)="S "_z_"="_""""""
	S vrescol=exe  ; beginning collation sequence of result table
	S vsql("P")=vrescol  ; setting the value of vsql("p") for next fetch itteration of exe array.
	S exe=exe+1,exe(exe)="S "_z_"=$O(^DBTMP(%TOKEN,sqlcur,"_z_")) I "_z_"="_""""""_" S vsql=-1",vsql(0)=exe		;ACM 33437
	I $D(vsql("HAVING")) D HAVING(z),AGONLY Q
	I $D(vsql("AG","expr",1)) D RESULT(z)
	S exe($O(vsql("COL",""),1))=$P(exe($O(vsql("COL",""),1)),"vsql=",1)_"vsql="_(exe-3)	; modify coll. exit level
	;
	D AGONLY
	Q
	;
	;----------------------------------------------------------------------
AGONLY	; Add code that is required only when the group by clause
	; is not used but an aggragate function was used.
	;----------------------------------------------------------------------
	N I
	;
	; Make sure all vsql() entries allocated here are reported
	S vsql("K")=$O(vsql(999999),-1)	;store last key variable
	;
	I $D(vsql("AG")),'$P($G(vsql("AG")),"|",2) D  Q
	.	I $D(vsql("AG","expr")) S exe=exe+1,exe(exe)=vsql("AG","expr",1)
	.	;S exe=exe+1,exe(exe)="S vsql="_exe
	.	I '$D(vsql("GB")) S exe=exe+1,exe(exe)="S vsql(0)=100" ;only 1 row returned.
	.	K vsql("AG")
	; 
	; If Group BY is not being used but a aggregate function is used then
	; build the code to return data and exit will be created here.
	;
	I $D(vsql("AG"))>1,'$D(vsql("GB")) D
	.	N saveP
	.	I vxp>-1 S exe=exe+1,exe(exe)="S vsql="_vxp		; return to collating logic 
	.	I sel["COUNT" D					; no record found but count always returns 0
	..		; Set count to zero and continue to get formatted results 
	..		S exe=exe+1,exe(exe)="I $G(vsql("_+$G(vsql("AGCOUNT"))_"))="""" S vsql("_+$G(vsql("AGCOUNT"))_")=0"   ; no record found
	..		S vsql(0)=exe
	.	E  D
	..		S exe=exe+1,exe(exe)="I $G(vsql("_+vsql("AG")_"))="""" S vd="""" S vsql=-1"   ; no record found
	..		S vsql(0)=exe
	.	S saveP=vsql("P")
	.	S vsql("P")=exe 					; point to first row
	.	;
	.	; set vsql to the result sequence once collation is complete ($O on 1st key="")
	.	I $D(vsql("COL")) S exe($O(vsql("COL",""),1))=$p(exe($O(vsql("COL",""),1)),"vsql=",1)_"vsql="_(exe-1) 
	.	E  I sel["COUNT" S exe(saveP)=$p(exe(saveP),"vsql=",1)_"vsql="_(exe-1)
	.	F I=1:1 Q:'$D(vsql("AG","expr",I))  S exe=exe+1,exe(exe)=vsql("AG","expr",I)
	.	S exe=exe+1,exe(exe)="S vsql(0)=100" ;only 1 row returned.
	.	K vsql("AG")
	.	S vsql("AGONLY")=""
	Q
	;
	;----------------------------------------------------------------------
HAVING(objqry)	;Add code required due to HAVING clause being part of the SQL command
	;	The HAVING clause is parsed similarly to the WHERE clause.
	;----------------------------------------------------------------------
	;
	N TMP,hav,having,hrng,i,j,mcode,tmp
	;
	S TMP="^DBTMP"_$P(vsql("AG","expr",1),"DBTMP",2,99)  ;table that results of agg functions are stored
	s TMP=$p(TMP,"_$C(9)",1)
	I vsql("AG","expr",1)["AVG",$D(vsql("GB")) S TMP="($J("_TMP_")"
	S REVIEW=$P(TMP,",",3)
	F  Q:'$F(TMP,REVIEW)  S TMP=$P(TMP,REVIEW,1)_objqry_$P(TMP,REVIEW,2,99)
	;
	S having=HAVING
	;
	; Handle aggregate function test (data is stored in ^DBTMP)
	F i=1:1:$L(having,",") do
	.	S j=0
	.	I '$$AGG($P(having,",",i)) Q   ; not an agg function.  Handled by ^SQLQ and ^SQLA
	.	;Agg function, so get result from ^DBTMP
	.	S j=j+1
	.	S tmp(j)="I "_TMP_"'"_$$QSWP^%ZS($$UNTOK^%ZS(vsql("HAVING","vsub"),.tok),"'","""")_" S vsql="_vrescol
	.	S $p(having,",",i)=""
	;
	; Handle any non-aggregate elements in the HAVING clause.  These should be parsed
	; the same as a WHERE clause.
	I $L(having) D
	.	D ^SQLQ(HAVING,frm,.hav,.hrng,1,.tok,.fsn,.vdd,.out)
	.	D QUERY^SQLA(.hrng,.hav,.mcode,.vsub,frm,.fsn,0,objqry)
	;
	; change code pointer to point to beginning of collating of result table v
	f i=1:1 Q:'$D(mcode(i))  I mcode(i)["vsql=" s $P(mcode(1),"vsql=",2)=vrescol
	f i=1:1 Q:'$D(mcode(i))  S exe=exe+1,exe(exe)=mcode(i)
	f i=1:1 Q:'$D(tmp(i))  S exe=exe+1,exe(exe)=tmp(i)
	;
	;
	D RESULT(objqry)
	S exe($O(vsql("COL",""),1))=$P(exe($O(vsql("COL",""),1)),"vsql=",1)_"vsql="_(exe-4)     ; modify coll. exit level
	Q
	;
	;----------------------------------------------------------------------
RESULT(vsqln)	;Private void; Add code which generates the actual return value
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	; . vsqln = Reference to vsql(n), which is used to collate through
	;	   the ^DBTMP global for each row of the result set.  This
	;	   must replace the value of vsql(x) that was used to build
	;	   ^DBTMP.
	;
	;	   example:  vslq="vsql(20)"
	;
	N aggcnt,EXPR,DBTMP,i,index,isOptimized,ptr,groupby,REVIEW,SUBS,TMP
	;
	S isOptimized=0	; Has expression been optimized?  (MIN and MAX are optimized to a 
	;	  	  single $O if the argument into the function is the primary key
	;		  into the table.  In that case, there will be no DBTMP reference.
	;
	S TMP=""
	F i=1:1 Q:'$D(vsql("AG","expr",i))  D
	.	S EXPR=vsql("AG","expr",i),EXPR=$E(EXPR,$F(EXPR,"vd="),$L(EXPR))
	.	S:$E(EXPR,1,2)="vd" EXPR=$E(EXPR,3,$L(EXPR))
	.	;
	.	; now EXPR contains the partial expression that constructs the SELECT list
	.	; but is uses the wrong vsql-subscripts
	.	; If EXPR contains an un-optimized aggregate, it will contain "^DBTMP"
	.	; and we need to replace the expr in the third subscript with the
	.	; vsql() entry that iterates over the result (in vsqln)
	.	F ptr=$F(EXPR,"^DBTMP"):0 Q:'ptr  D
	.	.	;
	.	.	; replace third subscript of this ^DBTPM occurrence
	.	.	S SUBS=$E(EXPR,ptr,$L(EXPR)),REVIEW=$P(SUBS,",",3)
	.	.	I REVIEW=vsqln S ptr=$F(EXPR,"^DBTMP",ptr) Q		; already replaced
	.	.	F  Q:'$F(EXPR,REVIEW)  S EXPR=$P(EXPR,REVIEW,1)_vsqln_$P(EXPR,REVIEW,2,99)
	.	.	;
	.	.	; advance to next ^DBTMP in EXPR
	.	.	S ptr=$F(EXPR,"^DBTMP",ptr)
	.	S TMP=TMP_EXPR
	;
	S groupby=","_vsql("GB","GB")_",",string=""
	F i=1:1:$l(sel,",") D
	.	;If this element is an agg function, set return value = ^DBTMP(....) (i.e., the total)
	.	I $$AGG($P(sel,",",i)) D  Q
	.	.	I 'isOptimized S $P(string,"_$C(9)_",i)=$P(TMP,"_$C(9)_",i)  ; AGG function
	.	.	E  S $P(string,"_$C(9)_",i)=$P(vsql("AG","expr",1),"_$C(9)_",i)
	.	;
	.	;non-agg function
	.	;Search for columns which is in select list and get that index
	.	;to replace with the corresponding column from group by list 
	.	;so that the columns in select list can be either before aggrigate
	.	;or after the aggrigates.
	.	S index=$l($e(groupby,1,$F(groupby,$p(sel,",",i))-1),",")-1
	.	S $P(string,"_$C(9)_",i)="$P("_vsqln_",$C(1),"_index_")"
	S exe=exe+1,exe(exe)="S vd="_string
	S $P(vsql("AG"),"|",2)=1	;flag as complete.  vd has been set in here.
	Q
	;
	;----------------------------------------------------------------------
HOSTVAR	; Handle Host variables in the Having Clause
	;----------------------------------------------------------------------
	;
	Q:'$$AGG(HAVING)
	S HAVING=$TR(HAVING," ","")
	I HAVING'[":" S vsql("HAVING","vsub")=$P(HAVING,")",2) Q
	S vsql("HAVING","vsub")=$E($P(HAVING,")",2))_$$HOSTVAR^SQLQ($E($P(HAVING,")",2),2,100),,,.exe)
	Q
	;
	;---------------------------------------------------------------------
AGG(str) ;Determine if the input string is an aggregate function or not
	;---------------------------------------------------------------------
	;
	Q:str="" 0
	I $e(str,1,6)="COUNT(" Q 1
	I $e(str,1,4)="MIN(" Q 1
	I $e(str,1,4)="MAX(" Q 1
	I $e(str,1,4)="AVG(" Q 1
	I $e(str,1,4)="SUM(" Q 1
	Q 0
