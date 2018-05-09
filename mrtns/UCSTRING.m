	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCSTRING ****
	;
	; 09/10/2007 17:31 - chenardp
	;
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
	; ---------------------------------------------------------------------
blank	; Method: String.blank(Number fieldLength, Boolean rightJustify)
	;
	D WARNDEP^UCGM("String.blank() - use String.justify()")
	;
	I (actual(2)="") S actual(2)=-1 ; Default left justify
	;
	N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"Number")
	N ap2 S ap2=$$tokenPush^UCPATCH(actual(2),"Boolean")
	;
	S return=$$tokenPush^UCPATCH(objectName,"String")_".justify("_ap1_","_ap2_",,1).extract(1,"_ap1_")"
	S return=$$tokenPop^UCPATCH($$vMExpr(return),3)
	Q 
	;
	; ---------------------------------------------------------------------
contains	; method: String.contains(String string)
	;
	I (actual(1)="") S actual(1)=""""""
	;
	I actual(1)="""""" S return="1" Q 
	;
	I $$isSimple^UCGM(actual(1)) S return="("_objectName_"["_actual(1)_")"
	E  S return="("_objectName_"[("_actual(1)_")"_")"
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	Q 
	;
	; ---------------------------------------------------------------------
follows	; method: String.follows(String string)
	;
	I (actual(1)="") S actual(1)=""""""
	;
	I $$isSimple^UCGM(actual(1)) S return="("_objectName_"]"_actual(1)_")"
	E  S return="("_objectName_"]("_actual(1)_")"_")"
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	Q 
	;
	; ---------------------------------------------------------------------
extract	; method: String.extract(Number start,Number end)
	; returns a sub-string of a given string
	;
	I (actual(1)="") S actual(1)=1 ; Default to position 1
	I (actual(2)="") S actual(2)=actual(1) ; Default to 1st parameter
	;
	; Optimize this syntax by replacing with the maximum string length
	E  I actual(2)=("$L("_objectName_")") S actual(2)=1048575
	;
	I actual(1)=actual(2) S return="$E("_objectName_","_actual(1)_")"
	E  S return="$E("_objectName_","_actual(1)_","_actual(2)_")"
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
piece	; method: String.piece(String delimiter,Number start,Number end,String quoteChar)
	; Returns a sub-string of a given string
	;
	I (""""""[actual(4)) D psl2m^UCPRIM(1,3) Q  ; standard M
	;
	I fset D ERROR^UCGM("Assignment function is not supported") Q 
	;
	I (""""""[actual(2)) S actual(2)=1
	I $$isLit^UCGM(actual(2)),(""""""[actual(3)) S actual(3)=actual(2)
	;
	; Optimize this syntax by replacing with the maximum string length
	I actual(3)=("$L("_objectName_")") S actual(3)=1048575
	;
	I '$D(labels("vStrPce")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object,String p1,Number p2,Number p3,String qt)","String.piece")
	.	;
	.	D vaddBuff(buf,"if 'p3.exists() set p3=p2")
	.	D vaddBuff(buf,"if '(object[qt)!qt.isNull() quit object.piece(p1,p2,p3)")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if object.piece(p1,1,p2-1)[qt do { // find real start")
	.	D vaddBuff(buf," type Number p,o=0")
	.	D vaddBuff(buf," for p=1:1:object.length(p1) quit:p=(p2+o)  s o=(object.piece(p1,1,p).length(qt)#2=0)+o")
	.	D vaddBuff(buf," set p2=p2+o,p3=p3+o")
	.	D vaddBuff(buf,"}")
	.	;do buf.add("if object.piece(p1,1,p2-1).length(qt)#2=0 do {")
	.	;do buf.add(" for p2=p2+1:1:object.length() set p3=p3+1 if object.piece(p1,1,p2-1).length(qt)#2 quit")
	.	;do buf.add("}")
	.	D vaddBuff(buf,"if object.piece(p1,p2,p3)[qt do { // find real end")
	.	D vaddBuff(buf," type Number p,o")
	.	D vaddBuff(buf," for p=p2:1:object.length(p1) set o=(object.piece(p1,p2,p).length(qt)#2=0),p3=o+p3 quit:(p=p3)&'o")
	.	;do buf.add(" set p3=p3-1")
	.	;do buf.add(" for p3=p3+1:1:object.length() if object.piece(p1,p2,p3).length(qt)#2=0 quit")
	.	D vaddBuff(buf,"}")
	.	D vaddBuff(buf,"quit object.piece(p1,p2,p3)")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrPce","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vStrPce"_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
justify	; Method: String.justify(Number fieldLength,Number option,String padCharacter,Boolean truncate)
	;
	I (""""""[actual(1)) S return=objectName Q 
	;
	I (""""""[actual(2)) S actual(2)=1 ; Default RightJustify
	I (""""""[actual(3)) S actual(3)=""" """ ; Default spacePad
	E  I actual(3)="$C(32)" S actual(3)=""" """
	I (""""""[actual(4)) S actual(4)=0 ; Default noTruncate
	;
	N obj S obj=$$tokenPush^UCPATCH(objectName,"String")
	N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"Number")
	N ap2 S ap2=$$tokenPush^UCPATCH(actual(2),"Number")
	N ap3 S ap3=$$tokenPush^UCPATCH(actual(3),"String")
	N ap4 S ap4=$$tokenPush^UCPATCH(actual(4),"Boolean")
	;
	N code S code="$J("""","_ap1_"-"_objectName_".length())"
	I ap3'=""" """ S code=code_".translate("" "","_ap3_")"
	;
	I $$isLit^UCGM(ap2) D  ; justification is known
	.	;
	.	N option S option=$$QSUB^%ZS(ap2,"""")
	.	;
	.	I option<0 S code=objectName_"_"_code
	.	E  I option=0 S code="$$CJ^%ZTEXT("_objectName_","_ap1_")"
	.	E  D
	..		I ap3=""" """ S code="$J("_objectName_","_ap1_")"
	..		E  S code=code_"_"_objectName
	..		Q 
	.	;
	.	Q 
	;
	E  S code="$S("_ap2_">0:"_code_"_"_objectName_","_ap2_"<0:"_objectName_"_"_code_",1:$$CJ^%ZTEXT("_objectName_"))"
	;
	I '$$isLit^UCGM(ap4) S code="$S("_ap4_":("_code_").extract(1,"_ap1_"),1:"_code_")"
	E  I $$QSUB^%ZS(ap4,"""") S code="("_code_").extract(1,"_ap1_")"
	;
	S return=$$tokenPop^UCPATCH($$vMExpr(code),5)
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
insert	; method: String.insert(String string,Number offSet,String padCharacter,Boolean displace)
	;
	I (""""""[actual(2)) S actual(2)=1 ; Default insert position
	I (""""""[actual(3)) S actual(3)=""" """ ; Default spacePad
	I (""""""[actual(4)) S actual(4)=0 ; Default overstrike
	;
	; if inserting in position one, optimize into simple expression
	I $$QSUB^%ZS(actual(2),"""")=1,$$isLit^UCGM(actual(4)) D  Q 
	.	;
	.	I $$QSUB^%ZS(actual(4),"""") S return=actual(1)_"_"_objectName
	.	E  D
	..		N obj S obj=$$tokenPush^UCPATCH(objectName,"String")
	..		N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"String")
	..		S return=$$tokenPop^UCPATCH($$vMExpr(ap1_"_"_obj_".extract("_ap1_".length()+1,"_obj_".length())"),2)
	..		Q 
	.	;
	.	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	.	Q 
	;
	; Optimize when literal string length is less than the insert position
	I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(2)),$$QSUB^%ZS(actual(2),"""")>$L($$QSUB^%ZS(objectName,"""")) D  Q 
	.	;
	.	N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"String")
	.	N ap3 S ap3=$$tokenPush^UCPATCH(actual(1),"String")
	.	;
	.	S return=objectName_"_"""".justify("_actual(2)_"+1-"_$L(objectName)_")"
	.	I ap3'=""" """ S return=return_".translate("" "","_ap3_")"
	.	S return=return_"_"_ap1
	.	S return=$$tokenPop^UCPATCH($$vMExpr(return),2)
	.	S return=$$toLit(return)
	.	Q 
	;
	N label S label="vStrIns"
	;
	I '$D(labels("vStrIns")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object,String p1,Number p2,String p3,Boolean p4)","String.insert")
	.	;
	.	D vaddBuff(buf,"set p2=p2-1")
	.	D vaddBuff(buf,"if object.length()<p2 set object=object_$S(p3="" "":"""".justify(p2-object.length()),1:"""".justify(p2-object.length()).translate("" "",p3))")
	.	D vaddBuff(buf,"quit object.extract(1,p2)_p1_object.extract($S(p4:0,1:p1.length())+p2+1,object.length()))")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrIns","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
find	; Method: String.find(String string,Number start,Boolean ignoreCase,String quoteChar)
	; Find an expression within a string
	;
	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	I (actual(3)="") S actual(3)=$$QADD^%ZS(actual(3),"""")
	I (actual(4)="") S actual(4)=$$QADD^%ZS(actual(4),"""")
	;
	I (""""""[actual(3)),(""""""[actual(4)) D  Q 
	.	;
	.	I (""""""[actual(2)) S return="$F("_objectName_","_actual(1)_")"
	.	E  S return="$F("_objectName_","_actual(1)_","_actual(2)_")"
	.	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	.	Q 
	;
	; Special case: "find the empty string" always returns 1
	I (""""""[actual(1)),(""""""[actual(2)) D  Q 
	.	N pos S pos=+$$QSUB^%ZS(actual(2),"""")
	.	I pos<1 S return=1
	.	E  S return=+actual(2)
	.	Q 
	;
	N label S label="vStrFnd"
	;
	I '$D(labels("vStrFnd")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object,String p1,Number p2,Boolean p3,String qt)","String.find")
	.	;
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if p1.isNull() quit $select(p2<1:1,1:+p2)")
	.	D vaddBuff(buf,"if p3 set object=object.upperCase(),p1=p1.upperCase()")
	.	D vaddBuff(buf,"set p2=object.find(p1,p2)")
	.	D vaddBuff(buf,"if 'qt.isNull(),object.extract(1,p2-1).length(qt)#2=0 do {")
	.	D vaddBuff(buf," for  set p2=object.find(p1,p2) quit:p2=0!(object.extract(1,p2-1).length(qt)#2)")
	.	D vaddBuff(buf,"}")
	.	D vaddBuff(buf,"quit p2")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrFnd","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
replace	; Method: String.replace(String expr1,String expr2,Number count,Boolean ignoreCase,String quoteChar)
	;
	I (""""""[actual(1)) S return=objectName Q 
	;
	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	I (""""""[actual(3)) S actual(3)=0 ; default: all occurrences
	I (""""""[actual(4)) S actual(4)=0 ; default: not ignore case
	I (actual(5)="") S actual(5)=$$QADD^%ZS(actual(5),"""")
	;
	; If parameters are identical - exit
	I actual(1)=actual(2) S return=objectName Q 
	;
	N count S count=$$toVal^UCPRIM(actual(3),1)
	;
	I count<0 S return=objectName Q 
	;
	N ignCase S ignCase=$$toVal^UCPRIM(actual(4),1)
	;
	N len1 S len1="" N len2 S len2=2
	I $$isLit^UCGM(actual(1)) S len1=$L($$QSUB^%ZS(actual(1),""""))
	E  I actual(1)?1"$C("1.N1")" S len1=1 ; $C(ascii)
	;
	I $$isLit^UCGM(actual(2)) S len2=$L($$QSUB^%ZS(actual(2),""""))
	E  I actual(2)?1"$C("1.N1")" S len2=1 ; $C(ascii)
	;
	I len1=1,len2<2,count=0,'ignCase,(""""""[actual(5)) D  Q 
	.	N obj S obj=$$tokenPush^UCPATCH(objectName,"String")
	.	N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"String")
	.	N ap2 S ap2=$$tokenPush^UCPATCH(actual(2),"String")
	.	;
	.	S return=obj_".translate("_ap1_","_ap2_")"
	.	S return=$$tokenPop^UCPATCH($$vMExpr(return),3)
	.	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	.	Q 
	;
	N label S label="vStrRep"
	;
	I '$D(labels("vStrRep")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object,String p1,String p2,Number p3,Boolean p4,String qt)","String.replace")
	.	;
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if p3<0 quit object")
	.	D vaddBuff(buf,"if p1.length()=1,p2.length()<2,'p3,'p4,qt.isNull() quit object.translate(p1,p2)")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"type Number y=0")
	.	D vaddBuff(buf,"for  set y=object.find(p1,y,p4,qt) quit:y=0  do {")
	.	D vaddBuff(buf," set object=object.extract(1,y-p1.length()-1)_p2_object.extract(y,object.length())")
	.	D vaddBuff(buf," set y=y+p2.length()-p1.length()")
	.	D vaddBuff(buf," if p3 set p3=p3-1 if p3=0 set y=object.length()+1")
	.	D vaddBuff(buf,"}")
	.	D vaddBuff(buf,"quit object")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrRep","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_","_actual(5)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
toLit(expr)	; Execute an expression and return a literal
	;
	N i
	N result
	;
	F i=1:1 Q:'($D(actual(i))#2)  I '((""""""[actual(i))!$$isLit^UCGM(actual(i))) Q 
	I ($D(actual(i))#2) Q expr
	;  #ACCEPT PGM=spier;date=12/8/03;CR=unknown;GROUP=XECUTE
	XECUTE "S result="_expr
	;
	I result'=+result S result=$S(result'["""":""""_result_"""",1:$$QADD^%ZS(result,""""))
	I $L(result)>511 S result=expr
	Q result
	;
	; ---------------------------------------------------------------------
unpack	; Method: String.unpack - returns unpack data based on position
	;
	I (""""""[actual(1)) D ERROR^UCGM("Length required") Q 
	;
	S return="$$UNPACK^%ZFUNC("_objectName_","_actual(1)_")"
	;
	I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
unpack2	; Method String.complexUnpack - returns unpack complex data
	;
	I (""""""[actual(1)) D ERROR^UCGM("Length required")
	I actual(2)>1!(actual(2)<0) D ERROR^UCGM($$^MSG(7609))
	I (""""""[actual(2)) D ERROR^UCGM("Signed indicator required")
	I (""""""[actual(3)) D ERROR^UCGM("Left nibble position required")
	;
	S return="$$UNPACK2^%ZFUNC("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
	Q 
	;
	; ---------------------------------------------------------------------
zero	; Method String.zero(Number length,Number decimal,Boolean implied,Boolean sign)
	; Return zero fill.  Save here for legacy support
	;
	D zero^UCNUMBER Q 
	;
	; ---------------------------------------------------------------------
getSub	; Method: String.getSub(String tag,String MajorDelim,String SubDelim,Number position)
	;
	S return=$$GETSUB(actual(1),actual(2),actual(3),actual(4),objectName,0)
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
GETSUB(tag,sfd1,sfd2,sfp,var,bSubfld)	;
	I (sfd1="") S sfd1=$S(sfd1'["""":""""_sfd1_"""",1:$$QADD^%ZS(sfd1,""""))
	I (sfd2="") S sfd2=$S(sfd2'["""":""""_sfd2_"""",1:$$QADD^%ZS(sfd2,""""))
	I (""""""[sfp) S sfp=1 ; default value = 1
	;
	; case 1) label and majorDelim both empty
	I (""""""[tag),(""""""[sfd1) Q $$vMExpr(var_".extract("_sfp_")")
	;
	; if parameters passed in DQ subfield format, then add code for $CHAR()
	N prefix N postfix
	;
	I bSubfld S prefix="$CHAR(" S postfix=")"
	E  S prefix="" S postfix=""
	;
	; case 2) label empty
	I (""""""[tag) Q $$vMExpr(var_".piece("_prefix_sfd1_postfix_","_sfp_")")
	;
	; remaining code handles case 3 or defers to runtime
	N bMajor S bMajor=$$isLit^UCGM(sfd1)
	I bMajor,(""""""[sfd2) S sfd2=sfd1
	;
	N bSub S bSub=$$isLit^UCGM(sfd2)
	;
	; If all parameters are literal, then the last runtime check can be done
	; here, and if OK, the M code can be returned directly
	; Note that the indvidual components may be optimized by .piece()
	N expr
	I bMajor,bSub,$$isLit^UCGM((sfp)) D  Q $$vMExpr(expr)
	.	I 'bSubfld D
	..		I $L($$QSUB^%ZS(sfd1,""""))>1 D ERROR^UCGM("String.getSub delimiter shall be single character")
	..		I $L($$QSUB^%ZS(sfd2,""""))>1 D ERROR^UCGM("String.getSub delimiter shall be single character")
	..		Q 
	.	I sfp>1,sfd1=sfd2 D ERROR^UCGM("String.getSub position shall be 1")
	.	S sfd1=prefix_sfd1_postfix
	.	S sfd2=prefix_sfd2_postfix
	.	S expr="("_sfd1_"_"_var_").piece("_sfd1_"_"_tag_"_"_sfd2_",2)"
	.	S expr=expr_".piece("_sfd1_",1).piece("_sfd2_","_sfp_")"
	.	Q 
	;
	; At least one parameter value is not literal. All checking must be
	; postponed until runtime. Generate a function that does the checking
	; and returns the runtime value. The name and generated code depend on
	; the value of bSubfld
	N label
	I bSubfld D
	.	S label="vStrGSub"
	.	;
	.	I '$D(labels("vStrGSub")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String tag,Number del1,Number del2,Number pos)","String.getSub passing Numbers")
	..		;
	..		D vaddBuff(buf,"if pos.isNull() set pos=1")
	..		D vaddBuff(buf,"if tag.isNull(),del1.isNull() quit object.extract(pos)")
	..		D vaddBuff(buf,"set del1 = $CHAR(del1)")
	..		D vaddBuff(buf,"if tag.isNull() quit object.piece(del1,pos)")
	..		D vaddBuff(buf,"set del2 = $CHAR(del2)")
	..		D vaddBuff(buf,"if del1=del2,pos>1 throw Class.new(""Error"",""%PSL-E-STRGETSUB"")")
	..		D vaddBuff(buf,"quit (del1_object).piece(del1_tag_del2,2).piece(del1,1).piece(del2,pos)")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrGSub","")
	..		K vobj(+$G(buf)) Q 
	.	Q 
	E  D
	.	S label="vStrGSUB"
	.	;
	.	I '$D(labels("vStrGSUB")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String tag,String del1,String del2,Number pos)","String.getSub passing Strings")
	..		;
	..		D vaddBuff(buf,"if pos.isNull() set pos=1")
	..		D vaddBuff(buf,"if tag.isNull(),del1.isNull() quit object.extract(pos)")
	..		D vaddBuff(buf,"if del1.length()>1 throw Class.new(""Error"",""%PSL-E-STRGETSUB"")")
	..		D vaddBuff(buf,"if tag.isNull() quit object.piece(del1,pos)")
	..		D vaddBuff(buf,"if del2.isNull() set del2 = del1")
	..		D vaddBuff(buf,"if del2.length()>1 throw Class.new(""Error"",""%PSL-E-STRGETSUB"")")
	..		D vaddBuff(buf,"if del1=del2,pos>1 throw Class.new(""Error"",""%PSL-E-STRGETSUB"")")
	..		D vaddBuff(buf,"quit (del1_object).piece(del1_tag_del2,2).piece(del1,1).piece(del2,pos)")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrGSUB","")
	..		K vobj(+$G(buf)) Q 
	.	Q 
	;
	Q "$$"_label_"("_var_","_tag_","_sfd1_","_sfd2_","_sfp_")"
	;
	; ---------------------------------------------------------------------
putSub	; Method: String.putSub(String insert,String tag,String majorDelim,String subDelim,Number position)
	;
	S return=$$PUTSUB(actual(1),actual(2),actual(3),actual(4),actual(5),objectName,0)
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
PUTSUB(ins,tag,sfd1,sfd2,sfp,var,bSubfld)	;
	;
	I (ins="") S ins=$S(ins'["""":""""_ins_"""",1:$$QADD^%ZS(ins,""""))
	I (tag="") S tag=$S(tag'["""":""""_tag_"""",1:$$QADD^%ZS(tag,""""))
	I (sfd1="") S sfd1=$S(sfd1'["""":""""_sfd1_"""",1:$$QADD^%ZS(sfd1,""""))
	I (sfd2="") S sfd2=$S(sfd2'["""":""""_sfd2_"""",1:$$QADD^%ZS(sfd2,""""))
	I (""""""[sfp) S sfp=1
	;
	; perform as much compile time checking as possible
	I '(""""""[tag) D
	.	N bMajor S bMajor=$$isLit^UCGM(sfd1)
	.	I bMajor,(""""""[sfd2) S sfd2=sfd1
	.	;
	.	N bSub S bSub=$$isLit^UCGM(sfd2)&bMajor
	.	;
	.	I bMajor,bSub,$$isLit^UCGM((sfp)) D
	..		I 'bSubfld D
	...			I $L($$QSUB^%ZS(sfd1,""""))>1 D ERROR^UCGM("String.getSub delimiter shall be single character")
	...			I $L($$QSUB^%ZS(sfd2,""""))>1 D ERROR^UCGM("String.getSub delimiter shall be single character")
	...			Q 
	..		I sfd1=sfd2,sfp>1 D ERROR^UCGM("String.getSub position shall be 1")
	..		Q 
	.	Q 
	;
	; name and generated code depend on bSubfld
	N label
	I bSubfld D
	.	S label="vStrPSub"
	.	;
	.	I '$D(labels("vStrPSub")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String ins,String tag,Number del1,Number del2,Number pos)","String.putSub passing Numbers")
	..		;
	..		D vaddBuff(buf,"if pos.isNull() set pos=1")
	..		D vaddBuff(buf,"if tag.isNull(),del1.isNull() set object.extract(pos) = ins quit object")
	..		D vaddBuff(buf,"set del1 = $CHAR(del1)")
	..		D vaddBuff(buf,"if tag.isNull() set object.piece(del1,pos) = ins quit object.trim(1,del1)")
	..		D vaddBuff(buf,"set del2 = $CHAR(del2)")
	..		D vaddBuff(buf,"if del1 = del2, pos > 1 throw Class.new(""Error"", ""%PSL-E-STRPUTSUB"")")
	..		D vaddBuff(buf,"if object.isNull() set object.piece(del2,pos) = ins quit tag_del2_object")
	..		D vaddBuff(buf,"type String field = (del1_object).piece((del1_tag_del2),2).piece(del1,1)")
	..		D vaddBuff(buf,"if 'field.isNull() do {") ; code to remove "old" value
	..		D vaddBuff(buf,"  type String z = del1_tag_del2_field")
	..		D vaddBuff(buf,"  set object = (del1_object).piece(z,1)_(del1_object).piece(z,2)")
	..		D vaddBuff(buf,"  if object.extract() = del1 set object = object.extract(2,object.length())")
	..		D vaddBuff(buf,"}")
	..		D vaddBuff(buf,"set field.piece(del2,pos) = ins")
	..		D vaddBuff(buf,"if object.isNull() quit tag_del2_field")
	..		D vaddBuff(buf,"quit object_del1_tag_del2_field")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrPSub","")
	..		K vobj(+$G(buf)) Q 
	.	Q 
	E  D
	.	S label="vStrPSUB"
	.	;
	.	I '$D(labels("vStrPSUB")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String ins,String tag,String del1,String del2,Number pos)","String.putSub passing Strings")
	..		;
	..		D vaddBuff(buf,"if pos.isNull() set pos=1")
	..		D vaddBuff(buf,"if tag.isNull(),del1.isNull() set object.extract(pos) = ins quit object")
	..		D vaddBuff(buf,"if del1.length()>1 throw Class.new(""Error"", ""%PSL-E-STRPUTSUB"")")
	..		D vaddBuff(buf,"if tag.isNull() set object.piece(del1,pos) = ins quit object.trim(1,del1)")
	..		D vaddBuff(buf,"if del2.isNull() set del2 = del1")
	..		D vaddBuff(buf,"if del2.length()>1 throw Class.new(""Error"", ""%PSL-E-STRPUTSUB"")")
	..		D vaddBuff(buf,"if del1 = del2, pos > 1 throw Class.new(""Error"", ""%PSL-E-STRPUTSUB"")")
	..		D vaddBuff(buf,"if object.isNull() set object.piece(del2,pos) = ins quit tag_del2_object")
	..		D vaddBuff(buf,"type String field = (del1_object).piece((del1_tag_del2),2).piece(del1,1)")
	..		D vaddBuff(buf,"if 'field.isNull() do {") ; code to remove "old" value
	..		D vaddBuff(buf,"  type String z = del1_tag_del2_field")
	..		D vaddBuff(buf,"  set object = (del1_object).piece(z,1)_(del1_object).piece(z,2)")
	..		D vaddBuff(buf,"  if object.extract() = del1 set object = object.extract(2,object.length())")
	..		D vaddBuff(buf,"}")
	..		D vaddBuff(buf,"set field.piece(del2,pos) = ins")
	..		D vaddBuff(buf,"if object.isNull() quit tag_del2_field")
	..		D vaddBuff(buf,"quit object_del1_tag_del2_field")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrPSUB","")
	..		K vobj(+$G(buf)) Q 
	.	Q 
	;
	Q "$$"_label_"("_var_","_ins_","_tag_","_sfd1_","_sfd2_","_sfp_")"
	;
	; ---------------------------------------------------------------------
loCase	; Method: String.lowerCase(Boolean capitalizeFirstChar)
	;
	N option S option=actual(1)
	I (""""""[option) S option=0 ; Default to 0
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(option) S return=$$vStrLC(objectName,option) Q 
	;
	I '$D(labels("vStrLC")) D
	.	;
	.	N uc S uc=$$QADD^%ZS($$UC^%CHARSET(),"""")
	.	N lc S lc=$$QADD^%ZS($$LC^%CHARSET(),"""")
	.	N buf S buf=$$vopenBuf("(String vObj,Boolean v1)","String.lowerCase")
	.	;
	.	D vaddBuff(buf,"set vObj=vObj.translate("_uc_","_lc_")")
	.	D vaddBuff(buf,"if v1 set vObj=vObj.extract().upperCase()_vObj.extract(2,vObj.length())")
	.	D vaddBuff(buf,"quit vObj")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrLC","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vStrLC"_"("_objectName_","_option_")"
	Q 
	;
	; ---------------------------------------------------------------------
upCase	; Method: String.upCase  Returns an upper case string
	;
	I $$isLit^UCGM(objectName) S return=$$vStrUC(objectName) Q 
	;
	I '$D(labels("vStrUC")) D
	.	;
	.	N uc S uc=$$QADD^%ZS($$UC^%CHARSET,"""")
	.	N lc S lc=$$QADD^%ZS($$LC^%CHARSET,"""")
	.	N buf S buf=$$vopenBuf("(String vObj)","String.upperCase")
	.	;
	.	D vaddBuff(buf,"quit vObj.translate("_lc_","_uc_")")
	.	D INSERT^UCMETHOD(buf,"vStrUC","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vStrUC"_"("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
trim	; Method: String.trim(Number Option, String character)
	; Trims white space from a string
	;
	I (""""""[actual(1)) S actual(1)=0 ; Trim both sides
	I (""""""[actual(2)) S actual(2)=""" """
	;
	I $$isLit^UCGM(actual(1)),$$QSUB^%ZS(actual(1),"""")=1 D  Q 
	.	;
	.	S return="$$RTCHR^%ZFUNC("_objectName_","_actual(2)_")"
	.	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	.	Q 
	;
	N label S label="vStrTrim"
	;
	I '$D(labels("vStrTrim")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object, Number p1, String p2)","String.trim")
	.	;
	.	D vaddBuff(buf,"if p1'<0 set object=object.trim(1,p2)")
	.	D vaddBuff(buf,"if p1'>0 for  quit:object.extract()'=p2  set object=object.extract(2,object.length())")
	.	D vaddBuff(buf,"quit object")
	.	D INSERT^UCMETHOD(buf,"vStrTrim","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
isBegin	; Method: String.beginsWith(String string,Boolean ignoreCase)
	;
	;if actual(1).isNull(1) set PSL.return="("_PSL.objectName_"="""")" quit
	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	;
	I '$$isLit^UCGM(actual(2)) D  Q 
	.	;
	.	N label S label="vStrBeg"
	.	;
	.	I '$D(labels("vStrBeg")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String p1,Boolean p2)","String.beginsWith")
	..		;
	..		D vaddBuff(buf,"if p2 set object=object.upperCase(),p1=p1.upperCase()")
	..		D vaddBuff(buf,"quit object.beginsWith(p1)")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrBeg","")
	..		K vobj(+$G(buf)) Q 
	.	;
	.	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	.	Q 
	;
	; actual(2) is literal
	N isIgnore S isIgnore=$$QSUB^%ZS(actual(2),"""")
	;
	S return=$$tokenPush^UCPATCH(objectName,"String")
	N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"String")
	;
	I isIgnore S return=return_".upperCase()"
	;
	I '($$isLit^UCGM(actual(1))!$$isVar^UCGM(actual(1))) S ap1="("_ap1_")"
	;
	S return="("_return_".extract(1,"_ap1_".length())="_ap1_$S(isIgnore:".upperCase()",1:"")_")"
	S return=$$tokenPop^UCPATCH($$vMExpr(return),2)
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
isEnd	; Method: String.endsWith(String string,Boolean ignoreCase)
	;
	;if actual(1).isNull(1) set PSL.return="("_PSL.objectName_"="""")" quit
	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	;
	I '$$isLit^UCGM(actual(2)) D  Q 
	.	;
	.	N label S label="vStrEnd"
	.	;
	.	I '$D(labels("vStrEnd")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String p1,Boolean p2)","String.endsWith")
	..		;
	..		D vaddBuff(buf,"if p2 set object=object.upperCase(),p1=p1.upperCase()")
	..		D vaddBuff(buf,"quit object.endsWith(p1)")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrEnd","")
	..		K vobj(+$G(buf)) Q 
	.	;
	.	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	.	Q 
	;
	; PSL.actual(2) is literal
	S return=$$tokenPush^UCPATCH(objectName,"String")
	N ap1 S ap1=$$tokenPush^UCPATCH(actual(1),"String")
	;
	N lstr S lstr=$$vMExpr(ap1_".length()")
	N lobj S lobj=$$vMExpr(return_".length()")
	;
	N isIgnore S isIgnore=$$QSUB^%ZS(actual(2),"""")
	I isIgnore S ap1=ap1_".upperCase()" S return=return_".upperCase()"
	;
	I lstr=1 S return=return_".extract("_lobj_")"
	E  S return=return_".extract("_lobj_"-"_lstr_"+1,"_lobj_")"
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("("_return_"="_ap1_")"),2)
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
isLike	; Method: String.isLike(String likeExpr,Boolean ignoreCase)
	;
	I (""""""[actual(1)) S return="("_return_"="""")" Q 
	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	;
	I '($$isLit^UCGM(actual(1))&$$isLit^UCGM(actual(2))) D  Q 
	.	;
	.	N label S label="vStrLike"
	.	;
	.	I '$D(labels("vStrLike")) D
	..		;
	..		N buf S buf=$$vopenBuf("(String object,String p1,Boolean p2)","String.isLike")
	..		;
	..		D vaddBuff(buf,"if p1.isNull() quit object.isNull()")
	..		D vaddBuff(buf,"if p2 set object=object.upperCase(),p1=p1.upperCase()")
	..		D vaddBuff(buf,"if p1.beginsWith(""%""),p1.endsWith(""%"") quit object[p1.extract(2,p1.length()-1)")
	..		D vaddBuff(buf,"if p1.beginsWith(""%"") quit object.endsWith(p1.extract(2,p1.length()))")
	..		D vaddBuff(buf,"if p1.endsWith(""%"") quit object.beginsWith(p1.extract(1,p1.length()-1))")
	..		D vaddBuff(buf,"quit object=p1")
	..		;
	..		D INSERT^UCMETHOD(buf,"vStrLike","")
	..		K vobj(+$G(buf)) Q 
	.	;
	.	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	.	Q 
	;
	; Both PSL.actual(1) and PSL.actual(2) are literal.
	N str S str=$$QSUB^%ZS(actual(1),"""")
	N isIgnore S isIgnore=$$QSUB^%ZS(actual(2),"""") ; Ignore Case
	;
	S return=objectName
	;
	I ($E(str,1)="%"),($E(str,$L(str))="%") D
	.	;
	.	S str=$$QADD^%ZS($E(str,2,$L(str)-1),"""")
	.	I isIgnore S str=str_".upperCase()" S return=return_".upperCase()"
	.	S return="("_return_"["_str_")"
	.	Q 
	;
	E  I ($E(str,1)="%") D
	.	;
	.	S str=$$QADD^%ZS($E(str,2,1048575),"""")
	.	S return="("_return_".endsWith("_str_","_actual(2)_"))"
	.	Q 
	;
	E  I ($E(str,$L(str))="%") D
	.	;
	.	S str=$$QADD^%ZS($E(str,1,$L(str)-1),"""")
	.	S return="("_return_".beginsWith("_str_","_actual(2)_"))"
	.	Q 
	;
	E  D
	.	;
	.	I isIgnore S actual(1)=actual(1)_".upperCase()" S return=return_".upperCase()"
	.	S return="("_return_"="_actual(1)_")"
	.	Q 
	;
	S return=$$vMExpr(return)
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
length	; Method: String.length(String delimiter)
	; Return the length of a string, or number of occurrances of parameter
	;
	N char S char=actual(1)
	;
	I (char="") D
	.	;
	.	S return="$L("_objectName_")"
	.	Q 
	;
	E  S return="$L("_objectName_","_char_")"
	;
	I $$isLit^UCGM(objectName) S return=$$toLit(return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
qsub	; Method: String.stripQuotes(String character)
	;
	N quote S quote=actual(1)
	I (""""""[quote) S quote="""""""""" ; literal for string of 4 quotes
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(quote) D
	.	S return=$$QADD^%ZS($$QSUB^%ZS($$QSUB^%ZS(objectName,""""),$$QSUB^%ZS(quote,"""")),"""")
	.	Q 
	E  S return="$$QSUB^%ZS("_objectName_","_quote_")"
	Q 
	;
	; ---------------------------------------------------------------------
qadd	; Method: String.addQuotes(String character)
	;
	N quote S quote=actual(1)
	I (""""""[quote) S quote=""""""""""
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(quote) D
	.	;set PSL.return = (PSL.objectName.stripQuotes().addQuotes($$toVal^UCPRIM(quote))).addQuotes()
	.	S return=$$QADD^%ZS($$QADD^%ZS($$QSUB^%ZS(objectName,""""),$$QSUB^%ZS(quote,"""")),"""")
	.	Q 
	E  D
	.	S return="$$QADD^%ZS("_objectName_","_quote_")"
	.	I $$isSimple^UCGM(objectName),$$isSimple^UCGM(quote) S return="$S("_objectName_"'["_quote_":"_quote_"_"_objectName_"_"_quote_",1:"_return_")"
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
isLit	; Method: String.isLit - String is a literal string (boolean)
	;
	I $$isLit^UCGM(objectName) S return=1
	E  S return="$$isLit^UCGM("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
isNum	; Method: String.isNum - String is a Number string (boolean)
	;if PSL.objectName.isLiteral() set PSL.return=$$isNum^UCGM(PSL.objectName.stripQuotes())
	;set PSL.return="$$isNum^UCGM("_PSL.objectName_")"
	I $$isLit^UCGM(objectName) D
	.	N val S val=$$QSUB^%ZS(objectName,"""")
	.	S return=(val=+val)
	.	Q 
	E  I $$isSimple^UCGM(objectName) D
	.	S return="("_objectName_"=+"_objectName_")"
	.	Q 
	E  D
	.	S return="$$"_"vStrIsNum"_"("_objectName_")"
	.	I '$D(labels("vStrIsNum")) D
	..		N sub S sub=$$vaddSubr("vStrIsNum","(vStr)","String.isNumber",0)
	..		D addCode^UCPSLSR(sub," Q vStr=+vStr")
	..		Q 
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
isInt	; Method: String.isInt  String is an Integer string (boolean)
	;
	;if PSL.objectName.isLiteral() set PSL.return=$$isInt^UCGM(PSL.objectName.stripQuotes())
	;else  set PSL.return="$$isInt^UCGM("_PSL.objectName_")"
	I $$isLit^UCGM(objectName) D
	.	N val S val=$$QSUB^%ZS(objectName,"""")
	.	S return=(val=+val)&(val'[".")
	.	Q 
	E  D
	.	S return="$$"_"vStrIsInt"_"("_objectName_")"
	.	I '$D(labels("vStrIsInt")) D
	..		N sub S sub=$$vaddSubr("vStrIsInt","object","String.isInteger",0)
	..		D addCode^UCPSLSR(sub," I object=+object,object'[""."" Q 1")
	..		D addCode^UCPSLSR(sub," Q 0")
	..		Q 
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
toNumber	; Method: String.toNumber(String mask,Boolean stripSpace)
	;
	I (""""""[objectName) S return="""""" Q 
	;
	I (""""""[actual(1)) S actual(1)=""".""" ; default decimal dot
	I (""""""[actual(2)) S actual(2)=0 ; default 0 (don't strip)
	;
	N mask S mask=$E($$toVal^UCPRIM(actual(1),"var"),1,4)
	N strip S strip=$$toVal^UCPRIM(actual(2),1) ; worst case default
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D  Q 
	.	;
	.	I mask=".",'strip S return=+($$QSUB^%ZS(objectName,""""))
	.	;
	.	E  S return=$$vStrToNu(($$QSUB^%ZS(objectName,"""")),mask,strip)
	.	Q 
	;
	I actual(1)=""".""",'strip S return="+"_objectName Q 
	;
	N neg S neg=$E(mask,3)
	I $$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)),neg'="T",neg'="P" D  Q 
	.	;
	.	S mask=$E(mask,1,2)_$E(mask,4)
	.	I strip,mask'[" " S mask=mask_" "
	.	S return=$$tokenPop^UCPATCH($$vMExpr("+"_$$tokenPush^UCPATCH(objectName,"String")_".translate("_$S(mask'["""":""""_mask_"""",1:$$QADD^%ZS(mask,""""))_",""."")"),1)
	.	Q 
	;
	N label S label="vStrToNu"
	;
	I '$D(labels("vStrToNu")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object,String p1,Boolean p2)","String.toNumber")
	.	;
	.	D vaddBuff(buf,"if object.isNull() quit """"")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if p1.isNull() set p1="".""")
	.	D vaddBuff(buf,"type String neg=p1.extract(3).upperCase()")
	.	D vaddBuff(buf,"set p1=p1.extract(1,2)_p1.extract(4)")
	.	D vaddBuff(buf,"if neg=""T"",object.endsWith(""-"") set neg=1,p1=p1_""-""")
	.	D vaddBuff(buf,"else  if neg=""P"" s p1=p1_"" "" i object.endsWith("")"") set neg=1,p1=p1_""()""")
	.	D vaddBuff(buf,"else  set neg=0")
	.	D vaddBuff(buf,"if p2,p1'["" "" set p1=p1_"" """)
	.	D vaddBuff(buf,"set object=object.translate(p1,""."")")
	.	D vaddBuff(buf,"quit $S(neg:-object,1:+object)")
	.	D INSERT^UCMETHOD(buf,"vStrToNu","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
toDate	; Method: String.toDate(String mask)
	; Convert a string to a julian date
	;
	I (""""""[objectName) S return="""""" Q 
	;
	N mask S mask=actual(1)
	;
	I (""""""[mask) S mask=$S(commands("mask","Date")'["""":""""_commands("mask","Date")_"""",1:$$QADD^%ZS(commands("mask","Date"),"""")) ; Default
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(mask) S return=$$vStrJD($$QSUB^%ZS(objectName,""""),$$QSUB^%ZS(mask,"""")) Q 
	;
	N label S label="vStrJD"
	;
	I '$D(labels("vStrJD")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String string,String mask)","String.toDate")
	.	;
	.	D vaddBuff(buf,"if 'string quit """"")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"type Number m,d,y")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"set d=mask.find(""DD"")")
	.	D vaddBuff(buf,"set m=mask.find(""MM"")")
	.	D vaddBuff(buf,"if string.length()=5,string.extract(1,5)?1.5N quit string")
	.	D vaddBuff(buf,"if '(m&d) quit $$^SCAJD(string,mask)")
	.	D vaddBuff(buf,"set m=string.extract(m-2,m-1),d=string.extract(d-2,d-1)")
	.	D vaddBuff(buf,"if (m?1.N)'&(d?1.N) quit $$^SCAJD(string,mask)")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"set y=mask.find(""YEAR"")")
	.	D vaddBuff(buf,"if y set y=string.extract(y-4,y-1)")
	.	D vaddBuff(buf,"else  set y=mask.find(""YY"") if y set y=string.extract(y-2,y-1)")
	.	D vaddBuff(buf,"else  quit $$^SCAJD(string,mask)")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if m<1!(m>12) Q -1")
	.	D vaddBuff(buf,"if y<100 set y=y+$S(y>50:1900,1:2000)")
	.	D vaddBuff(buf,"if (y#4=0)&('(y#100=0)!(y#400=0)) set m=""0,31,60,91,121,152,182,213,244,274,305,335,366"".piece("","",m,m+1)")
	.	D vaddBuff(buf,"else  set m=""0,31,59,90,120,151,181,212,243,273,304,334,365"".piece("","",m,m+1)")
	.	D vaddBuff(buf,"if ({String}m).piece("","",2)-({String}m).piece("","",1)<d quit -1")
	.	D vaddBuff(buf,"set d=d+({String}m).piece("","",1)+((y-1841)*365)")
	.	D vaddBuff(buf,"set d=d+((y-1841)\4)")
	.	D vaddBuff(buf,"set d=d-(((y-1)\100)-18)")
	.	D vaddBuff(buf,"set d=d+(((y-1)\400)-4)")
	.	D vaddBuff(buf,"quit d")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrJD","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_mask_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
toRow	; Method: String.toRow(List elements,String delimiter)
	;
	S actual(3)=actual(2) S actual(2)=actual(1)
	D classNew^UCROW
	S return=objectName
	;
	Q 
	;
	; ---------------------------------------------------------------------
toTime	; Method: String.toTime - Convert a string to Time (seconds past midnight)
	;
	I (""""""[objectName) S return="""""" Q 
	;
	N label S label="vStrTM"
	;
	I '$D(labels("vStrTM")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object)","String.toTime")
	.	;
	.	D vaddBuff(buf,"if 'object quit """"")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if object[""P"",object<12 set object.piece("":"",1)=object.piece("":"",1)+12")
	.	D vaddBuff(buf,"else  if object[""A"",object.piece("":"",1)=12 set object.piece("":"",1)=0")
	.	D vaddBuff(buf,"if object[""-""!(object.piece("":"",1)>23)!(object.piece("":"",2)>59)!(object.piece("":"",3)>59) quit """"")
	.	D vaddBuff(buf,"quit object.piece("":"",1)*60+object.piece("":"",2)*60+object.piece("":"",3)")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrTM","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_")"
	;
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vMExpr(v1)	; PSL.mExpr
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vExp N mcode N tok
	N vFun S vFun=$get(commands("OPTIMIZE","FUNCTIONS"),0)
	S commands("OPTIMIZE","FUNCTIONS")=0
	S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
	S commands("OPTIMIZE","FUNCTIONS")=vFun
	Q vExp
	; ----------------
	;  #OPTION ResultClass 0
vopenBuf(v1,v2)	; PSL.openBuffer
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vOid
	S vOid=$order(vobj(""),-1)+1
	I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
	S vobj(vOid,-1)=v1
	S vobj(vOid,-2)=v2
	S vobj(vOid,1)=v1_" // "_v2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vaddBuff(object,p1)	; PSLBuffer.add
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N line
	S line=$order(vobj(object,""),-1)+1
	S vobj(object,line)=" "_p1
	Q 
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vaddSubr(p1,p2,p3,p4)	; PSL.addSubrou
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I $get(p4) S p1=$$newLabel^UCGM(p1,.labels)
	E  I ($D(labels(p1))#2) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
	D addSubr^UCGM(p1,p2,p3)
	Q p1
	; ----------------
	;  #OPTION ResultClass 0
vStrToNu(object,p1,p2)	; String.toNumber
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	;
	I (p1="") S p1="."
	N neg S neg=$$vStrUC($E(p1,3))
	S p1=$E(p1,1,2)_$E(p1,4)
	I neg="T",($E(object,$L(object))="-") S neg=1 S p1=p1_"-"
	E  I neg="P" S p1=p1_" " I ($E(object,$L(object))=")") S neg=1 S p1=p1_"()"
	E  S neg=0
	I p2,p1'[" " S p1=p1_" "
	S object=$translate(object,p1,".")
	Q $S(neg:-object,1:+object)
	; ----------------
	;  #OPTION ResultClass 0
vStrJD(string,mask)	; String.toDate
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I 'string Q ""
	;
	N m N d N y
	;
	S d=$F(mask,"DD")
	S m=$F(mask,"MM")
	I $L(string)=5,$E(string,1,5)?1.5N Q string
	I '(m&d) Q $$^SCAJD(string,mask)
	S m=$E(string,m-2,m-1) S d=$E(string,d-2,d-1)
	I (m?1.N)'&(d?1.N) Q $$^SCAJD(string,mask)
	;
	S y=$F(mask,"YEAR")
	I y S y=$E(string,y-4,y-1)
	E  S y=$F(mask,"YY") I y S y=$E(string,y-2,y-1)
	E  Q $$^SCAJD(string,mask)
	;
	I m<1!(m>12) Q -1
	I y<100 S y=y+$S(y>50:1900,1:2000)
	I (y#4=0)&('(y#100=0)!(y#400=0)) S m=$piece("0,31,60,91,121,152,182,213,244,274,305,335,366",",",m,m+1)
	E  S m=$piece("0,31,59,90,120,151,181,212,243,273,304,334,365",",",m,m+1)
	I $piece((m),",",2)-$piece((m),",",1)<d Q -1
	S d=d+$piece((m),",",1)+((y-1841)*365)
	S d=d+((y-1841)\4)
	S d=d-(((y-1)\100)-18)
	S d=d+(((y-1)\400)-4)
	Q d
