RCMP	;;SCA - UTL - V4.1 - MUMPS portion of RCMP.COM
	;;Copyright(c)1990 Sanchez Computer Associates, Inc.  All Rights Reserved -  6 FEB 1990 15:02:38 - RUSSELL
	;     ORIG:  RUSSELL - 29 JAN 1990
	;CALLED BY:  
	;    CALLS:  
	;     DESC:  Provide list of routines to compare between two
	;            directories.
	;
	;            Get direct input in $ZCMDLINE
	;            Parse for DIR1|DIR2|P3|IGNORE_FILE
	;                 DIR1 = directory 1
	;                 DIR2 = directory 2
	;                 P3 - routine list if not to prompt
	;                 IGNORE FILE - list of routines to ignore
	;            Output list to file:  SYS$LOGIN:RCMP_pid.TMP
	;
	;            Routines may be entered by RTNNAME or RTN*.  No ranges.
	;
	; GLOBALS -
	;     READ:  
	;      SET:  
	;
	;    INPUT:  
	;   OUTPUT:  
	;
	;EXT ENTRY:  
	;
	S PID=$$DECHEX($J)
	S OUTFILE="SYS$LOGIN:RCMP_"_PID_".TMP"
	O OUTFILE:(NEWV:WRITE)
	;
	S X=$TR($ZCMDLINE,"""")
	S DIR1=$P(X,"|",1),DIR2=$P(X,"|",2)
	S P3=$P(X,"|",3),IGNORE=$P(X,"|",4)
	;
	F I="DIR1","DIR2" I @I="" U OUTFILE W I," is null" G END
	;
	S X=$E(DIR1,$L(DIR1)) I '(X=":"!(X="]")) S DIR1=DIR1_":"
	S X=$E(DIR2,$L(DIR2)) I '(X=":"!(X="]")) S DIR2=DIR2_":"
	;
	I IGNORE'="" D IGNORE ; Build ignore list
	I P3'="" D P3
	I P3="" F  U 0 R !,"Routine:  ",RTN Q:RTN=""  D RTN
	U OUTFILE
	S N=""
	F  S N=$O(SELECT(N)) Q:N=""  W N,!
	;
END	C OUTFILE
	Q
	;
RTN	; Build routine list
	S RTN=$$UPCASE(RTN)
	Q:RTN=""
	I RTN?1"'".E D DELRTNS Q
	S FILE=DIR1_RTN_".M",STRM=1 D SEARCH
	S FILE=DIR2_RTN_".M",STRM=2 D SEARCH
	Q
	;
SEARCH	F  S X=$ZSEARCH(FILE,STRM) Q:X=""  D CHK
	Q
	;
CHK	; See if should select or ignore
	S SEL=$P($P(X,".M;",1),"]",2)
	I $D(IGNORE(SEL)) Q  ; Ignore it
	S OK=1
	F I=1:1:$L(SEL) S Y=$E(SEL,1,I)_"*" I $D(IGNORE(Y)) S OK=0 Q
	I 'OK Q  ; Ignore
	S SELECT(SEL)="" ; Select it
	Q
	;
DELRTNS	; Delete routines selected, e.g. 'ABC
	I RTN="*" K SELECT Q
	S X=$P($E(RTN,2,99),"*",1),L=$L(X),N=X
	K SELECT(N)
	Q:RTN'?.E1"*"
	F  S N=$O(SELECT(N)) Q:$E(N,1,L)'=X  K SELECT(N)
	Q
	;
IGNORE	; Build ignore list
	O IGNORE:(READ:EXC="G IGNEND")
	U IGNORE:EXC="G IGNEND"
	F  R X S IGNORE($$UPCASE(X))=""
IGNEND	C IGNORE
	Q
	;
P3	; Parse routine input list
	F NXT=1:1:$L(P3,",") S RTN=$P(P3,",",NXT) D RTN
	Q
	;
UPCASE(X)	;
	Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	;
DECHEX(DEC)	; Extrinsic function to convert decimal to hex
	; Call by S HEX=$$DECHEX^%ZHEX(DEC) to return HEX equivalent of DEC
	;
	N HEX S HEX=""
	F  Q:'DEC  S HEX=$E("0123456789ABCDEF",DEC#16+1)_HEX,DEC=DEC\16
	Q HEX
