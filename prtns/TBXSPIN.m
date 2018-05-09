TBXSPIN	;;	Profile Software Installation Driver
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
	; 07/06/2006	KWANL
	;		Fixed spelling in SQLLOOP.
	;
	; 06/28/2006	KWANl
	;		Per Bardi changed the SQL plus option.
	;
	; 05/04/2006	KWANL
	;		Modified SQLLOP section to intall scripts in a specified order
	;		and perform recompile after the install.
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
	; 04/07/2006	KWANL
	;		Modified COMPARE section to ignore username
	;
	; 03/27/2006	KWANL
	;		Removed check for db type before loading CUVAR.DAT to an 
	;		initial environment. Changed to use SCAU_DIR to reference 
	;		the root directory of the environment. 
	; 
	; 02/09/2006	KWANL
	;		Added SQLLOOP section to handle sql scripts file. Modified
	;		OBSLOOP section to handle the obsolete of the sql scripts file.
	;
	; 02/03/2006	KWANL
	;		Modified LOAD section to log SQL related error to a different file
	;
	; 02/01/2006	KWANL
	;		Removed Badris's changes in REJECT section. 
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
	;		Merged Pete's changes.
	;	
	; 11/09/2005	KWANL
	;		Added code to insert CUVAR.DAT for init environment.
	;		set value to commands("boot","restrictionlevel")=1.
	;		Load CUVAR to RDB.
	;
	; 10/21/2005	KWANL
	;		Changed the load order to: install *.G, *COL or *.TBL, and .DAT
	; 
	; 10/20/2005	KWANL
	;		Combined LOADGTM and LOADDNI back to LOAD.
	;
	; 10/19/2005	KWANL
	;		Added a call to OBSTABLE^TBXSQL after the call OBSLOOP
	;		in LOADDBI section. 
	;
	; 10/18/2005	KWANL
	;		Replace LOGID^SCADRV with $$USERNAM^%ZFUNC as SCADRV may not be 
	;		avilable when the TBXSPIN is called.
	;		Added code to detect if it is an initial environment. If it is
	;		an initial environment set both OWCUST and OWFIX to 1, use read
	;		command to get inputs, and skip obosletes.
	;		Replace call to SCADAT and SCATIM with $$date^UCGMCU() and 
	;		$$time^UCGMCU() respectively.
	;		Added a call to CRTABLE^TBXSQL to install new table after TBLLOOP
	;		for RDB environment.
	;		Removed COMPFIL^TBXDQUTL.
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
	; 02/10/2005	Lik Kwan
	;		Modified OBSLOOP section to remove file entry from ^TBXFIX
	;
	; 12/02/2004	Lik Kwan
	;		Add a prompt to ask user what to do if the obsoleted element
	;		is in a fix pack. 
	;
	; 08/24/2004	Lik Kwan
	;		Display review reject message if ^TBXREJ is not empty.
	;
	; 07/23/2004	Lik Kwan
	;		Fixed to remove ^TBXFIX entry if the prompt to overlay Fix pack 
	;		element returns 1.
	;
	; 12/22/2003	Lik Kwan
	;		Changed to use absolute path when installing routine.
	;
	; 11/14/2003	Terrie Dougherty
	;		Corrected spelling error in WARN subroutine.
	;
	; 10/10/2003	Lik Kwan
	;		Modified GETCUR section to get status from piece 6 instead of 4.
	;		Modified OBSLOOP to skip obsolete if there is a fix pack already
	;		apply for the file.
	;
	; 06/27/2003	Terrie Dougherty
	;		Moved call to COPYINST to prevent ^TBXINST from being 
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
	; 01/23/2003	Lik Kwan
	;		Skip custom folder.
	;
	; 01/20/2003	Lik Kwan
	;		Remove edit check for label.
	;
	; 01/16/2003	Terrie Dougherty
	;		Modified LOG and COPYINST subroutines to get $P((%LOGID,"|",2) to 
	;		return user id correctly. Modified EXT subroutine to use PVB to 
	;		determine if build is older than current build. 
	;
	; 12/20/2002	Lik Kwan
	;		Added CHKBL section to compare the builds that will be 
	;		installed and the last build installed.
	;		Remove SP in directory lookup in SPDIRS section.
	;		Modified to use LOADPRTN to install % routine.
	;		Added user name and date in ^TBXINST header.
	;		Remove reject log before installation.
	;
	; 10/7/2002	Lik kwan
	;		Added a post processor in the lookup table to prevent
	;		first column being truncated.
	;
	; 09/20/2002 -  KWANL
	;		Modified to handle service pack install from a NFS mounted 
	;		directory.
	; 	
	; 08/28/2002 -  KWANL	
	;		Modified the program to read new build contents file.
	;		
	; 08/19/2002 -  KWANL
	;		Modified to handle VMS environment.
	;	
	; 08/02/2002 - JOYCEJ
	;	       Increased size of INSTDIR prompt
	;
	;
	;---------------------------------------------------------------------
	;
	;---------------------------------------------------------------------
SPINST	; Service Pack Install Prompt
	;---------------------------------------------------------------------
	; Release Directory - The directory where the Service Pack has been 
	;	unzipped to. This will be a common directory for 
	;	each server. At Sanchez, the release directory will be an 
	;	NFS mount to the /SCA_Release directory on Silvar (a Solaris 
	;	server) plus the unique service pack directory.
	; Percent Routine Directory - This is the directory where percent 
	;	routines will be loaded.
	; Prompt for Overwrite - If Yes, the installation program will 
	;	prompt the user to skip the item when a customized DATA QWIK 
	;	element is about to be overwritten. If No, all customized 
	;	items will be overwritten without prompting.
	;
	N %READ,%TAB,HDG,INSTDIR,PCNTDIR,OWCUST,OWFIX,$ZT,ok,zlogf,ISVMS,INSTBUILD,DIRLIST,db,dqv,dqvn7,initEnv
	;
	s initEnv=1
	i $D(^DBTBL) s initEnv=0
	;
	; if it is a empty shell
	i initEnv d
	.	; need to setup dqvn7 from a flat file.
	.	;
	.	s OWCUST=1
	.	s OWFIX=1
	.	w !,"Enter Service Pack Directory: (eg: /profile_release/sp)",!
	. read INSTDIR
	. w !,"Enter Build to install: (eg: SP_Profile04_P04_DEV_01)",!
	. r INSTBUILD
	. w !,"Enter Percent Routine Directory: (eg: $home)",!
	. r PCNTDIR
	e  d
	.	; Display warning page
	.	D WARN
	.	S HDG="Install Service Pack"
	.	;
	.	S INSTDIR="/profile_release/sp"
	.	S ISVMS=($P($ZVER," ",3)="VMS")
	.	S:ISVMS INSTDIR="PROFILE$RELEASE:[SP]"
	.	;
	.	S PCNTDIR=""
	.	S OWCUST=0
	.	S OWFIX=0
	.	;
	.	S %TAB("INSTDIR")=".INSTDIR/REQ/DES=Service Pack Directory/TYP=T/LEN=80/XPP=D GETDIRS^TBXSPIN(X,.DIRLIST)"
	.	S %TAB("INSTBUILD")=".INSTBUILD/REQ/DES=Build to install/TYP=T/LEN=80/TBL=DIRLIST(/XPP=S X=$$SPDIRS^TBXSPIN(X,.DIRLIST)"
	.	S %TAB("PCNTDIR")=".PCNTDIR/REQ/DES=Percent Routine Directory/TYP=T/LEN=60/XPP=D CHKDIR^TBXDQUTL(X)"
	.	S %TAB("OWCUST")=".OWCUST/REQ/DES=Overwrite Customized DQ Elements/TYP=L/LEN=1"
	.	S %TAB("OWFIX")=".OWFIX/REQ/DES=Overwrite Fix Pack Elements/TYP=L/LEN=1"
	.	S %READ="@HDG/CEN/REV,,,INSTDIR,INSTBUILD,PCNTDIR,OWCUST,OWFIX"
	.	D ^UTLREAD
	.	I VFMQ="Q" Q
	;
	I ER W !,RM,! Q:ER
	;
	D EXT(INSTDIR,INSTBUILD,PCNTDIR,OWCUST,OWFIX,initEnv)
	;
	D CLEAN
	Q
	;
	;---------------------------------------------------------------------
EXT(INSTDIR,INSTBUILD,PCNTDIR,OWCUST,OWFIX,initEnv)	; External entry point
	;---------------------------------------------------------------------
	;
	N CURBL,CURPROJ,CURVIEW,NEWPROJ,NEWVIEW,NEWBL,PVB,PACKTYPE,STIME
	;
	d init
	;
	I ER W !,RM,! Q:ER
	;
	I '$D(^dbtbl) D  Q
	.	W !,"Abort! Global ^dbtbl is necessary for proper software installation.  It is not present in the run-time environment.  Please contact your Sanchez Client Support Analyst for information.",!
	;
	I $D(^TBXREJ) Q:'$$PROMPT("Please resolve all rejects before installing a new build. Continue?")
	I $D(^TBXREJ) Q:'$$PROMPT("Continue will remove all rejects from the Reject Global. Continue?")
	K ^TBXREJ							; remove reject files
	;
	; If on vms, check if the disk is NFS mounted. (check if there is
	; a logical define for this directory which contains "NFS")
	;
	S ISNFS=0
	I (ISVMS)&($ZTRNLNM($P(INSTDIR,":",1))["NFS") S ISNFS=1
	;
	S INSTDIR=$$appdir^TBXDQUTL(INSTDIR,"["_INSTBUILD_"]")
	;
	d CHKDIR^TBXDQUTL(INSTDIR)
	W:ER !,RM,! Q:ER
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
	.	S RM="Can not find build in "_INSTDIR_"." 
	;
	I 'initEnv d
	. I PVB("VIEW")'=CURVIEW Q:'$$PROMPT("View "_CURVIEW_" differs from view of previous build. Continue")
	;
	S STIME=$P($H,",",2)
	D logmsg^TBXDQUTL("Begin installation of build "_PVB("BUILD"),zlogf)
	;
	; Compare service pack contents with last loaded service pack
	D COMPARE
	;
	; Install Started
	S $P(^TBXINST,"|",6)=1
	;
	D LOAD(INSTDIR,.PVB,OWCUST,OWFIX,ISVMS,ISNFS)
	I ER D ERROR Q
	;
	D COPYINST(.PVB)
	S ^TBXLOAD("SP",PVB("BUILD"),%LOGID,+$H,$P($H,",",2))=""
	;
	; Compile all loaded elements
	D COMPALL^TBXDQUTL
	I ER D ERROR Q
	;
	S $P(^TBXINST,"|",6)=0
	S ER="W",RM="Installation of build "_PVB("BUILD")_" completed"
	;
	I $D(^TBXREJ) d logmsg^TBXDQUTL("**** Run report TBXREJ to review reject file",zlogf)
	D logmsg^TBXDQUTL($G(RM),zlogf)
	c zlogf
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
GETCUR(CURPROJ,CURVIEW,CURBLD)	; Get previous build info from environment
	;---------------------------------------------------------------------
	;
	N PROCFLAG
	;
	S CURPROJ=$P($G(^TBXINST),"|",1)
	S CURVIEW=$P($G(^TBXINST),"|",2)
	S CURBLD=$P($G(^TBXINST),"|",3)
	S PROCFLAG=$P($G(^TBXINST),"|",6)
	;
	; Check the processing flag on the last build
	;	processing flag: 0 - Complete
	;			 1 - Started
	;			 2 - Fatal error during load
	;
	I PROCFLAG S ER=1,RM="Previus build "_CURBLD_" not fully loaded." D logmsg^TBXDQUTL(RM,zlogf) Q
	;
	Q
	;
	;---------------------------------------------------------------------
GETCONT(INSTDIR,PVB,ISVMS,ISNFS)	; Read build contents file
	;---------------------------------------------------------------------
	;
	N IO,REC,HEADER,X,FOUND,ISNEW,RELDIR,RELCONT
	;
	S RELDIR="release_doc",RELCONTS="build_contents.txt"
	;
	I ISVMS&ISNFS D
	.	S RELDIR=$$NFSVMS^TBXDQUTL(RELDIR)
	.	S RELCONTS=$$NFSVMS^TBXDQUTL(RELCONTS)
	;
	S IO=$$appdir^TBXDQUTL(INSTDIR,"["_RELDIR_"]")_RELCONTS
	;
	; A custom header is prepended to the build contents document 
	; during deployment.
	;
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q
	;
	U IO
	I $ZEOF U 0 S ER=1,RM=IO_"file missing"
	R HEADER
	S PVB("PROJECT")=$P(HEADER,"|",1)
	S PVB("VIEW")=$P(HEADER,"|",2)
	S PVB("BUILD")=$P(HEADER,"|",3)
	S ISNEW=$P(HEADER,"|",4)			; new build contents file will have a value of 1
	;
	; This section expects the build_contents.txt file to be in a specific
	; format. If StarBase changes the format of the this file, this code
	; must be changed accordingly.
	;
	N FILE,USER,DATE,TIME,REVISION,TYPE,FOLDER
	;
	;
	U IO
	F  Q:$ZEOF  R REC D
	.	I $G(ISNEW)="" D  Q
	.. 		S FOUND=0
	..		I $E(REC,1,7)="Folder:" S FOLDER=$P(REC," ",2)
	..		I ((ISVMS)&($$UPPER^%ZFUNC($G(FOLDER))="UNIX")) Q		; if platform is vms, ignore unix % routines
	..		I (('ISVMS)&($$UPPER^%ZFUNC($G(FOLDER))="VMS")) Q		; if platform is not vms, ignore vms % routine
	..		I $E(REC,1,12)="History for:" D  Q
	...			S FILE=$P(REC," ",3)
	...			S TYPE=$P(FILE,".",2)
	...			I ((TYPE="COL")!(TYPE="TBL"))&(FOLDER'="obsolete") S FOLDER="table"
	..		I $G(FILE)'="" D  Q:FOUND
	...			I $D(^TMP($J,"FILE",FILE)) S FOUND=1			; only capture the latest revision		
	..		I $E(REC,1,9)="Revision:" S REVISION=$P(REC," ",2) Q		; capture file revision 
	..		I $E(REC,1,7)="Author:" D
	...			S USER=$$TRIM^%ZS($E($P(REC,"Date:",1),9,999))
	...			D UNMASK($$TRIM^%ZS($P(REC,"Date:",2)),.DATE,.TIME)
	...			S ^TMP($J,"FILE",FILE)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER
	.	I (ISNEW=1) D  
	..		I REC="" Q
	..		I REC=$C(13) Q
	..		S FILE=$P(REC,"|",1)
	..		S TYPE=$P(FILE,".",2)
	..		S FOLDER=$P(REC,"|",2)
	..		I FOLDER="custom" Q
	..		I (TYPE="m")&(FOLDER="rtns") Q					; don't include external calls
	..		I FOLDER'="obsolete" D
	...			I (TYPE="COL")!(TYPE="TBL") S FOLDER="table"
	..		S REVISION=$P(REC,"|",3)
	..		D UNMASK($$TRIM^%ZS($P(REC,"|",4)),.DATE,.TIME)
	..		S USER=$$TRIM^%ZS($P(REC,"|",5))
	..		I (ISVMS)&((FOLDER["unix")!(FOLDER["uxscrpt")) Q	; if platform is vms, don't load unix stuff	
	..		I ('ISVMS)&((FOLDER["vms")!(FOLDER["com")) Q		; if platform is unix, don't load vms stuff
	..		S ^TMP($J,"FILE",FILE)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER
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
LOAD(INSTDIR,PVB,OWCUST,OWFIX,ISVMS,ISNFS)	
	;---------------------------------------------------------------------
	;
	N TYPES,FOLDER,command
	;
	s commands("boot","restrictionlevel")=1
	;
	; Build file type information array
	D TYPEINIT(.TYPES)
	;
	; Obsolete elements
	D:'initEnv OBSLOOP
	D:('initEnv)&(db'="GTM") OBSTABLE^TBXSQL
	;
	; Load routines
	D RTNLOOP(OWCUST,OWFIX,ISVMS,ISNFS)
	;
	; Load system files
	D SFLOOP(ISVMS,ISNFS) 	
	;
	; setup a temp global for PSL and Framework elements
	D ^TBXDQINT
	;
	; install M global first
	D GBLLOOP("G",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS,"G")
	;
	; Load table and column definitions
	D TBLLOOP(OWCUST,OWFIX,ISVMS,ISNFS)
	D logmsg^TBXDQUTL("All tables loaded.",zlogf)
	D logmsg^TBXDQUTL("Rebuilding data item control index for all tables",zlogf)
	D
	.	N X S X=""
	.	F  S X=$O(^DBTBL("SYSDEV",1,X)) Q:X=""  D BLDINDX^DBSDF9(X)
	;
	D logmsg^TBXDQUTL("Loading tables to RDB",zlogf)
	D:(db'="GTM") CRTABLE^TBXSQL,MODIFYTB^TBXSQL			; create tables in RDB
	D logmsg^TBXDQUTL("Done Loading RDB Tables",zlogf)
	D logmsg^TBXDQUTL("Rebuilding DBMAP for all tables",zlogf)
	I db'="GTM" D ALL^DBMAP(db),regnproc^TBXSQL
	;
	; Load data files to relational db.
	D GBLLOOP("G",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS,"DAT")
	I 'initEnv d eConstrt^TBXSQL 
	D:(initEnv) LOADCVAR
	;
	d SQLLOOP(OWCUST,OWFIX,ISVMS,ISNFS)
	;	
	; Load remaining DATA QWIK elements
	D ELLOOP("AGR",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("BATCH",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("EXC",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("FPP",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("FKY",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("IDX",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("JFD",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("LUD",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("PPL",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("PROC",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("QRY",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS) 
	D ELLOOP("RMP",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("RPT",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("SCR",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	D ELLOOP("TRIG",OWCUST,OWFIX,.TYPES,ISVMS,ISNFS)
	;
	D:(db'="GTM") UPDRDB^TBXSQL		; create objects in RDB.
	;
	k commands("boot","restrictionlevel")
	;
	d sqllog^TBXSQL(PVB("BUILD"))
	Q	
	;
GBLLOOP(TYPE,OWCUST,OWFIX,TYPES,ISVMS,ISNFS,FTYPE)	
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
	I $D(^TMP($J,"LOAD",FOLDER)) d logmsg^TBXDQUTL("Processing data for type : "_FTYPE,zlogf)
	E  Q
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	.	;
	.	Q:$P(FILE,".",2)'=FTYPE		; if file extension don't match quit.
	.	I '$$FIXPACK(FILE,OWFIX) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved","",ISVMS,ISNFS)
	.	D ITEM(FILE,FOLDER,RTN,PARENT,OWCUST,OWFIX,ISVMS,ISNFS)
	.	I ER W !,RM S ER=0,RM=""
	.	K ^TMP($J,"LOAD",FOLDER,FILE)
	;
	Q
	;
	;	
	;---------------------------------------------------------------------
ELLOOP(TYPE,OWCUST,OWFIX,TYPES,ISVMS,ISNFS)	; Generic element loop
	;---------------------------------------------------------------------
	;
	; Loop through the elements of a folder and process. All elements other 
	; than table headers and columns are processed in this section.
	;
	N FILE,X,FOLDER,PARENT,RTN
	s ER=0,RM=""
	;
	S FOLDER=$P(TYPES(TYPE),"|",1)
	S RTN=$P(TYPES(TYPE),"|",2)
	S PARENT=$P(TYPES(TYPE),"|",3)
	;
	I $D(^TMP($J,"LOAD",FOLDER)) d logmsg^TBXDQUTL("Processing folder "_FOLDER,zlogf)
	E  Q
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	.	;
	.	I '$$FIXPACK(FILE,OWFIX) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved","",ISVMS,ISNFS)
	.	D ITEM(FILE,FOLDER,RTN,PARENT,OWCUST,OWFIX,ISVMS,ISNFS)
	.	I ER W !,RM S ER=0,RM=""
	;
	K ^TMP($J,"LOAD",FOLDER)
	Q
	;
	;---------------------------------------------------------------------
ITEM(FILE,FOLDER,RTN,PARENT,OWCUST,OWFIX,ISVMS,ISNFS)	; Process one item
	;---------------------------------------------------------------------
	;
	N USER,DATE,TIME
	;
	S USER=$P(^TMP($J,"FILE",FILE),"|",2)
	S DATE=$P(^TMP($J,"FILE",FILE),"|",3)
	S TIME=$P(^TMP($J,"FILE",FILE),"|",4)
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
	; Read file contents into the CODE array.
	D READFILE(PARENT,FOLDER,"",FILE,.CODE,ISVMS,ISNFS)
	;
	; Load element 
	I 'ER D
	.	D logmsg^TBXDQUTL("Loading "_FOLDER_" definition "_FILE,zlogf,1)
	.	S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,PACKTYPE,USER,DATE,TIME)"
	.	X CMD
	;
	I ER D  Q
	.	D ERROR
	.	D REJECT(FOLDER,FILE,RTN,"Not Loaded: "_$G(RM),"",ISVMS,ISNFS)
	.	S ER=0,RM=""
	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;
	Q
	;
	;
	;---------------------------------------------------------------------
TBLLOOP(OWCUST,OWFIX,ISVMS,ISNFS)	; Table and column loop
	;---------------------------------------------------------------------
	;
	; Loop through the table (TBL) and column (COL) files and process.
	; The array is processed in reverse order to endure that a table's
	; header file is processed before it's columns. The naming convention
	; for these files ensures this order.
	;
	N FILE,X,TYPE,TABLE,USER,DATE,TIME,REVISION,FOLDER,RTN
	;
	S FOLDER="table"
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE),-1) Q:FILE=""!ER  D
	.	;
	.	N CODE
	.	S TYPE=$P(FILE,".",2)
	.	S RTN=$S(TYPE="COL":"TBXCOL",1:"TBXTBL")
	.	S TABLE=$$LOWER^%ZFUNC($P($P(FILE,"-",1),".",1))
	.	I '$$FIXPACK(FILE,OWFIX) D  Q	
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved","",ISVMS,ISNFS)
	.	;
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
	.	;
	.	; Read file contents into the CODE array.
	.	D READFILE("dataqwik","table",TABLE,FILE,.CODE,ISVMS,ISNFS)
	.	I 'ER D
	..		D logmsg^TBXDQUTL("Loading table definition "_FILE,zlogf,1)
	..		I TYPE="COL" S X=$$LOAD^TBXCOL(.CODE,FILE,PACKTYPE,USER,DATE,TIME)
	..		I TYPE="TBL" S X=$$LOAD^TBXTBL(.CODE,FILE,PACKTYPE,USER,DATE,TIME)
	.	I ER D  Q
	..		D ERROR
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: "_$G(RM),"",ISVMS,ISNFS)
	..		S ER=0,RM=""
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	Q
	;
	;---------------------------------------------------------------------
RTNLOOP(OWCUST,OWFIX,ISVMS,ISNFS)	; Copy routines to target
	;---------------------------------------------------------------------
	;
	N FILE,FOLDER,CFLAG,NOCOMP,RTN,PATH,TMPPATH,PPATH
	;
	S NOCOMP("TBXDRV.M")=""
	S NOCOMP("TBXRTN.M")=""
	S NOCOMP("SCADRV.M")=""
	S NOCOMP("SCADRV0.M")=""
	S NOCOMP("DRV.M")=""
	S NOCOMP("%OSSCRPT.M")=""
	;
	S FILE=""
	;
	S RTN="TBXRTN",ER=0,RM=""
	;
	; we need to load common % routine and platform specified % routine
	F FOLDER="percent_routine",$S($ZV["VMS":"vms",1:"unix") D
	.	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Loading percent routines",zlogf,1)
	.	;
	.	S TMPPATH=FOLDER,PPATH="percent_routine"
	.	S:ISVMS&ISNFS TMPPATH=$$NFSVMS^TBXDQUTL(TMPPATH),PPATH=$$NFSVMS^TBXDQUTL(PPATH)
	. 	I (FOLDER="unix")!(FOLDER="vms") S TMPPATH="["_PPATH_"."_TMPPATH_"]" 
	.	E  S TMPPATH="["_PPATH_"]" 
	.	S TMPPATH=$$appdir^TBXDQUTL(INSTDIR,TMPPATH)					; Source directory
	.	;
	.	S FILE="" F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	..		I '$$FIXPACK(FILE,OWFIX) D  Q
	...			D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved",TMPPATH,ISVMS,ISNFS)
	..		;
	..		S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	..		S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	..		S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	..		S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	..		S CFLAG=$D(NOCOMP($$UPPER^%ZFUNC(FILE)))
	..		;
	..		D logmsg^TBXDQUTL("Loading "_FOLDER_" "_FILE,zlogf,1)
	..		S ER=$$LOADPRTN^TBXRTN(FILE,"",TMPPATH,PCNTDIR,1,1)
	..		I ER D  Q
	...			D ERROR
	...			D REJECT(FOLDER,FILE,RTN,"Not loaded: "_$G(RM),TMPPATH,ISVMS,ISNFS)
	...			S ER=0,RM=""
	..		D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;
	S FOLDER="routine",FILE="",ER=0
	;
	S TMPPATH=$S(((ISVMS)&(ISNFS)):$$NFSVMS^TBXDQUTL(FOLDER),1:FOLDER)
	S TMPPATH=$$appdir^TBXDQUTL(INSTDIR,"["_TMPPATH_"]")					; Source directory
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Loading routines",zlogf)
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	.	I '$$FIXPACK(FILE,OWFIX) D  Q
	..		D REJECT(FOLDER,FILE,RTN,"Not Loaded: Fix pack version preserved",TMPPATH,ISVMS,ISNFS)
	.		;
	.	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	.	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	.	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	.	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	.	;
	.	S CFLAG=$D(NOCOMP($$UPPER^%ZFUNC(FILE)))	
	.	D logmsg^TBXDQUTL("Loading "_FOLDER_" "_FILE,zlogf,1)
	.	S ER=$$LOAD^TBXRTN(FILE,"",TMPPATH,"MRTNS",1,1)
	.	I ER D  Q
	..		D ERROR
	..		D REJECT(FOLDER,FILE,RTN,"Not loaded: "_$G(RM),TMPPATH,ISVMS,ISNFS)
	..		S ER=0,RM=""
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Loaded")
	;	
	Q
	;---------------------------------------------------------------------
COMPARE	; Compare new build contents with current build contents
	;---------------------------------------------------------------------
	;
	; This function compares the contents of the new build with 
	; what is currently in the Profile Runtime Environment. The
	; differences are stored in ^TMP($J,"LOAD".
	;
	N FILE,REC
	S FILE=""
	F  S FILE=$O(^TMP($J,"FILE",FILE)) Q:FILE=""  D
	.	S REC=^TMP($J,"FILE",FILE)
	.	;
	.	; Compare individual file elements
	.	; Skip files that match if there is no 
	.	; fix pack version
	.	; I '$D(^TBXFIX(FILE)),(REC=$G(^TBXINST(FILE))) Q
	.	I '$D(^TBXFIX(FILE)),($$isMatch(REC,FILE)) Q
	.	;
	.	; Create load records for mismatched files
	.	S FOLDER=$P(REC,"|",5)
	.	S ^TMP($J,"LOAD",FOLDER,FILE)=REC
	Q
	;
	;---------------------------------------------------------------------
UNMASK(MASKDATE,JD,JT)	; Convert masked date and time to julian format
	;---------------------------------------------------------------------
	;
	N dateStr,dd,mm,time
	;
	S dateStr=$P(MASKDATE," ",1)
	S dd=$P(dateStr,"/",1)
	s mm=$P(dateStr,"/",2)
	; 
	; it needs to supply 2 digit day and month to the utility.
	i dd<10 s $P(dateStr,"/",1)="0"_dd
	i mm<10 s $P(dateStr,"/",2)="0"_mm
	s JD=$$date^UCGMCU(dateStr,"MM/DD/YEAR")
	;
	s time=$TR($P(MASKDATE," ",2,3)," ","")
	s JT=$$time^UCGMCU(time)
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
	N SEQ,REC,PROJECT,VIEW,BUILD,REVISION,USER,DATE,TIME,ER,CODE
	;
	S ER=0
	S PROJECT=PVB("PROJECT")
	S VIEW=PVB("VIEW")
	S BUILD=PVB("BUILD")
	S REVISION=$P(^TMP($J,"FILE",FILE),"|",1)
	S USER=$P(^TMP($J,"FILE",FILE),"|",2)
	S DATE=$P(^TMP($J,"FILE",FILE),"|",3)
	S TIME=$P(^TMP($J,"FILE",FILE),"|",4)
	S TYPE=$P(FILE,".",2)
	;
	; optional variable FPATH are only for non dataqwik or global elements
	; if element is either global or dataqwik, FPATH is null
	I $G(FPATH)'="" S CODE(1)=FPATH
	I $G(FPATH)="" D
	.	I ($P(FILE,".",2)="COL")!($P(FILE,".",2)="TBL") D READFILE("dataqwik","table",TABLE,FILE,.CODE,ISVMS,ISNFS) Q
	.	S PARENT=$P(TYPES($P(FILE,".",2)),"|",3)
	.	D READFILE(PARENT,FOLDER,"",FILE,.CODE,ISVMS,ISNFS) Q:$G(ER)
	;
	K ^TBXREJ(FOLDER,FILE)
	S $P(REC,"|",1)=REVISION
	S $P(REC,"|",2)=USER
	S $P(REC,"|",3)=DATE
	S $P(REC,"|",4)=TIME
	S $P(REC,"|",5)=PROJECT
	S $P(REC,"|",6)=VIEW
	S $P(REC,"|",7)=BUILD
	S $P(REC,"|",8)=RTN
	S $P(REC,"|",9)=+$H
	S $P(REC,"|",10)=$P($H,",",2)
	S $P(REC,"|",11)=%LOGID		; User who performed action
	;S $P(REC,"|",12)=$G(MSG)
	S $P(REC,"|",12)=$E($G(MSG),1,500)	; PATCH ** badri ** 
	;
	S ^TBXREJ(FOLDER,FILE)=REC
	;
	S SEQ=""
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  S ^TBXREJ(FOLDER,FILE,SEQ)=CODE(SEQ)
	;
	D LOG^TBXSPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,$G(MSG))
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
	S $P(REC,"|",5)=PVB("BUILD")
	S $P(REC,"|",6)=REVISION
	S $P(REC,"|",7)=USER
	S $P(REC,"|",8)=DATE
	S $P(REC,"|",9)=TIME
	S $P(REC,"|",10)=MSG
	S $P(REC,"|",11)=%LOGID		; User who performed action
	S $P(REC,"|",12)=$P($H,",",2)	; Time of event
	;
	S SEQ=$O(^TBXLOG(+$H,""),-1)+1
	S ^TBXLOG(CURDATE,SEQ)=$e(REC,1,400)
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
COPYINST(PVB)	; Copy new build information to ^TBXINST
	;---------------------------------------------------------------------
	;
	N CURDATE
	S CURDATE=+$H
	K ^TBXINST
	S $P(^TBXINST,"|",1)=PVB("PROJECT")
	S $P(^TBXINST,"|",2)=PVB("VIEW")
	S $P(^TBXINST,"|",3)=PVB("BUILD")
	S $P(^TBXINST,"|",4)=%LOGID
	S $P(^TBXINST,"|",5)=+$H
	;
	N FILE,REC
	S FILE=""
	F  S FILE=$O(^TMP($J,"FILE",FILE)) Q:FILE=""  D
	.	S REC=^TMP($J,"FILE",FILE)
	.	S ^TBXINST(FILE)=REC
	;
	Q
	;
	;---------------------------------------------------------------------
WARN	; Preach about the use of backups, screen captures use of caution
	;---------------------------------------------------------------------
	;
	N %READ,%NOPRMT,HDG,LINE1,LINE2,LINE3,LINE4,LINE5,LINE6
	;
	S HDG="NOTICE"
	S LINE0="  ***   YOU ARE IN "_$ZDIR_"   ***"
	S LINE1="You are about to load a full build into this Profile Runtime"
	S LINE2="Environment. All database and program files should be"
	S LINE3="backed-up before proceeding. If your terminal emulator supports"
	S LINE4="screen capture, we strongly recommended you enable it now."
	S LINE5="Refer to the Profile Software Installation Instructions for"
	S LINE6="more details on how to use this function."
	;
	S %READ="@HDG/CEN/REV,,@LINE0/CEN,@LINE1/CEN,@LINE2/CEN,@LINE3/CEN,@LINE4/CEN,,,@LINE5/CEN,@LINE6/CEN"
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
FIXPACK(FILE,OWFIX)	; Check for Fix Pak revision of the element
	;---------------------------------------------------------------------
	;
	;	Extrinsic return 0 - Do not overwrite
	;			 1 - Overwrite
	;
	;
	N NEW,OLD,MSG,ANS
	;
	; Check for the existance of a fix version of this element
	I '$D(^TBXFIX(FILE)) Q 1
	;
	; If user answered Yes to overwrite fixes, remove fix record and load
	I OWFIX D  Q 1
	.	K ^TBXFIX(FILE)
	;
	; If the fix element matches the revision in the service pack, remove 
	; the fix record and load
	I $P(^TMP($J,"FILE",FILE),"|",1,4)=$P(^TBXFIX(FILE),"|",1,4) D  Q 1
	.	K ^TBXFIX(FILE)
	;
	; The fix pack revision does not match the service pack revision.
	; Display information about the file and prompt to continue
	S NEW("REVISION")=$P(^TMP($J,"FILE",FILE),"|",1)
	S NEW("USER")=$P(^TMP($J,"FILE",FILE),"|",2)
	S NEW("DATE")=$P(^TMP($J,"FILE",FILE),"|",3)
	S NEW("TIME")=$P(^TMP($J,"FILE",FILE),"|",4)
	;
	S OLD("REVISION")=$P(^TBXFIX(FILE),"|",1)
	S OLD("USER")=$P(^TBXFIX(FILE),"|",2)
	S OLD("DATE")=$P(^TBXFIX(FILE),"|",3)
	S OLD("TIME")=$P(^TBXFIX(FILE),"|",4)
	S OLD("CR")=$P(^TBXFIX(FILE),"|",7)
	;
	S MSG="Element "_FILE_" was loaded from a fix pack for CR "_OLD("CR")_$C(13,10)
	S MSG=MSG_"Current revision = "_OLD("REVISION")_$C(9)_OLD("USER")_$C(9)_$$^%ZD(OLD("DATE"))_$C(13,10)
	S MSG=MSG_"    New revision = "_NEW("REVISION")_$C(9)_NEW("USER")_$C(9)_$$^%ZD(NEW("DATE"))_$C(13,10)_$C(13,10)
	d logmsg^TBXDQUTL(MSG,zlogf)
	;
	S ANS=$$PROMPT("Do you want to replace the current revision with the new revision")
	I ANS D  Q 1
	. K ^TBXFIX(FILE)
	;
	Q 0
	;
	;---------------------------------------------------------------------
OBSLOOP	; Obsolete elements loop
	;---------------------------------------------------------------------
	;
	; Loop through the obsoleted element list and 
	;
	N FILE,X,TYPE,TABLE,USER,DATE,TIME,REVISION,FOLDER,RTN,CMD,ETYPE
	;
	S FOLDER="obsolete"
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE),-1) Q:FILE=""  D
	.	
	.	I $D(^TBXFIX(FILE)),$P($G(^TBXFIX(FILE)),"|",5)="obsolete" Q			; file already obsoleted by a FP
	.	I $D(^TBXFIX(FILE)),'$$OBSPROM(FILE) Q
	.	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	.	D logmsg^TBXDQUTL("Obsoleting "_FILE,zlogf,1)
	.	S TYPE=$$UPPER^%ZFUNC($P(FILE,".",2))
	.	S REVISION=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",1)
	.	S USER=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",2)
	.	S DATE=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",3)
	.	S TIME=$P(^TMP($J,"LOAD",FOLDER,FILE),"|",4)
	.	I $D(TYPES(TYPE)) D
	..		S RTN=$P(TYPES(TYPE),"|",2)				
	..		I TYPE="M" S CMD="S X=$$OBSRTN^TBXRTN(FILE)"	  	; obsolete routines
	..		I (TYPE="G")!(TYPE="DAT") S CMD="S X=$$OBSGBL^TBXDATA(FILE)"  		; obsolete data
	..		I '((TYPE="M")!(TYPE="G")!(TYPE="DAT")) S CMD="S X=$$OBSDQW^"_RTN_"(FILE)"	; obsolete DQs
	..		X CMD
	.	; I '$D(TYPES(TYPE)) S X=$$OBSRTN^TBXSFILE(FILE,INSTDIR)		; Obsolete system files
	.	i TYPE="SQL" d obsscrpt^TBXSQL(FILE)
	.	D LOG(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,"Obsoleted")
	K ^TMP($J,"LOAD",FOLDER)						; deleted obsoleted files
	Q
	;
	;---------------------------------------------------------------------
SFLOOP(ISVMS,ISNFS)	; Load system files
	;---------------------------------------------------------------------
	;
	; Loop through the system files list  
	;
	N FOLDERS,FILE,RTN,TMPPATH,PPATH,HELLO
	;
	S RTN="TBXSFILE",ER=0,RM=""
	;
	F FOLDER="com","doc","exp","gog","help","uxscrpt","ini" D
	.	I (ISVMS)&(FOLDER="uxscrpt") D logmsg^TBXDQUTL("Skipping "_FOLDER,zlogf,1) Q 	; don't load unix script if platform is vms
	.	I ('ISVMS)&(FOLDER="com") D logmsg^TBXDQUTL("Skipping "_FOLDER,zlogf,1) Q	; don't load command procedure if platform is unix
	.	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf,1)
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
	..		D logmsg^TBXDQUTL("Loading "_FILE,zlogf,1)
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
	.	K ^TMP($J,"LOAD",FOLDER)	
	Q	;
	;
	;-----------------------------------------------------------------------
ZERROR	;  Exception handler code. 
	;-----------------------------------------------------------------------
	; 
	u $p 
	w !,"Fatal error during service pack installation",! 
	S Z=$ZSTATUS,LOC=$P(Z,",",2),TXT=$P(Z,",",3),MSG=$P(Z,",",4,$L(Z,",")) 
	w "Location: "_LOC,! 
	w "GTM code: "_TXT,! 
	w "Message: "_MSG,! 
	w !,"Current stack information:",!				; dump stack to log file	
	zsh
	w !
	zwr 
	d CLEAN 
	h 
	Q 
	; 
	;-----------------------------------------------------------------------
GETDIRS(INSTDIR,DIRLIST);	Pre processor to return subdirectory 
	;-----------------------------------------------------------------------
	;
	N X,Y
	D CHKDIR^TBXDQUTL(INSTDIR)
	I $G(ER) Q
	K DIRLIST				
	S OUT=INSTDIR_"/*"
	S:ISVMS OUT=INSTDIR_"*.DIR"
	S Y=0 
	F  S X=$ZSEARCH(OUT) Q:X=""  S Y=Y+1,DIRLIST(Y)=$ZPARSE(X,"NAME")
	Q
	;------------------------------------------------------------------------
SPDIRS(INDEX,DIRLIST);	Post processor to return the value. This is to prevent the  
	;	     the first column of the drop down list being limited to 12
	;	     characters long. It takes the key as an argument and return
	;	     the description field.
	;------------------------------------------------------------------------
	;
	I '$D(DIRLIST(INDEX)) Q INDEX
	S DIRLIST(DIRLIST(INDEX))=DIRLIST(INDEX)
	Q DIRLIST(INDEX)
	;
	;------------------------------------------------------------------------
OBSPROM(FILE);	
	; Prompt user to see what to do with the obsolete element
	;------------------------------------------------------------------------
	N MSG
	S MSG="Element "_FILE_" was loaded from a fix pack for CR "_$P(^TBXFIX(FILE),"|",7)
	D logmsg^TBXDQUTL(MSG,zlogf)
	Q $$PROMPT("Do you want to obsolete this element?")
	;
LOADCVAR;	install CUVAR to RDB when in initial environment 
	; 
	;	
	n dir,X,CODE,IO
	s IO=$$TRNLNM^%ZFUNC("SCAU_DIR")_"/CUVAR.DAT"
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q
	U IO
	F  Q:$ZEOF  D
	.	R LINE
	.	I $ZEOF Q
	.	S CODE($O(CODE(""),-1)+1)=LINE
	U 0
	C IO
	;
	d logmsg^TBXDQUTL("Loading CUVAR.DAT",zlogf)
	S X=$$LOAD^TBXDATA(.CODE,"CUVAR.DAT",2,%LOGID,+$H,$P($H,",",2))
	Q	
	;
	;---------------------------------------------------------------------
SQLLOOP(OWCUST,OWFIX,ISVMS,ISNFS)	; Copy routines to target
	;---------------------------------------------------------------------
	;
	N FILE,FOLDER,PATH,TMPPATH,connstr,sqlfile,cmd,ok,count
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
	I initEnv u sqlfile w "@"_$$appdir^TBXDQUTL(INSTDIR,"[scripts]")_"UTILITY_PROGRAMS.sql",!,"/",!
	;
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	I '$$FIXPACK(FILE,OWFIX) D  Q
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
	;
isMatch(REC,FILE)	
	;	
	n tmpstr,tmpstr1
	s tmpstr=REC,tmpstr1=$G(^TBXINST(FILE))
	s $P(tmpstr,"|",2)="",$P(tmpstr1,"|",2)=""
	Q $S(tmpstr'=tmpstr1:0,1:1)		
	;
	;
init	;***********************************************************************
	; Purpose: Initialize variables to be used in installation
	;***********************************************************************
	;
	; S %LOGID=$$LOGID^SCADRV
	S %LOGID=$$USERNAM^%ZFUNC
	S %="|"
	;
	S $ZTRAP="D ZERROR^TBXSPIN",ER=0,RM=1
	;
	S ISVMS=($P($ZVER," ",3)="VMS")
	;
	S db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	;
	s dqvn7=0
	;	
	i initEnv d
	.	s dqv=$$GETVAR^TBXDQUTL()
	. i dqv=0 s ER=1,RM="Error: %VN is not defined in release.dat file."
	. S:dqv'<"7.0" dqvn7=1
	e  d 
	. s dqv=$$GETVN^TBXDQUTL()
	.	Q:ER
	.	S:dqv'<"7" dqvn7=1
	Q
	;
