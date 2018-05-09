 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSCURS ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSCURS ; 
 ;
 Q 
 ;
MAIN(QNAME,CPID) ; 
 N vTp
 ;
 N %INTRPT N cpCACHE N vzERMSG N vzEXIT N vzHDR N vzREPLY N vzSERVER
 N vzMSG
 ;
 S vzEXIT=0
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 ; Create request/reply queues
 S vzERMSG=$$CQSTART^%DBAPI()
 I '(vzERMSG="") D  Q:vzEXIT 
 .	I vzERMSG="CS_CQEXISTS" Q 
 .	D ERRLOG(vzERMSG)
 .	S vzEXIT=1
 .	Q 
 ;
 ; Connect to transport layer
 S vzERMSG=$$CPCNCT^%DBAPI()
 I '(vzERMSG="") D  Q:vzEXIT 
 .	I vzERMSG="CS_DUPLCNCT" Q 
 .	D ERRLOG(vzERMSG)
 .	S vzEXIT=1
 .	Q 
 ;
 ; Register Cursor Pool process in table SVCTRLCP
 N svctrlcp,vop1,vop2,vop3 S vop2=QNAME,vop1=CPID,svctrlcp=$$vRCgetRecord1Opt^RecordSVCTRLCP(QNAME,CPID,0,.vop3)
 I $G(vop3)=1,$$DECHEX^%ZHEX($J)'=$P(svctrlcp,$C(124),1) D  Q:vzEXIT 
 .	I $$VALID^%ZPID($P(svctrlcp,$C(124),1),1)=0 Q 
 .	S vzERMSG=$$CPDSCNCT^%DBAPI()
 .	D ERRLOG("CS_CPIDEXISTS")
 .	S vzEXIT=1
 .	Q 
 ;
  S $P(svctrlcp,$C(124),1)=$$DECHEX^%ZHEX($J)
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^SVCTRLCP(vop2,vop1)=$$RTBAR^%ZFUNC(svctrlcp) S vop3=1 TC:vTp  
 ;
 ; Register M process
 D REGISTER^IPCMGR("CURSOR")
 ;
 ; Process loop
 F  D  Q:vzEXIT 
 .	;
 .	; Clean up symbol table between loops
 .	;   #ACCEPT Date=11/06/2008; Pgm=RussellDS; CR=36492; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	KILL (%INTRPT,cpCACHE,CPID,QNAME,vzEXIT)
 .	;*** End of code by-passed by compiler ***
 .	;
 .	; Close expired cursors (those that exceed timeout)
 .	D CLOSE(.cpCACHE,$$TIM^PBSUTL($H))
 .	;
 .	; Check interrupt status
 .	I $D(%INTRPT)>1 D INTRPT^IPCMGR
 .	I $get(%INTRPT)="STOP" S vzEXIT=1 Q 
 .	;
 .	; Link new changes.
 .	I $get(%INTRPT)="CTRL" D LINK
 .	;
 .	; Get message from server process
 .	S vzERMSG=$$CPGETMSG^%DBAPI($J,.vzMSG,15)
 .	I vzERMSG="CS_TIMEOUT" Q 
 .	I vzERMSG="CS_NOCNCT" S vzEXIT=1 Q 
 .	;
 .	I '(vzERMSG="") D ERRLOG(vzERMSG) Q 
 .	I ($ZTRANSLATE($get(vzMSG)," ")="") Q 
 .	;
 .	S vzHDR=$ZEXTRACT(vzMSG,1,10)
 .	S vzMSG=$ZEXTRACT(vzMSG,11,1048575)
 .	;
 .	; Execute SQL on behalf of the server process
 .	D EXEC(vzMSG,.vzREPLY,.vzSERVER,.cpCACHE)
 .	;
 .	; Prepend the header to reply message
 .	S vzREPLY=vzHDR_vzREPLY
 .	;
 .	; Reply to server process
 .	S vzERMSG=$$CPREPLY^%DBAPI(vzSERVER,vzREPLY)
 .	I '(vzERMSG="") D ERRLOG(vzERMSG) Q 
 .	Q 
 ;
 ; Close all cursors
 D CLOSE(.cpCACHE,"")
 ;
 ; Remove cursor entries for the process.
  N V1 S V1=$J D vDbDe1()
 ;
 ; Unregister from cursor control table.
  K ^SVCTRLCP(QNAME,CPID)
 ;
 ; Disconnect from transport
 S vzERMSG=$$CPDSCNCT^%DBAPI()
 I '(vzERMSG="") D ERRLOG(vzERMSG)
 ;
 ; Unregister M Process
 D CLOSE^IPCMGR()
 HALT 
 ;
 Q 
 ;
EXEC(MSG,REPLY,SERVERID,cpCACHE) ; 
 N vTp
 ;
 N ptr
 N infld N outfld
 ;
 ; Variables set based on PBSMSQL message
 N %CO N %CRCD N %IDENT N %MSKC N %MSKD N %MSKE N %MSKL N %MSKN
 N %STFHOST N %TOKEN N %UCLS N %UID N %VN N %VNC N clientToken N curName
 N oldCID N sqlcmd N SQLEXPR N SQLPAR N SQLTOK N TJD N TLO N xexpr
 ;
 ; Variables expected as part of return from execute SQL to return to PBSMSQL
 N ER S ER=0
 N %ZTSEQ N RM N SQLCNT N SQLCOD N SQLDTA N SQLIND
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^UTLERR"",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
 ; Parse LV input message into fields
 S ptr=$$LV2V^MSG(MSG,.infld)
 ;
 S xexpr=infld(1) ; Executable string (i.e., "set ER=$$^SQL.." )
 S SERVERID=infld(2) ; Process ID of server
 S clientToken=infld(3) ; Client Token (%TOKEN)
 S %TOKEN=clientToken ; Used by $$^SQL
 S curName=infld(4) ; Cursor Name (ID)
 S sqlcmd=infld(5) ; SQL command (OPEN/FETCH/CLOSE)
 ;
 S SQLEXPR=infld(6)
 I '(infld(7)="") D
 .	;
 .	N i
 .	;
 .	F i=1:2:$L(infld(7),$char(0)) S SQLPAR($piece(infld(7),$char(0),i))=$piece(infld(7),$char(0),i+1)
 .	Q 
 S SQLTOK=infld(8)
 S %CO=infld(9)
 S %CRCD=infld(10)
 S %IDENT=infld(11)
 S %MSKC=infld(12)
 S %MSKD=infld(13)
 S %MSKE=infld(14)
 S %MSKL=infld(15)
 S %MSKN=infld(16)
 S %STFHOST=infld(17)
 S %UCLS=infld(18)
 S %UID=infld(19)
 S %VN=infld(20)
 S %VNC=infld(21)
 S TJD=infld(22)
 S TLO=infld(23)
 ;
 S oldCID=""
 ;
 I sqlcmd="OPEN" D
 .	;
 .	S oldCID=$piece($get(cpCACHE("CURSOR",clientToken,curName)),"|",3)
 .	S $piece(cpCACHE("CURSOR",clientToken,curName),"|",1)=SERVERID
 .	Q 
 E  I ($get(cpCACHE("CURSOR",clientToken,curName))="") D
 .	;
 .	S ER=1
 .	S RM="Cursor "_curName_" is not OPEN"
 .	Q 
 ;
 I 'ER D
 .	S $piece(cpCACHE("CURSOR",clientToken,curName),"|",2)=$$TIM^PBSUTL($H)
 .	;
 .	; Execute SQL statement
 .	D
 ..		;
 ..		; Protect variables we don't want touched
 ..		N clientToken N cpCACHE N curName
 ..		;
 ..		; Execute the call to $$SQL on behalf of the server process.
 ..		;    #ACCEPT PGM=Allan Mattson;DATE=05/13/05;CR=18181
 ..		XECUTE xexpr
 ..		Q 
 .	;
 .	I sqlcmd="OPEN" D
 ..		;
 ..		N ER
 ..		N exe N vsql
 ..		;
 ..		; Need to restore to recover vsql("vCurID")
 ..		D RESTORE^SQLUTL(curName,.vsql,.exe)
 ..		;
 ..		I '(oldCID=""),'($get(vsql("vCurID"))=""),oldCID'=vsql("vCurID") S ER=$$CLOSECUR^%DBAPI("",oldCID)
 ..		;
 ..		; Save RDB cursor ID to be able to close
 ..		S $piece(cpCACHE("CURSOR",clientToken,curName),"|",3)=$get(vsql("vCurID"))
 ..		;
 ..	  K ^SQLCUR(clientToken,curName)
 ..		;
 ..		N sqlcur0,vop1,vop2,vop3,vop4 S sqlcur0="",vop4=0 S vop3=clientToken S vop2=curName S vop1=$J
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^SQLCUR(vop3,vop2,vop1)=$$RTBAR^%ZFUNC(sqlcur0) S vop4=1 TC:vTp  
 ..  Q 
 .	;
 .	I sqlcmd="CLOSE" D
 ..		;
 ..	  K ^SQLCUR(clientToken,curName)
 ..		K cpCACHE("CURSOR",clientToken,curName)
 ..		Q 
 .	Q 
 ;
 S outfld(1)=$get(ER)
 S outfld(2)=$get(RM)
 S outfld(3)=$get(SQLCOD)
 S outfld(4)=$get(SQLDTA)
 S outfld(5)=$get(SQLCNT)
 S outfld(6)=$get(SQLIND)
 S outfld(7)=$get(%ZTSEQ)
 ;
 S REPLY=$$V2LV^MSG(.outfld)
 ;
 Q 
 ;
CREATEQ ; 
 ;
 S ER=1
 S RM="Function not valid for this environment"
 ;
 Q 
 ;
DELETEQ ; 
 ;
 S ER=1
 S RM="Function not valid for this environment"
 ;
 Q 
 ;
START ; 
 ;
 S ER=1
 S RM="Function not valid for this environment"
 ;
 Q 
 ;
STARTEXT(QNAME,CPCNT) ; Number of cursor processes to start
 ;
 ;check other calls to see what we need to return if external call
 ;
 S ER=1
 S RM="Function not valid for this environment"
 ;
 Q 
 ;
STOP ; 
 ;
 S ER=1
 S RM="Function not valid for this environment"
 ;
 Q 
 ;
STOPEXT(QNAME,CPCNT) ; Number of cursor processes to stop
 ;
 S ER=1
 S RM="Function not valid for this environment"
 ;
 Q 
 ;
CHKTBL(QNAME) ; 
 ;
 N CPID
 N LIST N PID
 ;
 D ^%ZPID(.LIST)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 .	;
 . S CPID=$P(rs,$C(9),1)
 . S PID=$P(rs,$C(9),2)
 .	;
 .	I '($D(LIST($$HEXDEC^%ZHEX(PID)))#2)  K ^SVCTRLCP(QNAME,CPID)
 .	Q 
 ;
 Q 
 ;
CLOSE(CACHE,DATETIME) ; 
 ;
 N ER
 N LASTTIME
 N %TOKEN N CURSOR N oldCID
 ;
 S (%TOKEN,CURSOR)=""
 F  S %TOKEN=$order(CACHE("CURSOR",%TOKEN)) Q:(%TOKEN="")  D
 .	F  S CURSOR=$order(CACHE("CURSOR",%TOKEN,CURSOR)) Q:(CURSOR="")  D
 ..		;
 ..		S LASTTIME=$piece(CACHE("CURSOR",%TOKEN,CURSOR),"|",2)
 ..		S oldCID=$piece(CACHE("CURSOR",%TOKEN,CURSOR),"|",3)
 ..		;
 ..		; Cursor timeout has not been exceeded
 ..		I (DATETIME>0),(DATETIME-LASTTIME<300) Q 
 ..		;
 ..		; Close expired cursor
 ..		I '(oldCID="") S ER=$$CLOSECUR^%DBAPI("",oldCID)
 ..		;
 ..		; Clean out the sqlcur0 table.
 ..	  K ^SQLCUR(%TOKEN,CURSOR,$J)
 ..		;
 ..		; Delete cursor entry in CACHE array
 ..		K CACHE("CURSOR",%TOKEN,CURSOR)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
LINK ; link changes specified in the CP control table.
 ;
 N QNAME N CPEXPR
 N CPID N MSEQ N PID
 ;
 S QNAME=$$TRNLNM^%ZFUNC("SCA_CS_ST_SCA_IBS")
 I (QNAME="") D  Q 
 .	;
 .	S ER=1
 .	; ~p1 - Logical not defined
 .	S RM=$$^MSG(7146,"SCA_CS_ST_SCA_IBS")
 .	Q 
 ;
 S PID=$J
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 . S CPEXPR=$P(rs,$C(9),1)
 . S CPID=$P(rs,$C(9),2)
 . S MSEQ=$P(rs,$C(9),3)
 .	;   #ACCEPT PGM=Badri Giridharan;DATE=08/13/06; CR=22684;GROUP=XECUTE
 .	XECUTE CPEXPR
 .	; remove the record after processing.
 .  ZWI ^SVCTRLCP(QNAME,CPID,MSEQ)
 .	Q 
 Q 
ERRLOG(ET) ; 
 ;
 D ^UTLERR
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61380^47623^Badrinath Giridharan^15248" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SQLCUR0 WHERE CPID=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SQLCUR(v1,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; CPID,PID FROM SVCTRLCP WHERE QNAME=:QNAME
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QNAME) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^SVCTRLCP(vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^SVCTRLCP(vos3,vos4))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)
 ;
 Q 1
 ;
vOpen2() ; CPEXPR,CPID,MSEQ FROM SVCTRLTCP WHERE QNAME=:QNAME AND PID=:PID
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QNAME) I vos3="" G vL2a0
 S vos4=$G(PID)
 S vos5=""
vL2a5 S vos5=$O(^SVCTRLCP(vos3,vos5),1) I vos5="" G vL2a0
 S vos6=""
vL2a7 S vos6=$O(^SVCTRLCP(vos3,vos5,vos6),1) I vos6="" G vL2a5
 S vos7=$G(^SVCTRLCP(vos3,vos5,vos6))
 I '(+$P(vos7,"|",2)=+vos4) G vL2a7
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^SVCTRLCP(vos3,vos5,vos6))
 S rs=$P(vos7,"|",1)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen3() ; TOKEN,CURSOR,CPID FROM SQLCUR0 WHERE CPID=:V1
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL3a4 S vos4=$O(^SQLCUR(vos4),1) I vos4="" G vL3a0
 S vos5=""
vL3a6 S vos5=$O(^SQLCUR(vos4,vos5),1) I vos5="" G vL3a4
 I '($D(^SQLCUR(vos4,vos5,vos3))#2) G vL3a6
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_vos3
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 N I
 ;
 S outfld(1)=$get(ER)
 S outfld(2)=$get(RM)
 F I=3:1:6 S outfld(I)=""
 S outfld(7)=$get(%ZTSEQ)
 ;
 S REPLY=$$V2LV^MSG(.outfld)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 D ZE^UTLERR
 S vzERMSG=$$CPDSCNCT^%DBAPI()
 K ^SVCTRLCP(QNAME,CPID)
 D ZX^UCGMR(voxMrk) Q 
