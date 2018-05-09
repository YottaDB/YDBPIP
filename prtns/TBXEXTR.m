TBXEXTR	;Private;Extract program 
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/17/02 17:05:36 - KWANL 
	; ORIG: KWANL - 06/17/02 
	; DESC: Extract program 
	; 
	; KEYWORDS: 
	; 
	; INPUTS: 
	;       . System 
	; 
	;       . Data  [ddfile]di 
	; 
	;       . v1    desc of variable        /TYP=T 
	; 
	; RETURNS: 
	;       . XX    desc of return          /TYP=T 
	; 
	; RELATED: 
	;       . $$func^rtn - description of how related 
	; 
	; EXAMPLE: 
	;      Text of example (line one) 
	; This program will loop through ^TBXINST global and extract data
	;	and dataqwik elements into a flat file.
	;
	;-----------------------------------------------------------------------
	; Revision History:
	; 01/20/2004	Lik kwan
	;		Changed to use absolute path when extracting m routines.
	;
	; 05/29/2003	Lik Kwan
	;		Remove CHKDIR section. Replace call to CHKDIR with CHKDIRX.
	;
	; 12/20/2002	Lik Kwan
	;		Remove code to extract system files and cleanup.
	;
	; 11/22/2002	Lik Kwan
	;		Modified global section to skip the non-distributed 
	;		globals during extract
	;-----------------------------------------------------------------------
	;
	S %LOGID=$$LOGID^SCADRV
	S %="|"
	;
	N %READ,%TAB,HDG,TARGETDIR,$ZT,%LIBS,RTNDIRS,RTNDIR,PRTNDIR,ISVMS
	;
	S $ZTRAP="D ZERROR^TBXEXTR"
	;
	S HDG="Extract Profile Element",%LIBS="SYSDEV"
	;
	S ISVMS=($ZVER["VMS")
	;
	S TARGETDIR=""
	S RTNDIR=""
	S PRTNDIR="$SCA_RTNS"
	S:ISVMS PRTNDIR="SCA$RTNS"
	S RTNDIRS("crtns")=""
	S RTNDIRS("mrtns")=""
	S RTNDIRS("prtns")=""
	S RTNDIRS("srtns")=""
	S RTNDIRS("zrtns")=""
	;
	S %TAB("TARGETDIR")=".TARGETDIR/REQ/DES=Target Directory/TYP=T/LEN=80"
	S %TAB("RTNDIR")=".RTNDIR/DES=Routine Directory to extract/TYP=T/LEN=40/TBL=RTNDIRS("
	S %TAB("PRTNDIR")=".RTNDIR/DES=Percent Routine Directory/TYP=T/LEN=40"
	S %READ="@HDG/CEN/REV,,,TARGETDIR,RTNDIR,PRTNDIR"
	D ^UTLREAD
	I VFMQ="Q" Q
	;
	; I $E(TARGETDIR,$L(TARGETDIR)-1,$L(TARGETDIR))'="/" S TARGETDIR=TARGETDIR_"/"
	D EXTRACT(TARGETDIR,RTNDIR,PRTNDIR)
	;
	W !,"Extracting Profile environment completed.",! 
	Q
	;
	;-----------------------------------------------------------------------
EXTRACT(TARGETDIR,RTNDIR,PRTNDIR)	
	;-----------------------------------------------------------------------
	;
	N EXRTN,EXPRTN,EXSF,EXDATA,EXDQW
	;
	; Build file type information array
	D TYPEINIT(.TYPES)
	;
	S EXRTN=$$PROMPT("Do you want to extract routines? ")
	S EXPRTN=$$PROMPT("Do you want to extract percent routines? ")
	S EXSF=$$PROMPT("Do you want to extract system files? ")
	S EXDATA=$$PROMPT("Do you want to extract data? ")
	S EXDQW=$$PROMPT("Do you want to extract DQ? ")
	;
	; copy routines
	I EXRTN D
	.	I RTNDIR="" Q
	.	W !,"Copying routines...",!
	.	D COPYRTN($$appdir^TBXDQUTL(TARGETDIR,"[routine]"),RTNDIR)
	;
	I EXPRTN D
	.	I PRTNDIR="" Q
	.	W !,"Copying percent rotuines...",!
	.	D COPYPRTN($$appdir^TBXDQUTL(TARGETDIR,"[percent_routine]"),PRTNDIR)
	;
	; copy system files
	; I EXSF D
	; .	W !,"Copying system files...",!
	; .	D EXTSFILE($$appdir^TBXDQUTL(TARGETDIR,"[system_files]"))
	;
	; I $D(^TBXINST) D TBXINST Q
	;
	; extract data
	I EXDATA D
	.	W !,"Processing data...",!
	.	D EXTDATA(TARGETDIR)
	;
	; extract dataqwik
	I EXDQW D
	.	W !,"Processing DataQwik...",!
	.	D EXTDQW(TARGETDIR)
	;
	Q
	;-----------------------------------------------------------------------
COPYRTN(TARGETDIR,RTNDIR);	Copy routine from mrtns to a target directory  
	;-----------------------------------------------------------------------
	;
	N XCMD,X,DIR
	S DIR=$$SCAU^%TRNLNM($$UPPER^%ZFUNC(RTNDIR))
	;
	S XCMD="ls "_DIR_" | grep ""\.m"" | xargs -i cp -p "_DIR_"/{} "_TARGETDIR_"{}"
	S:ISVMS XCMD="COPY/NOLOG "_DIR_"*.m "_TARGETDIR
	;
	S X=$$CHKDIRX^TBXDQUTL(TARGETDIR,ISVMS)
	Q:'X
	S X=$$SYS^%ZFUNC(XCMD)
	;
	Q
	;
	;-----------------------------------------------------------------------
COPYPRTN(TARGETDIR,RTNDIR);	Copy routine from precent routine directory to a target directory  
	;-----------------------------------------------------------------------
	;
	N XCMD,X
	;
	S XCMD="ls "_RTNDIR_" | grep ""\.m"" | xargs -i cp -p "_RTNDIR_"/{} "_TARGETDIR_"{}"
	S:((ISVMS)&(TARGETDIR["percent_routine")) XCMD="COPY/NOLOG "_RTNDIR_":*.m "_TARGETDIR
	;
	S X=$$CHKDIRX^TBXDQUTL(TARGETDIR,ISVMS)
	Q:'X
	S X=$$SYS^%ZFUNC(XCMD)	
	Q	
	;-----------------------------------------------------------------------
EXTDATA(TARGETDIR);	This section extract global  
	;-----------------------------------------------------------------------
	;
	N KEY1,KEY2,KEY3,FILENAME,CODE,X,OBJECTID
	S (KEY1,KEY2,KEY3)=""
	;
	; loop through ^SCATBL
	F  S KEY1=$O(^SCATBL(KEY1)) Q:KEY1=""  D
	.	F  S KEY2=$O(^SCATBL(KEY1,KEY2)) Q:KEY2=""  D
	..		S OBJECTID="SCATBL-"_KEY1_"-"_KEY2
	..		S X=$$GETCODE^TBXDATA(OBJECTID,.CODE,.FILENAME)
	..		Q:(+X=0)
	..		D OUT(.CODE,FILENAME)
	;
	; loop through ^STBL
	S (KEY1,KEY2)=""
	F  S KEY1=$O(^STBL(KEY1)) Q:KEY1=""  D
	.	S OBJECTID="STBL-"_KEY1
	.	S X=$$GETCODE^TBXDATA(OBJECTID,.CODE,.FILENAME)
	.	Q:(+X=0)
	.	D OUT(.CODE,FILENAME)
	;
	F OBJECTID="UTBL-NR4REC","UTBL-WCALC","SQL-SQLFUNC" D
	.	S X=$$GETCODE^TBXDATA(OBJECTID,.CODE,.FILENAME)
	.	Q:(+X=0)
	.	D OUT(.CODE,FILENAME)
	;
	; use zwrite to output the following global to a file
	F OBJECTID="CNVTBL","DBCTL","ELFELE","ELFLINK","ELFMAP","ELFMLI","GLCTL","OBJECT","OBJSCRIP" D 
	.	Q:'$D(@("^"_OBJECTID))
	.	S IO=$$appdir^TBXDQUTL(TARGETDIR,"[data]")_$$UPPER^%ZFUNC(OBJECTID)_".G"
	.  O IO:NEWV
	.  U IO
	. 	ZWRITE @("^"_OBJECTID)
	. C IO
	Q
	;
	;-----------------------------------------------------------------------
EXTDQW(TARGETDIR);	
	;-----------------------------------------------------------------------
	;
	N %LIBS,DQLVL,DQELM,KEY,X,FILENAME,CODE
	;
	S %LIBS="SYSDEV",(DQLVL,DQELM,KEY)=""
	F  S DQLVL=$O(^DBTBL(%LIBS,DQLVL)) Q:DQLVL=""  D
	.	Q:(DQLVL=11)!(DQLVL=10)!(DQLVL=17)		; loop up document is extracted with column
	.	W !,"DQLEVEL is : "_DQLVL,!
	.	F  S DQELM=$O(^DBTBL(%LIBS,DQLVL,DQELM)) Q:DQELM=""  D
	..		I DQLVL=1 D  Q				; extract table definition and data item
	...			S X=$$GETCODE^TBXTBL(DQELM,.CODE,.FILENAME)
	...			I +X=0
	...			D OUT(.CODE,FILENAME)
	...			D EXTCOL(DQELM,"TBXCOL")
	..		I DQLVL=2 D  Q				; extract screen
	...			S X=$$GETCODE^TBXSCRN(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)	
	..		I DQLVL=3 D  Q				; extract executive definition
	...			S X=$$GETCODE^TBXEXEC(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=4 D  Q				; extract query 
	...			S X=$$GETCODE^TBXQRY(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=5 D  Q				; extract report
	...			S X=$$GETCODE^TBXRPT(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=7 D EXTTRIG(DQELM,"TBXTRIG") Q				; extract extract trigger
	..		;
	..		I DQLVL=8 D EXTIDX(DQELM,"TBXIDX") Q				; index 
	..		;
	..		I DQLVL=9 D EXTJRN(DQELM,"TBXJRNL") Q				; extract journal 
	..		;
	..		I DQLVL=10 D  Q				; extract file pre/post processor
	...			S X=$$GETCODE^TBXFPP(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=12 D  Q				; extract lookup documentation
	...			S X=$$GETCODE^TBXLUD(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)		
	..		I DQLVL=13 D  Q				; extract pre/post library 
	...			S X=$$GETCODE^TBXPPL(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=16 D  Q				; extract record map
	...			S X=$$GETCODE^TBXRCDM(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	.. 		I DQLVL=17 D  Q				; extract export definition
	...			S X=$$GETCODE^TBXEXD(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)		
	..		I DQLVL=19 D EXTFKEY(DQELM,"TBXFKEY") Q				; extract foriegn key
	..		;
	..		I DQLVL=22 D  Q				; extract aggregate
	...			S X=$$GETCODE^TBXAGGR(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=25 D  Q					; extract procedure definition 
	...			S X=$$GETCODE^TBXPROC(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	..		I DQLVL=33 D  Q					; extract batch definition 
	...			S X=$$GETCODE^TBXBATCH(DQELM,.CODE,.FILENAME)
	...			D OUT(.CODE,FILENAME)
	Q
	;
	;-----------------------------------------------------------------------
ZERROR	; Display error message
	;-----------------------------------------------------------------------
	;
	W !!,"Error encountered ***************************************"
	W !,$G(RM)
	W !,$ZS
	W !,"*********************************************************"
	; 
	B
	Q
	;
	;-----------------------------------------------------------------------
TBXINST	; Loop through ^TBXINST global to extract element
	;-----------------------------------------------------------------------
	;
	N FILE,TYPE,OBJECTID
	S FILE="" F  S FILE=$O(^TBXINST(FILE)) Q:FILE=""  D
	.	S TYPE=$P(FILE,".",2)
	. 	Q:TYPE="m"
	. 	Q:'$D(TYPES(TYPE))
	. 	I $D(TYPES(TYPE)) D EXTITEM(FILE,TYPE) Q
	Q
	;
	;-----------------------------------------------------------------------
EXTITEM(FILE,TYPE)	; extract a global or a dataqwik item 
	;-----------------------------------------------------------------------
	;
	N RTN,X,FILENAME,FID,KEY,OBJECTDID,CMD
	;
	S RTN=$P(TYPES(TYPE),"|",2)
	;
	I TYPE="FKEY"!TYPE="COL"!TYPE="IDX"!TYPE="JFD"!TYPE="TRIG" D  Q
	.	S FID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2)
	. 	D ONEITEM(FID,KEY,RTN)
	;
	S OBJECTID=$P(FILE,".",1)
	; S X=@("$$GETCODE^"_RTN_"(OBJECTID,.CODE,.FILENAME)")
	S CMD="S X=$$GETCODE^"_RTN_"(OBJECTID,.CODE,.FILENAME)"
	X CMD
	D OUT(.CODE,FILENAME)
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
	;		 3 - dataqwik level
	;
	; Routines, tables and columns require additional processing
	; thus they are not processed in the generic ELLOOP section.
	; These file types are not stored in the TYPES array.
	;
	S TYPES("G")="data|TBXDATA|"
	S TYPES("COL")="table|TBXCOL|1"
	S TYPES("TBL")="table|TBXTBL|1" 
	S TYPES("SCR")="screen|TBXSCRN|2"
	S TYPES("EXC")="executive|TBXEXEC|3"
	S TYPES("QRY")="query|TBXQRY|4"
	S TYPES("RPT")="report|TBXRPT|5"
	S TYPES("TRIG")="trigger|TBXTRIG|7"
	S TYPES("IDX")="index|TBXIDX|8"
	S TYPES("JFD")="journal|TBXJRNL|9"
	S TYPES("LUD")="lookup_doc|TBXLUD|12"
	S TYPES("PPL")="pre_post_lib|TBXPPL|13"
	S TYPES("RMP")="record_map|TBXRCDM|16"
	S TYPES("FKY")="foreign_key|TBXFKEY|19"
	S TYPES("AGR")="aggregate|TBXAGGR|22"
	S TYPES("PROC")="procedure|TBXPROC|25"
	S TYPES("BATCH")="batch|TBXBATCH|33"
	; S TYPES("M")="routine|TBXRTN"
	;
	Q
	;
	;----------------------------------------------------------------------- 
EXTCOL(TBLID,RTN);	extract data items 
	;-----------------------------------------------------------------------
	;
	N DI
	S DI="" F  S DI=$O(^DBTBL(%LIBS,1,TBLID,9,DI)) Q:DI=""  D ONEITEM(TBLID,DI,RTN) 
	Q
	;
	;-----------------------------------------------------------------------
EXTTRIG(FID,RTN);	extract trigger definitions 
	;-----------------------------------------------------------------------
	;
	N TRIGID
	S TRIGID="" F  S TRIGID=$O(^DBTBL(%LIBS,7,FID,TRIGID)) Q:TRIGID=""  D ONEITEM(FID,TRIGID,RTN)
	Q
	;
	;----------------------------------------------------------------------
EXTJRN(FID,RTN);	
	;----------------------------------------------------------------------
	;
	N JKEY
	S JKEY="" F  S JKEY=$O(^DBTBL(%LIBS,9,FID,JKEY)) Q:JKEY=""  D ONEITEM(FID,JKEY,RTN) 
	Q
	;
	;---------------------------------------------------------------------
EXTIDX(FID,RTN);	
	;---------------------------------------------------------------------
	;
	N IDXKEY
	S IDXKEY="" F  S IDXKEY=$O(^DBTBL(%LIBS,8,FID,IDXKEY)) Q:IDXKEY=""  D ONEITEM(FID,IDXKEY,RTN)
	Q
	;
	;----------------------------------------------------------------------
EXTFKEY(FID,RTN);	
	;----------------------------------------------------------------------
	;
	N FKEY
	S FKEY="" F  S FKEY=$O(^DBTBL(%LIBS,19,FID,FKEY)) Q:FKEY=""  D ONEITEM(FID,FKEY,RTN)
	Q
	;
	;---------------------------------------------------------------------
ONEITEM(FID,KEY,RTN);	
	;---------------------------------------------------------------------
	;
	N OBJECTID,CMD
	S OBJECTID=FID_"-"_KEY
	; @("$$GETCODE^"_RTN_"(OBJECTID,.CODE,.FILENAME)")
	S CMD="S X=$$GETCODE^"_RTN_"(OBJECTID,.CODE,.FILENAME)"
	X CMD
	I '$D(CODE) Q
	D OUT(.CODE,FILENAME)
	Q
	;
	;---------------------------------------------------------------------- 
OUT(CODE,FILE)	; 
	;---------------------------------------------------------------------- 
	; 
	N IO,SEQ,TYPE,FOLDER,X,CMD 
	;
	I '$D(CODE) W !,"-ERROR- FAILED TO EXTRACT "_FILE,! Q
	S FILE=$$UPPER^%ZFUNC(FILE)
	W !,"    extracting "_FILE,!
	S FILE=$$TRIM^%ZS(FILE)
	I FILE[" " S FILE=$TR(FILE," ","_")
	I FILE["/" S FILE=$TR(FILE,"/","_") 
	I FILE["%" S FILE=$TR(FILE,"%","_") 
	I FILE["," S FILE=$TR(FILE,",","_") 
	I FILE["@" S FILE=$TR(FILE,"@","_")
	; 
	S TYPE=$P(FILE,".",2)
	S FOLDER=$P(TYPES(TYPE),"|",1)
	I FOLDER="data" S IO=$$appdir^TBXDQUTL(TARGETDIR,"[data]")
	I FOLDER'="data" S IO=$$appdir^TBXDQUTL(TARGETDIR,"[dataqwik."_FOLDER_"]")
	I (FOLDER="table")&(TYPE="COL") S IO=$$appdir^TBXDQUTL(IO,"["_$$LOWER^%ZFUNC($P(FILE,"-",1))_"]")
	I (FOLDER="table")&(TYPE="TBL") S IO=$$appdir^TBXDQUTL(IO,"["_$$LOWER^%ZFUNC($P(FILE,".",1))_"]")
	;
	S X=$$CHKDIRX^TBXDQUTL(IO,ISVMS)
	Q:'X
	S IO=IO_FILE
	S SEQ="" 
	; 
	O IO:NEWV 
	U IO 
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D 
	.       W CODE(SEQ) 
	.       I $O(CODE(SEQ)) W ! 
	U 0 
	C IO 
	K CODE
	Q 
	;
	;-----------------------------------------------------------------------
EXTSFILES(TARGETDIR);	Copy system files to target directory  
	;-----------------------------------------------------------------------
	;
	N FOLDER,X,CMD
	F FOLDER="com","exp","help" D
	.	S X=$$appdir^TBXDQUTL(TARGETDIR,"["_FOLDER_"]")
	.	Q:'$$CHKDIRX^TBXDQUTL(X,ISVMS)
	.	; D ^%ZCHKDIR I '$G(ER) D
	.	S CMD="cp -p "_FOLDER_"/*.* "_TARGETDIR_FOLDER_"/"
	.	S:ISVMS CMD="COPY/NOLOG [."_FOLDER_"]*.* "_$$appdir^TBXDQUTL(TARGETDIR,"["_FOLDER_"]")
	.	S X=$$SYS^%ZFUNC(CMD)
	Q
	;---------------------------------------------------------------------
PROMPT(MESSAGE)	; Call Yes/No prompt
	;---------------------------------------------------------------------
	;
	Q $$YN^DBSMBAR(0,MESSAGE,1)
	;
