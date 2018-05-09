SQLA	;private;SQL Query Generator Compiler
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/30/01 14:06:16 - CHENARDP
	;     ORIG:  Frank R. Sanchez (2497) - 22-FEB-95
	;
	; This routine generates MUMPS executable code from specially
	; formatted input records conforming to a defined structure.
	;
	; KEYWORDS:	Parsing,DATA-QWIK
	;
	; RELATED: SQLA,SQLO
	;
	; INPUT:
	;	. whr(line)	Query expression record		/REQ
	;			exprlft|exprght|oprelat|datatyp
	;
	;	exprlft	:== expr[oparith expr...]
	;	exprght	:== expr[oparith expr...]
	;
	;		expr	:== [$func(]value[,func_arg[,...])]
	;		value	:== :var|strlit|numlit|$C(1)_ddref_$c(1)
	;		ddref	:== library.file.data_item
	;
	;			$func	:== $A $C $E $F $F $L $P $ZD $$
	;
	;		oparith	:== + - * / 
	;
	;	oprelat	:== > <  =  [ ? L I
	;	datatyp	:== T U F L D C N $
	;	oplogic	:== & !
	;
	;	. %LIBS		DATA-QWIK Library	/NOREQ
	;	. fsn(file)	File Header		/NOREQ
	;	. vdd(ddref)	Dictionary Records	/NOREQ
	;
	; RETURNS:
	;
	; EXAMPLE:
	;
	; I18N=QUIT: Exculded from I18N standards. 
	; 
	Q
	;---------- Revision History ------------------------------------------
	; 09/07/07 - Pete Chenard - CR27652
	;	     Modified setting of exprght to use $C(254) instead
	;	     of "" in the case where the column is an access key
	;	     and the right expression is "".  This is the case when 
	;	     IS NULL or IS NOT NULL is used with the column in the
	;	     Where clause.
	;
	; 07/10/07 - Pete Chenard - CR28171
	;            Replaced occurrences of $C(255) with the value returned
	;            from $$getPslValue^UCOPTS("maxCharValue").
	;
	; 01/06/05 - Pete chenard - CR13875
	;	     Removed SEREQ section.  Was attempting to optimize serial
	;	     equals condition queries by adding a new query to stop
	;	     collating using a '< or '> condition.  This optimization
	;	     has been moved into ^SQLQ, in the SERIAL section, adding
	;	     the condition to the whr() array earlier in the process.
	;
	;	     Modified code in SERIAL section to restructure now that
	;	     that no call to SEREQ.
	;
	;	     Fixed bug in SERIAL section related to test for DESC.  Was
	;	     not properly considering the columns that might be involved.
	;
	; 04/05/04 - Pete Chenard - 8618
	;	     Modified ASCPRE section to correct a problem with the
	;	     starting point for a BETWEEN clause when the data type
	;	     of the column is Text, but the values supplied in the
	;	     BETWEEN clause are actually numeric values.  Code needs
	;	     to subtract 0.00000001 from the starting.
	;
	; 04/30/01 - Pete Chenard - 44968
	;	     Modified IN section to correct a problem when the OR
	;	     condition exceeds 255 bytes.  It was correctly building
	;	     code to handle the condition, but it should have loaded
	;	     that code into the mcode array instead of the exe array.
	;	     It was causing the OR condition to be checked before
	;	     the data was loaded from the database.
	;
	; 09/29/00 - SPIER - 41792
	;            Modified Serial section to correct error with order by
	;	     condition check.
	;
	; 01/21/00 - Frank Sanchez 37109
	;            Modified QUERY section to add logic to optimize queries on 
	;	     columns that are serial relative to the bottom level
	;            primary key.  Based on a flag set in the data dictionary 
	;            (DBTBL1D.SRL), the optimizer will insert logic to stop
	;            collating when the value in a selected column is beyond
	;            the query range and the collation direction supports that
	;            condition.
	;
	; 11/11/99 - Frank Sanchez 35688
	;            Fixed bug with 'string string' in IN list
	;
	; 06/22/98 - Chiang  29102
	;            Modified ASCPRE section to return $C(33,255)  as the 
	;	     starting value if the minimum value reference is equal to
	;            " (quote).  For example,
	;            SELECT NAM FROM CIF WHERE NAM BETWEEN '"' AND '"Z'.
	;
	; 12/15/97 - Chiang  27185
	;            Modified QUERY section to add the default value to the
	;            missing data type attribute.
	;
	; 11/28/97 - FSANCHEZ
	;        Fixed problem with order of or condition on access key
	;
	; 08/15/97 - Chiang - 25429
	;            Modified TRANSLATE section to replace ] (follow) operator
	;            with ]] (sort after) to support collating logic for 
	;            foreign language characters.
	;
	;----------------------------------------------------------------------
QUERY(rng,whr,mcode,vsub,jfiles,fsn,dqm,ojqry)	; Place query expressions into executable
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N datatyp,ddref,delete,exprqry,exprlft,exprght,nbrexpr,ok,outjoin,oplogic,oprelat,orkill,nest,serial,I,X
	;
	S exprqry="",delete="",orkill="",nbrexpr=0
	;
	F  S nbrexpr=$F(rng,1,nbrexpr+1)-1 Q:nbrexpr<0  D
	.	;
	.	S X=whr(nbrexpr)
	.	S exprlft=$P(X,$C(9),1)			; Subject
	.	S exprght=$P(X,$C(9),2)			; Object
	.	S oprelat=$P(X,$C(9),3)			; Relational operator
	.	S datatyp=$P(X,$C(9),4)
	.	S outjoin=$P(X,$C(9),5)			; Outer join flag
	.	I datatyp="" S datatyp="T"		; *** 12/15/97
	.	;
	.	S nest=$$NESTED(whr,nbrexpr,.oplogic),ok=1,serial=0
	.	;
	.	F I=2:2:$L(X,$C(1)) D  Q:'ok
	..		N isKey
	..		S ddref=$P(X,$C(1),I)
	..		S ok=$$CONTAIN(jfiles,$P(ddref,".",1))
	..		S isKey=$$CONTAIN($G(access),ddref)
	..		I 'ok S ok=isKey
	..		I isKey,exprght=$C(34,34) S exprght="$C(254)"
	.	;
	.	I 'ok D  Q
	..		;
	..		S (exprqry,orkill)=""			; Reset
	..		I nest F nbrexpr=nbrexpr+1:1:$L(rng) Q:'$$NESTED(whr,nbrexpr)	; *** 11/28/97 FRS
	.	;
	.	I nest=0,$P(X,$C(9),6),$L(exprlft,$C(1))=3 D SERIAL	; 02/21/2000 FRS
	.	D BUILD Q:ER
	.	;
	.	I exprqry'="" S orkill=$$ADDVAL(orkill,nbrexpr) Q
	.	I orkill'="" S delete=$$ADDVAL(delete,orkill),orkill=""
	.	S delete=$$ADDVAL(delete,nbrexpr)
	;
	I exprqry'="" D FILE
	;
	; Remove resolved queries from the list
	;
	I orkill'="" S delete=$$ADDVAL(delete,orkill)
	I delete'="" F I=1:1:$L(delete,",") D
	.	;
	.	S z=$P(delete,",",I)
	.	S rng=$E(rng,1,z-1)_0_$E(rng,z+1,$L(rng))
	Q
	;
	;----------------------------------------------------------------------
BUILD	; Construct the query
	;----------------------------------------------------------------------
	;
	I nest S:oplogic="" oplogic="&"
	E  S oplogic=""
	;
	; *** This code should be changed in version 6.0, when NULL must
	; be handled differently in the M database (FRS)
	; 
	I "N$L"[datatyp,oprelat["="!(oprelat["I") D	
	.	;
	.	I exprght="""""" Q
	.	I $E(exprlft)'="+" S exprlft=$S($$ISNUM(exprlft):+exprlft,1:"+"_exprlft)
	.	I oprelat["=",$E(exprght)'="+" S exprght=$S($$ISNUM(exprght):+exprght,1:"+"_exprght)
	;
	F I=0:1 Q:exprlft'[$C(1)  D DINAM(.exprlft) Q:ER
	F I=0:1 Q:exprght'[$C(1)  D DINAM(.exprght) Q:ER
	;
	I oprelat["<"!(oprelat[">") D
	.	;
	.	I "TUFM"[datatyp D TRNSLAT Q
	.	I "$L"[datatyp Q
	.	I '$$ISNUM(exprght) S exprght=exprght_"&("_exprlft_"'="""")" Q
	.	;
	.	I oprelat="<",exprght'>0 Q
	.	I oprelat=">",exprght'<0 Q
	.	I oprelat="'>",exprght<0 Q
	.	I oprelat="'<",exprght>0 Q
	.	S exprght=exprght_"&("_exprlft_"'="""")"
	; 
	I oprelat["E" D CORREL Q:ER
	I oprelat["I" D IN Q:ER
	;
	I nest\2 D				; Put parenthesis back
	.	;
	.	S z=$P(whr,nbrexpr,1)
	.	F I=$L(z):-1 Q:$E(z,I)'="("
	.	I $E(z,I)="'" S I=I-1
	.	S exprlft=$E(z,I+1,$L(z))_exprlft
	.	;
	.	S z=$P(whr,nbrexpr,2)
	.	F I=1:1 Q:$E(z,I)'=")"
	.	S exprght=exprght_$E(z,1,I-1)
	;
	I oprelat="=",exprlft=exprght Q
	;
	I exprqry="" S exprqry=exprlft_oprelat_exprght_oplogic
	E  S exprqry=exprqry_"("_exprlft_oprelat_exprght_")"_oplogic
	;
	I oplogic="" D FILE
	Q
	;
	;--------------------------------------------------------------------
FILE	; Set executable code into the mcode(seq)
	;--------------------------------------------------------------------
	;
	I serial N vxp S vxp=serial
	;
	I $E(exprqry,$L(exprqry))="&" S exprqry=$E(exprqry,1,$L(exprqry)-1)
	;
	S exprqry="I '("_exprqry_")"
	;
	I outjoin D
	.	; 
	.	I ojqry="" D				; Init OJ query flag 
	..		;
	..		S ojqry="vsql("_$$NXTSYM^SQLM_")"
	..		S exprqry="S "_ojqry_"=0 "_exprqry
	.	;
	.	S exprqry=exprqry_" S "_ojqry_"=1"
	.	;
	.	F i=1:1:$L(frm) S alias=$P(frm,",",i) I $D(join(alias,1)) D  Q
	..	S exprqry=exprqry_" I "_join(alias,1)_"'="""" S vsql="_vxp
	;
	E  S exprqry=exprqry_" S vsql="_vxp
	;
	S mcode=$G(mcode)+1,mcode(mcode)=exprqry,exprqry="" 
	Q
	;
	;--------------------------------------------------------------------
OUTJOIN(exe,fsn,join,vsub,ojqry)	; Outer join drop through
	;--------------------------------------------------------------------
	;
	N alias,expr,expr1,expr2,i
	;
	S (expr1,expr2)=""
	F i=1:1:$L(frm,",") S alias=$P(frm,",",i) I $D(join(alias))#2 D MAPVSQL^SQLM(.expr1,.expr2,alias,.jkeys,.vsub,.fsn,.fma)
	;
	I expr2="" Q
	;
	S expr="I "_ojqry_" S "_expr2
	I expr1'="" S expr="S "_expr1_" "_expr
	;
	S exe=exe+1,exe(exe)=expr
	Q
	;
	;--------------------------------------------------------------------
IN	; (List) processing, Data is in a list or array
	;--------------------------------------------------------------------
	;
	; I think you're only allowed numlits, stringlist, and hostvars.
	; I'm also supporting M globals, primarily to optimize subqueries!
	;
	N notoper,orexpr,ptr,str,i,z
	;
	S notoper="",ptr=0
	if $E(oprelat)="'" S notoper="'",oprelat=$E(oprelat,2,$L(oprelat))
	;
	for  set str=$$ATOM^%ZS(exprght,.ptr,",",.tok,1) D  if ptr=0!ER Q
	.	;
	.	if str="" set ER=1,RM=$$^MSG(8586) Q
	.	if str="," Q
	.	;
	.	if "^:"[$E(str),$E(str,3,$L(str))["(" D
	..		;
	..		if $E(str)=":" set str=$E(str,2,$L(str))
	..		set str=$$UNTOK^%ZS(str,.tok)
	..		;
	..		if $E(str,2,$L(str))?1E.E1"(".E1"#".E1")" S str=$P(str,"#",1)_exprlft_$P(str,"#",2)
	..		;  
	..		S z=notoper
	..		if $E(exprlft)="$" S z=z_"$S("_exprlft_"="""":0,1:"
	..		S z=z_"$D("_str_")"
	..		if  S z=z_")"
	.	;
	.	else  S z=$$MCOL^SQLCOL(str,frm,,,,.fsn,.cmp,.vsub,.tok,.vdd) Q:ER
	.	else  S:"$L"[datatyp z=+z S z=exprlft_notoper_"="_z
	.	;
	.	if '$D(orexpr) S orexpr=z Q
	.	if $L(orexpr)>255 D
	..		;
	..		S v="vsql("_$$NXTSYM^SQLM_")"
	..		S mcode=$G(mcode)+1,mcode(mcode)="S "_v_"=0 if ("_orexpr_") S "_v_"=1"  ;pc 04/30/2001
	..		S orexpr="("_v_"=1)"
	.	;
	.	S orexpr=orexpr_$S(notoper="":"!",1:"&")_"("_z_")"
	;
	S exprlft=$g(orexpr),exprght="",oprelat=""
	Q
	;
	;----------------------------------------------------------------------
DINAM(expr)	; Replace logical database references with physical
	;----------------------------------------------------------------------
	;
	N dinam,ref
	;
	S dinam=$P(expr,$C(1),2)
	;
	I $D(vsub(dinam)) S ref=vsub(dinam)
	E  S ref=$$PARSE^SQLDD(.dinam,"",.cmp,.fsn,,.vdd,,.vsub) Q:ER
	;
	S expr=$P(expr,$C(1),1)_ref_$P(expr,$C(1),3,999)
	Q
	;
	;----------------------------------------------------------------------
TRNSLAT	; Translate < > to ] if exprght is in quotes
	;----------------------------------------------------------------------
	;
	I oprelat=">" S oprelat="]]" Q
	I oprelat="'>" S oprelat="']]" Q
	I oprelat="<" S oprelat="']]",exprght=$$ASCPRE(exprght,datatyp) Q
	I oprelat="'<" S oprelat="]]",exprght=$$ASCPRE(exprght,datatyp) Q
	Q
	;
	;----------------------------------------------------------------------
FUNC(expr)	; Execute a function or assign a local variable
	;----------------------------------------------------------------------
	;
	I $E(expr)?1A,expr'["(" D  Q				; Local Var
	.	;
	.	; Undefined Host Variable ~p1
	.	I $D(@expr)#2=0 S ER=1,RM=$$^MSG(8592,expr) Q
	.	S expr=@expr
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ET^SQLA")
	X "S expr="_expr
	Q
ET	; Error executing function
	S ER=1,RM=$P($ZS,",",4)
	Q
	;
CONTAIN(X,Y)	Q ","_X_","[(","_Y_",")
	;
	;
	;----------------------------------------------------------------------
ASCPRE(v,typ,dinam,vdd)	; Return Minimum value string and datatype 
	;----------------------------------------------------------------------
	;
	N dec,maxCharV
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	;
	I $G(dinam)="" S dec=$S(v?.N1".".N:$L($P(v,".",2))+1,1:0)
	E  S dec=$S("N$"[typ:$$DEC^SQLDD(dinam,,.vdd),1:0)
	;
	I "N$DC"[typ S dec=$E(".00000000000000",1,dec)_"1"
	I v=+v Q $S(dec:v-dec,1:v-0.00000001)	;CR8624 - KADAMM
	I v="""""""""" Q "$C("_($A(v,$L(v)-1)-1)_","_maxCharV_")"	; 06/23/98 BC
	I $E(v)="""" Q "("_$E(v,1,$L(v)-2)_"""_$C("_($A(v,$L(v)-1)-1)_","_maxCharV_"))"
	;
	I "N$DC"[typ Q "("_v_"-"_dec_")"
	; *** 06/21/96
	Q "($E("_v_",1,$L("_v_")-1)_$C($A("_v_",$L("_v_"))-1)_$C("_maxCharV_"))"
	;
	;----------------------------------------------------------------------
SETRNG(exprlft,exprght,oprelat,datatyp)	; Set Range variables
	;----------------------------------------------------------------------
	;
	I $D(rng(exprlft))#2=0 S rng(exprlft)=datatyp
	E  I $D(rng(dinam,oprelat)),rng(dinam,oprelat)'=exprght S flag=0 Q
	;
	S rng(exprlft,oprelat)=exprght
	Q
	;
	;--------------------------------------------------------------------
NESTED(whr,nbrexpr,oplogic)	; Return nest code
	;--------------------------------------------------------------------
	;
	; Value#2  - OR oplogic present
	; Value\2  - Paranthesis level
	;
	N c,z
	;
	S z=$P(whr,nbrexpr,1),c=$L(z,"(")-$L(z,")")
	;
	I c=0,whr'["!" S oplogic="&" Q 0
	;
	S oplogic=$E(whr,$F(whr,nbrexpr))
	I oplogic=")" S oplogic=$E($TR($E(whr,$F(whr,nbrexpr),$L(whr)),"()"))
	;
	I oplogic="!"!($E(z,$L(z))="!") Q c*2+1
	I c=0 Q 0
	;
	N i
	F i=$L(z,"("):-1:($L(z,"(")-c) S z=$P(z,"(",1,i) I $E(z,$L(z))="!" Q
	Q c*2+($E(z,$L(z))="!")
	; 
	;--------------------------------------------------------------------
SERIAL	; This is a serial column relative to the bottom key
	;--------------------------------------------------------------------
	;
	N btmkey,dinam,expr,i,file,z
	;
	S dinam=$P(exprlft,$C(1),2)
	S file=$P(dinam,".",1),z=$P(fsn(file),"|",3)
	S btmkey=file_"."_$P(z,",",$L(z,","))
	S expr=$G(vsub(btmkey)) I expr="" Q
	S expr="S "_expr_"=$O("
	S serial=1
	;
	I $$SRLORD^SQLQ(dinam)="DESC" D
	.	I '(oprelat=">"!(oprelat="'<")) S serial=0
	;
	E  I '(oprelat="<"!(oprelat="'>")) S serial=0
	;
	I serial F i=exe:-1:1 I exe(i)[expr S serial=+$P(exe(i)," S vsql=",2) Q
	E  S serial=0
	Q
	;
	;--------------------------------------------------------------------
CORREL	; Build correlated query code
	;--------------------------------------------------------------------
	;
	I ER Q
	;
	D LOADALL^SQLM
	;
	N i,go,j0,j1,not,v,v0,v1
	;
	S v0="vsql("_$$NXTSYM^SQLM_")"
	S v1="vsql("_$$NXTSYM^SQLM_")"
	;
	S exe=exe+1,exe(exe)="S "_exprlft_" S "_v1_"=0"
	;
	S j0=$O(vsql("E",exprght,""),-1)-$O(vsql("E",exprght,""))+exe+1
	S j1=exe
	;
	S v="",go="S vsql="
	F  S v=$O(vsql("E",exprght,v)) Q:v=""  D
	.	;
	.	S z=vsql("E",exprght,v)
	.	I z[go S z=$P(z,go,1)_go_$S($P(z,go,2)=-1:j0,1:j1+$P(z,go,2))
	.	S exe=exe+1,exe(exe)=z
	;
	S exe(exe)="S "_v1_"=1"
	S oprelat=$S($E(oprelat)="'":"'",1:"")_"="
	S exprlft=v1,exprght=1,datatyp="N"
	K vsql("E",exprght)
	Q
	;-------------------------------------------------------------------- 
ADDVAL(str,val)	; Add Value to String 
	;-------------------------------------------------------------------- 
	; 
	I $G(str)="" Q $G(val) 
	Q str_","_$G(val) 
	;
	;-------------------------------------------------------------------- 
SUBVAL(str,val)	; Subtract Value from String 
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
ISNUM(expr)	Q expr?.N!(expr?.N1".".N)
