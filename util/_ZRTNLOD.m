%ZRTNLOD(RTN,ARRAY,START,LTAGS,NOKILL)	;Public; Load routine into an array
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 15:43:31 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 09/16/88
	;
	; GT.M utility to load routine text into an array.
	;
	; Uses reads from RMS file instead of $T command to avoid auto-linking 
	; of routines being loaded.  Because of that, must translate first TAB 
	; to a space.
	;
	;
	; NOTE:  Within the routine being loaded, line tag %STOPLOD
	;        is used to signal the end of the loading section.
	;        Any line from %STOPLOD and below will not be loaded.
	;
	;        For GT.M purposes, lines which are called by the
	;        routine but which are not in the routine should be
	;        added below %STOPLOD.  This will prevent the
	;        compiler from reporting misleading errors.
	;
	; KEYWORDS:	Routine handling, Compiling
	;
	; ARGUMENTS:
	;	. RTN    - Routine name to load
	;					/TYP=T/REQ/LEN=8/MECH=VAL
	;
	;	. ARRAY  - Local array name to be used for storing code
	;		   for compiled routine.
	;                  If not defined or null, will use ^TMP($J
	;                  *** Do not use %I or %L for values for ARRAY ***
	;					/TYP=T/MECH=VAL
	;
	;	. START  - Starting subscript for load to ARRAY
	;                  Adds to end if null or not defined
	;					/TYP=T/MECH=VAL
	;
	;	. LTAGS  - Line tag cross reference array
	;					/TYP=T/MECH=VAL
	;
	;	. NOKILL - Do not delete existing array
	;					/TYP=L/MECH=VAL
	;
	; EXAMPLE:
	;	D ^%ZRTNLOD(RTN,ARRAY,START,.LTAGS,NOKILL)
	;
	;
	;---- Revision History ------------------------------------------------
	; 06/17/93 - Dan Russell
	;            Modified U FILE:EXC="" to do only once per file.  Caused
	;            problems if in FOR loop due to GT.M not releasing
	;            memory properly.
	;
	;----------------------------------------------------------------------
	N %I,%START,%TAG,%L,STOP,%ZI,%ZR,FILE,VMS
	;
	; Is OS VMS ?
	S VMS=$$^%ZSYS
	;
	I $G(ARRAY)="" S ARRAY="^TMP($J"
	;
	I $E(ARRAY,$L(ARRAY))=")" S ARRAY=$E(ARRAY,1,$L(ARRAY)-1)
	I $E(ARRAY,$L(ARRAY))="," S ARRAY=$E(ARRAY,1,$L(ARRAY)-1)
	I ARRAY'["(" S ARRAY=ARRAY_"("
	;
	I '$G(NOKILL) D KILL
	;
	I $P(ARRAY,"(",2)="" S %START=ARRAY_""""")",ARRAY=ARRAY_"%I+START-1)"
	E  S %START=ARRAY_","""")",ARRAY=ARRAY_",%I+START-1)"
	;
	I $G(START)="" S START=$ZP(@%START)+1
	;
	S %ZI(RTN)="" D INT^%RSEL Q:'$D(%ZR(RTN))
	I VMS S FILE=%ZR(RTN)_$TR(RTN,"%","_")_".M"
	E  S FILE=%ZR(RTN)_$TR(RTN,"%","_")_".m"
	O FILE:READ
	S %I=0,STOP=0
	U FILE:EXC=""
	F  U FILE R %L Q:$ZEOF  D LINE Q:STOP
	C FILE
	Q
	;
LINE	S %I=%I+1
	I %L'="" S %L=$P(%L,$C(9),1)_" "_$P(%L,$C(9),2,999)
	S %TAG=$P(%L," ",1)
	I %TAG="%STOPLOD" S STOP=1 Q
	S @ARRAY=%L
	I %TAG'="" S LTAGS($P(%TAG,"(",1))=%I+START-1
	Q
	;
KILL	; Delete existing array
	N DEL
	I $P(ARRAY,"(",2)="" S DEL=$P(ARRAY,"(",1)
	E  S DEL=ARRAY_")"
	K @DEL
	Q
