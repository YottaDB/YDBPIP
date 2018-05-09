%OSSCRPT	;Library;O/S Script Library
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/30/98 10:21:15 - CHENARD
	; ORIG:	CHENARD - 06/21/95
	; DESC:	O/S Script Library	(UNIX)
	;	This routine contains various entry points designed to 
	; 	build command sequences pertinent to the current operating
	;	system.  The library of functions contained here are parameter
	;	driven, in order to make the calls as generic as possible.	
	;	
	;
	; KEYWORDS: System Services
	;
	;
	; LIBRARY:
	;  Command Scripts:
	;	. BACKUP   - Invoke on-linje baqckup script
	;	. BRCDMSG  - Broadcast message to a user
	;	. CLXFR    - Native client transfer
	;	. COPYRTN  - Copy a routine from the host
	;	. EXCHMSG  - MTM exchange
	;	. GETTPRF  - Execute remote TPRF compare
	;	. FEPTFILE - FEP transfer procedure
	;	. FMSPOST  - Auto post IBS batches
	;	. FMSPRNT  - Print files from FMS
	;	. JOBPARAM - Get JOB parameter list
	;	. JRNLON   - Turn on M journalling
	;	. JRNLOFF  - Turn off M journalling
	;	. MAIL     - Send mail to a user
	;	. MTMBOD   - Branch beginning of day procedure
	;	. MTMEOD   - Branch end of day procedure
	;	. PIDLIST  - Return list of all process IDs
	;	. RTNUPDAT - Build remote routine update procedure
	;	. SBMTBCH  - Submit a QUEUE batch
	;	. SENDSIG  - Send a specified signal to a process
	;	. STFMON   - Execute STF monitor
	;	. STFSTART - Build STF monitor startup procedure
	;	. STFSTOP  - Build STF monitor shutdown script
	;	. SVSTOP   - Send a SIGUSR2 signal to a server
	;
	;  Command Strings:
	;	. COMPRESS - File compression utility
	;	. COPYFIL  - Generic copy of file to target location
	;	. DIROUT   - Output a directory listing to file
	;	. DELETE   - Delete a disk file
	;	. EDTOPT   - Execute specified editor
	; 	. EXCHMSG  - MTM control message exchange
	;	. FILENAM  - Return file name from output record
	;	. FORMNAM  - Printer forms types
	;	. MERGE    - Merge/append a file on to another
	;	. MTMSTART - Start an MTM monitor
	;	. MTMSTOP  - Stop an MTM monitor
	;	. PRNTNAM  - Return printer name from output record
	;	. PURGE    - Purge files (nop on UNIX)
	;	. UICOK	   - Validate permissions
	;	. VALIDNM  - Validate a process as running or not
	;
	;
	;-----Revision History-------------------------------------------------
	;
	; 12/15/04 - RussellDS - CR14106
	;	     Modified SBMTBCH section to eliminate need for global
	;	     references if all parameters passed.  This allows it to
	;	     work correctly in DBI environments and remain backward
	;	     compatible.
	;
	;	     Removed unused and commented out code in that section.
	;
	;	     Added BATSTOPN as new version of BATSTOP for DBI to
	;	     avoid global references.  This sub-routines must be used
	;	     in DBI versions and later.
	;
	; 12/04/02 - MURRAY/KINI - 1488
	;	     Added section MERGE to merge/append a file to a target.
	;
	; 08/12/01 - Lik Kwan - 1270
	;	     Modified COPYRTN section to add additional argument to
	;	     preserve file date-time stamp.
	;
	; 06/27/01 - Lik Kwan - 50924
	;            Modified COPYRTN section to pass additional arguments when 
	;            calling sca_compile.sh. Unix return 0 when a command is 
	;            executed successfully. 
	; 
	; 11/06/01 - Harsha Lakshmikantha - 46174
	;	     Modified MAIL section to remove the "-d" option for the
	;	     "mail" command. This option is not supported on the Linux
	;	     platforms. Also modified the PIDLIST section to use the
	;	     "-efw" option for the "ps" command on Linux platforms. The
	;	     "-w" option produces a wide output so that the command
	;	     is not truncated.
	;
	; 05/30/00 - David Reed - 40165
	;	     Modified FMSPOST section to fix a typo and to add
	;	     a loop to copy all files to the FMS directory if the
	;	     IBS and FMS are on remote nodes.
	;
	; 02/15/00 - Brooke kline/David Reed
	;            Added logic to for GL autpost to FMS for an unlinked
	;            client.
	; 
	; 04/29/99 - Phil Chenard
	;            Added new functions to invoke scripts to turn on 
	;            M level journalling and turn off journalling, as well
	;            as on-line backup.
	;
	; 03/15/99 - Hien Ly
	;            Modified section EDTOPT to use a shell script to edit file
	;            so that it could return a value indicating whether changes
	;            were made to the file or not.
	;            (We already have something similar to this under VMS
	;            environment. You can check SCA$RTNS:SCAEDIT_EDT.COM.)
	;
	; 10/28/98 - Phil Chenard
	;            Added new function, BATSTOP, to stop all running batch
	;            processes from an Event ([QUEUEB]) in PROFILE
	;
	; 09/02/98 - Harsha Lakshmikantha
	;      Added new sections SENDSIG and SVSTOP. SENDSIG sends the
	;	     specified signal to a process. SVSTOP sends the SIGUSR2
	;	     signal to wakeup the server.
	;
	; 07/01/98 - Harsha Lakshmikantha
	;	     Modified SBMTBCH section by removing code to setup QUEUE
	;	     control table (^QUECTRL). The entries to the QUEUE control
	;	     table are made in CTRL^QUEFUNC.
	;
	; 03/05/98 - Phil Chenard
	;            Modified EDTOPT to address a problem when the editor 
	;            chosen is not one of the three currently supported 
	;            options.
	;            Also, modified VALIDNM to remove code that was attempting
	;            to execute a server connect in order to determine whether
	;            a MTM was running or not.
	;
	; 09/18/97 - Phil Chenard
	;            Modified RUNTPU to interrogat the value of 'buf' after 
	;            returning from the editor to determine whether a
	;            change was made.
	;
	; 06/26/97 - Harsha Lakshmikantha - 25136 
	;            Added new section EDTOPT to execute the specified editor. 
	; 
	; 05/16/96 - Phil Chenard
	;            Added $$PURGE to support application calls from platforms
	;            that support multiple versions of disk files.
	;
	; 05/09/96 - Phil Chenard
	;            Added new functions to support printing from a MUMPS
	;            application, called from FMS.  $$FMSPRNT, $$PNTQLIST,
	;            
	; 05/06/96 - Phil Chenard
	;            Incorporated a "patch" that was put into an application
	;            routine, CLSTATS^MTMFUNCS into the EXCHMSG function in
	;            this library.
	;
	; 03/15/96 - Phil Chenard
	;            Add new function, $$PIDLIST, that will return a listing
	;            of all active processes currently on the system.
	;
	; 01/09/95 - Phil Chenard
	;            Added documentation.  Added functions for jobbing servers,
	;            starting MTM.
	;
	;----------------------------------------------------------------------
	;**********************************************************************
	; Platform Specific Command Scripts
	;**********************************************************************
	;
	;----------------------------------------------------------------------
BACKUP(reglist,nowait)	;Public; Invoke on-line backups
	;----------------------------------------------------------------------
	;
	N cmd,dirname,script
	S script=$$SCAU^%TRNLNM("OLBACKUP")
	I script="" S script="${BUILD_DIR}/tools/backups/sca_olbackup.sh"
	;
	S nowait=$G(nowait)
	;
	S reglist=$G(reglist)
	I reglist="" S reglist="""*"""
	;
	S dirname=$$TRNLNM^%ZFUNC("PROFILE_DIR")
	I dirname="" S dirname=$$CDIR^%TRNLNM
	;
	S cmd=script
	;S cmd=script_" "_reglist		;comment out the region list
	S cmd=cmd_" "_dirname
	I nowait S cmd=cmd_" &"
	S X=$$SYS^%ZFUNC(cmd)
	I X'=0 Q 1
	Q 0
	;
	;----------------------------------------------------------------------
BOD(DATE)	; Private; 
	;----------------------------------------------------------------------
	D BOD^MTMBOD
	Q
	;
	;----------------------------------------------------------------------
TBRCDMSG(MSG,USER)	;Private; Broadcast message to user
	;----------------------------------------------------------------------
	N ER
	S ER=0
	S PARAM="REPLY/NONOTIFY/BELL/USER="_USER
	S X=$$SYS^%ZFUNC(PARAM_" """_MSG_"""")
	I 'X#2 S ER=1
	Q ER
	;
	;----------------------------------------------------------------------
BRCDMSG(MSG,USER)	;Private; Broadcast message to user
	;----------------------------------------------------------------------
	N ER
	S ER=0
	S PARAM="echo "_MSG_" > /tmp/BRCDMSG;write "_USER_" < /tmp/BRCDMSG;rm -f /tmp/BRCDMSG"
	S X=$$SYS^%ZFUNC(PARAM)
	I 'X#2 S ER=1
	Q ER
	;
	;----------------------------------------------------------------------
CLXFR(QUE,FDIR,FILES,files,HDIR,CPY)	;Private; Native Transfer
	;----------------------------------------------------------------------
	; This function will build a script file to be run on a FEP that will
	; copy and load software changes from the host.
	;
	; ARGUMENTS:	
	;
	;	. QUE	- The transfer queue number, incorporated into the
	;                 name of the procedure.
	;					/TYP=N/REQ/MECH=VAL
	;
	;	. FDIR	- The PROFILE fep directory name
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. FILES	- A list of files, comma separated, that are to be 
	;                 transferred to the client.
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. files	- Parameter list of the files to load
	;					/TYP=T/REQ/MECH=VAL
	;	
	;	. HDIR	- Host directory name	/TYP=T/REQ/MECH=VAL
	;
	;	. CPY	- Flag to indicate whether the files need to be
	;                 copied.		/TYP=L/REQ/MECH=VAL
	;
	;----------------------------------------------------------------------
	N CROU,DATE,ER,FEPNODE,GKILL,HOSTNODE,PROU,RMS,SROU,TBL,TIME,%TN,%TS,X,Z
	;
	N NODE,ERRNO
	S ER=0
	S NODE=$$NODENAM^%ZFUNC
	S ERRNO=1
	;
	I '$G(QUE) Q 1
	;
	I '$D(files) Q 1
	S TBL=$P(files,",",1) I TBL="" S TBL=$C(34,34)
	S GKILL=$P(files,",",2) I GKILL="" S GKILL=$C(34,34)
	S MROU=$P(files,",",3) I MROU="" S MROU=$C(34,34)
	S CROU=$P(files,",",4) I CROU="" S CROU=$C(34,34)
	S SROU=$P(files,",",5) I SROU="" S SROU=$C(34,34)
	S PROU=$P(files,",",6) I PROU="" S PROU=$C(34,34)
	S ZROU=$P(files,",",6) I ZROU="" S ZROU=$C(34,34)
	;	
	D &extcall.clxfr(NODE,FDIR,TBL,GKILL,MROU,CROU,SROU,PROU,.ERRNO)
	Q ER
	;
	;----------------------------------------------------------------------
COPYRTN(hostnode,hostdir,rtn,rtndir,cmp,prv)	; Private; Copy routine & compile
	;----------------------------------------------------------------------
	; Copy routine, called by HOST to FEP routine update/
	;
	; ARGUMENTS:
	;	. hostnode	- The host's system name /TYP=T/REQ/MECH=VAL
	;
	;	. hostdir	- Host diorectory name	/TYP=T/REQ
	;
	;	. rtn		- Routine name
	;
	;	. rtndir	- Routine directory to load
	;
	;	. cmp		- Compile flag
	;				0: Not compile
	;				1: Compile
	;
	;	. prv		- Preserve date-time stamp and user flag
	;				0: default, preserve
	;				1: Not Preserve 
	;	
	N CMD,X
	S rtn=rtn_".m"
	I +$G(prv)=0 D 
	.	I hostnode'="" S CMD="rcp -p "_hostnode_":"_hostdir_"/"_rtn_" "_rtndir
	.	E  S CMD="cp -p "_hostdir_"/"_rtn_" "_rtndir
	I $G(prv) D
	.	I hostnode'="" S CMD="rcp "_hostnode_":"_hostdir_"/"_rtn_" "_rtndir
	.	E  S CMD="cp "_hostdir_"/"_rtn_" "_rtndir
	; 
	S X=$$SYS^%ZFUNC(CMD)
	I X'=0 Q 1		; Routine not copied
	;
	I 'cmp Q 0
	; Compile routine
	U 0 W !,rtn,!
	S CMD="$SCA_RTNS/sca_compile.sh 1 "_rtndir_" "_rtndir_"/obj/"_" "_rtn 
	S X=$$SYS^%ZFUNC(CMD)
	Q 0
	;
	;----------------------------------------------------------------------
FEPTFILE(BCHNO,FDIR,HOSTNODE,FEPARR)	;Private; Fep transfer procedure
	;----------------------------------------------------------------------
	N DATE,DDPCOM,DDPFILE,FEPNODE,HDIR,QUENO,TIME,RMS,X,Z
	;
	S FEPNODE=""
	S HDIR=$$DIR^DDPUTL
	S HDIR=$$SUBDIR^%TRNLNM(HDIR,"DDP")
	S RMS=$$TRNLNM^%ZFUNC(FDIR) I RMS="" Q 1
	;
	S FEP=$P(RMS,":",1) I FEP="" S FEP=HOSTNODE
	N NODE,ERRNO
	S NODE=$$NODENAM^%ZFUNC
	S ER=0
	S ERRNO=1
	;
	D &extcall.feptfile(NODE,FEP,FDIR,RMS,.ERRNO)
	Q ER
	;
	;----------------------------------------------------------------------
FMSPRNT(FILE,QUAL,QUEUE,DELETE)	; Private; Called by FMS applications
	;----------------------------------------------------------------------
	; Execute a command to print a file
	;
	; ARGUMENTS:	
	;	. FILE		- File name	/TYP=T/REQ/MECH=VAL
	;
	;	. QUAL		- Qualifiers to the print command
	;					/TYP=T/NOREQ/MECH=VAL
	;
	;	. QUEUE		- Queue name 	/TYP=T/REQ/MECH=VAL
	;
	;	. DELETE	- Delete flag.  If on, delete file after
	; 			  printing has completed.	
	;					/TYP=L/NOREQ/MECH=VAL
	;
	;----------------------------------------------------------------------
	I '$D(QUEUE) Q 1		;Queue is required
	N cmd,q,qual,ER,X
	S ER=0
	S DELETE=+$G(DELETE)
	S qual=""
	I $G(QUAL)'="" D
	.	F I=1:1:$L(QUAL,"/") S q=$P(QUAL,"/",I) D
	..		I q["COPIES" S qual=qual_$P(q,"=",2) Q
	..		I q["NOTIFY" S qual=qual_" NOTIFY"
	S cmd="$SCA_RTNS/uxprint "_QUEUE_" "_FILE_" "_qual
	S X=$$SYS^%ZFUNC(cmd)
	I DELETE S X=$$SYS^%ZFUNC("rm "_FILE)
	Q ER
	;
	;----------------------------------------------------------------------
JOBPARAM(nam,err,gbl,inp,out,sta,log,pri,img)	;Public; Get JOB parameter list 
	;----------------------------------------------------------------------
	; This function is called by the process starting up a server, in 
	; order to return a parameter list for  jobbing a process.
	;
	; ARGUMENTS:
	;	. nam	- Process name		/TYP=T/REQ/MECH=VAL
	;
	;	. err	- Error file name	/TYP=T/NOREQ/MECH=VAL
	;	
	;	. gbl	- Global directory name /TYP=T/NOREQ/MECH=VAL
	;
	;	. inp	- Input file name	/TYP=T/NOREQ/MECH=VAL
	;
	; 	. out	- Output file name	/TYP=T/NOREQ/MECH=VAL
	;
	;	. sta	- Startup file name	/TYP=T/NOREQ/MECH=VAL
	;
	;	. log	- Log file name		/TYP=T/NOREQ/MECH=VAL
	;
	;	. pri	- Priority		/TYP=N/NOREQ/MECH=VAL
	;
	;	. img	- Image name		/TYP=T/NOREQ/MECH=VAL
	;
	;
	; RETURNS:
	;	. $$		- Parameter (list) to be passed ot the 
	;                         jobbing utility, $$^%ZJOB.
	;					/TYP=T
	;----------------------------------------------------------------------
	N params
	I $G(nam)'="" S params="PRO="_nam
	I $G(err)'="" S params=params_"/ERR="_err
	I $G(gbl)'="" S params=params_"/GBL="_gbl
	I $G(inp)'="" S params=params_"/IN="_inp
	I $G(out)'="" S params=params_"/OUT="_out
	I $G(sta)'="" S params=params_"/STA="_sta
	;
	Q params
	;
	;----------------------------------------------------------------------
JRNLON(reglist,nobefore)	;Public; Call shell script to turn M Journalling on
	;----------------------------------------------------------------------
	;
	Q ""
	;
	;----------------------------------------------------------------------
JRNLOFF(reglist,reopen)	;Public; Turn journalling off
	;----------------------------------------------------------------------
	;
	Q ""
	;
	;----------------------------------------------------------------------
MAIL(MSG,USER,SUBJ,IO)	;Private; Build VMS mail message and send to user
	;----------------------------------------------------------------------
	N I,N,PARAM,FILENAME,X
	;
	N ER,PARAM,X 
	S ER=0 
	S PARAM="mail "_USER_" <"_IO
	S X=$$SYS^%ZFUNC(PARAM)
	S X=$$SYS^%ZFUNC("rm -fr "_IO)
	;
	Q X
	;
	;----------------------------------------------------------------------
BRCD(MSG,GROUP)	; Broadcast the message in MSG to a group of people
	;----------------------------------------------------------------------
	N PARAM,FILENAME,X
	;
	;
	;S PARAM="wall -g"_GROUP_" "_FILENAME
	;S PARAM="wall -groot "_FILENAME
	;S X=$$SYS^%ZFUNC(PARAM)
	;S X=$$SYS^%ZFUNC("rm -fr "_FILENAME)
	Q ""
	;
	;----------------------------------------------------------------------
MERGE(io,target)      ; Public; Generic merge/append of a file to a target
	;----------------------------------------------------------------------
	;
	N X
	;
	; The following call is dummy call using a known and existing
	; standard logical.  This resets the context of the search away
	; from the routine that was last searched for so it will not look
	; for the next occurrence when you call the merge section multiple
	; times.
	S X=$$SEARCH^%ZFUNC("SCAU$SPOOL:")
	;
	S X=$$SEARCH^%ZFUNC(target)
	I X="" Q $$COPYFIL(io,target)
	;
	S X=$$SYS^%ZFUNC("cat "_io_" >> "_target)
	Q 0
	;			
	;----------------------------------------------------------------------
MTMBOD(RD,HD,DATE)	;Private; Build branch beginning of day script
	;----------------------------------------------------------------------
	; VMS Script called to execute a branch beginning of day procedure.
	;
	; ARGUMENTS:	
	;	. RD	- Remote directory name		/TYP=T/REQ/MECH=VAL
	;
	;	. HD	- Host directory name		/TYP=T/REQ/MECH=VAL
	;
	;	. DATE	- Host's system date		/TYP=N/REQ/MECH=VAL
	;
	;
	;----------------------------------------------------------------------
	N NODE
	S NODE=$$NODENAM^%ZFUNC
	;
	D &extcall.mtmbod(NODE,RD,DATE,.ERRORNO)
	Q 0
	;
	;----------------------------------------------------------------------
MTMEOD(RD,HD,%UID)	;Private; Build branch end of day script
	;----------------------------------------------------------------------
	; VMS Script called to execute a branch end of day procedure.
	;
	; ARGUMENTS:	
	;	. RD	- Remote directory name		/TYP=T/REQ/MECH=VAL
	;
	;	. HD	- Host directory name		/TYP=T/REQ/MECH=VAL
	;
	;	. %UID	- User ID to run procedure 	/TYP=N/REQ/MECH=VAL
	;
	;
	;----------------------------------------------------------------------
	N NODE,ERRNO
	S NODE=$$NODENAM^%ZFUNC
	S ER=0
	S ERRNO=1
	;
	D &extcall.mtmeod(NODE,RD,%UID,RD,HD,.ERRNO)
	Q ER
	;
	;----------------------------------------------------------------------
PIDLIST(list)	;Public; Return list of all active processes on system
	;----------------------------------------------------------------------
	; This function outputs all processes from a show system to a temporary
	; file, then opens the file, reads in a process at a time and adds it
	; to the list.  This list is then returned to the calling routine.
	;
	; ARGUMENTS:
	; 	. list	- Process list, keyed by the decimal process ID
	;                 and stores the HEX pid and process name.
	;					/TYP=T/MECH=REFNAM:W
	;
	N CMD,ER,ET,IO,PID,PRCNAM,SYS,X
	K LIST
	;
	S ER=0
	S IO=$$HOME^%TRNLNM("_ZPID_"_$J_".TMP")
	S CMD="ps -ef | cut -b 1-200 | awk -f $SCA_RTNS/cawk >"
	S SYS=$$^%ZSYS
	I SYS="LINUX" S CMD="ps -efw | cut -b 1-200 | awk -f $SCA_RTNS/cawk >"
	S X=$$SYS^%ZFUNC(CMD_IO)
	S X=$$FILE^%ZOPEN(IO,"READ",2)
	I 'X#2 S ER=1,RM=$$^MSG(2799,IO) Q ER  ;"Unable to open file"
	;
	F  S X=$$^%ZREAD(IO,.ET) Q:+ET=1  D
	.       S PID=$P(X," ",1)
	.       S PRCNAM=$P(X," ",2,99)	
	.       S LIST(PID)=PID_"|"_PRCNAM
	.       ;
	C IO:DELETE
	Q 0
	; 
	;----------------------------------------------------------------------
RTNUPDAT(FEP,CMP)	;Private; Build remote routine update script
	;----------------------------------------------------------------------
	; VMS Script called to execute a routine update procedure.
	;
	; ARGUMENTS:	
	;	. FEP	- Front-end directory name	/TYP=T/REQ/MECH=VAL
	;
	;	. CMP	- Compile routine flag		/TYP=L/NOREQ
	;
	;
	;----------------------------------------------------------------------
	N ER,ERRNO,NODE
	S NODE=$$NODENAM^%ZFUNC
	S ER=0
	S ERRNO=1
	S FILE=$$SCAU^%TRNLNM("DIR","HOSTRTNS.LIST")
	;
	D &extcall.rtnupdat(NODE,FEP,FILE,CMP,.ERRNO)
	Q ER
	;
	;----------------------------------------------------------------------
SBMTBCH(BCHNUM,JOBNUM,EVENT,QUEDCL,JOBOFF,BCHFRE,BCHOFF)	;Private; Submit a batch fot restart
	;----------------------------------------------------------------------
	;
	; If JOBOFF is not provided, access from ^QUEUE global.  Newer, DBI, code
	; will pass it to avoid global reference.  (Note that in the latter case
	; it may be zero.  Null or not present indicates VERSION=1.)
	;
	; BCHFRE and BCHOFF are not used in this UNIX version, but are in the
	; VMS version.
	;
	N BCHFRE,BCHOFF,CNT,JOB,JOBABT,PROCESS,VERSION,X
	;
	I $G(JOBOFF)="" S VERSION=1
	E  S VERSION=2
	;
	I '$D(%DIR) S %DIR=$$SCAU^%TRNLNM("DIR")
	;
	S PROCESS="INIT^%QUEFUNC("_$C(34)_%DIR_$C(34)_","
	S PROCESS=PROCESS_BCHNUM_","_JOBNUM_","""_EVENT_""","_VERSION_")"
	I JOBNUM D			;Resubmission pending
	.	I VERSION=1 S JOB=^QUEUE(BCHNUM,JOBNUM),JOBOFF=$P(JOB,"|",10)
	.	S PROCESS="SUBMITJ^%QUEFUNC("_BCHNUM_","_JOBNUM
	.	S PROCESS=PROCESS_","""_EVENT_""","_VERSION_")"
	.	Q:'$G(HDSEQ)
	.	S JOBABT=2 D JOBEND^QUEPGM
	;
	S ER=0
	D SUBMIT^%QUEFUNC(BCHNUM,JOBNUM,EVENT,PROCESS)
	Q ER
	;
	;---------------------------------------------------------------------- 
SENDSIG(PID,SIGNAL)	;Private; Send signal to a process 
	;---------------------------------------------------------------------- 
	S PID=$G(PID) I PID="" Q 0
	S SIGNAL=$G(SIGNAL) I SIGNAL="" S SIGNAL=2	;Default to interrupt
	D &extcall.sendsig(PID,SIGNAL) 
	Q 0 
	; 
	;----------------------------------------------------------------------
STFMON(PARAM,LOG)	;Private; Execute STF monitor script
	;----------------------------------------------------------------------
	N CMD,X
	S CMD="SUBMIT/NOPRINT/LOG="_LOG_"/PARAM="_PARAM_" SCA$RTNS:STFMON.COM"
	S X=$$SYS^%ZFUNC(CMD)
	I 'X#2 Q 1
	Q 0
	;
	;----------------------------------------------------------------------
STFSTART(FEP)	;Private; Startup a STF monitor
	;----------------------------------------------------------------------
	N NODE
	S FEP=$$TRNLNM^%ZFUNC(FEP)
	I FEP[":" S NODE=$P(FEP,":",1),FEP=$P(FEP,":",2)
	E  S NODE=$$NODENAM^%ZFUNC
	;
	D &extcall.stfstart(NODE,FEP,.ERRORNO)
	;
	; I ERRORNO Q 1  
	Q 0
	;
	;----------------------------------------------------------------------
STFSTOP(FEP)	;Private; Stop STF Monitor
	;----------------------------------------------------------------------
	N NODE
	S FEP=$$TRNLNM^%ZFUNC(FEP)
	I FEP[":" S NODE=$P(FEP,":",1),FEP=$P(FEP,":",2)
	E  S NODE=$$NODENAM^%ZFUNC
	;
	D &extcall.stfstop(NODE,FEP,.ERRORNO)
	;
	; I ERRORNO Q 1  
	Q 0
	;
	;---------------------------------------------------------------------- 
SVSTOP(HEXPID)	;Private; Send signal to wakeup server 
	;---------------------------------------------------------------------- 
	N PID 
	S PID=$$HEXDEC^%ZHEX(HEXPID) 
	D &extcall.sendsvsig(PID) 
	Q 0 
	; 
	;----------------------------------------------------------------------
	;
	;**********************************************************************
	; Platform Specific Command Strings
	;**********************************************************************
	;
        ;----------------------------------------------------------------------
BATSTOP ; Private; Stop running batches from all events
	;----------------------------------------------------------------------
	;UNIX VERSION OF THE STOP FUNCTION
	N BATCH,BCH,ENTRY,EVENT,JOB,PID,X
	;
	S (BATCH,EVENT,JOB)=""
	F  S EVENT=$O(^QUECTRL(EVENT)) Q:EVENT=""  D
	.	F  S BATCH=$O(^QUECTRL(EVENT,BATCH)) Q:BATCH=""  D
	..		Q:'$D(^QUETBL(EVENT,BATCH))     ;Batch not submitted
	..		Q:$G(^QUETBL(EVENT,BATCH))      ;Already completed
	..		F  S JOB=$O(^QUECTRL(EVENT,BATCH,JOB)) Q:JOB=""  D
	...			S BCH=$G(^QUECTRL(EVENT,BATCH,JOB))
	...			S PID=$P(BCH,"|",1)
	...			S X=$$SENDSIG(PID,15)  ;kill the proce^
	Q
	;
	;----------------------------------------------------------------------
BATSTOPN	; Private; Stop running batches from all events - NEW VERSION
	;----------------------------------------------------------------------
	;
	; This is a version of BATSTOP that is used for DBI and later versions
	; of Profile to avoid references to globals.
        ;
	;UNIX VERSION OF THE STOP FUNCTION
	;
	N BATCH,EVENT,JOB,JOBLIST,PID,X
	;
        D JOBLISTU^QUEPGM(.JOBLIST)
        S (BATCH,EVENT,JOB)=""
	F  S EVENT=$O(JOBLIST(EVENT)) Q:EVENT=""  D
	.	F  S BATCH=$O(JOBLIST(EVENT,BATCH)) Q:BATCH=""  D
	..		F  S JOB=$O(JOBLIST(EVENT,BATCH,JOB)) Q:JOB=""  D
	...			S PID=JOBLIST(EVENT,BATCH,JOB)
	...			S X=$$SENDSIG(PID,15)  ;kill the process
	;
	Q 
	;
	;----------------------------------------------------------------------
COPYLIST(list,FEP)	; Private;
	;----------------------------------------------------------------------
	N CMD,X
	;
	I $E(FEP,$L(FEP))'="/" S FEP=FEP_"/"
	S CMD="rcp "_list_" "_FEP_"."
	S X=$$SYS^%ZFUNC(CMD)
	Q 0
	;
	;----------------------------------------------------------------------
COPYFIL(io,target)	; Public; Generic copy of a file to a target
	;----------------------------------------------------------------------
	N X
	S X=$$SYS^%ZFUNC("cp "_io_" "_target)
	Q 0
	;
	;----------------------------------------------------------------------
DDPDIR(DIR)	;Private; Return the DDP sub-directory
	;----------------------------------------------------------------------
	N RMSDIR
	I $E(DIR,$L(DIR))'="/" S DIR=DIR_"/"
	S RMSDIR=DIR_"ddp/"
	Q RMSDIR
	;
	;----------------------------------------------------------------------
DIR(DIR,STR,QUAL)	;Public; Output directory list to RMS file
	;----------------------------------------------------------------------	
	; Directory listing of files contained in the specified location
	; matching the passed string.  Qualifiers on the direcotry command are 
	; optional.
	;
	; ARGUMENTS:
	;	. DIR	- Directory name, could be physical location or
	;		  logical name.		/TYP=T/REQ/MECH=VAL
	;	
	;	. STR	- String to scan for.  If null, directory listing
	;		  will include all files.
	;					/TYP=T/NOREQ/MECH=VAL
	;
	;	. QUAL	- Qualifiers to the directory command
	;					/TYP=T/NOREQ/MECH=VAL
	;
	I '$D(DIR) Q ""
	;
	N CMD,I,q,qual,Z,ZSTR,zDIR
	;
	S STR=$G(STR)
	;
	S zDIR=$$TRNLNM^%ZFUNC(DIR) I zDIR'="" S DIR=zDIR
	;
	S ZSTR=$$FILE^%TRNLNM(STR,DIR)
	S CMD="ls",qual=" -1p"
	;
	I $D(QUAL) D
	.	F I=1:1:$L(QUAL,"/") S q=$P(QUAL,"/",I) D
	..		I q["SIZ" S qual=qual_" -s" Q
	..		I q["DAT" S qual=qual_" -l"
	S CMD=CMD_qual
	;
	S Z=$$SYS^%ZFUNC(CMD_" "_ZSTR)
	Q Z
	;
	;----------------------------------------------------------------------
DIROUT(IO,DIR,STR,QUAL)	;Public; Output directory list to RMS file
	;----------------------------------------------------------------------	
	N CMD,I,q,qual,Z,ZSTR,zDIR
	;
	S STR=$G(STR)
	I STR="" S STR="*"
	;
	S zDIR=$$TRNLNM^%ZFUNC(DIR) I zDIR'="" S DIR=zDIR
	;
	S CMD="cd "_DIR			;First, change directory
	S CMD=CMD_"; ls",qual=" -1p"	;Use 'ls' to list contents, 1 file/line
	;
	I $D(QUAL) D
	.	F I=1:1:$L(QUAL,"/") S q=$P(QUAL,"/",I) D
	..		I q["SIZ" S qual=qual_" -s" Q
	..		I q["DAT" S qual=qual_" -l"
	S CMD=CMD_qual
	S CMD=CMD_" "_STR_" > "_IO	;Change standard output to IO
	S Z=$$SYS^%ZFUNC(CMD)
	Q 0
	;
	;----------------------------------------------------------------------
DELETE(FILE,DIR)	; Public; Delete a disk file
	;----------------------------------------------------------------------
	N CMD,file,I,X
	S DIR=$G(DIR)
	F I=1:1:$L(FILE,",") D
	.	S file=$P(FILE,",",I),file=$P(file,";",1)
	.	I DIR'="" S file=$$FILE^%TRNLNM(file,DIR)
	.	S CMD="rm -f "_file
	.	S X=$$SYS^%ZFUNC(CMD)
	Q 0
	;
	;---------------------------------------------------------------------- 
EDTOPT(EDTOPT,RMS,SCR,array)	; Public; Execute the specified editor 
	;---------------------------------------------------------------------- 
	; Call the appropriate editor.  On Unix, the VMS editors EDT and 
	; TPU are not supported.  If either of these options are chosen, 
	; this routine will default to the pico editor.  Currently, there
	; are three editors supported on the Unix platforms, vi, emacs,
	; and pico.  As other editors are introduced, they can be added to
	; this function.
	; 
	N edtcmd,X 
	; 
	S edtcmd="pico "
	I EDTOPT="emc" S edtcmd="emacs " 
	I EDTOPT="vi" S edtcmd="vi " 
	;  
	; LYH 03/15/99 - use a shell script to edit file so that it could
	; return a value indicating whether the file was changed or not.
	; Possible return values from the shell script are 0 (exit), 1 (quit).
	; However, we won't see a 1 in gtm. The value is shifted and it becomes
	; 256 instead. Be careful if you want to test for quit.
	S edtcmd=$$SCA^%TRNLNM("RTNS","scaedit_edt.sh")_" "_edtcmd
	; LYH 03/15/99 - end of change
	;
	S X=$$SYS^%ZFUNC(edtcmd_RMS)
	;
	I X'=0 Q 1 
	;
	Q 0 
	; 
	;----------------------------------------------------------------------
EXCHMSG(CMD,PARAMS,MTMID,RM,NOP)	;Private;Exchange message with an MTM
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;	. CMD		Command			
	;
	;	. PARAMS	Message parameters	
	;			Each parameter is separated by a FS
	;
	;	. MTMID		MTM to send to		
	;
	;	. RETURN	Response		
	;
	;	. NOP		Not used in UNIX
	;
	; RETURNS:
	;
	;	. Status indicator	
	;			0 = success, reply is in RETURN
	;			1 = failure, RM is in RETURN
	;
	; EXAMPLE:
	;	S ER=$$EXCHMSG("STOP",1,"ABC",.REPLY,0)
	;
	;
	N X
	S X=0
	W $$CUP^%TRMVT(1,24),$$CLL^%TRMVT
	;  Waiting for response from MTM ~p1 .  Control-Z to abort.
	W $$^MSG(4304,MTMID)
	S X=$$MTMCNTRL^%MTAPI(CMD,PARAMS,.RM,MTMID) 
	;	
	I CMD="CLSTAT" D
	.	N FS,N S FS=$$FS^MTMFUNCS
	.	S N=$L(RM,FS)
	.	I N=1 S RM=FS_FS_RM
	.	I N=2 S RM=FS_RM
	Q X
	;
	;----------------------------------------------------------------------
FILENAM(rec)	;Private; Return filename from string
	;----------------------------------------------------------------------
	; This private function parses a record from an output file that 
	; contains a directory listing of files
	;
	; ARGUMENTS:	
	;	. rec	- Record from the open file
	;					/TYP=T/REQ/MECH=VAL
	;
	N I,SIZ,X,done
	I $G(rec)="" Q "" 
	I $$UPPER^%ZFUNC($E(rec,1,5))="TOTAL" Q "" 
	F I=1:1 D  Q:$G(done) 
	.       I $E(rec)'=" " S done=1 Q 
	.       S rec=$E(rec,I+1,$L(rec)) 
	S SIZ=$P(rec," ",1) 
	S X=$P(rec," ",2) I X="" Q "" 
	I $E(X,$L(X))="/" Q ""          ;File is a directory 
	; 
	Q $P(X,"/",$L(X,"/"))           ;Only return file name 
	;
	;----------------------------------------------------------------------
FORMNAM(rec)	;Private; Return printer FORM from string
	;----------------------------------------------------------------------
	; This private function parses a record from an output file that
	; contains a listing of forms from the print queues
	;
	; ARGUMENTS:	
	;	. rec	- Record from the open file
	;					/TYP=T/REQ/MECH=VAL
	;
	Q ""		;Not implemented on UNIX
	;
	;----------------------------------------------------------------------
MTMSTART(MTMEXEC,MTMID)	;Public;Start up an MTM Process
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;	. INPUT		MTM ID
	;
	; RETURNS:
	;	. Success or Failure
	;
	N X
	S X=$$SYS^%ZFUNC(MTMEXEC)
	Q '(X#2)
	;
	;----------------------------------------------------------------------
PNTQLIST(IO,QUAL)	;Public; Output Queue list to RMS file
	;----------------------------------------------------------------------	
	; Output info from the existing queues to a disk file.
	;
	; ARGUMENTS:
	;	. IO	- Output file name	/TYP+T/REQ/MECH=VAL
	;
	;	. QUAL	- Qualifiers to the queue
	;		  listing.		/TYP=T/NOREQ/MECH=VAL
	;
	; 
	N CMD,ER,q,qual,Z
	S ER=0
	;
	S CMD="lpstat",qual=" -a"
	I $D(QUAL) D
	.	F I=1:1:$L(QUAL,"/") S q=$P(QUAL,"/",I) D
	..		I q["FULL" S qual=qual_" -t" Q
	S CMD=CMD_qual_" > "_IO
	S Z=$$SYS^%ZFUNC(CMD) 
	Q 0
	;
	;----------------------------------------------------------------------
PRNTNAM(rec)	;Private; Return printer name from string
	;----------------------------------------------------------------------
	; This private function parses a record from an output file that 
	; contains a printer listing of files
	;
	; ARGUMENTS:	
	;	. rec	- Record from the open file
	;					/TYP=T/REQ/MECH=VAL
	;
	N X
	I $G(rec)="" Q ""
	I $E(rec)=" " Q ""
	I $E(rec)=$C(9) Q ""
	;
	S X=$P(rec," ",1)
	I $E(X,$L(X))=":" S X=$E(X,1,$L(X)-1)
	Q X
	;
	;----------------------------------------------------------------------
PURGE(file,dir)	; Public; Purge files
	;----------------------------------------------------------------------
	Q ""		;Only single version exists on UNIX platforms
	;
	;----------------------------------------------------------------------
RUNEDT(RMS,SCR,arr)	; Public; Execute the EDT editor
	;----------------------------------------------------------------------
	N X
	;
	Q $$RUNTPU(RMS,.arr)
	;
	S X=$$SYS^%ZFUNC("@SCA$EDT_COM "_RMS_" "_SCR)
	Q 0
	;
	;----------------------------------------------------------------------
RUNEVE(RMS,arr)	;Public; Execute EVE editor
	;----------------------------------------------------------------------
	N X
	Q $$RUNTPU(RMS,.arr)
	S X=$$SYS^%ZFUNC("@SCA$EVE_COM "_RMS)
	Q 0
	;
	;----------------------------------------------------------------------
RUNTPU(NAME,arr)	;Public; Execute TPU editor
	;----------------------------------------------------------------------
	S ER=0
	I '$D(arr) D  Q:ER
	.	S X=$$FILE^%ZOPEN(NAME,"READ") E  S ER=1 Q
	.	F I=1:1 S X=$$^%ZREAD(NAME,.ET) Q:+ET=1  S ARRAY(I)=X
	.	C NAME
	;
	N array,buf,cmd,I,i,key,LIST,par,SCRIPT,SQLIHLP,X,x
	S par="CODE/TYP=L,DIRECTORY,DQMODE/TYP=L,EXTENSION,FORMAT/TBL=DBTBL6E"
	S par=par_",OUTPUT,PROMPT,MATCH/TYP=N,PLAN/TYP=L,ROWS/TYP=N" 
	S par=par_",PROTECTION/TYP=N,STATISTICS/TYP=L,OPTIMIZE/TYP=L,STATUS" 
	S par=par_",MASK/TYP=U,TIMEOUT/TYP=N,CACHE/TYP=N,BLOCK/TYP=N"
	;
	S SQLIHLP(1)=$$SCAU^%TRNLNM("HELP","SQLI.HLP")
	S SQLIHLP(2)=$$SCAU^%TRNLNM("HELP","SQL.HLP")
	S HELP(1)="Editor"
	S HELP(2)="PROFILE Commands"
	S SCRIPT=$$HOME^%TRNLNM("SQLI.INI") 
	;
	S LIST("TABLES")="SELECT FID,DES,GLOBAL FROM DBTBL1"
	S LIST("COLUMNS")="SELECT DI,DES,TYP,LEN FROM DBTBL1D WHERE FID=?"
	;
	S cmd("RUN")="D RUN^SQLI(1,rec),REF^EDIT"
	S cmd("LIST")="D LIST^SQLI(1/REQ),REF^EDIT"
	S cmd("INCLUDE","PROCEDURE")="D INCPRE^SQLI(1),REF^EDIT"
	S cmd("COLUMNS")="D COLUMNS^SQLI(1/REQ)"
	S cmd("CONVERT")="D CONVERT^SQLI(1/REQ),REF^EDIT"
	S cmd("TUTORIAL")="D ^DBSTEST9,REF^EDIT"
	;
	;S key("END")="SAVE"
	;
	S buf=""
	I $D(ARRAY) S X="" F  S X=$O(ARRAY(X)) Q:X=""  D
	.	S $P(buf,$C(13,10),X)=ARRAY(X)
	D ^EDIT(.buf,,,,,.cmd,.key,.par,NAME,.HELP,SCRIPT)
	I buf="" Q 1
	;
	F i=1:1:$L(buf,$C(13,10)) S ARRAY(i)=$P(buf,$C(13,10),i)
	Q 0
	;
	;----------------------------------------------------------------------
UICOK(MTMID)	;Private; Check if user is in same UIC group
	;----------------------------------------------------------------------
	; Private;Check that UIC group for this process is same as MTM
	; or is systemotherwise cannot talk to control mailbox
	;
	; ARGUMENTS:
	;	. MTMID		Name of MTM	/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$		Error indictor		/TYP=L
	;			1 = UIC is OK
	;			0 = Not OK
	;
	; EXAMPLE:
	;	S X=$$UICOK^%OSSCRPT(MTMID)
	;
	;----------------------------------------------------------------------
	Q 1
	;
	;----------------------------------------------------------------------
VALIDNM(pnam,running)	;Public;Check process status
	;----------------------------------------------------------------------
	; Check to see if the process exists, based on the process name.
	; This has little value on UNIX systems compared to VMS systems, 
	; however, there are some processes, like MTM, that do get submitted
	; with a specific name.
	;
	; Returns process state
	;
	; KEYWORDS:	
	;	
	; ARGUMENTS:
	;	. pnam	  - Process name
	;
	;	. running - Process is running or not
	;
	; RETURNS:
	;	. 1 or 0
	;
	; EXAMPLE:
	;	S X=$$VALIDNM^%OSSCRPT("MTM_V50UNIX",1)  
	;
	N STATUS,list,nam,x,z,zz
	S STATUS=0,x=""
	D ^%ZPID(.list)
	;
	F  S x=$O(list(x)) Q:x=""  D  Q:STATUS
	.	S nam=$P(list(x),"|",2)
	.	I pnam["MTM" D
	..		S z=$F(nam,"-n"),zz=$F(nam," ",z)-2
	..		S nam=$E(nam,z,zz)
	.	E  S nam=$P(nam,"/",$L(nam,"/"))
	.	I nam=pnam S STATUS=1
	;
	Q STATUS
	;
	;----------------------------------------------------------------------
FMSPOST(CO,BATCH,POSTFILE,LIST)	
	;----------------------------------------------------------------------
	N ER,IDIR,IO,X,FILE,SYSNODE,NODE,FMSDIR
	;
	S ER=0
	;
	S FILE=$$TRNLNM^%ZFUNC("fmspost") I FILE="" Q 1
	S NODIR=$$TRNLNM^%ZFUNC("fmsnodir")
	S FMSDIR=$P(NODIR,"::",2)	; FMS directory
	;
	; CREATE TEMPORARY SCRIPT FILE TO CALL AUTOPOST SCRIPT FILE
	S SPLDIR=$$SCAU^%TRNLNM("SPOOL")
	S DIR=$$SCAU^%TRNLNM("DIR")
	S FILENAME="FMSTMP.sh"
	S IO=$$FILE^%TRNLNM(FILENAME,SPLDIR)
	S X=$$FILE^%ZOPEN(IO,,2) I 'X S ER=1 Q ER
	S args=DIR_" "_CO_" "
	S args=args_""""_BATCH_""""
	S args=args_" "
	S args=args_""""_POSTFILE_""""
	U IO
	W "ksh "_FMSDIR_"/"_FILE_" "_args
	C IO
	;
	S SYSNODE=$$NODENAM^%ZFUNC()
	S NODE=$P(NODIR,":",1)
	;
	;
	; IBS/FMS same node
	I NODE=""!(NODE=SYSNODE) D
	.	I POSTFILE'="" D
	..		S FMSFILE=""
	..		F  S FMSFILE=$O(LIST(FMSFILE)) Q:FMSFILE=""  D
	...			S X=$$SYS^%ZFUNC("cp "_SPLDIR_"/"_FMSFILE_" "_FMSDIR_"/spool/"_FMSFILE)
	.	S X=$$SYS^%ZFUNC("ksh "_IO)
	;
	; Remote submit
	I NODE'="",NODE'=SYSNODE D
	.	S X=$$SYS^%ZFUNC("rcp "_SPLDIR_"/"_FILENAME_" "_NODE_":/"_FMSDIR_"/FMSTMP.ksh")
	.	I POSTFILE'="" D
	..		S FMSFILE=""
	..		F  S FMSFILE=$O(LIST(FMSFILE)) Q:FMSFILE=""  D
	...			S X=$$SYS^%ZFUNC("rcp "_SPLDIR_"/"_FMSFILE_" "_NODE_":/"_FMSDIR_"/"_FMSFILE)
	.	S X=$$SYS^%ZFUNC("ksh "_NODE_":/"_FMSDIR_"/"_FILENAME)
	Q ER
	;
	;----------------------------------------------------------------------
FMSSPOOL()	; Returns the FMS spool directory 
	;----------------------------------------------------------------------
	Q $$TRNLNM^%ZFUNC("fmsspool")
