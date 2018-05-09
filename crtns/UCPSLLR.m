UCPSLLR	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCPSLLR ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	Q 
	;
	;  #OPTION ResultClass ON
	;
	; ---------------------------------------------------------------------
stripCmt(code,inCmt,tsl)	;
	N nAll ; positions of all-remaining-comment
	N nBeg ; position of begin-block-comment
	N nEnd ; position of end-block-comment
	;
	I inCmt,code'["*/" Q "" ; no end-of-block on this line
	;
	I inCmt S code="/* "_code ; force comment state
	;
	I code["""" S code=$$TOKEN^%ZS(code,.tsl)
	;
	F  D  Q:'nBeg!'nEnd 
	.	S nAll=$F(code,"//")
	.	S nBeg=$F(code,"/*")
	.	S nEnd=$F(code,"*/",nBeg)
	.	;
	.	I 'nAll S nAll=$F(code,";") I nAll S nAll=nAll+1
	.	;
	.	I nAll>0,(nAll<nBeg)!(nBeg=0) S code=$E(code,1,nAll-3) S nBeg=0 Q 
	.	;
	.	I nBeg>0,nEnd>0 S code=$E(code,1,nBeg-3)_$E(code,nEnd,1048575)
	.	;
	.	E  I nBeg>0 S code=$E(code,1,nBeg-3)
	.	Q 
	;
	S inCmt=(nBeg>0) ; independent of nAll and nEnd
	Q $$vStrRep(code,$char(9)," ",0,0,"")
	;
	; ---------------------------------------------------------------------
getLblRec(src,rtn,valLvl,lblRec)	;
	N code S code="" ; source code line
	N cmdOpt ; command options
	N inCmt S inCmt=0 ; inside comment block?
	N lnr S lnr="" ; line itererator
	N postfix ; label postfix ("" or ^RTN)
	N tsl S tsl="" ; tokenized string literals
	;
	S cmdOpt("Options","ResultClass")=0
	;
	I (rtn="") S postfix=""
	E  S postfix="^"_rtn
	;
	F  S lnr=$order(src(lnr)) Q:lnr=""  D
	.	S code=code_$$stripCmt(src(lnr),.inCmt,.tsl)
	.	;
	.	I (code="") Q  ; nothing to deal with
	.	;
	.	I $E(code,1)'=" " D  ; found start of subroutine
	..		S tsl=""
	..		;
	..		D
	...			N voZT set voZT=$ZT
	...			N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	...			N lbl S lbl=$$fromSubrou($$getSrDec(.src,.lnr,.tsl),valLvl,cmdOpt("Options","ResultClass"))
	...			S lblRec($P(lbl,$C(9),4)_postfix)=lbl
	...			Q  ; end do-catch
	..		Q  ;end if code.extract()'=""
	.	E  I code["#OPTION",code["ResultClass" D decode^UCGMC(code,.cmdOpt)
	.	;
	.	S code="" S tsl=""
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
getSrDec(src,lptr,tok)	;
	N expr S expr="" ; return value
	N inCmt S inCmt=0
	N inFpl S inFpl=1
	N rec S rec="" ; line being decomposed
	;
	F  Q:'(inFpl)  D
	.	;
	.	S expr=expr_$$RTCHR^%ZFUNC($$stripCmt(src(lptr),.inCmt,.tok)," ")
	.	;
	.	I $L(expr,"(")'>$L(expr,")") S inFpl=0 Q 
	.	;
	.	I '($E(expr,$L(expr))=",") S $ZS="-1,"_$ZPOS_","_"%PSL-E-PARAMETER,Formal parameter declaration shall end with comma" X $ZT
	.	;
	.	I $L(expr)>1024 S $ZS="-1,"_$ZPOS_","_"%PSL-E-PARAMETER,Formal parameter list is too long" X $ZT
	.	I lptr="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-PARAMETER,incomplete formal parameter list" X $ZT
	.	;
	.	S lptr=$order(src(lptr))
	.	Q 
	;
	Q expr
	;
	; ---------------------------------------------------------------------
fromSubrou(expr,valLevel,bResCls)	;
	N ptr S ptr=0
	N atom S atom=$$ATOM^%ZS(expr,.ptr,"",,1)
	N acctyp S acctyp=$$vStrUC(atom)
	;type Number acclvl = -1
	N acclvl S acclvl=0
	;
	I acctyp="PUBLIC" S acclvl=2 S atom=$$ATOM^%ZS(expr,.ptr,"",,1)
	E  I acctyp="PRIVATE" S acclvl=1 S atom=$$ATOM^%ZS(expr,.ptr,"",,1)
	E  I acctyp="LOCAL" S acclvl=0 S atom=$$ATOM^%ZS(expr,.ptr,"",,1)
	;
	N cls S cls=""
	;
	N lbl S lbl=$piece(atom,"(")
	N fpl S fpl=""
	;
	;if acclvl > -1 do {
	I bResCls D
	.	I 'bResCls Q  ; not requested
	.	I lbl'=atom S cls="void" Q  ; lbl(... implies void
	.	I lbl="void"'!$$clsIsClass^UCGMR(lbl) Q 
	.	;
	.	S cls=lbl
	.	S atom=$$ATOM^%ZS(expr,.ptr,"",,1) S lbl=$piece(atom,"(")
	.	Q 
	;else  set acclvl = 0
	;
	I atom'=lbl D  ; has parameters
	.	S fpl=$E(atom,$L(lbl)+2,$L(atom)-1)
	.	I '(fpl="") S fpl=$$stdParms(fpl,valLevel)
	.	S fpl="("_fpl_")"
	.	Q 
	;
	N cmt S cmt=""
	S atom=$$ATOM^%ZS(expr,.ptr,"/;",,1)
	I atom="/",$E(expr,ptr)="/" S ptr=ptr+1 S atom=";"
	I atom=";" D
	.	S atom=$$vStrTrim($E(expr,ptr+1,1048575),0," ")
	.	I atom?1.ANP S cmt=atom
	.	Q 
	;
	Q ($char(9)_acclvl_$char(9)_cls_$char(9)_lbl_$char(9)_fpl_$char(9)_cmt)
	;
	; ---------------------------------------------------------------------
accessType(plr)	;
	Q $piece("local;private;public",";",$P(plr,$C(9),2)+1)
	;
	; ---------------------------------------------------------------------
getFp(plr,fp)	;
	N fpl S fpl=$P(plr,$C(9),5)
	I (fp=1)!(fp=$L(fpl,";")),$E(fpl,1)="(" S fpl=$E(fpl,2,$L(fpl)-1)
	Q $piece(fpl,";",fp)
	;
	; ---------------------------------------------------------------------
getFpAccess(plr,fp)	;
	Q $piece($$getFp(plr,fp)," ")
	;
	; ---------------------------------------------------------------------
getFpClass(plr,fp)	;
	Q $piece($$getFp(plr,fp)," ",2)
	;
	; ---------------------------------------------------------------------
getFpCount(plr)	;
	N fpl S fpl=$P(plr,$C(9),5)
	I (fpl="") Q -1
	I fpl="()" Q 0
	Q $L(fpl,";")
	;
	; ---------------------------------------------------------------------
getFpPosition(plr,sig)	;
	N fpl S fpl=$P(plr,$C(9),5)
	I (fpl="") Q 0
	I fpl="()" Q 0
	;
	N p1 S p1=0
	F  S p1=$F(fpl," "_sig,p1) Q:$E(fpl,p1)?1P  Q:p1=0 
	;
	I p1=0 Q 0 ; signature not found
	Q $L($E(fpl,1,p1-1),";")
	;
	; ---------------------------------------------------------------------
getFpVsig(plr,fp)	;
	Q $piece($$getFp(plr,fp)," ",3)
	;
	; ---------------------------------------------------------------------
setFormalList(plr,fpl,lvl)	;
	I (fpl="") S $P(plr,$C(9),5)=""
	E  S $P(plr,$C(9),5)="("_$$stdParms($E(fpl,2,$L(fpl)-1),lvl)_")"
	Q plr
	;
	; ---------------------------------------------------------------------
toM(plr)	;
	N code S code=$P(plr,$C(9),4)
	N fpl S fpl=$P(plr,$C(9),5)
	;
	I '(fpl="") D
	.	N fp
	.	S code=code_"(" S fpl=$E(fpl,2,$L(fpl)-1)
	.	F fp=1:1:$L(fpl,";") S code=code_$piece($piece($piece(fpl,";",fp)," ",3),"(")_","
	.	S code=$E(code,1,$L(code)-1)_")"
	.	Q 
	S code=code_" ; "_$P(plr,$C(9),6)
	Q code
	;
	; ---------------------------------------------------------------------
toPSL(plr)	;
	Q $$accessType(plr)_" "_$P(plr,$C(9),4)_$translate($P(plr,$C(9),5),";",",")_" // "_$P(plr,$C(9),6)
	;
	; ---------------------------------------------------------------------
stdParms(rec,validate)	;
	N std S std="" ; standardized return
	N par S par="" ; current parameter
	N x ; atom
	N mode S mode=0 ; syntax check mode
	N ptr S ptr=0
	;
	F  S x=$$ATOM^%ZS(rec,.ptr,",",,-1) D  Q:ptr=0 
	.	;
	.	I (x="") Q  ; trailing spaces
	.	I x'="," S mode=mode+1 S par=par_" "_$translate(x," ") Q:ptr>0 
	.	;
	.	I mode=0 S std=std_$char(9) Q  ; missing parameter
	.	I mode=1 S par=" public String"_par
	.	E  I mode=2 S par=" public"_par
	.	S par=$E(par,2,1048575)
	.	S par=$$stdParVl(par,validate)
	.	S x=$piece(par," ",4)
	.	S std=std_";"_par
	.	S mode=0 S par=""
	.	Q 
	;
	Q $E(std,2,1048575)
	;
	; ---------------------------------------------------------------------
stdParVl(x,md)	;
	N acc S acc=$$vStrLC($piece(x," "),0)
	N cls S cls=$piece(x," ",2)
	N par S par=$piece(x," ",3)
	;
	I md>0,'(",literal,local,private,public,"[(","_acc_",")) D ERROR^UCGM("unknown access type: "_acc)
	;
	I md>1 D
	.	I $E(par,1)="%",par'["(" D
	..		N kwds
	..		;
	..		N par2 S par2=$$getSysKwd^UCDTAUTL(par,.kwds)
	..		I (par2="") Q 
	..		;
	..		N gsc S gsc=$piece(kwds(par),"|",2)
	..		I gsc=-1 D ERROR^UCGM("SYSVAR: Assigning a value to a read-only system variable: "_par)
	..		I gsc=1 D warnGroup^UCGM("SYSVAR","Assigning system variable: "_par)
	..		;
	..		N cls2 S cls2=$piece(kwds(par),"|",3)
	..		I cls'=cls2 D warnGroup^UCGM("MISMATCH","Cannot overwrite system variable class "_cls2_" in declaration "_cls_" "_par)
	..		S par=par2 S cls=cls2
	..		Q 
	.	;
	.	I '$$isVar^UCGM($piece(par,"(")) D ERROR^UCGM("variable expected: "_par)
	.	I par["(",$translate(par,"%","A")'?1A.AN1"(".","1")" D ERROR^UCGM("invalid array declaration: "_par)
	.	Q 
	;
	I md>2,'$$clsIsClass^UCGMR(cls) D ERROR^UCGM("Undefined class: "_cls)
	;
	Q acc_" "_cls_" "_par
	;
vSIG()	;
	Q "60690^58589^Frans S.C. Witte^21946" ; Signature - LTD^TIME^USER^SIZE
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ")
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
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
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
	N lblEx S lblEx=$ZS
	I valLvl S $ZS=lblEx X voZT
	Q 
