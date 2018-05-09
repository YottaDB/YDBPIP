 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCIO ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
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
close(vOid) ; Runtime implementation of IO.close
 N vIo S vIo=$P(vobj(vOid,1),"|",6) Q:(vIo="") 
 ;
 ;  #ACCEPT CR=22273; DATE=2006-07-10; PGM=Frans S.C. Witte; GROUP=DEPRECATED
 S $piece(vobj($G(vOid),1),"|",6)=""
 ;
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 CLOSE vIo
 Q 
 ;
 ; ---------------------------------------------------------------------
locate(vOid,vSearch,vDelim,vFile,vCase) ; 
 N vDum S vDum=""
 N vDir S vDir=""
 N vElm S vElm=0
 N vFul S vFul=""
 N vMax S vMax=$S((vSearch=""):0,1:$L(vSearch,vDelim))
 N vOK S vOK=0
 ;
 S:vMax=0 vMax=1
 ;
 F vElm=1:1:vMax D  Q:vOK 
 .	S vDir=$piece(vSearch,vDelim,vElm)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S vFul=$$FILE^%TRNLNM(vFile,vDir)
 .	;   #ACCEPT CR=27800; DATE=2007-05-07; PGM=Frans S.C. Witte; GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	SET vDum=$ZSEARCH("reset",0),vFul=$ZSEARCH(vFul,0)
 .	;*** End of code by-passed by compiler ***
 .	Q:(vFul="") 
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S $P(vobj(vOid,1),"|",2)=$$PARSE^%ZFUNC(vFul,"DIRECTORY")
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S $P(vobj(vOid,1),"|",1)=$$PARSE^%ZFUNC(vFul,"NAME")_$$PARSE^%ZFUNC(vFul,"TYPE")
 .	S vOK=1
 .	Q 
 I vCase=0!vOK Q vOK
 ;
 N vLow S vLow=""
 F vElm=1:1:$S((vSearch=""):0,1:$L(vSearch,vDelim)) D  Q:vOK 
 .	S vDir=$piece(vSearch,vDelim,vElm)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S vLow=$$LOWER^UCGMR($$FILE^%TRNLNM(vFile,vDir))
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S vDir=$$FILE^%TRNLNM("*",vDir)
 .	;
 .	;   #ACCEPT CR=27800; DATE=2007-05-07; PGM=Frans S.C. Witte; GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	SET vDum=$ZSEARCH("reset",0)
 .	FOR  SET vFul=$ZSEARCH(vDir,0) QUIT:vFul=""!($$LOWER^UCGMR(vFul)=vLow)
 .	;*** End of code by-passed by compiler ***
 .	;
 .	Q:(vFul="") 
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S $P(vobj(vOid,1),"|",2)=$$PARSE^%ZFUNC(vFul,"DIRECTORY")
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S $P(vobj(vOid,1),"|",1)=$$PARSE^%ZFUNC(vFul,"NAME")_$$PARSE^%ZFUNC(vFul,"TYPE")
 .	S vOK=1
 .	Q 
 Q vOK
 ;
 ; ---------------------------------------------------------------------
open(vOid,vRtn,vSrn,vOnm) ; Runtime implementation of IO.open with support for character sets
 ;
 N vF S vF=$P(vobj(vOid,1),"|",1)
 I (vF="") S $ZE="0,"_$ZPOS_","_"%PSL-E-IOOPEN,missing file name",$EC=",U1001,"
 I '($P(vobj(vOid,1),"|",6)="") S $ZE="0,"_$ZPOS_","_"%PSL-E-IOOPEN,device already open",$EC=",U1001,"
 ;
 N vD S vD=$P(vobj(vOid,1),"|",2)
 ; if vD.isNull(),$$PARSE^%ZFUNC(vF,"DIRECTORY").isNull() set vD = $$^UCXCUVAR("SPLDIR")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (vD=""),vF'["/" S vD=$$TRNLNM^%ZFUNC("SCAU_SPOOL")
 ;
 N vP S vP=$P(vobj(vOid,1),"|",3)
 N vC S vC=$P(vobj(vOid,1),"|",7)
 ;
 I (vC="") D  ; no IO.charsetName specified, derive it
 .	N vT S vT=$P(vobj(vOid,1),"|",9)
 .	N vN S vN=$P(vobj(vOid,1),"|",8)
 .	;
 .	I (vT="") S vT="Routine" S vN=vRtn
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ..		;    #ACCEPT CR=22273; DATE=2006-07-10; PGM=Frans S.C. Witte; GROUP=ACCESS
 ..		S vC=$$^UCIOENCD(vT,vN,vSrn,vOnm)
 ..		S $P(vobj(vOid,1),"|",7)=vC
 ..		Q 
 .	Q 
 ;
 ; Independent of call to $$^UCIOENCD(): if characterset, then add it (quoted)
 ;if 'vC.isNull() set vP = vP_ "/ICHSET="_ vC_ "/OCHSET="_ vC
 I '(vC="") S vP=vP_"/CHSET="""_vC_""""
 ;
 ;  #ACCEPT CR=22273; DATE=2006-07-10; PGM=Frans S.C. Witte; GROUP=DEPRECATED,ACCESS
 S $piece(vobj($G(vOid),1),"|",6)=$$FILE^%TRNLNM(vF,vD)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N vR S vR=$$FILE^%ZOPEN($P(vobj(vOid,1),"|",6),vP,$P(vobj(vOid,1),"|",4),$P(vobj(vOid,1),"|",5))
 I +vR=0 S $ZE="0,"_$ZPOS_","_"%PSL-E-IOOPEN,"_$piece(vR,"|",2),$EC=",U1001,"
 Q 
 ;
 ; ---------------------------------------------------------------------
read(vOid) ; Runtime implementation of IO.read()
 N vEr
 ;
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 N vIo S vIo=$I ; save current device
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N vRd S vRd=$$^%ZREAD($P(vobj(vOid,1),"|",6),.vEr)
 ;
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I vIo'=$I USE vIo ; restore previous device if needed
 ;
 I +vEr'=0 N vo2 S vo2="%PSL-E-IO"_$piece("EOF,NOTOPEN,OTHER",",",vEr)_","_$piece(vEr,"|",2),$ZE="0,"_$ZPOS_","_vo2,$EC=",U1001,"
 Q vRd
 ;
 ; ---------------------------------------------------------------------
write(vOid,vStr,vEol) ; Runtime implementation of IO.write
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 N vIo S vIo=$I ; save current device
 ;
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I '($D(vEol)#2) USE $P(vobj(vOid,1),"|",6) WRITE vStr,!
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 E  USE $P(vobj(vOid,1),"|",6) WRITE vStr,vEol S $X=0
 ;
 ;  #ACCEPT CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 I vIo'=$I USE vIo ; restore previous device if needed
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61314^43156^Frans S.C. Witte^11953" ; Signature - LTD^TIME^USER^SIZE
 ;
vCatch1 ; Error trap
 ;
 N vX,$ET,$ES S vX=$ZE,$EC="",$ET="Q",$ZE=""
 ; ignore exceptions thrown due to $$^UCIOENCD()
 D ZX^UCGMR(voxMrk) Q 
