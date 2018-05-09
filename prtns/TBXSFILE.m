TBXSFILE;Private;M	routine utilities 
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/26/02 18:26:23 - KWANL
	; ORIG:	KWANL - 03/26/02
	; DESC:	M routine utilities
	;
	; KEYWORDS:	
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. v1	desc of variable	/TYP=T
	;
	; RETURNS:
	;	. XX	desc of return		/TYP=T
	;
	; RELATED:
	;	. $$func^rtn - description of how related
	;
	; EXAMPLE:
	;	Text of example (line one)
	;
	;-----------------------------------------------------------------------
	; Revision History:
	; 01/07/2004	Likk Kwan
	;		Changed to use absolute path when copying system files.
	;
	; 05/28/2003	Lik Kwan
	;		Changed CHKDIR to CHKDIRX. 
	;-----------------------------------------------------------------------
	;
CHECK(FILE,RUSER,RDATE,RTIME)	
	;-----------------------------------------------------------------------
	;
	Q 1
	;
	;-----------------------------------------------------------------------
LOAD(FILE,INSTDIR,RTYPE)	; Load a system files 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. FILE		System files to load
	;	. INSTDIR	Release directory
	;	. RTYPE		Release type
	;			  1: Fixpack
	;			  2: Service Pack
	;	. ISNFS		NFS mounted disk
	;
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success 0 
	;                       Failure 1
	;----------------------------------------------------------------------- 
	;
	N $ZT,STATUS,EXT,TARGET,ISVMS,ISNFS,X,DIR,FOUND
	S $ZT=$$SETZT^%ZT("ZTL^TBXSFILE")
	;
	S EXT=$P(FILE,".",2)
	S ISVMS=$ZVERSION["VMS"
	S ISNFS=0
	I (ISVMS)&($ZTRNLNM($P(INSTDIR,":",1))["NFS") S ISNFS=1
	;
	I EXT="COM" S TARGET=$S(ISVMS:"COM",1:"")
	I EXT="DOC" S TARGET=$S(ISVMS:"DOC",1:"doc")
	I EXT="SH" S TARGET=$S(ISVMS:"",1:"uxscrpt")
	I EXT="EXP" S TARGET=$S(ISVMS:"EXP",1:"exp")
	I EXT="GOG" S TARGET=$S(ISVMS:"GOG",1:"gog")
	I (EXT="HLP")!(EXT="HLB") S TARGET=$S(ISVMS:"HELP",1:"hlp")
	I EXT="ini" s TARGET=$S(ISVMS:$$GETDIR(),1:$$GETDIR()_"/")
	;
	Q:$G(TARGET)="" "0|Skipped: System file "_FILE_" is not for this platform"
	;
	S:EXT'="ini" TARGET=$$appdir^TBXDQUTL($$GETDIR(),"["_TARGET_"]")
	S X=$$CHKDIRX^TBXDQUTL(TARGET,ISVMS)
	Q:'X
	;
	S X="HELLO",FOUND=0
	;
	I EXT="ini" d  Q 1
	. S X=$ZSEARCH(TARGET_FILE)
	. S:X'="" FOUND=1
	. S:FOUND RM="UCOPTS.ini not copied to preserve the version on root directory."
	;
	;
	I 'ISVMS S STATUS=$$COPYFILU(INSTDIR_"/"_FILE,TARGET_FILE)
	I ISVMS&'ISNFS S STATUS=$$COPYFILV(INSTDIR_FILE,TARGET_FILE)
	I ISVMS&ISNFS S STATUS=$$COPYFILV(INSTDIR_$$NFSVMS^TBXDQUTL(FILE),TARGET_FILE)
	;	
	I STATUS=1 S RM=FILE_" not copied"
	Q STATUS
	;
	;-----------------------------------------------------------------------
OBSRTN(FILE,HOSTDIR);	obsolete a routine 
	;-----------------------------------------------------------------------
	;
	N STATUS,DIR,ISVMS
	S EXT=$P(FILE,".",2)
	;
	S ISVMS=$ZVERSION["VMS"
	;
	I EXT="COM" S DIR=$S(ISVMS:"COM",1:"")
	I EXT="DOC" S DIR=$S(ISVMS:"DOC",1:"doc")
	I EXT="SH" S DIR=$S(ISVMS:"",1:"uxscrpt")
	I EXT="EXP" S DIR=$S(ISVMS:"EXP",1:"exp")
	I EXT="GOG" S DIR=$S(ISVMS:"GOG",1:"gog")
	I (EXT="HLP")!(EXT="HLB") S TARGET=$S(ISVMS:"HELP",1:"hlp")
	;
	S DIR=$$appdir^TBXDQUTL($$GETDIR(),"["_DIR_"]")
	;
	Q:TARGET="" "0|Skipped: System file "_FILE_" is not for this platform"
	S STATUS=$$DELETE^%OSCCRPT(FILE,DIR)
	Q 'STATUS
	;
	;----------------------------------------------------------------------
ZTL	; Error trap for load 
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to load element. "_X 
	; 
	Q 0_"|"_RM 
	; 
	;---------------------------------------------------------------------- 
COPYFILU(io,target)	; Public; Generic copy of a file to a target 
	;---------------------------------------------------------------------- 
	N X 
	S X=$$SYS^%ZFUNC("cp "_io_" "_target) 
	I X'=0 Q 1 
	Q 0
	; 
	;---------------------------------------------------------------------- 
COPYFILV(io,target)	; Public; Generic copy of a file to a target 
	;---------------------------------------------------------------------- 
	; 
	N X 
	; 
	S X=$$SYS^%ZFUNC("COPY/NOLOG "_io_" "_target) 
	I X#2=0 Q 1 
	Q 0 
	; 
GETDIR();	
	Q $$SCAU^%TRNLNM("DIR")        
