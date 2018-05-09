 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV ; 
 ;
 ;  #ACCEPT Date=11/3/06; Pgm=RussellDS; CR=22719; Group=BYPASS
 ;*** Start of code by-passed by compiler
 KILL
 ;*** End of code by-passed by compiler ***
 ;
 N EXIT S EXIT=0
 N %ET N CONAM N drvlist N MENU N UIDLOC N USERNAME
 N vidinc N vidoff N vcll N vcps N vcpr N vclear N vidrev
 ;
 F  Q:'('EXIT)  D UID
 ;
 Q 
 ;
UID ; Standard PROFILE username access
 N vTp
 ;
 D INIT ; Init screen and key variables
 ;
 D PAINTSCR ; Paint screen
 ;
 ; Get user id
 S %UID=$$GETUID()
 ; No user id entered
 I (%UID="") D EXIT Q 
 ;
 N scau S scau=$$vRCgetRecord1^RecordSCAU(%UID,0)
 ;
 ; Invalid user ID
 I '$G(vobj(scau,-2)) D SETERR^DBSEXECU("SCAU","MSG",1504) D EXIT K vobj(+$G(scau)) Q 
 ;
 D LOADSCAU(.scau)
 D CHKSTAT(.scau) I ER D EXIT K vobj(+$G(scau)) Q  ; Disallow Access if User is Revoked
 ;
 D GETPWD(.scau)
 I ER S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp   D EXIT K vobj(+$G(scau)) Q 
 I $get(%fkey)="TIM" S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp   D EXIT K vobj(+$G(scau)) Q 
 ;
 I $get(ER)="W" D  ; WVB - 43805
 .	I $get(ET)'="" S %ZTHANG=60 D DSPBP^UTLERR Q 
 .	D PNTRM^SCADRV0(1)
 .	Q 
 ;
 D VALIDUID I ER D EXIT K vobj(+$G(scau)) Q  ; Validate user
 ;
 ; Update SCAU with successful login info.
  S $P(vobj(scau),$C(124),43)=0
  S $P(vobj(scau),$C(124),8)=$P($H,",",1)
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp  
 ;
 D VARSET(.scau) ; Set variables
 ;
 D REGISTER^IPCMGR("USER") ; Register process
 D ^SCADRV0() ; Dispatch
 D CLOSE^IPCMGR() ; Unregister process
 ;
 I ER D EXIT K vobj(+$G(scau)) Q 
 ;
 K vobj(+$G(scau)) Q 
 ;
VMSUID ; Private -  VMS username access
 N vpc
 ;
 D INIT ; Init screen and key variables
 ;
 ; Get PROFILE user id
 S %UID=$$GETUID()
 ;
 N scau S scau=$$vRCgetRecord1^RecordSCAU(%UID,0)
 ;
 ; Invalid user ID
 I '$G(vobj(scau,-2)) D SETERR^DBSEXECU("SCAU","MSG",1504) D EXIT K vobj(+$G(scau)) Q 
 ;
 D LOADSCAU(.scau)
 D VALIDUID I ER D EXIT K vobj(+$G(scau)) Q  ; Validate user
 ;
 ; First sign-on of the day
 I ($P(vobj(scau),$C(124),8)'=$P($H,",",1)) D PAINTSCR S vpc=$$PROMPT K:vpc vobj(+$G(scau)) Q:vpc 
 ;
 D VARSET(.scau) ; Set variables
 ;
 D REGISTER^IPCMGR("USER") ; Register process
 D ^SCADRV0() ; Dispatch
 D CLOSE^IPCMGR() ; Unregister process
 ;
 I $get(%fkey)="ESC" D EXIT K vobj(+$G(scau)) Q  ; Escape key
 I $get(%fkey)="CUU" D EXIT K vobj(+$G(scau)) Q  ; Up-Arrow
 I $get(%fkey)="TIM" D EXIT K vobj(+$G(scau)) Q  ; Time-out
 I ER D EXIT K vobj(+$G(scau)) Q 
 ;
 K vobj(+$G(scau)) Q 
 ;
ATTACH(pid,fn,input) ; 
 N vTp
 ;
 ;  #ACCEPT Date=11/3/06; Pgm=RussellDS; CR=22719; Group=BYPASS
 ;*** Start of code by-passed by compiler
 new (%TO,pid,fn,input,ER,RM)
 ;*** End of code by-passed by compiler ***
 ;
 N JOB S JOB=$J
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 ; Init screen and key variables
 D INIT
 ;
 N tmp,vop1 S tmp=$$vRCgetRecord1Opt^RecordTMP(pid,0,.vop1)
 ;
 ; Init user specific variables
 ;  #ACCEPT PGM=Erik Scheetz;DATE=01/03/03;CR=unknown
 I $G(vop1) XECUTE $P(tmp,$C(124),4)
 ;
 ; Invalid process ID
 E  D SETERR^DBSEXECU("TMP","MSG",1427) Q 
 ;
 ; Reset driver variables
 N savedrv S savedrv=$$vRCgetRecord1^RecordSAVEDRV(JOB,0)
  S vobj(savedrv,1,1)="" N von S von="" F  S von=$O(^TMP(0,"SAVEDRV",vobj(savedrv,-3),von)) quit:von=""  S vobj(savedrv,1,1)=vobj(savedrv,1,1)_^TMP(0,"SAVEDRV",vobj(savedrv,-3),von)
  S vobj(savedrv,-3)=JOB
  S vobj(savedrv,1,1)=""
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSAVEDRV(savedrv,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(savedrv,-100) S vobj(savedrv,-2)=1 TC:vTp  
 ;
 ; Load menu data
 N tmpmenu S tmpmenu=$$vRCgetRecord1^RecordTMPMENU(pid,1,0)
 S MENU=1
 S MENU(1)=$P(vobj(tmpmenu),$C(124),1)_"|"_$P(vobj(tmpmenu),$C(124),2)_"|"_$P(vobj(tmpmenu),$C(124),3)_"|"_$P(vobj(tmpmenu),$C(124),4)
 ;
 ; Save menu data
 N newmenu,vop2,vop3,vop4 S newmenu=$$vReCp1(tmpmenu)
  S vop3=JOB
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TMP(0,vop3,vop2)=$$RTBAR^%ZFUNC(newmenu) S vop4=1 TC:vTp  
 ;
 D ^SCADRV0($get(fn),$get(input))
 ;
 ; Delete all driver info
  K ^TMP(0,JOB)
 ;
 ; Delete all saved driver variables from SAVEDRV table
  K ^TMP(0,"SAVEDRV",JOB)
 ;
 K vobj(+$G(savedrv)),vobj(+$G(tmpmenu)) Q 
 ;
INIT ; Initialization and terminal setting
 ;
 N JOB S JOB=$J
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
  K ^TMP(0,JOB)
  K ^%ZNOREST(JOB)
 ;
 S drvlist="%TO|300,CONAM,%ET"
 S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
 D LIST^CUVAR(drvlist)
 D INIT^%ZM(.drvlist)
 ;
 S %LOGID=$$LOGID
 N ddpsts S ddpsts=$$vRCgetRecord0Opt^RecordDDPSTS(0,"")
  S ddpsts=$G(^%ZDDP("%NET"))
 S %NET=$P(ddpsts,$C(124),1)
 ;
 I (%NET="") S %NET=1
 ;
 S %="|"
 S %SN=""
 ;
 S TLO=$$TLO^UTLO
 ;
 D ZBINIT^%TRMVT()
 S vidinc=$$VIDINC^%TRMVT
 S vidoff=$$VIDOFF^%TRMVT
 S vcll=$$CLL^%TRMVT
 S vcps=$$CPS^%TRMVT
 S vcpr=$$CPR^%TRMVT
 S vclear=$$SCR80^%TRMVT_$$CLEAR^%TRMVT
 S vidrev=$$VIDREV^%TRMVT
 ;
 D TERMSET ; Set terminal characteristics
 ; I18N=OFF
 WRITE $$INSMOFF^%TRMVT ; Turn off insert mode
 WRITE vclear ; Clear screen
 ; I18N=ON
 ;
 Q 
 ;
STFENABL(%fn) ; 
 N vret
 ;
 N scatbl,vop1 S scatbl=$$vRCgetRecord1Opt^RecordSCATBL(%fn,0,.vop1)
 I '$G(vop1) Q 0
 ;
 S vret=$P(scatbl,$C(124),6) Q vret
 ;
LOGID() ; 
 ;
 N LOGID
 ;
 S LOGID=0
 S $piece(LOGID,"|",2)=$$USERNAM^%ZFUNC
 S $piece(LOGID,"|",3)=$$NODENAM^%ZFUNC()
 S $piece(LOGID,"|",4)=$$GBLDIR^DDPUTL($$HOSTLOG^DDPUTL)
 ;
 Q LOGID
 ;
PAINTSCR ; Paint header, copyright, and message
 ;
 N I
 N CO N LOGINMSG N X
 ;
 S UIDLOC=10 ; Default UID prompt location
 ;
 ; I18N=OFF
 WRITE vclear
  S X="PROFILE/"_"DQ"
 ;
 WRITE vidinc
 WRITE $$CUP^%TRMVT((40-$L(X))\2,1),$$DBLH^%TRMVT(X)
 WRITE vidoff
 ;
  S X="Sanchez Computer Associates"
 ;
 WRITE $$CUP^%TRMVT(26,3),X
 ;
  WRITE $$CUP^%TRMVT(12,7),$$DBLH^%TRMVT("PIP Version 0.2")
 ;
 ; Get copyright notice
 D COPYRT(.CO)
 F I=1:1:4 I CO(I)'="" WRITE $$CUP^%TRMVT((80-$L(CO(I)))\2,19+I),CO(I)
 ;
 ; Daily login message
 S LOGINMSG=""_"|"_""_"|"_""
 I ($translate(LOGINMSG,"|")="")
 ;
 WRITE $$LINE^%TRMVT(60,10,13)
 F I=1:1:3 WRITE $$CUP^%TRMVT(10,13+I),$piece(LOGINMSG,"|",I)
 WRITE $$LINE^%TRMVT(60,10,17)
 ; I18N=ON
 ;
 Q 
 ;
COPYRT(X) ; 
 ;
 N CUVVN
 ;
 ; I18N=OFF
 S X(1)="PROFILE(R) is a registered trademark of Sanchez Computer Associates, Inc."
 S X(2)="DATA-QWIK is a trademark of Sanchez Computer Associates, Inc."
 S X(3)="Copyright(C)"_$$YEAR^SCADAT(+$P($H,",",1),1)_" by Sanchez Computer Associates, Inc."
 S X(4)="All Rights Reserved."
 I 1 S X(4)=X(4)_"    Version "_"7.0"
 ; I18N=ON
 ;
 Q 
 ;
GETUID() ; 
 ;
 N E1 N E2 N L N VMSNLNG
 N VMSNAME
 ;
 I 1 D SCAUID(.VMSNAME) Q VMSNAME
 ;
 ; Return user id
 ;
SCAUID(USERID) ; 
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 ;
 ; User Identification:
 WRITE $$CUP^%TRMVT(20,UIDLOC),$$^MSG(7137)
 S USERID=$$TERM^%ZREAD("",20,"","",60,1)
 ;
 ; UID is not case sensitive
 S USERID=$ZCONVERT(USERID,"U")
 ;
 Q 
 ;
PROMPT() ; Continue prompt for VMS username access
 ; Return 0 if success, 1 if failure
 ;
 WRITE $$MSG^%TRMVT("",0,1,1,24,%TO,1)
 I $get(%fkey)="TIM" Q 1
 ;
 Q 0
 ;
LOADSCAU(scau) ; Load ^SCAU variables
 ;
 S %AUTOMNU=$P(vobj(scau),$C(124),2)
 S %UCLS=$P(vobj(scau),$C(124),5)
 ;
 ; Restrict Userclass During Accruals
 N scau0 S scau0=$G(^SCAU(0,%UCLS))
 S %ACRREST=$P(scau0,$C(124),9)
 ;
 Q 
 ;
GETPWD(scau) ; Get password
 ;
 N PWDTRY N TRY
 N ENC N X
 ;
 ; Maximum Number Of Retries
 N scau0 S scau0=$G(^SCAU(0,%UCLS))
 S PWDTRY=$P(scau0,$C(124),5)
 ;
 I ($P(vobj(scau),$C(124),6)="*")!($P(vobj(scau),$C(124),6)="") S ER=1 S ET="INVLDPWD" D ^UTLERR Q 
 ;
 ; Enter your password:
 WRITE $$CUP^%TRMVT(20,UIDLOC+1),$$^MSG(7135),vcps
 F TRY=1:1 D PWDTRY(.scau) Q:('ER)!($P(vobj(scau),$C(124),43)=PWDTRY) 
 I $get(%fkey)="TIM" Q 
 I ER S ET="ACCVIO" Q 
 ;
 ; Allow entry of new password
 I $P(vobj(scau),$C(124),4)!($P($H,",",1)>$P(vobj(scau),$C(124),7)) D  I ER Q 
 .	; Password has expired
 .	WRITE $$MSG^%TRMVT($$^MSG(2138),0,1,1,24,60,1)
 .	I %fkey="TIM"!(%fkey="ESC") S ER=1 S ET="ACCVIO" Q 
 .	;
 .	D NEWPWD(.scau)
 .	;
 .	I $P($H,",",1)>$P(vobj(scau),$C(124),7) S ER=1 S ET="PWDEXP" Q 
 .	I $P(vobj(scau),$C(124),4) S ER=1 S ET="SV_NEWPWREQ" Q 
 .	Q 
 ;
 D CHKEXP(.scau)
 ;
 Q 
 ;
PWDTRY(scau) ; Try to get Password
 ;
 N ENCMETH N TIMEOUT S TIMEOUT=30
 ;
 ; I18N=OFF
 WRITE vcpr ; Reposition cursor
 S ER=$$PWD(.scau,30) Q:'ER 
 ;
  S $P(vobj(scau),$C(124),43)=$P(vobj(scau),$C(124),43)+1 ; Increment Password Failures count
 ;
 ; Don't display for last time
 I TRY=PWDTRY Q 
 ;
 WRITE $$MSG^%TRMVT(RM,1,0,1,24)
 ; I18N=ON
 ;
 Q 
 ;
PWD(scau,%TO) ; 
 ;
 N RETURN
 ;
 D PWDCHECK(.scau,%TO)
 ;
 Q RETURN
 ;
PWDCHECK(scau,%TO) ; 
 ;
 N argv N PSWDAUT N PWDENC N X
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 ;
 D TERM^%ZUSE(0,"NOECHO")
 ;
 I '$get(%TO) S %TO=30
 ;
 ; Read input (password) from user
 S argv="X:%TO"
 ;  #ACCEPT PGM=Erik Scheetz;DATE=01/03/03;CR=unknown
 R @argv
 I (X="") S %fkey="TIM" S RETURN=0 Q 
 ;
 D TERM^%ZUSE(0,"ECHO")
 ;
 ; Code to handle being called from other routines
 I $P(vobj(scau),$C(124),39)'="" S PWDENC=$P(vobj(scau),$C(124),39) S ENCMETH=1
 E  S PWDENC=$P(vobj(scau),$C(124),6) S ENCMETH=0
 ;
 ; Invalid - Re-enter
 I $ascii($E(X,1))=1 S RM=$$^MSG(8301) S RETURN=1 Q 
 ;
 ; Valid Password
 S ER=$$ENC^%ENCRYPT(X,.PSWDAUT)
 I +$get(ENCMETH)=0,PWDENC'="",PWDENC=$$ENC^SCAENC(X) D  Q 
 .  S $P(vobj(scau),$C(124),39)=PSWDAUT
 .	S RETURN=0
 .	Q 
 ;
 I +$get(ENCMETH)=1,$get(PWDENC)'="",PSWDAUT=PWDENC S RETURN=0 Q 
 ;
 ; Invalid - Re-enter
 S RM=$$^MSG(8301)
 S RETURN=1
 ;
 Q 
 ;
PWDET ; Error trap for password input - restore echo
 ;
 S $ZT="G ^%ET"
 ;
 D TERM^%ZUSE(0,"ECHO")
 ; Invalid - Re-enter
 S RM=$$^MSG(8301)
 Q 1
 ;
NEWPWD(scau) ; Allow entry of new password
 ;
 D VPG0^SCADRV1(.scau) I ER Q 
 D TERMSET
 ;
 ; Create new one failed
 I ER!($P(vobj(scau),$C(124),6)="*") S ER=1 S ET="ACCVIO"
 ;
 Q 
 ;
CHKEXP(scau) ; Check password expiration for warning
 ;
 N MSG
 I $P(vobj(scau),$C(124),7)>($P($H,",",1)+7) Q  ; Not expiring in next 7 days
 I $P(vobj(scau),$C(124),8)=$P($H,",",1) Q  ; Already logged for today
 ;
 ; Your password expires on ~p1
 S MSG=$$^MSG(7136,$$vdat2str($P(vobj(scau),$C(124),7),"MM/DD/YEAR"))
 ; I18N=OFF
 WRITE $$MSG^%TRMVT(MSG,0,1,1,24,60,1)
 ; I18N=ON
 ;
 Q 
 ;
VALIDUID ; Validate %UID and device restrictions
 ;
  S ER=0
    S RM=""
 ;
 I (%UID="") S ER=1 S ET="ACCVIO" Q 
 I '$$vDbEx1() S ER=1 S ET="ACCVIO" Q 
 ;
 ; Check to see if device is restricted from this user then quit
 N device,vop1 S vop1=TLO,device=$$vRCgetRecord1Opt^RecordDEVICE(TLO,0,"")
  S device=$G(^%SYSVAR(3,vop1,0))
 I $P(device,$C(124),9)'=1 Q 
 ;
 ; Valid for this userclass
 ;
 Q 
 ;
VARSET(scau) ; 
 N vTp
 ;
 N JOB S JOB=$J
 N DRVVARS N I N MNUM N MPRMPT N v
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 I ''$G(vos1) S %UDFN=1
 E  S %UDFN=0
 ;
 S DRVVARS="S %ACRREST="_(+%ACRREST)
 S DRVVARS=DRVVARS_",%AUTOMNU="_(+%AUTOMNU)
 S DRVVARS=DRVVARS_",TLO="""_TLO_""""
 S DRVVARS=DRVVARS_",%UCLS="""_%UCLS_""""
 S DRVVARS=DRVVARS_",%UDFN="_%UDFN
 S DRVVARS=DRVVARS_",%UID="""_%UID_""""
 ;
 ; Add previously defined variables
 F I=1:1:$L(drvlist,",") D
 .	S v=$piece($piece(drvlist,",",I),"|",1)
 .	S DRVVARS=DRVVARS_","_v_"="""_@v_""""
 .	Q 
 ;
 ; Save driver variables
 N savedrv S savedrv=$$vRCgetRecord1^RecordSAVEDRV(JOB,0)
  S vobj(savedrv,1,1)="" N von S von="" F  S von=$O(^TMP(0,"SAVEDRV",vobj(savedrv,-3),von)) quit:von=""  S vobj(savedrv,1,1)=vobj(savedrv,1,1)_^TMP(0,"SAVEDRV",vobj(savedrv,-3),von)
  S vobj(savedrv,1,1)=DRVVARS
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSAVEDRV(savedrv,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(savedrv,-100) S vobj(savedrv,-2)=1 TC:vTp  
 ;
 ; Load menu data
 S MENU=1
 ;
 N scau0 S scau0=$G(^SCAU(0,%UCLS))
 S MNUM=$P(scau0,$C(124),2)
 ;
 I (MNUM="") S MNUM=1
 ;
 N scamenu0 S scamenu0=$G(^SCATBL(0,MNUM))
 S MPRMPT=$P(scamenu0,$C(124),2)
 ;
 S MENU(1)=MNUM_"|"_MPRMPT
 ;
 ; Save menu data
 N tmpmenu,vop1,vop2,vop3 S vop2=JOB,vop1=1,tmpmenu=$$vRCgetRecord1Opt^RecordTMPMENU(JOB,1,0,.vop3)
  S $P(tmpmenu,$C(124),1)=MNUM
  S $P(tmpmenu,$C(124),2)=MPRMPT
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TMP(0,vop2,vop1)=$$RTBAR^%ZFUNC(tmpmenu) S vop3=1 TC:vTp  
 ;
 K vobj(+$G(savedrv)) Q 
 ;
TERMSET ; Open terminal with necessary parameters - also called by SCADRV0
 ;
 D TERM^%ZUSE(0,"ECHO/ESCAPE/CHARACTERS/NOEDIT/NOIMAGE/WIDTH=81/TERMINATOR=$C(11,13,16,23)")
 WRITE $$GREN^%TRMVT ; Enable graphics
 WRITE $$CUON^%TRMVT ; Turn on cursor
 Q 
 ;
CLOSE ; Reset terminal with necessary parameters
 ;
 D TERM^%ZUSE(0,"ECHO/ESCAPE/EDIT/NOCHARACTERS/NOIMAGE/WIDTH=80/TERMINATOR=""""")
 WRITE $$SCRAWON^%TRMVT ; Enable auto wrap
 Q 
 ;
EXIT ; Report any error, and exit
 ;
 N JOB S JOB=$J
 ;
 ; Delete all driver information
  K ^TMP(0,JOB)
 ;
 I $get(ER) D
 .	I $get(ET)'="" S %ZTHANG=60 D DSPBP^UTLERR Q 
 .	D PNTRM^SCADRV0(1)
 .	Q 
 ;
 D CLOSE WRITE $$CLP^%TRMVT
 ;
 ; Delete all saved driver variables
  K ^TMP(0,"SAVEDRV",JOB)
 ;
 ; Delete all saved general use variables
  K ^TMP(0,"SAVEVAR",JOB)
 ;
 ; Delete all saved system variables
  K ^TMP(0,"SAVESYS",JOB)
 ;
 ;do CLOSE^IPCMGR(%ProcessID)
 ;
 S EXIT=1
 ;
 K ER,ET,RM
 ;
 Q 
 ;
CHKSTAT(scau) ; Check User STATUS
 ;
 N STATUS
 ;
 ; Get User Status
 S STATUS=$$STATUS^SCAUCDI($P(vobj(scau),$C(124),5),$P(vobj(scau),$C(124),8),$P(vobj(scau),$C(124),44),$P(vobj(scau),$C(124),43))
 ;
 ; User ID revoked
 I STATUS=3 S ER=1 S RM=$$^MSG(4249)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60723^27201^SSethy^17858" ; Signature - LTD^TIME^USER^SIZE
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
 ;
vDbEx1() ; min(1): DISTINCT UID FROM SCAU WHERE UID=:%UID
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%UID) I vsql2="" Q 0
 I '($D(^SCAU(1,vsql2))#2) Q 0
 Q 1
 ;
vOpen1() ; USERFN FROM CTBLUDFN
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^CTBL("CTBLUDFN",vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordTMPMENU.copy: TMPMENU
 ;
 S vop2=vobj(v1,-4)
 S vop3=vobj(v1,-3)
 S vop4=vobj(v1,-2)
 Q vobj(v1)
 ;
vCatch4 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ; Error trap for password input - restore echo
 S $ZT="G ^%ET"
 D TERM^%ZUSE(0,"ECHO")
 ;
 ; Invalid - Re-enter
 S RM=$$^MSG(8301)
 S RETURN=1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 D ZE^UTLERR
 S USERID=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 D ZE^UTLERR
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 D ZE^UTLERR
 D ZX^UCGMR(voxMrk) Q 
