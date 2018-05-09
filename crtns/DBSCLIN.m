 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSCLIN ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;
 Q 
 ;
CALFRMC(str1,str2,str3) ; handle call-in to evaluate computeds
 ;
 N ARG N ET N PAR N RET N RM
 N I N ER
 ;
 ;  #ACCEPT CR=23210;PGM=KELLYP;DATE=9/20/06
 ;*** Start of code by-passed by compiler
 kill (str1,str2,str3)
 ;*** End of code by-passed by compiler ***
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERROR^"_$T(+0)_""",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 D RUNC^ORACON
 I ER=-4 S ER=0 S RM=""
 E  I ER Q "Database connection error"
 ;
 F I=1:1:$L(str2,$char(31)) D
 .	S PAR=$piece(str2,$char(31),I)
 .	I PAR'=+PAR S $piece(str2,$char(31),I)=$S(PAR'["""":""""_PAR_"""",1:$$QADD^%ZS(PAR,""""))
 .	Q 
 ;
 S str2=$translate(str2,$char(31),",")
 ;
 ; process user/terminal information in str3
 I ($D(str3)#2),(str3'=" ") D
 .	;
 .	N opt S opt=$E(str3,1)
 .	N ptoken S ptoken=$E(str3,2,99)
 .	;
 .	I opt=1 D EXECPID(ptoken) Q 
 .	D EXECTKN(ptoken)
 .	Q 
 ;
 D SYSVAR^SCADRV0()
 S ARG="S RET="_str1_"("_str2_")"
 ;  #ACCEPT DATE=07/11/04; CR=21139; PGM=Badri Giridharan
 XECUTE ARG
 ;
 Q RET
 ;
EXECTKN(ptoken) ; 
 ;
 N tkn,vop1 S tkn=$$vRCgetRecord1Opt^RecordTOKEN(ptoken,0,.vop1)
 ;
 I '$G(vop1) D  Q 
 .	S (%UID,%UCLS)=""
 .	Q 
 ;
 S %UID=$P(tkn,$C(124),2)
 S %UCLS=$P(tkn,$C(124),6)
 ;
 Q 
 ;
EXECPID(ptoken) ; 
 ;
 N savedrv,vop1,vop2,vop3 S vop1=ptoken,savedrv=$$vRCgetRecord1Opt^RecordSAVEDRV(ptoken,0,.vop2)
  S vop3="" N von S von="" F  S von=$O(^TMP(0,"SAVEDRV",vop1,von)) quit:von=""  S vop3=vop3_^TMP(0,"SAVEDRV",vop1,von)
 ;
 I '$G(vop2) D  Q 
 .	S (%UID,%UCLS)=""
 .	Q 
 ;
 S drvvars=vop3
 ;
 ;  #ACCEPT DATE=03/19/07; CR=24702; PGM=Badri Giridharan; GROUP=XECUTE;
 XECUTE drvvars
 ;
 Q 
 ;
LOGERROR(err) ; Log error
 ;
 I ($P($P(err,",",3),"-",1)'="%GTM") D
 .	;
 .	N ET
 .	S ET=$P(err,",",3)_"-"_$P(err,",",2)
 .	D ^UTLERR
 .	Q 
 E  D LOGERR^UTLERR(err)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61311^54346^Dan Russell^2648" ; Signature - LTD^TIME^USER^SIZE
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 S RM=$P(error,",",4)
 D ZX^UCGMR(voxMrk) Q 
