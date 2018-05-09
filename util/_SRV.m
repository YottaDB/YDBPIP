%SRV	
	;;Copyright(c)1992 Sanchez Computer Associates, Inc.  All Rights Reserved  
	;     	ORIG:  		Sara Walters 7/12/95
	;		CALLED BY:	START^PBSUTL
	;
	;		DESC:	Sets up control data for server process.
	;    	INPUT: 		
	;   	OUTPUT: 	NONE
	;
	;----------------------------------------------------------------------
SVCNCT(SVTYP)	; Public
	;----------------------------------------------------------------------
	S ^SVCTRL(SVTYP,$J)="ACTIVE"
	Q
	;----------------------------------------------------------------------
START(SVTYP,SVCNT)	; Public
	;----------------------------------------------------------------------
	N SVID,PRCNAM,JOBNAM,DIRID
	I SVTYP="" S SVTYP="SCA$IBS"
	I 'SVCNT S SVCNT=1
	S DIRID=^CUVAR("PTMDIRID")
	; Delete entries in control table no longer active (i.e., via stop/id)
	S SVID=""
	S SVINDEX=0
	F  S SVID=$O(^SVCTRL(SVTYP,SVID)) Q:SVID=""  D
	.       I '$$VALIDPID^%ZFUNC(SVTYP,SVID) K ^SVCTRL(SVTYP,SVID)
	.	S SVINDEX=SVINDEX+1
	S SVINDEX=SVINDEX+1
	F  D  Q:'SVCNT
	.	S PRCNAM=SVTYP_"_"_DIRID_"_"_SVINDEX
	.	S JOBNAM="SVCNCT^PBSSRV("""_SVTYP_""","_SVINDEX_")"
	.	S x=$$^%ZJOB(JOBNAM,$$GETPARAMS^%ZFUNC("PBSSRV"_SVINDEX))
	.	I x S RM($ZP(RM(""))+1)=$$^MSG(6800,PRCNAM)
	.	E  S RM($ZP(RM(""))+1)=$$^MSG(6799,PRCNAM)
	.	S SVCNT=SVCNT-1
	.	S SVINDEX=SVINDEX+1
	Q
	;----------------------------------------------------------------------
STOP(SVTYP,SVCNT)	; Public
	;----------------------------------------------------------------------
	N PID
	;
	S PID=""
	F  S PID=$O(^SVCTRL(SVTYP,PID)) Q:PID=""  D  Q:'SVCNT
	.	I ^SVCTRL(SVTYP,PID)="ACTIVE" D
	..		S ^SVCTRL(SVTYP,PID)="STOP"
	..       	S SVCNT=SVCNT-1
	Q
	;----------------------------------------------------------------------
CNTRL(SVTYP)	; Public
	;----------------------------------------------------------------------
	N MSG
	;
	S MSG=^SVCTRL(SVTYP,$J)
	I $P(MSG," ",1)="EXEC" D  Q
	.	X $P(MSG," ",2,9999)
	I MSG="STOP" D  H
	.	S ET=$$SVDSCNCT^%MTAPI(vzcsid)
	.	I ET'="" D ERRLOG^PBSUTL(ET)
	.	K ^SVCTRL(SVTYP,$J)
	Q
