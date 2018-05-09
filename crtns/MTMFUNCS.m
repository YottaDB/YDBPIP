MTMFUNCS	;Library;PROFILE Message Transport Manager Functions
	;
	; **** Routine compiled from DATA-QWIK Procedure MTMFUNCS ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
START	;;Start Message Transport Manager
	;
	N %READ N %TAB N MTMID N STARTUP N X
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S MTMID=$$GETMTMID(0) Q:MTMID="" 
	;
	; Get startup file and test to be sure it is valid and readable
	N ctblmtm S ctblmtm=$$vDb2(MTMID)
	S STARTUP=$P(ctblmtm,$C(124),2)
	S X=$$FILE^%ZOPEN(STARTUP,"READ",2)
	;
	; Unable to open start-up file ~p1
	I (+X=0) S ER=1 S RM=$$^MSG(2802,STARTUP) Q 
	CLOSE STARTUP
	;
	WRITE $$CUP^%TRMVT(1,21)
	;
	S ER=$$MTMSTART^%OSSCRPT(STARTUP,MTMID)
	S X=$$^DBSMBAR(30)
	Q 
	;
STOP	;;Stop Message Transport Manager
	;
	N CNTRLD
	N %READ N %TAB N MTMID
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S %TAB("CNTRLD")=".CNTRLD"
	S CNTRLD=1
	S %READ="CNTRLD"
	;
	S MTMID=$$GETMTMID(1)
	Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("STOP",'CNTRLD,MTMID,.RM,0)
	I 'ER S ER="W"
	Q 
	;
SVSTATS	;;Request Message Tranport Manager Server Statistics
	;
	N UPDTDB N ZERO
	N DATE
	N %MODS N %PAGE N %PG N %REPEAT N I N SVTYPS N TIME
	N %READ N %TAB N DATA N IO N MTMID N MTMSVST N SID N VFMQ N VPG N X
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Zero Stats
	S %TAB("ZERO")=".ZEROS"
	S ZERO=0
	;
	; Save stats in database
	S %TAB("UPDTDB")=".SAVESTAT"
	S UPDTDB=0
	S %TAB("IO")=$$IO^SCATAB
	S IO=$I
	S %READ="ZERO,UPDTDB,IO"
	;
	S MTMID=$$GETMTMID(1)
	;
	Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("SVSTAT",+ZERO,MTMID,.RM,0)
	;
	Q:ER 
	;
	I RM'["|" S ER="W" Q  ; No servers connected
	;
	; Display stats and update database
	;
	K DATA
	S DATE=$P($H,",",1)
	S TIME=$P($H,",",2)
	;
	I UPDTDB LOCK +MTMSVST(DATE,MTMID):2 E  S ER=1 S ET="RECLOC" Q 
	;
	F I=1:1 S X=$piece(RM,$$FS,I) Q:X=""  D
	.	;
	.	N ACTIVE N AVG N MIN N MAX N REQ N RESP N TRACKED
	.	N SVTYP
	.	;
	.	S SVTYP=$piece(X,"|",1)
	.	S TRACKED=$piece(X,"|",2)\1000
	.	S ACTIVE=$piece(X,"|",3)
	.	S REQ=$piece(X,"|",4)
	.	S RESP=$piece(X,"|",5)
	.	S AVG=$piece(X,"|",6)/1000
	.	S MIN=$piece(X,"|",7)/1000
	.	S MAX=$piece(X,"|",8)/1000
	.	;
	.	D DFORMAT(.SVTYP,.ACTIVE,.REQ,.RESP)
	.	;
	.	S DATA(I)=SVTYP_"|"_$$TIM^%ZM(TRACKED,"24:60")_"|"_ACTIVE_"|"
	.	S DATA(I)=DATA(I)_REQ_"|"_RESP_"|"_MIN_"|"_MAX_"|"_AVG
	.	;
	.	I UPDTDB,ACTIVE=+ACTIVE D
	..		;
	..		N SEQ
	..		N SAVE
	..		;
	..		S SAVE=TIME_"|"_TRACKED_"|"_ACTIVE_"|"_REQ_"|"_RESP_"|"
	..		S SAVE=SAVE_AVG_"|"_MIN_"|"_MAX
	..		;
	..		N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
	..		I ''$G(vos1),$$vFetch1() S SEQ=rs
	..		E  S SEQ=0
	..		S SEQ=SEQ+1
	..		;
	..		N mtmsvstats,vop1,vop2,vop3,vop4,vop5 S mtmsvstats="",vop4="",vop3="",vop2="",vop1="",vop5=0
	..	 S vop4=DATE
	..	 S vop3=MTMID
	..	 S vop2=SVTYP
	..	 S vop1=SEQ
	..	 S $P(mtmsvstats,$C(124),1)=TIME
	..	 S $P(mtmsvstats,$C(124),2)=TRACKED
	..	 S $P(mtmsvstats,$C(124),3)=ACTIVE
	..	 S $P(mtmsvstats,$C(124),4)=REQ
	..	 S $P(mtmsvstats,$C(124),5)=RESP
	..	 S $P(mtmsvstats,$C(124),6)=AVG
	..	 S $P(mtmsvstats,$C(124),7)=MIN
	..	 S $P(mtmsvstats,$C(124),8)=MAX
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^MTMSVST(vop4,vop3,vop2,vop1)=$$RTBAR^%ZFUNC(mtmsvstats) S vop5=1 Tcommit:vTp  
	..		;
	..		Q 
	.	Q 
	;
	I UPDTDB LOCK -MTMSVST(DATE,MTMID)
	;
	; No servers active for MTM ~p1
	I I=1 S ER=1 S RM=$$^MSG(1985,MTMID) Q 
	;
	S SVTYPS=I-1
	S SID="MTMSVSTATS"
	;
	S %O=2
	I IO'=$I D OPEN^SCAIO I ER Q 
	S %PG=1
	S %PAGE=SVTYPS\15
	I SVTYPS#15 S %PAGE=%PAGE+1
	;
	; Stats - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4316,I)
	;
	F  D  Q:VFMQ="Q" 
	.	S %MODS=((%PG-1)*15)+1
	.	S %REPEAT=$S(%O=4:SVTYPS,1:15)
	.	I %MODS+15>SVTYPS S %REPEAT=SVTYPS#15
	. N vo1 N vo2 N vo3 N vo4 N vo5 D DRV^USID(%O,SID,.vo1,.vo2,.vo3,.vo4,.vo5) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) K vobj(+$G(vo5))
	.	;
	.	Q:VFMQ="Q" 
	.	S %PG=%PG+1
	.	Q 
	;
	K RM
	Q 
	;
CLSTATS	;;Request Message Tranport Manager Client Statistics
	;
	N DATE
	N %MODS N %PAGE N %PG N %REPEAT N I N MAXCNCT N TIME
	N %READ N %TAB N CLCNCT N CLIENTS N DATA N IO N MTMID N SID N VFMQ N VPG N X
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S %TAB("IO")=$$IO^SCATAB
	S IO=$I
	S %READ="IO"
	S MTMID=$$GETMTMID(1)
	;
	Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("CLSTAT","",MTMID,.RM,0)
	Q:ER 
	;
	; Display stats
	K DATA
	S DATE=$P($H,",",1)
	S TIME=$P($H,",",2)
	S CLCNCT=$piece(RM,$$FS,1)
	S MAXCNCT=$piece(RM,$$FS,2)
	S RM=$piece(RM,$$FS,3,9999)
	;
	F I=1:1 S X=$piece(RM,$$FS,I) Q:X=""  D
	.	;
	.	N CNCTTIM N REQ N REQACT N RESP N SRVID N TIMLAST
	.	N CLID
	.	;
	.	S CLID=$piece(X,"|",1)
	.	S CNCTTIM=$piece(X,"|",2)\1000
	.	S TIMLAST=$piece(X,"|",3)/1000
	.	S REQ=$piece(X,"|",4)
	.	S RESP=$piece(X,"|",5)
	.	S REQACT=$piece(X,"|",6)
	.	S SRVID=$piece(X,"|",7)
	.	S REQACT=$S(REQACT=1:"Q",REQACT=2:"S",1:"N")
	.	S SRVID=$S(SRVID<0:"",1:$J(SRVID,2))
	.	S DATA(I)=$E(CLID,1,25)_"|"_$$DISPTIM(CNCTTIM)_"|"
	.	S DATA(I)=DATA(I)_$$DISPTIM(TIMLAST)_"|"
	.	S DATA(I)=DATA(I)_REQ_"|"_RESP_"|"_REQACT_"|"_SRVID
	.	Q 
	;
	S CLIENTS=I-1
	S SID="MTMCLSTATS"
	;
	S %O=2
	I IO'=$I D OPEN^SCAIO I ER Q 
	;
	S %PG=1
	S %PAGE=CLIENTS\15
	I CLIENTS#15 S %PAGE=%PAGE+1
	I '%PAGE S %PAGE=1
	;
	; Stats - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4316,I)
	;
	F  D  Q:VFMQ="Q" 
	.	S %MODS=((%PG-1)*15)+1
	.	S %REPEAT=$S(%O=4:CLIENTS,1:15)
	.	I %MODS+15>CLIENTS S %REPEAT=CLIENTS#15
	. N vo6 N vo7 N vo8 N vo9 N vo10 D DRV^USID(%O,SID,.vo6,.vo7,.vo8,.vo9,.vo10) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8)) K vobj(+$G(vo9)) K vobj(+$G(vo10))
	.	;
	.	Q:VFMQ="Q" 
	.	S %PG=%PG+1
	.	Q 
	;
	K RM
	Q 
	;
PENDING	;;Request Message Tranport Manager Pending Message Info
	;
	N DATE
	N %MODS N %PAGE N %PG N %REPEAT N I N SERVERS N TIME
	N %READ N %TAB N DATA N IO N MTMID N SID N VFMQ N VPG N X
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S %TAB("IO")=$$IO^SCATAB
	S IO=$I
	S %READ="IO"
	S MTMID=$$GETMTMID(1) Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("PEND","",MTMID,.RM,0) Q:ER 
	;
	I RM'["|" S ER="W" Q  ; No servers connected
	;
	; Display pending messages
	K DATA
	S DATE=$P($H,",",1)
	S TIME=$P($H,",",2)
	;
	F I=1:1 S X=$piece(RM,$$FS,I) Q:X=""  D
	.	;
	.	N CONNECT N WAIT
	.	N CLIENT N PRCNM N SVID N SVTYP
	.	;
	.	S SVID=$piece(X,"|",1)
	.	S SVTYP=$piece(X,"|",2)
	.	S PRCNM=$piece(X,"|",3)
	.	S CONNECT=$piece(X,"|",4)\1000
	.	S CLIENT=$piece(X,"|",5)
	.	S WAIT=$piece(X,"|",6)\1000
	.	S WAIT=$S(WAIT:$$DISPTIM(WAIT),1:"")
	.	S DATA(I)=SVID_"|"_PRCNM_"|"_SVTYP_"|"_$$DISPTIM(CONNECT)_"|"
	.	S DATA(I)=DATA(I)_CLIENT_"|"_WAIT
	.	Q 
	;
	S SERVERS=I-1
	S SID="MTMPENDING"
	;
	S %O=2
	I IO'=$I D OPEN^SCAIO I ER Q 
	;
	S %PG=1
	S %PAGE=SERVERS\8
	I SERVERS#8 S %PAGE=%PAGE+1
	;
	; Servers - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4313,I)
	F  D  Q:VFMQ="Q" 
	.	S %MODS=((%PG-1)*8)+1
	.	S %REPEAT=$S(%O=4:SERVERS,1:8)
	.	I %MODS+8>SERVERS S %REPEAT=SERVERS#8
	. N vo11 N vo12 N vo13 N vo14 N vo15 D DRV^USID(%O,SID,.vo11,.vo12,.vo13,.vo14,.vo15) K vobj(+$G(vo11)) K vobj(+$G(vo12)) K vobj(+$G(vo13)) K vobj(+$G(vo14)) K vobj(+$G(vo15))
	.	Q:VFMQ="Q" 
	.	S %PG=%PG+1
	.	Q 
	K RM
	Q 
	;
DELSRV	;;Delete Server from Message Transport Manager
	;
	N %READ N %TAB N MTMID N SVID
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Server ID
	S %TAB("SVID")=".SRVID1/XPP=D DELSRVPP^MTMFUNCS/XPR=D DELSRVPR^MTMFUNCS"
	S %READ="SVID/REQ"
	S MTMID=$$GETMTMID(1) Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("DELSRV",SVID,MTMID,.RM,0) Q:ER 
	;
	S RM=$E(RM,2,99)
	S ER="W"
	Q 
	;
DELSRVPR	; Pre-processor to Server ID prompt.
	;
	N I
	N INFO N X
	;
	Q:($D(VALID)>0) 
	S ER=$$EXCHMSG^%OSSCRPT("PEND","",MTMID,.INFO,1) Q:ER 
	;
	Q:INFO'["|"  ; No servers connected
	F I=1:1 D  Q:X="" 
	.	S X=$piece(INFO,$$FS,I)
	.	I X'="" S VALID($piece(X,"|",1))=$piece(X,"|",3)
	.	Q 
	Q 
	;
DELSRVPP	; Post processor to Server ID prompt.
	;
	N PRCNAM
	;
	Q:X="" 
	S PRCNAM=$get(VALID(X))
	;
	; Invalid server ID
	I PRCNAM="" S ER=1 S RM=$$^MSG(1467) Q 
	I '$$VALIDNM^%OSSCRPT(PRCNAM,1) Q 
	;
	; Process ~p1 is still running.  Stop the server process first.
	S ER=1
	S RM=$$^MSG(2240,PRCNAM)
	;
	Q 
	;
JRNLON	;;Message Transport Manager Journaling On
	;
	N %READ N %TAB N FILE N MSG N MTMID N POST N SVTYP
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Service Type (* = ALL)
	S %TAB("SVTYP")=".SVTYP"
	;
	; Invalid file
	S POST="S %EXT=1 D ^SCAIO I 'ER,IOTYP'=""RMS"" S ER=1,RM=$$^MSG(1332)" ;Invalid file
	;
	; Journal to File
	S %TAB("FILE")=".JRNDEV2/XPP="_POST
	S %READ="SVTYP/REQ,FILE/REQ"
	S MTMID=$$GETMTMID(1) Q:MTMID="" 
	;
	S MSG="1"_$$FS_SVTYP_$$FS_FILE
	S ER=$$EXCHMSG^%OSSCRPT("JRNL",MSG,MTMID,.RM,0) Q:ER 
	S ER="W"
	Q 
	;
JRNLOFF	;;Message Transport Manager Journaling Off
	;
	N %READ N %TAB N MSG N MTMID N SVTYP
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Service Type (* = ALL)
	S %TAB("SVTYP")=".SVTYP"
	S %READ="SVTYP/REQ"
	S MTMID=$$GETMTMID(1)
	Q:MTMID="" 
	;
	S MSG="0"_$$FS_SVTYP
	S ER=$$EXCHMSG^%OSSCRPT("JRNL",MSG,MTMID,.RM,0)
	Q:ER 
	;
	S ER="W"
	Q 
	;
CLLOG	;;Close Log File for Message Transport Manager
	;
	N MTMID
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S MTMID=$$GETMTMID(1)
	Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("CLLOG","",MTMID,.RM,0)
	Q:ER 
	;
	S ER="W"
	Q 
	;
GETMTMID(RUNNING)	;Private;Prompt for a valid MTM ID
	;
	N %PG
	N MTMID N VFMQ
	;
	I $get(%READ)'="" S %READ=","_%READ
	S %TAB("MTMID")=".MTMID/TBL=[CTBLMTM]/XPP=D MTMIDPP^MTMFUNCS(X,$G(RUNNING))"
	S %READ="@@%FN,,MTMID/REQ"_$get(%READ)
	S %PG=-1
	;
	D ^UTLREAD
	I VFMQ="Q" S MTMID=""
	Q MTMID
	;
MTMIDPP(MTMID,RUNNING)	;Private;Post processor for MTMID prompt
	;
	N ctrlmbx
	;
	S ER='$$RUNNING(MTMID,RUNNING)
	Q:ER!'RUNNING 
	;
	I $$UICOK^%OSSCRPT(MTMID) Q 
	S ER=1
	S RM=$$^MSG(2779)
	Q 
	;
RUNNING(MTMID,RUNNING)	;Private;Determine if a specific MTMID is running
	;
	N X
	;
	S X=$$VALIDNM^%OSSCRPT($$PRCNAM(MTMID),RUNNING)
	I 'RUNNING,'X Q 1
	I RUNNING,X Q 1
	;
	; MTM ~p1 is not running
	I RUNNING S RM=$$^MSG(1786,MTMID)
	;
	; MTM ~p1 is already running
	E  S RM=$$^MSG(1785,MTMID)
	;
	Q 0
	;
PRCNAM(MTMID)	;Private;Return process name for an MTM ID (MTM_mtmid)
	;
	Q "MTM_"_MTMID
	;
DISPTIM(TIME)	;Private;Return standard displayable time (hh:mm:ss)
	;
	I $get(TIME)<1 Q "00:00:00"
	Q $$TIM^%ZM(TIME,"24:60:SS")
	;
FS()	;Field separator constant
	Q $char(28)
	;
DFORMAT(SVTYP,ACTIVE,REQ,RESP)	;
	;
	I ACTIVE'=+ACTIVE D
	.	S SVTYP="  "_SVTYP ; Indent a few spaces for server pid
	.	I ACTIVE="U" S ACTIVE="IN_USE" Q 
	.	I ACTIVE="F" S ACTIVE="FREE" Q 
	.	S ACTIVE="???"
	.	Q 
	;
	; REQ can be used for server state
	;
	I REQ'=+REQ D
	.	I REQ="P" S REQ="WAIT" Q 
	.	I REQ="B" S REQ="BUSY" Q 
	.	S REQ="???"
	.	Q 
	;
	; RESP can be used for process state
	;
	I RESP'=+RESP D
	.	I RESP="A" S RESP="ACTIVE" Q 
	.	I (RESP="?")!(RESP="O") S RESP="INACTIVE" Q 
	.	I RESP="W" S RESP="SWAPPED" Q 
	.	I RESP="I" S RESP="IDLE" Q 
	.	I RESP="Z" S RESP="ZOMBIE" Q 
	.	I RESP="T" S RESP="STOPPED" Q 
	.	S RESP="???"
	.	Q 
	;
	; Pre-format the data fields
	;
	S ACTIVE=$J(ACTIVE,6)
	S REQ=$J(REQ,9)
	S RESP=$J(RESP,9)
	Q 
	;
VERSION	; Request Message Tranport Manager Version Info
	;
	N DATE
	N I N %MODS N %PAGE N %PG N %REPEAT N SERVERS
	N DATA N IO N MTMID N %READ N SID N %TAB N VFMQ N VPG N X
	N TIME
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S %TAB("IO")=$$IO^SCATAB
	S IO=$I
	S %READ="IO"
	S MTMID=$$GETMTMID(1) Q:(MTMID="") 
	;
	S ER=$$EXCHMSG^%OSSCRPT("GETVER","",MTMID,.RM,0) Q:ER 
	;
	I RM'["|" S ER="W" Q  ; No servers connected
	;
	; Display version information
	S DATE=$P($H,",",1)
	S TIME=$P($H,",",2)
	F I=1:1 S X=$piece(RM,"|",I) Q:(X="")  S DATA(I)=X
	;
	S SERVERS=I-1
	S SID="MTMVERSION"
	;
	S %O=2
	I IO'=$I D OPEN^SCAIO I ER Q 
	;
	S %PG=1
	S %PAGE=SERVERS\8
	I SERVERS#8 S %PAGE=%PAGE+1
	;
	; Servers - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4313,I)
	;
	F  D  Q:VFMQ="Q" 
	.	S %MODS=((%PG-1)*8)+1
	.	S %REPEAT=$S(%O=4:SERVERS,1:8)
	.	I %MODS+8>SERVERS S %REPEAT=SERVERS#8
	. N vo16 N vo17 N vo18 N vo19 N vo20 D DRV^USID(%O,SID,.vo16,.vo17,.vo18,.vo19,.vo20) K vobj(+$G(vo16)) K vobj(+$G(vo17)) K vobj(+$G(vo18)) K vobj(+$G(vo19)) K vobj(+$G(vo20))
	.	;
	.	Q:VFMQ="Q" 
	.	S %PG=%PG+1
	.	Q 
	K RM
	Q 
	;
PARAM	;;Request Message Tranport Manager Startup Parameter Info
	;
	N DATE
	N %MODS N %PAGE N %PG N %REPEAT N I N TIME
	N %READ N %TAB N DATA N IO N MTMID N SID N VFMQ N VPG
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	S %TAB("IO")=$$IO^SCATAB S IO=$I
	S %READ="IO"
	S MTMID=$$GETMTMID(1) Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("GETPARAM","",MTMID,.RM,0) Q:ER 
	;
	; No servers connected
	I RM'["|" S ER="W" Q 
	;
	; Display MTM parameters
	S DATE=$P($H,",",1)
	S TIME=$P($H,",",2)
	S DATA=RM
	S SID="MTMPARAM"
	;
	S %O=2
	I IO'=$I D OPEN^SCAIO I ER Q 
	;
	S %PG=1
	S %PAGE=1
	S %MODS=1
	S %REPEAT=1
	;
	; Servers - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4313,I)
	F  D  Q:VFMQ="Q" 
	. N vo21 N vo22 N vo23 N vo24 N vo25 D DRV^USID(%O,SID,.vo21,.vo22,.vo23,.vo24,.vo25) K vobj(+$G(vo21)) K vobj(+$G(vo22)) K vobj(+$G(vo23)) K vobj(+$G(vo24)) K vobj(+$G(vo25))
	.	;
	.	Q:VFMQ="Q" 
	.	;
	.	S %PG=%PG+1
	.	Q 
	K RM
	Q 
	;
SVCLEAN	;;Cleanup Server Slots in Message Tranport Manager
	;
	N DATE
	N %MODS N %PAGE N %PG N %REPEAT N I N SVTYPS N TIME
	N %READ N %TAB N DATA N IO N MTMID N SID N VFMQ N VPG N X
	;
	K RM
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Zero Stats
	S %TAB("IO")=$$IO^SCATAB
	S IO=$I
	S %READ="IO"
	;
	S MTMID=$$GETMTMID(1) Q:MTMID="" 
	;
	S ER=$$EXCHMSG^%OSSCRPT("SVCLEAN","",MTMID,.RM,0)
	Q:ER 
	;
	I RM'["|" S ER="W" Q  ; No servers connected
	;
	; Display stats and update database
	K DATA
	S DATE=$P($H,",",1)
	S TIME=$P($H,",",2)
	F I=1:1 S X=$piece(RM,$$FS,I) Q:X=""  D
	.	S DATA(I)=X
	.	Q 
	;
	; No servers active for MTM ~p1
	I I=1 S ER=1 S RM=$$^MSG(1985,MTMID) Q 
	S SVTYPS=I-1
	S SID="MTMSVCLEAN"
	;
	S %O=2
	I IO'=$I D OPEN^SCAIO I ER Q 
	;
	S %PG=1
	S %PAGE=SVTYPS\15
	I SVTYPS#15 S %PAGE=%PAGE+1
	;
	; Stats - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4316,I)
	F  D  Q:VFMQ="Q" 
	.	S %MODS=((%PG-1)*15)+1
	.	S %REPEAT=$S(%O=4:SVTYPS,1:15)
	.	I %MODS+15>SVTYPS S %REPEAT=SVTYPS#15
	.	;
	. N vo26 N vo27 N vo28 N vo29 N vo30 D DRV^USID(%O,SID,.vo26,.vo27,.vo28,.vo29,.vo30) K vobj(+$G(vo26)) K vobj(+$G(vo27)) K vobj(+$G(vo28)) K vobj(+$G(vo29)) K vobj(+$G(vo30))
	.	;
	.	Q:VFMQ="Q" 
	.	;
	.	S %PG=%PG+1
	.	Q 
	;
	K RM
	Q 
	;
	;----------------------------------------------------------------------
GETSTAT	; Get MTM Statistics
	;----------------------------------------------------------------------
	;
	N %READ N %TAB N MTMID N SVTYP
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Service Type (* = ALL)
	S %TAB("SVTYP")=".SVTYP"
	S %READ="SVTYP/REQ"
	S MTMID=$$GETMTMID(1) Q:(MTMID="") 
	;
	S ER=$$EXCHMSG^%OSSCRPT("GETSTAT",SVTYP,MTMID,.RM,0)
	I ER Q 
	;
	N AVGREQ N AVGRPLY N MAXREQ N MAXRPLY N MINREQ N MINRPLY N NUMSRV N SEQ N TOTREQ N TOTRPLY
	N ETIME N I N REC N STIME N X
	;
	F I=1:1 S X=$piece(RM,$$FS,I) Q:(X="")  D
	.	;
	.	S SVTYP=$piece(X,"|",1)
	.	S SEQ=$O(^MTMSTAT(+$H,MTMID,SVTYP))
	.	N mtmstat,vop1,vop2,vop3,vop4,vop5 S mtmstat="",vop4=+$H,vop3=MTMID,vop2=SVTYP,vop1=SEQ,vop5=0
	. S $P(mtmstat,$C(124),1)=$piece(X,"|",2)
	. S $P(mtmstat,$C(124),2)=$piece(X,"|",3)
	. S $P(mtmstat,$C(124),3)=$piece(X,"|",4)
	. S $P(mtmstat,$C(124),8)=$piece(X,"|",5)
	. S $P(mtmstat,$C(124),9)=$$^SCARND(($piece(X,"|",6)/1000),,,,5)
	. S $P(mtmstat,$C(124),10)=$$^SCARND(($piece(X,"|",7)/1000),,,,5)
	. S $P(mtmstat,$C(124),11)=$$^SCARND(($piece(X,"|",8)/1000),,,,5)
	. S $P(mtmstat,$C(124),4)=$piece(X,"|",9)
	. S $P(mtmstat,$C(124),5)=$$^SCARND(($piece(X,"|",10)/1000),,,,5)
	. S $P(mtmstat,$C(124),6)=$$^SCARND(($piece(X,"|",11)/1000),,,,5)
	. S $P(mtmstat,$C(124),7)=$$^SCARND(($piece(X,"|",12)/1000),,,,5)
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^MTMSTAT(vop4,vop3,vop2,vop1)=$$RTBAR^%ZFUNC(mtmstat) S vop5=1 Tcommit:vTp  
	.	Q 
	;
	S ER="W" S RM="MTM statistics Updated"
	Q 
	;
	;----------------------------------------------------------------------
STRTSTAT	; Start MTM Stats Collecting
	;----------------------------------------------------------------------
	;
	N %READ N %TAB N MTMID N SVTYP
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Service Type (* = ALL)
	S %TAB("SVTYP")=".SVTYP"
	S %READ="SVTYP/REQ"
	S MTMID=$$GETMTMID(1) Q:(MTMID="") 
	;
	S ER=$$EXCHMSG^%OSSCRPT("STARTSTAT",SVTYP,MTMID,.RM,0)
	I 'ER S ER="W" S RM="MTM statistics started"
	Q 
	;
	;----------------------------------------------------------------------
STOPSTAT	; Stop MTM Stats Collecting
	;----------------------------------------------------------------------
	;
	N %READ N %TAB N MTMID N SVTYP
	;
	I '$$PRIVMTM^%ZFUNC S ER=1 Q 
	;
	; Service Type (* = ALL)
	S %TAB("SVTYP")=".SVTYP"
	S %READ="SVTYP/REQ"
	S MTMID=$$GETMTMID(1) Q:(MTMID="") 
	;
	S ER=$$EXCHMSG^%OSSCRPT("STOPSTAT",SVTYP,MTMID,.RM,0)
	I 'ER S ER="W" S RM="MTM statistics stopped"
	Q 
	;
vSIG()	;
	Q "60682^34115^Pete Chenard^24234" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1)	;	voXN = Db.getRecord(CTBLMTM,,0)
	;
	N ctblmtm
	S ctblmtm=$G(^CTBL("MTM",v1))
	I ctblmtm="",'$D(^CTBL("MTM",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CTBLMTM" X $ZT
	Q ctblmtm
	;
vOpen1()	;	SEQ FROM MTMSVSTATS WHERE DATE=:DATE AND MTMID=:MTMID AND SVTYPE=:SVTYP ORDER BY SEQ DESC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(DATE) I vos2="" G vL1a0
	;
	S vos3=$G(MTMID) I vos3="" G vL1a0
	S vos4=$G(SVTYP) I vos4="" G vL1a0
	S vos5=""
vL1a6	S vos5=$O(^MTMSVST(vos2,vos3,vos4,vos5),-1) I vos5="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
