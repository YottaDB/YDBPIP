%QUEFUNC	;PBS Utility;Event Driver for platform commands
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/17/97 06:37:23 - CHENARD
	; ORIG:	CHENARD - 09/25/95
	; DESC:	Event Driver for platform commands
	;       UNIX platform
	;
	; KEYWORDS:	System Services
	;
	;
	; EXAMPLE:
	;	
	;
	;-----Revision History-------------------------------------------------
	;
	; 12/15/04 - RussellDS - CR14106
	;	     Modified to allow a VERSION number for various functions
	;	     in order to remain backward compatible (act in old way),
	;	     as well as support DBI and not directly interact with
	;	     Profile globals (^QUECTRL).  Modified CTRL section to
	;	     call back into application for updates if VERSION>1.
	;
	; 01/13/99 - Harsha Lakshmikantha
	;	     Modified INIT section to call $$WAIT^%ZFUNC to pause.
	;
	; 10/13/97 - Phil Chenard
	;            Modified SUBMIT to create an additional parameter to
	;            pass to $$^%ZJOB that specifies the name of the error
	;            file.  This change is in conjunction w/ a change in 
	;            ^%ZJOB to use the error file if it is included in the 
	;            parameter list.  Also modified the extrinsic call to 
	;            ^%ZJOB to set the return value into ER.
	;
	;----------------------------------------------------------------------
INIT(%DIR,BCHNUM,JOBNUM,EVENT,VERSION)	;Private; Process entry point for QUEUEs
	;----------------------------------------------------------------------
	; The first time that a batch is submitted, the process that jobs runs
	; this subroutine.  JOBNUM is 0 in this case.  For all resubmissions,
	; the JOBNUM is passed and processing will directly execute the line tag
	; INIT^QUEPGM.
	;
	; ARGUMENTS:	
	;	. %DIR		- Directory name where dayend is running
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. BCHNUM	- Batch number to execute.
	;					/TYP=N/REQ/MECH=VAL
	;	
	;	. JOBNUM	- Job number to resubmit
	;					/TYP=N/REQ/MECH=VAL
	;
	;	. EVENT		- Name of event running
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. VERSION	- Version number
	;					/TYP=N/NOREQ/MECH=VAL
	;			  If not provided or 0 or 1, then code acts in
	;			  old (backward compatible manner) and interacts
	;			  with ^QUECTRL global.  If value is 2, then
	;			  running in DBI version and will call into
	;			  ^QUEPGM to manage updates to QUECTRL.
	;
      	;----------------------------------------------------------------------
	N X
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%QUEFUNC")
	;
	I $G(VERSION)="" S VERSION=1
	;
	S BCHNUM=$G(BCHNUM),JOBNUM=$G(JOBNUM)
	;
	D CTRL(BCHNUM,JOBNUM,.offset,VERSION)
	;
	S X=$$WAIT^%ZFUNC(offset)
	;
	D INIT^QUEPGM(%DIR,BCHNUM,JOBNUM,EVENT)		 ;Call batch executor
	;
	Q
	;
	;----------------------------------------------------------------------
SUBMIT(BCHNUM,JOBNUM,EVENT,PROCESS)	;Private; Spawn the UNIX process
	;----------------------------------------------------------------------
	; 
	;		CALLED BY:	$$SBMTBCH^%OSSCRPT
	; DESC:		Spawn a batch process
	;
	; ARGUMENTS:
	;	. BCHNUM	- Specific batch number to start
	;					/TYP=N/REQ/MECH=VAL
	;
	;	. EVENT		- Event name for which the batch is to run
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. JOBNUM	- Specific job number to start
	;					/TYP=N/REQ/MECH=VAL
	;
	;	. PROCESS	- Process name to job 
	;					/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. ER		- ER=0 => successful JOB
	;			  ER=1 => unsuccessful JOB
	;
	;----------------------------------------------------------------------
	N PARAMS
	S PARAMS="/PRO=QUEPGM"_BCHNUM_"/ERROR=QUEUE"_BCHNUM_".mje"
	;
	S ER='$$^%ZJOB(PROCESS,PARAMS)	;Job the process
	;
	Q 
	;
	;----------------------------------------------------------------------
SUBMITJ(BCHNUM,JOBNUM,EVENT,VERSION)
	;----------------------------------------------------------------------
	;
	; NOTE:  It appears that the global ^ZSLEEP was used as a means to know
	; which batch/jobnum we are waiting on.  There is apparently no other
	; references to this global other than here.  To eliminate the use of
	; a global reference, this has been changed to a Lock.
	;
	N CNT,REC,RTY,SHCMD,X
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%QUEFUNC")
	;
	I $G(VERSION)="" S VERSION=1
	;
	S BCHNUM=$G(BCHNUM),JOBNUM=$G(JOBNUM)
	D CTRL(BCHNUM,JOBNUM,.offset,VERSION)
	;
	I '$D(%DIR) D INT^%DIR
	;
	L +ZSLEEP(BCHNUM,JOBNUM,$J)
	S RESUB=0
	;
	S X=$$WAIT^%ZFUNC(offset)
 	;
	L -ZSLEEP(BCHNUM,JOBNUM,$J)
	;
	ZL "QUEPGM"
	;
	D INIT^QUEPGM(%DIR,BCHNUM,JOBNUM,EVENT)
	;
	Q
	;
	;----------------------------------------------------------------------
ZT	; Error Trap
	;----------------------------------------------------------------------
	S ER=1
	D ZE^UTLERR
	Q
	;
	;----------------------------------------------------------------------
CTRL(BCHNUM,JOBNUM,offset,VERSION)	;Private; Make entry in QUEUE control table
	;----------------------------------------------------------------------
	;
	; For DBI, do not update globals, call back into application to manage
	I $G(VERSION)>1 D QUECTRLU^QUEPGM(EVENT,BCHNUM,JOBNUM,.offset,$G(JOBOFF)) Q
	;
	N bchfre,bchoff,joboff,X,x,y
	S x=$G(^QUEUE(BCHNUM)) Q:x=""
	S bchfre=$P(x,"|",2),bchoff=$P(x,"|",5)
	S offset=bchoff*60
	K ^QUECTRL(EVENT,BCHNUM)
	;
	I JOBNUM D
	.	S y=$G(^QUEUE(BCHNUM,JOBNUM))
	.	S joboff=$P(y,"|",10)
	.	S offset=joboff*60
	;
	; NOTE that the following does not match the table definition, but it has
	; not been changed since not sure how it is used in prior versions.
	;
	S $P(X,"|",1)=$J
	S $P(X,"|",2)=bchfre
	S $P(X,"|",3)=+$H
	S $P(X,"|",4)=$P($H,",",2)
	S $P(X,"|",5)=bchoff
	S $P(X,"|",6)=$P($H,",",2)+(bchoff*60)
	S $P(X,"|",7)=$G(JOBOFF)
	I $G(JOBOFF) S $P(X,"|",8)=$P($H,"|",2)+(JOBOFF*60)
	S ^QUECTRL(EVENT,BCHNUM,JOBNUM)=X 
	Q