DBSPGM	;Public
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/22/94 14:17:42 - CHIANG
	;     ORIG:  BOB CHIANG (8447) - 05/30/86
	; DESC: Assign run-time routine name
	;
	; KEYWORDS: DATA-QWIK,RUN-TIME ROUTINE
	;
	; INPUTS:  
	;	. DBSCLS	DATA-QWIK function class
	;                       S- SCREEN   R - REPORT
	;
	;	. %LIBS		Library name
	;
	; RETURNS:
	;	PGM		 ZnnSsss   nn=LIBS  sss=SEQ #  Z=CLASS
	;
	; EXAMPLE:
	;
	;	S DBSCLS="R",%LIBS="SYSDEV" D ^DBSPGM
	;
	;---------- Revision History -------------------------------------------
	; 11/05/05 - Pete Chenard - CR18247
	;	     Added $G around ^DBTBL(%LIBS,0,"L") because in a new
	;	     environment this will not be defined.
	;
	; 06/22/94 - Bob Chiang - 13623
	;            Modified to add a new section EXT to return the next screen
	;	     or report run-time routine name.
	;----------------------------------------------------------------------
START	;
	N XL,XS,XNAME
	;
	I $G(DBSCLS)="" S PGM="ZZZ" Q
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	L +^DBTBL(%LIBS,0):5				; Lock sequence pointer
	S XL=$G(^DBTBL(%LIBS,0,"L"))			; Library name
	I '$D(^(DBSCLS)) S ^(DBSCLS)=1			; Init sequence
	S XS=^(DBSCLS),^(DBSCLS)=XS+1			; Update next pointer
	S XNAME=$S(DBSCLS="S":"V",1:"R")		; V or R name
	I XS<1000 S PGM=XNAME_$E(100+XL,2,3)_"S"_$E(1000+XS,2,4)
	E  S PGM=XNAME_$E(100+XL,2,3)_"S"_XS		; V/RllSxxxx
	L -^DBTBL(%LIBS,0)				; Unlock pointer
	Q
	;----------------------------------------------------------------------
EXT(DBSCLS)	; Public ; Return screen or report run-time routine name
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	.DBSCLS		DATA-QWIK class		/TYP=T/REQ/REF=VAL
	;
	; RETURNS:
	;	. $$	Run-time routine name
	;
	; EXAMPLE:
	;
	;	S PGM=$$EXT^DBSPGM("R")
	;	S PGM=$$EXT^DBSPGM("S")
	;
	;----------------------------------------------------------------------
	N PGM
	D START						; Get routine name
	Q PGM
