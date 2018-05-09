SCACOPYR(LINE)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCACOPYR ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	N USERNAME,%TIM
	;
	I '$D(TLO) N TLO S TLO=$$TLO^UTLO
	S LINE=" ;;Copyright(c)"_($$vdat2str($P($H,",",1),"YEAR"))
	S LINE=LINE_" Sanchez Computer Associates, Inc.  All Rights Reserved"
	S %TIM=$$TIM^%ZM(,"24:60")
	S LINE=LINE_" - "_$$vdat2str($P($H,",",1),$get(%MSKD))_" "_%TIM_" - "
	S LINE=LINE_$$USERNAM^%ZFUNC
	;
	Q 
	;
EXT	;
	;
	N MSG
	D SCACOPYR(.MSG)
	;
	Q MSG
	;
vSIG()	;
	Q "60627^21758^Hema Puttaswamy^1589" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
