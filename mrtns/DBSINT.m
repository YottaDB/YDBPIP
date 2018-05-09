DBSINT(str,tbl,int,ed,cd,ad,qd,vd)	;public;Command Interpreter
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/14/94 16:34:06 - XUS
	;     ORIG:  Frank R. Sanchez (2497)
	;
	; This utility is a general purpose command line interpreter.
	; Commands, arguments, qualifiers and validation conditions are
	; defined in command tables.  Command tables can be local or
	; global MUMPS arrays.  Input data is parsed for command,
	; argument, qualifier, and value delimiters and keywords and
	; data is validated against the command table.  An output
	; array is generated that contains a list of subroutine
	; addresses and their parameters.
	;
	; See INIT^DBSCRTNL and INIT^DBSMACRO for command table examples. 
	;
	; KEYWORDS: parsing
	;
	; ARGUMENTS:
	;	. str	String to parse		/REQ/LEN=255
	;	. tbl	Command table name 	/NOREQ/LEN=255/DFT="CMD("
	;		The MUMPS local or global array that contains
	;		the command table to parse input against.
	;		
	;		Syntax:
	;
	;		CMD(command_name)=expr
	;		expr	:== [linetag[^routine][(params)]]
	;		params	:== Arg_Num|Key_Word[/Qualifier[/...]][,...]
	;
	;	Optional command table qualifiers to validate values used
	;	for argument and qualifier assignments:
	;
	;           /NEG   Negatable flag     (allows VAV - NOVAL syntax)
	;	    /REQ   Required flag
	;	    /LEN=  Maximum field length
	;	    /DFT=  Default value
	;	    /TYP=  Data type
	;	    /TBL=  Lookup table name
	;	    /PTN=  Character pattern
	;	    /MIN=  Minimum value
	;           /MAX=  Maximum value
	;	    /DEC=  Decimal precision
	;	    /QWT   Quote Parameter      /TYP=L /DFT=1 /NEG
	;
	;	. int	Interactive flag	/NOREQ/LEN=1/TYP=L/DFT=0
	;	. ed	Expression delimiter	/NOREQ/LEN=1/DFT=":" 
	;	. cd	Command delimeter	/NOREQ/LEN=1/DFT="," 
	;	. ad	Argument delimeter	/NOREQ/LEN=1/DFT=" " 
	;	. qd	Qualifier delimeter	/NOREQ/LEN=1/DFT="/" 
	;	. vd	Value delimiter		/NOREQ/LEN=1/DFT="=" 
	;
	; RETURNS:
	;	. tree(#)	Subroutine Expression
	;	. ER		Error Indicator
	;	. RM(#)		Error Description
	;
	; EXAMPLES:
	; S CMD("ASSIGN")="(1/REQ,GOLD/NEG,KEYNAME/TYP=U)"
	; S CMD("PRINT")="PRINT^UTLPNT(1/REQ,DEVICE,COPIES/TYP=N)"
	;
	; D ^DBSINT("ASSIG DOFUN/GOLD/KEY=pf1")
	; ZWR
	; ER=0
	; tree(1)=ASSIGN("DOFUN","1","PF1")"
	;
	; D ^DBSINT("ASSIG DOFUN/NOGOLD/KEY=PF2 : PR X.X /DEV=LASER")
	; ZWR
	; ER=0
	; tree(1)=ASSIGN("DOFUN","1","PF1")
	; tree(2)="PRINT^UTLPNT("X.X","LASER","")
	;
	; D ^DBSINT("ASSIG DOFUN/NOGOLD/NOKEY : DISPLAY X.X")
	; ZWR
	; ER=1
	; RM(1)="ASSIG DOFUN/NOGOLD/NOKEY : DISPLAY X.X"
	; RM(2)="                   ^----NOTNEGATABLE"
	; RM(3)="                           ^------INVALID_COMMAND"
	;
        ; I18N=QUIT: Exclude from I18N standards
	;---------- Revision History -------------------------------------------
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$UPPER^SCAUTL with $$UPPER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;-----------------------------------------------------------------------
	;
A	;
	I '$D(int) S int=0
	I '$D(tbl) S tbl="CMD("
	;
	I '$D(ed) S ed=":"
	I '$D(cd) S cd=","
	I '$D(ad) S ad=" "
	I '$D(qd) S qd="/"
	I '$D(vd) S vd="="
	;
	I $E(str,$L(str))=" " F  S str=$E(str,1,$L(str)-1) Q:$E(str,$L(str))'=" "
	;
	N A,I,Y,X,atom,argunum,chklist,cmd,entryref,expr,mult,params,paramnum,pos,ptr,i,lcmd,list,no,y,reqlist,qwtlist
	;
	S A=""
	I ed'="" S Y=$F(str,ed) I Y D TOK(ed)
	I cd'="" S Y=$F(str,cd) I Y D TOK(cd)
	I ad'="" S Y=$F(str,ad) I Y D TOK(ad)
	I qd'="" S Y=$F(str,qd) I Y D TOK(qd)
	I vd'="" S Y=$F(str,vd) I Y D TOK(vd)
	;
	S atom=0,pos=0,ptr=0,cmd=ed,ER=0,mult=""
	;
NXT	;
	;
	I ptr S pos=$A(A,ptr),cmd=$E(str,pos)
	S pos=pos+1 I pos=$A(A,ptr+1) I cmd=" "!($E(str,pos+1)=" ") D WYTSPC
	;
	S expr=$E(str,pos,$S(ptr<$L(A):$A(A,ptr+1)-1,1:$L(str)))
	;
	I cmd=ed D EXPR G NXTEND
	I cmd=ad D ARGU G NXTEND
	I cmd=qd D QUAL G NXTEND
	I cmd=vd D VALU G NXTEND
	I cmd=cd D LIST G NXTEND
NXTEND	S ptr=ptr+1,lcmd=cmd
	;
	I ptr'>$L(A) G NXT
	I $L(mult) D ADD
	I ER K tree Q
	I atom D FYLPAR
	Q
	;
	;----------------------------------------------------------------------
EXPR	; Expression
	;----------------------------------------------------------------------
	;
	I $L(mult) D ADD
	;
	I atom D FYLPAR
	I expr="" D ERROR("MISSING_COMMAND") Q
	S expr=$$PRTL(tbl,expr) I expr="" Q
	S entryref=@(tbl_""""_expr_""")")
	S params="",list="",paramnum=0,argunum=0,reqlist="",qwtlist=""
	I entryref["(" S list=$P($P(entryref,"(",2),")",1),entryref=$P(entryref,"(",1)
	S:entryref="" entryref=expr ;			Default entryref
	S atom=atom+1,tree(atom)=entryref
	E  Q  ;						No parameters
	;
	F I=1:1:$L(list,",") DO
	.	S X=$P(list,",",I)
	.	D VAL(I,$S(X["/DEF=":$P($P(X,"/DEF=",2),"/",1),X["/NEG":1,$E(X)="""":X,1:""""""))
	.	S reqlist=reqlist_(X["/REQ")
	.	S qwtlist=qwtlist_(X'["/NOQWT")
	Q
	;
	;----------------------------------------------------------------------
ARGU	; Argument
	;----------------------------------------------------------------------
	;
	I '$D(tree(atom)) D:'ER ERROR("MISSING_COMMAND") Q
	I params="" D ERROR("UNEXPECTED_PARAMETER") Q
	S argunum=argunum+1,paramnum=$P(list,",",argunum) 
	I 'paramnum D ERROR("UNEXPECTED_ARGUMENT") Q
	;
	S chklist=$P(paramnum,"/",2,999)
	I chklist'="" S chklist="/"_chklist N ET S ET=$$VALUERR(.expr) I ET'="" D ERROR(ET) Q
	;
	D VAL(+paramnum,expr)
	S paramnum=0
	Q
	;
	;----------------------------------------------------------------------
QUAL	; Qualifier
	;----------------------------------------------------------------------
	;
	I '$D(tree(atom)) D:'ER ERROR("MISSING_COMMAND") Q
	S expr=","_$$UPCAS(expr),no=0
	S y=$F(","_list,expr) I y G QUALA
	I $E(expr,2,3)="NO" S expr=","_$E(expr,4,$L(expr)),no=1,y=$F(list,expr) I y G QUALA	 
	D ERROR("INVALID_QUALIFIER") Q
	;
QUALA	I $F(list,expr,y) D ERROR("AMBIGIOUS") Q
	S chklist=$P($P($E(list,y-1,$L(list)),",",1),"/",2,999)
	I chklist'="" S chklist="/"_chklist
	I no,chklist'["/NEG" D ERROR("NOTNEGATABLE") Q
	S paramnum=$L($E(list,1,y-2),",")
	I chklist["/NEG" D VAL(paramnum,'no)
	Q
	;
	;----------------------------------------------------------------------
VALU	; Value
	;----------------------------------------------------------------------
	;
	I 'paramnum D:'ER ERROR("UNEXPECTED_ASSIGNMENT") Q
	I chklist'="" N ET S ET=$$VALUERR(.expr) I ET'="" D ERROR(ET) Q
	D VAL(paramnum,expr)
	S paramnum=0
	Q
	;
	;----------------------------------------------------------------------
VALUERR(X)	; Check assignment value against qualifiers
	;----------------------------------------------------------------------
	;
	N REQ,TYP,MIN,MAX,TBL,PTN,LEN,DEC
	;
	S REQ=$S(chklist["/REQ":1,1:"")
	S TYP=$S(chklist["/TYP=":$P($P(chklist,"/TYP=",2),"/",1),1:"T")
	S MIN=$S(chklist["/MIN=":$P($P(chklist,"/MIN=",2),"/",1),1:"")
	S MAX=$S(chklist["/MAX=":$P($P(chklist,"/MAX=",2),"/",1),1:"")
	S TBL=$S(chklist["/TBL=":$P($P(chklist,"/TBL=",2),"/",1),1:"")
	S PTN=$S(chklist["/PTN=":$P($P(chklist,"/PTN=",2),"/",1),1:"")
	S LEN=$S(chklist["/LEN=":$P($P(chklist,"/LEN=",2),"/",1),1:"")
	S DEC=$S(chklist["/DEC=":$P($P(chklist,"/DEC=",2),"/",1),1:"")
	;
	I "DCLU"[TYP N ER S ER=0,X=$$INTYP^DBSCRT8(X,TYP) I ER Q $G(RM)
	;
	Q $$VALIDATE^DBSCRT8(TYP,LEN,REQ,TBL,PTN,MIN,MAX,DEC)
	;
	;----------------------------------------------------------------------
LIST	; List (> 1) of arguments or qualifiers
	;----------------------------------------------------------------------
	;
	I lcmd'=ad D ERROR("NOTFOLLOW_ARGUMENT") Q
	S mult=mult_expr_$C(0),cmd=lcmd
	Q
	;
	;----------------------------------------------------------------------
ADD	; Add expression atoms from mult to tree(atom,...
	;----------------------------------------------------------------------
	;
	N i,expr
	F i=1:1 S expr=$P(mult,$C(0),i) Q:expr=""  D ADDATOM
	S mult="" Q
	;
ADDATOM	;
	I atom D FYLPAR
	D VAL(1,expr)
	S tree(atom+1)=$P(tree(atom),"(",1)
	S atom=atom+1
	Q
	;
	;----------------------------------------------------------------------
WYTSPC	; Remove white space from command
	;----------------------------------------------------------------------
	;
	F  Q:$A(A,ptr)+1'=$A(A,ptr+1)  S ptr=ptr+1 I $E(str,$A(A,ptr))'=" " S cmd=$E(str,$A(A,ptr)) Q
	F ptr=ptr:1 Q:$A(A,ptr)+1'=$A(A,ptr+1)  I $E(str,$A(A,ptr+1))'=" " Q
	S pos=$A(A,ptr)+1
	Q
	;
	;----------------------------------------------------------------------
PRTL(ref,X)	; Match table to partial list
	;----------------------------------------------------------------------
	;
	N Z
	S Z=$$UPCAS(X),X=Z,ref=ref_"Z)"
	;
	I $D(@ref) Q Z
	;
	S Z=$O(@ref) I $E(Z,1,$L(X))'=X D ERROR("INVALID_COMMAND") Q ""
	I $E($O(@ref),1,$L(X))'=X Q Z ;		Unambigious reference
	I 'int D ERROR("AMBIGIOUS") Q "" ;      Not interactive
	;
	N OP
	;
	S Z=X,OP=1 F  S Z=$O(@ref) Q:$E(Z,1,$L(X))'=X  S OP(OP)=Z,OP=OP+1
	S X=$$^DBSMBAR(23,"","","","",.OP) I X="" Q ""	; *** - BC - 01/05/94
	Q OP(X)
	;
	;----------------------------------------------------------------------
VAL(I,X)	; Set the value into a parameter
	;----------------------------------------------------------------------
	;
	S $P(params,$C(0),I)=X Q
	;
	;----------------------------------------------------------------------
FYLPAR	; File parameters into tree(array)
	;----------------------------------------------------------------------
	;
	I reqlist F i=1:1:$L(reqlist) I $E(reqlist,i),$P(params,$C(0),i)="""""" D FYLERR Q
	;
	I ER Q
	;
	I qwtlist F i=1:1:$L(qwtlist) I $E(qwtlist,i) DO
	.	;
	.	N param
	.	S param=$P(params,$C(0),i)
	.	I $E(param)="""",$E(param,$L(param))="""" Q
	.	I param["""" S param=$$DBLQ(param)
	.	S $P(params,$C(0),i)=""""_param_""""
	;
	I params=""!ER Q
	S tree(atom)=tree(atom)_"("_$TR(params,$C(0),",")_")" Q
	;
	;----------------------------------------------------------------------
FYLERR	; Required Error 
	;----------------------------------------------------------------------
	;
	N et,xptr
	S et="/"_$P($P(list,",",i),qd,1) S:et="/" et="PARAMETER ("_i_")"
	S xptr=$A(A,ptr) S:xptr<0 xptr=$L(str)+1
	S et=$J("",xptr-1)_"^"_et_" REQUIRED"
	D MSG(et) Q
	;
	;----------------------------------------------------------------------
DBLQ(X)	; Double all quotes in X
	;----------------------------------------------------------------------
	;
	N y
	S y=0 F  S y=$F(X,"""",y) Q:y=0  S X=$E(X,1,y-1)_""""_$E(X,y,$L(X)),y=y+1
	Q X
	;
	;----------------------------------------------------------------------
CHKSTR(X)	; Check the syntax of the input expression
	;----------------------------------------------------------------------
	Q
	;
UPCAS(X)	Q $$UPPER^UCGMR(X)
	;
TEST	;
	;
	N RM
	R !,":/ STRING: ",str Q:"Q"[str
	K tree
	D DBSINT(str,"^DBCTL(""SYS"",""FORMCMD"",",1)
	F I=1:1 Q:'$D(tree(I))  W !,"tree(",I,")=",tree(I)
	I $D(RM) D DSPERR
	G TEST
	;
TOK(D)	;
TOKL	I $L($E(str,1,Y-2),"""")#2 D SORT
	S Y=$F(str,D,Y) Q:Y=0
	G TOKL
	;
	;----------------------------------------------------------------------
SORT	;
	;----------------------------------------------------------------------
	I $A(A,$L(A))+1<Y S A=A_$C(Y-1) Q
	F I=1:1:$L(A) I $A(A,I)+1>Y Q
	S A=$E(A,1,I-1)_$C(Y-1)_$E(A,I,$L(A))
	Q
	;
	;----------------------------------------------------------------------
DSPERR	; Display errors to screen
	;----------------------------------------------------------------------
	;
	F I=1:1 S X=$G(RM(I)) Q:X=""  W !,RM(I)
	K RM
	Q
	;
	;----------------------------------------------------------------------
EXT(str,CMD)	; External interface
	;----------------------------------------------------------------------
	;
	N tree
	;
	S CMD("Z")="("_CMD_")"
	D DBSINT("Z/"_str,"CMD(",0,"","","","/","=")
	I '$D(tree) S:ER RM(1)=$E(RM(1),2,999),RM(2)=$E(RM(2),2,999) Q ""
	Q $P($P(tree(1),"(",2,99),")",$L(tree(1),")")-1)
	;
	;----------------------------------------------------------------------
ERROR(et)	; Process errors and set error flag
	;----------------------------------------------------------------------
	;
	N PS,PE
	;
	S PS=$A(A,ptr),PE=$A(A,ptr+1) I PE<PS S PE=$L(str)+1
	D MSG($J("",PS)_"^"_$TR($J("",PE-PS-2)," ","-")_et)
	Q
	;
	;----------------------------------------------------------------------
MSG(M)	; Construct messages in the RM(array) to report conditions to caller
	;----------------------------------------------------------------------
	;
	I 'ER S ER=1,RM($ZP(RM(""))+1)=str
	S RM($ZP(RM(""))+1)=M
	Q
