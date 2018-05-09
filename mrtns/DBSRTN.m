DBSRTN(RTN,ARRAY,START,LTAGS,NOKILL) ;
	;;Copyright(c)1993 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/17/93 09:49:17 - CHIANG
	;     ORIG:  Bob Chiang
	;     DESC:  Utility to build DQ compiler template programs.  This
	;            is a modified version of the original routine %ZRTNLOD.
	;	     The source code will be stored in a entry in the global
	;            ^DBCTL("SYS",TYPE,SEQ)=MUMPS CODE
	;
	;                         TYPE: SCREEN    Base screen routine
	;                               SCRLNK    Base linked screen routine
	;                               REPORT    Base report routine
	;                               RWSORT    Base report sort routine
	;
	;            With this changes, the DQ software can be released in
	;            object code version.
	;
	; PARAMETERS:
	;
	;    RTN   = Routine name			/TYP=T/REQ/MECH=VAL
	;    ARRAY = Array/global reference		/TYP=T/REQ/MECH=VAL
	;                    
	;    START = Starting subscript for load to ARRAY
	;                    
	;    LTAGS = Line tag cross reference array	/TYP=T/REQ/MECH=REF
	;    NOKILL = Do not delete existing array
	;
	;           *** Do not use %I or %L for values for ARRAY ***
	;
	;----------------------------------------------------------------------
	;
	N %I,%START,%TAG,%L,STOP,FILE,%z
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
	S %I=0,STOP=0,%z=""
	F  S %z=$O(^DBCTL("SYS",RTN,%z)) Q:%z=""  S %L=^(%z) D LINE Q:STOP
	Q
	;
LINE	S %I=%I+1
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
