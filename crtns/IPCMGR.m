 ; 
 ; **** Routine compiled from DATA-QWIK Procedure IPCMGR ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;
 Q 
 ;
REGISTER(PRCTYP,SUBTYP) ; /NOREQ/MECH=VAL
 N vTp
 ;
 TS (vobj):transactionid="CS"
 ;
 N procid S procid=$$vRCgetRecord1^RecordPROCESSID($J,0)
 ;
  S $P(vobj(procid),$C(124),6)=PRCTYP
  S $P(vobj(procid),$C(124),7)=$get(SUBTYP)
  S $P(vobj(procid),$C(124),1)=$P($H,",",1)
  S $P(vobj(procid),$C(124),2)=$P($H,",",2)
 ;
 I $$INTRACT^%ZFUNC  S $P(vobj(procid),$C(124),3)="INTERACTIVE"
 E   S $P(vobj(procid),$C(124),3)="DETACHED"
 ;
  S $P(vobj(procid),$C(124),4)=$$TLO^UTLO()
  S $P(vobj(procid),$C(124),5)=$$USERNAM^%ZFUNC
 ;
  S $P(vobj(procid),$C(124),8)=$get(%UID)
  S $P(vobj(procid),$C(124),9)=$get(%UCLS)
 ;
  S $P(vobj(procid),$C(124),10)=$get(%FN)
  S $P(vobj(procid),$C(124),11)=$get(%EVENT)
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordPROCESSID(procid,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(procid,-100) S vobj(procid,-2)=1 TC:vTp  
 ;
  N V1 S V1=$J D vDbDe1()
 ;
  TC:$TL 
 ;
 ; Define common interrupt handler
 S $zinterrupt="do INTRPT^IPCMGR"
 K vobj(+$G(procid)) Q 
 ;
ISSUE(ACTREQ,QUALIF,SELECT) ; /NOREQ/MECH=REFARR:R
 ;
 N PID
 ;
 S QUALIF=$get(QUALIF)
 ;
 ; Signal specified PID
 S PID=$get(SELECT("PID"))
 ;
 I '(PID="") D
 .	;
 .	N procid S procid=$$vRCgetRecord1^RecordPROCESSID(PID,0)
 .	I $G(vobj(procid,-2))=0 K vobj(+$G(procid)) Q 
 .	;
 .	I '$$SELECT(.procid,.SELECT) K vobj(+$G(procid)) Q 
 .	D SIGNAL(vobj(procid,-3),ACTREQ,QUALIF)
 .	K vobj(+$G(procid)) Q 
 ;
 E  D
 .	;
 .	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
 .	;
 .	F  Q:'$$vFetch1()  D
 ..		N procid
 ..  S procid=$$vRCgetRecord1^RecordPROCESSID(ds,1)
 ..		;
 ..		I '$$SELECT(.procid,.SELECT) K vobj(+$G(procid)) Q 
 ..		D SIGNAL(vobj(procid,-3),ACTREQ,QUALIF)
 ..		K vobj(+$G(procid)) Q 
 . Q 
 Q 
 ;
SIGNAL(PID,ACTREQ,QUALIF) ; Action Qualifier /NOREQ/MECH=VAL
 N vTp
 ;
 N X
 ;
 ; Start transaction
 TS (vobj):transactionid="CS"
 ;
 N procact S procact=$$vcdmNew^RecordPROCESSACT()
 ;
  S vobj(procact,-3)=PID
  S vobj(procact,-4)=$O(^PROCACT(PID,""),-1)+1
 ;
  S $P(vobj(procact),$C(124),1)=ACTREQ
  S $P(vobj(procact),$C(124),2)=$get(QUALIF)
  S $P(vobj(procact),$C(124),3)="ISSUED"
 ;
  S $P(vobj(procact),$C(124),4)=$J
  S $P(vobj(procact),$C(124),5)=$P($H,",",1)
  S $P(vobj(procact),$C(124),6)=$P($H,",",2)
 ;
  S $P(vobj(procact),$C(124),8)=$$TLO^UTLO
  S $P(vobj(procact),$C(124),7)=$$USERNAM^%ZFUNC
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordPROCESSACT(procact,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(procact,-100) S vobj(procact,-2)=1 TC:vTp  
 ;
 ; Commit transaction
  TC:$TL 
 ;
 ; Send interrupt to process
 S X=$$INTRPT^%ZFUNC(PID)
 K vobj(+$G(procact)) Q 
 ;
INTRPT ; Process interrupt ($ZINTERRUPT)
 N vTp
 ;
 N ACTREQ N QUALIF
 ;
 N procid S procid=$$vRCgetRecord0^RecordPROCESSID($J,0)
 ;
 N ds,vos1,vos2,vos3,vos4  N V1 S V1=$J S ds=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 .	N STATUS S STATUS="PROCESSED"
 . N procact S procact=$$vRCgetRecord1^RecordPROCESSACT($P(ds,$C(9),1),$P(ds,$C(9),2),1)
 .	;
 .	S ACTREQ=$P(vobj(procact),$C(124),1)
 .	S QUALIF=$P(vobj(procact),$C(124),2)
 .	;
 .	D
 ..		;  Check for alredy processed interrupts
 ..		I '($get(%INTRPT(vobj(procact,-4)))="") Q 
 ..		;
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ..		;
 ..		; Job examination
 ..		I ACTREQ="EXAM" D JOBEXAM(QUALIF) Q 
 ..		;
 ..		; Execute M code
 ..		I ACTREQ="EXEC" D  Q 
 ...			;
 ...			;     #ACCEPT Date=03/21/07; PGM=EWS; CR=15677
 ...			XECUTE QUALIF
 ...			Q 
 ..		;
 ..		; Turn M trace 'on'
 ..		I ACTREQ="TRACE" D TRACE^SCAUTL(QUALIF) Q 
 ..		;
 ..		; Stop message (shutdown)
 ..		I ACTREQ="STOP" S %INTRPT="STOP" Q 
 ..		;
 ..		I ACTREQ="CTRL" S %INTRPT="CTRL" Q 
 ..		;
 ..		Q 
 .	;
 .	I $TLevel=0 D
 ..		;
 ..	 TS (vobj):transactionid="CS"
 ..		I '($get(%INTRPT(vobj(procact,-4)))="")  S $P(vobj(procact),$C(124),3)=$piece(%INTRPT(vobj(procact,-4)),"|",1)
 ..		E   S $P(vobj(procact),$C(124),3)=STATUS
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordPROCESSACT(procact,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(procact,-100) S vobj(procact,-2)=1 TC:vTp  
 ..		D JNL(.procid,.procact)
 ..	  TC:$TL 
 ..		;
 ..		K %INTRPT(vobj(procact,-4))
 ..		Q 
 .	;
 .	E  S %INTRPT(vobj(procact,-4))=STATUS_"|"_$P($H,",",1)_"|"_$P($H,",",2)
 .	;
 .	K vobj(+$G(procact)) Q 
 K vobj(+$G(procid)) Q 
 ;
JOBEXAM(FILE) ; 
 ;
 N RESULT
 ;
 I '(FILE="") S FILE=FILE_"_"_$J
 ;
 ;  #ACCEPT Date=03/21/07; PGM=EWS; CR=15677; Group=Bypass
 ;*** Start of code by-passed by compiler
 set RESULT=$zjobexam(FILE)
 ;*** End of code by-passed by compiler ***
 Q 
 ;
JNL(procid,procact) ; 
 N vTp
 ;
 N DAT
 N PID N SEQ
 ;
 S DAT=$P($H,",",1)
 S PID=$J
 S SEQ=$O(^PROCJNL(DAT,PID,""),-1)+1
 ;
 N procjnl S procjnl=$$vcdmNew^RecordPROCESSJNL()
 ;
  S vobj(procjnl,-3)=DAT
  S vobj(procjnl,-4)=PID
  S vobj(procjnl,-5)=SEQ
 ;
  S $P(vobj(procjnl),$C(124),1)=$P(vobj(procid),$C(124),1)
  S $P(vobj(procjnl),$C(124),2)=$P(vobj(procid),$C(124),2)
  S $P(vobj(procjnl),$C(124),3)=$P(vobj(procid),$C(124),3)
 ;
  S $P(vobj(procjnl),$C(124),4)=$P(vobj(procid),$C(124),4)
  S $P(vobj(procjnl),$C(124),5)=$P(vobj(procid),$C(124),5)
  S $P(vobj(procjnl),$C(124),6)=$P(vobj(procid),$C(124),6)
  S $P(vobj(procjnl),$C(124),7)=$P(vobj(procid),$C(124),7)
  S $P(vobj(procjnl),$C(124),8)=$P(vobj(procid),$C(124),8)
  S $P(vobj(procjnl),$C(124),9)=$P(vobj(procid),$C(124),9)
 ;
  S $P(vobj(procjnl),$C(124),10)=$P(vobj(procid),$C(124),10)
  S $P(vobj(procjnl),$C(124),11)=$P(vobj(procid),$C(124),11)
 ;
  S $P(vobj(procjnl),$C(124),12)=$P(vobj(procact),$C(124),1)
  S $P(vobj(procjnl),$C(124),13)=$P(vobj(procact),$C(124),2)
  S $P(vobj(procjnl),$C(124),14)=$P(vobj(procact),$C(124),3)
  S $P(vobj(procjnl),$C(124),15)=$P(vobj(procact),$C(124),4)
  S $P(vobj(procjnl),$C(124),16)=$P(vobj(procact),$C(124),5)
  S $P(vobj(procjnl),$C(124),17)=$P(vobj(procact),$C(124),6)
  S $P(vobj(procjnl),$C(124),18)=$P(vobj(procact),$C(124),7)
  S $P(vobj(procjnl),$C(124),19)=$P(vobj(procact),$C(124),8)
 ;
 I '($get(%INTRPT(vobj(procact,-4)))="") D
 .  S $P(vobj(procjnl),$C(124),20)=$piece(%INTRPT(vobj(procact,-4)),"|",2)
 .  S $P(vobj(procjnl),$C(124),21)=$piece(%INTRPT(vobj(procact,-4)),"|",3)
 .	Q 
 E  D
 .  S $P(vobj(procjnl),$C(124),20)=$P($H,",",1)
 .  S $P(vobj(procjnl),$C(124),21)=$P($H,",",2)
 .	Q 
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordPROCESSJNL(procjnl,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(procjnl,-100) S vobj(procjnl,-2)=1 TC:vTp  
 ;
  N V1 S V1=vobj(procact,-4)  ZWI ^PROCACT(PID,V1)
 ;
 K vobj(+$G(procjnl)) Q 
 ;
CLOSE(PID) ; 
 ;
 I ($get(PID)="") S PID=$J
 ;
 TS (vobj):transactionid="CS"
  ZWI ^PROCID(PID)
 D vDbDe2()
  TC:$TL 
 Q 
 ;
SETATTS(ATTS) ; Attributes to modify  /MECH=REFARR:R
 N vTp
 ;
 N PID S PID=$J
 ;
 N procid S procid=$$vRCgetRecord1^RecordPROCESSID(PID,0)
 ;
 I ($D(ATTS("PRCTYP"))#2)  S $P(vobj(procid),$C(124),6)=ATTS("PRCTYP")
 I ($D(ATTS("SUBTYP"))#2)  S $P(vobj(procid),$C(124),7)=ATTS("SUBTYP")
 I ($D(ATTS("FUNC"))#2)  S $P(vobj(procid),$C(124),10)=ATTS("FUNC")
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordPROCESSID(procid,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(procid,-100) S vobj(procid,-2)=1 TC:vTp  
 ;
 K vobj(+$G(procid)) Q 
 ;
SELECT(procid,SELECT) ; Selection Criteria /NOREQ/MECH=REFARR:R
 ;
 I '$$VALID^%ZPID(vobj(procid,-3)) D CLOSE(vobj(procid,-3)) Q 0
 ;
 I '($get(SELECT("MODE"))=""),$P(vobj(procid),$C(124),3)'=SELECT("MODE") Q 0
 I '($get(SELECT("USRNAM"))=""),$P(vobj(procid),$C(124),5)'=SELECT("USRNAM") Q 0
 ;
 I '($get(SELECT("PRCTYP"))=""),$P(vobj(procid),$C(124),6)'=SELECT("PRCTYP") Q 0
 I '($get(SELECT("SUBTYP"))=""),$P(vobj(procid),$C(124),7)'=SELECT("SUBTYP") Q 0
 ;
 I '($get(SELECT("USERID"))=""),$P(vobj(procid),$C(124),8)'=SELECT("USERID") Q 0
 I '($get(SELECT("USRCLS"))=""),$P(vobj(procid),$C(124),9)'=SELECT("USRCLS") Q 0
 ;
 I '($get(SELECT("FUNC"))=""),$P(vobj(procid),$C(124),10)'=SELECT("FUNC") Q 0
 I '($get(SELECT("EVENT"))=""),$P(vobj(procid),$C(124),11)'=SELECT("EVENT") Q 0
 ;
 Q 1
 ;
INTTEST(PID) ; Test Interrupt Mechanism
 ;
 D SYSVAR^SCADRV0()
 N TLO S TLO=$$TLO^UTLO()
 ;
 D REGISTER("USER","TEST")
 ;
 I ($get(PID)="") S PID=$J
 D SIGNAL(PID,"EXEC","write !!,""Process Interrupted Successfully"",!!")
 ;
 D CLOSE()
 Q 
 ;
INTLIST ; Listing of entries in PROCESSID
 ;
 N oslist
 N cnt0 S cnt0=0 N cnt1 S cnt1=0
 N pid
 ;
 D ^%ZPID(.oslist)
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . S pid=rs
 .	I ($get(oslist(pid))="") S cnt0=cnt0+1
 .	E  S cnt1=cnt1+1
 .	WRITE !,pid,$char(9),$get(oslist(pid))
 .	Q 
 ;
 WRITE !!,"Valid PROCESSID entries: "_cnt1
 WRITE !,"Invalid PROCESSID entries: "_cnt0
 Q 
 ;
CLEANPID ; Clean up PROCESSID entries that are no longer active
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen4()
 N cnt S cnt=0
 N pid
 ;
 F  Q:'$$vFetch4()  D
 . S pid=rs
 .	I $$VALID^%ZPID(pid) Q 
 .	D CLOSE(pid)
 .	S cnt=cnt+1
 .	Q 
 ;
 WRITE !!,"Number of PROCESSID entries removed: "_cnt
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60739^33736^Dan Russell^11436" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM PROCESSACT WHERE PID=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^PROCACT(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM PROCESSACT WHERE PID=:PID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^PROCACT(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; PID FROM PROCESSID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^PROCID(vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; PID,SEQNUM FROM PROCESSACT WHERE PID=:V1
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
vL2a4 S vos4=$O(^PROCACT(vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; PID FROM PROCESSID
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL3a3 S vos3=$O(^PROCID(vos3),1) I vos3="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen4() ; PID FROM PROCESSID
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL4a3 S vos3=$O(^PROCID(vos3),1) I vos3="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen5() ; PID,SEQNUM FROM PROCESSACT WHERE PID=:V1
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL5a4 S vos4=$O(^PROCACT(vos3,vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; PID,SEQNUM FROM PROCESSACT WHERE PID=:PID
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PID)
 S vos4=""
vL6a4 S vos4=$O(^PROCACT(vos3,vos4),1) I vos4="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
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
 N vzerror,$ET,$ES S vzerror=$ZE,$EC="",$ET="Q",$ZE=""
 S STATUS="FAILED"
 D ZX^UCGMR(voxMrk) Q 
