%MTAPI	;Library;Library of message transport APIs SCAMTM DECnet transport
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/22/00 16:02:53 - LYH
	;;Copyright(c) Sanchez Computer Associates, Inc.  All Rights Reserved - // - 
	; ORIG:  RUSSELL - 25 June 1992
	;
	; This routine provides a library of standard PROFILE application 
	; programming interface (API) calls to be used for the Message 
	; Transport mechanism.  In particular, this set of APIs implements an 
	; interface to a message transport using the SCAMTM software as the 
	; underlying transport mechanism.
	;
	; The logical name SCA$CS_MTM must be defined to point to the target 
	; task for connection.  The form should be
	;
	; KEYWORDS:	System services
	;
	;   DEFINE SCA$CS_MTM "node::""TASK=prcnam"""
	;
	;  LIBRARY:  . $$CLCNCT		- Client Connect
	;            . $$CLDSCNCT	- Client Disconnect
	;            . $$EXCHMSG	- Client Exchange Message
	;            . $$CLSEND		- Client Send Message
	;            . $$CLGET		- Client Get Message
	;            . $$SVCNCT		- Server Connect
	;            . $$SVDSCNCT	- Server Disconnect
	;            . $$GETMSG		- Server Get_Message
	;            . $$REPLY		- Server Reply_Message
	;            . $$MTMSTART	- Start up an MTM Process
	;            . $$MTMCNTRL	- MTM Control Message Sequence
	;
	;---- Revision History ------------------------------------------------
	; 02/15/07 - Pete Chenard - CR25320
	;	     Added additional checking in MTMCNTRL for error codes in 
	;	     order to provide more detailed message to the caller.
	;
	; 09/21/05 - Pete Chenard - CR 17435
	;	     Added additional parameter on EXCHMSG to capture the
	;	     message descriptor information.
	;
	; 03/31/04 - Manoj Thoniyil - CR8327
	;	     Modified the MQ section to return an error status by 
	;	     looking into $GETSTAT, instead of returning a generic 
	;	     CS_MQERROR or CS_MTERROR.
	;	     Changed $ZP to $O
	;
	; 06/13/01 - Harsha Lakshmikantha - 45731
	;	     Modified timeout section to support Linux and Solaris
	;	     ports.
	;
	; 06/04/01 - Harsha Lakshmikantha - 43104
	;	     Added sections PSCNCT, PSDSCNCT, and PUB to support
	;	     MQSeries Publish/Subscribe.
	;
	; 07/20/00 - lyh - ARQ 40027
	;	     Added MQ handling in CLSEND section.
	;	     Modified section GETSTAT to set STATUS=default for MQ.
	;	     Replaced status with STATUS in section GETSTAT for MQ.
	;	     Switched id and ERRNO in MQ client connect call.
	;
	; 03/22/00 - lyh - ARQ 36125
	;	     Changed the transport name in the client section to check
	;	     for MTM. We can expand the transport name to MTMCHEX,
	;	     MTMFDR, MTMMPS,... without creating a new section for
	;	     each new transport name if it's using the same mtm
	;	     external call package.
	;	     Added sections CLGET and CLSEND to support asynchronous
	;	     mode client communication.
	;
	; 06/14/99 - mjr - ARQ#33634
	;	     Changed handling of transport name instead of storing
	;	     as "#MTM" will use the "MTM_", etc. to find transport
	;	     name (in first field of ^SVCTRL())	
	;
	; 05/27/99 - mjr
	;	     Changes to support other server types and message
	;	     transport mechanism (i.e. MTM, MQSeries, RTR)
	;
	;	     *** IMPORTANT ***
	;	     This release requires a new verison of ^%MTAPI
	;	     (application program interfaces to message transport
	;	     layer).  Ensure the version of ^%MTAPI contains an
	;	     entry in the revision history that references
	;	     ARQ#32725 prior to loading this release.
	;
	;	     Also note that ^%MTAPI is a platform specific program
	;	     (i.e., a separate version supports Unix, VMS, etc.).
	;
	;
	; 05/10/99 - mjr
	;	     Completed logic introduced to support multiple transports 
	;	     within each API
	; 
	; 02/02/99 - Phil Chenard
	;	     Introduced logic to support multiple transport options within
	;	     each API function.  These changes will allow for the co-
	;	     existence of message transports for a single instance of
	;	     PROFILE, with servers for each running concurrently.
	;	     Additional transports enabled with these changes are 
	;	     MQ Series and Digital RTR.
	;
	; 05/01/96 - Phil Chenard 
	;	     Modified GETMSG to remove a second call to the external API
	;	     in the event that the first one times out.
	;
	;----------------------------------------------------------------------
CLCNCT(id,cltyp,mtnam)	;System;Client connect to transport
	;----------------------------------------------------------------------
	;
	; Allows connection of a client to the message transport layer.  Using
	; SCAMTM, the id identifies the socket descriptor.
	; In the case of error, id contains the error message.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . id	Identification number for the client connection.
	;					  /TYP=T/REQ/MECH=REF:RW
	;
	;     . cltyp 	Client type name - value is a environment variable that
	;		points to the initialization/setup file used to establish
	;		a connection with the transport.
	;				         /TYP=T/NOREQ/MECH=VAL
	;
	;     . mtnam	Transport name.  Determines which external package
	;               to call in order to connect to the transport.
	;					  /TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, id will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$CLCNCT^%MTAPI(.ID,cltyp,"MQ")
	;	S X=$$CLCNCT^%MTAPI(.id,"$SCAU_LNAPP","MQ")
	;----------------------------------------------------------------------
	;
	N ERRNO,LIST,STATUS,TASK,svinfo,I
	S ERRNO=0,STATUS="",id="",cltyp=$G(cltyp) 
	;
	S mtnam=$G(mtnam) S:mtnam="" mtnam="MTM"
	;
	I $E(mtnam,1,3)="MTM" D  Q STATUS
	.       ;
	.	S LIST=$$SCA^%TRNLNM("CS_"_mtnam)
	.	I LIST="" S id="",STATUS="CS_MTMLOG" Q
	.	;
	.	F I=1:1:$L(LIST,",") S TASK=$P(LIST,",",I) D  Q:'ERRNO
	..		S id=""
	..		D &mtm.ClConnect(TASK,.ERRNO)
	.	;
	.	I ERRNO=0 S id=mtnam_"_1",STATUS=""		;Success
	.	E  S id=$ZM(ERRNO) S STATUS="CS_MTERROR"	;Failure
	;
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.	;
	.	I cltyp="" S STATUS="",id="" Q
	.	; LYH 04/14/2000 - switch id and ERRNO
	.	; D &mq.ClConnect(cltyp,.ERRNO,.id)
	.	D &mq.ClConnect(cltyp,.id,.ERRNO)
	.	I ERRNO=0 S id="MQ_"_id Q
	.	S id=-1 S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_CLCNCT_ERROR")
	;
	I mtnam="RTR" D  Q STATUS
	.	S LIST=$$SCA^%TRNLNM("CS_RTR")  
	.	I LIST="" S id="",STATUS="CS_RTRLOG" Q
	.	;
	.	F I=1:1:$L(LIST,",") S TASK=$P(LIST,",",I) D  Q:'ERRNO
	..		S id=""
	..		D &rtr.ClConnect(TASK,.ERRNO)
	.	;
	.	I ERRNO=0 S id=1,STATUS="" Q				;Success
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"RTR_STS_ERROR")
	;
	Q STATUS
	;	
	;----------------------------------------------------------------------
CLDSCNCT(id)      	;System;Client disconnect from transport
	;----------------------------------------------------------------------
	;
	; Disconnects a client from the message transport layer.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . id	ID number of the current client connection
	;					/TYP=T/REQ/MECH=VAL
	;
	;
	; RETURNS:
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, id will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	;     . RM	Failure reason if return is CS_MTERROR
	;
	; EXAMPLE:
	;	S X=$$CLDSCNCT^%MTAPI(ID)
	;
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS
	S ERRNO=0,STATUS=""
	;
	S id=$G(id) I id="" Q "CS_MTERROR"
	; 
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	;
	I $E(mtnam,1,3)="MTM" D  Q STATUS
	.	S id=1
	.	D &mtm.ClDisconnect(.ERRNO)
	.	I ERRNO=0 S id=1 S STATUS="" Q
	.	S id=$ZM(ERRNO) S STATUS="CS_MTERROR" S RM=$ZM(ERRNO)
	;
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.	N chanlid
	.	S chanlid=$P(id,"|",1),chanlid=$P(chanlid,"_",2)
	.	D &mq.ClDisconnect(chanlid,.ERRNO)
	.	I ERRNO=0 S STATUS="" Q
	.	S id=ERRNO S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_CLDSCNCT_ERROR")
	;
	I mtnam="RTR" D  Q STATUS
	.	S ERRNO=0,STATUS="",id=1
	.	D &rtr.ClDisconnect(.ERRNO)
	.	I ERRNO=0 S id=1,STATUS="" Q
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"CS_RTERROR")
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
EXCHMSG(msg,reply,srvtyp,id,timeout,msgdsc)	;System;Client exchange message
	;----------------------------------------------------------------------
	;
	; Sends a client message to the host for processing by a valid server,
	; and returns a reply to the message.
	;
	; The reply message from the server may itself be an error message,
	; either a specific CS_* error or a general error.  In either case,
	; an error message is preceeded by a 1 (a good reply by a 0).  For
	; these types of error messages, return either the CS_* error or
	; a CS_MTERROR with the info in the reply field, as appropriate.
	;
	; For a CS_MTMCNCT failure (failure on send), disconnect and try to
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
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . id	ID of client connection
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . timeout	Timeout interval	
	;		Time to wait before giving up and returning a timeout
	;		error message.
	;
	;     . msgdsc  Message descriptor
	;				/TYP=T/NOREQ/MECH=REF
	;
	; RETURNS:	
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, reply will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$EXCHMSG^%MTAPI(.MSG,.REPLY,"*",.%CSID,15)
	;----------------------------------------------------------------------
	;
	N ERRNO,msgdscr,mtnam,STATUS,svid
	;
	S ERRNO=0,STATUS="",svid=""
	;
	S id=$G(id) I id="" Q "CS_MTERROR"		;Id not defined
	;
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	S svid=$P(id,"|",2)
	S msgdsc=$G(msgdsc)
	;
	;  SCA Message Transport Mechanism
	I $E(mtnam,1,3)="MTM" D  Q STATUS
	.       S reply="    "
	.	I (mtnam="MTM") S msg=srvtyp_$C(28)_msg
	.	D &mtm.ClExchmsg(.msg,.reply,timeout,.ERRNO)
	.	;
	.	I $$timeout(ERRNO) S STATUS="CS_TIMEOUT" Q
	.	I ERRNO=0 D  Q
	..		I (mtnam="MTM") S reply=$E(reply,2,99999)
	..		s STATUS=""					;Success
	.	I ERRNO>83 S reply=$ZM(ERRNO),STATUS="CS_MTMLOG" Q	;Failure
	.	I ERRNO>0 S reply=$ZM(ERRNO),STATUS="CS_MTERROR" Q	;Failure
	.	I ERRNO=-19 S reply="No server of this type",STATUS="CS_NOSVTYP" Q
	.	I ERRNO=-36 S reply="No server of this type",STATUS="CS_NOSVTYP" Q
	.	I ERRNO>-37 S reply="MTM Error",STATUS="CS_MTERROR"
	;
	;  IBM's MQSeries
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.       S reply="        ",STATUS=""
	.	N chanlid
	.	S chanlid=$P(id,"|",1),chanlid=$P(chanlid,"_",2)
	.	D &mq.ClExchmsg(.msg,.reply,msgdsc,.msgdscr,timeout,chanlid,.ERRNO)
	.	I ERRNO=0 S msgdsc=msgdscr Q
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_EXCHMSG_ERROR") S reply=STATUS_"-"_ERRNO 
	;
	;  Compaq Reliable Transaction Router
	I mtnam="RTR" D  Q STATUS
	.	S ERRNO=0,reply="    "
	.	I '$G(timeout) S timeout=30
	.	S msg=srvtyp_$C(28)_msg
	.	D &rtr.ClExchmsg(.msg,.reply,timeout,.ERRNO)
	.	;
	.	I ERRNO=0 S STATUS="" Q		;Success
	.	S reply="RTR Error"
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"CS_RTERROR",1,.reply)
	.	;
	;
	;  BEA Tuxedo
	I mtnam="TUX" Q "CS_MTERROR"
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
PSCNCT(id)	;System;Pulish/Subscribe initialization
	;----------------------------------------------------------------------
	;
	; Allows connection of a client to MQSeries to publish and subscribe,
	; the id identifies the session handle.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . id	Session handle
	;			  /TYP=N/REQ/MECH=REF:RW
	;
	; RETURNS:
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, id will contain message
	;
	; EXAMPLE:
	;	S X=$$PSCNCT^%MTAPI(.id)
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS
	S ERRNO=0,STATUS="",id=""
	;
	D &mq.psconnect(.id,.ERRNO)
	I ERRNO=0 Q ERRNO
	S id=-1 S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_PSCNCT_ERROR")
	;
	Q STATUS
	;	
	;----------------------------------------------------------------------
PSDSCNCT(id)      ;System;Client disconnect from MQseries Publish/Subscribe
	;----------------------------------------------------------------------
	;
	; Disconnects a client from MQseries Publish/Subscribe.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . id	Session handle
	;			/TYP=T/REQ/MECH=REF
	;
	;
	; RETURNS:
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, id will contain message
	;
	;     . RM	Failure reason if return is CS_MTERROR
	;
	; EXAMPLE:
	;	S X=$$PSDSCNCT^%MTAPI(.ID)
	;
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS
	S ERRNO=0,STATUS=""
	;
	D &mq.psdisconnect(.id,.ERRNO)
	I ERRNO=0 Q ERRNO
	S id=ERRNO S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_PSDSCNCT_ERROR")
	Q STATUS
	;
	;----------------------------------------------------------------------
PUB(msg,topic,handle)	;System;Publish message
	;----------------------------------------------------------------------
	;
	; Publish a message on a particular topic.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . msg	Message to be published	
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . topic	Topic of the message to be published
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . handle	Session handle
	;				    /TYP=N/REQ/MECH=VAL
	;
	; RETURNS:	
	;     . Condition value	0 = success
	;		CS_MTERROR = general error, reply will contain message
	;
	; EXAMPLE:
	;	S X=$$PUB^%MTAPI(MSG,"TestTopic",handle)
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS
	;
	S ERRNO=0,STATUS=""
	;
	D &mq.pub(msg,topic,handle,.ERRNO)
	I ERRNO=0 Q ERRNO
	;
	S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_PUB_ERROR")
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
CLSEND(msg,srvtyp,id,msgdsc)	;System;Client send message
	;----------------------------------------------------------------------
	;
	; Sends a client message to the host for processing by a valid server.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . msg	Message to server	
	;
	;     . srvtyp	Service type needed	
	;               The service type identifies what type of server is
	;               required to process this message.
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . id	ID of client connection
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . msgdsc	Message descriptor
	;				    /TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:	
	;     . Condition value	NULL = success
	;		CS_MTERROR = general error, reply will contain message
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$CLSEND^%MTAPI(.MSG,"*",.%CSID)
	;----------------------------------------------------------------------
	;
	N ERRNO,mtnam,STATUS,svid
	;
	S ERRNO=0,STATUS="",svid=""
	;
	S id=$G(id) I id="" Q "CS_MTERROR"		;Id not defined
	;
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	S svid=$P(id,"|",2)
	;
	I '$G(timeout) S timeout=30			;
	;
	S msgdsc=$G(msgdsc)
	;  SCA Message Transport Mechanism
	I $E(mtnam,1,3)="MTM" D  Q STATUS
	.	I (mtnam="MTM") S msg=srvtyp_$C(28)_msg
	.	D &mtm.ClSendMsg(.msg,timeout,.ERRNO)
	.	I ERRNO=0 S STATUS="" Q		;Success
	.	I ERRNO>83 S STATUS="CS_MTMLOG" Q	;Failure
	.	I ERRNO>0 S STATUS="CS_MTERROR" Q	;Failure
	.	I ERRNO=-19 S STATUS="CS_NOSVTYP" Q
	.	I ERRNO=-36 S STATUS="CS_NOSVTYP" Q
	.	I ERRNO>-37 S STATUS="CS_MTERROR"
	;
	;  IBM's MQSeries
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.       S reply="        ",STATUS=""
	.	N chanlid
	.	S chanlid=$P(id,"|",1),chanlid=$P(chanlid,"_",2)
	.	D &mq.ClSend(.msg,.msgdsc,chanlid,.ERRNO) Q:ERRNO=0
	.	;
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"MQ_CLSEND_ERROR")
	;
	; Any other mtnam will produce CS_MTERROR
	;
	S STATUS="CS_MTERROR"
	Q "CS_MTERROR"
	;
	;----------------------------------------------------------------------
CLGET(reply,srvtyp,id,timeout)	;System;Client get message
	;----------------------------------------------------------------------
	;
	; Gets a client message from the host.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . reply	Response from server	
	;
	;     . srvtyp	Service type needed	
	;               The service type identifies what type of server is
	;               required to process this message.
	;				    /TYP=T/REQ/MECH=VAL
	;
	;     . id	ID of client connection
	;				    /TYP=T/REQ/MECH=VAL
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
	;	S X=$$CLGET^%MTAPI(.REPLY,"*",.%CSID,15)
	;----------------------------------------------------------------------
	;
	N ERRNO,mtnam,STATUS,svid
	;
	S ERRNO=0,STATUS="",svid=""
	;
	S id=$G(id) I id="" Q "CS_MTERROR"		;Id not defined
	;
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	S svid=$P(id,"|",2)
	;
	I '$G(timeout) S timeout=30			;
	;
	;  SCA Message Transport Mechanism
	I $E(mtnam,1,3)="MTM" D  Q STATUS
	.       S reply="    "
	.	D &mtm.ClGetMsg(.reply,timeout,.ERRNO)
	.	;
	.	I $$timeout(ERRNO) S STATUS="CS_TIMEOUT" Q
	.	I ERRNO=0 D  Q
	..		I (mtnam="MTM") S reply=$E(reply,2,99999)
	..		s STATUS=""					;Success
	.	I ERRNO=4 S reply=$ZM(ERRNO),STATUS="CS_TIMEOUT" Q
	.	I ERRNO>83 S reply=$ZM(ERRNO),STATUS="CS_MTMLOG" Q	;Failure
	.	I ERRNO>0 S reply=$ZM(ERRNO),STATUS="CS_MTERROR" Q	;Failure
	.	I ERRNO=-19 S reply="No server of this type",STATUS="CS_NOSVTYP" Q
	.	I ERRNO=-36 S reply="No server of this type",STATUS="CS_NOSVTYP" Q
	.	I ERRNO>-37 S reply="MTM Error",STATUS="CS_MTERROR"
	;
	; Any other mtnam will produce an error
	;
	Q "CS_MTERROR"
	;
	;----------------------------------------------------------------------
SVSTART(jobnam,svtyp,svid)	;System;Start up a server process
	;----------------------------------------------------------------------
	Q $$^%ZJOB(jobnam,svtyp_svid)
	;
	;----------------------------------------------------------------------
SVCNCT(srvtyp,id,role,mtnam)	;System;Server connect to transport
	;----------------------------------------------------------------------
	;
	; Allows connection of a server to the message transport layer.
	;
	; Based on the server type, the appropriate transport will be 
	; identified and the call-out made to the external API to open
	; a channel to the transport.  Currently, transports supported 
	; include:
	;		MTM	- Sanchez Message Transport Manager
	;		RTR	- Compaq Reliable Transaction Router
	;		MQ	- IBM MQ Series
	;		TUX	- BEA Tuxedo  (not currently supported)
	;
	; KEYWORDS:	Message Transport
	;
	; ARGUMENTS:
	;     . srvtyp	Service type		/TYP=T/LEN=20/MECH=VAL
	;               Defines the category of service this server runs under.
	;               Messages from clients are directed to specific server
	;               types, and will be routed on the basis of this
	;               argument.  This argument also determines what
	;               transport layer this server will attach to.
	;
	;     . id	Connect ID.  A specific identifier, storing info
	;		on the transport, and server connection.
	;				      /TYP=T/REQ/MECH=REFNAM:RW
	;
	;     . mtnam	Message Transport Name.  This is the acronym used to
	;	        represent the appropriate transport to connect with.
	;			              /TYP=T/NOREQ/MECH=VAL/DFT="MTM"
	;
	;		
	;
	; RETURNS:
	;     . Condition value		
	;		NULL        = 	success
	;		CS_SVTYP    = 	No logical name defined for service type
	;		CS_NOMTM    = 	Transport is not active or does not
	;			       	respond
	;
	;     . id	Value associated with the server open channel connection and
	;		the transport it is connected to.  This variable will now
	;		contain the following pieces of information:
	;		MT ID - transport ID (not required)
	;		Server type ID - 
	;		Transport Name
	;		
	;		MQ_MGR_NAM|SCA$MQ_1|MQ
	;
	; EXAMPLE:
	;	S X=$$SVCNCT^%MTAPI(SVTYP,.ID)
	;	S ERR=$$SVCNCT^%MTAPI("SCA$IBS",%svid)
	;
	;----------------------------------------------------------------------
	;
	; Get the transport name from the server type table
	S mtnam=$G(mtnam)	      ;Message transport name
	I mtnam="" S mtnam="MTM"
	;
	N ERRNO,STATUS
	S ERRNO=0,STATUS="",id=""
	;
	I mtnam="TUX" Q "CS_MTERROR"
	;
	I mtnam="MTM" D  Q STATUS 		;MTM Transport
	.	D &mtm.SrvConnect(srvtyp,.id,.ERRNO)
	.	I ERRNO>0 S STATUS=$ZM(ERRNO)	Q		;UNIX system call Failure
	.	I ERRNO=-3 S STATUS="CS_SHUTDOWN" Q		;Shutdown pending
	.	I ERRNO=-4 S STATUS="CS_DUPPRCNM" Q		;Duplicate connection 
	.	I ERRNO=-5 S STATUS="CS_TOOMANY" Q		;Maximum number of servers is running
	.	I ERRNO=-38 S STATUS="CS_NOMTM" Q		;No MTM
	.	I ERRNO=0 D  Q
	..		S STATUS=""
	..		S srvtyp=$TR(srvtyp,"$","_")
	..		S id=$$SCA^%TRNLNM("CS_ST_"_srvtyp)_"|"_srvtyp_"_"_id  ;Success
	;
	I $E(mtnam,1,2)="MQ" D  Q STATUS		;MQ Series Transport
	.	S srvtyp=$TR(srvtyp,"$","_")
	.	S srvtyp=$$SCA^%TRNLNM("CS_ST_"_srvtyp)
	.	D &mq.SrvConnect(srvtyp,.id,.ERRNO)
	.	I ERRNO=0 D  Q
	..		S STATUS=""
	..		S srvtyp=$TR(srvtyp,"$","_")
	..		S id=srvtyp_"|"_srvtyp_"_"_id
	.	;
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"MQRC_SVCNCT_ERROR")
	;
	I mtnam="RTR" D  						;Compaq Reliable Transaction Router
	.	S (id,ROLE,role,STATUS)="",ERRNO=0
	.	;
	.	D &rtr.SrvConnect(srvtyp,.id,.ROLE,.ERRNO)
	.	I ERRNO=0 D  Q
	..		;
	..		; Define server ID
	..		S srvtyp=$TR(srvtyp,"$","_")
	..		S id=$$SCA^%TRNLNM("CS_ST_"_srvtyp)_"|"_srvtyp_"_"_id
	..		;
	..		I role=108 S role="PRIMARY" Q
	..		I role=109 S role="SECONDARY" Q
	..		I role=110 S role="SECONDARY" Q
	..		S role="UNKNOWN"
	..		;
	.	; Set up error condition w/ explanation in $ZSTATUS
	.	S STATUS=$$GETSTAT(mtnam,"","CS_RTERROR"),$ZS=ERRNO_",SVCNCT^%MTAPI,"_STATUS
	;
	;
	Q "CS_MTERROR"
	;
	;----------------------------------------------------------------------
SVDSCNCT(id)	;System;Server disconnect from transport
	;----------------------------------------------------------------------
	;
	; Disconnects a client from the message transport layer.
	;
	; Passes an DELSRV message to the MTM that is identified by the
	; first element of the ID (MTMNAME|idnumber) through the MTM's control
	; mailbox.  There is no reply sent from the server.
	;
	; KEYWORDS:	
	;
	; ARGUMENTS:
	;
	;     . id	Connect ID		
	;       The id parameter is made up of the MTMNAME plus the
	;		server id number (MTMNAME|idnumber).
	;
	; RETURNS:
	;     . Condition value		
	;		NULL = always
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$SVDSCNCT^%MTAPI(ID)
	;
	;----------------------------------------------------------------------
	;
	N mtnam
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	;
	I mtnam="MTM" D &mtm.SrvDisconnect()
	I $E(mtnam,1,2)="MQ" D &mq.SrvDisconnect()
	I mtnam="RTR" D &rtr.SrvDisconnect()
	;
	S ID=0
	S vzcsid=1
	Q ""
	;
	;----------------------------------------------------------------------
GETMSG(msg,msgid,id,timeout,msgdsc)	;System;Server get message from client
	;----------------------------------------------------------------------
	;
	; Gets a message that was sent from a client and destined for the
	; server class of this server.  The message is retreived through a
	; an external C all that pauses waiting for a signal from the MTM that a
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
	;     . msgdsc	Message descriptor
	;				    /TYP=T/NOREQ/MECH=REF
	;
	; RETURNS:
	;     . Condition value		
	;		NULL	   = success
	;		CS_TIMEOUT = timeout occurred
	;       	CS_MTERROR = UNIX error, msg holds error message
	;		CS_MTMSTOP = MTM stopped, forced server stop
	;		See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;	S X=$$GETMSG(.MSG,.MSGID,SRVID,60)
	;
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS,mtnam
	;
	I '$G(timeout) S timeout=300
	S ERRNO=0,STATUS="",msgid=1,msg="",msgdsc=""
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	;
	;  SCA Message Transport Mechanism
	I mtnam="MTM" D  Q STATUS
	.	D &mtm.SrvGetMsg(.msg,timeout,.ERRNO)
	.	I $$timeout(ERRNO) S STATUS="CS_TIMEOUT" Q
	.	I ERRNO>0 S msg=$ZM(ERRNO) S STATUS="CS_MTERROR"
	.	I $E(msg,1,12)="*CS_MTMSTOP*" S msg="MTM stopped",STATUS="CS_MTERROR"
	;
	;  IBM MQSeries
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.	D &mq.SrvGetMsg(.msg,.msgdsc,timeout,.ERRNO) Q:ERRNO=0
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"MQRC_GETMSG_ERROR")
	;
	;  Compaq Reliable Transaction Router
	I mtnam="RTR" D  Q STATUS
	.	S (msg,STATUS)="",ERRNO=0,msgid=1
	.	;
	.	D &rtr.SrvGetMsg(.msg,timeout,.ERRNO)
	.	;
	.	I $E(msg,1,12)="*CS_RTRSTOP*" S msg="RTR stopped",STATUS="CS_MTERROR" Q
	.	;
	.	I ERRNO=0 S STATUS="" Q
	.	;
	.	; Fatal events/errors
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"CS_RTERROR",2,.msg) Q:STATUS'="CS_RTERROR"
	.	S $ZS=ERRNO_",GETMSG^%MTAPI,"_STATUS
	;
	;  BEA Tuxedo
	I mtnam="TUX" Q "CS_MTERROR"
	;
	Q STATUS
	;
	;
	;----------------------------------------------------------------------
REPLY(reply,msgid,id,msgdsc)	;System;Server send reply message to client
	;----------------------------------------------------------------------
	;
	; Sends a reply message to a client in response to a message received
	; by the server.  
	; This is done through use of a an external C Call that places the
	; reply message in shared memory (i.e. queue) and then
	; signals the MTM that a server reply message is pending.
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
	;     . msgdsc	Message descriptor
	;				    /TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;     . Condition value		
	;		NULL         = success
	;
	; EXAMPLE:
	;	S X=$$REPLY^%MTAPI(.REPLY,MSGID,SRVID)
	;----------------------------------------------------------------------
	;
	N ERRNO,STATUS,mtnam
	;
	S STATUS="",ERRNO=0
	S mtnam=$P(id,"_",1) S:mtnam="" mtnam="MTM"
	;
	S msgdsc=$G(msgdsc)
	I mtnam="MTM" D  Q STATUS
	.	D &mtm.SrvReply(reply,.ERRNO)
	.	I ERRNO>0 S STATUS=$ZM(ERRNO) S reply=$ZM(ERRNO)	;Failure
	;
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.	D &mq.SrvReply(reply,msgdsc,.ERRNO) Q:ERRNO=0
	.	S STATUS=$$GETSTAT(mtnam,ERRNO,"MQRC_REPLY_ERROR") S reply=STATUS_"-"_ERRNO
	;
	;
	I mtnam="RTR" D  Q STATUS
	.	S ERRNO=0,STATUS=""
	.	D &rtr.SrvReply(reply,.ERRNO) Q:'ERRNO
	.	I ERRNO'=0 S STATUS="CS_RTERROR",$ZS=ERRNO_",REPLY^%MTAPI,"_STATUS
	.	;
	;
	I mtnam="TUX" Q "CS_MTERROR"
	;
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
	D &mtm.MTMCntrl(cmd,params,mtmid,.reply,.ERRNO)
	;
	I ERRNO=0 Q 0						;Success
	I ERRNO=-16 Q 0
	I ERRNO=-17 Q 0
	I ERRNO=-18 Q 0
	I $$timeout(ERRNO) S reply="CS_TIMEOUT" Q 1
	D
	.	I ERRNO>0 S reply=$ZM(ERRNO)	;UNIX Failure 
	.	E  I ERRNO=-1 S reply="Invalid Command." 
	.	E  I ERRNO=-10 S reply="Journaling is enabled." 
	.	E  I ERRNO=-11 S reply="Journaling is disabled." 
	.	E  I ERRNO=-12 S reply="Journaling is not enabled." 
	.	E  I ERRNO=-14 S reply="No clients connected." 
	.	E  I ERRNO=-15 S reply="Journaling enable flag is invalid." 
	.	E  I ERRNO=-19 S reply="No active servers." 
	.	E  I ERRNO=-36 S reply="Invalid Server Type." 
	.	E  I ERRNO=-46 S reply="MTM Statistics not running." 
	.	E  I ERRNO=-50 S reply="MTM Statistics already running." 
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
	I UPDTDB L +^MTMSVST(DATE,MTMID):2 E  S ET="RECLOC" Q 1
	F I=1:1 S X=$P(RM,"(",I) Q:X=""  D
	.	S SVTYP=$P(X,"|",1),TRACKED=$P(X,"|",2),ACTIVE=$P(X,"|",3)
	.	S REQ=$P(X,"|",4),RESP=$P(X,"|",5),AVG=$P(X,"|",6)/1000
	.	S MIN=$P(X,"|",7)/1000,MAX=$P(X,"|",8)/1000
	.	S DATA(I)=SVTYP_"|"_TRACKED_"|"_ACTIVE_"|"
	.	S DATA(I)=DATA(I)_REQ_"|"_RESP_"|"_MIN_"|"_MAX_"|"_AVG
	.	I UPDTDB D
	..		S SAVE=TIME_"|"_TRACKED_"|"_ACTIVE_"|"_REQ_"|"_RESP_"|"
	..		S SAVE=SAVE_AVG_"|"_MIN_"|"_MAX
	..		S SEQ=$O(^MTMSVST(DATE,MTMID,SVTYP,""),-1)+1
	..		S ^MTMSVST(DATE,MTMID,SVTYP,SEQ)=SAVE
	;
	I UPDTDB L -^MTMSVST(DATE,MTMID)
	; No servers active for MTM ~p1
	I I=1 S RM=$$^MSG(1985,MTMID) Q 1
	S SVTYPS=I-1
	S SID="MTMSVSTATS" D ^USID
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
	D &mtm.MTMRunning(MTMID,RUNNING,.RC)
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
	;
	;----------------------------------------------------------------------
GETSTAT(mtnam,errno,default,exchtype,reply)	; Private  ;
	;  DESC: 
	;		Return status value based on transport
	;
	;  ARGUMENTS:
	;	.	mtnam		-	Transport name (MTM, MQ, RTR, TUX)
	;	.	errno		-	Error Number returned from transport API
	;	.	default	-	Default return vaule
	;	.	exchtype	-	Different return values for same error number based
	;					upon where this is being called (EXCHMSG, GETMSG, etc)
	;	.				Used by RTR, MQ transport types
	;	.	reply		-	reply message returned, used by RTR
	;
	;  RETURN:  
	;	.	$$		/TYP=T
	;				Error Status Flag for appropriate
	;				transport type
	;				
	;
	;----------------------------------------------------------------------
	;
	N STATUS
	S STATUS=""
	;
	S default=$G(default),reply=$G(reply),exchtype=+$G(exchtype)
	;
	I mtnam="MTM" Q STATUS
	;
	I mtnam="RTR" D  Q STATUS
	.	I 'ERRNO S STATUS=default Q
	.	;
	.	I 'exchtype D  Q
	..		I ERRNO=-15007590 S STATUS="RTR_STS_INVFLAGS" Q
	..		I ERRNO=-16121702 S STATUS="RTR_STS_INVCHANAM" Q
	..		I ERRNO=-7798630 S STATUS="RTR_STS_INVFACNAM" Q
	..		I ERRNO=-15204198 S STATUS="RTR_STS_INVRCPNAM" Q
	..		I ERRNO=-15073126 S STATUS="RTR_STS_INVEVTNUM" Q
	..		I ERRNO=-7733094 S STATUS="RTR_STS_INVACCESS" Q
	..		I ERRNO=-14942054 S STATUS="RTR_STS_INVCHANNEL" Q
	..		S STATUS=default
	.	;
	.	I exchtype=1 D  Q
	..		I ERRNO=-16121702 S reply="Invalid Channel",STATUS="CS_RTR_INVCHNL" Q
	..		I ERRNO=-15007590 S reply="Invalid Flags",STATUS="CS_RTR_INVFLGS" Q
	..		I ERRNO=-13565798 S reply="Timeout",STATUS="CS_RTR_TIMOUT" Q
	..		S STATUS=default
	.	;
	.	I exchtype=2 D  Q
	..		;  Mask as timeout
	..		I ERRNO=-13565798 S STATUS="CS_TIMEOUT" Q
	..		I ERRNO>0,ERRNO<13,ERRNO'=10 S STATUS="CS_TIMEOUT" Q
	..		;
	..		; Events important to application
	..		I ERRNO=96 S STATUS="CS_FACREADY" Q
	..		I ERRNO=97 S STATUS="CS_FACDEAD" Q
	..		I ERRNO=108 S STATUS="CS_MTPRIMARY" Q
	..	        I ERRNO=109 S STATUS="CS_MTSECONDARY" Q
	..	        I ERRNO=110 S STATUS="CS_MTSECONDARY" Q
        ..              ; Fatal events/errors
        ..              I $D(^UTBL("RTRFATAL",ERRNO)) D  Q
        ...                   S STATUS="CS_FATAL"
        ...                   S $ZS=ERRNO_",GETMSG^%RTAPI,"_STATUS
        ...                   ;
        ..              ;	
	..		S STATUS=default
	;
	I $E(mtnam,1,2)="MQ" D  Q STATUS
	.	; *** LYH 04/12/2000 start of changes
	.	S STATUS=default
	.	I exchtype=1 D  Q
	..		I ERRNO>2000 S STATUS="CS_MQERROR" Q
	..		; S STATUS=default
	.	;
	. 	;	errors specific to MQSeries
	.	I ERRNO=2002 S STATUS="MQRC_ALREADY_CONNECTED" Q  ;Already connected
	.	I ERRNO=2004 S STATUS="MQRC_BUFFER_ERROR" Q
	.	I ERRNO=2005 S STATUS="MQRC_BUFFER_LENGTH_ERROR" Q
	.	I ERRNO=2009 S STATUS="MQRC_CONNECTION_BROKEN" Q
	.	I ERRNO=2010 S STATUS="MQRC_DATA_LENGTH_ERROR" Q
	.	I ERRNO=2011 S STATUS="MQRC_DYNAMIC_Q_NAME_ERROR" Q
	.	I ERRNO=2013 S STATUS="MQRC_EXPIRY_ERROR" Q
	.	I ERRNO=2016 S STATUS="MQRC_GET_INHIBITED" Q
	.	I ERRNO=2017 S STATUS="MQRC_HANDLE_NOT_AVAILABLE" Q
	.	I ERRNO=2027 S STATUS="MQRC_MISSING_REPLY_TO_Q" Q
	.	I ERRNO=2029 S STATUS="MQRC_MSG_TYPE_ERROR" Q
	.	I ERRNO=2030 S STATUS="MQRC_MSG_TOO_BIG_FOR_Q" Q
	.	I ERRNO=2031 S STATUS="MQRC_MSG_TOO_BIG_FOR_Q_MGR" Q
	.	I ERRNO=2033 S STATUS="CS_TIMEOUT" Q
	.	I ERRNO=2035 S STATUS="MQRC_NOT_AUTHORIZED" Q
	.	I ERRNO=2051 S STATUS="MQRC_PUT_INHIBITED" Q
	.	I ERRNO=2052 S STATUS="MQRC_Q_DELETED" Q
	.	I ERRNO=2053 S STATUS="MQRC_Q_FULL" Q
	.	I ERRNO=2058 S STATUS="MQRC_Q_MGR_NAME_ERROR" Q
	.	I ERRNO=2059 S STATUS="MQRC_Q_MGR_NOT_AVAILABLE" Q
	.	I ERRNO=2061 S STATUS="MQRC_Q_MGR_QUIESCING" Q
	.	I ERRNO=2062 S STATUS="MQRC_Q_MGR_STOPPING" Q
	.	; S STATUS=default
	.	; *** LYH 04/12/2000 - end of changes
	;
	I mtnam="TUX" Q STATUS
	;
	Q STATUS
	;
	;----------------------------------------------------------------
timeout(errno)	;  Private ; Determine if timeout based on platform if MTM
	;----------------------------------------------------------------
	;
	I (errno=80)!(errno=83) I $$^%ZSYS()="OSF1" Q 1 
	;
	I (errno=119)!(errno=35) I $$^%ZSYS()="AIX" Q 1
	;
	I (errno=52)!(errno=35) I $$^%ZSYS()="HPUX" Q 1
	;
	I (errno=62)!(errno=42) I $$^%ZSYS()="LINUX" Q 1
        ;
	I (errno=62)!(errno=35) I $$^%ZSYS()="SOLARIS" Q 1
        ;
	Q 0
	;
