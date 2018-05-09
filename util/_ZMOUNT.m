%ZMOUNT	;System;Mount Tape
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:51:40 - SYSRUSSELL
	; ORIG:  Mark Ballance, modified by Dan S. Russell (2417)
	;
	; M/VX tape mount utility.
	; Call at top for prompts
	;
	; Call at ENT to avoid tape drive prompt.
	;
	; Call at EXT as extrinisic function for no-prompt version with 
	; parameters.
	;
	;   E.g.  S X=$$EXT^%ZMOUNT(DEVICE,FOREIGN,LABEL)
	;
	; INPUT:  None if called from top
	;
	;         %TDRV may be input if called at ENT
	;
	;         For $$EXT -
	;         DEVICE may be any valid tape drive spec.
	;         FOREIGN = 1 if mount foreign
	;         LABEL is required if non-foreign mount
	;
	;OUTPUT:  ER and possibly RM if called from top
	;
	;         %TDRV if from ENT
	;
	;         For $$EXT -
	;           X=0 if tape mount fails
	;
	; KEYWORDS:	Device handling
	;
START	N %TDRV,X,LABEL,AQ,PHYSICAL,YN,FOREIGN
	S ER=0
	;
	U 0 W !!,"MOUNT A TAPE",!
	;
%TDRV	R !,"Enter tape drive (or 'Q' to quit): 'TAPE0'=> ",%TDRV
	I %TDRV="Q" S ER=1,RM="Tape mount aborted" Q
	I %TDRV="?" D HELP^%ZINIT G %TDRV
	;
%TDRV1	I %TDRV="" S %TDRV="TAPE0"
	D PPTDRV^%ZINIT(%TDRV,.PHYSICAL)
	I ER W !,RM D HELP^%ZINIT G %TDRV
	;
	W !!,"Ready tape on drive ",%TDRV," and press <return> when ready: " R X,!
	;
FOREIGN	R !,"Mount Foreign? (Y/N): Y=> ",YN I YN="" S YN="Y"
	S YN=$TR(YN,"yn","YN") I '(YN="Y"!(YN="N")) G FOREIGN
	I YN="Y" S FOREIGN=1,LABEL="" G TRY
	;
LABEL	S FOREIGN=0
	R !,"Enter label: ",LABEL I LABEL="" G FOREIGN
	;
TRY	D MOUNT
	I 'ER W !,"Tape mounted",! Q
	;
RETRY	;
	R !,"Tape is not ready.  Try <A>gain or <Q>uit?  A=> ",AQ
	I AQ="A"!(AQ="") G %TDRV
	I AQ="Q" S ER=1,RM="Tape not ready" Q
	W " ??"
	G RETRY
	;
MOUNT	S ER=0
	N Z
	S Z="MOUNT/"_$S(FOREIGN:"FOREIGN/",1:"")_"NOASSIST "_PHYSICAL_$S($G(LABEL)'="":" "_LABEL,1:"")
	S X=$$SYS^%ZFUNC(Z)
	I '(X#2) S ER=1
	Q
	;
	;----------------------------------------------------------------------
ENT	;System;Tape mount entry point to avoid prompting for the tape drive number
	;----------------------------------------------------------------------
	; If %TDRV defined, no prompt
	; If not defined, prompts and %TDRV is returned
	;
	; KEYWORDS:	Device handling
	;
	N X,LABEL,AQ,PHYSICAL,YN,FOREIGN
	S ER=0
	I '$D(%TDRV) G %TDRV
	G %TDRV1
	;
	;----------------------------------------------------------------------
EXT(DEVICE,FOREIGN,LABEL)	;System;Tape mount extrinisic function entry point.
	;----------------------------------------------------------------------
	; Avoids all prompting.  Requires parameters as identified above.
	;
	; KEYWORDS:	Device handling
	;
	N ER,%TDRV,X,RM,PHYSICAL
	I $G(FOREIGN)="" S FOREIGN=1
	S LABEL=$G(LABEL)
	I 'FOREIGN,LABEL="" Q 0 ; No label supplied
	D PPTDRV^%ZINIT(DEVICE,.PHYSICAL) I ER Q 0 ; Invalid device
	D MOUNT
	Q 'ER ; 0 => failure, 1 => success, so reverse ER
