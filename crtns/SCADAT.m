SCADAT	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADAT ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	S %DAT=$S(%DT'="":$ZD(%DT,"MM/DD/YEAR"),1:"")
	Q 
	;
DSJD(%DS)	;
	;
	N %JD,RM
	;
	S ER=0
	I %DS["?" Q ""
	S %JD=$$^SCAJD(%DS)
	;
	; Invalid date ~p1
	I %JD<0 S ER=1 S RM=$$^MSG(1308,%DS)
	;
	Q %JD
	;
MNAM(D,PURE)	;
	N vret
	;
	N M,MSTR,TYPE
	S ER=0
	; Get month number
	S M=$$MON(D,$get(PURE))
	;
	S TYPE="ML"
	N dvfmcal S dvfmcal=$G(^DBCTL("SYS","DVFM","D",TYPE))
	S vret=$piece(($P(dvfmcal,$C(124),1)),",",M) Q vret
	;
DOW(D,PURE)	;
	;
	N TYPE,X
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q ""
	;
	S TYPE="DL"
	; List of days
	N dvfmcal S dvfmcal=$G(^DBCTL("SYS","DVFM","D",TYPE))
	S X=$P(dvfmcal,$C(124),1)
	S D=D#7
	;
	I D<3 S D=D+5
	E  S D=D-2
	Q $piece(X,",",D)
	;
MON(D,PURE)	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q 0
	;
	Q +($ZD(D,"MM"))
	;
SDMON()	;
	N vret
	;
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR(2))
	;
	S vret=$$MON($P(cuvar,$C(124),1)) Q vret
	;
DAY(D,PURE)	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q 0
	;
	Q +($ZD(D,"DD"))
	;
YEAR(D,PURE)	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q 0
	;
	Q +($ZD(D,"YEAR"))
	;
VMIN(DATE,MIN,PURE)	;
	;
	S ER=0
	; No maximum value needed
	Q $$VRNG(DATE,MIN,"",$get(PURE))
	;
VMAX(DATE,MAX,PURE)	;
	;
	S ER=0
	; No minimum value needed
	Q $$VRNG(DATE,"",MAX,$get(PURE))
	;
VRNG(D,MIN,MAX,PURE)	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q 0
	I MIN'="",'$get(PURE) S MIN=$$^SCAJD(MIN) I ER Q 0
	I MAX'="",'$get(PURE) S MAX=$$^SCAJD(MAX) I ER Q 0
	;
	; Minimum value is ~p1
	I MIN'="",D<MIN S ER=1 S RM=$$^MSG(1743,$S(MIN'="":$ZD(MIN,"MM/DD/YEAR"),1:"")) Q 0
	; Maximum value is ~p1
	I MAX'="",D>MAX S ER=1 S RM=$$^MSG(1697,$S(MAX'="":$ZD(MAX,"MM/DD/YEAR"),1:"")) Q 0
	; It's ok
	Q 1
	;
MIN(D1,D2,PURE)	;
	;
	S ER=0
	I '$get(PURE) S D1=$$^SCAJD(D1) I ER Q -1
	I '$get(PURE) S D2=$$^SCAJD(D2) I ER Q -1
	I D1<D2 Q D1
	Q D2
	;
MAX(D1,D2,PURE)	;
	;
	S ER=0
	I '$get(PURE) S D1=$$^SCAJD(D1) I ER Q -1
	I '$get(PURE) S D2=$$^SCAJD(D2) I ER Q -1
	I D1>D2 Q D1
	;
	Q D2
	;
BOMJD(D,PURE)	;
	;
	S ER=0
	;
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	Q D-($ZD(D,"DD"))+1
	;
EOMJD(D,PURE)	;
	;
	S ER=0
	;
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	;
	N EOM
	F EOM=D+(28-($ZD(D,"DD"))):1 I ($ZD(EOM,"MM"))-($ZD((EOM+1),"MM")) Q 
	Q EOM
	;
BOYJD(D,PURE)	;
	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	;
	; Return Julian
	Q $$^SCAJD("1/1/"_$$YEAR(D,1))
	;
BOFY(D,PURE)	;
	;
	N JD,MMDD,YEAR
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	;
	N FINYE
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR("DAYEND"))
	S FINYE=$P(cuvar,$C(124),8)
	S MMDD=$S(FINYE'="":$ZD(FINYE,"MM/DD/"),1:"")
	;
	S YEAR=$$YEAR(D,1)
	S JD=$$^SCAJD(MMDD_YEAR)
	I (D=JD)!(D<JD) S JD=$$^SCAJD(MMDD_(YEAR-1))
	;
	Q JD+1
	;
BOTY(D,PURE)	;
	;
	N JD,MMDD,YEAR
	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	;
	N TAXYE
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR("DAYEND"))
	S TAXYE=$P(cuvar,$C(124),9)
	S MMDD=$S(TAXYE'="":$ZD(TAXYE,"MM/DD/"),1:"")
	S YEAR=$$YEAR(D,1)
	S JD=$$^SCAJD(MMDD_YEAR) I (D=JD)!(D<JD) S JD=$$^SCAJD(MMDD_(YEAR-1))
	;
	Q JD+1
	;
EOFY(D,PURE)	;
	;
	N JD,MMDD,YEAR
	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	;
	N FINYE
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR("DAYEND"))
	S FINYE=$P(cuvar,$C(124),8)
	S MMDD=$S(FINYE'="":$ZD(FINYE,"MM/DD/"),1:"")
	;
	S YEAR=$$YEAR(D,1)
	S JD=$$^SCAJD(MMDD_YEAR)
	I D>JD S JD=$$^SCAJD(MMDD_(YEAR+1))
	Q JD
	;
EOTY(D,PURE)	;
	;
	N JD,MMDD,YEAR
	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	;
	N TAXYE
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR("DAYEND"))
	S TAXYE=$P(cuvar,$C(124),9)
	S MMDD=$S(TAXYE'="":$ZD(TAXYE,"MM/DD/"),1:"")
	;
	S YEAR=$$YEAR(D,1)
	S JD=$$^SCAJD(MMDD_YEAR) I D>JD S JD=$$^SCAJD(MMDD_(YEAR+1))
	;
	Q JD
	;
EOYJD(D,PURE)	;
	;
	S ER=0
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q -1
	; Return Julian
	Q $$^SCAJD("12/31/"_$$YEAR(D,1))
	;
NOD(D1,D2,PURE)	;
	;
	S ER=0
	I '$get(PURE) S D1=$$^SCAJD(D1) I ER Q 0
	I '$get(PURE) S D2=$$^SCAJD(D2) I ER Q 0
	; Check if wrong order
	I D1<D2 Q D2-D1
	;
	Q D1-D2
	;
NODM(D,PURE)	;
	;
	S ER=0
	; Check if valid format
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q 0
	;
	Q $$EOMJD(D,1)-$$BOMJD(D,1)+1
	;
NODY(D,PURE)	;
	;
	S ER=0
	; Check if valid format
	I '$get(PURE) S D=$$^SCAJD(D) I ER Q 0
	;
	Q $$EOYJD(D,1)-$$BOYJD(D,1)+1
	;
NOM(D1,D2,FRACTION,PURE)	;
	;
	N DD,MONS,DAYS,YEARS,FRAC
	;
	S ER=0
	I '$get(PURE) S D1=$$^SCAJD(D1) I ER Q 0
	I '$get(PURE) S D2=$$^SCAJD(D2) I ER Q 0
	;
	; Calculate the delta-date of D1 and D2
	S DD=$$DD(D1,D2,1)
	; Error converting?
	I ER Q 0
	; Remove negative
	I $E(DD,1)="-" S DD=$E(DD,2,1048575)
	; Months in the delta
	S MONS=$piece(DD,"/",1)
	; Days...
	S DAYS=$piece(DD,"/",2)
	; Years...
	S YEARS=$piece(DD,"/",3)
	;
	I YEARS S MONS=MONS+(YEARS*12)
	;
	; Add fractional days only if needed...
	; No days left over?
	I 'DAYS Q MONS
	; No fractional part required?
	I '$get(FRACTION) Q MONS
	;
	Q MONS+(DAYS/$$NOD($$DDMATH(D1,MONS,1),$$DDMATH(D1,MONS+1,1),1))
	;
NOY(D1,D2,FRACTION,PURE)	;
	;
	N DD,YEARS,MONS,DAYS,NOD
	;
	S ER=0
	S PURE=$get(PURE)
	; Get the delta-date of D1 and D2
	S DD=$$DD(D1,D2,PURE)
	; Error converting
	I ER Q 0
	;
	S MONS=$piece(DD,"/",1)
	S DAYS=$piece(DD,"/",2)
	; Years in the delta
	S YEARS=$piece(DD,"/",3)
	;
	; No days left over?
	I 'DAYS,'MONS Q YEARS
	; Don't care about fractional part?
	I '$get(FRACTION) Q YEARS
	S DAYS=$$NOD($$DDMATH(D1,"//"_YEARS,PURE),D2,PURE)
	S NOD=$$NOD($$DDMATH(D1,"//"_YEARS,PURE),$$DDMATH(D1,"//"_(YEARS+1),PURE),PURE)
	;
	Q YEARS+(DAYS/NOD)
	;
ADDMDS(D,N,PURE)	;
	;
	N JD
	S ER=0
	S JD=$$ADDMJD(D,N,$get(PURE)) I ER Q ""
	;
	Q $S(JD'="":$ZD(JD,"MM/DD/YEAR"),1:"")
	;
ADDMJD(D,N,PURE)	;
	;
	S ER=0
	Q $$DDMATH(D,N,$get(PURE))
	;
DDT(DD)	;
	;
	N YEARS N YRS N MONS N MNS N DAYS N DYS N SIGN N DDT
	;
	S ER=0
	;
	; Check if negative
	I $E(DD,1)="-" S SIGN=1 S DD=$E(DD,2,1048575)
	E  S SIGN=""
	S YEARS=+$piece(DD,"/",3)
	S MONS=+$piece(DD,"/",1)
	S DAYS=+$piece(DD,"/",2)
	S DDT=""
	;
	I YEARS=0 S YEARS=""
	; ~p1 years
	E  S YRS=$$^MSG(4732,YEARS) S:YEARS>1 YRS=$$^MSG(5701,YEARS)
	I MONS=0 S MONS=""
	; ~p1 months
	E  S MNS=$$^MSG(4731,MONS) S:MONS>1 MNS=$$^MSG(5702,MONS)
	I DAYS=0 S DAYS=""
	; ~p1 days
	E  S DYS=$$^MSG(4730,DAYS) S:DAYS>1 DYS=$$^MSG(5703,DAYS)
	;
	S DDT=YRS
	I DDT="" S DDT=MNS
	E  S:MNS'="" DDT=DDT_", "_MNS
	I DDT="" S DDT=DYS
	E  S:DYS'="" DDT=DDT_", "_DYS
	;
	Q DDT
	;
DD(X,Y,PURE)	;
	;
	N SIGN,T,EOMX,EOMY,YEARS,MONS,DAYS,DAYY,DAYX
	N XJD N YJD
	S ER=0
	;
	; Convert to Julian
	I '$get(PURE) S XJD=$$^SCAJD(X) I ER Q ""
	I '$get(PURE) S YJD=$$^SCAJD(Y) I ER Q ""
	;
	I $get(PURE) S XJD=X S YJD=Y
	;
	; Reverse order?
	I XJD>YJD S SIGN="-" S T=XJD S XJD=YJD S YJD=T
	E  S SIGN=""
	; End-of-month?
	S EOMX=(XJD=$$EOMJD(XJD,1))
	S EOMY=(YJD=$$EOMJD(YJD,1))
	; Back to strings
	S X=$S(XJD'="":$ZD(XJD,"MM/DD/YEAR"),1:"")
	S Y=$S(YJD'="":$ZD(YJD,"MM/DD/YEAR"),1:"")
	S YEARS=$$YEAR(YJD,1)-$$YEAR(XJD,1)
	S MONS=$$MON(YJD,1)-$$MON(XJD,1)
	;
	I MONS<0,YEARS>0 S YEARS=YEARS-1 S MONS=MONS+12
	; Both end-of-months?
	I EOMX,EOMY S DAYS=0
	E  D
	.	S DAYY=$$DAY(YJD,1)
	.	S DAYX=$$DAY(XJD,1)
	.	I DAYY'<DAYX S DAYS=DAYY-DAYX Q 
	.	;
	.	S MONS=MONS-1
	.	I MONS<0,YEARS>0 S YEARS=YEARS-1 S MONS=MONS+12
	.	S DAYS=$$NOD($$DDMATH(XJD,MONS_"//"_YEARS,1),YJD,1)
	.	Q 
	;
	S D=MONS_"/"_DAYS_"/"_YEARS
	; Return the sign to indicate negative delta-date
	Q SIGN_D
	;
DDMATH(DATE,DD,PURE)	;
	;
	N MODE,MONS,DAYS,YEARS,EOM,M,D,Y,NODM
	;
	; Problem converting
	I '$get(PURE) S DATE=$$^SCAJD(DATE) I ER Q -1
	;
	; Strip off negative sign
	I $E(DD,1)="-" S MODE=-1 S DD=$E(DD,2,1048575)
	E  S MODE=1
	;
	S MONS=+$piece(DD,"/",1)
	S DAYS=+$piece(DD,"/",2)
	S YEARS=+$piece(DD,"/",3)
	; Add days to the Julian number directly
	S DATE=DATE+(MODE*DAYS)
	; Is it the end of a month?
	S EOM=(DATE=$$EOMJD(DATE,1))
	S M=$$MON(DATE,1)
	S D=$$DAY(DATE,1)
	S Y=$$YEAR(DATE,1)
	; Determine year
	S Y=Y+(MODE*YEARS)
	; Determine month
	S M=M+(MODE*MONS)
	;
	I MODE>0 F  Q:M'>12  S Y=Y+1 S M=M-12
	I MODE<0 F  Q:M'<1  S Y=Y-1 S M=M+12
	;
	; Correct days down to the maximum number of days in the month.
	S NODM=$$NODM(M_"/1/"_Y) I D>NODM S D=NODM
	;
	; Revert to Julian format
	Q $$^SCAJD(M_"/"_D_"/"_Y)
	;
TEST(beg,end,io)	; Test SCADAT
	;
	S x=$$FILE^%ZOPEN(io,"write/new",2,1024) I 'x Q 
	S x=$h S t1=x*1E5+$piece(x,",",2)
	;
	USE io
	F jd=beg:1:end D
	.	WRITE !,jd
	.	WRITE $char(9),$$MON^SCADAT(jd,1)
	.	WRITE $char(9),$$DAY^SCADAT(jd,1)
	.	WRITE $char(9),$$YEAR^SCADAT(jd,1)
	.	;
	.	WRITE $char(9),$$BOMJD^SCADAT(jd,1)
	.	WRITE $char(9),$$EOMJD^SCADAT(jd,1)
	.	;
	.	WRITE $char(9),$$BOTY^SCADAT(jd,1)
	.	WRITE $char(9),$$EOTY^SCADAT(jd,1)
	.	;
	.	WRITE $char(9),$$BOFY^SCADAT(jd,1)
	.	WRITE $char(9),$$EOFY^SCADAT(jd,1)
	.	Q 
	;
	S x=$h S t2=x*1E5+$piece(x,",",2)
	; I18N=OFF
	WRITE !,"Elapsed time=",t2-t1
	; I18N=ON
	D CLOSE^SCAIO
	Q 
	;
vSIG()	;
	Q "60425^3222^Dan Russell^25388" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
