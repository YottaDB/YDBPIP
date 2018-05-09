 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSSRV ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSSRV ; Private;PROFILE(SCA$IBS) Server
 ;
 ; I18N=QUIT
 ;
 Q 
 ;
SVCNCT(vzsvtyp,vzsvid,vzdebug) ; Server debug mode /NOREQ
 N vTp
 ;
 N vzactive N vzlogmsg N vzlogrep N vzsvsec N vztrap
 N vzmaxtim N vzsttim N vztimer N vztimout
 N vzcsid N vzermsg N vzgbldir N vzmsgpgm N vzmtname N vzrole N vzsav N vzsvfap N vzsvfape
 ;
 ; SCA$IBS Servers which are connected to synchronous MTMs
 I vzsvtyp="SCA$IBS" D
 .	;   #ACCEPT PGM=RussellDS;DATE=08/18/2008;CR=unknown
 .	;*** Start of code by-passed by compiler
 .	view "NOISOLATION":"+^DBBUF,^DQRTSTS,^MSGEXC,^MSGLOG,^PBSBBSSP,^SQLCUR,^TMPCACHE"
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 ; Get system role (PRIMARY or SECONDARY)
 S vzrole=$$ROLE^PBSUTL
 ;
 ; If role is PRIMARY, server is active
 I vzrole="PRIMARY" S vzactive=1
 ;
 ; If role is SECONDARY, server is not active
 E  I vzrole="SECONDARY" S vzactive=0
 ;
 ; Any other role is invalid; log an error and quit
 E  D ERRLOG^PBSUTL("SV_INVLDSTS",1) Q 
 ;
 N svtyp,vop1 S svtyp=$$vRCgetRecord1Opt^RecordCTBLSVTYP(vzsvtyp,0,.vop1)
 I $G(vop1)=0 D ERRLOG^PBSUTL("SV_INVLDSVT",'vzactive) Q 
 ;
 S vzsvfap=$P(svtyp,$C(124),2) ; Server FAP ID
 S vzsvfape=vzsvfap ; Copy for traps (see ZTPROC)
 S vzsvsec=$P(svtyp,$C(124),3) ; Security level
 S vzsttim=$P(svtyp,$C(124),5) ; Stat time interval
 S vzlogmsg=$P(svtyp,$C(124),6) ; Log client messages
 S vzlogrep=$P(svtyp,$C(124),7) ; Log server replies
 ;
 ; Will apply to GT.M only
 S vzmaxtim=$P(svtyp,$C(124),8) ; Transaction TP timeout
 I 'vzmaxtim S vzmaxtim=45 ; (default is 45 seconds)
 ;
 ;  #ACCEPT Date=02/05/2009; Pgm=RussellDS; CR=38078; Group=BYPASS
 ;*** Start of code by-passed by compiler
 I $P($ZVERSION,"GT.M V",2)>4 S $zmaxtptime=vzmaxtim
 ;*** End of code by-passed by compiler ***
 ;
 S vztimout=$P(svtyp,$C(124),9) ; Server GETMSG timeout
 I 'vztimout S vztimout=15 ; (default=15 seconds)
 ;
 S vztrap=$P(svtyp,$C(124),10) ; Trap last client message
 S vzmtname=$P(svtyp,$C(124),11) ; Message transport name
 S vzmsgpgm=$P(svtyp,$C(124),12) ; Non-std message handler
 ;
 S vzermsg=$$SVCNCT^%MTAPI(vzsvtyp,.vzcsid,.vzrole,vzmtname)
 I vzermsg'="" D ERRLOG^PBSUTL(vzermsg,'vzactive) Q 
 ;
 N svctrl,vop2,vop3,vop4 S svctrl="",vop4=0
  S vop3=vzsvtyp
  S vop2=vzsvid
  S $P(svctrl,$C(124),1)=$piece(vzcsid,"|",1)
  S $P(svctrl,$C(124),2)=$piece(vzcsid,"|",2)
  S $P(svctrl,$C(124),3)=$$DECHEX^%ZHEX($J)
  S $P(svctrl,$C(124),4)=vzrole
  S $P(svctrl,$C(124),5)=$P($H,",",1)_","_$P($H,",",2)
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^SVCTRL(vop3,vop2)=$$RTBAR^%ZFUNC(svctrl) S vop4=1 TC:vTp  
 ;
 ; Register M process
 D REGISTER^IPCMGR("SERVER",vzsvtyp)
 ;
 ; Execute debug code if applicable
 ;  #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 I $get(vzdebug)'="" XECUTE vzdebug
 ;
 ;Connection complete, continue with Main Processing
 ;
 ; Main process loop
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^UTLERR"",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 S vztimer=$$TIM^PBSUTL($P($H,",",1)_","_$P($H,",",2))+(vzsttim*60)
 S vzsav=$$INIT^PBSUTL
 S vzgbldir=""
 ;
 ;  #ACCEPT Date=02/05/2009; Pgm=RussellDS; CR=38078; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vzgbldir=$ZGBLDIR
 ;*** End of code by-passed by compiler ***
 ;
 D XKILL^PBSUTL
 ;
 ; Initialization complete, continue to Processing Loop
 D LOOP
 ;
 Q 
 ;
LOOP ; Message Processing Loop
 N vTp
 ;
 N %CACHE ; Start cache scoping
 N vzerror N vzlasttjd N vzsrvcls N vzstart N vzstatus N vztime N vztprest
 N %SVCNTXT N %ZTPTRAP N vzerrepl N vzjrnl N vzpkt N vzpktid
 N vzreply N vzrm N vzsvstat
 ;
 N vzcache ; Non-table caching
 ;
 S vzlasttjd=99999 ; Initialize TJD reset timer
 ;
 F  D
 .	;
 .	N vzcltokn N vzcpmsg N vzmssgid
 .	;
 .	; Check Interrupt status to shutdown or process control messages
 .	I $D(%INTRPT)>1 D INTRPT^IPCMGR
 .	I '($get(%INTRPT)="") D
 ..		;
 ..		I %INTRPT="STOP" D CTRLSTOP^PBSUTL
 ..		I %INTRPT="CTRL" D CTRL^PBSUTL(vzsvtyp,vzsvid,vzcsid,.vzactive)
 ..		;
 ..		; Clear Interrupt indicator
 ..		S %INTRPT=""
 ..		Q 
 .	;
 .	; File Server Statistics
 .	D FILSTAT^PBSUTL(vzsvtyp,vzsvid,.vzsvstat,.vztimer)
 .	;
 .	S vzermsg=$$GETMSG^%MTAPI(.vzpkt,.vzpktid,.vzcsid,vztimout)
 .	;
 .	; Timeout error
 .	I vzermsg="CS_TIMEOUT" Q 
 .	;
 .	; Trap last message received for this server process ID
 .	I $get(vztrap) D
 ..	  K ^SVTRAP($J)
 ..		N svtrap S svtrap=$$vcdmNew^RecordSVTRAP()
 ..		 S vobj(svtrap,1,1)=""
 ..	  S vobj(svtrap,-3)=$J
 ..		I vzermsg'=""  S $P(vobj(svtrap),$C(124),1)=vzermsg
 ..	  S vobj(svtrap,1,1)=vzpkt
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSVTRAP(svtrap,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(svtrap,-100) S vobj(svtrap,-2)=1 TC:vTp  
 ..		K vobj(+$G(svtrap)) Q 
 .	;
 .	; Attempt to re-connect
 .	I vzermsg="CS_MTERROR" D
 ..		D ERRLOG^PBSUTL(vzermsg,'vzactive)
 ..		S vzermsg=$$SVDSCNCT^%MTAPI(vzcsid)
 ..		I vzermsg="" S vzermsg=$$SVCNCT^%MTAPI(vzsvtyp,.vzcsid,.vzrole,vzmtname)
 ..		;
 ..		Q 
 .	;
 .	; Switch to PRIMARY role
 .	I vzermsg="CS_MTSECONDARY" D  Q 
 ..		I 'vzactive D FAILOVER^PBSUTL
 ..		Q 
 .	;
 .	; Switch to SECONDARY role
 .	I vzermsg="CS_MTPRIMARY" D  Q 
 ..		I 'vzactive D SHUTDOWN^PBSUTL(vzsvtyp,vzsvid)
 ..		Q 
 .	;
 .	; Fatal error
 .	I vzermsg'="" D  HALT 
 ..	  K ^SVCTRL(vzsvtyp,vzsvid)
 ..		;
 ..		; Unregister M process
 ..		D CLOSE^IPCMGR()
 ..		;
 ..		D ERRLOG^PBSUTL(vzermsg,'vzactive)
 ..		Q 
 .	;
 .	; Check if okay to process (switch to PRIMARY may be in process)
 .	I 'vzactive,'$$OK2PROC^PBSUTL Q 
 .	;
 .	; Transaction start time
 .	S vzstart=$$GETTIM^%ZFUNC
 .	;
 .	; Server context (for use by application for TP restarts)
 .	K %SVCNTXT
 .	;
 .	; Release any outstanding locks
 .	;   #ACCEPT Date=05/15/07; Pgm=RussellDS; CR=unknown; Group=Xecute
 .	XECUTE "lock"
 .	;
 .	S vztprest=0
 .	;
 .	; Transaction start with Client/Server transaction identifier
 . TS (vobj):transactionid="CS"
 .	;
 .	; If transaction is restarted, clean-up symbol table
 .	I $TRestart D
 ..		D XKILL^PBSUTL
 ..		I $get(vzsav)="" S vzsav=$$INIT^PBSUTL
 ..		D VLOD^PBSUTL(vzsav)
 ..		S vztprest=vztprest+1
 ..		Q 
 .	;
 .	S %ZTPTRAP="D ZTPTRAP^PBSSRV ZG "_$ZLEVEL
 .	S (vzerrepl,vzreply)=""
 .	;
 .	; Process the client message - protect with catch block
 .	D
 ..		;
 ..		N vzerrRpt S vzerrRpt=0
 ..		;
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^UTLERR"",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ..		;
 ..		S vzreply=$$PROC(vzpkt,vzsvfap,vzsvsec,.vzsav,vzmsgpgm,0,,.vzcltokn,.vzmssgid,.vzstatus,.vzsrvcls,.vzsvstat,vzstart,vztprest)
 ..		;
 ..		D LOGCMIT
 ..		Q 
 .	;
 .	; If trap back to here, vzreply will be null, since protected
 .	;  in PROC section.  vzerreply set by catch block, so use it.
 .	I (vzreply="") S vzreply=vzerrepl
 .	;
 .	; Release any outstanding locks
 .	;   #ACCEPT Date=05/15/07; Pgm=RussellDS; CR=unknown; Group=Xecute
 .	XECUTE "lock"
 .	;
 .	I $get(vzjrnl)'="" D
 ..		USE vzjrnl
 ..		WRITE !!
 ..		ZWRITE vzpkt,vzreply
 ..		USE 0
 ..		Q 
 .	;
 .	I vzreply'="" D
 ..		S vzermsg=$$REPLY^%MTAPI(.vzreply,vzpktid,vzcsid)
 ..		I vzermsg'="" D ERRLOG^PBSUTL(vzermsg)
 ..		Q 
 .	;
 .	; Clean up cache and reset TJD timer if change directories
 .	;   #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 .	;*** Start of code by-passed by compiler
 .	if $ZGBLDIR'=vzgbldir kill %CACHE,vzcache set vzlasttjd=99999
 .	;*** End of code by-passed by compiler ***
 .	;
 .	D XKILL^PBSUTL
 .	Q 
 ;
 D vKill1("") Q 
 ;
LOGCMIT ; Log and commit
 ;
 N vzkvst S vzkvst=0
 N vztime
 ;
 ; TRollback occured in application, issue new TStart
 I $TLevel=0 TS (vobj):transactionid="CS"
 ;
 ; If we end up here because of a trap, vzstart may not exists
 I '($D(vzstart)#2) D
 .	;
 .	S vzstart=$$GETTIM^%ZFUNC
 .	S vzkvst=1
 .	Q 
 ;
 S vztime=$J((($$GETTIM^%ZFUNC-vzstart)/1000000),0,3)
 ;
 ; Log message in message log
 D LOG^PBSUTL($get(vzcltokn),$get(vzmssgid),$get(vzpkt),$get(vzreply),$get(vzstatus),$get(vzsrvcls),"PBSSRV",$get(vzlogmsg),$get(vzlogrep),vztime,$get(vztprest))
 ;
 ; Update statistics
 I '($get(vzsrvcls)="") D STATS^PBSUTL(.vzsvstat,vzsrvcls,vztime)
 ;
  TC:$TL 
 ;
 I vzkvst K vzstart
 ;
 Q 
 ;
PROC(vzpkt,vzsvfap,vzsvsec,vzsav,vzmsgpgm,vzisagm,vzagmrep,vzcltokn,vzmssgid,vzstatus,vzsrvcls,vzsvstat,vzstart,vztprest) ; TP restarts   /NOREQ/MECH=REFNAM:R
 ;
 ; Required by PBSAGMSG
 ;
 ; Protect MAIN variables
 N vzactive N vzsvid N vztrap
 N vzsttim N vztimer N vztimout
 N vzcsid N vzgbldir N vzjrnl N vzmtname N vzpktid N vzreply N vzrole
 N vzsvtyp N vztime
 ;
 ; Local variables
 N vzcnt N vzerror N vzgrprec N vznum N vzptr
 N vztyp N vzsgn N vzstfflg
 N TOKEN N vzclvrsn N vzcontxt N vzermsg N vzfap
 N vzfaps N vzident N vzinst N vzlang N vzpwd N vzrecord
 N vzstn N vzsvchnl N vzucls N vzuid
 ;
 I '($D(vzisagm)#2) S vzisagm=0
 ;
 ; Initialize status
 S vzstatus=0
 ;
 ; Process non-standard message
 I vzmsgpgm'="" Q $$^PBSNSM(vzpkt,vzmsgpgm,$get(vzstart),$get(vztprest))
 ;
 ; Execute server layer entry FAP
 S vzermsg=$$FAPINP(.vzpkt,vzsvfap)
 I vzermsg'="" D  Q $$FAPOUT(vzermsg,vzsvfap)
 .	S vzstatus=1
 .	I vzisagm S vzagmrep="1|"_vzermsg
 .	Q 
 ;
 ; Parse client msg into hdr/msg(s)
 S vzptr=$$LV2V^MSG(vzpkt,.vzrecord)
 ;
 ; Process header, quit if error
 S vzermsg=$$HDR($get(vzrecord(1)))
 I vzermsg'="" S vzstatus=1 Q $$ERROR($$CSERR^PBSUTL(vzermsg),1,vzisagm,.vzagmrep)
 ;
 ; Update message count statistics; exclude restarts
 I $TRestart=0 S $piece(vzsvstat(vzsrvcls),"|",1)=$piece($get(vzsvstat(vzsrvcls)),"|",1)+1
 ;
 I (vzsrvcls=7) D  Q $$REPLY(vzreply,vzstatus)
 .	;
 .	N vzaghdr
 .	;
 .	S vzaghdr(1)=7
 .	S vzaghdr(2)=vzcltokn
 .	S vzaghdr(3)=vzmssgid
 .	S vzaghdr(4)=vzstfflg
 .	S vzaghdr(5)=vzgrprec
 .	S vzaghdr(6)=vzclvrsn
 .	S vzaghdr(7)=vzident
 .	S vzaghdr(8)=vzsvchnl
 .	;
 .	S vzstatus=$$^PBSAGMSG(.vzaghdr,.vzrecord,.vzreply)
 .	;
 .	; Execute service class layer exit FAP
 .	S vzfap=$piece(vzfaps,"~",vzsrvcls)
 .	S vzreply=$$FAPOUT(.vzreply,vzfap,vzsrvcls,vzstfflg)
 .	Q 
 ;
 ; Check if duplicate message
 S vzreply=$$MSGLOG(vzisagm,.vzagmrep)
 I vzreply'="" Q vzreply
 ;
 S vzfap=""
 S vzcnt=$order(vzrecord(""),-1)
 ;
 ; Non-NMSP message
 I vzsrvcls D
 .	S vzfap=$piece(vzfaps,"~",vzsrvcls)
 .	;
 .	;   #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 .	I vzgbldir'="" S $ZGBLDIR=vzgbldir
 .	Q 
 ;
 ; Process record(s)
 F vznum=2:1:vzcnt D
 .	N vzrm
 .	;
 .	S vzerror=$$EXEC(vzrecord(vznum),.vzrm)
 .	;
 .	I vzerror,'vzstatus D
 ..		S vzstatus=vzerror
 ..		D ERSTAT^PBSUTL(.vzsvstat,vzsrvcls,vzrm)
 ..		Q 
 .	;
 .	S vzreply(vznum)=vzrm
 .	S vzerror(vznum)=vzerror
 .	Q 
 ;
 I vzisagm S vzagmrep=vzerror(vznum)_"|"_vzreply(vznum)
 ;
 ; Format reply(ies)
 F vznum=2:1:vzcnt D
 .	N vzfld N vzst N vzrm
 .	;
 .	S vzst=vzerror(vznum)
 .	S vzrm=vzreply(vznum)
 .	;
 .	; Format rollback message, if applicable
 .	I vzgrprec,vzstatus,'vzst S vzst=2 S vzrm=""
 .	;
 .	S vzfld(1)=vzst
 .	S vzfld(2)=vzrm
 .	S vzrm=$$V2LV^MSG(.vzfld,"",1)
 .	;
 .	; Execute service class layer exit FAP
 .	S vzreply=vzreply_$$FAPOUT(.vzrm,vzfap,vzsrvcls,vzstfflg)
 .	Q 
 ;
 ; Server reply message
 Q $$REPLY(vzreply,vzstatus)
 ;
EXEC(vzrec,vzrm) ; Reply message /MECH=REFNAM:W
 ;
 N now N vzerror
 N vz1 N vz2 N vz3 N vz4 N vz5 N vzctxt N x
 ;
 S vzerror=0
 S ER=0
 S RM=""
 ;
 ; Execute service class layer entry FAP
 S vzrm=$$FAPINP(.vzrec,vzfap,vzsrvcls,vzstfflg) I vzrm'="" Q 1
 ;
 I ($get(%UCLS)'=$get(vzucls)) D vKill1("") K %CACHE
 ;
 I vzsrvcls D
 .	S %IPMODE="NOINT"
 .	S %UID=vzuid
 .	S %UCLS=vzucls
 .	S TLO=vzstn
 .	S vzctxt=$piece(vzcontxt,$char(28),vzsrvcls)
 .	Q 
 E  S vzctxt="/TRUST="_$S(vzsvsec:1,1:0)
 ;
 ; Initialize system variables
 I $get(vzsav)="" S vzsav=$$INIT^PBSUTL
 D VLOD^PBSUTL(vzsav)
 ;
 I ($get(vzlasttjd)="") S vzlasttjd=99999 ; Default
 S now=$P($H,",",2)
 I (((now-vzlasttjd)>30)!((now-vzlasttjd)<0)) D
 .	;
 .	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 .	;
 . I $$vFetch1(),TJD'=rs D
 ..		;
 ..		S vzsav=$$INIT^PBSUTL
 ..		D VLOD^PBSUTL(vzsav)
 ..		;
 ..		; Clear cache on date change
 ..		D vKill1("") K %CACHE,vzcache
 ..		Q 
 .	;
 .	S vzlasttjd=now
 . Q 
 ;
 ;  #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 S %TOKEN=vzcltokn
 S %STFHOST=$$%STFHOST^PBSUTL()
 ;
 ;  #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 S %VNC=vzclvrsn
 ;
 ;  #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 I %VNC="" S %VNC=%VN
 ;
 ;  #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 S %IDENT=vzident
 ;
 ;  #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 S %SVCHNID=vzsvchnl
 ;
 ; Process the record
 D
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGEREXEC^"_$T(+0)_""",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	;
 .	; Protect server variables
 .	;
 .	S vz1=vzsrvcls
 .	S vz2=vzstfflg
 .	S vz3=vzrec
 .	S vz4=vztyp
 .	S vz5=vzctxt
 .	;
 .	S x=vzmssgid
 .	N vzmssgid S vzmssgid=x
 .	;
 .	N vzisagm N vzlogmsg N vzlogrep N vzsvsec
 .	N vzcnt N vzgrprec N vzlasttjd N vznum N vzsrvcls N vzstatus N vzstfflg N vztyp
 .	N vzagmrep N vzclvrsn N vzcltokn N vzcontxt N vzctxt N vzfap
 .	N vzfaptbl N vzpkt N vzrec N vzrecord N vzreply N vzsav
 .	N vzstn N vzsvfap N vzsvstat N vzucls N vzuid
 .	N vzident N vzsvchnl
 .	;
 .	; Execute service class drivers
 .	I (vz1=0) S vzerror=$$^PBSNMSP(.vzrm,vz2,vz3,vz4,vz5) Q 
 .	I (vz1=1) S vzerror=$$^PBSTSSP(.vzrm,vz2,vz3,vz4,vz5,%STFHOST) Q 
 .	I (vz1=2) S vzerror=$$^PBSFSSP(.vzrm,vz2,vz3,vz4,vz5) Q 
 .	I (vz1=3) S vzerror=$$^PBSMRPC(.vzrm,vz2,vz3,vz4,vz5) Q 
 .	I (vz1=5) S vzerror=$$^PBSMSQL(.vzrm,vz2,vz3,vz4,vz5) Q 
 .	I (vz1=6) S vzerror=$$^PBSBBSSP(.vzrm,vz2,vz3,vz4,vz5) Q 
 .	;
 .	; Any other service class is invalid
 .	S vzerror=1
 .	S vzrm=$$CSERR^PBSUTL("SV_INVLDSRV")
 .	Q 
 ;
 I vzerror,vzstfflg S vzerror=$$MSGEXC(.vzrm)
 Q vzerror
 ;
HDR(vzhdr) ; Standard client request header
 ;
 N vzfld N vzx
 ;
 S vzptr=$$LV2V^MSG(vzhdr,.vzfld)
 S vzsrvcls=$get(vzfld(1))
 S vzcltokn=$get(vzfld(2))
 S TOKEN=vzcltokn
 S vzmssgid=$get(vzfld(3))
 S vzstfflg=$get(vzfld(4))
 S vzgrprec=$get(vzfld(5))
 S vzclvrsn=$get(vzfld(6))
 S vzident=$get(vzfld(7))
 S vzsvchnl=$get(vzfld(8))
 ;
 I vzsrvcls="" Q "SV_SVCLSREQ"
 I vzmssgid="" Q "SV_MSGIDREQ"
 ;
 I vzsrvcls=0 S vztyp=0 Q ""
 I vzcltokn="" Q "SV_TOKENREQ"
 ;
 ; Server Error - invalid grp_recs field option
 I (vzsrvcls=7),'((vzgrprec=1)!(vzgrprec=2)!(vzgrprec=3)) Q "SV_INVLGRPRC"
 ;
 N token,vop1 S token=$$vRCgetRecord1Opt^RecordTOKEN(TOKEN,0,.vop1)
 I $G(vop1)=0 Q "SV_INVLDTKN"
 ;
 S vzsgn=$P(token,$C(124),1)
 S vzuid=$P(token,$C(124),2)
 S vzstn=$P(token,$C(124),3)
 S vzpwd=$P(token,$C(124),4)
 S vzfaps=$P(token,$C(124),5)
 S vzucls=$P(token,$C(124),6)
 S vzlang=$P(token,$C(124),7)
 S vzinst=$P(token,$C(124),8)
 S vzgbldir=$P(token,$C(124),9)
 S vzcontxt=$P(token,$C(124),10)
 I vzsvchnl="" S vzsvchnl=$P(token,$C(124),13)
 ;
 I 'vzsgn,'vzstfflg Q "SV_NOTSGNON"
 ;
 ; Determine Native v. Non-Native Client
 ; 0=Native, 1=Non-native
 ;
 I vzfaps'=$char(0) S vztyp=1
 E  S vztyp=0 S vzfaps=""
 Q ""
 ;
REPLY(vzreply,vzstatus) ; Message status code
 ;
 N vzfld N vzhdr N vzpkt
 ;
 S vzfld(1)=$get(vzcltokn)
 S vzfld(2)=$get(vzmssgid)
 S vzfld(3)=$get(vzstatus)
 S vzfld(4)=$get(%VN)
 ;
 S vzhdr=$$V2LV^MSG(.vzfld,"",1)
 S vzpkt=vzhdr_vzreply_$char(0)_$char(0)
 ;
 ; Execute server layer exit FAP
 Q $$FAPOUT(vzpkt,vzsvfap)
 ;
MSGLOG(vzisagm,vzagmrep) ; Aggregage message reply [*]  //NOREQ/MECH=REFNAM:W
 ;
 N ID N ORIGRPLY N TOK
 ;
 I 'vzsrvcls Q ""
 ;
 I '($D(vzisagm)#2) S vzisagm=0
 ;
 ; New message
 S TOK=vzcltokn
 S ID=vzmssgid
 I '($D(^MSGLOG(TOK,ID))#2) Q ""
 ;
 ; Questionable STF transaction; quit w/ original reply
 I vzstfflg=1,'vzisagm D  Q $$REPLY(ORIGRPLY,0)
 .	N msglog,vop1,vop2,vop3,vop4 S vop1=TOK,vop2=ID,vop3=2,msglog=$$vRCgetRecord0Opt^RecordMSGLOGSEQ(TOK,ID,2,0,"")
 .	 S vop4="" N von S von="" F  S von=$O(^MSGLOG(vop1,vop2,vop3,von)) quit:von=""  S vop4=vop4_^MSGLOG(vop1,vop2,vop3,von)
 .	S ORIGRPLY=vop4
 . Q 
 ;
 ; Non-questionable STF transaction; quit w/ duplicate message error
 S vzstatus=1
 Q $$ERROR($$CSERR^PBSUTL("SV_DUPLIMSG"),1,vzisagm,.vzagmrep)
 ;
FAPINP(vzinp,vzfap,vzsrv,vzstf) ; STF flag  /NOREQ
 ;
 N vzermsg S vzermsg=""
 ;
 I vzfap'="" D
 .	N vzpgm N vzx
 .	;
 .	I '($D(vzfaptbl(vzfap))#2) D
 ..		N fap S fap=$$vRCgetRecord0Opt^RecordCTBLFAP(vzfap,0,"")
 ..		S vzfaptbl(vzfap)=$P(fap,$C(124),1)_"|"_$P(fap,$C(124),2)_"|"_$P(fap,$C(124),3)
 ..  Q 
 .	;
 .	S vzpgm=$piece(vzfaptbl(vzfap),"|",2) Q:vzpgm="" 
 .	S vzx=vzpgm_"(.vzinp"
 .	;
 .	I $get(vzsrv) S vzx=vzx_","_vzsrv_","_vzstf
 .	S vzx="S vzermsg="_vzx_")"
 .	;
 .	;   #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 .	XECUTE vzx
 .	Q 
 ;
 Q vzermsg
 ;
FAPOUT(vzout,vzfap,vzsrv,vzstf) ; STF flag  /NOREQ
 ;
 I vzfap'="" D
 .	N vzpgm N vzx
 .	;
 .	I '($D(vzfaptbl(vzfap))#2) D
 ..		N FAP
 ..		S FAP=vzfap
 ..		N fap S fap=$$vRCgetRecord0Opt^RecordCTBLFAP(FAP,0,"")
 ..		S vzfaptbl(vzfap)=$P(fap,$C(124),1)_"|"_$P(fap,$C(124),2)_"|"_$P(fap,$C(124),3)
 ..  Q 
 .	;
 .	S vzpgm=$piece(vzfaptbl(vzfap),"|",3) Q:vzpgm="" 
 .	S vzx=vzpgm_"(.vzout"
 .	;
 .	I $get(vzsrv) S vzx=vzx_","_vzsrv_","_vzstf
 .	S vzx="S vzx="_vzx_")"
 .	;
 .	;   #ACCEPT PGM=Erik Scheetz;DATE=11/22/02;CR=unknown
 .	XECUTE vzx
 .	Q 
 ;
 Q vzout
 ;
ERROR(vzermsg,vzstatus,vzisagm,vzagmrep) ; Aggregate message reply [*]  /NOREQ/MECH=REFNAM:W
 ;
 N vzx
 ;
 S vzx(1)=1
 S vzx(2)=vzermsg
 ;
 I vzisagm S vzagmrep="1|"_vzermsg
 ;
 Q $$REPLY($$V2LV^MSG(.vzx,"",1),vzstatus)
 ;
MSGEXC(vzrm) ; Message
 ;
 I vzcltokn="" S vzrm="" Q 0
 ;
 D msgfil(1,vzpkt)
 D msgfil(2,vzrec)
 D msgfil(3,vzrm)
 ;
 S vzrm=""
 ;
 Q 0
 ;
msgfil(vzkey,vzdata) ; Data
 N vTp
 ;
 N msgexc S msgexc=$$vRCgetRecord1^RecordMSGEXC(vzcltokn,vzmssgid,vzkey,0)
  S vobj(msgexc,1,1)="" N von S von="" F  S von=$O(^MSGEXC(vobj(msgexc,-3),vobj(msgexc,-4),vobj(msgexc,-5),von)) quit:von=""  S vobj(msgexc,1,1)=vobj(msgexc,1,1)_^MSGEXC(vobj(msgexc,-3),vobj(msgexc,-4),vobj(msgexc,-5),von)
 ;
 ; MSGEXC record already exists.
 I $G(vobj(msgexc,-2))=1 K vobj(+$G(msgexc)) Q 
 ;
 ; New MSGEXC record
  S vobj(msgexc,-3)=vzcltokn
  S vobj(msgexc,-4)=vzmssgid
  S vobj(msgexc,-5)=vzkey
  S vobj(msgexc,1,1)=vzdata
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordMSGEXC(msgexc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(msgexc,-100) S vobj(msgexc,-2)=1 TC:vTp  
 ;
 K vobj(+$G(msgexc)) Q 
 ;
ZTPROC() ; Error trap for PROC
 ;
  S vzstatus=1
 ;
 N vmsg
 ;
 ; Filer error - return message
 I $piece($ZS,",",3)="%PSL-E-DBFILER" S vmsg=$piece($ZS,",",4)
 ;
 ; Host error number ~p1. Contact system manager.
 E  S vmsg=$$^MSG(1191,$get(%ZTSEQ))
 ;
 I '($D(vzsvfap)#2) D
 .	;
 .	I ($D(vzsvfape)#2) S vzsvfap=vzsvfape
 .	E  S vzsvfap=""
 .	Q 
 ;
 Q $$ERROR($$ERRMSG^PBSUTL(vmsg),1,$get(vzisagm),.vzagmrep)
 ;
ZTPTRAP ; Error trap for TPTIMEOUT
 ;
 ; If already logged, don't log it again
 I ($get(%ZTSEQ)="") D ZE^UTLERR
 ;
 S vzreply=$$ZTPROC
 ;
 D LOGCMIT
 ;
 Q 
 ;
LOGEREXEC(err) ; Error logging from EXEC
 ;
 ; If filer error - don't log
 I $P(err,",",3)'="%PSL-E-DBFILER" D LOGERR^UTLERR(err)
 ;
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61397^62610^Dan Russell^32222" ; Signature - LTD^TIME^USER^SIZE
 ;
vKill1(ex1) ; Delete objects %CACHE()
 ;
 N n1 S (n1)=""
 F  S n1=$O(%CACHE(n1)) Q:n1=""  K:'((n1=ex1)) vobj(%CACHE(n1))
 Q
 ;
vOpen1() ; TJD FROM CUVAR
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 Q
 ;
vFetch1() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos3=$G(^CUVAR(2))
 S rs=$P(vos3,"|",1)
 S vos1=0
 ;
 Q 1
 ;
vCatch3 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ; Error trap for EXEC
 ;
 TRO:$TL>0 
 ;
 ; Filer error - don't log
 I $P(error,",",3)="%PSL-E-DBFILER" D
 .			;
 .			; Return specifics about the error
 .			S vzrm=$$ERRMSG^PBSUTL($P(error,",",4))
 .			Q 
 ;
 E  D
 .			I ($get(%ZTSEQ)="") D ZE^UTLERR
 .			;
 .			; Host error number ~p1. Contact system manager.
 .			S vzrm=$$ERRMSG^PBSUTL($$^MSG(1191,%ZTSEQ))
 .			Q 
 ;
 S vzerror=1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 TRO:$TL>0 
 ;
 ; Prevent loop
 I $get(vzerrRpt) S $ZE=error,$EC=",U1001,"
 S vzerrRpt=1
 ;
 ; If trap back to here, don't want to also do %ZTPTRAP
 S %ZTPTRAP=""
 ;
 I ($get(%ZTSEQ)="") D ZE^UTLERR
 S vzerrepl=$$ZTPROC
 ;
 ; Handle logging even if error
 D LOGCMIT
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 TRO:$TL>0 
 D ZX^UCGMR(voxMrk) Q 
