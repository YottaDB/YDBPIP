 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCXDT25 ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl.upgrade
 ;  #OPTION ResultClass ON
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
cmpStamp() ; 
 Q $$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$vtim2str($P($H,",",2),"24:60")_" - "_$$USERNAM^%ZFUNC
 ;
 ; ---------------------------------------------------------------------
copyright() ; 
 N line S line=" // Copyright(c)"_$$vdat2str($P($H,",",1),"YEAR")
 S line=line_" Fidelity National Information Services, Inc.  All Rights Reserved"
 ;
 Q line_" - "_$$cmpStamp()
 ;
 ; ---------------------------------------------------------------------
getSrc(proc,src) ; PSL source array  /MECH=REFARR:W
 ;
 N ln S ln=1
 N ret S ret=""
 ;
 ; Try direct M - remove this or move after .psl file at some point
 D
 .	;   #ACCEPT Date=07/19/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	N i,n,rec
 .	S rec=$G(^DBTBL("SYSDEV",25,proc))
 .	Q:rec=""
 .	S ret=$P(rec,"|",2)
 .	S n=""
 .	F i=1:1 S n=$O(^DBTBL("SYSDEV",25,proc,n)) Q:n=""  S src(i)=^(n)
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 ; Try .psl file
 I (ret="") D
 .	;
 .	N pslIO S pslIO=$$vClVobj($ST,"IO")
 .	;
 .	S $P(vobj(pslIO,1),"|",2)=$$getFWDirectory
 .	S $P(vobj(pslIO,1),"|",1)=proc_".psl"
 .	S $P(vobj(pslIO,1),"|",3)="READ"
 .	S $P(vobj(pslIO,1),"|",4)=5
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	D open^UCIO(pslIO,$T(+0),"getSrc","pslIO")
 .	;
 .	F  S src(ln)=$$read^UCIO(pslIO) S ln=ln+1
 .	K vobj(+$G(pslIO)) Q 
 ;
 Q ret
 ;
 ; ---------------------------------------------------------------------
isProc(UNIT) ; name of unit
 ;
 N isProc S isProc=0
 ;
 N pslIO S pslIO=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(pslIO,1),"|",2)=$$getFWDirectory
 S $P(vobj(pslIO,1),"|",1)=UNIT_".psl"
 S $P(vobj(pslIO,1),"|",3)="READ"
 S $P(vobj(pslIO,1),"|",4)=5
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	D open^UCIO(pslIO,$T(+0),"isProc","pslIO")
 .	;
 .	S isProc=1
 .	;
 .	D close^UCIO(pslIO)
 .	Q 
 ;
 ; Check DBTBL25 - use bypass for now - remove eventually
 I 'isProc D
 .	;
 .	;   #ACCEPT Date=07/19/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	I $D(^DBTBL("SYSDEV",25,UNIT)) S isProc=1
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 K vobj(+$G(pslIO)) Q isProc
 ;
 ; ---------------------------------------------------------------------
getFWDirectory() ; Framework directory
 ;
 ;  #ACCEPT Date=07/20/2008; Pgm=RussellDS; CR=30801; Group=ACCESS
 N fwDir S fwDir=$$TRNLNM^%ZFUNC("SCAU_CRTNS")
 ;
 I '($E(fwDir,$L(fwDir))="/") S fwDir=fwDir_"/"
 ;
 Q fwDir_"framework/"
 ;
 ; ---------------------------------------------------------------------
loadTokenizer(proc,tknzr) ; load DBTBL25D into PSLTokenizer
 N ret S ret=""
 ;
 Q ret
 ;
 ; ---------------------------------------------------------------------
MDCFirstLine(line,rtn,stamp) ; 
 N fpl S fpl=$piece($piece(line," "),"(",2)
 N d S d=+$piece(stamp,",")
 N t S t=+$piece(stamp,",",2)
 ;
 I $L(line,";")<4 S $piece(line,";",2)=";;"_$piece(line,";",2)
 ;
 S $piece(line,";",1)=rtn_$S((fpl=""):"",1:"("_fpl)_" "
 S $piece(line,";",2)=$$USERNAM^%ZFUNC
 S $piece(line,";",3)=$S(d'="":$ZD(d,"YEAR-MM-DD"),1:"")_" "_$$vtim2str(t,"24:60:SS")
 Q line
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61201^73661^Dan Russell^9586" ; Signature - LTD^TIME^USER^SIZE
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
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vCatch2 ; Error trap
 ;
 N ioerror,$ET,$ES S ioerror=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I '($P(vobj(pslIO,1),"|",6)="") D close^UCIO(pslIO)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N ioerror,$ET,$ES S ioerror=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I '($P(vobj(pslIO,1),"|",6)="") D close^UCIO(pslIO)
 ;
 I '($P(ioerror,",",3)["IO") S $ZE=ioerror,$EC=",U1001,"
 ;
 ; Found it, save procedure name
 I ($P(ioerror,",",3)["IOEOF") S ret=proc
 D ZX^UCGMR(voxMrk) Q 
