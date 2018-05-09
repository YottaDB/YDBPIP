%ZDISMOU	;System;Dismount Tape  
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:40:32 - SYSRUSSELL
	; ORIG:  Mark Ballance, modified by Dan S. Russell (2417)
	;
	; GT.M tape dismount utility
	; Call at top for prompts.
	;
	; Call at ENT to avoid tape drive prompt.
	;
	; Call at EXT as extrinsic function for no-prompt version.
	;
	;   E.g.  S X=$$EXT^%ZDISMOU(DEVICE)
	;
	; This utility will now distinguish whether or not to unload the tape 
	; as part of the dismount based on the value of the logical name 
	; SCA$MT_UNLOAD.  A false value, 0 or null, will result in a tape 
	; dismount with nounload.  A true value. 1 or anything else, will 
	; result ina full tape dismount.
	;
	;    INPUT:  None, if called from top
	;
	;            %TDRV may be input if called at ENT
	;
	;            For $$EXT -
	;            DEVICE may be any valid drive spec
	;
	;   OUTPUT:  ER and possible RM if called from top or ENT
	;
	;            For $$EXT -
	;              X=0 if invalid tape drive, otherwise X=1
	;
	; KEYWORDS:	Device handling
	;
	N %TDRV,%NTDRV
	S ER=0
	;
	U 0 W !!,"DISMOUNT A TAPE",!
	;
%TDRV	R !,"Enter tape drive: 'TAPE0'=> ",%TDRV
	I %TDRV="?" D HELP^%ZINIT G %TDRV
	;
%TDRV1	I %TDRV="" S %TDRV="TAPE0"
	D PPTDRV^%ZINIT(%TDRV,.%NTDRV)
	I ER W !,RM D HELP^%ZINIT G %TDRV
	;
	D DISMOUNT
	Q
	;
DISMOUNT	;
	N UNLD S UNLD="/UNLOAD"
	I '$$TRNLNM^%ZFUNC("SCA$MT_UNLOAD") S UNLD="/NOUNLOAD"
	S X=$$SYS^%ZFUNC("DISMOUNT "_%NTDRV_UNLD)
	Q
	;
	;----------------------------------------------------------------------
ENT	;System;Tape dismount entry point to avoid prompting for the tape drive number
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	N %NTDRV
	S ER=0
	I '$D(%TDRV) G %TDRV
	G %TDRV1
	;
	;----------------------------------------------------------------------
EXT(DEVICE)	;System;Tape dismount extrinisic function entry point
	;----------------------------------------------------------------------
	; Avoids all prompting.  Requires DEVICE parameter
	;
	; KEYWORDS:	Device handling
	;
	N ER,%TDRV,%NTDRV
	I '$D(DEVICE) Q 0
	D PPTDRV^%ZINIT(DEVICE,.%NTDRV) I ER Q 0 ; Invalid drive
	D DISMOUNT
	Q 1
