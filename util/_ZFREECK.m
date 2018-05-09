%ZFREECK	;Private;Check available blocks, freeze teller sign-on if insufficient
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/05/95 08:25:30 - CHENARD
	; ORIG: DSR 1/15/86
	;
	; Check free blocks and blocks available on disk(s).  Set up to freeze 
	; teller sign-on's if called from ^BTT to prevent disk full errors
	;
	; CALL at tag INT if want to avoid display
	;
	; Global used:
	;    ^UTBL("FREEB",region)= minimum free blocks required (VMS blocks)
	;                           sets up ^NOSIGNON(region) if freeze
	;                         = Free blocks | $H || Free blocks on disk
	;
	; KEYWORDS:	System Services
	;
	;    INPUTS:
	;	. %REST		Flag to set sign-on 	/TYP=LOG/NOREQ/
	;			restricts
	;
	;-----Revision History-------------------------------------------------
	;
	; 09/05/95 - Phil Chenard - 13005
	;            Replaced platform specific code with generic calls to 
	;            platform specific utilities.
	;
	;----------------------------------------------------------------------
	I $O(^UTBL("FREEB",""))="" W !!,"No minimum block restrictions",! Q
	N (%REST)
	S %DISP=1
	;
LOOP	S REGION="" I %DISP D HDR
	S WASREST=$O(^NOSIGNON(""))'="" ; Was there a restriction in place?
REGION	S REGION=$O(^UTBL("FREEB",REGION)) I REGION="" G EXIT
	S REQ=^(REGION) ; Always in terms of VMS blocks
	D GETAVL
	I %DISP D DISP
	I FREE+AVAIL'<REQ K ^NOSIGNON(REGION)
	E  I $D(%REST) S ^NOSIGNON(REGION)=FREE_"|"_$H_"||"_VMSAVAIL
	G REGION
	;
GETAVL	;Get available free block info for this region
	S (FREE,VMSAVAIL)=0
	S FILE=$V("GVFILE",REGION)
	S FILE=$P($$PARSE^%ZFUNC(FILE),";",1)
	S REMOTE=FILE["::"
	I REMOTE Q  ; Can't obtain info about remote files, shouldn't be set up
	S DISK=$$PARSE^%ZFUNC(FILE,"DEVICE")
	S GTMFREE=$V("FREEBLOCKS",REGION)
	S GTMTOTAL=$V("TOTALBLOCKS",REGION)
	S VMSSIZE=$$FILE^%ZFUNC(FILE,"ALQ")
	; Free blocks as VMS blocks is only estimate based on relation of size
	; of file in VMS blocks to GT.M total blocks.  Tries to factor out
	; miscellaneous GT.M blocks
	S FREE=VMSSIZE\GTMTOTAL*GTMFREE ; Estimate of free blocks in VMS terms
	S AVAIL=$$GETDVI^%ZFUNC(DISK,"FREEBLOCKS")
	Q
	;
HDR	;Heading for display
	W $$GREN^%TRMVT
	W $$CLEARXY^%TRMVT
	W ?32,$$VIDREV^%TRMVT W " FREE BLOCK STATUS " W $$VIDOFF^%TRMVT
	W !?34,"(In VMS blocks)"
	S X="For "_$P($$PARSE^%ZFUNC($ZGBLDIR),";",1)
	W !?(80-$L(X)\2),$$VIDINC^%TRMVT,X,!!,$$VIDOFF^%TRMVT
	W "               Free Blocks     Available         Total   ",$$UPLINE^%TRMVT,"    Minimum",!
	W "Region             In File  +    On Disk  =  Available   ",$$UPLINE^%TRMVT,"   Required",!
	W $$LINE^%TRMVT(57),$$CROSS^%TRMVT,$$LINE^%TRMVT(11),!
	Q
	;
DISP	;Display
	W REGION,?17,$J($FN(FREE,","),9),"  +",?31,$J($FN(AVAIL,","),9),"  =",?45,$J($FN(FREE+AVAIL,","),9)
	W ?57,$$UPLINE^%TRMVT,?60,$J($FN(REQ,","),9)
	I FREE+AVAIL<REQ W ?70,"*"
	W !
	Q
	;
EXIT	;
	I '%DISP Q
	I '$D(%REST),'WASREST Q  ;No restrictions set, no old restrictions
	S NOWREST=$O(^NOSIGNON(""))'="" ;Restricts now?
	I 'WASREST,'NOWREST Q  ;No old or new restrictions
	I WASREST,NOWREST W !!,$$VIDINC^%TRMVT,"Restrictions on sign-on's remain in force",$$VIDOFF^%TRMVT,! Q
	I WASREST,'NOWREST W !!,$$VIDINC^%TRMVT,"Restrictions on sign-on's have been removed",$$VIDOFF^%TRMVT,! Q
	W !!,$$VIDINC^%TRMVT
	W "RESTRICTIONS HAVE BEEN APPLIED TO TELLER SIGN-ON'S UNTIL MORE BLOCKS",!
	W ?15,"ARE FREED IN THE REGIONS MARKED WITH A '*'",$$VIDOFF^%TRMVT
	W !!,"For each region below, purge PROFILE files to gain more free space"
	W !,"within the region, or purge RMS files to gain more space on the disk.",!
	;
ELP	S REGION=$O(^NOSIGNON(REGION)) I REGION="" W !! Q
	S X=^(REGION),FILE=$V("GVFILE",REGION),FILE=$P($$PARSE^%ZFUNC(FILE),";",1)
	W !," Region ",$$VIDINC^%TRMVT,REGION,$$VIDOFF^%TRMVT," (file ",FILE,")"
	G ELP
	Q
	;
INT	;Enter here to avoid all displays
	N (%REST)
	S %DISP=0 G LOOP
