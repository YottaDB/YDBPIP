DBSMBAR(CODE,TERM,MASK,NOESC,VAR,TIME)	;Public; BAR menu utility
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/03/96 13:17:08 - ZENGF
	;
	; Extrinsic function to display a bar menu at the bottom of the screen.
	;
	; LIBRARY:
	;	. $$DBSMBAR	Menu options
	;	. $$YN		Yes or No options only
	;	. $$EMULATE	Function key emulation
	;
	; ARGUMENTS:
	;	. CODE	Menu bar table code	/TYP=N/REQ/MECH=VAL
	;		(^STBL("MBAR",CODE))
	;	. TERM	Valid terminators list (Def=ENT) /TYP=T/NOREQ/MECH=VAL
	;		e.g.: "ENT,PUP,PDN,ESC"
	;	. MASK	Option mask,  for options to exclude from display
	;					/TYP=T/NOREQ/MECH=REFNAM:R
	;	. NOESC No ESC flag		/TYP=N/NOREQ/MECH=VAL
	;	. VAR   Variable array for options
	;					/TYP=T/NOREQ/MECH=REFNAM:R
	;	. TIME Non-blocking timeout in seconds
	;					/TYP=N/NOREQ/MECH=VAL
	;	     If the TIME argument is defined, the function returns
	;            with NULL if no keybord response is received within the
	;            seconds sepecified in TIME.
	;
	;            If the TIME arguement is not define, an error message 
	;            is displayed when the system time-out in the seconds 
	;            sepcified ^CUVAR. The function does not return until 
	;            an valid opt is selected.
	;
	; RETURNS:
	;	$$	
	; EXAMPLE:
	;                       Display
	;                       -------------------------------------
	; S X=$$^DBSMBAR(9)	Deposit  Loan  Miscellaneous  Inquiry
	;
	; S RM=$$^MSG(17)
	; S X=$$^DBSMBAR(16)	Menu: Continue  Show_Input  Next  Quit
	;
	; S OPT(1)="DEP"	DEP  LN  CIF
	; S OPT(2)="LN"
	; S OPT(3)="CIF"
	; S X=$$^DBSMBAR(29,"","","",.OPT)
	;
	; S OPT(1)="DEP"	DEP  CIF
	; S OPT(2)="LN"
	; S OPT(3)="CIF"
	; S ZMASK(2)=""
	; S X=$$^DBSMBAR(29,"",.ZMASK,"",.OPT)
	;
	;-------- Revision History ---------------------------------------------
	; 10/18/05 - RussellDS - CR17834
	;	     Remove TABLE section.  No longer called, eliminates call to
	;	     DBSFILER.
	;
	;	     Remove old revision history.
	;-----------------------------------------------------------------------
	;
	U ""
	;
	N i,C,CT,D,I,FC,FN,NF,LOW,HIGH,OP,PG,STRING,T,J,X,TMOUT
	;
	I '$D(VA) N CSI,CURON,CUROF,VA,VIDOF,VIDRV,video D INIT
	I $D(%fkey)<10 N %fkey D ZBINIT^%TRMVT()
	D GETTAB
	I $G(TERM)="" S TERM="ENT"
	;
	; ----- NOECHO, Turn off cursor, Move to line 24, turn off video -----
	;
	D TERM^%ZUSE("","NOECHO")
	W CUROF,$$BTM^%TRMVT,VA(VIDOF)
	S video=VIDOF
	;
	S LOW=$O(OP("")),HIGH=$ZP(OP(""))
	;
	S FC="",PG=1,NF=LOW-1
	;
	S FN=LOW
	;
	F I=LOW:1:HIGH I $D(OP(I)) D LOAD
	;
	S PG(PG)=$E(D,1,80),PG=0
	D DISPLAY
	D GETOPT
	D TERM^%ZUSE("","ECHO")
	;
	W CURON,$$BTM^%TRMVT
	I FN="" Q FN
	I FN=0 S FN=1					; *** 06/17/94 - BC
	Q T(FN)
	;
	;----------------------------------------------------------------------
GETTAB	; Get the option string and prompt from the table
	;----------------------------------------------------------------------
	;
	S T=^STBL("MBAR",CODE),D=$P(T,"|",2),T=$P(T,"|")
	;
	I D["<<",D[">>" D	; *** BC - support variable syntax text<<var>>text
	.	S D="S D="_""""_$P(D,"<<",1)_""""_"_"_$P($P(D,"<<",2),">>",1)_"_"_""""_$P(D,">>",2)_""""
	.	X D
	I $L(D) S D=D_"  "
	S CT=0
	;
	; *** BC - General purpose external menu options - 02/08/94
	;
	I T="*" S I=$ZP(VAR("")) F J=1:1:I S $P(T,",",J)=$P(VAR(J),"|",1)
	F I=1:1:$L(T,",") I $P(T,",",I)[("~") S $P(T,",",I)=$P($P(T,",",I),"~")_$P($G(VAR(I)),"|",1)	; *** BC - 10/25/93
	F I=1:1:$L(T,",") S T(I)=I I '$D(MASK(I)),$P(T,",",I)'="" S CT=CT+1,OP(CT)=$P(T,",",I),T(CT)=I	; *** BC - 10/25/93
	Q
	;----------------------------------------------------------------------
LOAD	; Load the option array
	;----------------------------------------------------------------------
	;
	S X=OP(I)
	I $L(D)+$L(X)+3>80 D NEWPAG
	S C=$C(PG,13) I $L(D) S C=C_CSI_$L(D)_"C"
	S C(I)=C_X,D=D_X_"  ",FC=FC_$E(X)
	Q
	;----------------------------------------------------------------------
NEWPAG	; Change the page number to accept >1 screen
	;----------------------------------------------------------------------
	;
	I $L(D)+$L(X)'>80,$O(OP(I))="" Q  ; Last option and it fits
	S PG(PG)=$E(D,1,77)_$J("",77-$L(D))_"...",D="... "
	S PG=PG+1
	Q
	;
	;----------------------------------------------------------------------
GETOPT	; Display editor commands
	;----------------------------------------------------------------------
	;
	W VA(VIDRV) ; 		Turn reverse video on
	W $E(C(FN),2,999) ; 	Display the current option
	W VA(VIDOF) ; 		Turn reverse video off
	;
	; *** 07/12/95 BC (added timeout option)
	S TMOUT=0
	R X#1:$$TODFT E  S TMOUT=1
	I TMOUT,$D(TIME) S FN="" Q		; non blocking timeout
	I TMOUT,'$D(TIME) D RESUME^%ZREAD S PG=0 D DISPLAY G GETOPT
	;
	D ZB^%ZREAD
	W $E(C(FN),2,999)
	I X'="" D STRING G GETOPT
	I $D(STRING) Q:%fkey="ENT"  K STRING  ; RETURN Allowed after character
	;
	I %fkey="ESC",'$G(NOESC) S FN="" S:TERM'[%fkey %fkey="" Q
	I %fkey="CUB" S FN=FN-1 S:FN<LOW FN=HIGH D DISPLAY G GETOPT
	I %fkey="CUF" S FN=FN+1 S:FN>HIGH FN=LOW D DISPLAY G GETOPT
	;
	I %fkey'="",TERM[%fkey S:$D(fkterm(%fkey)) FN=fkterm(%fkey),%fkey="ENT" Q
	;
	I %fkey="PUP" D PUP,DISPLAY G GETOPT
	I %fkey="PDN" D PDN,DISPLAY G GETOPT
	W $C(7) G GETOPT
	;
	;----------------------------------------------------------------------
PDN	; Move forward 1 page
	;----------------------------------------------------------------------
	;
	N Z
	S Z=$O(PG(PG)) I Z="" S FN=$O(C("")) Q
	F FN=FN:1 Q:$A(C(FN))=Z
	Q
	;
	;----------------------------------------------------------------------
PUP	; Move backward 1 page
	;----------------------------------------------------------------------
	;
	N Z
	S Z=$ZP(PG(PG)) I Z="" S Z=$ZP(PG(PG))
	Q
	;----------------------------------------------------------------------
STRING	; User entered 1st character of choice
	;----------------------------------------------------------------------
	;
	S X=$$UPPER^UCGMR(X)
	I $F(FC,X,FN+1) S FN=$F(FC,X,FN+1)-1+NF,STRING="" D DISPLAY Q
	I $F(FC,X) S FN=$F(FC,X)-1+NF,STRING="" D DISPLAY Q
	W $C(7) Q
	;
	;----------------------------------------------------------------------
DISPLAY	;
	;----------------------------------------------------------------------
	;
	I PG=$A(C(FN)) Q
	S PG=$A(C(FN)) W $$BTM^%TRMVT,PG(PG) Q
	;
	;----------------------------------------------------------------------
	;----------------------------------------------------------------------
INIT	; Screen control variables were not previously defined
	;----------------------------------------------------------------------
	;
	N %KB
	S CSI=$$CSI^%TRMVT
	S VIDOF=0,VA(VIDOF)=$$VIDOFF^%TRMVT
	S VIDRV=1,VA(VIDRV)=$$VIDREV^%TRMVT
	S CURON=CSI_"?25h"
	S CUROF=CSI_"?25l"
	Q
	;
	;----------------------------------------------------------------------
YN(TERM,MSG,YN)	;Public; Prompt for Yes (1) or No (0) response
	;---------------------------------------------------------------------
	;
	; ARGUMENTS:
	;	. TERM	Field terminators	/TYP=T/NOREQ/MECH=VAL
	;	. MSG	Message			/TYP=T/NOREQ/MECH=VAL
	;	. YN	Yes/No option		/TYP=T/NOREQ/DEF=1,MECH=VAL
	;
	; EXAMPLE:
	;					Display
	;
	; S X=$$YN^DBSMBAR                      No Yes
	; S X=$$YN^DBSMBAR("",$$^MSG(603))	Continue  No Yes
	; S X=$$YN^DBSMBAR("",$$^MSG(603),1)    Continue  Yes No
	;----------------------------------------------------------------------
	N OP,fkterm
	I '$D(MSG) N MSG S MSG=""
	S OP=2 I $G(YN) S OP=1,fkterm("END")=0
	S OP=$$DBSMBAR(OP,$G(TERM)_",ENT,END","",1)
	S OP=$S($G(YN):OP#2,1:OP-1)
	Q OP
	;
EMULATE()	; Return terminal escape key from a menu bar
	;----------------------------------------------------------------------
	;
	N S,I,X,C,ES
	;
	S S=$$KBP^%TRMVT
	F I=1:1 S C=$P(S,"|",I*2) Q:C=""  I $D(%fkey(C)) S ES(I)=C	
	S X=$$DBSMBAR(3) I X="" Q ""
	Q ES(X)
	;
	;----------------------------------------------------------------------
ADD(%fkey,zseq)	; Public ; Add an option to the list
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;     . %fkey	Standard function key name	/TYP=T/REQ/MECH=VAL
	;     . zseq      menu option sequence number	/TYP=N/REQ/MECH=REFNAM:RW
	;
	; INPUTS:
	;
	;     . fkterm  List of valid VT function keys	/TYP=T/REQ/MECH=REFNAM:RW
	;
	; EXAMPLE:
	;
	;        D ADD^DBSMBAR("PUP",.I)
	;-----------------------------------------------------------------------
	;
	I $G(%fkey)="" Q
	S fkterm=$G(fkterm)
	S fkterm(%fkey)=zseq,zseq=zseq+1	; Next sequence number
	I fkterm'[%fkey S fkterm=fkterm_","_%fkey
	Q
	;--------------------------------------------------------------------- 
TODFT()	; Get time out in seconds 
	;----------------------------------------------------------------------- 
	Q $S($G(TIME):TIME,$G(%TO):%TO,1:300)
