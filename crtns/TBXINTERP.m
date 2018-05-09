TBXINTERP	;
	;
	; **** Routine compiled from DATA-QWIK Procedure TBXINTERP ****
	;
	; 01/25/2008 16:21 - pip
	;
	;
	Q 
	;
PSL(vinput,voutput,vmsrc,vcmperr)	;
	;
	N vstart ; Sart time of code execution, set below
	N vopts ; Shell options
	S vopts(0)=1 ; Language is PSL(1) or M(0) or SQLm(2) [default PSL]
	S vopts(1)=0 ; Return M source code [default False]
	;
	; Open a local file as a write buffer to accept the M WRITE output
	N vwrfile S vwrfile="zpslwr"_$J
	OPEN vwrfile:newv
	USE vwrfile
	;
	; Call SHELL if ZSHELL switch detected
	N vn S vn=""
	F  S vn=$order(vinput(vn)) Q:(vn="")  D
	.	I $$vStrUC($piece(vinput(vn)," ",1))="ZSHELL" D SHELL(.vinput,.vn,.voutput,.vopts,vwrfile) S vinput(vn)=" ; "_vinput(vn) Q 
	.	Q 
	;
	S vn=""
	N isDone S isDone=0
	;
	; SQL
	I vopts(0)=2 S isDone=1
	;
	F  S vn=$order(vinput(vn),-1) Q:(vn="")  I isDone=0 D
	.	;
	.	; Make sure the code ends with a quit, if not, add one
	.	I $$vStrTrim($$vStrRep(vinput(vn),$char(9)," ",0,0,""),0," ")="" Q 
	.	I ($E($$vStrUC($$vStrTrim($$vStrRep(vinput(vn),$char(9)," ",0,0,""),0," ")),1)="Q") S isDone=1 Q 
	.	E  S isDone=1 S vinput(vn+1)=" quit"
	.	Q 
	;
	; Call the PSL code generation utility
	I (vopts(0)=1) D main^UCGM(.vinput,.vmsrc,,,,,.vcmperr)
	;
	; if shell command switches mode to GTM, copy input to source array
	I (vopts(0)=0) F  S vn=$order(vinput(vn)) Q:(vn="")  S vmsrc(vn)=vinput(vn)
	;
	; If there were compile errors quit
	I $$hasErrors(.vcmperr) Q 
	;
	N isTemp S isTemp=0
	F  S vn=$order(vmsrc(vn)) Q:(vn="")  Q:isTemp=1  D
	.	; Find first non-whitespace character, if it's the first
	.	; character or a '.', must generate a temporary procedure
	.	; or a scope command 'new,quit'
	.	;
	.	N i
	.	F i=1:1:$L(vmsrc(vn)) Q:'($C(9,32)[$E(vmsrc(vn),i)) 
	.	; If it's a Linelabel or New or Quit command or '.' block - Build temporary program
	.	I ((i=1)!("NnQq."[$E(vmsrc(vn),i))) S isTemp=1 Q 
	.	Q 
	;
	; Execute the code, first compile if it contains local subroutines
	; **FRS - Need to deal with local variables, clean up scope
	;
	; Capture execution error and return (use existing compiler error array)
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	; Compile and call temporary program
	I isTemp=1 D
	.	;
	.	N outfile S outfile="zpsl"_$J
	.	D ^%ZRTNCMP(outfile,"vmsrc")
	.	USE vwrfile
	.	S vstart=$$GETTIM^%ZFUNC
	.	XECUTE "do ^"_outfile
	.	Q 
	;
	; xecute the M source code (remove leading space)
	E  D
	.	S vn=""
	.	USE vwrfile
	.	S vstart=$$GETTIM^%ZFUNC
	.	F  S vn=$order(vmsrc(vn)) Q:(vn="")  XECUTE $E(vmsrc(vn),2,9999)
	.	Q 
	;
	; Return execution time in microseconds
	S voutput(1)="%PSL-Runtime: "_(($$GETTIM^%ZFUNC-vstart)/1000000)_" Seconds"
	;
	D copyOut(vwrfile,.voutput) ; Copy Write buffer to output
	I vopts(1)=0 K vmsrc ; Don't return M code (delete it)
	Q 
	;
copyOut(vwrfile,voutput)	; Copy file into output buffer to return to client
	;
	N x
	N n
	;
	CLOSE vwrfile OPEN vwrfile:read USE vwrfile
	F n=2:1 Q:$ZEOF  READ x S voutput(n)=x
	CLOSE vwrfile
	;
	Q 
	;
hasErrors(vcmperr)	;
	;
	; No warnings or errors
	I ($order(vcmperr(""))="") Q 0
	;
	N hasErrors S hasErrors=0
	;
	N i S i=""
	F  S i=$order(vcmperr(i)) Q:hasErrors=1  Q:i'=""  D
	.	I ($E(vcmperr(i),1,5)="PSL-E") S hasErrors=1
	.	Q 
	Q hasErrors
	;
SHELL(vinput,vn,voutput,vopts,vwrfile)	; Process shell script
	;
	N x S x=$$vStrUC($$vStrTrim($E(vinput(vn),8,9999),0," "))
	;
	I (",M,MUMPS,"[(","_x_",")) S vopts(0)=0 Q 
	I x="SHOW CODE" S vopts(1)=1 Q 
	;
	I $piece($$vStrTrim(x,0," ")," ",1)'="SELECT" Q 
	;
	S vopts(0)=2
	USE vwrfile
	WRITE $$SELECT^MRPC155($$vStrTrim($E(vinput(vn),8,9999),0," "))
	;
	Q 
	;
SQL(vinput,voutput)	;
	;
	N vstart ; Sart time of code execution, set below
	N expr S expr=""
	;
	N vn S vn=""
	F  S vn=$order(vinput(vn)) Q:(vn="")  S expr=expr_" "_vinput(vn)
	;
	S vstart=$$GETTIM^%ZFUNC
	S voutput(2)=$$SELECT^MRPC155(expr)
	; Return execution time in microseconds
	S voutput(1)="%SQL-Runtime: "_(($$GETTIM^%ZFUNC-vstart)/1000000)_" Seconds"
	;
	Q 
	;
vSIG()	;
	Q "61003^41614^e0101711^6169" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
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
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
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
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	D copyOut(vwrfile,.voutput)
	;
	S voutput=$order(voutput(""))+1
	S voutput(voutput)=$ZS
	Q 
