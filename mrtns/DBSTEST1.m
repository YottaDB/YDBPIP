DBSTEST1	;; 
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/03/98 11:25:12 - NIB
	;     ORIG:  CHIANG -  8 JUL 1992
	;CALLED BY:  
	;    CALLS:  ^UTLREAD
	;     DESC:  DEMO/QA test program for UTLREAD,DBSMENU,%TRMVT
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;---------- Revision History -------------------------------------------
	;
	; 07/15/98 - Betty Ni - 29370
	;	     Added code to eliminate $TEXT function.
	;
	; 02/19/97 - Bob Chiang - 23875
	;            Modified to replace routine name "DBSMbar" with "DBSMBAR".
	;
	; 10/11/94 - Steve Canfield - 18
	;	     Change $$^MSG(603"") to $$^MSG(603) in MBAR2 section.
	;
	; 08/23/94 - Shaodong Tony Xu - ARQ 14621
	;            Modified the variables %READ and %TAB.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 02/16/94  Bob Chiang - I18N
	;
	;           Modified to use %TAB() to set up prompt attributes.
	;
	; 11/05/93  Bob Chiang - I18N
	;
	;           Modified to replace DBSMENU with DBSMBAR calls.
	;
	; 07/20/93  Bob Chiang
	;
	;           Modified to display a default frame for UTLREAD screen.
	;-----------------------------------------------------------------------
	K OLNTB
	S %LIBS=^CUVAR("%LIBS")
	;
	S %NOPRMT="F",(zread,zmenu,zmsg,ztbl)=0
	S OLNTB=40
	S MSG="DEMO/QA routine for UTLREAD, DBSMBAR and MSG^%TRMVT"
	S %READ="@MSG/REV/CEN,"
	S %READ=%READ_",zread/DES=General Purpose IO Utility (UTLREAD)/TYP=L/NOREQ"
	S %READ=%READ_",zmenu/DES=Menu Bar Utility (DBSMBAR)/TYP=L"
	S %READ=%READ_",zmsg/DES=Message Display Utility (MSG^%TRMVT)/TYP=L"
	S %READ=%READ_",ztbl/DES=Look-up Table Utility (DBSTBL)/TYP=L,"
	S %FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	;
	I zread D UTLREAD
	I zmenu W $$CLEAR^%TRMVT D MENU
	I zmsg W $$CLEAR^%TRMVT D MSG
	I ztbl D ^DBSTEST2
	Q
	;
READ()	;
	N d,z,ZREAD
	S q=""""
	S $p(zline,"-",78)=""
	S MESREAD="%READ="_q_%READ_q
	;
	I $E(%READ)=";" S d=";"
	E  S d=","
	S %READ=%READ_d_d_"@zline"_d_"@MESREAD"_d
	I $D(%CTPRMT) S d=d_d
	s z=$O(ZMSG(""),-1)
	s x="" f  s x=$O(%TAB(x)) Q:x=""  s ZMSG(z)="%TAB("_q_x_q_")="_q_%TAB(x)_q,z=z+1
	I $D(OLNTB) S ZMSG(z)="OLNTB="_OLNTB,z=z+1
	I $D(%CTPRMT) S ZMSG(z)="%CTPRMT="_q_%CTPRMT_q
	F I=1:1 Q:'$D(ZMSG(I))  S %READ=%READ_d_"@ZMSG("_I_")"
	;
	S %FRAME=1
	D ^UTLREAD				; 05/28/93 BC
	K ZMSG,%TAB
	; Continue?
	Q $$YN^DBSMBAR("",$$^MSG(603),1)
	Q
	;-----------------------------------------------------------------------
UTLREAD	; Private ; show how UTLREAD utility works
	;-----------------------------------------------------------------------
	;
	; ---------- Display documentation
	;
	N DOC
	S DOC(1)=""
	S DOC(2)="                    UTLREAD UTILITY"
	S DOC(3)="                 ====================="
	S DOC(4)=""
	S DOC(5)="     VALID VARIABLE SYNTAX:"
	S DOC(6)="                                                Example"
	S DOC(7)=""
	S DOC(8)=" dinam                Data Item Name ([fid]di)       [DEP]CID"
	S DOC(9)=" var                  Valid Variable Name            ACN"
	S DOC(10)="     @var Message/Banner                            @MS1"
	S DOC(11)=""
	S DOC(12)=""
	S DOC(13)="     VALID KEYWORDS:"
	S DOC(14)="                                Default"
	S DOC(15)=""
	S DOC(16)="  /LEN  Field Length            N$=12        /LE=12"
	S DOC(17)="                                L=1"
	S DOC(18)="                                DC=10"
	S DOC(19)="                                UTF=255"
	S DOC(20)=""
	S DOC(21)="  /TYP  Format Type             T            /TYP=$"
	S DOC(22)="  /DES  Description             /NODES       /DES=Full Name"
	S DOC(23)="  /HLP  Help File               /NOHLP       /HLP=[DEP]IRN"
	S DOC(24)="  /TBL  Look-up Table           /NOTBL       /TBL=^ACN("
	S DOC(25)="  /PAT  Pattern Check           /NOPAT       /PAT=3.4N"
	S DOC(26)="  /XPP  Post-Processor          /NOXPP       /XPP=D ^XYZ"
	S DOC(27)="  /XPR  Pre-processor           /NOXPR       /XPR=D ^ABC"
	S DOC(28)="  /MIN  Minimum Value           /NOMIN       /MIN=100"
	S DOC(29)="  /MAX  Maximum Value           /NOMAX       /MAX=200"
	S DOC(30)="  /DEC  Decimal Precision       /NODEC       /DEC=5"
	S DOC(31)="  /SIZ  Field display length    /NOSIZ       /SIZ=10"
	S DOC(32)=""
	S DOC(33)="  /REQ  Required Field       last default    /REQ"
	S DOC(34)="        (reverse video mode)"
	S DOC(35)="  /PROT Protected Field         /NOPRO       /PRO"
	S DOC(36)="  /SEC  Secret Mode(echo off)   /NOSEC       /SEC"
	S DOC(37)="  /REP  Repeat Group            /NOREP       /REP=3"
	S DOC(38)=""
	S DOC(39)="             Valid keywords for message mode only (@var format)"
	S DOC(40)=""
	S DOC(41)="  /REV  Reverse Video                        /REV"
	S DOC(42)="  /INC  Increased Intensity                  /INC"
	S DOC(43)="  /CEN  Center Text Message                  /CEN"
	S DOC(44)=""
	;
	D ^DBSHLP("DOC(")
	;
	K DOC
	;
	; Continue?
	I '$$YN^DBSMBAR("",$$^MSG(603),1) Q
	;
	; ---------- V 5.0 format (prompt table)
	;
	K OLNTB
	S MSG="V5.0 Format"
	S %TAB("CID")=".ACN1/REQ"
	S %TAB("TYPE")=".TYPE1/NOREQ"
	S %READ="@MSG/CEN/REV,,CID,TYPE"
	Q:'$$READ()
	;
	; ---------- Field length and type default
	;
	K OLNTB,ABC,XYZ
	S OLNTB=10
	S %READ=",,ABC/LE=70/DES=A,XYZ/LE=100/SIZ=60/DES=B," Q:'$$READ()
	;
	; ---------- Field length default (based on type)
	;
	K OLNTB,ABC,OLNTB
	S %TAB("ACN")="/TYP=N/DES=Account/LEN=12"
	S %READ="ACN" Q:'$$READ()
	;
	; ---------- Banner/Message
	;
	K CID,OLNTB
	; Account Inquiry
	S MS1=$$^MSG(5488),MS2="For DDA Accounts",MS3="Type 100"
	S %TAB("CID")="[DEP]CID/REQ"
	S %READ="@MS1/REV/CEN,@MS2/INC,@MS3/INC,,CID"
	Q:'$$READ()
	;
	; ---------- Required Flag
	;
	K CID,BAL,DOB,AD1,OLNTB
	S %READ="@MS1/REV/CEN,,[DEP]CID/NOREQ,[DEP]BAL,[CIF]DOB/REQ,[MADDR]AD1/REQ"
	Q:'$$READ()
	;
	; ---------- Look-Up Table
	;
	K OLNTB,CID,BAL
	S MSG="Look-up Table"
	S %TAB("XCID")="[DEP]CID/LEN=5/TBL=^ACN("
	S %TAB("XBAL")="/DES=Balance/TYP=$/DEC=2/LEN=12"
	S %READ="@MSG/REV/CEN,,XCID/REQ,XBAL/REQ"
	Q:'$$READ()
	;
	; ---------- User-defined Field Delimiter ;
	;
	K OLNTB,CID,BAL
	S MSG="User-Defined Field Delimiter"
	S %READ=";@MSG/REV/CEN;;[DEP]CID/TBL=[DEP]CID/REQ,LNM/REQ;BAL/DES=Balance/TYP=$/DEC=2/REQ"
	Q:'$$READ()
	;
	K OLNTB,CID,BOO,LNM
	S MSG="User-Defined Field Delimiter"
	S %READ=";@MSG/REV/CEN;;[DEP]CID/REQ;[DEP]BOO/TBL=^UTBL(""BRCD"",;[DEP]LNM"
	Q:'$$READ()
	;
	; ---------- Secret Mode (echo off)
	;
	K PSW
	S MSG="Secret Mode"
	; /DES=Password/TYP=T/LEN=12
	S %TAB("PSW")=".PWD1/REQ/SEC"
	S %READ="@MSG/REV/CEN,,PSW"
	Q:'$$READ()
	;
	; ---------- Protected Mode
	;
	K CID,DOB,BAL,AD1,OLNTB
	S MSG="Protected Mode",BAL=123.45,DOB=$H-5000
	S ZMSG(1)="Example:  S BAL=123.45,DOB=$H-5000"
	S %TAB("CID")="[DEP]CID"
	S %TAB("DOB")="[CIF]DOB/PRO/NOREQ"
	S %TAB("BAL")="[DEP]BAL/PRO"
	S %TAB("ADDR")="[MADDR]AD1"
	S %READ="@MSG/REV/CEN,,CID/REQ,DOB,BAL,ADDR"
	Q:'$$READ()
	;
	; ---------- Repeat Group
AAA	;
	K ABC,XYZ,OLNTB
	S MSG="Repeat Group"
	S %TAB("LNAM")="/LE=10/TYP=T/DES=Name/REP=4"
	S %TAB("ADDR")="/LE=40/TYP=T/DES=Address"
	S %READ="@MSG/REV/CEN,,LNAM/REQ,,ADDR/REQ"
	Q:'$$READ()
	;
	; ---------- Repeat Group with Multiple Columns
	;
	K ABC,XYZ,OLNTB
	S MSG="Repeat Group and Multiple Columns",%CTPRMT="2|20"
	S %TAB("LNAM")="/LE=10/TYP=T/DES=Name/REP=4"
	S %TAB("ADDR")="/LE=40/TYP=T/DES=Address"
	S %READ="@MSG/REV/CEN,,LNAM/REQ,,ADDR/REQ"
	Q:'$$READ()
	;
	K ABC,XYZ,OLNTB
	S MSG="Repeat Group and Multiple Columns",%CTPRMT="3|20",OLNTB=15
	S %TAB("LNAM")="/LE=10/TYP=T/DES=Name/REP=4"
	S %TAB("ADDR")="/LE=40/TYP=T/DES=Address"
	S %READ="@MSG/REV/CEN,,LNAM/REQ,,ADDR/REQ"
	Q:'$$READ()
	Q
	;-----------------------------------------------------------------------
MENU	; Private ; Show how DBSMBAR utility works
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;   	MENUID 	- The menu ID
	;       TERM 	- Valid terminators list (Def=ENT)
	;		  eg: "ENT,PUP,PDN,ESC"
	;-----------------------------------------------------------------------
	;
	N %FN
	S %FN="STBLMBAR"
	D TABLE^DBSMBAR
	;
	K OP
	S MS1="DBSMBAR         Menu Bar Utility                           "
	S MS2="Example:"
	S MS3="          ^STBL(""MBAR"",MENUID)=Definition  <--- function STBLMBAR"
	S MS4="                         1000 = "_$P(^STBL("MBAR",1000),"|",1,2)_"    "
	S MS5="          S OPT=$$^DBSMBAR(1000)                            "
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,@MS4/REV,,@MS5/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	S OPT=$$^DBSMBAR(1000)
	;----------------------------------------------------------------------
	;
	K OP
	S MS1="DBSMBAR         Menu Bar Utility (Dispatch Table)"
	S MS2="Example:"
	S MS3="          S LIST=""NEW,MOD,DEL,LIST""                         "
	S MS4="          S OPT=$$^DBSMBAR(1000) Q:'OPT      ; <F11> key    "
	S MS5="          D @$P(LIST,"","",OPT)            ; Dispatch"
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,@MS4/REV,,@MS5/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	S OPT=$$^DBSMBAR(1000)
	;
	;----------------------------------------------------------------------
	K OP,VAR
	S MS1="DBSMBAR         Menu Bar Utility (single variable ~ option)"
	S MS2="Example:"
	S MS3="          Menu ID 1001 = "_$p(^STBL("MBAR",1001),"|",1,2)
	S MS4="          S VAR(3)=12                                      "
	S MS5="          S OPT=$$^DBSMBAR(1001,"""","""","""",.VAR)     "
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,@MS4/REV,,@MS5/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	S VAR(3)=12
	S OPT=$$^DBSMBAR(1001,"","","",.VAR)
	;----------------------------------------------------------------------
MBAR1	;
	K OP,VAR,skp,PAGE
	S MS1="DBSMBAR         Menu Bar Utility (mask option)"
	S MS2="Example:"
	S MS3="          Menu ID 1001 = "_$p(^STBL("MBAR",1001),"|",1,2)
	S MS4="          I PAGE=1 S skp(1)=""""         ; Skip PREVIOUS option"
	S MS5="          I PAGE=99 S skp(4)=""""        ; Skip LAST option"
	S MS6="          S VAR(3)=PAGE                                    "
	S MS7="          S OPT=$$^DBSMBAR(1001,"""",.skp,"""",.VAR)     "
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,@MS4/REV,@MS5/REV,@MS6/REV,,@MS7/REv,,PAGE/LE=2/TY=N/DES=Page Number/REQ"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD I VFMQ="Q" G MBAR2
	S VAR(3)=PAGE
	I PAGE=1 S skp(1)=""
	I PAGE=99 S skp(4)=""
	S OPT=$$^DBSMBAR(1001,"",.skp,"",.VAR)
	G MBAR1
	;----------------------------------------------------------------------
MBAR2	;
	K OP,VAR
	S MS1="DBSMBAR         Menu Bar Utility (multiple variable * option)"
	S MS2="Example:"
	S MS3="          Menu ID 1002 = "_$p(^STBL("MBAR",1002),"|",1,2)
	S MS4="          S VAR(1)=""DEP"",VAR(2)=""LN"",VAR(3)=""CIF"""
	S MS5="          S OPT=$$^DBSMBAR(1002,"""","""","""",.VAR)     "
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,@MS4/REV,,@MS5/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	S VAR(1)="DEP",VAR(2)="LN",VAR(3)="CIF"
	S OPT=$$^DBSMBAR(1002,"","","",.VAR)
	;
	; ---------- Use Multiple lines to display options
	;
	K OP,VAR
	S MS1="DBSMBAR         Menu Bar Utility (Multi-Line List)"
	S MS2="Example:"
	S MS3="          F I=1:1:40 S OP(I)=I                            "
	S MS4="          S OPT=$$^DBSMBAR(1003,"""","""","""",.OP) "
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,,@MS4/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	F I=1:1:40 S OP(I)=I
	S X=$$^DBSMBAR(1003,"","","",.OP)
	;
	; ---------- Simple Yes or No Prompt
	;
	; Cursor on No option and Return 1 (yes) or o (no)
	;
	S MS1="DBSMBAR         Menu Bar Utility (Yes or No)"
	S MS2="Example:"
	; Continue?
	S MS3="          S PROMPT=$$^MSG(603)"    ; continue ... "
	S MS4="          S OPT=$$YN^DBSMBAR("""",PROMPT)"
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,,@MS4/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	; Continue?
	S OPT=$$YN^DBSMBAR("",$$^MSG(603))                 
	;
	; Cursor on Yes option and Return 1 (yes) or o (no)
	;
	S MS1="DBSME         Menu Bar Utility (Yes or No)"
	S MS2="Example:"
	S MS3="          S OPT=$$YN^DBSMBAR("""",PROMPT,1)       "
	S MS4="                                       ^        "
	S MS5="                                        |____ Default to Yes"
	S %READ="@MS1/REV/CEN,,@MS2/REV,@MS3/REV,@MS4/REV,@MS5/REV"
	K OLNTB
	S %NOPRMT="F",%FRAME=2 D ^UTLREAD
	; Continue?
	S OPT=$$YN^DBSMBAR("",$$^MSG(603),1)                 
	;
	Q
	;
	;-----------------------------------------------------------------------
MSG	; Private ; Single line message display utility
	;----------------------------------------------------------------------- 
	; ARGUMENTS:
	;
	;
	; MSG = Message to display, not checked for length
	; OPT = Message (0) or Error >0<  	(Dft=0)
	; PWZ = Pause until keyboard activity, then remove display (Dft=0)
	; CUX = Message starting column		(Dft=1)
	; CUY = Message starting row		(Dft=24)
	; TIM = Read timeout 			(Dft=$$TODFT^%ZREAD)
	;-----------------------------------------------------------------------
	;
	S MSG="MSG^%TRMVT                   Message Display Utility"
	S MSG1="Example:  Display message PURGE COMPLETED"
	S MSG2=""
	S MSG3="       W $$MSG^%TRMVT(""PURGE COMPLETED"","""",1)         "
	S MSG4="                               ^           ^       "
	S MSG5="                               |           |       "
	S MSG6="                           Message         Pause   "
	S %READ="@MSG/REV/CEN,,@MSG1/REV,@MSG2/REV,@MSG3/REV,@MSG4/REV,@MSG5/REV,@MSG6/REV",%NOPRMT="F"
	D ^UTLREAD
	; PURGE COMPLETED
	W $$MSG^%TRMVT($$^MSG(2288),"",1)
	;
	S MSG="MSG^%TRMVT                   Message Display Utility"
	S MSG1="Example:  Display message STATUS at line 15 column 20"
	S MSG2=""
	S MSG3="       $$MSG^%TRMVT(""STATUS"","""",1,15,20)              "
	S MSG4="                                ^  ^  ^                   "
	S MSG5="                                |  |  |                   "
	S MSG6="                             Pause Ln Column              "
	; 
	S %READ="@MSG/REV/CEN,,@MSG1/REV,@MSG2/REV,@MSG3/REV,@MSG4/REV,@MSG5/REV,@MSG6/REV",%NOPRMT="F"
	D ^UTLREAD
	;
	W $$MSG^%TRMVT("STATUS","",1,15,20)
	Q
	; Purge Completed
	W $$MSG^%TRMVT($$^MSG(2288),"",1)
	Q
	;
