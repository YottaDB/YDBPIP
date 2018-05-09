FORMINST	;; -  - V4.2 - Form system installation driver
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:25:49 - NIB
	;     ORIG:  Frank R. Sanchez (2497) - 07/27/89
	;     DESC: Install FORM editor commands and default key map
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 02/28/07 - RussellDS - CR25382
	;	     Removed initialization of "FILL" - no longer supported.
	;
	;	     Removed old revision history.
	;-----------------------------------------------------------------------
	;
	; ------------ OOE on-line help documentation
	;
	I '$D(^CUVAR("PC")) D CONVERT^FORMPNT($$SCAU^%TRNLNM("HELP","FORM.DOC"))
	;
	; ------------ Install the EDITOR commands ------------
	;
	U 0 W !!,"Install OOE commands",!!
	;
	K ^DBCTL("SYS","%KB")
	K ^DBCTL("SYS","FORMKEY")
	K ^DBCTL("SYS","FORMCMD")
	;
	D KBINIT
	;
	S ^DBCTL("SYS","FORMCMD","80_132")="D RM^FORMINIT"
	S ^("S80")="D CO^FORMINIT"
	S ^("S132")="D CI^FORMINIT"
	S ^("ASSIGN")="D ASSIGN^FORMDEF()|GOLDKEY/KEYNAME/COMMAND"
	S ^("ALIGN_LF")="D ALIGN^FORMEDIT(1)"
	S ^("ALIGN_RT")="D ALIGN^FORMEDIT(3)"
	S ^("BREAK")="D TRMSET^FORMINIT B"
	S ^("BRK_OBJ")="D BREAK^FORMEDIT"
	S ^("BUFCLR")="D BUFCLR^FORMBFR()"
	S ^("BUFCOP")="D BUFCOP^FORMBFR()"
	S ^("BUF_MGR")="D BUFMGR^FORMBFR()"
	S ^("CHGNCASE")="D CHGCAS^FORMHDG()"
	S ^("COLOR")="D COLOR^FORMHDR()"
	S ^("COMMAND")="D ^FORMCMD()"
	S ^("CONVERT")="D ^FORMCONV()|PREFIX/RECORDS/OUTPUT"
	S ^("COPY")="D SAVE^FORMBFR(1)"
	S ^("DCL")="D DCL^FORMEDIT()"
	S ^("DEFINE")="D DEFINE^FORMDEF()|HELP/LEARN"
	S ^("DEL_LIN")="D REMOVE^FORM"
	S ^("DEL_OBJ")="D REMOBJ^FORMFUN"
	S ^("EDIT")="D EDIT^FORMEDIT()"
	S ^("EOBJ")="D EOB^FORMCUR"
	S ^("END")="D END^FORMCUR"
	S ^("FILE")="D FILE^FORMEDIT()"
	S ^("FIND")="D FINDM^FORMCUR()|EXACT/MARKER"
	S ^("FIND_VAR")="D FINDD^FORMCUR()|EXACT/MARKER"
	S ^("FORMAT")="D FORMAT^FORMEDIT()"
	S ^("FRAME")="D ^FORMFRM($G(RHTMAR))"			; 05/05/93 BC
	S ^("FUNCTION")="D FUNCTION^FORMEDIT()"
	S ^("GOTO")="D GOTO^FORMCUR()|MARKER"
	S ^("GRAPHIC")="D GRAPH^FORMHDR"
	S ^("GRAPH_OF")="D GO^FORMHDR"
	S ^("GRAPH_ON")="D GI^FORMHDR"
	S ^("HEADING")="D ON^FORMHDG()"
	S ^("HELP")="D HELP^FORMFUN()"
	S ^("HOME")="D HOME^FORMCUR"
	S ^("IMPORT")="D IMPORT^FORMEXCH()|OVERLAY"
	S ^("INSERT")="D INSERT^FORMFUN()|LOCATION"
	S ^("JOIN_OBJ")="D JOIN^FORMEDIT"
	S ^("KEYPAD")="D KEYPAD^FORMFUN"
	S ^("LEARN")="D LEARN^FORMFUN()"
	S ^("LINE")="D ^FORMLINE"
	S ^("MARKER")="D MARK^FORMCUR()|LOCATION"
	S ^("MENU")="D ^FORMEDIT()"
	S ^("MOV_OBJ")="D MOVGRP^FORMFUN()"
	S ^("MOV_LIN")="D MOVLIN^FORMFUN()|LOCATION"
	S ^("PAN_UP")="D SCROLLUP^FORMPAN()"
	S ^("PAN_DN")="D SCROLLDN^FORMPAN()"
	S ^("PAN_LF")="D PANLFT^FORMPAN()"
	S ^("PAN_RT")="D PANRHT^FORMPAN()"
	S ^("PREV_OBJ")="D RTAB^FORMCUR"
	S ^("PRINT")="D ^FORMPNT()|DEVICE"
	S ^("QUIT")="D QUIT^FORMINIT()"
	S ^("READ")="D READ^FORMDEF()|PROMPT/GOLD"
	S ^("REFRESH")="D PUTRGN^FORMFUN()"
	S ^("REMOVE")="D REMOVE^FORM"
	S ^("RETURN")="D LNFEED^FORM"
	S ^("RESET")="D RESET^FORMSTAT()"
	S ^("RULER")="D ^FORMRULR"
	S ^("RULER_ON")="D ON^FORMRULR"
	S ^("RULER_OFF")="D OFF^FORMRULR"
	S ^("SCRIPT")="D SCRIPT^FORMCMD()|WAIT/VERIFY"
	S ^("SELECT")="D SELECT^FORMSEL()"
	S ^("SEL_LIN")="D SELLIN^FORMSEL()"
	S ^("SEL_ALL")="D SELALL^FORMSEL()"
	S ^("SEL_COL")="D SELCOL^FORMSEL()"
	S ^("SEL_FORM")="D FORM^FORMSEL()"
	S ^("SEL_GRP")="D SELGRP^FORMSEL()"
	S ^("SEL_OBJ")="D ^FORMSEL"
	S ^("SEL_OFF")="D SELOFF^FORMSEL(0)"
	S ^("SET")="D SET^FORMINIT()"
	S ^("SIZE")="D SIZE^FORMHDR()"
	S ^("STATUS")="D ^FORMSTAT"
	S ^("STATUS_ON")="D ON^FORMSTAT"
	S ^("STATUS_OFF")="D OFF^FORMSTAT"
	S ^("STYLE")="D STYLE^FORMHDR()"
	S ^("TRN_S_T")="D TRNST^I18NOOE()"
	S ^("TRN_T_S")="D TRNTS^I18NOOE()"
	S ^("TAB")="D FTAB^FORMCUR"
	S ^("TEXT")="D TEXT^FORMFUN()|LOCATION/STYLE/SIZE/COLOR/MARKER"
	S ^("WAIT")="D WAIT^FORMCMD()|COMMENT/VERIFY/PERMANENT"
	;
	; ------------ Define the default key map -----------------
	;
	D key("FND",0,"FIND")
	D key("INS",0,"INSERT")
	D key("SEL",0,"SEL_OBJ")
	D key("REM",0,"REMOVE")
	D key("PUP",0,"PAN_UP")
	D key("PDN",0,"PAN_DN")
	D key("TAB",0,"TAB")
	;;;;;D key("CTRL-L",0,"LINE")
	D key("DSP",0,"REFRESH")
	D key("ESC",0,"QUIT")
	D key("HLP",0,"KEYPAD")
	D key("END",0,"MENU")
	D key("PF3",0,"MOV_LIN")
	D key("PF4",0,"DEL_LIN")
	D key("F9",0,"TRN_S_T")
	D key("F10",0,"TRN_T_S")
	D key("KP,",0,"STATUS")
	D key("KP-",0,"ALIGN_RT")
	D key("KP1",0,"SELECT")
	D key("KP2",0,"GOTO")
	D key("KP3",0,"COMMAND")
	D key("KP4",0,"HEADING")
	D key("KP5",0,"STYLE")
	D key("KP6",0,"GRAPHIC")
	D key("KP7",0,"RULER")
	D key("KP8",0,"PREV_OBJ")
	D key("KP9",0,"BRK_OBJ")
	;
	; --------- GOLD keys --------------
	;
	D key("FND",1,"FIND_VAR")
	D key("SEL",1,"SEL_GRP")
	D key("PUP",1,"HOME")
	D key("PDN",1,"END")
	D key("ENT",1,"EOL")
	D key("END",1,"QUIT")
	D key("CUU",1,"PAN_UP")
	D key("CUD",1,"PAN_DN")
	D key("CUF",1,"PAN_RT")
	D key("CUB",1,"PAN_LF")
	D key("PF3",1,"MOV_OBJ")
	D key("PF4",1,"DEL_OBJ")
	D key("KP,",1,"RESET")
	D key("KP1",1,"SEL_OFF")
	D key("KP2",1,"BUF_MGR")
	D key("KP3",1,"DCL")
	D key("KP4",1,"CHGNCASE")
	D key("KP5",1,"SIZE")
	D key("KP6",1,"FRAME")				; 05/05/93 BC
	D key("KP-",1,"ALIGN_LF")
	D key("KP7",1,"80_132")
	D key("KP8",1,"EOBJ")
	D key("KP9",1,"JOIN_OBJ")
	D key("REM",1,"SEL_FORM")
	Q
	;
	;----------------------------------------------------------------------
	; Create command key map
	;---------------------------------------------------------------------
	;
key(ZB,GOLD,COMMAND,PARAMS,USER)	; File key map
	;
	N STRING
	;
	I ZB?1A.E S ZB=$G(^DBCTL("SYS","%KB",ZB)) I ZB="" Q
	;
	S PARAMS=$G(PARAMS) ;          Parameter list
	S USER=+$G(USER) ;             User id or default (0)
	I GOLD S ZB="*"_ZB ;            Gold key assigned
	;
	I $D(cmmd(COMMAND)) S STRING=cmmd(COMMAND)
	E  S STRING=$P($G(^DBCTL("SYS","FORMCMD",COMMAND)),"|",1) Q:STRING=""
	;
	I PARAMS]]"" S STRING=$P(STRING,"(",1)_"("_PARAMS_")"_$P(STRING,")",2)
	;
	S ^DBCTL("SYS","FORMKEY",USER,ZB)=COMMAND
	Q
	;
KBINIT	; ---------- Initialize the VT220 keyboard terminator sequences -----
	;
	; ---------- Direction and function keypad ----------
	;
	D ^FORMZB Q
	Q
