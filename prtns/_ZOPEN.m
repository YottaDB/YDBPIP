%ZOPEN	;Library; IO handler to open devices
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/09/94 12:59:23 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 11/03/88
	;
	; General OPEN command handler for GT.M.  Version will exist under 
	; M/VX also.
	;
	; All parameters are passed in string PARAMS, which is then decoded 
	; appropriately.  Parameters which have no meaning for GT.M are ignored.
	;
	; KEYWORDS:	Device handling
	;
	; LIBRARY:
	;	. $$TERM - Open terminal device
	;
	;	. $$FILE - Open RMS file
	;
	;	. $$TAPE - Open mag tape
	;
	;---- Revision History -------------------------------------------------
	;
	; 05/09/94 - Dan Russell
	;            Modified FILE section to all "FIXED" parameter
	;
	; 04/12/94 - Phil Chenard
	;            Modified FILE section to allow "SHARED" parameter
	;
	; 06/16/92 - Pete Chenard
	;            Modified FILE section to allow "APPEND" parameter
	;-----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
TERM(DEVICE,TIMEOUT)	;Public; Open terminal DEVICE, including printers
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	Terminal/printer	/TYP=T
	;
	;	. TIMEOUT	Timeout in seconds	/TYP=N/DEF=no timeout
	;
	; RETURNS:
	;	. $$		Success or failure	/TYP=T
	;			Success = 1
	;			Failure returns one of following:
	;			  "0|DEVICE parameter missing"
	;			  "0|Timeout failure"
	;			  "0|Unable to open DEVICE"
	;
	; RELATED:
	;	. TERM^%ZUSE - USE command handling
	;
	; EXAMPLE:
	;	S X=$$TERM^%ZOPEN(IO,5) => Open IO with 5 second timeout
	;
	I '$D(DEVICE) Q "0|DEVICE parameter missing"
	; UNIX
	S DEVICE=$P(DEVICE,"/",1,3)
	N $ZT
	S $ZT="G NOTOPEN^%ZOPEN"
	I $G(TIMEOUT)="" O DEVICE Q 1
	O DEVICE::TIMEOUT I  Q 1
	Q "0|Timeout failure"
	;
	;----------------------------------------------------------------------
FILE(DEVICE,PARAMS,TIMEOUT,RECSIZ)	;Public; Open RMS file
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	RMS file name		/TYP=T
	;			Must contain necessary directory reference
	;
	;	. PARAMS	Open parameters		/TYP=CMDLN
	;			Command line parameter	/DEF="READ/WRITE"
	;			list.  Options are:
	;			  READ or WRITE
	;			  NEWV - new version
	;			  APPEND
	;			  SHARED
	;			  FIXED
	;			WRITE always forces stream mode, unless FIXED
	;
	;	. TIMEOUT	Timeout in seconds	/TYP=N/DEF=no timeout
	;
	;	. RECSIZ	Record size		/TYP=N/DEF=512
	;
	; RETURNS:
	;	. $$		Success or failure	/TYP=T
	;			Success = 1
	;			Failure returns one of following:
	;			  "0|DEVICE parameter missing"
	;			  "0|Timeout failure"
	;			  "0|Unable to open DEVICE"
	;
	; RELATED:
	;	. FILE^%ZUSE - USE command handling
	;
	; EXAMPLE:
	;	S X=$$FILE^%ZOPEN(RMS,"WRITE/NEWV",5)
	;	  => Open file name RMS, a new version for write access with
	;	     a 5 second timeout
	;
	N APPEND,FIXED,XPARAMS,READ,WRITE,NEWV,X,SHARED
	I '$D(DEVICE) Q "0|DEVICE parameter missing"
	;UNIX
	I DEVICE["append" S DEVICE=$P(DEVICE,"/",1,3)
	I DEVICE["APPEND" S DEVICE=$P(DEVICE,"/",1,3)
	;
	; ADDED BY WGG 5-2-91, ALLOWS FOR EXPANDED RMS RECORDSIZE
	I $G(RECSIZ)="" S RECSIZ=512
	I $G(PARAMS)="" S PARAMS="READ/WRITE"
	E  S PARAMS=$$UPPER^%ZFUNC(PARAMS)
	;
	N $ZT S $ZT="G NOTOPEN^%ZOPEN"
	S READ=PARAMS["READ",WRITE=PARAMS["WRITE",NEWV=PARAMS["NEWV"
	S APPEND=1-NEWV,SHARED=PARAMS["SHARED"
	I 'READ,'WRITE S (READ,WRITE)=1
	S FIXED=PARAMS["FIXED"
	S XPARAMS=$S('WRITE:"READONLY:",1:"NOREADONLY:")
	I NEWV S XPARAMS=XPARAMS_"NEWV:"
	I APPEND&(XPARAMS["NOREADONLY") S XPARAMS=XPARAMS_"APPEND:"
	I SHARED&(XPARAMS["NOREADONLY") S XPARAMS=XPARAMS_"SHARED:"
	S XPARAMS=XPARAMS_"RECORDSIZE="_RECSIZ_":"
	I FIXED S XPARAMS=XPARAMS_"FIXED:"
	S X="DEVICE:("_$E(XPARAMS,1,$L(XPARAMS)-1)_")"
	I $G(TIMEOUT)="" O @X Q 1
	S X=X_":"_TIMEOUT
	O @X I  Q 1
	Q "0|Timeout failure"
	;
	;----------------------------------------------------------------------
TAPE(DEVICE,PARAMS,TIMEOUT)	;Public; Open tape drive
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	RMS file name		/TYP=T
	;			Must contain necessary directory reference
	;
	;	. PARAMS	Open parameters		/TYP=CMDLN
	;			Command line parameter	/DEF="NOEBCDIC
	;			list.  Options are:	      /NOLABEL/NOINIT
	;			  [NO]EBCDIC		      /NOMOUNT/NOREWIND"
	;			  FIXED or VARIABLE
	;			    (stream used if not FIXED or VARIABLE)
	;			  [NO]LABEL
	;			  RECORD=nnn  - record size for FIXED
	;			  BLOCK=nnn   - block size for FIXED or stream
	;			  INIT        - initialize tape
	;			  MOUNT       - mount tape
	;			  DENSITY=nnn - density for INIT
	;			  TAPELAB     - tape label for INIT or
	;				        for non-foreign MOUNT
	;			  FOREIGN     - if MOUNT, do so FOREIGN
	;			  REWIND
	;
	;	. TIMEOUT	Timeout in seconds	/TYP=N/DEF=no timeout
	;
	; RETURNS:
	;	. $$		Success or failure	/TYP=T
	;			Success = 1
	;			Failure returns one of following:
	;			  "0|DEVICE parameter missing"
	;			  "0|Timeout failure"
	;			  "0|Unable to open DEVICE"
	;			  "0|Invalid parameters (Fixed and Variable)"
	;			  "0|Invalid parameters (No record or block 
	;				size)"
	;			  "0|Invalid parameters (Block size not even
	;				records)"
	;			  "0|Invalid parameters (Record size not 
	;				allowed)"
	;			  "0|Tape init failed"
	;			  "0|Tape mount failed"
	;
	; RELATED:
	;	. TAPE^%ZUSE - USE command handling
	;
	; EXAMPLE:
	;	S X=$$TAPE^%ZOPEN("TAPE0","EBCDIC/LABEL/FIXED/RECORD=100 -
	;		/BLOCK=1000")
	;
	N XPARAMS,EBCDIC,FIXED,VARIABLE,LABEL,RECORD,BLOCK,INIT,MOUNT,DENSITY,X,TAPELAB,FOREIGN,REWIND
	I '$D(DEVICE) Q "0|DEVICE parameter missing"
	D PPTDRV^%ZINIT(DEVICE) I ER Q "0|Invalid tape device"
	;
	I $L($G(PARAMS)) S PARAMS=$$UPPER^%ZFUNC(PARAMS)
	N $ZT S $ZT="G NOTOPEN^%ZOPEN"
	;
	S EBCDIC=(PARAMS["EBCDIC"&(PARAMS'["NOEBCDIC"))
	S FIXED=PARAMS["FIXED",VARIABLE=PARAMS["VARIABLE"
	S LABEL=(PARAMS["LABEL"&(PARAMS'["NOLABEL"))
	S RECORD=PARAMS["RECORD=",BLOCK=PARAMS["BLOCK="
	S INIT=PARAMS["INIT",MOUNT=PARAMS["MOUNT",FOREIGN=PARAMS["FOREIGN"
	S REWIND=PARAMS["REWIND"
	S (DENSITY,TAPELAB)=""
	;
	I INIT S X=$F(PARAMS,"DENSITY=") I X S X=$E(PARAMS,X,999),DENSITY=$P(X,"/",1)
	I INIT!MOUNT S X=$F(PARAMS,"TAPELAB=") I X S X=$E(PARAMS,X,999),TAPELAB=$P(X,"/",1)
	I RECORD S X=$F(PARAMS,"RECORD="),RECORD=+$E(PARAMS,X,999)
	I BLOCK S X=$F(PARAMS,"BLOCK="),BLOCK=+$E(PARAMS,X,999)
	I FIXED,VARIABLE Q "0|Invalid parameters (Fixed and Variable)"
	I FIXED,'RECORD!'BLOCK Q "0|Invalid parameters (No record or block size)"
	I FIXED,BLOCK#RECORD!(BLOCK<RECORD) Q "0|Invalid parameters (Block size not even records)"
	I 'FIXED,RECORD Q "0|Invalid parameters (Record size not allowed)"
	;
	S XPARAMS=$S(EBCDIC:"EBCDIC:",1:"NOEBCDIC:")
	I LABEL S XPARAMS=XPARAMS_"LABEL=""ANSI"":"
	E  S XPARAMS=XPARAMS_"NOLABEL:"
	S XPARAMS=XPARAMS_$S(FIXED:"FIXED:",1:"VARIABLE:")
	I RECORD!BLOCK S XPARAMS=XPARAMS_"RECORD="_RECORD_":BLOCK="_BLOCK_":"
	I REWIND S XPARAMS=XPARAMS_"REWIND:"
	S XPARAMS=$E(XPARAMS,1,$L(XPARAMS)-1)
	;
	I INIT S X=$$EXT^%ZINIT(DEVICE,DENSITY,TAPELAB) I 'X Q "0|Tape init failed"
	I MOUNT S X=$$EXT^%ZMOUNT(DEVICE,FOREIGN,TAPELAB) I 'X Q "0|Tape mount failed"
	;
	S X="DEVICE:("_XPARAMS_")"
	I $G(TIMEOUT)="" O @X Q 1
	S X=X_":"_TIMEOUT
	O @X I  Q 1
	Q "0|Timeout failure"
	;
NOTOPEN	Q "0|Unable to open "_DEVICE ; Error on attempt to open
