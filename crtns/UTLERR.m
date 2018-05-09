 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UTLERR ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
UTLERR ; 
 ;  #OPTION ResultClass ON
 ; SCA error log and display utility
 ;
 ; Error not displayed
 ;
 D DSPMAIN($get(ET),-1)
 ;
 Q 
 ;
DSP ; Error displayed on next line
 ;
 D DSPMAIN($get(ET),0)
 ;
 Q 
 ;
DSP22 ; Error displayed on line 22
 ;
 D DSPMAIN($get(ET),22)
 ;
 Q 
 ;
DSPBP ; Error displayed at bottom of page
 ;
 D DSPMAIN($get(ET),23)
 ;
 Q 
 ;
DSPMAIN(ET,%ZTDY) ; Display line
 ;
 ; Manage logging and display for other direct calls, versus ZE/LOGERR calls
 ;
 N %ZTINFO
 ;
 D GetInfo(.%ZTINFO) ; Gather all process info first
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 ; Move ET into an empty Error object.  Set description to indicate this
 N %ZTError S %ZTError=""
 ;
 I ($E(ET,1,14)="%PSL-E-DBFILER") D
 .	;
 .	S $P(%ZTError,",",3)="%PSL-E-DBFILER"
 .	S $P(%ZTError,",",4)=$piece(ET,"%PSL-E-DBFILER",2)
 .	Q 
 E  D
 .	I (ET="") S ET="ETUNDEF"
 .	;
 .	I (ET[".") S ET=$piece(ET,".",$L(ET,"."))
 .	;
 .	I ($E(ET,1)="<") S ET=$E(ET,2,99)
 .	;
 .  D setProperty^UCERROR(.%ZTError,3,ET)
 .	S $P(%ZTError,",",4)="ET only"
 .	Q 
 ;
 ; Process and log (if appropriate) the error
 S %ZTSEQ=$$Process(.%ZTError,.%ZTINFO,%ZTDY,.RM)
 ;
 ; Clean up %ZT variables - we don't return them
 K %ZTHALT,%ZTHANG
 ;
 Q 
 ;
ZE ; Old logger for thrown errors
 ;
 N %ZTError S %ZTError=""
 ;
 D LOGERR("")
 ;
 Q 
 ;
LOGERR(%ZTError) ; Error logger for thrown errors
 ;
 N %ZTINFO
 ;
 Q:$P(%ZTError,",",1) 
 ;
 D GetInfo(.%ZTINFO) ; Gather all process info first
 ;
 S %ZTSEQ="" ; Default value if early quit
 S %ZTError=$$GetError(%ZTError)
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
  TRO:$TL>0 
 ;
 S ER=1
 S $P(%ZTError,",",1)=1
 ;
 Q:($P(%ZTError,",",3)="") 
 ;
 I ($P(%ZTError,",",3)="%PSL-E-DBFILER") D  Q 
 .	;
 .	S vVER=1
 .	S RM=$P(%ZTError,",",4)
 .	I (RM="") S RM=$$GetMSG(3322,"DBFILER","") ; ~p1 error
 .	S vVRM=RM
 .	Q 
 ;
 I ($P($P(%ZTError,",",3),"-",3)="INTERRUPT") WRITE !!,%ZTError Q 
 ;
 ; If replication is enabled and the error is generated on the secondary
 ; machine, log the error to a system file to avoid database updates.
 I $$ROLE^PBSUTL="SECONDARY" D Log2File(1) Q 
 ;
 ; Process and log (if appropriate) the error
 S %ZTSEQ=$$Process(%ZTError,.%ZTINFO,$get(%ZTDY),.RM)
 ;
 ; Clean up %ZT variables - we don't return them
 K %ZTDY,%ZTHALT,%ZTHANG
 ;
 Q 
 ;
Process(%ZTError,%ZTINFO,%ZTDY,RM) ; Return message(s)
 ;
 N breakEnabled S breakEnabled=0
 N %ZTSEQ S %ZTSEQ=0 ; Default value
 N errType S errType=$P($P(%ZTError,",",3),"-",3)
 ;
 N stbler
 ;
 ; Start empty
 K RM
 ;
 ; Don't allow interrupt during error logging - save status to reset
 I $piece($$^%ZBREAK,"|",1) D
 .	;
 .	S breakEnabled=1
 .	D DISABLE^%ZBREAK
 .	Q 
 ;
 S stbler=$$vRCgetRecord1^RecordSTBLER(errType,0)
 ;
 I (+$G(vobj(stbler,-2))'=+0) D
 .	;
 .	S RM(1)=$$VarSub($P(vobj(stbler),$C(124),1))
 .	S RM(2)=$$VarSub($P(vobj(stbler),$C(124),6))
 .	Q 
 ;No STBLER entry defined, set defaults
 E  D
 .	;
 .	I '($P(%ZTError,",",4)="") S RM(1)=$P(%ZTError,",",4)
 .	E  S RM(1)=$$GetMSG(5364,"","") ; Error not Defined
 .	S RM(2)=""
 .	;
 .  S $P(vobj(stbler),$C(124),2)=1
 .  S $P(vobj(stbler),$C(124),4)=1
 .  S $P(vobj(stbler),$C(124),11)=0
 .	Q 
 ;
 I ($D(%ZTHALT)#2)  S $P(vobj(stbler),$C(124),7)=%ZTHALT
 I ($D(%ZTHANG)#2)  S $P(vobj(stbler),$C(124),12)=%ZTHANG
 ;
  S $P(vobj(stbler),$C(124),11)=0
 ;
 I $P(vobj(stbler),$C(124),2) S %ZTSEQ=$$LogIt(%ZTError,.%ZTINFO)
 ;
 D PostProc(%ZTError,%ZTSEQ,%ZTDY,stbler,.RM)
 ;
 I breakEnabled D ENABLE^%ZBREAK
 ;
 K vobj(+$G(stbler)) Q %ZTSEQ
 ;
LogIt(%ZTError,%ZTINFO) ; Process and symbol table info
 N vTp
 ;
 N SaveDate S SaveDate=$P($H,",",1)
 N %ZTSEQ
 N errType N istr N var
 ;
 TS (vobj):transactionid="CS"
 ;
 S errType=$P($P(%ZTError,",",3),"-",3)
 I (errType="") S errType="Unknown"
 ;
 ; Set up top levels of error log
 ;
 N CNT N I N SEQ
 N X
 ;
 ; Get process unique sequence.  Allow up to 99 per second.  If
 ; we're logging more than that per process, hang one second.
 S CNT=1
 F  D  Q:'(SEQ="") 
 .	;
 .	S SEQ=1000000+$P($H,",",2)
 .	S SEQ=SEQ_$E((1000000+($J#1000000)),2,7)
 .	S SEQ=SEQ_$E((100+CNT),2,3)
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=SaveDate S rs=$$vOpen1()
 .	;
 . I ''$G(vos1) D
 ..		;
 ..		S SEQ=""
 ..		S CNT=CNT+1
 ..		I (CNT>99) D
 ...			;
 ...			S CNT=1
 ...			HANG 1
 ...			Q 
 ..		Q 
 . Q 
 ;
 S %ZTSEQ=SEQ
 ;
 N error S error=$$vcdmNew^RecordERROR() S vobj(error,-3)=SaveDate S vobj(error,-4)=errType S vobj(error,-5)=%ZTSEQ
  S vobj(error,1)=""
  S vobj(error,3)=""
 ;
  S vobj(error,-100,1)="" S $P(vobj(error,1),$C(124),1)=$get(%UID)
  S vobj(error,-100,1)="" S $P(vobj(error,1),$C(124),2)=$P($H,",",2)
  S vobj(error,-100,1)="" S $P(vobj(error,1),$C(124),3)=$get(TLO)
  S vobj(error,-100,1)="" S $P(vobj(error,1),$C(124),4)=$J
  S vobj(error,-100,1)="" S $P(vobj(error,1),$C(124),9)=$E($$SCAU^%TRNLNM("DIR"),1,25)
 ;
 ; Save routine info
 I '($P(%ZTError,",",2)="") D
 .	;
 .	N ELOC N errline N OFF N RTN N SETYP N TAG N XLT
 .	;
 .	S ELOC=$P(%ZTError,",",2)
 .	S RTN=$piece(ELOC,"^",2)
 .	;
 .	Q:(RTN="") 
 .	;
 .	S X=$piece(ELOC,"^",1)
 .	S TAG=$piece(X,"+",1)
 .	S OFF=+$piece(X,"+",2)
 .	;
 .	D ^%ZRTNLOD(RTN,"X",1,.XLT)
 .	;
 .	I '(TAG=""),($D(XLT(TAG))#2) S errline=$get(X(XLT(TAG)+OFF))
 .	E  S errline=""
 .	;
 .	; Do not include logged flag
 .  S vobj(error,-100,1)="" S $P(vobj(error,1),$C(124),5)=$ZSUBSTR(%ZTError,3,130)
 .  S vobj(error,-100,3)="" S $P(vobj(error,3),$C(124),1)=$E($$vStrRep(errline,$char(9),"_$C(9)_",0,0,""),1,150)
 .	Q 
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordERROR(error,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(error,-100) S vobj(error,-2)=1 TC:vTp  
 ;
 F istr="D","I","L","S","V" I $D(%ZTINFO(istr)) D
 .	;
 .	N isCache S isCache=0
 .	N I N SCALE N SEQ
 .	N DSC
 .	;
 .	I (istr="D") S DSC="#DEVICE"
 .	E  I (istr="I") S DSC="#INTRINSIC"
 .	E  I (istr="L") S DSC="#LOCK"
 .	E  I (istr="S") S DSC="#STACK"
 .	E  S DSC="#VAR"
 .	;
 .	; Use Scale to pad zeros to keep elements in order
 .	I (istr="V") S SCALE=10000000
 .	E  S SCALE=1000
 .	;
 .	S SEQ=0
 .	F I=1:1 Q:'($D(%ZTINFO(istr,I))#2)  D
 ..		;
 ..		N wasDone S wasDone=0
 ..		N DESC N suffix N value
 ..		;
 ..		S value=%ZTINFO(istr,I)
 ..		;
 ..		; ***** Begin cache suppression section **************
 ..		;
 ..		I (istr="V") D  Q:isCache 
 ...			;
 ...			I ($E(value,1)=" "),isCache Q  ; %CACHE extended record
 ...			I ($E(value,1,6)="%CACHE") S isCache=1 Q 
 ...			S isCache=0
 ...			Q 
 ..		;
 ..		; ***** End %CACHE suppression section ***************
 ..		;
 ..		I '($E(value,1,10)="          ") S SEQ=(SEQ\1)+1
 ..		E  S value=$E(value,11,1048575)
 ..		;
 ..		; Make sure we only save in 400 byte increments
 ..		F  Q:'('(value=""))  D
 ...			;
 ...			N dec
 ...			N saveVal S saveVal=$ZSUBSTR(value,1,400)
 ...			;
 ...			S value=$E(value,$L(saveVal)+1,1048575)
 ...			;
 ...			I (+(SEQ#1)'=+0) S dec=4
 ...			E  S dec=0
 ...			S suffix=$J((SCALE+SEQ),0,dec)
 ...			S DESC=DSC_$E(suffix,2,1048575)
 ...			;
 ...			N error9 S error9=$$vcdmNew^RecordERROR9() S vobj(error9,-3)=SaveDate S vobj(error9,-4)=errType S vobj(error9,-5)=%ZTSEQ S vobj(error9,-6)=DESC
 ...			;
 ...		  S $P(vobj(error9),$C(12),1)=saveVal
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordERROR9(error9,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(error9,-100) S vobj(error9,-2)=1 TC:vTp  
 ...			;
 ...			S SEQ=SEQ+.0001
 ...			K vobj(+$G(error9)) Q 
 ..		Q 
 .	Q 
 ;
  TC:$TL 
 ;
 K vobj(+$G(error)) Q %ZTSEQ
 ;
PostProc(%ZTError,%ZTSEQ,%ZTDY,stbler,RM) ; Return message(s)   /MECH=REFARR:RW
 ;
 ; Post-logging process
 ;
 N category N desc
 ;
 I ($P($P(%ZTError,",",3),"-",1)="%GTM") S category="MERROR"
 E  S category="STBLER" ; Default
 ;
 S desc=RM(1)
 ;
 ; Error log sequence number ~p1
 I (%ZTSEQ>0) S desc=desc_" - "_$$GetMSG(3389,%ZTSEQ,"")
 ;
 ; Return error priority level and post event
 S %ZTPRIO=$$ERRLOS^%ZFUNC($P($P(%ZTError,",",3),"-",3),category,"",0,0,.desc)
 ;
 ;If error not found, it won't be logged
 I %ZTPRIO S %ZTLOGD=1
 E  S %ZTLOGD=0
 ;
 I $P(vobj(stbler),$C(124),4) S RM(1)="<"_$P($P(%ZTError,",",3),"-",3)_"> "_RM(1)
 I $P(vobj(stbler),$C(124),2) S RM(1)="#"_%ZTSEQ_" "_RM(1)
 ;
 ; Write out error message(s)
 I $$INTRACT^%ZFUNC,(%ZTDY'<0),'($get(%IPMODE)["NOINT") D
 .	;
 .	N I
 .	N MSG N X
 .	;
 .	;   <RETURN> to continue:
 .	I ($P(vobj(stbler),$C(124),12)>0) S MSG=$$GetMSG(5362,"","")
 .	E  S MSG=""
 .	;
 .	USE 0
 .	I $P(vobj(stbler),$C(124),3) WRITE *7
 .	;
 .	I %ZTDY S %ZTDY=%ZTDY-('(RM(1)=""))-('(RM(2)=""))+(MSG="")
 .	;
 .	F I=1,2 I '(RM(I)="") D WriteMSG(.%ZTDY,RM(I))
 .	;
 .	I '(MSG="") D
 ..		;
 ..		N hangTime S hangTime=$P(vobj(stbler),$C(124),12)
 ..		;
 ..		D WriteMSG(.%ZTDY,MSG)
 ..		;
 ..		D TERM^%ZUSE(0,"FLUSH")
 ..		;
 ..		;    #ACCEPT Date=09/13/06; Pgm=RussellDS; CR=23019; Group=BYPASS
 ..		;*** Start of code by-passed by compiler
 ..		new X
 ..		read X:hangTime
 ..		;*** End of code by-passed by compiler ***
 ..		Q 
 .	Q 
 ;
 I $P(vobj(stbler),$C(124),11) D SendMail($P(vobj(stbler),$C(124),2),%ZTSEQ,$P($P(%ZTError,",",3),"-",3),.RM)
 I $P(vobj(stbler),$C(124),7) HALT 
 ;
 I (RM(2)="") D
 .	;
 .	N X S X=RM(1)
 .	;
 .	K RM
 .	S RM=X
 .	Q 
 ;
 Q 
 ;
GetInfo(%ZTINFO) ; Save ZSHow info to %ZTINFO array
 ;
 ;  #ACCEPT Date=12/07/2007;Pgm=RussellDS;CR=31014;Group=Bypass
 ;*** Start of code by-passed by compiler
 zshow "VDIL":%ZTINFO
 new I,seg
 set seq=1
 for I=$STACK(-1):-1:1 set %ZTINFO("S",seq)=$STACK(I,"PLACE"),seq=seq+1
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
WriteMSG(%ZTDY,MSG) ; Message
 ;
 ; Write RM(1), RM(2), and continue messages
 ;
 I '%ZTDY WRITE !
 E  D
 .	;
 .	WRITE $char(27)_"["_(%ZTDY+1)_";0H"_$char(27)_"[K"
 .	S $X=0
 .	S $Y=%ZTDY
 .	S %ZTDY=%ZTDY+1
 .	Q 
 ;
 WRITE $char(27)_"[7m"
 WRITE " "_MSG_" "_$char(27)_"[0m"
 ;
 Q 
 ;
VarSub(RM) ; Substitute variables into error message
 ;
 N X
 N V
 ;
 S X=0
 F  S X=$F(RM,"<<",X) Q:(X=0)  D
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	;
 .	Q:'($piece($E(RM,X+1,99),"<<",1)[">>") 
 .	;
 .	S V=$piece($E(RM,X,99),">>",1)
 .	;
 .	I ((V="")!(V=+V)) S V="<<"_V_">>"
 .	;
 .	;   #ACCEPT DATE=12/30/03;PGM=John Carroll;CR=unknown
 .	E  I ($E(V,1)="$"),(V["("),(V[")") XECUTE "set V="_V
 .	;
 .	E  I ($D(@V)#2) S V=@V
 .	E  S V=""
 .	;
 .	S RM=$E(RM,1,X-3)_V_$piece($E(RM,X,99),">>",2,99)
 .	Q 
 ;
 Q RM
 ;
SendMail(logError,%ZTSEQ,ET,RM) ; Error message array
 ;
 ; Send mail to users
 ;
 Q 
 ;
GetMSG(msgno,p1,p2) ; Parameter 2
 ;
 ; Error message handler
 ;
 N msg S msg=""
 ;
  N V1 S V1=msgno I ($D(^STBL("MSG",V1))#2) S msg=$$^MSG(msgno,p1,p2)
 E  D
 .	; I18N=OFF
 .	I msgno=3322 S msg=p1_" error"
 .	E  I msgno=3389 S msg="Error log sequence number "_p1
 .	E  I msgno=5362 S msg="  Press return to continue:  "
 .	E  I msgno=5363 S msg="Error in job "_p1_".  User ID: "_p2
 .	E  I msgno=5364 S msg="Error not defined"
 .	E  I msgno=5365 S msg="Error processor message"
 .	E  I msgno=5366 S msg="Error type:  "_p1_"  "_p2
 .	E  I msgno=5425 S msg="No routine"
 .	E  I msgno=5913 S msg="Error type "_p1_" Not logged"
 .	E  S msg="Unknown UTLERR message"
 .	; I18N=ON
 .	Q 
 ;
 Q msg
 ;
Log2File(isSecondary) ; Call because of secondary
 ;
 ; Log error to a system file
 ;
 N io S io=$$vClVobj($ST,"IO")
 N device
 N fileName S fileName="PROFILE_ERROR.LOG_"_$$vdat2str($P($H,",",1),"YEARMMDD")_"_"_$P($H,",",2)
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 ;
 S $P(vobj(io,1),"|",2)=$$SCAU^%TRNLNM("DIR")
 S $P(vobj(io,1),"|",1)=fileName
 ;
 S $P(vobj(io,1),"|",3)="WRITE/NEWV"
 ;
 D open^UCIO(io,$T(+0),"Log2File","io")
 ;
 D write^UCIO(io,"")
 D write^UCIO(io,"===================================================")
 D write^UCIO(io,"")
 D write^UCIO(io,$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$vtim2str($P($H,",",2),"24:60:SS"))
 D write^UCIO(io,"")
 D write^UCIO(io,"===================================================")
 D write^UCIO(io,"")
 ;
 S device=$P(vobj(io,1),"|",6)
 ;
 ;  #ACCEPT Date=12/05/2007;Pgm=RussellDS;CR=31014;Group=Bypass
 ;*** Start of code by-passed by compiler
 use device
 zshow "*"
 ;*** End of code by-passed by compiler ***
 ;
 D close^UCIO(io)
 ;
 WRITE !!,"Fatal error in UTLERR while executing error trap - "
 WRITE !,"Trapped in file ",device,!
 ;
 ; Return a "1" to the calling program to indicate that
 ; an error has occurred.
 ;  #ACCEPT Date=2009-04-06; Pgm=RussellDS; CR=39284; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S $ZT=""
 ZMESSAGE 1
 ;*** End of code by-passed by compiler ***
 ;
 I 'isSecondary HALT 
 ;
 K vobj(+$G(io)) Q 
 ;
GetError(inError) ; Standardize Error object based on last error
 ;
 I ($P(inError,",",3)="") D
 .	;
 .	;   #ACCEPT CR=29295; Date=12/13/2007; PGM=RussellDS; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	if (($ZE="")!($ZE="Unprocessed $ZERROR, see $ZSTATUS")) set $ZE="0,"_$P($ZS,",",2,999)
 .	set inError=$ZE
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 I (",CTRAP,CTRLY,CTRLC,"[(","_$P($P(inError,",",3),"-",3)_","))  D setProperty^UCERROR(.inError,3,"INTERRUPT")
 ;
 Q inError
 ;
ETLOC(inError) ; Return an error object as a standardized string
 ;
 I (",CTRAP,CTRLY,CTRLC,"[(","_$P($P(inError,",",3),"-",3)_","))  D setProperty^UCERROR(.inError,3,"INTERRUPT")
 ;
 Q $P(inError,",",3)_","_$P(inError,",",2)_","_$P($P(inError,",",3),"-",1)_","_$P(inError,",",4)_","_$P($P(inError,",",3),"-",3)
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61457^66611^Dan Russell^27300" ; Signature - LTD^TIME^USER^SIZE
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
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vOpen1() ; SEQ FROM ERROR WHERE DATE=:V1 AND SEQ=:SEQ
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 ;
 S vos4=$G(SEQ)
 S vos5=""
vL1a6 S vos5=$O(^ERROR(vos3,vos5),1) I vos5="" G vL1a0
 I '($D(^ERROR(vos3,vos5,vos4))>9) G vL1a6
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=vos4
 ;
 Q 1
 ;
vCatch4 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I '($P(error,",",3)["%PSL-E-IOOPEN") D close^UCIO(io)
 ;
 WRITE !!,"Fatal error while trapping error",!
 WRITE $P(error,",",4),!
 WRITE "Trapped in file ",fileName,!
 ;
 ; Return a "1" to the calling program to indicate that
 ; an error has occurred.
 ;   #ACCEPT Date=2009-04-06; Pgm=RussellDS; CR=39284; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S $ZT=""
 ZMESSAGE 1
 ;*** End of code by-passed by compiler ***
 ;
 I 'isSecondary HALT 
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 ; Ignore error and just return incoming RM
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N vERROR,$ET,$ES S vERROR=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D Log2File(0)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vERROR,$ET,$ES S vERROR=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D Log2File(0)
 D ZX^UCGMR(voxMrk) Q 
