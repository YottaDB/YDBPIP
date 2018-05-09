DBSCLI	;Library;Client/Server Client Side interface
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/01/96 11:27:47 - ROTELLA
	; ORIG:	ROTELLA - 09/22/94
	; DESC:	Client/Server Client Side interface
	;
	; KEYWORDS:	Client/Server
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. v1	desc of variable	/TYP=T
	;
	;
	; RELATED:
	;	. STUB^PBSCLI 	- 	Generic private MRPC program call
	;
	;
	; LIBRARY:
	;	. STUB	-	DATA QWIK Private MRPC Interface
	;
	;
	;-------- Revision History ---------------------------------------------
	;  08/01/96 - mjr - ARQ# 18828 
	;	      Correct problems added by release below
	;
	;  07/02/96 - mjr - ARQ# 18828, 18435
	;	      Added change to correct Offline function problems.
	;
	;
	;-----------------------------------------------------------------------
	;
	;
	Q
	;
	;
	;-----------------------------------------------------------------------
STUB(vzrpc,vzver,vzpar,vzlst,vzinp,vzout,vzlog)	;Private;DATA QWIK MRPC call
	;
	; DESC:
	;	 DATQ QWIK Interface to generic private MRPC program call
	;	 Service class = 3.
	;
	; KEYWORDS: Client/Server
	;
	; INPUTS:
	;	. System  
	;		%FN	Function Name		/TYP=T/COND
	;		%LOGID	Login Information	/TYP=T/REQ
	;
	; ARGUMENTS:
	;     . vzrpc	Remote Procedure Call		/TYP=T/REQ
	;		Public  = [SCATBL5]RPCID	/MECH=VAL
	;		Private = {$$}{tag}^pgm
	;
	;     . vzver	Version control string		/TYP=T/COND
	;		(Required if MRPC is		/MECH=VAL
	;		 version controlled)
	;
	;     . vzpar	Input parameters		/TYP=T/NOREQ
	;		(public MRPC only)		/MECH=REFARR:R
	;		par(1)-par(n)
	;
	;     . vzlst	Input list (ordered)		/TYP=T/NOREQ
	;		(private MRPC only)		/MECH=REFNAM:R
	;		val1,val2,val3...
	;
	;     . vzinp	Variable save list (client)	/TYP=T/NOREQ
	;		(private MRPC only)		/MECH=REFNAM:R
	;		lvn1,lvn2,lvn3...
	;
	;     . vzout	Variable save list (server)	/TYP=T/NOREQ
	;		(private MRPC only)		/MECH=REFNAM:R
	;		lvn1,lvn2,lvn3...
	;
	;     . vzlog	Log message			/TYP=N/NOREQ
	;		(private MRPC only)		/MECH=VAL/DFT=0
	;		0 = Do not log, 1 = Log
	;
	; RETURNS:
	;     . RM	Error flag			/TYP=N/COND
	;	
	;		ER will only be returned if the calling function
	;		is NOT "Off-Line" Enabled.  STFENABL^SCADRV is
	;		called to determine the return value of ER.  If
	;		the calling function is "off-line" enabled then
	;		ER is returned as 0.
	;
	; EXAMPLE:
	;     . From DATA QWIK Screen VLOD section
	;     . D STUB^DBSCLI("VLOD^V01S100",15,,CID,,"v") 
	;
	;----------------------------------------------------------------------
	;
	N vzreturn
	;
	S vzver=$G(vzver)
	S vzpar=$G(vzpar)
	S vzlst=$G(vzlst)
	S vzinp=$G(vzinp)
	S vzout=$G(vzout)
	S vzlog=$G(vzlog)
	;
	S vzreturn=$$MRPC^PBSCLI(vzrpc,vzver,vzpar,vzlst,vzinp,vzout,vzlog)
	;
	D ERROR(.ER,.RM) 
	;
	S vzout=$G(vzout)
	;
	I '$$ONLINE() D  
	.	S vzreturn=$G(vzreturn)
	.	N x,i
	.	F i=1:1:$L(vzout,",") D  
	..		S x=$P(vzout,",",i) 
	..		I $D(@x) Q			;  Already defined
	..		S @x=$G(@x) 			;  Set to ""
	;
	Q
	;
	;-----------------------------------------------------------------------
RETREC(frm,sel,acc,ext,del,qwt,fsn,vdd)	;public; Return database record
	;----------------------------------------------------------------------
	; Returns a list of values corresponding to an input list of data
	; items. Multi-table capability based on foriegn key definitions.
	; Uses RPC protocol in client mode.
	;
	; Note: See documentation for $$RETVAL
	;
	; KEYWORDS: Database
	;
	; RELATED: SETVAL^DBSDD,$$RETVAL^DBSDD
	;
	; ARGUMENTS:
	;	. frm		List of valid files	/REQ/MECH=VAL/DEL=44
	;	. sel		Select Item List	/REQ/MECH=VAL/DEL=44
	;	. acc		Access key values	/REQ/MECH=VAL
	;	. ext		External Format		/NOREQ
	;	. del		ASCII Field Delimiter	/NOREQ/MECH=VAL/DFT=124
	;	. qwt		ASCII Quote Character	/NOREQ/MECH=VAL
	;	. fsn(file)	File Attributes	Header	/NOREQ/MECH=REF:RW
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;
	;   RETURNS:
	;	. $$	Database value List
	;	. ER    (0,1) Error Flag
	;       . RM    Error message message (If ER=1)
	;
	;  EXAMPLES:
	; W $$RETREC^DBSDD("DEP","BAL,BALAVL,LNM,TLD",1,1,44,34,.fsn,.vdd)
	; 1000.00,850.00,"SMITH,JOHN",01/03/92
	;
	; W $$RETREC^DBSDD("DBTBL1D","DI,DES,NOD,POS","SYSDEV,DEP,BAL")
	; "BAL|Ledger Balance|51|1"
	;----------------------------------------------------------------------
	N vzrecord
	I '%NET Q ""				;  host not available
	;
	S frm=$G(frm) Q:frm="" ""
	S sel=$G(sel) Q:sel="" ""
	S acc=$G(acc) Q:acc="" ""
	S ext=$G(ext)
	S del=$G(del)
	S qwt=$G(qwt)
	;
	S vzrecord=$$RETREC^DBSDD(frm,sel,acc,ext,del,qwt,.fsn,.vdd)
	;
	D ERROR(.ER,.RM)
	Q vzrecord
	;
	;----------------------------------------------------------------------
ERROR(ER,RM)	; Private ; Error Handler for above functions
	;  DESC:
	;		Resets ER,RM when an error occurs that is related
	;		to network problems, if a function is Off-Line
	;		enalbed.
	;
	;  ARGUMENTS:
	;	.  ER		Error Flag		/TYP=N/MECH=REF:RW
	;	.  RM		Return Error Message	/TYP=T/MECH=REF:RW
	;
	;  RETURNS:
	;	.  ER		Error Flag		/TYP=N
	;	.  RM		Return Message		/TYP=T
	;----------------------------------------------------------------------
	N stf
	S stf=$$STFENABL^SCADRV($G(%FN))
	S ER=$G(ER),RM=$G(RM)
	;
	I ER=2,stf S ER=0,RM="",%NET=0 Q	;  mjr 10/27
	I +$G(%LOGID)=2,stf S ER=0,RM="",%NET=0 Q
	Q
	;
	;
	;----------------------------------------------------------------------
ONLINE()	;  Private ; Check %NET and %CSID
	;----------------------------------------------------------------------
	I '$G(%LOGID) Q 1		;  Host
	I '%NET Q 0			;  Net flagged down
	I $G(%CSID)="" Q 0		;  No HOST connection
	Q 1
	;
