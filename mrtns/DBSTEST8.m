	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 15:00:48 - NIB
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/21/94 13:57:02 - XUS
	; ORIG:	XUS - 02/28/94
	;
	;   PURPOSE:
	;          This routine is used to test the lookup table display 
	;          format section in file definitions,,also it can be used
	;          to test the routine "DBSTBL" and "DBSTBLA". It cwill be
	;          invoked by running function "DBSTEST" or itself. 
	;  
	;      DESC: DEMO/QA Testing program for lookup table format section
	;
	;---- Revision History ------------------------------------------------
	;
	; 08/12/97 - Betty Ndi - 25653
	;            Replace follows operator "]" with a "]]". 
	;
	; 11/21/94 - Shaodong Xu - ARQ 10195
	;            Modified RM undefined.
	; 11/10/94 - Janet An - 18
	; 	     Put I18N=QUIT on the top of routine.
	;
	; 10/27/94 - Bob Chiang - ARQ 18
	;            Removed calls to $$^MSG.
	;
	; 10/13/94 - Ying A.C. Liu - I18N
	;            Removed duplicate messages.
	;
	; 08/23/94 - Shaodong Tony Xu - ARQ 14621
	;            Modified the variables %READ and %TAB.
	;
	; 07/20/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from DQnnnn to nnnn.
	;
	;--------------------------------------------------------------------
	;
BEG	;
	;--------------------------------------------------------------------
	;  Initialize the variables
	;--------------------------------------------------------------------  
	;
	; I18N=QUIT
	;
	N FIDS,FIDE,CFID,VAR,X,MSG,TMPVAR,%TABS,%READ,ER,RM,DLINE,VAR1 ; the temporary variables
	I '$D(%LIBS) N %LIBS S %LIBS=^CUVAR("%LIBS")       
	I '$D(%UID) N %UID S %UID=$P($$LOGID^SCADRV,"|",2)
	I '$D(%FN) N %FN S %FN="DBSTEST8"
	I '$D(%) N % S %="|"                          ; standard delimiter
	S ER=0,RM=" "                                 ; reset the error signal
	S FIDS=$O(^DBTBL(%LIBS,1,""))                 ; Set default value for FIDS
	S FIDE=$ZP(^DBTBL(%LIBS,1,"Z"))               ; Set default value for FIDE
	;--------------------------------------------------------------------
	;  Create a screen for inputing starting file and ending file
	;--------------------------------------------------------------------
	;
	S %TAB("FIDS")=".FIDS"                     ; prompt "Starting File Name" for FIDS field 
	S %TAB("FIDE")=".FIDE"                     ; prompt "ending File Name" for FIDE field    
	S OLNTB=40
	S %READ="@@%FN,,FIDS/REQ,FIDE/REQ,"                ; Display Heading and Input
	D ^UTLREAD
	I VFMQ="Q" Q
	; 
	S CFID=FIDS,X=1,ER=0,MSG=" "               ; Initialize temporary variables
	;
	;----------------------------------------------------------------------- 
	;  Withdraw all the lookup table formats from the files between
	;  the starting file and ending file
	;-----------------------------------------------------------------------
	;
	F  D  Q:(CFID]]FIDE)!('$D(CFID))!(X=0)                   ; stop this loop until one condition happens  
	.	S FIDD="["_CFID_"]"                             ; get correct argument format 
	.	I $D(^DBTBL(%LIBS,1,CFID,10)) D MAIN            ; skip the file definition  which has no look_up format
	.	S CFID=$O(^DBTBL(%LIBS,1,CFID))                 ; get next file definition
	Q
	;
	;---------------------------------------------------------------------------------
MAIN	;   When there is lookup table syntax in the file definition, we will retrieve 
	;   it and display it
	;--------------------------------------------------------------------------------
	;
	N %READ,%NOPRMT
	S %NOPRMT="F"
	I ($P(^DBTBL(%LIBS,1,CFID,10),"|",6)'="")!($P(^DBTBL(%LIBS,1,CFID,10),"|",9)'="") D
	.	W $$CLEAR^%TRMVT                             ; put the cursor on the first line
	.	; File Name
	.	S MSG(1)="File Name "_CFID
	.	S %READ="@@%FN,,@MSG(1)"                     ; print the file name       
	.	; Syntax: 
	.	S MSG(2)="Syntax:"
	.	S %READ=%READ_",@MSG(2),"
	.	S VAR=" "_$P(^DBTBL(%LIBS,1,CFID,10),"|",6)  ; print the first line of 
	.	I $L(VAR)<78 S %READ=%READ_"@VAR,"
	.	E  S VAR(1)=$E(VAR,1,78),VAR(2)=$E(VAR,79,199),%READ=%READ_"@VAR(1),@VAR(2),"
	.	S VAR1=" "_$P(^DBTBL(%LIBS,1,CFID,10),"|",9) ; print the second line of
	.	I $L(VAR1)<78 S %READ=%READ_"@VAR1,"
	.	E  S VAR1(1)=$E(VAR1,1,78),VAR1(2)=$E(VAR1,79,199),%READ=%READ_"@VAR1(1),@VAR1(2),"
	.	S MKEY=^DBTBL(%LIBS,1,CFID,16)               ; get the primary key(s)
	.	S MSG(3)=""
	.	; Initial Value(s): 
	.	I MKEY["," S MSG(3)="Initial Value(s):" D INITVAR    ; if the file has multiple keys
	.	I CFID="CIF1" S MSG(3)="Initial Value(s):"	     ; for special case
	.	S %READ=%READ_"@MSG(3)"                      ; print the intial value
	.	D ^UTLREAD
	.	I VFMQ="Q" Q
	.	S TMPVAR=$$^DBSTBL(FIDD)                     ; display the look_up table
	.	I ER W $$MSG^%TRMVT($G(RM),0,1)                  ;  *** XUS 11/19/94display any error
	.	S ER=0,RM=""                                 ; reset error indication
	.	;
	.	S X=$$YN^DBSMBAR("","Continue?",1)         ; set options for users
	Q
	;
	;------------------------------------------------------------------------
INITVAR	; 
	;   Set the values to the local variables to support the case with
	;   multiple primary keys in file definition
	;----------------------------------------------------------------------- 
	; 
	N INDEXTMP,SYNKEY,NGLOBAL,II
	S NGLOBAL="^"_^DBTBL(%LIBS,1,CFID,0)         ; get the global variable name
	;
	F II=1:1:$L(MKEY,",")-1 D                    ; initialize all local  
	.	S CKEY=$P(MKEY,",",II)               ; variables for lookup
	.	I CKEY?1A1A.E S @CKEY=" "            ; table queries
	;
	F II=1:1:$L(MKEY,",")-1 D                    ; Check each key 
	.	I II>5 Q                             ; maximum number of keys is 6
	.	S CKEY=$P(MKEY,",",II)               ; retrieve a single key
	.	S INDEXTMP(II)=""                    ; initialization
	.	I CKEY?1A1A.E D ALPHKEY              ; key is beginning with an alphabetics
	.	I CKEY'?1A1A.E D OTHERKEY            ; other keys
	K INDEXTMP,NGLOBAL,SYNKEY                    ; clean up   
	Q
	;
	;-----------------------------------------------------------------------  
ALPHKEY	;   The key is alphabetics
	;-----------------------------------------------------------------------
	; get the value for current primary key
	;
	I II=1 S SYNKEY(1)=NGLOBAL_"(INDEXTMP(1))"
	I II=2 S SYNKEY(2)=NGLOBAL_"(INDEXTMP(1),INDEXTMP(2))"
	I II=3 S SYNKEY(3)=NGLOBAL_"(INDEXTMP(1),INDEXTMP(2),INDEXTMP(3))"
	I II=4 S SYNKEY(4)=NGLOBAL_"(INDEXTMP(1),INDEXTMP(2),INDEXTMP(3),INDEXTMP(4))"
	I II=5 S SYNKEY(5)=NGLOBAL_"(INDEXTMP(1),INDEXTMP(2),INDEXTMP(3),INDEXTMP(4),INDEXTMP(5))"
	S INDEXTMP(II)=$S(II=1:$O(@SYNKEY(1)),II=2:$O(@SYNKEY(2)),II=3:$O(@SYNKEY(3)),II=4:$O(@SYNKEY(4)),II=5:$O(@SYNKEY(5)))      
	I (II=2)&(CFID["LNOLC") S INDEXTMP(II)=$O(@SYNKEY(2))  ; for special files
	I INDEXTMP(II)="" S II=$L(MKEY) Q                      ; quit when no entry
	S @CKEY=INDEXTMP(II) S MSG(3)=MSG(3)_CKEY_"="_INDEXTMP(II)_"     "
	Q
	;
	;----------------------------------------------------------------------
OTHERKEY;	Deal with keys which is number,constant or system variable  
	;----------------------------------------------------------------------
	;
	I (CKEY?1N.N) S INDEXTMP(II)=CKEY Q              ; the key is a number
	E  D 
	.	I CKEY?1"%"1A.E S INDEXTMP(II)=@CKEY     ; the key is system variable
	.	E  S INDEXTMP(II)=$E(CKEY,2,$L(CKEY)-1)  ; the key is a constant
	Q 
	;
