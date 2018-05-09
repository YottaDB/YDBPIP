UCDATE	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCDATE ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;I18N=QUIT
	;
	;  #optimize FUNCTIONS OFF
	;
	Q 
	;
	; ---------------------------------------------------------------------
day	; method Date.day()
	; Returns (String) day of month
	;
	I $$isLit^UCGM(objectName) S return=$ZD(objectName,"DD")
	E  S return="$ZD("_objectName_",""DD"")"
	Q 
	;
	; ---------------------------------------------------------------------
dayOfM	; method Date.dayOfMonth()
	; Returns (Number) day of month
	;
	I $$isLit^UCGM(objectName) S return=+$ZD(objectName,"DD")
	E  S return="+$ZD("_objectName_",""DD"")"
	Q 
	;
	; ---------------------------------------------------------------------
month	; method Date.month()
	; Returns String month
	;
	I $$isLit^UCGM(objectName) S return=$ZD(objectName,"MM")
	E  S return="$ZD("_objectName_",""MM"")"
	Q 
	;
	; ---------------------------------------------------------------------
monthOfY	; method Date.monthOfYear()
	; Returns Number month
	;
	I $$isLit^UCGM(objectName) S return=+$ZD(objectName,"MM")
	E  S return="+$ZD("_objectName_",""MM"")"
	Q 
	;
	; ---------------------------------------------------------------------
year	; method Date.year()
	; Returns int year
	;
	I $$isLit^UCGM(objectName) S return=$ZD(objectName,"YEAR")
	E  S return="$ZD("_objectName_",""YEAR"")"
	Q 
	;
	; ---------------------------------------------------------------------
daysInMo	; method Date.daysInMonth
	; Returns Number of days in the month
	;
	N label S label="vdatDIM"
	;
	I '$D(labels("vdatDIM")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Date object)","Date.daysInMonth")
	.	;
	.	D vaddBuff(buf,"type Number month=object.month()")
	.	D vaddBuff(buf,"type Number return=""31,28,31,30,31,30,31,31,30,31,30,31"".piece("","",month)")
	.	D vaddBuff(buf,"if month=2,object.isLeapYear() set return=return+1")
	.	D vaddBuff(buf,"quit return")
	.	D INSERT^UCMETHOD(buf,"vdatDIM","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
dayOfYr	; method: Date.dayOfYear()
	;
	N tkn S tkn=$$tokenPush^UCPATCH(objectName)
	S return="("_tkn_"+1-(""01/01/""_"_tkn_".year()).toDate())"
	S return=$$tokenPop^UCPATCH($$vMExpr(return),1)
	Q 
	;
	; ---------------------------------------------------------------------
daysToEOY	; method: Date.daysToEOY()
	;
	N tkn S tkn=$$tokenPush^UCPATCH(objectName)
	S return="((""12/31/""_"_tkn_".year()).toDate()-"_tkn_")"
	S return=$$tokenPop^UCPATCH($$vMExpr(return),1)
	Q 
	;
	; ---------------------------------------------------------------------
isBusDat	; method: Date.isBusDate(String Calendar)
	;
	I (""""""[actual(1)) S actual(1)="""IBS"""
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)) D  Q 
	.	N obj2Date S obj2Date=(objectName)
	.	S return=$$vdatBD(obj2Date,$$QSUB^%ZS(actual(1),""""))
	.	Q 
	;
	I '$D(labels("vdatBD")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Date object,String p1)","Date.isBusDate")
	.	;
	.	D vaddBuff(buf,"#OPTIMIZE")
	.	; Added default values for parameters P01 - 8074
	.	D vaddBuff(buf,"if object.get().isNull() set object=%SystemDate")
	.	D vaddBuff(buf,"if p1.get().isNull() set p1=""IBS""")
	.	D vaddBuff(buf,"")
	.	;
	.	D vaddBuff(buf,"type Public Cache %CACHE()")
	.	D vaddBuff(buf,"type RecordUTBLNBD rec=%CACHE(""UTBLNBD"").getRecord(""UTBLNBD"",""NBDC=:p1"")")
	.	D vaddBuff(buf,"type Number n=(object#7)")
	.	D vaddBuff(buf,"if n=0,rec.thu quit 0")
	.	D vaddBuff(buf,"if n=1,rec.fri quit 0")
	.	D vaddBuff(buf,"if n=2,rec.sat quit 0")
	.	D vaddBuff(buf,"if n=3,rec.sun quit 0")
	.	D vaddBuff(buf,"if n=4,rec.mon quit 0")
	.	D vaddBuff(buf,"if n=5,rec.tue quit 0")
	.	D vaddBuff(buf,"if n=6,rec.wed quit 0")
	.	D vaddBuff(buf,"")
	.	;
	.	D vaddBuff(buf,"type Boolean x=%CACHE(""UTBLNBD"",p1,object).get()")
	.	D vaddBuff(buf,"if x.isNull() do {")
	.	D vaddBuff(buf," set x='Db.isDefined(""UTBLNBD1"",""NBDC=:p1,NBD=:object"")")
	.	D vaddBuff(buf," set %CACHE(""UTBLNBD"",p1,object)=x")
	.	D vaddBuff(buf," #bypass")
	.	D vaddBuff(buf," if $G(%CACHE(""UTBLNBD""))>100 kill %CACHE(""UTBLNBD"")")
	.	D vaddBuff(buf," set %CACHE(""UTBLNBD"")=$G(%CACHE(""UTBLNBD""))+1")
	.	D vaddBuff(buf," #endbypass")
	.	D vaddBuff(buf," }")
	.	D vaddBuff(buf,"quit x")
	.	D INSERT^UCMETHOD(buf,"vdatBD","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vdatBD"_"("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
nxBusDat	; method: Date.nextBusDate(Number numberDays, String Calendar)
	;
	I (""""""[actual(1)) S actual(1)=1
	I (""""""[actual(2)) S actual(2)="""IBS"""
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D  Q 
	.	N obj2Date S obj2Date=(objectName)
	.	S return=$$vdatNBD(obj2Date,$$QSUB^%ZS(actual(1),""""),$$QSUB^%ZS(actual(2),""""))
	.	Q 
	;
	N label S label="vdatNBD"
	;
	I '$D(labels("vdatNBD")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Date object,Number p1,String p2)","Date.nextBusDate")
	.	;
	.	D vaddBuff(buf,"for object=object+1:1 if object.isBusDate(p2) set p1=p1-1 quit:p1<1")
	.	D vaddBuff(buf,"quit object")
	.	D INSERT^UCMETHOD(buf,"vdatNBD","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
prBusDat	; method: Date.prevBusDate(Number numberDays, String Calendar)
	;
	I (""""""[actual(1)) S actual(1)=1
	I (""""""[actual(2)) S actual(2)="""IBS"""
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D  Q 
	.	N obj2Date S obj2Date=(objectName)
	.	S return=$$vdatPBD(obj2Date,$$QSUB^%ZS(actual(1),""""),$$QSUB^%ZS(actual(2),""""))
	.	Q 
	;
	N label S label="vdatPBD"
	;
	I '$D(labels("vdatPBD")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Date object,Number p1,String p2)","Date.prevBusDate")
	.	;
	.	D vaddBuff(buf,"for object=object-1:-1 if object.isBusDate(p2) set p1=p1-1 quit:p1<1")
	.	D vaddBuff(buf,"quit object")
	.	D INSERT^UCMETHOD(buf,"vdatPBD","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
isLeapYr	; method Date.isLeapYear - returns Boolean (date is leap year)
	;
	I $$isLit^UCGM(objectName) D  Q 
	.	;
	.	S return=$ZD(objectName,"YEAR")
	.	S return=return#4=0&('(return#100=0)!(return#400=0))
	.	Q 
	;
	N label S label="vdatILY"
	;
	I '$D(labels("vdatILY")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Date object)","Date.isLeapYear")
	.	;
	.	D vaddBuff(buf,"type Number year=object.year()")
	.	D vaddBuff(buf,"quit year#4=0&('(year#100=0)!(year#400=0))")
	.	D INSERT^UCMETHOD(buf,"vdatILY","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_label_"("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
toString	; method Date.toString(String mask) - return formatted date
	;
	N mask S mask=actual(1)
	;
	I (mask="") S mask=$S(commands("mask","Date")'["""":""""_commands("mask","Date")_"""",1:$$QADD^%ZS(commands("mask","Date"),""""))
	S return=""
	;
	I $$isLit^UCGM(mask),$$isLit^UCGM(objectName) D
	.	;
	.	; both values are literal, resolve at compile time
	.	N d S d=($$QSUB^%ZS(objectName,""""))
	.	S return=$$QADD^%ZS($$vdat2str(d,$$QSUB^%ZS(mask,"""")),"""")
	.	Q 
	E  I $$isVar^UCGM(objectName) D
	.	I $$isLit^UCGM(mask),",""DL"",""DS"",""ML"",""MS"","'[(","_mask_",") D
	..		S return="$S("_objectName_"'="""":$ZD("_objectName_","_mask_"),1:"""")"
	..		Q 
	.	Q 
	;
	I (return="") D
	.	;
	.	I '$D(labels("vdat2str")) D
	..		;
	..		N buf S buf=$$vopenBuf("(Date object, String mask)","Date.toString")
	..		;
	..		D vaddBuff(buf,"if object.isNull() quit """"")
	..		D vaddBuff(buf,"if mask.isNull() set mask="_$S(commands("mask","Date")'["""":""""_commands("mask","Date")_"""",1:$$QADD^%ZS(commands("mask","Date"),"""")))
	..		;
	..		;code for "DL"/"DS"/"ML"/"MS"
	..		D vaddBuff(buf,"type String cc,lday,lmon")
	..		D vaddBuff(buf,"if mask=""DL""!(mask=""DS"") do { // Long or short weekday")
	..		D vaddBuff(buf,"  set cc=^DBCTL(""SYS"",""DVFM"").get() // Country code")
	..		D vaddBuff(buf,"  if cc.isNull() set cc=""US""")
	..		D vaddBuff(buf,"  set lday=^DBCTL(""SYS"",""*DVFM"",cc,""D"",mask).get()")
	..		D vaddBuff(buf,"  set mask=""DAY"" // Day of the week")
	..		D vaddBuff(buf,"}")
	..		D vaddBuff(buf,"if mask=""ML""!(mask=""MS"") do { // Long or short month")
	..		D vaddBuff(buf,"  set cc=^DBCTL(""SYS"",""DVFM"").get() // Country code")
	..		D vaddBuff(buf,"  if cc.isNull() set cc=""US""")
	..		D vaddBuff(buf,"  set lmon=^DBCTL(""SYS"",""*DVFM"",cc,""D"",mask).get()")
	..		D vaddBuff(buf,"  set mask=""MON"" // Month of the year")
	..		D vaddBuff(buf,"}")
	..		D vaddBuff(buf,"quit $ZD(object,mask,lmon.get(),lday.get())")
	..		;
	..		D INSERT^UCMETHOD(buf,"vdat2str","")
	..		K vobj(+$G(buf)) Q 
	.	;
	.	S return="$$"_"vdat2str"_"("_objectName_","_mask_")"
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
nxFreDat	; method: Date.nextFregDate(String frequency,Number AF,String control)
	;
	I (actual(1)="") S actual(1)=$$QADD^%ZS(actual(1),"""")
	I (actual(3)="") S actual(3)=$$QADD^%ZS(actual(3),"""")
	;
	I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(3)) D  Q 
	.	N obj2Date S obj2Date=(objectName)
	.	S return=$$vdatFre(obj2Date,$$QSUB^%ZS(actual(1),""""),,$$QSUB^%ZS(actual(3),""""))
	.	Q 
	;
	N label S label="vdatFre"
	;
	I '$D(labels("vdatFre")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Date object,String p1,Number p2,String p3)","Date.Next Frequency")
	.	;
	.	D vaddBuff(buf,"if object.isNull()!p1.isNull() quit """"")
	.	D vaddBuff(buf,"type Public String SVFRE(,,)")
	.	D vaddBuff(buf,"if p3.get().isNull() set p3=0")
	.	D vaddBuff(buf,"type String x=SVFRE(p1,object,p3).get()")
	.	D vaddBuff(buf,"if x.isNull() quit $$NJD^UFRE(object,p1,.p2,p3)")
	.	D vaddBuff(buf,"set p2=x.piece(""|"",2) quit x.piece(""|"",1)")
	.	D vaddBuff(buf,"quit")
	.	D INSERT^UCMETHOD(buf,"vdatFre","")
	.	K vobj(+$G(buf)) Q 
	;
	; if 'PSL.actual(2).isNull(),'PSL.actual(2).isLiteral(),attrib(2).piece(tab,3) set PSL.actual(2)="."_PSL.actual(2)
	S return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
	;
	Q 
	;
vSIG()	;
	Q "60528^29068^Frans S.C. Witte^16075" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vopenBuf(v1,v2)	; PSL.openBuffer
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vOid
	S vOid=$order(vobj(""),-1)+1
	I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
	S vobj(vOid,-1)=v1
	S vobj(vOid,-2)=v2
	S vobj(vOid,1)=v1_" // "_v2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vaddBuff(object,p1)	; PSLBuffer.add
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N line
	S line=$order(vobj(object,""),-1)+1
	S vobj(object,line)=" "_p1
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vMExpr(v1)	; PSL.mExpr
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vExp N mcode N tok
	N vFun S vFun=$get(commands("OPTIMIZE","FUNCTIONS"),0)
	S commands("OPTIMIZE","FUNCTIONS")=0
	S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
	S commands("OPTIMIZE","FUNCTIONS")=vFun
	Q vExp
	; ----------------
	;  #OPTION ResultClass 0
vdatBD(object,p1)	; Date.isBusDate
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;  #OPTIMIZE
	I ($get(object)="") S object=TJD
	I ($get(p1)="") S p1="IBS"
	;
	N rec,vop1 S rec=$$vCa2(p1),vop1=1
	N n S n=(object#7)
	I n=0,$P(rec,$C(124),2) Q 0
	I n=1,$P(rec,$C(124),3) Q 0
	I n=2,$P(rec,$C(124),4) Q 0
	I n=3,$P(rec,$C(124),5) Q 0
	I n=4,$P(rec,$C(124),6) Q 0
	I n=5,$P(rec,$C(124),7) Q 0
	I n=6,$P(rec,$C(124),8) Q 0
	;
	N x S x=$get(%CACHE("UTBLNBD",p1,object))
	I (x="") D
	.	 N V1,V2 S V1=p1,V2=object S x='($D(^UTBL("NBD",V1,V2))#2)
	.	S %CACHE("UTBLNBD",p1,object)=x
	.	;*** Start of code by-passed by compiler
	.	if $G(%CACHE("UTBLNBD"))>100 kill %CACHE("UTBLNBD")
	.	set %CACHE("UTBLNBD")=$G(%CACHE("UTBLNBD"))+1
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Q x
	; ----------------
	;  #OPTION ResultClass 0
vdatNBD(object,p1,p2)	; Date.nextBusDate
	;
	;  #OPTIMIZE FUNCTIONS OFF
	F object=object+1:1 I $$vdatBD(object,p2) S p1=p1-1 Q:p1<1 
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vdatPBD(object,p1,p2)	; Date.prevBusDate
	;
	;  #OPTIMIZE FUNCTIONS OFF
	F object=object-1:-1 I $$vdatBD(object,p2) S p1=p1-1 Q:p1<1 
	Q object
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
	; ----------------
	;  #OPTION ResultClass 0
vdatFre(object,p1,p2,p3)	; Date.Next Frequency
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="")!(p1="") Q ""
	I ($get(p3)="") S p3=0
	N x S x=$get(SVFRE(p1,object,p3))
	I (x="") Q $$NJD^UFRE(object,p1,.p2,p3)
	S p2=$piece(x,"|",2) Q $piece(x,"|",1)
	;
vCa2(v1)	;	voXN = ({Cache}%CACHE("UTBLNBD").getRecord(UTBLNBD,0)
	;
	I '$D(%CACHE("UTBLNBD",v1)) D
	.  N v2out
	.  I $G(%CACHE("UTBLNBD"))>100 S %CACHE=%CACHE-%CACHE("UTBLNBD") KILL %CACHE("UTBLNBD")
	.  S %CACHE("UTBLNBD")=$G(%CACHE("UTBLNBD"))+1,%CACHE=$G(%CACHE)+1
	.  S %CACHE("UTBLNBD",v1)=$$vDb2(v1,.v2out),%CACHE("UTBLNBD",v1,-2)=v2out
	;
	;
	I %CACHE("UTBLNBD",v1,-2)=0 S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLNBD" X $ZT
	Q %CACHE("UTBLNBD",v1)
	;
vDb2(v1,v2out)	;	voXN = Db.getRecord(UTBLNBD,,1,-2)
	;
	N rec
	S rec=$G(^UTBL("NBD",v1))
	I rec="",'$D(^UTBL("NBD",v1))
	S v2out='$T
	;
	Q rec
