 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCNUMBER ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
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
 ;
 ; ---------------------------------------------------------------------
rnd() ; Number.round(Number decimal,String opt)
 ; Returns rounded Numeric value
 ;
 I (actual(1)="") S actual(1)=2
 I $$isNullOrLiteralNull^UCPRIM(actual(2)) S return="+$J("_objectName_",0,"_actual(1)_")"
 E  S return="$$round^vNumber("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
rndDec ; Number.roundDec(Number decimal,String opt,Number just)
 ; Returns rounded value as a String (may include leading spaces)
 ;
 I (actual(1)="") S actual(1)=2
 I (actual(3)="") S actual(3)=0
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(2)) S return="$J("_objectName_","_actual(3)_","_actual(1)_")"
 E  D roundSub(actual(1),actual(2),actual(3))
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
rndCRCD ; Number.roundCRCD(String CRCD,String opt,Number just)
 N dec
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) D
 .	S actual(1)="""0"""
 .	I $$isNullOrLiteralNull^UCPRIM(actual(1)) S dec=2
 .	Q 
 ;
 I '$$isNullOrLiteralNull^UCPRIM(actual(1)) D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isLit^UCGM(actual(1)),$$VALID^%ZRTNS("CRCDUTL") S dec=+$$curdec^CRCDUTL($$QSUB^%ZS(actual(1),""""))
 .	E  S dec="+$$curdec^CRCDUTL("_actual(1)_")"
 .	Q 
 ;
 I (actual(3)="") S actual(3)=0
 I $$isNullOrLiteralNull^UCPRIM(actual(2)) S return="$J("_objectName_","_actual(3)_","_dec_")"
 E  D roundSub(dec,actual(2),actual(3))
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
toString ; Method: Number.toString(Number decimal,String mask)
 ;
 I $$isNullOrLiteralNull^UCPRIM(objectName) S return="""""" Q 
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(2))!(actual(2)=""".""") D  Q 
 .	I (actual(1)="") S return=objectName Q 
 .	S return="$J("_objectName_",0,"_actual(1)_")"
 .	Q 
 ;
 I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
 ;
 I $$isLit^UCGM(actual(2)) D  Q 
 .	;
 .	N msk S msk=$$QSUB^%ZS(actual(2),"""")
 .	N vm S vm=$E(msk,1) ; Replace Decimal
 .	N vf S vf=$E(msk,3) ; Negative Number
 .	I 9'[$E(msk,2) S vf=vf_"," S vm=vm_$E(msk,2) ; Replace thousand sep
 .	;
 .	I '(vf="") D
 ..		S return="$FN("_objectName_","""_vf_""","_actual(1)_")"
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
roundSub(dec,option,jus) ; Round a number up/down to decimal precision
 ;  #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-12-18;PGM=Frans S.C. Witte
 I ((","_"Number,Integer"_",")[(","_$$getClass^UCGM(objectName)_",")) S return=objectName
 E  S return="+"_objectName
 ;
 S return="$$roundDec^vNumber("_return_","_dec_","_option_","_jus_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
zero ; Method Number.zero - returns zero fill
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) D ERROR^UCGM("Length required")
 I $$isNullOrLiteralNull^UCPRIM(actual(2)) S actual(2)=0
 I actual(3)>1!(actual(3)<0) D ERROR^UCGM($$^MSG(7609))
 I $$isNullOrLiteralNull^UCPRIM(actual(3)) S actual(3)=0
 I actual(4)>2!(actual(4)<0) D ERROR^UCGM($$^MSG(7609))
 I $$isNullOrLiteralNull^UCPRIM(actual(4)) S actual(4)=0
 ;
 N label S label="vNumZero"
 ;
 I '$$hasSubr^UCGM("vNumZero") D
 .	;
 .	N buf S buf=$$vopenBuf("(Number vo,Number v1,Number v2,Number v3,Number v4)","String.zero")
 .	;
 .	D vaddBuff(buf,"type String vSign,vX")
 .	D vaddBuff(buf,"set vX=""""")
 .	D vaddBuff(buf,"set vo=vo.roundDec(v2)")
 .	D vaddBuff(buf,"if v3=1,v2'=0 S vo=vo*(10**v2)")
 .	D vaddBuff(buf,"if v4'=0 do {")
 .	D vaddBuff(buf," set v1=v1-1")
 .	D vaddBuff(buf," if vo<0 set vo=vo*-1,vSign=""-""")
 .	D vaddBuff(buf," else  set vSign=""+""")
 .	D vaddBuff(buf," }")
 .	; do buf.add("I vo.length()>v1 throw Class.new(""Error"","%PSL-E-MISMATCH,"_$$^MSG(3037,vo,v1))")
 .	D vaddBuff(buf,"set vX.piece(0,v1-vo.length())=0 set vo=vX_vo")
 .	D vaddBuff(buf,"if v4=0 quit vo")
 .	D vaddBuff(buf,"if v4=1 quit vSign_vo")
 .	D vaddBuff(buf,"quit vo_vSign")
 .	;
 .	D INSERT^UCMETHOD(buf,"vNumZero","String")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
 ;
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61537^60709^Frans S.C. Witte^10577" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vopenBuf(v1,v2) ; PSL.openBuffer
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vOid
 S vOid=$O(vobj(""),-1)+1 S vobj(vOid,-1)="PSLBuffer"
 I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
 S vobj(vOid,-2)=v1
 S vobj(vOid,-3)=v2
 S vobj(vOid,1)=v1_" // "_v2
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vaddBuff(object,p1) ; PSLBuffer.add
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N line
 S line=$order(vobj(object,""),-1)+1
 S vobj(object,line)=" "_p1
 Q 
