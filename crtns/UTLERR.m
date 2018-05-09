UTLERR	; SCA error log and display utility
	;
	; **** Routine compiled from DATA-QWIK Procedure UTLERR ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	D NODSP
	;
	Q 
	;
NODSP	; Error not displayed
	;
	N %ZTINFO
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	D SAVEINFO(.%ZTINFO)
	;
	Tstart (vobj):transactionid="CS"
	D LOG
	Tcommit:$Tlevel 
	;
	K %ZTDY
	;
	D PROC
	;
	Q 
	;
DSP	; Error displayed on next line
	;
	N %ZTINFO
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	;
	D SAVEINFO(.%ZTINFO)
	;
	Tstart (vobj):transactionid="CS"
	D LOG
	Tcommit:$Tlevel 
	;
	S %ZTDY=0
	;
	D PROC
	;
	Q 
	;
DSP22	; Error displayed on line 22
	;
	N %ZTINFO
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
	;
	D SAVEINFO(.%ZTINFO)
	;
	Tstart (vobj):transactionid="CS"
	D LOG
	Tcommit:$Tlevel 
	;
	S %ZTDY=22
	;
	D PROC
	;
	Q 
	;
DSPBP	; Error displayed at bottom of page
	;
	N %ZTINFO
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap4^"_$T(+0)_""")"
	;
	D SAVEINFO(.%ZTINFO)
	;
	Tstart (vobj):transactionid="CS"
	D LOG
	Tcommit:$Tlevel 
	;
	S %ZTDY=23
	;
	D PROC
	;
	Q 
	;
ZE	; MUMPS errors
	;
	N %ZTINFO N %ZTS N ET N KEY1
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap5^"_$T(+0)_""")"
	;
	D SAVEINFO(.%ZTINFO)
	;
	Trollback:$Tlevel 
	;
	S %ZTS=$$ETLOC^%ZT
	Q:(%ZTS="") 
	;
	I $piece(%ZTS,",",1)="%PSL-E-DBFILER" D  Q 
	.	S (ER,vVER)=1
	.	S RM=$piece(%ZTS,",",4)
	.	I (RM="") S RM=$$MSG(3322,"DBFILER") ; ~p1 error
	.	S vVRM=RM
	.	S %ZTSEQ=""
	.	Q 
	;
	I $piece(%ZTS,",",1)="INTERRUPT" WRITE !!,%ZTS Q 
	;
	S ET=$piece(%ZTS,",",1)
	;
	; If replication is enabled and the error is generated on the secondary
	; machine, log the error to a system file to avoid database updates.
	I $$ROLE^PBSUTL="SECONDARY" D LOGFIL Q 
	;
	Tstart (vobj):transactionid="CS"
	D LOG
	;
	I %ZTLOG D RTNSAV
	Tcommit:$Tlevel 
	;
	; Turn on error flag
	S ER=1
	;
	; Default is scroll
	I '($D(%ZTDY)#2) S %ZTDY=0
	; Don't display
	E  I %ZTDY<0 K %ZTDY
	;
	D PROC
	;
	Q 
	;
PROC	; Process the error
	;
	N %ZTX
	;
	K RM
	;
	S %ZTZE=$get(%ZTZE)
	;
	S %ZTX=$get(ET)
	;
	; Use %ZTX=" " avoid error on instantiation
	I (%ZTX="") S %ZTX=" "
	;
	N stbler,vop1,vop2 S vop1=%ZTX,stbler=$$vDb5(%ZTX,.vop2)
	;
	I '(%ZTX=""),(+$G(vop2)'=+0) D
	.	S RM(1)=$P(stbler,$C(124),1)
	.	S RM(2)=$P(stbler,$C(124),6)
	.	Q 
	; Error not Defined
	E  D
	.	S %ZTX=""
	. S vop1=""
	.	S RM(1)=$S('(%ZTZE=""):$piece(%ZTZE,">",2,99),1:$$MSG(5364))
	.	S RM(2)=""
	.	S %ZTDSPET=1
	.	Q 
	;
	I '($D(%ZTBELL)#2) S %ZTBELL=$P(stbler,$C(124),3)
	I '($D(%ZTDSPET)#2) S %ZTDSPET=$P(stbler,$C(124),4)
	I %ZTDSPET S RM(1)="<"_ET_"> "_RM(1)
	I '($D(%ZTDSPSQ)#2) S %ZTDSPSQ=1
	I %ZTLOG,%ZTDSPSQ S RM(1)="#"_%ZTSEQ_" "_RM(1)
	I '($D(%ZTHALT)#2) S %ZTHALT=$P(stbler,$C(124),7)
	I '($D(%ZTBRK)#2) S %ZTBRK=$P(stbler,$C(124),8)
	I '($D(%ZTZQ)#2) S %ZTZQ=$P(stbler,$C(124),9)
	I '($D(%ZTGO)#2) S %ZTGO=$P(stbler,$C(124),10)
	;
	N cuvar S cuvar=$$vDb6()
	 S cuvar=$G(^CUVAR("%ET"))
	;
	I '($D(%ZTMAIL)#2) S %ZTMAIL=$P(stbler,$C(124),11)
	I %ZTMAIL,'$P(cuvar,$C(124),2) S %ZTMAIL=0
	;
	I '($D(%ZTHANG)#2) S %ZTHANG=+$P(stbler,$C(124),12)
	;
	; Environment (default to batch) not currently used
	I '($D(%ZTENV)#2) S %ZTENV=0
	;
	D VARSUB
	D WRITE
	;
	I (RM(2)="") D
	.	S %ZTX=RM(1)
	.	K RM
	.	S RM=%ZTX
	.	Q 
	;
	; Break requested in error trap
	I %ZTBRK BREAK 
	I %ZTMAIL D MAIL
	I %ZTHALT HALT 
	;
	;I18N=OFF
	;  #ACCEPT Date=05/10/05; PGM=Dan Russell; CR=15943
	;*** Start of code by-passed by compiler
	if %ZTZQ,$$^%ZSYS="GT.M" xecute "zgoto 1"
	;*** End of code by-passed by compiler ***
	;I18N=ON
	;
	S %ZTX=%ZTGO
	;
	; Clean up %ZT* variables, except for %ZTX
	K %ZTBELL,%ZTBRK,%ZTCOM,%ZTDSPET,%ZTDSPSQ,%ZTDY,%ZTENV
	K %ZTGO,%ZTHALT,%ZTHANG,%ZTI,%ZTLEN,%ZTLOG,%ZTMAIL
	K %ZTS,%ZTVAR,%ZTZE,%ZTZQ,%ZTZS
	;
	I '(%ZTX="") D @%ZTX Q 
	;
	Q 
	;
LOG	; Log the error if required
	; Always log all MUMPS errors and save all variables
	;
	N %ZTERRNO
	N %ET N %ZTCAT N %ZTDESC N %ZTZS
	;
	;Global scope variables/instance
	K %ZTPRIO,%ZTLOGD
	;
	S %ET=""
	;
	;Get Error info from $ZSTATUS, if defined
	S %ZTZS=$get(%ZTS)
	;
	;Default to stbler.id
	S %ZTCAT="STBLER"
	;
	S %ZTERRNO=$piece(%ZTZS,",",3)
	S %ZTDESC=$piece(%ZTZS,",",4)
	I %ZTERRNO>0 S %ZTCAT="MERROR"
	;
	S %ET=$piece(%ZTZS,",",5)
	I %ET["." S %ET=$piece(%ET,".",$L(%ET,"."))
	;
	;Default to log the error
	S %ZTLOG=1
	;
	;ET not set before calling error trap
	I ($get(ET)="") S ET=$piece(%ZTZS,",",1)
	I (ET="") S ET="ETUNDEF"
	;
	;ET is potentially re-formatted in %ZT
	I (%ET="") S %ET=ET
	;
	I ET?1"<".E D
	.	S ET=$E(ET,2,99)
	.	S %ZTVAR="ALL"
	.	S %ZTLOG=1
	.	Q 
	;
	D LOGIT
	;
	Q 
	;
LOGIT	;
	;
	N %ZJOB N %ZTI
	N %ZTX
	;
	; Don't allow interrupt during error logging.
	D DISABLE^%ZBREAK
	;
	S %ZJOB=$J
	;
	I '(%ET=""),$$vDbEx1() D
	.	N stbler S stbler=$$vDb7(%ET)
	.	S RM(1)=$P(stbler,$C(124),1)
	.	S RM(2)=$P(stbler,$C(124),6)
	.	;
	.	D VARSUB
	.	;
	.	S %ZTDESC=RM(1)
	.	S %ZTLOG=+$P(stbler,$C(124),2)
	.	Q 
	;No ET defined, default to log
	E  S %ZTLOG=1
	;
	I %ZTLOG D INIT
	;
	; Error log sequence number ~p1
	I $get(%ZTSEQ) S %ZTDESC=%ZTDESC_" - "_$$MSG(3389,%ZTSEQ)
	;
	; Return error priority level and post event
	S %ZTPRIO=$$ERRLOS^%ZFUNC(%ET,%ZTCAT,"",0,0,.%ZTDESC)
	;
	;If error not found, it won't be logged
	I %ZTPRIO S %ZTLOGD=1
	;
	;Don't log to ERROR table
	I '%ZTLOG Q 
	;
	K %ZTZE
	;
	S %ZTLOG=1
	;
	; Get variables to save for this error
	I '($D(%ZTVAR)#2) D
	.	I '(ET=""),($D(^STBL("ER",ET))#2) D  Q 
	..		N stbler S stbler=$$vDb7(ET)
	..		S %ZTVAR=$P(stbler,$C(124),5)
	..		Q 
	.	S %ZTVAR="ALL"
	.	Q 
	;
	S %ZTLEN=210-(5+$L(%ZTH)+$L(ET)+$L(%ZTSEQ)+11)
	;
	I ($D(%ZTX)#2) D
	.	N error9,vop1,vop2,vop3,vop4,vop5 S error9="",vop4=%ZTH,vop3=ET,vop2=%ZTSEQ,vop1="%ZTX",vop5=0
	.	;
	. S $P(error9,$C(124),1)=%ZTX
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop4,vop3,vop2,9,vop1)=$$RTBAR^%ZFUNC(error9) S vop5=1 Tcommit:vTp  
	.	Q 
	;
	I $$vStrUC(%ZTVAR)="ALL" D
	.	S %ZTX="%"
	.	I ($D(%)#2) D SAVE("%")
	.	F  S %ZTX=$order(@%ZTX) Q:(%ZTX="")  D SAVE(%ZTX)
	.	Q 
	E  D
	.	S %ZTX="%ZT"
	.	F  S %ZTX=$order(@%ZTX) Q:%ZTX'?1"%ZT".E  D SAVE(%ZTX)
	.	F %ZTI=1:1 S %ZTX=$piece(%ZTVAR,",",%ZTI) Q:(%ZTX="")  D SAVE(%ZTX)
	.	Q 
	;
	; Move STORE error non-array variables back to ^ERROR
	I ET="STORE" D
	.	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	.	;
	.	F  Q:'($$vFetch1())  D
	..		;
	..		N error9,vop6,vop7,vop8,vop9,vop10 S error9="",vop9=%ZTH,vop8=ET,vop7=%ZTSEQ,vop6=$P(rs,$C(9),1),vop10=0
	..		;
	..	 S $P(error9,$C(124),1)=$P(rs,$C(9),2)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop9,vop8,vop7,9,vop6)=$$RTBAR^%ZFUNC(error9) S vop10=1 Tcommit:vTp  
	..		Q 
	.	;
	. K ^TMP(%ZJOB)
	.	Q 
	;
	; Save stack related information
	D STKSAVE
	;
	Q 
	;
SAVE(%ZTX)	; Save variables
	;
	N %ZTD N %ZTY
	;
	I ",%ZTINFO,%ZTLEN,%ZTSEQ,%ZTX,"[(","_%ZTX_",") Q 
	;
	; Suppress warning due to .data used with indiretion
	;  #ACCEPT Date=03/14/06; Pgm=RussellDS; CR=20135
	S %ZTD=$D(@%ZTX)
	;
	I %ZTD#2 D
	.	S %ZTY=@%ZTX
	.	D save(%ZTX)
	.	Q 
	;
	F  S %ZTX=$query(@%ZTX) Q:(%ZTX="")  D
	.	S %ZTY=@%ZTX
	.	D save(%ZTX)
	.	Q 
	;
	Q 
	;
save(%ZTX)	; Update error table
	;
	N VAL
	;
	I $L(%ZTX)>%ZTLEN D
	.	; Strip off last 5 bytes
	.	S %ZTX=$E(%ZTX,1,%ZTLEN-5)
	.	;
	.	; Ensure quotes in string will be balanced
	.	F  Q:$L(%ZTX,"""")#2=0  S %ZTX=$E(%ZTX,1,$L(%ZTX)-1)
	.	;
	.	; Add ...") to indicate subscript was truncated
	.	S %ZTX=%ZTX_"..."")"
	.	Q 
	;
	; Replace $C(9) to avoid problems with result sets on this data
	I %ZTY[$char(9) S %ZTY=$$vStrRep(%ZTY,$char(9),"_$C(9)_",0,0,"")
	;
	S VAL=$E(%ZTY,1,400)
	;
	N error9,vop1,vop2,vop3,vop4,vop5 S error9="",vop4=%ZTH,vop3=ET,vop2=%ZTSEQ,vop1=%ZTX,vop5=0
	;
	S $P(error9,$C(124),1)=VAL
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop4,vop3,vop2,9,vop1)=$$RTBAR^%ZFUNC(error9) S vop5=1 Tcommit:vTp  
	;
	Q 
	;
SAVEINFO(%ZTINFO)	; Save ZSHow info to %ZTINFO array
	;
	 zshow "DILS":%ZTINFO
	;
	Q 
	;
STKSAVE	; Save device, lock, and stack information
	;
	N DSC N I N J
	;
	F I="D","I","L","S" I $D(%ZTINFO(I)) D
	.	;
	.	I (I="D") S DSC="#DEVICE"
	.	E  I (I="I") S DSC="#INTRINSIC"
	.	E  I (I="L") S DSC="#LOCK"
	.	E  S DSC="#STACK"
	.	;
	.	F J=1:1 Q:'($D(%ZTINFO(I,J))#2)  D
	..		;
	..		N DESC
	..		;
	..		S DESC=DSC_J
	..		;
	..		N error9,vop1,vop2,vop3,vop4,vop5 S error9="",vop4=%ZTH,vop3=ET,vop2=%ZTSEQ,vop1=DESC,vop5=0
	..		;
	..	 S $P(error9,$C(124),1)=$E(%ZTINFO(I,J),1,400)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop4,vop3,vop2,9,vop1)=$$RTBAR^%ZFUNC(error9) S vop5=1 Tcommit:vTp  
	..		Q 
	.	Q 
	;
	Q 
	;
INIT	; Set up top levels of error log
	;
	N DTE
	N %ZBL N I N SEQ
	N X N ZB
	;
	S ZB=""
	;
	; Translate control characters in $ZB
	S %ZBL=$L(($ZB))
	F I=1:1:%ZBL D
	.	S X=$E(($ZB),I)
	.	S ZB=ZB_$S(X?1C:"^"_$char((($ascii(X)+64)#128)),1:X)
	.	Q 
	;
	S DTE=$P($H,",",1)
	;
	; Get process unique sequence.  Allow up to 99 per second.  If
	; we're logging more than that per process, hang one second.
	D
	.	;
	.	N CNT S CNT=1
	.	;
	.	F  D  Q:'(SEQ="") 
	..		;
	..		S SEQ=1000000+$P($H,",",2)
	..		S SEQ=SEQ_$E(((1000000+($J#1000000))),2,7)
	..		S SEQ=SEQ_$E(((100+CNT)),2,3)
	..		;
	..		N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
	..		;
	..		I ''$G(vos1) D
	...			;
	...			S SEQ=""
	...			S CNT=CNT+1
	...			I (CNT>99) D
	....				;
	....				S CNT=1
	....				HANG 1
	....				Q 
	...			Q 
	..		Q 
	.	Q 
	;
	N error S error=$$vDbNew2(DTE,ET,SEQ)
	 S vobj(error,1)=""
	;
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),1)=$get(%UID)
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),2)=$P($H,",",2)
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),3)=$get(TLO)
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),4)=$J
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),6)=$ZA
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),7)=ZB
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),9)=$get(%DIR)
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),10)=$$vStrRep($get(%ZTCOM),$char(9),"_$C(9)_",0,0,"")
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(error) K vobj(error,-100) S vobj(error,-2)=1 Tcommit:vTp  
	;
	N error9,vop1,vop2,vop3,vop4,vop5 S error9="",vop4=DTE,vop3=ET,vop2=SEQ,vop1="",vop5=0
	;
	I ($D(%ZTH)#2) D
	. S vop1="%ZTH"
	. S $P(error9,$C(124),1)=%ZTH
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop4,vop3,vop2,9,vop1)=$$RTBAR^%ZFUNC(error9) S vop5=1 Tcommit:vTp  
	.	Q 
	;
	I ($D(%ZTSEQ)#2) D
	. S vop1="%ZTSEQ"
	. S $P(error9,$C(124),1)=%ZTSEQ
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop4,vop3,vop2,9,vop1)=$$RTBAR^%ZFUNC(error9) S vop5=1 Tcommit:vTp  
	.	Q 
	;
	S %ZTH=$P($H,",",1)
	S %ZTSEQ=SEQ
	;
	K vobj(+$G(error)) Q 
	;
WRITE	; Write out error message(s)
	;
	N I
	N MSG N X
	;
	; Don't display message (entry at NODSP)
	I '($D(%ZTDY)#2) Q 
	I $get(%IPMODE)["NOINT" Q 
	;
	I '($D(%ZTCOM)#2) S %ZTCOM=""
	;
	; Not running in interactive mode
	I '$$INTRACT^%ZFUNC Q 
	;
	;   <RETURN> to continue:
	S %ZTCOM=$E(%ZTCOM,1,50)_$S(%ZTHANG:$$MSG(5362),1:"")
	;
	Q:'$$TERM^%ZOPEN(0,0) 
	;
	USE 0
	I %ZTBELL WRITE *7
	;
	I %ZTDY S %ZTDY=%ZTDY-('(RM(1)=""))-('(RM(2)=""))+((%ZTCOM=""))
	;
	F I=1,2 I '(RM(I)="") D
	.	S MSG=RM(I)
	.	D WMSG
	.	Q 
	;
	Q:(%ZTCOM="") 
	;
	S MSG=%ZTCOM D WMSG
	;
	D TERM^%ZUSE(0,"FLUSH")
	;I18N=OFF
	;  #ACCEPT Date=09/13/06; Pgm=RussellDS; CR=23019; Group=BYPASS
	;*** Start of code by-passed by compiler
	xecute "read X:%ZTHANG"
	;*** End of code by-passed by compiler ***
	;I18N=ON
	;
	Q 
	;
WMSG	; Write RM(1), RM(2), and continue messages
	;
	I '%ZTDY WRITE !
	E  D
	.	WRITE $char(27)_"["_(%ZTDY+1)_";0H"_$char(27)_"[K"
	.	S $X=0 S $Y=%ZTDY S %ZTDY=%ZTDY+1
	.	Q 
	;
	WRITE $char(27)_"[7m"
	WRITE " "_MSG_" "_$char(27)_"[0m"
	;
	Q 
	;
RTNSAV	; Save routine info, last updated and error line text
	N vpc
	;
	N ELOC N ERR N ETYP N L1 N L2 N OFF N RTN N SETYP N TAG N X N XLT
	;
	D ET^%ZT(.SETYP,.ERR,.ETYP,.ELOC)
	;
	;  Value of $ZS
	S %ZTZS=$get(ERR)
	S %ZTZE=$$ETLOC^%ZT
	;
	; Log the value of $ZS
	N error9,vop1,vop2,vop3,vop4,vop5 S error9="",vop4=%ZTH,vop3=ET,vop2=%ZTSEQ,vop1="#ZS",vop5=0
	;
	S $P(error9,$C(124),1)=%ZTZS
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^ERROR(vop4,vop3,vop2,9,vop1)=$$RTBAR^%ZFUNC(error9) S vop5=1 Tcommit:vTp  
	;
	S RTN=$piece(ELOC,"^",2)
	S X=$piece(ELOC,"^",1)
	S vpc=((RTN="")) Q:vpc 
	;
	S TAG=$piece(X,"+",1)
	S OFF=+$piece(X,"+",2)
	;
	; No Routine
	S L1=$$MSG(5425)
	S L2=""
	;
	D ^%ZRTNLOD(RTN,"X",1,.XLT)
	S L1=$get(X(2))
	;
	I '(TAG=""),($D(XLT(TAG))#2) S L2=$get(X(XLT(TAG)+OFF))
	;
	N error S error=$$vDb4(%ZTH,ET,%ZTSEQ)
	 S vobj(error,1)=$G(^ERROR(vobj(error,-3),vobj(error,-4),vobj(error,-5),1))
	 S vobj(error,2)=$G(^ERROR(vobj(error,-3),vobj(error,-4),vobj(error,-5),2))
	 S vobj(error,3)=$G(^ERROR(vobj(error,-3),vobj(error,-4),vobj(error,-5),3))
	;
	S vobj(error,-100,1)="",$P(vobj(error,1),$C(124),5)=$E(%ZTZE,1,40)
	S vobj(error,-100,2)="",$P(vobj(error,2),$C(124),1)=$$vStrRep(L1,$char(9),"_$C(9)_",0,0,"")
	S vobj(error,-100,3)="",$P(vobj(error,3),$C(124),1)=$$vStrRep(L2,$char(9),"_$C(9)_",0,0,"")
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(error) K vobj(error,-100) S vobj(error,-2)=1 Tcommit:vTp  
	;
	K vobj(+$G(error)) Q 
	;
VARSUB	; Substitute variables into error message
	;
	N I
	;
	F I=1,2 D VSUB
	;
	Q 
	;
VSUB	;
	;
	N X
	N V
	;
	S X=0
	;
	F  S X=$F(RM(I),"<<",X) Q:X=0  D
	.	I $piece($E(RM(I),X+1,99),"<<",1)'[">>" Q 
	.	;
	.	S V=$piece($E(RM(I),X,99),">>",1)
	.	D V1
	.	S RM(I)=$E(RM(I),1,X-3)_V_$piece($E(RM(I),X,99),">>",2,99)
	.	Q 
	;
	Q 
	;
V1	;
	;
	I (V="")!V S V="<<"_V_">>" Q 
	;  #ACCEPT DATE=12/30/03;PGM=John Carroll;CR=unknown
	I $E(V,1)="$",V["(",V[")" XECUTE "S V="_V Q 
	I ($D(@V)#2) S V=@V Q 
	S V=""
	;
	Q 
	;
MAIL	; Send mail to users
	N vpc
	;
	N I
	N IO N MSG N SUBJ N USER N USERS N X
	;
	N cuvar,vop1 S cuvar=$$vDb6()
	 S cuvar=$G(^CUVAR("%ET"))
	 S vop1=$G(^CUVAR("SPLDIR"))
	S USERS=$P(cuvar,$C(124),3)
	S vpc=((USERS="")) Q:vpc 
	;
	S IO="MAIL"_$J_".TMP"
	;
	;Directory specific spooler
	S X=$P(vop1,$C(124),1)
	;
	;Logical reference to spooler
	I (X="") S X=$$SCAU^%TRNLNM("SPOOL")
	;
	;System-wide spooler
	I (X="") S X=$$SCA^%TRNLNM("SPOOL")
	;
	;User's home directory
	I (X="") S X=$$HOME^%TRNLNM
	;
	;Can't open file
	S vpc=('$$FILE^%ZOPEN(IO,"WRITE/NEWV",1)) Q:vpc 
	;
	; Error in job ~p1 .  User ID: ~p2
	USE IO WRITE !,$$MSG(5363,$J,$S(($D(%UID)#2):%UID,1:"???")),!
	;
	; Error type:  ~p1   log sequence ~p2
	I %ZTLOG WRITE !,$$MSG(5366,ET,%ZTSEQ)
	; Error type:  ~p1   not loged
	E  WRITE !,$$MSG(5913,ET),!
	;
	I $D(RM)=1 WRITE !,RM
	E  WRITE !,RM(1),!,RM(2)
	;
	CLOSE IO
	;
	; Error in job ~p1.  User ID: ~p2
	S SUBJ=$$MSG(5365)
	F I=1:1 S USER=$piece(USERS,",",I) Q:(USER="")  D
	.	S X=$$MAIL^%OSSCRPT(.MSG,USER,SUBJ,IO)
	.	Q 
	;
	S X=$$DELETE^%OSSCRPT(IO)
	;
	Q 
	;
STORE	; Handle store error - save and kill all non-array variables
	;
	N %ZJOB
	;
	S %ZJOB=$J
	;
	K ^TMP(%ZJOB)
	;
	N tmperr9,vop1,vop2,vop3 S tmperr9="",vop2=%ZJOB,vop1="",vop3=0
	;
	I ($D(%ZTX)#2) D
	. S vop1="%ZTX"
	. S $P(tmperr9,$C(124),1)=%ZTX
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(vop2,vop1)=$$RTBAR^%ZFUNC(tmperr9) S vop3=1 Tcommit:vTp  
	.	Q 
	;
	I ($D(%ZTI)#2) D
	. S vop1="%ZTI"
	. S $P(tmperr9,$C(124),1)=%ZTI
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(vop2,vop1)=$$RTBAR^%ZFUNC(tmperr9) S vop3=1 Tcommit:vTp  
	.	Q 
	;
	I ($D(%)#2) D
	. S vop1="%"
	. S $P(tmperr9,$C(124),1)=%
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(vop2,vop1)=$$RTBAR^%ZFUNC(tmperr9) S vop3=1 Tcommit:vTp  
	.	Q 
	;
	S %ZTX="%"
	;
	F %ZTI=1:1 S %ZTX=$order(@%ZTX) Q:(%ZTX="")  D
	.	I ($D(@%ZTX)#2),",%ZTI,%ZTX,"'[(","_%ZTX_",") D
	..		;
	..		N tmperr9,vop4,vop5,vop6 S tmperr9="",vop5=%ZJOB,vop4=%ZTX,vop6=0
	..		;
	..	 S $P(tmperr9,$C(124),1)=@%ZTX
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(vop5,vop4)=$$RTBAR^%ZFUNC(tmperr9) S vop6=1 Tcommit:vTp  
	..		;
	..		;    #ACCEPT Date=08/03/06; Pgm=RussellDS; CR=22445; GROUP=SCOPE
	..		K @%ZTX
	..		Q 
	.	Q 
	;
	Q 
	;
MSG(msgno,p1,p2)	;Private;Error message handler
	N msg
	;
	 N V1 S V1=msgno I ($D(^STBL("MSG",V1))#2) S msg=$$^MSG(msgno,$get(p1),$get(p2))
	E  D
	.	; I18N=OFF
	.	I msgno=3322 S msg=$get(p1)_" error" Q 
	.	I msgno=3389 S msg="Error log sequence number "_$get(p1) Q 
	.	I msgno=5362 S msg="  Press return to continue:  " Q 
	.	I msgno=5363 S msg="Error in job "_$get(p1)_".  User ID: "_$get(p2) Q 
	.	I msgno=5364 S msg="Error not defined" Q 
	.	I msgno=5365 S msg="Error processor message" Q 
	.	I msgno=5366 S msg="Error type:  "_$get(p1)_"  "_$get(p2) Q 
	.	I msgno=5425 S msg="No routine" Q 
	.	I msgno=5913 S msg="Error type "_$get(p1)_" Not logged" Q 
	.	I ($get(msg)="") S msg="Unknown UTLERR message" Q 
	.	; I18N=ON
	.	Q 
	;
	Q msg
	;
LOGFIL	;Log updates to a system file
	;
	N %ZTFILE
	;
	S %ZTFILE=$$FILE^%TRNLNM("PROFILE_ERROR.LOG","SCAU$DIR")
	I '$$FILE^%ZOPEN(%ZTFILE,"WRITE/APPEND",2,1024) Q 
	USE %ZTFILE
	;
	WRITE !,"===================================================",!
	WRITE $$vdat2str($P($H,",",1),"DD-MON-YEAR")
	WRITE $$TIM^%ZM($P($H,",",2),"24:60:SS")
	WRITE !,"===================================================",!
	;
	 zshow "*"
	;
	WRITE !,"===================================================",!
	CLOSE %ZTFILE
	USE 0
	;
	Q 
	;
vSIG()	;
	Q "60660^55502^Dan Russell^21854" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrRep(object,p1,p2,p3,p4,qt)	; String.replace
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
vStrFnd(object,p1,p2,p3,qt)	; String.find
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (p1="") Q $SELECT(p2<1:1,1:+p2)
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S p2=$F(object,p1,p2)
	I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
	.	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
	.	Q 
	Q p2
	;
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(ERROR,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordERROR"
	I '$D(^ERROR(v1,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,ERROR" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb5(v1,v2out)	;	voXN = Db.getRecord(STBLER,,1,-2)
	;
	N stbler
	S stbler=$G(^STBL("ER",v1))
	I stbler="",'$D(^STBL("ER",v1))
	S v2out='$T
	;
	Q stbler
	;
vDb6()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDb7(v1)	;	voXN = Db.getRecord(STBLER,,0)
	;
	N stbler
	S stbler=$G(^STBL("ER",v1))
	I stbler="",'$D(^STBL("ER",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,STBLER" X $ZT
	Q stbler
	;
vDbEx1()	;	min(1): DISTINCT KEY FROM STBLER WHERE KEY=:%ET
	;
	N vsql1
	S vsql1=$G(%ET) I vsql1="" Q 0
	I '($D(^STBL("ER",vsql1))#2) Q 0
	Q 1
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(ERROR)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordERROR",vobj(vOid,-2)=0
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	VAR,VAL FROM TMPERR9 WHERE JOB=:%ZJOB
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(%ZJOB) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TMP(vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^TMP(vos2,vos3))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
	;
vOpen2()	;	SEQ FROM ERROR WHERE DATE=:DTE AND SEQ=:SEQ
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(DTE) I vos2="" G vL2a0
	;
	S vos3=$G(SEQ) I vos3="" G vL2a0
	S vos4=""
vL2a5	S vos4=$O(^ERROR(vos2,vos4),1) I vos4="" G vL2a0
	I '($D(^ERROR(vos2,vos4,vos3))>9) G vL2a5
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos3
	;
	Q 1
	;
vReSav1(error)	;	RecordERROR saveNoFiler()
	;
	N vD,vN S vN=-1
	I '$G(vobj(error,-2)) F  S vN=$O(vobj(error,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(error,vN)) S:vD'="" ^ERROR(vobj(error,-3),vobj(error,-4),vobj(error,-5),vN)=vD
	E  F  S vN=$O(vobj(error,-100,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(error,vN)) S:vD'="" ^ERROR(vobj(error,-3),vobj(error,-4),vobj(error,-5),vN)=vD I vD="" ZWI ^ERROR(vobj(error,-3),vobj(error,-4),vobj(error,-5),vN)
	Q
	;
vtrap1	;	Error trap
	;
	N vERROR S vERROR=$ZS
	S $ZT=""
	D ^%ET Q 
	Q 
	;
vtrap2	;	Error trap
	;
	N vERROR S vERROR=$ZS
	S $ZT=""
	D ^%ET Q 
	Q 
	;
vtrap3	;	Error trap
	;
	N vERROR S vERROR=$ZS
	S $ZT=""
	D ^%ET Q 
	Q 
	;
vtrap4	;	Error trap
	;
	N vERROR S vERROR=$ZS
	S $ZT=""
	D ^%ET Q 
	Q 
	;
vtrap5	;	Error trap
	;
	N vERROR S vERROR=$ZS
	S $ZT=""
	D ^%ET Q 
	Q 
