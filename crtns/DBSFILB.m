 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSFILB ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSFILB ; 
 ;
 Q 
 ;
BUILDALL ; Build RecordTABLE code for all tables
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D COMPILE(rs)
 Q 
 ;
BUILD ; Build select RecordTABLE code
 ;
 N COUNT
 N fid N RM
 ;
 S COUNT=$$LIST^DBSGETID("DBTBL1") ; Interactive select
 Q:(COUNT'>0) 
 ;
 N tmpdqrs,vos1,vos2,vos3,vos4  N V1 S V1=$J S tmpdqrs=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D COMPILE(tmpdqrs)
 ;
  N V2 S V2=$J D vDbDe1()
 ;
 Q 
 ;
COMPILE(tableName,NLU1,NLU2,PGM) ; Generated program name /NOREQ/MECH=REFNAM:W
 ;
 N errors
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^UTLERR"",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 S PGM="Record"_tableName
 ;
 I '($D(^DBTBL("SYSDEV",25,PGM))#2) D
 .	;
 .	WRITE !,PGM,!
 .	;
 .	S errors=$$run^PSLC("--element="_PGM_"~Filer "_PGM)
 .	Q 
 E  D COMPILE^DBSPROC(PGM)
 ;
 Q 
 ;
SYSMAPLB(tag,comment) ; Comment on the line
 ;
 N RETURN S RETURN=tag
 ;
 I ($E(tag,1,4)="vRCT"),(comment["Trigger") D
 .	;
 .	S RETURN=$piece($piece(comment,"Trigger",2),"-",1)
 .	S RETURN=tag_" (Trigger - "_$$vStrTrim(RETURN,0," ")_")"
 .	Q 
 ;
 Q RETURN
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61282^64286^Dan Russell^2267" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM TMPDQ WHERE PID=:V2
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
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ;
vOpen1() ; FID FROM DBTBL1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL1a0
 S vos4=""
vL1a5 S vos4=$O(^DBTBL(vos3,1,vos4),1) I vos4="" G vL1a3
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; ELEMENT FROM TMPDQ WHERE PID=:V1
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
 I vos1=0 S tmpdqrs="" Q 0
 ;
 S tmpdqrs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V2
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2)
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
 N ERROR,$ET,$ES S ERROR=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 N ER S ER=0
 ;
 WRITE !!,?10," *** Compile error - see error log entry",!
 D ZX^UCGMR(voxMrk) Q 
