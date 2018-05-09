 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDFR1 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDFR1 ; 
 ;
  S ER=0
 ;
 N CNT N DBOPT N DOC N %FRAME N N N OLNTB N TEMP N VRWOPT
 N FIL N H2 N IO N PGM N %READ N RID N SORT N %TAB N VFMQ N vudwhere N WHERE
 ;
  N V1 S V1=$J D vDbDe1()
 ;
 S SORT="NOD,POS"
 ;
 S H2=" * = All  AB* = From AB to ABz  AB-CD = From AB to CD  'AB = Not AB"
 ;
 S %TAB("IO")=$$IO^SCATAB($I)
 S %TAB("DOC")=".LS1"
 S %TAB("SORT")=".SORT1/TBL=@SELDI^DBSFUN(""DBTBL1D"",.X):LIST"
 S %TAB("WHERE")=".WHERE1/XPP=D VALIDWHR^DBSDFR1 I RM'="""" S ER=1"
 S %TAB("FIL")=".FID1/TBL=[DBTBL1]/XPP=D LISTPP^DBSGETID(""DBTBL1"")/LEN=36"
 S %TAB("FIL(0)")=%TAB("FIL")
 ;
 S %READ="@@%FN,,IO/REQ,,DOC/NOREQ,SORT/NOREQ,WHERE,,@H2/INC,,FIL(0)/REQ,FIL/REP=10/NOREQ"
 ;
 S DBOPT=1 S %FRAME=2 S OLNTB=20 S TEMP=0
 D ^UTLREAD Q:VFMQ="Q" 
 ;
 S RID="DBSFILLST"
 D ^URID Q:$get(PGM)="" 
 ;
 ; Add selections to TMPDQ
 S N=""
 F  S N=$order(FIL(N)) Q:(N="")  S CNT=$$LISTBLD^DBSGETID(FIL(N),"DBTBL1")
 ;
 I SORT'="" D
 .	N I
 .	N X
 .	;
 .	S X=SORT S SORT=""
 .	F I=1:1:$L(X,",") S SORT=SORT_"DBTBL1D."_$piece(X,",",I)_","
 .	S SORT=$E(SORT,1,$L(SORT)-1)
 .	Q 
 ;
 I WHERE="" S vudwhere="%LIBS='SYSDEV' AND FID=:FID"
 E  S vudwhere="("_WHERE_") AND (%LIBS='SYSDEV' AND FID=:FID)"
 ;
 D OPEN^SCAIO Q:ER 
 ;
 N tmpdqrs,vos1,vos2,vos3,vos4  N V2 S V2=$J S tmpdqrs=$$vOpen1()
 ;
 S CNT=0
 F  Q:'$$vFetch1()  D  Q:ER 
 .	N FID
 .	;
 .	; If interactive, prompt to continue
 .	I CNT,IO=$P D  Q:ER 
 ..		N MSG
 ..		;
 ..		S MSG=""
 ..		I $$^DBSMBAR(161)'=1 S ER=1 S RM=""
 ..		Q 
 .	;
 . S FID=tmpdqrs
 .	S VRWOPT("NOOPEN")=1
 .	S VRWOPT("NOCLOSE")=1
 .	D @("V0^"_PGM)
 .	S CNT=CNT+1
 .	Q 
 ;
 D CLOSE^SCAIO
 ;
  N V3 S V3=$J D vDbDe2()
 ;
 Q 
 ;
VALIDWHR ; Validate where clause entered
 ;
 ; Entry must be a valid where clause against table DBTBL1D
 ;
 S RM=""
 ;
 Q:(X="") 
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ; Try it ... if it fails it will trigger the catch block
 ;  #ACCEPT Date=09/19/06; Pgm=RussellDS; CR=22567
 N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"DI","DBTBL1D",X,"","","",1)
 ;
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60527^73806^Dan Russell^2789" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM TMPDQ WHERE PID=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen2()
 F  Q:'$$vFetch2()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM TMPDQ WHERE PID=:V3
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="VALIDWHR.rs"
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
 ;
 S vExpr="SELECT "_vSelect_" FROM "_vFrom
 I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
 I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
 I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
 S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
 ;
 S sqlcur=$O(vobj(""),-1)+1
 ;
 I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vos1=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rs="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rs=vd
 S vos1=vsql
 S vos2=$G(vi)
 Q vsql
 ;
vOpen1() ; ELEMENT FROM TMPDQ WHERE PID=:V2
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2)
 S vos4=""
vL1a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S tmpdqrs="" Q 0
 ;
 S tmpdqrs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V1
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL2a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V3
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V3)
 S vos4=""
vL3a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 ; Invalid WHERE statement
 S RM=$$^MSG(1507)
 ;
 D ZX^UCGMR(voxMrk) Q 
