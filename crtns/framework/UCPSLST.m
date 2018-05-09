 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCPSLST ****
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
botDo(pslSt) ; PSLState "object"
 N sDo S sDo=$piece(pslSt,"|")
 ;
 Q $piece(sDo,",",$L(sDo,","))
 ;
 ; ---------------------------------------------------------------------
getDo(pslSt) ; PSLState "object"
 Q $piece(pslSt,"|")
 ;
 ; ---------------------------------------------------------------------
getFor(pslSt) ; PSLState "object"
 Q $piece(pslSt,"|",3)
 ;
 ; ---------------------------------------------------------------------
getForBlock(pslSt,outer) ; outer scope
 N sub
 I ($get(outer)="") S sub=0
 E  S sub=$L(outer,",")
 ;
 N fSt S fSt=$piece(pslSt,"|",3)
 N siz S siz=$L(fSt)
 F sub=siz-sub:-1:0 Q:$E(fSt,sub)="1" 
 I 'sub Q ""
 Q $piece($piece(pslSt,"|"),",",sub,siz)
 ;
 ; ---------------------------------------------------------------------
getIf(pslSt) ; PSLState "object"
 Q $piece(pslSt,"|",2)
 ;
 ; ---------------------------------------------------------------------
isDoScope(pslSt,outer) ; outer scope doStack
 N inner S inner=$piece(pslSt,"|")
 I inner=outer Q 1
 ;
 N diff S diff=$L(inner)-$L(outer)
 I $E(inner,diff)="," Q ($E(inner,$L(inner)-$L(outer)+1,1048575)=outer)
 Q 0
 ;
 ; ---------------------------------------------------------------------
new(doVal,ifVal,forVal) ; value for forState
 Q doVal_"|"_ifVal_"|"_forVal
 ;
 ; ---------------------------------------------------------------------
pop(pslSt,doVal,ifFl,forFl) ; lvn for top of forState /MECH=REFVAR:W
 N dSt S dSt=$piece(pslSt,"|")
 N iSt S iSt=$piece(pslSt,"|",2)
 N fSt S fSt=$piece(pslSt,"|",3)
 ;
 N top S top=$L(iSt)
 S doVal=$piece(dSt,",")
 S ifFl=$E(iSt,1)
 S forFl=$E(fSt,1)
 ;
 S pslSt=$piece(dSt,",",2,top)_"|"_$E(iSt,2,top)_"|"_$E(fSt,2,top)
 Q 
 ;
 ; ---------------------------------------------------------------------
push(pslSt,doVal,ifFl,forFl) ; value to push on forState
 N dSt S dSt=doVal_","_$piece(pslSt,"|")
 N iSt S iSt=ifFl_$piece(pslSt,"|",2)
 N fSt S fSt=forFl_$piece(pslSt,"|",3)
 ;
 S pslSt=dSt_"|"_iSt_"|"_fSt
 Q 
 ;
 ; ---------------------------------------------------------------------
set(pslSt,doVal,ifFl,forFl) ; value to replace top of forState
 N dSt S dSt=$piece(pslSt,"|")
 N iSt S iSt=$piece(pslSt,"|",2)
 N fSt S fSt=$piece(pslSt,"|",3)
 ;
 S $piece(dSt,",")=doVal
 S $E(iSt,1)=ifFl
 S $E(fSt,1)=forFl
 ;
 S pslSt=dSt_"|"_iSt_"|"_fSt
 Q 
 ;
 ; ---------------------------------------------------------------------
topDo(pslSt) ; PSLState "object"
 Q $piece($piece(pslSt,"|"),",")
 ;
 ; ---------------------------------------------------------------------
topFor(pslSt) ; PSLState "object"
 Q $E($piece(pslSt,"|",3),1)
 ;
 ; ---------------------------------------------------------------------
topIf(pslSt) ; PSLState "object"
 Q $E($piece(pslSt,"|",2),1)
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61045^43029^Frans S.C. Witte^8483" ; Signature - LTD^TIME^USER^SIZE
