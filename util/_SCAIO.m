%SCAIO	;M Utility;Standard device selection for % utilities
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/01/95 08:18:15 - CHENARD
	; ORIG: Dan S. Russell - 30 Nov 1989
	;
	; Simple general purpose SCA device selection.
	;
	; If ^SCAIO is valid routine and user has access to %SYSVAR global, 
	; then use ^SCAIO.
	;
	; Otherwise, simply prompt for any VAX device and parameters.
	;
	; Call at READ^%SCAIO for RMS READ default prompt.
	;
	; Standard RMS default prompt is WRITE/NEWV.
	;
	; KEYWORDS:	Device handling
	;
	;------Revision History------------------------------------------------
	;
	; 09/01/95 - Phil Chenard - 13005
	;            Replace platform speicfic code with generic calls to 
	;            platform specific utilities.	
	;
	;----------------------------------------------------------------------
	N DEFPAR
	D SET
	Q
	;
	;----------------------------------------------------------------------
READ	; Read default prompt entry point
	;----------------------------------------------------------------------
	N DEFPAR
	S DEFPAR="READ" D SET
	Q
	;
	;----------------------------------------------------------------------
SET	;
	;----------------------------------------------------------------------
	N (DEFPAR,IO,IORM,IOSL,IOTYP,ER)
	S ER=0
	N $ZT
	S $ZT="G DEVICE^%SCAIO" ; Trap for no access to global directory
	I '$D(^%SYSVAR) D DEVICE Q
	I '$$VALID^%ZRTNS("SCAIO") D DEVICE Q  ; No ^SCAIO
	S CALLAT="^SCAIO"
	I $G(DEFPAR)="READ",$T(READ^SCAIO)'="" S CALLAT="READ^SCAIO"
	D @CALLAT I IO=0!(IO="") S IO=$P
	Q
	;
	;----------------------------------------------------------------------
DEVICE	;
	;----------------------------------------------------------------------
	S $ZT=""
	S TIMEOUT=2
	U 0 S IO=$$PROMPT^%READ("Device:  ","")
	I IO=""!(IO=0) S IO=$P W IO
	S X=$TR(IO,"quitsop","QUITSOP")
	I X="Q"!(X="QUIT")!(X="STOP") S ER=1 Q
	I IO["." S CLASS=1
	E  S CLASS=$$DEVCLASS^%ZFUNC(IO)		;Generic call for device
	S IOTYP=$S(CLASS=1:"RMS",CLASS=2:"MT",1:"TRM")
	D @IOTYP
	;
	I PARAMS="" S OPEN="IO::TIMEOUT"
	E  S OPEN="IO:("_PARAMS_"):TIMEOUT"
	D OPEN
	I ER G DEVICE
	Q
	;
	;----------------------------------------------------------------------
RMS	; RMS file
	;----------------------------------------------------------------------
	I $G(DEFPAR)="" S DEFPAR="WRITE:NEWV"
	S PARAMS=$$PROMPT^%READ("  Parameters:  ",DEFPAR)
	I PARAMS="" S PARAMS=DEFPAR
	I PARAMS="?" W !!,"Enter valid GT.M parameters, separated by ':'",!! G RMS
	S IORM=512,IOSL=66
	Q
	;
	;----------------------------------------------------------------------
MT	; Mag tape
	;----------------------------------------------------------------------
	S PARAMS=$$PROMPT^%READ("  Parameters:  ","BLOCK=2048:REWIND")
	I PARAMS="" S PARAMS="BLOCK=2048:REWIND"
	I PARAMS="?" W !!,"Enter valid GT.M parameters, separated by ':'",!! G MT
	S IORM=99999,IOSL=66
	Q
	;
	;----------------------------------------------------------------------
TRM	; Terminal
	;----------------------------------------------------------------------
	S PARAMS=""
	S IORM=$$PROMPT^%READ("  Right margin:  ",80)
	I 'IORM S IORM=80
	S IOSL=24
	Q
	;
	;----------------------------------------------------------------------
OPEN	; Try to open device
	;----------------------------------------------------------------------
	N $ZT
	S $ZT="G OPENERR"
	S ER=0
	O @OPEN
	E  S ER=1 W !!,"Device not available...timeout",!
	Q
	;
	;----------------------------------------------------------------------
OPENERR	;
	;----------------------------------------------------------------------
	W !!,"Error opening device",!,$P($ZS,",",2,999),!
	S ER=1
	Q
	;
	;----------------------------------------------------------------------
CLOSE	; Close IO, use CLOSE^SCAIO if available
	;----------------------------------------------------------------------
	I '$D(^%SYSVAR) C IO Q
	I '$$VALID^%ZRTNS("SCAIO") C IO Q  ; No ^SCAIO
	D CLOSE^SCAIO
	Q
