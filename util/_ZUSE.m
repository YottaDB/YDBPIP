%ZUSE	;Library;General USE command handler for GT.M
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/28/95 08:14:16 - CHENARD
	; ORIG:  Dan S. Russell (2417) - 11/03/88
	;
	; General USE command handler for GT.M  Version will also exist under 
	; M/VX.
	;
	; See ^%ZOPEN for OPEN command handling
	;
	; Use this routine for non-simple USE commands, e.g. anything other 
	; than U IO.
	;
	; All parameters are passed in string PARAMS, which is then decoded 
	; appropriately.  Parameters which have no meaning for GT.M are ignored.
	;
	; KEYWORDS:	Device handling
	;
	; LIBRARY:
	;	. TERM		- Use terminal/printer device
	;
	;	. FILE		- Use RMS file
	;
	;	. TAPE		- Use mag tape device
	;
	;	. EOFHDR	- Write EOF records, TM, new HDR records to tape
	;
	;	. $$EOT		- Check for end-of-tape when writing to tape
	;
	;	. $$%EOT	- Compilable check for end-of-tape
	;
	;-------Revision History-----------------------------------------------	
	; 06/28/95 - Phil Chenard - 13005 
	;            Modified TERM section to accomodate the differences between
	;            the terminal device defaults in MUMPS on a UNIX operating
	;            system.  

	;----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
TERM(DEVICE,PARAMS,USE)	;Public;Use terminal DEVICE, including printers
	;----------------------------------------------------------------------
	;
	; Issues USE command with parameters to terminal/printer device that
	; is either primary device or has been previously opened.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	Terminal/printer	/TYP=T
	;
	;	. PARAMS	USE parameters		/TYP=CMDLN/DEF=""
	;			Command line parameter
	;			list.  Options are:
	;			  [NO]CENABLE	 - control-C [not] enabled
	;			  [NO]ECHO
	;			  [NO]ESCAPE
	;			  [NO]PASTHRU
	;			  [NO]TYPEAHEAD
	;			  TERMINATOR=... - specify terminators as
	;					   (term,term,...)
	;			  WIDTH=nnn      - specify right margin (if 
	;					   less than 134, will use 
	;					   specified margin, otherwise 
	;					   will force to 132.  133 
	;					   retained to allowed bypass 
	;					   of auto-line feed.)
	;			  [NO]WRAP
	;
	;	. USE	USE executable string.  Allow subsequent use of U @USE
	;
	; RELATED:
	;	. $$TERM^%ZOPEN - OPEN command handling
	;
	; EXAMPLE:
	;	D TERM^%ZUSE(IO,"NOECHO",.USE)
	;	  => U IO:(NOECHO) to use device
	;	     and return of USE="U IO:(NOECHO)"
	;
	;----------------------------------------------------------------------
	N MARGIN,PAGELEN,TERMIN,BREAK,X,XPARAMS
	S PARAMS=$$UPPER^%ZFUNC(PARAMS)
	S XPARAMS=""
	;
	I PARAMS["WIDTH" D
	.	S MARGIN=+$P(PARAMS,"WIDTH=",2)
	.	S MARGIN=$S(MARGIN'>133:MARGIN,1:132)
	.	S XPARAMS=XPARAMS_"WIDTH="_MARGIN_":"
	I PARAMS["LEN" D
	.	S PAGELEN=+$P(PARAMS,"LEN=",2)
	.	S XPARAMS=XPARAMS_"LEN="_PAGELEN_":"
	I PARAMS["CENABLE" D
	.	I PARAMS["NOCENABLE" S XPARAMS=XPARAMS_"NOCENABLE:"
	.	E  S XPARAMS=XPARAMS_"CENABLE:"
	S X=$F(PARAMS,"TERMINATOR=") I X D
	.	S X=$E(PARAMS,X,999),TERMIN=$P(X,"/",1)
	.	S XPARAMS=XPARAMS_"TERMINATOR="_TERMIN_":"
	I PARAMS["TYPEAHEAD" D
	.	I PARAMS["NOTYPE" S XPARAMS=XPARAMS_"NOTYPEAHEAD:"
	.	E  S XPARAMS=XPARAMS_"TYPEAHEAD:"
	I PARAMS["ECHO" D
	.	I PARAMS["NOECHO" S XPARAMS=XPARAMS_"NOECHO:"
	.	E  S XPARAMS=XPARAMS_"ECHO:"
	I PARAMS["ESCAPE" D
	.	I PARAMS["NOESCAPE" S XPARAMS=XPARAMS_"NOESCAPE:FIL=""NOESCAPE"":" Q
	.	S XPARAMS=XPARAMS_"ESCAPE:FIL=""ESCAPE"":"
	I PARAMS["PAST" D
	.	I PARAMS["NOPAST" S XPARAMS=XPARAMS_"NOPAST:"
	.	E  S XPARAMS=XPARAMS_"PAST:"
	S XPARAMS=XPARAMS_$S(PARAMS'["WRAP":"NOWRAP:",PARAMS["NOWRAP":"NOWRAP:",1:"WRAP:")
	I PARAMS["CHAR" D
	.	I PARAMS["NOCHAR" S XPARAMS=XPARAMS_"FIL=""NOCHARACTERS"":" 
	.	E  S XPARAMS=XPARAMS_"FIL=""CHARACTERS"":"
	;
TERM1	I $E(XPARAMS,$L(XPARAMS))=":" S XPARAMS=$E(XPARAMS,1,$L(XPARAMS)-1)
	I $L(XPARAMS) S USE=""""_DEVICE_""":("_XPARAMS_")"
	E  S USE=""""_DEVICE_""""
	U @USE
	Q
	;
	;----------------------------------------------------------------------
FILE(FILENAME,PARAMS)	;Public;Use file
	;----------------------------------------------------------------------
	;
	; Issues USE command with parameters to file that has been
	; previously opened.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. FILENAME	file name		
	;
	;	. PARAMS	Null			
	;			Not currently used for files.  Ignored if passed.
	;
	; RELATED:
	;	. $$FILE^%ZOPEN - OPEN command handling
	;
	; EXAMPLE:
	;	D FILE^%ZUSE(FILENAME,PARAMS) => U FILENAME
	;
	U FILENAME
	Q
	;
	;----------------------------------------------------------------------
TAPE(DEVICE,PARAMS)	;Public;Use tape drive
	;----------------------------------------------------------------------
	;
	; Issues USE command with parameters to tape drive that has been
	; previously opened.
	;
	; Note:  Separate calls for each action may be needed to ensure
	; the proper order of execution of instructions passed in parameters.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	Terminal/printer	/TYP=T
	;
	;	. PARAMS	USE parameters		/TYP=CMDLN/DEF=""
	;			Command line parameter
	;			list.  Options are:
	;			  SPACE=nnn  - forward or backspace # blocks
	;			  WRITELBVOL - write volume header label
	;			  WRITELBHDR - write HDR1, HDR2, TM
	;			  WRITELBEOF - write TM, EOF1, EOF2, TM, TM
	;			  WRITETM    - write tape mark
	;			  WRITEOF    - write end-of-file (TM,TM)
	;			  REWIND     - rewind tape
	;
	; RELATED:
	;	. $$TAPE^%ZOPEN - OPEN command handling
	;
	; EXAMPLE:
	;	D $$TAPE^%ZUSE("TAPE0","REWIND")
	;	  => U "TAPE0":(REWIND) to use device and rewind
	;
	N SPACE,X
	;
	S PARAMS=$$UPPER^%ZFUNC(PARAMS)
	S SPACE=+$P(PARAMS,"SPACE=",2)
	I SPACE U DEVICE:SPACE=SPACE
	;
	I PARAMS["WRITELBVOL" U DEVICE:WRITELB="VOL1"
	I PARAMS["WRITELBHDR" U DEVICE:WRITELB="HDR1",DEVICE:WRITELB="HDR2",DEVICE:WRITETM
	I PARAMS["WRITELBEOF" U DEVICE:WRITETM,DEVICE:WRITELB="EOF1",DEVICE:WRITELB="EOF2",DEVICE:WRITEOF
	I PARAMS["WRITEOF" U DEVICE:WRITEOF
	I PARAMS["WRITETM" U DEVICE:WRITETM
	I PARAMS["REWIND" U DEVICE:REWIND
	Q
	;
	;----------------------------------------------------------------------
EOFHDR(DEVICE)	;Public;Write EOF records, TM, new HDR records
	;----------------------------------------------------------------------
	;
	; Write EOF records, tape mark, and new HDR records to tape.  Used
	; for multiple files on a single tape (see SCAFICHE, for example)
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	Tape drive		/TYP=T
	;
	; EXAMPLE:
	;	D EOFHDR^%ZUSE("TAPE0")
	;
	U DEVICE:WRITETM,DEVICE:WRITELB="EOF1",DEVICE:WRITELB="EOF2"
	U DEVICE:WRITETM
	U DEVICE:WRITELB="HDR1",DEVICE:WRITELB="HDR2"
	U DEVICE:WRITETM
	Q
	;
	;----------------------------------------------------------------------
EOT(DEVICE)	;Public;Check for end-of-tape when writing to tape	
	;----------------------------------------------------------------------
	;
	; Checks for end-of-tape when writing to tape.  Code is MUMPS
	; implementation specific.  For GT.M checks value of $ZA.
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. DEVICE	Tape drive		/TYP=T
	;
	; RETURNS:
	;	. $$		EOT indicator		/TYP=L
	;			1 => at EOT
	;			0 => not at EOT
	;
	; EXAMPLE:
	;	I $$EOT^%ZUSE D CLOSE
	;
	U DEVICE I $ZA=1 Q 1
	Q 0
	;
	;----------------------------------------------------------------------
%EOT()	;System;Return compilable EOT check code
	;----------------------------------------------------------------------
	;
	; Return code that can be compiled into routines to check for
	; end-of-tape in a GT.M environment
	;
	; KEYWORDS:	Device handling
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$%EOT^%ZUSE => returns "$ZA=1" to allow
	;	                    compile I $ZA=1 D CLOSE
	;
	Q "$ZA=1"
