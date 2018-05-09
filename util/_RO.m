%RO	;M Utility;Standard SCA routine output
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/28/97 07:50:15 - SYSCHENARD
	; ORIG:  RUSSELL - 29 OCT 1989
	;
	; Routine output in standard routine output format
	;   Rec 1 = date
	;   Rec 2 = description
	;   Repeats - Routine name
	;             line 1...
	;             last line
	;             Null record
	;   Final record = null record
	;
	; NOTE: External call without prompting by calling
	;	  S CNT=$$EXT^%RO(DEVICE,DESCRIPTION,.RTNLST)
	;       See EXT section for details
	;
	; KEYWORDS:	Routine handling
	;
	;------Revision History-------------------------------------------------
	; 03/28/97 - Phil Chenard
	;            Replaced reference to source code extension of .M w/
	;            a lowercase .m.  This will ensure equal handling and
	;            a single version of this routine across all platforms.
	;
	;-----------------------------------------------------------------------
	N (READ)
	W !,"Routine output."
	S DESC=$$PROMPT^%READ("Description:  ","")
	D ^%RSEL Q:'$G(%ZR)
	D ^%SCAIO
	S CNT=$$EXT(IO,DESC,.%ZR,0)
	D CLOSE^%SCAIO
	U 0:(EXC="")
	W !!,"Total of ",CNT," routine",$s(CNT>1:"s",1:"")," output.",!
	Q
	;
	;----------------------------------------------------------------------
EXT(DEV,DESC,RTNLST,NODISP)	;M Utility;Routine output without prompting
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. DEV		Device - must be opened		/TYP=T
	;			Will not be closed by this
	;			this routine.  Must be closed
	;			by caller.
	;
	;	. DESC		Description			/TYP=T
	;
	;	. RTNLST(rtn	Routine names to output		/TYP=T
	;
	;	. RTNLST(rtn)	Directory location		/TYP=T
	;			RTNLST must be in %RSEL
	;			format.
	;
	;	. NODISP	Display option			/TYP=L/NOREQ
	;			  0 => no display		/DEF=0
	;			  1 => display
	;
	; RETURNS:
	;	. $$		Count of routines output	/TYP=N
	;
	; EXAMPLE:
	;	S CNT=$$EXT^%RO(DEV,DESC,RTNLST,NODISP)
	;
	N (DEV,DESC,RTNLST,NODISP,IOTYP)
	S NODISP=$G(NODISP)
	I DEV=$P S NODISP=1 ; Don't display routine names if output to $P
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%RO"
	; If output to terminal, format output with tab in
	; If output to printer, form feed between routines
	S (TRM,FF)=0 I $G(IOTYP)="TRM" S TRM=1 I DEV'=$P S FF=1
	I 'NODISP U 0:(CTRAP=$C(3):EXC="ZG "_$ZL_":CTRAP^%RO")
	I 'NODISP W !
	U DEV
	W DESC,!,$$^%ZD($H,"DD-MON-YEAR 24:60:SS"),!
	S RTN="",CNT=0
	F  S RTN=$O(RTNLST(RTN)) Q:RTN=""  D OUTPUT
	U DEV W !!
	I 'NODISP U 0:EXC=""
	Q CNT  ; Return number of routines to caller
	;
OUTPUT	; Write the routine
	S FILE=RTNLST(RTN)_$TR($E(RTN),"%","_")_$E(RTN,2,999)_".m"  ;03/28/97
	O FILE:(READ:REWIND:EXC="G NOOPEN") U FILE:EXC=""
	I 'NODISP U 0 W:$X>70 ! W RTN,?$X\10+1*10
	S CNT=CNT+1
	U DEV
	I FF W #
	W RTN,!
	F  U FILE R X Q:$ZEOF  S NEWX=$$FORMAT(X,'TRM) I NEWX'="" U DEV W NEWX,!
	U DEV W !
	C FILE
	Q
	;
	;----------------------------------------------------------------------
FORMAT(LINE,OPTION)	;M Utility;Replace tabs in source code with spaces
	;----------------------------------------------------------------------
	;
	; Removes tabs in source code lines and replaces with spaces.  Used
	; for various formatting.
	;
	; Called by other utilities, e.g. ^%RTNDESC, ^%RCHANGE, ^%RFIND
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. LINE		Source code line	/TYP=T
	;
	;	. OPTION	Change option		/TYP=N
	;			  0 => change all tabs to spaces
	;			  1 => only change first tab to
	;			       a single space
	;
	; RETURNS:
	;	. $$		Formatted line		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$FORMAT(X,OPTION)
	;
	I LINE="" Q "" ; If null, return null
	N TAB,X
	; If option=1, just make first tab a single space
	I $G(OPTION) S LINE=$P(LINE,$C(9),1)_" "_$P(LINE,$C(9),2,999) Q LINE
	S TAB=0
	F  S TAB=$F(LINE,$C(9),TAB) Q:'TAB  S LINE=$E(LINE,1,TAB-2)_$J("",8-(TAB-2#8))_$E(LINE,TAB,999)
	F X=$L(LINE):-1:0 Q:$E(LINE,X)'=" "
	S LINE=$E(LINE,1,X)
	Q LINE
	;
NOOPEN	; Unable to open .M file
	U 0 W !,"Error opening file ",FILE,!,$P($ZS,",",2,999),!
	Q
	;
ERR	; Error on output
	U 0 W !,"Error during routine output",!,$P($ZS,",",2,999),!
	U 0:EXC=""
	I $G(FILE)'="" C FILE
	Q ""
