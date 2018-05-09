UTLO	; Define teller location (TLO)
	;
	; **** Routine compiled from DATA-QWIK Procedure UTLO ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	S UTLO=$$TLO
	Q 
	;
TLO()	; Function returns TLO
	;
	N UTLO
	I '$$INTRACT^%ZFUNC S UTLO="BATCH"
	E  S UTLO=$$READPRT^%ZFUNC($I)
	;
	Q UTLO
	;
vSIG()	;
	Q "59495^75673^Lik Kwan^1403" ; Signature - LTD^TIME^USER^SIZE
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	N ET,RM
	S ET=$P(error,",",3)
	;
	I ET["%GTM-" D ZE^UTLERR Q 
	S ET=ET_"-"_$P(error,",",2)
	S RM=$P(error,",",4)
	D ^UTLERR
	Q 
