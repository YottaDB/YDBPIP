MRPC121(RET,VERSN,type,CODE,CMPTOK,LOCFILE,OBJTYPE,OBJID,TOK,USER)	
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/10/02 09:26:58 - CHEUNGA
	; ORIG:	CHEUNGA - 06/04/02
	;
	; DESC:	MRPC121
	; This procedure is used to facilitate the sending, receiving, code 
	; review, and compiling of code on the host system from the 
	; Sanchez/Profile Java Interface via the Sanchez JDBC Driver. The 
	; ToolBox program TBXDQSVR is being called from this procedure to 
	; perform these functions.
	; 
	;
	; ARGUMENTS:
	;
	;     . RET   Value of fields requested       /TYP=T/REQ
	;                                               /MECH=REFNAM:W 
	;     . VERSN   ^MRPC121 version number         /TYP=N/REQ 
	;               Current version = 1             /MECH=VAL 
	; 
	;     . type	Subsection type			/TYP=T		
	;
	;     . CODE	Code from the file		/TYP=T
	;                                                
	;     . CMPTOK	Compilation token		/TYP=T
	;                                                
	;     . LOCFILE Local file			/TYP=T
	;                                           
	;     . OBJID	Object ID			/TYP=T
	;
	;     . OBJTYPE	Object Type			/TYP=T
	;
	;     . TOK     Token				/TYP=T
	;
	;     . USER    User ID				/TYP=T
	;
	;
	; RETURNS:
	;       . $$            Error Message           /TYP=T 
	; 
	;
	;-------- Revision History ------------------------------------------
	; 11/05/2007    Jim Joyce
	;		Added PSLRUN and SELECT functions
	;
	;-----------------------------------------------------------------------
	; Check type here to determent which subsection is being called from
	; the client
	;  
	I type="INITOBJ" Q $$INITOBJ^MRPC121(.RET,VERSN,OBJTYPE,OBJID)
	I type="RETOBJ" Q $$RETOBJ^MRPC121(.RET,VERSN,TOK)
	I type="INITCODE" Q $$INITCODE^MRPC121(.RET,VERSN,CODE,CMPTOK)
	I type="CHECKOBJ" Q $$CHECKOBJ^MRPC121(.RET,VERSN,LOCFILE,TOK)
	I type="SAVEOBJ" Q $$SAVEOBJ^MRPC121(.RET,VERSN,LOCFILE,TOK,USER)
	I type="EXECCOMP" Q $$EXECCOMP^MRPC121(.RET,VERSN,LOCFILE,CMPTOK)
	I type="EXECREV" Q $$EXECREV^MRPC121(.RET,VERSN,LOCFILE,CMPTOK)
	I type="PSLRUN" Q $$PSLRUN^MRPC121(.RET,VERSN,CMPTOK)
	I type="SQLRUN" Q $$SQLRUN^MRPC121(.RET,VERSN,CMPTOK)
	;
	S ER=1,RM="Invalid TBX RPC type: "_type
	Q $$ERRMSG^PBSUTL(RM)
	;
	;-----------------------------------------------------------------------
INITOBJ(RET,VERSN,OBJTYPE,OBJID)	;
	;
	; DESC: calls INITOBJ^TBXDQSVR MRPC and returns CMPTOK
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 Q $$ERRMSG^PBSUTL($$^MSG(2951)) 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	; 
	S RET=$$INITOBJ1^TBXDQSVR(OBJTYPE,OBJID) 
	; 
	;
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q ""
	;
	;-----------------------------------------------------------------------
RETOBJ(RET,VERSN,TOK)	;
	;
	; DES: Calls RETOBJ^TBXDQSVR and returns Object
	;
	;-----------------------------------------------------------------------
	; 
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 Q $$ERRMSG^PBSUTL($$^MSG(2951)) 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	; 
	S RET=$$RETOBJ1^TBXDQSVR(TOK) 
	; 
	;
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	;
	;-----------------------------------------------------------------------
INITCODE(RET,VERSN,CODE,CMPTOK)	;
	;
	; DES: INITCODE^TBXDQSVR and returns CMPTOK
	;
	;-----------------------------------------------------------------------
	; 
	S ER=0
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 Q $$ERRMSG^PBSUTL($$^MSG(2951)) 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	; 
	S RET=$$INITCOD1^TBXDQSVR(CODE,CMPTOK) 
	; 
	;
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	;
	;-----------------------------------------------------------------------
CHECKOBJ(RET,VERSN,LOCFILE,TOK)	;
	;
	; DESC: Calls CHECKOBJ^TBXDQSVR and returns CHECK 
	; 
	;----------------------------------------------------------------------- 
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 S RM=$$^MSG(2951) Q 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	. Q 
	; 
	S RET=$$CHECKOB1^TBXDQSVR(LOCFILE,TOK) 
	; 
	;
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	;
	;-----------------------------------------------------------------------
SAVEOBJ(RET,VERSN,LOCFILE,TOK,USER)	;
	;
	; DES: Calls SAVEOBJ^TBXDQSVR and returns SAVE
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 S RM=$$^MSG(2951) Q 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	. Q 
	; 
	S RET=$$SAVEOBJ1^TBXDQSVR(LOCFILE,TOK,USER) 
	; 
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	;
	;-----------------------------------------------------------------------
EXECCOMP(RET,VERSN,LOCFILE,CMPTOK)	;
	;
	; DES: calls EXECCOMP^TBXDQSVR and return CMPERR
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 S RM=$$^MSG(2951) Q 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	. Q 
	; 
	S RET=$$EXECCOM1^TBXDQSVR(LOCFILE,CMPTOK) 
	; 
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	;
	;-----------------------------------------------------------------------
EXECREV(RET,VERSN,LOCFILE,CMPTOK)	;
	;
	; DES: calls EXECREV^TBXDQSVR and return LOCFIL and COMTOK
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 S RM=$$^MSG(2951) Q 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	. Q 
	; 
	S RET=$$EXECREV1^TBXDQSVR(LOCFILE,CMPTOK) 
	; 
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	;
	;-----------------------------------------------------------------------
PSLRUN(RET,VERSN,CMPTOK)	
	;
	; DES: RPC entry for remote PSL invocation
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 S RM=$$^MSG(2951) Q 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	. Q 
	; 
	S RET=$$PSLRUN^TBXDQSVR(CMPTOK) 
	; 
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	; 
	;-----------------------------------------------------------------------
SQLRUN(RET,VERSN,CMPTOK)	
	;
	; DES: RPC entry for remote PSL invocation
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 
	S RM="" 
	; Version number of client message is not compatible with server 
	I $G(VERSN)'=1 S ER=1 S RM=$$^MSG(2951) Q 
	; 
	; If an error occurred, save it in the %SVCNTXT variable 
	I $G(ER) D  Q $$ERRMSG^PBSUTL(RM) 
	. S RM=$G(RM) 
	. S %SVCNTXT("ER")=ER ; Save ER error code 
	. S %SVCNTXT=RM ; Save Error Message 
	. Q 
	; 
	S RET=$$SQLRUN^TBXDQSVR(CMPTOK) 
	; 
	S RET=$$V2LV^MSG(.RET) 
	; 
	Q "" 
	
