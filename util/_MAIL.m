%MAIL	
	;;Copyright(c)1992 Sanchez Computer Associates, Inc.  All Rights Reserved  
	;     	ORIG:  		Sara Walters 6/06/95
	;		CALLED BY:	QUEALRT
	;
	;		DESC:		Interface to the OS mail utility
	;    	INPUT: 		Message to be mailed
	;   	OUTPUT: 	NONE
	;
	;----------------------------------------------------------------------
USER(MSG,USER)	; Mail a user the message in MSG
	;----------------------------------------------------------------------
	N I,N,PARAM,FILENAME,X
	;
	S FILENAME="/tmp/mail"_$J_".tmp" 
	S X=$$FILE^%ZOPEN(FILENAME,"WRITE/NEWV",1)
	U FILENAME W !,MSG
	C FILENAME
	;
	S PARAM="mail -d "_USER_" <"_FILENAME
	S X=$$SYS^%ZFUNC(PARAM)
	S X=$$SYS^%ZFUNC("rm -fr "_FILENAME)
	;
	Q X
	;
	;----------------------------------------------------------------------
BRCD(MSG,GROUP)	; Broadcast the message in MSG to a group of people
	;----------------------------------------------------------------------
	N PARAM,FILENAME,X
	;
	S FILENAME="/tmp/brcd"_$J_".tmp" 
	S X=$$FILE^%ZOPEN(FILENAME,"WRITE/NEWV",1)
	U FILENAME W !,MSG
	C FILENAME
	;
	;S PARAM="wall -g"_GROUP_" "_FILENAME
	;S PARAM="wall -groot "_FILENAME
	;S X=$$SYS^%ZFUNC(PARAM)
	;S X=$$SYS^%ZFUNC("rm -fr "_FILENAME)
	Q X
