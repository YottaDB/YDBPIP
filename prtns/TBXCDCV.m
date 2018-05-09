TBXCDCV	;Private;Toolbox - Code coverage utilities
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/14/01 22:56:15 - RUSSELL
	; ORIG:	RUSSELL - 10/18/01 - ARQ 48301
	; DESC:	Code coverage utilities
	;
	; KEYWORDS:	Toolbox, QA, Testing
	;
	; To see documentation on the use of this utility, go to the DOC
	; section at the end of the routine, or D DOC^TBXCDCV to display it,
	;
	Q:'$$DISCLAIM^TBX	; Show disclaimer, see if want to continue
	;
	;----------------------------------------------------------------------
START	;Private; Menu of options
	;----------------------------------------------------------------------
	N (TBXCDCV)
	F  D  Q:VFMQ="Q"
	.	S OPTION(1)="Server data collection ON|SRVON"
	.	S OPTION(2)="Server data collection OFF|SRVOFF"
	.	S OPTION(3)="Batch data collection ON|BCHON"
	.	S OPTION(4)="Batch data collection OFF|BCHOFF"
	.	S OPTION(5)="ON for this process|PROCON"
	.	S OPTION(6)="OFF for this process|PROCOFF"
	.	S OPTION(7)="Generate HTML report|REPORT"
	.	S OPTION(8)="Aggregate data|AGGRGATE"
	.	S OPTION(9)="Clear collected data|CLEAR"
	.	S OPTION(10)="Display documentation|DOC"
	.	S OPTION=""
	.	S %TAB("OPTION")="/DES=Coverage option/TYP=N/LEN=2/TBL=OPTION("
	.	S hdr="Code Coverage Options"
	.	S %READ="@hdr/CEN,,OPTION/REQ"
	.	S %FRAME=1,%NOPRMT="F"
	.	D ^UTLREAD Q:VFMQ="Q"
	.	D @$P(OPTION(OPTION),"|",2)
	.	I $G(VFMQ)'="Q" W !!,"Press any key to continue" R *X
	.	E  S VFMQ=""
	;
	; Reset terminal after UTLREADs
	D TERM^%ZUSE(0,"ECHO/ESCAPE/EDIT/NOCHARACTERS/NOIMAGE/WIDTH=80/TERMINATOR=""""")
	W $$SCRAWON^%TRMVT				; Enable auto wrap
	Q
	;----------------------------------------------------------------------
SRVON	;; Turn coverage on for servers
	;----------------------------------------------------------------------
	;
	N (TBXCDCV)
	S SVTYP=$$gettype("Turn code coverage ON for servers",.MTM)
	I SVTYP="" Q
	S KEY=SVTYP
	I $G(MTM)'="" S KEY=KEY_"_"_MTM
	K ^TMP("TBXCDCV",KEY)
	S CMD="VIEW ""TRACE"":1:""^TMP(""""TBXCDCV"""","""""_KEY_""""",$J)"""
	S CNT=$$sendcmd(SVTYP,$G(MTM),CMD)
	W "Turned on for ",CNT," servers",!
	S TBXCDCV("ONKEY")=KEY				; Return for use by OFF
	Q 
	;
	;----------------------------------------------------------------------
SRVOFF	;; Turn coverage off for servers and consolidate
	;----------------------------------------------------------------------
	; Return DATAGLOB with reference to global where data is stored
	; to allow to be passed through to other sections
	N (TBXCDCV)
	S SVTYP=$$gettype("Turn code coverage OFF for servers",.MTM)
	I SVTYP="" Q
	S KEY=SVTYP
	I $G(MTM)'="" S KEY=KEY_"_"_MTM
	S CMD="VIEW ""TRACE"":0:""^TMP(""""TBXCDCV"""","""""_KEY_""""",$J)"""
	S CNT=$$sendcmd(SVTYP,$G(MTM),CMD)
	W "Turned off for ",CNT," servers",!
	I 'CNT Q
	S DATAGLOB="^TBXCDCV("""_KEY_""")"
	W "Wait one minute for servers to execute command",!
	H 65
	W "Merging data to dataset ",KEY," ... "
	K ^TBXCDCV(KEY)
	S GLOB=$E(DATAGLOB,1,$L(DATAGLOB)-1)
	S FROM="^TMP(""TBXCDCV"","""_KEY_""")"
	S LEN=$L(FROM)-1,STOP=$E(FROM,1,LEN)
	F  S FROM=$Q(@FROM) Q:$E(FROM,1,LEN)'=STOP  D
	.	S X=@FROM
	.	S TO=GLOB_","_$P(FROM,",",4,99)
	.	S Y=$G(@TO)
	.	F I=1:1:$L(X,":") S $P(Y,":",I)=$P(Y,":",I)+$P(X,":",I)
	.	S @TO=Y
	S ^TBXCDCV(KEY)=$ZD($H,"DD-MON-YEAR 12:60AM")
	W "done",!!
	K ^TMP("TBXCDCV",KEY)
	S TBXCDCV("DATAGLOB")=DATAGLOB		; Return for report
	Q 
	;
	;----------------------------------------------------------------------
BCHON	;; Turn on data collection for batch
	;----------------------------------------------------------------------
	; This option set ^tbxcdcv with the current date.  This will cause
	; all batch jobs run through the queuing system, including threads
	; of multi-threaded jobs, to collect coverage data.  The data will
	; be saved to ^tbxcdcv(seq) for each process when the process exits.
	;
	; When the coverage collection is turned off, the various collections
	; will be consolidated to ^TBXCDCV("BATCH_<seq>").
	;
	; The switch, ^tbxcdcv, is examined only by ^QUEPGM and ^JOBTHR.  
	; To avoid this switch being left on accidentally, if the date in the
	; switch is greater than 1 day old, data collection will not take
	; place.
	;
	; See codecov^QUEPGM for additional details.
	;
	N
	W $$CLEAR^%TRMVT
	S X=$G(^tbxcdcv)
	I +X=+$H,$D(^tbxcdcv)>9 D  Q:quit
	.	S quit=0
	.	W !!,"Flag already set for today, and collection is data present."
	.	W !!,"Continuing will remove existing collection data."
	.	R !!,"Continue?  N=> ",X
	.	S X=$TR(X,"yes","YES")
	.	I '(X="Y"!(X="YES")) D
	..		W !!,"Not deleted"
	..		S quit=1
	K ^tbxcdcv
	S ^tbxcdcv=$H_"|^tbxcdcv"
	;
	W !!,"Turned on for batch.  Note that this option only works for batch"
	W !,"processing run through the queuing system."
	W !!,"Remember to turn off after batch runs are complete to consolidate"
	W !,"data.  For any batch processes started directly, be sure to exit"
	W !,"from M prior to turning collection off in order to save data for"
	W !,"that process.",!
	Q
	;
	;----------------------------------------------------------------------
BCHOFF	;; Turn off data collection for batch and consolidate data
	;----------------------------------------------------------------------
	N (TBXCDCV)
	W $$CLEAR^%TRMVT
	I '$D(^tbxcdcv) D  Q
	.	W !,"Batch coverage collection not turned on"
	S CNT=$O(^tbxcdcv(""),-1)
	I 'CNT D  Q
	.	W !,"No data has been collected."
	.	R !!,"Do you still want to turn off?  Y=> ",X
	.	S X=$TR(X,"yes","YES")
	.	I (X=""!(X="Y")!(X="YES")) K ^tbxcdcv
	;
	W !,"Data collected on ",CNT," process",$S(CNT=1:"",1:"es"),"."
	W !!,"Be sure all batch jobs have completed and any processes started directly"
	W !,"have been exited from M."
	R !!,"Continue?  Y=>  ",X
	S X=$TR(X,"yes","YES")
	Q:'(X=""!(X="Y")!(X="YES"))
	;
	; Get key for accumulated data, key format is BATCH_nnnn (n zero padded)
	S X=$O(^TBXCDCV("BATCH_A"),-1)
	I X'?1"BATCH_".E S KEY="BATCH_0001"
	E  D
	.	S SEQ=$P(X,"_",2)+1
	.	I SEQ<9999 S KEY="BATCH_"_$E(10000+SEQ,2,5)
	.	E  S KEY="BATCH_"_SEQ
	;
	S DATAGLOB="^TBXCDCV("""_KEY_""")"
	W !!,"Merging data from ",CNT," process",$S(CNT=1:"",1:"es")
	W " to dataset ",KEY," may take a moment",!
	K ^TBXCDCV(KEY)
	S GLOB=$E(DATAGLOB,1,$L(DATAGLOB)-1)
	S FROM="^tbxcdcv"
	F  S FROM=$Q(@FROM) Q:FROM=""  D
	.	Q:FROM'[","			; Process level - ignore
	.	S X=@FROM
	.	S TO=GLOB_","_$P(FROM,",",2,99)
	.	S Y=$G(@TO)
	.	F I=1:1:$L(X,":") S $P(Y,":",I)=$P(Y,":",I)+$P(X,":",I)
	.	S @TO=Y
	S ^TBXCDCV(KEY)=$ZD($H,"DD-MON-YEAR 12:60AM")
	K ^tbxcdcv
	W !,"Done",!!
	S TBXCDCV("DATAGLOB")=DATAGLOB		; Return for report
	Q
	;
	;----------------------------------------------------------------------
PROCON	;; Turn coverage data collection on for this process
	;----------------------------------------------------------------------
	N
	; Check to see if already on and clean up old data
	S (N,NAME)=""
	F  S N=$O(^TBXCDCV(N)) Q:N=""  D  Q:NAME'=""
	.	S X=^TBXCDCV(N)
	.	S JOB=$P(X,"|",2)
	.	Q:JOB=""
	.	I $D(^TBXCDCV(N))>9 D  Q  		; Clean up old $J's
	..		S $P(X,"|",2)=""
	..		S ^TBXCDCV(N)=X
	.	Q:JOB'=$J				; Not this process
	.	S NAME=N,DESC=$P(X,"|",1)
	.	W !,"Already turned on for dataset ",NAME," - ",DESC,!
	Q:NAME'=""
	;
	S %TAB("NAME")="/DES=Dataset name/TYP=T/LEN=20/XPP=D PROCON1^TBXCDCV"
	S %TAB("DESC")="/DES=Description/TYP=T/LEN=40"
	S hdr="Turn code coverage data collection on for this process"
	S %READ="@hdr/CEN,,NAME/REQ,DESC"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD Q:VFMQ="Q"
	;
	I DESC="" S DESC=$ZD($H,"DD-MON-YEAR 12:60AM")
	; Note:  Save $J to use to check if on when trying to turn off
	S ^TBXCDCV(NAME)=DESC_"|"_$J
	VIEW "TRACE":1:"^TBXCDCV("""_NAME_""")"
	W !!,"Turned on for this process to dataset ",NAME,"."
	W !!,"Data will not move to dataset until you turn collection off for this"
	W !,"process or exit M."
	Q
	;
PROCON1	; Post processor on NAME
	I $D(^TBXCDCV(X)) S ER=1,RM="Name already exists"
	Q
	;
	;----------------------------------------------------------------------
PROCOFF	;; Turn coverage data collection off for this process
	;----------------------------------------------------------------------
	N
	S (N,NAME)=""
	F  S N=$O(^TBXCDCV(N)) Q:N=""  D  Q:NAME'=""
	.	S X=^TBXCDCV(N)
	.	S JOB=$P(X,"|",2)
	.	Q:JOB'=$J
	.	I $D(^TBXCDCV(N))>9 D  Q  		; Clean up old $J's
	..		S $P(X,"|",2)=""
	..		S ^TBXCDCV(N)=X
	.	S NAME=N
	I NAME="" D  Q
	.	W !,"Data collection not on for this process."
	.	W !!,"If you exited M after turning it on, the data should be in"
	.	W !,"the dataset you selected."
	;
	VIEW "TRACE":0:"^TBXCDCV("""_NAME_""")"
	W !!,"Data collection turned off.  Data is in dataset ",NAME
	S $P(^TBXCDCV(NAME),"|",2)=""			; Remove $J
	Q
	;
	;----------------------------------------------------------------------
REPORT	;; Generate code coverage report info to HTML format
	;----------------------------------------------------------------------
	; Data always in ^TBXCDCV(dataset)
	N (VFMQ,TBXCDCV)
	S DATAGLOB=$G(TBXCDCV("DATAGLOB"))
	I $G(DATAGLOB)'="" S DATASET=$$QSUB^%ZS($P($P(DATAGLOB,"(",2),")",1))
	E  S DATASET=""
	S len=$$getdsets(.OPTS)			; Get datasets
	I 'len W "No code coverage datasets available" Q
	S N=""
	F  S N=$O(OPTS(N)) Q:N=""  I $P(OPTS(N),"|",2)=DATASET S ID=N
	S %TAB("ID")="/DES=From dataset/TYP=N/LEN="_len_"/TBL=OPTS("
	S %TAB("OUTDIR")="/DES=To directory/TYP=T/LEN=40/XPP=D PROCRPT^TBXCDCV"
	S hdr="Generate HTML Reporting from Code Coverage Data"
	S %READ="@hdr/CEN,,ID/REQ,OUTDIR/REQ"
	I $G(ID) D
	.	S trailer="Dataset ID "_ID_" is for dataset "_DATASET
	.	S %READ=%READ_",,@trailer/CEN"
	S OUTDIR=$$SCAU^%TRNLNM("SPOOL")  		; Default to spool
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD Q:VFMQ="Q"
	S DATASET=$P(OPTS(ID),"|",2)
	I $D(^TBXCDCV(DATASET))<9 D  Q
	.	W !,"No data collected in dataset ",DATASET
	D ^TBXCDCVR("^TBXCDCV("""_DATASET_""")",OUTDIR)
	Q
	;
PROCRPT	; Post processor on directory
	Q:X=""
	D ^%ZCHKDIR
	Q
	;
	;----------------------------------------------------------------------
AGGRGATE	;; Aggregate data from one dataset into another
	;----------------------------------------------------------------------
	N (VFMQ)
	S len=$$getdsets(.OPTS)
	I 'len W "No code coverage datasets available" Q
	S %TAB("FROMID")="/DES=From dataset/TYP=N/LEN="_len_"/TBL=OPTS("
	S %TAB("TOID")="/DES=To existing dataset/TYP=N/LEN="_len_"/TBL=OPTS(/XPP=D AGGRPP1^TBXCDCV"
	S %TAB("NEW")="/DES=Or to new dataset/TYP=T/LEN=20/XPP=D AGGRPP2^TBXCDCV"
	S %TAB("DESC")="/DES=New dataset description/TYP=T/LEN=40"
	S hdr="Aggregate Code Coverage Datasets"
	S %READ="@hdr/CEN,,FROMID/REQ,,TOID/NOREQ,NEW,DESC"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD Q:VFMQ="Q"
	S FROMDS=$P(OPTS(FROMID),"|",2)
	I NEW'="" D
	.	I DESC="" S DESC=$ZD($H,"DD-MON-YEAR 12:60AM")
	.	S ^TBXCDCV(NEW)=DESC
	.	S TODS=NEW
	E  S TODS=$P(OPTS(TOID),"|",2)
	S TO="^TBXCDCV("""_TODS_""""
	S FROM="^TBXCDCV("""_FROMDS_""")"
	S LEN=$L(FROM)-1,STOP=$E(FROM,1,LEN)
	F  S FROM=$Q(@FROM) Q:$E(FROM,1,LEN)'=STOP  D
	.	S X=@FROM
	.	S TOREF=TO_","_$P(FROM,",",2,99)
	.	S Y=$G(@TOREF)
	.	F I=1:1:$L(X,":") S $P(Y,":",I)=$P(Y,":",I)+$P(X,":",I)
	.	S @TOREF=Y
	W !!,"Complete.  Delete dataset ",FROMDS,"?  Y=> " R X
	S X=$TR(X,"yes","YES")
	I '(X=""!(X="Y")!(X="YES")) D
	.	W !!,"Not deleted"
	E  D
	.	K ^TBXCDCV(FROMDS)
	.	W !!,"Deleted"
	Q
	;
AGGRPP1	; Post-processor on TOID
	I FROMID=X S ER=1,RM="Cannot be same dataset as 'From dataset'"
	I X'="" S NI=99				; Skip other fields
	Q
	;
AGGRPP2	; Post-processor on NEW
	I TOID="",X="" S ER=1,RM="Must select existing dataset or create new onw"
	I TOID'="",X'="" S ER=1,RM="Can only select existing dataset OR create new one"
	Q
	;
	;----------------------------------------------------------------------
CLEAR	;; Delete collected data from a selected dataset
	;----------------------------------------------------------------------
	N (VFMQ)
	S len=$$getdsets(.OPTS)
	I 'len W "No code coverage datasets available" Q
	S %TAB("ID")="/DES=Delete dataset/TYP=N/LEN="_len_"/TBL=OPTS("
	S hdr="Delete Code Coverage Dataset"
	S %READ="@hdr/CEN,,ID/REQ"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD Q:VFMQ="Q"
	S DATASET=$P(OPTS(ID),"|",2)
	W !!,"Confirm deletion of dataset ",DATASET,"?  N=>  " R X
	S X=$TR(X,"yes","YES")
	I '(X="Y"!(X="YES")) D
	.	W !!,"Not deleted"
	E  D
	.	K ^TBXCDCV(DATASET)
	.	W !!,"Deleted"
	Q
	;
	;----------------------------------------------------------------------
getdsets(list)	;Private; Get list of datasets for selection
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. list	Dataset list		/TYP=ARRAY/MECH=REF:W
	;
	; RETURNS:
	;	. $$	Length of index		/TYP=N
	;
	N desc,i,n
	S n=""
	F i=1:1 S n=$O(^TBXCDCV(n)) Q:n=""  D
	.	S desc=$P($G(^TBXCDCV(n)),"|",1)
	.	S list(i)=$E(n_$J("",20),1,20)_" "_desc_"|"_n
	Q $L($O(list(""),-1))
	;
	;----------------------------------------------------------------------
gettype(hdr,mtm)	;Private; Get server type and MTM
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. hdr	header for screen	/TYP=T/NOREQ/MECH=VAL
	;
	;	. mtm	MTM to use		/TYP=T/NOREQ/MECH=REF:W
	;		Allows specification of only
	;		a single MTM to use
	;
	; RETURNS:
	;	. $$	server type		/TYP=T
	;		Null if none selected
	;
	N (hdr,mtm,TBXCDCV)
	S %TAB("SVTYP")="/DES=Server type/TYP=T/LEN=12/TBL=[CTBLSVTYP]"
	S %TAB("MTM")="/DES=Limit to MTM/TYP=T/LEN=20/TBL=[CTBLMTM]"
	I $G(hdr)'="" S %READ="@hdr/CEN,,"
	S %READ=$G(%READ)_"SVTYP/REQ,MTM/NOREQ"
	S ONKEY=$G(TBXCDCV("ONKEY"))
	I ONKEY'="" S SVTYP=$P(ONKEY,"_",1),MTM=$P(ONKEY,"_",2)
	E  S SVTYP="SCA$IBS"
	;
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q" Q ""
	I MTM="ALL"!(MTM="") S mtm=""
	E  S mtm=MTM
	Q SVTYP
	;
	;----------------------------------------------------------------------
sendcmd(svtyp,mtm,cmd)	;Private; Send command to servers of type indicated
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. svtyp	Server type		/TYP=T/REQ/MECH=VAL
	;
	;	. mtm	Limit to this mtm	/TYP=T/NOREQ/MECH=VAL
	;
	;	. cmd	Command to send		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	Number of servers	/TYP=N
	;
	N (cmd,mtm,svtyp)
	S cnt=0,svid=""
	F  S svid=$O(^SVCTRL(svtyp,svid)) Q:svid=""  D
	.	I $G(mtm)'="",$P($P(^SVCTRL(svtyp,svid),"|",1),"_",2)'=mtm Q
	.	D EXEC^PBSUTL(svtyp,svid,cmd)
	.	S cnt=cnt+1
	Q cnt
	;
	;----------------------------------------------------------------------
batchck	;Private;Turn on code coverage collection if requested
	;----------------------------------------------------------------------
	; This sub-routine is called only from ^QUEPGM and ^JOBTHR to determine
	; if code coverage has been turned on for batch, and if so, to
	; activate it.
	;
	; Coverage data collection during batch processing is requested by
	; the presence of ^tbxcdcv=$h|^global, where $h is the time that
	; the request was made, and global is the global to which the data
	; should be collected.
	;
	; If the current day is greater than one day from the request date, 
	; collection will not occur.  This prevents the switch from being set 
	; and left on by accident.
	;
	; Data will be collected to ^global(seq), where seq is the next
	; available sequence number in order to avoid processes overlaying
	; each other's data.  global must be of the form of an unsubscripted
	; global.  The standard global that will be used is ^tbxcdcv.  Data
	; will be written to the specified global when the process exits M.  
	; The collected data is consolidated through an internal Sanchez 
	; utility (^TBXCDCV) when the coverage collection is turned off.
	;
	N $zt
	S $zt="q"					; If error, just give up
	N glob,globref,reqdate,seq,x
	S x=$G(^tbxcdcv) Q:x=""				; Switch not on
	S reqdate=+$P(x,"|",1),glob=$P(x,"|",2)
	Q:+$h>(reqdate+1)				; Date too old
	L +@glob
	S globref=glob_"("""")"
	S seq=$O(@globref,-1)+1
	; Note that seq must be a literal in the globref string for the view
	S globref=glob_"("_seq_")"
	S @globref=$h_"|"_$j
	L -@glob
	VIEW "trace":1:globref
	Q
	;
	;----------------------------------------------------------------------
DOC	;Private; Display documentation
	;----------------------------------------------------------------------
	N (VFMQ)
	S hdr="Display TBXCDCV utility documentation"
	D DOCPRINT^TBX("DOCTEXT^TBXCDCV",hdr)
	Q
	;
DOCTEXT	;Note that line are not tabbed to improve readability in the code
	; Documentation for code coverage toolbox utility TBXCDCV 
	; 
	; Accessing the routine from the top, D ^TBXCDCV, will display a disclaimer 
	; and then provide access to the menu options.  To avoid the disclaimer 
	; D START^TBXCDCV, which will directly access the menu options. 
	; 
	; Menu options are as follows: 
	; 
	;     Option  1 - Server data collection ON 
	;     Option  2 - Server data collection OFF 
	;     Option  3 - Batch data collection ON 
	;     Option  4 - Batch data collection OFF 
	;     Option  5 - ON for this process 
	;     Option  6 - OFF for this process 
	;     Option  7 - Run report 
	;     Option  8 - Aggregate data 
	;     Option  9 - Clear collected data 
	;     Option 10 - Print this documentation 
	; 
	; What each option does is listed below. 
	; 
	; Server data collection ON: 
	; 
	;     Allows you to specify a server type and associated MTM and turns on  
	;     data collection. 
	; 
	;     Data is collected to ^TMP("TBXCDCV",server_mtm_key,$J). 
	; 
	; Server data collection OFF: 
	; 
	;     Allows you to specify a server type and associated MTM and turns off 
	;     data collection. 
	; 
	;     If you haven't exited from M and haven't done anything to kill your  
	;     symbol table, the server type and MTM used to turn on will default in  
	;     the prompts.  On completion of this option, the data that has been  
	;     collected in ^TMP will be consolidated into ^TBXCDCV(server_mtm_key). 
	; 
	; Batch data collection ON: 
	; 
	;     Sets up a flag at the top level of global ^tbxcdcv.  This will signal 
	;     to QUEPGM and JOBTHR to turn on the collection.  Each process will save  
	;     its data in a unique sequence in ^tbxcdcv(seq). 
	; 
	;     There is a check to prevent leaving this on for too long.  The switch  
	;     has a date associated with it, and if the date is over one day old,  
	;     batches won't turn collection on. 
	; 
	;     This form of collection only works for jobs that run through the queuing  
	;     system. 
	; 
	;     Processes write their data to ^tbxcdcv when they exit M, so there is no 
	;     need to turn off collection for specific processes in batch. 
	; 
	; Batch data collection OFF: 
	; 
	;     Turns off the flag and consolidates all the various process data into  
	;     ^TBXCDCV("BATCH_nnnn") 
	; 
	; ON for this process: 
	; 
	;     Allows you to specify a dataset name and turns on collection. 
	;     Collection will continue until the off option is used or you exit M.  No  
	;     data will show in the dataset until one of those is done. 
	; 
	; OFF for this process: 
	; 
	;     If collection has been turned on for this process, this will turn it off  
	;     and move the collected data into the dataset. 
	; 
	; Run report: 
	; 
	;     Will run the HTML generation for the dataset you specify. 
	; 
	;     If you haven't exited from M and haven't done anything to kill your  
	;     symbol table, the dataset ID will default to the one used in the ON/OFF 
	;     options. 
	; 
	; Aggregate data: 
	; 
	;     Allows you to merge one dataset into another. 
	; 
	;     Will prompt for a 'from' dataset and a 'to' dataset.  You may choose a 
	;     'to' dataset that already exists or create a new (empty) one.  The data 
	;     from the 'from' dataset will be added to the 'to' dataset.  At the end, 
	;     you'll have an option to delete the 'from' dataset. 
	; 
	; Clear collected data: 
	; 
	;     Allows removal of a dataset. 
	; 
	;     After selection of the dataset to remove, there will be a confirmation 
	;     prompt.  If OK, the dataset will be deleted from ^TBXCDCV. 
	; 
	; Print this documentation: 
	; 
	;     As it indicates, allows you to print this documentation, to the device 
	;     of your choice. 
	; 
	; 
	; Note that all datasets are stored in the global ^TBXCDCV, other then during 
	; the server collection where they are temporarily in ^TMP, and during batch 
	; colleciton where they are stored in ^tbxcdcv 
	; $$EOF 
