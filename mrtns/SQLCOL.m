SQLCOL(exe,parms,frm,sel,lvn,fmt,tok,fsn,fma,cmp,vsub,vdd,nlv,subqry)	;public; Build SQL Column executable code 
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/02/01 13:06:25 - CHENARDP
	;     ORIG:  FSANCHEZ - 25 DEC 1991
	;
	; I18N=QUIT
	;----------------------------------------------------------------------
	; Builds an array of executable code that is returned in exe(line).
	; This code maps the physical MUMPS record into a record ordered
	; according to the select list.  If external formatting is
	; defined, formatting will be included in the generated code.
	;
	; KEYWORDS: database
	;
	; ARGUMENTS:
	;	.exe		# Lines in Array	/MECH=REFNAM:W
	;	.exe(line)	Executable code 	/MECH=REFNAM:W
	;	.
	;	.frm		File list		/REQ/DEL=44/MECH=VAL
	;	.sel		Data item select list	/DEL=44/MECH=VAL
	;	.lvn		Record variable
	;	.
	;	.tok		String Token
	;	.fsn(file)	File Attributes Record	/NOREQ/MECH=REF:RW
	;	.fma(file,nod)	Mask node load		/NOREQ/MECH=REF:RW
	;	.cmp(file,di)	Computed Expressions	/NOREQ/MECH=REF:R
	;	.vsub(ddref)	Literal Substition 	/NOREQ/MECH=REF:R
	;	.vdd(ddref)	Data Dictionary		/MECH=REFNAM:RW
	;	.nlv          	Ignore Local Array      /NOREQ/TYP=L/DFT=Y
	;	.subqry         Called from subqry      /NOREQ/TYPE=L
	;
	; RETURNS:
	;	. ER		Error Flag
	;	. RM		Error message
	;
	; EXAMPLE:
	;
	;---------- Revision History ------------------------------------------
	; 07/24/2008 - RussellDS - CR30801
	;	     Modified FUNCTION section to add support for LOWER and to
	;	     change both LOWER and UPPER to call ^UCGMR
	;
	; 09/24/07 - GiridharanB - CR28353
	;	     Replaced call to LIST^SQLDD to call COLLIST^DBSDD instead.
	;
	; 07/10/07 - Pete Chenard - CR28171
	;	     Replaced occurrance of $C(255) with call to 
	;	     $$BYTECHAR^SQLUTL(255) for unicode compliance.
	;
	; 01/31/05 - Pete Chenard - CR19161
	;	     Backed out last change.  Instead, that fix will be handled 
	;	     in SQLM.m
	;
	; 01/09/05 - Pete Chenard - CR 18899
	;	     Modified DDREF to use pirce 1 of the data item name
	;	     for the file is the di contains "."
	;
	; 01/06/05 - Pete Chenard - 13875
	;	     Added support for 1Mb strings.
	;
	; 11/26/03 - Pete Chenard - 4971
	;	     Modified sections ATOM to correct an issue 
	;	     with select count(*) being displayed correctly.
	;
	; 11/18/03 - Pete Chenard - 7056
	;	     Modified section ATOM to support "*" as a arithmetic
	;	     operator in a sql select statement.
	;
	; 07/29/03 - Pete Chenard - 3226
	;	     Modified COLEXPR and DDREF sections to check the value of
	;	     DBTBL1D.NULLIND for columns of types $,N, and L.  If the
	;	     null indicator flag is turned on, + the result.  This
	;	     will result in the value being treated like a 0 if it is
	;	     null.
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	; Convert * to column list
	;
	I $E(sel)="*" S sel="" D  Q:ER
	.	N i
	.	F i=1:1:$L(frm,",") S sel=sel_","_$$COLLIST^DBSDD($P(frm,",",i),0,1,0)
	.	S sel=$E(sel,2,99999)
	;
	I $G(tok)="" S sel=$$SQL^%ZS(sel,.tok) Q:ER
	I '$D(nlv) S nlv=1
	;
	N I,col,expr,file,prepare,ptr,str,vpack,z,zvd
	;
	I $G(lvn)="" S lvn="v"				; Local record name
	;
	S expr=1,ptr=0
	;
	S vsql("D")="",vsql("A")=""
	S prepare=$G(par("PREPARE"))  			; ODBC/JDBC qualifier
	;
	F col=1:1 S str=$$GETCOL(sel,.ptr) D COLEXPR Q:ptr>$L(sel)!ER
	;
	I prepare=3 S vsql("A")=$$COLATT^SQLODBC(sqlfrm,vsql("D")) ; Column formats and access keys (PFW/PIA)
	I $D(expr)<10!ER Q
	;
	F I=1:1:$L(frm,",") D  I ER Q 			; Build load code
	.	;
	.	S file=$P(frm,",",I)
	.	I '$D(vsql("AG")) D LOAD^SQLDD(file,.fsn,.exe,nlv,.fma,frm,.vsub,.cmp) Q
	.	D LOAD^SQLDD(file,.fsn,.vexe,nlv,.fma,frm,.vsub,.cmp)
	; 
	I '$D(vsql("AG")) DO  Q
	.	F I=1:1:expr S exe=exe+1,exe(exe)=expr(I)

	; Save the code generated above into vsql("AG" array for later placement into exe array
	;
	F I=1:1:expr  S vsql("AG","expr",I)=expr(I)
	S I=""
	F  S I=$O(vexe(I)) Q:I=""  S vsql("AG","load",I)=vexe(I)
	K vexe
	;
	K vsql("IDX")                           ; remove temporary file
	Q
	;
	;----------------------------------------------------------------------
GETCOL(sel,ptr)	;Public; Return the next column expression in a select statement
	;----------------------------------------------------------------------
	;
	N str,y
	S y=$F(sel,",",ptr) I y=0 S y=$L(sel)+2
	S str=$E(sel,ptr,y-2),ptr=y
	I str["(",$L(str,"(")'=$L(str,")") D
	.	;
	.	S ptr=ptr-$L(str)-1
	.	S str=$$PXP^%ZS(sel,.ptr)
	.	I ptr=0 S ptr=$L(sel)
	.	S ptr=ptr+2
	;
	Q str
	;
	;----------------------------------------------------------------------
COLEXPR	;Private; Build Column Expression
	;----------------------------------------------------------------------
	;
	N dec,len,nul,typ,z,z1
	;
	S (dec,len,nul,typ)=""
	;
	S z=$$MCOL(str,frm,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,,.nul) I ER Q
	;
	I (",N,$,L,"[(","_typ_",")),(nul) S z="+"_z	; treat null as zero if null flag is set
	I typ="" S typ="T"				; Constant
	I str["||" s typ="T",dec=0
	S vsql("D")=vsql("D")_typ_+dec
	;
	I prepare=1 D  I ER Q
	.    S z1=$$PREPARE^SQLODBC(str,frm,.vpack)          ; Attributes 11/10/99
	.    I $$BSL^SQLUTL(z1)+$$BSL^SQLUTL(vsql("A"))<1022000 S vsql("A")=vsql("A")_z1_$$BYTECHAR^SQLUTL(255) Q 
	.    S ER=1,RM=$$^MSG(2079)				; Buffer overflow
	;
	I col=1 S expr(1)="S "_lvn_"="_z Q
	;
	I $L(expr(expr))+$L(z)>250 S expr=expr+1,expr(expr)="S "_lvn_"="_lvn_"_$C(9)_"_z
	E  S expr(expr)=expr(expr)_"_$C(9)_"_z
	Q
	;
	;----------------------------------------------------------------------
MCOL(str,frm,len,typ,dec,fsn,cmp,vsub,tok,vdd,nop,nul)	; Return M column expression
	;----------------------------------------------------------------------
	;
	I $G(tok)="" S str=$$SQL^%ZS(str,.tok)
	;
	I $G(str)="" S typ="T",len=0 Q """"""
	;
	N cnt,ptr,ret,X
	S ptr=0,ret=""
	;
	F cnt=0:1 S ret=ret_$$ATOM(str,.ptr,.len,.typ,.dec,.frm,.fsn,.cmp,.vsub,.vdd,.nop) Q:ptr=0!ER
	I cnt S ret="("_ret_")" I cnt#2 S ER=1
	;
	I ER S ret="" I $G(RM)="" S RM=$$^MSG(1477,str)
	Q ret
	;
	;-----------------------------------------------------------------------
ATOM(str,ptr,len,typ,dec,frm,fsn,cmp,vsub,vdd,nop)	; Next Column Atom
	;-----------------------------------------------------------------------
	;
	N z
	S z=$$ATOM^%ZS(str,.ptr,"+-/*|",tok)
	;
	I z[$C(0) S z=$$UNTOK^%ZS(z,tok)
	;						; ODBC SELECT format
	I z="*",$G(aggfun)'="" Q z			; count(*) support
	I cnt#2=0,"+-"[z s cnt=cnt+1 Q z		; Support +-column_name
	I z?1n.n1"E" S cnt=cnt+1 Q z			; nE+-n format
	S ER=(cnt#2)-("+-*/|"[z)			; SELECT CID,-BAL ...
	I ER S RM=$$^MSG(8572,z) Q ""
	;
	I $E(z)="""",$E(z,$L(z))="""" D DDREF Q z
	I $E(z)="'" Q $$QADD^%ZS($E(z,2,$L(z)-1))
	I $E(z)=":" Q $$VSUB(z)
	I $E(z)="(" Q "("_$$MCOL($$POP^%ZS(z),frm,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,.nop)_")"
	;
	I z="|",$E(str,ptr+1)="|" S ptr=ptr+1 Q "_"
	I z?.N!(z?1"."1N.N)!(z?1N.N1".".N) Q z		; nn  .nn  nn.nn
	I z?1N.N1"E"1N.N!(z?1N.N1".".N1"E"1N.N) Q z	; *** 11/19/97 En format
	I "+-/*"[z Q z
	I z="NULL" Q """"""				; *** 10/23/96
	I z="SYSDAT" S typ="D" Q $$VSUB(":+$H")
	I z="USERID" S typ="N" Q $$VSUB(":%UID")
	;
	I $e(z,1,5)="vsql(" q z			; *** 09/18/98
	I z["(" Q $$FUNCTION(z,.nop,.typ,.len,.dec)
	;
	D DDREF Q z
	;
DDREF	;
	I """"[z S ER=1,RM="Invalid Data Item Syntax" Q
	;
 	I '$G(nop) S X="",z=$$PARSE^SQLDD(z,.X,.cmp,.fsn,.frm,.vdd,,.vsub,.v255)
	E  I nop=1 S X=$$DI^SQLDD(.z,frm,.vdd,.fsn),z=$C(1)_z_$C(1)
	E  S X="",z=$$PARSE^SQLDD(z,.X,.cmp,.fsn,.frm,.vdd,,.vsub,.v255),ER=0 Q
	;
	I ER Q
	;
	I $P(X,"|",19) S len=$G(len)+$P(X,"|",19)
	E  S len=$G(len)+$P(X,"|",2)
	;
	S nul=$P(X,"|",31)				; null vs. 0 indicator
	I $G(typ)="" S typ=$P(X,"|",9)			; Type
	I $G(dec)="" S dec=$P(X,"|",14)			; Decimal
	Q
	;
VSUB(expr)	;
	;
	N lvn,sub,v
	S lvn=$P(expr,"(",1),sub=$P(expr,"(",2,999)
	I ":"[lvn S ER=1,RM="Invalid Host Variable Syntax" Q ""
	;
	I sub'="" D
	.	;
	.	N tok
	.	S sub=$$SQL^%ZS($E(sub,1,$L(sub)-1),.tok)
	.	S lvn=lvn_"("_$$MCOL(sub,frm,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,.nop)_")"
	;
	I lvn[$C(1) Q $E(lvn,2,$L(lvn))
	;
	Q $$HOSTVAR^SQLQ(lvn,.typ,.vsub,.exe)
	;
	;-----------------------------------------------------------------------
FUNCTION(expr,nop,funtyp,len,dec,tok)	; Build Scaler function expression
	;-----------------------------------------------------------------------
	;
	N farg,fnam,func,savobj,listpars,inptlist,parnum,rec,str,typ
	;
	I '$D(tok) S expr=$$SQL^%ZS(expr,.tok)
	;
	S fnam=$P(expr,"(",1)
	S farg=$P(expr,"(",2,999)
	S farg=$E(farg,1,$L(farg)-1)			; Strip Parans
	;
	I $$CONTAIN("SUM,MAX,MIN,COUNT,AVG",fnam) N X D  Q X
	.	S X=$$^SQLAGFUN(fnam,farg,.typ,.dec)
	.	I $G(typ)="" S typ=$$TYP^SQLDD(frm_"."_farg)
	.	S funtyp=typ
	;
	S func=$G(^SQL("SQLFUNC",fnam))
	;
	I func="" D  I func="" S ER=1,RM=$$^MSG(1361,fnam) Q ""
	.	;
	.	I fnam="$E" S func="$E(VALUE,FROM/REQ/TYP=N,TO/TYP=N)|T" Q
	.	I fnam="$L" S func="$L(VALUE,LENGTH)|N" Q
	.	I fnam="$P" S func="$P(VALUE,DELIMITER/REQ,FROM/REQ/TYP=N,TO/TYP=N)|T" Q
	.	I fnam="LOWER" S func="$$LOWER^UCGMR(VALUE)|T" Q
	.	I fnam="UPPER" S func="$$UPPER^UCGMR(VALUE)|T" Q
	.	I fnam="SUBSTR" S func="$E(VALUE,FROM/REQ/TYP=N,TO/TYP=N)|T" Q
	;
	S funtyp=$P(func,"|",2) I funtyp="" S funtyp="T"
	S params=$P($P(func,"(",2),")",1),func=$P(func,"(",1)
	;
	I $L(farg,",")>$L(params,",") S ER=1,RM=$$^MSG(319) Q ""
	;
	S func=func_"("
	;
	F parnum=1:1:$L(farg,",") D  Q:ER
	.	;
	.	S str=$P(farg,",",parnum),typ=""
	.	S expr=$$MCOL(str,frm,.len,.typ,.dec,.fsn,.cmp,.vsub,.tok,.vdd,.nop)
	.	I $e(expr)'="'" D						;6/28/2000
	..		;
	..		I "TUF"[funtyp,typ'="","DCL"[typ S expr="$$"_$S(typ="D":"DAT",typ="C":"TIM",1:"LOG")_"^%ZM("_expr_")"
	..		I parnum=1 S func=func_expr Q				;6/28/2000 mas
	..		S func=func_","_expr					;6/28/2000
	.	;
	.	E  S func=func_","_expr
	;
	F fparnum=parnum+1:1:$L(params,",") D
	.	;
	.	S expr=$P(params,",",fparnum)
	.	I $E(expr)="""" S func=func_$E(",,,,,,,,,,",1,fparnum-parnum)_expr,parnum=fparnum
	;
	I ER Q ""
	Q $$UNTOK^%ZS(func,.tok)_")"
	;
	;----------------------------------------------------------------------
FINDINAM(exe,files,sel,tok,fsn,fma,cmp,vsub,vdd)	;public; Find data items in select list for files
	;----------------------------------------------------------------------
	; This subroutine is used to search the select list for references to
	; tables that can be loaded high.
	; 
	N ER,RM,file,i,ptr,str,z
	;
	S ER=0,ptr=0
	;
	F  S str=$$GETCOL(sel,.ptr),z=$$MCOL(str,files,,,,.fsn,.cmp,.vsub,.tok,.vdd,-1) Q:ptr>$L(sel)!ER
	I ER Q
	;
	F i=1:1:$L(files,",") D
	.	;
	.	S file=$P(files,",",i)
	.	D LOAD^SQLDD(file,.fsn,.exe,1,.fma,files,.vsub,.cmp)
	Q
	;
	;----------------------------------------------------------------------
VSQLF(par)	; Build format record
	;----------------------------------------------------------------------
	; 
	; des | litdel | flddel | recsep | eofdel | header | mskd | mskl | mskc
	; msk$ | mskn
	;
	N litdel,flddel,fmt,mskd,mske,mskl,mskn,mskc,recsep
	;
	S fmt=$G(par("FORMAT")) I fmt="" Q ""
	;
	I fmt="IMAGE" Q "||"_$G(%MSKD)_"|"_$G(%MSKL)_"|"_$G(%MSKC)_"|"_$G(%MSKE)_"|"_$G(%MSKN)
	;
	I $E(fmt)'="|" S fmt=$G(^STBL("TFMT",fmt))
	I fmt="" Q ""
	;
	S litdel=$p(fmt,"|",2)			  ; Quote string data
	S flddel=$p(fmt,"|",3)			  ; Column delimiter
	S recsep=$p(fmt,"|",4)			  ; Record Separator
	;
	S mskd=$P(fmt,"|",7) I mskd="*" S mskd=$G(%MSKD)
	S mskl=$P(fmt,"|",8) I mskl="*" S mskl=$G(%MSKL)
	S mskc=$P(fmt,"|",9) I mskc="*" S mskc=$G(%MSKC)
	S mske=$P(fmt,"|",10) I mske="*" S mske=$G(%MSKE)
	S mskn=$P(fmt,"|",11) I mskn="*" S mskn=$G(%MSKN)
	;
	; Why isn't this in dbtbl6e
	;
	I $G(par("DATE"))'="" S mskd=par("DATE")
	I $G(par("DEC"))'="" S (mske,mskn)=par("DEC")
	;
	Q litdel_"|"_flddel_"|"_mskd_"|"_mskl_"|"_mskc_"|"_mske_"|"_mskn_"|"_recsep
	;
CONTAIN(X,Y)	Q ","_X_","[(","_Y_",") 
