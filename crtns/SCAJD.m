 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCAJD ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCAJD(STRING,MASK) ; SCA Julian Date Conversion
 ;
 N %MLIST,ALPHA,DAY,DE,DN,DS,ME,MONTH,MS,ORDER,YE,YEAR,YS
 ;
 I '$D(MASK) S MASK="MM/DD/YY"
 S ER=0
 D CONVERT
 ;
 Q DN
 ;
CONVERT ; Converts String date into Julian format
 ;
 ; Returned
 S DN=-1
 ;
 ; Nulls are disallowed
 ;
 I STRING="" D ERR Q 
 I $get(MASK)="" D GETMASK
 I $get(%MLIST)="" D GETMASK
 ;
 ; No alpha characters, yet.
 S ALPHA=0
 ;
 ; Lowercase
 I STRING?.E1L.E S STRING=$ZCONVERT(STRING,"U")
 I STRING="T" D TODAY Q 
 I STRING?1"T"1P1N.N D TODAY Q 
 I STRING="C" D CALENDAR Q 
 I STRING?1"C"1P1N.N D CALENDAR Q 
 ;
 ; Contains alpha characters
 I STRING?.E1U.E D HASALPHA D VALIDATE Q 
 ;
 ; Has punctuation characters
 I STRING?.E1P.E D HASPUNC D VALIDATE Q 
 ;
 ; All numeric with 2 digit year
 I STRING?6N D ALLNUM D VALIDATE Q 
 ;
 ; All numeric with 4 digit year
 I STRING?8N D ALLNUM D VALIDATE Q 
 ;
 ; Already Julian
 I STRING?1.5N S DN=STRING Q 
 ;
 ; Use default mask
 D USEMASK(MASK)
 D VALIDATE
 ;
 Q 
 ;
ALLNUM ; All Numeric
 ;
 N I,J,K,ORDER
 ;
 D PARSEMASK(MASK,.YS,.YE,.MS,.ME,.DS,.DE)
 I YS S ORDER(YS)=""
 I MS S ORDER(MS)=""
 I DS S ORDER(DS)=""
 ;
 S (YEAR,MONTH,DAY)=""
 S J=""
 S K=1
 F I=1:1:3 D AllN1 Q:J="" 
 ;
 Q 
 ;
AllN1 ; Determine which piece we've got
 ;
 S J=$order(ORDER(J)) Q:J="" 
 I J'=MS D  Q 
 .	I J'=DS D  Q 
 ..		N YL
 ..		;
 ..		I $L(STRING)=6 S YL=2
 ..		E  S YL=4
 ..		S YEAR=$E(STRING,K,K+YL-1)
 ..		S K=K+YL
 ..		Q 
 .	;
 .	S DAY=$E(STRING,K,K+1)
 .	S K=K+$L(DAY)
 .	Q 
 S MONTH=$E(STRING,K,K+1)
 S K=K+$L(MONTH)
 ;
 Q 
 ;
USEMASK(MASK) ; Input does not use Default Format
 ;
 D PARSEMASK(MASK,.YS,.YE,.MS,.ME,.DS,.DE)
 S YEAR=$E(STRING,YS,YE)
 S MONTH=$E(STRING,MS,ME)
 S DAY=$E(STRING,DS,DE)
 ;
 Q 
 ;
HASALPHA ; Contains a named month, probably.
 ;
 N I,J,PARTS
 ;
 S ALPHA=1
 ;
 ; Punctuation
 I STRING?.E1P.E D HASPUNC D HASA2 Q 
 I STRING?2N3U.U4N D USEMASK("DDMONYEAR")
 I STRING?2N3U.U2N D USEMASK("DDMONYY")
 I STRING?3U.U4N D USEMASK("MONDDYY") D HASA2 Q 
 I STRING?3U.U6N D USEMASK("MONDDYEAR") D HASA2 Q 
 ;
 ; Parse
 D PARSEALPHA(STRING,.PARTS)
 D PARSEMASK(MASK,.YS,.YE,.MS,.ME,.DS,.DE)
 I YS S ORDER(YS)=""
 I MS S ORDER(MS)=""
 I DS S ORDER(DS)=""
 ;
 S (YEAR,MONTH,DAY)=""
 S J=""
 F I=1:1:PARTS D HASA1 Q:J="" 
 ;
HASA2 ; 
 ;
 N X
 ;
 Q:ER 
 I DAY?1U.U D SWAP(.DAY,.MONTH)
 I YEAR?1U.U D SWAP(.YEAR,.MONTH)
 I MONTH'?1U.U Q 
 ;
 S X=$$NAMETONUM(MONTH)
 ;
 ; Not valid
 I X<1 D BADMONTH(MONTH) Q 
 S MONTH=X
 ;
 Q 
 ;
HASA1 ; Determine which piece we've got
 ;
 S J=$order(ORDER(J)) Q:J="" 
 I J=MS S MONTH=PARTS(I) Q 
 I J=DS S DAY=PARTS(I) Q 
 I J=YS S YEAR=PARTS(I) Q 
 ;
 Q 
 ;
HASPUNC ; Date has puncuation characters
 ;
 N I,J,PARTS
 ;
 D PARSEPUNC(STRING,.PARTS)
 ;
 ; Can't have more than 3 parts
 I PARTS>3 D BadDate(STRING) Q 
 D PARSEMASK(MASK,.YS,.YE,.MS,.ME,.DS,.DE)
 I YS S ORDER(YS)=""
 I MS S ORDER(MS)=""
 I DS S ORDER(DS)=""
 ;
 S (YEAR,MONTH,DAY)=""
 S J=""
 F I=1:1:PARTS D HASP1 Q:J="" 
 ;
 Q 
 ;
HASP1 ; Determine which piece we've got
 ;
 S J=$order(ORDER(J)) Q:J="" 
 I J=MS S MONTH=PARTS(I) Q 
 I J=DS S DAY=PARTS(I) Q 
 I J=YS S YEAR=PARTS(I) Q 
 ;
 Q 
 ;
PARSEPUNC(TEXT,ARRAY) ; Parse Text with Puncuation Delimiters
 ;
 N J,X,Y,Z
 ;
 S ARRAY=0
 S J=0
 F  S J=J+1 S X=$E(TEXT,J) D PPUNC1 Q:X="" 
 ;
 Q 
 ;
PPUNC1 ; Collect non-punctuation characters
 ;
 Q:X="" 
 ;
 ; Skip one/many punctuation characters
 I X?1P D PPUNC2 Q 
 S ARRAY=ARRAY+1
 S Y=X
 F  S Z=$E(TEXT,J+1) Q:Z=""  Q:Z?1P  S Y=Y_Z S J=J+1
 S ARRAY(ARRAY)=Y
 ;
 Q 
 ;
PPUNC2 ; Skip puncuation characters
 ;
 ; Look ahead one character
 S X=$E(TEXT,J+1)
 Q:X="" 
 Q:X'?1P 
 S J=J+1
 ;
 Q 
 ;
PARSEALPHA(TEXT,ARRAY) ; Parse Text with mixed Alpha/Numeric
 ;
 ; Note that the string can only contain alpha and numeric!
 N J,PAT,X,Y
 ;
 S PAT(0)="1N"
 S PAT(1)="1U"
 ;
 I $E(TEXT,1)?1N S PAT=0
 E  S PAT=1
 ;
 S ARRAY=0
 S J=0
 F  S J=J+1 S X=$E(TEXT,J) Q:X=""  D PALPHA1
 ;
 Q 
 ;
PALPHA1 ; Collect characters
 ;
 N Z
 ;
 ; Have to toggle patterns
 I X'?@PAT(PAT) S PAT='PAT
 S ARRAY=ARRAY+1
 S Y=X
 ;
 F  S Z=$E(TEXT,J+1) Q:Z=""  Q:Z'?@PAT(PAT)  S Y=Y_Z S J=J+1
 S ARRAY(ARRAY)=Y
 ;
 Q 
 ;
CALCYEAR ; Calculate Current Year
 ;
 N D
 ;
 S D=+TJD
 ;
 S YEAR=$ZD(D,"YEAR")
 ;
 Q 
 ;
VALDAY(DAY) ; Validate Day
 ;
 I DAY<1 Q 0
 I DAY>31 Q 0
 ;
 Q 1
 ;
VALMONTH(MONTH) ; Validate Month
 ;
 I MONTH<1 Q 0
 I MONTH>12 Q 0
 ;
 Q 1
 ;
VALYEAR(YEAR) ; Validate Year
 ;
 I YEAR<100 S YEAR=YEAR+$S(YEAR>50:1900,1:2000)
 I YEAR<1 Q 0
 I YEAR<1841 Q 0
 ;
 Q 1
 ;
VALIDATE ; Validate Date Components
 ;
 N DL,%DJ
 ;
 ; Might have been an error
 Q:ER 
 ;
 ; Make all pieces numeric
 S DAY=+DAY
 S MONTH=+MONTH
 ;
 ; Provide year if not specified
 I YEAR="" D CALCYEAR
 ;
 ; Guess Month, Day & Year
 I '$$VALMONTH(MONTH),'$$MONTHGUESS D BADMONTH(MONTH) Q 
 I '$$VALDAY(DAY),'$$DAYGUESS D BADDAY(DAY) Q 
 I '$$VALYEAR(YEAR),'$$YEARGUESS D BADYEAR(YEAR) Q 
 ;
 S DL=0
 I YEAR<100 S YEAR=YEAR+$S(YEAR>50:1900,1:2000)
 ;
 ; Leap year
 I (YEAR#4=0)&('(YEAR#100=0)!(YEAR#400=0)) S DL=1
 ;
 I DAY>30,MONTH=4!(MONTH=6)!(MONTH=9)!(MONTH=11) D BADDAY(DAY) Q 
 I MONTH=2,(('DL&(DAY>28))!(DL&(DAY>29))) D BADDAY(DAY) Q 
 ;
 I DL=0 S %DJ=$piece("0,31,59,90,120,151,181,212,243,273,304,334",",",MONTH)+DAY
 E  S %DJ=$piece("0,31,60,91,121,152,182,213,244,274,305,335",",",MONTH)+DAY
 ;
 ; Days in normal 365 day years
 S DN=%DJ+((YEAR-1841)*365)
 ;
 ; Add one day for each leap year
 S DN=DN+((YEAR-1841)\4)
 ;
 ; Subtract one day for each century
 S DN=DN-((YEAR-1)\100-18)
 ;
 ; Add one day for each fourth century
 S DN=DN+((YEAR-1)\400-4)
 ;
 Q 
 ;
DAYGUESS() ; Try to get a valid day
 ;
 ; Can't use the month if it wasn't ambiguous, e.g. AUG
 N S1,S2
 ;
 S S1=0
 S S2=0
 ;
 I $$VALYEAR(DAY) I $$VALDAY(YEAR) S S1=1
 I 'ALPHA I $$VALMONTH(DAY) I $$VALDAY(MONTH) S S2=1
 ;
 I (S1&S2)&(MONTH'=YEAR) Q 0
 I S1 D SWAP(.DAY,.YEAR) Q 1
 I S2 D SWAP(.DAY,.MONTH) Q 1
 ;
 ; No swap possible
 ;
 Q 0
 ;
MONTHGUESS() ; Try to get a valid month
 ;
 ; Can't swap with Day or Year if the month was not amibiguous
 I ALPHA Q 0
 ;
 N S1,S2
 ;
 S S1=0
 S S2=0
 ;
 I $$VALDAY(MONTH) I $$VALMONTH(DAY) S S1=1
 I $$VALYEAR(MONTH) I $$VALMONTH(YEAR) S S2=1
 ;
 ; Ambiguous
 I (S1&S2)&(DAY'=YEAR) Q 0
 I S1 D SWAP(.MONTH,.DAY) Q 1
 I S2 D SWAP(.MONTH,.YEAR) Q 1
 ;
 ; No swap possible
 ;
 Q 0
 ;
YEARGUESS() ; Try to get a valid year
 ;
 N S1,S2
 ;
 S S1=0
 S S2=0
 ;
 I $$VALDAY(YEAR) I $$VALYEAR(DAY) S S1=1
 I 'ALPHA I $$VALMONTH(YEAR) I $$VALYEAR(MONTH) S S2=1
 ;
 ; Ambiguous
 I (S1&S2)&(DAY'=MONTH) Q 0
 I S1 D SWAP(.YEAR,.DAY) Q 1
 I S2 D SWAP(.YEAR,.MONTH) Q 1
 ;
 ; No swap possible
 ;
 Q 0
 ;
SWAP(X,Y) ; Swap X and Y values
 ;
 N Z
 ;
 S Z=X
 S X=Y
 ;
 ; Swap X and Y values
 S Y=Z
 ;
 Q 
 ;
TODAY ; T = today's system date from CUVAR(2)
 ;
 N cuvar S cuvar=$$vRCgetRecord0Opt^RecordCUVAR(0,"")
  S cuvar=$G(^CUVAR(2))
 ;
 I $P(cuvar,$C(124),1) S DN=$P(cuvar,$C(124),1)
 E  S DN=$P($H,",",1)
 I STRING?1"T+".E S DN=DN+$E(STRING,3,1048575)
 E  I STRING?1"T-".E S DN=DN-$E(STRING,3,1048575)
 E  I '(STRING="T") D BADEXPR(STRING)
 ;
 Q 
 ;
CALENDAR ; C = today's calendar (+%CurrentDate) date
 ;
 S DN=$P($H,",",1)
 I STRING?1"C+".E S DN=DN+$E(STRING,3,1048575)
 E  I STRING?1"C-".E S DN=DN-$E(STRING,3,1048575)
 E  I '(STRING="C") D BADEXPR(STRING)
 ;
 Q 
 ;
 ;  Date Mask Parsing Functions
 ;
PARSEMASK(MASK,YS,YE,MS,ME,DS,DE) ; Parse Mask for Postitions
 ;
 I $E(MASK,1,7)="MM/DD/Y" D  Q 
 .	S YS=7
 .	S YE=$L(MASK)
 .	S MS=1
 .	S ME=2
 .	S DS=4
 .	S DE=5
 .	Q 
 I $E(MASK,1,7)="DD/MM/Y" D  Q 
 .	S YS=7
 .	S YE=$L(MASK)
 .	S MS=4
 .	S ME=5
 .	S DS=1
 .	S DE=2
 .	Q 
 D FINDYEAR(MASK,.YS,.YE)
 D FINDMONTH(MASK,.MS,.ME)
 D FINDDAY(MASK,.DS,.DE)
 ;
 Q 
 ;
GETMASK ; Locate Date Mask
 ;
 ; Define Date-Mask variable and month-list (I18n_#9 edit mask)
 ;
 I $get(%MS)'="" S %MLIST=","_$ZCONVERT(%MS,"U")_","
 E  S %MLIST=",JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC,"
 ;
 ; Already defined
 I $get(MASK)'="" Q 
 S MASK="MM/DD/YY"
 ;
 Q 
 ;
FINDYEAR(MASK,YS,YE) ; Locate year portion
 ;
 ; Year masks can me "YY" or "YEAR"
 N X
 ;
 S X="YY"
 S YS=$$FINDSTART(MASK,"YY")
 ;
 I YS S YE=YS+$L(X)-1 Q 
 S X="YEAR"
 S YS=$$FINDSTART(MASK,"YEAR")
 ;
 I YS S YE=YS+$L(X)-1 Q 
 S YE=0
 ;
 ; No year in mask
 ;
 Q 
 ;
FINDMONTH(MASK,MS,ME) ; Locate month portion
 ;
 ; Month mask part can be "MM" or "MON"
 N X
 ;
 S X="MM"
 ; Locate
 S MS=$$FINDSTART(MASK,"MM")
 I MS S ME=MS+$L(X)-1 Q 
 ;
 S X="MON"
 S MS=$$FINDSTART(MASK,"MON")
 ;
 I MS S ME=MS+$L(X)-1 Q 
 S ME=0
 ;
 ; No month in mask
 ;
 Q 
 ;
FINDDAY(MASK,DS,DE) ; Locate day portion
 ;
 ; Day mask part can only be "DD"
 N X
 ;
 S X="DD"
 S DS=$$FINDSTART(MASK,"DD")
 ;
 I DS S DE=DS+$L(X)-1 Q 
 S DE=0
 ;
 ; No day in mask
 ;
 Q 
 ;
FINDSTART(STRING,SUB) ; Find Start of Substring
 ;
 N X
 ;
 ; Finds end of the substring
 S X=$F(STRING,SUB)
 ;
 ; Back up to first character of the substring
 I X Q X-$L(SUB)
 ;
 Q X
 ;
NAMETONUM(MONTH) ; Month Name to Number Translation
 ;
 S ALPHA=1
 ;
 ; Too long
 I $L(MONTH)>3 S MONTH=$E(MONTH,1,3)
 ;
 Q ($F(%MLIST,","_MONTH_",")-2)\4
 ;
BADMONTH(M) ; Invalid Month
 ;
 ; ~p1 is an invalid month
 S RM=$$^MSG(1407,M)
 D ERR
 ;
 Q 
 ;
BADDAY(D) ; Invalid Day
 ;
 ; ~p1 is an invalid day
 S RM=$$^MSG(1312,D)
 D ERR
 ;
 Q 
 ;
BADYEAR(Y) ; Invalid Year
 ;
 ; ~p1 is an invalid year
 S RM=$$^MSG(1510,Y)
 D ERR
 ;
 Q 
 ;
BadDate(D) ; Invalid date
 ;
 ; Invalid date ~p1
 S RM=$$^MSG(1308,D)
 D ERR
 ;
 Q 
 ;
BADEXPR(S) ; Invalid expression
 ;
 ; Invalid expression ~p1
 S RM=$$^MSG(8045,S)
 D ERR
 ;
 Q 
 ;
ERR ; 
 S DN=-1
 S ER=1
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60487^37529^Pat Kelly^11073" ; Signature - LTD^TIME^USER^SIZE
