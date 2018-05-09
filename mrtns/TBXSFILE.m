TBXSFILE;Private;M routine utilities
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/26/02 18:26:23 - KWANL
	; ORIG:	KWANL - 03/26/02
	; DESC:	M routine utilities
	;
	;-------- Revision History ---------------------------------------------
	; 2009-06-18, CR40964, Jaywant Khairnar
	;	* Changed the call to TBXINST labels instead of TBXSPIN labels
	;	* Changed it to support TBX autobuild
	;
	; 2009-05-07, CR39019, Jaywant Khairnar
	;	* Changed the call for CHKDIRX^TBXDQUTL() subroutine
	;	* Removed the ISVMS parameter.
	;	* Changed LOAD() to accomodate complete file path as input parameter
	;
	; 2009-03-13, CR 38738, Frans S.C. Witte
	;	* Corrected miss-spelling of %OSSCRPT in OBSOLETE().
	;	* Added special processing for mapping of SRCDIR/uxscrpt to
	;	  TARGET/scripts.
	;
	; 2008-09-19, CR34458, Frans S.C. Witte
	;	* Subroutines LOAD() rewritten to accept and consider a target
	;	  folder instead of deriving the target forlder from the file
	;	  extension.
	;	* Added subroutine OBSOLETE() to obsolete a file from a folder.
	;	* Removed OBSRTN because it is not called (and was using the
	;	  extension as well).
	;
	; 06/26/2008	Ajitkumar - CR 34458
	;		Modified LOAD & OBSRTN section. Changed 'hpl' to 'help' 
	;		for loading the System Help Files to help subdirectory.
	;
	; 01/07/2004	Likk Kwan
	;		Changed to use absolute path when copying system files.
	;
	; 05/28/2003	Lik Kwan
	;		Changed CHKDIR to CHKDIRX. 
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME)
	;-----------------------------------------------------------------------
	;
	Q 1
	;
	;-----------------------------------------------------------------------
LOAD(FILE,FOLDER,INSTDIR)  ; Load a system files
	;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. FILE		System file to load
	;	. FOLDER	System file folder to load from and store to
	;			The caller is responsible to skip irrelevant
	;			folders.
	;	. INSTDIR	Complete file path
	;
        ; RETURNS:
        ;       . $$            Success or failure      /TYP=T
        ;                       Success 0
        ;                       Failure	1
        ;-----------------------------------------------------------------------
	;
	N DIR,FOUND,RM,STATUS,TARGET,X,$ZT
	;
	S $ZT=$$SETZT^%ZT("ZTL^TBXSFILE")
	;
	; FOUND = 0 : OK to store file
	; FOUND = 1 : do not store file, but report as "success"
	; FOUND = 2 : do not store file, and report as "failure"
	S FOUND=0
	;
	; system files from the ini subdirectory are ignored.
	; The only exception is the copy of UCOPTS.ini to $SCAU_DIR if it does
	; not overwrite an existing file. If it does exist, the skip is reported
	; as a failure, so TBXSPIN will add an entry to TBXREJ.
	I FOLDER="ini" D
	. I FILE'="UCOPTS.ini" S FOUND=1,RM="Skipped: System file "_FILE_" is template" Q
	. S TARGET=$$GETDIR()_"/"
	. S X=$ZSEARCH(TARGET_FILE)
	. I X'="" S FOUND=2,RM="UCOPTS.ini not copied to preserve the version on root directory."
	E  D
	. S TARGET=$$appdir^TBXINST($$GETDIR(),$$remap(FOLDER))
	. S X=$$CHKDIRX^TBXDQUTL(TARGET)
	. S:'X FOUND=2,RM="Skipped: directory "_TARGET_" does not exist"
	I FOUND>0 Q FOUND-1_"|"_RM
	;
	; Append FOLDER to INSTDIR
	;S DIR=$$appdir^TBXSPIN(INSTDIR,FOLDER)
	S STATUS=$$COPYFILU(INSTDIR,TARGET_FILE)
	;	
	I STATUS=1 S STATUS="1|"_FILE_" not copied"
	Q STATUS
	;
	;-----------------------------------------------------------------------
OBSOLETE(FILE,FOLDER) ; obsolete a system file from the specified folder
	;-----------------------------------------------------------------------
	; NOTES:
	; . Unlike LOAD(), this subroutine will not remap a folder name of "ini"
	;	to the application root directory.
	; . Like LOAD(), the caller is responsible to skip irrelevant folders.
	;
	N DIR,STATUS
	;
	S DIR=$$appdir^TBXINST($$GETDIR(),$$remap(FOLDER))
	;
	S STATUS=$$DELETE^%OSSCRPT(FILE,DIR)
	Q 'STATUS
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
COPYFILU(io,target)      ; Public; Generic copy of a file to a target
        ;----------------------------------------------------------------------
        N X
        S X=$$SYS^%ZFUNC("cp "_io_" "_target)
        I X'=0 Q 1
	Q 0
        ;
        ;----------------------------------------------------------------------
GETDIR() Q $$SCAU^%TRNLNM("DIR")
        ;
        ;----------------------------------------------------------------------
remap(folder) ; private String ; remap the source-folder-name to a target-folde
        ;----------------------------------------------------------------------
        ; Remap the source-folder-name to a target-folder-name.
        ; The following folder name is remapped:
        ; * uxscrpt	scripts
        ;
        I folder="uxscrpt" Q "scripts"
        Q folder
	;
        ;----------------------------------------------------------------------