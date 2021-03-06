TBXDQSVR ;; RPC for developers toolbox
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/10/02 15:21:11 - JOYCEJ
	; ORIG:	JOYCEJ - 10/01/01
	; DESC:	
	;
	;-------- Comments --------------------------------------------------
	; The subroutines in this module are called by MRPC121, which is a
	; DQ procedure in the TBX "FrameWorkInstall" view.
	;
	; The subroutines PSLRUN and SQLRUN call ^TBXINTERP, which is a DQ
	; procedure in the TBX "FrameWorkInstall" view.
	;
	;-------- Revision History ------------------------------------------
	; 2009-06-18, CR40964, Jaywant Khairnar
	;	* Changed the call to TBXINST labels instead of TBXSPIN labels
	;	* Changed it to support TBX autobuild
	;
	; 2009-05-20, CR39019, Jaywant Khairnar
	;	* modified the call to LOG entry in SAVEOBJ1 
	;	* modified the PVB array as per the new structure 
	;
	; 2008-11-28, CR36017, Frans S.C. Witte
	;	* Moved to TBX "FrameWorkInstall" view.
	;	* Added PRECMP and CMPLINK from an MRPC121.m (!) version
	;	* Calls ^TBXG for .G files and ^TBXDATA for .DAT files (where
	;	  possible)
	;
	; 2008-10-04, CR34458, Frans S.C. Witte
	;	Added support for mixed-case DQ Procedure names (where
	;	possible).
	;
	; 11/05/2007    Jim Joyce
	;		Added PSLRUN and SELECT functions
	;
	; 05/02/2007    NOWAKJ
	;		Added PVB("CR") initialization in section SAVEOBJ1 as
	;		LOG^TBXFPIN expects it to be initialized
	;
	; 04/27/2007	KWANl
	;		Modified SAVEOBJ1 section to use LOG^TBXFPIN instead of 
	;		LOG^TBXSPIN
	;
	; 04/26/2007	KWANL
	;		Added additional parameter "FAW" to LOG^TBXSPIN.
	;
	; 07/26/2005	JOYCEJ
	;		Improved error messages in CHECKOBJ1 and SAVEOBJ1
	;		Added missing line to SAVEOBJ1 to correct save failure
	;
	; 07/21/2005	JOYCEJ
	;		Added lines to suport new data file format: .DAT.
	;
	; JOYCEJ - 01/29/03 
	;		Added call to LOG^TBXSPIN in the SAVEOBJ1 
	;		section.
	;
	;-----------------------------------------------------------------------
CHECKOB1(LOCFILE,TOK) ; MRPC121 CHECKOBJ request
	;-----------------------------------------------------------------------
	; Check the date and user data
	;
	N CHECK,OBJTYPE,OBJID,OBJNAM
	;
	S OBJNAM=$P(LOCFILE,".")	; mixed case name
	S OBJID=$$UPPER^%ZFUNC(OBJNAM)	; upper case name
	S OBJTYPE=$$UPPER^%ZFUNC($P(LOCFILE,".",2))
	;
	S CHECK=0_$C(13,10)_"Error saving "_OBJTYPE_"-"_OBJID_" unsupported file type"
	;
	I OBJTYPE="AGR"   S CHECK=$$CHECKOBJ^TBXAGGR(TOK,OBJID)
	I OBJTYPE="BATCH" S CHECK=$$CHECKOBJ^TBXBATCH(TOK,OBJID)
	I OBJTYPE="COL"   S CHECK=$$CHECKOBJ^TBXCOL(TOK,OBJID)
	I OBJTYPE="G"     S CHECK=$$CHECKOBJ^TBXDATA(TOK,OBJID)
	I OBJTYPE="DAT"   S CHECK=$$CHECKOBJ^TBXDATA(TOK,OBJNAM) ; FSCW 2008-12-05: case sensitive
	I OBJTYPE="EXC"   S CHECK=$$CHECKOBJ^TBXEXEC(TOK,OBJID)
	I OBJTYPE="FKY"   S CHECK=$$CHECKOBJ^TBXFKEY(TOK,OBJID)
	I OBJTYPE="IDX"   S CHECK=$$CHECKOBJ^TBXIDX(TOK,OBJID)
	I OBJTYPE="JFD"   S CHECK=$$CHECKOBJ^TBXJRNL(TOK,OBJID)
	I OBJTYPE="LUD"   S CHECK=$$CHECKOBJ^TBXLUD(TOK,OBJID)
	I OBJTYPE="PPL"   S CHECK=$$CHECKOBJ^TBXPPL(TOK,OBJID)
	I OBJTYPE="PROC"  S CHECK=$$CHECKOBJ^TBXPROC(TOK,OBJNAM) ; FSCW 2007-11-01: case sensitive
	I OBJTYPE="PSL"   S CHECK=$$CHECKOBJ^TBXPROC(TOK,OBJNAM) ; FSCW 2007-11-01: case sensitive
	I OBJTYPE="QRY"   S CHECK=$$CHECKOBJ^TBXQRY(TOK,OBJID)
	I OBJTYPE="RMP"   S CHECK=$$CHECKOBJ^TBXRCDM(TOK,OBJID)
	I OBJTYPE="RPT"   S CHECK=$$CHECKOBJ^TBXRPT(TOK,OBJID)
	I OBJTYPE="SCR"   S CHECK=$$CHECKOBJ^TBXSCRN(TOK,OBJID)
	I OBJTYPE="TBL"   S CHECK=$$CHECKOBJ^TBXTBL(TOK,OBJID)
	I OBJTYPE="TRIG"  S CHECK=$$CHECKOBJ^TBXTRIG(TOK,OBJID)
	;
	Q CHECK
	;
	;-----------------------------------------------------------------------
CMPLINK(CMPTOK) ; handle MRPC121 CMPLINK request
	;-----------------------------------------------------------------------
	; DES:	Compile and Link resource.
	; Valid for tables, procedures, triggers, batch definitions
	;
	; ARGUMENTS:
	; . CMPTOK = compile token as produced by PRECMP
	;
	; INPUTS:
	; . ER = 0
	;
	; OUTPUTS:
	; . $$ = message to be returned
	; . ER = 1 if error
	;
	; NOTES:
	; . In this subroutine, the CMPTOK variable contains info about the
	;	compile. The code to be compiled must already reside in profile.
	;	The client should provide a option to upload the code prior to
	;	compiling to ensure that the latest version (if so desired) is
	;	compiled.
	; . This code will need tol be adapted for PSL Version 3 packages.
	;	The FFN field references crtns, whereas the module could reside
	;	in any of the sub-directories specified by SCAU_PACKAGES.
	;
	N CDT,EXT,FFN,OID,RTN,TYP
	;
	S TYP=$P(CMPTOK,"|",1)		; compile type (PROCEDURE or FILER)
	S OID=$P(CMPTOK,"|",2)		; Object ID. i.e. DEP or TRNDRV
	S EXT=$P(CMPTOK,"|",3)		; File extension
	S RTN=$P(CMPTOK,"|",4)		; Routine name
	S FFN=$P(CMPTOK,"|",5)		; Name and path to compiled m file
	S CDT=$P(CMPTOK,"|",6)		; Date and time stamp of compiled file
	;
	I TYP="PSL" D
	.	S ER=$$run^PSLC(OID)
	.	I ER S RM="Compile failed" Q
	.	D LINK^PBSUTL(OID)
	I TYP="PROCEDURE" D
	.	D COMPILE^DBSPROC(OID)
	.	D LINK^PBSUTL("SCA$IBS",RTN)
	;
	I TYP="FILER" D
	.	D COMPILE^DBSFILB(ID)
       	.	D LINK^PBSUTL("SCA$IBS",RTN)
	;
	I ER Q RM
	;
	N NEWCDT
	S NEWCDT=$$FILE^%ZFUNC(FFN,"CDT")
	I CDT=NEWCDT Q "Remote compile failed. Please wait a moment before attempting remote compile again, or use server compile to troubleshoot errors."
	Q TYP_" "_OID_" compile and link successful"
	;
	;-----------------------------------------------------------------------
EXECCOM1(LOCFILE,CMPTOK) ; Compile PSL source code and return errors
	;-----------------------------------------------------------------------
	;
	N CMDARY,CMPERR,CODE,MSEC,OUTFILE,PROCID,PSLSRC,SEQ,SRCFLG,TYPE,X
	N $ZT
	S $ZT="ZG "_$ZL_":ZTA^TBXDQSVR"
	;;;
	;;; FSCW 20071101:
	;;; The check below is very limiting, and never communicated to the
	;;; framework group. I stumbled across this when I modified the first
	;;; line of UCGM, and the test compiles stopped working ...
	;;;
	;;; Check for the PSL compiler
	;;I $TEXT(UCGM^UCGM)'["cmperr" Q "Remote Compile not available in "_$$^CUVAR("%VN")
	S ER=0
	S SRCFLG=0
	;;S LOCFILE=$$UPPER^%ZFUNC(LOCFILE)
	;
	S PROCID=$P(LOCFILE,"."),TYPE=$$UPPER^%ZFUNC($P(LOCFILE,".",2))
	I ",PROC,PSL,"'[(","_TYPE_",") Q "Only PSL Procedures can be test compiled"
	;
	I $G(PROCID)="" Q "Invalid Procedure"
	;
	; Start with line one to skip the header.
	S SEQ=1
	F  S SEQ=$O(^TMP(CMPTOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(CMPTOK,SEQ)
	K ^TMP(CMPTOK)
	;
	S ER=0,RM=""
	;
	; FSCW 20071101:
	; This is a deprecated entry.
	; Furthermore for proper test-compilation the PSL comiler must now the
	; name of the module it is compiling. This is currently "solved" in
	; main^UCGM by using the lvn PROCID, which is used above, as the name
	; of the module, at the cost of yet another bad dependency between
	; independent modules. 
	D main^UCGM(.CODE,.MSRC,,,.CMDARY,,.CMPERR)
	I ER Q $G(RM)
        ;
	N SEQ,RET
	S SEQ=""
        S RET=PROCID_" compiled at "_$$TIME^%ZD()_" on "
	S RET=RET_$$^%ZD()_" in "_$$^CUVAR("CONAM")_$C(13,10)
	F  S SEQ=$O(CMPERR(SEQ),1) Q:SEQ=""  D
	.	I $L(RET)>30000 Q
	.	I CMPERR(SEQ)="++++++++++++++++++++++" D  Q
	..		S RET=RET_" "_$C(13,10)_"Source: "_LOCFILE_$C(13,10) Q
	.	S RET=RET_CMPERR(SEQ)_$C(13,10)
	Q RET
        ;
	;-----------------------------------------------------------------------
EXECREV1(LOCFILE,CMPTOK) ; Execute code Review
	;-----------------------------------------------------------------------
	;
	N X,CODE,PSLSRC,OUTFILE,CMDARY,CMPERR,SRCFLG,OBJNAM,OBJTYPE,MSEC,SEQ,RET
        N $ZT,desc,tdir,hist,i18n,comment,LEVEL,v,v1,id,x,external
        S $ZT="ZG "_$ZL_":ZTA^TBXDQSVR"
	;
	S ER=0
	S SRCFLG=0
	S LOCFILE=$$UPPER^%ZFUNC(LOCFILE)
	;
	S OBJTYPE=$P(LOCFILE,".",2)
	S OBJNAM=$P(LOCFILE,".",1)	; FSCW 2007-11-01: mixed case ?
	S SEQ=""
	F  S SEQ=$O(^TMP(CMPTOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(CMPTOK,SEQ)
	K ^TMP(CMPTOK)
	;
	I ($E(OBJTYPE,1,4)="PROC") Q $$REVCODE(OBJNAM,.CODE,25)
	I ($E(OBJTYPE,1,4)="TRIG") Q $$REVCODE(OBJNAM,.CODE,7)
	I (OBJTYPE="BATCH") Q $$REVCODE(OBJID,.CODE,33)
	;
	Q "Invalid DATA QWIK element type"
	;
	;-----------------------------------------------------------------------
INITCOD1(CODE,CMPTOK) ; Store code from client in temporary global on the host
	;-----------------------------------------------------------------------
	;
	I CMPTOK="" S CMPTOK=$$GETTOKEN K ^TMP(CMPTOK)
	;
	N LINE,SEQ,I,CHR
	;
	; Remainder from last call
	S LINE=$G(^TMP(CMPTOK))
	S SEQ=$O(^TMP(CMPTOK,""),-1)+1
	;
	I CODE="" D  Q CMPTOK
	.	S ^TMP(CMPTOK,SEQ)=LINE 
	.	S ^TMP(CMPTOK)=""
	;
	; Jim Joyce - reversed the order for checking characters. 13 is the more common line seperator.
	F I=1:1:($L(CODE,"|")-1) D
	.	S CHR=$P(CODE,"|",I)
	.	I (CHR=13) Q
	.	I (CHR=10) D  Q
	..		S ^TMP(CMPTOK,SEQ)=LINE
	..		S SEQ=SEQ+1
	..		S LINE=""
	.	S LINE=LINE_$C(CHR)
	S ^TMP(CMPTOK)=LINE
	;
	Q CMPTOK
	;
	;-----------------------------------------------------------------------
INITOBJ1(OBJTYPE,OBJID)	; Initalize source code and return token
	;-----------------------------------------------------------------------
	;	Create a token and place the code in a temporary 
	;	global for retrieval by a client.
	;
	; FSCW 20081004:
	; It turns out that by the time this function is called OBJID has
	; already been converted to uppercase. So there is no way obtain the
	; PSL code of a mixed case DQ Procedure.
	;
	N CODE,SEQ,TOK,GET
	S GET=0_$C(13,10)_"Invalid type: "_OBJTYPE
	;
	I OBJTYPE="Aggregate"    S GET=$$GETCODE^TBXAGGR(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Batch"        S GET=$$GETCODE^TBXBATCH(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Column"       S GET=$$GETCODE^TBXCOL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Data"         S GET=$$GETCODE^TBXDATA(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Executive"    S GET=$$GETCODE^TBXEXEC(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Foreign Key"  S GET=$$GETCODE^TBXFKEY(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Index"        S GET=$$GETCODE^TBXIDX(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Journal"      S GET=$$GETCODE^TBXJRNL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Lookup Doc"   S GET=$$GETCODE^TBXLUD(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Pre Post Lib" S GET=$$GETCODE^TBXPPL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Procedure"    S GET=$$GETCODE^TBXPROC(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Query"        S GET=$$GETCODE^TBXQRY(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Record Map"   S GET=$$GETCODE^TBXRCDM(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Report"       S GET=$$GETCODE^TBXRPT(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Screen"       S GET=$$GETCODE^TBXSCRN(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Table"        S GET=$$GETCODE^TBXTBL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Trigger"      S GET=$$GETCODE^TBXTRIG(OBJID,.CODE,.FILENAME)
	;
	; Check for an error 
	I +GET=0 Q GET
	;
	; Place the object's contents in a temporary buffer keyed by
	; TOK for retrieval
	S SEQ=""
	S TOK=$$GETTOKEN()
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  S ^TMP(TOK,SEQ)=CODE(SEQ)
	;
	; Return a success code (1), the token and the file name
	Q 1_$C(13,10)_TOK_$C(13,10)_FILENAME
	;
	;-----------------------------------------------------------------------
PRECMP(LOCFILE)
	;-----------------------------------------------------------------------
	; Before a program can be compiled, some checks must be done.
	; Additionally, the client is given some infomation about the compile so
	; it can determine if the compile was successful.
	;
	; The client must call COMPILE with include the token returned by this
	; RPC.
	;
	; OUTPUTS:
	; . $$ = compile descriptor (bar delimited
	;	TYP = PROCEDURE, PSL or FILER
	;	OID = Object ID (remote file name without the extension)
	;	EXT = file extension (one of PROC, PSL, TBL, COL, TRIG, FKY,
	;		IDX or JRN)
	;	RTN = module name
	;	FFN = full file name crtns/RTN.m
	;	CDT = file change date
	; . ER = 1
	;	if an invalid extension is supplied
	;
	N EXT,FFN,OID,RTN,TYP
	;
	; Resource ID and file extension
	S OID=$P(LOCFILE,".")
	S EXT=$$UPPER^%ZFUNC($P(LOCFILE,".",2))
	;
	I ",PROC,PSL,COL,TRIG,TBL,JFD,FKY,IDX,"'[","_EXT_"," S ER=1 Q "File type "_EXT_" not supported by compile and link function"
	;
	I EXT="PSL" S RTN=OID,TYP="PSL"
	E  I EXT="PROC" S RTN=$P($G(^DBTBL(%LIBS,25,OID)),"|",2),TYP="PROCEDURE"
	E  D
	.	S OID=$P(OID,"-"),TYP="FILER"
	.	I $$VALID^%ZRTNS("PSLC") S RTN="Record"_OID
	.	E  S RTN=$P($G(^DBTBL(%LIBS,1,OID,99)),"|",2)
	;
	I RTN="" S ER=1 Q "Missing program name for "_LOCFILE
	;
	; FSCW 2008-12-05: no longer true for PSL Version 3 and above, but this
	;	shall be handled by the code that ZLINKs AFTER a successful
	;	compile (because the package may not yet be known).
	S FFN=$$SCAU^%TRNLNM("CRTNS")_"/"_RTN_".m"
	;
	; Create a compile token to pass into the compile function
	Q TYP_"|"_ID_"|"_EXT_"|"_RTN_"|"_FFN_"|"_$$FILE^%ZFUNC(FFN,"CDT")
	;
	;-----------------------------------------------------------------------
PSLRUN(CMPTOK)	; Remote PSL invocation 
	;-----------------------------------------------------------------------
	;
	N X,CODE,SYSOUT,MSRC,CMPERR,SRCFLG,PROCID,MSRC,SEQ
	N $ZT
	S $ZT="ZG "_$ZL_":ZTA^TBXDQSVR"
	S ER=0
	;
	S SEQ=""
	F  S SEQ=$O(^TMP(CMPTOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(CMPTOK,SEQ)
	K ^TMP(CMPTOK)
	;
	S ER=0,RM=""
	D PSL^TBXINTERP(.CODE,.SYSOUT,.MSRC,.CMPERR)
	I ER Q $G(RM)
	; 
	N SEQ,RET
	S SEQ=1
	S RET="<div id=""Runtime"">"_SYSOUT(SEQ)_"</div>"_$C(13,10) 
	; 
	F  S SEQ=$O(SYSOUT(SEQ)) Q:SEQ=""  D
	.	I $L(RET)>1000000 Q
	.	S RET=RET_SYSOUT(SEQ)_$C(13,10) 	
	;    	
	I $D(CMPERR) D
	.	S SEQ=""
	.	S RET=RET_$C(13,10)_"Compile errors> "_$C(13,10)
	.	F  S SEQ=$O(CMPERR(SEQ)) Q:SEQ=""  D
	..		I $L(RET)>1000000 Q
	..		S RET=RET_CMPERR(SEQ)_$C(13,10)
	;
	I $D(MSRC) D
	.	S SEQ=""
	.	S RET=RET_$C(13,10)_"M Source> "_$C(13,10)
	.	F  S SEQ=$O(MSRC(SEQ)) Q:SEQ=""  D
	..		I $L(RET)>1000000 Q
	..		S RET=RET_MSRC(SEQ)_$C(13,10)
	;
	;
	Q RET
	;
	;-----------------------------------------------------------------------
RETOBJ1(TOK) ;
	;-----------------------------------------------------------------------
	;
	N BLOCK,CNT,MORE,RETURN,REC,SEQ
	;
	; BLOCK is the maximum number of rows to return in each call
	S BLOCK=300
	S (SEQ,RETURN,CNT)=""
	;
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""!(CNT=BLOCK)  D
	.	S REC=^TMP(TOK,SEQ)
	.	S RETURN=RETURN_REC
	.	I $D(^TMP(TOK,SEQ+1)) S RETURN=RETURN_$C(13,10)
	.	K ^TMP(TOK,SEQ)
	.	S CNT=CNT+1
	;
	; Flag to indicate that there are more rows to return
	S MORE=$E($D(^TMP(TOK)))
	;
	Q MORE_RETURN
	;
	;-----------------------------------------------------------------------
REVCODE(OBJID,CODE,LEVEL)
	;-----------------------------------------------------------------------
	;
	N coderv,SEQ,DBATYPE,RET
	;
	I LEVEL=7 S DBATYPE=7
	I LEVEL=33 S DBATYPE=7
	I LEVEL=25 S DBATYPE=3
	;
	S SEQ=""
	;
        S RET=OBJID_" code reviewed at "_$$TIME^%ZD()_" on "
	S RET=RET_$$^%ZD()_" in "_$$^CUVAR("CONAM")_$C(13,10)
	I DBATYPE=3 D SETUP3^TBXCKDQ
	I DBATYPE=7 D SETUP7^TBXCKDQ
	;
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	.	N coderv,ERSEQ
	.	I DBATYPE=3 D EXT3^TBXCKDQ(CODE(SEQ),LEVEL,OBJID,SEQ,1)
	.	I DBATYPE=7 D EXT7^TBXCKDQ(CODE(SEQ),LEVEL,OBJID,SEQ,1)
	.		;
	.	S ERSEQ=""
	.	F  S ERSEQ=$O(coderv(ERSEQ),1) Q:ERSEQ=""  D
	..		I $L(RET)>30000 Q
	..		S RET=RET_coderv(ERSEQ)_$C(13,10)
	;
	S ER=0
	;
	Q RET
	;-----------------------------------------------------------------------
SAVEOBJ1(LOCFILE,TOK,USER)	; Save object with contents of tmp buffer
	;-----------------------------------------------------------------------
	N SAVE,OBJTYPE,OBJID,OBJNAM,%LOGID,DATA,%FN
	;
	S OBJTYPE=$$UPPER^%ZFUNC($P(LOCFILE,".",2))
	S OBJNAM=$P(LOCFILE,".")	; mixed case name
	S OBJID=$$UPPER^%ZFUNC(OBJNAM)	; upper case name
	;
	S SAVE=0_$C(13,10)_"Error saving "_OBJTYPE_"-"_OBJID_" unsupported file type"
	;
	; Set %LOGID to the network user for call to SYSLOG
	S %LOGID=$$LOGID^SCADRV()
	S $P(%LOGID,"|",2)=USER
	S %FN="SAVEOBJ^TBXDQSVR"
	S DATA=$$SYSLOG^SCADRV0()
	;
	I OBJTYPE="AGR"   S SAVE=$$SAVEOBJ^TBXAGGR(TOK,OBJID,USER)
	I OBJTYPE="BATCH" S SAVE=$$SAVEOBJ^TBXBATCH(TOK,OBJID,USER)
	I OBJTYPE="COL"   S SAVE=$$SAVEOBJ^TBXCOL(TOK,OBJID,USER)
	I OBJTYPE="DAT"   S SAVE=$$SAVEOBJ^TBXDATA(TOK,OBJNAM,USER) ; FSCW 2008-12-05: case sensitive
	I OBJTYPE="G"     S SAVE=$$SAVEOBJ^TBXDATA(TOK,OBJID,USER)
	I OBJTYPE="EXC"   S SAVE=$$SAVEOBJ^TBXEXEC(TOK,OBJID,USER)
	I OBJTYPE="FKY"   S SAVE=$$SAVEOBJ^TBXFKEY(TOK,OBJID,USER)
	I OBJTYPE="IDX"   S SAVE=$$SAVEOBJ^TBXIDX(TOK,OBJID,USER)
	I OBJTYPE="JFD"   S SAVE=$$SAVEOBJ^TBXJRNL(TOK,OBJID,USER)
	I OBJTYPE="LUD"   S SAVE=$$SAVEOBJ^TBXLUD(TOK,OBJID,USER)
	I OBJTYPE="PPL"   S SAVE=$$SAVEOBJ^TBXPPL(TOK,OBJID,USER)
	I OBJTYPE="PROC"  S SAVE=$$SAVEOBJ^TBXPROC(TOK,OBJNAM,USER) ; FSCW 2007-11-01: case sensitive
	I OBJTYPE="PSL"   S SAVE=$$SAVEOBJ^TBXPROC(TOK,OBJNAM,USER) ; FSCW 2007-11-01: case sensitive
	I OBJTYPE="QRY"   S SAVE=$$SAVEOBJ^TBXQRY(TOK,OBJID,USER)
	I OBJTYPE="RMP"   S SAVE=$$SAVEOBJ^TBXRCDM(TOK,OBJID,USER)
	I OBJTYPE="RPT"   S SAVE=$$SAVEOBJ^TBXRPT(TOK,OBJID,USER)
	I OBJTYPE="SCR"   S SAVE=$$SAVEOBJ^TBXSCRN(TOK,OBJID,USER)
	I OBJTYPE="TBL"   S SAVE=$$SAVEOBJ^TBXTBL(TOK,OBJID,USER)
	I OBJTYPE="TRIG"  S SAVE=$$SAVEOBJ^TBXTRIG(TOK,OBJID,USER)
	;
	; Log action
	N FOLDER,FILE,PVB,REVISION,DATE,TIME,MSG
	S FOLDER=""
	S FILE=LOCFILE
	;
	; local customization will have highest priority i.e. 99
	;
	S PVB(99,"PROJ")=""
	S PVB(99,"VIEW")=""
	S PVB(99,"BLD")=""
	S REVISION=""
	S DATE=""
	S TIME=""
	S MSG="MRPC:"_$S(+SAVE:"Saved",1:"Failed")
	;
	D LOG^TBXINST(DATE,FILE,FOLDER,.PVB,99,REVISION,TIME,USER,MSG)
	;
	I +SAVE D SYSLOGXT^SCADRV0(DATA)
	;
	Q SAVE
	;
	;-----------------------------------------------------------------------
SQLRUN(CMPTOK)	; Remote SQL invocation 
	;-----------------------------------------------------------------------
	;
	N X,CODE,SYSOUT,MSRC,CMPERR,SRCFLG,PROCID,MSRC,SEQ
	N $ZT
	S $ZT="ZG "_$ZL_":ZTA^TBXDQSVR"
	;
	S SEQ=""
	F  S SEQ=$O(^TMP(CMPTOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(CMPTOK,SEQ)
	K ^TMP(CMPTOK)
	;
	S ER=0,RM=""
	D SQL^TBXINTERP(.CODE,.SYSOUT)
	I ER Q $G(RM)
	; 
	N SEQ,RET
	S SEQ=1
	S RET="<div id=""Runtime"">"_SYSOUT(SEQ)_"</div>"_$C(13,10) 
	;
	F  S SEQ=$O(SYSOUT(SEQ)) Q:SEQ=""  D
	.	I $L(RET)>1000000 Q
	.	S RET=RET_SYSOUT(SEQ)_$C(13,10) 
	;
	Q RET
	;
	;=======================================================================
	; Local support methods.
	;
	; All methods below are private, and shall not be called by other
	; routines.
	;
	;-----------------------------------------------------------------------
GETTOKEN()	; Compute token
	;-----------------------------------------------------------------------
	;
	Q "TOK"_$J_"-"_$P($H,",",2)_"-"_$R(100000)
	;
	;---------------------------------------------------------------------        ;
ZTA     ;
	;---------------------------------------------------------------------        ;
	S ER=0
	I $G(RM)="" S RM=$ZS
        Q RM
