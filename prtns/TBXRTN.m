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
	; Revision History:
	; 01/18/2006	KWANL
	;		Updates changes.
	;
	; 12/22/2003	Lik Kwan
	;		Changed to use absolute path when installing a routine.		
	;
	; 01/22/2002	Lik kwan
	;		Remove call to _OSSCRPT.m use local subroutine.
	;
	; 12/05/2002	LiK Kwan
	;		Added LOADPRTN section which will use Makefile to load
	;		% rotuine.
	; 
	; 11/22/2002	Lik Kwan
	;		Modified OBSRTN section to obolete routine from mrnts 
	;		directory.
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME)
	;-----------------------------------------------------------------------
	;
	Q 1
	;
	;-----------------------------------------------------------------------
LOADPRTN(FILE,HOSTNODE,SOURCEDIR,TARGETDIR,CFLAG,PFLAG); Load a % routine
	;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. FILE		% Routine to install
	;	. HOSTNODE	The host's system name
	;	. SOURCEDIR	Source direcotry 
	;	. TARGETDIR	Target directory
	;	. CFLAG		Compile flag
	;			  0: not compile
	;			  1: compile
	;	. PFLAG		Preserve date time stamp flag
	;			  0: default: preserve
	;			  1: Not preserve
        ; RETURNS:
        ;       . $$            Success or failure      /TYP=T
        ;                       Success = 0
        ;                       Failure = 1
	;
	N $ZT,CMD,RTN,ER,ISVMS,X
	S $ZT=$$SETZT^%ZT("ZTL^TBXRTN")
	;
	S ISVMS=($ZVER["VMS")
	I ISVMS Q $$LOAD(FILE,HOSTNODE,SOURCEDIR,TARGETDIR,CFLAG,PFLAG)
	;
	; if host is unix, look for Makefile in target directory
	; if Makefile is not found, call LOAD to load the routine
	; if Makefile is found, use make command
	;
	S X=$ZSEARCH("oh.no")
	S X=$ZSEARCH(TARGETDIR_"/Makefile")
	I X="" Q $$LOAD(FILE,HOSTNODE,SOURCEDIR,TARGETDIR,CFLAG,PFLAG)
	;
	S RTN=$P(FILE,".",1)
	; copy the % routine to target directory, don't compile, we will use Makefile
	S ER=$$COPYRTNU(HOSTNODE,SOURCEDIR,RTN,TARGETDIR,0,PFLAG)
	I ER=1 S RM=FILE_" not copied" Q ER
	S CMD="cd "_TARGETDIR_" ; make "_RTN_".o"
	S X=$$SYS^%ZFUNC(CMD)
	I X'=0 S ER=1,RM=FILE_" not compiled" 
	;
	Q ER
	;-----------------------------------------------------------------------
LOAD(FILE,HOSTNODE,SOURCEDIR,TARGETDIR,CFLAG,PFLAG)  ; Load a routine
	;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. FILE		Routine to install
	;	. HOSTNODE	The host's system name
	;	. SOURCEDIR	Source direcotry without file name
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
        ;                       Success = 0
        ;                       Failure = 1
        ;-----------------------------------------------------------------------
	;
	N $ZT,STATUS,RTN,ER,ISVMS,ISNFS,NFSNAME,RTNDIR
	S $ZT=$$SETZT^%ZT("ZTL^TBXRTN")
	;
	S RTN=$P(FILE,".",1)
	S ISVMS=($ZVER["VMS")
	S ISNFS=0
	I (ISVMS)&($ZTRNLNM($P(SOURCEDIR,":",1))["NFS") S ISNFS=1	
	;
	S RTNDIR=$$SCAU^%TRNLNM($$UPPER^%ZFUNC(TARGETDIR))
	I RTNDIR="" S RTNDIR=TARGETDIR		; if no references defined, use the path provided. 
	;
	I 'ISVMS D 
	.	S ER=$$COPYRTNU(HOSTNODE,SOURCEDIR,RTN,RTNDIR,CFLAG,PFLAG)
	I (ISVMS)&('ISNFS) D
	.	S ER=$$COPYRTNV(HOSTNODE,SOURCEDIR,RTN,RTNDIR,CFLAG)
	I (ISVMS)&(ISNFS) D
	.	S ER=$$NFSCOPY(HOSTNODE,SOURCEDIR,RTN,RTNDIR,CFLAG)
	;
	I $D(^TMPDQS($J,"phase1","routine",RTN)) s ^TMPDQS($J,"phase1")=1
	I $D(^TMPDQS($J,"phase2","routine",RTN)) s ^TMPDQS($J,"phase2")=1
	;
	I ER=1 S RM="Routine not loaded"
	;	
	Q ER
	;
	;-----------------------------------------------------------------------
OBSRTN(FILE); Remove a routine from mrtns.
	;-----------------------------------------------------------------------
	;
	N RTNAME,DIR
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
NFSCOPY(hostnode,hostdir,rtn,rtndir,cmp) ; Private; Copy routine from a NFS mounted 
	;	disk & compile
        ;----------------------------------------------------------------------
        ; Copy routine, called by HOST to FEP routine update/
        ;
        ; ARGUMENTS:
        ;       . hostnode      - The host's system name /TYP=T/REQ/MECH=VAL
        ;
        ;       . hostdir       - Host diorectory name  /TYP=T/REQ/MECH=VAL
        ;
        ;       . rtn           - Routine name          /TYP=T/REQ/MECH=VAL
        ;
        ;       . rtndir        - Target Directory      /TYP=T/REQ/MECH=VAL
        ;
        ;       . cmp           - Compile flag          /TYP=L/REQ/MECH=VAL
        ;
        ; RETURNS:
        ;       . $$            - Error status (success or failure)
        ;----------------------------------------------------------------------
        ;
        N CMD,X,NFSRTN,RTN
        ;
	S RTN=rtn_".m"
	;
	S NFSRTN=$$NFSVMS^TBXDQUTL(RTN)
	;
        I hostnode'="" S CMD="COPY/NOLOG "_hostnode_"::"_hostdir_NFSRTN_" "_rtndir_RTN
        E  S CMD="COPY/NOLOG "_hostdir_NFSRTN_" "_rtndir_RTN
        ;
        S X=$$SYS^%ZFUNC(CMD)
        I X#2=0 Q 1              ;Routine not copied
        ;
        ; Purge routine
        S X=$$SYS^%ZFUNC("PURGE "_rtndir_RTN)
        I 'cmp Q 0
        ;
        ; Compile routine
        U 0 W !,RTN
        ;
        S X=$$SYS^%ZFUNC("@SCA$RTNS:SCA_COMPILE "_rtndir_RTN)
	I X#2=0 Q 1
        Q 0
	;
        ;----------------------------------------------------------------------
COPYRTNU(hostnode,hostdir,rtn,rtndir,cmp,prv)    ; Private; Copy routine & compile
	; This subroutine is for unix
        ;----------------------------------------------------------------------
        ; Copy routine, called by HOST to FEP routine update/
        ;
        ; ARGUMENTS:
        ;       . hostnode      - The host's system name /TYP=T/REQ/MECH=VAL
        ;
        ;       . hostdir       - Host diorectory name  /TYP=T/REQ
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
        N CMD,X,RTN
        S RTN=rtn_".m"
        I +$G(prv)=0 D
        .       I hostnode'="" S CMD="rcp -p "_hostnode_":"_hostdir_RTN_" "_rtndir_"/"_RTN
        .       E  S CMD="cp -p "_hostdir_RTN_" "_rtndir_"/"_RTN
        I $G(prv) D
        .       I hostnode'="" S CMD="rcp "_hostnode_":"_hostdir_RTN_" "_rtndir_"/"_RTN
        .       E  S CMD="cp "_hostdir_RTN_" "_rtndir_"/"_RTN
        ;
        S X=$$SYS^%ZFUNC(CMD)
        I X'=0 Q 1              ; Routine not copied
        ;
	; change file permission
	S CMD="integer a=777-`umask` ; chmod -f $a "_rtndir_"/"_RTN
	S X=$$SYS^%ZFUNC(CMD)
	;
        I 'cmp Q 0
        ; Compile routine
	new msg
	set msg="loading "_RTN
	do logmsg^TBXDQUTL(msg,$g(zlogf),1) 
	U 0 W !,RTN,!
        S CMD="$SCA_RTNS/sca_compile.sh 1 "_rtndir_" "_rtndir_"/obj/"_" "_RTN
        S X=$$SYS^%ZFUNC(CMD)
	I X'=0 Q 1
	Q 0
	;
        ;----------------------------------------------------------------------
COPYRTNV(hostnode,hostdir,rtn,rtndir,cmp)        ; Private; Copy routine & compile
	; This subroutine is for VMS
        ;----------------------------------------------------------------------
        ; Copy routine, called by HOST to FEP routine update/
        ;
        ; ARGUMENTS:
        ;       . hostnode      - The host's system name /TYP=T/REQ/MECH=VAL
        ;
        ;       . hostdir       - Host diorectory name  /TYP=T/REQ/MECH=VAL
        ;
        ;       . rtn           - Routine name          /TYP=T/REQ/MECH=VAL
        ;
        ;       . rtndir        - Target Directory      /TYP=T/REQ/MECH=VAL
        ;
        ;       . cmp           - Compile flag          /TYP=L/REQ/MECH=VAL
        ;
        ; RETURNS:
        ;       . $$            - Error status (success or failure)
        ;----------------------------------------------------------------------
        ;
        N CMD,X,RTN
        ;
        S RTN=rtn_".M"
        I hostnode'="" S CMD="COPY/NOLOG "_hostnode_"::"_hostdir_RTN_" "_rtndir_RTN
        E  S CMD="COPY/NOLOG "_hostdir_RTN_" "_rtndir_RTN
        ;
        S X=$$SYS^%ZFUNC(CMD)
        I X#2=0 Q 1              ;Routine not copied
        ;
        ; Purge routine
        S X=$$SYS^%ZFUNC("PURGE "_rtndir_RTN)
        I 'cmp Q 0
        ;
        ; Compile routine
        U 0 W !,RTN
        ;
        S X=$$SYS^%ZFUNC("@SCA$RTNS:SCA_COMPILE "_rtndir_RTN)
	I X#2=0 Q 1
        Q 0
        ;        