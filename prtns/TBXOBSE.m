TBXOBSE	;Private;Fixed obsoleted element in patch release 
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/31/02 15:12:23 - KWANL 
	; ORIG: KWANL - 10/31/02 
	; DESC: Fixed obsoleted element in patch release 
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
	;       Text of example (line one) 
	; 
	;
	;	1. Read release.dat file to compute the latest patch release installed
	;	2. Read OBSDATA.TXT to compute the files to be obsoleted
	;	3. Remove routine, globals and DQ elements that were obsoleted in the patch release 
	;	   which have not been installed
	;	4. Convert elements name from lowercase to uppercase in ^DBTBL and ^dbtbl
	;	5. Build ^TMP(J) which contains DQ elements (DQ type 1.9, 7, 8 and 9), if the 
	;	   element date stamp in ^DBTBL matches the date stamp in ^dbtbl 
	;	6. Read build_contents.txt and write the elments into ^TMP1($J)
	;	7. Compare ^TMP1($J) and ^TMP(J), if elements exists in both ^TMP($J) and ^TMP1($J)
	;	   remove the elements from ^TMP($J)
	;	8  Remove DQs (type 1.9,7,8, and 9) remains in ^TMP($J).
	;	
	;----------------------------------------------------------------------
	; Revision History:
	; 12/26/2003	Lik Kwan
	;		Changed to use absolute path when reading or deleting file.
	;
	; 10/03/2003	Lik Kwan
	;		Remove obsoleted globals.
	;
	; 6/27/2003	Lik Kwan
	;		Fixed undefined TMPPAT
	;----------------------------------------------------------------------
	;
	D WARN
	;
	N zlogf,%,ISVMS,ISNFS,ER,RM,HDG,INSTDIR,OBSFILE
	;
	S HDG="Obsolete utilities"
	S ER=0,RM=""
	K ^TMP($J),^TMP1($J)
	;
	;
	S %="|"
	S ISVMS=$ZV["VMS"
	;
	;
	S %TAB("INSTDIR")=".INSTDIR/REQ/DES=Build contents/TYP=T/LEN=100/XPP=D CHKFILE^TBXOBSE(X)"
	S %READ="@HDG/CEN/REV,,,INSTDIR"
	D ^UTLREAD
	I VFMQ="Q" Q
	;
	Q:'$$PROMPT("This is your last chance to quit. Continue")
	;
	; If on vms, check if the disk is NFS mounted. (check if there is
	; a logical define for this directory which contains "NFS")
	;
	S ISNFS=0
	I (ISVMS)&($ZTRNLNM($P(INSTDIR,":",1))["NFS") S ISNFS=1
	;
	D LOGF,DOBSO(INSTDIR,ISVMS,ISNFS),logmsg($G(RM))
	;
	c zlogf
	Q 
	;
	;----------------------------------------------------------------------
DOBSO(INSTDIR,ISVMS,ISNFS)	; element obsolete entry point
	;----------------------------------------------------------------------
	;
	N DONE,RELST,CURPAT,TWPAT
	;
	S DONE=0
	S RELST=$$GETPAT() Q:ER					; get last patch release installed
	I +RELST=0 d logmsg($P(RELST,%,2)) Q
	;
	S REL=$P(RELST,%,1),CURPAT=$P(RELST,%,2)
	d logmsg("Last patch installed was : Patch Release "_CURPAT)
	S TWPAT=$$GETOBS(REL,CURPAT) Q:ER				; build obsolete data from obsdata.txt
	d logmsg("Latest patch from Sanchez is : Patch Release "_TWPAT)
	;
	I (CURPAT<TWPAT)&($D(^TMP($J))) D  Q:'$$PROMPT("Do you want to continue?")
	.	d logmsg("This function will remove elements obsoleted between Patch "_(CURPAT+1)_" and Patch "_TWPAT)	
	;
	I (CURPAT<TWPAT)&($D(^TMP($J))) D
	.	d logmsg("Removing elements obsoleted between Patch "_(CURPAT+1)_" and Patch "_TWPAT)
	.	D OBSO1
	;
	I (CURPAT=TWPAT) S DONE=1				; latest patch installed. converted trigger to uppercase and quit
	D CNVST001("^DBTBL",1),CNVST001("^dbtbl",1)		; convert trigger to uppercase
	I DONE=1 S RM="Latest patch release installed. No elements to obosolete" Q
	;
	K ^TMP($J)
	;
	D DQLIST,GETCONT(INSTDIR,ISVMS,ISNFS) Q:ER
	;
	D COMPARE,OBSO2,CLEANUP
	S ER="W",RM="Obsoleted elements have been removed."
	Q
	;
	;-----------------------------------------------------------------------
GETPAT();	Get last patch release installed from release.dat file 
	;-----------------------------------------------------------------------
	;	
	N IO,X,HEADER,REL,LINE,PAT,CURPAT,DIR
	S IO=$$SCAU^%TRNLNM("DIR")_"/release.dat"
	S:ISVMS IO=$$SCAU^%TRNLNM("DIRNAME")_":release.dat"
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q 0_%_RM
	;
	U IO
	I $ZEOF U 0 S ER=1,RM=IO_" file missing"
	Q:ER 0_%_RM								        
	R LINE
	S REL=$P(LINE,"|",1)
	U IO
	S CURPAT=1				; set current patch release to be 1
	F  Q:$ZEOF  R LINE D					        
	.	S PAT=$P(LINE,"|",1)
	.	I PAT>CURPAT S CURPAT=PAT
	C IO
	Q REL_"|"_CURPAT			        
	;
	;-----------------------------------------------------------------------
GETOBS(REL,LVL)	; Build obsoleted data from OBSDATA.TXT
	;-----------------------------------------------------------------------
	;
	N PATLVL,ELEM,TYPE,TMPPAT
	S PATLVL=LVL,ELEM=""
	S TMPPAT=PATLVL
	F  S PATLVL=$O(^OBSDATA(REL,PATLVL)) Q:PATLVL=""  D
	.	S TMPPAT=PATLVL
	.	F  S ELEM=$O(^OBSDATA(REL,PATLVL,ELEM)) Q:ELEM=""  D
	..		S TYPE=$P(ELEM,".",2)
	..		S FOLDER=$S(TYPE="M":"RTN",TYPE="G":"GBL",TYPE="D":"DQW")
	..		I TYPE="M" S ELEM=$P(ELEM,".",1)_".m"
	..		S ^TMP($J,FOLDER,ELEM)=""
	..		
	Q TMPPAT
	;
	;----------------------------------------------------------------------
OBSO1	; First round of obosolete
	;----------------------------------------------------------------------
	;
	D OBSRTN,OBSDATA,OBSDQW
	;
	Q
	;
	;-----------------------------------------------------------------------
OBSRTN	; Remove routines from mrtns directory
	;-----------------------------------------------------------------------
	;
	d logmsg("Obsoleting rotuines")
	;
	N FOLDER,ELEM,RTNAME
	S FOLDER="RTN"
	S ELEM="" F  S ELEM=$O(^TMP($J,FOLDER,ELEM)) Q:ELEM=""  D
	.	d logmsg("Removing routine: "_ELEM_" from mrtns.")
	.	S RTNAME=$P(ELEM,".",1)
	.	D DELRTN(RTNAME)
	Q
	;
	;-----------------------------------------------------------------------
DELRTN(RTNAME);	Call %ZRTNDEL to remove routines from target directory 
	;-----------------------------------------------------------------------
	;
	N DIR
	;
	S DIR=$$SCAU^%TRNLNM("MRTNS")
	D DEL^%ZRTNDEL(RTNAME,DIR)
	Q
	;
	;-----------------------------------------------------------------------
OBSDATA	; Remove global reference from database
	;-----------------------------------------------------------------------
	;
	d logmsg("Obsoleting globals")
	;
	N FOLDER,ELEM,GBLREF
	S FOLDER="GBL"
	S ELEM="" F  S ELEM=$O(^TMP($J,FOLDER,ELEM)) Q:ELEM=""  D
	.	d logmsg("Removing global : "_ELEM_" from database")
	.	S GBLREF=$$GXNAME(ELEM)
	.	Q:'$D(@GBLREF)
	.	K @GBLREF	 
	;
	Q
	;
	;-----------------------------------------------------------------------
GXNAME(elem);	Convert a global CMS element name into an external format. 
	; 
	;       GBL$1$-5$TEST_DATA.G    -->     ^GBL(1,.5,"TEST_DATA") 
	;       TRN$-ADD_IT.G           -->     ^TRN("@ADD_IT") 
	;----------------------------------------------------------------------- 
	;
	n gnam s gnam=$p(elem,"$") 
	s elem=$p(elem,".") 
	i elem'["$" q "^"_elem 
	q "^"_$p(elem,"$")_"("_$$GSUBIX($p(elem,"$",2,$l(elem,"$")),gnam)_")" 
	; 
	;-----------------------------------------------------------------------
GSUBIX(gelm,gnam);	Returns an external global subscript based on the internal TrackWare 
	;  representation. 
	; 
	;       1$-5$AB_CD      -->     1,.5,"AB_CD" 
	;       -ADD_IT         -->     "@ADD_IT"       for ^TRN 
	;----------------------------------------------------------------------- 
	;
	n i,p,x 
	; 
	s x="" 
	i gnam="TRN" s gelm=$tr(gelm,"-","@") 
	e  s gelm=$tr(gelm,"-",".") 
	f i=1:1:$l(gelm,"$") d 
	. s p=$p(gelm,"$",i) 
	. i p'=+p s p=""""_p_"""" 
	. s x=x_p_"," 
	; 
	q $e(x,1,$l(x)-1) 
	; 
	;------------------------------------------------------------------------
OBSDQW	; Remove DQ elements from database
	;------------------------------------------------------------------------
	;
	d logmsg("Obsoleting data-qwik elements")
	;
	N FOLDER,ELEM,lib,typ,elm
	;
	S FOLDER="DQW"
	S ELEM="" F  S ELEM=$O(^TMP($J,FOLDER,ELEM)) Q:ELEM=""  D
	.	D DQELEM(ELEM,.lib,.typ,.elm)
	.	S ^ZZOBS($J,lib,typ,elm)=""
	.	d logmsg("Removing "_lib_"."_typ_"."_elm_" from database")
	.	D dqobso(lib,typ,elm,ISVMS)
	.	k ^DBTBL(lib,typ,elm),^dbtbl(lib,typ,elm)
	;
	Q
	;
	;------------------------------------------------------------------------
DQELEM(dqwe,libr,type,elem);	Convert DATA-QWIK element CMS name into the library triplet. 
	;------------------------------------------------------------------------ 
	;
	s dqwe=$p(dqwe,".") 
	s libr=$p(dqwe,"$",1),type=$p(dqwe,"$",2),elem=$p(dqwe,"$",3) 
	q 
	; 
	;=======================================================================
	;  The following code is taken from the old kit pre-processor routine.
	;-----------------------------------------------------------------------
	;***********************************************************************
dqobso(lib,typ,elm,ISVMS)	
	; Purpose: Use DQ Utility to obsolete DQ element.
	;
	; NOTE: Current DATA-QWIK level definition is as followed:
	; level		description
	; 0		library being used
	; 1		file definition
	; 2		screen definition
	; 3		sort definition
	; 4		query definition
	; 5		report definition
	; 6		qwik-report definition
	; 8		index file definition
	; 9		journal file definition
	; 10		pre/post-processor filer definition
	; 11		data item documentation
	; 12		table value documentation
	; 13		pre/post-processor library
	; 14		data item protection definition
	; 16		data item exchange definition
	; 20		data item index file
	; 22		aggregate definition
	; 25 		procedure definition
	; 33		batch definition
	;
	; The DQTA-QWIK obsolete process is defined as followed:
	; 1) remove implicit definition.
	; 2) remove associated application program.
	; 3) remove DATA-QWIK element from database.
	;***********************************************************************
	n (lib,typ,elm,ISVMS)
	i '$D(^DBTBL(lib,typ,elm)) q						; nothing to obsolete
	d implicit(lib,typ,elm)                                                 ; remove implicit first
	d runpgm(lib,typ,elm)
	;									; remove run time program
	I (typ=1) d ofile q							; obsolete file definition
	;
	I typ=8 d odifd q						; obsolete index file definition
	;
	I (typ>1)&(typ<7)!(typ=13) d outil					; rm index for screen,sort,query,report,qwik,pplib
	;
	q
	;
implicit(lib,typ,elm)	
	;*********************************************************************** 
	; Purpose: Remove implicit because DQ element is no longer valid. 
	;*********************************************************************** 
	n zxlib,zimp 
	s zxlib=""                                                              ; go through all library 
	f  s zxlib=$O(^DBTBL(zxlib)) q:zxlib=""  d                              ; get library name 
	. i zxlib=lib q                                                         ; skip checking the current library 
	. i typ=1 s zimp=$P($G(^DBTBL(zxlib,typ,elm,10)),"|",5)                 ; check node 10 piece 5 for file def 
	. e  s zimp=$G(^DBTBL(zxlib,typ,elm,-3))                                ; check node -3 for screen and report 
	. i zimp[lib k ^DBTBL(zxlib,typ,elm)                                    ; if implicit then kill it 
	q 
	; 
runpgm(lib,typ,elm)	
	;***********************************************************************
	; Purpose: Remove run time program associated with DQ element.
	; Note: Only file, screen, sort, report, protection, and data item
	;	exchange definitions have run time programs.
	;***********************************************************************
	n rname,DIR
	s rname="VP01"								; this has some purpose, don't set it to null
	;
	S DIR=$$SCAU^%TRNLNM("CRTNS")
	i typ=1 s rname=$P($G(^DBTBL(lib,typ,elm,99)),"|",2)			; file definition
	i (typ=2)!(typ=5) s rname=$P($G(^DBTBL(lib,typ,elm,0)),"|",2)		; screen, sort, report definition
	i (typ=3)!(typ=16) s rname=$P($G(^DBTBL(lib,typ,elm)),"|",2)		; record map,filer executive definition
	i typ=14 s rname=rname_$P($G(^DBTBL(lib,typ,elm,99)),"|",2)		; protection definition
	i (typ=25)!(typ=33) s rname=$P($G(^DBTBL(lib,typ,elm)),"|",2)		; procedure,batch definition
	i (rname="")!(rname="VP01") q						; no routine to delete
	d logmsg("Removing run time program : "_rname_" from crtns.")
	d DEL^%ZRTNDEL(rname,DIR)						; delete routine
	i typ=5 d								; report may have sort and stat routine
	. s rname=$TRANSLATE(rname,"S","Z")					; get sort routine name
	. d logmsg("Removing run time program : "_rname_" from crtns.")
	. d DEL^%ZRTNDEL(rname,DIR)						; delete sort routine
	. s rname=$TRANSLATE(rname,"Z","T")					; get stat routine name
	. d logmsg("Removing run time program : "_rname_" from crtns.")
	. d DEL^%ZRTNDEL(rname,DIR)						; delete stat routine
	q
	;
ofile	;***********************************************************************
	; Purpose: Obsolete file definitions.
	;***********************************************************************
	n (lib,typ,elm)								; refresh stack - make sure it's clean
	d logmsg("Removing file definitions : "_lib_"."_typ_"."_elm)
	s %LIBS=lib,FID=elm							; set up variables for PROFILE
	d @"^DBSDF1F(3)"							; 3 is used for delete"
	q									; done
	;
outil	;***********************************************************************
	; Purpose: Call delete data item index utility.
	; Assume:  PROFILE recognizes the following variables for processing:
	;	   %LIBS = library
	;	   DBOPT = DQ type
	;	   ID    = DQ element name
	;	   DQFUN = function - "D" is used here for delete
	; The statement n (lib,typ,elm) is used to clear all local variables.
	;***********************************************************************
	n (lib,typ,elm)								; refresh the stack - make sure it's clean
	d logmsg("Removing data item index : "_lib_"."_typ_"."_elm)
	s %LIBS=lib,DBOPT=typ,ID=elm,DQFUN="D"					; set up variables for PROFILE
	d @"^DBSUTL3"								; actual call to delete
	q									; done
	;
odifd	;*********************************************************************** 
	; Purpose: Delete index file definition. 
	; Assume: PROFILE recognizes the following variables for processing: 
	;         %LIBS = library 
	;         FID   = index definition 
	;         INDEXNM = index name 
	;         fDBTBL8 = index info 
	;*********************************************************************** 
	n (lib,typ,elm)                                                         ; refresh the stack - make sure it's clean 
	n fDBTBL8,INDEXNM 
	s INDEXNM="" 
	f  s INDEXNM=$D(^DBTBL(lib,8,elm,INDEXNM)) q:INDEXNM=""  d              ; go through one index at a time 
	. s fDBTBL8=$G(^DBTBL(lib,8,elm,INDEXNM))                               ; set up var for PROFILE 
	. s %LIBS=lib,FID=elm 
	. d @"^DBSINDXF(3)"                                                     ; actual call to delete index 
	q 
	; 
	;======================================================================= 
	;
	;----------------------------------------------------------------------
DQLIST	; Get dataqwik list 
	;----------------------------------------------------------------------
	;
	N %LIBS,DQLVL,DQELM,KEY,X,FILENAME,CODE,DID
	;
	d logmsg("Get DQ element list from database")
	S %LIBS="SYSDEV",(DQLVL,DQELM,KEY)=""
	F  S DQLVL=$O(^DBTBL(%LIBS,DQLVL)) Q:DQLVL=""  D
	.	Q:(DQLVL=11)!(DQLVL=17)		; loop up document is extracted with column
	.	F  S DQELM=$O(^DBTBL(%LIBS,DQLVL,DQELM)) Q:DQELM=""  D
	..		Q:$D(^ZZOBS($J,%LIBS,DQLVL,DQELM))
	..		Q:$E(DQELM,1)="Z"
	..		I DQLVL=1 D  Q				; extract table definition and data item
	...			S DID="" F  S DID=$O(^DBTBL(%LIBS,DQLVL,DQELM,9,DID)) Q:DID=""  D
	....				Q:(DID["*")!(DID["""")!(DID["$")
	....				S KEY=DID
	....				I $E(DID,1)="_" S KEY="%"_$E(DID,2,999)
	....				S FILENAME=DQELM_"-"_KEY_".COL"
	....				S:'$$ISCUSTOM(1.9,DQELM,DID) ^TMP($J,$$LOWER^%ZFUNC(DQELM),$$SETFILE(FILENAME))=%LIBS_"|1|"_DQELM_"|"_DID
	..		I DQLVL=7 D  Q				; trigger
	...			S DID="" F  S DID=$O(^DBTBL(%LIBS,DQLVL,DQELM,DID)) Q:DID=""  D
	....				S FILENAME=DQELM_"-"_DID_".TRIG"
	....				S:'$$ISCUSTOM(7,DQELM,DID) ^TMP($J,"trigger",$$SETFILE(FILENAME))=%LIBS_"|7|"_DQELM_"|"_DID
	..		I DQLVL=8 D  Q				; index 
	...			S DID="" F  S DID=$O(^DBTBL(%LIBS,DQLVL,DQELM,DID)) Q:DID=""  D
	....				S FILENAME=DQELM_"-"_DID_".IDX"
	....				S:'$$ISCUSTOM(8,DQELM,DID) ^TMP($J,"index",$$SETFILE(FILENAME))=%LIBS_"|8|"_DQELM_"|"_DID
	..		I DQLVL=9 D  Q				; extract journal 
	...			S DID="" F  S DID=$O(^DBTBL(%LIBS,DQLVL,DQELM,DID)) Q:DID=""  D
	....				S FILENAME=DQELM_"-"_DID_".JFD"
	....				S:'$$ISCUSTOM(9,DQELM,DID) ^TMP($J,"journal",$$SETFILE(FILENAME))=%LIBS_"|9|"_DQELM_"|"_DID
	..		I DQLVL=19 D  Q							; foriegn key
	...			S DID="" F  S DID=$O(^DBTBL(%LIBS,DQLVL,DQELM,DID)) Q:DID=""  D
	....				S FILENAME=DQELM_"-"_DID_".FKY"
	....				S:'$$ISCUSTOM(19,DQELM,DID) ^TMP($J,"foreign_key",$$SETFILE(FILENAME))=%LIBS_"|19|"_DQELM_"|"_DID					
	Q
	;
	;----------------------------------------------------------------------
appdir(tgt,dir)	;  Append directory specifications.
	;----------------------------------------------------------------------
	n x 
	;
	i ISVMS s x=$e(tgt,1,$l(tgt)-1)_$tr(dir,"[",".")
	e  s:$e(tgt,$l(tgt))="/" tgt=$e(tgt,1,$l(tgt)-1) s x=tgt_$tr(dir,"[.]","///")
	;
	q x
	;
	;----------------------------------------------------------------------
ISCUSTOM(LVL,ELM,DID);	Determine if this DQ element is customized. 
	; If it is in ^DBTBL but not in ^dbtbl => customized
	; if date stamp between ^DBTBl and ^dbtbl if not matched => cusomized
	;
	; Return:	0: not customized
	;		1: customized  
	;----------------------------------------------------------------------
	;
	N %LIB,STATUS
	S %LIB="SYSDEV",STATUS=0
	I LVL=1.9 D  Q STATUS
	.	I '$D(^dbtbl(%LIB,1,ELM,9,DID)) S STATUS=1 Q
	.	I $$dqd(1,LVL,ELM,DID)'=$$dqd(2,LVL,ELM,DID) S STATUS=1 Q
	.	I ($E(DID)="Z") S STATUS=1 Q
	I (LVL=7)!(LVL=8)!(LVL=9) D  Q STATUS
	.	I '$D(^dbtbl(%LIB,LVL,ELM,DID)) S STATUS=1 Q
	.	I $$dqd(1,LVL,ELM,DID)'=$$dqd(2,LVL,ELM,DID) S STATUS=1 Q
	.	I ($E(DID)="Z") S STATUS=1 Q
	E  D  Q STATUS							; table header
	.	I '$D(^dbtbl(%LIB,LVL,ELM)) S STATUS=1 Q
	.	I $$dqd(1,LVL,ELM)'=$$dqd(2,LVL,ELM) S STATUS=1 Q
	.	I ($E(ELM)="Z") S STATUS=1 Q			
	Q 0
	;
	;-----------------------------------------------------------------------
dqd(src,lvl,elm,did)	;  Return DATA-QWIK element modification date. 
	; 
	;  This routine returns the last mofigication date for a DATA-QWIK 
	;  element;  if the date stamp is not store at the requested level 
	;  or if the date stamp is null, then a 0 is returned. 
	; 
	;  The source parameter (src) determines whether the date stamp is 
	;  obtained from the real ^DBTBL (src=1) or from the ^dbtbl global 
	;  (src=0). 
	; 
	;  The 4th parameter, did, is only needed for levels 1.9, 7, 8, and 
	;  9;  it defines the "item" in question within the requested element. 
	;----------------------------------------------------------------------- 
	;
	i (lvl=22)!(lvl=12) Q 0
	; 
	n gbl s gbl=$s(src=1:"^DBTBL",src=2:"^dbtbl",1:"^DBTBL") 
	; 
	i lvl=1 q +$p($g(@gbl@("SYSDEV",lvl,elm,10)),%,10) 
	i lvl=1.9 q +$p($g(@gbl@("SYSDEV",1,elm,9,did)),%,25) 
	i lvl=2 q +$p($g(@gbl@("SYSDEV",lvl,elm,0)),%,3) 
	i lvl=3 q +$p($g(@gbl@("SYSDEV",lvl,elm)),%,3) 
	i lvl=4 q +$p($g(@gbl@("SYSDEV",lvl,elm,0)),%,3) 
	i lvl=5 q +$p($g(@gbl@("SYSDEV",lvl,elm,0)),%,3) 
	i lvl=6 q +$p($g(@gbl@("SYSDEV",lvl,elm,0)),%,3) 
	i lvl=7 q +$p($g(@gbl@("SYSDEV",lvl,elm,did)),%,9) 
	i lvl=8 q +$p($g(@gbl@("SYSDEV",lvl,elm,did)),%,12) 
	i lvl=9 q +$p($g(@gbl@("SYSDEV",lvl,elm,did)),%,9) 
	i lvl=13 q +$p($g(@gbl@("SYSDEV",lvl,elm,0)),%,3) 
	i lvl=16 q +$p($g(@gbl@("SYSDEV",lvl,elm)),%,4) 
	i lvl=17 q +$p($g(@gbl@("SYSDEV",lvl,elm)),%,2) 
	i lvl=18 q +$p($g(@gbl@("SYSDEV",lvl,elm)),%,6) 
	i lvl=25 q +$p($g(@gbl@("SYSDEV",lvl,elm)),%,3) 
	i lvl=33 q +$p($g(@gbl@("SYSDEV",lvl,elm)),%,3) ; *** ZCL - 08/20/98 - to do the date check for level 33. 
	; 
	;  A catch all, just in case. 
	; 
	q -1 
	; 
	;-----------------------------------------------------------------------
SETFILE(FILE);	
	;-----------------------------------------------------------------------
	S FILE=$$TRIM^%ZS(FILE)
	I FILE[" " S FILE=$TR(FILE," ","_")
	I FILE["/" S FILE=$TR(FILE,"/","_") 
	I FILE["%" S FILE=$TR(FILE,"%","_") 
	I FILE["," S FILE=$TR(FILE,",","_") 
	I FILE["@" S FILE=$TR(FILE,"@","_")
	Q FILE
	;
	;---------------------------------------------------------------------
GETCONT(INSTDIR,ISVMS,ISNFS)	; Read build contents file
	;---------------------------------------------------------------------
	;
	N IO,REC,HEADER,X,FOUND,ISNEW,RELDIR,RELCONT
	;
	d logmsg("Reading service pack build_contents.txt")
	;S RELDIR="release_doc",RELCONTS="build_contents.txt"
	;
	;I ISVMS&ISNFS D
	;.	S RELDIR=$$NFSVMS(RELDIR)
	;.	S RELCONTS=$$NFSVMS(RELCONTS)
	;;
	;S IO=$$appdir(INSTDIR,"["_RELDIR_"]")_RELCONTS
	;
	; A custom header is prepended to the build contents document 
	; during deployment.
	;
	S IO=INSTDIR
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q
	;
	U IO
	I $ZEOF U 0 S ER=1,RM=IO_"file missing"
	R HEADER
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
	..		I $G(FILE)'="" D  Q:FOUND
	...			I $D(^TMP1($J,FOLDER,FILE)) S FOUND=1			; only capture the latest revision		
	..		I $E(REC,1,9)="Revision:" S REVISION=$P(REC," ",2) Q		; capture file revision 
	..		I $E(REC,1,7)="Author:" D
	...			S ^TMP1($J,FOLDER,FILE)=""
	.	I (ISNEW=1) D  
	..		I REC="" Q
	..		I REC=$C(13) Q
	..		S FILE=$P(REC,"|",1)
	..		S FOLDER=$P(REC,"|",2)
	..		I (ISVMS)&((FOLDER["unix")!(FOLDER["uxscrpt")) Q	; if platform is vms, don't load unix stuff	
	..		I ('ISVMS)&((FOLDER["vms")!(FOLDER["com")) Q		; if platform is unix, don't load vms stuff
	..		S ^TMP1($J,FOLDER,FILE)=""
	;
	U 0
	C IO
	Q
	;
	;----------------------------------------------------------------------
COMPARE	; This will compare the all elements in ^TMP($J) and ^TMP1($J) globals. 
	; if element is in both ^TMP($J) and ^TMP1($J), it will be removed from 
	; ^TMP($J). It will not compare % routines
	;----------------------------------------------------------------------
	;
	N FOLDER,FILE
	D logmsg("Comparing database and build_contents...")
	S (FOLDER,FILE)=""
	F  S FOLDER=$O(^TMP1($J,FOLDER)) Q:FOLDER=""  D
	.	F  S FILE=$O(^TMP1($J,FOLDER,FILE)) Q:FILE=""  D
	..		I $D(^TMP($J,FOLDER,FILE)) K ^TMP($J,FOLDER,FILE)
	Q
	;
	;----------------------------------------------------------------------
OBSO2	; This function will go through the remaining elements in ^TMP($J)
	;----------------------------------------------------------------------
	N FOLDER,FILE,LIB,TYP,ELM,EXT,DID,INFO
	S (FOLDER,FILE,EXT)=""
	F  S FOLDER=$O(^TMP($J,FOLDER)) Q:FOLDER=""  D
	.	F  S FILE=$O(^TMP($J,FOLDER,FILE)) Q:FILE=""  D
	..		S EXT=$P(FILE,".",2)
	..		S INFO=^TMP($J,FOLDER,FILE)
	..		S LIB=$P(INFO,"|",1)
	..		S TYP=$P(INFO,"|",2)
	..		S ELM=$P(INFO,"|",3)
	..		S DID=$P(INFO,"|",4)
	..		I (EXT="COL")&($E(DID,1)="_") S DID="%"_$E(DID,2,999)
	..		I (EXT="FKY")&($E(DID,1)="_") S DID="%"_$E(DID,2,999)
	..		I (EXT="FKY")&(DID["_") S DID=$TR(DID,"_",",")
	.. 		d logmsg("Removing "_LIB_"."_TYP_"."_ELM_"."_DID)
	..		I EXT="COL" K ^DBTBL(LIB,TYP,ELM,9,DID),^dbtbl(LIB,TYP,ELM,9,DID),^TMP($J,FOLDER,FILE) Q
	..		K ^DBTBL(LIB,TYP,ELM,DID),^dbtbl(LIB,TYP,ELM,DID),^TMP($J,FOLDER,FILE)
	Q
	;
CLEANUP	;
	K ^TMP($J),^TMP1($J)
	Q
	;
CNVST001(GBLREF,change)	;Private; StarTeam conversion program 1
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/03/02 19:25:45 - JOYCEJ
	; ORIG:	JOYCEJ - 07/03/02
	;
	S ERROR=0
	S change=+$g(change)
	S %LIBS="SYSDEV",CNT=0
	F LEV=1,2,3,5,7,8,9,11,25,33 D DQLEV(GBLREF,LEV)
	W !!,"Count="_CNT
	Q
	;
DQLEV(GBLREF,LEV)	
	;
	;I LEV=1 D LEVLOOP(LEV,"TBL",0)
	;I LEV=2 D LEVLOOP(LEV,"SCR",0)
	;I LEV=3 D LEVLOOP(LEV,"EXC",0)
	;I LEV=5 D LEVLOOP(LEV,"REP",0)
	I LEV=7 D LEVLOOP(GBLREF,LEV,"TRG",1)
	;I LEV=8 D LEVLOOP(LEV,"IND",1)
	I LEV=9 D LEVLOOP(GBLREF,LEV,"JNL",1)
	;I LEV=11 D LEVLOOP(LEV,"DOC",0)
	;I LEV=25 D LEVLOOP(LEV,"PSL",0)
	;I LEV=33 D LEVLOOP(LEV,"BCH",0)
	;
	Q
LEVLOOP(GBLREF,LEV,EXT,CTL)	
	;
	;	CTL	0 - Single key object
	;		1 - Double key object
	;	
	N KEY1,KEY2,FILE,DIR
	S (KEY1,KEY2)=""
	;
	I 'CTL D  Q	; Single key objects
	.	F  S KEY1=$O(@GBLREF@(%LIBS,LEV,KEY1)) Q:KEY1=""  D
	..		S ERROR=0
	..		I $$UPPER^%ZFUNC($E(KEY1))="Z" Q
	..		S FILE=KEY1_"."_EXT
	..		S GBL="^DBTBL(%LIBS,LEV,KEY1,*)"
	..		D OUT(FILE)
	;
	; Double key objects
	F  S KEY1=$O(@GBLREF@(%LIBS,LEV,KEY1)) Q:KEY1=""  D
	.	I $$UPPER^%ZFUNC($E(KEY1))="Z" Q
	.	F  S KEY2=$O(@GBLREF@(%LIBS,LEV,KEY1,KEY2)) Q:KEY2=""  D
	..		S ERROR=0
	..		I $$UPPER^%ZFUNC($E(KEY2))="Z" Q
	..		S FILE=KEY1_"_"_KEY2_"."_EXT	 
	..		D OUT(FILE)
	..		I 'ERROR Q
	..		S FIX1=$TR(KEY1,"/ %","___")
	..		S FIX2=$TR($$RTRIM^%ZS(KEY2),"/ %","___")
	..		w !!,KEY1,?20,"'",KEY2,"'",?40,FIX2
	..		I 'change Q
	..		I '$D(@GBLREF@(%LIBS,LEV,FIX1,FIX2)) D
	...			I $D(@GBLREF@(%LIBS,LEV,KEY1,KEY2))#10 S @GBLREF@(%LIBS,LEV,FIX1,FIX2)=@GBLREF@(%LIBS,LEV,KEY1,KEY2)
	...			S KEY3=""
	...			F  S KEY3=$O(@GBLREF@(%LIBS,LEV,KEY1,KEY2,KEY3)) Q:KEY3=""  D
	....				S @GBLREF@(%LIBS,LEV,FIX1,FIX2,KEY3)=@GBLREF@(%LIBS,LEV,KEY1,KEY2,KEY3)
	..		E  W !," Data converted already"
	..		K @GBLREF@("SYSDEV",LEV,KEY1,KEY2)
	;
	Q
	;
OUT(FILE)	;
	;
	I FILE["/" D ER Q
	I FILE[" " D ER Q
	I FILE["%" D ER Q
	Q
	;
	;
ER	;
	;
	S ERROR=1
	S CNT=CNT+1
	S LEVEL(LEV)=$G(LEVEL(LEV))+1
	;W !,$G(KEY1)
	;W $C(9),$G(KEY2)
	;W $C(9),"File = ",$G(FILE)
	Q
	;
	;
logmsg(str);	
	;***********************************************************************
	; Purpose: Log message to screen and log file.
	;***********************************************************************
	i $D(zlogf),zlogf'=0 u zlogf w $ZD($H,"DD-MON 24:60"),"  ",str,!	; write message to log file
	u 0 w !,$ZD($H,"DD-MON 24:60"),"  ",str,!
	q									; done
	;	
	;-----------------------------------------------------------------------
LOGF	; Create a log file
	;-----------------------------------------------------------------------
	;
	s zlogf=$$SCAU^%TRNLNM("SPOOL","OBSOLETE_"_$J_".LOG")			; log file
	s ok=$$FILE^%ZOPEN(zlogf,"WRITE/NEWV",5)				; try to open log file in WRITE mode
	i +ok=0 s zlogf=0							; how can we log anything if we can't open log file?
	d logmsg("Name of log file: "_zlogf)
	Q
	;
NFSVMS(nfs)	;  Convert a Unix NFS file name into a VMS RMS file name. 
	; 
	;  This routine takes a Unix file specification and converts it into 
	;  the equivalent RMS file name, supporting mixed case characters as 
	;  well as some special characters ("$", "_", and "-"). 
	; 
	n vms,i,fp,lc 
	s vms="",(fp,lc)=1 
	; 
	f i=1:1:$l(nfs) s vms=vms_$$rms($e(nfs,i)) 
	q vms 
	; 
rms(c)	;  Convert a single NFS file name character into an RMS file name char. 
	; 
	;  Local variables used to determine the current state: 
	; 
	;       fp      no period seen yet in the file name 
	;       lc      currently using lower case letters 
	; 
	i c?1N q c 
	i c?1U s c=$s(lc:"$"_c,1:c),lc=0 q c 
	i c?1L s c=$c($a(c)-32) s:lc=0 c="$"_c s lc=1 q c 
	i c="-" q c 
	i c="_" q c 
	i c="." s c=$s(fp:".",1:"$5N"),fp=0 q c 
	i c="$" s:$e(nfs,i+1)?1LU c="$$" q c 
	q "?" 
	; 
VMSNFS(vms)	;  Convert a VMS RMS file name into a Unix NFS file name. 
	; 
	n nfs,i,fp,lc 
	s nfs="",(fp,lc)=1 
	; 
	s i=1 
	f  q:i>$l(vms)  s nfs=nfs_$$nfs() ;(vms,i) 
	q nfs 
	; 
nfs()	;  Convert a single RMS file name character into an NFS file name char. 
	; 
	;  Input as local variables: 
	; 
	;       vms     string representing the VMS file name 
	;       i       current character position 
	; 
	n c 
	; 
	;  Get a character from the current position. 
	; 
	s c=$e(vms,i),i=i+1 
	; 
	;  Numbers and certain punctuation are just fine. 
	; 
	i c?1N q c 
	i c="_" q c 
	i c="-" q c 
	i c="." q c 
	; 
	;  Upper case letters should be dealt with appropriately. 
	; 
	i c?1U s:lc c=$c($a(c)+32) q c 
	; 
	;  Dollar sign will be tricky ... process further. 
	; 
	i c="$" d  q c 
	. i $e(vms,i)?1U s lc='lc,c="" q 
	. i $e(vms,i)?1N s c=$$esc() i c'="" s i=i+2 q 
	. s c="$" 
	; 
	;  Don't know what to do with this (yet)! 
	; 
	q "?" 
	; 
	; 
esc()	;  Process NFS escape character. 
	; 
	;  Get possible escape code. 
	; 
	s z=$e(vms,i,i+1) 
	; 
	;  Check it against any known code;  if it's real, return the Unix 
	;  file name character counterpart.  Otherwise, retunr null string. 
	; 
	i z="5N" q "." 
	q "" 
	;
	;-----------------------------------------------------------------------
CHKFILE(FILE);	Check if the file exists 
	;-----------------------------------------------------------------------
	; 
	N X
	S X=$ZSEARCH("oh.no")
	S X=$ZSEARCH(FILE)
	I X="" S ER=1,RM="File not found"
	Q
	;
	;---------------------------------------------------------------------
WARN	; Preach about the use of backups, screen captures use of caution
	;---------------------------------------------------------------------
	;
	N %READ,%NOPRMT,HDG,LINE1,LINE2,LINE3,LINE4,LINE5,LINE6
	;
	S HDG="NOTICE"
	S LINE1="You are about to obsolete elements from this Profile Runtime"
	S LINE2="Environment. All database and program files should be"
	S LINE3="backed-up before proceeding. If your terminal emulator supports"
	S LINE4="screen capture, we strongly recommended you enable it now."
	;
	S %READ="@HDG/CEN/REV,,@LINE1/CEN,@LINE2/CEN,@LINE3/CEN,@LINE4/CEN"
	D INQ^UTLREAD
	Q
	;
	;---------------------------------------------------------------------
PROMPT(MESSAGE)	; Call Yes/No prompt
	;---------------------------------------------------------------------
	;
	Q $$YN^DBSMBAR(0,MESSAGE)
	;
