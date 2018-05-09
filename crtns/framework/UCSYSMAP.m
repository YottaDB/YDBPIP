 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCSYSMAP ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;
UCSYSMAP(PGM,msrc,sysmap,cmperr) ; 
 N vpc,vTp
 ;
 N ELEMENT N ELEMTYPE N pdata N subRou N TARGET
 ;
 ; If we get an error, rollback the transaction, before re-throwing
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 S subRou="^UCSYSMAP"
 S TARGET=sysmap("RTNNAME")
 ;
 Q:(TARGET="") 
 ;
 S ELEMENT=$piece(PGM,"~",1)
 S ELEMTYPE=$piece(PGM,"~",2)
 ;
 I (",Batch,Filer,Procedure,Report,Screen,"[(","_ELEMTYPE_",")) D  Q:($piece($get(cmperr),"|",1)>0) 
 .	;
 .	N maprtns,vop1 S maprtns=$$vRCgetRecord1Opt^RecordSYSMAPRTNS(TARGET,0,.vop1)
 .	;
 . S vpc=($G(vop1)=0) Q:vpc  ; OK, doesn't exist yet
 .	;
 . S vpc=(($P(maprtns,$C(124),1)=ELEMTYPE)&($P(maprtns,$C(124),2)=ELEMENT)) Q:vpc  ; OK, same
 .	;
 .	; If "orphaned", i.e., element no longer exists, OK.  Otherwise, conflict.
 .	I ELEMTYPE="Batch",'($D(^DBTBL("SYSDEV",33,ELEMENT))#2)
 .	E  I ELEMTYPE="Filer",'($D(^DBTBL("SYSDEV",1,ELEMENT)))
 .	E  I ELEMTYPE="Procedure",'($D(^DBTBL("SYSDEV",25,ELEMENT))#2)
 .	E  I ELEMTYPE="Report",'($D(^DBTBL("SYSDEV",5,ELEMENT)))
 .	E  I ELEMTYPE="Screen",'($D(^DBTBL("SYSDEV",2,ELEMENT)))
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	E  D warnGroup^UCGM("MISMATCH","Module name ("_TARGET_") conflicts with "_$P(maprtns,$C(124),1)_" "_$P(maprtns,$C(124),2))
 . Q 
 ;
 ; Save data to SYSMAP tables
 TS (vobj):transactionid="CS"
 ;
 D delTarget(TARGET)
 ;
 D SAVCMDS(TARGET,ELEMTYPE,.sysmap,.msrc)
 D SAVLITDT(TARGET,.sysmap,.cmperr)
 D SAVLITFN(TARGET,.sysmap,.cmperr)
 D SAVMETHS(TARGET,ELEMTYPE,.sysmap,.msrc)
 D SAVDATA0(TARGET,ELEMTYPE,.sysmap,.msrc,.cmperr,.pdata)
 D SAVDATA1(TARGET,ELEMTYPE,.sysmap,.msrc,.pdata)
 D SAVVAR(TARGET,ELEMTYPE,.sysmap,.msrc,0)
 D SAVVAR(TARGET,ELEMTYPE,.sysmap,.msrc,1)
 D SAVGVN(TARGET,ELEMTYPE,.sysmap,.msrc,0)
 D SAVGVN(TARGET,ELEMTYPE,.sysmap,.msrc,1)
 D SAVLABLS(TARGET,.sysmap)
 D SAVCALLS(TARGET,ELEMTYPE,ELEMENT,.sysmap,.msrc)
 ;
 ; Map functions used as literals in other elements
 D MAPLITFN(TARGET,.sysmap,.pdata)
 ;
 ; Create map of routines to PSL elements (SYSMAPRTNS)
 N sysmapr S sysmapr=$$vcdmNew^RecordSYSMAPRTNS() S vobj(sysmapr,-3)=TARGET
 ;
  S $P(vobj(sysmapr),$C(124),1)=ELEMTYPE
  S $P(vobj(sysmapr),$C(124),2)=ELEMENT
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPRTNS(sysmapr,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapr,-100) S vobj(sysmapr,-2)=1 TC:vTp  
 ;
 I ($piece($get(cmperr),"|",1)>0) D
 .	;
 .  TRO:$TL>0 
 .	Q 
 ;
 E   TC:$TL 
 ;
 K vobj(+$G(sysmapr)) Q 
 ;
 ; ---------------------------------------------------------------------
clean(val) ; clean value for use in SYSMAP tables
 I val?.ANP Q val
 I $E(val,1)="@" Q "@?"
 Q $translate(val,$char(9)," ")
 ;
 ; ---------------------------------------------------------------------
delAll() ; DELETE FROM SYSMAP*
 TS (vobj):transactionid="CS"
 ;
 D vDbDe1()
 D vDbDe2()
 D vDbDe3()
 D vDbDe4()
 D vDbDe5()
 D vDbDe6()
 D vDbDe7()
 D vDbDe8()
 D vDbDe9()
 D vDbDe10()
 ;
  TC:$TL 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
delTarget(TARGET) ; DELETE FROM SYSMAP* WHERE TARGET = :TARGET
 TS (vobj):transactionid="CS"
 ;
 N dsdel,vos1,vos2,vos3,vos4,vos5 S dsdel=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 .	;
 .	N XTARGET
 . N litfnc,vop1 S vop1=$P(dsdel,$C(9),3),litfnc=$$vRCgetRecord1Opt^RecordSYSMAPLITFNC($P(dsdel,$C(9),1),$P(dsdel,$C(9),2),vop1,1,"")
 .	;
 .	S XTARGET=vop1
 .	;
 .	N rs,vos6,vos7,vos8,vos9,vos10,vos11 S rs=$$vOpen2()
 .	;
 .	F  Q:'$$vFetch2()  D
 ..  N func S func=rs
 ..		;
 ..		I $piece(func,"^",2)=TARGET  N V1 S V1=func D vDbDe11()
 ..		Q 
 . Q 
 ;
 ; Eliminate old SYSMAP table entries
 D vDbDe12()
 D vDbDe13()
 D vDbDe14()
 D vDbDe15()
 D vDbDe16()
 D vDbDe17()
 D vDbDe18()
 D vDbDe19()
 D vDbDe20()
  ZWI ^SYSMAP("RTN2ELEM",TARGET)
 ;
  TC:$TL 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVCMDS(TARGET,ELEMTYPE,sysmap,msrc) ; 
 N vTp
 N command N label
 ;
 S (command,label)=""
 F  S label=$order(sysmap("T",label)) Q:(label="")  D
 .	F  S command=$order(sysmap("T",label,command)) Q:(command="")  D
 ..		;
 ..		N LABEL
 ..		;
 ..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		N sysmapc S sysmapc=$$vcdmNew^RecordSYSMAPCOMMANDS() S vobj(sysmapc,-3)=TARGET S vobj(sysmapc,-4)=LABEL S vobj(sysmapc,-5)=command
 ..		;
 ..	  S $P(vobj(sysmapc),$C(124),1)=sysmap("T",label,command)
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPCOMMANDS(sysmapc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapc,-100) S vobj(sysmapc,-2)=1 TC:vTp  
 ..		K vobj(+$G(sysmapc)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVLITDT(TARGET,sysmap,cmperr) ; 
 N vTp
 N column N table
 ;
 S table=""
 F  S table=$order(sysmap("#IF","Db.isDefined",table)) Q:(table="")  D
 .	;
 .	S column=$piece(sysmap("#IF","Db.isDefined",table),$char(9))
 .	;
 .	N sysmapld S sysmapld=$$vcdmNew^RecordSYSMAPLITDTA() S vobj(sysmapld,-3)=TARGET S vobj(sysmapld,-4)=table S vobj(sysmapld,-5)=column S vobj(sysmapld,-6)="0"
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPLITDTA(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 TC:vTp  
 .	;
 .	D FILERCHK(table,.cmperr)
 .	K vobj(+$G(sysmapld)) Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVLITFN(TARGET,sysmap,cmperr) ; 
 N vTp
 N func S func=""
 ;
 F  S func=$order(sysmap("#IF","FUNC",func)) Q:(func="")  D
 .	N FUNCFILE N XLABEL
 .	;
 .	S FUNCFILE=$$clean($piece(func,"^",2))
 .	S XLABEL=$$clean($piece(func,"^",1))
 .	I (XLABEL="") S XLABEL=FUNCFILE
 .	;
 .	N sysmaplf S sysmaplf=$$vcdmNew^RecordSYSMAPLITFNC() S vobj(sysmaplf,-3)=FUNCFILE S vobj(sysmaplf,-4)=XLABEL S vobj(sysmaplf,-5)=TARGET
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPLITFNC(sysmaplf,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmaplf,-100) S vobj(sysmaplf,-2)=1 TC:vTp  
 .	;
 .	N ds,vos1,vos2,vos3,vos4,vos5,vos6 S ds=$$vOpen3()
 .	;
 .	F  Q:'$$vFetch3()  D
 ..		N column N table
 ..  N sysmapp,vop1,vop2 S vop2=$P(ds,$C(9),3),vop1=$P(ds,$C(9),4),sysmapp=$$vRCgetRecord1Opt^RecordSYSMAPPROPDATA($P(ds,$C(9),1),$P(ds,$C(9),2),vop2,vop1,1,"")
 ..		;
 ..		S table=vop2
 ..		S column=vop1
 ..		;
 ..		N sysmapld S sysmapld=$$vRCgetRecord1^RecordSYSMAPLITDTA(TARGET,table,column,func,0)
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPLITDTA(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 TC:vTp  
 ..		;
 ..		D FILERCHK(table,.cmperr)
 ..  K vobj(+$G(sysmapld)) Q 
 . K vobj(+$G(sysmaplf)) Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVMETHS(TARGET,ELEMTYPE,sysmap,msrc) ; 
 N vTp
 N classmet N label
 ;
 S (classmet,label)=""
 F  S label=$order(sysmap("M",label)) Q:(label="")  D
 .	F  S classmet=$order(sysmap("M",label,classmet)) Q:(classmet="")  D
 ..		N class N LABEL N method
 ..		;
 ..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		S class=$piece(classmet,".",1)
 ..		S method=$piece(classmet,".",2)
 ..		;
 ..		I ($E(class,1,6)="Record") S class="Record"
 ..		;
 ..		N sysmapm S sysmapm=$$vRCgetRecord1^RecordSYSMAPM(TARGET,LABEL,class,method,0)
 ..		;
 ..	  S $P(vobj(sysmapm),$C(124),1)=$P(vobj(sysmapm),$C(124),1)+1
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPM(sysmapm,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapm,-100) S vobj(sysmapm,-2)=1 TC:vTp  
 ..		K vobj(+$G(sysmapm)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVDATA0(TARGET,ELEMTYPE,sysmap,msrc,cmperr,pdata) ; 
 N vTp,vpc
 N label N tabcol
 ;
 S (label,tabcol)=""
 F  S label=$order(sysmap("P0",label)) Q:(label="")  D
 .	F  S tabcol=$order(sysmap("P0",label,tabcol)) Q:(tabcol="")  D
 ..		N column N LABEL N objname N table N X
 ..		;
 ..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		S table=$ZCONVERT($piece(tabcol,".",1),"U")
 ..		S column=$ZCONVERT($piece(tabcol,".",2),"U")
 ..		Q:(column="") 
 ..		;
 ..		N sysmappd S sysmappd=$$vRCgetRecord1^RecordSYSMAPPROPDATA(TARGET,LABEL,table,column,0)
 ..		;
 ..	  S $P(vobj(sysmappd),$C(124),1)=$P(vobj(sysmappd),$C(124),1)+1
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPPROPDATA(sysmappd,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmappd,-100) S vobj(sysmappd,-2)=1 TC:vTp  
 ..		;
 ..		S pdata(table,column,LABEL)=""
 ..		;
 ..		; Determine if literal
 ..		S objname=$piece(sysmap("P0",label,tabcol),$char(9))
 ..		S vpc=(objname="") K:vpc vobj(+$G(sysmappd)) Q:vpc 
 ..		;
 ..		S X=$get(sysmap("V0",label,objname))
 ..		;
 ..		I ($E(X,1,7)="LITERAL") D
 ...			N sysmapld S sysmapld=$$vRCgetRecord1^RecordSYSMAPLITDTA(TARGET,table,column,"0",0)
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPLITDTA(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 TC:vTp  
 ...			D FILERCHK(table,.cmperr)
 ...			K vobj(+$G(sysmapld)) Q 
 ..		K vobj(+$G(sysmappd)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVDATA1(TARGET,ELEMTYPE,sysmap,msrc,pdata) ; 
 N vTp
 N label N tabcol
 ;
 S (label,tabcol)=""
 F  S label=$order(sysmap("P1",label)) Q:(label="")  D
 .	F  S tabcol=$order(sysmap("P1",label,tabcol)) Q:(tabcol="")  D
 ..		N column N LABEL N table
 ..		;
 ..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		S table=$ZCONVERT($piece(tabcol,".",1),"U")
 ..		S column=$ZCONVERT($piece(tabcol,".",2),"U")
 ..		;
 ..		I '(column="") D
 ...			N sysmappd S sysmappd=$$vRCgetRecord1^RecordSYSMAPPROPDATA(TARGET,LABEL,table,column,0)
 ...			;
 ...		  S $P(vobj(sysmappd),$C(124),2)=$P(vobj(sysmappd),$C(124),2)+1
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPPROPDATA(sysmappd,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmappd,-100) S vobj(sysmappd,-2)=1 TC:vTp  
 ...			;
 ...			S pdata(table,column,LABEL)=""
 ...			K vobj(+$G(sysmappd)) Q 
 ..		Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVGVN(TARGET,ELEMTYPE,sysmap,msrc,varid) ; 
 N vTp
 N item N label N varref
 ;
 S item="G"_varid
 ;
 S (label,varref)=""
 F  S label=$order(sysmap(item,label)) Q:(label="")  D
 .	F  S varref=$order(sysmap(item,label,varref)) Q:(varref="")  D
 ..		N LABEL S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		N var S var=$$clean(varref)
 ..		N sysmapg S sysmapg=$$vRCgetRecord1^RecordSYSMAPMPROPS(TARGET,LABEL,var,0)
 ..		;
 ..		I (varid=0)  S $P(vobj(sysmapg),$C(124),1)=$P(vobj(sysmapg),$C(124),1)+1
 ..		E   S $P(vobj(sysmapg),$C(124),2)=$P(vobj(sysmapg),$C(124),2)+1
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPMPROPS(sysmapg,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapg,-100) S vobj(sysmapg,-2)=1 TC:vTp  
 ..		K vobj(+$G(sysmapg)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVVAR(TARGET,ELEMTYPE,sysmap,msrc,varid) ; 
 N vTp
 N item N label N varref
 ;
 S item="V"_varid
 ;
 S (label,varref)=""
 F  S label=$order(sysmap(item,label)) Q:(label="")  D
 .	F  S varref=$order(sysmap(item,label,varref)) Q:(varref="")  D
 ..		N LABEL N var
 ..		;
 ..		S var=$$clean($piece(varref,"(",1))
 ..		;
 ..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		N sysmapv S sysmapv=$$vRCgetRecord1^RecordSYSMAPVAR(TARGET,LABEL,var,0)
 ..		;
 ..		I (varid=0)  S $P(vobj(sysmapv),$C(124),1)=$P(vobj(sysmapv),$C(124),1)+1
 ..		E   S $P(vobj(sysmapv),$C(124),2)=$P(vobj(sysmapv),$C(124),2)+1
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPVAR(sysmapv,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapv,-100) S vobj(sysmapv,-2)=1 TC:vTp  
 ..		K vobj(+$G(sysmapv)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVLABLS(TARGET,sysmap) ; 
 N vTp
 N label S label=""
 ;
 F  S label=$order(sysmap("L",label)) Q:(label="")  D
 .	;
 .	I '(($E(label,1)="v")!(label=" ")) D
 ..		N sysmapl S sysmapl=$$vcdmNew^RecordSYSMAPLABELS() S vobj(sysmapl,-3)=TARGET S vobj(sysmapl,-4)=label
 ..		 S vobj(sysmapl,1,1)=""
 ..		N SEP S SEP=$E(sysmap("L",label,0),1)
 ..		;
 ..	  S vobj(sysmapl,1,1)=$piece(sysmap("L",label,0),SEP,4)
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPLABELS(sysmapl,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapl,-100) S vobj(sysmapl,-2)=1 TC:vTp  
 ..		K vobj(+$G(sysmapl)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
SAVCALLS(TARGET,ELEMTYPE,ELEMENT,sysmap,msrc) ; 
 N vTp
 N calls N label
 ;
 S (calls,label)=""
 F  S label=$order(sysmap("C",label)) Q:(label="")  D
 .	F  S calls=$order(sysmap("C",label,calls)) Q:(calls="")  D
 ..		N i
 ..		N clab N cparams N crtn N LABEL
 ..		;
 ..		I (calls["^") S crtn=$$clean($piece(calls,"^",2))
 ..		E  D
 ...			I $E(calls,1)="@" S crtn=$$clean(calls)
 ...			E  S crtn=TARGET ; modified FSCW@2007-07-13: ELEMENT
 ...			Q 
 ..		;
 ..		S clab=$$clean($piece(calls,"^",1))
 ..		I (clab="") S clab=crtn
 ..		;
 ..		;type RecordSYSMAPRTNS sysmapr = Db.getRecord("SYSMAPRTNS", "TARGET=:crtn", 1)
 ..		;if (sysmapr.getMode() > 0) set crtn = sysmapr.element
 ..		;
 ..		S cparams=sysmap("C",label,calls)
 ..		F i=1:1:$L(cparams,",") S $piece(cparams,",",i)=$$vStrTrim($piece(cparams,",",i),0," ")
 ..		;
 ..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
 ..		;if LABEL.isNull() set LABEL = label
 ..		;
 ..		I LABEL=" " Q 
 ..		;
 ..		N sysmapc S sysmapc=$$vRCgetRecord1^RecordSYSMAPCALLS(TARGET,LABEL,crtn,clab,0)
 ..		;
 ..	  S $P(vobj(sysmapc),$C(124),1)=cparams
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPCALLS(sysmapc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapc,-100) S vobj(sysmapc,-2)=1 TC:vTp  
 ..		K vobj(+$G(sysmapc)) Q 
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
MAPLITFN(FUNCFILE,sysmap,pdata) ; 
 N vTp
 N dsset,vos1,vos2,vos3,vos4,vos5 S dsset=$$vOpen4()
 ;
 F  Q:'$$vFetch4()  D
 .	N COLUMN N FUNC N LABEL N TABLE N XTARGET
 . N sysmaplf,vop1,vop2 S vop2=$P(dsset,$C(9),2),vop1=$P(dsset,$C(9),3),sysmaplf=$$vRCgetRecord1Opt^RecordSYSMAPLITFNC($P(dsset,$C(9),1),vop2,vop1,1,"")
 .	;
 .	S LABEL=vop2
 .	S XTARGET=vop1
 .	;
 .	S FUNC=LABEL_"^"_FUNCFILE
 .	;
 .	S (COLUMN,TABLE)=""
 .	F  S TABLE=$order(pdata(TABLE)) Q:(TABLE="")  D
 ..		F  S COLUMN=$order(pdata(TABLE,COLUMN)) Q:(COLUMN="")  D
 ...			I ($D(pdata(TABLE,COLUMN,LABEL))#2) D
 ....				N sysmapld S sysmapld=$$vRCgetRecord1^RecordSYSMAPLITDTA(XTARGET,TABLE,COLUMN,FUNC,0)
 ....				;
 ....				I ($G(vobj(sysmapld,-2))=0) S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSYSMAPLITDTA(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 TC:vTp  
 ....				K vobj(+$G(sysmapld)) Q 
 ...			Q 
 ..		Q 
 . Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
getElement(MODULE) ; module name
 N vret
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen5()
 I $$vFetch5() S vret=$TR(rs,$C(9),"~") Q vret
 Q ""
 ;
 ; ---------------------------------------------------------------------
GETLABEL(INLABEL,ELEMTYPE,msrc,sysmap) ; Labels map  /MECH=REFARR:R
 N MSRCNO
 N RETURN N SEP N TAG
 ;
 S TAG=$piece(INLABEL,"+",1)
 S RETURN=$get(sysmap("L",TAG,0))
 S SEP=$E(RETURN,1)
 S MSRCNO=+$piece(RETURN,SEP,2)
 ;
 S RETURN=TAG
 ;
 I (MSRCNO>0) D
 .	;
 .	I (ELEMTYPE="Filer") S RETURN=$$SYSMAPLB^DBSFILB(TAG,msrc(MSRCNO))
 .	E  I (ELEMTYPE="Batch") S RETURN=$$SYSMAPLB^DBSBCH(TAG,msrc(MSRCNO))
 .	I (RETURN="") S RETURN=TAG
 .	Q 
 ;
 I (RETURN="") S RETURN=" "
 ;
 Q RETURN
 ;
 ; ---------------------------------------------------------------------
FILERCHK(TABLE,cmperr) ; Error array (*2)
 N isOK
 ;
 ; Check to be sure version of filer contains code for checking literals
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	N filer S filer="Record"_$ZCONVERT(TABLE,"U")
 .	S isOK=$$vhasLiterals^@filer
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I 'isOK D warnGroup^UCGM("SYSMAP","Regenerate filer for literals - table "_TABLE)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61530^32570^Frans S.C. Witte^25071" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SYSMAPCALLS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("CALLS",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM SYSMAPCOMMANDS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen7()
 F  Q:'$$vFetch7()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("COMMAND",v1,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM SYSMAPLABELS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen8()
 F  Q:'$$vFetch8()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	K ^SYSMAP("LABELS",v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe4() ; DELETE FROM SYSMAPLITDTA
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen9()
 F  Q:'$$vFetch9()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("LITDATA",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe5() ; DELETE FROM SYSMAPLITFNC
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen10()
 F  Q:'$$vFetch10()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("LITFUNC",v1,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe6() ; DELETE FROM SYSMAPM
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen11()
 F  Q:'$$vFetch11()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("METHOD",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe7() ; DELETE FROM SYSMAPMPROPS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen12()
 F  Q:'$$vFetch12()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("DATA",v1,v2,"G",v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe8() ; DELETE FROM SYSMAPPROPDATA
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4,vos5,vos6 S vDs=$$vOpen13()
 F  Q:'$$vFetch13()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordSYSMAPPROPDATA($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSYSMAPPROPDATA(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe9() ; DELETE FROM SYSMAPVAR
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen14()
 F  Q:'$$vFetch14()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("DATA",v1,v2,"V",v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe10() ; DELETE FROM SYSMAPRTNS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3 S vRs=$$vOpen15()
 F  Q:'$$vFetch15()  D
 . S v1=vRs
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("RTN2ELEM",v1)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe11() ; DELETE FROM SYSMAPLITDTA WHERE TARGET=:XTARGET AND FUNC=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen16()
 F  Q:'$$vFetch16()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("LITDATA",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe12() ; DELETE FROM SYSMAPCALLS WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen17()
 F  Q:'$$vFetch17()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("CALLS",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe13() ; DELETE FROM SYSMAPCOMMANDS WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen18()
 F  Q:'$$vFetch18()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("COMMAND",v1,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe14() ; DELETE FROM SYSMAPLABELS WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen19()
 F  Q:'$$vFetch19()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	K ^SYSMAP("LABELS",v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe15() ; DELETE FROM SYSMAPLITDTA WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen20()
 F  Q:'$$vFetch20()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("LITDATA",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe16() ; DELETE FROM SYSMAPLITFNC WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen21()
 F  Q:'$$vFetch21()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("LITFUNC",v1,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe17() ; DELETE FROM SYSMAPM WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen22()
 F  Q:'$$vFetch22()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("METHOD",v1,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe18() ; DELETE FROM SYSMAPMPROPS WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen23()
 F  Q:'$$vFetch23()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("DATA",v1,v2,"G",v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe19() ; DELETE FROM SYSMAPPROPDATA WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4,vos5,vos6 S vDs=$$vOpen24()
 F  Q:'$$vFetch24()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordSYSMAPPROPDATA($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSYSMAPPROPDATA(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe20() ; DELETE FROM SYSMAPVAR WHERE TARGET=:TARGET
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen25()
 F  Q:'$$vFetch25()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SYSMAP("DATA",v1,v2,"V",v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ;
vOpen1() ; FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC WHERE FUNCFILE=:TARGET
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^SYSMAP("LITFUNC",vos3,vos4),1) I vos4="" G vL1a0
 S vos5=""
vL1a6 S vos5=$O(^SYSMAP("LITFUNC",vos3,vos4,vos5),1) I vos5="" G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dsdel="" Q 0
 ;
 S dsdel=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen10() ; FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC
 ;
 ;
 S vos1=2
 D vL10a1
 Q ""
 ;
vL10a0 S vos1=0 Q
vL10a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL10a3 S vos3=$O(^SYSMAP("LITFUNC",vos3),1) I vos3="" G vL10a0
 S vos4=""
vL10a5 S vos4=$O(^SYSMAP("LITFUNC",vos3,vos4),1) I vos4="" G vL10a3
 S vos5=""
vL10a7 S vos5=$O(^SYSMAP("LITFUNC",vos3,vos4,vos5),1) I vos5="" G vL10a5
 Q
 ;
vFetch10() ;
 ;
 ;
 I vos1=1 D vL10a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen11() ; TARGET,LABEL,CLASS,METHOD FROM SYSMAPM
 ;
 ;
 S vos1=2
 D vL11a1
 Q ""
 ;
vL11a0 S vos1=0 Q
vL11a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL11a3 S vos3=$O(^SYSMAP("METHOD",vos3),1) I vos3="" G vL11a0
 S vos4=""
vL11a5 S vos4=$O(^SYSMAP("METHOD",vos3,vos4),1) I vos4="" G vL11a3
 S vos5=""
vL11a7 S vos5=$O(^SYSMAP("METHOD",vos3,vos4,vos5),1) I vos5="" G vL11a5
 S vos6=""
vL11a9 S vos6=$O(^SYSMAP("METHOD",vos3,vos4,vos5,vos6),1) I vos6="" G vL11a7
 Q
 ;
vFetch11() ;
 ;
 ;
 I vos1=1 D vL11a9
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen12() ; TARGET,LABEL,GLOBALREF FROM SYSMAPMPROPS
 ;
 ;
 S vos1=2
 D vL12a1
 Q ""
 ;
vL12a0 S vos1=0 Q
vL12a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL12a3 S vos3=$O(^SYSMAP("DATA",vos3),1) I vos3="" G vL12a0
 S vos4=""
vL12a5 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL12a3
 S vos5=""
vL12a7 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"G",vos5),1) I vos5="" G vL12a5
 Q
 ;
vFetch12() ;
 ;
 ;
 I vos1=1 D vL12a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen13() ; TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA
 ;
 ;
 S vos1=2
 D vL13a1
 Q ""
 ;
vL13a0 S vos1=0 Q
vL13a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL13a3 S vos3=$O(^SYSMAP("DATA",vos3),1) I vos3="" G vL13a0
 S vos4=""
vL13a5 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL13a3
 S vos5=""
vL13a7 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"P",vos5),1) I vos5="" G vL13a5
 S vos6=""
vL13a9 S vos6=$O(^SYSMAP("DATA",vos3,vos4,"P",vos5,vos6),1) I vos6="" G vL13a7
 Q
 ;
vFetch13() ;
 ;
 ;
 I vos1=1 D vL13a9
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen14() ; TARGET,LABEL,VAR FROM SYSMAPVAR
 ;
 ;
 S vos1=2
 D vL14a1
 Q ""
 ;
vL14a0 S vos1=0 Q
vL14a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL14a3 S vos3=$O(^SYSMAP("DATA",vos3),1) I vos3="" G vL14a0
 S vos4=""
vL14a5 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL14a3
 S vos5=""
vL14a7 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"V",vos5),1) I vos5="" G vL14a5
 Q
 ;
vFetch14() ;
 ;
 ;
 I vos1=1 D vL14a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen15() ; TARGET FROM SYSMAPRTNS
 ;
 ;
 S vos1=2
 D vL15a1
 Q ""
 ;
vL15a0 S vos1=0 Q
vL15a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL15a3 S vos3=$O(^SYSMAP("RTN2ELEM",vos3),1) I vos3="" G vL15a0
 Q
 ;
vFetch15() ;
 ;
 ;
 I vos1=1 D vL15a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen16() ; TARGET,TABLE,COLUMN,FUNC FROM SYSMAPLITDTA WHERE TARGET=:XTARGET AND FUNC=:V1
 ;
 ;
 S vos1=2
 D vL16a1
 Q ""
 ;
vL16a0 S vos1=0 Q
vL16a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(XTARGET) I vos3="" G vL16a0
 S vos4=$G(V1) I vos4="" G vL16a0
 S vos5=""
vL16a5 S vos5=$O(^SYSMAP("LITDATA",vos3,vos5),1) I vos5="" G vL16a0
 S vos6=""
vL16a7 S vos6=$O(^SYSMAP("LITDATA",vos3,vos5,vos6),1) I vos6="" G vL16a5
 I '($D(^SYSMAP("LITDATA",vos3,vos5,vos6,vos4))#2) G vL16a7
 Q
 ;
vFetch16() ;
 ;
 ;
 I vos1=1 D vL16a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)_$C(9)_vos4
 ;
 Q 1
 ;
vOpen17() ; TARGET,LABEL,CALLELEM,CALLLAB FROM SYSMAPCALLS WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL17a1
 Q ""
 ;
vL17a0 S vos1=0 Q
vL17a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL17a0
 S vos4=""
vL17a4 S vos4=$O(^SYSMAP("CALLS",vos3,vos4),1) I vos4="" G vL17a0
 S vos5=""
vL17a6 S vos5=$O(^SYSMAP("CALLS",vos3,vos4,vos5),1) I vos5="" G vL17a4
 S vos6=""
vL17a8 S vos6=$O(^SYSMAP("CALLS",vos3,vos4,vos5,vos6),1) I vos6="" G vL17a6
 Q
 ;
vFetch17() ;
 ;
 ;
 I vos1=1 D vL17a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen18() ; TARGET,LABEL,COMMAND FROM SYSMAPCOMMANDS WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL18a1
 Q ""
 ;
vL18a0 S vos1=0 Q
vL18a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL18a0
 S vos4=""
vL18a4 S vos4=$O(^SYSMAP("COMMAND",vos3,vos4),1) I vos4="" G vL18a0
 S vos5=""
vL18a6 S vos5=$O(^SYSMAP("COMMAND",vos3,vos4,vos5),1) I vos5="" G vL18a4
 Q
 ;
vFetch18() ;
 ;
 ;
 I vos1=1 D vL18a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen19() ; TARGET,LABEL FROM SYSMAPLABELS WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL19a1
 Q ""
 ;
vL19a0 S vos1=0 Q
vL19a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL19a0
 S vos4=""
vL19a4 S vos4=$O(^SYSMAP("LABELS",vos3,vos4),1) I vos4="" G vL19a0
 Q
 ;
vFetch19() ;
 ;
 ;
 I vos1=1 D vL19a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; FUNC FROM SYSMAPLITDTA WHERE TARGET=:XTARGET AND FUNC <> '0'
 ;
 ;
 S vos6=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos6=0 Q
vL2a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(XTARGET) I vos8="" G vL2a0
 S vos9=""
vL2a4 S vos9=$O(^SYSMAP("LITDATA",vos8,vos9),1) I vos9="" G vL2a0
 S vos10=""
vL2a6 S vos10=$O(^SYSMAP("LITDATA",vos8,vos9,vos10),1) I vos10="" G vL2a4
 S vos11=""
vL2a8 S vos11=$O(^SYSMAP("LITDATA",vos8,vos9,vos10,vos11),1) I vos11="" G vL2a6
 I '(vos11'="0") G vL2a8
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos6=1 D vL2a8
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rs="" Q 0
 ;
 S rs=$S(vos11=vos7:"",1:vos11)
 ;
 Q 1
 ;
vOpen20() ; TARGET,TABLE,COLUMN,FUNC FROM SYSMAPLITDTA WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL20a1
 Q ""
 ;
vL20a0 S vos1=0 Q
vL20a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL20a0
 S vos4=""
vL20a4 S vos4=$O(^SYSMAP("LITDATA",vos3,vos4),1) I vos4="" G vL20a0
 S vos5=""
vL20a6 S vos5=$O(^SYSMAP("LITDATA",vos3,vos4,vos5),1) I vos5="" G vL20a4
 S vos6=""
vL20a8 S vos6=$O(^SYSMAP("LITDATA",vos3,vos4,vos5,vos6),1) I vos6="" G vL20a6
 Q
 ;
vFetch20() ;
 ;
 ;
 I vos1=1 D vL20a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen21() ; FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL21a1
 Q ""
 ;
vL21a0 S vos1=0 Q
vL21a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL21a0
 S vos4=""
vL21a4 S vos4=$O(^SYSMAP("LITFUNC",vos4),1) I vos4="" G vL21a0
 S vos5=""
vL21a6 S vos5=$O(^SYSMAP("LITFUNC",vos4,vos5),1) I vos5="" G vL21a4
 I '($D(^SYSMAP("LITFUNC",vos4,vos5,vos3))#2) G vL21a6
 Q
 ;
vFetch21() ;
 ;
 ;
 I vos1=1 D vL21a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_vos3
 ;
 Q 1
 ;
vOpen22() ; TARGET,LABEL,CLASS,METHOD FROM SYSMAPM WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL22a1
 Q ""
 ;
vL22a0 S vos1=0 Q
vL22a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL22a0
 S vos4=""
vL22a4 S vos4=$O(^SYSMAP("METHOD",vos3,vos4),1) I vos4="" G vL22a0
 S vos5=""
vL22a6 S vos5=$O(^SYSMAP("METHOD",vos3,vos4,vos5),1) I vos5="" G vL22a4
 S vos6=""
vL22a8 S vos6=$O(^SYSMAP("METHOD",vos3,vos4,vos5,vos6),1) I vos6="" G vL22a6
 Q
 ;
vFetch22() ;
 ;
 ;
 I vos1=1 D vL22a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen23() ; TARGET,LABEL,GLOBALREF FROM SYSMAPMPROPS WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL23a1
 Q ""
 ;
vL23a0 S vos1=0 Q
vL23a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL23a0
 S vos4=""
vL23a4 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL23a0
 S vos5=""
vL23a6 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"G",vos5),1) I vos5="" G vL23a4
 Q
 ;
vFetch23() ;
 ;
 ;
 I vos1=1 D vL23a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen24() ; TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL24a1
 Q ""
 ;
vL24a0 S vos1=0 Q
vL24a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL24a0
 S vos4=""
vL24a4 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL24a0
 S vos5=""
vL24a6 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"P",vos5),1) I vos5="" G vL24a4
 S vos6=""
vL24a8 S vos6=$O(^SYSMAP("DATA",vos3,vos4,"P",vos5,vos6),1) I vos6="" G vL24a6
 Q
 ;
vFetch24() ;
 ;
 ;
 I vos1=1 D vL24a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen25() ; TARGET,LABEL,VAR FROM SYSMAPVAR WHERE TARGET=:TARGET
 ;
 ;
 S vos1=2
 D vL25a1
 Q ""
 ;
vL25a0 S vos1=0 Q
vL25a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TARGET) I vos3="" G vL25a0
 S vos4=""
vL25a4 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL25a0
 S vos5=""
vL25a6 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"V",vos5),1) I vos5="" G vL25a4
 Q
 ;
vFetch25() ;
 ;
 ;
 I vos1=1 D vL25a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen3() ; TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA WHERE TARGET=:FUNCFILE
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FUNCFILE) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^SYSMAP("DATA",vos3,vos4),1) I vos4="" G vL3a0
 S vos5=""
vL3a6 S vos5=$O(^SYSMAP("DATA",vos3,vos4,"P",vos5),1) I vos5="" G vL3a4
 S vos6=""
vL3a8 S vos6=$O(^SYSMAP("DATA",vos3,vos4,"P",vos5,vos6),1) I vos6="" G vL3a6
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen4() ; FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC WHERE FUNCFILE=:FUNCFILE
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FUNCFILE) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^SYSMAP("LITFUNC",vos3,vos4),1) I vos4="" G vL4a0
 S vos5=""
vL4a6 S vos5=$O(^SYSMAP("LITFUNC",vos3,vos4,vos5),1) I vos5="" G vL4a4
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dsset="" Q 0
 ;
 S dsset=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen5() ; ELEMENT,ELEMTYPE FROM SYSMAPRTNS WHERE TARGET=:MODULE
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(MODULE) I vos3="" G vL5a0
 I '($D(^SYSMAP("RTN2ELEM",vos3))#2) G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos4=$G(^SYSMAP("RTN2ELEM",vos3))
 S rs=$P(vos4,"|",2)_$C(9)_$P(vos4,"|",1)
 S vos1=0
 ;
 Q 1
 ;
vOpen6() ; TARGET,LABEL,CALLELEM,CALLLAB FROM SYSMAPCALLS
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL6a3 S vos3=$O(^SYSMAP("CALLS",vos3),1) I vos3="" G vL6a0
 S vos4=""
vL6a5 S vos4=$O(^SYSMAP("CALLS",vos3,vos4),1) I vos4="" G vL6a3
 S vos5=""
vL6a7 S vos5=$O(^SYSMAP("CALLS",vos3,vos4,vos5),1) I vos5="" G vL6a5
 S vos6=""
vL6a9 S vos6=$O(^SYSMAP("CALLS",vos3,vos4,vos5,vos6),1) I vos6="" G vL6a7
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a9
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen7() ; TARGET,LABEL,COMMAND FROM SYSMAPCOMMANDS
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL7a3 S vos3=$O(^SYSMAP("COMMAND",vos3),1) I vos3="" G vL7a0
 S vos4=""
vL7a5 S vos4=$O(^SYSMAP("COMMAND",vos3,vos4),1) I vos4="" G vL7a3
 S vos5=""
vL7a7 S vos5=$O(^SYSMAP("COMMAND",vos3,vos4,vos5),1) I vos5="" G vL7a5
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen8() ; TARGET,LABEL FROM SYSMAPLABELS
 ;
 ;
 S vos1=2
 D vL8a1
 Q ""
 ;
vL8a0 S vos1=0 Q
vL8a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL8a3 S vos3=$O(^SYSMAP("LABELS",vos3),1) I vos3="" G vL8a0
 S vos4=""
vL8a5 S vos4=$O(^SYSMAP("LABELS",vos3,vos4),1) I vos4="" G vL8a3
 Q
 ;
vFetch8() ;
 ;
 ;
 I vos1=1 D vL8a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen9() ; TARGET,TABLE,COLUMN,FUNC FROM SYSMAPLITDTA
 ;
 ;
 S vos1=2
 D vL9a1
 Q ""
 ;
vL9a0 S vos1=0 Q
vL9a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL9a3 S vos3=$O(^SYSMAP("LITDATA",vos3),1) I vos3="" G vL9a0
 S vos4=""
vL9a5 S vos4=$O(^SYSMAP("LITDATA",vos3,vos4),1) I vos4="" G vL9a3
 S vos5=""
vL9a7 S vos5=$O(^SYSMAP("LITDATA",vos3,vos4,vos5),1) I vos5="" G vL9a5
 S vos6=""
vL9a9 S vos6=$O(^SYSMAP("LITDATA",vos3,vos4,vos5,vos6),1) I vos6="" G vL9a7
 Q
 ;
vFetch9() ;
 ;
 ;
 I vos1=1 D vL9a9
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 S isOK=0
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 TRO:$TL>0 
 S $ZE=error,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
