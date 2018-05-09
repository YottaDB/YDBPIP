%ZM	;;09:02 PM  1 May 1993 
	;;Copyright(c)1993 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/20/93 09:55:06 - CHIANG
	;     ORIG: FSANCHEZ   07 - NOV - 1991 
	;CALLED BY: 
	;    CALLS:  ^%ZM,^%ZT 
	;     DESC: This routine contains a series of format mask subroutines 
	; 
	;      NUM -	Numeric Mask 	Byte1=Decimal  Byte2=Thousand
	; DAT -	Data Mask 	DD=Day  MM=Month  YY=Year
	; TIM -	Time Mask	12:00:00 A/PM or 24:00:00
	; LOG -	Logic Mask	Bytr1=NO       Byte2=YES
	; PIC -	Picture Mask    x=Character    n=Number
	; 
	;---------- Revision History ------------------------------------------- 
	; 
	; 12/18/92  Bob Chiang - I18N_#9 
	;           Modified to support special date format ML,MS,DL,DS 
	;           (days of the week and months of the year). 
	;--------------------------------------------------------------------- 
NUM(v,dec,msk)	; Numeric mask - Decimal<Thousand<Negative<Leading
	;--------------------------------------------------------------------- 
	; 
	I v="",'dec Q "" 
	; 
	I "."[$G(msk) Q $J(v,0,$G(dec)) 
	; 
	N vm,vf 
	; 
	S vf="" 
	; 
	S vm=$E(msk,1) ; 			Replace Decimal
	I $E(msk,3)'="" S vf=$E(msk,3) S:vf="L" vf="" ; Negative Number
	I 9'[$E(msk,2) S vf=vf_",",vm=vm_$E(msk,2) ; Replace thousand sep
	; 
	I vf'="" S v=$TR($FN(v,vf,+$G(dec)),".,",vm) 
	E  I vm'="." S v=$TR($J(v,0,+$G(dec)),".",vm) 
	; 
	I $E(msk,4)'="" S v=$E(msk,4)_v 
	Q v 
	; 
	;--------------------------------------------------------------------- 
DAT(v,msk)	; Date mask - MM/DD/YY
	;--------------------------------------------------------------------- 
	; 
	N DAY,MON 
	I '$D(v) Q $ZD(+$H)                                                  ;NG 
	I 'v Q "" 
	I $G(msk)="" Q $ZD(+v) 
	S DAY=$G(%DAY),MON=$G(%MON) 
	; 
	I $G(msk)'="" D 
	. ;I msk["MON" S MON=$G(%MS) 
	. I msk["MON" S MON="" 
	. I msk["DAY" S DAY=$G(%DS) 
	. I msk["ML" D:'$D(%ML) INIT^%ZM() S msk=$P(msk,"ML",1)_"MON"_$P(msk,"ML",2),MON=$G(%ML) 
	. I msk["MS" D:'$D(%MS) INIT^%ZM() S msk=$P(msk,"MS",1)_"MON"_$P(msk,"MS",2),MON=$G(%MS) 
	. I msk["DL" D:'$D(%DL) INIT^%ZM() S msk=$P(msk,"DL",1)_"DAY"_$P(msk,"DL",2),DAY=$G(%DL) 
	. I msk["DS" D:'$D(%DS) INIT^%ZM() S msk=$P(msk,"DS",1)_"DAY"_$P(msk,"DS",2),DAY=$G(%DS) 
	E  s msk="MM/DD/YY",MON="",DAY="" 
	; 
	I msk["YY",v<21550!(v>58073) S msk=$P(msk,"YY",1)_"YEAR"_$P(msk,"YY",2) 
	;Q $ZD(v,msk,MON,DAY) 
	Q $ZD(+$H) 
	; 
	;--------------------------------------------------------------------- 
TIM(v,msk)	; Time mask - 24:00
	;--------------------------------------------------------------------- 
	; 
	I $G(msk)="" s msk=$G(%MSKC) 
	I $D(v),v<1 Q "" 
	I '$D(v) S v=$P($H,",",2) 
	; 
	I $G(msk)="" S msk="12:60 AM" 
	Q $ZD(","_v,msk) 
	; 
	;--------------------------------------------------------------------- 
UPC(v)	; Uppercase
	;--------------------------------------------------------------------- 
	; 
	Q $TR(v,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ") 
	; 
	;--------------------------------------------------------------------- 
PIC(v,msk)	; Picture Mask  - (XXX) XXX-XXXX
	;--------------------------------------------------------------------- 
	; 
	Q "" 
	; Not implemented 
	; 
	;--------------------------------------------------------------------- 
LOG(v,msk)	; Logic Mask  - NY
	;--------------------------------------------------------------------- 
	; 
	I $G(msk)="" S msk=$G(%MSKL) 
	I $G(msk)="" Q $S(v:"Y",1:"N") 
	; 
	Q $S(v:$E(msk,2),1:$E(msk)) 
	; 
	;---------------------------------------------------------------------- 
CTR(v,len)	; Center Value in field 
	;---------------------------------------------------------------------- 
	; 
	S v=$J("",len-$L(v)\2)_v 
	Q v_$J("",len-$L(v)) 
	; 
	;---------------------------------------------------------------------- 
SGN(v)	; Signed Field Edit Mask 
	;---------------------------------------------------------------------- 
	; 
	N LNUM 
	; 
	S LNUM=$E(v,$L(v)) 
	I v'["-" S v=$E(v,1,$L(v)-1)_$TR(LNUM,"0123456789","{ABCDEFGHI") Q v 
	S v=$E(v,1,$L(v)-1)_$TR(LNUM,"0123456789","}JKLMNOPQR") 
	S v=$P(v,"-",1)_"0"_$P(v,"-",2) 
	Q v 
	; 
	;---------------------------------------------------------------------- 
ILOG(X,msk)	; Logic Conversion to internal 
	;---------------------------------------------------------------------- 
	; 
	I X=0!(X=1) Q "" 
	; 
	I $A(X)>96 S X=$C($A(X)-32) ; 		Convert to Upper case
	; 
	I $G(msk)="" S msk="NYFT" 
	I msk'[X Q 1  ; 				Error, no match
	S X=$F(msk,X)#2 ;				Convert to 0 or 1
	Q "" 
	; 
	;---------------------------------------------------------------------- 
INUM(X,msk,dec)	; Internal format conversion for numeric and currency 
	;---------------------------------------------------------------------- 
	; 
	I X?.N Q "" 
	I X?1A.AN Q "" ; 		*****	For Alpha PP
	I X?1N.N1"-".E Q "" ; 		*****   For TAXId PP
	; 
	I $G(msk)="" S msk="." ; 		Decimal Separator only
	; 
	I "."'[$E(msk) S X=$TR(X,$E(msk),".") ; 	Change Decimal Character
	I $L(msk)=2 N I,z S z=$L($P(X,".",1)) F I=z-3:-4:0 I $E(X,I)=$E(msk,2) S X=$E(X,1,I-1)_$E(X,I+1,$L(X)) 
	; 
	I X?.N!(X?.N1".".1N.N)!(X?1"-".N)!(X?1"-".N1"."1N.N) Q "" 
	I $TR(X,".-","")'?.N S X=$$MATH(X) I X="" Q 1 
	I X?.N!(X?.N1".".1N.N)!(X?1"-".N)!(X?1"-".N1"."1N.N) Q "" 
	Q 1 
	; 
	;---------------------------------------------------------------------- 
MATH(X,dec)	; Calculate Math 
	;---------------------------------------------------------------------- 
	; 
	;I $$NEW^%ZT N $ZT 
	;S @$$SET^%ZT("MATHERR^%ZM") 
	; 
	N C,I,J,Y,Z 
	S Y=0,Z="H100,K1000,M1000000" 
	; 
	F I=1:1:$L(Z,",") S C=$E($P(Z,",",I)),M=$E($P(Z,",",I),2,99) DO 
	. F  S Y=$F(X,C,Y) Q:Y=0  DO
	.. F J=Y-2:-1:0 Q:$E(X,J)?1N=0  ;			Not a number
	.. S X=$E(X,1,J)_"("_$E(X,J+1,Y-2)_"*"_M_")"_$E(X,Y,$L(X))
	; 
	I X'?.N S X="V+("_X_")" 
	X "S X="_X 
	; 
	I $G(dec) Q $J(X,0,dec) 
	Q X 
	; 
MATHERR	Q "" 
	; 
	;---------------------------------------------------------------------- 
INIT(list)	; Initialize %MSK* Variables and add to the list 
	;---------------------------------------------------------------------- 
	; 
	N N,z,v 
	; 
	F N="$","N","D","C","L" S z=^DBCTL("SYS","DVFM",N) DO 
	. ;
	. S v="%MSK"_$TR(N,"$","E") ;		Translate $ - E
	. S @v=$P(z,"|",6)
	.       D LIST 
	; 
	;----------------------------------------------------------------------- 
	; Month and day tables for $ZD(A,%MSKD,%MON,%DAY) syntax 
	;----------------------------------------------------------------------- 
	; 
	F N="MS","ML","DS","DL" S @("%"_N)=$G(^DBCTL("SYS","DVFM","D",N)) 
	S %MON=%MS,%DAY=%DS 
	I %MSKD["ML" S %MSKD=$P(%MSKD,"ML",1)_"MON"_$P(%MSKD,"ML",2),%MON=%ML 
	I %MSKD["MS" S %MSKD=$P(%MSKD,"MS",1)_"MON"_$P(%MSKD,"MS",2),%MON=%MS 
	I %MSKD["DL" S %MSKD=$P(%MSKD,"DL",1)_"DAY"_$P(%MSKD,"DL",2),%DAY=%DL 
	I %MSKD["DS" S %MSKD=$P(%MSKD,"DS",1)_"DAY"_$P(%MSKD,"DS",2),%DAY=%DS 
	F v="%MON","%DAY","%MS","%ML","%DS","%DL" ; D LIST 
	; 
	I $E($G(list))="," S list=$E(list,2,$L(list)) 
	Q 
LIST	I $D(list) S list=list_","_v Q                         ;NG 
	Q 
	Q 
	; 
	;---------------------------------------------------------------------- 
PATNUM(v,dec,msk,patmsk)	; Patch numeric mask 
	;---------------------------------------------------------------------- 
	; 
	N i 
	F i=1:1:$L(patmsk) I $E(patmsk,i)'="%" S msk=$E(msk,1,i-1)_$E(patmsk,i)_$E(msk,i+1,999) 
	Q $$NUM(v,dec,msk) 
