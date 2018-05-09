 ; 
 ; **** Routine compiled from DATA-QWIK Procedure TBXABIN ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;
 ;  #OPTION ResultClass ON
 ; Display any error and then quit, which will exit back to shel
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 N status
 N cmdline
 ;
 ;  #ACCEPT DATE=2009-06-15; Pgm=JaywantK; CR=40964; Group=BYPASS
 ;*** Start of code by-passed by compiler
 ; Parse the command line
 SET cmdline=$ZCMDLINE
 ;*** End of code by-passed by compiler ***
 ;
 S status=$$run(cmdline)
 ;
 ; pass the status of pack installation to command line
 ;  #ACCEPT DATE=2009-06-15; Pgm=JaywantK; CR=40964; Group=BYPASS
 ;*** Start of code by-passed by compiler
 SET $ZTRAP="" ZMESSAGE:status status
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
 ;---------------------------------------------------------------------
run(cmdline) ; wrapper around the call to TBXABIN.pslmain().
 ;---------------------------------------------------------------------
 N args
 ;
 ; captures the arguments in args array from command line
 ;
 D cmdline(cmdline,.args)
 ;
 N status S status=$$pslmain(.args)
 ;
 Q status
 ;
 ;---------------------------------------------------------------------
pslmain(args) ; 
 ;---------------------------------------------------------------------
 N stat S stat=0 ; 0 = success, anything else = failure
 ;
 D
 .	;
 .	N instdir N autobuild
 .	N overlayval
 .	N errmsg S errmsg=""
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	; pass the status of pack installation to command line
 .	;
 .	I '($D(args(1))#2) S stat=$$errormsg("No build is available for install") Q 
 .	I '($D(args("local"))#2) S stat=$$errormsg("Missing --local option") Q 
 .	I args("local")=2 S stat=$$errormsg("Incorrect overlay value for fix pack element --local option") Q 
 .	; pass the status of pack installation to command line
 .	; simulate a Fix Pack install, so use PRIO=0
 .	S autobuild(0)=args(1)
 .	S instdir=$get(args("dir"),"/profile_install/ab/")
 .	S overlayval=args("local")
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=40964;DATE=2009-06-15;PGM=Jaywant Khairnar
 .	S stat=$$install^TBXINST(.autobuild,0,instdir,1,overlayval)
 .	;
 .	Q 
 ;
 Q stat
 ;
 ; ---------------------------------------------------------------------
cmdline(cmdStr,args) ; Decomposed command line arguments/options
 ;
 N argCnt S argCnt=0
 N elem N tok
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=40964;DATE=2009-06-15;PGM=Jaywant Khairnar
 S cmdStr=$$TOKEN^%ZS(cmdStr,.tok)
 ;
 ; Replace TAB by SPACE and reduce multiple space to single space
 S cmdStr=$$vStrRep($$vStrTrim($translate(cmdStr,$char(9)," "),0," "),"  "," ",0,0,"")
 ;
 F  Q:'('(cmdStr=""))  D
 .	;
 .	S elem=$piece(cmdStr," ",1)
 .	S cmdStr=$piece(cmdStr," ",2,$L(cmdStr))
 .	;
 .	I '($E(elem,1)="-") D
 ..		;
 ..		S argCnt=argCnt+1
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=40964;DATE=2009-06-15;PGM=Jaywant Khairnar
 ..		S args(argCnt)=$$QSUB^%ZS($$UNTOK^%ZS(elem,tok),"""")
 ..		Q 
 .	E  I ($E(elem,1,2)="--") D
 ..		;
 ..		N opt S opt=$piece(elem,"=",1)
 ..		N value S value=$piece(elem,"=",2,$L(elem))
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=40964;DATE=2009-06-15;PGM=Jaywant Khairnar
 ..		S args($E(opt,3,1048575))=$$QSUB^%ZS($$UNTOK^%ZS(value,tok),"""")
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ;
errormsg(errMsg) ; Message associated with failure
 ;
 ; Direct to stderr once we are able to
 WRITE errMsg,!
 ;
 Q 1 ; Error indicator
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61544^27162^Jaywant Khairnar^8419" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vCatch2 ; Error trap
 ;
 N err,$ET,$ES S err=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S errmsg=$P(err,",",3)_", "_$P(err,",",2)_", "_$P(err,",",4)
 ;
 I '($P(err,",",5)="") S errmsg=errmsg_$P(err,",",5)
 ;
 S stat=$$errormsg(errmsg)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N err,$ET,$ES S err=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 N retStat
 ;
 N errmsg S errmsg=$P(err,",",3)_", "_$P(err,",",2)_", "_$P(err,",",4)
 ;
 I '($P(err,",",5)="") S errmsg=errmsg_$P(err,",",5)
 ;
 S retStat=$$errormsg(errmsg)
 ;
 ;   #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=BYPASS
 ;*** Start of code by-passed by compiler
 set $ZTRAP="" ZMESSAGE 2 ; Indicates uncontrolled error
 ;*** End of code by-passed by compiler ***
 D ZX^UCGMR(voxMrk) Q 
