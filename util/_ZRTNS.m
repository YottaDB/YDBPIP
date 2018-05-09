%ZRTNS	;Library;  General routine information utility
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/18/99 10:59:50 - CHENARD
	;     ORIG:  Dan S. Russell (2417) - 11/14/88
	;
	; Various Routine related utilities.
	; See each section for details.
	;
	;
	; KEYWORDS:	Routine handling
	;
	; LIBRARY:
	;	. %ZRTNS  - Called from the top, this utility will return
	;	            all routines currently linked into the user's
	;	            image.
	;
	;	. IMAGE   - Returns an array listing of routines currently
	;	            linked into the user's image.
	;
	;	. $$NEXT  - Returns the next found routine in the search
	;	            list.
	;
	;	. $$VALID - Returns a flag, 1 or 0, identifying whether the
	;	            passed routine is valid or not.
	;
	;	. RELINK  - Relinks all routines that are currently contained
	;	            in the user's image.
	;
	;-----Revision History-------------------------------------------------
	;
	; 11/18/99 - Phil Chenard - 35745
	;            Modified $$VALID function to first parse the variable
	;            RTN and remove tag and "^" if present. This is necessary
	;            based on last revision made.  Some tables and/or routines
	;            calling $$VALID may still allow for a tag and/or "^" in the
	;            name of the routine.
	;
	; 10/09/98 - Phil Chenard
	;            Modified function $$VALID to check for both source
	;            and object modules to determine if a routine is valid.
	;            This addresses situations where source code is removed
	;            after being compiled for security reasons.
	;
	;----------------------------------------------------------------------
	;
	; This utility lists every routine found in the image to the current 
	; device.  It is used to simply display this information to the screen.
	;
	; RETURNS:
	;	. RTN	- This call will output all routines found in the
	;		  image to the current device.
	; 
	; EXAMPLE:	
	; D ^%ZRTNS 	; prints list of routines in the image
	;
	;----------------------------------------------------------------------
	N LIST,RTN
	D IMAGE(.LIST)
	W !,"Routines currently in image:",!!
	S RTN=""
	F  S RTN=$O(LIST(RTN)) Q:RTN=""  W RTN,!
	Q
	;
	;----------------------------------------------------------------------
IMAGE(RTNLIST)	;System;Return list of routines in image in RTNLIST
	;----------------------------------------------------------------------
	; Will return an array containing all routines found in the current
	; image.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTNLIST - Array name to be used to list all routines
	;                   currently linked in the image.
	;					/TYP=T/REQ/MECH=REFNAM
	;
	; RETURNS:
	;	. RTNLIST - Output array of all routines found in the image.
	;					/TYP=T/MECH=ARRAY	
	;
	; EXAMPLES:
	; 	D IMAGE^%ZRTNS(.LIST)
	;
	;----------------------------------------------------------------------
	N RTN
	S RTN=""
	F  S RTN=$V("RTNNEXT",RTN) Q:RTN=""  S RTNLIST(RTN)=""
	Q
	;
	;----------------------------------------------------------------------
NEXT(RTN)	;System;Extrinsic function to return next routine 
	;----------------------------------------------------------------------
	;
	; Based on the routine name passed to this function, the next routine
	; found in the search list will be returned.
	;
	; NOTE:  Quick and dirty ... improve in the future
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTN	- Routine name, used as reference to find the next
	;		  routine in the search list.
	;					/TYP=T/REQ/LEN=8/MECH=VAL
	;
	; RETURNS:
	;	. $$    - Routine name found in the search list following the
	;		  passed routine.
	;					/TYP=T
	;
	; EXAMPLE:	
	;	S X=$$NEXT^%ZRTNS(RTN) 	;return X as routine following RTN
	;
	;----------------------------------------------------------------------
	N (FLTR,LTR,FIRSTNXT,%ZI,%ZR,NXT,RTN,RTNDIR)
	S FLTR=$E($$UPPER^%ZFUNC(RTN)),LTR=FLTR ; Get first letter
	F  Q:LTR="Z"  S LTR=$S(LTR="%":"A",1:$C($A(LTR)+1)) D NEXT1 Q:%ZR
	S FIRSTNXT=$O(%ZR("")) ; Get first possible routine for next letter
	K %ZI,%ZR
	S %ZI(FLTR_"*")="" D INT^%RSEL
	S NXT=$O(%ZR(RTN))
	I NXT="" S NXT=FIRSTNXT
	Q NXT
	;
	;----------------------------------------------------------------------
NEXT1	; Get list of next routines possible routines, based on LTR
	;----------------------------------------------------------------------
	K %ZI,%ZR
	S %ZI(LTR_"*")="" D INT^%RSEL
	Q
	;
	;----------------------------------------------------------------------
VALID(RTN)	;Public; Extrinsic function to validate a routine.
	;----------------------------------------------------------------------
	;
	; This function will validate the existence of a routine, determined
	; by whether or not it is found in the current routine search list.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTN	- Routine name to be validated.
	;					/TYP=T/REQ/LEN=8/MECH=VAL
	;
	; RETURNS:
	;	. $$	- If routine is valid, returns 1, else 0
	;					/TYP=L
	;
	; EXAMPLE:
	;	S X=$$VALID^%ZRTNS(RTN)
	; 
	;----------------------------------------------------------------------
	I $G(RTN)="" Q 0
	N %ZI,%ZR,%ZRO
	I RTN["^" S RTN=$P(RTN,"^",2)	;Strip off leading tag and "^"
	S %ZI(RTN)=""
	D BOTH^%RSEL			;Check for both source & object
	I $D(%ZR(RTN))!$D(%ZRO(RTN)) Q 1
	Q 0
	;
	;----------------------------------------------------------------------
DQ(RTN)	;Public;Extrinsic function to validate a routine
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTN		Routine name		/TYP=T/REQ/MECH=VAL
	;					
	; RETURNS:
	;	. $$		Error indicator		/TYP=L
	;			1 => routine does not exist
	;			0 => routine exists
	;
	;	. RM		Error message		/TYP=T/COND
	;			Only returned if $$=1
	;
	; EXAMPLE:	
	;	S ER=$$DQ^%ZRTNS(^RTN)
	;
	S RTN=$P($G(RTN),"^",2) I RTN="" S RM="Invalid routine" Q 1
	N %ZI,%ZR S %ZI(RTN)="" D INT^%RSEL I $D(%ZR) Q 0
	S RM="Invalid routine"
	Q 1
	;
	;----------------------------------------------------------------------
RELINK(IGNPCNT)	;Public;Relink all routines in current image
	;----------------------------------------------------------------------
	;
	; This utility will re-link all routines currently found in the image
	;
	; KEYWORDS:	Routine handling, Compiling
	;
	; ARGUMENTS:
	;	. IGNPCNT - Flag defining whether or not to ignore percent
	;		    routines when re-linking.
	;					/TYP=L/REQ/MECH=VAL
	;
	; EXAMPLE:
	;	D RELINK^%ZRTNS(1)
	;
	;----------------------------------------------------------------------
	N RTN,RTNS
	S RTN=""
	N $ZT
	S $ZT="G RELINKLP^%ZRTNS"
	D IMAGE(.RTNS)
RELINKLP	;
	S RTN=$O(RTNS(RTN)) Q:RTN=""
	I $G(IGNPCNT),$E(RTN)="%" G RELINKLP
	ZL $TR(RTN,"%","_")
	G RELINKLP
