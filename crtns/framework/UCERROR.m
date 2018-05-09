 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCERROR ****
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
 ; * changes are made to this procedure.  The M routine from the     *
 ; * crtns directory should be used for this purpose.                *
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
 ;--------------------------------------------------------------------
getIdent ; property Error.ident
 ;--------------------------------------------------------------------
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr($$tokenPush^UCPATCH(objectName,"PSLError")_".type"),1)
 I 'fset S return="$P("_return_",""-"",3)"
 E  D
 .	S struct("setProperty")="setProperty^UCERROR"
 .	S return="."_objectName_",3"
 .	Q 
 Q 
 ;
 ;--------------------------------------------------------------------
getSvrty ; property Error.severity
 ;--------------------------------------------------------------------
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr($$tokenPush^UCPATCH(objectName,"PSLTable")_".type"),1)
 ;
 I 'fset S return="$P("_return_",""-"",2)"
 E  D
 .	S struct("setProperty")="setProperty^UCERROR"
 .	S return="."_objectName_",2"
 .	Q 
 Q 
 ;
 ;--------------------------------------------------------------------
getComp ; property Error.component
 ;--------------------------------------------------------------------
 ;
 S return=$$tokenPop^UCPATCH($piece($$vMExpr($$tokenPush^UCPATCH(objectName,"PSLTable")_".type"),"-",1),1)
 ;
 I 'fset S return="$P("_return_",""-"",1)"
 E  D
 .	S struct("setProperty")="setProperty^UCERROR"
 .	S return="."_objectName_",1"
 .	Q 
 Q 
 ;
 ;---------------------------------------------------------------------
setProperty(error,pos,value) ; modify one of the Error.type components
 ;
 N et S et=$P(error,",",3)
 S $piece(et,"-",pos)=value
 S $P(error,",",3)=et
 Q 
 ;
 ;---------------------------------------------------------------------
toString() ; method Error.toString()
 S return=objectName
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60946^40563^Frans S.C. Witte^4106" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vMExpr(v1) ; PSL.mExpr
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vExp N mcode N tok
 N vDep S vDep=$$getSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",0)
 N vMis S vMis=$$getSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 N vFun S vFun=$$getSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",0)
 D addSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",0)
 D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 D addSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",0)
 S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
 D addSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",vDep)
 D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",vMis)
 D addSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",vFun)
 Q vExp
