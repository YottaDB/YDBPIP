%ZD(JD,FMT)	;M Utility;$ZD equivalent for GT.M
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:38:29 - SYSRUSSELL
	; ORIG:  RUSSELL - 19 DEC 1989
	;
	; DATE:  Return date in M/VX $ZD format.
	;
	;        If JD not defined, return current system date
	;
	;        $$^%ZD or $$^%ZD()
	;
	;        If JD<1, returns null
	;        In 1800's, return MM/DD/YYYY
	;        In 1900's, return MM/DD/YY
	;        In 2000's, return MM/DD/YYYY
	;
	;        Call by S X=$$^%ZD(jd)
	;
	; TIME:  Return time in HH:MM AM/PM or HH:MM:SS AM/PM format.
	; 
	;        $$TIME^%ZD        return current time HH:MM AM/PM
	;        $$TIME^%ZD("",1)  return current time HH:MM:SS
	;
	;        TIME(12345)       return  3:25 AM
	;        TIME(12345,1)     return  3:25:45 AM
	;        TIME(40000)       return 11:06 AM
	;
	;        Call by  $$TIME^%ZD(N) or $$TIME^%ZD(N,1)
	;
	; KEYWORDS:	Date and Time
	;
	I '$D(JD) Q $ZD(+$H)
	;
	I JD<1 Q ""
	;
	I $G(FMT)'="" Q $ZD(JD,FMT)
	;
	I JD>21549,JD<58074 Q $ZD(JD) ; 1900's
	Q $ZD(JD,"MM/DD/YEAR") ; 1800's or 2000's
	;
	;----------------------------------------------------------------------
MONTH(JD)	;M Utility;Return $ZD month
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time
	;
	Q +$ZD(JD,"MM")
	;----------------------------------------------------------------------
DAY(JD)		;M Utility;Return $ZD day
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time
	;
	Q +$ZD(JD,"DD")
	;----------------------------------------------------------------------
YEAR(JD)	;M Utility;Return $ZD year
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time
	;
	Q +$ZD(JD,"YEAR")
	;
	;----------------------------------------------------------------------
TIME(%TN,TIMOPT)	;M Utility;Return time in HH:MM or HH:MM:SS AM/PM format
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Date and Time
	;
	;
	N %M,%N,%I,%TS
	;
	I $G(%TN)="" S %TN=$P($H,",",2) ; current system time
	;
	I %TN'>0!(%TN>86400) Q "        "
	S %M=%TN\60,%N=" AM" S:%M'<720 %M=%M-720,%N=" PM" S:%M<60 %M=%M+720
	S %I=%M\600 S:'%I %I=" " S %TS=%I_(%M\60#10)_":"_(%M#60\10)_(%M#10)
	I '$G(TIMOPT) Q %TS_%N
	Q %TS_":"_(%TN#60)_%N
