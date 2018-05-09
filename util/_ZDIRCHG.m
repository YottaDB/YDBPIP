%ZDIRCHG	;M Utility;Change directories
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:39:32 - SYSRUSSELL
	; ORIG:  RUSSELL - 30 OCT 1989
	;
	; Utility to allow changing directories.
	; Can change either routine directory, global directory, or both.
	;
	; Prompted change:    D ^%ZRTNCHG
	;
	; To change -
	;                Both:  D CHANGE^%ZDIRCHG(dir) or
	;                       D CHANGE^%ZDIRCHG(rdir,gdir)
	;   Routine directory:  D RTNDIR^%ZDIRCHG(dir)
	;    Global directory:  D GBLDIR^%ZDIRCHG(dir)
	;
	; Must use logical names for 'dir' and they must have the following
	; meanings:
	;
	;   .  dir = top level GT.M directory, e.g., SYSDEV
	;   .  'dir'_routines = routine list, e.g., SYSDEV_ROUTINES
	;   .  'dir'_gbldir   = global directory, e.g., SYSDEV_GBLDIR
	;
	; *** NOTE:  Care must be take when using this routine since any
	;            necessary underlying logicals, e.g. SCAU$CRTNS, etc.,
	;            are not changed.  ^%ZRTNCMP accounts for this, but other
	;            routines may not.
	;
	; KEYWORDS:	System Services
	;
	N DIR
	S DIR=$$PROMPT^%READ("Change GT.M directory to:  ","") Q:DIR=""
	I $ZTRNLNM(DIR)="" W " ... invalid logical name.",! Q
	D CHANGE(DIR)
	W " ... done",!
	Q
	;
	;----------------------------------------------------------------------
CHANGE(RTNDIR,GBLDIR)	;System;Change both routine and global directory
	;----------------------------------------------------------------------
	; If both specified, use both, may be different
	; If only first is specified, change both to first
	;
	; KEYWORDS:	System Services
	;
	I '$D(GBLDIR) S GBLDIR=RTNDIR
	D RTNDIR(RTNDIR)
	D GBLDIR(GBLDIR)
	Q
	;
	;----------------------------------------------------------------------
RTNDIR(DIR)	;System;Change routine directory
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System Services
	;
	S $ZROUTINES=$ZTRNLNM(DIR_"_ROUTINES")
	Q
	;
	;----------------------------------------------------------------------
GBLDIR(DIR)	;System;Change routine directory
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System Services
	;
	S $ZGBLDIR=$ZTRNLNM(DIR_"_GBLDIR")
	Q
