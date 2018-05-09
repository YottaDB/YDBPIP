%ZFUNC	;Library;GT.M extrinisic function non-MUMPS ($ZC) function calls 
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/04/00 11:28:01 - LYH
	; ORIG:  Dan S. Russell (2417) - 10/31/88
	;
	;
	; Various GT.M non-MUMPS functions as extrinsic functions.
	;
	; Generally calls to $ZC functions.  On other, non-GT.M implementations 
	; may call $ZF functions or may be coded in MUMPS.
	;
	; Call at appropriate line tag with parameter(s) for normal function 
	; call.
	;
	; To return appropriate code for use in compile routine, call at 
	; "%"_linetag.
	;
	; KEYWORDS:	System services
	;
	; LIBRARY:
	;
	;	. ALERT		- Invoke alerts external facility
	;
	;	. ASC2EBC	- EBCDIC translation of ASCII string
	;	. %ASC2EBC	- Return ASC2EBC compilable code
	;
	;	. COLIN		- Column attributes - translate in
	;	. COLOUT	- Column attributes - translate out
	;
	;	. CPUTM		- Cpu usage of the current process
	;	. %CPUTM 	- Return CPUTM compilable code
	;
	;	. DEVCLASS	- Device class 
	;	. %DEVCLASS 	- Return DEVCLASS compilable code
	;
	;	. DEVTYP	- Device type
	;
	;	. EBC2ASC	- ASCII translation of EBCDIC string
	;	. %EBC2ASC	- Return EBC2ASC compilable code
	;
	;	. ELFHASH	- Return hash value for string
	;	. %ELFHASH	- Return ELFHASH compilable code
	;
	;	. EIGHTBIT	- Does terminal support 8-bit ascii ?
	;	. %EIGHTBIT 	- Return EIGHTBIT compilable code
	;
	;	. ERRCNT	- Error count of a device
	;	. %ERRCNT	- Return ERRCNT compilable code
	;
	;	. ERRLOS	- Error level of severity
	;
	;	. EVNTLOG	- Post an event to external logging
	;			  facility
	;	. EXIT		- Exit M process w/ a status
	;
	;	. EXP		- Exponential of the input value
	;	. %EXP		- Return EXP compilable code
	;
	;	. FILE		- File attributes
	;
	;	. FREEBLK	- Number of freeblocks on a device
	;	. %FREEBLK	- Return FREEBLK compilable code
	;
	;	. FULLIO	- Full file specification 
	;
	;	. GETPID	- Get the process id of calling process
	;
	;	. GETTIM	- Current system time in a 64-bit format
	;	. %GETTIM	- Returns GETTIM compilable code
	;
	;	. GROUP		- Group id of the current process
	;	. %GROUP	- Return GROUP compilable code
	;
	;	. HEALTHCK	- Run MRPC073 for testing purpose
	;
	;	. HELP		- Access HELP files
	;
	;	. IMAGE		- Image name of current process
	;	. %IMAGE	- Return IMAGE compilable code
	;
	;	. IMAGENM	- Imagename of given image
	;	. %IMAGENM	- Return IMAGENM compilable code
	;
	;	. INTRACT	- Indicator if interactive job query
	;	. %INTRACT	- Return INTRACT compilable code
	;
	;	. INTRPT	- Interrupt M Process
	;
	;	. IODEVICE	- NOP to support generic code
	;
	;	. JBPRCNT	- Subprocess count for a process id
	;	. %JBPRCNT	- Return JBPRCNT compilable code
	;
	;	. JOBBED	- Indicator if job was started via job command	
	;	. %JOBBED	- Return JOBBED compilable code
	;
	;	. JOBID		- NOP to support generic code
	;
	;	. JOBNAM	- Job queue information for named job
	;
	;	. JOBTYPE	- Job type of the current process
	;	. %JOBTYPE	- Return JOBTYPE compilable code
	;
	;	. LISTPIDS	- List of the pids associated with mumps processes
	;
	;	. LNX		- Natural log values
	;	. %LNX		- Return LNX compilable code
	;
	;	. LOG		- Common log values (base 10)
	;	. %LOG		- Return LOG compilable code
	;
	;	. LOGINTM	- Login time of the current process
	;	. %LOGINTM 	- Return LOGINTM compilable code
	;
	;	. LOWER		- Convert string to lower case
	;	. %LOWER	- Return LOWER compilable code
	;
	;	. MASTERPD	- Process id of parent of current process
	;	. %MASTERPD	- Return MASTERPD compilable code
	;
	;	. MAXBLK	- Maximum number of blocks on a device
	;	. %MAXBLK	- Return MAXBLK compilable code
	;
	;	. MEMBER	- Group name of the current process
	;	. %MEMBER	- Return MEMBER compilable code
	;
	;	. MESSAGE	- Error mesasage text in error messaage
	;
	;	. MTMID		- Get ID of the MTM Process
	;
	;	. NPID		- In UNIX, $J
	;	. %NPID		- Return NPID compilable code
	;
	;	. PARSE		- Parse file specification
	;
	;	. PID		- Process id of current process
	;	. %PID		- Return PID compilable code
	;
	;	. PRCNAM	- Process name of current process
	;	. %PRCNAM	- Return PRCNAM compilable code
	;
	;	. PRIV		- Indicator if process has specified privilege
	;
	;	. PS		- Check process status
	;
	;	. READPRT	- Physical terminal address
	;	. %READPRT	- Return READPRT compilable code
	;
	;	. RLCHR		- Remove leading characters from a string
	;	. %RLCHR	- Return RLCHR compilable code
	;
	;	. RTB		- Remove trailing blanks from a string
	;	. %RTB		- Return RTB compilable code
	;
	;	. RTBAR		- Remove trailing upbars (|) from a string
	;	. %RTBAR	- Return RTBAR compilable code
	;
	;	. RTCHR		- Remove trailing characters from a string
	;	. %RTCHR	- Return RTCHR compilable code
	;
	;	. RTNLST	- Return list of customized routines
	;
	;	. SEARCH	- Full file sepcification of a located
	;
	;	. SPAWN		- Attempt to Spawn a subprocess
	;	. %SPAWN	- Return SPAWN compilable code
	;
	;	. SRCEXT	- Return MUMPS source extension
	;
	;	. STDPRNT	- Return system default print
	;
	;	. SYS		- System level call out to DCL
	;	. %SYS		- Return SYS compilable code
	;
	;	. TERMINAL	- Terminal of the current process
	;	. %TERMINAL	- Return TERMINAL compilable code
	;
	;	. TLO		- NOP to support generic code
	;
	;	. TRNLNM	- Translation of logical name
	;	. %TRNLNM	- Return TRNLNM compilable code
	;
	;	. UNPACK	- UNPACKED value
	;	. %UNPACK	- Return UNPACK compilable code
	;
	;	. UNPACK2	- Complex UNPACKED value
	;	. %UNPACK2	- Return UNPACK2 compilable code
	;
	;	. UPPER		- Convert string to upper case
	;	. %UPPER	- Return UPPER compilable code
	;
	;	. USERNAM	- Username of the current process
	;	. %USERNAM	- Return USERNAM compilable code
	;
	;	. VALIDPID	- Does PID identify a valid process.
	;
	;	. WAIT		- Execute a MUMPS hang
	;
	;	. XOR		- Exclusive OR's of input string
	;	. %XOR		- Return XOR compilable code
	;
	;	. ZKILL		- Kill at this level, but not descendants
	;	. %ZKILL	- Return ZKILL compilable code
	;
	;
	;---- Revision History ------------------------------------------------
	;
	; 05/22/05 - Erik Scheetz - 16067
	;	     Added INTRPT section to issue an M interrupt by calling
	;	     an executable routine (mintrpt) which issues a SIGUSR1
	;	     signal to the specified process ID.
	;	
	; 12/15/04 - RussellDS - CR14106
	;	     Modified JOBNAM section to accept a VERSION parameter to
	;	     indicate that call is from DBI version.  This allows it to
	;	     work correctly in DBI environments and remain backward
	;	     compatible.
	;
	; 11/20/03 - GIRIDHARANB - CR 6116
	;	     Modified section readprt to check for a env variable
	;	     SCA_IP_READPORT before calling readport.c to obtain the 
	;            physical address of a machine.This fix resolves a session 
	;            hang during problems with  the network
	;
	; 07/14/03 - Harsha Lakshmikantha - ARQ 51607
	;	     Added new functions RTCHR, %RTCHR, RLCHR, and %RLCHR.
	;	     RTCHR removes trailing characters from a string. RLCHR
	;	     removes leading characters from a string. %RTCHR and %RLCHR
	;	     return the compiliable code for RTCHR and RLCHR respectively.
	;
	; 09/12/02 - JERUCHIMC - 49202 - CR 979
	; 	     Modified HEALTHCHECK section.  Changed call to fsn^dbsdd to
	;	     uppercase fsn^DBSDD.
	;
	; 05/01/01 - Harsha Lakshmikantha - 43567 & 43650
	;	     Modified FILE section to call format date function
	;	     (FDAT^%ZM) with a date mask. The date returned by the
	;	     UNIX system is in DD/MM/YY format irrespective of the
	;	     timezone or country.
	;
	; 01/02/01 - JOYCEJ - 42522
	;	     Added function RTNLST for Customization Tracking.
	;
	; 08/18/00 - Harsha Lakshmikantha - 41575
	;	     Modified COLIN and COLOUT to quit with null if a null
	;	     argument is passed.
	;
	; 04/04/00 - Harsha Lakshmikantha & Hien Ly - ARQ 36125
	;	     This is an official release of a number of patches
	;	     we've added to _ZFUNC.m on the UNIX platform.
	;
	;	     Replaced FOR loops used in allocating memory with $J in
	;	     several fuctions.
	;
	;	     Added new functions ASC2EBC and %ASC2EBC. ASC2EBC returns 
	;	     the EBCDIC translation of the ASCII input string. 
	;	     %ASC2EBC returns the ASC2EBC compilable code.
	;		
	;	     Modified ERRLOS section to use the alerts package for the
	;	     external call geterrlos if it is defined else use the
	;	     extcall package.
	;
	;	     Added HEALTHCK section for Healthcheck project. It
	;	     will run MRPC073 for testing purpose.
	;
	; 06/25/99 - Harsha Lakshmikantha
	;	     Modified WAIT section to support GT.M versions 3 and 4.
	;
	; 05/12/99 - Harsha Lakshmikantha
        ;            Modified ELFHASH, UNPACK, and XOR sections to new the 
	;	     variable "I".
        ;
	; 04/23/99 - Harsha Lakshmikantha
        ;            Modified sections ELFHASH, UNPACK, and XOR to allocate
        ;            memory before invoking an external call. Prior to this
        ;            change the input was assinged to the output variable to
        ;            allocate memory.
        ;
	; 03/25/99 - Hien Ly & Harsha Lakshmikantha
	;            Reworked MASTERPD section external call to return the
	;            correct process parent id. The returning result code is
	;            changed: 0 means successful, non-zero means error.
	;
        ; 02/24/99 - Harsha Lakshmikantha
        ;            Modified WAIT section to quit before invoking the external
        ;            call if the specified wait time is zero.
        ;
        ; 01/13/99 - Harsha Lakshmikantha
        ;            Modified WAIT section to call the new implementation of
        ;            external sleep using GT.M timers.
        ;
	; 10/30/98 - Phil Chenard - 28227
	;            Added new function, ERRLOS, to return an error's
	;            arbitrarily assigned level of severity.  This function
	;            is also the primary API for centralized error loggging
	;            and alerts automation.  Also added ALERTS and EVNTLOG to 
	;            directly initiate an alert or event log.
	;	
	; 05/26/98 - Harsha Lakshmikantha
	;	     Added new functions ELFHASH and %ELFHASH to return 
	;	     hash value of a string.
	;	
	; 03/03/98 - Doug Dantzer
	;	     Modified RTBAR and RTB to not use the external call
	;	     for removing of trailing delimiters.  Problems have
	;	     been found in using this which causes data corruption
	;
	; 10/06/97 - Phil Chenard
	;            Added function $$EXIT to provide the capability of
	;            exiting the M process and return a specific status 
	;            to the managing shell that called M.  This utilizes
	;            the ZMESSAGE facility within GT.M.
	;
	; 09/17/97 - Phil Chenard
	;            Modified INTRACT function to utilize a reference to
	;            $ZIO instead of $ZMODE to determine whether a process
	;            is interactive or running in background.  Also
	;            replaced the patch in RTB and RTBAR.
	; 
	;----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
ALERT(er,ercat,param,prio)	;Public; Invoke alerts system call
	;----------------------------------------------------------------------
	;
	N %PRIO
	S param=$G(param)
	S %PRIO=$$ERRLOS(er,ercat,param,1)
	Q
	;
	;----------------------------------------------------------------------
ASC2EBC(INPUT)	;Public;EBCDIC translation of ASCII string
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. INPUT		ASCII string		
	;
	; RETURNS:
	;	. EBCDIC translation	
	;
	; RELATED:
	;	. $$%ASC2EBC^%ZFUNC - Compilable code for ASC2EBC
	;
	; EXAMPLE:
	;	S X=$$ASC2EBC^%ZFUNC(string) => X=ebcdic_string
	;
	N ERRNO,OUTPUT
	S ERRNO=1
	S OUTPUT=$J("",$L(INPUT))
	D &extcall.asc2ebc(.INPUT,.OUTPUT,.ERRNO)
	I ERRNO=0 S OUTPUT=ERRNO
	Q OUTPUT 
	;
	;----------------------------------------------------------------------
%ASC2EBC(VARIABLE)	;System;Return ASCII to EBCDIC compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of ASCII string
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$ASC2EBC^%ZFUNC - Direct call for ASC2EBC
	;
	; EXAMPLE:
	;	S X=$$%ASC2EBC^%ZFUNC("STRING") => X="$$ASC2EBC^%ZFUNC("_VARIABLE_")"
	;
	Q "$$ASC2EBC^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
COLIN(atb)	;Public; Translate LV column attributes into column bitmap
	;----------------------------------------------------------------------
	; This function will translate the length-value equivalent in the
	; SQL reply to a column bit map, where every column in the row will
	; be expressed if protection was turned on.  Every column that has a 
	; protection attribute contains a two byte binary value for the column
	; number.  The decimal column number is computed by using a $ASCII on
	; the first byte and multiplying that by 256, then adding the $ASCII
	; equivalent of the second byte.  Multiple rows will be delimited
	; with a carriage return, line feed, $C(13,10).
	;
	; ARGUMENTS:
	;	. atb	- SQL attributes field in length-value
	;		  format.			/TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	- Column attributes bit map for each
	;		  row, delimited by $C(13,10)	/TYP=T
	;
	; EXAMPLES:
	;	S sqlind=$$COLIN($C(8,7,0,4,2,0,8,2)) =>"00020002"
	;
	;	S sqlind=$$COLIN($C(18,7,0,6,3,0,9,3,10,0,3,3,0,7,3,0,11,3))
	;	  => "000003003"_$C(13,10)_"00300030003"
	;
	N out
	I atb="" Q ""
	S out=""
	D &extcall.colin(atb,.out)
	Q out
	;
	;----------------------------------------------------------------------
COLOUT(atb)  ;Public; Parse column attributes field(s) & return in LV format
	;----------------------------------------------------------------------
	; SQL returns a bit map value for column attributes, relating to data
	; item protection.  Every column will be represented for each row that
	; that is returned in the SQL request.  This function will translate
	; the bit map into the appropriate LV reply, based on the specification
	; in the PROFILE Enterprise Server document.  
	;
	; If there are no columns protected for a row, the reply will be null.
	;
	; ARGUMENTS:
	;	. atb 	 - Column attributes bit map, returned from
	;                  the application.		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	 - Length-value reply of those columns, 
	; 		   in each row, w/ protection turned on.
	;						/TYP=T
	; EXAMPLES:
	;	S fld(5)=$$colout("000200020") => $C(8,7,0,4,2,0,8,2)
	;	S fld(5)=$$colout("000003003"_$C(13,10)_"00300030003") =>
	;		$C(18,7,0,6,3,0,9,3,10,0,3,3,0,7,3,0,11,3)
	;----------------------------------------------------------------------
	;
	N out 
	I atb="" Q ""
	S out=""
	D &extcall.colout(atb,.out)
	Q out
	;
	;----------------------------------------------------------------------
CPUTM(PID)	;Public;CPUTM of the current process
	;----------------------------------------------------------------------
	;
	; Provide CPUTM of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. CPUTM for current	process
	;
	; RELATED:
	;	. $$%CPUTM^%ZFUNC - Compiled code for CPUTM
	;
	; EXAMPLE:
	;	S X=$$CPUTM^%ZFUNC(12345) => X="0:00"
	;
	Q $ZGETJPI(PID,"CPUTIM")
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getcputime(.PID,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%CPUTM(VARIABLE)	;System;Return compilable code cpu usage for pid
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$CPUTM^%ZFUNC - Direct call for CPUTM
	;
	; EXAMPLE:
	;	S X=$$%CPUTM^%ZFUNC(12345) => X="$$CPUTM^%ZFUNC(12345)"
	;
	Q "$$CPUTM^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
DEVCLASS(DEVICE)	;Public;Class of device 
	;----------------------------------------------------------------------
	;
	; Class of device 
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. DEVICE	Device name		
	;
	; RETURNS:
	;	. TRM, MT, or FILE
	;
	; RELATED:
	;	. $$%DEVCLASS^%ZFUNC - Compilable code for DEVCLASS
	;
	; EXAMPLE:
	;	S X=$$DEVCLASS^%ZFUNC("/dev/ptty4") => X="TRM"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getdevclass(DEVICE,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%DEVCLASS(VARIABLE)	;System;Return get compilable code for class of device
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of device	
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$DEVCLASS^%ZFUNC - Direct call for DEVCLASS
	;
	; EXAMPLE:
	;	S X=$$%DEVCLASS^%ZFUNC("DEVICE") => X= "$$DEVCLASS^%ZFUNC("DEVICE")"
	;
	Q "$$DEVCLASS^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
DEVTYP(DEVICE)	;Public; Returns the device type
	;----------------------------------------------------------------------
	; This function returns the string identifying the IO type, as used
	; by the SCA device handler.
	;
	; ARGUMENTS:
	;	. DEVICE        - Device name           /TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$ DEVTYP     - Device type           /TYP=T
	;                         "TRM" - terminal
	;                         "FILE"- RMS file
	;                         "MT"  - magnetic tape
	;                         "PTR" - printer
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getdevclass(DEVICE,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
DIFF(DIR1,DIR2,SRCFILE)	;Public; Report differences between two routines
	;----------------------------------------------------------------------
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",128)
	I SRCFILE'[".m" S SRCFILE=SRCFILE_".m"
	D &extcall.diff(DIR1,DIR2,SRCFILE,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
EBC2ASC(INPUT)	;Public;ASCII translation of EBCDIC string
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. INPUT		EBCDIC string		
	;
	; RETURNS:
	;	. ASCII translation	
	;
	; RELATED:
	;	. $$%EBC2ASC^%ZFUNC - Compilable code for EBC2ASC
	;
	; EXAMPLE:
	;	S X=$$EBC2ASC^%ZFUNC(string) => X=ascii_string
	;
	N ERRNO,OUTPUT
	S ERRNO=1
	S OUTPUT=$J("",$L(INPUT))
	D &extcall.ebc2asc(.INPUT,.OUTPUT,.ERRNO)
	I ERRNO=0 S OUTPUT=ERRNO
	Q OUTPUT 
	;
	;----------------------------------------------------------------------
%EBC2ASC(VARIABLE)	;System;Return EBCDIC to ASCII compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of EBCDIC string
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$EBC2ASC^%ZFUNC - Direct call for EBC2ASC
	;
	; EXAMPLE:
	;	S X=$$%EBC2ASC^%ZFUNC("STRING") => X="$$EBC2ASC^%ZFUNC("_VARIABLE_")"
	;
	Q "$$EBC2ASC^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
EIGHTBIT()	;Public;Does terminal support 8-bit character set ?
	;----------------------------------------------------------------------
	;
	; Does terminal support 8-bit character set ?
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. TRUE(1) or FALSE(0)
	;
	; RELATED:
	;	. $$%EIGHTBIT^%ZFUNC - Compilable code for EIGHTBIT 
	;
	; EXAMPLE:
	;	S X=$$EIGHTBIT^%ZFUNC() => X=TRUE(1) or FALSE(0)
	;
	N RC
	S RC=1
	D &extcall.getcharset(.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%EIGHTBIT()	;System;Does terminal support 8-bit character set ?
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$EIGHTBIT^%ZFUNC - Direct call 
	;
	; EXAMPLE:
	;	S X=$$%EIGHTBIT^%ZFUNC => X= "$$EIGHTBIT^%ZFUNC"
	;
	Q "$$EIGHTBIT^%ZFUNC"
	;
        ;----------------------------------------------------------------------
ELFHASH(INPUT)  ;Public;Algorithm to generate a HASH value
        ;----------------------------------------------------------------------
        ;
        ; External Call from M to return hash value for string
        ; S HASH=$&ELFHASH(string)
        ;
        ; KEYWORDS:     System services
        ;
        ; ARGUMENTS:
        ;       . INPUT         String          /TYP=T/REQ/MECH=VAL
        ;
        ; RETURNS:
        ;       . $$            Hash value      /TYP=T
        ;
        ; RELATED:
	;	. $$%ELFHASH^%ZFUNC - Compilable code for ELFHASH 
        ;
        ; EXAMPLE:
        ;       S X=$$ELFHASH^%ZFUNC("STRING")
        ;
	N ERRNO,CDATA,I
        S ERRNO=1
	S CDATA=$J("",80)
        D &extcall.elfhash(INPUT,.CDATA,.ERRNO)
        ;
        Q CDATA
        ;
        ;----------------------------------------------------------------------
%ELFHASH(INPUT)  ;Public;Algorithm to generate a HASH value
        ;----------------------------------------------------------------------
        ;
        ; External Call from M to return hash value for string
        ; S HASH=$&ELFHASH(string)
        ;
        ; KEYWORDS:     System services
        ;
        ; ARGUMENTS:
        ;       . INPUT         String          /TYP=T/REQ/MECH=VAL
        ;
        ; RETURNS:
        ;       . $$            Hash value      /TYP=T
        ;
        ; RELATED:
	;	. $$ELFHASH^%ZFUNC - Direct call 
        ;
        ; EXAMPLE:
        ;       S X=$$%ELFHASH^%ZFUNC("STRING")
        ;
	Q "$$ELFHASH^%ZFUNC("_INPUT_")"
        ;
	;----------------------------------------------------------------------
ERRCNT(INPUT)	;Public;Error count of a device
	;----------------------------------------------------------------------
	;
	; Device error count.  
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. INPUT		Device name		
	;
	; RETURNS:
	;	. Not supported by UNIX
	;
	; RELATED:
	;	. $$%ERRCNT^%ZFUNC - Compilable code for error count
	;
	; EXAMPLE:
	;	S X=$$ERRCNT^%ZFUNC("?") => X=5
	;
	Q 0
	;
	;----------------------------------------------------------------------
%ERRCNT(VARIABLE)	;System;Return device error count compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of device	
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$ERRCNT^%ZFUNC - Direct call for error count
	;
	; EXAMPLE:
	;	S X=$$%ERRCNT^%ZFUNC("DEVICE") => X="$$ERRCNT^%ZFUNC("DEVICE")"
	;
	Q "$$ERRCNT^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
ERRLOS(er,ercat,param,nolog,noalrt,desc)	; Public; Return level of severity of an error
	;----------------------------------------------------------------------
	; This function can be called by error handlers or applications to 
	; determine an error condition's level of severity, based on customer
	; definition.  This is the primary function to support both error 
	; logging as well as alerts automation.  Separate functions will exist
	; to support each of these functions on an individual basis.
	; 
	; It passes the identity of the error condition or code to the 
	; external routine, which then checks its priority from an external
	; file and execute a call to a logging and/or alerts automation 
	; system, if one exists.
	;
	; ARGUMENTS:
	; 	. er	- The error code in question, generated by the
	;                 application.			/TYP=T/REQ/MECH=VAL
	;
	;	. ercat	- Error classification		/TYP=T/REQ/MECH=VAL
	;		STBLER	- Errors catalogued in [STBLER]
	;		STBLMSG - Error messages from [STBLMSG]
	;		QUEUE   - Errors occurring in Queuing System
	;		MINTEG  - MUPIP Integrity errors
	;		MERROR  - GT.M M errors
	;
	;	. param	- Parameter list		/TYP=T/NOREQ/MECH=VAL
	;
	;	. nolog	- Log override, determines whether the API will handle
	;                 the error normally or, if this flag is set, to not
	;                 log this error.
	;		  				/TYP=N/NOREQ
	;
	;	. noalrt - Alert override, determines whether the API will 
	;                  call out to alerts system, if one exists, or based
	;                  on this override not createan alert, regardless.
	;						/TYP=N/NOREQ/DEF=0
	;
	;	. desc	- Error description, returned by reference by the
	;                 API to allow for external level override of a 
	;                 error event explanation	/TYP=t/NOREQ/MECH=REF:RW
	;
	;
	; RETURNS:
	;	. $$	- Level of severity value, returned to the caller.
	;						/TYP=N/REQ
	;
	; EXAMPLE:	S los=$$ERRLOS^%ZFUNC("UNDEFINED","MERROR",1)
	;		S los=$$ERLOS^%ZFUNC("INVLDUID","STBLER")
	;
	;----------------------------------------------------------------------
	;***  Until external call is widely distributed to all Unix
	; platforms, simply quit w/o invoking the external call
	;Q 0
	N i,rc,X
	S er=$P($G(er),".",$L(er,"."))		;Parse complex error string
	I er="" Q 0
	;
	; Default error category to STBLER
	S ercat=$$UPPER($G(ercat)) 
        I ercat="" S ercat="STBLER"
	;
 	S nolog=+$G(nolog)
	S noalrt=+$G(noalrt)
	S param=$G(param) I param'="" S param=$$QADD^%ZS(param)
	S desc=$G(desc) I desc="" S $P(desc," ",300)=""
	;
	; Strip off MSG or ER identifier if built into error code
	I ercat="STBLMSG",$E(er,1,4)="MSG_" S er=$P(er,"_",2)
	I ercat="STBLER",$E(er,1,3)="ER_" S er=$P(er,"_",2)
	;
	S rc=-1				;Initialize return code
	S X=$ZTRNLNM("GTMXC_alerts")
	I X'="" D &alerts.geterrlos(er,ercat,param,nolog,noalrt,.desc,.rc)
	E  D &extcall.geterrlos(er,ercat,param,nolog,noalrt,.desc,.rc)
	Q rc
	;
	;----------------------------------------------------------------------
EVNTLOG(er,ercat,param,desc)	; Public; Return level of severity of an error
	;----------------------------------------------------------------------
	; This function can be called by error handlers or applications to 
	; log an event by calling the external logging facility, if one
	; exists.
	; 
	; ARGUMENTS:
	; 	. er	- The error code in question, generated by the
	;                 application.			/TYP=T/REQ/MECH=VAL
	;
	;	. ercat	- Error classification		/TYP=T/REQ/MECH=VAL
	;		STBLER	- Errors catalogued in [STBLER]
	;		STBLMSG - Error messages from [STBLMSG]
	;		QUEUE   - Errors occurring in Queuing System
	;		MINTEG  - MUPIP Integrity errors
	;		MERROR  - GT.M M errors
	;
	;	. param	- Parameter list; string of variables to be inserted
	;                 with static information about the event.
	;						/TYP=T/NOREQ/MECH=VAL
	;
	;	. desc	- Error description, returned by reference by the
	;                 API to allow for external level override of a 
	;                 error event explanation	/TYP=t/NOREQ/MECH=REF:RW
	;
	;
	;
	; EXAMPLE:	D EVNTLOG^%ZFUNC("UNDEFINED","MERROR","",1)
	;		D EVNTLOG^%ZFUNC("INVLDUID","STBLER")
	;		D EVNTLOG^%ZFUNC(102,"STBLMSG","1012345,150.00")
	;
	;----------------------------------------------------------------------
	N %PRIO
	S er=$G(er) Q:er=""
	S ercat=$G(ercat) I ercat="" S ercat="STBLER"
	S param=$G(param)
	S desc=$G(desc)
	;
	S %PRIO=$$ERRLOS(er,ercat,param,0,0,.desc)
	Q
	;
	;----------------------------------------------------------------------
EXIT(STATUS)    ;Public; Exit current MUMPS image w/ status
	;----------------------------------------------------------------------
	I '+$G(STATUS) S STATUS=0
	S $ZT=""
	ZMESSAGE STATUS
	Q ""
	;
	;----------------------------------------------------------------------
EXP(INPUT)	;Public;Exponential of the input value
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;	
	; ARGUMENTS:
	;	. INPUT		Number to exponentiate	
	;
	; RETURNS:
	;	. Exponential of INPUT	
	;
	; RELATED:
	;	. $$%EXP^%ZFUNC - Compilable code for EXP
	;	. $$LNX^%ZFUNC  - Natural log
	;	. $$LOG^%ZFUNC  - Common log
	;
	; EXAMPLE:
	;	S X=$$EXP^%ZFUNC(2) => X=7.38905609893065
	;
	N RETDATA,I
	S RETDATA=$J("",256)
	S INPUT=+INPUT
	D &extcall.expsca(INPUT,$LENGTH(INPUT),.RETDATA)
	S RETDATA=+RETDATA
	Q RETDATA
	;
	;----------------------------------------------------------------------
%EXP(VARIABLE)	;System;Return exponentiation compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of number to exponentiate
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$EXP^%ZFUNC - Direct call for EXP
	;
	; EXAMPLE:
	;	S X=$$%EXP^%ZFUNC("NUM") => X="$$EXP^%ZFUNC("NUM")"
	;
	Q "$$EXP^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
FILE(RMS,ITEM)	;Public;file attribute information about an RMS file
	;----------------------------------------------------------------------
	;
	; Returns requested file attribute information about a specified
	; RMS file.  Equivalent to the DCL lexical F$FILE_ATTRIBUTES.
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. RMS		File name		/TYP=T
	;
	;	. ITEM		Desired information	/TYP=T
	;
	; RETURNS:
	;	. $$		Requested information	/TYP=T
	;
	; RELATED:
	;	. $$%FILE^%ZFUNC - Compilable code for file attributes
	;
	;
	; EXAMPLE:
	;	S X=$$FILE^%ZFUNC(file,"BLS") => X=block size for file
	;
        N DATE,TIME,I,RC,RESULT
        S RC=1
	S RESULT=$J("",24)
        D &extcall.getfileinfo(RMS,ITEM,.RESULT,.RC);
        I ITEM="CDT" D  Q RESULT
        .       S DATE=$P(RESULT," ",1)
        .       S TIME=$P(RESULT," ",2)
        .       S DATE=$$FDAT^%ZM(DATE,"MM/DD/YY")
        .       S TIME=$P(TIME,":",1,2)
        .       S TIME=$$FTIM^%ZM(TIME)
        .       S RESULT=DATE_","_TIME
        E  Q RC
	;
	;----------------------------------------------------------------------
FREEBLK(DEVICE)	;Public;Number of free blocks on a device
	;----------------------------------------------------------------------
	;
	; Number of free blocks on a device.  
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. DEVICE	Device name		
	;
	; RETURNS:
	;	. Number of free blocks	
	;
	; RELATED:
	;	. $$%FREEBLK^%ZFUNC - Compilable code for free blocks
	;
	; EXAMPLE:
	;	S X=$$FREEBLK^%ZFUNC("/uxdev") => X=646324
	;
	N RC
	S RC=1
	D &extcall.getfreeblk(DEVICE,.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%FREEBLK(VARIABLE)	;System;Return get free blocks compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of device	
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$FREEBLK^%ZFUNC - Direct call for free blocks
	;
	; EXAMPLE:
	;	S X=$$%FREEBLK^%ZFUNC("DEVICE") => X= "$$FREEBLK^%ZFUNC("DEVICE")"
	;
	Q "$$FREEBLK^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
FULLIO(io)	;Public; Return io w/ physical directory, if not already present
	;----------------------------------------------------------------------
	; Determine whether the passed file variable is complete with a physical
	; directory name included, and if not, default the value of the spool
	; directory.
	;
	; ARGUMENTS:
	;	. io	- File name.		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. io	- Full file name, including physical directory 
	;		  location.		/TYP=T
	;
	;
	;----------------------------------------------------------------------
	I io["/" Q io
	N spldir
	S spldir=$$^CUVAR("SPLDIR")
	I spldir'="" D  Q spldir_io
	.	I $E(spldir,$L(spldir))'="/" S spldir=spldir_"/"
	I $$SCAU^%TRNLNM("SPOOL")'="" Q $$SCAU^%TRNLNM("SPOOL",io)
	Q $$HOME^%TRNLNM(io)
	;
	;----------------------------------------------------------------------
GETDVI(DEVICE,ITEM)	;Public;Device information
	;----------------------------------------------------------------------
	;
	; Provide requested device information.  Equivalent to DCL lexical
	; F$GETDVI(device,item).
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. DEVICE	Device name		/TYP=T
	;
	;	. ITEM		Desired information	/TYP=T
	;
	; RETURNS:
	;	. $$		Information requested	/TYP=T
	;
	; RELATED:
	;	. $$%GETDVI^%ZFUNC - Compilable code for device information
	;
	; EXAMPLE:
	;	S X=$$GETDVI^%ZFUNC("$1$DIA0:","DEVNAM") => X="_R1SLAB$DIA0:
	;
	;Q ""				;Not implemented on HPUX
	Q $$MAXBLK(DEVICE)
	;
	;Q $ZGETDVI(DEVICE,ITEM)
	;
	;----------------------------------------------------------------------
GETSYI(param)	;Public; Return system specific info
	;----------------------------------------------------------------------
	I $G(param)'="NODENAM" Q ""
	;
	Q $$NODENAM
	;
	;----------------------------------------------------------------------
GETPID()	;Public;Get the process id of calling process
	;----------------------------------------------------------------------
	;
	; Returns process id
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	. Process Id
	;
	; EXAMPLE:
	;	S PID=$$%GETPID^%ZFUNC()  
	;
	N PID
	S PID=0
	D &extcall.getprocessid(.PID)
	Q PID
	;
	;----------------------------------------------------------------------
GETTIM()	;Public
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	. Current system time	/TYP=N
	;
	; RELATED:
	;	. $$%GETTIM^%ZFUNC - Compiled code for current system time
	;
	; EXAMPLE:
	;	S X=$$GETTIM^%ZFUNC => X=427285898299
	;
	N TIME,I
	S TIME=$J("",24)
	D &extcall.gettime(.TIME)
	Q TIME
	;
	;
	;----------------------------------------------------------------------
%GETTIM()	;System;Returns current system time compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$GETTIM^%ZFUNC - Direct call for current system time
	;
	; EXAMPLE:
	;	S X=$$%GETTIM^%ZFUNC => X="$$GETTIM^%ZFUNC"
	;
	Q "$$GETTIM^%ZFUNC"
	;
	;----------------------------------------------------------------------
GROUP(PID)	;Public;GROUP of the current process
	;----------------------------------------------------------------------
	;
	; Provide GROUP of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. GROUP for current	process
	;
	; RELATED:
	;	. $$%GROUP^%ZFUNC - Compiled code for GROUP
	;
	; EXAMPLE:
	;	S X=$$GROUP^%ZFUNC(12345) => X="3"
	;
	N RC
	S RC=1
	D &extcall.getgroup(.PID,.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%GROUP(VARIABLE)	;System;Return compilable code to get grp id of process
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$GROUP^%ZFUNC - Direct call for GROUP
	;
	; EXAMPLE:
	;	S X=$$%GROUP^%ZFUNC(12345) => X="$$GROUP^%ZFUNC(12345)"
	;
	Q "$$GROUP^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
HEALTHCK()	;System;Run MRPC073 for testing purpose.
	;----------------------------------------------------------------------
	S VERSION=$$^CUVAR("%VN")
	I VERSION<6 D
	.	; VERSIONS LESS THAN V6.0
	.	s return="^TBLS~"
	.	F TABLE="ACN","CIF","CUVAR","DAYEND","HIST","TTX" D
	..		K fsn,key,param,sqldta,sqlsta,sqlstm,vdd
	..		S ER=0
	..		;
	..		D fsn^DBSDD(.fsn,TABLE,.vdd) I ER S return=return_TABLE_"#"_RM_"," Q
	..		;
	..		S param("ROWS")=1
	..		S key=$P($G(fsn(TABLE)),"|",3)
	..		D SELECT^SQL(key_" FROM "_TABLE,.param,.sqlsta,.sqldta)
	..		S return=return_TABLE_"#"_$S(ER=1:RM,1:"OK")_","
	.	S return=$$V2LV^MSG(return)
	E  D
	.	S RM=$$^MRPC073(.return,1)
	.	I RM'="" S return=$$ERRMSG^PBSUTL($G(RM),$G(ET))
	Q return
	;
	;----------------------------------------------------------------------
HELP(TOPIC,LIBRARY)	;Public;Access HELP files
	;----------------------------------------------------------------------
	;
	; Clears screen then accesses specified help library.
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. TOPIC		Name of topic		
	;
	;	. LIBRARY	Name of library		
	;
	; RETURNS:
	;	. Always returns 1	
	;
	; EXAMPLE:
	;	S X=$$HELP^%ZFUNC("","SCAU$HELP:CALC.HLB")
	;	  => Gets general help from CALC.HLB library
	;
	W $$CLEAR^%TRMVT			; Clear screen first
	U 0 ZHELP $G(TOPIC):$G(LIBRARY)
	Q 1 						; Always returns a 1
	;
	;----------------------------------------------------------------------
IMAGENM(PID)	;Public;Image name of the current process
	;----------------------------------------------------------------------
	;
	; Provide image name of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Image name for current	process
	;
	; RELATED:
	;	. $$%IMAGENM^%ZFUNC - Compiled code for IMAGENM
	;
	; EXAMPLE:
	;	S X=$$IMAGENM^%ZFUNC(12345) => X="/gtm_dist/mumps"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getimage(.PID,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%IMAGENM(VARIABLE)	;System;Return compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$IMAGENM^%ZFUNC - Direct call for IMAGENM
	;
	; EXAMPLE:
	;	S X=$$%IMAGENM^%ZFUNC(12345) => X="$$IMAGENM^%ZFUNC(12345)"
	;
	Q "$$IMAGENM^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
INTRACT()	;Public;Interactive indicator
	;----------------------------------------------------------------------
	;
	; Returns indicator to identify interactive jobs versus batch or
	; JOBbed jobs.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. $$		Interactive indicator	/TYP=L
	;			0 => not interactive
	;			1 => interactive
	;
	; RELATED:
	;	. $$%INTRACT^%ZFUNC - Compiled code for interactive indicator
	;
	; EXAMPLE:
	;	S X=$$INTRACT^%ZFUNC => X=1
	;
	I $ZIO=0 Q 0
	Q 1
	;
	;----------------------------------------------------------------------
%INTRACT()	;System;Return interactive status compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$INTRACT^%ZFUNC - Direct call for interactive indicator
	;
	; EXAMPLE:
	;	S X=$$%INTRACT^%ZFUNC => X="$ZMODE=""INTERACTIVE"""
	;
	Q "$$INTRACT^%ZFUNC"
	;
	;----------------------------------------------------------------------
INTRPT(PID)	;Public;Issue M Interrupt
	;----------------------------------------------------------------------
	;
	; Executes SIGUSR1 interrupt to M Process
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. $$		Failure indicator	/TYP=L
	;			0 => Success
	;			1 => Failure
	;
	; EXAMPLE:
	;	S X=$$INTRPT^%ZFUNC(15839) => X=0
	;
	I +$TR($P($ZVN,"GT.M V",2),"-","")<4.4002 Q 1
	ZSY "$SCA_RTNS/mintrpt "_PID
	Q 0
	;
	;----------------------------------------------------------------------
IODEL()	;Public; Return device delimiter for parsing IO and its qualifiers
	;----------------------------------------------------------------------
	; Based on the platform, return an acceptable delimiter used to
	; distinguish when the inputted IO device has ended and its qualifiers
	; has begun.
	;
	Q " "
	;
	;----------------------------------------------------------------------
IODEVICE(IO)	;Public; NOP for UNIX
	;----------------------------------------------------------------------
	;
	; NOP for UNIX
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	NOP for UNIX
	Q 0
	;
	;----------------------------------------------------------------------
JBPRCNT(PID)	;Public;Subprocess count for specified process ID
	;----------------------------------------------------------------------
	;
	; Provide subprocess count for a specific process.  
	; 
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. PID	Process ID for which	
	;			subprocess count is
	;			requested
	;
	; RETURNS:
	;	. Subprocess count	
	;
	; RELATED:
	;	. $$%JBPRCNT^%ZFUNC - Compiled code for subprocess count
	;	No meaning in UNIX
	;
	; EXAMPLE:
	;	S X=$$JBPRCNT^%ZFUNC(10545)  =>  X=2
	;
	Q 0
	;
	;----------------------------------------------------------------------
%JBPRCNT(VARIABLE)	;System;Return subprocess count compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of process ID
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$JBPRCNT^%ZFUNC - Direct call for subprocess count
	;
	; EXAMPLE:
	;	S X=$$%JBPRCNT^%ZFUNC("PID") => X="$$JBPRCNT^%ZFUNC(PID)"
	;
	Q "$$JBPRCNT^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
JOBBED()	;Public;Indicator if job was started via job command	
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. Jobbed indicator	
	;			0 => not jobbed
	;			1 => jobbed
	;
	; RELATED:
	;	. $$%JOBBED^%ZFUNC - Compiled code for jobbed indicator
	;
	; EXAMPLE:
	;	S X=$$JOBBED^%ZFUNC => X=0 (not jobbed)
	;
	I $ZIO=0 Q 1
	Q 0
	;
	;----------------------------------------------------------------------
%JOBBED()	;System;Return jobbed indicator compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$JOBBED^%ZFUNC - Direct call for jobbed indicator
	;
	; EXAMPLE:
	;	S X=$$%JOBBED^%ZFUNC => X="$ZMODE=""OTHER"""
	;
	Q "$$JOBBED^%ZFUNC" 
	;
	;----------------------------------------------------------------------
JOBID(PID)	;Public; NOP for UNIX
	;----------------------------------------------------------------------
	;
	; NOP for UNIX 
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	PID unchanged
	;
	Q PID
	;
	;----------------------------------------------------------------------
JOBNAM(JOBNAM,EVENT,BATCH,VERSION)   ;Public;Job queued status
	;----------------------------------------------------------------------
	;
	; Indicates whether a specified job exists or not on any batch queues.
	; Duplicates function GETQUIJO^%ZFUNC.
	;
	; Version > 1 indicates call from a DBI version.  This will call back
	; into Profile ^QUEPGM to return process ID and avoid reference to
	; globals.  NOTE that VERSION is required and must be 2 or greater for
	; DBI and newer versions.
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. JOBNAM	Job name		/TYP=T
	;
	;	. EVENT		Event Name		/TYP=T/NOREQ
	;
	;	. BATCH		Batch Number		/TYP=N/NOREQ
	;
	;	. VERSION	Version			/TYP=N/NOREQ/DFT=1
	;
	; RETURNS:
	;	. $$		Exists on queue status	/TYP=L
	;			0 => not on batch queue
	;			1 => on batch queue
	;
	; EXAMPLE:
	;	S X=$$JOBNAM^%ZFUNC("BATCH_001") => X=1
	;
	N PID,X
	;
	S EVENT=$G(EVENT),BATCH=$G(BATCH)
	I EVENT="" Q 0
	I 'BATCH Q 0
	;
	S PID=0
	;
	I $G(VERSION)>1 S PID=$$PID^QUEPGM(EVENT,BATCH)
	;
	E  D
	.	I '$D(^QUECTRL(EVENT,BATCH)) Q  	;Batch control table
	.	;
	.	S X=$O(^QUECTRL(EVENT,BATCH,"")) I X="" Q 0
	.	S PID=$P(^QUECTRL(EVENT,BATCH,X),"|",1)
	;
	I PID D &extcall.validpid(.PID)
	;
	I PID Q 1
	Q 0
	;
        ;----------------------------------------------------------------------
JOBSRV  ; Job SCA$IBS servers
        ;----------------------------------------------------------------------
	;
        D JOB^PBSUTL("SCA$IBS",1)
        Q
        ;
	;----------------------------------------------------------------------
JOBTYPE(PID)	;Public;job type of the current process
	;----------------------------------------------------------------------
	;
	; Provide job type of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. job type for current	process
	;
	; RELATED:
	;	. $$%JOBTYPE^%ZFUNC - Compiled code for JOBTYPE
	;
	; EXAMPLE:
	;	S X=$$JOBTYPE^%ZFUNC(12345) => X="1"
	;
	N RC
	S RC=1
	I '$D(PID) S PID=$J
	D &extcall.getjobtype(.PID,.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%JOBTYPE(VARIABLE)	;System;Return compilable code to get job type of pid
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$JOBTYPE^%ZFUNC - Direct call for username
	;
	; EXAMPLE:
	;	S X=$$%JOBTYPE^%ZFUNC(12345) => X="$$JOBTYPE^%ZFUNC(12345)"
	;
	Q "$$JOBTYPE^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
LISTPIDS(LIST)	;Public; Does PID identify a valid process.
	;----------------------------------------------------------------------
	;
	; Get list of mumps processes
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	; List of UNIX pids
	;
	N PID,RC
	S PID=0
	S RC=1
	S LIST(0)=0
LOOP	;
	D &extcall.listpids(.PID,.RC)
	I RC>1 S LIST=RC Q 1
	I PID=0 Q 0
	S LIST(PID)=PID
	GOTO LOOP
	;
	;----------------------------------------------------------------------
LNX(INPUT)	;Public;Natural log value of input
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;	
	; ARGUMENTS:
	;	. INPUT		Number to find log of	
	;
	; RETURNS:
	;	. Natural log of INPUT	
	;
	; RELATED:
	;	. $$%LNX^%ZFUNC - Compiled code for natural log
	;	. $$EXP^%ZFUNC  - Exponentiation
	;	. $$LOG^%ZFUNC  - Common log
	;
	; EXAMPLE:
	;	S X=$$LNX^%ZFUNC(2)  =>  X=.693147180559945
	;
	N RETDATA,I
	S RETDATA=$J("",256)
	S INPUT=+INPUT
	D &extcall.lnx(INPUT,$LENGTH(INPUT),.RETDATA)
	S RETDATA=+RETDATA
	Q RETDATA
	;
	;----------------------------------------------------------------------
%LNX(VARIABLE)	;System;Return natural log compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of 	/TYP=T
	;			number for which log
	;			is required
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$LNX^%ZFUNC - Direct call for natural log
	;
	; EXAMPLE:
	;	S X=$$%LNX^%ZFUNC("NUM") => X="$$LNX^%ZFUNC("NUM")"
	;
	Q "$$LNX^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
LOG(INPUT)	;Public;Common log value (base 10) of input
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;	
	; ARGUMENTS:
	;	. INPUT		Number to find log of	
	;
	; RETURNS:
	;	. Common log of INPUT	
	;
	; RELATED:
	;	. $$%LOG^%ZFUNC - Compiled code for common log
	;	. $$EXP^%ZFUNC  - Exponentiation
	;	. $$LNX^%ZFUNC  - Natural log
	;
	; EXAMPLE:
	;	S X=$$LOG^%ZFUNC(2) => X=.301029995663981
	;
	N RETDATA,I
	S RETDATA=$J("",256)
	S INPUT=+INPUT
	D &extcall.logsca(INPUT,$LENGTH(INPUT),.RETDATA)
	S RETDATA=+RETDATA
	Q RETDATA
	;
	;----------------------------------------------------------------------
%LOG(VARIABLE)	;System;Return common log compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of number for which log is required
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$LOG^%ZFUNC - Direct call for common log
	;
	; EXAMPLE:
	;	S X=$$%LOG^%ZFUNC("NUM") => X="$$LOG^%ZFUNC("NUM")"
	;
	Q "$$LOG^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
LOGINTM(PID)	;Public;LOGINTM of the current process
	;----------------------------------------------------------------------
	;
	; Provide LOGINTM of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. LOGINTM for current	process
	;
	; RELATED:
	;	. $$%LOGINTM^%ZFUNC - Compiled code for LOGINTM
	;
	; EXAMPLE:
	;	S X=$$LOGINTM^%ZFUNC(12345) => X="13:33:22"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getlogintime(.PID,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%LOGINTM(VARIABLE)	;System;Return compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$LOGINTM^%ZFUNC - Direct call for LOGINTM
	;
	; EXAMPLE:
	;	S X=$$%LOGINTM^%ZFUNC(12345) => X="$$LOGINTM^%ZFUNC(12345)"
	;
	Q "$$LOGINTM^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
LOWER(INPUT)	;Public;Convert string to lower case
	;----------------------------------------------------------------------
	;
	; Convert input string to lower case.
	;
	; Case conversion is based on character set contained in ^%CHARSET.  
	; If using alternate character sets, replace the standard ^%CHARSET 
	; with a custom version.
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. INPUT		Input string		
	;
	; RETURNS:
	;	. Output string converted to lower case
	;
	; RELATED:
	;	. $$%LOWER^%ZFUNC - Compiled code for lower case conversion
	;	. $$UPPER^%ZFUNC  - Upper case conversion
	;
	; EXAMPLE:
	;	S X=$$LOWER^%ZFUNC("ABC")  =>  X="abc"
	;
	Q $TR(INPUT,$$UC^%CHARSET,$$LC^%CHARSET)
	;
	;----------------------------------------------------------------------
%LOWER(VARIABLE)	;System;Return lower case conversion compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of string to be converted
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$LOWER^%ZFUNC - Direct call for lower case conversion
	;
	; EXAMPLE:
	;	S X=$$%LOWER^%ZFUNC("X") => X="$TR(X,""ABC..."",""...xyz"")"
	;
	Q "$TR("_VARIABLE_","""_$$UC^%CHARSET_""","""_$$LC^%CHARSET_""")"
	;
	;----------------------------------------------------------------------
MASTERPD(PID)	;Public;parent pid of the current process
	;----------------------------------------------------------------------
	;
	; Provide parent pid of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. parent pid for current	process
	;
	; RELATED:
	;	. $$%MASTERPD^%ZFUNC - Compiled code for MASTERPD
	;
	; EXAMPLE:
	;	S X=$$MASTERPD^%ZFUNC(12345) => X="1"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getparentpid(.PID,.RESULT,.RC)
	I RC'=0 S RESULT=RC	; LYH 03/25/99 - changed from RC=0 to RC'=0
	Q RESULT
	;
	;----------------------------------------------------------------------
%MASTERPD(VARIABLE)	;System;Return compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$MASTERPD^%ZFUNC - Direct call for MASTERPD
	;
	; EXAMPLE:
	;	S X=$$%MASTERPD^%ZFUNC(12345) => X="$$MASTERPD^%ZFUNC(12345)"
	;
	Q "$$MASTERPD^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
MAXBLK(DEVICE)	;Public;Maximum number of blocks on a device
	;----------------------------------------------------------------------
	;
	; Provides the maximun number of blocks on a device.  
	; 
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. DEVICE	Device name		
	;
	; RETURNS:
	;	. Maximum number of	blocks on DEVICE
	;
	; RELATED:
	;	. $$%MAXBLK^%ZFUNC - Compiled code for maximum blocks
	;
	; EXAMPLE:
	;	S X=$$MAXBLK^%ZFUNC("/uxdev") => X=744400
	;
	N RC
	S RC=1
	D &extcall.getmaxblk(DEVICE,.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%MAXBLK(VARIABLE)	;System;Return get maximum blocks compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of device	
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$MAXBLK^%ZFUNC - Direct call for maximum blocks
	;
	; EXAMPLE:
	;	S X=$$%MAXBLK^%ZFUNC("DEVICE")	=> X="$$MAXBLK^%ZFUNC("DEVICE")"
	;
	Q "$$MAXBLK^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
MEMBER(PID)	;Public;Group name of the current process
	;----------------------------------------------------------------------
	;
	; Provide Group name of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Group name for current	process
	;
	; RELATED:
	;	. $$%MEMBER^%ZFUNC - Compiled code for MEMBER
	;
	; EXAMPLE:
	;	S X=$$MEMBER^%ZFUNC(12345) => X="sca"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getmember(.PID,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%MEMBER(VARIABLE)	;System;Return compilable code to return grp name of pid
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$MEMBER^%ZFUNC - Direct call for MEMBER
	;
	; EXAMPLE:
	;	S X=$$%MEMBER^%ZFUNC(12345) => X="$$MEMBER^%ZFUNC(12345)"
	;
	Q "$$MEMBER^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
MESSAGE(MSGID)	;Public;Mesasage text for error message number
	;----------------------------------------------------------------------
	;
	; Provides message from message ID.  
	;
	; KEYWORDS:	System services, Error handling
	;	
	; ARGUMENTS:
	;	. MSGID		OS message number	
	;
	; RETURNS:
	;	. Message string		
	;
	; EXAMPLE:
	;	S X=$$MESSAGE^%ZFUNC(123)
	;	  => X="%SYSTEM-I-DEVNOTMOUNT, device is not mounted"
	;
	Q $ZMESSAGE(INTEXP)
	;
	;----------------------------------------------------------------------
MTMID(SVTYP)	;Public; Get ID of the MTM Process
	;----------------------------------------------------------------------
	;
	; Get ID of the MTM Process
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	ID of MTM Process
	;
	N MTMID,I
	S MTMID=$J("",11)
    	D &mtsapi.SrvMTMId(SVTYP,.MTMID)
    	Q MTMID
	;
	;----------------------------------------------------------------------
NODENAM()	;Public Get nodename
	;----------------------------------------------------------------------
	;
	;  Get the nodename
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	. Nodename
	;
	; RELATED:
	;	. $$%NODENAM^%ZFUNC - Compiled code to get nodename
	;
	; EXAMPLE:
	;	S X=$$NODENAM^%ZFUNC => X="hpux"
	;
	;
	N CDATA,I
	S CDATA=$J("",24)
	D &extcall.getnodename(.CDATA)
	Q CDATA
	;
	;----------------------------------------------------------------------
%NODENAM()	;System;Returns node name of current system
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$NODENAME^%ZFUNC - Direct call for current system time
	;
	; EXAMPLE:
	;	S X=$$%NODENAME^%ZFUNC => X="$$NODENAME^%ZFUNC"
	;
	Q "$$NODENAME^%ZFUNC"
	;
	;----------------------------------------------------------------------
NPID(PID)	;Public;
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;
	; RETURNS:
	;
	; RELATED:
	;	. $$%NPID^%ZFUNC - Compiled code 
	;
	;
	q ""
	N RC
	S RC=1
	D &extcall.getprocessid(.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%NPID(PID)	;System;Return compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$NPID^%ZFUNC - Direct call for this level
	;
	; EXAMPLE:
	;
	Q "$$NPID^%ZFUNC()"
	;
	;----------------------------------------------------------------------
PARSE(FILE,KEY)	; Public;Return the  expanded  file-specification
	;----------------------------------------------------------------------
	; 
	; KEYWORDS:	System Services
	;
	; ARGUMENTS:
	;	. FILE	- File specification	/TYP=N/REQ
	;					
	; 	. KEY	- Parse qualifier	/TYP=T/NOREQ
	;		  NODE  -  Node name
	;		  DEVICE  -  Device name
 	;		  DIRECTORY  -  Directory name
	;		  NAME  -  File name
	;		  TYPE  -  File type
	;		  VERSION  -  File version number
	;
	; RETURNS:
	;	. $$	- Expanded file specification or one of its fields. It
	;		  is analogous  to  the  DCL  F$PARSE.
	;
	; EXAMPLE:
	;	S X=$$PARSE^%ZFUNC("RMS.FILE")
	;
	;
	I '$D(KEY) Q $ZPARSE(FILE)
	Q $ZPARSE(FILE,KEY)
	;
	;----------------------------------------------------------------------
PGTM(PID)	;Public;Is process a mumps process ?
	;----------------------------------------------------------------------
	;
	; Returns process state
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;
	; RETURNS:
	;	. 1 or 0
	;
	; EXAMPLE:
	;	D $$%PMUMPS^%ZFUNC(25012)  
	;
	N STATUS
	S STATUS=0
	D &extcall.pgtm(PID,.STATUS)
	Q STATUS
	;
	;----------------------------------------------------------------------
PID(PID)	;Public;Next PID in the OS pid list
	;----------------------------------------------------------------------
	;
	; Provide PID of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. PID for current	process
	;
	; RELATED:
	;	. $$%PID^%ZFUNC - Compiled code for PID
	;
	; EXAMPLE:
	;	S X=$$PID^%ZFUNC() => X="12345"
	;
	N RC
	S RC=1
	D &extcall.getprocessid(.RC)
	Q RC
	;
	;----------------------------------------------------------------------
%PID()	;System;Return compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$PID^%ZFUNC - Direct call for username
	;
	; EXAMPLE:
	;	S X=$$%PID^%ZFUNC => X="$$PID^%ZFUNC"
	;
	Q "$$PID^%ZFUNC"
	;
	;----------------------------------------------------------------------
PRCNAM(PID)	;Public;Name of the current process
	;----------------------------------------------------------------------
	;
	; Provide name of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. name for current	process
	;
	; RELATED:
	;	. $$%PRCNAM^%ZFUNC - Compiled code for PRCNAM
	;
	; EXAMPLE:
	;	S X=$$PRCNAM^%ZFUNC(12345) => X="/gtm_dist/mumps"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	I '$D(PID) S PID=$J
	D &extcall.getprcnam(.PID,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%PRCNAM(VARIABLE)	;System;Return compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$PRCNAM^%ZFUNC - Direct call for PRCNAM
	;
	; EXAMPLE:
	;	S X=$$%PRCNAM^%ZFUNC(12345) => X="$$PRCNAM^%ZFUNC(12345)"
	;
	Q "$$PRCNAM^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
PRIV(PERMISSION)	;Public;Indicator if process has specified privilege
	;----------------------------------------------------------------------
	;
	; Provides indication as to whether process has specified privileges.
	; Equivalent to DCL lexical F$PRIVILEGE(priv_states).
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. PERMISSION		Permission
	;						May be single privilege or comma separated list
	;
	; RETURNS:
	;	. Indicator		
	;			0 => does not have all permissions requested
	;			1 => has permissions requested
	;			Possible cases are:
	;				MTMUSER, SUPERUSER
	;
	; EXAMPLE:
	;	S X=$$PRIV^%ZFUNC("MTMUSER") => X=1 (Process is member of the MTM group)
	;
	N RC
	S RC=0
	D &extcall.permissions(PERMISSION,.RC)
	Q RC
	;
	;----------------------------------------------------------------------
PRIVMTM(PRIV)	;Public;Indicator if process has specified privilege
	;----------------------------------------------------------------------
	;
	; Provides indication as to whether process has specified privileges.
	; Equivalent to DCL lexical F$PRIVILEGE(priv_states).
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. PERMISSION		Permission
	;						May be single privilege or comma separated list
	;
	; RETURNS:
	;	. Indicator		
	;			0 => does not have all permissions requested
	;			1 => has permissions requested
	;			Possible cases are:
	;				MTMUSER, SUPERUSER
	;
	; EXAMPLE:
	;	S X=$$PRIV^%ZFUNC("MTMUSER") => X=1 (Process is member of the MTM group)
	;
	; Return "1" so that all processes have permission to start the MTM. 
	; Priveleges to start and stop the MTM is controlled using PROFILE
	; userclass.
	;
	Q 1
	;
	N privs,RC
	I '$D(PRIV) S PRIV="MTMPRIV"
	S RC=0
	D &extcall.permissions(PRIV,.RC)
	Q RC
	;
	;----------------------------------------------------------------------
PS(PNAME,RUNNING)	;Public;Check process status
	;----------------------------------------------------------------------
	;
	; Returns process state
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;	. PNAME	Must be string with length of 6 or greater
	;
	; RETURNS:
   	;	. 1 or 0
	;
	; EXAMPLE:
	;	D $$%PS^%ZFUNC("V50UNIX",1)  
	;
	N STATUS
	S STATUS=0
	D &extcall.prunning(PNAME,RUNNING,.STATUS)
	Q STATUS
	;----------------------------------------------------------------------
READPRT(DEVICE)	;Public;Physical terminal address 
	;----------------------------------------------------------------------
	;
	; Provides physical terminal address, i.e, port identification.  Allows
	; identification of the physical address even if connected to a
	; LAT or ethernet link.
	;
	; KEYWORDS:	System services, Device handling
	;	
	; ARGUMENTS:
	;	. DEVICE	Terminal identifier	Generally $I or $P
	;
	; RELATED:
	;	. $$%READPRT^%ZFUNC - Compiled code for physical address
	;
	; RETURNS:
	;	. Physical address	
	;
	; EXAMPLE:
	;	S X=$$READPRT^%ZFUNC("LTA5873:") => X="LAT5#PORT2"
	;
	N X,NOIP
	S NOIP=$$TRNLNM("SCA_IP_READPORT") I NOIP'="" Q DEVICE
	S DEVICE=$J("",80)
	S ERRNO=1
	D &extcall.readport(.DEVICE,.ERRNO)
	I ERRNO=0 S DEVICE=ERRNO
	Q DEVICE
	;
	;----------------------------------------------------------------------
%READPRT(VARIABLE)	;System;Return get physical address compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services, Device handling
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of device	/TYP=T
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$READPRT^%ZFUNC - Direct call for physical address
	;
	; EXAMPLE:
	;	S X=$$%READPRT^%ZFUNC("DEVICE") => X="$$READPRT^%ZFUNC("DEVICE")"
	;
	Q "$$READPRT^%ZFUNC("_VARIABLE_")"
	;
        ;----------------------------------------------------------------------
RLCHR(INPUT,CHR)        ;Public; Remove leading CH's from a string
        ;----------------------------------------------------------------------
        ;
        ; KEYWORDS:     Formatting
        ;
        ; ARGUMENTS:
        ;       . INPUT         Input string    /TYP=T/MECH=VAL/REQ
        ;
        ;       . CHR           Character to be removed
        ;                                       /TYP=T/LEN=1/MECH=VAL/REQ
        ;
        ; RETURNS:
        ;       . $$            Output string, with leading CHR's removed
        ;                                       /TYP=T
        ; RELATED:
        ;       . $$%RLCHR^%ZFUNC - Compiled code for removing leading characters
        ;       . $$RTCHR^%ZFUNC - Remove trailing characters from a string
	;	. $$RTBAR^%ZFUNC - Direct call for remove trailing upbars
        ;       . $$RTB^%ZFUNC    - Remove trailing blanks
        ;
        ; EXAMPLE:
        ;       S X=$$RLCHR^%ZFUNC($c(0)_$c(0)_"abc"_$c(0)_"XYZ",$c(0))
        ;               => X="abc"_$c(0)_"XYZ"
        ;
        ;
	N CDATA,ERRNO
	S ERRNO=1
	S CDATA=$J("",32000)
	D &extcall.rlchr(INPUT,CHR,.CDATA,.ERRNO)
	;
	Q CDATA
	;
	;----------------------------------------------------------------------
%RLCHR(VAR1,VAR2)	;System;Return remove leading CH's compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VAR1		Variable name of	/TYP=T
	;			input string
	;	. VAR2		Variable name of	/TYP=T
	;			character to be removed
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
        ;       . $$RLCHR^%ZFUNC - Remove leading characters from a string
        ;       . $$RTCHR^%ZFUNC - Remove trailing characters from a string
	;	. $$RTBAR^%ZFUNC - Direct call for remove trailing upbars
        ;       . $$RTB^%ZFUNC    - Remove trailing blanks
	;
	; EXAMPLE:
	;	S X=$$%RLCHR^%ZFUNC("STRING1","STRING2") => X="$$RLCHR^%ZFUNC("STRING1","STRING2")"
	;
	Q "$$RLCHR^%ZFUNC("_VAR1_","_VAR2_")"
	;
	;----------------------------------------------------------------------
RTB(INPUT)	;Public;Remove trailing blanks from a string
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. INPUT		Input string		
	;
	; RETURNS:
	;	. Output string, with	
	;			trailing blanks removed
	;
	; RELATED:
	;	. $$%RTB^%ZFUNC  - Compiled code for remove trailing blanks
	;	. $$RTBAR^%ZFUNC - Remove trailing upbars
	;
	; EXAMPLE:
	;	S X=$$RTB^%ZFUNC("abc   ") => X="abc"
	;
	I INPUT="" Q INPUT
	F  Q:$E(INPUT,$L(INPUT))'=" "  S INPUT=$E(INPUT,1,$L(INPUT)-1)
	Q INPUT
	;
	;N i
	;F i=1:1:$L(INPUT," ") Q:$E(INPUT,i)'=" "
	;I i'<$L(INPUT) Q ""
	;
	;N CDATA,ERRNO
	;S ERRNO=1
	;S CDATA=INPUT
	;D &extcall.rtb(INPUT,.CDATA,.ERRNO)
	;
	;Q CDATA
	;
	;----------------------------------------------------------------------
%RTB(VARIABLE)	;System;Return remove trailing blanks compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of input string
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$RTB^%ZFUNC - Direct call for remove trailing blanks
	;
	; EXAMPLE:
	;	S X=$$%RTB^%ZFUNC("STRING") => X="$$RTB^%ZFUNC("STRING")"
	;
	Q "$$RTB^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
RTBAR(INPUT)	;Public; Remove trailing upbars (|) from a string
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. INPUT		Input string		
	;
	; RETURNS:
	;	. Output string, with trailing upbars removed
	;
	; RELATED:
	;	. $$%RTBAR^%ZFUNC - Compiled code for remove trailing upbars
	;	. $$RTB^%ZFUNC    - Remove trailing blanks
	;
	; EXAMPLE:
	;	S X=$$RTBAR^%ZFUNC("abc|XYZ|||") => X="abc|XYZ"
	;
	I INPUT="" Q INPUT
	F  Q:$E(INPUT,$L(INPUT))'="|"  S INPUT=$E(INPUT,1,$L(INPUT)-1)
	Q INPUT
	;
	;I INPUT'["|" Q INPUT
	;
	;N i
	;F i=0:1:$L(INPUT,"|") Q:$E(INPUT,i+1)'="|"
	;I i'<$L(INPUT) Q ""
	;
	;N ERRNO,CDATA
	;S ERRNO=1
	;S CDATA=INPUT
	;D &extcall.rtbar(INPUT,.CDATA,.ERRNO)
	;
	;Q CDATA
	;
	;----------------------------------------------------------------------
%RTBAR(VARIABLE)	;System;Return remove trailing upbars compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of	/TYP=T
	;			input string
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$RTBAR^%ZFUNC - Direct call for remove trailing upbars
	;
	; EXAMPLE:
	;	S X=$$%RTBAR^%ZFUNC("STRING") => X="$$RTBAR^%ZFUNC("STRING")"
	;
	Q "$$RTBAR^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
RTCHR(INPUT,CHR)        ;Public; Remove trailing CH's from a string
	;----------------------------------------------------------------------
	; This is a generalized form for $$RTBAR^%ZFUNC and $$RTB^%ZFUNC.
	;
        ; KEYWORDS:     Formatting
        ;
        ; ARGUMENTS:
        ;       . INPUT         Input string    /TYP=T/MECH=VAL/REQ
        ;
        ;       . CHR           Character to be removed
        ;                                       /TYP=T/LEN=1/MECH=VAL/REQ
        ;
        ; RETURNS:
        ;       . $$            Output string, with trailing CHR's removed
        ;                                       /TYP=T
        ; RELATED:
        ;       . $$%RTCHR^%ZFUNC - Compiled code for remove trailing characters
        ;       . $$RLCHR^%ZFUNC - Remove leading characters from a string
        ;       . $$RTBAR^%ZFUNC  - Remove trailing upbars
        ;       . $$RTB^%ZFUNC    - Remove trailing blanks
        ;
        ; EXAMPLE:
        ;       S X=$$RTCHR^%ZFUNC("abc"_$c(0)_"XYZ"_$c(0)_$c(0),$c(0))
        ;               => X="abc"_$c(0)_"XYZ"
        ;
        ;
	N CDATA,ERRNO
	S ERRNO=1
	S CDATA=$J("",32000)
	D &extcall.rtchr(INPUT,CHR,.CDATA,.ERRNO)
	;
	Q CDATA
	;
	;----------------------------------------------------------------------
%RTCHR(VAR1,VAR2)	;System;Return remove trailing CH's compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VAR1		Variable name of	/TYP=T
	;			input string
	;	. VAR2		Variable name of	/TYP=T
	;			character to be removed
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
        ;       . $$%RTCHR^%ZFUNC - Remove trailing characters from a string
	;	. $$RTBAR^%ZFUNC - Direct call for remove trailing upbars
	;
	; EXAMPLE:
	;	S X=$$%RTCHR^%ZFUNC("STRING1","STRING2") => X="$$RTCHR^%ZFUNC("STRING1","STRING2")"
	;
	Q "$$RTCHR^%ZFUNC("_VAR1_","_VAR2_")"
	;
	;----------------------------------------------------------------------
RTNLST(RTNLST)	;; Public ; Return array of modified routines
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. RTNLST	List of customized	/TYP=T/MECH=REF
	;			routines
	;
	; EXAMPLE:
	;	S X=$$RTNLST^%ZFUNC(.LIST) 
	;
	;
	N REC,FILE,X,%
	S %="|"
	;
	S FILE="f_result.dat"
	;
	; run command file
	S X=$$SYS^%ZFUNC("$SCA_RTNS/sca_rtndir_diff.sh")
	;
	S FILE=$$FILE^%TRNLNM(FILE,"$SCAU_SPOOL")
	S X=$$FILE^%ZOPEN(FILE,"READ",5)
	I X'=1 S ER=1,RM=$P(X,"|",2) Q
	;
	F  U FILE Q:$ZEOF  R REC U 0 D
	.	N RTN,COREDIR,CORESIZ,COREDAT,CORETIM,CUSTDIR,CUSTSIZ,CUSTDAT,CUSTTIM,ER
	.	I REC="" Q
	.	S RTN=$P(REC," ",1)
	.	;
	.	; Custom routine information
	.	S CUSTDIR=$P(REC," ",2)
	.	S CUSTSIZ=$P(REC," ",3)
	.	S CUSTDAT=$$DSJD^SCADAT($P(REC," ",4))
	.	S CUSTTIM=$P(REC," ",5)
	.	;
	.	; Core routine information
	.	S COREDIR=$P(REC," ",6)
	.	I COREDIR'=-1 D
	..		S CORESIZ=$P(REC," ",7)
	..		S COREDAT=$$DSJD^SCADAT($P(REC," ",8))
	..		S CORETIM=$P(REC," ",9)
	.	E  S (COREDIR,CORESIZ,COREDAT,CORETIM)=""
	.	;
	.	;
	.	S RTNLST(RTN)=COREDIR_%_CORESIZ_%_COREDAT_%_CORETIM
	.	S RTNLST(RTN)=RTNLST(RTN)_%_CUSTDIR_%_CUSTSIZ_%_CUSTDAT_%_CUSTTIM
	;
	C FILE
	;
	D DELFILE^%ZRTNDEL(FILE)
	;
	Q
	;
	;----------------------------------------------------------------------
SCABATCH()		;Public; 
	;----------------------------------------------------------------------
	; Called by the application to determine if the batch facility is
	; defined and available.  For UNIX, this function will always return 
	; 1, indicating that the facility to start processes is available.
	;
	Q 1
	;
	;----------------------------------------------------------------------
SEARCH(FILESPEC,STRM)	;Public;Full file specification of file match
	;----------------------------------------------------------------------
	;
	; Provides full file specification of specified file.  
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. FILESPEC	Full or partial	file name.  
	;				Search will find next file matching this input.
	;
	;	. STRM		Search stream		
	;
	; RETURNS:
	;	. File specification	
	;
	; EXAMPLE:
	;	S X=$$SEARCH^%ZFUNC("data.dat") => X="/user/dat/data.dat"
	;
	I $D(STRM) Q $ZSEARCH(FILESPEC,STRM)
	Q $ZSEARCH(FILESPEC)
	;
	;----------------------------------------------------------------------
SPAWN(RTN,CMD,NOMSG)	;Public;Attempt to Spawn a subprocess
	;----------------------------------------------------------------------
	;
	; Spawns a subprocess, invoking either specified image or GM, standard
	; direct mode image.  Runs specified routine within image.
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. RTN		Called routine		/TYP=T
	;			Routine that is called by
	;			the spawned process
	;
	;	. CMD		Symbol to run image	/TYP=T/NOREQ/DEF="GM"
	;			Used to invoke appropriate
	;			image by spawned process.
	;			If GM used, must be defined
	;			at DCL level as:
	;			  GM :== $sca$extcall:scadmod
	;
	;	. NOMSG		Suppress connection	/TYP=L/NOREQ
	;			message.
	;			1 => suppress
	;			0 => display
	;
	; RETURNS:
	;	. $$		Success or failure	/TYP=T
	;			If success, returns 1
	;			If failure, returns message
	;			  "Session limit nnn reached"
	;
	; RELATED:
	;	. $$%SPAWN^%ZFUNC - Compiled code for spawn
	;
	; EXAMPLE:
	;	S X=$$SPAWN^%ZFUNC("^DBSSPAWN") => X=1
	;
	N X,PRCLM,PRCCNT
	S PRCLM=$$PRCNAM($J)
	S PRCCNT=$$JBPRCNT($$MASTERPD($J))
	I PRCCNT'<PRCLM Q "Session limit "_PRCLM_" reached"
	I '$G(NOMSG) U 0 W $$MSG^%TRMVT("Connecting, Please wait") U 0
	I $G(CMD)="" S CMD="GM"
	ZSY CMD_" "_RTN
	Q 1
	;
	;----------------------------------------------------------------------
%SPAWN(RTN,CMD)	;System;Return spawn image compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. RTN		Called routine		/TYP=T
	;			Routine that is called by
	;			the spawned process
	;
	;	. CMD		Symbol to run image	/TYP=T/NOREQ/DEF="GM"
	;			Used to invoke appropriate
	;			image by spawned process.
	;			If GM used, must be defined
	;			at DCL level as:
	;			  GM :== $sca$extcall:scadmod
	;
	; RETURNS:
	;	. $$		Compilable code		/TYP=T
	;
	; RELATED:
	;	. $$SPAWN^%ZFUNC - Direct call for spawn
	;
	; EXAMPLE:
	;	S X=$$%SPAWN^%ZFUNC("^DBSSPAWN") => X="ZSY GM ^DBSSPAWN"
	;
	I $G(CMD)="" S CMD="GM"
	Q "ZSY "_CMD_" "_RTN
	;
	;----------------------------------------------------------------------
STDPRNT()	; Public; Return value for system standard print
	;----------------------------------------------------------------------
	Q ""
	;
	;----------------------------------------------------------------------
SRCEXT()	;Public; Return value for MUMPS routines extension
	;----------------------------------------------------------------------
	Q ".m"		;	lOWER CASE FOR unix
	;
	;----------------------------------------------------------------------
SYS(INPUT)	;Public;Make system level call out of GT.M to UNIX Shell
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. INPUT		Shell command to execute	
	;
	; RETURNS:
	;	. Status code Code returned by $ZSYSTEM call
	;
	; RELATED:
	;	. $$%SYS^%ZFUNC - Compiled code for system call
	;
	; EXAMPLE:
	;	S X=$$SYS^%ZFUNC("DIR") => X=1 and runs DIRECTORY command
	;
	ZSY INPUT
	Q $ZSYSTEM ; Return code
	;
	;----------------------------------------------------------------------
%SYS(VARIABLE)	;System;Return system level call compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable containing	Shell command to execute
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$SYS^%ZFUNC - Direct call for system call
	;
	; EXAMPLE:
	;	S X=$$%SYS^%ZFUNC("COMMAND") => X="ZSY COMMAND"
	;
	Q "ZSY "_VARIABLE
	;
	;----------------------------------------------------------------------
TERMINAL(PID)	;Public;Terminal of the current process
	;----------------------------------------------------------------------
	;
	; Provide terminal of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Terminal for current	process
	;
	; RELATED:
	;	. $$%TERMINAL^%ZFUNC - Compiled code for Terminal
	;
	; EXAMPLE:
	;	S X=$$TERMINAL^%ZFUNC(12345) => X="/dev/ptty4"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.geterminal(.PID,.RESULT,.RC)
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%TERMINAL(VARIABLE)	;System;Return compilable code to get terminal
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$TERMINAL^%ZFUNC - Direct call for TERMINAL
	;
	; EXAMPLE:
	;	S X=$$%TERMINAL^%ZFUNC(12345) => X="$$TERMINAL^%ZFUNC(12345)"
	;
	Q "$$TERMINAL^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
TLO()	;Public; 
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;
	N UTLO
	S UTLO=$PRINCIPAL
	S UTLO=$P(UTLO,"/",$L(UTLO,"/"))
	Q UTLO
	;
	;----------------------------------------------------------------------
TRNLNM(LNM,NOP)	;Public;Translate environmental name
	;----------------------------------------------------------------------
	;
	; Return environmental value for ENVNAM.  
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. ENVNAM	Environmental name		
	;
	;	. NOP		Not used in UNIX
	;
	; RETURNS:
	;	. Equivalence name	
	;
	; RELATED:
	;	. $$TRNLNM^%ZFUNC - Direct call for translate logical name
	;
	; EXAMPLE:
	; 	S X=$$TRNLNM^%ZFUNC("HOME",0) => X="/users/sgw"
	;
	N TMP
	I LNM="SCA$DIR" Q $$CDIR^%LNM
	I LNM["$" D
	.	S TMP=$P(LNM,"$",1)_"_"_$P(LNM,"$",2)
	.	S LNM=TMP
	Q $ZTRNLNM(LNM)
	;
	;----------------------------------------------------------------------
%TRNLNM(VARIABLE,ITER)	;System;Return env name translation compilable code
	;----------------------------------------------------------------------
	;
	; Return compilable version of env name translation.  
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of logical name
	;
	;	. NOP	Not used in UNIX.
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$TRNLNM^%ZFUNC - Direct call for translate logical name
	;
	; EXAMPLE:
	;	S X=$$TRNLNM^%ZFUNC("LOGNAM") => X="$ZTRNLNM("_VARIABLE_")"
	;
	Q "$ZTRNLNM("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
UNPACK(DATA,LENGTH)	;Public;UNPACK DATA based on LENGTH positions
	;----------------------------------------------------------------------
	;
	; Unpack packed numbers.  Format of packed data for this translation is:
	;
	; 	NN NN NS  where - N = some number from 0-9
	;	                  S = Sign  (A/C/E/F = Positive)
	;	                            (anything else = Negative)
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. DATA		Packed data		
	;
	;	. LENGTH	Number of digits to	unpack, excluding sign
	;
	; RETURNS:
	;	. Unpacked result		
	;
	; RELATED:
	;	. $$%UNPACK^%ZFUNC - Compiled code for unpack
	;	. $$UNPACK2^%ZFUNC - Complex unpack
	;
	; EXAMPLE:
	;	S X=$$UNPACK^%ZFUNC("!3l",5) => X=21336
	;
	N CDATA,I
	S CDATA=$J("",256)
	D &extcall.unpack(DATA,LENGTH,.CDATA)
	Q CDATA 
	;
	;----------------------------------------------------------------------
%UNPACK(VAR1,VAR2)	;System;Return unpack compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VAR1		Variable name for packed data
	;
	;	. VAR2		Variable name for length
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$UNPACK^%ZFUNC - Direct call for unpack
	;
	; EXAMPLE:
	;	S X=$$%UNPACK^%ZFUNC("DATA","LEN") 
	;		=> X="$$UNPACK^%ZFUNC("DATA","LEN")"
	;
	Q "$$UNPACK^%ZFUNC("_VAR1_","_VAR2_")"
	;
	;----------------------------------------------------------------------
UNPACK2(DATA,LENGTH,SIGNED,LEFTNIB)	;Public;Complex UNPACKED DATA
	;----------------------------------------------------------------------
	;
	; Unpack more complex packed data than can be handled by 
	; $$UNPACK^%ZFUNC.
	;
	; Handles packed data where the sign is on the left or there
	; may be no sign.  Also, number may start and end in half-bytes
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. DATA		Packed data		
	;
	;	. LENGTH	Number of digits to	unpack, excluding sign
	;
	;	. SIGNED	Signed indicator	
	;				0 => not signed
	;				1 => signed
	;
	;	. LEFTNIB	Start at left nibble
	;				Allows starting at left or right half byte
	;
	; RETURNS:
	;	. Unpacked result		
	;
	; RELATED:
	;	. $$%UNPACK2^%ZFUNC - Compiled code for complex unpack
	;	. $$UNPACK^%ZFUNC   - Simple unpack
	;
	; EXAMPLE:
	;	S X=$$UNPACK2^%ZFUNC("!3l",6,0,1) => X=213372
	;
	N RETDATA,FLOATING,I
	S RETDATA=$J("",24)
	D &extcall.unpack2(DATA,LENGTH,SIGNED,LEFTNIB,.RETDATA)
	S FLOATING=$P(RETDATA,".",2)
	S FLOATING=+FLOATING
	I FLOATING=0 S RETDATA=$P(RETDATA,".",1)
	Q RETDATA
	;
	;----------------------------------------------------------------------
%UNPACK2(DATA,LENGTH,SIGNED,LEFTNIB)	;System;Return UNPACK2 compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. DATA		Variable name for packed data		
	;
	;	. LENGTH	Variable name for number of digits to
	;				unpack, excluding sign
	;
	;	. SIGNED	Variable name for signed indicator
	;
	;	. LEFTNIB	Variable name for start at left nibble
	;				indicator
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$UNPACK2^%ZFUNC - Direct call for complex unpack
	;
	; EXAMPLE:
	;	S X=$$%UNPACK2^%ZFUNC("DATA","LEN","SIGND","LEFT")
	;	  => X="$$UNPACK2^%ZFUNC("_DATA_","_LENGTH_","_SIGNED_","_LEFTNIB_")"
	;
	Q "$$UNPACK2^%ZFUNC("_DATA_","_LENGTH_","_SIGNED_","_LEFTNIB_")"
	;
	;----------------------------------------------------------------------
UPPER(INPUT)	;Public;Convert string to upper case
	;----------------------------------------------------------------------
	;
	; Convert input string to upper case.
	;
	; Case conversion is based on character set contained in ^%CHARSET.  
	; If using alternate character sets, replace the standard ^%CHARSET 
	; with a custom version.
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. INPUT		Input string		
	;
	; RETURNS:
	;	. Output string converted to upper case
	;
	; RELATED:
	;	. $$%UPPER^%ZFUNC - Compiled code for upper case conversion
	;	. $$LOWER^%ZFUNC  - Lower case conversion
	;
	; EXAMPLE:
	;	S X=$$UPPER^%ZFUNC("abc")  =>  X="ABC"
	;
	Q $TR(INPUT,$$LC^%CHARSET,$$UC^%CHARSET)
	;
	;----------------------------------------------------------------------
%UPPER(VARIABLE)	;System;Return upper case conversion compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name of string to be converted
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$UPPER^%ZFUNC - Direct call for upper case conversion
	;
	; EXAMPLE:
	;	S X=$$%UPPER^%ZFUNC("X") => X="$TR(X,""abc..."",""...XYZ"")"
	;
	Q "$TR("_VARIABLE_","""_$$LC^%CHARSET_""","""_$$UC^%CHARSET_""")"
	;
	;----------------------------------------------------------------------
USERNAM()	;Public;Username of the current process
	;----------------------------------------------------------------------
	;
	; Provide username of current process.  
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Username for current	process
	;
	; RELATED:
	;	. $$%USERNAM^%ZFUNC - Compiled code for username
	;
	; EXAMPLE:
	;	S X=$$USERNAM^%ZFUNC() => X="sgw"
	;
	N RC,RESULT,I
	S RC=1
	S RESULT=$J("",80)
	D &extcall.getusername(.RESULT,.RC)
	Q RESULT
	;
	I RC=0 S RESULT=RC
	Q RESULT
	;
	;----------------------------------------------------------------------
%USERNAM(VARIABLE)	;System;Return compilable code to get current process 
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$USERNAM^%ZFUNC - Direct call for username
	;
	; EXAMPLE:
	;	S X=$$%USERNAM^%ZFUNC(12345) => X="$$USERNAM^%ZFUNC(12345)"
	;
	Q "$$USERNAM^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
VALIDPID(SVTYP,SVID)	;Public; Does PID identify a valid process.
	;----------------------------------------------------------------------
	;
	; Returns process id if valid, else 0
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;	. Process Id
	;
	; EXAMPLE:
	;	S PID=$$VALIDPID^%ZFUNC(PID)  
	;
	N PID
	S PID=$P(^SVCTRL(SVTYP,SVID),"|",2)
	D &extcall.validpid(.PID)
	Q PID
	;
        ;----------------------------------------------------------------------
WAIT(wait)      ;Public; Execute a wait or hang
        ;----------------------------------------------------------------------
        ;
        ; Pause the current process, as if a MUMPS hang were executed
        ;
        ; KEYWORDS:     System services
        ;
        ;
        ; RELATED:
        ;       . H 2
        ;
        ; EXAMPLE:
        ;       S X=$$WAIT^%ZFUNC(2) => H 2
        ;
	N VER
        S wait=+$G(wait)
        I 'wait Q ""
	S VER=$ZVERSION
	I VER["V3" D  Q ""
	.	D &extcall.extsleep(wait)
        S wait=wait*1000
        S slpunint=0
        D &extcall.extsleep(wait,slpunint)
        Q ""
        ;
	;----------------------------------------------------------------------
XOR(INPUT)	;Public;Exclusive OR of input string
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. INPUT		Input string		
	;
	; RETURNS:
	;	. Exclusive OR of characters in INPUT
	;
	; RELATED:
	;	. $$%XOR^%ZFUNC - Compiled code for exclusive OR
	;
	; EXAMPLE:
	;	S X=$$XOR^%ZFUNC("ABC") => X=64
	;
	N CDATA,I
	S CDATA=$J("",80)
	D &extcall.xor(INPUT,.CDATA)
	S INPUT=CDATA
	Q INPUT
	;
	;
	;----------------------------------------------------------------------
%XOR(VARIABLE)	;System;Return XOR compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name for input string
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$XOR^%ZFUNC - Direct call for exclusive OR
	;
	; EXAMPLE:
	;	S X=$$%XOR^%ZFUNC("DATA") => X="$$XOR^%ZFUNC("_VARIABLE_")"
	;
	Q "$$XOR^%ZFUNC("_VARIABLE_")"
	;
	;----------------------------------------------------------------------
ZKILL(GLVN)	;Public;Kill array at this level, but not descendants
	;----------------------------------------------------------------------
	;
	; Provides the facility to kill data in a global or local array at
	; a specific subscript level without affecting any lower level data.
	;
	; KEYWORDS:	Array handling
	;	
	; ARGUMENTS:
	;	. GLVN		Global or local array	
	;
	; RETURNS:
	;	. Always returns 1	
	;
	; RELATED:
	;	. $$%ZKILL^%ZFUNC - Compiled code for kill this level
	;
	; EXAMPLE:
	;	If ABC(1,2)="ABC"
	;          ABC(1,2,3)="XYZ"
	;
	;	then S X=$$ZKILL^%ZFUNC("ABC(1,2)") => X=1
	;
	;       leaves only ABC(1,2,3)="XYZ")
	;
	ZWI @GLVN
	Q 1
	;
	;----------------------------------------------------------------------
%ZKILL(VARIABLE)	;System;Return kill at this level compilable code
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Array handling
	;	
	; ARGUMENTS:
	;	. VARIABLE	Variable name for array argument
	;
	; RETURNS:
	;	. Compilable code		
	;
	; RELATED:
	;	. $$ZKILL^%ZFUNC - Direct call for kill this level
	;
	; EXAMPLE:
	;	S X=$$%ZKILL^%ZFUNC("GLVN") => X="ZWI GLVN"
	;
	Q "ZWI "_VARIABLE
	;
