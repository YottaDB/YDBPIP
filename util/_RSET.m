%RSET	;M Utility;GT.M version of M/VX routine selection
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 15:36:54 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 09 Nov 88
	;
	; GT.M version of M/VX %RSET.  Allows prompted selection of routines 
	; then returns selected routines in ^UTILITY($J).
	;
	; Provided for backward compatibility with M/VX ^%RSET, still in use
	; by older routines.
	;
	; DO NOT USE FOR NEW USES.  Instead, use ^%RSEL or one of its utilities.
	;
	; KEYWORDS:	Routine handling
	;
	; RETURNS:
	;	. %JO	Job number index		/TYP=N
	;		Job number#256 used as first
	;		key to ^UTILITY(%JO,rtn)
	;
	;	. %R	Number of routines selected	/TYP=N
	;
	N %ZR,N,I
	D ^%RSEL
	S N="",%JO=$J#256
	K ^UTILITY(%JO)
	F I=1:1 S N=$O(%ZR(N)) Q:N=""  S ^UTILITY(%JO,N)=""
	S %R=I-1
	Q
