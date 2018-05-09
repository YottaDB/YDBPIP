SQLG	;Private;SQL GROUP BY , functions to handle group by and having clauses 
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/11/01 16:12:18 - CHENARDP
	; ORIG:	SPIER - 11/06/00
	; DESC:	SQL group by 
	;
	; KEYWORDS:	
	;
	;----------------------------------------------------------------------
	;I18N=QUIT: Excluded from I18N standards.
	;----------------------------------------------------------------------
	;------- Revision History ---------------------------------------------
	; 02/19/07 - Pete Chenard - CR25515/25514
	;	     Corrected problem code generation.
	;
	; 09/15/06 - Pete Chenard - 20049
	;	     Retrofit of SQL from Profile04 to keep in sunc with PSL.
	;
	; 11/14/05 - Pete Chenard - 18202
	;	     Modified RESULT section to deal with situation where
	;	     the select list might have more than 1 aggregate
	;	     function in it.  Prior to this change, the code would
	;	     return the same value as the first aggregate function for 
	;	     all subsequent functions in the select list.
	;
	; 05/03/04 - Meena Kadam - 7569
	;	     Retrofitted changes to from Profile 01 to fix several issues 
	;	     with aggregate functions, MIN() and MAX().
	;
	; 04/20/04 - Meena Kadam - 9459
	;	     Modified to store the last key variable name in 
	;	     vsql("K").  Prior to this change, the last key variable 
	;	     was not being saved when running SQL via JDBC causing
	;	     un undefined error.
	;
	; 04/19/04 - Meena Kadam - 9457
	;	     Modified AGONLY section to correctly handle situations
	;	     when an aggregate function returns a value of 0.  The 
	;	     code was returning an error saying that no rows were processed
	;	     even though 0 might be a legitimate value to be returned.
	;	     Changed to code to check if the result is null and if it is
	;	     return the "no rows processed" error.
	;
	; 07/11/01 - Pete Chenard - 43811
	;	     Modified AGONLY section to fix a bug on  the AVG 
	;	     function.  The collation was not exiting properly (i.e.,
	;	     vsql was not being set correctly at the end of the 
	;	     table).
	;
	; 04/10/01 - Pete Chenard - 43811
	;	     Modified ADDCODE and HAVING sections to parse the HAVING
	;	     clause the same way as a WHERE clause.
	;----------------------------------------------------------------------
	;
	Q
	;----------------------------------------------------------------------
INIT	; Initialize vsql("GB" to create references to group by columns
	;----------------------------------------------------------------------
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
group(grp);	Build group by information and column extract information  
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
	S z=$O(vsql(999999),-1)+1
	S z="vsql("_z_")"
	; GROUP BY key
	I $D(vsql("GB","GB")) set vsub(sqlfrm_"."_vsql("GB","GB"))=z
	S exe=exe+1,exe(exe)="S vsql="_vxp	; return to collating logic
	S exe=exe+1,exe(exe)="S "_z_"="_""""""
	S vrescol=exe  ; beginning collation sequence of result table
	S exe=exe+1,exe(exe)="S "_z_"=$O(^DBTMP(%TOKEN,sqlcur,"_z_")) I "_z_"="_""""""_" S vsql(0)=exe S vsql=-1"
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
	I $D(vsql("AG")),'$P($G(vsql("AG")),"|",2) D  Q
	.	F I=2:1:vsql("P") S exe(I)=";"	; comment out all key levels of access
	.					; since we've optimized this query
	.					;down to one statement 
	.	I $D(vsql("AG","expr")) S exe=exe+1,exe(exe)=vsql("AG","expr",1)
	.	S exe=exe+1,exe(exe)="S vsql="_exe
	.	S exe=exe+1,exe(exe)="S vsql(0)=100" ;only 1 row returned.
	;
	.	K vsql("AG")
	; 
	; If Group BY is not being used but a aggregate function is used then
	; build the code to return data and exit will be created here.
	;
	I $D(vsql("AG"))>1,'$D(vsql("GB")) D
	.	I vxp>-1 S exe=exe+1,exe(exe)="S vsql="_vxp		; return to collating logic 
	.	I sel["COUNT" D					; no record found but count always returns 0
	..		S exe=exe+1,exe(exe)="I $G(vsql("_+vsql("AG")_"))="""" S vd="""" S vsql=-1"   ; no record found
	..		S vsql(0)=exe
	.	E  D
	..		S exe=exe+1,exe(exe)="I $G(vsql("_+vsql("AG")_"))="""" S vd="""" S vsql=-1"   ; no record found
	..		S vsql(0)=exe
	.	S vsql("P")=exe 					; point to first row
	.	;
	.	; set vsql to the result sequence once collation is complete ($O on 1st key="")
	.	I $D(vsql("COL")) S exe($O(vsql("COL",""),1))=$p(exe($O(vsql("COL",""),1)),"vsql=",1)_"vsql="_$s(sel["COUNT":(exe-1),1:exe-1) 
	.	F I=1:1 Q:'$D(vsql("AG","expr",I))  S exe=exe+1,exe(exe)=vsql("AG","expr",I)
	.	S exe=exe+1,exe(exe)="S vsql("_(+vsql("AG"))_")="""""
	.	S exe=exe+1,exe(exe)="S vsql(0)=100" ;only 1 row returned.
	.	K vsql("AG")
	.	S vsql("K")=$O(vsql(999999),-1)	;store last key variable
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
	N aggcnt,DBTMP,i,index,select,TMP
	S TMP="^DBTMP"_$P(vsql("AG","expr",1),"DBTMP",2,99)
	I vsql("AG","expr",1)["AVG",$D(vsql("GB")) S TMP="($J("_TMP_")"
	;
	; Need to replace references to vsql(n) that was used to build DBTMP with
	; the new vsql(m) that will be used to collate ^DBTMP to return the
	; result set.  Since there could be more than 1 aggregate function
	; in a statement, loop on $L(TMP,"_$C(9)_").  At this point, TMP looks like this:
	;^DBTMP(%TOKEN,sqlcur,vsql(15),"TYPE","COUNT")_$C(9)_^DBTMP(%TOKEN,sqlcur,vsql(16),"BAL","SUM")_$C(9)_^DBTMP(%TOKEN,sqlcur,vsql(18),"ACR","SUM")
	;
	; After execution of this loop TMP will be modified to reference the value of
	; vsql(x) that was passed in:
	;^DBTMP(%TOKEN,sqlcur,vsql(20),"TYPE","COUNT")_$C(9)_^DBTMP(%TOKEN,sqlcur,vsql(20),"BAL","SUM")_$C(9)_^DBTMP(%TOKEN,sqlcur,vsql(20),"ACR","SUM")
	F i=1:1:$L(TMP,"_$C(9)_") DO
	.	S DBTMP=$P(TMP,"_$C(9)_",i)
	.	S REVIEW=$P(DBTMP,",",3)
	.	F  Q:'$F(DBTMP,REVIEW)  S DBTMP=$P(DBTMP,REVIEW,1)_vsqln_$P(DBTMP,REVIEW,2,99)
	.	S $P(TMP,"_$C(9)_",i)=DBTMP
	S select=","_sel_",",string=""
	S aggcnt=0
	F i=1:1:$l(sel,",") D
	.	;If this element is an agg function, set return value = ^DBTMP(....) (i.e., the total)
	.	I $$AGG($P(sel,",",i)) S aggcnt=aggcnt+1,$P(string,"_$C(9)_",i)=$P(TMP,"_$C(9)_",aggcnt) Q  ; AGG function
	.	;
	.	;non-agg function
	.	S index=$l($e(select,1,$F(select,$p(sel,",",i))-1),",")-1
	.	S $P(string,"_$C(9)_",i)="$P("_vsqln_",$C(1),"_index_")"
	S exe=exe+1,exe(exe)="S vd="_string
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
AGG(str)	;Determine if the input string is an aggregate function or not 
	;---------------------------------------------------------------------
	Q:str=""
	I str["COUNT" Q 1
	I str["MIN" Q 1
	I str["MAX" Q 1
	I str["AVG" Q 1
	I str["SUM" Q 1
	Q 0
