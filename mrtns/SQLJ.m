SQLJ(frm,whr,fsn,join,tok)	;PUBLIC;SQL FROM Clause Parser
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/01/97 15:04:11 - CHIANG
	;     ORIG: Frank Sanchez (2497) - December 17, 1994
	;
	; This routine parses the FROM clause of an SQL statement
	;
	; KEYWORDS:	Parsing, DATA-QWIK
	;
	; RELATED: 
	;
	;  PARAMS:
	;	. frm		SQL From Clause			/REQ
	;	. whr		SQL Where Clause
	;	. fsn		File Header array
	;	. join		Join Array Data Structure
	;
	;  RETURNS:
	;	. ER	Error Indicator			/TYPE=T
	;	. RM		Return message	
	;
	; EXAMPLE:
	;
	;---- Revision History -----------------------------------------------
	; 2009-05-12, Pete Chenard, CR 40607
	;	Modified ON to account for INNER, and other valid join keywords
	;	Also removed the resetting of jfrm in the ON section because this
	;	was causing SQLQ to return an error if jfrm did not include
	;	all of the tables that are refernced in the ON clause.
	;
	; 2009-05-06, Pete Chenard CR 40607
	;	Modified DQJOIN to deal with alias issue.
	;
	; 2009-04-22, Frans S.C. Witte, 39529
	;	Modified ON() to NEW and SET lvn 'oby'.
	;
	; 01/22/09 - Pete Chenard
	;	     Modified TABLE section to create an entry in vAlias
	;	     array as map between the alias and the actual underlying
	;	     table.
	;
	; 10/15/07 - Pete Chenard - CR29774
	;	     Modified ON section to include 'LEFT' in the list
	;	     of keywords to look for while parsing the from clause.
	;	     Without this, a from clause such as "CIF LEFT OUTER JOIN CIFPIC
	;	     ON CIF.ACN=CIFPIC.ACN LEFT OUTER JOIN CIFSIG ON CIF.ACN=CIFSIG.ACN"
	;	     will not compile correctly.
	;
	; 07/01/96 - Frank Sanchez
	;            Replaced old foreign key referneces 110, with new
	; 06/14/96 - Bob Chiang - 21736
	;            Modified to use left outer join as the default.
	;
	;----------------------------------------------------------------------
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;
	I '$D(%LIBS) S %LIBS=$$^CUVAR("%LIBS")
	;
	I $G(tok)="" N tok S frm=$$SQL^%ZS($G(frm),.tok)
	;
	S ER=0
	;
	N alias,jfrm,keywords,ptr,typobj,typjoin,outer,left,return,savptr,stack,tbl
	;
	S return="",jfrm=""
	;
	S ptr=0,stack=0,typobj=0,outer=0,left=0,typjoin=-1
	S keywords=",LEFT,RIGHT,KEY,CROSS,NATURAL,INNER,JOIN,ON,USING,,"
	;
	I $E(frm)="X",$L(frm,",")>1 D DELIDX		; v50 patch
	;
	I $G(par("DQMODE")),'(frm[" JOIN ") S frm=$$TOKEN^%ZS($$DQJOIN(frm,.fsn),.tok)
	;
	F  D INTERP($$ATOM^%ZS(.frm,.ptr,",",tok)) Q:ptr=0!ER
	;
        I typobj=4 D ERROR($$^MSG(1337,frm))   ;Table Name expected
	;
	I ER S return=""
	Q return
	;
     	;-----------------------------------------------------------------------
INTERP(atm)	; Interpret expression atom
	;-----------------------------------------------------------------------
	;
	I $A(atm)=0 S atm=$$UNTOK^%ZS(atm,.tok)
	;
	I $E(atm)="(" D  Q
	.	;
     	.       I '(typobj=0!(typobj=4)) D ERROR($$^MSG(840)) Q  ;Unexpected paranthesis
	.	;
	.	N frm
	.	S frm=$$TRIM^%ZS($E(atm,2,$L(atm)-1))
	.	;
	.	N ptr
 	.	S ptr=0,stack=stack+1
	.	F  D INTERP($$ATOM^%ZS(.frm,.ptr,",",.tok))  Q:ptr=0!ER
	.	S stack=stack-1
	;
	I typobj=0 D TABLE(atm,.alias) S typobj=1,tbl=alias Q	; Table name
	;
	I typobj=1 D  Q
	.	;
	.	I atm="," S typobj=4 Q
	.	I atm="LEFT" S typobj=3,left=1,outer=1 Q
	.	I atm="RIGHT" S typobj=3,left=0,outer=1 Q
	.	I atm="KEY" S typobj=2 Q
	.	I atm="CROSS" S typobj=3,typjoin=-1 Q
	.	I atm="NATURAL" S typobj=2,typjoin=0 Q
	.	I atm="INNER" S typobj=3,outer=0 Q
	.	I atm="JOIN" S typobj=4 Q
	.	I atm="ON" D ON Q
	.	I atm="USING" D USING Q
	.	S ER=1,RM=$$^MSG(8564,frm) Q
	;
	I typobj=2 D  Q
	.	;
	.	I atm="LEFT" S typobj=3,left=1,outer=1 Q
	.	I atm="RIGHT" S typobj=3,left=0,outer=1 Q
	.	I atm="INNER" S typobj=3,outer=0 Q
	.	I atm="JOIN" S typobj=4 Q
	.	I atm="FULL" D NOOP(atm) Q
	.	I atm="UNION" D NOOP(atm) Q
	;
	I typobj=3 D  Q
	.	;
	.	I atm="OUTER" Q
	.	I atm="JOIN" S typobj=4 Q
	.       D ERROR($$^MSG(365)) Q   ;JOIN expression expected
	;
	D TABLE(atm,.alias) Q:ER
	D JOIN(tbl,alias,outer,left,typjoin,.fsn,.join)
	;I typobj=5 D INTERP(atm)
	S typobj=1
	Q
	;
    	;----------------------------------------------------------------------
TABLE(tbl,alias)	; Input is table name [as alias]
    	;----------------------------------------------------------------------
	;
	I tbl["""" S tbl=$$QSUB^%ZS(tbl,"""")
	;
	S alias=tbl,savptr=ptr
	;
	I ptr D  I ER Q
	.	;
	.	S atm=$$ATOM^%ZS(.frm,.ptr,",",tok) Q:ER
	.	;
	.	I atm="AS" D  ;Q
	..		;
	..		I ptr=0 D ERROR("Missing alias name") Q
	..		S atm=$$ATOM^%ZS(.frm,.ptr,",",tok)
	..		;;S alias=$$QSUB^%ZS(atm,"""")
	.	;
	.	I '$$CONTAIN(keywords,atm) S alias=$$QSUB^%ZS(atm) Q
	.	S ptr=savptr
	;
	I '$D(fsn(tbl)) D fsn^SQLDD(.fsn,tbl) Q:ER
	S vAlias(alias)=tbl
	I alias'=tbl D
	.	;
	.	S fsn(alias)=fsn(tbl)
	.	S $P(fsn(alias),"|",11)=$P(fsn(alias),"|",11)_"."_tbl
	;
	S return=$$ADDVAL(return,alias)
	S jfrm=$$ADDVAL(jfrm,alias)			; Local From Scope
	Q
	;
    	;----------------------------------------------------------------------
JOIN(tbl1,tbl2,outer,left,typjoin,fsn,join)	;
	;----------------------------------------------------------------------
	;
	N dinam1,dinam2,i,key,keys
	;
	S ER=0
	;
	S keys=""
	;
	I typjoin=1 S keys=$$KEY(tbl1,tbl2,.fsn)	; Key Join
	I typjoin=0 S keys=$$NATURAL(tbl1,tbl2,.fsn)	; Natural
	;
	I keys'="" F i=1:1:$L(keys,",") D
	.	;
	.	S key=$P(keys,",",i) I key=+key!($E(key)="""") Q
	.	S dinam1=tbl1_"."_key,dinam2=tbl2_"."_key
	.	;
	.	I '$D(join(dinam1)) S join(dinam1)=dinam2
	.	E  I join(dinam1)'[dinam2 S join(dinam1)=join(dinam1)_","_dinam2
	.	;
	.	I '$D(join(dinam2)) S join(dinam2)=dinam1
	.	E  I join(dinam2)'[dinam2 S join(dinam2)=join(dinam2)_","_dinam1
	.	;
	.	D POINTER^SQLQ(dinam1,dinam2)
	;
	I outer=0 Q
	;
	N t1,t2
	;
	I left S t1=tbl1,t2=tbl2
	E  S t1=tbl2,t2=tbl1
	;
	I '$D(join(t2)) S join(t2)=t1
	E  S join(t2)=join(t2)_","_t1
	Q
	;
	;----------------------------------------------------------------------
KEY(tbl1,tbl2,fsn)	; Return key join
	;----------------------------------------------------------------------
	;
	;
	N fid1,fid2,lib1,lib2
	;
	S lib1=$P(fsn(tbl1),"|",11)
	S lib2=$P(fsn(tbl2),"|",11)
	;
	I lib1["." S fid1=$P(lib1,".",2),lib1=$P(lib1,".",1)
	E  S fid1=tbl1
	;
	I lib2["." S fid2=$P(lib2,".",2),lib2=$P(lib2,".",1)
	E  S fid2=tbl2
	;
	S ER=0
	;
	N v1,v2
	S v1="",v2=""
	F  S v1=$O(^DBTBL(lib1,19,fid1,v1)) Q:v1=""  I $P(^(v1),"|",5)=fid2 Q
	F  S v2=$O(^DBTBL(lib2,19,fid2,v2)) Q:v2=""  I $P(^(v2),"|",5)=fid1 Q
	;
 	I v1="" S:v2="" v2=$$NATURAL(tbl1,tbl2,.fsn) Q v2
 	I v2="" Q v1
	;
        ;
        ; "Tables "_tbl1_" and "_tbl2_" foreign keys refernce each other")
        D ERROR($$^MSG(370,tbl1,tbl2))
	Q ""
	;
	;----------------------------------------------------------------------
NATURAL(tbl1,tbl2,fsn)	; Return Natural join
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	I '$D(fsn(tbl1)) D fsn^SQLDD(.fsn,tbl1) I ER Q ""
	I '$D(fsn(tbl2)) D fsn^SQLDD(.fsn,tbl2) I ER Q ""
	;
	N fkeys,key,keylvl,v
	;
	S v="",fkeys=$P(fsn(tbl2),"|",3)
	;
	I fkeys'="" F keylvl=1:1:$L(fkeys,",") D
	.	;
	.	S key=$P(fkeys,",",keylvl)
	.	I $$VER^SQLDD(tbl1,key,.fsn,.vdd) S $P(v,",",keylvl)=key
	;
	Q v
	;
     	;-----------------------------------------------------------------------
DELIDX	; Remove redundant or obselete cross references
     	;-----------------------------------------------------------------------
	; This subroutine exists for back compatibility -- pre V5.0 SELECTS
	; reference 'index' files as primary files. In V6 these files should
	; be removed from the dictionary
	;
	; eg: XCLS,LN,LTYPE    =  LN,LTYPE
	;
	;
	N file
	S file=$P(frm,",",1)
	I '$$CONTAIN("XCLS,XCC,XCLSACN,XCRCD",file) Q
	S frm=$P(frm,",",2,999)
	;
	I sel[file S sel=$$REMREF(sel,file)
	I tok[file S tok=$$REMREF(tok,file)
	I $G(sqloby)[file S sqloby=$$REMREF(sqloby,file)
	I $G(sqlwhr)[file S sqlwhr=$$REMREF(sqlwhr,file)
	;
	Q
	;
	;-----------------------------------------------------------------------
REMREF(expr,ref)	; Remove all file references from expr
     	;-----------------------------------------------------------------------
	;
	N y
	S y=0
	F  S y=$F(expr,ref) Q:y=0  D  Q:ER
	.	;
        .       I "]."'[$E(expr,y) D ERROR($$^MSG(373)) Q  ;Invalid from clause
	.	I $E(expr,y)="." S expr=$E(expr,1,y-$L(ref)-1)_$E(expr,y+1,$L(expr))
	.	E  S expr=$E(expr,1,y-$L(ref)-2)_$E(expr,y+1,$L(expr))
	Q expr
	;
	;-----------------------------------------------------------------------
ON	; On clause processing
     	;-----------------------------------------------------------------------
	;
	; All lvns except oby are "type public".
	; The lvn oby is referenced by SQLQ if the ON clause specifies a
	; sequential column. This subroutine cannot / shall not rely on the
	; caller.
	;
	N oby
	S ptr=ptr+1,oby=""
	;;S atm=$$GETSTRING(frm,.ptr,"CROSS,NATURAL,UNION,INNER,LEFT,FULL,RIGHT,OUTER,JOIN",.tok)
	S atm=$$GETSTRING(frm,.ptr,"LEFT,RIGHT,OUTER,INNER,CROSS,NATURAL,FULL,JOIN",.tok)
	D ^SQLQ(atm,jfrm,.whr,.rng,.mode,.tok,.fsn,.vdd,outer)
	S outer=0,left=0,typjoin=-1
	Q
	;
	;-----------------------------------------------------------------------
USING	; Using clause processing
     	;-----------------------------------------------------------------------
	;
	I $L($G(return),",")=1 Q
	;
	S atm=$$GETSTRING(frm,.ptr,"JOIN",.tok)
	;
	N i,j,col,tbl1,tbl2
	;
	S tbl1=$P(return,",",1)
	;
	F i=2:1:$L(return,",") S tbl2=$P(return,",",i) F j=1:1:$L(USING,",") D
	.	;
	.	S col=$P(USING,",",j)
	.	;
	.	I $G(whr)="" S whr=tbl1_"."_col_"="_tbl2_"."_col
	.	E  S whr=whr_" AND "_tbl1_"."_col_"="_tbl2_"."_col
	;
	S jfrm="",outer=0,left=0,typjoin=-1
	Q 
	;
     	;-----------------------------------------------------------------------
DQJOIN(frm,fsn)	; Return DATA-QWIK mode FROM clause with LEFT JOIN logic
     	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;	. frm	Table names		/TYP=T/REQ/MECH=VAL
	;       . fsn   File attributes         /TYP=T/MECH=REFARRY:RW
	;
	; EXAMPLE:
	;
	;  W $$DQJOIN("HIST,DEP")
	;
	;
	;  W $$DQJOIN("DEP,HIST")
	;
	;  W $$DQJOIN("XCC,DEP,CIF")
	;
	;----------------------------------------------------------------------
	S ER=0
	;
	S frm=$$UNTOK^%ZS(frm,.tok)
	;
	I '(frm[",") Q frm				; Single table
	;
	N i,j,k,key,keys,ptbl,return,tbl1,tbl2,on
	;						; Join secondary tables to primary table
	S on="",ptbl=$P(frm,",",1)			; Primary table
	I ptbl["""" S ptbl=$$QSUB^%ZS(ptbl,"""")
	;
	S return=ptbl_" LEFT JOIN ("_$P(frm,",",2,$L(frm,","))_")"
	;
	F i=1:1:$L(frm,",") D  Q:ER
	.	;
	.	S tbl1=$P(frm,",",i)
	.	I tbl1["""" S tbl1=$$QSUB^%ZS(tbl1,"""")
	.	if tbl1[" " D ALIAS(.tbl1) Q:ER
	.	F j=1:1:$L(frm,",") D  Q:ER
	..		;
	..		S tbl2=$P(frm,",",j)
	..		I tbl2["""" S tbl2=$$QSUB^%ZS(tbl2,"""")
	..		if tbl2[" " D ALIAS(.tbl2) Q:ER
	..		I tbl2=tbl1!(tbl2=ptbl)	Q
	..		S keys=$$NATURAL^SQLJ(tbl1,tbl2,.fsn)
	..		F k=1:1:$L(keys,",") D
	...			;
	...			S key=$P(keys,",",k) I key="" Q
	...			I $D(keys(tbl2,key)) Q
	...			S keys(tbl1,key)="",keys(tbl2,key)=""
	...			I on'="" s on=on_" AND "
	...			S on=on_""""_tbl1_"""."""_key_"""="""_tbl2_"""."""_key_""""
	;
	I on'="" S return=return_" ON ("_on_")"
	Q return
	;
     	;-----------------------------------------------------------------------
GETSTRING(str,ptr,keywords,tok)	; Return string until keywords
     	;-----------------------------------------------------------------------
	;
	N bptr,eptr,atm
	;
	S bptr=ptr
	F  S eptr=ptr,atm=$$ATOM^%ZS(str,.ptr,",",tok) Q:ptr=0!ER  I atm=","!$$CONTAIN(keywords,atm) S ptr=eptr Q
	;
	I ptr=0 S eptr=$L(str)
	Q $E(str,bptr,eptr)
	;
	;--------------------------------------------------------------------------------------
ALIAS(tbl) ; Sets public scoped variables fsn and vAlias to deal with aliases in the from clause
	;--------------------------------------------------------------------------------------
	I '(tbl[" ") Q
	N alias
	S alias=$P(tbl," ",$L(tbl," "))  ; Take last atom as the alias (in case AS keyword is present)
	S tbl=$P(tbl," ",1)
	I '$D(fsn(tbl)) D fsn^SQLDD(.fsn,tbl) Q:ER
	S vAlias(alias)=$P(tbl," ",1)
	S fsn(alias)=fsn(tbl)
	Q
	;
NOOP(m)	D ERROR($$^MSG(374,m)) Q          ; m Not supported
	;
ERROR(m)	S RM=m,ER=1 Q
	;
CONTAIN(a,b)	Q ","_a_","[(","_b_",")
	;
ADDVAL(a,b)	Q a_$S(a="":"",1:",")_b
