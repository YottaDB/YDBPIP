%ZJOB(%zjobref,%zparams,%znoload)	;Public;Interface to JOB Command
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved
	; ORIG:  Dan S. Russell (2417) - 09 Nov 88
	;
	;
	; GT.M Job command with passing of symbol table.
	; Use as extrinisic function:
	;
	; Under GT.M, the job command will execute the user's login.com.  This 
	; routine will specify that the startup file SCAU$DIR:GTMENV.COM will 
	; then be executed, if the parameter %zjobsta is not defined by the 
	; logical name SCAU$GTMENV.
	;
	; Temporary files, JOB.TMP_$J_SU and _ZWR will be created in SYS$LOGIN
	; as startup files and input files.  This naming convention avoids
	; conflicts with other processes under the same user name using ^%ZJOB
	; at the same time.
	;
	; Output files (.MJO) will be directed to the null device, 
	; /dev/null, unless specified in the params argument and error 
	; files (.mje) will either be directed to the defined spool 
	; directory or the users home directory if the spool is not defined.
	;
	; Note: until the GT.M on UNIX has been changed to accept more
	; than 14 characters in the file specification names for ERROR
	; and OUTPUT, the placement of these files will be forced to the 
	; current directory and truncated to 14 characters.
	;
	;
	; KEYWORDS:	M Utilities
	;     
	; ARGUMENTS:
	;     . %zjobref	Line_tag^rtn to call
	;						/TYP=T/REQ/MECH=VAL
	;
	;     . %zparams	Option parameters	/TYP=T/NOREQ/MECH=VAL
	;
	;                       /PRO=process_name
	;			/ERROR=error_file
	;			/OUTPUT=output_file
	;			/DEF=default_dir
	;
	;     . %znoload	Ignore save/load	/TYP=N/NOREQ/MECH=VAL
	;			of symbol table
	;
	;                       0 = Do not ignore (default)
	;                       1 = Ignore
	;
	; INPUTS:
	;     . Logical		$SCAU_GTMENV		/TYP=L/NOREQ
	;
	;			Process logical used to define the startup
	;			file name to be executed by a jobbed process.
	;			If null, the utility uses the gtmenv file
	;			found in the current directory.
	;
	; RETURNS:
	;     . $$	0 if unsuccessful
	;		1 if successful
	;
	; EXAMPLE:
	;	S X=$$^%ZJOB("TAG^RTN",PRCNAM)
	;
	;---- Revision History ------------------------------------------------
	; 01/19/05 - RussellDS - CR14106
	;	     Add ability to handle variables that have values longer
	;	     than 1K.  For time being, up to 32K will be handled, due
	;	     to file record size limitations.  At some point, GT.M
	;	     should support passing entire symbol table without the
	;	     need to write and read from file.
	;
	;	     Add logic for connection to Oracle DB, if that is the
	;	     environment.
	;
	; 01/08/05 - RussellDS - CR13910
	;	     Modify name for .mje file to include more information now
	;	     that size limit under GT.M has been removed.
	;
	; 12/21/99 - Allan Mattson - 34824	
	;            Modified SYSVAR^SCADRV0 to call NOISO^SCAUTL.  This call
	;            invokes the "NoIsolation" feature in GT.M in order to
	;            improve system performance.
	;
	; 09/17/99 - Phil Chenard
	;            Modified the JOB command to increase the timeout from 5
	;            seconds to 60.  This addresses a problem when creating 
	;            the new process on a heavily loaded system takes more than
	;            5 seconds, resulting in a signal being sent when the timer
	;            goes off.  If the new process had not yet registered its
	;            signal handlers, receipt of a SIGALRM results in a 
	;            termination of the process.  The extra time will help 
	;            ensure that the new process can get started and initialize
	;            handlers before getting stopped by this signal.
	;
	;            Also remove the locking of JOBA name since it is no 
	;            longer needed since the primary Lock grabs a subscripted
	;            variable now.
	;
	; 03/05/99 - Allan Mattson
	;            Modified the incremental locks on named variables JOBA and
	;            JOBB to include the job number as the subscript.  This
	;            eliminates the possibility of a process failing to job
	;            one or more threads because another process owns the
	;            locks while it is jobbing one or more threads.
	;
	;            Removed pre-1997 revision history.
	;
        ; 12/04/98 - Phil Chenard
        ;            Modified NEWJOB section to open the file with a
        ;            record size=1024 to avoid data overrun problems.  Also
        ;            cleaned up some file management in order avoid GT.M 
        ;            limitations.
	;----------------------------------------------------------------------
	;
	;
	;----------------------------------------------------------------------
START	;Private;
	;----------------------------------------------------------------------
	;
	H 1		;Pause for a second to ensure unique name
	;
	; Create startup file as $$HOME^%TRNLNM("JOB.TMP_$J_SU")
	; Save symbol table to file $$HOME^%TRNLNM("JOB.TMP_$J_ZWR")
	;
	I $G(%zjobref)'["^" Q 0 		; Invalid new job reference
	S %zjobref=$$quote(%zjobref)		; Add quotes to string arguments
	S %znoload=$G(%znoload)
	;
	N $ZT
	S @$$SET^%ZT("ERROR^%ZJOB")
	;
	N %zjob,%zjoberr,%zjobf1,%zjobf2
	N %zjobfil,%zjobout,%zjobdir,%zjobsta,%zpar,%zpid
	;
	; Create start-up file with proper GTMENV as first element
	S %zjobsta=$$SCAU^%TRNLNM("GTMENV")
	S %zpid=$j
	;
	I %zjobsta'="" S %zjobsta=$ZPARSE(%zjobsta,"","","","NO_CONCEAL")
	E  S %zjobsta=$ZPARSE($$SCAU^%TRNLNM("DIR","gtmenv"),"","","","NO_CONCEAL")
	;
	S %zjobf1="JOB."_$E(%zpid,1,5)_$P($H,",",2)
	;
	O %zjobf1:(OWNER="RWX":NEWVERSION)
	U %zjobf1 W %zjobsta,!
	C %zjobf1
	;
	S %zjobf2=""
	S %zjobdir=$$SCAU^%TRNLNM("SPOOL")
	I %zjobdir="" S %zjobdir=$$HOME^%TRNLNM
	;
	S %zjobfil=$P($TR($P(%zjobref,"^",2),"%","_"),"(",1)
	;
	I ($P($ZVER,"GT.M V",2)<4.3)!((+$P($ZVER,"GT.M V",2)=4.3)&(+$P($ZVER,"-",2)<1)) S %zjoberr=$E(%zjobfil,1,5)_$P($H,",",2)_".mje"
	E  S %zjoberr=%zjobfil_"_"_$J_"_"_+$H_"_"_$P($H,",",2)_".mje"
	;
	S %zjobout="/dev/null"
	;
	; Redirect output based on the specification in the parameter list
	I $G(%zparams)["OUTPUT=" S %zjobout=$P($P(%zparams,"OUTPUT=",2),"/",1)
	;
	; Redirect error file based on specification in parameter list
	I $G(%zparams)["ERROR=" S %zjoberr=$P($P(%zparams,"ERROR=",2),"/",1)
	;
	; Build parameter list
	S %zpar="(ERROR="""_%zjoberr
	S %zpar=%zpar_""":OUTPUT="""_%zjobout_""""
	;
	; Under the GT.M implementation on Unix, process name has no value
	;I $G(%zparams)["PRO=" S %zpar=%zpar_":PRO="""_$P($P(%zparams,"PRO=",2),"/",1)_""""
	;
	S %zpar=%zpar_"):60"		;Increase timeout to 60 seconds
	;
	L +JOBB(%zpid):30 E  Q 0
	;
	I '%znoload D  I ER L -JOBB(%zpid) Q 0
	.	S ER=0
	.	S %zjobf2=$$HOME^%TRNLNM("JOB.TMP_"_%zpid_$P($H,",",2)_"_ZWR")
	.	O %zjobf2:(NEWV:RECORD=32767):1 E  S ER=1 Q
	.	U %zjobf2 D
	..		N %zjob,%zjobdir,%zjoberr,%zjobf1,%zjobf2,%znoload
	..		N %zjobout,%zpar,%zpid,%zparams,%zjobsta,%zjobref
	..		ZWR
	.	C %zjobf2
	;
	S %zjob="NEWJOB^%ZJOB("""_%zjobref_""","""_%zjobf1_""","""_%zjobf2_""","""_%zpid_""")"
	S %zjob=%zjob_":"_%zpar
	;
	J @%zjob E  D  Q 0
	.	N zio
	.	I $$VALID^%ZRTNS("UTLERR") D ZE^UTLERR
	.	S zio=$$HOME^%TRNLNM("ZJOBERR"_$J_".ERR")
	.	O zio:(NEWVERSION:RECORD=32767):5 E  Q
	.	U zio
	.	W "Error encountered in JOB Command -",!
	.	W $ZS,!!,"$ZROUTINES = ",$ZRO,!
	.	W !,"$ZGBLDIR = ",$ZGBLDIR,!
	.	W !,"ZSHOW - ",! ZSHOW "*"
	.	C zio
	.	L -JOBB(%zpid)
	;
	L -JOBB(%zpid)
	H 1
	;
	L +JOBB(%zpid):30 E  Q 0
	L -JOBB(%zpid)
	Q 1
	; 
	;----------------------------------------------------------------------
ERROR	; Error trap to here
	;----------------------------------------------------------------------
	;
	I $$VALID^%ZRTNS("UTLERR") D ZE^UTLERR
	I $G(%zjobf1)'="" C %zjobf1:DELETE
	I $G(%zjobf2)'="" C %zjobf2:DELETE
	L -JOBB(%zpid)
	Q 0				; Return failure
	;
	;
	;----------------------------------------------------------------------
NEWJOB(%zjobref,%zjobf1,%zjobf2,%zpid)	; Start new job here
	;----------------------------------------------------------------------
	;
	S $ZT="G NEWJOBER^%ZJOB"
	L +JOBB(%zpid)
	;
	O %zjobf1:(READ)
	C %zjobf1:DELETE
	;
	I $G(%zjobf2)'="" D				;Reload symbol table
	.	N ET
	.	O %zjobf2:(READ:RECORD=32767):1 E  Q
	.	U %zjobf2
	.	;
	.	F  S %zjobx=$$^%ZREAD(%zjobf2,.ET) Q:+ET=1  D
	..		I $L(%zjobx)<2048 S @%zjobx Q
	..		;
	..		; Handle indirection size limits
	..		N %zjobptr,%zjobtok,%zjobval,%zjobvar
	..		S %zjobx=$$TOKEN^%ZS(%zjobx,.%zjobtok,"")
	..		S %zjobptr=0
	..		S %zjobvar=$$ATOM^%ZS(%zjobx,.%zjobptr,"=",.%zjobtok)
	..		S %zjobvar=$$UNTOK^%ZS(%zjobvar,%zjobtok)
	..		S %zjobval=$E(%zjobx,%zjobptr+2,$L(%zjobx))
	..		S %zjobval=$$UNTOK^%ZS(%zjobval,%zjobtok)
	..		S @%zjobvar=$$QSUB^%ZS(%zjobval)
	.	C %zjobf2:DELETE
	.	U 0
	;
	L -JOBB(%zpid)
	;
	K %zjobf1,%zjobf2,%zjobx,%zpid
	;
	; Execute code for "NoIsolation" (supported in P/A V6.0 & GT.M V4.2)
	I $$VALID^%ZRTNS("SCAUTL") D NOISO^SCAUTL
        ;
        ; If appropriate, connect to Oracle DB
	S %zjobdb=$$TRNLNM^%ZFUNC("SCAU_DB")
	I %zjobdb="ORACLE" D
	.	N ER,INIPATH,RM
	.	S INIPATH=$$TRNLNM^%ZFUNC("SCAU_DB_INI")
	.	Q:INIPATH=""
	.	S ER=$$DBCNCT^%DBAPI(INIPATH,.index,.RM)
	.	I ER S $ZS="Error connecting to Oracle "_$G(RM) D NEWJOBER
	K %zjobdb
	;
	; Execute job
	D @%zjobref
	Q
	;
	;----------------------------------------------------------------------
NEWJOBER	; Error trap for new job
	;----------------------------------------------------------------------
	;
	I $$VALID^%ZRTNS("UTLERR") D ZE^UTLERR
	;
	S zio=$$HOME^%TRNLNM("ZJOBERR"_$J_".ERR")
	O zio:(NEWVERSION):5 E  H
	U zio
	;
	W "Error encountered during ^%ZJOB -",!
	W $G(%zjobref),!
	W $ZS,!!,"$ZROUTINES = ",$ZRO,!
	W !,"$ZGBLDIR = ",$ZGBLDIR,!
	W !,"ZSHOW - ",! ZSH
	W !,"ZWRITE - ",! ZWR
	H
	;
	;----------------------------------------------------------------------
quote(str)	; Private; Add double quotes
	;----------------------------------------------------------------------
	;
	;
	N x
	;
	S x=0
	F  S x=$F(str,$C(34),x) Q:x=0  D
	.	S str=$E(str,1,x-1)_$C(34)_$E(str,x,9999),x=x+1
	Q str	
