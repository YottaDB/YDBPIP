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
	N expr,gbl,i,pkey,optimize,op1,op2,ptr,q,seq,tmpstringv,vf,z,REVIEW
	S q="""",expr=""
	;
	I '$D(whr),'$D(vsql("IDX")) D index(frm)			; Index definitions
	;
	I $G(GROUP)="",$D(vsql("GB","GB")) S GROUP=vsql("GB","GB")
	I $G(GROUP)'="" D group^SQLG(GROUP)				; GROUP BY logic
	I $G(ER) Q ""
	;
	I farg'="*" S expr=$$MCOL^SQLCOL(farg,frm,,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,.nop)
	I $G(ER) Q ""
	;
	I farg="*",fnam="COUNT" S typ="N"       			; COUNT(*) function 
	E  S typ=$$TYP^SQLDD(frm_"."_farg,,.vdd) I "$N"[typ S dec=$$DEC^SQLDD(frm_"."_farg,,.vdd)
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
	I '$D(fsn(frm)) D fsn^SQLDD(.fsn,frm) I ER Q
	S pkey=$P($P(fsn(frm),"|",3),",",1)				; Primary key
	S gbl=$P($P(fsn(frm),"|",2),"(",1)_"("				; global name
	S optimize=0
	S op1=">",op2="<"
	I "TUFMB"[typ S op1="]",op2="']"				; Change to follow command
	;
	;Min function
MIN	I fnam="MIN" D							; MIN() logic
	.	I '$D(whr),pkey=farg S z="$O("_gbl_""""""_"))",optimize=1 Q
	.	I '$D(whr),$D(vsql("IDX",farg)) S z="$O("_vsql("IDX",farg)_""""""_"))",optimize=1 Q
	.	S z="$S('$D("_vf_"):"_expr_","_vf_op1_expr_":"_expr_",1:"_vf_")"
	;
	;Max function
MAX	I fnam="MAX" D							; MAX() logic
	.	I '$D(whr),pkey=farg S z="$O("_gbl_""""""_"),-1)",optimize=1	Q
	.	I '$D(whr),$D(vsql("IDX",farg)) S z="$O("_vsql("IDX",farg)_""""""_"),-1)",optimize=1 Q
	.	S z="$S('$D("_vf_"):"_expr_","_vf_op2_expr_":"_expr_",1:"_vf_")"
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
	I optimize Q z							; Place MIN or MAX in return value
	S vsql("AG")=$G(v)_"|1"
	D
	.	I $G(vsql("GB"))'="" D  Q
	..		S vsql("AG",seq)="I "
	..		F i=1:1:$L(GROUP,",") S vsql("AG",seq)=vsql("AG",seq)_$S(i=1:vsql("GB",i),1:","_vsql("GB",i))_"'="_q_q
	..		; Skip NULL value
	..		S vsql("AG",seq)=vsql("AG",seq)_" S "_vf_"="_z Q	 
	.	I expr="" S vsql("AG",seq)="S "_vf_"="_z Q		; COUNT(*)
	.	;
	.	;Below is commented out until we determine an overall solution
	.	;on how to deal with null values in our database.  In come cases
	.	;in our system, null actually means '0' (BAL, for example) and this
	.	;should be counted.
	.	I "N$L"[typ S vsql("AG",seq)="S "_vf_"="_z		;temp solution.  treat "" as 0 and count it for agg.
	.	E  S vsql("AG",seq)="I "_expr_"'="_q_q_" S "_vf_"="_z	; Aggregate function
	;
	I farg="*" Q vf						; COUNT(*)
	I fnam'="AVG" Q $S(vf'["^DBTMP":"$G("_vf_")",1:vf)	; AVG() need SUM() and COUNT()
	;
	I $D(vsql("GB")) D  Q "$J("_vf_"/"_tmpstring_",0,5)"	;AVG()=SUM()/COUNT()
	.	S tmpstring="^DBTMP(%TOKEN,sqlcur,"_vsql("GB")_","_q_farg_q_",""COUNT"")"
	.	S vsql("AG",seq)=vsql("AG",seq)_","_tmpstring_"=$G("_tmpstring_")+1"
	S v=v+1,vsql(v)=0,vsql("AG",seq+1)="S vsql("_v_")=$G(vsql("_v_"))+1"
	Q "$J("_vf_"/vsql("_v_"),0,5)"	; AVG()=SUM()/COUNT()
	;
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
ADDCODE;	Add Aggregate function to executable code 
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
