 ; 
 ; **** Routine compiled from DATA-QWIK Procedure CUVAR ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
CUVAR(COL) ; Institution Variable Defaults
 N vret
 ;
 N DFT N VAL
 ;
 I COL="%LIBS" Q "SYSDEV" ; Library Name
 I COL="%CRCD" Q 0 ; System Base Currency Code
 I COL="CO" Q "" ; Company Mnemonic
 I COL="ISO" Q "" ; ISO Number
 ;
 N cuvar S cuvar=$$vRCgetRecord0^RecordCUVAR(0)
  S vobj(cuvar,2)=$G(^CUVAR(2))
 I COL="TJD" S vret=$P(vobj(cuvar,2),$C(124),1) K vobj(+$G(cuvar)) Q vret ; System Processing Date
 ;
 S DFT=""
 ;
 I (COL["|") D
 .	S COL=$piece(COL,"|",1) ; Column Name
 .	S DFT=$piece(COL,"|",2) ; Default Value
 .	Q 
 ;
 S VAL=$$propGet^DBSDYNRA(cuvar,COL)
 ;
 I (VAL="") K vobj(+$G(cuvar)) Q DFT
 ;
 K vobj(+$G(cuvar)) Q VAL
 ;
LIST(VLIST) ; Load a list of Institution Variables if not already defined
 ;
  S ER=0
 ;
 N I N PC
 N COL
 ;
 F I=1:1:$L(VLIST,",") D  Q:ER 
 .	S PC=$piece(VLIST,",",I) ; get piece
 .	S COL=$piece(PC,"|",1) ; get column name
 .	I '$D(@COL) S @COL=$$^CUVAR(COL) ; get value
 .	Q 
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60087^61013^Dan Russell^1401" ; Signature - LTD^TIME^USER^SIZE
