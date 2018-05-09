 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCREF ****
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
 Q 
 ;
 ; ---------------------------------------------------------------------
copy ; method Reference.copy; Returns Reference
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N class S class=$$getClass^UCGM(objectName,objectLevel)
 ;
 S return="$$copy^UCGMR("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
equals ; method Reference.equals; Returns boolean
 N class1 N class2
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S class1=$$getClass^UCGM(objectName)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S class2=$$getClass^UCGM(actual(1))
 ;
 I class1'=class2 D ERROR^UCGM("Objects must the same type") Q 
 ;
 S return="$$equals^UCGMR("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getPointer ; method Reference.getPointer; returns Number (integer)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.7,0,"Reference.getPointer() - consider using Object.exists()")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isVar^UCGM(objectName)!$$isArr^UCGM(objectName) S return="$G("_objectName_")"
 E  S return="+"_objectName
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getOpti^UCGM(objectName,objectLevel)>msrc D setOpti^UCGM(objectName,objectLevel,0)
 Q 
 ;
 ; ---------------------------------------------------------------------
getValue ; method Reference.getStoredValue(String tag)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N class S class=$$getClass^UCGM(objectName,objectLevel)
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) D ERROR^UCGM("Tag parameter is required")
 ;
 S return="$G("_oLvn_"("_objectName_",-999,"_actual(1)_"))"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
setValue ; method Reference.setStoredValue(String tag,Object value)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 S return="S"_postCond_" "_oLvn_"("_objectName_",-999,"_actual(1)_")="_actual(2)
 Q 
 ;
 ; ---------------------------------------------------------------------
toString ; method Reference.toString; Returns String
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N class S class=$$getClass^UCGM(objectName,objectLevel)
 ;
 S return="$$toString^UCGMR("_objectName_")"
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61058^29757^Frans S.C. Witte^7389" ; Signature - LTD^TIME^USER^SIZE
