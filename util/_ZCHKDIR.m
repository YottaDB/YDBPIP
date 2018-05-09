%ZCHKDIR	;System;Directory validation routine
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:36:50 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 08 Nov 88
	;
	; Return name of directory.  May use as DATA-QWIK post
	; processor.
	;
	; KEYWORDS:	System Services
	;
	; INPUTS:
	;	. X	Directory name		/TYP=T
	;
	; RETURNS:
	;	. X	Directory name if valid	/TYP=T
	;
	;---- Revision History ------------------------------------------------
        ;
        ; 03/27/02 - Harsha Lakshmikantha - 46174
        ;            Modified CHKDIR section to validate a directory entry.
        ;            Prior to this change the directory validation worked only
	;	     on a VMS platform.
        ;
	;----------------------------------------------------------------------
CHKDIR	;================= Directory checker (post-processor) ===============
	I '$D(X) Q
	N Z
	S Z=$ZSEARCH("/tmp")	; reset the context
	S X=$ZSEARCH(X)
	I X="" S ER=1,RM="Invalid directory"
	Q
