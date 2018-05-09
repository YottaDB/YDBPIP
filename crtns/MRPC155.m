MRPC155(RETURN,VERSN,EXPR)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure MRPC155 ****
	;
	; 01/29/2008 13:30 - pip
	;
	;
	 S ER=0 ; Error indicator
	 S RM="" ; Error message (if any)
	 ; Unix / Linux record delimiter
	N vstart S vstart=$$GETTIM^%ZFUNC ; Start time of code execution, set below
	;
	S RETURN=$$SELECT(EXPR)
	S RETURN="<div id='Runtime'>%SQL-Runtime: "_(($$GETTIM^%ZFUNC-vstart)/1000000)_" Seconds</div>"_$C(10)_RETURN
	;
	Q RM
	;
SELECT(expr)	;         Run Interactive SQL
	;
	N outputBuffer S outputBuffer=""
	; Capture execution error and return with results
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	 ; Unix / Linux record delimiter
	 ; CrLf String
	;
	N ER S ER=0
	;
	N altbg N code N plan
	N I N IORM N PN N break N cache N col N i N line N match N rows N sqlcnt N sqlsta N tot
	N exe N fsn N ovf N pars N vdd N vsql N xcol
	N colgrp N cursor N hdg N msk N par N parms N sqldta N sqlind N title N tok N typ N d N z
	N SELECT N FROM N WHERE N ORDER N GROUP N RM
	;
	N IO S IO=""
	N IOSL S IOSL=0
	;
	S cursor=0 ; Enhance when cursor option is enabled
	;
	S expr=$$TOKEN^%ZS(expr,.tok) ; Tokenize quoted Strings
	;
	I (expr["//") D
	.	S parms=$piece(expr,"//",2,$L(expr)) S expr=$piece(expr,"//",1)
	.	I (parms[($char(0))) S parms=$$UNTOK^%ZS(parms,.tok)
	.	;
	.	D parse(parms,.pars,"/","=",1,0,1,"BREAK,CACHE,CAPTION,CODE,COLS,DEBUG,DQMODE,HEADINGS,LAYOUT,MARKUP,MATCH,OUTPUT,PAGE,PLAN,ROWS,STYLE,TEMPLATE,TITLE")
	.	Q 
	;
	; Parse our special column definition syntax
	;
	F  Q:'((expr["{"))  D  I ER Q 
	.	;
	.	N colNum S colNum=$L($piece(expr,"{",1),",")
	.	;
	.	I '(expr["}") D ERROR("Column Qualifier terminator '}' expected on column # "_colNum,"") Q 
	.	;
	.	S parms=$piece($piece(expr,"{",2),"}",1)
	.	I (parms[($char(0))) S parms=$$UNTOK^%ZS(parms,.tok)
	.	;
	.	S expr=$piece(expr,"{",1)_$piece(expr,"}",2,$L(expr))
	.	D dispOpts(parms,colNum,.xcol,.tok)
	.	Q 
	;
	I ER Q outputBuffer
	;
	; FRS - May not be necessary to untokenize here, check this out
	I (expr[($char(0))) S expr=$$UNTOK^%ZS(expr,.tok)
	S expr=$$SQL^%ZS(expr,.tok)
	;
	I ER D ERROR($get(RM)) Q outputBuffer
	;
	S expr=$$vStrTrim($E(expr,8,1048575),0," ")
	;
	N isHTML S isHTML=1 ; Default markup
	I ($$vStrUC($get(pars("MARKUP")))="TEXT") S isHTML=0
	;
	N isPortrait S isPortrait=0
	I ($$vStrLC($get(pars("LAYOUT")),0)="portrait") S isPortrait=1
	;
	I '($get(pars("TEMPLATE"))="") D template(pars("TEMPLATE"),.pars)
	I ER Q outputBuffer
	;
	I '($get(pars("DEBUG"))="") D  I ER Q outputBuffer
	.	;
	.	I ($$vStrLC(pars("DEBUG"),0)="syntax") D showPars(.pars,.xcol,.isHTML) Q 
	.	;
	.	N msg
	.	D RUN^SQLTESTS(expr,0,.msg,.par,.tok)
	.	D caption("Debug SQL Statement","UT",isHTML,40)
	.	;
	.	F I=1:1 Q:'($D(msg(I))#2)  D writeln($C(10)_msg(I))
	.	D section(80,isHTML)
	.	S ER=(ER=2)
	.	Q 
	;
	S SELECT=$$TOK^SQL(expr,"FROM,WHERE,ORDER,GROUP",.tok)
	I ER D ERROR($get(RM)) Q outputBuffer
	;
	I (SELECT="") D ERROR($$^MSG(8569),"") Q outputBuffer
	I ($get(FROM)="") D ERROR($$^MSG(8561),"") Q outputBuffer
	;
	N distinct S distinct=($E(SELECT,1,9)="DISTINCT ")
	;
	I distinct S SELECT=$E(SELECT,10,1048575)
	E  I ($E(SELECT,1,4)="ALL ") S SELECT=$E(SELECT,5,1048575)
	;
	I ($E(SELECT,1)="*") D  I ER Q outputBuffer
	.	;
	.	I (SELECT="*") S SELECT=$$COLLIST^DBSDD(FROM,0,1,0)
	.	E  S SELECT=$$selectWild(SELECT,FROM,.xcol,.fsn,.tok)
	.	Q 
	;
	; Build the columm array col()
	D bldcol(SELECT,FROM,$get(ORDER),.col,.xcol,.pars,.tok,.fsn,.vdd)
	I ER Q outputBuffer
	;
	I '($get(pars("TITLE"))="") S pars("title")=$$bldTitle(pars("TITLE"),isHTML,.col,.pars,FROM,$get(WHERE),.tok)
	;
	S IORM=0 ; Initialize right margin
	;
	S hdg=$$bldhdg(.col,.xcol,isHTML,.IORM,.colgrp,.tot,isPortrait) I ER Q outputBuffer
	;
	S rows=$get(pars("ROWS")) D rangeCheck(rows,"0:","Rows")
	S code=$get(pars("CODE")) I (code="") S code=($D(pars("CODE"))#2)
	S cache=$get(pars("CACHE")) I (cache="") S cache=($D(pars("CACHE"))#2)
	S plan=$get(pars("PLAN")) I (plan="") S plan=($D(pars("PLAN"))#2)
	;
	I (plan&cache) S cache=0 D writeln($C(10)_" *** Cache disabled to display plan ***")
	;
	I (rows="") S rows=1000 ; Default 1000 rows
	;
	; Remove and/or set these parameters to fix bug in SQL
	K pars("ROWS")
	S pars("CACHE")=cache
	;
	S expr=SELECT_" FROM "_FROM
	I '($get(WHERE)="") S expr=expr_" WHERE "_WHERE
	I '($get(ORDER)="") S expr=expr_" ORDER "_ORDER
	I '($get(GROUP)="") S expr=expr_" GROUP "_GROUP
	;
	I distinct S expr=("DISTINCT "_expr)
	;
	D SELECT^SQL(expr,.pars,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok,-1)
	;
	I ER D ERROR($get(RM)) Q outputBuffer
	;
	I plan D plan(.pars,.vsql,isHTML)
	I code D code(.pars,.vsql,.exe,isHTML)
	;
	I (rows=0)!(vsql=0) D writeln("Complete :| 0 rows processed. ") Q outputBuffer
	;
	I '($get(pars("OUTPUT"))="") D  I ER D ERROR($get(RM)) Q outputBuffer
	.	;
	.	N X S X=pars("OUTPUT")
	.	;
	.	N AUXPTR N HDG N IOHDG N IOPAR N IOSUB N IOTYP N mod
	.	;
	.	N %EXT S %EXT=1
	.	;
	.	D writeln("Output directed to: "_X)
	.	D ^SCAIO
	.	USE IO
	.	Q 
	;
	; Format heading for HTML table output and start table
	I (isHTML=1) D newTable(.pars,"RS",colgrp)
	;
	S altbg='($piece($piece($piece((";"_$get(pars("xstyle"))),";alt-row-color:",2),";",1),":",1)="")
	;
	I (isPortrait=1) D portrait(hdg,isHTML,altbg,.col,.pars,IO,IOSL,IORM,rows) Q outputBuffer
	;
	S PN=0 S line=0 ; Initialize
	S sqlind="" ; Protection indicator
	;
	I '($get(pars("CAPTION"))="") D caption(pars("CAPTION"),"RS",isHTML) S line=(line+$L(pars("CAPTION"),$C(10)))
	;
	F sqlcnt=1:1 D  I (vsql(0)=100) Q 
	.	;
	.	S vsql=$$^SQLF(.exe,.sqldta,.sqlind) I (vsql=0) S sqlcnt=(sqlcnt-1) Q 
	.	;
	.	I (sqlind[1) S sqldta=$$protect(sqldta,sqlind)
	.	I isHTML S sqldta=$$escape(sqldta) ; Process HTML escapes
	.	;
	.	S d=$$bldRow(sqldta,.col,isHTML,.tot,.break)
	.	D wrtRow(d,hdg,isHTML,.pars,.break,.line,altbg,.IOSL,IORM,.PN)
	.	;
	.	I '(rows="") S rows=(rows-1) I (rows=0) S vsql(0)=100
	.	Q 
	;
	D totals(.tot,hdg,.col,isHTML,IOSL,IORM,line,altbg,PN,.pars)
	D close(cursor,isHTML,IO,sqlcnt,1)
	Q outputBuffer
	;
bldRow(rowdta,col,isHTML,tot,break)	; Format a row
	;
	N I
	N cptr S cptr=0
	;
	S break=0
	;
	N colrec N accum
	;
	N z
	N d S d="" N ovf S ovf=""
	;
	F I=1:1:col D
	.	;
	.	S colrec=col(I)
	.	;
	.	S z=$piece(rowdta,$C(9),I)
	.	;
	.	I ((z="")&'($P(colrec,$C(9),11)="")) S z=$P(colrec,$C(9),11)
	.	;
	.	I '(($P(colrec,$C(9),8)="")!(z="")) D  ; Process accumulators
	..		;
	..		S accum=tot(I)
	..		; if "N$".contains(colrec.type) & z.contains(".") set z = +z
	..		;
	..		; Save for histogram
	..		I ($E($P(accum,$char(9),1),5)=1) S tot(I,z)=$get(tot(I,z))+1
	..		I '($E($P(accum,$char(9),1),1,4)[1) Q 
	..		;
	..		I ($E($P(accum,$char(9),1),1)=1) S $P(accum,$char(9),2)=$P(accum,$char(9),2)+1
	..		I ($E($P(accum,$char(9),1),2)=1) S $P(accum,$char(9),3)=$P(accum,$char(9),3)+z
	..		;
	..		I ($E($P(accum,$char(9),1),3)=1) D  ; MAX
	...			I ($P(accum,$char(9),4)="") S $P(accum,$char(9),4)=z
	...			E  I ("N$DC"[($P(colrec,$C(9),2))) S:(z>$P(accum,$char(9),4)) $P(accum,$char(9),4)=z
	...			E  I (z]($P(accum,$char(9),4))) S $P(accum,$char(9),4)=z
	...			Q 
	..		;
	..		I ($E($P(accum,$char(9),1),4)=1) D  ; MIN
	...			I ($P(accum,$char(9),5)="") S $P(accum,$char(9),5)=z
	...			E  I ("N$DC"[($P(colrec,$C(9),2))) S:(z<$P(accum,$char(9),5)) $P(accum,$char(9),5)=z
	...			E  I ($P(accum,$char(9),5)]z) S $P(accum,$char(9),5)=z
	...			Q 
	..		;
	..		S tot(I)=accum
	..		Q 
	.	;
	.	I ($P(colrec,$C(9),12)&'($get(col(I,0))=z)) D  ; Break line
	..		;
	..		N i
	..		;
	..		I '($get(col(I,0))="") D
	...			I ($P(colrec,$C(9),12)<0) S break=$P(colrec,$C(9),12)
	...			E  I ($P(colrec,$C(9),12)>break)&'(break<0) S break=$P(colrec,$C(9),12)
	...			Q 
	..		;
	..		S col(I,0)=z S $P(colrec,$C(9),10)=1
	..		;
	..		; Force columns to the right always repeat after break
	..		F i=I+1:1:col I ($D(col(i,0))#2) S col(i,0)=""
	..		Q 
	.	;
	.	I ($P(colrec,$C(9),1)=0) S col(I,0)=z Q  ; Save value and quit
	.	;
	.	I ($P(colrec,$C(9),10)=0) D  ; Repeat option
	..		;
	..		;if 'IOSL.isNull() & (line + 1 > IOSL) set col(I,0) = ""
	..		;
	..		I ($get(col(I,0))=z) S z="" ; Null if same as last
	..		E  S col(I,0)=z
	..		Q 
	.	;
	.	I (z="") D  Q  ; Null column
	..		;
	..		I '($P(colrec,$C(9),6)="") Q 
	..		;
	..		I isHTML S d=d_"<td>"
	..		E  S cptr=(cptr+$P(colrec,$C(9),1)+$P(colrec,$C(9),7))
	..		Q 
	.	;
	.	I '($P(colrec,$C(9),16)="")&(+z'<+0) S $P(colrec,$C(9),16)=""
	.	I '($P(colrec,$C(9),4)="") D  ; FOrmat value
	..		;
	..		I (("N$"[($P(colrec,$C(9),2)))) S z=$$NUM^%ZM(z,$P(colrec,$C(9),3),$P(colrec,$C(9),4))
	..		E  I ($P(colrec,$C(9),2)="D") S z=$$vdat2str(z,$P(colrec,$C(9),4))
	..		E  I ($P(colrec,$C(9),2)="L") S z=$$LOG^%ZM(z,$P(colrec,$C(9),4))
	..		E  I ($P(colrec,$C(9),2)="C") D  ; Oracle time handling
	...			;
	...			I '($P(colrec,$C(9),4)["DATE") S z=$$TIM^%ZM(z,$P(colrec,$C(9),4))
	...			; 21550= 01/01/1900 DATE0 format (ORACLE datetime format)
	...			E  I ($P(colrec,$C(9),4)["DATE0") S z=$$vdat2str(21550,%MSKD)_$$TIM^%ZM(z,$piece($P(colrec,$C(9),4),"DATE0",2))
	...			E  S z=$$vdat2str((+$H),%MSKD)_$$TIM^%ZM(z,$piece($P(colrec,$C(9),4),"DATE",2))
	...			Q 
	..		E  I (("MTU"[($P(colrec,$C(9),2)))) S z=$$STRFormat(z,$P(colrec,$C(9),4))
	..		;
	..		Q 
	.	;
	.	E  I '($P(colrec,$C(9),3)="") S z=$J(z,0,$P(colrec,$C(9),3))
	.	;
	.	I isHTML D
	..		;
	..		I ($P(colrec,$C(9),9)=2) S z=$E(z,1,$P(colrec,$C(9),1)) ;Truncate
	..		I '($P(colrec,$C(9),16)="") S z="<span style="_$P(colrec,$C(9),16)_">"_z_"</span>"
	..		;
	..		I ($P(colrec,$C(9),6)="") S d=d_"<td>"_z
	..		;
	..		E  D
	...			I '($P(colrec,$C(9),13)="") S z="<span style="_$P(colrec,$C(9),13)_">"_z_"</span>"
	...			S d=d_$P(colrec,$C(9),6)_z
	...			Q 
	..		;
	..		Q 
	.	;
	.	E  D
	..		;
	..		I '($P(colrec,$C(9),5)="") D
	...			;
	...			I $P(colrec,$C(9),5)="right" S z=$J(z,$P(colrec,$C(9),1)) ; Right
	...			E  I $P(colrec,$C(9),5)="center" S z=$J("",($P(colrec,$C(9),1)-$L(z))\2)_z
	...			Q 
	..		;
	..		I '($P(colrec,$C(9),6)="") D
	...			;
	...			S z=$P(colrec,$C(9),6)_z
	...			;
	...			N i
	...			F i=I-1:-1:1 S colrec=col(i) I (($P(colrec,$C(9),6)="")&($P(colrec,$C(9),1)>0)) Q 
	...			;
	...			S cptr=(cptr-$P(colrec,$C(9),1)-$P(colrec,$C(9),7)) ; Reset position
	...			;
	...			; Prepend prior overflow
	...			F i=$L(ovf,$C(10)):-1:1 I ($L($piece(ovf,$C(10),i))>cptr) S z=$C(10)_$E($piece(ovf,$C(10),i),cptr+1,9999)_z S $piece(ovf,$C(10),i)=$E($piece(ovf,$C(10),i),1,cptr)
	...			S z=$E(d,cptr+1,1048575)_z ; Concatenate to prior column
	...			;
	...			I ($E(z,1)=" ") S z=$$vStrTrim(z,-1," ") ; Remove leading whitespace
	...			S d=$E(d,1,cptr)
	...			Q 
	..		;
	..		I (z[($C(10))) D
	...			;
	...			N i1 N i2
	...			F i1=1:1:$L(ovf,$C(10)) I (+$L($piece(ovf,$C(10),i1))'>+cptr) Q 
	...			F i2=2:1:$L(z,$C(10)) S $piece(ovf,$C(10),i1)=$piece(ovf,$C(10),i1)_$J("",cptr-$L($piece(ovf,$C(10),i1)))_$piece(z,$C(10),i2) S i1=i1+1
	...			S z=$piece(z,$C(10),1)
	...			Q 
	..		;
	..		I ($P(colrec,$C(9),9)>0)&($L(z)>$P(colrec,$C(9),1)) D
	...			;
	...			I ($P(colrec,$C(9),9)=2) S z=$E(z,1,$P(colrec,$C(9),1)) ; Truncate
	...			E  S z=$$overflow(z,cptr,$P(colrec,$C(9),1),.ovf) ; Wrap
	...			Q 
	..		;
	..		S d=d_$J("",cptr-$L(d))_z S cptr=(cptr+$P(colrec,$C(9),1)+$P(colrec,$C(9),7))
	..		Q 
	.	Q 
	;
	S d=(d_$C(10))
	;
	I isHTML S d=("<tr>"_d)
	E  I '(ovf="") S d=(d_ovf_$C(10))
	;
	Q d
	;
STRFormat(str,format)	; String format
	;
	; May want to 'beef up'the url syntax and either add "http:..." and/or
	; remove attributes onthe displayed portion.  May also wantot add masks.
	;
	I format="URL" Q "<a href="_$S(str'["""":""""_str_"""",1:$$QADD^%ZS(str,""""))_"> "_str_"</a>"
	I format="IMAGE" Q "<img src="_$S(str'["""":""""_str_"""",1:$$QADD^%ZS(str,""""))_">"
	I format="HTML" Q $$unEscape(str)
	Q str
	;
overflow(val,cptr,len,ovf)	; Data overflow with orphan control
	;
	N i N j
	N x
	;
	S x=$E(val,len+1,1048575)
	S val=$E(val,1,len)
	;
	; Append a single orphan character after break to the current string
	; or back up halfway through the string and find a break delimiter
	I (" ,"[($E(x,2))) S val=val_$E(x,1) S x=$E(x,2,1048575)
	I ($E(x,$L(x))=" ") S x=$$RTCHR^%ZFUNC(x," ")
	;
	I '(x="") D
	.	;
	.	F j=len:-1:1 I (" ,"[($E(val,j))) Q 
	.	I   S x=$E(val,j+1,1048575)_x S val=$E(val,1,j)
	.	Q 
	;
	I ($E(x,1)=" ") S x=$$vStrTrim(x,-1," ")
	I (x="") Q val
	;
	F i=1:1 D  I (x="") Q 
	.	;
	.	S $piece(ovf,$C(10),i)=$piece(ovf,$C(10),i)_$J("",cptr-$L($piece(ovf,$C(10),i)))_$$vStrTrim($E(x,1,len),-1," ")
	.	S x=$E(x,len+1,1048575)
	.	;
	.	I (" ,"[($E(x,2))) S $piece(ovf,$C(10),i)=$piece(ovf,$C(10),i)_$E(x,1) S x=$E(x,2,1048575)
	.	I ($E(x,$L(x))=" ") S x=$$RTCHR^%ZFUNC(x," ")
	.	;
	.	I '(x="") D
	..		N start S start=$L($piece(ovf,$C(10),i))
	..		N end S end=(start-len+1)
	..		;
	..		F j=start:-1:end I (" ,"[($E($piece(ovf,$C(10),i),j))) Q 
	..		I   S x=$E($piece(ovf,$C(10),i),j+1,$L($piece(ovf,$C(10),i)))_x S $piece(ovf,$C(10),i)=$E($piece(ovf,$C(10),i),1,j)
	..		Q 
	.	Q 
	;
	Q val
	;
wrtRow(rd,hdg,isHTML,pars,break,line,altbg,IOSL,IORM,PN)	; Output a row
	;
	I ((isHTML=1)&altbg&(line#2)) S rd="<tr class=d1"_$E(rd,4,1048575)
	;
	I (break&(line>0)) D
	.	;
	.	I (break<0) D  Q  ; Form-Feed value (-1)
	..		;
	..		I (IOSL="") S IOSL=0 ; No heading - just FF
	..		E  S line=(IOSL+1) ; Force heading & FF
	..		S break=0
	..		Q 
	.	;
	.	I (isHTML=1) S rd=("<tr>"_rd)
	.	E  S rd=$translate($J("",break-0)," ",$C(10))_""_rd S line=(line+break)
	.	Q 
	;
	I isHTML S line=line+1
	E  S line=(line+$L(rd,$C(10))-1) ; Consider overflow
	;
	I '(IOSL="")&(line>IOSL) D
	.	;
	.	I break S rd=$piece(rd,$C(10),(break+1),$L(rd)) ; Remove break Linefeed on new page
	.	;
	.	S PN=(PN+1)
	.	;
	.	S hdg=$$title(.pars,isHTML,IORM,PN)_hdg
	.	;
	.	I (IOSL=0) D
	..		S IOSL=$get(pars("PAGE")) ; First line
	..		I isHTML S hdg=($C(10)_"<thead>"_$C(10)_"<tr>"_hdg_$C(10)_"<tbody>")
	..		Q 
	.	;
	.	E  S hdg=($S(isHTML:"<tr>",1:$char(12))_hdg) ; Form-feed
	.	;
	.	S line=$S(isHTML:1,1:$L(hdg,$C(10)))
	.	S rd=(hdg_rd)
	.	Q 
	;
	D writeln(rd)
	Q 
	;
protect(sqldta,sqlind)	; Set protected columns to Null
	;
	N y S y=0
	F  S y=$F(sqlind,1,y) Q:y=0  S $piece(sqldta,$char(9),y-1)=""
	Q sqldta
	;
title(pars,isHTML,IORM,PN)	; Display title
	;
	; This is a structured element that was is created by the bldTitle procedure
	;
	 ; Delimiter - Record
	 ; Delimiter - Field
	;
	N x N dec N fmt N var N typ N style
	N i
	;
	N title S title=$get(pars("title"))
	I (title="") Q ""
	;
	; Perform Variable substitution in title
	;
	N vars
	;
	S vars=$piece(title,$C(0),1) S title=$piece(title,$C(0),2,$L(title))
	;
	F i=1:1:$L(vars,$C(1)) D
	.	;
	.	S x=$piece(vars,$C(1),i) ; Get the variable
	.	;
	.	S typ=$piece(x,"|",2) S dec=$piece(x,"|",3) S style=$piece(x,"|",4) S fmt=$piece(x,"|",5)
	.	;
	.	;   #ACCEPT DATE=12/04/07; PGM=Frank Sanchez; CR=unknown
	.	XECUTE ("set var="_$piece(x,"|",1))
	.	;
	.	I (("N$"[typ)) S var=$$NUM^%ZM(var,dec,fmt)
	.	E  I (typ="D") S var=$$vdat2str(var,fmt)
	.	E  I (typ="L") S var=$$LOG^%ZM(var,fmt)
	.	E  I (typ="C") S var=$$TIM^%ZM(var,fmt)
	.	;
	.	I '(style="")&isHTML S var="<span style="_$S(style'["""":""""_style_"""",1:$$QADD^%ZS(style,""""))_">"_var_"</span>"
	.	;
	.	S title=$piece(title,$C(1),1)_var_$piece(title,$C(1),2,$L(title))
	.	;
	.	Q 
	;
	I ('isHTML&(title[($C(9)))) D  ; Adjust padding for variables, right float
	.	;
	.	N i
	.	F i=1:1:$L(title,$C(10)) D
	..		;
	..		S x=$piece(title,$C(10),i)
	..		I (x[($C(9))) D
	...			S x=$piece(x,$C(9),1)_$J("",IORM-$L(x)+1)_$piece(x,$C(9),2)
	...			S $piece(title,$C(10),i)=x
	...			Q 
	..		Q 
	.	Q 
	;
	Q title
	;
close(cursor,isHTML,IO,sqlcnt,complete)	;
	;
	D CLOSE^SQLM(cursor) ; Close SQL cursor
	;
	I (isHTML=1) D writeln("</table>")
	;
	I (complete=1) D paragraph("Complete :> "_sqlcnt_" rows processed.","RS",isHTML)
	Q 
	;
border(col,chr)	; Return border break line
	;
	; This function returns a formatted plain text line
	;
	N I
	N cptr S cptr=0
	N colrec
	N d S d=""
	;
	S d=""
	F I=1:1:col D
	.	;
	.	S colrec=col(I)
	.	;
	.	I '($P(colrec,$C(9),1)&($P(colrec,$C(9),6)="")) Q 
	.	;
	.	I (cptr>0) S d=(d_$J("",cptr-$L(d)))
	.	S d=d_$translate($J("",$P(colrec,$C(9),1)-0)," ",chr)_""
	.	S cptr=(cptr+$P(colrec,$C(9),1)+$P(colrec,$C(9),7))
	.	Q 
	;
	Q d
	;
caption(text,class,isHTML,length)	; Output a table caption
	;
	I (isHTML=1) S text="<caption><p class=PSL-"_class_">"_$$vStrRep($$vStrRep(text,"  ","&nbsp;&nbsp;",0,0,""),$C(10),"<BR>",0,0,"")_"</p></caption>"
	E  S text="*** "_text_" ***" S text=($J("",(length-$L(text))\2)_text)
	;
	D writeln($C(10)_text_$C(10))
	Q 
	;
paragraph(text,class,isHTML)	; Output a paragraph
	;
	I (isHTML=1) S text="<p class=PSL-"_class_">"_$$vStrRep($$vStrRep(text,"  ","&nbsp;&nbsp;",0,0,""),$C(10),"<BR>",0,0,"")_"</p>"
	D writeln($C(10)_text_$C(10))
	Q 
	;
section(length,isHTML)	; Output a section break (horizontal rule)
	;
	N text
	I (isHTML=1) S text="<br><hr /><br>"
	E  S text=$translate($J("",$S((length<80):80,1:length)-0)," ","-")_""
	D writeln($C(10)_text_$C(10))
	Q 
	;
totals(tot,hdg,col,isHTML,IOSL,IORM,line,altbg,PN,pars)	; output totals
	;
	I ($order(tot(""))="") Q 
	;
	N I N i N break N colNum
	N fl N func N rd N row N x N xcol N z
	N accum N colrec
	;
	S xcol=col
	;
	; Lay out the row / function map
	F I=1:1:col D
	.	;
	.	S colrec=col(I)
	.	;
	.	S fl=$P(colrec,$C(9),8) ; function list
	.	;
	.	I (fl="") Q 
	.	;
	.	F i=1:1:$L(fl,";") D
	..		S x=$get(row(i))
	..		S $piece(x,$C(9),I)=$piece(fl,";",i)
	..		S row(i)=x
	..		Q 
	.	Q 
	;
	I ($order(row(0))="") Q 
	;
	; Output underlines or empty row
	I (isHTML=1) S break=1 ; In HTML force an empty row
	E  D  ; In text mode, output underlines
	.	S rd=($$border(.col,"=")_$C(10)) S break=0
	.	D wrtRow(rd,hdg,isHTML,.pars,0,.line,altbg,.IOSL,IORM,.PN)
	.	Q 
	;
	N n S n=""
	;
	F  S n=$order(row(n)) Q:(n="")  D
	.	;
	.	S rd=""
	.	S colNum=0
	.	;
	.	; First generate rows to map the functions
	.	F I=1:1:col D
	..		;
	..		S colrec=col(I)
	..		;
	..		I (($P(colrec,$C(9),1)=0)!'($P(colrec,$C(9),6)="")) Q 
	..		;
	..		S colNum=colNum+1
	..		S func=$piece(row(n),$C(9),I)
	..		;
	..		S $P(colrec,$C(9),8)="" S $P(colrec,$C(9),12)="" S $P(colrec,$C(9),10)="" S $P(colrec,$C(9),11)=""
	..		I (func="") S xcol(colNum)=colrec Q 
	..		;
	..		S $P(colrec,$C(9),15)=func_"("_$piece($$escape($P(colrec,$C(9),15))," ",1)_")"
	..		;
	..		S accum=tot(I)
	..		;
	..		I func="COUNT" S z=$P(accum,$C(9),2)
	..		E  I func="SUM" S z=$P(accum,$C(9),3)
	..		E  I func="MAX" S z=$P(accum,$C(9),4)
	..		E  I func="MIN" S z=$P(accum,$C(9),5)
	..		E  I func="AVG" D
	...			;
	...			I ($P(accum,$C(9),2)>0) S z=($P(accum,$C(9),3)/$P(accum,$C(9),2))
	...			E  S z=""
	...			;
	...			I (z[".")&($P(colrec,$C(9),3)="") S $P(colrec,$C(9),3)=2
	...			Q 
	..		;
	..		E  I func="UNIQUE" D  ; Count unique
	...			;
	...			N v S v=""
	...			F z=0:1 S v=$order(tot(I,v)) Q:(v="") 
	...			Q 
	..		;
	..		E  I func="MED" D  ; Find median
	...			;
	...			N t S t=($P(accum,$C(9),2)/2)
	...			N c S c=0
	...			N v S v=""
	...			S z=""
	...			;
	...			F  S v=$order(tot(I,v)) Q:(v="")  S c=(c+tot(I,v)) Q:(c>t)  S z=v
	...			I '(v="") S z=$S(t#1:v,1:((z+v)/2))
	...			;
	...			I (z[".")&($P(colrec,$C(9),3)="") S $P(colrec,$C(9),3)=2
	...			Q 
	..		;
	..		E  I func="LEAST" D  ; Find least popular value
	...			;
	...			N n S n=$order(tot(I,"")) I (n="") S z="" Q 
	...			N v S v=tot(I,n)
	...			;
	...			S z=n
	...			F  S n=$order(tot(I,n)) Q:(n="")  D
	....				I (tot(I,n)<v) S v=tot(I,n) S z=n
	....				E  I (tot(I,n)=v) S z=(z_$C(10)_n)
	....				Q 
	...			Q 
	..		;
	..		E  I func="MOST" D  ; Find most popular value
	...			;
	...			N n S n=$order(tot(I,"")) I (n="") S z="" Q 
	...			N v S v=tot(I,n)
	...			;
	...			S z=n
	...			F  S n=$order(tot(I,n)) Q:(n="")  D
	....				I (tot(I,n)>v) S v=tot(I,n) S z=n
	....				E  I (tot(I,n)=v) S z=(z_$C(10)_n)
	....				Q 
	...			Q 
	..		;
	..		E  I func="COUNT-LEAST" D  ; Find # occurrances of least popular value
	...			;
	...			N v S v=$order(tot(I,"")) I (v="") S z="" Q 
	...			S z=tot(I,v)
	...			;
	...			F  S v=$order(tot(I,v)) Q:(v="")  I (tot(I,v)<z) S z=tot(I,v)
	...			Q 
	..		;
	..		E  I func="COUNT-MOST" D  ; Find # occurrances of most popular value
	...			;
	...			N v S v=$order(tot(I,"")) I (v="") S z="" Q 
	...			S z=tot(I,v)
	...			;
	...			F  S v=$order(tot(I,v)) Q:(v="")  I (tot(I,v)>z) S z=tot(I,v)
	...			Q 
	..		;
	..		E  I ($E(func,1,2)="t-") D  ; Special 'tie value' syntax
	...			;
	...			S $P(colrec,$C(9),15)="t-"_($piece(func,"t-",2)-5)_"("_$piece($P(colrec,$C(9),15),"(",2,999)
	...			;
	...			S z=$piece(accum,$C(9),$piece(func,"t-",2))
	...			I ("$NDCL"[($P(colrec,$C(9),2))) S z=$$EXT^%ZM(z,$P(colrec,$C(9),4),$P(colrec,$C(9),3)) S $P(colrec,$C(9),4)="" S $P(colrec,$C(9),3)=""
	...			S z=("t-"_z) ;Display ties
	...			Q 
	..		;
	..		I (",COUNT,COUNT-LEAST,COUNT-MOST,UNIQUE,"[(","_func_",")) S $P(colrec,$C(9),3)=""
	..		;
	..		S xcol(colNum)=colrec
	..		;
	..		; Results contain more than one value, insert rows to handle and shift down
	..		I (z[($C(10))) D
	...			;
	...			N t S t=5
	...			N r S r=n
	...			N s S s=""
	...			N x N y
	...			N xaccum S xaccum=accum
	...			;
	...			; Shift rows down within this column (start at end)
	...			F  S s=$order(row(s),-1) Q:(s=r)  D
	....				;
	....				S x=row(s)
	....				I ($piece(x,$C(9),I)="") Q  ; No function for column
	....				S y=$get(row(s+$L(z,$C(10))-1))
	....				S $piece(y,$C(9),I)=$piece(x,$C(9),I)
	....				S row(s+$L(z,$C(10))-1)=y
	....				Q 
	...			;
	...			F i=2:1:$L(z,$C(10)) D
	....				;
	....				S t=(t+1)
	....				S r=(r+1)
	....				;
	....				N y S y=accum ; PSL error forces this
	....				S $piece(xaccum,$C(9),t)=$piece(z,$C(10),i) ; Add value to accumm (sic y)
	....				S x=$get(row(r))
	....				S $piece(x,$C(9),I)=("t-"_t)
	....				S row(r)=x
	....				Q 
	...			;
	...			S tot(I)=xaccum
	...			S z=$piece(z,$C(10),1)
	...			Q 
	..		;
	..		S $piece(rd,$C(9),colNum)=z
	..		Q 
	.	;
	.	S xcol=colNum
	.	S rd=$$bldRow(rd,.xcol,isHTML)
	.	;
	.	I (isHTML=1) D  ; Poke titles into columns
	..		;
	..		F I=1:1:colNum D
	...			;
	...			S colrec=$get(xcol(I))
	...			I '($P(colrec,$C(9),15)="") S rd=$piece(rd,"<td",1,I)_"<td title="_$P(colrec,$C(9),15)_$piece(rd,"<td",I+1,$L(rd))
	...			Q 
	..		Q 
	.	;
	.	D wrtRow(rd,hdg,isHTML,.pars,break,.line,altbg,.IOSL,IORM,PN)
	.	S break=0
	.	Q 
	;
	Q 
	;
bldcol(sel,from,order,col,xcol,pars,tok,fsn,vdd)	; Return internal column array
	;
	; This procedure returns a column array based on the data dictionary
	; and overridden by xcol
	;
	N RM S RM=""
	;
	S from=$$^SQLJ(from,,.fsn,,.tok)
	I ER D ERROR(RM) Q 
	;
	N length N ptr
	N agf N att N align N break N class N datatype N format N name N hdg N str N style N title N n N p N x N z
	N colrec N forext N schema
	;
	N isError S isError=0 ; Group error indicator
	;
	; Initialize format to %MSK global formats
	;
	N dftAtts S dftAtts=$$dftFormat() ; Initialize %MASK global formats
	I ($D(pars("COLS"))#2) S dftAtts=dftAtts_","_pars("COLS")
	;
	N zpars N gcol
	D parse(dftAtts,.zpars,",","=",0,"none","default","length,type,decimal,format,align,merge,space,math,wrap,repeat,null,break,style,heading,title,minus")
	;
	S n=""
	F  S n=$order(zpars(n)) Q:(n="")  D
	.	;
	.	I ER S isError=1 S ER=0 ; Mark error & continue
	.	;
	.	S class=$piece(n,".",1) S att=$piece(n,".",2)
	.	S z=zpars(n)
	.	;
	.	I (att="") S att=class S class="."
	.	E  I (class="") S class="."
	.	;
	.	S p=$L($piece(",length,type,decimal,format,align,merge,space,math,wrap,repeat,null,break,style,heading,title,minus,",","_att_",",1),",")
	.	I 'p D ERROR("Invalid Column Parameter",n) Q 
	.	;
	.	I (z="default") S z=$piece(",,,,, ,2,,1,1,,1,,",",",p)
	.	;
	.	; Save for title or other formatting if necessary
	.	I (att="format") S pars(class_"."_att)=z
	.	;
	.	;if z.piece(":",2,2,"""").isNull() set z = "mask:" _ z
	.	;
	.	; Move this into the appropriate column in gcol
	.	S x=$get(gcol(class)) S $piece(x,$C(9),p)=z S gcol(class)=x
	.	;
	.	Q 
	;
	I '($get(gcol("."))="") D  ; Merge Root & classes
	.	;
	.	N i
	.	N n S n="."
	.	;
	.	N x N z
	.	S x=gcol(".") ; Root class record
	.	;
	.	F  S n=$order(gcol(n)) Q:(n="")  D
	..		;
	..		S z=gcol(n) ; Class record
	..		F i=1:1:$L(x,$C(9)) I '($piece(x,$C(9),i)="") S $piece(z,$C(9),i)=$$mergeProperties($piece(x,$C(9),i),$piece(z,$C(9),i))
	..		S gcol(n)=z
	..		Q 
	.	Q 
	;
	I (isError=1) S ER=1
	;
	I ER Q 
	;
	I ($D(pars("BREAK"))#2) D  ; Initialize orderby to set-up auto break
	.	;
	.	N table S table=$piece(from,",",1)
	.	N keys S keys=$piece(fsn(table),"|",3)
	.	;
	.	I (order="") S order=keys
	.	;
	.	F col=1:1:$L(order,",") D  I ER Q 
	..		S str=$$vStrTrim($piece($piece(order,",",col)," ",1),0," ")
	..		S str=$$MCOL^SQLCOL(str,from,,,,.fsn,,,.tok,.vdd,1)
	..		S $piece(order,",",col)=$piece(str,$char(1),2)
	..		Q 
	.	;
	.	I $piece(order,",",col)=(table_"."_$piece(keys,",",$L(keys,","))) S order=$piece(order,",",1,$L(order,",")-1)
	.	Q 
	;
	S ptr=0
	;
	F col=1:1 S str=$$GETCOL^SQLCOL(sel,.ptr) D  I (ptr>$L(sel)) Q 
	.	;
	.	I ER S isError=1 S ER=0 ; Mark error & continue
	.	;
	.	S colrec="" ; Initialize column record
	.	S length="" S datatype=""
	.	;
	.	; For aggregate functions, get the root column
	.	I (str["(") S agf=$piece(str,"(",1) S str=$piece($piece(str,"(",2),")",1)
	.	E  S agf=""
	.	;
	.	S str=$$MCOL^SQLCOL(str,from,.length,.datatype,,.fsn,,,.tok,.vdd,1)
	.	I ER D ERROR(RM) Q 
	.	;
	.	I (length="") S length=$L(str)
	.	I (datatype="") S datatype=$S(str=+str:"N",1:"T")
	.	;
	.	S class=$$getClass(datatype)
	.	;
	.	S forext=$get(xcol(col))
	.	I '($P(forext,$C(9),2)="") S class=$$vStrLC($P(forext,$C(9),2),0) S datatype=$$getType(class)
	.	;
	.	S forext=$$getColAtts(class,.gcol,forext)
	.	;
	.	; Support one global shift of datatype - could be implemented to be recursive (trap a-->b-->a)
	.	I '(($P(forext,$C(9),2)="")!($$vStrLC($P(forext,$C(9),2),0)=class)) D
	..		;
	..		S class=$$vStrLC($P(forext,$C(9),2),0) S datatype=$$getType(class)
	..		S forext=$$getColAtts(class,.gcol,forext)
	..		Q 
	.	;
	.	I (datatype="") D ERROR("Invalid DataType",class) Q 
	.	;
	.	S $P(colrec,$C(9),2)=datatype
	.	;
	.	I (str[($char(1))) S name=$piece(str,$char(1),2)
	.	E  S name=str
	.	;
	.	S schema=$get(vdd(name))
	.	;
	.	S hdg=$P(forext,$C(9),14) ; User attribute input
	.	I (hdg="none") S hdg=""
	.	E  I (hdg="") S hdg=$$vStrTrim($translate($P(schema,"|",22),"@"," "),0," ") I '(agf="") S hdg=agf_" "_hdg
	.	S $P(colrec,$C(9),14)=hdg
	.	;
	.	S title=$P(forext,$C(9),15) ; User attribute input
	.	I (title="none") S title=""
	.	E  I (title="") D
	..		;
	..		I '(agf="") S name=(agf_"("_name_")")
	..		;
	..		S title=name_" "_class
	..		;
	..		I '("BLDCM"[datatype) D  ; Add length and decimal schema values
	...			;
	...			S title=title_"("_$P(schema,"|",2)
	...			;
	...			I '($P(schema,"|",14)="") S title=title_","_$P(schema,"|",14)
	...			S title=title_")"
	...			Q 
	..		;
	..		I ($P(schema,"|",1)["*") S title=title_" Primary-Key"
	..		I '($P(schema,"|",5)="") D
	...			;
	...			I ($E($P(schema,"|",5),1)="[") S title=title_" Table-Ref: "_$piece($piece($P(schema,"|",5),"[",2),"]",1)
	...			I ($E($P(schema,"|",5),1)=",") S title=title_" Enum-List: "_$$QADD^%ZS($E($P(schema,"|",5),2,999),"""")
	...			Q 
	..		;
	..		I '($P(schema,"|",16)="") S title=title_" Computed: "_$P(schema,"|",16)
	..		Q 
	.	S $P(colrec,$C(9),15)=title
	.	;
	.	; Length can be set to zero to hide the column (no output)
	.	I '($P(forext,$C(9),1)="") S length=$P(forext,$C(9),1) ; User attribute input
	.	I (length="none") S length=0
	.	I (length=0) S $P(forext,$C(9),7)=0 S $P(forext,$C(9),8)="" ; Hidden column
	.	S $P(colrec,$C(9),1)=length
	.	;
	.	S align=$S(("CLDF"[datatype):"center",("N$"[datatype):"right",1:"")
	.	I '($P(forext,$C(9),5)="") S align=$$vStrLC($P(forext,$C(9),5),0)
	.	I (align="left"!(align="none")) S align="" ; Always default in output
	.	S $P(colrec,$C(9),5)=align
	.	;
	.	S break=$P(forext,$C(9),12) ; User attribute input
	.	I (break="none") S break=0
	.	E  I ((break="")&($D(pars("BREAK"))#2)) S break=$S(($piece(order,",",col)=name):pars("BREAK"),1:0)
	.	I (break="page") S break=-1
	.	S $P(colrec,$C(9),12)=break
	.	;
	.	S style=$P(forext,$C(9),13)
	.	I (style="none") S style=""
	.	E  I '(style="") D
	..		;
	..		S z=$piece($piece($piece((";"_style),";minus-color:",2),";",1),":",1)
	..		I '(z="") S style=$$remProperty(style,"minus-color") S $P(colrec,$C(9),16)="color:"_z
	..		Q 
	.	S $P(colrec,$C(9),13)=style
	.	;
	.	S format=$P(forext,$C(9),4) ; User attribute input
	.	I (format="none") S $P(colrec,$C(9),4)="" S $P(colrec,$C(9),3)=""
	.	E  D
	..		S $P(colrec,$C(9),3)=$$getProperty("decimal-size",format,$P(schema,"|",14))
	..		S $P(colrec,$C(9),4)=$$getFormat(class,format)
	..		Q 
	.	;
	.	I ($P(forext,$C(9),9)="none") S $P(forext,$C(9),9)=0
	.	E  I ($P(forext,$C(9),9)="") S $P(forext,$C(9),9)=1
	.	E  I ($E("truncate",1,$L(($P(forext,$C(9),9))))=($P(forext,$C(9),9))) S $P(forext,$C(9),9)=2
	.	;
	.	I ($P(forext,$C(9),8)="none") S $P(forext,$C(9),8)=""
	.	I ($P(forext,$C(9),11)="none") S $P(forext,$C(9),11)=""
	.	;
	.	I ($P(forext,$C(9),7)="none") S $P(forext,$C(9),7)=0
	.	E  I ($P(forext,$C(9),7)="") S $P(forext,$C(9),7)=2
	.	;
	.	I ($P(forext,$C(9),6)="none") S $P(forext,$C(9),6)=""
	.	I ($P(forext,$C(9),10)="none") S $P(forext,$C(9),10)=0
	.	;
	.	S $P(colrec,$C(9),10)=$P(forext,$C(9),10)
	.	S $P(colrec,$C(9),11)=$P(forext,$C(9),11)
	.	S $P(colrec,$C(9),9)=$P(forext,$C(9),9)
	.	S $P(colrec,$C(9),8)=$$vStrUC($P(forext,$C(9),8))
	.	S $P(colrec,$C(9),6)=$P(forext,$C(9),6)
	.	S $P(colrec,$C(9),7)=$P(forext,$C(9),7)
	.	;
	.	; If break or norepeat are specified, set the other default
	.	I (($P(colrec,$C(9),10)="")&$P(colrec,$C(9),12)) S $P(colrec,$C(9),10)=0
	.	E  I (($P(colrec,$C(9),12)="")&($P(colrec,$C(9),10)=0)) S $P(colrec,$C(9),12)=1
	.	;
	.	S col(col)=colrec
	.	Q 
	;
	I (isError=1) S ER=1 ; Signal to return error
	;
	Q 
	;
bldhdg(col,xcol,isHTML,IORM,colgrp,tot,isPortrait)	;
	N vo106
	;
	; This utility generates a heading and other returned parameters
	;
	N I N i
	N colrec
	;
	N d N z
	N hdg S hdg=""
	;
	S colgrp=""
	;
	F I=1:1:col D  ; Patch & validate format options
	.	;
	.	S colrec=col(I)
	.	;
	.	; Don't display this column, typically used for keys if imbedded in heading
	.	I ($P(colrec,$C(9),1)=0) Q 
	.	;
	.	I '($P(colrec,$C(9),8)="") S vo106=$P(colrec,$C(9),8) S tot(I)=$$initMath(.vo106) S $P(colrec,$C(9),8)=vo106
	.	;
	.	; This section ignores the linebreak '@' defined in the report heading and
	.	; constructs the heading based on the available field length.  It will also
	.	; expand the field length to fit the longest word in the heading.
	.	;
	.	N label S label=$P(colrec,$C(9),14)
	.	;
	.	I (label["  ") S label=$$vStrRep(label,"  "," ",0,0,"") ; Remove extra whitespace
	.	;
	.	; if 'isHTML do {
	.	;
	.	; Minimum field length must at least fit the longest heading word
	.	F i=1:1:$L(label," ") I ($L($piece(label," ",i))>$P(colrec,$C(9),1)) D
	..		;
	..		S $P(colrec,$C(9),1)=$L($piece(label," ",i))
	..		S col(I)=colrec
	..		Q 
	.	;
	.	; Starting at the end, fit as many words into each line as possible
	.	I ($L(label)>$P(colrec,$C(9),1)) D
	..		;
	..		N p S p=$L(label," ")
	..		F i=(p-1):-1:1 I ($L($piece(label," ",i,p))>$P(colrec,$C(9),1)) S label=$piece(label," ",1,i)_$C(10)_$piece(label," ",i+1,999) S p=i
	..		Q 
	.	;
	.	I (label[($C(9))) D  ; Check for markup type
	..		;
	..		I ($$vStrUC($piece(label,$C(9),1))="HTML") S label=$piece(label,$C(9),2,$L(label))
	..		E  I (isHTML=1) S label=$$escape(label)
	..		Q 
	.	;
	.	I '($P(colrec,$C(9),6)="")&(I>1) D  Q  ; Merge with prior column
	..		;
	..		N merge S merge=$P(colrec,$C(9),6)
	..		I (merge?1N.E) S merge=$$ASCIItoHTML(merge,isHTML)
	..		;
	..		I (isHTML=1) D  ; Modify heading & title
	...			;
	...			I (merge["  ") S merge=$$vStrRep(merge,"  "," &nbsp;",0,0,"")
	...			;
	...			I '(label="") S hdg=$E(hdg,1,$L(hdg)-5)_merge_label_"</th>"
	...			;
	...			; Patch the title to add the column header info
	...			N p S p="<th title=" ; Pattern to patch, get last occurrance
	...			N c S c=$L(hdg,"<th title=")
	...			N z S z=$piece(hdg,"<th title=",c)
	...			N h S h=$piece(z,">",2,99)
	...			N s S s=$piece(z," style=",2) ; Parse out style= qualifier
	...			;
	...			S z=$piece(z,">",1)
	...			I '(s="") S z=$piece(z," style=",1)
	...			;
	...			S z=$$QADD^%ZS(($$QSUB^%ZS(z,"""")_$C(10)_$$escape($P(colrec,$C(9),15))),"""")
	...			I '(s="") S z=(z_" style="_s)
	...			;
	...			S $piece(hdg,p,c)=(z_">"_h)
	...			Q 
	..		;
	..		E  D  ; Text Markup
	...			;
	...			S merge=$$vStrRep(merge,"<br>",$C(10),0,0,"")
	...			S merge=$$vStrRep(merge,"<BR>",$C(10),0,0,"")
	...			;
	...			I (label="") Q 
	...			;
	...			N pcol
	...			N pcolrec
	...			;
	...			F pcol=I-1:-1:1 S pcolrec=col(pcol) I (($P(pcolrec,$C(9),6)="")&($P(pcolrec,$C(9),1)>0)) Q 
	...			;
	...			; Modify merge 'into' column length to fit merged columns
	...			;
	...			S IORM=(IORM-$P(pcolrec,$C(9),1)-$P(pcolrec,$C(9),7))
	...			;
	...			S col(pcol)=pcolrec
	...			;
	...			; merge heading to prior heading
	...			S label=$E($piece(hdg,$C(10),5),IORM+1,999)_merge_label
	...			S $piece(hdg,$C(10),5)=$E($piece(hdg,$C(10),5),1,IORM)
	...			;
	...			N p
	...			;
	...			F p=4:-1:1 I ($L($piece(hdg,$C(10),p))>IORM) D
	....				S label=$E($piece(hdg,$C(10),p),IORM+1,999)_$C(10)_label
	....				S $piece(hdg,$C(10),p)=$E($piece(hdg,$C(10),p),1,IORM)
	....				Q 
	...			;
	...			S p=$L(label,$C(10))
	...			;
	...			F i=p:-1:1 D
	....				S z=$piece(label,$C(10),i)
	....				S d=$piece(hdg,$C(10),(5+i-p))
	....				;
	....				I (IORM>0) S d=d_$J("",IORM-$L(d)) ; Pad
	....				I ($P(colrec,$C(9),5)="right") S z=$J(z,$P(colrec,$C(9),1)) ; Right
	....				E  I ($P(colrec,$C(9),5)="center") S z=$J("",($P(colrec,$C(9),1)-$L(z))\2)_z
	....				S $piece(hdg,$C(10),(5+i-p))=(d_z)
	....				Q 
	...			;
	...			S d=$E($piece(hdg,$C(10),6),1,IORM)_$translate($J("",$P(pcolrec,$C(9),1)-0)," ","-")_""_$J("",$P(pcolrec,$C(9),7))
	...			S $piece(hdg,$C(10),6)=d
	...			;
	...			S IORM=(IORM+$P(pcolrec,$C(9),1)+$P(pcolrec,$C(9),7))
	...			Q 
	..		;
	..		S $P(colrec,$C(9),6)=merge
	..		S $P(colrec,$C(9),8)=""
	..		S $P(colrec,$C(9),5)=""
	..		S col(I)=colrec
	..		Q 
	.	;
	.	I (isHTML=1) D
	..		;
	..		S label=$$vStrRep(label,$C(10),"<br>",0,0,"")
	..		;
	..		S hdg=hdg_$C(10)_"<th"
	..		I '($P(colrec,$C(9),15)="") S hdg=hdg_" title="_$$QADD^%ZS($$escape($P(colrec,$C(9),15)),"""")
	..		I '($P(colrec,$C(9),13)="") S hdg=hdg_" style=color:black"
	..		S hdg=hdg_">"_label_"</th>"
	..		;
	..		I $get(isPortrait) Q 
	..		;
	..		S colgrp=colgrp_"<col"
	..		;
	..		I '($P(colrec,$C(9),5)="") S colgrp=(colgrp_" align="_$P(colrec,$C(9),5))
	..		I '($P(colrec,$C(9),13)="") S colgrp=(colgrp_" style="_$$QADD^%ZS($translate($P(colrec,$C(9),13),"= ",":;"),""""))
	..		;
	..		S colgrp=(colgrp_">"_$C(10))
	..		Q 
	.	;
	.	E  D  ; Create plain text heading
	..		;
	..		N p S p=$L(label,$C(10))
	..		;
	..		F i=p:-1:1 D
	...			S z=$piece(label,$C(10),i)
	...			S d=$piece(hdg,$C(10),(5+i-p))
	...			;
	...			I (IORM>0) S d=d_$J("",IORM-$L(d)) ; Pad
	...			I ($P(colrec,$C(9),5)="right") S z=$J(z,$P(colrec,$C(9),1)) ; Right
	...			E  I ($P(colrec,$C(9),5)="center") S z=$J("",($P(colrec,$C(9),1)-$L(z))\2)_z
	...			S $piece(hdg,$C(10),(5+i-p))=(d_z)
	...			Q 
	..		;
	..		S d=$piece(hdg,$C(10),6)_$J("",IORM-$L(d))_$translate($J("",$P(colrec,$C(9),1)-0)," ","-")_""_$J("",$P(colrec,$C(9),7))
	..		S $piece(hdg,$C(10),6)=d
	..		Q 
	.	;
	.	S IORM=(IORM+$P(colrec,$C(9),1)+$P(colrec,$C(9),7)) ; Nominal Right margin
	.	Q 
	;
	I ($E(hdg,1,$L(($C(10))))=($C(10))) S hdg=$$vStrTrim(hdg,-1,$C(10))
	Q hdg_$C(10)
	;
bldTitle(title,isHTML,col,pars,from,where,tok)	; Initialize title
	;
	; Format title from fixed template and pre-process variable substitution
	;
	 ; Delimiter - Record
	 ; Delimiter - Field
	;
	N i N y N yz
	N v N var N cakwd N class N parms N L1 N L2 N R1 N R2
	N colrec
	;
	I (title="default") D  ; Generate a default title
	.	;
	.	N table S table=$$UNTOK^%ZS($piece($piece(from," ",1),",",1),.tok)
	.	N dbtbl1 S dbtbl1=$G(^DBTBL("SYSDEV",1,table))
	.	S title=$P(dbtbl1,$C(124),1)
	.	I '(where="") S title=title_" ( "_$$UNTOK^%ZS(where,.tok)_")"
	.	Q 
	;
	N txtHTML S txtHTML=0 ; Title is in HTML text format
	;
	I (title[($C(9))) D
	.	;
	.	I ($$vStrUC($piece(title,$C(9),1))="HTML") S txtHTML=1 S title=$piece(title,$C(9),2,$L(title))
	.	I (title[($C(9))) S title=$translate(title,$C(9)," ")
	.	Q 
	;
	S L1=""
	 S L1="Profile Framework"
	;
	I ((TJD=$P($H,",",1))!(TJD="")) S R1=""
	E  S R1="Effective: <:%SystemDate>"
	;
	I ($get(pars("PAGE"))>0) S R1=(R1_"  Page: <:PN>")
	S R2="Run Date: <:%CurrentDate>   <:%CurrentTime>"
	;
	I (isHTML=1) D
	.	;
	.	I 1 S title=(L1_$C(10)_title)
	.	I '(R1="") S R2=(R1_$C(10)_R2)
	.	;
	.	S title=(title_$C(9)_R2)
	.	Q 
	;
	E  D
	.	;
	.	I '(R1="") S L1=(L1_$C(9)_R1)
	.	I '(R2="") S $piece(title,$C(10),1)=($piece(title,$C(10),1)_$C(9)_R2)
	.	S title=(title_$C(10))
	.	I '(L1="") S title=(L1_$C(10)_title_$C(10))
	.	Q 
	;
	N vars S vars=""
	;
	S y=0
	F  S y=$F(title,"<:",y) Q:(y=0)  D  ; Parse variable insertion
	.	;
	.	S yz=$F(title,">",y) I (yz=0) Q 
	.	S v=$E(title,y,yz-2) ; element expression
	.	;
	.	S parms=$$vStrTrim($piece(v," ",2,$L(v)),0," ") S var=$piece(v," ",1)
	.	;
	.	I (var[".") D  ; Find Column reference in column title
	..		S var=$$vStrUC(var)
	..		F i=1:1:col S colrec=col(i) I ($piece($P(colrec,$C(9),15)," ",1)=var) S var=i Q 
	..		Q 
	.	;
	.	I var?1N.N&($D(col(var))#2) S colrec=col(var) S var=("col("_var_",0)")
	.	;
	.	E  I ($E(var,1)="%") D  Q:(var="") 
	..		;
	..		S var=$$kwdRow^UCDTAUTL(var,.cakwd) I (var="") D ERROR("Invalid variable syntax",v) Q 
	..		S colrec=""
	..		S $P(colrec,$C(9),2)=$S($piece(var,"|",4)="Time":"C",1:$E($piece(var,"|",4),1))
	..		S class=$$getClass($P(colrec,$C(9),2))
	..		S $P(colrec,$C(9),4)=$$getFormat(class,$get(pars(class_".format")))
	..		;
	..		S var=$piece(var,"|",2)
	..		Q 
	.	;
	.	E  I '(var="PN") D ERROR("Invalid variable syntax",v) Q  ; Could add more local vars if required (e.g., sqlcnt)
	.	;
	.	I '($E(var,1)="$") S var="$G("_var_")" ; Prevent undefined errors
	.	;
	.	I '(parms="") D
	..		;
	..		N format N style
	..		;
	..		S class=$$getClass($P(colrec,$C(9),2))
	..		;
	..		D parse(parms,.pars,",","=",,,,"format,style")
	..		S format=$get(pars("format")) S style=$get(pars("style"))
	..		;
	..		I (format="") S format=$P(colrec,$C(9),4)
	..		E  I (format="none") S format=""
	..		E  S format=$$getFormat(class,format)
	..		;
	..		S $P(colrec,$C(9),3)=$$getProperty("decimal-size",format,$P(colrec,$C(9),3))
	..		;if (colrec.decimal = "none") set colrec.decimal = ""
	..		S $P(colrec,$C(9),4)=format S $P(colrec,$C(9),13)=style
	..		Q 
	.	;
	.	S vars=$S((vars=""):var_"|"_$P(colrec,$C(9),2)_"|"_$P(colrec,$C(9),3)_"|"_$P(colrec,$C(9),13)_"|"_$P(colrec,$C(9),4),1:vars_$C(1)_var_"|"_$P(colrec,$C(9),2)_"|"_$P(colrec,$C(9),3)_"|"_$P(colrec,$C(9),13)_"|"_$P(colrec,$C(9),4))
	.	S title=$E(title,1,y-3)_$C(1)_$E(title,yz,1048575)
	.	Q 
	;
	I (txtHTML=0&(isHTML=1)) S title=$$escape(title) ; Escape HTML chars
	I (txtHTML=1&(isHTML=0)) D
	.	; Insert code to replace HTML tags with appropriate plain text (e.g., alternate text)
	.	Q 
	;
	I (isHTML=1) D
	.	;
	.	S title=$$vStrRep(title,$C(10),"<br>",0,0,"")
	.	S title=("<div style=float:left;color:black>"_$piece(title,$C(9),1)_"</div><div style=float:right;color:black>"_$piece(title,$C(9),2)_"</div>")
	.	;
	.	; Count the number of unhidden and unmerged columns for colspan
	.	N i
	.	N c S c=0
	.	;
	.	F i=1:1:col S colrec=col(i) I (($P(colrec,$C(9),1)>0)&($P(colrec,$C(9),6)="")) S c=(c+1)
	.	S title=("<tr><th colspan="_c_" align=left>"_title_"</th></tr>"_$C(10))
	.	Q 
	;
	S title=vars_$C(0)_title
	;
	Q title
	;
plan(pars,vsql,isHTML)	; Display execution IO plan
	;
	N d N colgrp N hdg
	N i N z
	N index S index=""
	N xcol N sort
	;
	N IORM S IORM=0
	;
	N colrec S colrec=""
	;
	S xcol=5
	S $P(colrec,$C(9),7)=2
	S $P(colrec,$C(9),2)="T"
	;
	S $P(colrec,$C(9),1)=12
	S $P(colrec,$C(9),5)="left"
	S $P(colrec,$C(9),14)="Index"
	;
	S xcol(1)=colrec
	;
	S $P(colrec,$C(9),1)=30
	S $P(colrec,$C(9),14)="Primary Keys"
	S xcol(2)=colrec
	;
	S $P(colrec,$C(9),1)=7
	S $P(colrec,$C(9),5)="center"
	S $P(colrec,$C(9),14)="Cost"
	S xcol(3)=colrec
	;
	S $P(colrec,$C(9),1)=4
	S $P(colrec,$C(9),14)="Code"
	S xcol(4)=colrec
	;
	S $P(colrec,$C(9),1)=20
	S $P(colrec,$C(9),5)="left"
	S $P(colrec,$C(9),14)="Distribution"
	S xcol(5)=colrec
	;
	S hdg=$$bldhdg(.xcol,,isHTML,.IORM,.colgrp)
	;
	I (isHTML=1) D newTable(.pars,"UT",colgrp)
	;
	; First sort index by cost
	F i=1:1 S index=$order(vsql("P",index)) Q:(index="")  D
	.	;
	.	S z=vsql("P",index)
	.	S sort($piece(z,"|",4)+(i/100))=index
	.	Q 
	;
	D caption("Display SQL IO Access Plan - "_(i-1)_" Indexes","UT",isHTML,IORM)
	D writeln($C(10)_hdg)
	;
	N n S n=""
	F  S n=$order(sort(n)) Q:(n="")  D
	.	;
	.	S index=sort(n)
	.	S z=vsql("P",index)
	.	S d=index_$C(9)_$piece(z,"|",2)_$C(9)_(($piece(z,"|",4)+.05)\1)_$C(9)_$piece(z,"|",5)_$C(9)_$piece(z,"|",3)
	.	I (isHTML=1) S d=$$escape(d)
	.	D writeln($$bldRow(d,.xcol,isHTML))
	.	Q 
	;
	I (isHTML=1) D writeln($C(10)_"</table>")
	D section(IORM,isHTML)
	Q 
	;
dftCSS(pars,class)	; Default CSS
	;
	N n N m
	N alt N css N hstyle N tstyle N xstyle
	;
	; Frank's hard-coded default style sheet
	S tstyle="border-width:1px;padding:2px;border-spacing:;border-style:inset;border-color:#788cb3;border-collapse:collapse;background-color:#FCFDFE;font-family:Verdana;font-size:80%"
	;
	; Process user declaration of style attributes
	I (class="RS") D parse($get(pars("STYLE")),.css,";",":",0,"none","default","")
	;
	I ER Q 
	;
	; Add additional table level custom properties for alt-row (not standard css, move to xstyle)
	;
	S xstyle=""
	S n="alt-row-" S m=n
	;
	F  S m=$order(css(m)) Q:'($E(m,1,$L(n))=n)  D
	.	I (css(m)="none") S xstyle=$$remProperty(xstyle,m)
	.	E  S xstyle=$$setProperty(xstyle,m,css(m))
	.	K css(m)
	.	Q 
	;
	S n=""
	F  S n=$order(css(n)) Q:(n="")  S tstyle=$$setProperty(tstyle,n,css(n)) I ($E(n,1)="@") S tstyle=n
	;
	S hstyle=$$setProperty(tstyle,"padding","3px")
	S hstyle=$$setProperty(hstyle,"background-color","#EBEEF4")
	;
	I class="UT" S tstyle=$$setProperty(tstyle,"border-color","#d2b48c")
	;
	; Output style sheet in HTML format
	;
	D writeln(($C(10)_"<style type=""text/css"">"_$C(10)))
	D writeln(($C(10)_"table.PSL-"_class_" {"_$$vStrRep(tstyle,";",(";"_$C(10,9)),0,0,"")_"}"_$C(10)))
	D writeln(($C(10)_"table.PSL-"_class_" th {"_$$vStrRep(hstyle,";",(";"_$C(10,9)),0,0,"")_"}"_$C(10)))
	;
	; Alternate row background modifies the bottom border of the table
	S alt=$piece($piece($piece((";"_xstyle),";alt-row-color:",2),";",1),":",1) ; Alternate Row backround
	I (alt="default") S alt="#EFFFDF"
	;
	I (alt=$piece($piece($piece((";"_tstyle),";background-color:",2),";",1),":",1)) S alt="" ; Same as alternate row
	;
	I ((alt="")!(alt="none")) S xstyle=$$remProperty(xstyle,"alt-row-color")
	E  S tstyle=$$setProperty(tstyle,"border-bottom-color",alt)
	;
	D writeln(($C(10)_"table.PSL-"_class_" td {"_$$vStrRep(tstyle,";",(";"_$C(10,9)),0,0,"")_"}"_$C(10)))
	;
	I '(alt="") D writeln(($C(10)_"table.PSL-"_class_" tr.d1 td {background-color:"_alt_"}"_$C(10)))
	;
	I '($translate(xstyle,";","")="") D
	.	;
	.	D writeln(($C(10,9)_"/* PROFILE-SQL extended style properties"_$C(10,9)))
	.	D writeln($$vStrRep(xstyle,";",(";"_$C(10,9)),0,0,""))
	.	D writeln(("*/"_$C(10)))
	.	Q 
	;
	D writeln($C(10)_"</style>"_$C(10))
	;
	S pars("tstyle")=tstyle
	S pars("xstyle")=xstyle
	;
	Q 
	;
dftFormat()	; Return application format defaults derived from %MSK* runtime variables
	;
	I ($get(%MSKN)="") S %MSKN="."
	I ($get(%MSKE)="") S %MSKE="."
	I ($get(%MSKD)="") S %MSKD="MM/DD/YEAR"
	I ($get(%MSKC)="") S %MSKC="12:60 AM"
	I ($get(%MSKL)="") S %MSKL="NY"
	;
	N format
	;
	; Set the application default to global masks %MSK*
	;
	S format="number.format=decimal-separator:"_$$QADD^%ZS($E(%MSKN,1),"""")
	I $L(%MSKN)>1 S format=format_";group-separator:"_$$QADD^%ZS($E(%MSKN,2),"""")_";group-size:3"
	I $L(%MSKN)>2 S format=format_";minus-sign:"_$$QADD^%ZS($E(%MSKN,3),"""")
	;
	S format=format_",currency.format=decimal-separator:"_$$QADD^%ZS($E(%MSKE,1),"""")
	I $L(%MSKE)>1 S format=format_";group-separator:"_$$QADD^%ZS($E(%MSKE,2),"""")_";group-size:3"
	I $L(%MSKE)>2 S format=format_";minus-sign:"_$$QADD^%ZS($E(%MSKE,3),"""")
	;
	I '($get(%MSKC)="") S format=format_",time.format="_$S(%MSKC'["""":""""_%MSKC_"""",1:$$QADD^%ZS(%MSKC,""""))
	I '($get(%MSKD)="") S format=format_",date.format="_$S(%MSKD'["""":""""_%MSKD_"""",1:$$QADD^%ZS(%MSKD,""""))
	I '($get(%MSKL)="") S format=format_",logical.format="_$S(%MSKL'["""":""""_%MSKL_"""",1:$$QADD^%ZS(%MSKL,""""))
	;
	Q format
	;
getFormat(class,format)	; Return internal format from external format
	;
	I class="currency"!(class="number") D
	.	;
	.	N z
	.	;
	.	; Note: group-size is specified but not implemented, will default to 3 in NUM^%ZM
	.	S z=$$getProperty("decimal-separator",format)
	.	S z=z_$$getProperty("group-separator",format)
	.	S z=z_$$getProperty("minus-sign",format)
	.	;
	.	S format=z I format="." S format="" ; Standard decimal
	.	Q 
	;
	; else  set format = $$getProperty("mask", format)
	; if z.piece(":",2,2,"""").isNull() set z = "mask:" _ z
	; Other formats don't have multiple properties
	;
	I (format="none") S format=""
	E  S format=$$vStrUC(format)
	;
	Q format
	;
getProperty(property,input,default)	; Return property value
	;
	I '($E(input,1)=";") S input=";"_input
	;
	N value S value=$$vStrPce($$vStrPce(input,(";"_property_":"),2,2,""""),";",1,1,"""")
	;
	I (value["""") S value=$$QSUB^%ZS(value,"""")
	;
	I ((value="default")!(value="")) S value=$get(default)
	I (value="none") S value=""
	;
	Q value
	;
setProperty(expr,name,val,tok)	; Insert or update a property in expr
	;
	N isTokenized S isTokenized=1
	;
	I (($get(tok)="")&(expr["""")) S isTokenized=0 S expr=$$token(expr,.tok)
	;
	I (val="") Q name
	I ((val[":")!((val[";"))) S val=$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,"""")) ; Quote to protect delimiters
	;
	S name=(";"_name_":") S expr=(";"_expr)
	;
	I ($E(expr,$L(expr))=";") S expr=$E(expr,1,$L(expr)-1)
	;
	I '((";"_expr_":")[name) S expr=(expr_name_val) ; Insert at end
	E  S expr=$piece(expr,name,1)_name_val_";"_$piece($piece(expr,name,2,999),";",2,999)
	;
	S expr=$$vStrTrim(expr,-1,";")
	;
	I (isTokenized=0) S expr=$$UNTOK^%ZS(expr,.tok)
	;
	Q expr
	;
mergeProperties(expr,add,tok)	; Merge or add column attributes (properties) to expr
	;
	I (add="") Q expr
	;
	I (",none,default,"[(","_$$vStrLC(expr,0)_",")) S expr=""
	I (expr="") Q add
	;
	S ER=0
	;
	N isTokenized S isTokenized=1
	;
	I (($get(tok)="")&(expr["""")) S isTokenized=0 S expr=$$token(expr,.tok)
	;
	N i
	N z
	F i=1:1:$L(add,";") S z=$piece(add,";",i) S expr=$$setProperty(expr,$piece(z,":",1),$piece(z,":",2,$L(z)),.tok)
	;
	I (isTokenized=0) S expr=$$UNTOK^%ZS(expr,.tok)
	;
	I ER D ERROR("Syntax Error Merging Properties: ",add)
	;
	Q expr
	;
remProperty(expr,name,tok)	; Remove a property from an expression
	;
	N isTokenized S isTokenized=1
	;
	I (($get(tok)="")&(expr["""")) S isTokenized=0 S expr=$$token(expr,.tok)
	;
	S name=(";"_name_":")
	I '($E(expr,1)=";") S expr=(";"_expr)
	S expr=$piece(expr,name,1)_";"_$piece($piece(expr,name,2,999),";",2,999)
	I ($E(expr,1)=";") S expr=$E(expr,2,1048575)
	;
	I (isTokenized=0) S expr=$$UNTOK^%ZS(expr,.tok)
	;
	Q expr
	;
token(expr,tok)	; Tokenize a string
	;
	I (expr["""") S expr=$$TOKEN^%ZS(expr,.tok,"""")
	;
	; Issue with two string delimiters, disable single quote for now at least
	; if expr.contains("'") set expr = $$TOKEN^%ZS(expr,.tok,"'")
	Q expr
	;
parse(input,return,de,dv,upCase,falseText,trueText,valid)	; Parse string into array
	;
	N i
	N a N c N x
	;
	I ($get(de)="") S de=","
	I ($get(dv)="") S dv="="
	I ($get(upCase)="") S upCase=0
	I ($get(falseText)="") S falseText="none"
	I ($get(trueText)="") S trueText="default"
	;
	S valid=$get(valid)
	;
	I (input="?") D ERROR(valid,"?") Q 
	;
	N y S y=0 N yz S yz=1
	;
	F  S y=$F(input,de,y) D  I (y>$L(input)) Q 
	.	;
	.	I (y=0) S y=$L(input)+2
	.	;
	.	I '($L($E(input,yz,y-1),"""")#2) Q 
	.	;
	.	S x=$$vStrTrim($E(input,yz,y-2),0," ") S yz=y
	.	I (x="") Q 
	.	S a=$$RTCHR^%ZFUNC($piece(x,dv,1)," ")
	.	S x=$$vStrTrim($piece(x,dv,2,$L(x)),-1," ")
	.	;
	.	I (a[".") S c=$piece(a,".",1)_"." S a=$piece(a,".",2)
	.	E  S c=""
	.	;
	.	I ("""'"[($E(x,1))) S x=$$QSUB^%ZS(x,$E(x,1))
	.	;
	.	I (a[" ") S x=$piece(a," ",2,$L(a))_$char(9)_x S a=$piece(a," ",1)
	.	I (a="") D ERROR("Property name or tag expected",$piece(input,de,i)) Q 
	.	;
	.	I upCase S a=$$vStrUC(a)
	.	E  S a=$$vStrLC(a,0)
	.	;
	.	I (x="") D
	..		;
	..		I (upCase=1&($E(a,1,2)="NO")) S x=falseText S a=$E(a,3,1048575)
	..		E  I ($E(a,1,2)="no") S x=falseText S a=$E(a,3,1048575)
	..		E  S x=trueText
	..		Q 
	.	;
	.	I '((valid="")!((","_valid_",")[(","_a_","))) D ERROR("Invalid property name or tag",a) Q 
	.	;
	.	; Join the class back to the property, if this is a root property change all classes
	.	; Implemented through 'brute-force' scan (should be OK unless list is very large)
	.	;
	.	I '(c="") S a=c_a I (c=".") D
	..		;
	..		N n S n=""
	..		F  S n=$order(return(n)) Q:(n="")  I (n[a) S return(n)=$$mergeProperties(return(n),x)
	..		Q 
	.	;
	.	; Multi-value syntax (tag:value;)
	.	I ('(dv=":")&($D(return(a))#2)) S x=$$mergeProperties(return(a),x)
	.	;
	.	S return(a)=x
	.	Q 
	;
	Q 
	;
code(pars,vsql,exe,isHTML)	; Display SQL code and data region
	;
	N d N hdg N colgrp N n N m
	N xcol
	;
	N IORM S IORM=0
	;
	N colrec S colrec=""
	;
	S xcol=2
	;
	S $P(colrec,$C(9),2)="T"
	S $P(colrec,$C(9),7)=2
	S $P(colrec,$C(9),5)="left"
	;
	S $P(colrec,$C(9),1)=4
	S $P(colrec,$C(9),14)="Line"
	S xcol(1)=colrec
	;
	S $P(colrec,$C(9),1)=74
	S $P(colrec,$C(9),14)="Code"
	S $P(colrec,$C(9),15)="exe(line)"
	S xcol(2)=colrec
	;
	I '($get(exe)=$order(exe(""),-1)) D writeln($C(10)_"** Program pointer is: "_exe)
	;
	S hdg=$$bldhdg(.xcol,,isHTML,.IORM,.colgrp)
	;
	I (isHTML=1) D newTable(.pars,"UT",colgrp)
	;
	D caption("Show SQL Executable Code ","UT",isHTML,IORM)
	D writeln($C(10)_hdg)
	;
	S n=""
	F  S n=$order(exe(n)) Q:(n="")  D
	.	;
	.	S d=n_$C(9)_exe(n)
	.	I (isHTML=1) S d=$$escape(d)
	.	D writeln($$bldRow(d,.xcol,isHTML))
	.	Q 
	;
	I (isHTML=1) D writeln($C(10)_"</table>"_$C(10))
	;
	D section(IORM,isHTML)
	;
	; Display vsql array
	;
	S IORM=0
	;
	S $P(colrec,$C(9),1)=12
	S $P(colrec,$C(9),14)="Key"
	S $P(colrec,$C(9),15)="vsql(key)"
	S xcol(1)=colrec
	;
	S $P(colrec,$C(9),1)=40
	S $P(colrec,$C(9),14)="Value"
	S xcol(2)=colrec
	;
	S hdg=$$bldhdg(.xcol,,isHTML,.IORM,.colgrp)
	;
	I (isHTML=1) D newTable(.pars,"UT",colgrp)
	;
	D caption("Show Data Context","UT",isHTML,IORM)
	D writeln($C(10)_hdg)
	;
	S n="" S m=""
	F  S n=$order(vsql(n)) Q:(n="")  D
	.	;
	.	I (($D(vsql(n))#2)#2) D
	..		;
	..		S d=n_$C(9)_$S(vsql(n)'["""":""""_vsql(n)_"""",1:$$QADD^%ZS(vsql(n),""""))
	..		I (isHTML=1) S d=$$escape(d)
	..		D writeln($$bldRow(d,.xcol,isHTML))
	..		Q 
	.	;
	.	I (n="P") Q  ; Don't show access plan
	.	;
	.	F  S m=$order(vsql(n,m)) Q:(m="")  D
	..		;
	..		I (($D(vsql(n,m))#2)#2) D
	...			;
	...			S d=n_","_m_$C(9)_$S(vsql(n,m)'["""":""""_vsql(n,m)_"""",1:$$QADD^%ZS(vsql(n,m),""""))
	...			I (isHTML=1) S d=$$escape(d)
	...			D writeln($$bldRow(d,.xcol,isHTML))
	...			Q 
	..		Q 
	.	Q 
	;
	I (isHTML=1) D writeln($C(10)_"</table>")
	D section(IORM,isHTML)
	Q 
	;
showPars(pars,xcol,isHTML)	; Show user parameter input
	;
	; This procedure outputs input parameters
	; For table and column properties
	;
	N d N n N hdg N colgrp
	N zcol
	;
	N i N IORM
	;
	N colrec S colrec=""
	;
	; Display // Table level qualifiers
	;
	S zcol=2 S IORM=0
	;
	S $P(colrec,$C(9),7)=2
	S $P(colrec,$C(9),1)=12
	S $P(colrec,$C(9),14)="Name"
	S zcol(1)=colrec
	;
	S $P(colrec,$C(9),1)=40
	S $P(colrec,$C(9),14)="Value"
	S zcol(2)=colrec
	;
	S hdg=$$bldhdg(.zcol,,isHTML,.IORM,.colgrp)
	;
	I (isHTML=1) D newTable(.pars,"UT",colgrp)
	;
	D caption("Show Input Table Qualifiers","UT",isHTML,IORM)
	D writeln($C(10)_hdg)
	;
	S n=""
	F  S n=$order(pars(n)) Q:((n="")!(n?1L.E))  I (($D(pars(n))#2)#2) D
	.	;
	.	S d=n_$C(9)_pars(n)
	.	I (isHTML=1) S d=$$escape(d)
	.	D writeln($$bldRow(d,.zcol,isHTML))
	.	Q 
	;
	I (isHTML=1) D writeln($C(10)_"</table>")
	;
	D section(IORM,isHTML)
	;
	; Display [ Column qualifiers]
	;
	N colpar S colpar="length,type,decimal,format,align,merge,space,math,wrap,repeat,null,break,style,heading,title"
	;
	S $P(colrec,$C(9),1)=6
	S $P(colrec,$C(9),2)="N"
	S $P(colrec,$C(9),14)="Column"
	S zcol(1)=colrec
	;
	S $P(colrec,$C(9),2)="T"
	S $P(colrec,$C(9),1)=8
	;
	F i=1:1:$L(colpar,",") S $P(colrec,$C(9),14)=$piece(colpar,",",i) S zcol(i+1)=colrec
	;
	S zcol=(i+1) S IORM=0
	;
	S hdg=$$bldhdg(.zcol,,isHTML,.IORM,.colgrp)
	;
	I (isHTML=1) D newTable(.pars,"UT",colgrp)
	;
	D caption("Show Input Column Properties","UT",isHTML,IORM)
	D writeln($C(10)_hdg)
	;
	S n=""
	F  S n=$order(xcol(n)) Q:(n="")  I (($D(xcol(n))#2)#2) D
	.	;
	.	S d=n_$C(9)_xcol(n)
	.	I (isHTML=1) S d=$$escape(d)
	.	D writeln($$bldRow(d,.zcol,isHTML))
	.	Q 
	I (isHTML=1) D writeln($C(10)_"</table>")
	;
	D section(IORM,isHTML)
	Q 
	;
newTable(pars,class,colgrp)	; Start a new HTML table
	;
	I '($D(pars("css",class))#2) D dftCSS(.pars,class) S pars("css",class)=""
	D writeln($C(13)_"<table class=PSL-"_class_">"_$C(13)_colgrp)
	Q 
	;
escape(str)	; Escape HTML characters
	;
	I (str["&") S str=$$vStrRep(str,"&","&amp;",0,0,"")
	I (str["<") S str=$$vStrRep(str,"<","&lt;",0,0,"")
	I (str[">") S str=$$vStrRep(str,">","&gt;",0,0,"")
	I (str["""") S str=$$vStrRep(str,"""","&quot;",0,0,"")
	;
	Q str
	;
unEscape(str)	; Unescape HTML characters
	;
	N y S y=0
	N x
	;
	F  S y=$F(str,"&",y) Q:(y=0)  D
	.	S x=$E(str,y,y+4)
	.	;
	.	I ($E(x,1,3)="lt ") S str=$E(str,y-2)_"<"_$E(str,y+3,1048575)
	.	E  I ($E(x,1,3)="gt ") S str=$E(str,y-2)_">"_$E(str,y+3,1048575)
	.	E  I ($E(x,1,4)="amp ") S str=$E(str,y-2)_"&"_$E(str,y+4,1048575)
	.	E  I x="apos " S str=$E(str,y-2)_"'"_$E(str,y+5,1048575)
	.	E  I x="quot " S str=$E(str,y-2)_""""_$E(str,y+5,1048575)
	.	Q 
	;
	Q str
	;
ASCIItoHTML(expr,isHTML)	; Convert an ASCII string to chars then to html HTML
	;
	N i
	N chars S chars=$char(($piece(expr,",",1)))
	I $L(expr,",")>1 F i=2:1:$L(expr,",") S chars=chars_$char(($piece(expr,",",i)))
	;
	I 'isHTML Q $$vStrRep(chars,"<br>",$char(10),0,0,"") ; Leave in ASCII
	;
	I (chars[($C(13,10))) S chars=$$vStrRep(chars,$C(13,10),"<br>",0,0,"")
	I (chars[($char(10))) S chars=$$vStrRep(chars,$char(10),"<br>",0,0,"")
	I (chars[($char(13))) S chars=$$vStrRep(chars,$char(13),"<br>",0,0,"")
	;
	Q chars
	;
dispOpts(parms,index,xcol,tok)	; Specify display options
	;
	 S TAB=$char(9)
	;
	I (parms="") Q 
	I (parms[($char(0))) S parms=$$UNTOK^%ZS(parms,.tok)
	;
	N data N x N tag N pars
	;
	N record S record="length,type,,format,align,merge,space,math,wrap,repeat,null,break,style,heading,title"
	;
	D parse(parms,.pars,",","=",0,"none","default","length,type,,format,align,merge,space,math,wrap,repeat,null,break,style,heading,title")
	;
	S tag="" S data=""
	F  S tag=$order(pars(tag)) Q:(tag="")  D
	.	;
	.	S x=pars(tag)
	.	I x="default" S x=$piece(",,,,,32,2,,1,1,,1,,",",",$L($piece((","_record_","),","_tag_",",1),","))
	.	;
	.	S $piece(data,TAB,$L($piece((","_record_","),","_tag_",",1),","))=x
	.	Q 
	;
	S xcol(index)=data
	Q 
	;
rangeCheck(val,ranges,par)	; Perform valid  range check on input
	;
	; Validate input against ranges
	;                        ranges == range[,...]
	;                                  range == min[:max]
	;
	I (val="") Q 
	;
	I '(val=+val) D ERROR("Number Expected",val,par) Q 
	;
	N isRange S isRange=1
	;
	I (ranges[":") D
	.	;
	.	N i N min N max
	.	N range
	.	;
	.	F i=1:1:$L(ranges,",") D  I (isRange=0) Q 
	..		;
	..		S range=$piece(ranges,",",i)
	..		S min=$piece(range,":",1) S max=$piece(range,":",2)
	..		I ('(min="")&(val<min)) S isRange=0
	..		E  I ('(max="")&(val>max)) S isRange=0
	..		Q 
	.	Q 
	;
	E  I '((","_ranges_",")[(","_val_",")) S isRange=0 ; Simple list
	;
	I isRange=0 D ERROR("Not in valid range ("_ranges_")",val,par)
	Q 
	;
template(url,pars)	; Process an external and default templates
	;
	I ((","_$get(pars("templates"))_",")[(","_url_",")) Q  ; Circular recursion
	S pars("templates")=$get(pars("templates"))_url_"," ; Add name to list
	;
	N tpars
	;
	I (url[".") D
	.	;
	.	N ok N parms N x
	.	;
	.	S ok=$$FILE^%ZOPEN(url,"READ")
	.	I '$piece(ok,"|",1) D ERROR($piece(ok,"|",2)) Q 
	.	;
	.	S parms=""
	.	;
	.	USE url
	.	F  Q:'('$ZEOF)  READ x S parms=parms_x
	.	CLOSE url
	.	;
	.	S parms=$translate(parms,$C(9,10,13),"   ") ; Translate all whitspace to space
	.	;
	.	D parse(parms,.tpars,"/","=",1,0,1,"BREAK,CACHE,CAPTION,CODE,COLS,DEBUG,DQMODE,FORMAT,HEADINGS,LAYOUT,MARKUP,MATCH,OUTPUT,PAGE,PLAN,ROWS,STYLE,TEMPLATE,TITLE")
	.	;
	.	I '($get(tpars("TEMPLATE"))="") D  ; Recursive iteration
	..		;
	..		N n N zpars
	..		;
	..		S n=""
	..		F  S n=$order(tpars(n)) Q:(n="")  S zpars(n)=tpars(n)
	..		D template(pars("TEMPLATE"),.zpars) I ER Q 
	..		F  S n=$order(zpars(n)) Q:(n="")  S tpars(n)=zpars(n)
	..		Q 
	.	Q 
	;
	; Application hard-coded templates (since these are not parsed, don't use [NO]qualifier syntax)
	;
	E  D
	.	S url=$$vStrUC(url)
	.	;
	.	I (url="REPORT") D
	..		;
	..		N grpsep S grpsep=$E($get(%MSKE),2)
	..		I (grpsep="") S grpsep=","
	..		;
	..		S tpars("STYLE")="alt-row-color:default"
	..		S tpars("TITLE")="default"
	..		S tpars("BREAK")="1"
	..		S tpars("COLS")="currency.math=SUM,currency.format=group-separator:"""_grpsep_""",currency.style=minus-color:red"
	..		Q 
	.	;
	.	; Include additional hard-coded templates as appropriate
	.	;
	.	E  D ERROR("Invalid Template",url)
	.	Q 
	;
	; These two add or accumulate properties
	I ($D(tpars("STYLE"))#2) S pars("STYLE")=tpars("STYLE")_";"_$get(pars("STYLE"))
	I ($D(tpars("COLS"))#2) S pars("COLS")=tpars("COLS")_","_$get(pars("COLS"))
	;
	K tpars("STYLE"),tpars("COLS") ; Remove these to, merged above
	;
	N n S n=""
	F  S n=$order(tpars(n)) Q:(n="")  I '($D(pars(n))#2) S pars(n)=tpars(n)
	Q 
	;
initMath(parms)	; Initialize internal MATH accumulation structures
	;
	N i
	N func N x
	N ctl S ctl=""
	;
	F i=1:1:$L(parms,";") D
	.	;
	.	S x=$$vStrTrim($piece(parms,";",i),0," ") I (x="") Q 
	.	;
	.	S func=$piece(x," ",1) S x=$piece(x," ",2,$L(x))
	.	I (func="") D ERROR("Math function expected",x) Q 
	.	;
	.	I func="COUNT" S $E(ctl,1)=1
	.	E  I func="SUM" S $E(ctl,2)=1
	.	E  I func="MAX" S $E(ctl,3)=1
	.	E  I func="MIN" S $E(ctl,4)=1
	.	E  I func="AVG" S $E(ctl,1)=1 S $E(ctl,2)=1
	.	E  I func="MED" S $E(ctl,1)=1 S $E(ctl,5)=1
	.	E  I (",HSTO,LEAST,MOST,STD,UNIQUE,COUNT-LEAST,COUNT-MOST,"[(","_func_",")) S $E(ctl,5)=1
	.	;
	.	E  D ERROR("Invalid Math function",func) Q 
	.	;
	.	S $piece(parms,";",i)=func
	.	;
	.	I (x="") Q  ; No qualifiers
	.	I (x=+x)&(",MAX,MIN,"[(","_func_",")) S $E(ctl,5)=1
	.	; Need to add RUNNING / BREAK
	.	Q 
	;
	Q ctl
	;
selectWild(sel,from,xcol,fsn,tok)	; Return Data-QWik default list or keys and description
	;
	N fnum N i
	N keys N more N table N typ
	N columns S columns=""
	;
	I ($get(tok)="") S sel=$$TOKEN^%ZS(sel,.tok)
	;
	S typ=$$RTCHR^%ZFUNC($piece(sel,",",1)," ")
	S sel=$piece(sel,",",2,$L(sel))
	;
	F fnum=1:1:$L(from,",") D
	.	;
	.	S table=$piece(from,",",fnum)
	.	I '($D(fsn(table))#2) D fsn^SQLDD(.fsn,table) I ER Q 
	.	;
	.	S keys=$piece(fsn(table),"|",3)
	.	;
	.	I fnum>1 S columns=(columns_",")
	.	S columns=columns_keys ; Always include primary keys
	.	;
	.	I typ="*LIST" S more=$$selectDefault(table,.tok)
	.	E  I (typ[($char(0))) S more=$$selectQuery(table,typ,.tok)
	.	E  S more=""
	.	;
	.	F i=1:1:$L(more,",") I '((","_columns_",")[(","_$piece(more,",",i)_",")) S columns=columns_","_$piece(more,",",i)
	.	Q 
	;
	I (sel="") Q columns
	;
	; If additional columns are specified, add them to the list if they aren't already
	;  on it and move the external formatting to new column location if appropriate
	;
	; First move any formatting to an 'illegal' location
	N n S n=""
	F  S n=$order(xcol(n)) Q:(n="")  S xcol(-n+1)=xcol(n) K xcol(n)
	;
	F i=1:1:$L(sel,",") D
	.	N di S di=$$vStrTrim($piece(sel,",",i),0," ")
	.	I (di[($char(0))) S di=$$QSUB^%ZS($$UNTOK^%ZS(di,.tok),"""")
	.	I '((","_columns_",")[(","_di_",")) S columns=(columns_","_di)
	.	I ($D(xcol(-i))#2) S xcol($L($piece((","_columns_","),","_di_",",1),","))=xcol(-i) K xcol(-i)
	.	Q 
	;
	Q columns
	;
selectDefault(table,tok)	; Select default list
	;
	N i
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=table,dbtbl1=$$vDb3("SYSDEV",table)
	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	;
	N dftdes S dftdes=$P(vop3,$C(124),6)
	N dftord S dftord=$P(vop3,$C(124),7) ; Solve this later
	;
	I ("^,#"[($E(dftdes,1))) S dftdes=""
	;
	I (dftdes="") D
	.	;
	.	N di
	.	N rs,vos1,vos2,vos3,vos4  N V1 S V1=table S rs=$$vOpen1()
	.	F  Q:'($$vFetch1())  S di=rs I ($E("DESCRIPTION",1,$L(di))=di) S dftdes=di
	.	Q 
	;
	E  F i=1:1:$L(dftdes,",") S $piece(dftdes,",",i)=$piece($piece(dftdes,",",i),"/",1)
	;
	Q dftdes
	;
selectQuery(table,whr,tok)	; Select default list
	;
	N columns S columns=""
	;
	F  Q:'((whr[($char(0))))  S whr=$$UNTOK^%ZS(whr,.tok)
	;
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	.	;
	.	S whr=$$vStrTrim($$QSUB^%ZS($E(whr,2,1048575),""""),0," ")
	.	S whr="FID ='"_table_$S((whr=""):"'",1:"' AND "_whr)
	.	;
	.	;   #ACCEPT DATE=12/04/07; PGM=Frank Sanchez; CR=unknown
	.	N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"DI","DBTBL1D",whr,"NOD,POS,DI","","")
	.	F  Q:'($$vFetch0())  S columns=(columns_$P(rs,$C(9),1)_",")
	.	Q 
	;
	Q $E(columns,1,$L(columns)-1)
	;
testMask(class,mask)	; Test format masks
	;
	; Calls format mask and traps GTM errors generated by invalid mask
	; Doesn't seem to coordinate the error trap correctly, doesn't return ER
	;
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
	.	;
	.	I (class="currency")&$$NUM^%ZM(0,0,mask)
	.	E  I (class="number")&$$NUM^%ZM(0,0,mask)
	.	E  I (class="date")&$$vdat2str(0,mask)
	.	E  I (class="logical")&$$LOG^%ZM(0,mask)
	.	E  I (class="time")&$$TIM^%ZM(0,mask)
	.	Q 
	;
	Q 
	;
ERROR(des,val,par)	; Output Error message & set ER
	;
	S ER=1
	;
	; Try to patch legacy error description syntax to get consistent display
	I (des["-")&($get(val)="") S val=$$vStrTrim($piece(des,"-",2,99),0," ") S des=$$vStrTrim($piece(des,"-",1),0," ")
	;
	I '($get(val)="") S des=des_": "_val
	I '($get(par)="") S des="Parameter: "_par_" - "_des
	;
	D writeln($C(10)_"%SQL-E-"_des)
	Q 
	;
portrait(hdg,isHTML,altbg,col,pars,IO,IOSL,IORM,rows)	;
	;
	N break N line N sqlcnt N PN
	N d N sqldta N sqlind
	;
	S break=0 S line=0 S PN=0
	;
	I '($get(pars("CAPTION"))="") D caption(pars("CAPTION"),"RS",isHTML) S line=(line+$L(pars("CAPTION"),$C(10)))
	;
	S sqlind=""
	F sqlcnt=1:1 D  I (vsql(0)=100) Q 
	.	;
	.	S vsql=$$^SQLF(.exe,.sqldta,.sqlind) I (vsql=0) S sqlcnt=(sqlcnt-1) Q 
	.	;
	.	I (sqlind[1) S sqldta=$$protect(sqldta,sqlind)
	.	I (isHTML=1) S sqldta=$$escape(sqldta) ; Process HTML escapes
	.	;
	.	S d=$$bldRow(sqldta,.col,isHTML,,0)
	.	D writeln($$wrtPort(d,hdg,isHTML,.pars,0,.line,altbg,.IOSL,IORM,.PN))
	.	I '(rows="") S rows=(rows-1) I (rows=0) S vsql(0)=100
	.	;
	.	Q 
	;
	D close(0,isHTML,IO,sqlcnt,0)
	;
	Q 
	;
wrtPort(rd,hdg,isHTML,pars,break,line,altbg,IOSL,IORM,PN)	; Output a row
	;
	N cellNum
	N page S page=""
	;
	N trOpen S trOpen="<tr>"
	N trClose S trClose="</tr>"
	;
	I altbg S trOpen="<tr class=d1>"
	;
	S rd=$piece(rd,"<tr>",2) ; remove tr from row data
	;
	S hdg=$$vStrRep(hdg,"<br>"," ",0,0,"")
	;set hdg = $$title(.pars(), isHTML, IORM, PN) _ hdg
	;
	F cellNum=1:1:$L(hdg,$C(10)) D
	.	;
	.	N rowh N rowd
	.	S rowh=$piece(hdg,$C(10),cellNum)
	.	I rowh="" Q 
	.	S rowd=$piece(rd,"<td>",cellNum+1)
	.	;
	.	S page=page_trOpen_rowh_"<td>"_rowd_"</td>"_trClose_$C(10)
	.	;
	.	Q 
	;
	Q page_"<tr><td><hr/></td><td><hr/></td></tr>"
	;
writeln(lineOfText)	; Concatenate line to outbuffer
	;
	S outputBuffer=outputBuffer_lineOfText
	Q 
	;
getClass(typ)	; Return the class that corresponds to type
	;
	Q $piece("text,currency,date,number,logical,time,frequency,memo,upper,blob",",",$F("T$DNLCFMUB",typ)-1)
	;
getType(class)	; Return the internal type associated with an external type
	;
	Q $E("TT$DNNLLCTMTB",$L($piece(",text,string,currency,date,number,integer,logical,boolean,time,frequency,memo,upper,blob,",","_class_",",1),","))
	;
getColAtts(class,gcol,input,tok)	; Build column record
	;
	N i
	;
	N classProps S classProps=$get(gcol(class))
	I (classProps="") S classProps=$get(gcol("."))
	;
	I (classProps="") Q input
	;
	F i=1:1:$L(classProps,$C(9)) S $piece(input,$C(9),i)=$$mergeProperties($piece(classProps,$C(9),i),$piece(input,$C(9),i),.tok)
	;
	Q input
	;
vSIG()	;
	Q "61024^48559^e0101711^72905" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ","abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vStrRep(object,p1,p2,p3,p4,qt)	; String.replace
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I p3<0 Q object
	I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
	;
	N y S y=0
	F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
	.	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
	.	S y=y+$L(p2)-$L(p1)
	.	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
	.	Q 
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vStrPce(object,p1,p2,p3,qt)	; String.piece
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(p3)#2) S p3=p2
	I '(object[qt)!(qt="") Q $piece(object,p1,p2,p3)
	;
	I $piece(object,p1,1,p2-1)[qt D  ; find real start
	.	N p N o S o=0
	.	F p=1:1:$L(object,p1) Q:p=(p2+o)  S o=($L($piece(object,p1,1,p),qt)#2=0)+o
	.	S p2=p2+o S p3=p3+o
	.	Q 
	I $piece(object,p1,p2,p3)[qt D  ; find real end
	.	N p N o
	.	F p=p2:1:$L(object,p1) S o=($L($piece(object,p1,p2,p),qt)#2=0) S p3=o+p3 Q:(p=p3)&'o 
	.	Q 
	Q $piece(object,p1,p2,p3)
	; ----------------
	;  #OPTION ResultClass 0
vStrFnd(object,p1,p2,p3,qt)	; String.find
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (p1="") Q $SELECT(p2<1:1,1:+p2)
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S p2=$F(object,p1,p2)
	I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
	.	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
	.	Q 
	Q p2
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="selectQuery.rs"
	N ER,vExpr,mode,RM,vTok S ER=0 ;=noOpti
	;
	S vExpr="SELECT "_vSelect_" FROM "_vFrom
	I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
	I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
	I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
	S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
	;
	S sqlcur=$O(vobj(""),-1)+1
	;
	I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
	E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)
	I ER S $ZS="-1,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT
	;
	S vos1=vsql
	Q ""
	;
vFetch0()	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S rs=vd
	S vos1=vsql
	S vos2=$G(vi)
	Q vsql
	;
vOpen1()	;	DI FROM DBTBL1D WHERE FID=:V1 AND DI BETWEEN 'D' AND 'E'
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL1a0
	S vos4="D"
	I $D(^DBTBL(vos3,1,vos2,9,vos4)),'(vos4]]"E") G vL1a7
vL1a6	S vos4=$O(^DBTBL(vos3,1,vos2,9,vos4),1) I vos4=""!(vos4]]"E") G vL1a3
vL1a7	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	; quit $ZS _ outputBuffer.get()
	Q 
	;
vtrap2	;	Error trap
	;
	N error S error=$ZS
	D ERROR($P(error,",",4))
	Q 
	;
vtrap3	;	Error trap
	;
	N error S error=$ZS
	S ER=1
	Q 
