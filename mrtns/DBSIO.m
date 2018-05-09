DBSIO	;; -  - V4.4 - 
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/01/97 16:41:34 - CHIANG
	;     ORIG:  CHIANG - 20 OCT 1992
	;     DESC:  General purpose device selection utility to be used on
	;            the last line of the screen.
	;
        ; I18N=QUIT: Exclude from I18N standards
	; MODIFICATIONS:
	; RLC	12/8/92
	;	Modified to translate Device input to uppercase.
	;
	;
	; RETURNS:
	;    IO	   Device Name				/TYP=T
	;-----------------------------------------------------------------------
	;---------- Revision History -------------------------------------------
	; 10/01/97 - Bob Chiang - 26335
	;            Modified to not convert device name into uppercase format,
	;            otherwise the UNIX system will not recognize the file name.
	;
	; 10/29/96 - Bob Chiang - 20948
	;            Modified routine to reset variable %O (processing mode) so
	;            the lookup table selection logic on output device will
	;            function correctly.
	;----------------------------------------------------------------------
	;
START	;     
	N X,%EXT,ER,I,ET,RM,Z,vdd,%O			; *** 10/29/96
	S %O=1						; ***
START1	;
	S ER=0
	; Device: 
	W $$BTM^%TRMVT,$$^MSG(829)			; Select device
	S IO=$$TERM^%ZREAD				; RMS or printer
	I IO="?"!(%fkey="SEL") DO  G START1:IO=""	; <SELECT> key
	.	N OLNTB
	.	S OLNTB=1,IO=$P(IO,"?",1)		; Reset display region
	.	W $$CLEAR^%TRMVT			; Clear screen
	.	S IO=$$^DBSTBL("[DEVICE]DEVNAME",IO)	; Select Device
	.	I $G(PGM)'="" D VREPRNT^@PGM		; Restore screen image
	;
	I IO="" Q					; skip if CRT
	U 0 I IO=$I Q					; skip if same device
	;
	S X=IO,%EXT=1
	D ^SCAIO					; Check device name
	I $G(ER) D MSG G START1
	;
	N %O						; Protect %O variable
	D OPEN^SCAIO					; Open output device
	I $G(ER) D MSG G START1				; Not authorized
	Q
MSG	;-----------------------------------------------------------------------
	; Private ; Display error message
	;-----------------------------------------------------------------------
	S IO=""	
	I $G(RM)'="" W $$MSG^%TRMVT(RM,"",1)		; Display error message
	Q
