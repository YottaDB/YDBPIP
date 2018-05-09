TBXPSLX;Private;M routine utilities
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/07 11:13:23 - KWANL
	; ORIG:	KWANL - 10/26/07
	; DESC:	deal with .pslx file from FP, SP, or MRPC
	;
	;---------- Revision History -------------------------------------------
	; 2009-04-28, CR39019, Jaywant Khairnar
	;	* Modified LOAD() to use new signature 
	;	* Changed the output value for sucess of LOAD()
	;
	; 10/26/07	Lik Kwan
	;		First revision to support Class Module Definition.
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME)
	;-----------------------------------------------------------------------
	;
	Q 1
	;
	;-----------------------------------------------------------------------
LOAD(PSLPATH)  ; Load a system files
	;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. PSLPATH	complete file name
	;
        ; RETURNS:
        ;       . $$            Success or failure      /TYP=T
        ;                       Success 1
        ;                       Failure	0
        ;-----------------------------------------------------------------------
	;
	N STATUS,$ZT
	S $ZT=$$SETZT^%ZT("ZTL^"_$T(+0))
	;
	S STATUS=$$storePslx^PSLC(PSLPATH)
	Q 1
	;
	;-----------------------------------------------------------------------
OBSDQW(FILE); obsolete a routine
	;-----------------------------------------------------------------------
	; The drop^PSLC is similar to runpgm^TBXDQUTL which will remove .m, .o files
	; when a procedure is obsoleted. The dqobso^TBXDQUTL which calls runpgm will
	; remove the entry from DBTBL25 and drop^PSLC will only remove the files 
	; related to the proc(ie: .pslx, psl, .m, and .o file) from an environment. 
	;
	N FNAME
	S FNAME=$P(FILE,".",1)
	d drop^PSLC(FNAME)
	Q 1
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