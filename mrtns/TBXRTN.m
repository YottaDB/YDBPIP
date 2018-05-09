TBXRTN	;Private;M routine utilities
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
	;
	; Revision History:
	; 2009-06-25, CR39019, Jaywant Khairmar
	;	* added commented logic to change file permission
	;	* removed hostnode parameter from COPYRTNU label
	;	* removed unwanted code 
	;	* LOADPRTN - which was used for percent routine
	;
	; 2009-04-24, CR39019, Jaywant Khairmar
	;	* Modified the LOAD() to remove VMS check and 
	;	* code as per the complete file path send as input parameter
	;	* removed the third paramter for logmsg^TBXDQUTL
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME)
	;-----------------------------------------------------------------------
	;
	Q 1
	;
	;-----------------------------------------------------------------------
	;-----------------------------------------------------------------------
LOAD(FILE,HOSTNODE,SOURCEFILE,TARGETDIR,CFLAG,PFLAG)  ; Load a routine
	;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. FILE		Routine to install
	;	. HOSTNODE	The host's system name
	;	. SOURCEFILE	Source directory with file name
	;	. TARGETDIR	Target routine directory
	;			  Valid entry
	;				MRTNS,PRTNS,CRTNS,SRTNS or user defined absolute path
	;	. CFLAG		Compile flag
	;			  0: not compile
	;			  1: compile
	;	. PFLAG		Preserve date time stamp flag
	;			  0: default: preserve
	;			  1: Not preserve
        ; RETURNS:
        ;       . $$            Success or failure      /TYP=T
        ;                       Success = 1
        ;                       Failure = 0
        ;-----------------------------------------------------------------------
	;
	N ER,ISVMS,ISNFS,NFSNAME,RTN,RTNDIR,STATUS,$ZT
	S $ZT=$$SETZT^%ZT("ZTL^TBXRTN")
	S STATUS=1
	;
	S RTN=$P(FILE,".",1)
	;
	S RTNDIR=$$SCAU^%TRNLNM($$UPPER^%ZFUNC(TARGETDIR))
	I RTNDIR="" S RTNDIR=TARGETDIR		; if no references defined, use the path provided. 
	;
	S ER=$$COPYRTNU(SOURCEFILE,RTN,RTNDIR,CFLAG,PFLAG)
	;
	I $D(^TMPDQS($J,"phase1","routine",RTN)) s ^TMPDQS($J,"phase1")=1
	I $D(^TMPDQS($J,"phase2","routine",RTN)) s ^TMPDQS($J,"phase2")=1
	;
	I ER=1 S RM="Routine not loaded",STATUS=0
	;	
	Q STATUS
	;
	;-----------------------------------------------------------------------
OBSRTN(FILE); Remove a routine from mrtns.
	;-----------------------------------------------------------------------
	;
	N DIR,RTNAME
	S RTNAME=$P(FILE,".",1)
	S DIR=$$SCAU^%TRNLNM("MRTNS")
	D DEL^%ZRTNDEL(RTNAME,DIR)
	q 1
	;
	;----------------------------------------------------------------------
ZTL     ; Error trap for load
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
COPYRTNU(hostfile,rtn,rtndir,cmp,prv)    ; Private; Copy routine & compile
	; This subroutine is for unix
        ;----------------------------------------------------------------------
        ; Copy routine, called by HOST to FEP routine update/
        ;
        ; ARGUMENTS:
        ;       . hostnode      - The host's system name /TYP=T/REQ/MECH=VAL
        ;
        ;       . hostfile       - Host diorectory with file name  /TYP=T/REQ
        ;
        ;       . rtn           - Routine name
        ;
        ;       . rtndir        - Routine directory to load
        ;
        ;       . cmp           - Compile flag
        ;                               0: Not compile
        ;                               1: Compile
        ;
        ;       . prv           - Preserve date-time stamp and user flag
        ;                               0: default, preserve
        ;                               1: Not Preserve
        ;
        N CMD,RTN,X
        S RTN=rtn_".m"
        I +$G(prv)=0 D
        .       S CMD="cp -p "_hostfile_" "_rtndir_"/"_RTN
        I $G(prv) D
        .       S CMD="cp "_hostfile_" "_rtndir_"/"_RTN
        ;
        S X=$$SYS^%ZFUNC(CMD)
        I X'=0 Q 1              ; Routine not copied
        ;
        ;; uncomment this code to change file permission
        ;S CMD="integer a=777-`umask` ; chmod -f $a "_rtndir_"/"_RTN
        ;S X=$$SYS^%ZFUNC(CMD)
        ;; end of file permission change code
        ;
        I 'cmp Q 0
        ; Compile routine
	new msg
	set msg="loading "_RTN
	do logmsg^TBXDQUTL(msg,$g(zlogf)) 
	U 0 W !,RTN,!
        S CMD="$SCA_RTNS/sca_compile.sh 1 "_rtndir_" "_rtndir_"/obj/"_" "_RTN
        S X=$$SYS^%ZFUNC(CMD)
	I X'=0 Q 1
	Q 0
	;
	;----------------------------------------------------------------------