%RTAPI	;Library;Library of message transport APIs to Digital RTR
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/30/99 13:14:00 - MATTSON
	; ORIG:  Chenard - 12/17/97
	;
	;----------------------------------------------------------------------
	;
	; UNIX Version
	;
	; This routine provides a library of standard PROFILE application 
	; programming interface (API) calls to be used for Digital's Reliable 
	; Transport Router (RTR). 
	;
	; The logical name SCA$CS_RTR must be defined to point to the target 
	; task for connection.  The form should be
	;
	; KEYWORDS:	System services
	;
	;   DEFINE SCA$CS_RTR "/profile_dir/RTR.INI"
	;
	;  LIBRARY:  . $$CLCNCT		- Client Connect
	;            . $$CLDSCNCT	- Client Disconnect
	;            . $$EXCHMSG	- Client Exchange Message
	;            . $$SVCNCT		- Server Connect
	;            . $$SVDSCNCT	- Server Disconnect
	;            . $$GETMSG		- Server Get_Message
	;            . $$REPLY		- Server Reply_Message
	;            . $$MTMSTART	- Start up an MTM Process
	;            . $$MTMCNTRL	- MTM Control Message Sequence
	;
	;---- Revision History ------------------------------------------------
	; 06/21/99 - Allan Mattson - 33633
	;            Modified GETMSG to support the ability to specify errors
	;            as fatal or non-fatal.  Note that this change requires a
	;            complimentary change to routine CGMSSRV (under the same
	;            ARQ - 33633).
	;
	; 03/15/99 - Harsha Lakshmikantha - 25662
	;	     Uncommented the line of code in GETMSG section used to 
	;	     handle a non operational facility (FACDEAD). Also changed
	;	     CS_RTR_ERROR to CS_RTERROR for a non-specific error to
	;	     ensure consistency.
	;
	; 12/30/98 - Phil Chenard - 25662
	;            Added status code for new RTR event subscription, FACDEAD,
	;            for handling of situations when a facility has become
	;            non operational.  Also modified the SVCNCT external call
	;            to include additional argument for primary/secondary
	;            role determination.
	;
        ; 12/08/98 - Phil Chenard - 25662
        ;            Added status codes in GETMSG for determining state
        ;            changes, primary to secondary, & vice versa.
	;
	; 12/17/97 - Phil Chenard
	;            Created this routine, as a copy of ^%MTAPI.  The API
	;            calls are the same however they now execute code that
	;            communicates with the RTR.
	;
	;----------------------------------------------------------------------
CLCNCT(id)	;System;Client connect to transport
	;----------------------------------------------------------------------
	;
	; Allows connection of a client to the message transport layer.  Using
	; SCAMTM, the id identifies the socket descriptor.
	; In the case of error, id contains the error message.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . id	Error message is returned if error occurs
	;
	; RETURNS:
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, id will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$CLCNCT^%RTAPI(.ID)
	;----------------------------------------------------------------------
	N ERRNO,LIST,STATUS,TASK
	S ERRNO=0
	S LIST=$$SCA^%TRNLNM("CS_RTR")  
	I LIST="" S id="" Q "CS_RTRLOG"
	;
	F I=1:1:$L(LIST,",") S TASK=$P(LIST,",",I) D  Q:'ERRNO
	.	S id=""
	.	D &rtr.ClConnect(TASK,.ERRNO)
	;
	I ERRNO=0 S id=1 S STATUS=""				;Success
	E  D
	.	E  I ERRNO=-15007590 S STATUS="RTR_STS_INVFLAGS"
	.	E  I ERRNO=-16121702 S STATUS="RTR_STS_INVCHANAM"
	.	E  I ERRNO=-7798630 S STATUS="RTR_STS_INVFACNAM"
	.	E  I ERRNO=-15204198 S STATUS="RTR_STS_INVRCPNAM"
	.	E  I ERRNO=-15073126 S STATUS="RTR_STS_INVEVTNUM"
	.	E  I ERRNO=-7733094 S STATUS="RTR_STS_INVACCESS"
	.	E  S STATUS="RTR_STS_ERROR"
	;
	Q STATUS
	;	
	;----------------------------------------------------------------------
CLDSCNCT(id)	;System;Client disconnect from transport
	;----------------------------------------------------------------------
	;
	; Disconnects a client from the message transport layer.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . id	Error message is returned if error occurs
	;
	; RETURNS:
	;     . Condition value	NULL = success
	;		CS_RTERROR = general error, id will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	;     . RM	Failure reason if return is CS_RTERROR    
	;
	; EXAMPLE:
	;	S X=$$CLDSCNCT^%RTAPI(ID)
	;
	;----------------------------------------------------------------------
	N ERRNO,STATUS
	S ERRNO=0
	S STATUS=""
	S id=1
	D &rtr.ClDisconnect(.ERRNO)
	I ERRNO=0 S id=1 S STATUS=""
	E  D
	.	S STATUS="CS_RTERROR"
	.	I ERRNO=-14942054 S STATUS="RTR_STS_INVCHANNEL"
	.	I ERRNO=-15007590 S STATUS="RTR_STS_INVFLAGS"
	Q STATUS
	;
	;----------------------------------------------------------------------
EXCHMSG(msg,reply,srvtyp,id,timeout)	;System;Client exchange message
	;----------------------------------------------------------------------
	;
	; Sends a client message to the host for processing by a valid server,
	; and returns a reply to the message.
	;
	; The reply message from the server may itself be an error message,
	; either a specific CS_* error or a general error.  In either case,
	; an error message is preceeded by a 1 (a good reply by a 0).  For
	; these types of error messages, return either the CS_* error or
	; a CS_RTERROR with the info in the reply field, as appropriate.
	;
	; For a CS_RTRCNCT failure (failure on send), disconnect and try to
	; reconnect and resend the message.
	;
	; For a CS_TIMEOUT failure try to reconnect.  If succeed, report at
	; timeout, otherwise, report as CS_TIMEOUTNC.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . msg	Message to server	
	;
	;     . reply	Response from server	
	;
	;     . srvtyp	Service type needed	
	;               The service type identifies what type of server is
	;               required to process this message.
	;
	;     . id	Error message is returned if error occurs
	;
	;     . timeout	Timeout interval	
	;		Time to wait before giving up and returning a timeout
	;		error message.
	;
	; RETURNS:	
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, reply will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$EXCHMSG^%RTAPI(.MSG,.REPLY,"*",.%CSID,15)
	;----------------------------------------------------------------------
	;
	N ERRNO
	S ERRNO=0
	S reply="    "
	I '$G(timeout) S timeout=30
	S msg=srvtyp_$C(28)_msg
	D &rtr.ClExchmsg(.msg,.reply,timeout,.ERRNO)
	;
	;I ERRNO=0 S reply=$E(reply,2,99999) Q ""	;Success
	I ERRNO=0 Q ""					;Success
	;
	S reply="RTR Error" Q "CS_RTERROR"
	I ERRNO=-16121702 S reply="Invalid Channel" Q "CS_RTR_INVCHNL"
	I ERRNO=-15007590 S reply="Invalid Flags" Q "CS_RTR_INVFLGS"
	I ERRNO=-13565798 S reply="Timeout" Q "CS_RTR_TIMOUT"
	;
	;
	Q "CS_RTERROR"
	;
	;----------------------------------------------------------------------
SVSTART(jobnam,svtyp,svid)	;System;Start up a server process
	;----------------------------------------------------------------------
	Q $$^%ZJOB(jobnam,svtyp_svid)
	;
	;----------------------------------------------------------------------
SVCNCT(srvtyp,id,role)	;System;Server connect to transport
	;----------------------------------------------------------------------
	;
	; Allows connection of a server to the message transport layer.
	;
	; Passes an ADDSRV message to the RTR
	; If the connection is successful, the server process is attached
   	; to the RTR shared memory section and the RTR server and control queues.
	;
	; KEYWORDS:	
	;
	; ARGUMENTS:
	;     . srvtyp	Service type		/TYP=T/LEN=20/MECH=VAL
	;               Defines the type of service this server offers.
	;               Messages from clients are directed to specific server
	;               types, and will be routed on the basis of this
	;               argument.
	;
	;     . id	Connect ID		/TYP=T/REQ/MECH=REF:RW
	;		identify this server. Not used.
	;
	;     . role	Role code returned for server status, PRIMARY or
	;               SECONDARY, anything else is UNKNOWN
	;					 /TYP=T/MECH=REFNAM:RW
	;
	; RETURNS:
	;     . Condition value		
	;		NULL        = 	success
	;		CS_SVTYP    = 	No logical name defined for service type
	;		CS_NORTR    = 	RTR process is not active or does not
	;			       		respond
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	;     . id	always set to null as it is not used in the Unix version.
	;
	; EXAMPLE:
	;	S X=$$SVCNCT^%RTAPI(SVTYP,.ID)
	;
	;----------------------------------------------------------------------
	;
	N ERRNO,ROLE,STATUS
	;
	S (id,ROLE,role,STATUS)=""
	S ERRNO=0
	;
	D &rtr.SrvConnect(srvtyp,.id,.ROLE,.ERRNO)
	;
	I ERRNO=0 D
	.	;
	.	; Define server ID
	.	S srvtyp=$TR(srvtyp,"$","_")
	.	S id=$$SCA^%TRNLNM("CS_ST_"_srvtyp)_"|"_srvtyp_"_"_id
	.	;
	.	I ROLE=108 S role="PRIMARY" Q
	.	I ROLE=109 S role="SECONDARY" Q
	.	I ROLE=110 S role="SECONDARY" Q
	.	S role="UNKNOWN"
	;
	; Set up error condition w/ explanation in $ZSTATUS
	E  S STATUS="CS_RTERROR",$ZS=ERRNO_",SVCNCT^%RTAPI,"_STATUS
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
SVDSCNCT(id)	;System;Server disconnect from transport
	;----------------------------------------------------------------------
	;
	; Disconnects a client from the message transport layer.
	;
	; Passes an DELSRV message to the RTR that is identified by the
	; first element of the ID (RTRNAME|idnumber) through the RTR's control
	; mailbox.  There is no reply sent from the server.
	;
	; KEYWORDS:	
	;
	; ARGUMENTS:
	;
	;     . id	Connect ID		
	;       The id parameter is made up of the RTRNAME plus the
	;		server id number (RTRNAME|idnumber).
	;
	; RETURNS:
	;     . Condition value		
	;		NULL = always
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$SVDSCNCT^%RTAPI(ID)
	;
	;----------------------------------------------------------------------
	;
	D &rtr.SrvDisconnect()
	S ID=0
	S vzcsid=1
	Q ""
	;
	;----------------------------------------------------------------------
GETMSG(msg,msgid,id,timeout)	;System;Server get message from client
	;----------------------------------------------------------------------
	;
	; Gets a message that was sent from a client and destined for the
	; server class of this server.  The message is retreived through a
	; an external C all that pauses waiting for a signal from the RTR that a
	; message is available in shared memory (i.e. Service Class Queue).
	;
	; KEYWORDS:	
	;
	; ARGUMENTS:
	;     . msg	Message to server	
	;
	;     . msgid	ID of client		
	;		Not used in UNIX version
	;
	;     . id	Server's ID		
	;		Not used in UNIX version
	;
	;     . timeout	Timeout interval	
	;		Time to wait without receiving a message before
	;		returning a timeout error message.
	;
	; RETURNS:
	;     . Condition value		
	;		NULL	   = success
	;		CS_TIMEOUT = timeout occurred
	;		CS_MTERROR = UNIX error, msg holds error message
	;		CS_RTRSTOP = RTR stopped, forced server stop
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$GETMSG(.MSG,.MSGID,SRVID,60)
	;
	;----------------------------------------------------------------------
	;
	I '$G(timeout) S timeout=60
	N ERRNO,STATUS
	;
	S (msg,STATUS)=""
	S ERRNO=0
	S msgid=1
	;
	D &rtr.SrvGetMsg(.msg,timeout,.ERRNO)
	;
	I $E(msg,1,12)="*CS_RTRSTOP*" S msg="RTR stopped" Q "CS_MTERROR"
	;
	I ERRNO'=0 D
	.	;
	.	;  Mask as timeout
	.	I ERRNO=-13565798 S STATUS="CS_TIMEOUT" Q
	.	I ERRNO>0,ERRNO<13,ERRNO'=10 S STATUS="CS_TIMEOUT" Q
	.	;
	.	; Events important to application
	.	I ERRNO=97 S STATUS="CS_FACDEAD" Q
	.	I ERRNO=108 S STATUS="CS_MTPRIMARY" Q
	.       I ERRNO=109 S STATUS="CS_MTSECONDARY" Q
	.       I ERRNO=110 S STATUS="CS_MTSECONDARY" Q
	.	;
	.	; Fatal events/errors
	.	I $D(^UTBL("RTRFATAL",ERRNO)) D  Q
	..		S STATUS="CS_FATAL"
	..		S $ZS=ERRNO_",GETMSG^%RTAPI,"_STATUS
	..		;
	.	; Non-fatal events/errors
	.	S STATUS="CS_RTERROR"
	.	S $ZS=ERRNO_",GETMSG^%RTAPI,"_STATUS
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
REPLY(reply,msgid,id)	;System;Server send reply message to client
	;----------------------------------------------------------------------
	;
	; Sends a reply message to a client in response to a message received
	; by the server.  
	; This is done through use of a an external C Call that places the
	; reply message in shared memory (i.e. queue) and then
	; signals the RTR that a server reply message is pending.
	;
	; KEYWORDS:	
	;
	; ARGUMENTS:
	;     . reply	Reply message to client	
	;
	;     . msgid	ID of client		
	;		Not used in UNIX version
	;
	;     . id	Server's ID		
	;		Not used in UNIX version
	;
	; RETURNS:
	;     . Condition value		
	;		NULL         = success
	;
	; EXAMPLE:
	;	S X=$$REPLY^%RTAPI(.REPLY,MSGID,SRVID)
	;
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS
	S ERRNO=0
	S STATUS=""
	D &rtr.SrvReply(reply,.ERRNO)
	;
	I ERRNO'=0 S STATUS="CS_RTERROR",$ZS=ERRNO_",REPLY^%RTAPI,"_STATUS
	Q STATUS
	;
	;----------------------------------------------------------------------
MTMSTART(MTMID)	;Public;Start up an MTM Process
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;	. INPUT		MTM ID
	;
	; RETURNS:
	;	. Success or Failure
	;
	; EXAMPLE:
	;	S X=$$MTMSTART^%MFUNC("V50UXDEV") => X = 1 (Success)
	;
	N MTMEXEC
	; Get path name of MTM executable
	S MTMEXEC=$P($G(^CTBL("MTM",MTMID)),"|",2)
	; Verify that the executable exits
	S X=$$FILE^%ZOPEN(MTMEXEC,"READ",2)
	; Unable to open executable
	I 'X S ER=1,RM=$$^MSG(2802,MTMEXEC) Q 0
	C MTMEXEC
	;
	W $$CUP^%TRMVT(1,21)
	ZSY MTMEXEC		; Start the MTM detached
	Q $ZSYSTEM
	;
	;----------------------------------------------------------------------
MTMCNTRL(cmd,params,reply,mtmid);System;MTM/Server exchange control message
	;----------------------------------------------------------------------
	;
	; Sends a control message to the MTM as specified by mtmid.
	;
	; ARGUMENTS:
	;     . cmd	MTM Control command
	;
	;     . params Control commands args
	;
	;     . reply	Reply from MTM on status of command
	;
	;     . mtmid	Unique MTM id 
	;
	; RETURNS:	
	;		NULL         = success
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;		CS_MTERROR = general error, reply will contain message
	;
	; EXAMPLE:
	;	S X=$$MTMCNTRL^%MTAPI("STOP",1,.reply,"V50UNIX")
	;
	N ERRNO
	S ERRNO=0
	S reply="    "
	D &rtr.MTMCntrl(cmd,params,mtmid,.reply,.ERRNO)
	;
	I ERRNO=0 Q 0						;Success
	I ERRNO=-16 Q 0
	I ERRNO=-17 Q 0
	I ERRNO=-18 Q 0
	I ERRNO=83 S reply="CS_TIMEOUT" Q 1 ;No reply message received from MTM
	E  D
	.	I ERRNO>0 S reply=$ZM(ERRNO)	;UNIX Failure 
	.	E  I ERRNO=-10 S reply="Journaling is enabled." 
	.	E  I ERRNO=-11 S reply="Journaling is disabled." 
	.	E  I ERRNO=-12 S reply="Journaling is not enabled." 
	.	E  I ERRNO=-14 S reply="No clients connected." 
	.	E  I ERRNO=-15 S reply="Journaling enable flag is invalid." 
	.	E  I ERRNO=-19 S reply="No active servers." 
	W $$CUP^%TRMVT(1,24)
	Q 1
	;
	;----------------------------------------------------------------------
MTMEXCHMSG(CMD,PARAMS,MTMID,RM,NOP)	;Private;Exchange message with an MTM
	;
	; ARGUMENTS:
	;	. CMD		Command			
	;
	;	. PARAMS	Message parameters	
	;				Each parameter is separated by a FS
	;
	;	. MTMID		MTM to send to		
	;
	;	. RETURN	Response		
	;
	;	. NOP		Not used in UNIX
	;
	; RETURNS:
	;
	;	. Status indicator	
	;			0 = success, reply is in RETURN
	;			1 = failure, RM is in RETURN
	;
	; EXAMPLE:
	;	S ER=$$EXCHMSG("STOP",1,"ABC",.REPLY,0)
	;
	;
	S X=0
	W $$CUP^%TRMVT(1,24),$$CLL^%TRMVT
	;  Waiting for response from MTM ~p1 .  Control-Z to abort.
	W $$^MSG(4304,MTMID)
	S X=$$MTMCNTRL(CMD,PARAMS,.RM,MTMID) 
	Q X
	;
	;----------------------------------------------------------------------
SVSTATS(MTMID,RM,UPDTDB)	;Public;Display MTM Server Statistics
	;
	; ARGUMENTS:
	;	. MTMID		MTM Identifier
	;	. RM		Response from MTM
	;	. UPDTDB	Update Database 1=Yes 0=No
	;
	; RETURNS:
	;	. VOID 
	;
	; EXAMPLE:
	;	S ER=$$MTMSVSTATS^%MFUNC("MTM_V50UXDEV",MSG,0)
	;
	N X,DATE,TIME,DATA,I
	S X=$H,DATE=+X,TIME=$P(X,",",2)
	I UPDTDB L +^RTRSVST(DATE,MTMID):2 E  S ET="RECLOC" Q 1
	F I=1:1 S X=$P(RM,"(",I) Q:X=""  D
	.	S SVTYP=$P(X,"|",1),TRACKED=$P(X,"|",2),ACTIVE=$P(X,"|",3)
	.	S REQ=$P(X,"|",4),RESP=$P(X,"|",5),AVG=$P(X,"|",6)/1000
	.	S MIN=$P(X,"|",7)/1000,MAX=$P(X,"|",8)/1000
	.	S DATA(I)=SVTYP_"|"_TRACKED_"|"_ACTIVE_"|"
	.	S DATA(I)=DATA(I)_REQ_"|"_RESP_"|"_MIN_"|"_MAX_"|"_AVG
	.	I UPDTDB D
	..		S SAVE=TIME_"|"_TRACKED_"|"_ACTIVE_"|"_REQ_"|"_RESP_"|"
	..		S SAVE=SAVE_AVG_"|"_MIN_"|"_MAX
	..		S SEQ=$ZP(^RTRSVST(DATE,MTMID,SVTYP,""))+1
	..		S ^MTMSVST(DATE,MTMID,SVTYP,SEQ)=SAVE
	;
	I UPDTDB L -^MTMSVST(DATE,MTMID)
	; No servers active for MTM ~p1
	I I=1 S RM=$$^MSG(1985,MTMID) Q 1
	S SVTYPS=I-1
	S SID="RTRSVSTATS" D ^USID
	I PGM="" S ET="INVLDSCR" D ^UTLERR Q 1
	S %O=2 I IO'=$I D OPEN^SCAIO I ER Q
	S %PG=1
	S %PAGE=SVTYPS\15 I SVTYPS#15 S %PAGE=%PAGE+1
	; Stats - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4316,I)
	F  D  Q:VFMQ="Q"
	.	S %MODS=%PG-1*15+1
	.	S %REPEAT=$S(%O=4:SVTYPS,1:15)
	.	I %MODS+15>SVTYPS S %REPEAT=SVTYPS#15
	.	D ^@PGM
	.	Q:VFMQ="Q"
	.	S %PG=%PG+1
	;
	Q 1
	;
	;----------------------------------------------------------------------
CLSTATS(RM)	;Public;Display MTM Client Statistics
	;
	; ARGUMENTS:
	;	. MTMRESPONSE		MTM Identifier
	;
	; RETURNS:
	;
	;	. 1 (SUCCESS) or 0 (FAILURE)
	;
	; EXAMPLE:
	;	S ER=$$CLSTATS^%MFUNC(MTMRESPONSE)
	;
	N I
	S X=$H,DATE=+X,TIME=$P(X,",",2)
	S CLCNCT=$P(RM,"|",1),MAXCNCT=$P(RM,"|",2),RM=$P(RM,"|",3,9999)
	F I=1:1 S X=$P(RM,"(",I) Q:X=""  D
	.	S CLID=$P(X,"|",1),CNCTTIM=$P(X,"|",2)
	.	S TIMLAST=$P(X,"|",3),REQ=$P(X,"|",4),RESP=$P(X,"|",5)
	.	S REQACT=$P(X,"|",6),SRVID=$P(X,"|",7)
	.	S REQACT=$S(REQACT=1:"Q",REQACT=2:"S",1:"N")
	.	S SRVID=$S(SRVID<0:"",1:$J(SRVID,2))
	.	S DATA(I)=$E(CLID,1,25)_"|"_CNCTTIM_"|"
	.	S DATA(I)=DATA(I)_TIMLAST_"|"
	.	S DATA(I)=DATA(I)_REQ_"|"_RESP_"|"_REQACT_"|"_SRVID
	;
	S CLIENTS=I-1
	S SID="MTMCLSTATS" D ^USID
	I PGM="" S ET="INVLDSCR",ER=1 D ^UTLERR Q
	S %O=2 I IO'=$I D OPEN^SCAIO I ER Q
	S %PG=1
	S %PAGE=CLIENTS\15 I CLIENTS#15 S %PAGE=%PAGE+1
	I '%PAGE S %PAGE=1
	; Stats - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4316,I)
	F  D  Q:VFMQ="Q"
	.	S %MODS=%PG-1*15+1
	.	S %REPEAT=$S(%O=4:CLIENTS,1:15)
	.	I %MODS+15>CLIENTS S %REPEAT=CLIENTS#15
	.	D ^@PGM
	.	Q:VFMQ="Q"
	.	S %PG=%PG+1
	Q 1
	;
	;----------------------------------------------------------------------
PENDING(RM)	;Public;Display pending messages from clients to servers
	;
	; ARGUMENTS:
	;	. RM		MTM Identifier
	;
	; RETURNS:
	;
	;	. 1 (SUCCESS) or 0 (FAILURE)
	;
	; EXAMPLE:
	;	S ER=$$PENDING^%MTAPI(MTMRESPONSE)
	;
	N X,TIME,I,SVTYP,PRCNAM,CONNECT,CLIENT,WAIT,SERVERS
	K DATA
	;
	S X=$H,DATE=+X,TIME=$P(X,",",2)
	F I=1:1 S X=$P(RM,"(",I) Q:X=""  D
	.	S SVID=$P(X,"|",1),SVTYP=$P(X,"|",2),PRCNM=$P(X,"|",3)
	.	S CONNECT=$P(X,"|",4),CLIENT=$P(X,"|",5)
	.	S WAIT=$P(X,"|",6)\60
	.	S DATA(I)=SVID_"|"_PRCNM_"|"_SVTYP_"|"_CONNECT_"|"
	.	S DATA(I)=DATA(I)_CLIENT_"|"_WAIT
	;
	S SERVERS=I-1
	S SID="MTMPENDING" D ^USID
	I PGM="" S ET="INVLDSCR",ER=1 D ^UTLERR Q
	S %O=2 I IO'=$I D OPEN^SCAIO I ER Q
	S %PG=1
	S %PAGE=SERVERS\8 I SERVERS#8 S %PAGE=%PAGE+1
	; Servers - Page ~p1
	F I=1:1:%PAGE S VPG(I)=$$^MSG(4313,I)
	F  D  Q:VFMQ="Q"
	.	S %MODS=%PG-1*8+1
	.	S %REPEAT=$S(%O=4:SERVERS,1:8)
	.	I %MODS+8>SERVERS S %REPEAT=SERVERS#8
	.	D ^@PGM
	.	Q:VFMQ="Q"
	.	S %PG=%PG+1
	Q 1
	;
	;----------------------------------------------------------------------
MTMIDPP(MTMID,RUNNING)	;Public;Post processor for MTMID prompt
	;
	; ARGUMENTS:
	;	. MTMID		ID of MTM requested	
	;
	;	. RUNNING	Indicator if requesting		
	;			running (1) or non-running (0) MTMs.
	;
	; OUTPUT:
	;	. ER		Error flag		
	;
	;	. RM		Error message		
	;
	S ER='$$RUNNING(MTMID,RUNNING)
	Q:ER!'RUNNING
	;
	Q
	;
	;----------------------------------------------------------------------
RUNNING(MTMID,RUNNING)	;Private;Determine if a specific MTMID is running
	;
	; This function determines if a particular MTM is currently running,
	; or not.  
	;
	; If RUNNING=1, request is to see if the MTM is running, in which case
	; return of 1 is Yes, 0 is no.
	;
	; If RUNNING=0, request is to see if the MTM is not running, in which
	; case return of 1 is Yes, 0 is no.
	;
	; ARGUMENTS:
	;	. MTMID		ID of MTM requested	
	;
	;	. RUNNING	1 = Is it running?	
	;				0 = Is it not running?
	;
	; RETURNS:
	;	. Status			
	;
	;	. RM		Message on status = 0	
	;
	; EXAMPLE:
	;	S X=$$RUNNING("ABC",1) - to see if MTM ID ABC is running
	;	S X=$$RUNNING("ABC",0) - to see if MTM ID ABC is not running
	;
	N RC
	S RC=0
	D &rtr.MTMRunning(MTMID,RUNNING,.RC)
	;
	I RC Q 1
	;
	; MTM ~p1 is not running
	I RUNNING S RM=$$^MSG(1786,MTMID)
	; MTM ~p1 is already running
	E  S RM=$$^MSG(1785,MTMID)
	Q 0
	;
	;----------------------------------------------------------------------
DELSRV(MTMID,RM)	;Public;Post processor for MTMID prompt
	;
	; ARGUMENTS:
	;	. MTMID		ID of MTM requested	
	;
	; OUTPUT:
	;	. ER		Error flag		
	;
	;	. RM		Error message		
	;
	S %TAB("SVID")=".SRVID1/XPP=D DELSRVPR"
	S %READ="SVID/REQ"
	S X=$$MTMEXCHMSG^%MTAPI("DELSRV","",MTMID,.RM,1)
	Q X
	;
DELSRVPR; Pre-processor to Server ID prompt.  Builds list of valid
	; server IDs, based on reply to PENDING request.
	;
	N I
	Q:$D(VALID)
	S X=$$MTMEXCHMSG^%MTAPI("PEND","",MTMID,.INFO,1)
	Q:INFO'["|"				; No servers connected
	F I=1:1 S X=$P(INFO,"(",I) Q:X=""  S VALID($P(X,"|",1))=$P(X,"|",3)
	Q
	;
MTMJRNLNAM(TAB)
	Q ".JRNDEV2"
	;
