DBAPI  ;Public;DATABASE API
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserv^
	; ORIG: GIRIDHARANB - 02/15/02
	; DESC: DATABASE API
	;
	; KEYWORDS:
	;
	; INPUTS:
	;       . System
	;
	;       . Data  [ddfile]di
	;
	;       . v1    desc of variable        /TYP=T
	;
	; RETURNS:
	;       . XX    desc of return          /TYP=T
	;
	; RELATED:
	;       . $$func^rtn - description of how related
	;
	; EXAMPLE:
	;       Text of example (line one)
	;
	; ------- Revision History ----------------------------------
	; 03/28/06 - Pete Chenard - CR
	;	     Modified SVXCHGMSG to move the 'get reply' logic
	;	     into its own loop, separate from the exchange message
	;	     API.  This prevents the code from resending the same message
	;	     if it gets a reply that it didn't expect.
	;
	; 03/16/06 - GIRIDHARAN - CR18240
	;	     Minor changes/Cleanup or API's. Release for 
	;	     the CP project.
	;
	; 07/18/05 - Manoj Thoniyil CR 18181
	;	     Added new APIs to send/receive messages to/from
	;	     the cursor pool processes.
	;
	; 03/21/05 - Pete Chenard CR 18181
	;	     Modified all APIs to New ER and initialize it
	;	     to null.
	;------------------------------------------------------------
	;
	;
	;------------------------------------------------------------
DBCNCT(inipath,index,RM)
	;------------------------------------------------------------
	; 	Connects to the target database
	;       Input Arguments: inipath, path to the initialization
	;		         file
	;                        /TYP=T/NOREQ/VAL
	;
	;                        index, index of array of DBhandles
	;                        /TYP=T/NOREQ/VAL
	;
	;       Returns          1- Success
	;                        0- Failure
	;-----------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(inipath)="" S inipath=$$TRNLNM^%ZFUNC("SCAU_DB_INI")
	I $G(index)="" S index=0 
	;
	D &libdbapi.connect(inipath,index,.RM,.ER)
	Q ER
	;
	;-----------------------------------------------------------
DBDSCNCT(index,RM)
	;-----------------------------------------------------------
	;	Disconnects from the target database
	;
	;	Input Arguments:
	;		Index	Database Index
	;			/TYP=T/NOREQ/VAL
	;
	;	Returns		 1- Success
	;			 0- failure
	;	
	;	Sets:	ER - Error Code
	;		RM - Error Message
	;---------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	;
	D &libdbapi.disconnect(index,.RM,.ER)
	Q ER
	;
	;---------------------------------------------------------------
EXECUTE(index,sqlmsg,del,list,RM)
	;---------------------------------------------------------------
	;Executes a SQL statement on the target database
	;
	;	Input Arguments:
	;		Sqlmsg	-SQL create Statement
	;			 /TYP=T/REQ/VAL
	;
	;		Index	-Database Index
	;			 /TYP=T/NOREQ/VAL
	;
	;	Returns:    1 - Success
	;		    0 - Failure
	;
	;	Sets:       ER - Error Code
	;		    RM - Error Message
	;---------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	I $G(del)="" S del=$C(124)
	;
	D &libdbapi.execute(index,sqlmsg,del,$G(list),.RM,.ER)
	Q ER
	;
	;---------------------------------------------------------------
SELECT(index,sqlmsg,del,list,data,RM)
	;---------------------------------------------------------------
	; Executes a Select Statement on the Database
	;       Input Parameters:
	;               sqlmsg  - Select Statement
	;                         /TYP=T/REQ/VAL
	;
	;		del	- Delimiter
	;			  /TYP=T/REQ/VAL
	;
	;               index   - Database Index
	;
	;       Returns:  1 - success
	;                 0 - Failure
	;
	;       Sets:     ER - Error Code
	;                 RM - Error Message
	;---------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	I $G(del)="" S del=$C(124)
	;
	D &libdbapi.select(index,sqlmsg,del,$G(list),.data,.RM,.ER)
	Q ER
	;
	;---------------------------------------------------------------
OPENCUR(index,sqlmsg,del,list,cid,RM)
	;---------------------------------------------------------------
	;Executes an open Cursor Statement on the database
	;
	;       Input Parameters:
	;               sqlmsg  - Open Cursor Statement
	;                         /TYP=T/REQ/VAL
	;
	;               index   - Database Index
	;                         /TYP=T/NOREQ/VAL
	;
	;       Returns:  1 - success
	;                <1 - Failure
	;
	;       Sets:     ER - Error Code
	;                 RM - Error Message
	;---------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	;
	D &libdbapi.opencursor(index,sqlmsg,$C(9),list,.cid,.RM,.ER)
	Q ER
	;
	;---------------------------------------------------------------
CLOSECUR(index,cid,RM)
	;---------------------------------------------------------------
	;Executes an close Cursor Statement on the database
	;
	;       Input Parameters:
	;               cid - Cursor_id Returned from Open cursor
	;                         /TYP=T/REQ/VAL
	;
	;               index   - Database Index
	;                         /TYP=T/NOREQ/VAL
	;
	;       Returns:  1 - success
	;                 0 - Failure
	;
	;       Sets:     ER - Error Code
 	;		  RM - Error Message
	;-------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	;
	D &libdbapi.closecursor(index,cid,.RM,.ER)
	Q ER
	;
	;---------------------------------------------------------------
FETCH(index,cid,rows,del,data,RM)
	;---------------------------------------------------------------
	;Executes an Fetch Statement on the database
	;
	;       Input Parameters:
	;               cursor_id - Cursor_id Returned from Open cursor
	;                         /TYP=T/REQ/VAL
	;
	;               index   - Database Index
	;                         /TYP=T/NOREQ/VAL
	;		
	;		rows - Number of rows to be retrieved
	;			   /TYP=T/REQ/VAL
	;
	;		del	 - Delimiter
	;			   /TYP=T/REQ/DEF=$C(124)
	;
	;       Returns:  1 - success
	;                 0 - Failure
	;
	;       Sets:     ER - Error Code
 	;---------------------------------------------------------------
 	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	I $G(del)="" S del=$C(124)
	;
	D &libdbapi.fetch(index,cid,.rows,del,.data,.RM,.ER)
	Q ER
	;
	;---------------------------------------------------------------
COMMIT(index,RM)
	;---------------------------------------------------------------
	; Commit a profile Transaction
	;
	;       Input Parameters:
	;              
	;               index   - Database Index
	;                         /TYP=T/NOREQ/VAL
	;
	;
	;       Returns:  1 - success
	;                 0 - Failure
	;
	;       Sets:     ER - Error Code
	;--------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	;
	D &libdbapi.commit(index,.RM,.ER)
	Q ER
	;
	;--------------------------------------------------------------
ROLLBACK(index,RM)
	;--------------------------------------------------------------
	;Rolls Back a profile commit
	;       Input Parameters:
	;
	;               index   - Database Index
	;                         /TYP=T/NOREQ/VAL
	;
	;
	;       Returns:  1 - success
	;                 0 - Failure
	;
	;       Sets:     ER - Error Code
	;--------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	;
	D &libdbapi.rollback(index,.RM,.ER)
	Q ER
	;
	;-------------------------------------------------------------
GETVAL(index,sqlmsg,del,list,RM)	
	;-------------------------------------------------------------
	;Fetches the values from a sequence
	;
	;	Input Arguments	
	;
	;		Index	-Database Index
	;			/TYP=T/NOREQ/DEF=0
	;		sqlmsg	-SQL string
	;			/TYP=T/REQ/NODEF
  	;               del     -Delimiter
	;                       /TYP=T/REQ/VAL
	;		list	-array of values
	;			
	;       Returns:  1 - success
	;                 0 - Failure
	;
	;       Sets:     ER - Error Code
	;                 RM - Error Message
	;-------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	I $G(del)="" S del=$C(124)
	;
	D &libdbapi.select(index,sqlmsg,del,list,.data,.RM,.ER)
	Q ER
	;
	;------------------------------------------------------------
EXECSP(index,procname,colval,novals,del,data,RM)
	;-----------------------------------------------------------
	;Executes a stored procedure on the oracle database
	;
	;       Input Arguments
	;               Index    -Database Index
	;                       /TYP=T/NOREQ/DEF=0
	;               procname -name of the stored procedure
	;                       /TYP=T/REQ/NODEF
	;		colval   -list of column values
	;			/TYP=T/REQ/NODEF
	;		nocols   -number of columns
	;			/TYP=T/REQ/NODEF
	;               del     -Delimiter
	;                       /TYP=T/REQ/VAL
	;		data  -data returned from the database
	;			/TYP=T/REQ/NODEF
	;--------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	S colval=$G(colval)
	;
	D &libdbapi.storedproc(index,procname,colval,novals,$G(del),.data,.RM,.ER)
	Q ER
	;
	;--------------------------------------------------------------
EXECCP(index,procname,collist,tabnam,cond,hostval,RM)
	;-------------------------------------------------------------
	;Executes the create_proc procedure on the oracle database
	;
	;       Input Arguments
	;               Index    -Database Index
	;                       /TYP=T/NOREQ/DEF=0
	;               procname -name of the stored procedure
	;                       /TYP=T/REQ/NODEF
	;               colval   -list of column values
	;                       /TYP=T/REQ/NODEF
	;               nocols   -number of columns
	;                       /TYP=T/REQ/NODEF
	;               del     -Delimiter
	;                       /TYP=T/REQ/VAL
	;               data  -data returned from the database
	;                       /TYP=T/REQ/NODEF
	;--------------------------------------------------------------
	;
	N ER
	S ER=""
	;
	I $G(index)="" S index=0
	I $G(del)="" S del=$C(124)
	;
	D &libdbapi.createproc(index,procname,collist,tabnam,cond,$G(hostval),.RM,.ER)
	Q ER
	;
	;----------------------------------------------------------------------
CQSTART()  ;System;Start the cursor queues
	;----------------------------------------------------------------------
	;
	; Creates the Request and Reply queues for the server and cursor
	; processes to communicate.
	;
	; KEYWORDS:     System services
	;
	; ARGUMENTS:
	;
	; RETURNS:
	;     . Condition value NULL = success
	;               CS_MTERROR = general error, id will contain message
	;               See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;       S X=$$CQSTART^%DBAPI()
	;----------------------------------------------------------------------
	;
	N ERRNO
	S ERRNO=0
	;
	D &srvapi.CurQStart(.ERRNO)
	;
	I ERRNO=-39 Q "CS_CQEXISTS"
	I ERRNO S RM=$ZM(ERRNO) Q "CS_ERROR"
	Q ""
	;
	;----------------------------------------------------------------------
CQSTOP()    ;System;Stop the Cursor Queues
	;----------------------------------------------------------------------
	;
	; Stops the queues used to communicate to cursor processes.
	;
	; KEYWORDS:     System services
	;
	; ARGUMENTS:
	;
	;
	; RETURNS:
	;     . Condition value NULL = success
	;               CS_MTERROR = general error, id will contain message
	;               See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	;     . RM      Failure reason if return is CS_MTERROR
	;
	; EXAMPLE:
	;       S X=$$CQSTOP^%DBAPI()
	;
	;----------------------------------------------------------------------
	;
	N ERRNO
	S ERRNO=0
	;
	D &srvapi.CurQStop(.ERRNO)
	;
	if ERRNO=-40 Q "CS_CQNOEXIST"
	I ERRNO S RM=$ZM(ERRNO) Q "CS_ERROR"
	Q ""
	;
	;----------------------------------------------------------------------
SVXCHMSG(msgtyp,svid,msg,reply,timeout)    ;System;Server exchange message
	;----------------------------------------------------------------------
	;
	; Sends a server message to the cursor for processing by a valid 
	; cursor process and returns a reply to the message.
	;
	; The reply message from the cursor may itself be an error message,
	; either a specific CS_* error or a general error.
	;
	; For a CS_TIMEOUT failure try to reconnect.  If succeed, report at
	; timeout, otherwise, report as CS_TIMEOUTNC.
	;
	; KEYWORDS:     System services
	;
	; ARGUMENTS:
	;     . msgtyp	Type of the message
	;		1 (generic) for OPEN CURSOR
	;		Cursor process ID for FETCH and CLOSE
	;
	;     . svid	Server ID ($J)
	;
	;     . msg     Message to cursor
	;
	;     . reply   Response from cursor
	;
	;     . timeout Timeout interval
	;               Time to wait before giving up and returning a timeout
	;               error message.
	;
	; RETURNS:
	;     . Condition value NULL = success
	;               CS_TIMEOUT = Timeout
	;               CS_ERROR   = General error, reply will contain message
	;               See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;       S X=$$SVXCHMSG^%DBAPI(mtyp,svid,msghdr,.MSG,.REPLY,15)
	;----------------------------------------------------------------------
	;
	N ERRNO,ERRMSG,EXIT,TIME,TIMEOUT
	;
	S ERRNO=0,ERRMSG=""
	;
	S TIME=$H*1E5+$P($H,",",2)
	S TIMEOUT=timeout
	;
	S reply=""
	S $P(reply," ",1048576)=""
	D &srvapi.SrvExchMsg(msgtyp,svid,.msg,.reply,timeout,.ERRNO)
	;
	; If error, set ERRMSG and exit
	I ERRNO=-10 S ERRMSG="CS_TIMEOUT" Q ERRMSG
	I ERRNO<0 S RM=$ZM(ERRNO) S ERRMSG="CS_ERROR" Q ERRMSG
	;
	; If the message headers match (bytes 1-10),
	; return to caller.
	;
	I $E(reply,1,10)=$E(msg,1,10) S EXIT=1 Q ""	
	;
	; Otherwise, reduce the timeout by the elapsed time
	; inside of the API; if less than zero, set TIMEOUT
	; error message and exit.  If time still remains on
	; the timer, the SrvGetReply API will be executed
	; again to retrieve the reply message associated
	; with the server request message.
	;
	S EXIT=0
	F  D  Q:EXIT
	.	S timeout=TIMEOUT-($H*1E5+$P($H,",",2)-TIME)
	.	I timeout<0 S ERRMSG="CS_TIMEOUT",EXIT=1 Q
	.	S reply=""
	.	S $P(reply," ",1048576)=""
	.	D &srvapi.SrvGetReply(msgtyp,.reply,timeout,.ERRNO)
	.	; If error, set ERRMSG and exit
	.	I ERRNO=-10 S ERRMSG="CS_TIMEOUT",EXIT=1 Q
	.	I ERRNO<0 S RM=$ZM(ERRNO) S ERRMSG="CS_ERROR",EXIT=1 Q
	.	;
	.	; If the message headers match (bytes 1-10),
	.	; return to caller.
	.	;
	.	I $E(reply,1,10)=$E(msg,1,10) S EXIT=1 Q
	;
	Q ERRMSG
	;
	;----------------------------------------------------------------------
CPCNCT()    ;System;Cursor connect to transport
	;----------------------------------------------------------------------
	;
	; Allows connection of a cursor process to the transport layer.
	;
	; KEYWORDS:     Message Transport
	;
	; ARGUMENTS:
	;
	; RETURNS:
	;     . Condition value
	;               NULL        =   success
	;               CS_SVTYP    =   No logical name defined for service type
	;               CS_NOMTM    =   Transport is not active or does not
	;                               respond
	; EXAMPLE:
	;       S X=$$CPCNCT^%DBAPI()
	;
	;----------------------------------------------------------------------
	;
	; Get the transport name from the server type table
	;
	N ERRNO
	S ERRNO=0
	;
	D &curapi.CurConnect(.ERRNO)
	;
	I ERRNO=-41 S RM="Already Connected" Q "CS_DUPLCNCT"
	I ERRNO S RM=$ZM(ERRNO) Q "CS_ERROR"
	Q ""
	;
	;----------------------------------------------------------------------
CPDSCNCT()    ;System;Cursor disconnect from transport
	;----------------------------------------------------------------------
	;
	; Disconnects a cursor process from the transport layer.
	;
	; KEYWORDS:
	;
	; ARGUMENTS:
	;
	; RETURNS:
	;     . Condition value
	;               NULL = always
	;               See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;       S X=$$CPDSCNCT^%DBAPI()
	;
	;----------------------------------------------------------------------
	;
	D &curapi.CurDisconnect()
	Q ""
	;
	;----------------------------------------------------------------------
CPGETMSG(msgtyp,msg,timeout)    ;System;Cursor get message from server
	;----------------------------------------------------------------------
	;
	; Gets a message that was sent from a server and destined for the
	; cursor process.
	;
	; KEYWORDS:
	;
	; ARGUMENTS:
	;     . msgtyp	ID of client
	;
	;     . msg     Message from server
	;
	;     . timeout Timeout interval
	;               Time to wait without receiving a message before
	;               returning a timeout error message.
	;
	; RETURNS:
	;     . Condition value
	;               NULL       = success
	;               CS_TIMEOUT = timeout occurred
	;               CS_MTERROR = UNIX error, msg holds error message
	;               CS_MTMSTOP = MTM stopped, forced server stop
	;               See /usr/include/sys/errno.h and ${MTS_INC}/mtserrno.h
	;
	; EXAMPLE:
	;       S X=$$CPGETMSG^%DBAPI(.MSGTYP,.MSG,60)
	;
	;----------------------------------------------------------------------
	;
	N ERRNO
	;
	I '$G(timeout) S timeout=30
	S ERRNO=0
	;
	S msg=""
	S $P(msg," ",1048576)=""
	D &curapi.CurGetMsg(msgtyp,.msg,timeout,.ERRNO)
	;
        I ERRNO=-42 S RM="Not Connected" Q "CS_NOCNCT"
        I ERRNO=-10 S RM="Timed Out" Q "CS_TIMEOUT"
	I ERRNO<0 S RM=$ZM(ERRNO) Q "CS_ERROR"
	Q ""
	;
	;----------------------------------------------------------------------
CPREPLY(msgtyp,reply)   ;System;Cursor send reply message to server
	;----------------------------------------------------------------------
	;
	; Sends a reply message to a server in response to a message received
	; by the cursor.
	;
	; KEYWORDS:
	;
	; ARGUMENTS:
	;     . msgtyp	ID of server
	;
	;     . reply   Reply message to server
	;
	; RETURNS:
	;     . Condition value
	;               NULL         = success
	;
	; EXAMPLE:
	;       S X=$$CPREPLY^%DBAPI(msgtyp,.REPLY)
	;----------------------------------------------------------------------
	;
	N ERRNO
	S ERRNO=0
	;
	D &curapi.CurReply(msgtyp,.reply,.ERRNO)
	;
        I ERRNO=-42 S RM="Not Connected" Q "CS_NOCNCT"
	I ERRNO<0 S RM=$ZM(ERRNO) Q "CS_ERROR"
	Q ""
