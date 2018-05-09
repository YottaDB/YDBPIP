 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDTAUTL ****
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
JRNFUNCS(KEYWORDS) ; DEPRECATED;
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getSysKwd(KWD,caKwd) ; Get the keyword translation from the cache, load if needed
 N kwdRow S kwdRow=$$kwdRow(KWD,.caKwd)
 Q $P(kwdRow,$C(124),2)
 ;
 ; ---------------------------------------------------------------------
keywords(KWDS) ; Load table STBLSYSKEYWD into supplied array
 ;
 S KWDS("%BatchExit")="vEXIT|0|Boolean"
 S KWDS("%BatchRestart")="vRESTART|0|Boolean"
 S KWDS("%ClientVersionID")="%VNC|1|String"
 S KWDS("%CompanyName")="%CO|1|String"
 S KWDS("%CurrentDate")="$P($H,"","",1)|-1|Date"
 S KWDS("%CurrentTime")="$P($H,"","",2)|-1|Time"
 S KWDS("%EffectiveDate")="EFD|0|Date"
 S KWDS("%Identifier")="%IDENT|1|String"
 S KWDS("%InputTimeOut")="%TO|1|Number"
 S KWDS("%Library")="%LIBS|0|String"
 S KWDS("%ModuleName")="$T(+0)|-1|String"
 S KWDS("%ProcessID")="$J|-1|Integer"
 S KWDS("%ProcessMode")="%O|0|Integer"
 S KWDS("%RoutineName")="$T(+0)|-1|String"
 S KWDS("%ServerChannelID")="%SVCHNID|1|String"
 S KWDS("%SessionID")="%TOKEN|1|String"
 S KWDS("%SystemCurrency")="%CRCD|1|String"
 S KWDS("%SystemDate")="TJD|1|Date"
 S KWDS("%UserClass")="%UCLS|0|String"
 S KWDS("%UserDirectory")="$ZDIR|-1|String"
 S KWDS("%UserID")="%UID|0|String"
 S KWDS("%UserName")="$$USERNAM^%ZFUNC|-1|String"
 S KWDS("%UserStation")="TLO|0|String"
 S KWDS("%VerifyMode")="(%O=2)|-1|Boolean"
 S KWDS("%VersionID")="%VN|1|String"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
kwdRow(KWD,caKwd) ; Get the keyword descriptor row from the cache, load if needed
 I '$D(caKwd) D keywords(.caKwd)
 ;
 ; found as supplied, return complete descriptor, cf UCGM
 I ($D(caKwd(KWD))#2) Q KWD_"|"_caKwd(KWD)
 ;
 ; Not found, try case insensitive lookup, but do not modify caKwd()
 N KWU S KWU=$ZCONVERT(KWD,"U")
 N kwd S kwd=""
 F  S kwd=$order(caKwd(kwd)) Q:(kwd="")  Q:$ZCONVERT(kwd,"U")=KWU 
 ;
 ; If not found, even after lookup, return empty string
 I (kwd="") Q ""
 ;
 ; found, return complete descriptor, cf UCGM
 Q kwd_"|"_caKwd(kwd)
 ;
 ; ---------------------------------------------------------------------
kwdRowDef() ; return defintion of Row returned by $$kwdRow()
 Q "KEYWORD,DES,GLOBALSCOPE,CLASS"_$char(9)_124
 ;
 ; ---------------------------------------------------------------------
masks(prsr) ; compiler options /MECH=REFARR:RW
 ;
 N msk
 ;
 ; Ensure Boolean mask value
 I ($$getSetting^PSLCC(.prsr,"PSL","BooleanMask","")="") D
 .	;
 .	S msk=""
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ..		N rsD,vos1,vos2,vos3 S rsD=$$vOpen1()
 ..  I $$vFetch1() S msk=rsD
 ..  Q 
 .	I '(msk="") D addSetting^PSLCC(.prsr,"PSL","BooleanMask",$E(msk,1)_","_$E(msk,2)) Q 
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","BooleanMask","+,-")
 .	Q 
 ;
 ; Ensure Date mask value
 I ($$getSetting^PSLCC(.prsr,"PSL","DateMask","")="") D
 .	;
 .	S msk=""
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ..		N rsD,vos4,vos5,vos6 S rsD=$$vOpen2()
 ..  I $$vFetch2() S msk=rsD
 ..  Q 
 .	I '(msk="") D addSetting^PSLCC(.prsr,"PSL","DateMask",msk) Q 
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","DateMask","YEAR-MM-DD")
 .	Q 
 ;
 ; Ensure Time mask value
 I ($$getSetting^PSLCC(.prsr,"PSL","TimeMask","")="") D
 .	;
 .	S msk=""
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 ..		N rsT,vos7,vos8,vos9 S rsT=$$vOpen3()
 ..  I $$vFetch3() S msk=rsT
 ..  Q 
 .	I '(msk="") D addSetting^PSLCC(.prsr,"PSL","TimeMask",msk) Q 
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","TimeMask","24:60:SS")
 .	Q 
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61530^32638^Frans S.C. Witte^13556" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vRsRowGC(vNms,vTps) ; Runtime ResultSet.getRow().getColumns()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 N vL S vL="" N vN N vT N vO
 F vO=1:1:$S((vNms=""):0,1:$L(vNms,",")) D
 .	S vN=$piece(vNms,",",vO)
 .	S vT=$E(vTps,(vO-1)*2+1)
 .	I "TUF"[vT S vT="String"
 .	E  S vT=$piece("ByteString,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",vT)-1)
 .	S $piece(vL,",",v0)=vT_" "_vN
 .	Q 
 Q vL
 ;
vOpen1() ; MSK FROM DBCTLDVFM WHERE TYP='L'
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 I '($D(^DBCTL("SYS","DVFM","L"))#2) G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 ;
 I vos1=0 S rsD="" Q 0
 ;
 S vos1=100
 S vos3=$G(^DBCTL("SYS","DVFM","L"))
 S rsD=$P(vos3,"|",6)
 S vos1=0
 ;
 Q 1
 ;
vOpen2() ; MSK FROM DBCTLDVFM WHERE TYP='D'
 ;
 ;
 S vos4=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos4=0 Q
vL2a1 S vos5=$$BYTECHAR^SQLUTL(254)
 I '($D(^DBCTL("SYS","DVFM","D"))#2) G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 ;
 I vos4=0 S rsD="" Q 0
 ;
 S vos4=100
 S vos6=$G(^DBCTL("SYS","DVFM","D"))
 S rsD=$P(vos6,"|",6)
 S vos4=0
 ;
 Q 1
 ;
vOpen3() ; MSK FROM DBCTLDVFM WHERE TYP='C'
 ;
 ;
 S vos7=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos7=0 Q
vL3a1 S vos8=$$BYTECHAR^SQLUTL(254)
 I '($D(^DBCTL("SYS","DVFM","C"))#2) G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 ;
 I vos7=0 S rsT="" Q 0
 ;
 S vos7=100
 S vos9=$G(^DBCTL("SYS","DVFM","C"))
 S rsT=$P(vos9,"|",6)
 S vos7=0
 ;
 Q 1
 ;
vCatch3 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S msk=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S msk=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S msk=""
 D ZX^UCGMR(voxMrk) Q 
