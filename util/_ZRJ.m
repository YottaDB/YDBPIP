%ZRJ	;M Utility;Restore GT.M process
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:04:48 - SYSRUSSELL
	; ORIG:  RUSSELL - 22 SEP 1989
	;
	; Allows interactive STOP/ID of GT.M processes to restore at a 
	; GT.M level.
	;
	; Call $$EXT^%ZRJ(PID,.RM) for non-interactive stop
	;
	; KEYWORDS:	System Services
	;
	;-----Revision History-------------------------------------------------
	; 11/06/01 - Harsha Lakshmikantha - 46174
	;	     Modified START section to use the "-w" option for the "ps"
	;	     command on the Linux platforms. The "-w" option produces 
	;	     a wide output so that the command is not truncated.
	;
	; 06/13/01 - Harsha Lakshmikantha - 45731
	;            Modified START section for Solaris port. The grep command
	;	     in /usr/bin does not support the syntax used in the START
	;	     section so /usr/xpg4/bin/grep is used.
	;
	;----------------------------------------------------------------------
	;
START	N (READ)
	N I,GREP,PS,SYS
	S PID=$$PROMPT^%READ("Enter process ID to stop:  ","")
	I "Q"[$TR(PID,"q","Q") Q
	I PID="?" D
	.	S GREP="grep"
	.	S PS="ps -ef"
	.	S SYS=$$^%ZSYS
	.	I SYS="SOLARIS" S GREP="/usr/xpg4/bin/grep"
	.	I SYS="LINUX" S PS="ps -efw"
	.	W !! ZSYSTEM PS_" | "_GREP_" -E ""[0-9] /gtm_dist/mu""" G START
	S OSPID=PID
	I $$OWN(OSPID,.RM) W !!,*7,"  ",RM G START
	I '$$VALID(OSPID,.RM) W !!,*7,"  ",RM G START
	;
	W !! F I=1:1:79 W "-"
	ZSYSTEM "ps -p "_PID 
	W !! F I=1:1:79 W "-"
	W !!,"Image name:  ",$$IMAGENM^%ZFUNC(OSPID)_"."_PID
	W !! F I=1:1:79 W "-"
	;
	I '$$GTMPROC(OSPID,.RM) W !!,*7,"  ",RM G START
	;
	S OK=$$PROMPT^%READ("Is this correct?  No=> ","") I OK="" S OK="N"
	I $TR(OK,"y","Y")'?1"Y".E G START
	W !!,"Please wait..."
	D STOP
	G START
	;
	;----------------------------------------------------------------------
EXT(PID,%rjmsg)	;M Utility;External entry point for non-prompted stop
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. PID		Process number to stop		/TYP=T
	;			In Hex
	;
	;	.%rjmsg		Return message			/TYP=T/NOREQ
	;							/MECH=REF:W
	;
	; RETURNS:
	;	. $$		Success flag			/TYP=L
	;			  1 = success
	;			  0 = failure
	;
	; EXAMPLE:
	;	S ER=$$EXT^%ZTJ(PID,.RM)
	;
	N (PID,%rjmsg)
	S OSPID=PID
	I $$OWN(OSPID,.%rjmsg) Q 0
	I '$$VALID(OSPID,.%rjmsg) Q 0
	I '$$GTMPROC(OSPID,.%rjmsg) Q 0
	D STOP S %rjmsg=""
	Q 1
	;
VALID(OSPID,MSG)	; Check to see if valid PID
	N GETPID,HIT,I
	S GETPID=0,HIT=0
	S HIT=$$PS^%ZFUNC(OSPID,1)
	I $ZGBLDIR'="",$D(^%ZNOREST(OSPID)) S MSG="Process not allowed to be restored" Q 0
	I HIT Q 1
	S MSG="Invalid process ID or insufficient privileges"
	Q 0
	;
OWN(OSPID,MSG)	; Check to see if PID entered is this process
	I OSPID'=$J Q 0
	S MSG="Cannot stop your own process"
	Q 1
	;
MVX(OSPID,MSG)	; Check to see if process is M/VX.  If so, don't stop
	N IMAGE
	S IMAGE=$P($P($ZGETJPI(OSPID,"IMAGNAME"),".",1),"]",2)
	I "/MDAEMON/MGARCOL/MC/MJ/"'[("/"_IMAGE_"/") Q 0
	S MSG="Cannot stop process running in M/VX.  Use M/VX utilities."
	Q 1
	;
GTMPROC(OSPID,MSG)	; Check to see if process is GT.M.  If not, don't stop
	N LKID,HIT,I
	S LKID=0,HIT=0
	S HIT=$$PGTM^%ZFUNC(OSPID)
	I 'HIT S MSG="Process is not running under GT.M.  Cannot stop."
	Q HIT
	;
STOP	; Stop the designated process
	;
	ZSYSTEM "mupip stop "_PID 
	H 5
	Q
