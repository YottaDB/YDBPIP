%GO	;M Utility;Standard SCA global output in %GO format
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 17:31:44 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 01/09/89
	;
	; Standard SCA global output (%GO) utility
	; %GO format:
	;
	;    Description
	;    Date and time
	;    Global reference  ---}  These two record types
	;    Data              ---}  repeat
	;    ...
	;    Null record
	;
	; MUPIP EXTRACT is much faster than %GO, however it does not work on 
	; globals on remote nodes.  Use MUPIP EXTRACT directly if possible.
	;
	; KEYWORDS:	Global handling
	;
START	N (READ)
	W !,"Global output.  (Use MUPIP on local globals for faster %GO)",!
	S DESC=$$PROMPT^%READ("Description:  ","")
	D ^%GSEL Q:'%ZG
	D ^%SCAIO Q:$G(ER)
	U IO
	W DESC,!
	D INT^%D,INT^%T W %DAT," ",%TIM,!
	;
	S GLOB=""
LOOP	S GLOB=$O(%ZG(GLOB)) I GLOB="" G EXIT
	U 0 I IO'=$I W !,GLOB
	U IO D OUTPUT^%G(GLOB,"%GO")
	G LOOP
	;
EXIT	U IO W !	
	U 0 I $I'=IO D CLOSE^%SCAIO
	Q
