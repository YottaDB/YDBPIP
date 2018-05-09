%ZSHSAVE(REF)	;Public;Save various ZSH information into variable
	;;Copyright(c) Sanchez Computer Associates, Inc.  All Rights Reserved - // - 
	;     ORIG:  RUSSELL - 10 DEC 1990
	;
	; Save device, lock, and stack information provided by ZSHOW into
	; variable, array, or global specified by REF.
	;
	; KEYWORDS: System services
	;
	; ARGUMENTS:
	;     . REF	Variable, array, or global	/TYP=T/REQ
	;		reference to save data		/MECH=REFARR:RW
	; RETURNS:
	;     REF("D",seq)=device info
	;         "L",seq)=lock info
	;         "S",seq)=stack info
	;
	; EXAMPLE:
	;     D ^%ZSHSAVE("ABC(1,2)")
	;          Returns:
	;                      ABC(1,2,"D",1-n)=device info
	;                      ABC(1,2,"L",1-n)=lock info
	;                      ABC(1,2,"S",1-n)=stack info
	;----------------------------------------------------------------------
	;
	ZSH "DLS":@REF
	Q
