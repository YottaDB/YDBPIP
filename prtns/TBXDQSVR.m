TBXDQSVR	;Private; RPC for developers toolbox
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/10/02 15:21:11 - JOYCEJ
	; ORIG:	JOYCEJ - 10/01/01
	; DESC:	
	;
	;-------- Revision History ------------------------------------------
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
GETTOKEN()	; Compute token
	;-----------------------------------------------------------------------
	Q "TOK"_$J_$P($H,",",2)_$R(100000)
	;-----------------------------------------------------------------------
INITOBJ1(OBJTYPE,OBJID)	; Initalize source code and return token
	;-----------------------------------------------------------------------
	;
	;	Create a token and place the code in a temporary 
	;	global for retrieval by a client.
	;
	N CODE,SEQ,TOK,GET
	S GET=0_$C(13,10)_"Invalid type: "_OBJTYPE
	;
	I OBJTYPE="Aggregate" S GET=$$GETCODE^TBXAGGR(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Batch" S GET=$$GETCODE^TBXBATCH(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Column" S GET=$$GETCODE^TBXCOL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Data" S GET=$$GETCODE^TBXDATA(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Executive" S GET=$$GETCODE^TBXEXEC(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Foreign Key" S GET=$$GETCODE^TBXFKEY(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Index" S GET=$$GETCODE^TBXIDX(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Journal" S GET=$$GETCODE^TBXJRNL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Lookup Doc" S GET=$$GETCODE^TBXLUD(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Pre Post Lib" S GET=$$GETCODE^TBXPPL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Procedure" S GET=$$GETCODE^TBXPROC(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Query" S GET=$$GETCODE^TBXQRY(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Record Map" S GET=$$GETCODE^TBXRCDM(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Report" S GET=$$GETCODE^TBXRPT(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Screen" S GET=$$GETCODE^TBXSCRN(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Table" S GET=$$GETCODE^TBXTBL(OBJID,.CODE,.FILENAME)
	I OBJTYPE="Trigger" S GET=$$GETCODE^TBXTRIG(OBJID,.CODE,.FILENAME)
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
RETOBJ1(TOK)	
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
INITCOD1(CODE,CMPTOK)	; Store code from client in temporary global on the host 
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
CHECKOB1(LOCFILE,TOK)	; Check the date and user data
	;-----------------------------------------------------------------------
	N CHECK,OBJTYPE,OBJID
	;
	S OBJID=$$UPPER^%ZFUNC($P(LOCFILE,".",1))
	S OBJTYPE=$$UPPER^%ZFUNC($P(LOCFILE,".",2))
	;
	S CHECK=0_$C(13,10)_"Error saving "_OBJTYPE_"-"_OBJID_" unsupported file type"
	;
	I OBJTYPE="AGR" S CHECK=$$CHECKOBJ^TBXAGGR(TOK,OBJID)
	I OBJTYPE="BATCH" S CHECK=$$CHECKOBJ^TBXBATCH(TOK,OBJID)
	I OBJTYPE="COL" S CHECK=$$CHECKOBJ^TBXCOL(TOK,OBJID)
	I OBJTYPE="G" S CHECK=$$CHECKOBJ^TBXDATA(TOK,OBJID)
	I OBJTYPE="DAT" S CHECK=$$CHECKOBJ^TBXDATA(TOK,OBJID)	
	I OBJTYPE="EXC" S CHECK=$$CHECKOBJ^TBXEXEC(TOK,OBJID)
	I OBJTYPE="FKY" S CHECK=$$CHECKOBJ^TBXFKEY(TOK,OBJID)
	I OBJTYPE="IDX" S CHECK=$$CHECKOBJ^TBXIDX(TOK,OBJID)
	I OBJTYPE="JFD" S CHECK=$$CHECKOBJ^TBXJRNL(TOK,OBJID)
	I OBJTYPE="LUD" S CHECK=$$CHECKOBJ^TBXLUD(TOK,OBJID)
	I OBJTYPE="PPL" S CHECK=$$CHECKOBJ^TBXPPL(TOK,OBJID)
	I OBJTYPE="PROC" S CHECK=$$CHECKOBJ^TBXPROC(TOK,OBJID)
	I OBJTYPE="QRY" S CHECK=$$CHECKOBJ^TBXQRY(TOK,OBJID)
	I OBJTYPE="RMP" S CHECK=$$CHECKOBJ^TBXRCDM(TOK,OBJID)
	I OBJTYPE="RPT" S CHECK=$$CHECKOBJ^TBXRPT(TOK,OBJID)
	I OBJTYPE="SCR" S CHECK=$$CHECKOBJ^TBXSCRN(TOK,OBJID)
	I OBJTYPE="TBL" S CHECK=$$CHECKOBJ^TBXTBL(TOK,OBJID)
	I OBJTYPE="TRIG" S CHECK=$$CHECKOBJ^TBXTRIG(TOK,OBJID)
	;
	Q CHECK
	;-----------------------------------------------------------------------
SAVEOBJ1(LOCFILE,TOK,USER)	; Save object with contents of tmp buffer
	;-----------------------------------------------------------------------
	N SAVE,OBJTYPE,OBJID,%LOGID,DATA,%FN
	;
	S OBJTYPE=$$UPPER^%ZFUNC($P(LOCFILE,".",2))
	S OBJID=$$UPPER^%ZFUNC($P(LOCFILE,".",1))
	;
	S SAVE=0_$C(13,10)_"Error saving "_OBJTYPE_"-"_OBJID_" unsupported file type"
	;
	; Set %LOGID to the network user for call to SYSLOG
	S %LOGID=$$LOGID^SCADRV()
	S $P(%LOGID,"|",2)=USER
	S %FN="SAVEOBJ^TBXDQSVR"
	S DATA=$$SYSLOG^SCADRV0()
	;
	I OBJTYPE="AGR" S SAVE=$$SAVEOBJ^TBXAGGR(TOK,OBJID,USER)
	I OBJTYPE="BATCH" S SAVE=$$SAVEOBJ^TBXBATCH(TOK,OBJID,USER)
	I OBJTYPE="COL" S SAVE=$$SAVEOBJ^TBXCOL(TOK,OBJID,USER)
	I OBJTYPE="DAT" S SAVE=$$SAVEOBJ^TBXDATA(TOK,OBJID,USER)
	I OBJTYPE="G" S SAVE=$$SAVEOBJ^TBXDATA(TOK,OBJID,USER)
	I OBJTYPE="EXC" S SAVE=$$SAVEOBJ^TBXEXEC(TOK,OBJID,USER)
	I OBJTYPE="FKY" S SAVE=$$SAVEOBJ^TBXFKEY(TOK,OBJID,USER)
	I OBJTYPE="IDX" S SAVE=$$SAVEOBJ^TBXIDX(TOK,OBJID,USER)
	I OBJTYPE="JFD" S SAVE=$$SAVEOBJ^TBXJRNL(TOK,OBJID,USER)
	I OBJTYPE="LUD" S SAVE=$$SAVEOBJ^TBXLUD(TOK,OBJID,USER)
	I OBJTYPE="PPL" S SAVE=$$SAVEOBJ^TBXPPL(TOK,OBJID,USER)
	I OBJTYPE="PROC" S SAVE=$$SAVEOBJ^TBXPROC(TOK,OBJID,USER)
	I OBJTYPE="QRY" S SAVE=$$SAVEOBJ^TBXQRY(TOK,OBJID,USER)
	I OBJTYPE="RMP" S SAVE=$$SAVEOBJ^TBXRCDM(TOK,OBJID,USER)
	I OBJTYPE="RPT" S SAVE=$$SAVEOBJ^TBXRPT(TOK,OBJID,USER)
	I OBJTYPE="SCR" S SAVE=$$SAVEOBJ^TBXSCRN(TOK,OBJID,USER)
	I OBJTYPE="TBL" S SAVE=$$SAVEOBJ^TBXTBL(TOK,OBJID,USER)
	I OBJTYPE="TRIG" S SAVE=$$SAVEOBJ^TBXTRIG(TOK,OBJID,USER)
	;
	; Log action
	N FOLDER,FILE,PVB,REVISION,DATE,TIME,MSG
	S FOLDER=""
	S FILE=$$UPPER^%ZFUNC(LOCFILE)
	S PVB("PROJECT")=""
	S PVB("VIEW")=""
	S PVB("BUILD")=""
	S PVB("CR")=""
	S REVISION=""
	S DATE=""
	S TIME=""
	S MSG="MRPC:"_$S(+SAVE:"Saved",1:"Failed")
	D LOG^TBXFPIN(FOLDER,FILE,.PVB,REVISION,USER,DATE,TIME,MSG)
	;
	I +SAVE D SYSLOGXT^SCADRV0(DATA)
	;
	Q SAVE
	;
	;-----------------------------------------------------------------------
EXECCOM1(LOCFILE,CMPTOK)	; Compile PSL source code and return errors 
	;-----------------------------------------------------------------------
	;
	N X,CODE,PSLSRC,OUTFILE,CMDARY,CMPERR,SRCFLG,PROCID,MSEC,SEQ
	N $ZT
	S $ZT="ZG "_$ZL_":ZTA^TBXDQSVR"
	; 
	; Check for the PSL compiler
	I $TEXT(UCGM^UCGM)'["cmperr" Q "Remote Compile not available in "_$$^CUVAR("%VN")
	S ER=0
	S SRCFLG=0
	S LOCFILE=$$UPPER^%ZFUNC(LOCFILE)
	;
	I $P(LOCFILE,".",2)'="PROC" Q "Only PSL Procedures can be test compiled"
	S PROCID=$P(LOCFILE,".PROC",1)
	;
	I $G(PROCID)="" Q "Invalid Procedure"
	;
	; Start with line one to skip the header.
	S SEQ=1
	F  S SEQ=$O(^TMP(CMPTOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(CMPTOK,SEQ)
	K ^TMP(CMPTOK)
	;
	S ER=0,RM=""
	; Do not pass the PGM parameter to UCGM. This is a test compile. 
	; Passing PGM would trigger a real compile.
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
EXECREV1(LOCFILE,CMPTOK)	; Execute code Review 
	;-----------------------------------------------------------------------
	;
	N X,CODE,PSLSRC,OUTFILE,CMDARY,CMPERR,SRCFLG,OBJTYPE,MSEC,SEQ,RET
	N $ZT,desc,tdir,hist,i18n,comment,LEVEL,v,v1,id,x,external 
	S $ZT="ZG "_$ZL_":ZTA^TBXDQSVR" 
	;
	S ER=0
	S SRCFLG=0
	S LOCFILE=$$UPPER^%ZFUNC(LOCFILE)
	;
	S OBJTYPE=$P(LOCFILE,".",2)
	S OBJID=$P(LOCFILE,".",1)
	S SEQ=""
	F  S SEQ=$O(^TMP(CMPTOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(CMPTOK,SEQ)
	K ^TMP(CMPTOK)
	;
	I ($E(OBJTYPE,1,4)="PROC") Q $$REVCODE(OBJID,.CODE,25)
	I ($E(OBJTYPE,1,4)="TRIG") Q $$REVCODE(OBJID,.CODE,7)
	I (OBJTYPE="BATCH") Q $$REVCODE(OBJID,.CODE,33)
	;
	Q "Invalid DATA QWIK element type"
	;
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
	; 
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
	;---------------------------------------------------------------------        ;
ZTA	; 
	;---------------------------------------------------------------------        ;
	S ER=0
	I $G(RM)="" S RM=$ZS
	Q RM 
	;
	;
