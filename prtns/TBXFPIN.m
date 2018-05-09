TBXFPIN	;;	Profile Software Installation Driver
	;
	; Original: Jim Joyce - 05/10/2001
	;
	; This routine is responsible for loading Service and Fix
	; Packs into a Profile runtime environment.
	;
	;--------- Revision History ------------------------------------------
	; 01/18/2007	KWANL
	;		Fixed undefined error.
	;
	; 03/01/2007	KWANL
	;		Update EXT to be an external entry point.
	;
	; 09/28/2006	KWANL
	; 		Fixed unedfined error in SFLOOP
	;
	; 07/06/2006	KWANL
	;		Fixed spelling in SQLLOOP.
	;
	; 06/28/2006	KWANL
	;		Per Badri changed the SQL plus options.
	;
	; 05/04/2006	KWANL
	;		Modified SQLLOOP section to re-compile scripts after the install.
	;	
	; 05/03/2006	KWANL
	;		Added code to recompile stored procedures if there are
	;		schema changes
	;
	; 04/26/2006	KWANL
	;		Reset ER and RM in ELLOOP, GBLOOP, and SFLOOP.
	;
	; 04/20/2006	KWANL
	;		Per Rick S. remove all locks when installation is done.
	;
	; 03/24/2006	KWANL
	;		Modified COPYINST section to remove check in TBXREJ global
	;		before filing to TBXFIX global
	;
	; 02/09/2006	KWANL
	;		Added SQLLOOP section to handle sql scripts file. Modified
	;		OBSLOOP section to handle the obsolete of the sql scripts fie.
	;
	; 02/06/2006	KWANL
	;		Modified LOAD section to log SQL related error to a different file
	;
	; 01/16/2006	KWANL
	;		Enable table constraints when all *.dat files are loaded.
	;
	; 01/05/2006    KWANL
	;               Increased the record size from default 512 to 1024 in 
	;               READFILE section. 
	;
	; 01/04/2006	KWANL
	;		Postponed the call to TBXDQINT after m routines are installed.
	;
	; 10/20/2005	KWANL
	;		Combined the LOADGTM and LOADDBI back to LOAD.
	;
	; 10/19/2005	KWANL
	;		Added a call to OBSTABLE^TBXSQL after the call OBSLOOP
	;		in LOADDBI section. 
	;
	; 10/18/2005	KWANL
	;		Added a call to CRTABLE^TBXSQL to install new table after TBLLOOP
	;		for RDB environment.
	;		Removed the COMPFIL^TBXDQUTL call.
	;
	; 06/09/2005	Lik Kwan
	;		Broke the LOAD section into 2: LOADGTM and LOADDBI with 
	;		different element loading order depends on the profile version.
	;		Removed previous changes on 04/26/2005. The program used folder 
	;		to deterimine what to load instead of file extension. However the 
	;		TYPEINIT section still need to initialize the new type for lookup in
	;		REJECT section.
	;
	; 04/26/2005	MBUIM CR 14804
	;		Modified TYPEINIT section to include type "DAT" for 
	;		profile version 7.0. Also modified Load section to
	;		load new data format
	;
	; 08/11/2004	Lik Kwan
	;		Quit if the file about to load matches the file revision in ^TBXFIX in FIXPACK section.
	;
	; 08/11/2004	Lik Kwan
	;		New variable CODE in REJECT section.
	;		Write previous fix pack not fully loaded to screen if the previous fix pack 
	;		did not load successfully. (ie piece 4 in TBXFIX is 1).
	;
	; 02/09/2004	Lik Kwan
	;		Fixed error in FIXPACK
	;
	; 01/21/2004	Lik Kwan
	;		Fixed undefined error in FIXPACK.
	;
	; 12/22/2003	Lik Kwan
	;		Modified to allow M routine to be installed to a different 
	;		directory. The default is MRTNS. Fixed call to REJECT so that
	;		information will be captured in the ^TBXREJ global correctly.
	;
	; 08/26/2003	Terrie Dougherty
	;		Moved call to COPYINST to prevent ^TBXFIX from being 
	;		killed and not rebuilt.
	;
	; 05/28/2003	Lik Kwan
	;		Replace %ZCHKDIR with a local call CHKDIR.
	;		Reorganize EXT section
	;
	; 02/12/2003	Lik Kwan
	;		Added code to check ^dbtbl. if it doesn't exist, exit installation
	;		Added logic to check directory in GETDIRS section
	;
	; 02/03/2003	Lik kwan
	;		Added ^TBXLOAD global and additional installation info in ^TBXREJ.
	;
	; 10/29/2002	Lik Kwan
	;		Fixed undefined variables problem: ISVMS
	;
	; 10/7/2002	Lik kwan
	;		Added a post processor in the lookup table to prevent
	;		first column being truncated.
	;
	; 08/21/2002	Lik kwan
	;		Modified to handle VMS environment.
	;
	;---------------------------------------------------------------------
	;
	;---------------------------------------------------------------------
FPINST	; Fix Pack Install Prompt
	;---------------------------------------------------------------------
	; Fix Pack Directory - The directory where the Fix Pack has been 
	;	unzipped to. This will be a common directory for 
	;	each server. At Sanchez, the release directory will be an 
	;	NFS mount to the release directory on Silvar (a Solaris 
	;	server) plus the unique fix pack directory.
	; Percent Routine Directory - This is the directory where percent 
	;	routines will be loaded.
	; Overwrite Customized DQ Elements - If Yes, the installation program will 
	;	prompt the user to skip the item when a customized DATA QWIK 
	;	element is about to be overwritten. If No, all customized 
	;	items will be overwritten without prompting.
	;
	; Display warning page
	D WARN
	;
	N %READ,%TAB,HDG,INSTDIR,PCNTDIR,OWCUST,$ZT,ok,zlogf,ISVMS,INSTBUILD,DIRLIST,FP,RTNDIRS,RTNDIR,db,dqv,dqvn7,initEnv
	;  
	S HDG="Install Fix Pack"
	;
	S INSTDIR="/profile_release/fp",RTNDIR="MRTNS"
	S ISVMS=($P($ZVER," ",3)="VMS")
	S:ISVMS INSTDIR="PROFILE$RELEASE:[FP]"
	S RTNDIRS("CRTNS")=""
	S RTNDIRS("MRTNS")=""
	S RTNDIRS("PRTNS")=""
	S RTNDIRS("SRTNS")=""
	S RTNDIRS("ZRTNS")=""	
	;
	S PCNTDIR=""
	S OWCUST=0
	;
	S %TAB("INSTDIR")=".INSTDIR/REQ/DES=Fix Pack Directory/TYP=T/LEN=80/XPP=D GETDIRS^TBXFPIN(X,.DIRLIST)"
	S %TAB("FP")=".INSTBUILD/REQ/DES=Fix Pack to install/TYP=T/LEN=80/TBL=DIRLIST(/XPP=S X=$$FPDIRS^TBXFPIN(X,.DIRLIST)"
	S %TAB("PCNTDIR")=".PCNTDIR/REQ/DES=Percent Routine Directory/TYP=T/LEN=80/XPP=D CHKDIR^TBXDQUTL(X)"
	S %TAB("RTNDIR")=".RTNDIR/REQ/DES=Directory to install M routines/TYP=T/LEN=40/TBL=RTNDIRS("
	S %TAB("OWCUST")=".OWCUST/REQ/DES=Overwrite Customized DQ Elements/TYP=L/LEN=1"
	S %READ="@HDG/CEN/REV,,,INSTDIR,FP,PCNTDIR,RTNDIR,OWCUST"
	D ^UTLREAD
	I VFMQ="Q" Q
	;
	D EXT(INSTDIR,FP,PCNTDIR,OWCUST,RTNDIR)
	D CLEAN
	;
	Q
	;
	;---------------------------------------------------------------------
EXT(INSTDIR,FP,PCNTDIR,OWCUST,RTNDIR)	; External entry point
	;---------------------------------------------------------------------
	;
	N CURCR,CURPROJ,CURVIEW,NEWPROJ,NEWVIEW,NEWBL,PVB,PACKTYPE,ISNFS
	;
	d init
	; 
	I ER W !,RM,! Q:ER 
	;
	I '$D(^dbtbl) D  Q
	.	W !,"Abort! Global ^dbtbl is necessary for proper software installation.  It is not present in the run-time environment.  Please contact your Sanchez Client Support Analyst for information.",!
	;
	; If on vms, check if the disk is NFS mounted. (check if there is
	; a logical define for this directory which contains "NFS")
	;
	;
	S ISNFS=0
	I (ISVMS)&($ZTRNLNM($P(INSTDIR,":",1))["NFS") S ISNFS=1
	;
	S INSTDIR=$$appdir^TBXDQUTL(INSTDIR,"["_FP_"]")
	;
	S PACKTYPE=2
	;
	D CLEAN
	;
	s zlogf=$$SCAU^%TRNLNM("SPOOL","INST_"_$J_".LOG")			; log file	
	d LOGF^TBXDQUTL(.zlogf,"WRITE/NEWV")
	d logmsg^TBXDQUTL("Name of log file: "_zlogf,zlogf)
	;
	; Find last build loaded info.
	D GETCUR(.CURPROJ,.CURVIEW,.CURBLD) Q:ER
	;
	; Parse Release Directory to identify the project, view and build 
	; number (or CR number if it is a fix pack)
	D GETCONT(INSTDIR,.PVB,ISVMS,ISNFS) Q:ER
	;
	I '$D(^TMP($J)) D  Q
	.	S ER=1
	.	S RM="Can not find fix pack in "_INSTDIR_"." 
	;
	D logmsg^TBXDQUTL("Begin installation of CR "_PVB("CR"),zlogf)
	;
	; Install Started
	S $P(^TBXFIX,"|",4)=1
	;
	D LOAD(INSTDIR,.PVB,OWCUST,ISVMS,ISNFS,RTNDIR)
	I ER D ERROR Q
	;
	D COPYINST(.PVB)
	S ^TBXLOAD("FP",PVB("CR"),$P(%LOGID,"|",2),+$H,$P($H,",",2))=""
	;
	; Compile all loaded elements
	D COMPALL^TBXDQUTL
	I ER D ERROR Q
	;
	S $P(^TBXFIX,"|",4)=0
	S ER="W",RM="Installation of fix pack "_PVB("CR")_" completed"
	;
	D logmsg^TBXDQUTL($G(RM),zlogf)
	;
	c zlogf
	;
	Q
	;
	;---------------------------------------------------------------------
CLEAN	; Cleanup potentail left-overs
	;---------------------------------------------------------------------
	;
	S ER=0
	K ^TMP($J),^TMPDQS($J),TMPSQL($J)
	I $D(zlogf),zlogf'=0 c zlogf		; close log file, if it is open
	l
	;
	Q
	;
	;---------------------------------------------------------------------
GETCUR(CURPROJ,CURVIEW,CURCR)	; Get previous build info from environment
	;---------------------------------------------------------------------
	;
	N PROCFLAG
	;
	S CURPROJ=$P($G(^TBXFIX),"|",1)
	S CURVIEW=$P($G(^TBXFIX),"|",2)
	S CURCR=$P($G(^TBXFIX),"|",3)
	S PROCFLAG=$P($G(^TBXFIX),"|",4)
	;
	; Check the processing flag on the last build
	;	processing flag: 0 - Complete
	;			 1 - Started
	;			 2 - Fatal error during load
	;
	I PROCFLAG S ER=1 D logmsg^TBXDQUTL("Previous fix pack "_CURCR_" not fully loaded.",zlogf) Q
	;
	D logmsg^TBXDQUTL("Previous Fix Pack Loaded: "_CURCR,zlogf)
	;
	Q
	;
	;---------------------------------------------------------------------
GETCONT(INSTDIR,PVB,ISVMS,ISNFS)	; Read build contents file
	;---------------------------------------------------------------------
	;
	N IO,REC,HEADER,X,CRFILE
	S CRFILE="CR_contents.txt"
	S:(ISVMS&ISNFS) CRFILE=$$NFSVMS^TBXDQUTL(CRFILE)
	S IO=INSTDIR_CRFILE
	;
	; A custom header is prepended to the pack contents file
	; during deployment.
	;
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q
	;
	U IO
	I $ZEOF U 0 S ER=1,RM=IO_" file missing"
	R HEADER
	S PVB("PROJECT")=$E(($P(HEADER,"|",1)),2,$L($P(HEADER,"|",1)))
	S PVB("VIEW")=$P(HEADER,"|",2)
	S PVB("CR")=$P(HEADER,"|",3)				; get CR #
	S ^TMP($J)=PVB("PROJECT")_"|"_PVB("VIEW")_"|"_PVB("CR")
	;
	N FILE,USER,DATE,TIME,REVISION,TYPE
	;
	U IO
	F  Q:$ZEOF  R REC D
	.	I REC="" Q
	.	I REC=$C(13) Q
	.	S FILE=$P(REC,"|",1)
	.	S TYPE=$P(FILE,".",2)
	.	S FOLDER=$P(REC,"|",2)
	. 	I FOLDER'="obsolete" D
	..		I (TYPE="COL")!(TYPE="TBL") S FOLDER="table"
	.	S REVISION=$P(REC,"|",3)
	.	D UNMASK($$TRIM^%ZS($P(REC,"|",4)),.DATE,.TIME)
	.	S USER=$$TRIM^%ZS($P(REC,"|",5))
	.	I (ISVMS)&((FOLDER["unix")!(FOLDER["uxscrpt")) Q	; if platform is vms, don't load unix stuff	
	.	I ('ISVMS)&((FOLDER["vms")!(FOLDER["com")) Q		; if platform is unix, don't load vms stuff
	.	S ^TMP($J,"LOAD",FOLDER,FILE)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER_"|"_+$H_"|"_PVB("CR")
	;
	U 0
	C IO
	Q
	;
	;---------------------------------------------------------------------
PROMPT(MESSAGE)	; Call Yes/No prompt
	;---------------------------------------------------------------------
	;
	Q $$YN^DBSMBAR(0,MESSAGE)
	;
	;---------------------------------------------------------------------
OWPROM(FILE,DATE,USER)	; Overwrite prompt
	;---------------------------------------------------------------------
	;
	N MSG
	D logmsg^TBXDQUTL(FILE_" has been customized by "_USER_" on "_$$^%ZD(DATE)_".",zlogf)
	S MSG=" Overwrite with new version?"
	Q $$PROMPT(MSG)
	;
	;---------------------------------------------------------------------
LOAD(INSTDIR,PVB,OWCUST,ISVMS,ISNFS,RTNDIR)	
	;---------------------------------------------------------------------
	;
	N TYPES,FOLDER
	;
	; Build file type information array
	D TYPEINIT(.TYPES)
	;
	; Obsolete elements
	D OBSLOOP
	D:db'="GTM" OBSTABLE^TBXSQL		; obsolete table or column from RDB
	;	
	; Load routines
	D RTNLOOP(OWCUST,ISVMS,ISNFS,RTNDIR)
	;
	; Load system files
	D SFLOOP(ISVMS,ISNFS)	
	;
	; setup a temp global for PSL and Framework elements
	D ^TBXDQINT	
	;
	; install M global first
	D GBLLOOP("G",OWCUST,.TYPES,ISVMS,ISNFS,"G")
	;	
	; Load table and column definitions
	D TBLLOOP(OWCUST,ISVMS,ISNFS)
	D:db'="GTM" CRTABLE^TBXSQL,MODIFYTB^TBXSQL,regnproc^TBXSQL	; create tables in RDB	
	;
	; Load data files to relational db.
	D GBLLOOP("G",OWCUST,.TYPES,ISVMS,ISNFS,"DAT")	
	d eConstrt^TBXSQL
	;
	D SQLLOOP(OWCUST,ISVMS,ISNFS)
	;
	; Load remaining DATA QWIK elements
	D ELLOOP("AGR",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("BATCH",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("EXC",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("FPP",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("FKY",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("IDX",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("JFD",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("LUD",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("PPL",OWCUST,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("PROC",OWCUST,.TYPES,ISVMS,ISNFS)
	D ELLOOP("QRY",OWCUST,.TYPES,ISVMS,ISNFS)
	D ELLOOP("RMP",OWCUST,.TYPES,ISVMS,ISNFS)
	D ELLOOP("RPT",OWCUST,.TYPES,ISVMS,ISNFS)
	D ELLOOP("SCR",OWCUST,.TYPES,ISVMS,ISNFS)
	D ELLOOP("TRIG",OWCUST,.TYPES,ISVMS,ISNFS)
	;
	D:(db'="GTM") UPDRDB^TBXSQL		; create objects in RDB.
	;
	d sqllog^TBXSQL(PVB("CR"))
	Q	
	;
	;----------------------------------------------------------------------
GBLLOOP(TYPE,OWCUST,TYPES,ISVMS,ISNFS,FTYPE)	
	;
	; Loop through the elements of a folder and process. All elements other 
	; than table headers and columns are processed in this section.
	;----------------------------------------------------------------------
	N FILE,X,FOLDER,PARENT,RTN
	;
	S ER=0,RM=""
	S FOLDER=$P(TYPES(TYPE),"|",1)
	S RTN=$P(TYPES(TYPE),"|",2)
	S PARENT=$P(TYPES(TYPE),"|",3)
	;
	I $D(^TMP($J,"LOAD",FOLDER)) d logmsg^TBXDQUTL("Processing data for type : "_FTYPE,zlogf)
	E  Q
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	.	;
	.	Q:$P(FILE,".",2)'=FTYPE		; if file extension don't match quit.
	.	I '$$FIXPACK(FILE,FOLDER) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved","",ISVMS,ISNFS)
	.	D ITEM(FILE,FOLDER,RTN,PARENT,OWCUST,ISVMS,ISNFS)
	.	I ER W !,RM S ER=0,RM=""
	.	K ^TMP($J,"LOAD",FOLDER,FILE)
	;
	Q
	;
	;		
	;---------------------------------------------------------------------
ELLOOP(TYPE,OWCUST,TYPES,ISVMS,ISNFS)	; Generic element loop
	;---------------------------------------------------------------------
	;
	; Loop through the elements of a folder and process. All elements other 
	; than table headers and columns are processed in this section.
	;
	N FILE,X,FOLDER,PARENT,RTN
	;
	S ER=0,RM=""
	S FOLDER=$P(TYPES(TYPE),"|",1)
	S RTN=$P(TYPES(TYPE),"|",2)
	S PARENT=$P(TYPES(TYPE),"|",3)
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing folder "_FOLDER,zlogf)
	E  Q
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	.	;
	.	I '$$FIXPACK(FILE,FOLDER) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved","",ISVMS,ISNFS)
	.	D ITEM(FILE,FOLDER,RTN,PARENT,OWCUST,ISVMS,ISNFS)
	.	I ER D logmsg^TBXDQUTL(RM,zlogf) S ER=0,RM=""
	;
	Q
	;
	;---------------------------------------------------------------------
ITEM(FILE,FOLDER,RTN,PARENT,OWCUST,ISVMS,ISNFS)	; Process one item
	;---------------------------------------------------------------------
	;
	N USER,DATE,TIME,X
	;
	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	;
	; Check for customization
	N CMD
	S CMD="S X=$$CHECK^"_RTN_"(FILE,USER,DATE,TIME)"
	X CMD
	;
	; If customized and user wants to decide on individual elements
	; prompt to overwrite
	I +X=0,'OWCUST S X=$$OWPROM(FILE,$P(X,"|",2),$P(X,"|",3))
	;
	; If user chooses not to overwrite, reject to allow for loading
	; later with @DBBSRJC.
	I X=0 D REJECT(FOLDER,FILE,RTN,"Not Loaded: Custom version preserved","",ISVMS,ISNFS) Q
	;
	N REVISION,USER,DATE,CODE,TIME
	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	;
	D logmsg^TBXDQUTL("Loading "_FOLDER_" definition "_FILE,zlogf)
	; Read file contents into the CODE array.
	D READFILE(PARENT,FOLDER,"",FILE,.CODE,ISVMS,ISNFS)
	;
	I 'ER D
	.	; Load element 
	.	S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,PACKTYPE,USER,DATE,TIME)"
	.	X CMD
	I ER D  Q
	.	D ERROR
	.	D REJECT(FOLDER,FILE,RTN,"Not Loaded: "_$G(RM),"",ISVMS,ISNFS)
	.	S ER=0,RM=""
	;
	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;
	Q
	;
	;
	;---------------------------------------------------------------------
TBLLOOP(OWCUST,ISVMS,ISNFS)	; Table and column loop
	;---------------------------------------------------------------------
	;
	; Loop through the table (TBL) and column (COL) files and process.
	; The array is processed in reverse order to endure that a table's
	; header file is processed before it's columns. The naming convention
	; for these files ensures this order.
	;
	N FILE,X,TYPE,TABLE,USER,DATE,TIME,REVISION,FOLDER
	;
	S FOLDER="table"
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE),-1) Q:FILE=""!ER  D
	.	;
	.	N CODE
	.	S TYPE=$P(FILE,".",2)
	.	S RTN=$S(TYPE="COL":"TBXCOL",1:"TBXTBL")
	.	S TABLE=$$LOWER^%ZFUNC($P($P(FILE,"-",1),".",1))
	.	I '$$FIXPACK(FILE,FOLDER) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved","",ISVMS,ISNFS)
	.	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	.	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	.	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	.	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	.	;
	.	; Check for customization
	.	I TYPE="COL" S X=$$CHECK^TBXCOL(FILE,USER,DATE,TIME)
	.	I TYPE="TBL" S X=$$CHECK^TBXTBL(FILE,USER,DATE,TIME)
	.	;
	.	; If customized and user wants to decide on individual elements
	.	; prompt to overwrite
	.	I +X=0,'OWCUST S X=$$OWPROM(FILE,$P(X,"|",2),$P(X,"|",3))
	.	;
	.	; If user chooses not to overwrite, reject to allow for loading
	.	; later with @DNBSRJC.
	.	I X=0 D REJECT(FOLDER,FILE,RTN,"Not Loaded: Custom version preserved","",ISVMS,ISNFS) Q
	.	;
	.	; Read file contents into the CODE array.
	.	D READFILE("dataqwik","table",TABLE,FILE,.CODE,ISVMS,ISNFS)
	.	I 'ER D
	..		D logmsg^TBXDQUTL("Loading table definition "_FILE,zlogf)
	..		I TYPE="COL" S X=$$LOAD^TBXCOL(.CODE,FILE,PACKTYPE,USER,DATE,TIME)
	..		I TYPE="TBL" S X=$$LOAD^TBXTBL(.CODE,FILE,PACKTYPE,USER,DATE,TIME)	
	.	I ER D  Q
	..		D ERROR
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Custom version preserved","",ISVMS,ISNFS)
	..		S ER=0,RM=""
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	Q
	;
	;---------------------------------------------------------------------
RTNLOOP(OWCUST,ISVMS,ISNFS,RTNDIR)	; Copy routines to target
	;---------------------------------------------------------------------
	;
	N FILE,FOLDER,CFLAG,NOCOMP,RTN,X,TMPPATH,PPATH
	;
	S NOCOMP("TBXFPIN.M")=""
	S NOCOMP("TBXRTN.M")=""
	S NOCOMP("SCADRV.M")=""
	S NOCOMP("SCADRV0.M")=""
	S NOCOMP("DRV.M")=""
	S NOCOMP("%OSSCRPT.M")=""
	;
	S FILE="",RTN="TBXRTN",ER=0
	;
	F FOLDER="percent_routine",$S($ZV["VMS":"vms",1:"unix") D
	.	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Loading percent routines",zlogf)
	.	;
	.	S TMPPATH=FOLDER,PPATH="percent_routine"
	.	S:ISVMS&ISNFS TMPPATH=$$NFSVMS^TBXDQUTL(TMPPATH),PPATH=$$NFSVMS^TBXDQUTL(PPATH)
	. 	I (FOLDER="unix")!(FOLDER="vms") S TMPPATH="["_PPATH_"."_TMPPATH_"]" 
	.	E  S TMPPATH="["_PPATH_"]" 
	.	S TMPPATH=$$appdir^TBXDQUTL(INSTDIR,TMPPATH)
	.	;
	.	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	..		I '$$FIXPACK(FILE,FOLDER) D  Q
	...			D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved",TMPPATH,ISVMS,ISNFS)
	..			;
	..		S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	..		S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	..		S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	..		S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	..		S CFLAG=$D(NOCOMP($$UPPER^%ZFUNC(FILE)))
	..		;
	..		D logmsg^TBXDQUTL("Loading "_FOLDER_" "_FILE,zlogf)
	..		S ER=$$LOADPRTN^TBXRTN(FILE,"",TMPPATH,PCNTDIR,1,1)
	..		I ER D  Q
	...			D ERROR
	...			D REJECT(FOLDER,FILE,RTN,"Not Loaded: "_$G(RM),TMPPATH,ISVMS,ISNFS)
	...			S ER=0,RM=""
	..		D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;
	S FOLDER="routine",FILE="",ER=0
	;
	S PPATH=$S(((ISVMS)&(ISNFS)):$$NFSVMS^TBXDQUTL(FOLDER),1:FOLDER)
	S PPATH=$$appdir^TBXDQUTL(INSTDIR,"["_PPATH_"]")	
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Loading routines",zlogf)
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	I '$$FIXPACK(FILE,FOLDER) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved",PPATH,ISVMS,ISNFS)
	.		;
	.	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	.	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	.	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	.	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	.	;
	.	S CFLAG=$D(NOCOMP($$UPPER^%ZFUNC(FILE)))	
	.	D logmsg^TBXDQUTL("Loading "_FOLDER_" "_FILE,zlogf)
	.	S ER=$$LOAD^TBXRTN(FILE,"",PPATH,RTNDIR,1,1)
	.	I ER D  Q
	..		D ERROR
	..		D REJECT(FOLDER,FILE,RTN,"Not loaded: "_$G(RM),TMPPATH,ISVMS,ISNFS)
	..		S ER=0,RM=""
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;	
	Q
	;---------------------------------------------------------------------
UNMASK(MASKDATE,JD,JT)	; Convert masked date and time to julian format
	;---------------------------------------------------------------------
	;
	N %TS,%TN
	S JD=$$DSJD^SCADAT($P(MASKDATE," ",1))
	;
	S %TS=$TR($P(MASKDATE," ",2,3)," ","")
	D ^SCATIM
	S JT=%TN
	Q
	;
	;---------------------------------------------------------------------
READFILE(PARENT1,PARENT2,TABLE,FILE,CODE,ISVMS,ISNFS)	; Read file contents 
	;---------------------------------------------------------------------
	;
	N IO,X,LINE
	;
	I (ISVMS)&(ISNFS) D						
	.	S PARENT1=$$NFSVMS^TBXDQUTL(PARENT1)
	.	S PARENT2=$$NFSVMS^TBXDQUTL(PARENT2)
	.	S TABLE=$$NFSVMS^TBXDQUTL(TABLE)
	.	S FILE=$$NFSVMS^TBXDQUTL(FILE)
	;
	I (PARENT2="data")!(PARENT2="DATA") S IO=$$appdir^TBXDQUTL(INSTDIR,"["_PARENT2_"]")_FILE
	I (TABLE="")&(PARENT1'="") S IO=$$appdir^TBXDQUTL(INSTDIR,"["_PARENT1_"."_PARENT2_"]")_FILE
	I TABLE'="" S IO=$$appdir^TBXDQUTL(INSTDIR,"["_PARENT1_"."_PARENT2_"."_TABLE_"]")_FILE
	;
	S X=$$FILE^%ZOPEN(IO,"READ",25,1024)
	I 'X S ER=1,RM=$P(X,"|",2) Q
	U IO
	F  Q:$ZEOF  D
	.	R LINE
	.	I $ZEOF Q
	.	S CODE($O(CODE(""),-1)+1)=LINE
	U 0
	C IO
	Q
	;
	;---------------------------------------------------------------------
REJECT(FOLDER,FILE,RTN,MSG,FPATH,ISVMS,ISNFS)	; Reject element for future processing
	;---------------------------------------------------------------------
	;
	; Set reject record indicating when it was rejected and 
	; which build it came was released in.
	;
	N SEQ,REC,PROJECT,VIEW,CR,REVISION,USER,DATE,TIME,TYPE,PARENT,ER,CODE
	;
	S ER=0
	S PROJECT=$P(^TMP($J),"|",1)
	S VIEW=$P(^TMP($J),"|",2)
	S CR=$P(^TMP($J),"|",3)
	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	S TYPE=$P(FILE,".",2)
	;
	; optional variable FPATH are only for non dataqwik files
	; if element is either global or dataqwik, FPATH is null
	I $G(FPATH)'="" S CODE(1)=FPATH
	I $G(FPATH)="" D
	.	I ($P(FILE,".",2)="COL")!($P(FILE,".",2)="TBL") D READFILE("dataqwik","table",TABLE,FILE,.CODE,ISVMS,ISNFS) Q
	.	S PARENT=$P(TYPES($P(FILE,".",2)),"|",3)
	.	D READFILE(PARENT,FOLDER,"",FILE,.CODE,ISVMS,ISNFS) Q:$G(ER)
	;
	; I $G(ER) D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Error while creating reject record: "_$G(RM)) Q
	;
	K ^TBXREJ(FOLDER,FILE)
	S $P(REC,"|",1)=REVISION
	S $P(REC,"|",2)=USER
	S $P(REC,"|",3)=DATE
	S $P(REC,"|",4)=TIME
	S $P(REC,"|",5)=PROJECT
	S $P(REC,"|",6)=VIEW
	S $P(REC,"|",7)=CR
	S $P(REC,"|",8)=RTN
	S $P(REC,"|",9)=+$H
	S $P(REC,"|",10)=$P($H,",",2)
	S $P(REC,"|",11)=$P(%LOGID,"|",2)	; User who performed action
	S $P(REC,"|",12)=$E($G(MSG),1,500)
	;
	S ^TBXREJ(FOLDER,FILE)=REC
	;
	S SEQ=""
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  S ^TBXREJ(FOLDER,FILE,SEQ)=CODE(SEQ)
	;
	D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,$G(MSG))
	Q
	;
	;---------------------------------------------------------------------
LOG(FOLDER,FILE,PVB,REVISION,USER,DATE,TIME,MSG)	; Log action
	;---------------------------------------------------------------------
	;
	N REC,CURDATE,SEQ
	;
	S CURDATE=+$H
	S $P(REC,"|",1)=FOLDER
	S $P(REC,"|",2)=FILE
	S $P(REC,"|",3)=PVB("PROJECT")
	S $P(REC,"|",4)=PVB("VIEW")
	S $P(REC,"|",5)=PVB("CR")
	S $P(REC,"|",6)=REVISION
	S $P(REC,"|",7)=USER
	S $P(REC,"|",8)=DATE
	S $P(REC,"|",9)=TIME
	S $P(REC,"|",10)=MSG
	S $P(REC,"|",11)=$P(%LOGID,"|",2)	; User who performed action
	S $P(REC,"|",12)=$P($H,",",2)		; Time of event
	;
	S SEQ=$O(^TBXLOG(+$H,""),-1)+1
	S ^TBXLOG(CURDATE,SEQ)=REC
	S ^TBXLOGX(FILE,CURDATE,SEQ)=""
	;
	Q
	;
	;-----------------------------------------------------------------------
TYPEINIT(TYPES)	; Build TYPES array
	;-----------------------------------------------------------------------
	; The TYPES array contains information about the supported file
	; types. The key is the file extension.
	;
	;	Position 1 - directory used to store the element file
	;		 2 - routine used to handle the element
	;		 3 - parent directory of position 1 (if any)
	;
	; Routines, tables and columns require additional processing
	; thus they are not processed in the generic ELLOOP section.
	; These file types are not stored in the TYPES array.
	;
	S TYPES("G")="data|TBXDATA"
	S TYPES("DAT")="data|TBXDATA"
	S TYPES("AGR")="aggregate|TBXAGGR|dataqwik"
	S TYPES("BATCH")="batch|TBXBATCH|dataqwik"
	S TYPES("EXC")="executive|TBXEXEC|dataqwik"
	S TYPES("FPP")="filer_pre_post|TBXFPP|dataqwik"
	S TYPES("FKY")="foreign_key|TBXFKEY|dataqwik"
	S TYPES("IDX")="index|TBXIDX|dataqwik"
	S TYPES("JFD")="journal|TBXJRNL|dataqwik"
	S TYPES("LUD")="lookup_doc|TBXLUD|dataqwik"
	S TYPES("PPL")="pre_post_lib|TBXPPL|dataqwik"
	S TYPES("PROC")="procedure|TBXPROC|dataqwik"
	S TYPES("QRY")="query|TBXQRY|dataqwik"
	S TYPES("RMP")="record_map|TBXRCDM|dataqwik"
	S TYPES("RPT")="report|TBXRPT|dataqwik"
	S TYPES("SCR")="screen|TBXSCRN|dataqwik"
	S TYPES("TRIG")="trigger|TBXTRIG|dataqwik"
	S TYPES("M")="routine|TBXRTN"
	S TYPES("COL")="column|TBXCOL"
	S TYPES("TBL")="table|TBXTBL" 
	;
	Q
	;
	;---------------------------------------------------------------------
COPYINST(PVB);	Copy new Fix Pack information to ^TBXFIX 
	;---------------------------------------------------------------------
	;
	S $P(^TBXFIX,"|",1)=PVB("PROJECT")
	S $P(^TBXFIX,"|",2)=PVB("VIEW")
	S $P(^TBXFIX,"|",3)=PVB("CR")
	;
	N FILE,REC,FOLDER
	S FILE="",FOLDER=""
	F  S FOLDER=$O(^TMP($J,"LOAD",FOLDER)) Q:FOLDER=""  D
	.	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	..		S REC=^TMP($J,"LOAD",FOLDER,FILE)
	..		S ^TBXFIX(FILE)=REC
	Q
	;
	;---------------------------------------------------------------------
WARN	; Preach about the use of backups, screen captures use of caution
	;---------------------------------------------------------------------
	;
	N %READ,%NOPRMT,HDG,LINE1,LINE2,LINE3,LINE4,LINE5,LINE6
	;
	S HDG="NOTICE"
	S LINE1="You are about to load a fix pack into this Profile Runtime"
	S LINE2="Environment. All database and program files should be"
	S LINE3="backed-up before proceeding. If your terminal emulator supports"
	S LINE4="screen capture, we strongly recommended you enable it now."
	S LINE5="Refer to the Profile Software Installation Instructions for"
	S LINE6="more details on how to use this function."
	;
	S %READ="@HDG/CEN/REV,,@LINE1/CEN,@LINE2/CEN,@LINE3/CEN,@LINE4/CEN,,,@LINE5/CEN,@LINE6/CEN"
	D INQ^UTLREAD
	Q
	;
	;---------------------------------------------------------------------
ERROR	; Display error message
	;---------------------------------------------------------------------
	;
	D logmsg^TBXDQUTL("Error encountered ***************************************",zlogf)
	D logmsg^TBXDQUTL($G(RM),zlogf)
	D logmsg^TBXDQUTL($ZS,zlogf)
	D logmsg^TBXDQUTL("*********************************************************",zlogf)
	Q
	;
	;---------------------------------------------------------------------
FIXPACK(FILE,FOLDER)	; Check for Fix Pak revision of the element
	;---------------------------------------------------------------------
	;
	;	Extrinsic return 0 - Do not overwrite
	;			 1 - Overwrite
	;
	;
	N NEW,OLD,SP,MSG,STATUS,TMPREC,FIXREC
	;
	; Check for the existance of a fix version of this element
	I '$D(^TBXFIX(FILE)) Q 1
	;
	; If the fix element matches the revision in the fix pack, return 1
	I $G(^TMP($J,"LOAD",FOLDER,FILE))=$G(^TBXFIX(FILE)) Q 1
	;
	S NEW("REVISION")=$P($G(^TMP($J,"LOAD",FOLDER,FILE)),"|",1)
	S NEW("USER")=$P($G(^TMP($J,"LOAD",FOLDER,FILE)),"|",2)
	S NEW("DATE")=$P($G(^TMP($J,"LOAD",FOLDER,FILE)),"|",3)
	S NEW("TIME")=$P($G(^TMP($J,"LOAD",FOLDER,FILE)),"|",4)
	S NEW("CR")=$P($G(^TMP($J,"LOAD",FOLDER,FILE)),"|",7)
	;
	S OLD("REVISION")=$P($G(^TBXFIX(FILE)),"|",1)
	S OLD("USER")=$P($G(^TBXFIX(FILE)),"|",2)
	S OLD("DATE")=$P($G(^TBXFIX(FILE)),"|",3)
	S OLD("TIME")=$P($G(^TBXFIX(FILE)),"|",4)
	S OLD("CR")=$P($G(^TBXFIX(FILE)),"|",7)
	;
	; If this is the same file that was previously loaded in a fix pack, do not prompt
	S TMPREC=$P($G(^TMP($J,"LOAD",FOLDER,FILE)),"|",1,5)
	S FIXREC=$P($G(^TBXFIX(FILE)),"|",1,5)
	;
	; quit if the file about to load matches the file revision in ^TBXFIX.
	I TMPREC=FIXREC Q 1
	;
	I TMPREC'=FIXREC D  Q $$PROMPT("Do you want to replace the current revision with the new revision")
	.	; The fix pack revision does not match the fix pack revision in ^TBXFIX.
	.	; Display information about the file and prompt to continue
	.	;
	.	S MSG="Element "_FILE_" was loaded from a fix pack for CR "_OLD("CR")_$C(13,10)
	.	S MSG=MSG_"Current revision = "_OLD("REVISION")_$C(9)_OLD("USER")_$C(9)_"CR "_OLD("CR")_$C(9)_$$^%ZD(OLD("DATE"))_$C(13,10)
	.	S MSG=MSG_"    New revision = "_NEW("REVISION")_$C(9)_NEW("USER")_$C(9)_"CR "_NEW("CR")_$C(9)_$$^%ZD(NEW("DATE"))_$C(13,10)_$C(13,10)
	.	D logmsg^TBXDQUTL(MSG,zlogf)
	;
	S SP("SP")=$P($G(^TBXINST),"|",3)
	S SP("REVISION")=$P($G(^TBXINST(FILE)),"|",1)
	S SP("USER")=$P($G(^TBXINST(FILE)),"|",2)
	S SP("DATE")=$P($G(^TBXINST(FILE)),"|",3)
	S SP("TIME")=$P($G(^TBXINST(FILE)),"|",4)
	;
	; if the SP revision is newer than the fix pack revision, prompt for confirmation
	I NEW("DATE")<SP("DATE") D  Q $$PROMPT("Do you want to replace the current revision with the new revision")
	.	S MSG="Element "_FILE_" was loaded from a fix pack for CR "_OLD("CR")_$C(13,10)
	.	S MSG=MSG_"Current revision = "_SP("REVISION")_$C(9)_SP("USER")_$C(9)_"SP "_SP("SP")_$C(9)_$$^%ZD(SP("DATE"))_$C(13,10)
	.	S MSG=MSG_"    New revision = "_NEW("REVISION")_$C(9)_NEW("USER")_$C(9)_"CR "_NEW("CR")_$C(9)_$$^%ZD(NEW("DATE"))_$C(13,10)_$C(13,10)
	.	D logmsg^TBXDQUTL(MSG,zlogf)
	;
	Q 1
	;
	;---------------------------------------------------------------------
OBSLOOP	; Obsolete elements loop
	; Note: assume we will never obsolete % routines from this program!
	;---------------------------------------------------------------------
	;
	; Loop through the obsoleted element list 
	;
	N FILE,X,TYPE,TABLE,USER,DATE,TIME,REVISION,FOLDER,RTN,CMD
	;
	S FOLDER="obsolete"
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE),-1) Q:FILE=""  D
	.	D logmsg^TBXDQUTL("Obsoleting "_FILE,zlogf)
	.	S TYPE=$$UPPER^%ZFUNC($P(FILE,".",2))				; check file extension
	.	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	.	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	.	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	.	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	.	I $D(TYPES(TYPE)) D						; if extension found in TYPES						
	..		S RTN=$P(TYPES(TYPE),"|",2)				
	..		I TYPE="M" S CMD="S X=$$OBSRTN^TBXRTN(FILE)"  		; obsolete routines
	..		I (TYPE="G")!(TYPE="DAT") S CMD="S X=$$OBSGBL^TBXDATA(FILE)"  	; obsolete data
	..		I '((TYPE="M")!(TYPE="G")!(TYPE="DAT")) S CMD="S X=$$OBSDQW^"_RTN_"(FILE)"	; obsolete global and DQs
	..		X CMD
	.	I TYPE="SQL" d obsscrpt^TBXSQL(FILE)
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Obsoleted")	; deleted obsoleted files
	Q
	;
	;---------------------------------------------------------------------
SFLOOP(ISVMS,ISNFS)	; Load system files
	;---------------------------------------------------------------------
	;
	; Loop through the system files list  
	;
	N ISVMS,FOLDERS,FILE,X,TMPPATH,PPATH
	S ER=0,RM="",RTN="TBXSFILE"
	;
	S ISVMS=$ZVERSION["VMS"
	;
	F FOLDER="com","doc","exp","gog","help","uxscrpt","ini" D
	.	I (ISVMS)&(FOLDER="uxscrpt") Q 		; don't load unix scripts if platform is vms
	.	I ('ISVMS)&(FOLDER="com") Q		; don't load *.com if platform is unix
	.	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	.	;
	.	S TMPPATH=FOLDER,PPATH="system_files"
	.	S:(ISVMS)&(ISNFS) TMPPATH=$$NFSVMS^TBXDQUTL(TMPPATH),PPATH=$$NFSVMS^TBXDQUTL(PPATH)
	.	S TMPPATH=$$appdir^TBXDQUTL(INSTDIR,"["_PPATH_"."_TMPPATH_"]")
	.	;
	.	S FILE="" 
	.	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE),-1) Q:FILE=""!ER  D
	..		I FOLDER="ini",FILE'="UCOPTS.ini" Q
	..		I '$$FIXPACK(FILE,FOLDER) D  Q
	...			D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved",TMPPATH,ISVMS,ISNFS)
	..		S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	..		S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	..		S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	..		S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	..		S ER=$$LOAD^TBXSFILE(FILE,TMPPATH,PACKTYPE)
	..		I ER D  Q
	...			D ERROR
	...			D REJECT(FOLDER,FILE,RTN,"Not Loaded: "_$G(RM),TMPPATH,ISVMS,ISNFS)
	...			W !,RM S ER=0,RM=""
	..		D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")	
	Q
	;
	;----------------------------------------------------------------------- 
	; 
ZERROR	;  Exception handler code. 
	; 
	w !,"Fatal error during fix pack installation",! 
	S Z=$ZSTATUS,LOC=$P(Z,",",2),TXT=$P(Z,",",3),MSG=$P(Z,",",4,$L(Z,",")) 
	w "Location: "_LOC,! 
	w "GTM code: "_TXT,! 
	w "Message: "_MSG,! 
	d CLEAN 
	h 
	Q 
	; 
	; 
	;----------------------------------------------------------------------- 
GETDIRS(INSTDIR,DIRLIST);	Pre processor to return subdirectory 
	;-----------------------------------------------------------------------
	;
	N X,Y
	D CHKDIR^TBXDQUTL(INSTDIR)
	I $G(ER) Q
	S OUT=INSTDIR_"/*"
	S:ISVMS OUT=INSTDIR_"*.DIR"
	S Y=0 
	F  S X=$ZSEARCH(OUT) Q:X=""  S Y=Y+1,DIRLIST(Y)=$ZPARSE(X,"NAME")
	Q
	;
	;------------------------------------------------------------------------
FPDIRS(INDEX,DIRLIST);	Post processor to return the value. This is to prevent the  
	;	     the first column of the drop down list being limited to 12
	;	     characters long. It takes the key as an argument and return
	;	     the description field.
	;------------------------------------------------------------------------
	;
	I '$D(DIRLIST(INDEX)) Q INDEX
	S DIRLIST(DIRLIST(INDEX))=DIRLIST(INDEX)
	Q DIRLIST(INDEX)
	;
	;---------------------------------------------------------------------
SQLLOOP(OWCUST,ISVMS,ISNFS)	; Copy routines to target
	;---------------------------------------------------------------------
	;
	N FILE,FOLDER,PATH,TMPPATH,connstr,sqlfile,cmd,ok,cnt
	S FOLDER="scripts",FILE=""
	;
	Q:'$D(^TMP($J,"LOAD",FOLDER))
	Q:$G(db)="GTM"
	;
	D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	;
	s connstr=$$getCnStr^TBXSQL()
	Q:connstr=""
	s count=0
	;
	s sqlfile=$$SCAU^%TRNLNM("SPOOL","SQL_BATCH_"_$J_".sh")
	s ok=$$FILE^%ZOPEN(sqlfile,"WRITE/NEWV",5)					; attempt to open file
	i +ok=0 d logmsg^TBXDQUTL("Error - unable to open file "_sqlfile,zlogf) Q
	u sqlfile w "PATH=.:$PATH:$ORACLE_HOME/bin",!
	u sqlfile w "export PATH",! 
	u sqlfile w "sqlplus "_connstr_" <<EOF",!
	u sqlfile w "set serveroutput on size 200000",!
	u sqlfile w "set head off",!
	;
	S TMPPATH=$$appdir^TBXDQUTL(INSTDIR,"[scripts]")					; Source directory
	;
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	I '$$FIXPACK(FILE,FOLDER) D  Q
	..		D REJECT(FOLDER,FILE,"","Not Loaded: Fix pack version preserved",TMPPATH,ISVMS,ISNFS)
	.		;
	.	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	.	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	.	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	.	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	.	;
	.	u sqlfile w !,"select '"_FILE_"' from dual;",!
	.	u sqlfile w "@"_$$appdir^TBXDQUTL(INSTDIR,"[scripts]")_FILE,!,"/",!
	.	s count=count+1
	.	;
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;
	u sqlfile w "exec DBMS_OUTPUT.PUT_LINE('RECOMPILING ALL OBJECTS'||recompile)",!
	u sqlfile w "EXIT",!
	u sqlfile w "EOF"
	c sqlfile
	i count>0 d
	. s cmd="chmod +x "_sqlfile
	. s ok=$$SYS^%ZFUNC(cmd)
	. s cmd=sqlfile
	. s ok=$$SYS^%ZFUNC(cmd)
	s cmd="rm "_sqlfile
	s ok=$$SYS^%ZFUNC(cmd)
	;	
	Q
init	;***********************************************************************
	; Purpose: Initialize variables to be used in installation
	;***********************************************************************
	;
	S %LOGID=$$LOGID^SCADRV
	S %="|"
	;
	S $ZTRAP="D ZERROR^TBXFPIN",ER=0,RM=""
	;
	S initEnv=0
	;
	S ISVMS=($ZVER["VMS")
	;
	S db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	;	
	s dqv=$$GETVN^TBXDQUTL()
	s dqvn7=0
	S:dqv'<"7.0" dqvn7=1 
	Q 
	; 
