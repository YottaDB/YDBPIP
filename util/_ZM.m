%ZM	;LIBRARY;Data-Type Format masks
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/29/02 16:03:56 - CHENARDP
	; ORIG: FSANCHEZ   07 - NOV - 1991
	;
	; Library of format mask subroutines
	;
	; LIBRARY:
	;     	. NUM	External Numeric Display
 	;	. DAT	External Data Display
	;	. TIM	External Time Display
 	;	. LOG	External Logic Display
	;	. PIC	External Picture Display 
	;	. CTR	Center Value in Field
	;	. FDAT	External to Internal Date Filter
	;	. FCUR	External to Internal Currency Filter
	;	. FNUM	External to Internal Number Filter
	;	. FTIM	External to Internal Time Filter
	;	. FLOG	External to Internal Logical Filter
	;	. FUPC	External to Internal Uppercase
	;
	;---- Revision History ------------------------------------------------
	;
	; 01/28/02 - Pete Chenard - 48770
	;	     Modified FCUR section to correct a problem when the
	;	     currency mask is defined as a single character other than
	;	     ".".  In cases where it was defined as a single char, such
	;	     as ",", the code was appending another "," to it, which
	;	     caused problems.
	;
	; 02/14/01 - Harsha Lakshmikantha - 43184
	;	     Modified FCUR section to support Indian currency format.
	;	     Prior to this change the function worked only if the
	;	     thousand delimiter was placed after every 3 digits.
	;
	; 02/02/01 - Harsha Lakshmikantha - 43184
	;	     Modified NUM section to support Indian currency format. A
	;	     byte 5 is added to the mask. A value of 1 for byte 5 
	;	     denotes India format. 
	;
	; 06/28/00 - SHANL - 40674
	;            Modified the FCUR section to support Netherlands currency 
	;	     input which is with a dot to separate the thousands and 
	;	     a coma to separate the decimals when the currency format 
	;	     edit mask is set up as Netherlands format.   
	;
	; 01/26/00 - Chiang - 36803
	;            Modified TIM section to return 0 second (internal value)
	;            as 12:00 AM (external format).
	;
	; 03/09/99 - SPIER - 31754
	;            Removed the change from 2/10/98 dealing with defaulting
	;	     CUVAR(2) rather then $H. Versions v5.3 and above will
	;	     not allow calls to this label without a parameter (through
	;	     automated code review). The old $H value is still correct
	;	     for existing code in lower versions.
	;
	; 02/12/99 - SPIER - 31754
	;            Corrected error frm recent change, default of cuvar or $h
	;	     should occur only when v is not defined coming into the
	;	     DAT label.
	;
	; 02/10/98 - Judy Motson - 31754
        ;	     Removed line I msk["YY",v<21550!(v>58073) S
	;	     msk=$P(msk,"YY",1)_"YEAR"_$P(msk,"YY",2) in 
	;	     DAT section which printed four digit year 
	;            if year was greater then 2000.  Should be controlled
	;	     by Mask instead and not forced to have four digit year
	;            Also changed +$H if v not defined to ^CUVAR(2) in
	;	     DAT section
	;
	; 02/08/95 - Bob Chiang - i18n
	;            Modified DAT section to support DL,DS,ML,MS date format as
	;            part of I18N project.
	;
	;            Example: $$DAT^%ZM(,"DS") returns Fri
	;                     $$DAT^%ZM(,"DL") returns Friday
	;                     $$DAT^%ZM(,"ML") returns February
	;                     $$DAT^%ZM(,"MS") returns Feb
	;
	;----------------------------------------------------------------------
EXT(v,fmt,dec)	;Public; Format string for external display
	;----------------------------------------------------------------------
	; Returns an externally formatted string using the default
	; masks %MSKC,%MSKD,%MSKE,%MSKL,%MSKN for fmt types (C,D,$,L,N)
	; respectively.
	; 
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. v	Internal Value			/REQ
	;	. fmt	Format Type			/REQ
	;		(TUFL$NDC) or [DBCTLRFMT]
	;	. dec	Decimal Precision		/NOREQ/TYP=N
	;
	; RETURNS:
	;	. $$	Externally Formatted Output
	;
        I "TUF"[fmt Q v				; Text, Uppercase, Frequency
        I fmt="L" Q $$LOG(v,$G(%MSKL))
        I fmt="$" Q $$NUM(v,.dec,$G(%MSKE))
        I fmt="N" Q $$NUM(v,.dec,$G(%MSKN))
        I fmt="D" Q $$DAT(v,$G(%MSKD))
        I fmt="C" Q $$TIM(v,$G(%MSKC))
	;
        I $D(vfmt(fmt)) S z=vfmt(fmt)
        E  S z=$$fmt^DBSEXEP(fmt,"v",dec),vfmt(fmt)=z
        I z'="" X "S v="_z
        Q v
	;
	;---------------------------------------------------------------------
NUM(v,dec,msk)	;Public; Format Numbers
	;---------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value			/TYP=N/REQ
	;	. dec	Decimal Precision		/TYP=N/NOREQ
	;	. msk	Format Mask			/TYP=T/NOREQ
	;
	;		Byte 1 - Decimal Delimiter	/DFT="."
	;		Byte 2 - Thousand Delimiter	/DFT=","
	;		Byte 3 - Negative Option	/DFT=L
	;		  L = Leading
	;		  T = Trailing
	;		  P = Parantheses
	;		  - = Suppress
	;		Byte 4 - Leading Character	/DFT=""
	;		Byte 5 - Country format code 	/DFT=""
	;		  1 = India
	;	
	; RETURNS:
	;	. $$	Formatted Number
	;
	; EXAMPLES:
	;
	; W $$NUM^%ZM(123456,2)
	; 123456.00
	;
	; W $$NUM^%ZM(123456,2,",.")		; European Format
	; 123.456,00
	;
	; W $$NUM^%ZM(-123456,2,".,P")		; US Format - Neg Parentheses
	; (123,456.00)
	;
	; W $$NUM^%ZM(-123456,2,".,  1")	; India Format
	; 1,23,456.00
	;---------------------------------------------------------------------
	;
	S dec=$G(dec)
	S msk=$G(msk)
	;
	I v="",'dec Q ""
	;
	I "."[msk Q $J(v,0,dec)
	;
	N len,vm,vf,x,xd,y,z
	;
	S vf=""
	S vm=$E(msk)					; Replace Decimal
	I $TR($E(msk,3)," ","")'="" S vf=$E(msk,3) S:vf="L" vf=""	; Negative Number
	I 9'[$E(msk,2) S vf=vf_",",vm=vm_$E(msk,2)	; Replace thousand sep
	;
	I vf'="" S v=$TR($FN(v,vf,+dec),".,",vm)
	E  I vm'="." S v=$TR($J(v,0,+dec),".",vm)
	;
	I $E(msk,5)=1 D
	.	S z=$E(msk)
	.	S x=$P(v,z,1)
	.	S y=$P(v,z,2)
	.	S x=$TR(x,$E(msk,2),"")
	.	I x>99999 D
	..		S len=$L(x),xd=$E(x,len-2,len)
	..		S len=len-2 I len<2 S xd=$E(x,1,len-3)_xd
	..		F  S xd=$E(x,len-2,len-1)_","_xd,len=len-2 Q:len<2
	..		S v=xd_z_y
	;
	I $TR($E(msk,4)," ","")'="" S v=$E(msk,4)_v
	Q v
	;
	;---------------------------------------------------------------------
DAT(v,msk,lmon,lday)	;Public; Format Date for External Display
	;---------------------------------------------------------------------
	; Convert a date value (Julian number) into a formatted date string.  
	; Note, the 'v' argument is required from a Programming Standards 
	; perspective.  If not passed, value will default to either the current
	; system date within the application or if that is not defined, the 
	; current calendar date.
	;
	; KEYWORDS:	Date and Time, Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value			/TYP=N/REQ/DFT=^CUVAR(2)
	;	. msk	Format Mask			/DFT=%MSKD
	;	. lmon	List of Months (Jan,Feb,...)	/NOREQ/DEL=44/DFT=%MON
	;	. lday	List of Days (Sun,Mon,...)	/NOREQ/DEL=44/DFT=%DAY
	;
	; INPUTS:
	;	. %MSKD	Date Mask (Environmental)	/NOREQ/DFT="DD/MM/YY"
	;	   DD = Date within Month (01 - 31)
	;	   DAY= Use Date String in lday or %DAY
	;	   MM = Month within Year (01 - 12)
	;	   MON= Use Month String in lmon or %MON
	;	   YY = 2 Character Year, eg. 93, 94, ...
	;	   YEAR = 4 Character Year, eg. 1993, 1994, ...
	;
	;	. %MON	Month(s) String (eg. Jan,Feb,...)	/NOREQ
	;	. %DAY	Day(s) String (eg. Mon,Tue,...)		/NOREQ
	;
	; RETURNS:
	;	. $$	Formatted Date
	;
	; EXAMPLES:
	;
	; W $$DAT^%ZM(56004,"DD/MM/YY")
	; 05/02/94
	;
	; W $$DAT^%ZM(56004,"YEAR/MM/DD")
	; 1994/05/02
	;---------------------------------------------------------------------
	;
	N fmt
	I '$D(v)  S v=+$H		;3/9/99 mas
	I 'v Q ""
	;
	I $G(msk)="" S msk=$G(%MSKD) I msk="" s msk="MM/DD/YY"
	;					; *** 02/08/96
	I msk="DL"!(msk="DS") D	; Long or short name
	.	S fmt=$G(^DBCTL("SYS","DVFM"))	; Country code
	.	I fmt="" S fmt="US"		; Week definition
	.	I $G(lday)="" S lday=$G(^DBCTL("SYS","*DVFM",fmt,"D",msk))
	.	S msk="DAY"			; Day of the week
	I msk="ML"!(msk="MS") D			; Long or short name
	.	S fmt=$G(^DBCTL("SYS","DVFM"))	; Country code
	.	I fmt="" S fmt="US"		; Month definition
	.	I $G(lmon)="" S lmon=$G(^DBCTL("SYS","*DVFM",fmt,"D",msk))
	.	S msk="MON"			; Month of the year
	;					; ***
	Q $ZD(v,msk,$G(lmon),$G(lday))
	;
	;---------------------------------------------------------------------
TIM(v,msk)	;Public; Format Time for External Display
	;---------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time, Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value			/TYP=C/DFT=$H
	;	. msk	Format Mask			/DFT=%MSKC
	;
	; INPUTS:
	;	. %MSKC	Time Mask (Environmental)	NOREQ/DFT="12:60 AM"
	;
	; RETURNS:
	;	. $$	Formatted Number
	;
	; EXAMPLES:
	;
	; W $$TIM^%ZM(61919)
	; 05:11 PM
	;
	; W $$TIM^%ZM(61919,"24:60")
	; 17:11
	;---------------------------------------------------------------------
	;
	I $G(msk)="" s msk=$G(%MSKC)
	I $D(v),v="" Q ""			; Return NULL value 01/26/2000 BC
	I '$D(v) S v=$P($H,",",2)		; Defualt to current time
	;
	I $G(msk)="" S msk="12:60 AM"		; Default time display mask
	Q $ZD(","_v,msk)	
	;
	;---------------------------------------------------------------------
PIC(v,msk)	;Public; Format Picture Mask - (XXX) XXX-XXXX
	;---------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value
	;	. msk	Format Mask
	;
	; RETURNS:
	;	. $$	Formatted Picture
	;
	; EXAMPLES:
	;
	Q ""
	; Not implemented
	;
	;---------------------------------------------------------------------
LOG(v,msk)	;Public; Format Logical
	;---------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value			/TYP=N
	;	. msk	Format Mask			/DFT=%MSKL
	;
	;		Byte 1 = 0 Display
	;		Byte 2 = 1 Display
	;
	; INPUTS:
	;	. %MSKL	Logical Mask (Environmental)	NOREQ/DFT="YN"
	;
	; RETURNS:
	;	. $$	Formatted Logical
	;
	; EXAMPLES:
	;
	; W $$LOG^%ZM(0,"XY")
	; X
	;
	; W $$LOG^%ZM(1,"XY")
	; Y
	;---------------------------------------------------------------------
	;
	I $G(msk)="" S msk=$G(%MSKL) I $G(msk)="" Q $S(v:"Y",1:"N")
	;
	Q $S(v:$E(msk,2),1:$E(msk))
	;
	;----------------------------------------------------------------------
CTR(v,len)	;Public; Format Value in Center of Field
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value	
	;	. len	Field Length			/TYP=N
	;
	; RETURNS:
	;	. $$	Formatted Number
	;
	S v=$J("",len-$L(v)\2)_v
	Q v_$J("",len-$L(v))
	;
	;----------------------------------------------------------------------
SGN(v)	;Public; Signed Field Edit Mask
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. v	Input Value			/TYP=N
	;
	; RETURNS:
	;	. $$	Formatted Number
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
INT(X,typ,msk,dec)	;Public; Convert External Data to Internal Format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. X	Input String			/REQ/MECH=VAL
	;	. typ	Data Type (TUFL$NDC)		/REQ
	;	. msk	Format Mask			/NOREQ
	;	. dec	Decimal Precision		/NOREQ
	;
	; RETURNS:
	;	. $$	Return transformed X
	;	. ER	Error Flag (Set if unable to transform)
	;
        I typ="L" Q $$FLOG(X,.msk)
        I typ="N" Q $$FNUM(X,.msk,.dec)		; *** 06/08/95 BC
        I typ="$" Q $$FCUR(X,.msk,.dec)
        I X="" Q ""
        I typ="U" Q $$UPPER^%ZFUNC(X)
        I typ="D" Q $$FDAT(X,.msk)
        I typ="C" Q $$FTIM(X,.msk)
        Q X
	;
	;----------------------------------------------------------------------
FLOG(X,msk)	;Public; Convert Logical to Internal Format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. X	External Value			/TYP=N/MECH=REF:RW
	;	. msk	Format Mask
	;		Byte 1,3,5,...	Proxy Character's for 0
	;		Byte 2,4,6,...	Proxy Character's for 1
	;
	; RETURNS:
	;	. $$	Internal value of X
	;	. ER	ER=1 if Unable to Transform
	;
	I $A(X)>96 S X=$C($A(X)-32) 			; Convert to Upper case
	;
	I X=0!(X=1) Q X					; Always use 0 or 1 value
	I $G(msk)="" S msk=$G(%MSKL) I msk="" S msk="NYFT01"
	I msk'[X S ER=1 Q X  				; Error, no match
	I X="" Q 0
	Q $F(msk,X)#2					; Convert to 0 or 1
	;
	;----------------------------------------------------------------------
FNUM(X,msk,dec)	;Public; Convert Numeric Internal format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. X	External Value			/TYP=N/MECH=REF:RW
	;	. msk	Format Mask
	;	. dec	Decimal Precision for MATH	/TYP=N
	;		See Documentation for $$NUM^%ZM
	;
	; RETURNS:
	;	. $$	Internal value of X
	;	. ER	ER=1 if Unable to Transform
	;
	; Do not process if alpha lookup, allow math such as 1K usage to continue
	I X?1A Q X                              ; For alpha
	I X?1.E1A.E,X'?.N1A1.N.E,X'?.N1"H",X'?.N1"K",X'?.N1"M" Q X ;***** For Alpha PP
	I X?1N.N1"-".E Q X			; *****   For TAXId PP
	I X?1A1"-".E Q X			; A-,M-,C-,S- lookups		;1/9/96 mas
	I $E(X)="*" Q X				; Converted account 		;1/9/96 mas
	;
	I $G(msk)="" S msk=$G(%MSKN) I msk="" S msk="." ; Decimal Separator
	I "."'[$E(msk) S X=$TR(X,$E(msk),".") 		; Change Decimal Character
	;
	I $TR(X,".-","")'?.N S X=$$MATH(X,.dec) I X="" S ER=1 ; *** 06/08/95
	I '(X?.N!(X?.N1".".1N.N)!(X?1"-".N)!(X?1"-".N1"."1N.N)) S ER=1
	Q +X
	;
	;----------------------------------------------------------------------
FCUR(X,msk,dec)	;Public; Convert Currency to Internal format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. X	External Value			/TYP=N/MECH=REF:RW
	;	. msk	Format Mask
	;		See Documentation for $$NUM^%ZM
	;	. dec	Decimal Precision for MATH	/TYP=N
	;
	; RETURNS:
	;	. $$	Internal value of X
	;	. ER	ER=1 if Unable to Transform
	;
	I $G(msk)="" S msk=$G(%MSKE) I msk="" S msk="." ; Decimal Separator ; 06/28/00 shanl
	;
	I $L(msk)=1,msk'="," S msk=msk_","        ; "," is the default for 1000 separator
	E  I $L(msk)=1 S msk=msk_" "  ;pc 2/28/02 - If msk len is 1 and it is a "," use
	;  					    a different character for the 1000's 
	;					    separator.  Can't use "," for both dec 
	;					    and 1000's separator.
	;
	I X[$E(msk,2) S X=$TR(X,$E(msk,2),"")
	;
	I "."'[$E(msk) S X=$TR(X,$E(msk),".")   ; Change Decimal Character
        I X=+X Q X
	;
	I $TR(X,".-","")'?.N S X=$$MATH(X,.dec) I X="" S ER=1
	I '(X?.N!(X?.N1".".1N.N)!(X?1"-".N)!(X?1"-".N1"."1N.N)) S ER=1 
	Q +X
	;
	;----------------------------------------------------------------------
MATH(X,dec)	; Calculate Math
	;----------------------------------------------------------------------
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("MATHERR^%ZM")
	;
	N C,I,J,Y,Z
	S Y=0,Z="H100,K1000,M1000000"
	;
	F I=1:1:$L(Z,",") S C=$E($P(Z,",",I)),M=$E($P(Z,",",I),2,99) D
	.	F  S Y=$F(X,C,Y) Q:Y=0  D
	..	F J=Y-2:-1:0 Q:$TR($E(X,J),"+-.0123456789","")'=""
	..	S X=$E(X,1,J)_"+("_$E(X,J+1,Y-2)_"*"_M_")"_$E(X,Y,$L(X))
	;
	X "S X="_X
	;
	I $G(dec) Q $J(X,0,dec)
	Q X
	;
MATHERR Q ""
	;
	;----------------------------------------------------------------------
FTIM(X,msk)	;Public; Convert Time to Internal format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time, Formatting
	;
	; ARGUMENTS:
	;	. X	External Value			/TYP=N/MECH=REF:RW
	;	. msk	Format Mask (Not Enabled)
	;
	; RETURNS:
	;	. $$	Internal value of X
	;	. ER	ER=1 if Unable to Transform
	;
	I $G(msk)="" S msk=$G(%MSKC)
	;
	N %TS,%TN
        S %TS=X D ^SCATIM
	I %TN<0 S ER=1
	Q %TN
	;
	;----------------------------------------------------------------------
FDAT(X,msk)	;Public; Convert Date to Internal format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time, Formatting
	;
	; ARGUMENTS:
	;	. X	External Value			/TYP=N/MECH=REF:RW
	;	. msk	Format Mask
	;
	; RETURNS:
	;	. $$	Internal value of X
	;	. ER	ER=1 if Unable to Transform
	;
	I $G(msk)="" S msk=$G(%MSKD)
        S X=$$^SCAJD(X,msk)
	I X<0 S ER=1
	Q X
	;
	;---------------------------------------------------------------------
FUPC(X)	;Public; Format Uppercase
	;---------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. X	Input String
	;
	; RETURNS:
	;	. $$ 	Uppercase Output
	;
	; EXAMPLES:
	;
	Q $$UPPER^%ZFUNC(X)
	;
	;----------------------------------------------------------------------
INIT(list)	; Initialize %MSK* Variables and add to the list
	;----------------------------------------------------------------------
	;
	N N,z,v
	;
	F N="$","N","D","C","L" S z=^DBCTL("SYS","DVFM",N) DO
	.	;
	.	S v="%MSK"_$TR(N,"$","E") ;		Translate $ - E
	.	S @v=$P(z,"|",6)
	.       D LIST
	;
	;-----------------------------------------------------------------------
	; Month and day tables for $ZD(A,%MSKD,%MON,%DAY) syntax
	;-----------------------------------------------------------------------
	;
	F N="MS","ML" I %MSKD[N D  Q
	.	;
	.	S %MON=$G(^DBCTL("SYS","DVFM","D",N))
	.	S %MSKD=$P(%MSKD,N,1)_"MON"_$P(%MSKD,N,2)
	.	I $D(list) S list=list_",%MON"
	;
	F N="DS","DL" I %MSKD[N D  Q
	.	;
	.	S %DAY=$G(^DBCTL("SYS","DVFM","D",N))
	.	S %MSKD=$P(%MSKD,N,1)_"DAY"_$P(%MSKD,N,2)
	.	I $D(list) S list=list_",%DAY"
	Q
LIST	I $D(list) S list=list_","_v Q
	Q
	;
	;----------------------------------------------------------------------
PATNUM(v,dec,msk,patmsk)	; Patch numeric mask
	;----------------------------------------------------------------------
	;
	N i
	F i=1:1:$L(patmsk) I $E(patmsk,i)'="%" S msk=$E(msk,1,i-1)_$E(patmsk,i)_$E(msk,i+1,999)
	Q $$NUM(v,dec,msk)
	;
	;----------------------------------------------------------------------
INUM(X,msk,dec)	; Obselete External to Internal Number Filter
	;----------------------------------------------------------------------
	;
	I $G(TYP)="$" S X=$$FCUR(X,msk,.dec) Q $G(ER)
	S X=$$FNUM(X,msk) Q $G(ER)
	;
	;----------------------------------------------------------------------
ILOG(X,msk)	; Obselete External to Internal Logical Filter
	;----------------------------------------------------------------------
	;
	S X=$$FLOG(X,msk) Q $G(ER)
