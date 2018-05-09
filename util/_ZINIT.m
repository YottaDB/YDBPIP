%ZINIT	;M Utility;GT.M Tape Initialization Utility
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 13:42:56 - SYSRUSSELL
	; ORIG:  Mark Ballance, modified by Dan S. Russell (2417)
	;
	; Call at top for prompts.
	;
	; Call at ENT to avoid tape drive prompt.
	;
	; Call at EXT as extrinsic function for no-prompt version
	; with parameters.
	;
	; Also provides DATA-QWIK post processor sub-routines to
	; allow validation of tape drive, density, and label.
	; See PP* sections at bottom.
	;
	; KEYWORDS: 	Device handling
	;
	; EXAMPLE:
	;     S X=$$EXT^%ZINIT(DEVICE,DENSITY,LABEL)
	;
	;            %TDRV may be input if called at ENT
	;
	; OUTPUT:
	;            For $$EXT -
	;              X=0 if tape init fails
	;
	;----------------------------------------------------------------------
	N AQ,DENSITY,LABEL,PHYSICAL,%TDRV,X
	S ER=0
	;
	U 0 W !!,"INITIALIZE A TAPE",!
	;
%TDRV	R !,"Enter tape drive (or 'Q' to quit): 'TAPE0'=> ",%TDRV
	I %TDRV="Q" S ER=1,RM="Tape initialization aborted" Q
	I %TDRV="?" D HELP G %TDRV
	;
%TDRV1	I %TDRV="" S %TDRV="TAPE0"
	D PPTDRV(%TDRV,.PHYSICAL)
	I ER W !,RM D HELP G %TDRV
	;
	W !!,"Ready tape on drive ",%TDRV," and press <return> when ready: "
	R X,!
	;
DENS	R !,"Density: 1600=> ",DENSITY I DENSITY="" S DENSITY=1600
	D PPDENS(DENSITY) I ER W !!,*7,RM,! G DENS
	;
COMPACT	S COMP=""
	R !,"Use Tape Compaction (Y or N) ",COMP S COMP=$S(COMP="Y":1,1:0)
	;
LABEL	R !,"  Label: (SCATAP)=> ",LABEL I LABEL="" S LABEL="SCATAP"
	D PPLABEL(LABEL)
	I ER W !!,*7,RM,! G LABEL
	;
	D INIT
	I 'ER W !,"Tape initialized with density "_DENSITY_" and label "_$E(LABEL,1,6),! Q
	;
RETRY	R !,"Tape is not ready.  Try <A>gain or <Q>uit?  A=> ",AQ
	I AQ="A"!(AQ="") G %TDRV
	I AQ="Q" S ER=1,RM="Tape not ready" Q
	W " ??"
	G RETRY
	;
INIT	S ER=0
	I 'COMP S X=$$SYS^%ZFUNC("INIT "_PHYSICAL_"/DENSITY="_DENSITY_"/MEDIA_FORMAT=NOCOMPACTION/OVER=OWNER "_$E(LABEL,1,6))
	E  S X=$$SYS^%ZFUNC("INIT "_PHYSICAL_"/MEDIA_FORMAT=COMPACTION/OVER=OWNER "_$E(LABEL,1,6))
	I '(X#2) S ER=1
	Q
	;
	;----------------------------------------------------------------------
ENT	;M Utility;Inititialize tape, avoid prompting for the tape drive number
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; INPUTS:
	;     . %TDRV	Tape drive			/TYP=T/NOREQ
	;
	;		If %TDRV defined, no prompt
	;		If not defined, prompt and
	;		return %TDRV.
	;
	; RETURNS:
	;     . ER	Error flag			/TYP=N/LEN=1
	;     . RM	Error message			/TYP=T/COND
	;----------------------------------------------------------------------
	;
	N AQ,DENSITY,LABEL,PHYSICAL,X
	S ER=0
	;
	I '$D(%TDRV) G %TDRV
	G %TDRV1
	;
	;----------------------------------------------------------------------
EXT(DEVICE,DENSITY,LABEL,COMP)	;M Utility;Extrinisic function entry point for tape init
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;     . DEVICE	Tape device			/TYP=T/REQ/MECH=VAL
	;
	;     . DENSITY	Tape density			/TYP=N/NOREQ/LEN=4
	;		(800, 1600 or 6250)		/MECH=VAL/DFT=6250
	;
	;     . LABEL	Tape label			/TYP=T/NOREQ/LEN=6
	;						/MECH=VAL/DFT="SCATAP"
	;
	;     . COMP	Use tape compaction		/TYP=L/NOREQ/LEN=1
	;						/MECH=VAL/DFT=0
	;----------------------------------------------------------------------
	;
	N ER,PHYSICAL,RM,%TDRV,X
	;
	I $G(DENSITY)="" S DENSITY=6250
	I $G(LABEL)="" S LABEL="SCATAP"
	S COMP=+$G(COMP)
	;
	D PPTDRV(DEVICE,.PHYSICAL) I ER Q 0 ; Invalid drive
	D PPDENS(DENSITY) I ER Q 0 ; Invalid density
	D INIT
	Q 'ER ; 0 => failure, 1 => success so reverse ER
	;
	;----------------------------------------------------------------------
PPTDRV(TDRV,PHYSICAL)	;M Utility;Validate tape drive
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;     . TDRV		Tape drive		/TYP=T/REQ/MECH=VAL
	;
	;     . PHYSICAL	Physical device name	/TYP=T/NOREQ
	;						/MECH=REFNAM:W
	; RETURNS:
	;     . ER	Error flag			/TYP=N/LEN=1
	;     . RM	Error message			/TYP=T/COND
	;
	; EXAMPLE:
	;     D PPTDRV^%ZINIT(TDRV)		Verify only
	;     D PPTDRV^%ZINIT(TDRV,.PHYSICAL)	Verify and return
	;					physical device name
	;----------------------------------------------------------------------
	;
	N I,%TDRV
	;
	S ER=0
	I TDRV="" Q
	;
	I TDRV?1N.N S %TDRV="TAPE"_TDRV
	I '$D(%TDRV) S %TDRV=TDRV
	;
	S PHYSICAL=$$TRNLNM^%ZFUNC(%TDRV) ; Translate logical name
	I PHYSICAL="" S PHYSICAL=%TDRV ; or keep actual name
	;
	I $$GETDVI^%ZFUNC(%TDRV,"DEVCLASS")=2 Q
	S ER=1,RM="Invalid tape device"
	Q
	;
	;----------------------------------------------------------------------
PPDENS(DENS)	;M Utility;Validate tape density
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;     . DENS	Tape density			/TYP=N/REQ/MECH=VAL
	;
	; RETURNS:
	;     . ER	Error flag			/TYP=N/LEN=1
	;     . RM	Error message			/TYP=T/COND
	;----------------------------------------------------------------------
	;
	S ER=0
	I DENS="" Q
	I "/800/1600/6250/"[("/"_DENS_"/") Q
	S ER=1,RM="Valid densities are 800, 1600, 6250"
	Q
	;
	;----------------------------------------------------------------------
PPLABEL(LABEL)	;M Utility;Validate tape label
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;     . LABEL	Tape label			/TYP=T/REQ/LEN=6
	;						/MECH=VAL
	;
	; RETURNS:
	;     . ER	Error flag			/TYP=N/LEN=1
	;     . RM	Error message			/TYP=T/COND
	;----------------------------------------------------------------------
	;
	S ER=0
	I LABEL="" Q
	I LABEL'?1.6AN S ER=1,RM="Label must be 1-6 alphanumeric characters"
	Q
	;
	;----------------------------------------------------------------------
HELP	;Private;Help for top level entry
	;----------------------------------------------------------------------
	W !!
	W "Valid tape drive designations are:"
	W !!?5," 0-n  to designate logical names TAPE0 - TAPEn"
	W !!?5,"Any other physical or logical names which are valid tape drives"
	Q
