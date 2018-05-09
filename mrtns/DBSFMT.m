DBSFMT	;;DBS - UTL - V4.4 - DQ DATA TYPE DEFINITION
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/27/00 14:20:09 - SPIER
	;     ORIG:  CHIANG - 14 JAN 1992
	;     DESC:  DQ DATA TYPE DEFINITION
	;
	;---------- Revision History -------------------------------------------
	;
	; 11/27/00 - SPIER - 41078
	;            Reset Value of %REPEAT to reflect number of entries
	;	     in ZTYPE array. This cures and error where not all
	;	     entries were being displayed for change. A change was
	;	     also made to the screen dbsfmt to allow more entries.
	;
	; 16/07/98 - Betty Ni - 29370
	;	     The routine ^DBSINIT1 was obsoleted from V6.1DEVM, removed 
	;	     code to call ^DBSINIT1.
	;	     
	; 07/01/96 - SPIER - 22281
	;            Correct undef at UPDATE+13 
	;
	; 06/28/96 - SPIER - 22281
	;            Added definition of DESC in order to display on screen
	;	     and then file the description.
	;	     Due to changes in dbsinit1, we ar enow able to call
	;	     DBSINIT1 if the mask being changed is the one currently
	;	     in use for the system. This means the user will not have
	;	     to run DBSINIT and change the country back and forth in
	;	     order for the change to take place. 
	;
	; 08/02/94 - N.Gorman
	;            Commented out call to ^DBSINIT after database updated with
	;	     changes entered by this function. System was overlaying 
	;	     data entered by user of this function with default values
	;	     from DBSINIT.
	;
	; 05/16/94 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	; 10/15/93  Frank Prendergast - I18N#18
	;
	; 	    Change call to DBSMBAR from DBSMENU
	;	    Moved text to ^STBL("MBAR",19)
	;
	; 07/13/93  Bob Chiang
	;
	;           Modified to add a standard screen to UTLREAD screen.
	;
	; 03/29/93  Bob Chiang 
	;
	;           Modified to add default field size to each data type.
	;
	; 12/18/92  Bob Chiang - I18N#?
	;
	;           Modified to access screens DBSFMTDAY and DBSFMTMON to
	;           define alphabetic display of days and months.
	;-----------------------------------------------------------------------
	;
	N PT,OP,OPTION,MSKOPT,TYPE,ZHDR,DFT,SAVEDESC,SCREEN,REPORT,DATFMT,DESC
	K %TAB,OLNTB,%REPEAT
	S MSKOPT=$G(^DBCTL("SYS","DVFM"))
	I MSKOPT="" S MSKOPT="US"
	;
	S SCREEN=1,REPORT=1,DATFMT=1
	S %TAB("MSKOPT")=".MSKOPT1/XPR=D PRE^DBSFMT"
	S %TAB("SCREEN")=".SCREEN2"
	S %TAB("REPORT")=".REPORT2"
	S %TAB("DATFMT")=".DQDTFMT1"
	S OLNTB=40
	;
	S %READ="@@%FN,,MSKOPT/REQ,SCREEN/,REPORT,DATFMT,",%NOPRMT="F"
	S %FRAME=2 D ^UTLREAD I VFMQ="Q" Q
	;
	S DFT=MSKOPT
	I '$D(^DBCTL("SYS","*RFMT",MSKOPT)) DO
	.	;
	.	N MASK,VAR
	.	F I=1:1:50 S (MASK(I),VAR(I))=""
	.	S X="" F I=1:1 S X=$O(^DBCTL("SYS","*RFMT",X)) Q:X=""  S VAR(I)=X K MASK(I)
	.	S DFT=$$^DBSMBAR(19,"",.MASK,"",.VAR)
	.	I 'DFT S DFT="US"
	.	E  S DFT=VAR(DFT)
	;
	I SCREEN S OPTION="Screen",TYPE="DVFM" D UPDATE
	I REPORT S OPTION="Report",TYPE="RFMT" D UPDATE
	I DATFMT S TYPE="DVFM" D FMTD
	;I MSKOPT=$G(^DBCTL("SYS","DVFM")) D ^DBSINIT1
	;
	; *** BC - 08/02/94
	Q
UPDATE	;
	; ~p1 Format Type Definition (Table Name: ~p2 )
	S ZHDR=$$^MSG("5176",OPTION,MSKOPT)
	;
	S %O=1,SID="DBSFMT" D ^USID I PGM="" Q
	;
	S %REPEAT=8
	D LOAD
	I DFT'=MSKOPT S UX=1 ;		Include FILE prompt
	;
	S %REPEAT=$O(ZTYPE(""),-1)
	D ^@PGM
	; If DESC changes due to prior screen, then file it even though the user
	; may not have made any other change on the screen.
	I SCREEN,REPORT,OPTION="Report" D
	.	I $G(^DBCTL("SYS","*"_TYPE,MSKOPT))'="",$G(SAVEDESC)'="" S ^DBCTL("SYS","*"_TYPE,MSKOPT)=SAVEDESC
	I VFMQ="Q" Q
	;
	;---------- FILE DATA
	;
	S X="" F  S X=$O(ZTYPE(X)) Q:X=""  DO
	.	;
	.	S Z=$P(ZTYPE(X),"|",15)
	.	S ^DBCTL("SYS","*"_TYPE,MSKOPT,Z)=$P(ZTYPE(X),"|",1,14)
	.	;
	S ^DBCTL("SYS","*"_TYPE,MSKOPT)=DESC
	S KVAR=$P(KVAR,",DESC",1)_$P(KVAR,",DESC",2)	;keep DESC for next screen
	X KVAR
	Q
LOAD	;
	K ZTYPE S X=""
	S (SAVEDESC,DESC)=$S($G(DESC)'="":DESC,1:$G(^DBCTL("SYS","*"_TYPE,DFT)))
	F I=1:1 S X=$O(^DBCTL("SYS","*"_TYPE,DFT,X)) Q:X=""  DO
	.	;
	.	S ZTYPE(I)=^(X),$P(ZTYPE(I),"|",15)=X
	.	;
	F I=1:1 S X=$O(^DBCTL("SYS","*"_TYPE,MSKOPT,X)) Q:X=""  DO
	.	;
	.	S ZTYPE(I)=^(X),$P(ZTYPE(I),"|",15)=X
	.	;
	Q
	;
PRE	; ========== Pre-processor
	;
	D CHANGE^DBSMACRO("TBL","^DBCTL(""SYS"",""*DVFM"",:NOVAL")
	;
	Q
PP	; ========== Screen Post-processor
	;
	Q
	;-----------------------------------------------------------------------
FMTD	; Private ; Access screens DBSFMTDAY and DBSFMTMON to set up the names
	;           for each day of the week and each month of the year.
	;-----------------------------------------------------------------------
	;
	N MS,ML,DS,DL,MDS,MDL,REPEAT
	;
	I '($D(^DBCTL("SYS","*"_TYPE,MSKOPT,"D"))#10) Q
	F I="MS","ML","DS","DL" S @I=$G(^DBCTL("SYS","*DVFM",DFT,"D",I))
	; Day Of Week Definition (Table Name: ~p1 )
	S ZHDR=$$^MSG("5174",MSKOPT)
	;   Days Of The Week
	S DAYMONTH=$$^MSG("5172")
	;
	S SID="DBSFMTDAY",REPEAT=7,MDL=DL,MDS=DS,XX="D" D UP
	; Months Of Year Definition (Table Name: ~p1 )
	S ZHDR=$$^MSG("5175",MSKOPT)
	;  Months Of The Year
	S DAYMONTH=$$^MSG("5173")
	S SID="DBSFMTDAY",REPEAT=12,MDL=ML,MDS=MS,XX="M" D UP
	Q
	;
UP	;
	S %O=1 D ^USID I PGM="" Q
	S %REPEAT=REPEAT D LOADZ K UX
	I DFT'=MSKOPT S UX=1
	D ^@PGM I VFMQ="Q" Q
	;
	; ----------- file data
	;
	S (X,MDL,MDS)="" F  S X=$O(ZTYPE(X)) Q:X=""  D
	. S Z=ZTYPE(X)
	. S $P(MDL,",",X)=$P(Z,"|",2)
	. S $P(MDS,",",X)=$P(Z,"|",3)
	;
	F I="DVFM","RFMT" S ^DBCTL("SYS","*"_I,MSKOPT,"D",XX_"S")=MDS
	F I="DVFM","RFMT" S ^DBCTL("SYS","*"_I,MSKOPT,"D",XX_"L")=MDL
	Q
	;
	;
LOADZ	K ZTYPE
	F I=1:1:%REPEAT S ZTYPE(I)=I_"|"_$P(MDL,",",I)_"|"_$P(MDS,",",I)
	Q
