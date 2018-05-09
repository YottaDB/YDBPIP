 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCACOPYR ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCACOPYR(LINE) ; 
 ;
 N USERNAME,%TIM
 ;
 I '$D(TLO) N TLO S TLO=$$TLO^UTLO
 S LINE=" ;;Copyright(c)"_$$vdat2str($P($H,",",1),"YEAR")
 S LINE=LINE_" Sanchez Computer Associates, Inc.  All Rights Reserved"
 S %TIM=$$TIM^%ZM(,"24:60")
 S LINE=LINE_" - "_$$vdat2str($P($H,",",1),$get(%MSKD))_" "_%TIM_" - "
 S LINE=LINE_$$USERNAM^%ZFUNC
 ;
 Q 
 ;
EXT ; 
 ;
 N MSG
 D SCACOPYR(.MSG)
 ;
 Q MSG
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60627^21758^Hema Puttaswamy^1610" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
