	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCNUMBER ****
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
rndDec	; Number.roundDec(Number decimal,String opt,Number just)
	; Returns rounded value
	;
	I (""""""[actual(1)) S actual(1)=2
	I (""""""[actual(3)) S actual(3)=0
	;
	I (""""""[actual(2)) S return="$J("_objectName_","_actual(3)_","_actual(1)_")"
	E  D roundSub(actual(1),actual(2),actual(3))
	;
	Q 
	;
	; ---------------------------------------------------------------------
rndCRCD	; Number.roundCRCD(String CRCD,String opt,Number just)
	;
	N dec
	;
	I (""""""[actual(1)) D
	.	S actual(1)="""USD"""
	.	I (""""""[actual(1)) S dec=2
	.	Q 
	;
	I '(""""""[actual(1)) D
	.	I $$isLit^UCGM(actual(1)),$$VALID^%ZRTNS("CRCDUTL") S dec=+$$curdec^CRCDUTL($$QSUB^%ZS(actual(1),""""))
	.	E  S dec="+$$curdec^CRCDUTL("_actual(1)_")"
	.	Q 
	;
	I (""""""[actual(3)) S actual(3)=0
	I (""""""[actual(2)) S return="$J("_objectName_","_actual(3)_","_dec_")"
	E  D roundSub(dec,actual(2),actual(3))
	;
	Q 
	;
	; ---------------------------------------------------------------------
toString	; Method: Number.toString(Number decimal,String mask)
	;
	I (""""""[objectName),(""""""[actual(1)) Q """"""
	;
	I (actual(1)="") S actual(1)=$$QADD^%ZS(actual(1),"""")
	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	;
	I (""""""[actual(2))!(actual(2)=""".""") S return="$J("_objectName_",0,"_actual(1)_")" Q 
	;
	I $$isLit^UCGM(actual(2)) D  Q 
	.	;
	.	N msk S msk=$$QSUB^%ZS(actual(2),"""")
	.	N vm S vm=$E(msk,1) ; Replace Decimal
	.	N vf S vf=$E(msk,3) ; Negative Number
	.	I 9'[$E(msk,2) S vf=vf_"," S vm=vm_$E(msk,2) ; Replace thousand sep
	.	;
	.	I '(vf="") D
	..		S return="$FN("_objectName_","""_vf_""",+"_actual(1)_")"
	..		I $E(vm,1,2)'=".," S return="$TR("_return_","".,"","""_vm_""")"
	..		Q 
	.	;
	.	E  D
	..		S return="$J("_objectName_",0,+"_actual(1)_")"
	..		I vm'="." S return="$TR("_return_",""."","""_vm_""")"
	..		Q 
	.	;
	.	I $L(msk)=4 S return=""""_$E(msk,4)_"""_"_return
	.	;
	.	Q 
	;
	S return="$$NUM^%ZM("_objectName_","_actual(1)_","_actual(2)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
roundSub(dec,option,jus)	;  Round a number up/down to decimal precision
	N label S label="vNumRnd"
	;
	I '$D(labels("vNumRnd")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Number p1,String p2,Number p3)","Number.round")
	.	;
	.	D vaddBuff(buf,"type Number y=p1.find(""."")+p3-1")
	.	D vaddBuff(buf,"if y<p3!(y=p1.length()) quit p1.justify(p3)")
	.	D vaddBuff(buf,"if p1.extract(y+1)=0 quit p1.extract(1,y).justify(p3)")
	.	D vaddBuff(buf,"if p2=""+"" set p1=p1+("".0000000000000"".extract(1,p3)_1)")
	.	D vaddBuff(buf,"quit p1.extract(1,y).justify(p3)")
	.	;
	.	D INSERT^UCMETHOD(buf,"vNumRnd","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_dec_","_option_")"
	Q 
	;
	; ---------------------------------------------------------------------
zero	; Method Number.zero - returns zero fill
	;
	I (""""""[actual(1)) D ERROR^UCGM("Length required")
	I (""""""[actual(2)) S actual(2)=0
	I actual(3)>1!(actual(3)<0) D ERROR^UCGM($$^MSG(7609))
	I (""""""[actual(3)) S actual(3)=0
	I actual(4)>2!(actual(4)<0) D ERROR^UCGM($$^MSG(7609))
	I (""""""[actual(4)) S actual(4)=0
	;
	N label S label="vstrZero"
	;
	I '$D(labels("vstrZero")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Number object,Number p1,Number p2,Number p3,Number p4)","String.zero")
	.	;
	.	D vaddBuff(buf,"type String SIGN,X")
	.	D vaddBuff(buf,"set X=""""")
	.	D vaddBuff(buf,"set object=object.roundDec(p2)")
	.	D vaddBuff(buf,"if p3=1 S object=object*$S(p2'=0:(10**p2),1:1)")
	.	D vaddBuff(buf,"if p4'=0 do {")
	.	D vaddBuff(buf," set p1=p1-1")
	.	D vaddBuff(buf," if object<0 set object=object*-1,SIGN=""-""")
	.	D vaddBuff(buf," else  set SIGN=""+""")
	.	D vaddBuff(buf," }")
	.	; do buf.add("I object.length()>p1 set $ZS=""0,""_$ZPOS_"",""_$$^MSG(3037,object,p1) X $ZT")
	.	D vaddBuff(buf,"set X.piece(0,p1-object.length())=0 set object=X_object")
	.	D vaddBuff(buf,"if p4=0 quit object")
	.	D vaddBuff(buf,"if p4=1 quit SIGN_object")
	.	D vaddBuff(buf,"quit object_SIGN")
	.	;
	.	D INSERT^UCMETHOD(buf,"vstrZero","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
	;
	Q 
	;
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
