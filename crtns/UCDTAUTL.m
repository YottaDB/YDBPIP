UCDTAUTL	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCDTAUTL ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	Q 
	;
	; ---------------------------------------------------------------------
JRNFUNCS(KEYWORDS)	; DEPRECATED;
	;
	Q 
	;
	; ---------------------------------------------------------------------
getSysKwd(KWD,caKwd)	;
	N kwdRow S kwdRow=$$kwdRow(KWD,.caKwd)
	Q $P(kwdRow,$C(124),2)
	;
	; ---------------------------------------------------------------------
keywords(KWDS)	; supported keywords
	;
	S KWDS("%BatchExit")="vEXIT|0|Boolean"
	S KWDS("%BatchRestart")="vRESTART|0|Boolean"
	S KWDS("%ClientVersionID")="%VNC|1|Number"
	S KWDS("%CompanyName")="%CO|1|String"
	S KWDS("%CurrentDate")="$P($H,"","",1)|-1|Date"
	S KWDS("%CurrentTime")="$P($H,"","",2)|-1|Time"
	S KWDS("%EffectiveDate")="EFD|0|Date"
	S KWDS("%Identifier")="%IDENT|1|String"
	S KWDS("%InputTimeOut")="%TO|1|Number"
	S KWDS("%Library")="%LIBS|0|String"
	S KWDS("%ProcessID")="$J|-1|Number"
	S KWDS("%ProcessMode")="%O|0|Number"
	S KWDS("%RoutineName")="$T(+0)|-1|String"
	S KWDS("%ServerChannelID")="%SVCHNID|1|String"
	S KWDS("%SessionID")="%TOKEN|1|String"
	S KWDS("%SystemCurrency")="%CRCD|1|String"
	S KWDS("%SystemDate")="TJD|1|Date"
	S KWDS("%UserClass")="%UCLS|0|String"
	S KWDS("%UserID")="%UID|0|String"
	S KWDS("%UserName")="$$USERNAM^%ZFUNC|-1|String"
	S KWDS("%UserStation")="TLO|0|String"
	S KWDS("%VerifyMode")="(%O=2)|-1|Boolean"
	S KWDS("%VersionID")="%VN|1|String"
	;
	Q 
	;
	; ---------------------------------------------------------------------
kwdRow(KWD,caKwd)	;
	I '$D(caKwd) D keywords(.caKwd)
	;
	; found as supplied, return complete descriptor, cf UCGM
	I ($D(caKwd(KWD))#2) Q KWD_"|"_caKwd(KWD)
	;
	; Not found, try case insensitive lookup, but do not modify caKwd()
	N KWU S KWU=$$vStrUC(KWD)
	N kwd S kwd=""
	F  S kwd=$order(caKwd(kwd)) Q:(kwd="")  Q:$$vStrUC(kwd)=KWU 
	;
	; If not found, even after lookup, return empty string
	I (kwd="") Q ""
	;
	; found, return complete descriptor, cf UCGM
	Q kwd_"|"_caKwd(kwd)
	;
	; ---------------------------------------------------------------------
kwdRowDef()	; return defintion of Row returned by $$kwdRow()
	Q ("KEYWORD,DES,GLOBALSCOPE,CLASS"_$char(9)_124)
	;
	; ---------------------------------------------------------------------
masks(co)	; compiler options /MECH=REFARR:RW
	;
	N msk
	;
	; Ensure Boolean mask value
	I '($D(co("mask""Boolean"))#2) D
	.	I '($get(%MSKL)="") S co("mask","Boolean")=$E(%MSKL,1)_","_$E(%MSKL,2) Q 
	.	;
	.	S msk=""
	.	D
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	..		N rsD,vos1,vos2 S rsD=$$vOpen1()
	..		I $$vFetch1() S msk=rsD
	..		Q 
	.	I '(msk="") S co("mask","Boolean")=$E(msk,1)_","_$E(msk,2) Q 
	.	;
	.	S co("mask","Boolean")="+,-"
	.	Q 
	;
	; Ensure Date mask value
	I '($D(co("mask""Date"))#2) D
	.	I '($get(%MSKD)="") S co("mask","Date")=%MSKD Q 
	.	;
	.	S msk=""
	.	D
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	..		N rsD,vos3,vos4 S rsD=$$vOpen2()
	..		I $$vFetch2() S msk=rsD
	..		Q 
	.	I '(msk="") S co("mask","Date")=msk Q 
	.	;
	.	S co("mask","Date")="YEAR-MM-DD"
	.	Q 
	;
	; Ensure Time mask value
	I '($D(co("mask""Time"))#2) D
	.	I '($get(%MSKT)="") S co("mask","Time")=%MSKT Q 
	.	;
	.	S msk=""
	.	D
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
	..		N rsT,vos5,vos6 S rsT=$$vOpen3()
	..		I $$vFetch3() S msk=rsT
	..		Q 
	.	I '(msk="") S co("mask","Time")=msk Q 
	.	;
	.	S co("mask","Time")="24:60:SS"
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
UCINIT(commands)	; Compiler commands /NOREQ/MECH=REFARR:RW
	N grp N val
	N usrOpts ; values from $HOME/UCOPTS.ini
	;
	; Step 1: User supplied overwrites
	N file S file=$$SCAU^%TRNLNM("UCOPTS")
	I '(file="") D
	.	N path S path=$$PARSE^%ZFUNC(file,"DIR")
	.	I file[path S file=$E(file,$L(path)+1,1048575)
	.	D decodeFile^UCGMC(path,file,.usrOpts)
	.	F grp="WARN","INFO","OPTIMIZE","Options" D
	..		S val=""
	..		F  S val=$order(usrOpts(grp,val)) Q:val=""  D
	...			I '($D(commands(grp,val))#2) S commands(grp,val)=usrOpts(grp,val)
	...			Q 
	..		Q 
	.	Q 
	;
	; Step 2: Environment standard values
	I $get(commands("boot","restrictionlevel"))'<3 Q 
	;
	N N
	N opt N Options
	;
	D ^UCOPTS(.Options)
	F grp="WARN","INFO","OPTIMIZE","Options" D
	.	S opt=$get(Options(grp))
	.	F N=1:1:$L(opt,",") D
	..		S val=$piece(opt,",",N)
	..		I (val="") Q 
	..		I ($D(commands(grp,val))#2) Q 
	..		S commands(grp,val)=1
	..		Q 
	.	Q 
	;
	Q 
	;
vSIG()	;
	Q "60809^23915^Frans S.C. Witte^14970" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vRsRowGC(vNms,vTps)	; Runtime ResultSet.getRow().getColumns()
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	N vL S vL="" N vN N vO N vT
	F vO=1:1:$S((vNms=""):0,1:$L(vNms,",")) D
	.	S vN=$piece(vNms,",",vO)
	.	S vT=$E(vTps,(vO-1)*2+1)
	.	I "TUF"[vT S vT="String"
	.	E  S vT=$piece("Blob,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",vT)-1)
	.	S $PIECE(vL,",",v0)=vT_" "_vN
	.	Q 
	Q vL
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vOpen1()	;	MSK FROM DBCTLDVFM WHERE TYP='L'
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	I '($D(^DBCTL("SYS","DVFM","L"))#2) G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vos2=$G(^DBCTL("SYS","DVFM","L"))
	S rsD=$P(vos2,"|",6)
	S vos1=0
	;
	Q 1
	;
vOpen2()	;	MSK FROM DBCTLDVFM WHERE TYP='D'
	;
	;
	S vos3=2
	D vL2a1
	Q ""
	;
vL2a0	S vos3=0 Q
vL2a1	I '($D(^DBCTL("SYS","DVFM","D"))#2) G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos3=0 Q 0
	;
	S vos3=100
	S vos4=$G(^DBCTL("SYS","DVFM","D"))
	S rsD=$P(vos4,"|",6)
	S vos3=0
	;
	Q 1
	;
vOpen3()	;	MSK FROM DBCTLDVFM WHERE TYP='T'
	;
	;
	S vos5=2
	D vL3a1
	Q ""
	;
vL3a0	S vos5=0 Q
vL3a1	I '($D(^DBCTL("SYS","DVFM","T"))#2) G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos5=0 Q 0
	;
	S vos5=100
	S vos6=$G(^DBCTL("SYS","DVFM","T"))
	S rsT=$P(vos6,"|",6)
	S vos5=0
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N vEx S vEx=$ZS
	S msk=""
	Q 
	;
vtrap2	;	Error trap
	;
	N vEx S vEx=$ZS
	S msk=""
	Q 
	;
vtrap3	;	Error trap
	;
	N vEx S vEx=$ZS
	S msk=""
	Q 
