%HTAPI	;Library;Heavy Thread Manager APIs
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 15:05:37 - MATTSON
	; ORIG:	RUSSELL - 05/28/95
	; 
	; This routine provides a library of standard PROFILE application 
	; programming interface (API) calls to be used for the Heavy Thread
	; Manager.  In particular, this set of APIs implements an interface
	; to both a job scheduler (SC* APIs) and associated threads (TH* APIs).
	;
	; The underlying mechanism is via shared memory, accessed throug a
	; set of external calls.
	;
	; KEYWORDS:	System service
	;
	; LIBRARY:
	;	. $$SCINIT^%HTAPI	- Initialize job scheduler
	;	. $$SCSNDMSG^%HTAPI	- Send data message and return thread 
	;				   msg
	;	. $$SCSHTDWN^%HTAPI	- Initiate thread shutdown
	;	. $$SCGETMSG^%HTAPI	- Return thread message (on completion 
	;				   of all message to be sent)
	;	. $$SCSTAT^%HTAPI	- Return scheduler status
	;	. $$SCBUFDAT^%HTAPI	- Return buffer data
	;	. $$SCCLOSE^%HTAPI	- Close job scheduler
	;	. $$THCNNCT^%HTAPI	- Create thread connection
	;	. $$THGETMSG^%HTAPI	- Get data message from data buffers
	;	. $$THREPLY^%HTAPI	- Return thread response message to
	;				   data buffer
	;	. $$THCLOSE^%HTAPI	- Close thread connection
	;
	;---- Revision History ------------------------------------------------
	; 04/28/04 - Thoniyilm - 9279
	;	     Modified SCINIT and other sections to handle error codes
	;	     less than -1. When an error number is less than -1, it 
	;	     was resulting in an Undefined variable STATUS error.
	;
	; 01/29/04 - Giridharanb - 8079
	;	     Backed out change from 8/12/97.  The C external call 
	;	     was changed to handle the signal issue.  That C code
	;	     was released in 2001 so no additional changes are needed
	;	     to it.
	;
	; 08/12/97 - Allan Mattson
	;            Modified SCSNDMSG and SCGETMSG to handle the timeout in
	;            the API.  This changed is necessary as GT.M and the HTM
	;            had a conflicting use of the signal that controlled the
	;            timeout in the C code.
	;
	; 01/04/96 - Fan Zeng 
	;            Moved to Unix.
	;----------------------------------------------------------------------
	Q
	;----------------------------------------------------------------------
SCINIT(msgslots,maxsize,schtimer,thrtimer,id,norandom)	;System;Init job scheduler
	;----------------------------------------------------------------------
	;
	; Initializes the necessary shared memory structures to create a job
	; scheduler.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. msgslots  Number of message slots	/TYP=N
	;		Defines the number of message slots
	;		available
	;
	;	. maxsize   Max size of messages	/TYP=N/MAX=32767
	;
	;	. schtimer  Scheduler timeout		/TYP=N
	;		Timeout for scheduler send and get
	;		in seconds
	;
	;	. thrtimer  Thread wait time		/TYP=N
	;		Wait time for a thread if no message
	;		is available before second try
	;
	;	. id	Shared memory id		/TYP=T/MECH=REFNAM:W
	;		Returned identifier for the shared
	;		memory area.  Required by threads to
	;		connect.
	;
	;	. norandom  Disable random thread start	/TYP=L/NOREQ/DEFAULT=0
	;		Threads start at random points unleass
	;		this indicator is on.
	;
	; RETURNS:
	;	. $$	Condition value			/TYP=T
	;               null = success
	;		HT_ISINIT = already initialized
	;		HT_OSERR = failure - o/s error
	;
	;	. RM	Failure reason if $$ return is other than success
	;
	; EXAMPLE:
	;	S X=$$SCINIT^%HTAPI(50,25,30,10,.ID,0)
	;
	N RANDOM,STATUS,ID,ERRNO
	S ID=$J("",30)	; memory allocation, 30 bytes
	;
	I $G(norandom) S RANDOM=0
	E  S RANDOM=1
	;
	S ERRNO=0
	D &htm.scinit(msgslots,maxsize,schtimer,thrtimer,RANDOM,.ID,.ERRNO)
	S id=ID
	;
	I ERRNO D
	.	I ERRNO=-1 S STATUS="HT_ISINIT",RM="Scheduler initialization already run"
	.	E  S RM="("_ERRNO_") "_$ZM(ERRNO),STATUS="HT_OSERR"
	E  S STATUS=""
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
SCSNDMSG(schmsg,thrrply)	;System;Send data message and return thread msg
	;----------------------------------------------------------------------
	;
	; Send message from scheduler, return reply from thread
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. schmsg  Scheduler message	/TYP=T/LEN=32767
	;		  Message from scheduler to thread
	;
	;	. thrrply  Thread reply		/TYP=T/LEN=32767/MECH=REF:W
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOSCHINIT = No scheduler init
	;		HT_TIMEOUT = Timeout
	;		HT_SHUTDOWN = In shutdown mode
	;		HT_OSERR = failure - o/s error
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$SCSNDMSG^%HTAPI("message",.reply)
	;
	N STATUS,THRRPLY,ERRNO
	S THRRPLY=$J("",32767)		; memory allocation, 32767 bytes
	;
	S ERRNO=0
	;
	D &htm.scsndmsg(schmsg,.THRRPLY,.ERRNO)
	S thrrply=THRRPLY
	;
	I ERRNO D
	.	I ERRNO=-1 S STATUS="HT_NOSCHINIT",RM="Scheduler initialization not run" Q
	.	I ERRNO=-2 S STATUS="HT_TIMEOUT",RM="Timeout" Q
	.	I ERRNO=-3 S STATUS="HT_SHUTDOWN",RM="Shutdown mode is active" Q
	.	S RM="("_ERRNO_") "_$ZM(ERRNO),STATUS="HT_OSERR"
	E  S STATUS=""
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
SCSHTDWN()	;System;Initiate thread shutdown
	;----------------------------------------------------------------------
	;
	; Signal scheduler shutdown - all messages sent, just needs to collect
	; replies.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOSCHINIT = No scheduler init
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$SCSHTDWN^%HTAPI
	;
	N STATUS,ERRNO
	;
	S ERRNO=0
	D &htm.scshtdwn(.ERRNO)
	;
	I ERRNO=-1 S STATUS="HT_NOSCHINIT",RM="Scheduler initialization not run"
	E  S STATUS=""
	;
	Q STATUS
	;
  	;----------------------------------------------------------------------
SCGETMSG(thrrply)	;System;Return thread message (on completion of
	;----------------------------------------------------------------------
	;
	; Get thread messages from shared memory after all SCHSNDMSGs done.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. thrrply	Thread reply	/TYP=T/LEN=32767/MECH=REF:W
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOSCHINIT = No scheduler init
	;		HT_TIMEOUT = Timeout
	;		HT_GETDONE = All replies retrieved
	;		HT_NOSHUTDWN = Not in shutdown mode
	;		HT_OSERR = failure - o/s error
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$SCGETMSG^%HTAPI(.reply)
	;
	N STATUS,THRRPLY,ERRNO
	S THRRPLY=$J("",32767)		; memory allocation, 32767 bytes
	;
	S ERRNO=0
	D &htm.scgetmsg(.THRRPLY,.ERRNO)
	S thrrply=THRRPLY
	;
	I ERRNO D
	.	I ERRNO=-1 S STATUS="HT_NOSCHINIT",RM="Scheduler initialization not run" Q
	.	I ERRNO=-2 S STATUS="HT_TIMEOUT",RM="Timeout" Q
	.	I ERRNO=-3 S STATUS="HT_GETDONE",RM="All reply messages have been received" Q
	.	I ERRNO=-4 S STATUS="HT_NOSHUTDWN",RM="Shutdown mode is not active" Q
	.	S RM="("_ERRNO_") "_$ZM(ERRNO),STATUS="HT_OSERR"
	E  S STATUS=""
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
SCSTAT(data)	;System;Return scheduler status
	;----------------------------------------------------------------------
	;
	; Return scheduler status information
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. data	   Status information array	/TYP=array/MECH=REF:W
	;
	;	. data(0)  # of buffers with status=0	/TYP=N
	;		   Status=0 => message from scheduler
	;
	;	. data(1)  # of buffers with status=1	/TYP=N
	;		   Status=1 => thread processing message
	;
	;	. data(2)  # of buffers with status=2	/TYP=N
	;		   Status=2 => reply from thread
	;
	;	. data(3)  # of buffers with status=3	/TYP=N
	;		   Status=3 => slot closed
	;
	;	. data("reg")  # of registered threads	/TYP=N
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOSCHINIT = No scheduler init
	;
  	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$SCSTAT^%HTAPI(.DATA)
	;
	N STATUS,DATA,ERRNO
	S DATA=$J("",32767)		; memory allocation, 32767 bytes
	K data
	;
	S ERRNO=0
	D &htm.scstat(.DATA,.ERRNO)
	;
	I ERRNO=-1 S STATUS="HT_NOSCHINIT",RM="Scheduler initialization not run"
	E  D
	.	N I
	.	S STATUS=""
	.	F I=1:1:4 S data(I-1)=$P(DATA,",",I)
	.	S data("reg")=$P(DATA,",",5)
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
SCBUFDAT(start,data)	;System;Return buffer data
	;----------------------------------------------------------------------
	;
	; Returns the next data buffer from shared memory.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. start	  Starting buffer #	/TYP=N
	;		  Starting buffer number to search
	;
	;	. data	  Return data array	/TYP=array/MECH=REF:W
	;
	;	. data("bufno")  Buffer number	/TYP=N
	;		       Buffer number being returned
	;		       0 indicates done
	;
	;	. data("msgstat") Buffer status	/TYP=N
	;		       0 => scheduler message
	;		       1 => thread processing message
	;		       2 => reply message
	;		       3 => slot closed
	;
	;	. data("thrpid") Thread process ID	/TYP=T
	;			 If status is 1 or 2
	;
	;	. data("data") Buffer contents	/TYP=T/LEN=32767
	;		       Contents of this buffer
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOSCHINIT = No scheduler init
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$SCBUFDAT^%HTAPI(.DATA)
	;
	N STATUS,DATA,BUFNO,MSGSTAT,THRPID,ERRNO
	S DATA=$J("",32767)		; memory allocation, 37676 bytes
	K data
	;
	S ERRNO=0
	D &htm.scbufdat(start,.BUFNO,.MSGSTAT,.THRPID,.DATA,.ERRNO)
	;
	I ERRNO=-1 S STATUS="HT_NOSCHINIT",RM="Scheduler initialization not run"
	E  D
	.	S STATUS=""
	.	S data("bufno")=BUFNO
	.	S data("msgstat")=MSGSTAT
	.	S data("thrpid")=THRPID
	.	S data("data")=DATA
	;
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
SCCLOSE()	;System;Close job scheduler
	;----------------------------------------------------------------------
	;
	; Frees the shared memory.  Final scheduler step.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;
	; EXAMPLE:
	;	S X=$$SCCLOSE^%HTAPI
	;
	N STATUS,ERRNO
	;
	S ERRNO=0
	D &htm.scclose(.ERRNO)
	Q ""
	;
	;----------------------------------------------------------------------
THCNNCT(id)	;System;Create thread connection
	;----------------------------------------------------------------------
	;
	; Connect a thread to the scheduler indicated by id.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. id	Connect ID		/TYP=T
	;		ID passed from scheduler
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_ISCONNECT  = Already connected
	;		HT_NOREGBUFS = No additional registration buffers
	;				 available
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$THCNNCT^%HTAPI(ID)
	;
	N STATUS,ERRNO
	;
	S ERRNO=0
	D &htm.thcnnct(id,.ERRNO)
	;
	I ERRNO D
	.	I ERRNO=-1 S STATUS="HT_ISCONNECT",RM="Thread has already connected" Q
	.	I ERRNO=-2 S STATUS="HT_NOREGBUFS",RM="No registration buffers are available" Q
	.	S RM="("_ERRNO_") "_$ZM(ERRNO),STATUS="HT_OSERR"
	E  S STATUS=""
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
THGETMSG(schmsg)	;System;Get data message from data buffers
	;----------------------------------------------------------------------
	;
	; Get a message from the scheduler
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. schmsg  Scheduler message	/TYP=T/LEN=32767/MECH=REF:W
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOCONNECT = Thread connect not done
	;		HT_NOMSGS0 = No messages, shutdown indicator off
	;		HT_NOMSGS1 = No messages, shutdown indicator on
	;		HT_NOREPLY = Did not reply to last message
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$THGETMSG^%HTAPI(.MSG)
	;
	N STATUS,SCHMSG,ERRNO
	S SCHMSG=$J("",32767)		; memory allocation
	;
	S ERRNO=0
	D &htm.thgetmsg(.SCHMSG,.ERRNO)
	S schmsg=SCHMSG
	;
	I ERRNO D
	.	I ERRNO=-1 S STATUS="HT_NOCONNECT",RM="Thread connect has not been done" Q
	.	I ERRNO=-2 S STATUS="HT_NOMSGS1",RM="No messages, in shutdown status" Q
	.	I ERRNO=-3 S STATUS="HT_NOMSGS0",RM="No messages, not in shutdown status" Q
	.	I ERRNO=-4 S STATUS="HT_NOREPLY",RM="Did not reply to last message retrieved" Q
	.	S RM="("_ERRNO_") "_$ZM(ERRNO),STATUS="HT_OSERR"
	E  S STATUS=""
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
THREPLY(thrrply)	;System;Return thread response message to
	;----------------------------------------------------------------------
	;
	; Send a reply from a thread
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. thrrply  Reply from thread	/TYP=T/LEN=32767
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOCONNECT = Thread connect not done
	;		HT_NOMSG = Never retrieved message
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$THREPLY^%HTAPI(REPLY)
	;
	N STATUS,ERRNO
	;
	S ERRNO=0
	D &htm.threply(thrrply,.ERRNO)
	;
	I ERRNO D
	.	I ERRNO=-1 S STATUS="HT_NOCONNECT",RM="Thread connect has not been done" Q
	.	I ERRNO=-2 S STATUS="HT_NOMSG",RM="Did not retrieve message" Q
	.	S RM="("_ERRNO_") "_$ZM(ERRNO),STATUS="HT_OSERR"
	E  S STATUS=""
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
THCLOSE()	;System;Close thread connection
	;----------------------------------------------------------------------
	;
	; Disconnect a thread from a scheduler's shared memory
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$	Condition value		/TYP=T
	;               null = success
	;		HT_NOCONNECT = Thread connect not done
	;
	;	. RM	Failure reason if $$ return is not success
	;
	; EXAMPLE:
	;	S X=$$THCLOSE^%HTAPI
	;
	N STATUS,ERRNO
	;
	S ERRNO=0
	D &htm.thclose(.ERRNO)
	;
	I ERRNO=-1 S STATUS="HT_NOCONNECT",RM="Thread connect has not been done"
	E  S STATUS=""
	;
	Q STATUS
