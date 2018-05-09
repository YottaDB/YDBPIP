 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDATE ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE  framework.psl
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 ;I18N=QUIT
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
day ; method Date.day()
 ; Returns (String) day of month
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I $$isLit^UCGM(objectName) S return=$ZD(objectName,"DD")
 E  S return="$ZD("_objectName_",""DD"")"
 Q 
 ;
 ; ---------------------------------------------------------------------
dayOfM ; method Date.dayOfMonth()
 ; Returns (Number) day of month
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I $$isLit^UCGM(objectName) S return=+$ZD(objectName,"DD")
 E  S return="+$ZD("_objectName_",""DD"")"
 Q 
 ;
 ; ---------------------------------------------------------------------
month ; method Date.month()
 ; Returns String month
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I $$isLit^UCGM(objectName) S return=$ZD(objectName,"MM")
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 E  S return="$ZD("_objectName_",""MM"")"
 Q 
 ;
 ; ---------------------------------------------------------------------
monthOfY ; method Date.monthOfYear()
 ; Returns Number month
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I $$isLit^UCGM(objectName) S return=+$ZD(objectName,"MM")
 E  S return="+$ZD("_objectName_",""MM"")"
 Q 
 ;
 ; ---------------------------------------------------------------------
year ; method Date.year()
 ; Returns int year
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I $$isLit^UCGM(objectName) S return=$ZD(objectName,"YEAR")
 E  S return="$ZD("_objectName_",""YEAR"")"
 Q 
 ;
 ; ---------------------------------------------------------------------
daysInMo ; method Date.daysInMonth
 ; Returns Number of days in the month
 ;
 I '$$hasSubr^UCGM("vdatDIM") D
 .	N buf S buf=$$vopenBuf("(Date vo)","Date.daysInMonth")
 .	;
 .	D vaddBuff(buf,"type Number month=vo.month()")
 .	D vaddBuff(buf,"type Number return=""31,28,31,30,31,30,31,31,30,31,30,31"".piece("","",month)")
 .	D vaddBuff(buf,"if month=2,vo.isLeapYear() set return=return+1")
 .	D vaddBuff(buf,"quit return")
 .	D INSERT^UCMETHOD(buf,"vdatDIM","Number")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vdatDIM"_"("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
dayOfYr ; method: Date.dayOfYear()
 ;
 N tkn S tkn=$$tokenPush^UCPATCH(objectName)
 S return="("_tkn_"+1-(""01/01/""_"_tkn_".year()).toDate())"
 S return=$$tokenPop^UCPATCH($$vMExpr(return),1)
 Q 
 ;
 ; ---------------------------------------------------------------------
daysToEOY ; method: Date.daysToEOY()
 ;
 N tkn S tkn=$$tokenPush^UCPATCH(objectName)
 S return="((""12/31/""_"_tkn_".year()).toDate()-"_tkn_")"
 S return=$$tokenPop^UCPATCH($$vMExpr(return),1)
 Q 
 ;
 ; ---------------------------------------------------------------------
isBusDat ; method: Date.isBusDate(String Calendar)
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) S actual(1)="""IBS"""
 ;
 I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)) D  Q 
 .	N obj2Date S obj2Date=$$vStrJD(objectName,"MM/DD/YEAR")
 .	S return=$$vdatBD(obj2Date,$$QSUB^%ZS(actual(1),""""))
 .	Q 
 ;
 I '$$hasSubr^UCGM("vdatBD") D
 .	N buf S buf=$$vopenBuf("(Date vo,String v1)","Date.isBusDate")
 .	;
 .	D vaddBuff(buf,"#OPTIMIZE")
 .	; Added default values for parameters P01 - 8074
 .	D vaddBuff(buf,"if vo.get().isNull() set vo=%SystemDate")
 .	D vaddBuff(buf,"if v1.get().isNull() set v1=""IBS""")
 .	D vaddBuff(buf,"")
 .	;
 .	; ======== COMMENTED OUT BEGIN ========
 .	D vaddBuff(buf,"catch vRecErr {")
 .	D vaddBuff(buf,"  if vRecErr.type=""%PSL-E-RECNOFL"" set vRecErr.type=""%PSL-E-BUSDATE""")
 .	D vaddBuff(buf,"  throw vRecErr")
 .	D vaddBuff(buf,"}")
 .	;======== COMMENTED OUT END ======== */
 .	;
 .	D vaddBuff(buf,"type Public Cache %CACHE()")
 .	D vaddBuff(buf,"type RecordUTBLNBD rec=%CACHE(""UTBLNBD"").getRecord(""UTBLNBD"",""NBDC=:v1"")")
 .	D vaddBuff(buf,"type Number n=(vo#7)")
 .	D vaddBuff(buf,"if n=0,rec.thu quit 0")
 .	D vaddBuff(buf,"if n=1,rec.fri quit 0")
 .	D vaddBuff(buf,"if n=2,rec.sat quit 0")
 .	D vaddBuff(buf,"if n=3,rec.sun quit 0")
 .	D vaddBuff(buf,"if n=4,rec.mon quit 0")
 .	D vaddBuff(buf,"if n=5,rec.tue quit 0")
 .	D vaddBuff(buf,"if n=6,rec.wed quit 0")
 .	D vaddBuff(buf,"")
 .	;
 .	D vaddBuff(buf,"quit '%CACHE(""UTBLNBD1"").isDefined(""UTBLNBD1"",""NBDC=:v1,NBD=:vo"")")
 .	D INSERT^UCMETHOD(buf,"vdatBD","Boolean")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vdatBD"_"("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
nxBusDat ; method: Date.nextBusDate(Number numberDays, String Calendar)
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) S actual(1)=1
 I $$isNullOrLiteralNull^UCPRIM(actual(2)) S actual(2)="""IBS"""
 ;
 I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D  Q 
 .	N obj2Date S obj2Date=$$vStrJD(objectName,"MM/DD/YEAR")
 .	S return=$$vdatNBD(obj2Date,$$QSUB^%ZS(actual(1),""""),$$QSUB^%ZS(actual(2),""""))
 .	Q 
 ;
 I '$$hasSubr^UCGM("vdatNBD") D
 .	N buf S buf=$$vopenBuf("(Date vo,Number v1,String v2)","Date.nextBusDate")
 .	;
 .	D vaddBuff(buf,"for vo=vo+1:1 if vo.isBusDate(v2) set v1=v1-1 quit:v1<1")
 .	D vaddBuff(buf,"quit vo")
 .	D INSERT^UCMETHOD(buf,"vdatNBD","Date")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vdatNBD"_"("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
prBusDat ; method: Date.prevBusDate(Number numberDays, String Calendar)
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) S actual(1)=1
 I $$isNullOrLiteralNull^UCPRIM(actual(2)) S actual(2)="""IBS"""
 ;
 I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D  Q 
 .	N obj2Date S obj2Date=$$vStrJD(objectName,"MM/DD/YEAR")
 .	S return=$$vdatPBD(obj2Date,$$QSUB^%ZS(actual(1),""""),$$QSUB^%ZS(actual(2),""""))
 .	Q 
 ;
 I '$$hasSubr^UCGM("vdatPBD") D
 .	N buf S buf=$$vopenBuf("(Date vo,Number v1,String v2)","Date.prevBusDate")
 .	;
 .	D vaddBuff(buf,"for vo=vo-1:-1 if vo.isBusDate(v2) set v1=v1-1 quit:v1<1")
 .	D vaddBuff(buf,"quit vo")
 .	D INSERT^UCMETHOD(buf,"vdatPBD","Date")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vdatPBD"_"("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
isLeapYr ; method Date.isLeapYear - returns Boolean (date is leap year)
 ;
 I $$isLit^UCGM(objectName) D  Q 
 .	;
 .	;   #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 .	S return=$ZD(objectName,"YEAR")
 .	S return=return#4=0&('(return#100=0)!(return#400=0))
 .	Q 
 ;
 I '$$hasSubr^UCGM("vdatILY") D
 .	N buf S buf=$$vopenBuf("(Date vo)","Date.isLeapYear")
 .	;
 .	D vaddBuff(buf,"type Number year=vo.year()")
 .	D vaddBuff(buf,"quit year#4=0&('(year#100=0)!(year#400=0))")
 .	D INSERT^UCMETHOD(buf,"vdatILY","Boolean")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vdatILY"_"("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
toString ; method Date.toString(String mask) - return formatted date
 ;
 N mask S mask=actual(1)
 ;
 I (mask="") S mask=$$QADD^%ZS($$getSetting^PSLCC(.pslPrsr,"PSL","DateMask"),"""")
 S return=""
 ;
 I $$isLit^UCGM(mask),$$isLit^UCGM(objectName) D
 .	; both values are literal, resolve at compile time
 .	N d S d=$$QSUB^%ZS(objectName,"""")
 .	S return=$$QADD^%ZS($$vdat2str(d,$$QSUB^%ZS(mask,"""")),"""")
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  I $$isVar^UCGM(objectName) D
 .	I $$isLit^UCGM(mask),",""DL"",""DS"",""ML"",""MS"","'[(","_mask_",") D
 ..		S return="$S("_objectName_"'="""":$ZD("_objectName_","_mask_"),1:"""")"
 ..		Q 
 .	Q 
 ;
 I (return="") D
 .	;
 .	I '$$hasSubr^UCGM("vdat2str") D
 ..		N buf S buf=$$vopenBuf("(Date vo, String mask)","Date.toString")
 ..		;
 ..		D vaddBuff(buf,"if vo.isNull() quit """"")
 ..		D vaddBuff(buf,"if mask.isNull() set mask="_$$QADD^%ZS($$getSetting^PSLCC(.pslPrsr,"PSL","DateMask"),""""))
 ..		;
 ..		;code for "DL"/"DS"/"ML"/"MS"
 ..		D vaddBuff(buf,"type String cc,lday,lmon")
 ..		D vaddBuff(buf,"if mask=""DL""!(mask=""DS"") do { // Long or short weekday")
 ..		D vaddBuff(buf,"  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL")
 ..		D vaddBuff(buf,"  set cc=^DBCTL(""SYS"",""DVFM"").get() // Country code")
 ..		D vaddBuff(buf,"  if cc.isNull() set cc=""US""")
 ..		D vaddBuff(buf,"  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL")
 ..		D vaddBuff(buf,"  set lday=^DBCTL(""SYS"",""*DVFM"",cc,""D"",mask).get()")
 ..		D vaddBuff(buf,"  set mask=""DAY"" // Day of the week")
 ..		D vaddBuff(buf,"}")
 ..		D vaddBuff(buf,"if mask=""ML""!(mask=""MS"") do { // Long or short month")
 ..		D vaddBuff(buf,"  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL")
 ..		D vaddBuff(buf,"  set cc=^DBCTL(""SYS"",""DVFM"").get() // Country code")
 ..		D vaddBuff(buf,"  if cc.isNull() set cc=""US""")
 ..		D vaddBuff(buf,"  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL")
 ..		D vaddBuff(buf,"  set lmon=^DBCTL(""SYS"",""*DVFM"",cc,""D"",mask).get()")
 ..		D vaddBuff(buf,"  set mask=""MON"" // Month of the year")
 ..		D vaddBuff(buf,"}")
 ..		D vaddBuff(buf,"#ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS")
 ..		D vaddBuff(buf,"#BYPASS")
 ..		D vaddBuff(buf,"set cc=$ZD(vo,mask,$G(lmon),$G(lday))")
 ..		D vaddBuff(buf,"#ENDBYPASS")
 ..		D vaddBuff(buf,"quit cc")
 ..		;
 ..		D INSERT^UCMETHOD(buf,"vdat2str","String")
 ..		K vobj(+$G(buf)) Q 
 .	;
 .	S return="$$"_"vdat2str"_"("_objectName_","_mask_")"
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
nxFreDat ; method: Date.nextFregDate(String frequency,Number AF,String control)
 I (actual(1)="") S actual(1)=$$QADD^%ZS(actual(1),"""")
 I (actual(3)="") S actual(3)=$$QADD^%ZS(actual(3),"""")
 ;
 I $$isLit^UCGM(objectName),$$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(3)) D  Q 
 .	N obj2Date S obj2Date=$$vStrJD(objectName,"MM/DD/YEAR")
 .	S return=$$vdatFre(obj2Date,$$QSUB^%ZS(actual(1),""""),,$$QSUB^%ZS(actual(3),""""))
 .	Q 
 ;
 I '$$hasSubr^UCGM("vdatFre") D
 .	N buf S buf=$$vopenBuf("(Date vo,String v1,ret Number v2,String v3)","Date.Next Frequency")
 .	;
 .	D vaddBuff(buf,"if vo.isNull()!v1.isNull() quit """"")
 .	D vaddBuff(buf,"type public String SVFRE(,,)")
 .	D vaddBuff(buf,"if v3.get().isNull() set v3=0")
 .	D vaddBuff(buf,"type String x=SVFRE(v1,vo,v3).get()")
 .	D vaddBuff(buf,"if x.isNull() quit $$NJD^UFRE(vo,v1,.v2,v3)")
 .	D vaddBuff(buf,"set v2=x.piece(""|"",2) quit x.piece(""|"",1)")
 .	D INSERT^UCMETHOD(buf,"vdatFre","Date")
 .	K vobj(+$G(buf)) Q 
 ;
 ; if 'PSL.actual(2).isNull(),'PSL.actual(2).isLiteral(),attrib(2).piece(tab,3) set PSL.actual(2)="."_PSL.actual(2)
 S return="$$"_"vdatFre"_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61058^29283^Frans S.C. Witte^17338" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vopenBuf(v1,v2) ; PSL.openBuffer
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vOid
 S vOid=$O(vobj(""),-1)+1 S vobj(vOid,-1)="PSLBuffer"
 I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
 S vobj(vOid,-2)=v1
 S vobj(vOid,-3)=v2
 S vobj(vOid,1)=v1_" // "_v2
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vaddBuff(object,p1) ; PSLBuffer.add
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N line
 S line=$order(vobj(object,""),-1)+1
 S vobj(object,line)=" "_p1
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vMExpr(v1) ; PSL.mExpr
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vExp N mcode N tok
 N vDep S vDep=$$getSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",0)
 N vMis S vMis=$$getSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 N vFun S vFun=$$getSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",0)
 D addSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",0)
 D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 D addSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",0)
 S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
 D addSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",vDep)
 D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",vMis)
 D addSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",vFun)
 Q vExp
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
vdatBD(vo,v1) ; Date.isBusDate
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #OPTIMIZE
 I ($get(vo)="") S vo=TJD
 I ($get(v1)="") S v1="IBS"
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 N rec,vop1 S rec=$$vCa3(v1),vop1=1
 N n S n=(vo#7)
 I n=0,$P(rec,$C(124),2) Q 0
 I n=1,$P(rec,$C(124),3) Q 0
 I n=2,$P(rec,$C(124),4) Q 0
 I n=3,$P(rec,$C(124),5) Q 0
 I n=4,$P(rec,$C(124),6) Q 0
 I n=5,$P(rec,$C(124),7) Q 0
 I n=6,$P(rec,$C(124),8) Q 0
 ;
 Q '$$vCaEx1()
 ; ----------------
 ;  #OPTION ResultClass 1
vdatNBD(vo,v1,v2) ; Date.nextBusDate
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 F vo=vo+1:1 I $$vdatBD(vo,v2) S v1=v1-1 Q:v1<1 
 Q vo
 ; ----------------
 ;  #OPTION ResultClass 1
vdatPBD(vo,v1,v2) ; Date.prevBusDate
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 F vo=vo-1:-1 I $$vdatBD(vo,v2) S v1=v1-1 Q:v1<1 
 Q vo
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
 ; ----------------
 ;  #OPTION ResultClass 1
vdatFre(vo,v1,v2,v3) ; Date.Next Frequency
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="")!(v1="") Q ""
 I ($get(v3)="") S v3=0
 N x S x=$get(SVFRE(v1,vo,v3))
 I (x="") Q $$NJD^UFRE(vo,v1,.v2,v3)
 S v2=$piece(x,"|",2) Q $piece(x,"|",1)
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx1() ; {Cache}%CACHE("UTBLNBD1").isDefined("UTBLNBD1","NBDC=:v1,NBD=:vo")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa4(v1,vo,.vop1)
 S vret=$G(vop1)=1 Q vret
 ;
vCa3(v1) ; voXN = ({Cache}%CACHE("UTBLNBD").getRecord(UTBLNBD,0)
 ;
 I '$D(%CACHE("UTBLNBD",v1)) D
 .  N v2out
 .  I $G(%CACHE("UTBLNBD"))>100 KILL %CACHE("UTBLNBD")
 .  S %CACHE("UTBLNBD")=$G(%CACHE("UTBLNBD"))+1
 .  S %CACHE("UTBLNBD",v1)=$$vRCgetRecord1Opt^RecordUTBLNBD(v1,0,.v2out),%CACHE("UTBLNBD",v1,-2)=v2out
 ;
 ;
 I %CACHE("UTBLNBD",v1,-2)=0 S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLNBD",$EC=",U1001,"
 Q %CACHE("UTBLNBD",v1)
 ;
vCa4(v1,v2,v2out) ; voXN = ({Cache}%CACHE("UTBLNBD1").getRecord(UTBLNBD1,1)
 ;
 I '$D(%CACHE("UTBLNBD1",v1,v2)) D
 .  I $G(%CACHE("UTBLNBD1"))>100 KILL %CACHE("UTBLNBD1")
 .  S %CACHE("UTBLNBD1")=$G(%CACHE("UTBLNBD1"))+1
 .  S %CACHE("UTBLNBD1",v1,v2)=$$vRCgetRecord1Opt^RecordUTBLNBD1(v1,v2,0,.v2out),%CACHE("UTBLNBD1",v1,v2,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("UTBLNBD1",v1,v2,-2)
 Q %CACHE("UTBLNBD1",v1,v2)
 ;
vCatch1 ; Error trap
 ;
 N vRecErr,$ET,$ES S vRecErr=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(vRecErr,",",3)="%PSL-E-RECNOFL" S $P(vRecErr,",",3)="%PSL-E-BUSDATE"
 S $ZE=vRecErr,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
