 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCGMR ****
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
clsIsClass(c) ; runtime wrapper for Class.isValid
 I c="" Q ""
 Q $$rtClsByName^UCXOBJ(c)'=""
 ;
 ; ---------------------------------------------------------------------
clsIsAnc(a,d) ; runtime wrapper for Class.isAncestor / Class.isDecendant
 I a="" Q ""
 I d="" Q ""
 S a=$$rtClsByName^UCXOBJ(a) I a="" Q 0
 S d=$$rtClsByName^UCXOBJ(d) I d="" Q 0
 Q $$rtClsIsAnc^UCXOBJ(a,d)
 ;
 ; ---------------------------------------------------------------------
LOWER(S) ; Return S.lowerCase()
 Q $ZCONVERT(S,"L")
 ;
 ; ---------------------------------------------------------------------
UPPER(S) ; Return S.upperCase()
 Q $ZCONVERT(S,"U")
 ;
 ; ---------------------------------------------------------------------
copy(v1) ; MTL runtime for Object.copy()
 N vOid
 ;
 ;  #ACCEPT CR=22720; Date=2006-08-18; PGM=Frans S.C. Witte; Group=BYPASS
 ;*** Start of code by-passed by compiler
 set vOid=$O(vobj(""),-1)+1
 merge vobj(vOid)=vobj(v1)
 ;*** End of code by-passed by compiler ***
 ;
 Q vOid
 ;
 ; ---------------------------------------------------------------------
equals(p1,p2) ; MTL runtime for Object.equals()
 N equals
 N z1 N z1e N z2 N z2e
 S z1="vobj("_p1 S z1e=z1 S z1=z1_")"
 S z2="vobj("_p2 S z2e=z2 S z2=z2_")"
 ;
 S equals=1
 I $get(@z1)'=$get(@z2) Q 0 ; compare top nodes
 F  S z1=$query(@z1) S z2=$query(@z2) Q:$E(z1,1,$L(z1e))'=z1e  D  I equals=0 Q 
 .	;
 .	I $E(z1,$L(z1e)+1,1048575)'=$E(z2,$L(z2e)+1,1048575) S equals=0
 .	E  I @z1'=@z2 S equals=0
 .	Q 
 Q equals
 ;
 ; ---------------------------------------------------------------------
toString(p1) ; MTL runtime for Object.toString()
 N return N zo N ze
 S zo="vobj("_p1 S ze=zo S zo=zo_")"
 ;
 I ($D(@zo)#2) S return=@zo_$char(9)
 E  S return=""
 ;
 F  S zo=$query(@zo) Q:'($E(zo,1,$L(ze))=ze)  S return=return_$E(zo,$L(ze)+2,1048575)_"="""_@zo_""""_$char(9)
 ;
 Q $E(return,1,$L(return)-1)
 ;
 ; ---------------------------------------------------------------------
ZX(voPtr,voGoto,voTag) ; MTL General error handler
 ;public ZX( Number voPtr )
 ;  #ACCEPT CR=22720; Date=2006-08-18; PGM=Frans S.C. Witte; Group=BYPASS
 ;*** Start of code by-passed by compiler
 ;;do @voTag
 ;
 ; reset $EC to end error processing mode
 SET $ECODE="",$ZERROR=""
 ;
 IF $DATA(vobj) FOR  SET voPtr=$ORDER(vobj(voPtr)) QUIT:voPtr=""  KILL vobj(voPtr)
 DO garbageCollect^vRuntime($STACK-1)
 IF $GET(%ZTPTRAP)'="",$PIECE($ZSTATUS,",",3)["%GTM-E-TPTIMEOUT" XECUTE "set %ZTPTRAP="""" "_%ZTPTRAP
 ;;zgoto voGoto-1
 IF $DATA(voGoto) ZGOTO @("voGoto:"_voTag)
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ; ---------------------------------------------------------------------
vobjDfer(vObjDfer) ; 
 ;  #ACCEPT CR=27800; Date=2007-07-12; PGM=Frans S.C. Witte; Group=BYPASS
 ;*** Start of code by-passed by compiler
 NEW vD,vN,vO,vS
 SET vS=+vobjDfer
 FOR vN=2:1:$LENGTH(vobjDfer,",") SET vO=$PIECE(vobjDfer,",",vN) IF vO]"""",$PIECE($GET(vobj(vO,-1)),$CHAR(9),2)'<vS DO
 . SET vD=$PIECE(vobj(vO,-1),$CHAR(9),3)
 . IF vD="" KILL vobj(vO) QUIT
 . DO @(vD_"(vO)")
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ; ---------------------------------------------------------------------
vobjDes(vS,vO) ; 
 ;  #ACCEPT CR=27800; Date=2007-07-12; PGM=Frans S.C. Witte; Group=BYPASS
 ;*** Start of code by-passed by compiler
 QUIT:vO=""  QUIT:$PIECE($GET(vobj(vO,-1)),$CHAR(9),2)<vS
 NEW vD SET vD=$PIECE(vobj(vO,-1),$CHAR(9),3)
 IF vD="" KILL vobj(vO) QUIT
 DO @(vD_"(vO)")
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ;---------------------------------------------------------------------
ZE ; General error handler pre-processor
 ;
 ;  #ACCEPT CR=28995; Date=2007-08-12; PGM=KWANL; Group=BYPASS
 ;*** Start of code by-passed by compiler
 if $ZE="" set $ZE="0,"_$P($ZS,",",2,999)
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ;---------------------------------------------------------------------
LOG(vLabref,vErr) ; Entry point to call error logger
 D  ; call logger under protection of an ignore-all catch-statement
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	;   #ACCEPT CR=28995; Date=2007-08-12; PGM=KWANL; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	do @(vLabref_"(.vErr)")
 .	;*** End of code by-passed by compiler ***
 .	Q  ; end code protected by catch
 ;
 S $P(vErr,",",1)=1
 S $ZE=vErr,$EC=",U1001,"
 Q  ; will never be reached
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61293^42583^Frans S.C. Witte^15106" ; Signature - LTD^TIME^USER^SIZE
 ;
vCatch1 ; Error trap
 ;
 N xIgnore,$ET,$ES S xIgnore=$ZE,$EC="",$ET="Q",$ZE=""
 D ZX^UCGMR(voxMrk) Q 
