%QFUNC	
	;;Copyright(c)1992 Sanchez Computer Associates, Inc.  All Rights Reserved  
	;     	ORIG:  		Sara Walters 6/06/95
	;----------------------------------------------------------------------
	;
	;----------------------------------------------------------------------
SUBMITB(BCHNUM,EVENT)	; Spawn the UNIX process
	;		CALLED BY:	QUEDRV
	;
	;		INPUT:		Batch Number, Event to run
	;		DESC:		Spawn a batch process
	;   	OUTPUT: 	SUCCESS or FAILURE
	;
	;----------------------------------------------------------------------
	N PROCESS
	I '$D(%DIR) S %DIR=$$TRNLNM^%ZFUNC("HOME")
	S PROCESS="BMGR^QUEPGM("_$C(34)_%DIR_$C(34)_","_BCHNUM_","""_EVENT_""")"
	I '$D(^K) S ^K=0
	S ^K=^K+1
	S ^ZBATCH(BCHNUM,$J,^K)=BCHNUM_"|"_$P(^QUEUE(BCHNUM),"|",2)_"|"_+$H_"|"_$P($H,",",2)
    Q $$^%ZJOB(PROCESS,"QUEPGM"_BCHNUM)
	;----------------------------------------------------------------------
BMGR(%DIR,BCHNUM,EVENT) ; Sleep for time specified for batch job to delay
	;----------------------------------------------------------------------
	;
	;D SLEEP^%PCNTRL(($P(^QUEUE(BCHNUM),"|",5)*60))
	D SLEEP^%PCNTRL($P(^QUEUE(BCHNUM),"|",5))
	D INIT^QUEPGM(%DIR,BCHNUM,0,EVENT)	
	;
	;----------------------------------------------------------------------
SUBMITJ(BCHNUM,JOBNUM,EVENT)
	;----------------------------------------------------------------------
	;
	N SHCMD
	I '$D(%DIR) S %DIR=$$TRNLNM^%ZFUNC("HOME")
	S BCHABT=4
	I $P(X,"|",10)["1" D
	.	N MSG
	.	; Directory ~p1
	.	S MSG(1)=$$^MSG(4572,%DIR)
	.	; Batch number ~p1 (~p2)
	.	S MSG(2)=$$^MSG(4569,BCHNUM,$P(X,"|",1))
	.	; Job number ~p1 (~p2)
	.	S MSG(3)=$$^MSG(4583,JOBNUM,$P(^QUEUE(BCHNUM,JOBNUM),"|",1))
	.	; has been resubmitted due to incomplete dependency.
	.	S MSG(4)=$$^MSG(4579)
	.	; Continuation of the batch has been
	.	S MSG(5)=$$^MSG(4570)
	.	; rescheduled for ~p1 at ~p2.
	.	S MSG(6)=$$^MSG(5758,$$DAT^%ZM(+$H,$G(%MSKD)),$$TIME^%ZD)
	.	N X D MAIL^QUEALRT(.MSG)
	;
	I $P(X,"|",12)["1" D 
	.	N MSG
	.	; Directory ~p1, Batch number ~p2, Job number ~p3 has been resubmitted
	.	S MSG=$$^MSG(5757,%DIR,BCHNUM,JOBNUM)
	.	D BRCD^QUEALRT(MSG)
	S X="Sleeping on dependency"
	I '$D(^J) S ^J=0
	S ^J=^J+1
	S ^ZSLEEP(BCHNUM,JOBNUM,$J,^J)=BCHNUM_"|"_JOBNUM_"|"_$P(^QUEUE(BCHNUM,JOBNUM),"|",2)_"|"_+$H_"|"_$P($H,",",2)_"|"_X_"|"_$P(%LOGID,"|",2)
	S RESUB=0
	D SLEEP^%PCNTRL(60)
	S X="Returned from Sleep"
	S ^ZSLEEP(BCHNUM,JOBNUM,$J,^J)=BCHNUM_"|"_JOBNUM_"|"_$P(^QUEUE(BCHNUM,JOBNUM),"|",2)_"|"_+$H_"|"_$P($H,",",2)_"|"_X_"|"_$P(%LOGID,"|",2)
	D INIT^QUEPGM(%DIR,BCHNUM,JOBNUM,EVENT)
	S SHCMD="mupip stop "_$J
	ZSY SHCMD
