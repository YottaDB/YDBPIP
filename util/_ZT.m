%ZT	;Library;Error trap utilities
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/06/00 05:17:09 - MATTSON
	; ORIG:  Dan S. Russell (2417) - 09 Nov 88
	;
	; GT.M Error Trap Handling.
	;
	; Provides various extrinsic functions necessary to know how to handle 
	; error trap setting.
	;
	; KEYWORDS:	Error handling
	;
	; LIBRARY:
	;	. $$NEW		- Returns flag to know if should NEW $ZT 
	;			  prior to setting $ZT, GT.M returns 1,
	;			  M/VX returns 0 (should not be used in
	;			  V6.3 and above).
	;
	;	. $$SET		- Returns indirection string to allow proper
	;			  GT.M setting of error trap (should not be
	;			  used in V6.3 and above).
	;
	;	. $$SETZT	- Returns variable to allow proper GT.M 
	;			  setting of error trap (replaces $$SET
	;			  in V6.3 and above).
	;
	;	. $$COMP	- Returns compilable error trapping code
	;
	;	. ET		- Provides standardized error message handling
	;
	;	. $$ETLOC	- Returns error type and location only
	;
	;---- Revision History -------------------------------------------------
	; 01/05/00 - Allan Mattson - 36312
	;            Added comments to function $$NEW^%ZT to advise against
	;            the use of this subroutine in V6.3 and above.
	;
	;            Added extrinsic function $$SETZT to eliminate the need to
	;            use indirection when setting an error trap.  Refer to the
	;            documentation within the function for additional details.
	;
	; 09/15/98 - Allan Mattson - 25662
	;            Modified to execute %ZTRAP (if it is not null) to support
	;            recovery project.  This variable is used to return
	;            program control back to the P/A server if an error
	;            is encountered (including a transaction timeout).
	;
	; 06/29/94 - Dan Russell
	;            Fixed return value in COMP section to pass $ZL back
	;            correctly.
	;
	; 03/11/94 - Allan Mattson
	;            Added standardized error type FILE_FULL.
	;
	; 10/12/92 - Dan Russell
	;            Added null return for ETLOC in the case that both
	;            SETYP and ELOC were null.
	;-----------------------------------------------------------------------
	;
	;----------------------------------------------------------------------
NEW()	;Public;Indicate if $ZT should be NEW'd
	;----------------------------------------------------------------------
	;
	;*** IMPORTANT NOTE ***************************************************
	; This subroutine should no longer be called in P/A V6.3 and above.
	; The application programs should automatically N[ew] $ZT, if
	; appropriate (i.e. it is no longer necessary to rely on the
	; value returned from $$NEW^%ZT).
	;**********************************************************************
	;
	; Returns logical value to indicate if error trap variable should be 
	; NEW'd before setting new value.  GT.M requires $ZT to be NEW'd in
	; order to save old value on stack.  M/VX does not.
	;
	; KEYWORDS:	Error handling
	;
	; RETURNS:
	;	. $$		OK to new indicator	/TYP=L
	;			Returns 1 since GT.M
	;
	; EXAMPLE:
	;	I $$NEW^%ZT N $ZT
	;
	Q 1
	;
	;----------------------------------------------------------------------
SET(TAG)	;Public;Return SETable error trap string
	;----------------------------------------------------------------------
	;
	;*** IMPORTANT NOTE ***************************************************
	; This subroutine should no longer be called in P/A V6.3 and above.
	; Instead, the application programs should call extrinsic function
	; $$SETZT^%ZT in order to avoid the need to use indirection and to
	; improve performance.
	;**********************************************************************
	;
	; Returns setable string to set GT.M error trap.  If TAG does not 
	; contain a routine name, $T(+0) will be used to use the calling 
	; routine.
	;
	; If TAG="", error trap will be set to a null, which indicates that
	; on an error the image will terminate.
	;
	; If TAG?1"*B".e, error trap will be set to break.
	;
	; If %ZTRAP'="", error trap will be set to %ZTRAP.
	;
	; If TAG=ZE^UTLERR, set up to go to trap before popping stack
	;
	; KEYWORDS:	Error handling
	;
	; RETURNS:
	;	. $$		Error trap string	/TYP=T
	;
	; EXAMPLE:
	;	S @$$SET^%ZT("ZE^UTLERR")
	;----------------------------------------------------------------------
	;
	N X
	;
	I TAG="" S X="$ZT="""""
	E  I TAG?1"*B".E S X="$ZT=""B"""
	E  I $G(%ZTRAP)'="" S X="$ZT=""S %ZTRAP="""""""" "_%ZTRAP_""""
	E  I TAG="ZE^UTLERR" S X="$ZT=""D ZE^UTLERR ZG "_($ZL-1)_""""
	E  S X="$ZT=""ZG "_($ZL-1)_":"_TAG_""""_$S(TAG["^":"",1:"_""^""_$T(+0)")
	Q X
	;
	;----------------------------------------------------------------------
SETZT(TAG)	;Public;Return error trap string
	;----------------------------------------------------------------------
	;
	; Returns a string to set a GT.M error trap.  Unlike SET^%ZT, this
	; function REQUIRES a routine name (i.e., $T(+0) will not be used).
	;
	; If TAG="", error trap will be set to a null, which indicates that
	; on an error the image will terminate.
	;
	; If TAG?1"*B".e, error trap will be set to break.
	;
	; If %ZTRAP'="", error trap will be set to %ZTRAP.
	;
	; If TAG=ZE^UTLERR, set up to go to trap before popping stack
	;
	; KEYWORDS:	Error handling
	;
	; RETURNS:
	;	. $$		Error trap string	/TYP=T
	;
	; EXAMPLE:
	;	S $ZT=$$SETZT^%ZT("ZE^UTLERR")
	;----------------------------------------------------------------------
	;
	I TAG="" Q ""
	I TAG?1"*B".E Q "B"
	I $G(%ZTRAP)'="" Q "S %ZTRAP="""" "_%ZTRAP
	I TAG="ZE^UTLERR" Q "D ZE^UTLERR ZG "_($ZL-1)
	;
	Q "ZG "_($ZL-1)_":"_TAG
	;
	;----------------------------------------------------------------------
COMP(VARIABLE,NONEW)	;Public;Return compilable error trap code for GT.M
	;----------------------------------------------------------------------
	;
	; Return compilable error trap code for GT.M.  Allows code to be
	; built into routines that are compiled by application.
	;
	; KEYWORDS:	Error handling
	;
	; ARGUMENTS:
	;	. VARIABLE	tag^rtn for trap	/TYP=T
	;			If only tag specified, i.e.,
	;			no "^", $T(+0) used to get routine
	;			name at run time
	;
	;	. NONEW		Don't NEW $ZT		/TYP=L
	;			If on, string returned does
	;			not NEW $ZT
	;
	; EXAMPLE:
	;	S X=$$COMP^%ZT("TAG^RTN",0)
	;	   => X="N $ZT S $ZT=""ZG $ZL:TAG^RTN"""
	;----------------------------------------------------------------------
	;
	N X
	S X=$S($G(NONEW):"",1:"N $ZT ")
	I VARIABLE'["^" S VARIABLE=VARIABLE_"^""_$T(+0)"
	;
	I $G(%ZTRAP)="" S X=X_"S $ZT=""ZG ""_$ZL_"":"_VARIABLE_""""
	E  S X=X_"S $ZT=""S %ZTRAP="""""""" "_%ZTRAP_""""
	Q X
	;
	;----------------------------------------------------------------------
ET(setyp,err,etyp,eloc,emsg,errno)	;Public;Return select error variables
	;----------------------------------------------------------------------
	;
	; Returns requested variables associated with an error.  Translates
	; to common meanings to allow implementation across varied M systems.
	;
	; NOTE:  do not use the following variable names in your parameter
	;        list - setyp,err,etyp,eloc,emsg,errno,x
	;
	; KEYWORDS:	Error handling
	;
	; ARGUMENTS:
	;	. setyp		Standardized error 	/TYP=T/MECH=REFNAM:W
	;			SCA standardized error
	;			type for common errors.  
	;			E.g., undefined is always 
	;			UNDEF, syntax is SYNTAX.
	;			If not converted by this 
	;			utility to a standard, setyp 
	;			will be the same as etyp.
	;
	;	. err		Contents of $ZS		/TYP=T/MECH=REFNAM:W
	;
	;	. etyp		GT.M error type		/TYP=T/MECH=REFNAM:W
	;			Implementation (GT.M)
	;			specific, e.g. %GTM-E-UNDEF
	;
	;	. eloc		Location of error	/TYP=T/MECH=REFNAM:W
	;			tag^rtn of error
	;
	;	. emsg		Literal error msg	/TYP=T/MECH=REFNAM:W
	;			as reported in $ZS
	;
	;	. errno		GT.M error number	/TYP=N/MECH=REFNAM:W
	;			as reported in $ZS
	;
	; EXAMPLE:
	;	D $$ET^%ZT(.SCAET,.ERR,.ET,.LOC,.MSG,.NO)
	;
	N x
	s err=$ZS
	S errno=$P($ZS,",",1)
	S eloc=$P($ZS,",",2)
	S etyp=$P($ZS,",",3),setyp=etyp
	S emsg=$P($ZS,",",4)
	;
SETYP	; Set standardized errors
	S x=etyp
	I errno S x=$P(etyp,"-",3)
	E  I etyp["." S x=$P(etyp,".",$L(etyp,"."))
	S etyp=x
	;
	I "/CTRAP/CTRLY/CTRLC"[("/"_x_"/") S setyp="INTERRUPT" Q
	I "/DBRDERR/DBNOTGDS/DBOPNERR/DBNOFILEOPN/DBFILERR/"[("/"_x_"/") S setyp="FILE_PROTECTION" Q
	I x="FLTDIV_F" S setyp="DIVIDE_BY_ZERO" Q
	I x="IOEOF" S setyp="END_OF_FILE" Q
	I x="LABELMISSING" S setyp="NOLINE" Q
	I x="MAXSTRLEN" S setyp="MAXSTRING" Q
	I x="NUMOFLOW" S setyp="MAXNUMBER" Q
	I x="GBLOFLOW" S setyp="FILE_FULL" Q
	I "/ROUTINEUNKNOWN/ROUTINEMISSING/"[("/"_x_"/") S setyp="NOROUTINE" Q
	I x="UNDEF" S setyp="UNDEFINED" Q
	I x?1"NET".E S setyp="NETWORK_ERROR" Q
	Q
	;
	;----------------------------------------------------------------------
ETLOC()	;Public;Return standard error type and location of error
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Error handling
	;
	; RETURNS:
	;	. $$		"error_type,tag^rtn"	/TYP=T
	;
	; EXAMPLE:
	;	S X=$$ETLOC^%ZT =>  X="UNDEFINED,A+1^ABC"
	;
	N SETYP,ERR,ETYP,ELOC,EMSG,ERRNO
	D ET(.SETYP,.ERR,.ETYP,.ELOC,.EMSG,.ERRNO)
	I SETYP="",ELOC="" Q ""
	Q SETYP_","_ELOC_","_ERRNO_","_EMSG_","_ETYP
