TBXINST	;;	Profile Software Installation Driver
	;
	; Original: Jaywant Khairnar - 2009-06-12
	;
	; This routine is to support the automatic builds.
	; This routine is responsible for loading Service and Fix
	; Packs into a Profile runtime environment.
	;
	;-------- Comments -----------------------------------------------------
	; This is used for Service pack, fix pack installation.
	; Provide transparant support for multiple layers of software, 
	; a separate TBXBUILD table is created, which maps
	; to ^TBXBUILD(PRIO) as follows: 
	;	PRIO : Priority of the build element with
	;		*  0 : Last fixpack installed
	;		* 10 : Framework element,
	;		* 20 : Application element
	;		* 30 : Custom element
	;	Piece info of ^TBXBUILD(PRIO)
	;	1 : Descriptive name of build (application, framework or custom)
	;	2 : project
	;	3 : view
	;	4 : build for service pack and CR number for fix pack
	;	5 : user
	;	6 : date
	;	7 : build status (0- sucessful,1- in progress,2- fatal error)
	; Just like the standard Framework Version 3 package structure, in which
	; the search order is: custom overwrites application overwrites
	; framework, the element with higher priority is getting installed.
	;
	;-------- Revision History ---------------------------------------------
	; 2009-06-12, CR40964, Jaywant Khairnar
	;	* provide support for TBX autobuild ,FP & SP installation
	;	* added changes for bootstrap issue
	;	* added date in the log file name
	;
	Q
	;---------------------------------------------------------------------
install(BUILDS,initEnv,INSTDIR,OWCUST,OWFIX)	; external entry
	;---------------------------------------------------------------------
	; Public subroutine to perform a Fix Pack or Service Pack install.
	; This subroutine assumes that all pre-conditions are satisfied:
	; * ^dbtbl exists if relevant
	; * Rejects have been processed
	;
	; ARGUMENTS:
	; . BUILDS - local array stores the type of build to be installed.
	; . initEnv - 1 means initial environment
	; . INSTDIR - installation directory
	; . OWCUST - overwrite customized DQ element.
	; . OWFIX - overwrite fix pack for fix pack it will be 0
	; RETURN PARAMETERS:
	; . status
	;	0 - sucess
	;	1 - failure
	;	Note : status code value should be between 0 to 255		
	; . zlogf - log file name
	;
	N %,%LOGID,db,PVB,PACKTYPE,PRIO,PROMPT,SUB,zlogf
	; initialise the variables used during the installation.
	;
	d init(.BUILDS,.%,.%LOGID,.db,.PACKTYPE,.zlogf)		
	;
	I ER D CLEAN(.zlogf) Q 1	; Cleanup potentail left-overs
	;
	; check structure of ^TBXINST 
	; if it has 2 subscripts then convert it to 1 subscript which is FILE.
	;
	S SUB=$o(^TBXINST(""))
	I SUB]"",$D(^TBXINST(SUB))>9 D CONVERT()
	;
	; Find last build loaded info.
	;
	D GETCUR(.CURPVB,.BUILDS) 
	I ER D CLEAN(.zlogf) Q 1	; Cleanup potentail left-overs
	;
	; Parse Release Directory to identify the project, view and build 
	; number (or CR number if it is a fix pack)
	;
	S PRIO=""
	F  S PRIO=$O(BUILDS(PRIO)) Q:(PRIO="")!(ER)  D GETCONT(BUILDS(PRIO),.PVB,PACKTYPE,PRIO) 
	; leave the installtion for any error in GETCONT
	I ER D CLEAN(.zlogf) Q 1	; Cleanup potentail left-overs
	;
	; No build element available to process then 
	; cleanup potentail left-overs
	;
	I '$D(^TMP($J)) S ER=1,RM="Can not find build in "_INSTDIR_"." D CLEAN(.zlogf) Q 1	
	;
	I PACKTYPE=1 D		; for service pack it checks the view to be installed.
	.	S PROMPT=1
	.	I 'initEnv D
	..		S PRIO="" F  S PRIO=$O(PVB(PRIO)) Q:PRIO=""  D
	...			I PVB(PRIO,"VIEW")'=$G(CURPVB(PRIO,"VIEW")) S PROMPT=$$PROMPT("View "_PVB(PRIO,"VIEW")_" differs from view of previous build. Continue")
	.	I 'PROMPT Q
	;
	S RM="Installation of"
	S PRIO="" F  S PRIO=$O(BUILDS(PRIO)) Q:PRIO=""  S RM=RM_" build "_PVB(PRIO,"BLD")_" and "
	S RM=$E(RM,1,($L(RM)-4))
	D logmsg^TBXDQUTL(RM,zlogf)
	;
	; Compare service pack contents with last loaded service pack
	;
	D:PACKTYPE=1 COMPARE()
	;
	; Install Started flag is set
	;
	S PRIO="" F  S PRIO=$O(BUILDS(PRIO)) Q:PRIO=""  S $P(^TBXBUILD(PRIO),"|",7)=1
	;
	; Loads the elements from the pack
	;
	D LOAD(.BUILDS,.PVB,OWCUST,OWFIX,PACKTYPE,db,initEnv)
	I ER D ERROR(),CLEAN(.zlogf) Q 1
	;
	; logs the current build information, also records entries in
	; TBXBUILD,TBXINST,TBXFIX globals
	;
	D COPYINST(.PVB,PACKTYPE)
	;
	; sets the TBXLOAD global entry
	;
	S PRIO="" F  S PRIO=$O(PVB(PRIO)) Q:PRIO=""  S ^TBXLOAD($S(PRIO=0:"FP",1:"SP"),PVB(PRIO,"BLD"),$P(%LOGID,"|",2),+$H,$P($H,",",2))=""
	;
	; Compile all loaded elements
	;
	D COMPALL^TBXDQUTL(zlogf)
	I ER D CLEAN(.zlogf),ERROR() Q 1
	;
	; installation completed flag is set
	;
	S PRIO="" F  S PRIO=$O(BUILDS(PRIO)) Q:PRIO=""  S $P(^TBXBUILD(PRIO),"|",7)=0
	;
	S RM="Installation of"
	S PRIO="" F  S PRIO=$O(BUILDS(PRIO)) Q:PRIO=""  S RM=RM_" build "_PVB(PRIO,"BLD")_" and "
	S RM=$E(RM,1,($L(RM)-4))_" completed"
	;
	I $D(^TBXREJ) d logmsg^TBXDQUTL("**** Run report TBXREJ to review reject file",zlogf)
	D logmsg^TBXDQUTL(RM,zlogf)
	D CLEAN(.zlogf)
	Q 0
	;
	;---------------------------------------------------------------------
CLEAN(zlogf)	; Cleanup potentail left-overs
	;---------------------------------------------------------------------
	;
	S ER=0
	K ^TMP($J),^TMPDQS($J),TMPSQL($J)
	I $D(zlogf),zlogf'=0 c zlogf		; close log file, if it is open
	;
	Q
	;
	;---------------------------------------------------------------------
GETCUR(CURPVB,BUILDS)	; Get previous build info from environment
	;---------------------------------------------------------------------
	; Retrieve the build info currently stored for all builds (Framework,
	; Application, Custom and Fixpack)
	;
	; ARGUMENTS:
	; . CURPVB - local array to store the previous build info
	; . BUILDS - local array stores the type of build to be installed.
	;
	N ER,INFO,PRIO,RM
	;
	S ER=0	
	; checks if previous installation for selected build priority is sucessful or not
	;
	S PRIO="" F  S PRIO=$O(^TBXBUILD(PRIO)) Q:PRIO=""  D  
	.	S INFO=^TBXBUILD(PRIO)
	.	;
	.	; Check the processing flag on the last build 
	.	;	processing flag: 0 - Complete
	.	;			 1 - Started
	.	;			 2 - Fatal error during load
	.	;
	.	; generates the log message for build load failure
	.	;
	.	I $P(INFO,"|",7) D   ; checks the build load status
	..		S ER=1
	..		S RM="Previous build "
	..		S RM=RM_$P(INFO,"|",4)_" not fully loaded."
	..		D logmsg^TBXDQUTL(RM,zlogf)  
	.	I $D(BUILDS(PRIO)) D
	..		S CURPVB(PRIO,"PROJ")=$P(INFO,"|",2)		; previous project
	..		S CURPVB(PRIO,"VIEW")=$P(INFO,"|",3)		; previous view
	..		S CURPVB(PRIO,"BLD")=$P(INFO,"|",4)		; previous build
	;
	Q
	;
	;---------------------------------------------------------------------
GETCONT(INPUTDIR,PVB,PACKTYPE,PRIO)	; Read build contents file
	;---------------------------------------------------------------------
	; reads the build (for SP) or CR (for FP) content file
	; stores the details in ^TMP($J, global
	; from this ^TMP($J global the elements are processed
	;
	; ARGUMENTS:
	; . INPUTDIR - directory path for build or CR content file
	; . PVB - local array to store the build info from the content file
	; . PACKTYPE - Type of installation
	;	1 - service pack
	;	2 - fix pack
	; . PRIO - priority of application -10/framework -20/custom -30/fix pack -0
	;
	N HEADER,IO,REC,X
	;
	; service pack will have priority more than 0
	;
	I PACKTYPE=1 S IO=$$appdir(INPUTDIR,"release_doc")_"build_contents.txt"  	; service pack release directory
	I PACKTYPE=2 S IO=$$appdir(INPUTDIR,"")_"CR_contents.txt"					; fix pack release directory
	;
	; A custom header is prepended to the build contents document 
	; during deployment.
	;
	S X=$$FILE^%ZOPEN(IO,"READ")		; tries to open the build_content file
	I 'X S ER=1,RM=$P(X,"|",2) Q		; set error for not opening the file for reading
	;
	U IO
	I $ZEOF U 0 S ER=1,RM=IO_"file missing"	; checks the end of file 	
	R HEADER				; reads the file header
	;
	; Fix Pack header starts with "#"
	;
	S:$E(HEADER)="#" HEADER=$E(HEADER,2,$L(HEADER))
	;
	; sets info for current pack installation
	;
	S PVB(PRIO,"PROJ")=$P(HEADER,"|",1)	; current pack project
	S PVB(PRIO,"VIEW")=$P(HEADER,"|",2)	; current pack view
	S PVB(PRIO,"BLD")=$P(HEADER,"|",3) 	; current pack Build or CR number
	;
	; This section expects the build_contents.txt file to be in a specific
	; format. If StarBase changes the format of the this file, this code
	; must be changed accordingly.
	;
	N DATE,INSTTYP,FILE,FOLDER,REVISION,TIME,TYPE,USER
	;
	U IO
	;	
	; reads each record from content file till the end of file
	;
	F  Q:$ZEOF  R REC D		
	.	I REC="" Q				; dont process the balnk record
	.	I REC=$C(13) Q		
	.	S FILE=$P(REC,"|",1)			; element name with its extension
	.	S TYPE=$P(FILE,".",2)
	.	S FOLDER=$P(REC,"|",2)			; folder name for the element
	. ;	I FOLDER="custom" Q			; now the custom elements are also processed
	.	I (TYPE="m")&(FOLDER="rtns") Q		; don't include external calls
	.	I FOLDER'="obsolete" D			; exclude the obsolete element
	..		;
	..		; COL and TBL elements from folders other than "table"
	..		; are processed under "table" folder and saved accordingly on target
	..		;
	..		I (TYPE="COL")!(TYPE="TBL") S FOLDER="table"
	.	S REVISION=$P(REC,"|",3)		; element revision number
	.	D UNMASK($$TRIM^%ZS($P(REC,"|",4)),.DATE,.TIME) ; Convert masked date and time to julian format
	.	S USER=$$TRIM^%ZS($P(REC,"|",5))	; user name who worked on it
	.	;
	.	; For SP, COMPARE() will move the entries to be loaded to ^TMP($J,"LOAD") 
	.	; as service pack will have all elements which may not be required to load 
	.	; as same version might be loaded in previous version 
	.	; For FP, COMPARE() is not called as there will be few elements, 
	.	; so put them in ^TMP($J,"LOAD") here
	.	;
	.	I PACKTYPE=1 S ^TMP($J,"FILE",FILE,PRIO)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER_"|"_+$H_"|"_PVB(PRIO,"BLD")
	.	I PACKTYPE=2 S ^TMP($J,"LOAD",FOLDER,FILE,PRIO)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER_"|"_+$H_"|"_PVB(PRIO,"BLD")
	;
	U 0
	C IO
	Q
	;
	;---------------------------------------------------------------------
LOAD(BUILDS,PVB,OWCUST,OWFIX,PACKTYPE,db,initEnv)
	;---------------------------------------------------------------------
	; loads the elements
	;
	; ARGUMENTS:
	; . BUILDS - local array having build install directory info 
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	; . OWCUST - overwrite customized elements
	; . OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	; 	2 - fix pack
	; . db - database default is GTM
	; . initEnv - 1 means initial environment	
	;
	N commands,FOLDER,PRIO,STR,TYPES
	;
	; Build file type information array
	;
	D TYPEINIT(.TYPES)
	;
	; Obsolete elements
	;
	D:'initEnv OBSLOOP(OWFIX,OWCUST,PACKTYPE)
	D:('initEnv)&(db'="GTM") OBSTABLE^TBXSQL
	;
	; Load routines and ZLINK modules that might be used
	;
	D RTNLOOP(.BUILDS,OWCUST,OWFIX,PACKTYPE,.PVB)
	;
	; setup a temp global for PSL and Framework elements
	;
	D LOADINT($G(BUILDS(10))) 
	I $$VALID^%ZRTNS("USTMAPDF") ZLINK "USTMAPDF"
	D linkPreBoot^UCGMCU()
	;
	; Load PSLX files. Required Framework CR28700
	;
	D PSLXLOOP(.BUILDS,OWCUST,OWFIX,PACKTYPE,.PVB)
	;
	; Load system files
	;
	D SFLOOP(.BUILDS,OWCUST,OWFIX,PACKTYPE,.PVB) 	
	;
	; install M global first
	;
	D ELLOOP(.BUILDS,"G",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	;
	; Load table and column definitions
	;
	D TBLLOOP(.BUILDS,OWCUST,OWFIX,PACKTYPE,.PVB)
	;
	D logmsg^TBXDQUTL("All tables loaded.",zlogf)
	D logmsg^TBXDQUTL("Rebuilding data item control index for all tables",zlogf)
	D
	.	N X S X=""
	.	F  S X=$O(^DBTBL("SYSDEV",1,X)) Q:X=""  D BLDINDX^DBSDF9(X)
	;
	; for the database other than GTM i.e. for Oracle and in future DB2 will
	; also be covered
	;
	I (db'="GTM") D
	. D logmsg^TBXDQUTL("Loading tables to RDB",zlogf)
	. D CRTABLE^TBXSQL,MODIFYTB^TBXSQL			; create tables in RDB
	. D logmsg^TBXDQUTL("Done Loading RDB Tables",zlogf)
	. ;
	. D logmsg^TBXDQUTL("Rebuilding DBMAP for all tables",zlogf)
	. D regnproc^TBXSQL,ALL^DBMAP(db)			; regenerates the procedures
	;
	; Load data files to relational db.
	;
	D ELLOOP(.BUILDS,"DAT",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	I 'initEnv d eConstrt^TBXSQL 
	D:(initEnv) LOADCVAR()					; for initial environment copies CURVAR to RDB
	;
	D SQLLOOP(.BUILDS,OWCUST,OWFIX,PACKTYPE,.PVB)				; loads SQL elements scripts 
	;	
	; Load remaining DATA QWIK elements
	;
	D ELLOOP(.BUILDS,"AGR",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"BATCH",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"FKY",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"IDX",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"JFD",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"LUD",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"PPL",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"PROC",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"QRY",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB) 
	D ELLOOP(.BUILDS,"RPT",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"SCR",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	D ELLOOP(.BUILDS,"TRIG",OWCUST,OWFIX,.TYPES,PACKTYPE,.PVB)
	;
	D:(db'="GTM") UPDRDB^TBXSQL		; create objects in RDB.
	;
	; generates the sql log message
	;
	N DT
	S DT=$P($H,",")
	D sqllog^TBXSQL(DT,zlogf)
	Q
	;	
	;----------------------------------------------------------------------
ELLOOP(BUILDS,TYPE,OWCUST,OWFIX,TYPES,PACKTYPE,PVB)	; Generic element loop
	;---------------------------------------------------------------------
	; Loop through the elements of a folder and process. All elements other 
	; than table headers and columns are processed in this section.
	; ARGUMENTS:
	; . BUILDS - local array having build install directory info 
	; . TYPE - element type e.g. "G" for global
	; . OWCUST - overwrite customized elements
	; . OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	;	2 - fix pack
	; . TYPES - array with type-to-folder and type-to-routine mapping
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	N FILE,FOLDER,INFO,PARENT,PRIO,RTN,RSTR,SRCPATH,TRPATH,X
	s ER=0,RM=""
	;
	S FOLDER=$P(TYPES(TYPE),"|",1)		; directory used to store the element file
	S RTN=$P(TYPES(TYPE),"|",2)		; routine used to handle the element
	S PARENT=$P(TYPES(TYPE),"|",3)		; parent directory of directory used to store the element
	;
	I $D(^TMP($J,"LOAD",FOLDER)) d logmsg^TBXDQUTL("Processing folder "_FOLDER,zlogf)
	;
	; checks the element if can be ovarlaid or not by checking 
	; overlay inputs for fix pack and custom element 
	; . 0 - never overlay
	; . 1 - always overlay
	; . 2 - overlay with confirmation
	; and following conditions.
	; . element in FP/SP, never installed before
	; . element in FP/SP, installed version from SP build with higher priority
	; . element in FP/SP, current version customized locally
	; . element in FP/SP, installed version from FP
	; . previous build priority in is lower than current build priority
	; . element in FP/SP, installed version from SP build with same priority
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	;
	.	; gets the highest priority element from the installation pack
	.	;
	.	S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1)
	.	S SRCPATH=BUILDS(PRIO)
	.	Q:$P(FILE,".",2)'=TYPE		; if file extension don't match quit.
	.	S TRPATH=$$appdir(SRCPATH,PARENT)
	.	S TRPATH=$$appdir(TRPATH,FOLDER)_FILE
	.	S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	.	I '$P(RSTR,$C(124)) D  Q
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_$P(RSTR,$C(124),2),PRIO,TRPATH,.PVB)
	.	D ITEM(FILE,FOLDER,RTN,PARENT,SRCPATH,PRIO,.PVB)	
	.	I ER W !,RM S ER=0,RM=""
	;
	Q
	;
	;---------------------------------------------------------------------
ITEM(FILE,FOLDER,RTN,PARENT,SRCPATH,PRIO,PVB)	; Process one item
	;---------------------------------------------------------------------
	; reads the contents of file and calls the respective routine 
	; defined to handle the element in TYPES array 
	; ARGUMENTS:
	; . FILE - element name
	; . FOLDER - directory used to store the element
	; . RTN - routine defined to handle the element
	; . PARENT - parent directory for element's directory
	; . SRCPATH - source directory path
	; . PRIO - priority of element 
	;	framework-10/application -20/custom -30/fix pack -0
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	N CODE,DATE,REVISION,TIME,TPPATH,USER
	S $ZS="",$ZE=""	; clear error indicators
	;
	; get info for the element to be loaded
	;
	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)	
	;
	;S TRPATH=$$appdir(SRCPATH,FOLDER)_FILE
	;
	; If user chooses not to overwrite, reject to allow for loading
	; later with @DBBSRJC.
	;
	S TPPATH=SRCPATH_"/"_PARENT_"/"_FOLDER_"/"_FILE
	;
	; Read file contents into the CODE array.
	;
	D READFILE(.CODE,TPPATH)	
	;
	; Load element using the routine defined 
	;
	I 'ER D
	.	D logmsg^TBXDQUTL("Loading "_FOLDER_" definition "_FILE,zlogf)
	.	;
	.	; TBX passes LOADTYPE=2 for both SP and FP to ensure ^dbtbl is
	.	; maintained for both. In a future version of the TBX software
	.	; creating ^dbtbl (if needed at all) shall be the sole
	.	; responsibility of TBXINST.
	.	;
	.	I RTN'="TBXPROC" S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,2,USER,DATE,TIME)"
	.	E  S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,2,USER,DATE,TIME,TPPATH)"
	.	X CMD
	.	I 'X S ER=1,RM=$P(X,"|",2)
	;
	; if error while reading or loading the file reject the element
	;
	I ER D  Q
	.	D ERROR()
	.	D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_RM,PRIO,TPPATH,.PVB)
	.	S ER=0,RM=""
	;
	; log a element entry in the TBXLOG
	;
	D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded")
	;
	Q
	;
	;---------------------------------------------------------------------
TBLLOOP(BUILDS,OWCUST,OWFIX,PACKTYPE,PVB)	; Table and column loop
	;---------------------------------------------------------------------
	;
	; Loop through the table (TBL) and column (COL) files and process.
	; ARGUMENTS:
	; . BUILDS - local array having build install directory info 
	; . OWCUST - overwrite customized elements
	; . OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	;	2 - fix pack
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	; Structures:
	; ^TMP($JOB,"LOAD","table",TABLE.TBL) = table info
	; ^TMP($JOB,"LOAD","table",TABLE-COLUMN.COL) = column info
	; BUILDS(PRIO)_"/dataqwik/table/<tablename>/TABLE.TBL = table data
	; BUILDS(PRIO)_"/dataqwik/table/<tablename>/TABLE-COL.COL = column data
	;
	N DATE,FILE,FOLDER,INFO,PRIO,REVISION,RTN,RSTR,SRCPATH,TABLE,TIME,TPPATH,TRPATH,TYPE,USER,X
	;
	; checks the element if can be ovarlaid or not by checking 
	; overlay inputs for fix pack and custom element 
	; . 0 - never overlay
	; . 1 - always overlay
	; . 2 - overlay with confirmation
	; and following conditions.
	; . element in FP/SP, never installed before
	; . element in FP/SP, installed version from SP build with higher priority
	; . element in FP/SP, current version customized locally
	; . element in FP/SP, installed version from FP
	; . previous build priority in is lower than current build priority
	; . element in FP/SP, installed version from SP build with same priority
	;
	S FOLDER="table",FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1) 		; get the highest priority element from current pack
	.	S SRCPATH=BUILDS(PRIO)					; gets the source path
	.	N CODE
	.	S TYPE=$P(FILE,".",2)					; check the element type
	.	S RTN=$S(TYPE="COL":"TBXCOL",1:"TBXTBL")
	.	S TABLE=$$LOWER^%ZFUNC($P($P(FILE,"-",1),".",1))
	.	S TPPATH=SRCPATH_"/dataqwik/table/"_TABLE_"/"_FILE
	.	S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	.	I '$P(RSTR,$C(124)) D  Q
	..		;
	..		; rejects the element
	..		;
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_$P(RSTR,$C(124),2),PRIO,TPPATH,.PVB)
	.	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)	; get info for the element to be loaded
	.	;
	.	; Read file contents into the CODE array.
	.	;
	.	D READFILE(.CODE,TPPATH)
	.	I 'ER D
	..		D logmsg^TBXDQUTL("Loading table definition "_FILE,zlogf)
	..		I TYPE="COL" S X=$$LOAD^TBXCOL(.CODE,FILE,PACKTYPE,USER,DATE,TIME)
	..		I TYPE="TBL" S X=$$LOAD^TBXTBL(.CODE,FILE,PACKTYPE,USER,DATE,TIME)
	.	I ER D  Q
	..		D ERROR()
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_RM,PRIO,TPPATH,.PVB)
	..		S ER=0,RM=""
	.	;
	.	; log a element entry in the TBXLOG
	.	;
	.	D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded")
	Q
	;
	;---------------------------------------------------------------------
RTNLOOP(BUILDS,OWCUST,OWFIX,PACKTYPE,PVB)	; Copy routines to target
	;---------------------------------------------------------------------
	; ARGUMENTS:
	; BUILDS - local array having build install directory info 
	; OWCUST - overwrite customized elements
	; OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	;	2 - fix pack
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	N FILE,FOLDER,INFO,PRIO,RTN,RSTR,SRCPATH,TMPPATH,TRPATH
	;
	S FILE=""
	;
	S RTN="TBXRTN",ER=0,RM=""
	;
	; copies the elements from the routine folder to target
	;
	S FOLDER="routine",FILE="",ER=0
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Loading routines",zlogf)
	;
	; checks the element if can be ovarlaid or not by checking 
	; overlay inputs for fix pack and custom element 
	; . 0 - never overlay
	; . 1 - always overlay
	; . 2 - overlay with confirmation
	; and following conditions.
	; . element in FP/SP, never installed before
	; . element in FP/SP, installed version from SP build with higher priority
	; . element in FP/SP, current version customized locally
	; . element in FP/SP, installed version from FP
	; . previous build priority in is lower than current build priority
	; . element in FP/SP, installed version from SP build with same priority
	;
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""!ER  D
	.	;
	.	; gets the highest priority element from the installation pack
	.	;
	.	S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1) 		
	.	;
	.	; gets the build path
	.	;
	.	S TMPPATH=$$appdir(BUILDS(PRIO),FOLDER)
	.	S TRPATH=$$appdir(BUILDS(PRIO),FOLDER)_FILE
	.	S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	.	I '$P(RSTR,$C(124)) D  Q
	..		;
	..		; reject the element
	..		;
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_$P(RSTR,$C(124),2),PRIO,TRPATH,.PVB)
	.	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)	; get info for the element to be loaded
	.	;
	.	D logmsg^TBXDQUTL("Loading "_FOLDER_" "_FILE,zlogf)
	.	S ER=$$LOAD^TBXRTN(FILE,"",TRPATH,"MRTNS",1,1)		; routine dir is hardcoded as "MRTNS"
	.	S ER=$S(ER=0:1,1:0)
	.	I ER D  Q
	..		D ERROR()
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_RM,PRIO,TRPATH,.PVB)
	..		S ER=0,RM=""
	.	I FILE="DBMAP.m" ZLINK "DBMAP"
	.	;
	.	; log a element entry in the TBXLOG
	.	;
	.	D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded")
	;	
	Q
	;
	;---------------------------------------------------------------------
COMPARE()	; Compare new build contents with current build contents
	;---------------------------------------------------------------------
	; This subroutine compares the contents of the new SP build with 
	; what is previously installed (either as Fix Pack or as Service Pack).
	; The differences are stored in ^TMP($J,"LOAD",*).
	;
	; Note that this does not detect changes to the elements that are caused
	; by editing the element locally.
	;
	N FILE,INFO,PRIO
	S FILE=""
	F  S FILE=$O(^TMP($J,"FILE",FILE)) Q:FILE=""  D
	.	S PRIO="",PRIO=$O(^TMP($J,"FILE",FILE,PRIO),-1)
	.	S INFO=^TMP($J,"FILE",FILE,PRIO) 
	.	;
	.	; Compare individual file elements
	.	; Skip files that match and if there is no
	.	; fix pack version
	.	;
	.	I '$D(^TBXFIX(FILE)),($$isMatch(INFO,FILE,PRIO)) Q
	.	;
	.	; Create load records for mismatched files
	.	;
	.	S FOLDER=$P(INFO,"|",5)
	.	S ^TMP($J,"LOAD",FOLDER,FILE,PRIO)=INFO
	Q
	;
	;---------------------------------------------------------------------
UNMASK(MASKDATE,JD,JT)	; Convert masked date and time to julian format
	;---------------------------------------------------------------------
	; for migration from StarTeam to Subversion, will 
	; accept one of the following date-time formats:
	; Check initial format. Either the ISO SQL standard TIMESTAMP literal
	; format (YYYY-MM-DD hh:mm:ss) or the US format (m/d/year h:m A)
	;
	N dateStr,dd,mm,time
	;
	S dateStr=$P(MASKDATE," ",1)
	I dateStr?4N1"-"2N1"-"2N D	; date format YYYY-MM-DD
	.	; ISO SQL standard TIMESTAMP literal
	.	;
	.	S JD=$$date^UCGMCU(dateStr,"YEAR-MM-D")
	.	S JT=$$time^UCGMCU($E(MASKDATE,11,18))
	E  D
	.	; US format
	.	;
	.	S dd=$P(dateStr,"/",1)
	.	s mm=$P(dateStr,"/",2)
	.	; 
	.	; it needs to supply 2 digit day and month to the utility.
	.	i dd<10 s $P(dateStr,"/",1)="0"_dd
	.	i mm<10 s $P(dateStr,"/",2)="0"_mm
	.	s JD=$$date^UCGMCU(dateStr,"MM/DD/YEAR")
	.	;
	.	s time=$TR($P(MASKDATE," ",2,3)," ","")
	.	s JT=$$time^UCGMCU(time)
	Q
	;
	;---------------------------------------------------------------------
READFILE(CODE,SRCPATH) 
	;---------------------------------------------------------------------
	; Read file contents and stores it in CODE array
	; ARGUMENTS:
	; . CODE - local array to store the file contents
	; . SRCPATH - source path
	;
	N IO,LINE,X
	;
	S IO=SRCPATH
	;
	S X=$$FILE^%ZOPEN(IO,"READ",25,1024)
	I 'X S ER=1,RM=$P(X,"|",2) Q
	U IO
	F  Q:$ZEOF  D		; reads each line till the end of file
	.	R LINE
	.	I $ZEOF Q
	.	S CODE($O(CODE(""),-1)+1)=LINE
	U 0
	C IO
	Q
	;
	;---------------------------------------------------------------------
REJECT(FILE,LOADFOLDER,RTN,MSG,PRIO,SRCPATH,PVB)	; Reject element for future processing
	;---------------------------------------------------------------------
	;
	; ARGUMENTS:
	; . FILE - FILENAME
	; . LOADFOLDER - FOLDER name (for lookup in ^TMP()
	; . RTN - routine defined to handle the element
	; . MSG - rejection message
	; . FPATH - for global or dataqwik, FPATH is null
	; . PRIO - priority of element to be installed
	; . SRCPATH - - SOURCEPATH (including the file name or not) to find the file in SP/FP
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build 
	;
	; Set reject record indicating when it was rejected and 
	; which build it came was released in.
	;
	N BUILD,CODE,DATE,ER,INFO,PROJECT,REC,REVISION,SEQ,TIME,TYPE,USER,VIEW
	;
	S ER=0
	;
	; gets the build information like project,view and build or cr
	;
	S PROJECT=PVB(PRIO,"PROJ")
	S VIEW=PVB(PRIO,"VIEW")
	S BUILD=PVB(PRIO,"BLD")		; for fix pack it is CR
	;
	; get info for the element to be loaded
	;
	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)
	;
	; stores the rejection info
	;
	S $P(REC,"|",1)=REVISION
	S $P(REC,"|",2)=$E(USER,1,40)			; USER (LEN=40)
	S $P(REC,"|",3)=DATE
	S $P(REC,"|",4)=TIME
	S $P(REC,"|",5)=PROJECT				; PROJECT (LEN=40)
	S $P(REC,"|",6)=VIEW				; VIEW (LEN=40)
	S $P(REC,"|",7)=BUILD				; CRNUMBER (LEN=12?)
	S $P(REC,"|",8)=RTN				; TBXRTN (LEN=40)
	S $P(REC,"|",9)=+$H				; INSTDATE
	S $P(REC,"|",10)=$P($H,",",2)			; INSTTIME
	S $P(REC,"|",11)=$E($P(%LOGID,"|",2),1,20)	; USERID (LEN=20)
	S $P(REC,"|",12)=$E($G(MSG),1,150)		; DESCMT (LEN=150)
	S $P(REC,"|",13)=SRCPATH			; ??? to be added
	;
	S ^TBXREJ(FILE,PRIO)=REC  ; S TBXREJ(LOADFOLDER,FILE,PRIO)=REC
	;
	; log an element entry in the TBXLOG
	;
	D LOG(DATE,FILE,LOADFOLDER,.PVB,PRIO,REVISION,TIME,USER,MSG)
	;
	; Delete all descendants because the FILE is rejected.
	;
	K ^TMP($J,"LOAD",LOADFOLDER,FILE)
	Q
	;
	;---------------------------------------------------------------------
LOG(DATE,FILE,FOLDER,PVB,PRIO,REVISION,TIME,USER,MSG)	; Log action
	;---------------------------------------------------------------------
	; ARGUMENTS:
	; . DATE - element build date
	; . FILE - element to be logged 
	; . FOLDER - directory used to store the element
	; . PVB - local array having info about current build
	; . PRIO - priority of element to be logged
	; . REVISION - element revision
	; . TIME - element build time
	; . USER - user who run the build
	; . MSG - log message
	;	
	N BUILD,CURDATE,PROJ,REC,SEQ,VIEW
	;
	; get info for the element to be loaded
	;
	S PROJECT=PVB(PRIO,"PROJ")
	S VIEW=PVB(PRIO,"VIEW")
	S BUILD=PVB(PRIO,"BLD")
	;
	S CURDATE=+$H					; CURDATE
	S $P(REC,"|",1)=FOLDER
	S $P(REC,"|",2)=FILE
	S $P(REC,"|",3)=PROJECT
	S $P(REC,"|",4)=VIEW
	S $P(REC,"|",5)=BUILD
	S $P(REC,"|",6)=REVISION
	S $P(REC,"|",7)=$E(USER,1,40)			; USER (LEN=40)
	S $P(REC,"|",8)=DATE
	S $P(REC,"|",9)=TIME
	S $P(REC,"|",10)=$E(MSG,1,150)			; MSG (LEN=150)
	S $P(REC,"|",11)=$E($P(%LOGID,"|",2),1,40)	; LOGID (LEN=40)
	S $P(REC,"|",12)=$P($H,",",2)			; EVENTTIME
	S $P(REC,"|",13)=PRIO				; priority
	;
	; logs the element
	;
	S SEQ=$O(^TBXLOG(CURDATE,""),-1)+1		; SEQ
	S ^TBXLOG(CURDATE,SEQ)=$e(REC,1,400)
	;
	; creates an index for element log
	;
	S ^TBXLOGX(FILE,CURDATE,SEQ)=""
	;
	Q
	;
	;-----------------------------------------------------------------------
TYPEINIT(TYPES)	; Build TYPES array
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; The TYPES array contains information about the supported file
	; types. The key is the file extension.
	;
	;	Position 1 - directory used to retrieve the element file
	;		 2 - routine used to handle the element
	;		 3 - parent directory of position 1 (if any)
	;
	; Routines, tables and columns require additional processing
	; thus they are not processed in the generic ELLOOP section.
	; However, the file types are stored in the TYPES array.
	;
	S TYPES("AGR")="aggregate|TBXAGGR|dataqwik"
	S TYPES("BATCH")="batch|TBXBATCH|dataqwik"
	S TYPES("COL")="column|TBXCOL"
	S TYPES("DAT")="data|TBXDATA"
	S TYPES("FKY")="foreign_key|TBXFKEY|dataqwik"
	S TYPES("G")="data|TBXG"
	S TYPES("IDX")="index|TBXIDX|dataqwik"
	S TYPES("JFD")="journal|TBXJRNL|dataqwik"
	S TYPES("LUD")="lookup_doc|TBXLUD|dataqwik"
	S TYPES("M")="routine|TBXRTN"
	S TYPES("PPL")="pre_post_lib|TBXPPL|dataqwik"
	S TYPES("PROC")="procedure|TBXPROC|dataqwik"
	S TYPES("PSLX")="pslx|TBXPSLX|dataqwik"
	S TYPES("QRY")="query|TBXQRY|dataqwik"
	S TYPES("RPT")="report|TBXRPT|dataqwik"
	S TYPES("SCR")="screen|TBXSCRN|dataqwik"
	S TYPES("SQL")="scripts|TBXSQL"
	S TYPES("TBL")="table|TBXTBL"
	S TYPES("TRIG")="trigger|TBXTRIG|dataqwik"
	;
	Q
	;
	;---------------------------------------------------------------------
COPYINST(PVB,PACKTYPE)	
	;---------------------------------------------------------------------
	; Copy new build info for ^TBXBUILD(PRIO)
	; ARGUMENTS:
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	; . PACKTYPE - type of installation
	;	1 - service pack 
	; 	2 - fix pack
	;
	N FILE,FOLDER,PRIO,REC
	S PRIO="" F  S PRIO=$O(PVB(PRIO)) Q:PRIO=""  D
	.	S $P(^TBXBUILD(PRIO),"|",2)=PVB(PRIO,"PROJ")
	.	S $P(^TBXBUILD(PRIO),"|",3)=PVB(PRIO,"VIEW")
	.	S $P(^TBXBUILD(PRIO),"|",4)=PVB(PRIO,"BLD")
	.	S $P(^TBXBUILD(PRIO),"|",5)=$E($P(%LOGID,"|",2),1,20)
	.	S $P(^TBXBUILD(PRIO),"|",6)=$P($H,",")	
	;
	; add priority as a last piece in ^TBXINST(FILE)
	; make sure elements in obsolete are stored with PRIO=0
	;
	S FOLDER=""
	F  S FOLDER=$O(^TMP($J,"LOAD",FOLDER)) Q:FOLDER=""  D
	.	S FILE="" F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	..		S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1)
	..		S REC=^TMP($J,"LOAD",FOLDER,FILE,PRIO)
	..		;
	..		; for obsolete elements set priority as 0
	..		;
	..		S:FOLDER="obsolete" PRIO=0
	..		I PACKTYPE=2 S ^TBXFIX(FILE)=REC_"|"_PRIO
	..		I PACKTYPE=1 S ^TBXINST(FILE)=REC_"|"_PRIO
	;
	Q
	;
	;---------------------------------------------------------------------
ERROR()	; Display error message
	;---------------------------------------------------------------------
	;
	D logmsg^TBXDQUTL("Error encountered ***************************************",zlogf)
	D logmsg^TBXDQUTL(RM,zlogf)
	I $ZS["%GTM-E-SETECODE" D
	.	D logmsg^TBXDQUTL($ZE,zlogf)
	E  D logmsg^TBXDQUTL($ZS,zlogf)
	D logmsg^TBXDQUTL("*********************************************************",zlogf)
	Q
	;
	;---------------------------------------------------------------------
OBSLOOP(OWFIX,OWCUST,PACKTYPE)	; Obsolete elements loop
	;---------------------------------------------------------------------
	;
	; Loop through the obsoleted element list and 
	;
	N CMD,DATE,ETYPE,FILE,FOLDER,PRIO,RES,REVISION,RTN,TABLE,TBUILD,TIME,TYPE,USER,X
	;
	S FOLDER="obsolete"
	S ER=0,RM=""
	;
	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	;
	S FILE=""
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	. 	S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1)
	.	S RES=0
	.	S TYPE=$$UPPER^UCGMR($P(FILE,".",2))				; checks the file extension
	.	S RTN=$P(TYPES(TYPE),"|",2)
	.	S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	.	Q:'+$P(RSTR,$C(124)) 
	.	D logmsg^TBXDQUTL("Obsoleting "_FILE,zlogf)
	.	;
	.	; get info for the element to be obsoleted
	.	;
	.	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)
	.	I $D(TYPES(TYPE)) D
	..		;S RTN=$P(TYPES(TYPE),"|",2)				
	..		I TYPE="M" S CMD="S X=$$OBSRTN^TBXRTN(FILE)"		  	; obsolete routines
	..		E  I (TYPE="G") S CMD="S X=$$OBSOBJ^TBXG(FILE)"  		; obsolete data
	..		E  I (TYPE="DAT") S CMD="S X=$$OBSOBJ^TBXDATA(FILE)"  		; obsolete data
	..		E  S CMD="S X=$$OBSDQW^"_RTN_"(FILE)"				; obsolete DQs
	..		X CMD
	.	;i TYPE="SQL" d obsscrpt^TBXSQL(FILE)					; obsolete SQL element
	.	;I TYPE="PSLX" d OBSDQW^TBXPSLX(FILE)					; obsolete PSLX element
	.	;
	.	; log a element entry in the TBXLOG		
	.	;
	.	D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Obsoleted")
	.	I ER S ER=0,RM=""							; why we need to supress error
	Q
	;
	;---------------------------------------------------------------------
SFLOOP(BUILDS,OWCUST,OWFIX,PACKTYPE,PVB)	; Load system files
	;---------------------------------------------------------------------
	; The system files are retrieved from a hard-coded set of folders
	; underneath the system_files folder.
	;
	; Rejected files are stored in ^TBXREJ(filename) and
	; 13th piece of ^TBXREJ(filename) will contain the compelte file path 
	; to $$LOAD^TBXSFILE(). The TBXRJL program uses this layout to load
	; rejected system files.
	;
	; Keep this code in sync with PROC^TBXRJL
	; ARGUMENTS:
	; . BUILDS - local array having build install directory info 
	; . OWCUST - overwrite customized elements
	; . OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	;	2 - fix pack
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	N ER,FOLDER,FILE,HELLO,INFO,PRIO,PPATH,RM,RTN,RSTR,SRCPATH,TRPATH
	;
	S RTN="TBXSFILE",ER=0,RM=""
	;
	; PPATH is constant for all folders (so set and convert it outside the
	; loop).
	;
	S PPATH="system_files"
	;
	; checks the element if can be ovarlaid or not by checking 
	; overlay inputs for fix pack and custom element 
	; . 0 - never overlay
	; . 1 - always overlay
	; . 2 - overlay with confirmation
	; and following conditions.
	; . element in FP/SP, never installed before
	; . element in FP/SP, installed version from SP build with higher priority
	; . element in FP/SP, current version customized locally
	; . element in FP/SP, installed version from FP
	; . previous build priority in is lower than current build priority
	; . element in FP/SP, installed version from SP build with same priority
	;
	F FOLDER="doc","exp","gog","help","ini","uxscrpt" D
	.	I $D(^TMP($J,"LOAD",FOLDER)) D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	.	;
	.	S FILE=""
	.	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	..		;
	..		; gets the highest priority element from the installation pack
	..		;
	..		S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1)
	..		S SRCPATH=$$appdir(BUILDS(PRIO),PPATH)
	..		I FOLDER="ini",FILE'="UCOPTS.ini" Q
	..		S TRPATH=$$appdir(SRCPATH,FOLDER)_FILE
	..		S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	..		I '$P(RSTR,$C(124)) D  Q
	...			D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_$P(RSTR,$C(124),2),PRIO,TRPATH,.PVB)
	..		D logmsg^TBXDQUTL("Loading "_FILE,zlogf)
	..		D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)	; get info for the element to be loaded
	..		S ER=$$LOAD^TBXSFILE(FILE,FOLDER,TRPATH)
	..		I ER D  Q
	...			S RM=$E(ER,$F(ER,"|"),$L(ER))
	...			D ERROR()
	...			D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_RM,PRIO,TRPATH,.PVB)
	...			W !,RM S ER=0,RM=""
	..		;
	..		; log a element entry in the TBXLOG
	..		;
	..		D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded")
	Q
	;
	;-----------------------------------------------------------------------
ZERROR(zlogf)  ;  Exception handler code.
	;-----------------------------------------------------------------------
        ;
        u $p
        w !,"Fatal error during service pack installation",!
        S Z=$ZSTATUS,LOC=$P(Z,",",2),TXT=$P(Z,",",3),MSG=$P(Z,",",4,$L(Z,","))
        w "Location: "_LOC,!
        w "GTM code: "_TXT,!
        w "Message: "_MSG,!
	w !,"Current stack information:",!				; dump stack to log file	
	ZSHOW
	w !
        ZWRITE
        d CLEAN(.zlogf)	; Cleanup potentail left-overs
        HALT
        ;
	;-----------------------------------------------------------------------
GETDIRS(INSTDIR,DIRLIST); Pre processor to return subdirectory
	;-----------------------------------------------------------------------
	;
	N X,Y
	D CHKDIR^TBXDQUTL(INSTDIR)
	I $G(ER) Q
	K DIRLIST				
	S OUT=INSTDIR_"/*"
	S Y=0 
	F  S X=$ZSEARCH(OUT) Q:X=""  S Y=Y+1,DIRLIST(Y)=$ZPARSE(X,"NAME")
	Q
	;
	;------------------------------------------------------------------------
SPDIRS(INDEX,DIRLIST); Post processor to return the value.
	;------------------------------------------------------------------------
	; This is to prevent the first column of the drop down list being limited
	; to 12 characters long. It takes the key as an argument and return
	; the description field.
	;
	I '$D(DIRLIST(INDEX)) Q INDEX
	S DIRLIST(DIRLIST(INDEX))=DIRLIST(INDEX)
	Q DIRLIST(INDEX)
	;
	;------------------------------------------------------------------------
OBSPROM(FILE,type)
	;---------------------------------------------------------------------
	; Prompt user to see what to do with the obsolete element
	;
	N MSG
	I type=2 S MSG="Element "_FILE_" was loaded from a fix pack for CR "_$P(^TBXFIX(FILE),"|",7)
	I type=1 S MSG="Element "_FILE_" was loaded from a service pack for BUILD "_$P(^TBXINST(FILE),"|",7)
	D logmsg^TBXDQUTL(MSG,zlogf)
	Q $$PROMPT("Do you want to obsolete this element?")
	;
	;------------------------------------------------------------------------
LOADCVAR() ; install CUVAR to RDB when in initial environment
	;------------------------------------------------------------------------
	;	
	n dir,CODE,IO,X
	s IO=$$TRNLNM^%ZFUNC("SCAU_DIR")_"/CUVAR.DAT"
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q
	U IO
	F  Q:$ZEOF  D		; reads the file content till end of file
	.	R LINE
	.	I $ZEOF Q
	.	S CODE($O(CODE(""),-1)+1)=LINE
	U 0
	C IO
	;
	d logmsg^TBXDQUTL("Loading CUVAR.DAT",zlogf)
	S X=$$LOAD^TBXDATA(.CODE,"CUVAR.DAT",2,$P(%LOGID,"|",2),+$H,$P($H,",",2))
	Q	
	;
	;---------------------------------------------------------------------
SQLLOOP(BUILDS,OWCUST,OWFIX,PACKTYPE,PVB)	; Copy routines to target
	;---------------------------------------------------------------------
	; processes the SQL scripts stored in the scripts folder.
	; ARGUMENTS:
	; . BUILDS - local array having build install directory info 
	; . OWCUST - overwrite customized elements
	; . OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	; 	2 - fix pack
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	N INFO,FILE,FOLDER,PATH,PRIO,RSTR,SRCPATH,TMPPATH,TRPATH,cmd,count,connstr,sqlfile,ok
	S FOLDER="scripts",FILE=""
	;
	Q:'$D(^TMP($J,"LOAD",FOLDER))		; checks if there is any scripts folder
	Q:db="GTM"				; database if mumps then leaves the loop
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
	I initEnv u sqlfile w "@"_$$appdir(APPDIR,"scripts")_"UTILITY_PROGRAMS.sql",!,"/",!
	;
	S FILE=""
	;
	; checks the element if can be ovarlaid or not by checking 
	; overlay inputs for fix pack and custom element 
	; . 0 - never overlay
	; . 1 - always overlay
	; . 2 - overlay with confirmation
	; and following conditions.
	; . element in FP/SP, never installed before
	; . element in FP/SP, installed version from SP build with higher priority
	; . element in FP/SP, current version customized locally
	; . element in FP/SP, installed version from FP
	; . previous build priority in is lower than current build priority
	; . element in FP/SP, installed version from SP build with same priority
	;
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	; gets the highest priority element from the installation pack
	.	S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1)
	.	S SRCPATH=BUILDS(PRIO)
	.	S TRPATH=$$appdir(SRCPATH,FOLDER)_FILE
	.	S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	.	I '$P(RSTR,$C(124)) D  Q
	..		D REJECT(FILE,FOLDER,"","Not Loaded: "_$P(RSTR,$C(124),2),PRIO,TRPATH,.PVB)
	.	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER) 	; get info for the element to be loaded
	.	u sqlfile w !,"select '"_FILE_"' from dual;",!
	.	u sqlfile w "@"_$$appdir(SRCPATH,"scripts")_FILE,!,"/",!
	.	s count=count+1
	.	; log a element entry in the TBXLOG
	.	D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded")
	;
	; FSCW CR 37328: According to Badri, the script below is not part of the
	; standard FIS distribution (it is not owned by FIS). It may not be
	; present in the target environment.
	;; u sqlfile w "exec DBMS_OUTPUT.PUT_LINE('RECOMPILING ALL OBJECTS'||recompile)",!
	;
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
	;----------------------------------------------------------------------
isMatch(INFO,FILE,PRIO)
	;----------------------------------------------------------------------	
	; This is called only for service pack install. Checks if
	; previously loaded element is the same as the new element.
	; If so it will not load the element.
	; "same" is defined as having the same REVISION, FILEDATE, FILETIME, and
	; TYPE (load folder).
	;
	; ARGUMENTS:
	; . INFO - information of element to be loaded
	; . FILE - element to be checked
	; . PRIO - element priority
	;
	N tmpstr1,tmpstr2
	S tmpstr1=$P(INFO,"|",1,5),tmpstr2=$P($G(^TBXINST(FILE)),"|",1,5)
	S $P(tmpstr1,"|",2)="",$P(tmpstr2,"|",2)=""  
	Q tmpstr1=tmpstr2
	;
	;----------------------------------------------------------------------
init(BUILDS,%,%LOGID,db,PACKTYPE,zlogf)	;
	;-----------------------------------------------------------------------  
	; Initialize variables to be used in installation
	; kills the BUILDS(PRIO) entry if is not supplied for current installation
	; Cleanup potentail left-overs
	; sets PACKTYPE as per the type of installation 1 - service pack and 2 for fix pack
	; creates the log file
	;
	; ARGUMENTS :
	; . BUILDS	- 
	; . %		- piece delimeter
	; . %LOGID	- log information
	; . db		- database
	; . PACKTYPE 	- installation type
	; . zlogf	- name of log file
	; PUBLIC :
	; . ER - error  
	; . 	0 - no error
	; . RM - error message
	;
	N PRIO,ok
	S %LOGID="0|"_$$USERNAM^%ZFUNC_"|"_$$NODENAM^%ZFUNC()
	S %="|"		; sets the piece delimeter
	;
	S $ZTRAP="D ZERROR^TBXINST(.zlogf)",ER=0,RM=1
	;
	; ZLINK TBX routines
	S IMG=$$getImage()
	S CNT=$L(IMG,",")
	F CN=1:1:CNT S CMD="ZL """_$P(IMG,",",CN)_"""" X CMD
	;
	;
	S db=$$database() 	; gets the databse name, default is GTM
	; 
	; the details of build directories is fetched from ^TBXBUILD(PRIO) global
	;
	S PRIO="" F  S PRIO=$O(BUILDS(PRIO)) Q:PRIO=""  D
	.	I BUILDS(PRIO)'="" D
	..		S BUILDS(PRIO)=$$appdir(INSTDIR,"")_BUILDS(PRIO) 
	..		D CHKDIR^TBXDQUTL(BUILDS(PRIO)) W:ER !,RM,! 
	.	E  D
	..		;it KILLs BUILD(PRIO) if BUILD(PRIO)="" (i.e. not supplied for this
	..		; install), and that it prepends INSTDIR to all (remaining) nodes
	..		; in BUILDS()
	..		;
	..		K BUILDS(PRIO)
	;
	S PACKTYPE=$S($D(BUILDS(0)):2,1:1)  ; for fix pack PACKTYPE=2 else it is 1
	;
	D CLEAN(.zlogf)	; Cleanup potentail left-overs
	;
	; Try file in $SCAU_LOG_DIR, if that fails fall back to $SCAU_SPOOL
	N DT
	S DT=$P($H,",")
	s zlogf=$$SCAU^%TRNLNM("LOG_DIR","INST_"_DT_"_"_$J_".LOG")		; log file
	s ok=$$FILE^%ZOPEN(.zlogf,"WRITE/NEWV",5)			; try to open the file	
	;
	; not able to open log file in LOG_DIR so create it in SPOOL directory		
	;
	i +ok=0 D
	.	s zlogf=$$SCAU^%TRNLNM("SPOOL","INST_"_DT_"_"_$J_".LOG")	
	.	d LOGF^TBXDQUTL(.zlogf,"WRITE/NEWV")
	d logmsg^TBXDQUTL("Name of TBX log file: "_zlogf,zlogf)
	
	Q
	;
	;----------------------------------------------------------------------
LOADINT(FWDIR); Load TBXDQINT and UCGMU from the framework label directory.
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; . FWDIR - framework directory 
	;
	n FOLDER,TMPPATH,X
	;
	i $G(FWDIR)'=""	d
	. 	;	
	. 	; install TBXDQINIT and UCGMCU from framework directory;
	. 	S FOLDER="routine",TMPPATH=""
	.	S TMPPATH=$$appdir(FWDIR,FOLDER)
	. 	S X=$$LOAD^TBXRTN("TBXDQINT.m","",TMPPATH,"MRTNS",1,1)
	. 	S X=$$LOAD^TBXRTN("UCGMCU.m","",TMPPATH,"MRTNS",1,1)
	;
	zl "TBXDQINT","UCGMCU"
	D ^TBXDQINT
	Q
	;		
	;---------------------------------------------------------------------
PSLXLOOP(BUILDS,OWCUST,OWFIX,PACKTYPE,PVB)	; Load PSLX files
	;---------------------------------------------------------------------
	; ARGUMENTS:
	; . BUILDS - local array having build install directory info 
	; . OWCUST - overwrite customized elements
	; . OWFIX - overwrite fix pack element for fix pack it will be 0
	; . PACKTYPE - type of installation
	;	1 - service pack 
	;	2 - fix pack
	; . PVB - local array having the build info for current install
	;	for service pack
	;		Framework build
	;		Application build
	;		Custom build
	;	for fix pack
	;		fix pack build
	;
	N FILE,FOLDER,INFO,PRIO,RSTR,SRCPATH,TMPPATH,TRPATH
	S FOLDER="pslx"
	S RTN="TBXPSLX",ER=0,RM=""
	;
	D logmsg^TBXDQUTL("Processing "_FOLDER,zlogf)
	;
	S FILE=""
	;
	; checks the element if can be ovarlaid or not by checking 
	; overlay inputs for fix pack and custom element 
	; . 0 - never overlay
	; . 1 - always overlay
	; . 2 - overlay with confirmation
	; and following conditions.
	; . element in FP/SP, never installed before
	; . element in FP/SP, installed version from SP build with higher priority
	; . element in FP/SP, current version customized locally
	; . element in FP/SP, installed version from FP
	; . previous build priority in is lower than current build priority
	; . element in FP/SP, installed version from SP build with same priority
	;
	F  S FILE=$O(^TMP($J,"LOAD",FOLDER,FILE)) Q:FILE=""  D
	.	;
	.	; gets the highest priority element from the installation pack
	.	;
	.	S PRIO=$O(^TMP($J,"LOAD",FOLDER,FILE,""),-1)
	.	S TMPPATH=$$appdir(BUILDS(PRIO),"dataqwik/pslx")
	.	S TRPATH=TMPPATH_FILE
	.	S RSTR=$$OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)
	.	I '$P(RSTR,$C(124)) D  Q
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_$P(RSTR,$C(124),2),PRIO,TRPATH,.PVB)
	.	D logmsg^TBXDQUTL("Loading "_FILE,zlogf)
	.	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER) 	; get info for the element to be loaded
	.	S ER=$$LOAD^TBXPSLX(TRPATH)	; loads the pslx element
	.	S ER=$S(ER=0:1,1:0)
	.	I ER D  Q
	..		D ERROR()
	..		D REJECT(FILE,FOLDER,RTN,"Not Loaded: "_RM,PRIO,TRPATH,.PVB)
	..		W !,RM S ER=0,RM=""
	.	;
	.	; log a element entry in the TBXLOG
	.	;
	.	D LOG(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded")
	Q
	;
	;---------------------------------------------------------------------	
appdir(tgt,dir)	;  Append directory specifications.
	;---------------------------------------------------------------------
	;
	s:$e(tgt,$l(tgt))'="/" tgt=tgt_"/" 
	I dir'="" s:$e(dir,$l(dir))'="/" dir=dir_"/" 
	q tgt_dir
	;
	;---------------------------------------------------------------------
CONVERT()
	;---------------------------------------------------------------------
	; ^TBXINST will have only one subscript as FILE
	; this will copy data from ^TBXINST(PRIO,FILE) to ^TBXINST(FILE)
	;
	N FILE,PRIO
	K ^TMPTBX
	S PRIO="" F  S PRIO=$O(^TBXINST(PRIO)) Q:PRIO=""  D
	.	S FILE="" F  S FILE=$O(^TBXINST(PRIO,FILE)) Q:FILE=""  S ^TMPTBX(FILE)=^TBXINST(PRIO,FILE)_"|||"_$S(PRIO="FW":10,PRIO="APP":20,1:30) K ^TBXINST(PRIO,FILE)
	M ^TBXINST=^TMPTBX
	K ^TMPTBX
	Q
	;
	;---------------------------------------------------------------------
getINFO(FOLDER,FILE,PRIO,DATE,REVISION,TIME,USER)
	;---------------------------------------------------------------------
	;
	; ARGUMENTS:
	; . FOLDER - folder of the element 
	; . FILE - element to be checked
	; . PRIO - element priority
	; Return parameters
	; . DATE -
	; . REVISION - 
	; . TIME -
	; . USER - 
	;
	N INFO
	S INFO=^TMP($J,"LOAD",FOLDER,FILE,PRIO)
	S REVISION=$P(INFO,"|",1)
	S USER=$P(INFO,"|",2)
	S DATE=$P(INFO,"|",3)
	S TIME=$P(INFO,"|",4)
	Q
	;
	;--------------------------------------------------------------------
CRTBXBLD()	; create ^TBXBUILD for first time call to TBXSPIN or TBXFPIN
	;--------------------------------------------------------------------
	; it will create ^TBXBUILD data from ^TBXINST and ^TBXFIX
	; this will have previous build info
	;
	N INFO
	S INFO=$G(^TBXINST)
	S ^TBXBUILD(20)="Application|"_$P(INFO,"|",1,6)				; application build
	S ^TBXBUILD(10)="Framework|"_$P(INFO,"|",7,9)_"|"_$P(INFO,"|",4,6)	; framework build
	S ^TBXBUILD(30)="Custom" 
	S INFO=$G(^TBXFIX)						; custom build
	S ^TBXBUILD(0)="Fixpack|"_$P(INFO,"|",1,3)_"|||"_$P(INFO,"|",4)	; fix pack build	
	ZWITHDRAW ^TBXFIX							; kills TBXFIX and TBXINST entries but keeps their child entries.
	ZWITHDRAW ^TBXINST
	Q
	;
	;---------------------------------------------------------------------
OVERLAY(FILE,FOLDER,OWFIX,OWCUST,PACKTYPE,PRIO,RTN)	; Check for Fix Pak revision of the element
	;---------------------------------------------------------------------
	;	Extrinsic return 0 - Do not overlay
	;			 1 - Overlay
	;
	; checks the element if can be ovarlaid or not
	; ARGUMENTS:
	; . FILE - element to be checked
	; . FOLDER - folder of the element 
	; . OWFIX - overwrite fix pack element
	; . OWCUST - overwrite custom element
	; . PACKTYPE - type of pack installation 1 - service pack, 2 - fix pack
	; . PRIO - element priority
	; . RTN - routine name
	;
	N INSTREC,FIXREC,INFO,obsOrOver,PREVPRIO,PREVREC,RES
	;
	; Case 1 - element in FP/SP, never installed before It will be loaded unconditionally
	; This case corresponds to the following conditions:
	; .	No entry in TBXINST
	; .	No entry in TBXFIX
	; . 	No local version  Not checked yet!
	;
	I '$D(^TBXINST(FILE)),'$D(^TBXFIX(FILE)) Q 1
	; an entry in TBXFIX means that the FP version is more recent than the SP version.
	I $D(^TBXFIX(FILE)) S (PREVREC,FIXREC)=^TBXFIX(FILE)
	E  S (PREVREC,INSTREC)=^TBXINST(FILE)
	S INFO=^TMP($J,"LOAD",FOLDER,FILE,PRIO)		; element to be loaded info
	;
	S obsOrOver=" cannot "_$S(FOLDER="obsolete":"obsolete",1:"overlay")
	;
	; get info for the element to be loaded
	;
	D getINFO(FOLDER,FILE,PRIO,.DATE,.REVISION,.TIME,.USER)	
	;
	; For FP, re-calculate PRI. Note that this must follow the call to getINFO
	;
	I PACKTYPE=2 D
	.	;
	.	; recalc PRIO by iterating over ^TBXBUILD()
	.	; 
	.	S RES="",TPRIO=0	; do not check previous fix pack entry
	.	F  S TPRIO=$O(^TBXBUILD(TPRIO)) Q:(TPRIO="")!(RES=1)  D
	..		I PVB(PRIO,"PROJ")=$P(^TBXBUILD(TPRIO),"|",2),PVB(PRIO,"VIEW")=$P(^TBXBUILD(TPRIO),"|",3) S RES=1,PRIO=TPRIO
	;	
	; Case 2 - element in FP/SP, installed version from SP build with higher
	; priority. The element will be skipped.
	; This case corresponds to the following conditions:
	; .	The entry in TBXINST has a higher priority than the element in the FP/SP
	; The presence of a TBXFIX entry or local customization is irrelevant. 
	;
	; NOTE: If the PRIO of a TBXFIX row is always zero, the $D() can be removed
	;
	I $D(^TBXINST(FILE)),+$P(PREVREC,"|",8)>PRIO Q 0_$c(124)_" low priority element cannot be loaded "
	;
	; Case 3 - element in FP/SP, 
	; current version customized locally
	; The element will be skipped or overlaid depends on the overlay confirmation option. 
	; This case corresponds to the following conditions:
	; .	0 - never overlay
	; .	1 - always overlay
	; .	2 - confirm overlay for each element
	;
	; Check for customization (return value of 1 means no customization)
	;
	N CMD
	S CMD="S X=$$CHECK^"_RTN_"(FILE,USER,DATE,TIME)"
	X CMD
	;
	; skip the customized element
	;
	I +X=0,OWCUST=0 Q 0_$c(124)_obsOrOver_" locally customized element "
	;
	; If customized and user wants to decide on individual elements
	; prompt to overwrite.
	; If a TBXFIX row exists for the element, and the overlay is accepted,
	; the TBXFIX row will be deleted.
	;
	I +X=0 D  Q X
	.	S MSG=FILE_$C(13,10)
	.	S MSG=MSG_"Current: revision="_$P(PREVREC,"|",1)_", user="_$P(PREVREC,"|",2)_", CR/BUILD="_$P(PREVREC,"|",7)_", on="_$$^%ZD($P(PREVREC,"|",3))_$C(13,10)
	.	S MSG=MSG_"New:     revision= "_REVISION_", user="_USER_$C(9)_", CR/BUILD="_CRBLD_", on="_$$^%ZD(DATE)_$C(13,10)
	.	D logmsg^TBXDQUTL(MSG,zlogf)
	.	I OWCUST=1 K ^TBXFIX(FILE) S X=1 Q
	.	I OWCUST=2 S X=$$PROMPT("Overwrite")
	.	K:X ^TBXFIX(FILE) 
	.	S:X=0 X=X_$C(124)_obsOrOver_" locally customized element "
	;
	; Case 4 - element in FP/SP, installed version from FP
	; the FP will have an associated priority, which is stored in TBXFIX.PRIO.
	; The standard way to upgrade an element is through an SP. 
	; If the current version of the element is from an FP, check the entry
	; in ^TBXFIX(FILE) that signals a special condition. 
	; The overlay decision will depend exclusively on the overlay
	; confirmation option in effect.
	;
	I $D(^TBXFIX(FILE)) D  Q X
	.	;
	.	; call logmsg() for all FP rows even if we overlay
	.	;
	.	; If the fix element matches the revision in the fix pack
	.	;
	.	I $P(INFO,"|",1,4)=$P(^TBXFIX(FILE),"|",1,4) D  Q
	..		K ^TBXFIX(FILE)
	..		S X=1
	.	S MSG=FILE_$C(13,10)
	.	S MSG=MSG_"Current: revision="_$P(PREVREC,"|",1)_", user="_$P(PREVREC,"|",2)_", CR/BUILD="_$P(PREVREC,"|",7)_", on="_$$^%ZD($P(PREVREC,"|",3))_$C(13,10)
	.	S MSG=MSG_"New:     revision= "_REVISION_", user="_USER_$C(9)_", CR/BUILD="_CRBLD_", on="_$$^%ZD(DATE)_$C(13,10)
	.	D logmsg^TBXDQUTL(MSG,zlogf)
	.	S X=OWFIX I X=2 S X=$$PROMPT("Overwrite")
	.	K:X ^TBXFIX(FILE) 
	.	I X=0 S X=X_$C(124)_obsOrOver_" fix pack element "
	;
	; Case 5
	; If priority in PREVREC is lower than PRIO, we can unconditionally 
	; install.
	;
	I $P(PREVREC,"|",8)<PRIO Q 1
	;
	; Case 6 - element in FP/SP, installed version from SP build with same
	; priority. This case corresponds to the following conditions:
	; .	The entry in TBXINST has the same priority as the element we are
	;	checking
	; .	There is no entry for this element in TBXFIX 
	; .	The entry has not been customized locally 
	; In this case the element will be installed if and only if it is
	; "newer" than the installed element, which might occur if the same
	; FP/SP is installed more than once, and the element has not changed,
	; or for an SP: if the element was not updated in this release.
	; The overlay decision will need to be based on OWCUST or OWFIX, but
	; neither are 100% accurate. Since we are dealing with differences
	; between installed elements, OWFIX is preferred over OWCUST.
	; OWFIX value is interpreted as 
	; . 	0 - never overlay with older version of element
	; . 	1 - always overlay with older version of element
	; . 	2 - on user confirmation overlay with older version of element
	;
	S RES=OWFIX
	I (DATE*1E5+TIME)'>($P(PREVREC,"|",3)*1E5+$P(PREVREC,"|",4)) D  Q:RES=0 0_$C(124)_obsOrOver_" newer element "
	.	S MSG="A newer version of element "_FILE_" was loaded for CR/BUILD "_$P(PREVREC,"|",7)_$C(13,10)
	.	S MSG=MSG_"Current revision = "_$P(PREVREC,"|",1)_$C(9)_$P(PREVREC,"|",2)_$C(9)_" CR/BUILD "_$P(PREVREC,"|",7)_$C(9)_$$^%ZD($P(PREVREC,"|",3))_$C(13,10)
	.	S MSG=MSG_"    New revision = "_REVISION_$C(9)_USER_$C(9)_" CR/BUILD "_PVB($S(PACKTYPE=1:PRIO,1:0),"BLD")_$C(9)_$$^%ZD(DATE)_$C(13,10)_$C(13,10)
	.	D logmsg^TBXDQUTL(MSG,zlogf)
	.	I OWFIX=2 S RES=$$PROMPT(" Overwrite with old version?")
	Q 1
	;
	;-----------------------------------------------------------------------
database() ; public static String(); return the name of the underlying databasem
        ;-----------------------------------------------------------------------
        ; This function returns the value of %DB, forcing that public variable
        ; to exist after the call.
        ;
        ; OUTPUTS:
        ; . %DB property initialized
        ;
        IF $GET(%DB)="" SET %DB=$ZTRNLNM("SCAU_DB") IF %DB="" SET %DB="GTM"
        QUIT %DB
        ;
        ;---------------------------------------------------------------------
PROMPT(MESSAGE)	; Call Yes/No prompt
	;---------------------------------------------------------------------
	; ARGUMENTS:
	; . MESSAGE - message text for the prompt
	;
	Q $$YN^DBSMBAR(0,MESSAGE)       
	;
	;-----------------------------------------------------------------------
getImage() 	; public : return all TBX modules that compises bootstrp
	;-----------------------------------------------------------------------
	; returns all TBX modules may be involved during pack installation
	; except the caller routines i.e. TBXFPIN,TBXSPIN AND TBXABIN
	; we may need to include PSL compiler modules
	N STR
	S STR="TBXAGGR,TBXBATCH,TBXCOL,TBXDATA,TBXFKEY,TBXG,TBXIDX,TBXJRNL,TBXLUD,"
	S STR=STR_"TBXRTN,TBXPPL,TBXPROC,TBXPSLX,TBXQRY,TBXRPT,TBXSCRN,TBXSQL,TBXTBL,TBXTRIG"
	Q STR
	;
        ;-----------------------------------------------------------------------
