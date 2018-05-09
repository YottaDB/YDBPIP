%GOGEN	;; - UTL - V3.6 - Standard SCA global output in %GOGEN format
	;;Copyright(c)1992 Sanchez Computer Associates, Inc.  All Rights Reserved - 18 SEP 1992 15:26:40 - RUSSELL
	;     ORIG:  Dan S. Russell (2417) - 09 Jan 89
	;CALLED BY:  
	;    CALLS:  %SCAIO
	; PROJ #'S:  
	;     DESC:  Standard SCA global output (%GOGEN format).
	;
	;            Allows selection of portions or ranges of global
	;            nodes (ala %G) as well as renaming on input with
	;            %GIGEN.
	;
	; GLOBALS -
	;     READ:  
	;      SET:  
	;
	;    INPUT:  none
	;   OUTPUT:  none
	;
	;EXT ENTRY:  D EXT^%GOGEN(global_ref) for %GOGEN output format
	;            D END^%GOGEN to write ending records
	;
START	N (READ)
	W !,"%GOGEN Global output",!
	D ^%SCAIO Q:$G(ER)
	;
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%GOGEN"
	;
LOOP	U 0:(CTRAP=$C(3)) S READ("PROMPT")="Global ^",X=""
	D ^%READ I X="" G EXIT
	D VALID^%G(X) I ER U 0 W "  ",RM S ER=0 G LOOP
	U IO:(CTRAP=$C(3))
	D EXT(X)
	G LOOP
	;
EXT(GBL)	; Output in %GOGEN format.  May be called externally while
	; IO device is being used for %GOGEN format output of GBL
	D HDR(GBL),OUTPUT^%G(GBL,"%GO")
	W "***DONE***",!
	Q
	;
HDR(GBL)	; Write header records.  May be called externally while
	; IO device is being used for %GOGEN format output of GBL.
	N %DAT,%TIM
	D INT^%T,INT^%D
	W !,"Transferring files on ",%DAT," at ",%TIM,!
	W GBL,!!
	Q
	;
ERR	I $ZS["CTRAP" G LOOP
	U 0 W !,$P($ZS,",",2,999)
	G LOOP
	;
END	; Write final records.  May be called externally using IO device.
	W !,"***DONE***",!!
	Q
	;
EXIT	U IO D END
	U 0 I $I'=IO D CLOSE^%SCAIO
	Q
