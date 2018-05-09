TBX	;Private;Toolbox utilities
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/15/01 16:20:31 - RUSSELL
	; ORIG:	RUSSELL - 10/18/01 - ARQ 48301
	; DESC:	Toolbox utilities
	;
	; The TBX* routines are internal utilities designed for testing or
	; other purposes by Sanchez.  They are not intended for customer use
	; except as directed by Sanchez.
	;
	; This routine contains utilities that may be commonly used by other
	; TBX routines.
	;
	; KEYWORDS:	Toolbox
	;
	; LIBRARY:
	;	. DISCLAIM	Displays disclaimer and determines if you
	;			want to continue.
	;
	;	. DOCPRINT	Print documentation from utility routine
	;
	Q		; Never called from the top
	;
	;----------------------------------------------------------------------
DISCLAIM()	;Private; Display disclaimer, see if want to continue
	;----------------------------------------------------------------------
	; RETURNS:
	;	. $$	Continuation flag	/TYP=L
	;		0 = Don't continue
	;		1 = Continue
	;
	N I,X
	W $$CLEAR^%TRMVT
	D NOTICE
	F I=0:1 S X=$P($T(DISTEXT+I),";",2) Q:X="$$EOF"  W $$CJ^%ZTEXT(X,80),!
	D NOTICE
	R !!,"Continue?  N=> ",X
	S X=$TR(X,"yes","YES")
	I '(X="Y"!(X="YES")) Q 0			; Return don't continue
	Q 1						; Return continue
	;
NOTICE	;
	W $$VIDBLK^%TRMVT
	W !,$$CJ^%ZTEXT("* * * * *  N O T I C E  * * * * *",80)
	W $$VIDOFF^%TRMVT
	Q
	;
DISTEXT	;
	;This routine is part of a toolbox of utilities designed for testing
	;or other internal use by Sanchez, or by a customers under the
	;direction of Sanchez.
	;
	;It is not intended for use in a production environment.
	;
	;No support for this utility is provided to customers.
	;$$EOF
	;
	;----------------------------------------------------------------------
DOCPRINT(source,hdr)	;Private; Display documentation
	;----------------------------------------------------------------------
	; Common method to display documentation for a TBX utility
	;
	; The source routine must have documentation in commented lines
	; starting at source+1, i.e., the first line after the line
	; specificed in soure.  Lines should be of the form ' ; text ...'
	; where text begins after a semi-colon and a space.
	;
	; The documentation section must end with ' ; $$EOF', although
	; the output will stop on the first null line encounter as a safety
	; precaution to prevent an infinite loop.
	;
	; INPUT:
	;	. source	tag^rtn where doc	/TYP=T/REQ/MECH=VAL
	;			text begins.
	;
	;	. hdr		Header for UTLREAD	/TYP=T/NOREQ/MECH=VAL
	;			Displays purpose of documentation,
	;			e.g., "Display TBXCDCV utility documentation"
	;
	N (ER,hdr,RM,source,VFMQ)
	S %TAB("IO")=$$IO^SCATAB($I)
	I $g(hdr)="" S hdr="Display utility documentation"
	S %READ="@hdr/CEN,,IO/REQ"
	S %FRAME=1,%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q"
	I IO=$I W $$CLEAR^%TRMVT
	I IO'=$I D OPEN^SCAIO I ER W:$D(RM) !!,RM Q
	S tag=$P(source,"^",1),rtn="^"_$P(source,"^",2)
	S done=0
	U IO
	F I=1:1 D  Q:done
	.	S X="S LINE=$T("_tag_"+I"_rtn_")"
	.	X X
	.	I LINE="" S done=1 Q
	.	S TEXT=$P(LINE,"; ",2,999)
	.	I TEXT="$$EOF" S done=1 Q
	.	W TEXT,!
	D CLOSE^SCAIO
	Q
