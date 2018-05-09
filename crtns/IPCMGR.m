IPCMGR	;
	;
	; **** Routine compiled from DATA-QWIK Procedure IPCMGR ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
REGISTER(PRCTYP,SUBTYP)	;
	;
	Tstart (vobj):transactionid="CS"
	;
	N procid S procid=$$vDb1($J)
	;
	S $P(vobj(procid),$C(124),6)=PRCTYP
	S $P(vobj(procid),$C(124),7)=$get(SUBTYP)
	S $P(vobj(procid),$C(124),1)=$P($H,",",1)
	S $P(vobj(procid),$C(124),2)=$P($H,",",2)
	;
	I $$INTRACT^%ZFUNC S $P(vobj(procid),$C(124),3)="INTERACTIVE"
	E  S $P(vobj(procid),$C(124),3)="DETACHED"
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
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^PROCFILE(procid,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(procid,-100) S vobj(procid,-2)=1 Tcommit:vTp  
	;
	 N V1 S V1=$J D vDbDe1()
	;
	Tcommit:$Tlevel 
	;
	; Define common interrupt handler
	S $zinterrupt="do INTRPT^IPCMGR"
	K vobj(+$G(procid)) Q 
	;
ISSUE(ACTREQ,QUALIF,SELECT)	;
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
	.	N procid S procid=$$vDb1(PID)
	.	I $G(vobj(procid,-2))=0 K vobj(+$G(procid)) Q 
	.	;
	.	I '$$SELECT(.procid,.SELECT) K vobj(+$G(procid)) Q 
	.	D SIGNAL(vobj(procid,-3),ACTREQ,QUALIF)
	.	K vobj(+$G(procid)) Q 
	;
	E  D
	.	;
	.	N ds,vos1,vos2 S ds=$$vOpen1()
	.	;
	.	F  Q:'($$vFetch1())  D
	..		N procid
	..		S procid=$$vDb1(ds)
	..		;
	..		I '$$SELECT(.procid,.SELECT) K vobj(+$G(procid)) Q 
	..		D SIGNAL(vobj(procid,-3),ACTREQ,QUALIF)
	..		K vobj(+$G(procid)) Q 
	.	Q 
	Q 
	;
SIGNAL(PID,ACTREQ,QUALIF)	;
	;
	N X
	;
	; Start transaction
	Tstart (vobj):transactionid="CS"
	;
	N procact S procact=$$vDbNew1("","")
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
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^PROCAFIL(procact,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(procact,-100) S vobj(procact,-2)=1 Tcommit:vTp  
	;
	; Commit transaction
	Tcommit:$Tlevel 
	;
	; Send interrupt to process
	S X=$$INTRPT^%ZFUNC(PID)
	K vobj(+$G(procact)) Q 
	;
INTRPT	; Process interrupt ($ZINTERRUPT)
	;
	N ACTREQ N QUALIF
	;
	N procid S procid=$$vDb2($J)
	;
	N ds,vos1,vos2,vos3  N V1 S V1=$J S ds=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	N STATUS S STATUS="PROCESSED"
	.	N procact S procact=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2))
	.	;
	.	S ACTREQ=$P(vobj(procact),$C(124),1)
	.	S QUALIF=$P(vobj(procact),$C(124),2)
	.	;
	.	D
	..		;  Check for alredy processed interrupts
	..		I '($get(%INTRPT(vobj(procact,-4)))="") Q 
	..		;
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
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
	..		Tstart (vobj):transactionid="CS"
	..		I '($get(%INTRPT(vobj(procact,-4)))="") S $P(vobj(procact),$C(124),3)=$piece(%INTRPT(vobj(procact,-4)),"|",1)
	..		E  S $P(vobj(procact),$C(124),3)=STATUS
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^PROCAFIL(procact,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(procact,-100) S vobj(procact,-2)=1 Tcommit:vTp  
	..		D JNL(.procid,.procact)
	..	 Tcommit:$Tlevel 
	..		;
	..		K %INTRPT(vobj(procact,-4))
	..		Q 
	.	;
	.	E  S %INTRPT(vobj(procact,-4))=STATUS_"|"_$P($H,",",1)_"|"_$P($H,",",2)
	.	;
	.	K vobj(+$G(procact)) Q 
	K vobj(+$G(procid)) Q 
	;
JOBEXAM(FILE)	;
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
JNL(procid,procact)	;
	;
	N DAT
	N PID N SEQ
	;
	S DAT=$P($H,",",1)
	S PID=$J
	S SEQ=$O(^PROCJNL(DAT,PID,""),-1)+1
	;
	N procjnl S procjnl=$$vDbNew2("","","")
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
	. S $P(vobj(procjnl),$C(124),20)=$piece(%INTRPT(vobj(procact,-4)),"|",2)
	. S $P(vobj(procjnl),$C(124),21)=$piece(%INTRPT(vobj(procact,-4)),"|",3)
	.	Q 
	E  D
	. S $P(vobj(procjnl),$C(124),20)=$P($H,",",1)
	. S $P(vobj(procjnl),$C(124),21)=$P($H,",",2)
	.	Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^PROCJFIL(procjnl,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(procjnl,-100) S vobj(procjnl,-2)=1 Tcommit:vTp  
	;
	 N V1 S V1=vobj(procact,-4) ZWI ^PROCACT(PID,V1)
	;
	K vobj(+$G(procjnl)) Q 
	;
CLOSE(PID)	;
	;
	I ($get(PID)="") S PID=$J
	;
	Tstart (vobj):transactionid="CS"
	ZWI ^PROCID(PID)
	D vDbDe2()
	Tcommit:$Tlevel 
	Q 
	;
SETATTS(ATTS)	; Attributes to modify  /MECH=REFARR:R
	;
	N PID S PID=$J
	;
	N procid S procid=$$vDb1(PID)
	;
	I ($D(ATTS("PRCTYP"))#2) S $P(vobj(procid),$C(124),6)=ATTS("PRCTYP")
	I ($D(ATTS("SUBTYP"))#2) S $P(vobj(procid),$C(124),7)=ATTS("SUBTYP")
	I ($D(ATTS("FUNC"))#2) S $P(vobj(procid),$C(124),10)=ATTS("FUNC")
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^PROCFILE(procid,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(procid,-100) S vobj(procid,-2)=1 Tcommit:vTp  
	;
	K vobj(+$G(procid)) Q 
	;
SELECT(procid,SELECT)	;
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
INTTEST(PID)	; Test Interrupt Mechanism
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
INTLIST	; Listing of entries in PROCESSID
	;
	N oslist
	N cnt0 S cnt0=0 N cnt1 S cnt1=0
	N pid
	;
	D ^%ZPID(.oslist)
	;
	N rs,vos1,vos2 S rs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S pid=rs
	.	I ($get(oslist(pid))="") S cnt0=cnt0+1
	.	E  S cnt1=cnt1+1
	.	WRITE !,pid,$char(9),$get(oslist(pid))
	.	Q 
	;
	WRITE !!,"Valid PROCESSID entries: "_cnt1
	WRITE !,"Invalid PROCESSID entries: "_cnt0
	Q 
	;
CLEANPID	; Clean up PROCESSID entries that are no longer active
	;
	N rs,vos1,vos2 S rs=$$vOpen4()
	N cnt S cnt=0
	N pid
	;
	F  Q:'($$vFetch4())  D
	.	S pid=rs
	.	I $$VALID^%ZPID(pid) Q 
	.	D CLOSE(pid)
	.	S cnt=cnt+1
	.	Q 
	;
	WRITE !!,"Number of PROCESSID entries removed: "_cnt
	Q 
	;
vSIG()	;
	Q "60739^33736^Dan Russell^11432" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM PROCESSACT WHERE PID=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^PROCACT(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM PROCESSACT WHERE PID=:PID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^PROCACT(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(PROCESSID,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSID"
	S vobj(vOid)=$G(^PROCID(v1))
	I vobj(vOid)="",'$D(^PROCID(v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb2(v1)	;	vobj()=Db.getRecord(PROCESSID,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSID"
	S vobj(vOid)=$G(^PROCID(v1))
	I vobj(vOid)="",'$D(^PROCID(v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,PROCESSID" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb3(v1,v2)	;	vobj()=Db.getRecord(PROCESSACT,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSACT"
	S vobj(vOid)=$G(^PROCACT(v1,v2))
	I vobj(vOid)="",'$D(^PROCACT(v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(PROCESSACT)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSACT",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(PROCESSJNL)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordPROCESSJNL",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	PID FROM PROCESSID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^PROCID(vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	PID,SEQNUM FROM PROCESSACT WHERE PID=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^PROCACT(vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	PID FROM PROCESSID
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=""
vL3a2	S vos2=$O(^PROCID(vos2),1) I vos2="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen4()	;	PID FROM PROCESSID
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=""
vL4a2	S vos2=$O(^PROCID(vos2),1) I vos2="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen5()	;	PID,SEQNUM FROM PROCESSACT WHERE PID=:V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^PROCACT(vos2,vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	PID,SEQNUM FROM PROCESSACT WHERE PID=:PID
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(PID) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^PROCACT(vos2,vos3),1) I vos3="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N vzerror S vzerror=$ZS
	S STATUS="FAILED"
	Q 
