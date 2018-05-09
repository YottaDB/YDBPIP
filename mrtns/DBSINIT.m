DBSINIT	;;DBS - U -  INIT DATA QWIK CONTROL TABLE
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/28/99 14:16:51 - CHEUNGA
	; ORIG:  CHIANG - 1/1/85
	;
        ; I18N=QUIT: Exclude from I18N standards
	;
	;---- Revision History ------------------------------------------------
	;
	; 09/28/99 - Alan Cheung - 34875
	;	     Found a typing error on global name ^DBCTL in the
	;	     FORMAT section. Modified ^DBSCTL to ^DBCTL.  Also
	;            added setting of ^DBCTL("SYS","DVFM","B") for Binary
	;            and setting of ^DBCTL("SYS","DVFM","M") for Memo in
	;            the FORMAT section.
	;
	; 09/24/99 - Alan Cheung - 34875
	;	     Added a new section called FORMAT to kill off the old
	;	     ^DBCTL("SYS","RFMT") and ^DBCTL("SYS","DVFM"). This
	;	     section will build the new ^DBCTL("SYS","RFMT") and
	;	     ^DBCTL("SYS","DVFM") for the format conversion.
	;
	; 16/07/98 - Betty Ni - 29370
        ;            The routine ^DBSINIT1 was obsoleted from V6.1DEVM, removed
        ;            code to call ^DBSINIT1.
	;
	; 09/12/97 - Chiang - 26122
	;            Modified to set up initial sequence number for Data
	;            exchange and Aggregate run-time routines.
	;
	; 07/22/97 - Chiang - 24519
	;            Modified VAR section to default in the correct RW page
	;            header.
	;
	; 04/18/97 - Chiang - 24519
	;            Modified VAR section to use the correct CUVAR file short
	;            name.
	;
	; 03/27/97 - Bob Chiang - 24316
	;            Modified VAR section to move institution report/screen
	;            format edit mask information from DBCTL file to CUVAR
	;            (Institution Variables) file.
	;
	; 10/23/96 - Bob Chiang - 20948
	;            Modified to remove PRD user library logic.
	;
	; 10/09/96 - Bob Chiang - 20948
	;            Modified to set up default user library.
	;
	; 06/28/96 - SPIER - 22281
	;            Removed call to dbsinit4 to prevent rebuilding of dbctl
	;	     which may be different from cms released version.
	;
	; 02/16/96 - SPIER - 21125
	;            Removed goto START1 from section VAR, the routine was
	;	     performing background updates even if the user quit
	;	     out of the screen.
	;----------------------------------------------------------------------
	;
START	;
	N rwph80,rwph132
	;
	I '$D(^CUVAR("%LIBS")) S ^CUVAR("%LIBS")="SYSDEV"
	I '$D(%LIBS) S %LIBS=$G(^CUVAR("%LIBS"))
	;
	I '$D(^SCAU(0)) S ^SCAU(0,"SCA")="ALL LIBRARIES AND FUNCTIONS|800|3|999|3"
	I '$D(^SCAU(1)) S ^SCAU(1,1)="USER||||SCA|*",$P(^(1),"|",21)="TPU"
	;
	; *** 09/12/97
	; Aggregate , library , Store proc , Qwik , Screen , Report , Exchange
	;
	F I=22,"L","P","Q","S","R","X" I '$D(^DBTBL("SYSDEV",0,I)) S ^(I)=1
	;
	; set up default DQ variables
	;
	; Banner page
	;
	I '$D(^CUVAR("BANNER")) S ^("BANNER")=1
	;
	; Alignment pattern count
	;
	I '$D(^CUVAR("ALCOUNT")) S ^("ALCOUNT")=5
	;
	; On-line <help>/<select> option  BPS & PC mode
	;
	;
	F I="%HELP","DBS" I '$D(^CUVAR(I)) S ^CUVAR(I)=0
	I '$D(^CUVAR("DBS")) S ^CUVAR("DBS")=0
	I '$D(^CUVAR("%IO")) S ^CUVAR("%IO")="^SCAIO|2"
	I '$D(^CUVAR("%CRCD")) S ^CUVAR("%CRCD")=0
	I '$D(^CUVAR(2)) S ^CUVAR(2)=+$H
	I '$D(^CUVAR("CONAM")) S ^CUVAR("CONAM")="DATA-QWIK "_^DBTBL
	I '$D(^CUVAR("SYSDRV")) S ^("SYSDRV")="DQ"
	;
	S rwph80="SCA80",rwph132="SCA132"
	I $zvn["VMS" S rwph80="SCAU$HELP:OOE_SCA80.EXP",rwph132="SCAU$HELP:OOE_SCA132.EXP"
	;
	I $P(^("DBS"),"|",2)="" S $P(^("DBS"),"|",2)=rwph80
	I $P(^("DBS"),"|",3)="" S $P(^("DBS"),"|",3)=rwph132
	;
	I '$D(^OOEDOC) D ^FORMINST
	;
	I '$D(^DBCTL("SYS","%HELP")) G START1
	;
VAR	;
	S %O=1,%TO=60
	I $G(%FN)="" S %FN="DBSINIT"
	S ZMSKOPT=$P($G(^CUVAR("DBS")),"|",6)           ; CUVAR.EDITMASK
	I ZMSKOPT="" S ZMSKOPT="US"
        ;
        N SID S SID="DBSVAR"
        D ^USID I PGM="" Q
        D ^@PGM I VFMQ="Q" Q
	; *** 04/18/97
	S Z=0 F I=1:1 S Z=$O(fCUVAR(Z)) Q:Z=""  S ^CUVAR(Z)=fCUVAR(Z)
	;
	;;S ^DBCTL("SYS","DVFM")=ZMSKOPT  	; DQ edit mask table name
	S $P(^CUVAR("DBS"),"|",6)=ZMSKOPT  	; *** 03/27/97
	X KVAR
	;
START1	;
	D IOF
	;
	S ^DBTBL="5.3"				; *** 03/27/97
	U 0 W !!,"Create "_$G(^DBTBL)_" DATA-QWIK control table",!
	S %OPT="N"
	;
	K ^DBTBL("SYS",10)
	;
A	;
	; ---------- Define library number, screen, report, sort , filer
	;
	; ---------- Filer error condition code
	;
	S ^DBCTL("SYS","ERRFLG",1)="Log error and continue"
	S ^(2)="Log error and exit"
	;
	; ========== QWIK report data transfer option
	;
	S ^DBCTL("SYS","TFMT","ASCII")="Standard ASCII Interface|34|44|13,10|26|0|1|1|1"
	S ^DBCTL("SYS","THDR",0)="Skip Header Record",^(1)="Column Short Name Format",^(2)="Column Long Name Format"
	;
	;S ^DBCTL("SYS","DFMT",1)="MM/DD/YY",^(2)="MM/DD/YEAR",^(3)="DD-MON-YY"
	;S ^(4)="DD-MON-YEAR"
	S ^DBCTL("SYS","CFMT",1)="HH:MM AM/PM",^(2)="HH:MM:SS AM/PM"
	S ^DBCTL("SYS","LFMT",1)="Y or N",^(2)="0 or 1"
	;
	; ========== EDITOR OPTION TABLE
	;
	K ^DBCTL("SYS","EDITOR","DBS")
	S ^DBCTL("SYS","EDITOR","EDT")="VAX EDT editor"
	S ^("TPU")="VAX TPU editor"
	K ^SCAFUN
	;
	F K1="DBSEXE","DBSSCR","DBSBUR" K ^SCAFUN(K1)
	;D ^DBSINIT1
	;  ASC 09/24/1999  Calls the FORMAT section to update
        ;                  ^DBCTL("SYS","RFMT") and ^DBCTL("SYS","DVFM")
	D FORMAT	
	Q
	;
IOF	W $$CLEAR^%TRMVT Q
	;
	;
	; Select editor option
	;
EDITOR	;
	;
	D IOF
	;
	I $G(%UID)="" Q
	;
	I '$D(^SCAU(1,%UID)) Q
	S EDITOR=$P(^(%UID),"|",21) I EDITOR="" S EDITOR="EDT"
	;
	S MSG=$J("",20)_"User Id "_%UID_"   "_$P(^(%UID),"|",1)_$J("",20)
	;
	S %TAB("EDITOR")=".EDITOR1/TBL=^DBCTL(""SYS"",""EDITOR"","
	;
	K OLNTB S %READ="@MSG,,,EDITOR" D ^UTLREAD I VFMQ="Q" Q
	S $P(^SCAU(1,%UID),"|",21)=EDITOR
	Q
	;
        ;   Alan Cheung - 09/24/1999 - ARQ # 34875
        ;
        ;   Added this section of code to update ^DBCTL("SYS","RFMT") and
        ;   ^DBCTL("SYS","DVFM")
FORMAT  ;
        K ^DBCTL("SYS","RFMT")
        K ^DBCTL("SYS","DVFM")
        S ZMSKOPT=$P($G(^CUVAR("DBS")),"|",6)
        S ^DBCTL("SYS","DVFM")=ZMSKOPT        ; DQ edit mask table name
	S X=""
        F  S X=$O(^DBCTL("SYS","*RFMT",ZMSKOPT,X)) Q:X=""  D
        .       S ^DBCTL("SYS","RFMT",X)=$G(^DBCTL("SYS","*RFMT",ZMSKOPT,X))
        .       S Y=""
        .       F  S Y=$O(^DBCTL("SYS","*RFMT",ZMSKOPT,X,Y)) Q:Y=""  D
        ..              S ^DBCTL("SYS","RFMT",X,Y)=$G(^DBCTL("SYS","*RFMT",ZMSKOPT,X,Y))
        ;  Second loop
        S X=""
        F  S X=$O(^DBCTL("SYS","*DVFM",ZMSKOPT,X)) Q:X=""  D
        .       S ^DBCTL("SYS","DVFM",X)=$G(^DBCTL("SYS","*DVFM",ZMSKOPT,X))
        .       S Y=""
        .       F  S Y=$O(^DBCTL("SYS","*DVFM",ZMSKOPT,X,Y)) Q:Y=""  D
        ..              S ^DBCTL("SYS","DVFM",X,Y)=$G(^DBCTL("SYS","*DVFM",ZMSKOPT,X,Y))
        ;
	S ^DBCTL("SYS","DFMT",1)="MM/DD/YY",^(2)="MM/DD/YEAR",^(3)="DD-MON-YY"
	S ^(4)="DD-MON-YEAR"
	;
        ; Turn off I18N for the following hard-coded references to avoid this 
	; release software from flagging these code as violating I18N.
        ; I18N=OFF
	S ^DBCTL("SYS","DVFM","B")="Binary|||32000|||||32000"
	S ^DBCTL("SYS","DVFM","M")="Memo|||32000|||||32000"
        S ^DBCTL("SYS","RFMT","DAY")="Date of the week"
        S ^DBCTL("SYS","RFMT","DD-MON-YEAR")="Date"
	S ^DBCTL("SYS","RFMT","DD-MON-YY")="Date"
        S ^DBCTL("SYS","RFMT","DL")="Date of the week (long name)"
        S ^DBCTL("SYS","RFMT","DRCR")="DR/CR sign"
        S ^DBCTL("SYS","RFMT","DS")="Date of the week (short name)"
        S ^DBCTL("SYS","RFMT","EM")="Edit mask (RW only)"
        S ^DBCTL("SYS","RFMT","I$")="$ image format $$$CC"
        S ^DBCTL("SYS","RFMT","I$S")="$ image format with sign $$$Cs"
        S ^DBCTL("SYS","RFMT","ID")="Date image format MMDDYY|$$DAT^%ZM(glvn,""MM"")_$$DAT^%ZM(glvn,""DD"")_$$DAT^%ZM(glvn,""YY"")"
        S ^DBCTL("SYS","RFMT","IN")="Numeric image format NNNN"
        S ^DBCTL("SYS","RFMT","INS")="IN format with sign NNNs"
        S ^DBCTL("SYS","RFMT","JC")="Center justified"
	S ^DBCTL("SYS","RFMT","JL")="Left justified"
        S ^DBCTL("SYS","RFMT","JR")="Right justified"
        S ^DBCTL("SYS","RFMT","ML")="Month of the year (long name)"
        S ^DBCTL("SYS","RFMT","MM/DD/YEAR")="Date"
        S ^DBCTL("SYS","RFMT","MON")="Month"
        S ^DBCTL("SYS","RFMT","MS")="Month of the year (short name)"
        S ^DBCTL("SYS","RFMT","NC")="Negative  NNN CR|$S(V<0:$J(-glvn,0,+dec)_"" CR"",1:$J(glvn,0,+dec)_""   "")||R"
        S ^DBCTL("SYS","RFMT","ND")="Negative  NNN DR|$S(V<0:$J(-glvn,0,+dec)_"" DR"",1:$J(glvn,0,+dec)_""   "")||R"
	S ^DBCTL("SYS","RFMT","NP")="Negative (NNN)|$FN(glvn,""P"",dec)||R"
	S ^DBCTL("SYS","RFMT","NR")="Negative NNN-|$FN(glvn,""T"",dec)||R"
        S ^DBCTL("SYS","RFMT","RDn")="Round decimal (n)"
        S ^DBCTL("SYS","RFMT","RH")="Round hundred"
        S ^DBCTL("SYS","RFMT","RI")="Round integer"
        S ^DBCTL("SYS","RFMT","RK")="Round thousand"
        S ^DBCTL("SYS","RFMT","RM")="Round million"
        S ^DBCTL("SYS","RFMT","RT")="Round ten"
        S ^DBCTL("SYS","RFMT","YEAR")="Year"
        S ^DBCTL("SYS","RFMT","ZS")="Zero suppress"
        ;
        Q

