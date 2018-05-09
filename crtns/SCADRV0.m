SCADRV0(FN,INPUT)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV0 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	; Compile procedure SCAUTL1 and build routine NOISO
	;
	N DISPLAY N EXIT N STATLIN
	N OLDTIME N VMSOPT
	N %MSGS
	;
	; Do single function
	I $get(FN)'="" D ONEFUNC(FN,$get(INPUT)) Q 
	;
	S STATLIN=0
	S DISPLAY=1
	S EXIT=0
	;
	F  Q:'('EXIT)  D NXTMENU Q:ER 
	;
	Q 
	;
ONEFUNC(FN,INPUT)	;
	; Single function - call from session or from %IPMODE non-interactive
	;
	N NOSUB
	;
	I $E(FN,1)'="@" S FN="@"_FN
	;
	I $$vStrUC(($get(%IPMODE)))["NOINT" S NOSUB=1
	E  S NOSUB=0
	;
	D PROC(FN,INPUT,1,NOSUB)
	Q 
	;
NXTMENU	; Next menu
	;
	N MENUNO
	N INPUT N PRMPT N RPTX N X
	;
	S ER=0
	;
	I '$get(MENU) S EXIT=1 Q 
	;
	S MENUNO=$piece(MENU(MENU),"|",1)
	S PRMPT=$piece(MENU(MENU),"|",2)
	;
	I DISPLAY D DISPLAY
	I STATLIN D STATLIN
	;
	; Check menu restrictions
	I MENU=1,$$CHKREST S ER=1 Q 
	;
	; Update time change
	I ($P($H,",",2)-$piece(($get(OLDTIME)),"|",2))<60 D TIME
	;
	D DSPMENU(MENU,PRMPT)
	;
	; Get answer to prompt
	S %fkey=""
	;
	I '%AUTOMNU S X=$$READ($get(RPTX)) K RPTX
	I %AUTOMNU D
	.	N %O
	.	S %O=99
	.	WRITE vcps
	.	S X=$$SELECT^SCADRV2("")
	.	WRITE vcpr
	.	S X=$$READ($get(RPTX))
	.	K RPTX
	.	Q 
	;
	I %fkey="DSP" S RPTX=X D TERMSET^SCADRV D DISPLAY Q 
	I %fkey="TIM" S EXIT=1 Q 
	;
	; Clear any displayed messages
	I $D(%MSGS) D CLRMSGS
	;
	; Must handle first
	I %fkey="KYB" D KYB^SCADRV2 D STATLIN
	;
	; Save input for DUP
	I X'="" S $piece(MENU(MENU),"|",3)=X
	I $E(X,$L(X))="?" S %fkey="SEL"
	;
	I %fkey="CUU" D BACKUP Q 
	I %fkey="DUP" S X=$piece(MENU(MENU),"|",3) WRITE X
	I %fkey="END" D CLRMENU Q 
	I %fkey="ESC" S EXIT=1 Q 
	I %fkey="FND" D  Q:X="" 
	.	S X=$$FIND^SCADRV2(X)
	.	S STATLIN=1
	.	D TIME
	.	I X="" Q 
	.	I $D(%MSGS) D CLRMSGS
	.	Q 
	I %fkey="HLP" D HELP^SCADRV2(X) D TIME Q 
	I %fkey="SEL" D  Q:X="" 
	.	S X=$$SELECT^SCADRV2(X)
	.	S STATLIN=1
	.	D TIME
	.	I X="" Q 
	.	I $D(%MSGS) D CLRMSGS
	.	Q 
	; Use the UP ARROW key to return to the menu~p1
	I X="" S RM=$$^MSG(2842,$char(7)) D PNTRM(%AUTOMNU) Q 
	;   Save input (again) for DUP
	S $piece(MENU(MENU),"|",3)=X
	;
	; Handle block mode type input
	S INPUT=""
	I $piece(X,",",2,99)'="" S INPUT="/,"_$piece(X,",",2,99) S X=$piece(X,",",1)
	;
	; Check input and dispatch if necessary
	D PROC(X,INPUT)
	I ER!(ER="W") D PNTRM(%AUTOMNU)
	;
	S ER=0
	;
	Q 
	;
PROC(fn,INPUT,NOMENU,NOSUB)	; Check menu or function selection
	; Call function if valid, check for sub-functions and loop if selected.
	;
	N DISPEXIT N EXIT N SUB
	N SEQ
	N %BLK
	;
	S EXIT=0
	S DISPEXIT=0
	I $get(INPUT)'="" S %BLK=INPUT
	;
	; Loop here for sub-functions
	F  Q:'('EXIT)  D  Q:ER 
	.	;
	.	N %FN N DESC
	.	;
	.	N scatbl
	.	S %FN=$$VALIDSEL(fn,.scatbl)
	.	I ER S EXIT=1 K vobj(+$G(scatbl)) Q 
	.	;
	.	; Display choice if using menu and not at sub-menu
	.	I '$get(SUB)!$get(NOMENU) WRITE $$CUP^%TRMVT(41,4+MENU),vcll,DESC
	.	;
	.	; New menu selected
	.	I %FN?.N D NEWMENU S EXIT=1 K vobj(+$G(scatbl)) Q 
	.	;
	.	; Call function
	.	D DISPATCH(.scatbl)
	.	I DISPEXIT S EXIT=1 K vobj(+$G(scatbl)) Q 
	.	; Force redisplay
	.	S DISPLAY=1
	.	I ER!$get(NOSUB) S EXIT=1 K vobj(+$G(scatbl)) Q 
	.	;
	.	; If no submenus, set up for display of ER=W messages
	.	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	.	I '$G(vos1) D  K vobj(+$G(scatbl)) Q 
	..		;
	..		S EXIT=1
	..		I (ER="W") S %MSGS(23)=""
	..		Q 
	.	;
	.	I ER="W" D PNTRM()
	.	; Select from submenu
	.	S fn=$$SUBMENU(%FN)
	.	I fn="" S EXIT=1 K vobj(+$G(scatbl)) Q 
	.	S SUB=1
	.	K vobj(+$G(scatbl)) Q 
	;
	Q 
	;
DISPATCH(scatbl)	; Dispatch to selected function
	;
	N NOBRK N NOREST N NOSUB N vVER
	N %JRNL N I N JOB
	N %ID N DRVVARS N PGM N PREP N SYSVARS N TFKDEF N vclear N vcpr
	N vcps N vidinc N vidoff N vidrev N vstatus N vVRM N X
	;
	; Check menu restrictions
	I $$CHKREST S (ER,DISPEXIT)=1 Q 
	;
	S %ID=$$SYSLOG ; Log function start
	S JOB=$J
	S %JRNL=0 ; Journal count
	;
	; Set system variables.   %sn - System name
	I $P(vobj(scatbl),$C(124),11)'=%SN S %SN=$P(vobj(scatbl),$C(124),11) D %SN Q:ER 
	;
	S NOREST=$P(vobj(scatbl),$C(124),14)
	S NOBRK=$P(vobj(scatbl),$C(124),15)
	;
	; Save variables
	N savevar,vop1,vop2 S vop1=JOB,savevar=$$vDb16(JOB,.vop2)
	S $P(savevar,$C(124),1)=MENU
	S $P(savevar,$C(124),2)=%ID
	S $P(savevar,$C(124),3)=%SN
	S $P(savevar,$C(124),4)=%FN
	S $P(savevar,$C(124),5)=$P(vobj(scatbl),$C(124),3)
	S $P(savevar,$C(124),6)=NOREST
	S $P(savevar,$C(124),7)=NOBRK
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(0,"SAVEVAR",vop1)=$$RTBAR^%ZFUNC(savevar) S vop2=1 Tcommit:vTp  
	;
	; Save system variables
	N savesys S savesys=$$vDb2(JOB)
	 S vobj(savesys,1,1)="" N von S von="" F  S von=$O(^TMP(0,"SAVESYS",vobj(savesys,-3),von)) quit:von=""  S vobj(savesys,1,1)=vobj(savesys,1,1)_^TMP(0,"SAVESYS",vobj(savesys,-3),von)
	S vobj(savesys,1,1)=%VSAVE
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SAVESYFL(savesys,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(savesys,-100) S vobj(savesys,-2)=1 Tcommit:vTp  
	;
	; Save menu information
	F I=1:1:MENU D
	.	N tmpmenu,vop3,vop4,vop5 S vop4=JOB,vop3=I,tmpmenu=$$vDb17(JOB,I,.vop5)
	. S $P(tmpmenu,$C(124),1)=$piece(MENU(I),"|",1)
	. S $P(tmpmenu,$C(124),2)=$piece(MENU(I),"|",2)
	. S $P(tmpmenu,$C(124),3)=$piece(MENU(I),"|",3)
	. S $P(tmpmenu,$C(124),4)=$piece(MENU(I),"|",4)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(0,vop4,vop3)=$$RTBAR^%ZFUNC(tmpmenu) S vop5=1 Tcommit:vTp  
	.	Q 
	;
	; Restrict restore of this process
	I NOREST D  K:ER vobj(+$G(savesys)) Q:ER 
	.	N norest,vop6,vop7 S vop6=JOB,norest=$$vDb18(JOB,.vop7)
	. S vop6=JOB
	. S $P(norest,$C(124),2)=$P($H,",",2)
	. S $P(norest,$C(124),1)=$P($H,",",1)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^%ZNOREST(vop6)=$$RTBAR^%ZFUNC(norest) S vop7=1 Tcommit:vTp  
	.	Q 
	;
	I NOBRK D DISABLE^%ZBREAK ; Function not interruptable
	;
	S ER=0
	K RM,%MSGS
	;
	S PREP=$P(vobj(scatbl),$C(124),2) ; Pre-processor
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	I PREP'="" XECUTE PREP
	;
	I $get(ER) D PNTRM(1) K vobj(+$G(savesys)) Q 
	;
	S PGM=$P(vobj(scatbl),$C(124),4)
	;
	K %ACRREST,%AUTOMNU,DESC,I,MENU,MENUNO,NEWPRMPT,NOBRK
	K NOREST,OLDTIME,PREP,PRMPT,TFKDEF,%VSAVE,X
	;
	; Add function to PROCESSID table
	D
	.	;
	.	N IPCATTS
	.	;
	.	S IPCATTS("FUNC")=%FN
	.	;
	.	D SETATTS^IPCMGR(.IPCATTS)
	.	Q 
	;
	D
	.	N $ZT
	.	S $ZT=$$SETZT^%ZT(%ET)
	.	D DOPGM
	.	Q 
	;
	; Remove function from PROCESSID table - protect ER and RM
	D
	.	;
	.	N ER N IPCATTS N RM
	.	;
	.	S IPCATTS("FUNC")=""
	.	;
	.	D SETATTS^IPCMGR(.IPCATTS)
	.	Q 
	;
	; Based on trapping, ER may not be returned correctly, so also
	; need to examine vVER and vVRM, which will be returned from UTLERR.
	I ($get(ER)=0),$get(vVER) S ER=1
	I ($get(ER)'=0),($get(RM)=""),'($get(vVRM)="") S RM=vVRM
	;
	S JOB=$J
	;
	N savedrv,vop8,vop9 S vop8=JOB,savedrv=$$vDb19(JOB)
	 S vop9="" N von S von="" F  S von=$O(^TMP(0,"SAVEDRV",vop8,von)) quit:von=""  S vop9=vop9_^TMP(0,"SAVEDRV",vop8,von)
	S DRVVARS=vop9
	;
	N savesys2,vop10,vop11 S vop10=JOB,savesys2=$$vDb20(JOB)
	 S vop11="" N von S von="" F  S von=$O(^TMP(0,"SAVESYS",vop10,von)) quit:von=""  S vop11=vop11_^TMP(0,"SAVESYS",vop10,von)
	S SYSVARS=vop11
	;
	LOCK 
	;
	USE 0 D TERMSET^SCADRV ; Reset terminal
	I $get(ER) D PNTRM(ER) S ER=0 ; Display ER=1 messages
	;
	; Execute post procecessor
	N savevar2,vop12 S savevar2=$$vDb16(JOB,.vop12)
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	I $G(vop12),($P(savevar2,$C(124),5)'="") XECUTE $P(savevar2,$C(124),5)
	I ('$G(vop12))!($P(savevar2,$C(124),6)) K ^%ZNOREST(JOB)
	I ('$G(vop12))!($P(savevar2,$C(124),7)) D ENABLE^%ZBREAK
	;
	; Reset variables
	I '$$RESET() S DISPEXIT=1 K vobj(+$G(savesys)) Q 
	D SYSLOGXT(%ID) ; Log function completed
	;
	K vobj(+$G(savesys)) Q 
	;
DOPGM	; Call the program
	;
	N fn N INPUT N vcll N %OPMODE
	;
	K %SFC
	D @PGM
	;
	Q 
	;
READ(x)	; Read input and return it
	; Partition reads into 60 seconds portions and display time in between
	;
	N EXIT
	N TIMEREM N TIM
	;
	S EXIT=0
	S TIMEREM=%TO
	S TIM=60
	S x=$get(x)
	WRITE vcps,x,vcpr
	;
	F  Q:'('EXIT)  D  Q:ER 
	.	I TIMEREM<60 S TIM=TIMEREM
	.	S x=$$TERM^%ZREAD(x,38,""," ",TIM,1)
	.	I %fkey'="TIM" S EXIT=1 Q 
	.	S TIMEREM=TIMEREM-60
	.	I TIMEREM'>0 S %fkey="TIM" S EXIT=1 S x="" Q  ; Timeout
	.	D TIME ; Display time
	.	WRITE vcpr ; Return cursor
	.	Q 
	;
	Q x
	;
SUBMENU(FN)	; Check for and select submenu options
	; Return function name or null
	;
	N I
	N OPTION N X
	;
	S I=1
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
	I ''$G(vos1) F  Q:'($$vFetch2())  D  Q:ER 
	.	S OPTION(I)=$P(rs,$C(9),2)_"|"_$P(rs,$C(9),3)
	.	S I=I+1
	.	Q 
	; Recall
	S OPTION(I)=$$^MSG(2321)_"|@"_FN
	;
	S X=$$^DBSMBAR(39,"","","",.OPTION)
	I X="" Q ""
	;
	Q $piece(OPTION(X),"|",2)
	;
%SN	; Change to new system variables
	;
	S ER=0
	D SYSVAR(.%VSAVE)
	;
	; Execute Pre-processor
	N scasys,vop1 S scasys=$$vDb21(%SN,.vop1)
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	I $G(vop1) XECUTE $P(scasys,$C(124),2)
	I ER S %SN=""
	;
	Q 
	;
RESET()	; Reset variables for this session
	; Return 1 if successful, 0 if not
	;
	D KILL0() ; Kill useless variables & restore old ones
	;
	N EXIT
	N I N JOB
	;
	S JOB=$J
	;
	N savevar,vop1,vop2 S vop1=JOB,savevar=$$vDb16(JOB,.vop2)
	I '$G(vop2) Q 0
	;
	; No variables defined.
	I DRVVARS="",SYSVARS="",vop1="" Q 0
	I '($D(ER)#2) S ER=0
	S MENU=$P(savevar,$C(124),1)
	S %ID=$P(savevar,$C(124),2)
	S %SN=$P(savevar,$C(124),3)
	S %FN=$P(savevar,$C(124),4)
	S DISPEXIT=$P(savevar,$C(124),8)
	; Clear last function
	S $P(savevar,$C(124),4)=""
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(0,"SAVEVAR",vop1)=$$RTBAR^%ZFUNC(savevar) S vop2=1 Tcommit:vTp  
	;
	S %VSAVE=SYSVARS
	;
	F I=1:1:MENU D
	.	I I="SAVTMP" Q 
	.	;
	.	N tmpmenu S tmpmenu=$$vDb22(JOB,I)
	.	S $piece(MENU(I),"|",1)=$P(tmpmenu,$C(124),1)
	.	S $piece(MENU(I),"|",2)=$P(tmpmenu,$C(124),2)
	.	S $piece(MENU(I),"|",3)=$P(tmpmenu,$C(124),3)
	.	S $piece(MENU(I),"|",4)=$P(tmpmenu,$C(124),4)
	.	Q 
	;
	N ddpsts S ddpsts=""
	 S ddpsts=$G(^%ZDDP("%NET"))
	S %NET=$P(ddpsts,$C(124),1)
	;
	I '$D(%fkey) D ZBINIT^%TRMVT()
	I '($D(vcll)#2) S vcll=$$CLL^%TRMVT
	;
	Q 1
	;
CHKREST()	; Check menu restrictions and accrual restrictions
	; Return 1 if restricted, plus ET set
	;
	I '$get(%NET) Q 0 ; Network down
	;
	; Accrual restriction
	I %ACRREST,($D(^TTR("PA"))#2) S ET="ACCRSTCT" Q 1
	;
	; Unrestricted ucls
	I %UCLS="MGR"!(%UCLS="SCA") Q 0
	;
	; Menu restriction
	;
	; No restrictions...
	Q 0
	;
VALIDSEL(fn,scatbl)	;
	;
	N FNAME
	;
	; Convert function name to upper case
	S fn=$$vStrUC(fn) S FNAME="" S ER=0
	; Remove @ sign
	I $E(fn,1)="@" S fn=$E(fn,2,999) D VERAT(fn,.scatbl) Q FNAME
	I fn'?.N S fn=$$STRMTCH(MENUNO,fn)
	;
	; Invalid choice. Press the Help key or the Select key for help.
	I fn="" D SETERR^DBSEXECU("SCAMENU","MSG",1278) Q ""
	N scamenu,vop1 S scamenu=$$vDb23(MENUNO,+fn,.vop1)
	I '$G(vop1) D SETERR^DBSEXECU("SCAMENU","MSG",1278) Q ""
	S DESC=$P(scamenu,$C(124),1)
	S fn=$P(scamenu,$C(124),2)
	;
	I fn?.N D VERMENU Q FNAME ; Next menu
	S FNAME=$$VALIDFN(fn,.scatbl)
	;
	Q FNAME
	;
VERAT(fn,scatbl)	; Interpret @ input
	;
	; Function name or menu number required
	I fn="" S ER=1 S RM=$$^MSG(1138) Q 
	S DESC="@"_fn
	I fn'?.N S FNAME=$$VALIDFN(fn,.scatbl) Q  ; Function
	D VERMENU
	;
	Q 
	;
VERMENU	; Check numeric (menu) @ input
	;
	N CHOICE
	;
	N scamenu0 S scamenu0=$G(^SCATBL(0,fn))
	S CHOICE=$P(scamenu0,$C(124),2)
	;
	I CHOICE'="" S FNAME=fn S NEWPRMPT=CHOICE
	; Invalid menu ~p1
	E  D SETERR^DBSEXECU("SCAMENU0","MSG",1405,fn) Q 
	;
	Q 
	;
STRMTCH(MENUNO,STR)	; Find first string match, return selection number
	;
	N MATCH
	N LEN N SEQ
	N DESC
	;
	S MATCH=""
	S LEN=$L(STR)
	S STR=$$vStrUC(STR)
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen3()
	I ''$G(vos1) F  Q:'($$vFetch3())  D  Q:MATCH=1 
	.	S DESC=$$vStrUC(($P(rs,$C(9),2)))
	.	I $E(DESC,1,LEN)=STR S MATCH=1 S SEQ=$P(rs,$C(9),1)
	.	Q 
	;
	Q:MATCH SEQ
	;
	Q ""
	;
VALIDFN(fn,scatbl)	; Check validity of selected function
	;
	N OFN
	;
	S ER=1
	S OFN=fn
	;
	; If user defined function name, get SCA fn
	I %UDFN  N V1 S V1=fn I ($D(^CTBL("CTBLUDFN",V1))#2) D
	.	N ctbludfn S ctbludfn=$$vDb24(fn)
	.	S fn=$P(ctbludfn,$C(124),1)
	.	I fn="" S fn=OFN
	.	Q 
	;
	; Function ~p1 does not exist
	 N V2 S V2=fn I (fn="")!('($D(^SCATBL(1,V2))#2)) S RM=$$^MSG(1146,OFN) Q ""
	;
	K vobj(+$G(scatbl)) S scatbl=$$vDb12(fn)
	;
	; Userclass ~p1 not authorized for this function
	N scatbl3 S scatbl3=$$vDb25(fn,%UCLS)
	;
	I $P(scatbl3,$C(124),1)'=1 S RM=$$^MSG(2898,%UCLS) Q ""
	;
	; Invalid network function
	I $P(vobj(scatbl),$C(124),5),%LOGID S RM=$$^MSG(1409) Q ""
	;
	; Invalid host function
	I $P(vobj(scatbl),$C(124),16),'%LOGID S RM=$$^MSG(1376) Q ""
	;
	; Invalid function when network is down
	I $get(%NET)=0,$P(vobj(scatbl),$C(124),5),$P(vobj(scatbl),$C(124),6) S RM=$$^MSG(1360) Q ""
	;
	; Function invalid before ~p1
	I $P(vobj(scatbl),$C(124),7),$P($H,",",2)<$P(vobj(scatbl),$C(124),7) S RM=$$^MSG(1132,$$TIM^%ZM($P(vobj(scatbl),$C(124),7))) Q ""
	;
	; Function invalid after ~p1
	I $P(vobj(scatbl),$C(124),8),$P($H,",",2)>$P(vobj(scatbl),$C(124),8) S RM=$$^MSG(1131,$$TIM^%ZM($P(vobj(scatbl),$C(124),8))) Q ""
	;
	S ER=0
	Q fn
	;
KILL	; Kill variables between function calls and re-init variables
	; Note - This line tag called from a number of application routines
	D KILL0()
	Q 
	;
KILL0()	; Call by: D KILL0(.TMP0)
	;
	D XKILL()
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	XECUTE $get(DRVVARS) ; Restore driver variables
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	XECUTE $get(SYSVARS) ; Restore system variables
	S %="|"
	;
	; Redefine %SystemDate to today's system date.
	N cuvar S cuvar=$$vDb26()
	 S cuvar=$G(^CUVAR(2))
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S TJD=$P(cuvar,$C(124),1)
	;
	Q 
	;
XKILL(x)	; Save system and selected application variables
	;
	N argv
	;
	S argv="("_$$VSAV_$get(x)_",%BLK,%cmmd,DISPEXIT,DRVVARS,%DUP,EXIT,%ID,%JRNL,%MSGID,%MSGS,ER,RM,SYSVARS)"
	;  #ACCEPT Date=05/11/05; PGM=Dan Russell; CR=15943
	K @argv
	;
	Q 
	;
VSAV()	; Standard variable save list
	; Note - This line tag called from a number of application routines
	;
	Q "%,%CRCD,%DB,%EMUCRCD,%CSID,%fkey,%FN,%IDENT,%IPMODE,%LIBS,%LOGID,%MCP,%NET,%OPMODE,%RESPROC,%SN,%SVCHNID,%TO,%VN,%VNC,%ZTPTRAP"
	;
SYSVAR(sysvar)	;
	;
	;I18N=OFF
	 D ^NOISO
	;I18N=ON
	;
	N i
	N list N x N y
	;
	N cuvar,vop1,vop2,vop3,vop4,vop5,vop6,vop7 S cuvar=$$vDb26()
	 S cuvar=$G(^CUVAR(2))
	 S vop4=$G(^CUVAR("CO"))
	 S vop6=$G(^CUVAR("ODP"))
	 S vop2=$G(^CUVAR("%MCP"))
	 S vop1=$G(^CUVAR("%CRCD"))
	 S vop5=$G(^CUVAR("EUR"))
	 S vop7=$G(^CUVAR("RESPROC"))
	 S vop3=$G(^CUVAR("%VN"))
	;
	S list="%CO,%CRCD,%DB,%EMUCRCD,%ED,%IDENT,%LIBS,%MCP,%ODP,%RESPROC,%SVCHNID,%VN,%VNC,TJD"
	;
	S %="|"
	S %LIBS="SYSDEV"
	D INIT^%ZM(.list)
	;
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S TJD=$P(cuvar,$C(124),1)
	S %ED=$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"")
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S %CO=$P(vop4,$C(124),1)
	S %ODP=$P(vop6,$C(124),1)
	S %MCP=$P(vop2,$C(124),1)
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S %CRCD=$P(vop1,$C(124),1)
	S %EMUCRCD=$P(vop5,$C(124),16)
	S %RESPROC=$P(vop7,$C(124),1)
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S %VN=$P(vop3,$C(124),1)
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S %VNC=$get(%VNC) I %VNC="" S %VNC=%VN
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S %IDENT=$$USERNAM^%ZFUNC
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	S %SVCHNID="PA"
	S %DB=$$TRNLNM^%ZFUNC("SCAU$DB") ; defined database type
	I %DB="" S %DB="GTM" ; default DB type is GTM
	S sysvar="S %=$C(124)"
	F i=1:1:$L(list,",") D
	.	S x=$piece(list,",",i)
	.	S y=@x
	.	S sysvar=sysvar_","_x_"="""_y_""""
	.	Q 
	Q 
	;
BACKUP	; Backup one menu level
	;
	WRITE $$CUP^%TRMVT(1,4+MENU),vcll
	K MENU(MENU)
	S MENU=MENU-1
	Q 
	;
NEWMENU	; New menu selected, set it up
	;
	S $piece(MENU(MENU),"|",4)=DESC S MENU=MENU+1
	S MENU(MENU)=%FN_"|"_NEWPRMPT
	;
	Q 
	;
SYSLOG()	; Log function started in SYSLOG
	;
	N LOGINF
	;
	I $get(%LOGID)="" S %LOGID=$$LOGID^SCADRV
	;
	S LOGINF=%UID_$char(17)_TLO_$char(17)_$get(%FN)_$char(17)_$P($H,",",2)
	S $piece(LOGINF,$char(17),7)=$piece(%LOGID,"|",2)
	S $piece(LOGINF,$char(17),9)=$P($H,",",1)
	;
	Q LOGINF
	;
SYSLOGXT(DATA)	;
	;
	N TIME
	N HLOG N NODE
	;
	I $get(DATA)="" Q 
	;
	S DATA=$TR(DATA,$char(17),"|")
	;
	S HLOG=$H
	;
	I $get(TJD)="" D
	.	N cuvar S cuvar=$$vDb26()
	.	 S cuvar=$G(^CUVAR(2))
	.	;   #accept pgm=spier;date=12/8/03; CR=unknown
	.	S TJD=$P(cuvar,$C(124),1)
	.	;   #accept pgm=spier;date=12/8/03; CR=unknown
	.	I TJD="" S TJD=$P($H,",",1)
	.	Q 
	;
	I $get(%LOGID)="" S %LOGID=$$LOGID^SCADRV
	S TIME=$$GETTIM^%ZFUNC
	S NODE=$piece(%LOGID,"|",3)
	;
	; File locally only
	N syslog,vop1,vop2,vop3,vop4,vop5 S syslog="",vop4="",vop3="",vop2="",vop1="",vop5=0
	S vop4=TJD
	S vop3=TIME
	S vop2=NODE
	S vop1=$J
	S $P(syslog,$C(124),1)=$piece(DATA,"|",1)
	S $P(syslog,$C(124),2)=$piece(DATA,"|",2)
	S $P(syslog,$C(124),3)=$piece(DATA,"|",3)
	S $P(syslog,$C(124),4)=$piece(DATA,"|",4)
	S $P(syslog,$C(124),5)=$piece(HLOG,",",2)
	S $P(syslog,$C(124),7)=$piece(DATA,"|",7)
	S $P(syslog,$C(124),8)=+HLOG
	S $P(syslog,$C(124),9)=$piece(DATA,"|",9)
	I $get(%SN)="GLS" S $P(syslog,$C(124),6)=$get(CO)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^SYSLOG(vop4,vop3,vop2,vop1)=$$RTBAR^%ZFUNC(syslog) S vop5=1 Tcommit:vTp  
	;
	Q 
	;
DISPLAY	; Display header and menu
	;
	N I
	;
	S DISPLAY=0
	;
	N cuvar,vop1 S cuvar=$$vDb26()
	 S cuvar=$G(^CUVAR("CONAM"))
	 S vop1=$G(^CUVAR("DRVMSG"))
	;
	WRITE vclear,vidrev," ",$P(cuvar,$C(124),1)
	;
	D DATE
	D TIME
	;
	I $P(vop1,$C(124),1)'="" D DRVMSG($P(vop1,$C(124),1))
	WRITE $$LINE^%TRMVT(80,1,4)
	;
	F I=1:1:MENU-1 D DSPMENU(I,$piece(MENU(I),"|",2),$piece(MENU(I),"|",4))
	;
	I $D(%MSGS) D PNTRM()
	D STATLIN
	Q 
	;
DRVMSG(drvmsg)	; Display driver message
	;
	WRITE $$CUP^%TRMVT((80-$L(drvmsg))\2,3),vidinc
	WRITE drvmsg,vidoff
	Q 
	;
DATE	; Display current calendar date (and system date for IBS)
	;
	N DATE
	;
	N cuvar,vop1 S cuvar=$$vDb26()
	 S cuvar=$G(^CUVAR(2))
	 S vop1=$G(^CUVAR("CONAM"))
	;
	S DATE=$$vdat2str($P($H,",",1),"MM/DD/YEAR")
	I ($P(cuvar,$C(124),1)),($P(cuvar,$C(124),1)-$P($H,",",1)) S DATE="["_$$vdat2str(($P(cuvar,$C(124),1)),$get(%MSKD))_"]  "_DATE
	E  S DATE="["_TLO_"]  "_DATE
	WRITE $J("",68-$L(($P(vop1,$C(124),1)))-$L(DATE)),DATE
	;
	Q 
	;
TIME	; Display current time
	;
	WRITE vidrev,$$CUP^%TRMVT(70,1),$J($$TIM^%ZM,10)," ",vidoff
	;
	S OLDTIME=$P($H,",",2) ; Last time displayed
	;
	Q 
	;
STATLIN	; Display status line
	;
	N STAT
	;
	S STATLIN=0
	;
	Q:$get(%AUTOMNU) 
	I ($D(vstatus)#2) WRITE vstatus Q 
	;
	S STAT(1)="HLP"
	S STAT(2)="SEL"
	S STAT(3)="FND"
	S STAT(4)="END|Main_Menu"
	S STAT(5)="ESC"
	S vstatus=$$SHOWKEY^%TRMVT(.STAT)
	WRITE vstatus
	;
	Q 
	;
DSPMENU(menu,prmpt,ans)	; Display menu prompt and prior answer
	;
	WRITE $$CUP^%TRMVT(39-$L(prmpt),4+menu),prmpt,": ",$get(ans),vcll
	;
	Q 
	;
PNTRM(er)	; Display message(s) on next to bottom line(s) of screen
	;
	N WAIT
	N DY N N
	;
	Q:'$D(RM) 
	;
	S er=$get(er)
	S N=""
	S DY=23
	I $D(RM)<9 D MSG(RM) I 1
	E  D  ; Get starting line number
	.	F  S N=$order(RM(N)) Q:N=""  S DY=DY-1
	.	F  S N=$order(RM(N)) Q:N=""  S DY=DY+1 D MSG(RM(N))
	.	Q 
	I 'er Q 
	D CLRMSGS
	;
	Q 
	;
MSG(msg)	; Write message at line specified
	;
	; Only wait on error if last line
	I (DY=23),er S WAIT=1
	E  S WAIT=0
	WRITE $$MSG^%TRMVT(msg,er,WAIT,1,DY,%TO,1)
	S %MSGS(DY)="" ; Indicate line where message displayed
	;
	Q 
	;
CLRMSGS	; Clear any messages displayed
	;
	N BTM N TOP N I
	;
	I '($D(vcll)#2) S vcll=$$CLL^%TRMVT
	S TOP=$order(%MSGS(""))
	S BTM=$order(%MSGS(""),-1)
	F I=TOP:1:BTM WRITE $$CUP^%TRMVT(1,I),vcll
	K %MSGS,RM
	;
	Q 
	;
CLRMENU	; Clear menus and return to top
	;
	N I
	N X
	;
	I MENU>1 F I=MENU:-1:2 WRITE $$CUP^%TRMVT(1,4+I),vcll
	S X=MENU(1)
	K MENU
	S MENU=1 S MENU(1)=X
	;
	Q 
	;
EXT(%UID,%FN)	; External function call from PROFILE function
	;
	N PGM
	;
	N scatbl
	;
	N scau S scau=$$vDb15(%UID)
	;
	D VALIDUID^SCADRV K:ER vobj(+$G(scau)) Q:ER 
	D LOADSCAU^SCADRV(scau) K:ER vobj(+$G(scau)) Q:ER 
	S %LOGID=$$LOGID^SCADRV
	;
	S %FN=$$VALIDFN(%FN,.scatbl) I %FN="" K vobj(+$G(scatbl)),vobj(+$G(scau)) Q 
	I $$CHKREST S ER=1 K vobj(+$G(scatbl)),vobj(+$G(scau)) Q 
	;
	S %SN=$get(%SN)
	I $P(vobj(scatbl),$C(124),11)'=%SN S %SN=$P(vobj(scatbl),$C(124),11) D %SN K:ER vobj(+$G(scatbl)),vobj(+$G(scau)) Q:ER 
	;
	S %="|"
	S %JRNL=0
	S %ID=$$SYSLOG
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	I $P(vobj(scatbl),$C(124),2)'="" S PGM=$P(vobj(scatbl),$C(124),2) XECUTE PGM I $get(ER) K vobj(+$G(scatbl)),vobj(+$G(scau)) Q 
	S PGM=$P(vobj(scatbl),$C(124),4) D EXTPGM(PGM)
	;  #accept pgm=spier;date=12/8/03; CR=unknown
	I $P(vobj(scatbl),$C(124),3)'="" S PGM=$P(vobj(scatbl),$C(124),3) XECUTE PGM I $get(ER) K vobj(+$G(scatbl)),vobj(+$G(scau)) Q 
	D SYSLOGXT(%ID)
	D KILL
	;
	K vobj(+$G(scatbl)),vobj(+$G(scau)) Q 
	;
EXTPGM(PGM)	; Dispatch to PGM
	;
	N %ID
	;
	D @PGM
	;
	LOCK 
	;
	Q 
	;
NOISO	; Specify NoIsolation (M database feature only)
	;
	;I18N=OFF
	 D ^NOISO
	;I18N=ON
	Q 
	;
vSIG()	;
	Q "60773^54266^Aries Beltran^26579" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
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
	;
vDb12(v1)	;	vobj()=Db.getRecord(SCATBL,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL"
	S vobj(vOid)=$G(^SCATBL(1,v1))
	I vobj(vOid)="",'$D(^SCATBL(1,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb15(v1)	;	vobj()=Db.getRecord(SCAU,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU"
	S vobj(vOid)=$G(^SCAU(1,v1))
	I vobj(vOid)="",'$D(^SCAU(1,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb16(v1,v2out)	;	voXN = Db.getRecord(SAVEVAR,,1,-2)
	;
	N savevar
	S savevar=$G(^TMP(0,"SAVEVAR",v1))
	I savevar="",'$D(^TMP(0,"SAVEVAR",v1))
	S v2out='$T
	;
	Q savevar
	;
vDb17(v1,v2,v2out)	;	voXN = Db.getRecord(TMPMENU,,1,-2)
	;
	N tmpmenu
	S tmpmenu=$G(^TMP(0,v1,v2))
	I tmpmenu="",'$D(^TMP(0,v1,v2))
	S v2out='$T
	;
	Q tmpmenu
	;
vDb18(v1,v2out)	;	voXN = Db.getRecord(NOREST,,1,-2)
	;
	N norest
	S norest=$G(^%ZNOREST(v1))
	I norest="",'$D(^%ZNOREST(v1))
	S v2out='$T
	;
	Q norest
	;
vDb19(v1)	;	voXN = Db.getRecord(SAVEDRV,,1)
	;
	N savedrv
	S savedrv=$G(^TMP(0,"SAVEDRV",v1))
	I savedrv="",'$D(^TMP(0,"SAVEDRV",v1))
	;
	Q savedrv
	;
vDb2(v1)	;	vobj()=Db.getRecord(SAVESYS,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSAVESYS"
	S vobj(vOid)=$G(^TMP(0,"SAVESYS",v1))
	I vobj(vOid)="",'$D(^TMP(0,"SAVESYS",v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb20(v1)	;	voXN = Db.getRecord(SAVESYS,,1)
	;
	N savesys2
	S savesys2=$G(^TMP(0,"SAVESYS",v1))
	I savesys2="",'$D(^TMP(0,"SAVESYS",v1))
	;
	Q savesys2
	;
vDb21(v1,v2out)	;	voXN = Db.getRecord(SCASYS,,1,-2)
	;
	N scasys
	S scasys=$G(^SCATBL(2,v1))
	I scasys="",'$D(^SCATBL(2,v1))
	S v2out='$T
	;
	Q scasys
	;
vDb22(v1,v2)	;	voXN = Db.getRecord(TMPMENU,,0)
	;
	N tmpmenu
	S tmpmenu=$G(^TMP(0,v1,v2))
	I tmpmenu="",'$D(^TMP(0,v1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,TMPMENU" X $ZT
	Q tmpmenu
	;
vDb23(v1,v2,v2out)	;	voXN = Db.getRecord(SCAMENU,,1,-2)
	;
	N scamenu
	S scamenu=$G(^SCATBL(0,v1,v2))
	I scamenu="",'$D(^SCATBL(0,v1,v2))
	S v2out='$T
	;
	Q scamenu
	;
vDb24(v1)	;	voXN = Db.getRecord(CTBLUDFN,,0)
	;
	N ctbludfn
	S ctbludfn=$G(^CTBL("CTBLUDFN",v1))
	I ctbludfn="",'$D(^CTBL("CTBLUDFN",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CTBLUDFN" X $ZT
	Q ctbludfn
	;
vDb25(v1,v2)	;	voXN = Db.getRecord(SCATBL3,,0)
	;
	N scatbl3
	S scatbl3=$G(^SCATBL(1,v1,v2))
	I scatbl3="",'$D(^SCATBL(1,v1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCATBL3" X $ZT
	Q scatbl3
	;
vDb26()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vOpen1()	;	FN FROM SCATBL4 WHERE FN=:%FN
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(%FN) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^SCATBL(4,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2
	;
	Q 1
	;
vOpen2()	;	SEQ,DESC,SUB FROM SCATBL4 WHERE FN=:FN ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FN) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^SCATBL(4,vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^SCATBL(4,vos2,vos3))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)_$C(9)_$P(vos4,"|",2)
	;
	Q 1
	;
vOpen3()	;	SNUMB,MDESC FROM SCAMENU WHERE MNUMB=:MENUNO
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(MENUNO) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^SCATBL(0,vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^SCATBL(0,vos2,vos3))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
