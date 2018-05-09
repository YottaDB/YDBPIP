 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCTIME ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
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
toString() ; method Time.toString(String mask)
 ;
 N mask S mask=actual(1)
 ;
 I (mask=""!(mask="""""")) S mask=$$QADD^%ZS($$getSetting^PSLCC(.pslPrsr,"PSL","TimeMask"),"""")
 ;
 S return=""
 ;
 I $$isLit^UCGM(mask),$$isLit^UCGM(objectName) D
 .	; both values are literal, resolve at compile time
 .	;   #ACCEPT GROUP=DEPRECATED;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S return=$$QADD^%ZS($ZD(","_$$QSUB^%ZS(objectName,""""),$$QSUB^%ZS(mask,"""")),"""")
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=40212;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  I $$isLit^UCGM(mask),$$isVar^UCGM(objectName) D
 .	S return="$S("_objectName_"'="""":$ZD("_objectName_","_mask_"),1:"""")"
 .	Q 
 E 
 ;
 I '$$hasSubr^UCGM("vtim2str") D
 .	N buf S buf=$$vopenBuf("(Time vo, String vm)","Time.toString")
 .	;
 .	D vaddBuff(buf,"if vo.isNull() quit """"")
 .	D vaddBuff(buf,"if vm.isNull() set vm="_$$QADD^%ZS($$getSetting^PSLCC(.pslPrsr,"PSL","TimeMask"),""""))
 .	D vaddBuff(buf,"type String cc")
 .	D vaddBuff(buf,"#ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS")
 .	D vaddBuff(buf,"#BYPASS")
 .	D vaddBuff(buf,"SET cc=$ZDATE("",""_vo,vm)")
 .	D vaddBuff(buf,"#ENDBYPASS")
 .	D vaddBuff(buf,"quit cc")
 .	;
 .	D INSERT^UCMETHOD(buf,"vtim2str","String")
 .	K vobj(+$G(buf)) Q 
 S return="$$"_"vtim2str"_"("_objectName_","_mask_")"
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61530^32594^Frans S.C. Witte^4413" ; Signature - LTD^TIME^USER^SIZE
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
