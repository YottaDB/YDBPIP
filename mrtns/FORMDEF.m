FORMDEF	;; -  - V4.1 - User defined key mapping & command definition
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 16:16:37 - CANFIELDS
	;     ORIG:  Frank R. Sanchez (1) - 07/29/89
	;     DESC: ASSIGN(Command_String,Keyname,Goldkey,Command_Name)
	;	    DEFINE(Command_Name,Executable_code,Help_file,Learn_file)
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	;----------------------------------------------------------------------
	;
ASSIGN(X,ALTKEY,KEYNAME,COMMAND)	; Assign a value to a key
	;
	I $G(X)="" S X=$$MORE^FORMCMD("Assign","ALTKEY/KEYNAME/COMMAND") Q:X=""
	;
	I $G(KEYNAME)="" D ZB^%ZREAD S KEYNAME=$G(%fkey)
	E  I '$$MNEMONIC(KEYNAME,$G(ALTKEY)) W $$MSG^FORM("Invalid key assigned",1) Q
	;
	N XECUTE S XECUTE=$$PARSE^FORMCMD(.X) Q:XECUTE=""
	;
	I KEYNAME="HLP" W $$MSG^FORM("Cannot assign the HELP key",1) Q
	I KEYNAME="END" W $$MSG^FORM("Cannot assign the DO key",1) Q
	I KEYNAME="ENT" W $$MSG^FORM("Cannot assign the RETURN key",1) Q
	;
	I $G(COMMAND)="" S COMMAND=X I X["|" S COMMAND=$E(X,1,2) F I=2:1 Q:$P(X,"|",I)=""  S $P(COMMAND,"_",I)=$E($P(X,"|",I),1,2)
	;
	S cmmd(COMMAND)=XECUTE
	I KEYNAME="" Q  ; Command created, not assigned to a key
	S key(KEYNAME)=COMMAND
	Q
	;
DEFINE(X,PAR,HELP,LEARN,RESET)	; ---------- Define a command locally ----------
	;
	I $G(X)="" S X=$$MORE^FORMCMD("Define","PAR/HELP/LEARN") Q:X=""
	;
	N CMMD,MUMPS
	;
	S MUMPS=$P(X," ",2,999),CMMD=$P(X," ",1)
	;
	I MUMPS="" S MUMPS=$$^FORMREAD("",99,"Code: ") Q:MUMPS=""
	;
	S cmmd(CMMD)=MUMPS
	I $G(PAR)'="" S qlfy(CMMD)=PAR
	I $G(HELP)'="" S help(CMMD)=HELP
	I $G(LEARN)'="" S learn(CMMD)=LEARN
	Q
	;
READ(X,cmmt,alt)	; ---------- Read key from screen ----------
	;
	W $$CPS^%TRMVT ; Save cursor location
	;
	N Z,%fkey
	;
	I $G(cmmt)="" S cmmt="Press " S:$G(alt) cmmt=cmmt_"ALT-" S cmmt=cmmt_X
REAGN	;
	;
	D VIDEO^FORM(VIDOF) W BTMPAG,cmmt," ",$$CPR^%TRMVT ; Restore cursor
	R *Z D ZB^%ZREAD I X'[%fkey W BEL G REAGN
	W BTMPAG Q
	;
MNEMONIC(key,alt)	; Validate MNEMONIC key value 
	;
	I $G(alt)'="" S key="*"_key
	Q $D(^DBCTL("SYS","%KB",$$UC(key)))
	;
UC(X)	Q $$UPPER^SCAUTL(X)
ZB()	S ZB=$A($ZB,$L($ZB)) S:ZB=126 ZB=+$E($ZB,3,9) Q ZB
