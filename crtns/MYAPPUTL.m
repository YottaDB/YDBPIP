 ; 
 ; **** Routine compiled from DATA-QWIK Procedure MYAPPUTL ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #OPTION ResultClass ON
 Q 
 ;
 ; ---------------------------------------------------------------------
DAT2PIP(myDate) ; 
 N retVal
 S retVal=$$vStrJD(myDate,"YEAR/MM/DD")
 Q retVal
 ;
 ; ---------------------------------------------------------------------
TIM2PIP(myTime) ; 
 N retVal
 S retVal=$$vStrTM(myTime)
 Q retVal
 ;
 ; ---------------------------------------------------------------------
PIP2DAT(pipDate) ; 
 Q $S(pipDate'="":$ZD(pipDate,"YEAR/MM/DD"),1:"")
 ;
 ; ---------------------------------------------------------------------
PIP2TIM(pipTime) ; 
 Q $$vtim2str(pipTime,"24:60:SS")
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61277^26562^e0101572^1826" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrJD(string,mask) ; String.toDate
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (string="") Q ""
 ;
 N m N d N y
 ;
 S d=$F(mask,"DD")
 S m=$F(mask,"MM")
 I string?5N Q string
 I '(m&d) Q $$^SCAJD(string,mask)
 S m=$E(string,m-2,m-1) S d=$E(string,d-2,d-1)
 I (m?1.N)'&(d?1.N) Q $$^SCAJD(string,mask)
 ;
 S y=$F(mask,"YEAR")
 I y S y=$E(string,y-4,y-1)
 E  S y=$F(mask,"YY") I y S y=$E(string,y-2,y-1)
 E  Q $$^SCAJD(string,mask)
 ;
 I m<1!(m>12) Q -1
 I y<100 S y=y+$S(y>50:1900,1:2000)
 I (y#4=0)&('(y#100=0)!(y#400=0)) S m=$piece("0,31,60,91,121,152,182,213,244,274,305,335,366",",",m,m+1)
 E  S m=$piece("0,31,59,90,120,151,181,212,243,273,304,334,365",",",m,m+1)
 I $piece(m,",",2)-$piece(m,",",1)<d Q -1
 S d=d+$piece(m,",",1)+((y-1841)*365)
 S d=d+((y-1841)\4)
 S d=d-(((y-1)\100)-18)
 S d=d+(((y-1)\400)-4)
 Q d
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTM(object) ; String.toTime
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (object="") Q ""
 I object["P",object<12 S $piece(object,":",1)=$piece(object,":",1)+12
 E  I object["A",$piece(object,":",1)=12 S $piece(object,":",1)=0
 I object["-"!($piece(object,":",1)>23)!($piece(object,":",2)>59)!($piece(object,":",3)>59) Q ""
 Q $piece(object,":",1)*60+$piece(object,":",2)*60+$piece(object,":",3)
 ; ----------------
 ;  #OPTION ResultClass 1
vtim2str(vo,vm) ; Time.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (vm="") S vm="24:60:SS"
 N cc
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 SET cc=$ZDATE(","_vo,vm)
 ;*** End of code by-passed by compiler ***
 Q cc
