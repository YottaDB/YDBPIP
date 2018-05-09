SQLQ(X,frm,whr,rng,mode,tok,fsn,vdd,out)	;PUBLIC;SQL where clause Parser
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/02/02 11:35:05 - SPIER
	;     ORIG: Frank Sanchez (2497) - December 17, 1994
	;
	; This routine parses the WHERE clause of an SQL statement
	;
	; KEYWORDS:	Parsing, DATA-QWIK
	;
	; RELATED: ^SQLA
	;
	;  PARAMS:
	;	. X		SQL Where clause		/REQ
	;	. frm		List of Files			/REQ
	;	. whr		Return Parse array
	;
	;  RETURNS:
	;	. ER		Error Indicator			/TYPE=T
	;	. RM		Return message	
	;	. rng(ddref)	Range array for optimizer
	;	. whr		boolean logic
	;	. whr(#)	Intermediate record
	;	   		exprlft|exprght||oprelat|datatyp
	;
	; EXAMPLE:
	;
	;---- Revision History -----------------------------------------------
	; 04/29/09 - Pete Chenard
	;	     Reversed previous change.  The issue that the previous change 
	;	     was attempting to correct has now been handled in VIEW^SQLM.  See
	;	     revision history in SQLM for details.
	;
	; 03/18/09 - Pete Chenard
	;	     Modified RANGE TO replace a line that was mistakently removed
	;	     in a previous revision.  The line to QUIT from the loop if
	;	     piece 3 of exprlft was not null was put back in.  Piece 3, if
	;	     not null, contains data, or punctuation such as parenthesis
	;	     that belong after the column defined in piece 2.
	;
	; 02/26/09 - Pete Chenard
	;	     Modified RANGE section to remove the code the eliminated the
	;	     outer join condition if there's a query on the table.  This was
	;	     an optimization that was causing some rows to be omitted from
	;	     the result set when they should in fact be included.
	;
	; 01/24/09 - Pete Chenard
	;	     Modified SUBQUERY to call ^SQLJ to process the subquery
	;	     FROM clause.  Without this call, table aliases are not
	;	     handled correctly.
	;
	; 06/05/2008 - RussellDS - CR30801
	;	Modified HOSTVAR to save vsql("hostVars") for use by SQL
	;	to build using reference for audit logging.
	;
	;	Fixed problem in LITSTR with use of ='' for D, C, and L
	;	datatypes.
	;
	;	Removed old revision history.
	;
	; 11/27/07 - Pete Chenard -  CR 30087
	;	     Modified to not cache SQL statements with LIKE in 
	;	     the where clause.
	;
	; 07/10/07 - Pete Chenard - CR28171
	;	     Replaced occurances of $C(255)
	;
	; 09/26/06 - Pete Chenard - CR22216
	;	     Modified SETRNG section to use $G around reference to exe.
	;	     In cases where only a WHERE clause is present (in the case
	;	     of compiling a query definition) the exe variable may not
	;	     be defined yet, causing an undefined error.
	;
	; 07/13/06 - RussellDS - CR22121
	;	     Modified LIKE section to eliminate use of ^UCOLLATE and
	;	     replace with use of '> and
	;	     $$getPslValue^UCOPTS("maxCharValue") to make Unicode
	;	     compliant.
	;
	; 02/26/06 - RussellDS - CR19065
	;	     Modify SUBQUERY section to remove some of the constraints
	;	     on type checking for sub-queries that were leading to
	;	     query type errors where they are unnecessary.  Expanded
	;	     error message.
	;----------------------------------------------------------------------
	;
	; I18N=QUIT: Exculded from I18N standards.
	;
	N I,chrtbl,datatyp,dec,exprlft,exprght,lstbool,lstlogic,lstypobj,marklft,markrht
	N nbrexpr,notoper,object,oplogic,oprelat,serial,typobj,ptr,z
	;
	I $G(tok)="" S X=$$SQL^%ZS($G(X),.tok)
	;
	S ER=0,lstbool=0,ptr=0,lstlogic="",chrtbl="+-*/<>=|"
	;
	I '$D(whr) S whr="",nbrexpr=0
	E  S whr=whr_"&",nbrexpr=$O(whr(""),-1)
	;
	D INI
	F  D INTERP($$ATOM^%ZS(.X,.ptr,chrtbl,tok)) Q:ptr=0!ER
	I ER Q
	;
	I exprlft'="" D FILE("")			; File Last query
	;
	S I=$E(whr,$L(whr))
	I I="&"!(I="!") S ER=1,RM=$$^MSG(1434) Q  	; Invalid WHERE syntax
	;
	I whr["(" F  S whr=$$REMPAR(whr,.ptr) Q:ptr=0   ; Drop unnecessary ()
	;
		; CR11049 GHODKEY
	; Attempt to optimize where by moving serial columns to front
	; Do this prior to calling RANGE so that correct whr() is in place
	I $G(whr)'="" D SERIAL(.whr)
	;
	S nbrexpr=nbrexpr-1
	S rng=$G(rng)_$TR($J("",nbrexpr-$L($G(rng)))," ",1)
	F I=1:1:nbrexpr I $$NESTED^SQLA(whr,I)=0 D RANGE(I,.whr,.rng)
	;
	; Merge the range array based on join conditions
	;
	S exprlft=""
	F  S exprlft=$O(join(exprlft)) Q:exprlft=""  D
	.	;
	.	I "J"[$O(rng(exprlft,"")) Q
	.	;
	.	N i,v
	.	S v=join(exprlft)
	.	F i=1:1:$L(v,",") D MERGE(exprlft,$P(v,",",i))
	Q
	;
	;-----------------------------------------------------------------------
INTERP(WRD)	; Interpret expression atom
	;-----------------------------------------------------------------------
	;
	I ER Q
	;
	I $E(WRD)="(" D  Q
	.	;
	.	N span
	.	I lstypobj'="" S span=0
	.	E  I ptr=0 S span=1
	.	E  S span=$$CONTAIN("AND,OR",$$ATOM^%ZS(.X,ptr,chrtbl,tok))
	.	D NEST(WRD,span)
	;
	I $E(WRD)="'" D LITSTR Q				; Strlit
	I $E(WRD)="""" D DINAM(WRD) Q				; Data Item
	I WRD!($E(WRD)=0) D LITSTR Q				; Numlit
	;
	I "><="[WRD D OPRELAT(WRD) Q				; Logical OP
	I "+-*/"[WRD D OPARITH(WRD) Q				; Aritmetic OP
	;
	I WRD["(" D SET(object,$$FUNCTION^SQLCOL(WRD,1,.datatyp,,,.tok)) Q
	I WRD="IN" D IN Q
	I WRD="IS" D IS Q
	I WRD="OR" D FILE("!") Q
	I WRD="AND" D FILE("&") Q
	I WRD="LIKE" D LIKE Q
	I WRD="NOT" S notoper='notoper D:ptr=0 ERROR() Q
	I WRD="BETWEEN" D BETWEEN Q
	I WRD="EXISTS" D EXISTS Q
	I WRD="|" D CONCAT Q
	I $E(WRD)=":" D VAR Q					; Hostvar
	;
	I WRD="SYSDAT" S WRD=":+$H" D VAR Q
	I WRD="USERID" S WRD=":%UID" D VAR Q
	;
	I WRD[$C(0) S WRD=$$UNTOK^%ZS(WRD,.tok)			; DBTBL1."%LIBS"
	D DINAM(WRD) Q
	;
	;-----------------------------------------------------------------------
NEST(X,span)	; Process paranthesis nest
	;-----------------------------------------------------------------------
	;
	N ox						; *** 06/12/99
	S ox=X						; ***
	S X=$$POP^%ZS(X)				; ***
	I X=ox D ERROR() Q				; Query syntax error
	;
	I $E(X,1,7)="SELECT " D SUBQUERY($E(X,8,$L(X))) Q
	;
	I $G(span) S:notoper whr=whr_"'",notoper=0 S whr=whr_"("
	E  D SET(object,"(")
	;
	N ptr S ptr=0 F  D INTERP($$ATOM^%ZS(X,.ptr,chrtbl,tok))  Q:ptr=0!ER
	;
	I $G(span) D FILE(")") Q
	D SET(object,")")
	Q
	;
	;-----------------------------------------------------------------------
CHKEXPR	; Check syntax before processing keyword
	;-----------------------------------------------------------------------
	;
	I exprlft="" D ERROR($$^MSG(8042)) Q		; Missing subject
	I oprelat'="" D ERROR("Invalid operator combination "_oprelat_" "_WRD) Q
	Q
	;
	;-----------------------------------------------------------------------
OPARITH(val)	; +-/*
	;-----------------------------------------------------------------------
	;
	I lstypobj=4 D ERROR() Q
	;
	I $$GETEXPR(object)="",("+-"'[val) D ERROR() Q		; Allowable Unary op
	;
	D SET(object,val)
	S lstypobj=4
	I datatyp="" S datatyp="N"
	Q
	;
	;-----------------------------------------------------------------------
OPRELAT(val)	; = < >
	;-----------------------------------------------------------------------
	;
	I exprlft="" D ERROR($$^MSG(8033)) Q
	I oprelat'="" D ERROR() Q
	;
	S oprelat=val,object=5,lstypobj=0
	;
	S WRD=$$ATOM^%ZS(.X,.ptr,chrtbl,tok)
	;
	I oprelat="<",">="[WRD D
	.	;
	.	S notoper='notoper
	.	;
	.	I WRD=">" S oprelat="="
	.	E  S oprelat=">"
	.	;
	.	S WRD=$$ATOM^%ZS(.X,.ptr,chrtbl,tok)
	;
	I oprelat=">",WRD="=" S notoper='notoper,oprelat="<",WRD=$$ATOM^%ZS(.X,.ptr,chrtbl,tok)
	;
	I WRD="ANY"!(WRD="ALL") S oprelat=oprelat_WRD Q
	;
	D INTERP(WRD)
	Q
	;
	;-----------------------------------------------------------------------
LITSTR	; Object is a string or numeric literal
	;-----------------------------------------------------------------------
	;
	I lstypobj=object D ERROR() Q
	;
	I $E(WRD)="'" S WRD=$$QSWP^%ZS(WRD,"'","""")		; *** 06/19/96
	;
	I oprelat="=",$E(WRD)="""",datatyp="N"!(datatyp="$") S WRD=+$E(WRD,2,9999)	; *** 09/11/96
	I WRD?.N!(WRD?1N.N1".".N)!(WRD?1".".N) D		; *** 06/20/96
	.	;
	.	S WRD=+WRD	
	.	I datatyp="" S datatyp="N"
	.	I oprelat="=","$"[datatyp,$E(exprlft)'="+" S exprlft="+"_exprlft
	;
	E  I datatyp="D"!(datatyp="C")!(datatyp="L") D
	.	;
	.	S WRD=$$QSUB^%ZS(WRD,"""")		; *** 06/19/96
	.	S WRD=$$INT^%ZM(WRD,datatyp,"",.dec)
	.	I ER D ERROR($$TYPERR(datatyp)) Q
	.	I WRD="" S WRD=$$QADD^%ZS(WRD,"""")	;allow for ='' format 
	;
	E  I datatyp="U" S WRD=$$UPPER^UCGMR(WRD)
	E  I datatyp="" S datatyp="T"
	;
	I lstypobj=4,WRD'=+WRD D ERROR("Invalid Value for arithmetic operation") Q
	S lstypobj=object
	;
	D SET(object,WRD)
	Q
	;
	;-----------------------------------------------------------------------
BETWEEN	; WHERE ddref [NOT] BETWEEN low_value AND high_value
	;-----------------------------------------------------------------------
	;
	; Save serial if it is defined to ensure that both queries associated
	; with BETWEEN are tagged as related to a serial column, if that is the
	; case
	;
	D CHKEXPR Q:ER
	;
	S oprelat="<",notoper='notoper,object=5,lstypobj=0
	;
	S z=$F(X,"AND",ptr) I z=0 D ERROR($$^MSG(8584)) Q
	;
	N savelft,savenot,savetype,svserial
	;
	S savelft=exprlft,savenot=notoper,savetype=datatyp
	I $D(serial) S svserial=serial
	S exprght=$E(X,ptr+2,z-5),ptr=z
	S exprght=$$MCOL^SQLCOL(exprght,frm,,datatyp,,.fsn,.cmp,.vsub,.tok,.vdd,1)
	;
	I $E(exprght)="""","DCL"[datatyp S exprght=$$INT^%ZM(exprght,datatyp) 
	;
	D FILE($S(notoper:"&",1:"!"))
	;
	S exprlft=savelft,notoper=savenot,oprelat=">",object=5,lstypobj=0
	S datatyp=savetype
	I $D(svserial) S serial=svserial
	Q
	;
	;-----------------------------------------------------------------------
IN	; WHERE ddref [NOT] IN (SELECT... | VAL1,...VAL(n)
	;-----------------------------------------------------------------------
	;
	D CHKEXPR Q:ER
	D RETLIST(.exprght) Q:ER
	;
	S oprelat="I"
	I $E(exprght,1,7)="SELECT " D SUBQUERY($E(exprght,8,$L(exprght))) Q
	;
	I ("^:"[$E(exprght)) Q
	;
	I $L(exprght,",")=1 D  Q
	.	;
	.	S oprelat="="
	.	S WRD=$$UNTOK^%ZS(exprght,tok),exprght=""
	.	D LITSTR
	;
	I datatyp="" Q			; *** 12/15/97 BC
	I "DCL"[datatyp D  Q		; 
	.	;
	.	N i,list,val			; format into internal format
	.	S list=""
	.	F i=1:1:$L(exprght,",") D
	..		S val=$P(exprght,",",i)
	..		S val=$$MCOL^SQLCOL(val,frm,,,,.fsn,.cmp,.vsub,.tok,.vdd,1)
	..		S val=$$INT^%ZM(val,datatyp) 
	..		S list=list_val_","
	.	S exprght=$E(list,1,$L(list)-1)
	;
	Q
	;
	;-----------------------------------------------------------------------
IS	; WHERE ddref IS [NOT] NULL
	;-----------------------------------------------------------------------
	;
	S exprght=""""""
	;
	;for numeric and currency datatypes, a null usually means 0.
	;check for ths condition and + the left side and set right side 
	;to 0.
	I "$NL"[datatyp,$S(exprlft[$C(1):$P(vdd($P(exprlft,$c(1),2)),"|",31),1:0) D  ;pc 9.24.01
	.	S exprlft=$S($E(exprlft)="+":exprlft,1:"+"_exprlft)
	.	S exprght=0
	;
	S WRD=$$ATOM^%ZS(.X,.ptr,chrtbl,tok),lstypobj=0,object=5,datatyp="T"
	I WRD="NULL" S oprelat="=" Q
	I WRD="NOT" S notoper='notoper,WRD=$$ATOM^%ZS(.X,.ptr,chrtbl,tok) I WRD="NULL" S oprelat="=" Q
	D ERROR()
	Q
	;
	;-----------------------------------------------------------------------
EXISTS	; WHERE [NOT] EXISTS
	;-----------------------------------------------------------------------
	;
	;D CHKEXPR Q:ER
	D RETLIST(.exprght) Q:ER
	;
	S oprelat="E"
	I $E(exprght,1,7)="SELECT " D SUBQUERY($E(exprght,8,$L(exprght))) Q
	;
	S exprlft=1,exprght=1,oprelat="="
	Q
	;
	;-----------------------------------------------------------------------
LIKE	; WHERE ddref LIKE [NOT] LIKE
	;-----------------------------------------------------------------------
	;
	D CHKEXPR Q:ER
	S par("CACHE")=0,CACHE=0
	I "DCL"[datatyp S exprlft="$$"_$S(datatyp="D":"DAT",datatyp="C":"TIM",1:"LOG")_"^%ZM("_exprlft_")"
	;
	S oprelat="L",object=5,lstypobj=0,datatyp="T"
	S exprght=$$ATOM^%ZS(.X,.ptr,chrtbl,tok)
	I $E(exprght)=":" S vexpr=$E(exprght,2,$L(exprght)),exprght="'"_@vexpr_"'"
	I '($E(exprght)="'"&($E(exprght,$L(exprght))="'")) D ERROR("Invalid LIKE Syntax") Q
	;
	S exprght=$$QSWP^%ZS(exprght,"'","""")
	;
	I $E(exprght,2)="%",$E(exprght,$L(exprght)-1)="%" S oprelat="[",exprght=""""_$E(exprght,3,$L(exprght)-2)_"""" Q
	I "%_"[$E(exprght,2)!notoper S exprght=$$MPAT(exprght),oprelat="?" Q
	;
	N exprlike
	;
	S exprlike=$P(exprght,"%",1)
	I exprlike["_" S exprlike=$P(exprlike,"_",1)
	;
	I exprlike=exprght S oprelat="=" Q
	;
	N chrlike,savelft,savenot,saverht
	S chrlike=$E(exprght,$L(exprlike)+1,$L(exprght)-1)
	S savelft=exprlft,saverht=exprght,savenot=notoper
	S notoper='savenot,oprelat="<",exprght=exprlike_""""
	;
	S whr=whr_"("
	;
	; call FILE to add entry to whr array for '< only when the column is not numeric or $ OR when it is
	; a key column to allow optimization on starting point
	I ("N$"'[$P(vdd($p(savelft,$C(1),2)),"|",9)!($P(vdd($p(savelft,$C(1),2)),"|",1)["*")) D FILE("&")
	;
	; PAR 04/23/98
	S exprlft=savelft,notoper=savenot
	S datatyp="T"
	;
	; If database key is numeric then we need to use pattern match and loop throught the entire database
	; Otherwise, use '> against righthand side concatenated to maxCharValue
	I "N$"'[$P(vdd($p(savelft,$C(1),2)),"|",9),$TR(exprlike,"""","")'?1N.E S oprelat=">",notoper='savenot,exprght="("_exprlike_""""_"_$C("_$$getPslValue^UCOPTS("maxCharValue")_"))"
	E  S exprght=$$MPAT(saverht),oprelat="?"		;7/26/00 mas
	;
	I chrlike="%" D FILE(")") Q
	;
	D FILE("&")
	s notoper=savenot
	;
	S exprlft=savelft
	;
	I $TR(chrlike,"_")="" S datatyp="N",oprelat="=",exprlft="$L("_exprlft_")",exprght=$L(saverht)-2
	E  S exprght=$$MPAT(saverht),oprelat="?",datatyp="T"
	;
	D FILE(")")
	Q
	;
	;-----------------------------------------------------------------------
CONCAT	; Concatenate operator
	;-----------------------------------------------------------------------
	;
	S ptr=ptr+1
	;
	I $E(X,ptr)'="|" D ERROR("Invalid Concatenation Syntax") Q
	I $$GETEXPR(object)="" D ERROR() Q
	I lstypobj=4 D ERROR() Q
	;
	D SET(object,"_")
	S lstypobj=4,datatyp="T"
	Q
	;
	;----------------------------------------------------------------------
MPAT(X)	; Create M executable pattern match for LIKE
	;----------------------------------------------------------------------
	;
	S X=$E(X,2,$L(X)-1)
	;
	I X="" Q ""
	N P,T
	;
	S P=$S($F(X,"%"):$E(X,1,$F(X,"%")-2),1:$E(X,1,999))_""""
	F  S T=$F(X,"%") Q:T=0  S P=P_".E",X=$E(X,T,999) I $L(X) S P=P_"1"""_$E(X,1,$S($F(X,"%",1):$F(X,"%",1)-2,1:999))_""""
	F  S T=$F(P,"_") Q:T=0  S P=$P(P,"_",1)_"""1E1"""_$P(P,"_",2,999)
	Q "1"""_P
	;
	;-----------------------------------------------------------------------
RETLIST(exprght)	; Return a list expression
	;-----------------------------------------------------------------------
	;
	S exprght=$$ATOM^%ZS(.X,.ptr,chrtbl,tok),lstypobj=0,object=5
	;
	I $E(exprght)'="(" D ERROR($$^MSG(8587)) Q
	S exprght=$$TRIM^%ZS($E(exprght,2,$L(exprght)-1))
	Q
	;
	;-----------------------------------------------------------------------
DINAM(WRD)	; Data item syntax
	;-----------------------------------------------------------------------
	;02/03/2009 Pete Chenard.  Modifed to allow for multiple columns to be passed
	; into the WRD parameter.
	; Multiple columns will be delimited by a comma (,).  When rebuilding WRD,
	; separate columns with $C(0).  Also the corresponding data type, decimal 
	; precision, and serial flag will be delimited by $C(0) when multiple columns
	; are passed in.
	N i,TMPWRD
	I $$GETEXPR(object)'="",4'[lstypobj D ERROR() Q
	;
	F i=1:1:$L(WRD,",") D  Q:ER
	.	S TMPWRD=$P(WRD,",",i)
	.	S z(i)=$$DI^SQLDD(.TMPWRD,frm,.vdd,.fsn) 
	.	;
	.	I ER,$D(vsql("R")) D 			; Correlated
	..		;
	..		I '$$CONTAIN(vsql("R"),$P(TMPWRD,".",1)) Q
	..		S v0="vsql("_$$NXTSYM^SQLM_")"
	..		S vsql("R",v0)=TMPWRD,TMPWRD=v0
	..		S $P(WRD,",",i)=TMPWRD
	..		S ER=0
	.	Q:ER
	.	E  S TMPWRD=$C(1)_TMPWRD_$C(1)
	.	S $P(WRD,",",i)=TMPWRD_$C(0)
	;
	I ER Q
	;
	; Multiple columns in WRD will be stored like this:
	; $C(1)_TBL.COL1_$C(1)_$C(0)_$C(1)_TBL.COL2_$C(1)
	I $E(WRD,$L(WRD))=$C(0) S WRD=$E(WRD,1,$L(WRD)-1)
	S WRD=$TR(WRD,",")
	;
	D SET(object,WRD)
	F i=1:1 Q:'$D(z(i))  D
	.	I object=3 D
	..		S dec=$G(dec)_$S(i>1:$C(0),1:"")_$P(z(i),"|",14)
	..		S datatyp=$G(datatyp)_$S(i>1:$C(0),1:"")_$P(z(i),"|",9)
	..		S serial=$G(serial)_$S(i>1:$C(0),1:"")_$P(z(i),"|",23)	; 02/21/2000 FRS
	.	;
	.	E  I lstypobj=4 D				; Type conversions
	..		;
	..		S z=$P(z(i),"|",9)
	..		I "N$"[$G(datatyp),"DCLN$"[z S datatyp=z Q
	..		I $G(datatyp)="D",z="D" S datatyp="N" Q
	..		I $G(datatyp)="C",z="C" S datatyp="N" Q
	..		D ERROR("Invalid type conversion") Q
	;
	S typobj=object
	S lstypobj=typobj
	Q
	;
	;-----------------------------------------------------------------------
VAR	; Object is a host variable :var
	;-----------------------------------------------------------------------
	;
	S typobj=object
	I $$GETEXPR(object)'="",4'[lstypobj D ERROR() Q
	;
	S WRD=$$HOSTVAR(WRD,.datatyp,.vsub,.exe)
	D SET(object,WRD)
	S lstypobj=typobj
	Q
	;
	;-----------------------------------------------------------------------
ERROR(M,ptr)	; Input order syntax error
	;-----------------------------------------------------------------------
	;
	S ER=1,RM=$G(M)
	I RM="" S RM="Query Parsing Error :"_$G(WRD)
	Q
	;
	;-----------------------------------------------------------------------
FILE(oplogic)	; File into whr(nbrexpr)
	;-----------------------------------------------------------------------
	;
	S lstlogic=$E(whr,$L(whr))
	I lstlogic=")" S whr=whr_oplogic S:exprlft'="" ER=1,RM="Invalid Syntax" Q
	;
	I exprlft="" D ERROR($$^MSG(8042)) Q		; Missing subject
	I oprelat="" D ERROR($$^MSG(8041)) Q		; Missing Operator
	I exprght="" D ERROR($$^MSG(8040)) Q		; Missing Expression
	;
	I notoper S oprelat="'"_oprelat
	;
	I $L(markrht)>1 D COMPOUND(.exprght,.markrht)
	I $L(marklft)>1 D COMPOUND(.exprlft,.marklft)
	;
	I $P(exprlft,$C(1),2)="" D SWAP(.exprlft,.exprght,.oprelat)
	;
	; In this section, see if multiple OR's can be compressed in an IN
	;
	I lstlogic="!","I="[oprelat D
	.	;
	.	N z,p2,p3
	.	S z=$G(whr(nbrexpr-1))
	.	I exprlft'=$P(z,$C(9),1) Q		; Different column
	.	S p2=$P(z,$C(9),2),p3=$P(z,$C(9),3)
	.	I p3="=" S p2=$$QSWP^%ZS(p2,"""","'")
	.	E  I p3'="I" Q				; Not = or IN
	.	;
	.	I oprelat="=" S exprght=$$QSWP^%ZS(exprght,"""","'")
	.	;
	.	S nbrexpr=nbrexpr-1
	.	S exprght=p2_","_exprght
	.	S whr=$P(whr,nbrexpr_lstlogic,1)
	.	S oprelat="I"
	;
	S whr=whr_nbrexpr_oplogic
	D SETWHR(nbrexpr,exprlft,exprght,oprelat,datatyp,.out)	; Set whr array
	I $G(serial) S $P(whr(nbrexpr),$C(9),6)=1,serial=""
	;
INI	;
	S object=3 
	S nbrexpr=nbrexpr+1
	S (dec,datatyp,exprlft,exprght,lstypobj,marklft,markrht,notoper,oplogic,oprelat,typobj)=""
	Q
	;
	;
	;-----------------------------------------------------------------------
SETWHR(nbrexpr,exprlft,exprght,oprelat,datatyp,outjoin)	; Set whr array
	;-----------------------------------------------------------------------
	;
	S whr(nbrexpr)=exprlft_$C(9)_exprght_$C(9)_oprelat_$C(9)_datatyp_$C(9)_$G(outjoin)
	Q
	;
	;-----------------------------------------------------------------------
COMPOUND(expr,mark)	; Modify Compound Expression
	;-----------------------------------------------------------------------
	;
	I $L(mark)=2,$A(mark,2)=1 Q			; +100, -100, etc.
	;
	N i,p,flg,nullchk,pflg,pcnt,null		; 03/14/2000 BC
	;
	S p=$E(expr)="'"+1
	S pflg=$E(expr,p)="("
	S flg=0,null="",pcnt=0
	;
	F i=1:1:$L(mark) D
	.	;
	.	S p=$A(mark,i)+1
	.	S z=$E(expr,p)
	.	I z="(" S pcnt=pcnt+1 Q
	.	I z=")" S pcnt=pcnt-1 I pflg,pcnt=0 S pflg=0 Q
	.	I z=$C(1) D  Q
	..		;
	..		S z=$E(expr,p,$S(i=$L(mark):$L(expr),1:$A(mark,i+1)))
	..		I null="" S null=z_"="""""
	..		E  S null=null_"!("_z_"="""")"
	.	.
	.	S flg=1
	;
	I flg=0!pcnt Q						; No Math
	;
	I pflg=0,pcnt=0 S expr="("_expr_")"
	I null'="",'$G(dqm) S expr="$S("_null_":"""",1:"_expr_")"
	Q
	;
	;-----------------------------------------------------------------------
GETEXPR(object)	; Return value of  exprlft or exprght
	;-----------------------------------------------------------------------
	;
	I object=3 Q $TR(exprlft,"()")
	Q $TR(exprght,"()")
	;
	;-----------------------------------------------------------------------
SET(object,WRD,mark)	; Set exprlft or exprght and mark location
	;-----------------------------------------------------------------------
	;
	;
	I object=3 S marklft=marklft_$C($L(exprlft)),exprlft=exprlft_WRD
	E  S markrht=markrht_$C($L(exprght)),exprght=exprght_WRD
	Q
	;
CONTAIN(X,Y)	Q ","_X_","[(","_Y_",") 
	;
	;----------------------------------------------------------------------
SUBQUERY(expr)	; Subquery
	;----------------------------------------------------------------------
	N isAgg,I
	I oprelat="" D ERROR("Invalid subquery, missing operator") Q
	N PREVFROM 
	S PREVFROM=$G(FROM)
	;
	N SELECT,FROM,WHERE,ORDER,GROUP
	S SELECT=$$TOK^SQL(expr,"FROM,WHERE,ORDER,GROUP",.tok)
	;
	I $G(SELECT)="" D ERROR($$^MSG(8569)) Q
	I $G(FROM)="" D ERROR($$^MSG(8561)) Q
	I $G(GROUP)'="" D ERROR($$^MSG(8562)) Q
	;
	I FROM[$C(0) S FROM=$$UNTOK^%ZS(FROM,.tok)
	I FROM["""" S FROM=$$QSUB^%ZS(FROM)
	;
	I $E(SELECT,1,4)="ALL " S SELECT=$e(SELECT,5,$L(SELECT))
	E  I $E(SELECT,1,8)="DISTINCT " S SELECT=$e(SELECT,9,$L(SELECT))
	;
	N exprsel,function
	S isAgg=0
	S exprsel=""
	I oprelat="E" S ORDER="",SELECT=""
	;
	E  F I=1:1:$L(SELECT,",") D  I ER Q	; Allow for multiple SELECT list columns
	.	N col,typ,agtest
	.	S col=$P(SELECT,",",I)
	.	S agtest=","_$P(col,"(",1)_","
	.	I col["(",",MIN,MAX,AVG,COUNT,SUM,"[agtest D
	..		S isAgg=1
	..		S par("SAVSYM")="rng,whr,vsub"
	..		I "<>="[$E(oprelat),(oprelat'="=ANY") S oprelat=$E(oprelat)
	.	E  D
	..		S exprsel=exprsel_","_$$MCOL^SQLCOL(col,FROM,,.typ,,.fsn,,,.tok,.vdd,1) Q:ER
	..		I $P(datatyp,$C(0),I)="" S datatyp=typ
	..		E  I '$$VALSQTYP($P(datatyp,$C(0),I),typ) S ER=1,RM="Query type error - sub-query datatype mismatch" Q
	.	I "<>"[$E(oprelat),$E(exprsel)'="(" S ORDER=SELECT I $$CONTAIN("<ANY,>ALL",oprelat) S ORDER=ORDER_" DESC"
	Q:ER
	;
	N expr,fkey,key,lvn,newtmp,par,pf,ptr,sav0,savexe,savone,v,z,zrng,zvsub,zwhr
	;
	; If:
	;	- This is an IN condition and 
	;	- Not a NOT IN and 
	;	- The inner SELECT column is a single primary key
	; Then:
	;	The inner WHERE can be transferred up and the subquery eliminated!!!!!!
	N zFROM
	S zFROM=$$^SQLJ(FROM,.whr,.fsn,.tok)
	I $L(zFROM,",")>1 S ER=1,RM="Table join in subquery not supported" Q
	I $D(vAlias(zFROM)) S zFROM=vAlias(zFROM)
	I '$D(fsn(zFROM)) D fsn^SQLDD(.fsn,zFROM)
	S key=$P(fsn(zFROM),"|",3)
	;
	I "I="[oprelat,'notoper,$L(key,",")=1,$C(1)_zFROM_"."_key_$C(1)=exprsel D  Q
	.	;
	.	I '$$CONTAIN(frm,zFROM) S frm=frm_","_zFROM
	.	;
	.	S WHERE=$G(WHERE)
	. 	I exprlft'=exprsel D		; Add Join expression
	..		;
	..		I WHERE'="" S WHERE="AND "_WHERE
	..		S WHERE=$TR(exprlft,$C(1)," ")_"="_$TR(exprsel,$C(1)," ")_WHERE
	.	;
	.	D INI S nbrexpr=nbrexpr-1
	.	I WHERE'="" D NEST("("_WHERE_")",1)
	;
	I SELECT="" S expr="FROM "_FROM
	E  S expr=$S('isAgg:"DISTINCT ",1:"")_SELECT_" FROM "_FROM
	;
	I $G(WHERE)'="" S expr=expr_" WHERE "_WHERE
	I $G(ORDER)'="" S expr=expr_" ORDER BY "_ORDER
	;
	S savexe=+$G(exe)
	;
	S vsql("R")=frm					; Save for correllated
	;
	S par("SAVSYM")="rng,whr,vsub"
	D SELECT^SQL(expr,.par,,,,,.tok,-2) I ER Q
	;
	S lvn=""		; Copy saved arrays into zrng,zvsub and zwhr
	F  S lvn=$O(vsql("S",lvn)) Q:lvn=""  S @("z"_lvn)=vsql("S",lvn)
	;
	K vsql("S")
	;
	I $D(vsql("R"))>1 D CORREL Q			; Correllated Subquery
	;
	; Here's a cool optimization.  There is a transitive relationship
	; between the subquery select column and the outer query.  
	; Exclusive AND's from the subquery can be passed up!!
	;
	I "I="[oprelat,$L(exprsel,$C(1))=3 D
	.	;
	.	N dinam,x,z
	.	S dinam=$P(exprsel,$C(1),2),z=""
	.	F  S z=$O(zrng(dinam,z)) Q:z=""  D
	..		;
	..		S x=zwhr(zrng(dinam,z))
	..		;
	..		I exprlft'[exprsel F  Q:x'[exprsel   S x=$P(x,exprsel,1)_exprlft_$P(x,exprsel,2,999)
	..		;
	..		S whr=whr_nbrexpr_"&"
	..		S whr(nbrexpr)=x
	..		S nbrexpr=nbrexpr+1
	;
	S savone=$G(vsql("O")),sav0=$G(vsql(0))-1,newtmp=$G(vsql("T"))
	;
	S z=$G(vsql("I")),z=$P(z,",",$L(z,","))
	;
	I z="" S key=""
	E  D
	.	S key=$G(vsql("I",z))
	.	S key=$P(key,"|",2)
	.	S key=z_"."_$P(key,",",$L(key,","))
	;
	S z=$O(vsql(1000000),-1) 			; Get last varseq
	;
	K vsql
	S vsql(z)=""
	;
	I oprelat="E" K exe(exe) S exe=exe-1 Q		; Query Passed - Drop
	;
	S lvn=$S(key="":"",1:$G(zvsub(key)))
	;
	; 01/20/09 Pete Chenard - include ANY operator in this check - it behaves similar to IN
	I '((oprelat="I")!(oprelat["ANY"))!(savone=1) D SUBQONE Q
	;
	S fkey=(exe(exe)=("S vd="_lvn))			; Select is bottom key
	I fkey,exe(exe-1)[" S vsql=-1" D SUBACC Q	; bottom key of a single key table 
	;
	S tmptbl=$$TMPTBL^SQLM
	I 'fkey D
	.	;
	.	S exe=exe+1,lvn="vd"
	.	I datatyp="$" S lvn="+"_lvn
	;
	S exe(exe)=$S(lvn="vd":"I vd'="""" ",1:"")_"S "_tmptbl_","_lvn_")="""""
	;
	I 'isAgg S exe=exe+1,exe(exe)="S vsql="_(sav0)
	S exprght=tmptbl_",#)"
	S vxp=-1
	;
	F I=1:1:exe I exe(I)["S vsql=-1" S exe(I)=$P(exe(I),"S vsql=-1",1)_"S vsql="_exe
	Q
	;
	;-----------------------------------------------------------------------
SUBACC	; Access substitution - inner collating replaces outer
	;-----------------------------------------------------------------------
	;
	; OK, here's the drill.  If the selected column is the bottom key
	; AND there is only one collating level - Substitute the inner
	; collating for the outer collating at this level, and pass up
	; the whr conditions to build the rng(array) at the outer level.
	;
	; Big optimization -- avoids building a temporary array.
	;
	; Move host variables to vsub
	S z=":" F  S z=$O(zvsub(z)) Q:$E(z)'=":"  S vsub(z)=zvsub(z)
	;
	S exprght=$$ARRAY(exe(exe-1))
	;
	F exe=exe:-1:(savexe+1) K exe(exe)
	S exe=exe-1
	Q
	;
	;-----------------------------------------------------------------------
SUBQONE	; Subquery needs one row
	;-----------------------------------------------------------------------
	;
	N cv
	;
	I exe(exe)["S vd=" S cv=$P(exe(exe),"S vd=",2)
	E  S ER=1,RM="Subquery Column Select Error" Q
	;
	I cv=+cv!($E(cv)="""") S exprght=cv,oprelat=$E(oprelat) Q
	;
	I cv?1"$".E D					; Function
	.	;
	.	S cv="vd"
	.	I datatyp="$" S cv="+"_cv 		; MUMPS null = 0
	.	E  S exe=exe+1,exe(exe)="I vd="""" S vsql=-1"
	;
	E  S exe=exe-1
	;
	I savone D  Q
	.	;
	.	I cv["vd" D				; Remap to vsql
	..		;
	..		S exprght="vsql("_$$NXTSYM^SQLM_")"
	..		S exe=exe+1,exe(exe)="S "_exprght_"="_cv
	.	;
	.	E  S exprght=cv
	.	;
	.	I oprelat="I" S oprelat="="
	.	S oprelat=$E(oprelat)
	;
	I sav0=1,cv=lvn S exprght=cv,oprelat=$E(oprelat) Q
	;
	S exprght="vsql("_$$NXTSYM^SQLM_")"
	;
	E  I $$CONTAIN(">ANY,<ALL",oprelat) D
	.	;
	.	S exe=exe+1,exe(exe)="I $G("_exprght_")="""" S "_exprght_"="_cv
	.	S exe=exe+1,exe(exe)="E  I "_cv_" S:"_cv_"<"_exprght_" "_exprght_"="_cv
	.	S exe=exe+1,exe(exe)="E  S:"_exprght_"]]"_cv_" "_exprght_"="_cv
	.	I cv=lvn S sav0=$P(exe(sav0+1),"S vsql=",2)
	;
	E  I $$CONTAIN("<ANY,>ALL",oprelat) D
	.	;
	.	S exe=exe+1,exe(exe)="I $G("_exprght_")="""" S "_exprght_"="_cv
	.	S exe=exe+1,exe(exe)="E  I "_cv_" S:"_cv_">"_exprght_" "_exprght_"="_cv
	.	S exe=exe+1,exe(exe)="E  S:"_cv_"]]"_exprght_" "_exprght_"="_cv
	.	I cv=lvn S sav0=$P(exe(sav0+1),"S vsql=",2)
	;
	E  D
	.	;
	.	S exe=exe+1,exe(exe)="I $G("_exprght_")="""" S "_exprght_"="_cv
	.	S exe=exe+1,exe(exe)="E  I "_cv_"'="_exprght_" S ER=1,RM=""Multiple rows in subquery"" S vsql=-1"
	;
	S oprelat=$E(oprelat)
	S exe=exe+1,exe(exe)="S vsql="_sav0
	;
	F z=1:1:exe I exe(z)["S vsql="&(exe(z)["$O(") S exe(z)=$P(exe(z),"S vsql=",1)_"S vsql="_exe Q
	;
	I cv'="vd" S exe=exe+1,exe(exe)="I $G("_exprght_")="""" s vsql=-1"
	Q
	;
	;----------------------------------------------------------------------
VALSQTYP(OUTTYP,INTYP)	; Validate data types for sub-query use
	;----------------------------------------------------------------------
	;
	; Valid is numeric or string types on the outside against numeric or
	; string types on the inside, but only numeric on the outside against
	; numeric on the inside.
	;
	; ARGUMENTS:
	;	. OUTTYP	Outer data type			/REQ/MECH=VAL
	;
	;	. INTYP		Inner (sub-query) data type	/REQ/MECH=VAL
	;
	; For example, SELECT CID FROM ACN WHERE CID IN
	;			(SELECT KEY1 FROM TMPRPT1 WHERE PID=:PID)
	;
	;	OUTTYP is N, since that's the data type of ACN.CID
	;	INTYP is T, since that's the data type of TMPRPT1.KEY1
	;
	N OK
	S OK=1
	;
	; These datatypes only work against themselves
	I ((",D,C,L,B,M,")[(","_INTYP_","))!((",D,C,L,B,M,")[(","_OUTTYP_",")),INTYP'=OUTTYP S OK=0
	;
	; Otherwise, we're dealing with N,$,T,U, or F
	; If INTYP is a numeric type, then OUTTYP must also be numeric
	E  I (",N,$,")[(","_INTYP_","),(",N,$,")'[(","_OUTTYP_",") S OK=0
	;
	Q OK
	;
	;-----------------------------------------------------------------------
ARRAY(z)	; Return Special array expression ^gvn(key1,...#)
	;-----------------------------------------------------------------------
	;
	N return
	S z=$P($P(z,"^",2,999),")),",1)
	S return="^"_$P(z,"(",1)_"("
	S z=$P($P(z,"(",2,999),",",1,$L(z,",")-1) I z'="" S z=z_","
	Q return_z_"#)"
	;
	;--------------------------------------------------------------------
CORREL	; Build correlated Subquery code
	;--------------------------------------------------------------------
	;
	N ddref,fnum,gbref,i,v,z
	;
	F fnum=1:1 S z=$G(vsql("G",fnum)) Q:z=""  D
	.	;
	.	F i=2:2 S ddref=$P(z,$C(1),i) Q:ddref=""  D  Q:p=""
	..		;
	..		S p=$G(zrng(ddref,"=")) I p="" Q
	..		S zrng=$E(zrng,1,p-1)_1_$E(zrng,p+1,$L(zrng))
	..		;
	..		S ddref=$C(1)_ddref_$C(1)
	..		I $P(zwhr(p),$C(9),1)=ddref S v=$P(zwhr(p),$C(9),2)
	..		E  S v=$P(zwhr(p),$C(9),1)
	..		;
	..		I $D(vsql("R",v)) S $P(z,$C(1),i)=vsql("R",v)
	.	;
	.	I i>$L(z,$C(1)) S gbref=z 
	.	E  S gbref=$P(z,$C(1),1,i-1),gbref=$E(gbref,1,$L(gbref)-1)
	;
	I zrng'["0",fnum=2 D
	.	;
	.	F i=savexe+1:1:exe K exe(i)
	.	S exprlft="$D("_gbref_"))"
	.	S exprght=0
	.	S oprelat=">"
	.	S datatyp="N"
	;
	E  D
	.	S exprlft="",v="" 
	.	F  S v=$O(vsql("R",v)) Q:v=""  S exprlft=exprlft_v_"="_$C(1)_vsql("R",v)_$C(1)_","
	.	S exprlft=$E(exprlft,1,$L(exprlft)-1)
	.	S exprght=$O(vsql("E",""),-1)+1
	.	F i=savexe+1:1:exe S vsql("E",exprght,i)=exe(i) K exe(i)
	;
	S exe=savexe
	;
	K vsql("G")
	K vsql("R")
	Q
	;
	;--------------------------------------------------------------------
REMPAR(str,ptr)	;	Remove all unnecessary paranthesis
	;--------------------------------------------------------------------
	;
	S ptr=$G(ptr)
	;
	S ptr=$F(str,"(",ptr) I ptr=0 Q str
	;
	N i,n,y,z
	S y=$F(str,")",ptr),n=$L($E(str,ptr,y-1),"(")-1
	;
	I n F i=1:1:n S z=y,y=$F(str,")",y) I $E(str,z,y)["(" S i=i-$L($E(str,z,y),"(")+1
	;
	; Search for unnecessary boundary paranthesis
	I ptr=2,y>$L(str) S ptr=1 Q $E(str,2,$L(str)-1)
	;
	I $E(str,ptr-2,y)["!",'($E(str,ptr,y-2)?.N) Q str
	;
	S n=$E(str,ptr,y-2),ptr=ptr-1
	I $E(str,ptr-1)="'" I '(n?.N) S ptr=ptr+1 Q str
	I $E(str,ptr-1)="'" D
	.	;
	.	S str=$E(str,1,ptr-2)_$E(str,ptr,$L(str))
	.	S ptr=ptr-1,y=y-1
	.	S $P(whr(n),$C(9),3)="'"_$P(whr(n),$C(9),3) Q
	;
	I $E(str,ptr-1)="!" D
	.	;
	.	I '("I="[$P(whr(n),$C(9),3)) Q
	.	I '("I="[$P(whr(n-1),$C(9),3)) Q
	.	I '($P(whr(n),$C(9),1)=$P(whr(n-1),$C(9),1)) Q
	.	;
	.	N x,y
	.	S x=$P(whr(n),$C(9),2) 
	.	I $P(whr(n),$C(9),3)="=" S x=$$QSWP^%ZS(x,"""","'")
	.    	S y=$P(whr(n-1),$C(9),2)
	.	I $P(whr(n-1),$C(9),3)="=" S y=$$QSWP^%ZS(y,"""","'")
	.	;
	.	S $P(whr(n-1),$C(9),2)=x_","_y
	.	S $P(whr(n-1),$C(9),3)="I"
	.	;
	.	D SETWHR(n,1,1,"=","N",0)
	.	S str=$E(str,1,ptr-2)_"&"_$E(str,ptr,$L(str))
	;
	Q $E(str,1,ptr-1)_n_$E(str,y,$L(str))
	;
	;--------------------------------------------------------------------
ADDVAL(str,val)	; Add Value to String
	;--------------------------------------------------------------------
	;
	I $G(str)="" Q $G(val)
	Q str_","_$G(val)
	;
	;----------------------------------------------------------------------
RANGE(nbrexpr,whr,rng)	; Conditionally Build the range array
	;----------------------------------------------------------------------
	;
	N datatyp,dinam,exprlft,exprght,i,maxCharV,outjoin,oprelat,tmpexprlft,X
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	;
	S X=whr(nbrexpr)
	;
	S exprlft=$P(X,$C(9),1),exprght=$P(X,$C(9),2)
	S oprelat=$P(X,$C(9),3),datatyp=$P(X,$C(9),4)
	S outjoin=$P(X,$C(9),5)
	;
	; Modified to allow for multiple expressions delimited by $C(0)
	S tmpexprlft=exprlft
	F i=1:1:$L(tmpexprlft,$C(0)) d
	.	S exprlft=$P(tmpexprlft,$C(0),i)
	.	S dinam=$P(exprlft,$C(1),2) I dinam="" Q
	.	;
	.	; Patch input for (table.column) syntax *** 08/25/00
	.	I $E(exprlft)="(" S exprlft=$$POP^%ZS(exprlft)
	.	I $E(exprght)="(" S exprght=$$POP^%ZS(exprght)
	.	;
	.	I $P(exprlft,$C(1),1)'="",$E(exprght)="""",$E(oprelat)'="'" D  Q
	..	       ;
	..	       S z=$P(exprlft,$C(1),1)
	..	       I z'="$E(",z'="$P(" Q
	..	       I $TR($P($P(exprlft,$C(1),3),",",$S(z="$E(":2,1:3)),"""","")>1 Q
	..	       ;
	..		; 'Hide' whr() with pointer values <0 - May be used to optimize
	..		;
	..		N nbrexpr,oprelat
	..		;
	..		F nbrexpr=-1:-1 Q:'$D(whr(nbrexpr))
	..		S oprelat="'<"
	..		D SETWHR(nbrexpr,exprlft,exprght,oprelat,datatyp,outjoin)
	..		D SETRNG(dinam,exprght,oprelat,datatyp)	; low range
	..		;
	..		S nbrexpr=nbrexpr-1,oprelat="'>"
	..		S exprght=$E(exprght,1,$L(exprght)-1)_maxCharV_""""
	..		D SETWHR(nbrexpr,exprlft,exprght,oprelat,datatyp,outjoin)
	..		D SETRNG(dinam,exprght,oprelat,datatyp)	; high range
	.
	.	I $P(exprlft,$C(1),3)'="" Q			; Figure out later
	.	;
	.	I oprelat="=",$A(exprght)=1 D  Q
	..		;
	..		D SETRNG(dinam,exprght,"J",datatyp)
	..		D POINTER(dinam,$P(exprght,$C(1),2)) Q
	.	;
	.	D SETRNG(dinam,exprght,oprelat,datatyp)		; Set rng array
	.	;
	.	I outjoin Q
	.	;
	.	; Remove outer join because there's a query!
	.	;
	.	I $D(join($P(dinam,".",1)))#2,exprght'="""""" D
	..		K join($P(dinam,".",1))
	..		S $P(whr(nbrexpr),$C(9),5)=0
	.	;
	.	N I,jlist
	.	S jlist=$G(join(dinam))
	.	I jlist'="" F I=1:1:$L(jlist,",") D SETRNG($P(jlist,",",I),exprght,oprelat,datatyp)	; Set Range variables
	Q
	;
	;----------------------------------------------------------------------
SETRNG(exprlft,exprght,oprelat,datatyp)	; Set Range variables
	;----------------------------------------------------------------------
	;
	I $D(rng(exprlft,oprelat)) D  Q
	.	;
	.	N v,z
	.	S v=rng(exprlft,oprelat) I v=nbrexpr Q		; Same pointer
	.	S z=$P(whr(v),$C(9),2)
	.	I z=exprght S rng=$E(rng,1,nbrexpr-1)_0_$E(rng,nbrexpr+1,$L(rng)) Q
	.	I oprelat="=",'(z[$C(1)!(exprght[$C(1))) D	; const=const
	..		;
	..		S exe=$G(exe)+1
	..		S exe(exe)="I '("_z_"="_exprght_") S vsql=-1"
	..		S rng=$E(rng,1,nbrexpr-1)_0_$E(rng,nbrexpr+1,$L(rng))
	;
	S rng(exprlft)=datatyp
	S rng(exprlft,oprelat)=nbrexpr
	Q
	;
	;----------------------------------------------------------------------
POINTER(ddref1,ddref2)	; Value is a pointer to another value
	;----------------------------------------------------------------------
	;
	N jlist,v1,v2,v,I
	;
	I $P(ddref2,".",1)=$P(ddref1,".",1) Q	
	;
	S v1=$G(join(ddref1)),v2=$G(join(ddref2))
	I v1[ddref2 Q						; Done before
	;
	; Generate Union of pointers in v1 and v2
	;
	S v=v1
	I v2'="" F I=1:1:$L(v2,",") I v'[(","_$P(v2,",",I)) S:v'="" v=v_"," S v=v_$P(v2,",",I)
	;
	I v="" S v1=ddref2,v2=ddref1
	E  S v1=ddref2_","_v,v2=ddref1_","_v
	;
	S join(ddref1)=v1
	S join(ddref2)=v2
	Q
	;
	;----------------------------------------------------------------------
MERGE(ddref1,ddref2)	; Merge rng arrays of ddref1 and ddref2
	;----------------------------------------------------------------------
	;
	N j1,j2,oprelat,datatyp,exprght,nbrexpr
	S oprelat=""
	;
	;S j1=($G(join($P(ddref1,".",1)))=$P(ddref2,".",1))
	;S j2=($G(join($P(ddref2,".",1)))=$P(ddref1,".",1))
	;
	S j1=0,j2=0
	F  S oprelat=$O(rng(ddref1,oprelat)) Q:oprelat=""  D
	.	;
	.	S datatyp=rng(ddref1),nbrexpr=rng(ddref1,oprelat)
	.	I j1,$P(whr(nbrexpr),$C(9),5) Q
	.	S exprght=$P(whr(nbrexpr),$C(9),2)
	.	D SETRNG(ddref2,exprght,oprelat,datatyp) Q
	;
	F  S oprelat=$O(rng(ddref2,oprelat)) Q:oprelat=""  D
	.	;
	.	S datatyp=rng(ddref2),nbrexpr=rng(ddref2,oprelat)
	.	I j2,$P(whr(nbrexpr),$C(9),5) Q
	.	S exprght=$P(whr(nbrexpr),$C(9),2)
	.	D SETRNG(ddref1,exprght,oprelat,datatyp) Q
	Q
	; 
	;----------------------------------------------------------------------- 
SWAP(exprlft,exprght,oprelat)	; Swap Left and right expressions to optimize 
	;----------------------------------------------------------------------- 
	; 
	I $P(exprght,$C(1),2)="" Q 
	I '$$CONTAIN("=,'=,<,>,'<,'>",oprelat) Q 
	; 
	N z 
	S z=exprlft,exprlft=exprght,exprght=z 
	I oprelat="=" Q 
	I oprelat="<" S oprelat=">" Q 
	I oprelat=">" S oprelat="<" Q 
	I oprelat="'<" S oprelat="'>" Q 
	I oprelat="'>" S oprelat="'<" Q 
	Q 
	; 
	;----------------------------------------------------------------------- 
HOSTVAR(expr,typ,vsub,exe)	; Host variable Processing 
	;----------------------------------------------------------------------- 
	;
	N hvexpr
	;
	S typ=$G(typ)
	I typ="",$$CONTAIN(":+$H,:TJD",expr) S typ="D"
	;
	I $D(vsub(expr)) Q vsub(expr)
	;
	N v,vexpr,z,zk
	; 
	N v,vexpr 
	S v=$E(expr,2,99)   			; Variable name syntax
	I '((v?1"%".UN)!(v?1U.UN)!(v["$H")) S ER=1,RM=$$^MSG(8592,expr) Q "" 
	; 
	S v="vsql("_$$NXTSYM^SQLM_")",vsub(expr)=v
	;
	S exe=$G(vsql("V"))+1,vsql("V")=exe
	;
	I $D(exe(exe+1)) D
	.	;
	.	N g,i,z
	.	S g="S vsql="
	.	S i=$O(exe(""),-1)
	.       I vxp'<exe S vxp=vxp+1 
	.	;
	.	F i=i:-1:exe D
	..		;
	..		S z=exe(i)
	..		I z[g,$P(z,g,2)'<exe S z=$P(z,g,1)_g_($P(z,g,2)+1)
	..		S exe(i+1)=z
	.	;
	.	; Also need to adjust the mcode array to set vsql appropriately. pc 2/21/05
	.	F i=1:1 Q:'$D(mcode(i))  do 
	..		S z=mcode(i)
	..		I z[g,$P(z,g,2)'<exe S z=$P(z,g,1)_g_($P(z,g,2)+1)
	..		S mcode(i)=z
	;
	S exe=$O(exe(""),-1)+1				; next sequence
	S vexpr=$E(expr,2,$L(expr))
	I vexpr'["$" S z=vexpr,vexpr="$G("_vexpr_")"	; Null value
	S exe(exe)="S "_v_"="_vexpr			; vsql(n)=host_variable		; 04/23/99
	;
	; Build "hostVars" so that by Xecuting "S using="_vsql(""hostVars"")" we
	; get a string of variables and values, e.g, V1='ABC',etc.
	I $D(vsql("hostVars")) S vsql("hostVars")=vsql("hostVars")_"_"","
	E  S vsql("hostVars")=""""
	I "TUF"[typ S hvexpr="$$QADD^%ZS("_vexpr_",""'"")"
	E  S hvexpr=vexpr
	S vsql("hostVars")=vsql("hostVars")_$E(expr,2,$L(expr))_"=""_"_hvexpr
	;
	I  D						; *** 08/14/98
	.	S exe(exe)=exe(exe)_" I "_v_"="""""
	.	I $g(exprlft)'="",$F(exprlft,$C(1)) D			;5/18/2000 mas
	..		S zk=$$NOD^SQLDD($P(exprlft,$C(1),2))	; Check NULL condition 04/19/2000
	..		I zk'?1N1"*"!($G(val)'="=") S exe(exe)=exe(exe)_",'$D("_z_")"
	.	S exe(exe)=exe(exe)_" S vsql=-1"
	;
	I $D(savexe) S savexe=exe			; Save this line
	S exe=$O(exe(""),-1)
	;						; Date conversion 10/27/99
	I typ="" Q v					; System variable
	I "DCL$N"'[typ Q v				; Conversion not required
        I typ="N",'$G(dec) Q v                          ; whole number
	;						; Convert it to internal format
	S exe=exe+1,vsql("V")=exe                       ;43218 mas
	I typ="D" S exe(exe)="I "_v_"'?.N S "_v_"=$$FDAT^%ZM("_v_")"	; date conversion
	I typ="C" S exe(exe)="I "_v_"'?.N S "_v_"=$$FTIM^%ZM("_v_")"	; time conversion
	I typ="L" S exe(exe)="I "_v_"'?.N S "_v_"=$$FLOG^%ZM("_v_")"	; logical conversion
        I typ="$"!(typ="N") S exe(exe)="S "_v_"=+"_v			; Numeric with decimal 01/20/2000
	Q v
	;
	;----------------------------------------------------------------------
SERIAL(whr)	; Private ; Try to move queries on serials columns to front
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;	. whr()	Profile SQL whr array 	/TYP=T/REQ/NONUL/MECH=REFARR:RW
	;
	; EXAMPLE:
	;	S whr=$$SERIAL(.whr)
	;
	; This subroutine will optimize a whr expression that contains at least
	; one serial column (DBTBL1D.SRL) by moving the serial column(s) as far
	; as possible towards the front of the expression.
	;
	; Moving a serial column earlier may result in a more efficient
	; evaluation of the whr expression, causing it to require fewer rows to
	; access prior to termination.  Consider the following example:
	;
	;   - SELECT TAMT FROM HIST WHERE TAMT>10000 AND TJD<56000
	;
	;       The where clause will evaluate TAMT>10000 first, and, if it
	;       is false, will fetch the next row, never evaluating
	;       TJD<56000.
	;
	;       However, if the WHERE clause were reversed to read
	;       WHERE TJD<56000 AND TAMT>10000, then TJD<56000 element
	;       would be evaluated first, and, because TSEQ is a serial
	;       column, as soon as a row was retrieved that did not pass
	;       this test, the entire query would be complete.
	;
	;       Automatically switching the order of these two elements
	;       results in a potentially more efficient query, with the
	;       same logic meaning.
	;
	; A further optimization, where a serial column uses an equals
	; operation and is not nested, allows us to stop collating once
	; we are past the "equals" value.  This is handled in ^SQLA for
	; < and > operations, and was attempted for = by adding a query
	; with the appropriate < or > test.  However, the query was
	; always added to the end of the whr array.  New code here will
	; add the query to the left of a top level, serial, equals query
	; where only AND conditions are involved.
	;
	; The algorithm used for this process is:
	;   - a serial element is either a serial column or a set of elements
	;     in parenthesis that contains a serial column
	;   - a serial element will be moved to the left only at its
	;     parenthesis level
	;   - a serial element will be moved to the left if the operator
	;     to its left is an & AND, either the element to the left of
	;     the & is the last element at the parenthesis level, OR, the
	;     operator to the left of the element to the left of the serial
	;     element is also an &.
	;   - if the element to the left of a serial element is also a
	;     serial element or a key, the right-most serial element will not
	;     be moved.
	;   - if a serial element is at the top of the nest, and is involved
	;     in an equals operation, a new '< or '> query will be added to
	;     its left to allow stopping collating as quickly as possible.
	;
	; Examples (assume column represented by S is the only serial column):
	;
	;   - A&S => S&A
	;   - A&B&S => S&A&B
	;   - A!B&S => A!B&S (No change since promoting the serial column
	;                     would change the meaning of the expressions
	;                     since evaluation takes place left to right)
	;   - A!(B&S) => A!(S&B)
	;   - (A!B)&(C&S) => (S&C)&(A!B) (The expression (C&S) is considered
	;                                 serial since it contains a serial
	;                                 column).
	;
	; The whr expression (made up of numbers representing the elements,
	; & and ! operators, and parenthesis) is first parsed into a parse
	; tree resulting in individual expressions representing parenthesis
	; groups.  The base, parse, expression is then evaluated right to
	; left, promoting serial elements accoring to the rules stated.
	;
	; For example, if whr=1&(2&3)!4!(5&6), this will be parsed into:
	;    TREE(0)="1^&^TREE(0,1)^!^4^!^TREE(0,2)"
	;    TREE(0,1)="2^&^3"
	;    TREE(0,2)="5^&^6"
	;
	;    The parenthesied expression (2&3) is replaced by TREE(0,1), and
	;    (5&6) by TREE(0,2) in the base expression.  These are simply the
	;    1st and 2nd replaced expressions at this level.  This would
	;    continue for further nested expressions.  Basically,
	;    parenthesied expressions are replaced and moved into the tree
	;    structure.  This provides the structure to execute the
	;    algorithm against the base expression.
	;
	N N,PROMOTED,SERIAL,TREE
	;
	; If no serial columns, no need to go further
	S N="",SERIAL=0
	F  S N=$O(whr(N)) Q:N=""  I $P(whr(N),$C(9),6) S SERIAL=1 Q
	Q:'SERIAL
	;
	S PROMOTED=0					; Something promoted flag
	D SRLPARSE(whr,.TREE)				; Parse it
	S SERIAL=$$SRLOPTMZ("TREE(0)",.TREE,.whr)	; See if can optimize it
	I $P(TREE(0),"|",1) D SRLEQOPT(.TREE,.whr)	; If serial, optimize equals at top
	I PROMOTED D
	.	S whr=$$SRLUNPRS("TREE(0)",.TREE)	; Unparse it
	.	D SRLWHR(.whr)				; Reorder whr()
	;
	Q
	;
SRLPARSE(whr,TREE)	;Private; Move whr expression into parse tree
	;
	; ARGUMENTS:
	;	. whr()		whr array	 	/TYP=T/REQ/NONUL/MECH=REFARR:R
	;
	;	. TREE()	Parse tree		/TYP=T/REQ/MECH=REFAFF:W
	;
	N char,del,expr,I,lvl,newexpr,ref,subscrpt,x
	;
	S lvl=0,expr="TREE(0)",del="^"
	S @expr=""
	;
	F I=1:1:$L(whr) D
	.	S char=$E(whr,I)
	.	I char?1N S @expr=@expr_char		; add to expression
	.	E  I "!&"[char S @expr=@expr_del_char_del
	.	E  I char="(" D				; drop down to next level
	..		S lvl=lvl+1
	..		S x=$P(expr,")",1)_","""")"
	..		S subscrpt=$O(@x,-1)+1		; Next subscript, this level
	..		S newexpr=$p(expr,")",1)_","_subscrpt_")"
	..		S @expr=@expr_newexpr		; Add new expression to this level
	..		S expr=newexpr			; Start building new expression
	..		S @expr=$G(@expr)		; Initialize to null if necessary
	.	E  D					; char=")"
	..		S lvl=lvl-1			; Pop up a level
	..		S expr=$P(expr,",",1,$L(expr,",")-1)_")"
	Q
	;
SRLOPTMZ(ref,TREE,whr)	; Attempt to optimize expression for serial elements
	;
	; ARGUMENTS:
	;	. ref		Reference to the	/TYP=T/REQ/NONUL/MECH=VAL
	;			parse expression that
	;			we will try to optimize,
	;			or a base (number) element
	;
	;	. TREE()	Parse tree		/TYP=T/REQ/MECH=REFAFF:R
	;
	;	. whr()		whr array	 	/TYP=T/REQ/NONUL/MECH=REFARR:R
	;
	; RETURNS:
	;	. $$	Boolean indicating if expr	/TYP=L
	;		is serial
	;
	; EXAMPLE:
	;	S SERIAL=$$SRLOPTMZ("TREE(0,1)",.TREE)
	;
	; Note that this function is called recursively if parenthesied
	; expressions (TREE elements) are found in expr.  Because an expression
	; might be passed into here more than once (this could happen if we
	; are dealing with multiple serial elements) the TREE array is flagged
	; for each element to indicate that it has already been optimized.
	;   - Piece 2 ("|") if not null, indicates optimized and the value
	;     indicates if serial or not
	;
	;   - For the purposes of this section, a key is considered serial, and
	;     other serial columsn won't be promoted ahead of it.
	;
	N elem,expr,I,isSerial,leftelem,rghtelem,serial,X
	;
	S isSerial=0
	I ref?1N.N D  Q isSerial			; Base element
	.	I $P(whr(ref),$C(9),6) set isSerial=1	; Serial column
	.	E  D					; See if key
	..		N column,ddref,file,keys
	..		S ddref=$P(whr(ref),$C(1),2) Q:ddref=""
	..		S file=$P(ddref,".",1),column=$P(ddref,".",2)
	..		S keys=$P(fsn(file),"|",3)
	..		I ","_keys_","[(","_column_",") S isSerial=1
	;
	S X=@ref
	S serial=$P(X,"|",2)
	I serial'="" Q serial
	S expr=$P(X,"|",1)
	S isSerial=0		; Track whether this expression is serial
	;
	; Evaluate from right to left, elements are odd positions, operators even
	F I=$L(expr,"^"):-2:1 D
	.	S elem=$P(expr,"^",I)
	.	S serial=$$SRLOPTMZ(elem,.TREE,.whr)
	.	Q:'serial			; Not serial, don't try to promote
	.	S isSerial=1			; This expression has a serial component
	.	Q:I=1				; At far left
	.	Q:$P(expr,"^",I-1)'="&"		; Operator to left isn't an &
	.	Q:(I>3)&($P(expr,"^",I-3)'="&")	; Second leftmost operator isn't an &
	.	S leftelem=$P(expr,"^",I-2)
	.	S serial=$$SRLOPTMZ(leftelem,.TREE,.whr)
	.	Q:serial			; Element to the left is serial too
	.	;
	.	S $P(expr,"^",I-2)=elem		; OK, we can shift them
	.	S $P(expr,"^",I)=leftelem
	.	S PROMOTED=1			; Something has been promoted
	.	;
	.	; In the event of multiple serial elements, the one to the
	.	; right could be serial as well, so we have to back up and
	.	; allow it to shift (example, A&B&S1&S2, we want to end up
	.	; with S1&S2&A&B)
	.	S rghtelem=$P(expr,"^",I+2) Q:rghtelem=""	; We were at the end
	.	S serial=$$SRLOPTMZ(rghtelem,.TREE,.whr)
	.	I serial S I=I+4		; Move back one
	;
	S @ref=expr_"|"_isSerial		; Save change and fact that we've done this one
	;
	Q isSerial
	;
SRLEQOPT(TREE,whr)	;Private; Optimize serial equals at top level
	;
	; ARGUMENTS;
	;	. TREE()	Parse tree		/TYP=T/REQ/MECH=REFAFF:R
	;
	;	. whr()		whr array	 	/TYP=T/REQ/NONUL/MECH=REFARR:RW
	;
	; RETURNS:
	;	. PROMOTED = 1 if add a new query
	;
	; If serial equals and only ANDs, add new whr element
	;
	N elem,expr,I,newexpr
	;
	S expr=$P(TREE(0),"|",1)
	Q:expr["!"					; Must be only ANDs
	;
	S newexpr=""
	F I=1:1:$L(expr,"^") D
	.	S elem=$P(expr,"^",I)
	.	I I#2=0 S newexpr=newexpr_elem				; Operator
	.	E  I elem'?1N.N S newexpr=newexpr_elem			; Tree element
	.	E  I '$P(whr(elem),$C(9),6) S newexpr=newexpr_elem	; Not serial
	.	E  I $P(whr(elem),$C(9),3)'="=" S newexpr=newexpr_elem	; Not equals
	.	E  D
	..		N OPER,X
	..		I $$SRLORD($P(whr(elem),$C(1),2))="DESC" S OPER="'<"
	..		E  S OPER="'>"
	..		S X=$O(whr(""),-1)+1
	..		S whr(X)=whr(elem)
	..		S $P(whr(X),$C(9),3)=OPER
	..		S nbrexpr=nbrexpr+1			; Increase number of whr elements
	..		S whr=whr_"&"_X
	..		S newexpr=newexpr_X_"^&^"_elem
	..		S PROMOTED=1
	.	S newexpr=newexpr_"^"
	;
	S $P(TREE(0),"|",1)=$E(newexpr,1,$L(newexpr)-1)
	;
	Q
	;
SRLORD(ddref)	;Private; Determine operator based on order by for serial equals optimization
	;
	; ARGUEMNTS:
	;	. ddref		TABLE.COLUMN
	;
	; RETURNS:
	;	. ORDER		DESC or ASC
	;
	; Note that collating order code here is based on code in COLLATE^SQLM
	;
	; This function is also called by SERIAL^SQLA
	;
	; Descending if DESC for either the serial element or the bottom level key for
	; this table
	;
	N file,ORDER
	;
	S file=$P(ddref,".",1)
	S ORDER="ASC"
	I oby[ddref,$P($P(oby,ddref,2),",",1)["DESC" S ORDER="DESC"
	E  D
	.	N btmkey,keys
	.	I '$D(fsn(file)) D fsn^DBSDD(.fsn,file)
	.	S keys=$P(fsn(file),"|",3)
	.	S btmkey=file_"."_$P(keys,",",$L(keys,","))
	.	I oby[btmkey,$P($P(oby,btmkey,2),",",1)["DESC" S ORDER="DESC"
	;
	Q ORDER
	;
SRLUNPRS(ref,TREE)	;Private; Reconstruct whr clause
	; ARGUMENTS:
	;	. ref		Reference to the	/TYP=T/REQ/NONUL/MECH=VAL
	;			parse expression that
	;			we will unparse
	;
	;	. TREE()	Parse tree		/TYP=T/REQ/MECH=REFAFF:R
	;
	; RETURNS:
	;	. $$		Unparsed expression	/TYP=T
	;
	; Note that this function is recursive and will call itself for elements
	; that need to be unparsed
	;
	N elem,expr,I,newexpr
	;
	S expr=$P(@ref,"|",1)
	S newexpr=""
	F I=1:1:$L(expr,"^") D
	.	S elem=$P(expr,"^",I)
	.	I I#2=0 S newexpr=newexpr_elem			; Operator
	.	E  I elem?1N.N S newexpr=newexpr_elem		; Base element
	.	E  S newexpr=newexpr_$$SRLUNPRS(elem,.TREE)	; Tree element
	;
	I ref'="TREE(0)" S newexpr="("_newexpr_")"
	Q newexpr
	;
SRLWHR(whr)	;Private; Rebuild whr structure
	; ARGUMENTS:
	;	. whr()		whr array	 	/TYP=T/REQ/NONUL/MECH=REFARR:RW
	;
	; EXAMPLE:
	;	D SRLWHR(.whr)
	;
	; If elements in whr have been reordered, e.g., (1!2)&(3&4) is now
	; (4&3)!(1&2) due to serial promotion, need to reset elements to the
	; correct numerical order, i.e., (1&2)!(3&4), and reset whr(n) accordingly
	; to allow correct processing.
	;
	N char,I,N,newnbr,oldnbr,whrold
	;
	S whrold=whr
	S N=""
	F  S N=$O(whr(N)) Q:N=""  S whrold(N)=whr(N)
	K whr
	;
	S newnbr=1,oldnbr=""
	S whr=""
	F I=1:1:$L(whrold) D
	.	S char=$E(whrold,I)
	.	I char?1N S oldnbr=oldnbr_char	; Build old number
	.	E  I oldnbr="" S whr=whr_char	; ))
	.	E  D
	..		S whr=whr_newnbr_char	; Assign new number, in order
	..		S whr(newnbr)=whrold(oldnbr)
	..		; Adjust rng array to reflect changes to whr array
	..		D SRLRNG(whr(newnbr),newnbr,.rng)
	..		S newnbr=newnbr+1
	..		S oldnbr=""
	; Handle last element
	I oldnbr'="" D
	.	S whr=whr_newnbr
	.	S whr(newnbr)=whrold(oldnbr)
	.	; Adjust rng array to reflect changes to whr array
	.	D SRLRNG(whr(newnbr),newnbr,.rng)
	;
	Q
	;
SRLRNG(whr,newnbr,rng)	;Private; Adjust rng array to reflect whr changes
	; ARGUMENTS:
	;	. whr		single whr array entry 	/TYP=T/REQ/NONUL
	;	. newnbr	New pointer to whr array for this element /TYP=T/REQ/NONUL
	;	. rng()		rng array		/TYP=T/NOREQ/MECH=REFARR:RW
	;
	; EXAMPLE:
	;	D SRLRNG(whr(newnbr),newnbr,.rng)
	;
	; Need to adjust the rng array in addition to the whr array.
	; rng is structured as rng(column,oper)=whr pointer.
	; Example: rng("DEP.CLS","=")=1
	; We have to change the whr pointer to the new position in the
	; whr array.
	;
	N di,oper
	S di=$P(whr,$C(1),2)
	S oper=$P(whr,$C(9),3)
	I $D(rng(di,oper)) S rng(di,oper)=newnbr
	Q
	;
TYPERR(typ)	Q $$^MSG("742",$P(^DBCTL("SYS","DVFM",typ),"|",1)) ; type error