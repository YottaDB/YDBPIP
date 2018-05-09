%ZMBX	;Library;IO handler for mailboxes
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/13/94 11:15:13 - SYSRUSSELL
	; ORIG:  Dan S. Russell - 4/5/89
	;
	; General IO handlers for mailboxes under GT.M
	; Sections provided for OPEN, WRITE, READ, and CLOSE.
	;
	; KEYWORDS:	Device handling
	;
	; LIBRARY:
	;	. $$OPEN	- Open mailbox
	;
	;	. WRITE		- Write to a mailbox
	;
	;	. $$READ	- Read from a mailbox
	;
	;	. $$CLOSE	- Close a mailbox
	;
	;----------------------------------------------------------------------
OPEN(NAME,PARAMS)	;Public;Open mailbox
	;----------------------------------------------------------------------
	;
	; Open a VMS mailbox.  Allows either permanent or temporary mailboxes
	; of a specified record size to be opened.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. NAME		Mailbox name		/TYP=T
	;
	;	. PARAMS	Parameter list		/TYP=CMDLN
	;			Valid commands are:	/DEF="PRMMBX/RECORD=512"
	;			  PRMMBX - permanent
	;			  TMPMBX - temporary
	;			  RECORD=size - record size
	;
	; RETURNS:
	;	. $$		If success, NAME is	/TYP=T
	;			returned for use in subsequent READ,
	;			WRITE, and CLOSE calls.
	;			If failure, returns one of 
	;			the following messages:
	;               	  "0|NAME parameter missing"
	;               	  "0|Unable to open 'name'"
	;
	; EXAMPLE:
	;	S X=$$OPEN^%ZMBX("MBX_TST","PRMMBX/RECORD=512")
	;
	N X,XPARAMS,RECORD
	I '$D(NAME) Q "0|NAME parameter missing"
	S PARAMS=$G(PARAMS)
	S XPARAMS="PRMMBX:"
	I PARAMS["TMPMBX",PARAMS'["PRMMBX" S XPARAMS="TMPMBX:"
	S X=$F(PARAMS,"RECORD="),RECORD=+$E(PARAMS,X,999)
	I 'RECORD S RECORD=512
	S XPARAMS=XPARAMS_"BLOCKSIZE="_RECORD
	S X="NAME:("_XPARAMS_"):2"
	O @X I  Q NAME
	Q "0|Unable to open "_NAME
	;
	;----------------------------------------------------------------------
WRITE(IO,MSG)	;Public;Write message to mailbox
	;----------------------------------------------------------------------
	;
	; Write a message to a previously opened VMS mailbox.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. IO		Mailbox name		/TYP=T
	;
	;	. MSG		Message string to write	/TYP=T
	;			  RECORD=size - record size (default = 512)
	;
	; RETURNS:
	;	. ER		Error flag		/TYP=L
	;			0 => no error
	;			1 => error
	;
	;	. RM		Error message, if error	/TYP=T
	;               	  "0|Unable to open 'name'"
	;
	; EXAMPLE:
	;	D WRITE^%ZMBX(IO,"Test output message")
	;
	I '$D(IO) S ER=1,RM="Missing parameter 'IO'" Q
	I '$D(MSG) S ER=1,RM="Missing parameter 'MSG'" Q
	;
	U IO W MSG
	Q
	;
	;----------------------------------------------------------------------
READ(IO,PARAMS)	;Public;Read message from mailbox
	;----------------------------------------------------------------------
	;
	; Read a message from a previously opened VMS mailbox.  Allows either
	; synchronous read (waits until a message is present in mailbox), or
	; asynchronous read (reads whatever is there now - may be null).
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. IO		Mailbox name		/TYP=T
	;
	;	. PARAMS	Parameter list		/TYP=CMDLN/DEF="ASYNC"
	;			Valid commands are:	
	;			  RECORD=size - maximum record size
	;			                Ignored by GT.M
	;			  SYNC - synchronous read
	;			  ASYNC - asynchronous read
	;
	; RETURNS:
	;	. $$		Message read		/TYP=T
	;			Returns null if IO parameter
	;			not specified
	;
	; EXAMPLE:
	;	S X=$$READ^%ZMBX(IO,"RECORD=512/ASYNC")
	;
	I '$D(IO) Q ""
	N X,ASYNC
	;
	S ASYNC=1
	I PARAMS["SYNC",PARAMS'["ASYNC" S ASYNC=0
	I 'ASYNC U IO R X ; Sync
	E  U IO R X:0 ; Async
	Q X
	;
	;----------------------------------------------------------------------
CLOSE(IO)	;Public;Close mailbox
	;----------------------------------------------------------------------
	;
	; Close a previously opened VMS mailbox.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. IO		Mailbox name		/TYP=T
	;
	; RETURNS:
	;	. $$		If success, returns 1	/TYP=T
	;			If failure, returns
	;			the following messages:
	;               	  "0|IO parameter missing"
	;
	; EXAMPLE:
	;	S X=$$CLOSE^%ZMBX(IO)
	;
	I '$D(IO) Q "0|IO parameter missing"
	;
	C IO:DELETE ; Mark for deletion
	Q 1
