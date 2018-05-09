	;=%UserName;=%FileMod; M run-time code for PSL class Number
	; Copyright(c)2008 Fidelity National Information Services, Inc.  All Rights Reserved
	;
	; ORIG: Frans S.C. Witte - 2008-10-29
	; DESC: M run-time code for PSL class Number
	;
	; I18N=QUIT
	;
	;---- Comments ---------------------------------------------------------
	; This routine contains the GT.M runtime code for the PSL class Number
	; that cannot be generated as inline M code.
	;
	;
	;---- Revision History -------------------------------------------------
	; 2009-02-03, Frans S.C. Witte, CR 35741/37665
	;	Corrected round() to ensure it returns a canonic number for
	;	vRound="".
	;
	; 2008-10-29, Frans S.C. Witte, CRs 35741/36952
	;	Initial module. Contains NLL implementations of Number.round()
	;	and Number.roundDec().
	;
	;-----------------------------------------------------------------------
round(this,vDec,vRound) ; public String(Integer,String)
	;-----------------------------------------------------------------------
	; This function provides the M implementation of the method
	; Number.round(). There is no need to initialize default values for
	; missing variables, as that is done by the code generator.
	;
	; This function expects a canonic number and returns a canonic number.
	; So if the number of fractional digits is less than or equal to the
	; requested number of decimals, the original value is returned.
	;
	IF $LENGTH($PIECE(this,".",2))'>vDec QUIT this
	;
	; There are excess digits, apply rounding.
	; Standard round-to-nearest is provided by ISO-M $JUSTIFY(), but the
	; returned value needs to be turned into a canonic number.
	IF vRound="" QUIT +$JUSTIFY(this,0,vDec)
	;
	; If there are (non-zero) excess digits this#vFrac will be non-zero. Use
	; that to construct the increment value. The combination of integer
	; divide and multiplication will get rid of the excess digits, and vInc
	; will provide the additional rounding:
	; - round down of negative value: vInc=-1
	; - round up of positive value: vInc=1
	; - round down of positive value and round up of negative value: vInc=0
	NEW vFrac,vInc
	SET vFrac=10**-vDec,vInc=$SELECT(vRound="-":-(this<0),1:this>0)
	QUIT (this\vFrac+vInc)*vFrac
	;
	;-----------------------------------------------------------------------
roundDec(this,vDec,vRound,vJust) ; public String(Integer,String,Integer)
	;-----------------------------------------------------------------------
	; This function provides the M implementation of the method
	; Number.roundDec(). There is no need to initialize default values for
	; missing variables, as that is done by the code generator.
	;
	; Standard round-to-nearest is provided by ISO-M $JUSTIFY().
	IF vRound="" QUIT $JUSTIFY(this,vJust,vDec)
	;
	; Else use Number.round() to do the rounding, and ISO-M $JUSTIFY() for
	; leading spaces and trailing zeros.
	QUIT $JUSTIFY($$round(this,vDec,vRound),vJust,vDec)
	