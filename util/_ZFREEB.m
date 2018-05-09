%ZFREEB	;M Utility;Free block display for current global directory
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/01/95 08:53:50 - CHENARD
	; ORIG:  RUSSELL - 23 OCT 1989
	;
	; Display total and free blocks for all regions within the current 
	; global directory.
	;
	; KEYWORDS:	System services
	;
	;------Maintenance History--------------------------------------------
	;
	; 09/01/95 - Phil Chenard - 13005
	;            Replaced platform specific code with generic calls to 
	;            platform specific utilities.
	;
	; 03/17/93 - Phil Chenard
	;            Change screen width to 132 when running report.  Also,
	;            replace some of the prompting with standard calls to 
	;            ^%TRMVT.
	;
	;---------------------------------------------------------------------
	N DISK,DISKS,FILE,GTMFREEB,GTMTOTB,REGION,REMOTE,VMSTOTB,X
	S @$$SET^%ZT("ZT^%ZFREEB")
	W $$GREN^%TRMVT
	W $$CLEAR^%TRMVT
	W $$SCR132^%TRMVT
	D HDR
	;
	S REGION=$V("GVFIRST") I REGION="" S ER=1,RM="No regions" Q
	D GETINFO,DISPLAY
	;
	F  S REGION=$V("GVNEXT",REGION) Q:REGION=""  D GETINFO,DISPLAY
	D SHOWDSKS
	;
	W $$MSG^%TRMVT("End of report",0,1)
	W $$SCR80^%TRMVT
	Q
	;
	;---------------------------------------------------------------------
GETINFO	; Get information about REGION
	;---------------------------------------------------------------------
	S FILE=$V("GVFILE",REGION),FILE=$P($$PARSE^%ZFUNC(FILE),";",1)
	S REMOTE=FILE["::",DISK=$$PARSE^%ZFUNC(FILE,"DEVICE")
	S DISKS(DISK)=REMOTE
	;
	I REMOTE S (GTMFREEB,GTMTOTB)="Remote"
	E  S GTMFREEB=$V("FREEBLOCKS",REGION)
	E  S GTMTOTB=$V("TOTALBLOCKS",REGION)
	S VMSTOTB=$$FILE^%ZFUNC(FILE,"ALQ")
	Q
	;
	;---------------------------------------------------------------------
DISPLAY	; Display block information by region
	;---------------------------------------------------------------------
	W !,REGION,!
	W ?3,FILE,!
	W ?39,$J($FN(VMSTOTB,","),10)
	W ?51,$J($FN(GTMTOTB,","),10)
	W ?62,$J($FN(GTMFREEB,","),10)
	W ?73,$J($S('GTMTOTB:0,1:GTMFREEB/GTMTOTB*100),6,1),"%"
	Q
	;
	;---------------------------------------------------------------------
SHOWDSKS	; Show free blocks for all disks used
	;---------------------------------------------------------------------
	W !,$$LINE^%TRMVT(80)
	W !,"Free blocks on disk - "
	S DISK=""
	F  S DISK=$O(DISKS(DISK)) Q:DISK=""  W ?22,DISK,?28,$J($S(DISKS(DISK):"Remote",1:$FN($$GETDVI^%ZFUNC(DISK,"FREEBLOCKS"),",")),10),!
	W $$LINE^%TRMVT(80)
	Q
	;
	;---------------------------------------------------------------------
HDR	; Clear screen and display heading
	;---------------------------------------------------------------------
	W $$CLEAR^%TRMVT
	S X="Block usage for "_$P($$PARSE^%ZFUNC($ZGBLDIR),";",1) W $J("",80-$L(X)\2),X
	W !!,"Region",?40,"Total VMS",?51,"Total GT.M",?63,"Free GT.M",?73,"Percent"
	W !,"   File",?40,"   Blocks",?52,"   Blocks",?63,"   Blocks",?76,"Free"
	W !,$$LINE^%TRMVT(80),!
	Q
	;
	;---------------------------------------------------------------------
ZT	; Log MUMPS errors
	;---------------------------------------------------------------------
	D ZE^UTLERR
	Q
	;
