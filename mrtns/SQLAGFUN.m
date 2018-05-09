SQLAGFUN(fnam,farg,typ,dec)	;Private;SQL Aggregate Function
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/20/01 15:55:59 - CHENARDP
	; ORIG:	CHIANG - 11/15/99
	; DESC:	SQL Aggregate Function
	;
	; KEYWORDS:	Aggregate
	;
	; ARGUMENTS:
	;	. fnam	Function name		/TYP=T/REQ/MECH=VAL
	;
	;	. farg	Function Argumennt	/TYP=T/REQ/MECH=VAL
	;
	;	. typ	Column format type	/TYP=T/MECH=REFARRY:W
	;
	; RETURNS:
	;	. $$	M code expression	/TYP=T
	;	. ER    Error flag
	; 	. RM    Error message
	;
	; RELATED:
	;	. SQLCOL - SQL column name/function parser
	;
	; EXAMPLE:
	;
	;	Q $$^SQLAGFUN("MIN","BAL",.type)
	;
	;----------------------------------------------------------------------
	;I18N=QUIT: Excluded from I18N standards.
	;----------------------------------------------------------------------
	;------- Revision History ---------------------------------------------
	;
	; 2009-06-19 - Sha Mirza, CR 41162
	;	* Modified SLQAGFUN to support [DISTINCT/ALL] inside aggregates, 
	;	  added getAggrCode section which returns post conditions.
	;	  example: COUNT([DISTINCT/ALL] ACN),SUM([DISTINCT/ALL] BAL),AVG([DISTINCT/ALL] BAL)
	;	* Removed group section as this is no longer used.
	;	
	; 04/07/09 - Pete Chenard
	;	* Modified OPTIMIZE section to return 0 if multiple tables 
	;	  are involved.
	;
	; 03/10/09 - Pete Chenard
	;	* Modified to allow function argument to be either tbl.col format
	;	  or just col format.
	;
	; 02/24/09 - Pete Chenard
	;	* Replaced the test to optimize MIN or MAX with a call to new
	;	  function OPTIMIZE, which attempts to optimize more complex
	;	  scenarios than simple queries without where clauses.
	;
	;	* Modified to deal with cases where the from clause contains more
	;	  than one table.  Need to determine which table the function
	;	  argument belongs to.
	;
	; 12/08/2008 - RussellDS - CRs 35741/36952/36954
	;	* Modifications to correct problems with aggretage functions
	;	  when table is empty.
	;----------------------------------------------------------------------
	N all,argtbl,expr,gbl,groupby,i,pkey,optimize,op1,op2,ptr,q,REVIEW,seq
	N tmpstringv,vf,z
	S q="""",expr=""
	;
	I '$D(whr),'$D(vsql("IDX")) D index(frm)			; Index definitions
	;
	I $G(GROUP)="",$D(vsql("GB","GB")) S GROUP=vsql("GB","GB")
	I $G(GROUP)'="" D group^SQLG(GROUP)				; GROUP BY logic
	I $G(ER) Q ""
	I $D(vsql("GB")) S groupby=1  ;CR 41162
	E  S groupby=0
	;
	; To support DISTINCT in aggrigates :ex:COUNT([DISTINCT/ALL]
	I $E(farg,1,9)="DISTINCT " S all=0,farg=$E(farg,10,$L(farg))
  	E  S all=1 I $E(farg,1,4)="ALL " S farg=$E(farg,5,$L(farg))
  	;
	S argtbl=""
	I farg="*" S argtbl=$P(frm,",",1)	; use primary table
	E  I farg["." S argtbl=$P(farg,".",1),farg=$P(farg,".",2)	; use the specified table
	;
	;  If there are multiple tables in the FROM clause and the function argument does not
	;  specify the table in tbl.col format, then try to match the column with a table in the list.
	E  I $L(frm,",")>1 D  I ER Q ""
	.	F i=1:1:$L(frm,",") I $$VER^SQLDD($P(frm,",",i),farg,.fsn,.vdd) S argtbl=$P(frm,",",i) Q
	.	I argtbl="" S ER=1,RM="Invalid Table"
	E  S argtbl=frm
	;
	I farg'="*" S expr=$$MCOL^SQLCOL(farg,argtbl,,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,.nop)
	I $G(ER) Q ""
	;
	I farg="*",fnam="COUNT" S typ="N"       			; COUNT(*) function 
	E  S typ=$$TYP^SQLDD(argtbl_"."_farg,,.vdd) I "$N"[typ S dec=$$DEC^SQLDD(argtbl_"."_farg,,.vdd)
	I fnam="COUNT" S dec=0						;COUNT must be integer
	;
	; Not valid for non-numeric data
	I "TUFMB"[typ,((fnam="SUM")!(fnam="AVG")) S ER=1,RM=$$^MSG(1361,fnam_"("_farg_")") Q ""
	I fnam="SUM",$D(col(1)) S $P(col(1),"|",1)=$P(col(1),"|",1)+5
	;
	S seq=$O(vsql("AG",""),-1)+1					; Next function sequence number
	S v=$O(vsql(999999),-1)+1					; use local array
	I '$D(vsql("GB")) D						; no GROUP BY keyword 
	.	S vf="vsql("_v_")"					; function internal reference
	.	S vsql(v)=""						; Reserve spot
	E  S vf="^DBTMP(%TOKEN,sqlcur,"_vsql("GB")_","_q_farg_q_","_q_fnam_q_")"
	;
	I '$D(fsn(argtbl)) D fsn^SQLDD(.fsn,argtbl) I ER Q
	S pkey=$P($P(fsn(argtbl),"|",3),",",1)				; Primary key
	S gbl=$P($P(fsn(argtbl),"|",2),"(",1)_"("				; global name
	S optimize=0
	S op1=">",op2="<"
	I "TUFMB"[typ S op1="]",op2="']"				; Change to follow command
	;
	;Min function
MIN	I fnam="MIN" D							; MIN() logic
	.	S optimize=$$OPTIMIZE()
	.	S z="$S($G("_vf_")="""":"_expr_","_vf_op1_expr_":"_expr_",1:"_vf_")"
	;
	;Max function
MAX	I fnam="MAX" D	
	.	S optimize=$$OPTIMIZE()					; MAX() logic
	.	S z="$S($G("_vf_")="""":"_expr_","_vf_op2_expr_":"_expr_",1:"_vf_")"
	;
	;COUNT function
COUNT	I fnam="COUNT" D
	.	I farg="*" S z="$G("_vf_")+1" Q				; Row count
	.	;
	.	;Below is commented out until we determine an overall solution
	.	;on how to deal with null values in our database.  In come cases
	.	;in our system, null actually means '0' (BAL, for example) and this
	.	;should be counted.
	.	S z="$G("_vf_")+1"
	.	;I "N$L"[typ S z="$G("_vf_")+1"	;Temp solution.  Treat "" as 0 and count it for agg
	.	;E  S z="$G("_vf_")+$S("_expr_"="""":0,1:1)"		; non-null column count
	;
SUM	I fnam="SUM"!(fnam="AVG") S z="$G("_vf_")+"_expr,vsql(v)=0
	;
	I '$D(vsql("AG")) S vsql("AG")=""
	S exprsel=vf
	I optimize S vsql("AG")=$G(v)_"|0"							; Place MIN or MAX in return value
	E  S vsql("AG")=$G(v)_"|1"
	I fnam="COUNT" S vsql("AGCOUNT")=$G(v)				; COUNT node
	;
	; common code for all
	D
	.	I $G(vsql("GB"))'="" D  Q
	..		S vsql("AG",seq)="I "
	..		F i=1:1:$L(GROUP,",") S vsql("AG",seq)=vsql("AG",seq)_$S(i=1:vsql("GB",i),1:","_vsql("GB",i))_"'="_q_q
	..		; Skip NULL value
	..		S vsql("AG",seq)=vsql("AG",seq)_" "_$$getAggrCode(farg,fnam,typ,all,groupby,expr,vf,z) Q 
	.	;S vsql("AG",seq)=expr_"="_q_q_":0,1:"_expr_")"  ;41162
	.	;S expr=vsql("AG",seq) ;41162
	.	I expr="" S vsql("AG",seq)=$$getAggrCode(farg,fnam,typ,all,groupby,expr,vf,z) Q		; COUNT(*)
	.	;
	.	;Below is commented out until we determine an overall solution
	.	;on how to deal with null values in our database.  In come cases
	.	;in our system, null actually means '0' (BAL, for example) and this
	.	;should be counted.
	.	I "N$L"[typ S vsql("AG",seq)=$$getAggrCode(farg,fnam,typ,all,groupby,expr,vf,z)		;temp solution.  treat "" as 0 and count it for agg.
	.	E  S vsql("AG",seq)="I "_expr_"'="_q_q_" "_$$getAggrCode(farg,fnam,typ,all,groupby,expr,vf,z)	; Aggregate function
	;
	I farg="*" Q vf						; COUNT(*)
	I fnam'="AVG" Q $S(vf'["^DBTMP":"$G("_vf_")",1:vf)	; AVG() need SUM() and COUNT()
	;
	I $D(vsql("GB")) D  Q "$S(+$G("_tmpstring_")=0:"""",1:$J("_vf_"/"_tmpstring_",0,5))"	;AVG()=SUM()/COUNT()
	.	S tmpstring="^DBTMP(%TOKEN,sqlcur,"_vsql("GB")_","_q_farg_q_",""COUNTAVG"")"
	.	S vsql("AG",seq)=vsql("AG",seq)_","_tmpstring_"=$G("_tmpstring_")+1"
	S v=v+1,vsql(v)=0,vsql("AG",seq)=vsql("AG",seq)_",vsql("_v_")=$G(vsql("_v_"))+1"
	Q "$S(+$G(vsql("_v_"))=0:"""",1:$J("_vf_"/vsql("_v_"),0,5))"  ; AVG()=SUM()/COUNT()
	;
	;----------------------------------------------------------------------
getAggrCode(farg,fnam,typ,all,groupby,expr,vf,z);
	;----------------------------------------------------------------------
	; 
	; CR 41162 -To support DISTINCT in aggregate functions.
	; type public Integer v
	; type public String vsql()
	N nullexpr,postcond,setflag
	S (nullexpr,postcond,setflag)=""
	;
	;Null actually means '0' (BAL, for example) and this
	;should be counted.
	I "N$L"[typ D
	.	S v=v+1,vsql(v)=""
	.	S nullexpr="S vsql("_v_")=$S("_expr_"="""":0,1:"_expr_") ",expr="vsql("_v_")"
	E  S nullexpr=""
	;
	I all S (postcond,setflag,nullexpr)=""
	E  I groupby S (postcond,setflag)="^DBTMP(%TOKEN,sqlcur,"_vsql("GB")_","_q_farg_q_","_q_fnam_q_","_expr_")"
	E  S (postcond,setflag)="^DBTMP(%TOKEN,sqlcur,"_q_farg_q_","_q_fnam_q_","_expr_")" 
	;
	S:postcond'="" postcond=":'$D("_postcond_")"
	S:setflag'="" setflag=","_setflag_"="_q_q
	;
	;
	Q nullexpr_"S"_postcond_" "_vf_"="_z_setflag
	;----------------------------------------------------------
OPTIMIZE()	;Optimize MIN or MAX
	;----------------------------------------------------------
	;This subroutine will try to determine whether the MIN or MAX function
	; can be optimized down to a single $O statement.
	; If the function argument is the primary key in the table (or index being used)
	; and there is no where clause, then it can be optimized to a single $O.
	;
	; In some cases, even if there is a where clause it can still be optimized if the
	; function argument is the primary key of the table or of the index being used (if any)
	; and the index is keyed by the column indicated in the WHERE clause (see the whr array).
	;
	; NOTE THIS SECTION STILL NEEDS WORK.  MIN CAN BE OPTIMIZED BUT MAX NEEDS WORK.  THIS IS
	; BEING RELEASED WITH THE REST OF THE SQL CODE AS A BETA VERSION SO SOME TESTING CAN BEGIN
	;  NOW.  A FOLLOW UP TO THIS WILL BE RELEASED IN A FEW DAYS WITH MAX CORRECTED.
	I fnam="MAX" Q 0	; temporary.  Will optimize in next release
	;
	;If there is no where clause, and the primary key in the table (or index) matches
	;the argument of the function, then it can be optimized.
	I '$D(whr),pkey=farg Q 1
	I '$D(whr),$D(vsql("IDX",farg)) Q 1
	;
	N file,i,keys,opt,pkey
	S file=$G(vsql("I"))	; get the primary access file for this query
	I file="" Q 0
	I $L(file,",")>1 Q 0	; can't optimize multiple tables in from clause
	S keys=$P(vsql("I",file),"|",2)
	S pkey=$P(keys,",",1)
	S opt=0
	;
	;Scan the whr array to see if there is a match between the function argument
	;and the column specified in the left expression of the where condition.
	F i=1:1 Q:'$D(whr(i))  D
	.	N wcol,wfid,wop
	.	S wcol=$P(whr(i),$C(1),2)	;WHERE clause left expression column
	.	I wcol="" Q
	.	S wop=$P(whr(i),$C(9),3)	;WHERE clause operator
	.	S wfid=$P(wcol,".",1)
	.	S wcol=$P(wcol,".",2)
	.	I wfid'=file Q			;If WHERE clause tbl does not match the primary access file, quit.
	.	I wcol'=pkey Q			;If WHERE column does not match primary key of access file, quit.
	.	I wop'="=" Q			;If all match so far, the operator must be "=" to optimize
	.	I farg'=$P(keys,",",i+1) Q	;Function argument must match bottom key
	.	S opt=1				; okay to optimize
	Q opt
	;----------------------------------------------------------------------
index(fid)	; Save index information
	;----------------------------------------------------------------------
	N gbl,i,j,key,ref,z
	S i="" F  S i=$O(vsql("P",i)) q:i=""  D
	.	S z=vsql("P",i)
	.	S gbl=$P(z,"|",1),ref=$P(z,"|",2)	
	.	I gbl="DAYEND" Q			; Skip DAYEND global
	.	F j=1:1:$L(gbl,",") S key=$P(ref,",",j) Q:key?1A.AN
	.	S vsql("IDX",key)=$P(gbl,",",1,j)_","
	Q
	;----------------------------------------------------------------------
ADDCODE; Add Aggregate function to executable code
	;----------------------------------------------------------------------
	;
	; Add code to retrieve required data from Database
	;
	F I=1:1 Q:'$D(vsql("AG","load",I))  S exe=exe+1,exe(exe)=vsql("AG","load",I)
	;
	; Add code to extract individual columns from data loaded from Database
	F I=1:1 Q:'$D(vsql("AG",I))  D
	.	I vsql("AG",I)[$C(1) S $P(vsql("AG",I),$C(1),2)=$$MCOL^SQLCOL($P(vsql("AG",I),$C(1),2),,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd),vsql("AG",I)=$TR(vsql("AG",I),$C(1),"")
	.	S exe=exe+1,exe(exe)=vsql("AG",I)
	;
	Q
