 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UTLO ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ; Define teller location (TLO)
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 S UTLO=$$TLO
 Q 
 ;
TLO() ; Function returns TLO
 ;
 N UTLO
 I '$$INTRACT^%ZFUNC S UTLO="BATCH"
 E  S UTLO=$$READPRT^%ZFUNC($I)
 ;
 Q UTLO
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "59495^75673^Lik Kwan^1435" ; Signature - LTD^TIME^USER^SIZE
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 N ET,RM
 S ET=$P(error,",",3)
 ;
 I ET["%GTM-" D ZE^UTLERR D ZX^UCGMR(voxMrk) Q 
 S ET=ET_"-"_$P(error,",",2)
 S RM=$P(error,",",4)
 D ^UTLERR
 D ZX^UCGMR(voxMrk) Q 
