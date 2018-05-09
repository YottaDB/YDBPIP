UCSYSMAP(PGM,msrc,sysmap,cmperr)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCSYSMAP ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	N vpc
	;
	N ELEMENT N ELEMTYPE N pdata N subRou N TARGET
	;
	; Don't even bother if we already have errors
	Q:($piece($get(cmperr),"|",1)>0) 
	;
	; If we get an error, report it as a warning
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	S subRou="^UCSYSMAP"
	;
	S TARGET=sysmap("RTNNAME")
	;
	Q:(TARGET="") 
	;
	S ELEMENT=$piece(PGM,"~",1)
	S ELEMTYPE=$piece(PGM,"~",2)
	;
	I (",Batch,Filer,Procedure,Report,Screen,"[(","_ELEMTYPE_",")) D  Q:($piece($get(cmperr),"|",1)>0) 
	.	;
	.	N maprtns,vop1 S maprtns=$$vDb10(TARGET,.vop1)
	.	;
	.	S vpc=(($G(vop1)=0)) Q:vpc  ; OK, doesn't exist yet
	.	;
	.	S vpc=((($P(maprtns,$C(124),1)=ELEMTYPE)&($P(maprtns,$C(124),2)=ELEMENT))) Q:vpc  ; OK, same
	.	;
	.	; If "orphaned", i.e., element no longer exists, OK.  Otherwise, conflict.
	.	I ELEMTYPE="Batch",'($D(^DBTBL("SYSDEV",33,ELEMENT))#2)
	.	E  I ELEMTYPE="Filer",'($D(^DBTBL("SYSDEV",1,ELEMENT)))
	.	E  I ELEMTYPE="Procedure",'($D(^DBTBL("SYSDEV",25,ELEMENT))#2)
	.	E  I ELEMTYPE="Report",'($D(^DBTBL("SYSDEV",5,ELEMENT)))
	.	E  I ELEMTYPE="Screen",'($D(^DBTBL("SYSDEV",2,ELEMENT)))
	.	E  D warnGroup^UCGM("MISMATCH","Routine name ("_TARGET_") conflicts with "_$P(maprtns,$C(124),1)_" "_$P(maprtns,$C(124),2))
	.	Q 
	;
	; Save data to SYSMAP tables
	;
	Tstart (vobj):transactionid="CS"
	;
	N dsdel,vos1,vos2,vos3,vos4 S dsdel=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N XTARGET
	.	;
	.	N litfnc,vop2 S vop2=$P(dsdel,$C(9),3),litfnc=$G(^SYSMAP("LITFUNC",$P(dsdel,$C(9),1),$P(dsdel,$C(9),2),vop2))
	.	;
	.	S XTARGET=vop2
	.	;
	.	N rs,vos5,vos6,vos7,vos8,vos9 S rs=$$vOpen2()
	.	;
	.	F  Q:'($$vFetch2())  D
	..		;
	..		N func S func=rs
	..		;
	..		I $piece(func,"^",2)=TARGET  N V1 S V1=func D vDbDe1()
	..		Q 
	.	Q 
	;
	; Eliminate old SYSMAP table entries
	D vDbDe2()
	D vDbDe3()
	D vDbDe4()
	D vDbDe5()
	D vDbDe6()
	D vDbDe7()
	D vDbDe8()
	D vDbDe9()
	D vDbDe10()
	ZWI ^SYSMAP("RTN2ELEM",TARGET)
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
	N sysmapr,vop3,vop4 S sysmapr="",vop3=TARGET,vop4=0
	;
	S $P(sysmapr,$C(124),1)=ELEMTYPE
	S $P(sysmapr,$C(124),2)=ELEMENT
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^SYSMAP("RTN2ELEM",vop3)=$$RTBAR^%ZFUNC(sysmapr) S vop4=1 Tcommit:vTp  
	;
	I ($piece($get(cmperr),"|",1)>0) D
	.	;
	. Trollback:$Tlevel 
	.	Q 
	;
	E  Tcommit:$Tlevel 
	;
	Q 
	;
	; ---------------------------------------------------------------------
clean(val)	; clean value for use in SYSMAP tables
	I val?.ANP Q val
	I $E(val,1)="@" Q "@?"
	Q $translate(val,$char(9)," ")
	;
	; ---------------------------------------------------------------------
delAll()	; DELETE FROM SYSMAP*
	;
	Tstart (vobj):transactionid="CS"
	;
	D vDbDe11()
	D vDbDe12()
	D vDbDe13()
	D vDbDe14()
	D vDbDe15()
	D vDbDe16()
	D vDbDe17()
	D vDbDe18()
	D vDbDe19()
	D vDbDe20()
	;
	Tcommit:$Tlevel 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVCMDS(TARGET,ELEMTYPE,sysmap,msrc)	;
	;
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
	..		N sysmapc S sysmapc=$$vDbNew2(TARGET,LABEL,command)
	..		;
	..	 S $P(vobj(sysmapc),$C(124),1)=sysmap("T",label,command)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPCOMM(sysmapc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapc,-100) S vobj(sysmapc,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(sysmapc)) Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVLITDT(TARGET,sysmap,cmperr)	;
	;
	N column N table
	;
	S table=""
	F  S table=$order(sysmap("#IF","Db.isDefined",table)) Q:(table="")  D
	.	;
	.	S column=sysmap("#IF","Db.isDefined",table)
	.	;
	.	N sysmapld S sysmapld=$$vDbNew3(TARGET,table,column,"0")
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SYSMAPLD(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 Tcommit:vTp  
	.	;
	.	D FILERCHK(table,.cmperr)
	.	K vobj(+$G(sysmapld)) Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVLITFN(TARGET,sysmap,cmperr)	;
	;
	N func S func=""
	;
	F  S func=$order(sysmap("#IF","FUNC",func)) Q:(func="")  D
	.	;
	.	N FUNCFILE N XLABEL
	.	;
	.	S FUNCFILE=$$clean($piece(func,"^",2))
	.	S XLABEL=$$clean($piece(func,"^",1))
	.	I (XLABEL="") S XLABEL=FUNCFILE
	.	;
	.	N sysmaplf,vop1,vop2,vop3,vop4 S sysmaplf="",vop3=FUNCFILE,vop2=XLABEL,vop1=TARGET,vop4=0
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^SYSMAP("LITFUNC",vop3,vop2,vop1)=$$RTBAR^%ZFUNC(sysmaplf) S vop4=1 Tcommit:vTp  
	.	;
	.	N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen3()
	.	;
	.	F  Q:'($$vFetch3())  D
	..		;
	..		N column N table
	..		;
	..		N sysmapp,vop5,vop6 S vop6=$P(ds,$C(9),3),vop5=$P(ds,$C(9),4),sysmapp=$G(^SYSMAP("DATA",$P(ds,$C(9),1),$P(ds,$C(9),2),"P",vop6,vop5))
	..		;
	..		S table=vop6
	..		S column=vop5
	..		;
	..		N sysmapld S sysmapld=$$vDb4(TARGET,table,column,func)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SYSMAPLD(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 Tcommit:vTp  
	..		;
	..		D FILERCHK(table,.cmperr)
	..		K vobj(+$G(sysmapld)) Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVMETHS(TARGET,ELEMTYPE,sysmap,msrc)	;
	;
	N classmet N label
	;
	S (classmet,label)=""
	F  S label=$order(sysmap("M",label)) Q:(label="")  D
	.	F  S classmet=$order(sysmap("M",label,classmet)) Q:(classmet="")  D
	..		;
	..		N class N LABEL N method
	..		;
	..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
	..		;
	..		I LABEL=" " Q 
	..		;
	..		S class=$piece(classmet,".",1)
	..		S method=$piece(classmet,".",2)
	..		;
	..		I (($E(class,1,6)="Record")) S class="Record"
	..		;
	..		N sysmapm S sysmapm=$$vDb5(TARGET,LABEL,class,method)
	..		;
	..	 S $P(vobj(sysmapm),$C(124),1)=$P(vobj(sysmapm),$C(124),1)+1
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPMETHO(sysmapm,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapm,-100) S vobj(sysmapm,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(sysmapm)) Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVDATA0(TARGET,ELEMTYPE,sysmap,msrc,cmperr,pdata)	;
	N vpc
	;
	N label N tabcol
	;
	S (label,tabcol)=""
	F  S label=$order(sysmap("P0",label)) Q:(label="")  D
	.	F  S tabcol=$order(sysmap("P0",label,tabcol)) Q:(tabcol="")  D
	..		;
	..		N column N LABEL N objname N table N X
	..		;
	..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
	..		;
	..		I LABEL=" " Q 
	..		;
	..		S table=$$vStrUC($piece(tabcol,".",1))
	..		S column=$$vStrUC($piece(tabcol,".",2))
	..		Q:(column="") 
	..		;
	..		N sysmappd S sysmappd=$$vDb3(TARGET,LABEL,table,column)
	..		;
	..	 S $P(vobj(sysmappd),$C(124),1)=$P(vobj(sysmappd),$C(124),1)+1
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPPPROP(sysmappd,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmappd,-100) S vobj(sysmappd,-2)=1 Tcommit:vTp  
	..		;
	..		S pdata(table,column,LABEL)=""
	..		;
	..		; Determine if literal
	..		;
	..		S objname=$get(sysmap("P0",label,tabcol,1))
	..		S vpc=((objname="")) K:vpc vobj(+$G(sysmappd)) Q:vpc 
	..		;
	..		S X=$get(sysmap("V0",label,objname,1))
	..		;
	..		I (($E(X,1,7)="LITERAL")) D
	...			;
	...			N sysmapld S sysmapld=$$vDb4(TARGET,table,column,"0")
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SYSMAPLD(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 Tcommit:vTp  
	...			;
	...			D FILERCHK(table,.cmperr)
	...			K vobj(+$G(sysmapld)) Q 
	..		K vobj(+$G(sysmappd)) Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVDATA1(TARGET,ELEMTYPE,sysmap,msrc,pdata)	;
	;
	N label N tabcol
	;
	S (label,tabcol)=""
	F  S label=$order(sysmap("P1",label)) Q:(label="")  D
	.	F  S tabcol=$order(sysmap("P1",label,tabcol)) Q:(tabcol="")  D
	..		;
	..		N column N LABEL N table
	..		;
	..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
	..		;
	..		I LABEL=" " Q 
	..		;
	..		S table=$$vStrUC($piece(tabcol,".",1))
	..		S column=$$vStrUC($piece(tabcol,".",2))
	..		;
	..		I '(column="") D
	...			;
	...			N sysmappd S sysmappd=$$vDb3(TARGET,LABEL,table,column)
	...			;
	...		 S $P(vobj(sysmappd),$C(124),2)=$P(vobj(sysmappd),$C(124),2)+1
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPPPROP(sysmappd,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmappd,-100) S vobj(sysmappd,-2)=1 Tcommit:vTp  
	...			;
	...			S pdata(table,column,LABEL)=""
	...			K vobj(+$G(sysmappd)) Q 
	..		Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVGVN(TARGET,ELEMTYPE,sysmap,msrc,varid)	;
	;
	N item N label N varref
	;
	S item="G"_varid
	;
	S (label,varref)=""
	F  S label=$order(sysmap(item,label)) Q:(label="")  D
	.	F  S varref=$order(sysmap(item,label,varref)) Q:(varref="")  D
	..		;
	..		N LABEL S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
	..		;
	..		I LABEL=" " Q 
	..		;
	..		N var S var=$$clean(varref)
	..		;
	..		 N V1 S V1=var I '($D(^OBJECT(V1))) D
	...			;
	...			N sysmapg S sysmapg=$$vDb6(TARGET,LABEL,var)
	...			;
	...			I (varid=0) S $P(vobj(sysmapg),$C(124),1)=$P(vobj(sysmapg),$C(124),1)+1
	...			E  S $P(vobj(sysmapg),$C(124),2)=$P(vobj(sysmapg),$C(124),2)+1
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPMPROP(sysmapg,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapg,-100) S vobj(sysmapg,-2)=1 Tcommit:vTp  
	...			K vobj(+$G(sysmapg)) Q 
	..		Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SAVVAR(TARGET,ELEMTYPE,sysmap,msrc,varid)	;
	;
	N item N label N varref
	;
	S item="V"_varid
	;
	S (label,varref)=""
	F  S label=$order(sysmap(item,label)) Q:(label="")  D
	.	F  S varref=$order(sysmap(item,label,varref)) Q:(varref="")  D
	..		;
	..		N LABEL N var
	..		;
	..		S var=$$clean($piece(varref,"(",1))
	..		;
	..		S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
	..		;
	..		I LABEL=" " Q 
	..		;
	..		 N V1 S V1=var I '($D(^OBJECT(V1))) D
	...			;
	...			N sysmapv S sysmapv=$$vDb7(TARGET,LABEL,var)
	...			;
	...			I (varid=0) S $P(vobj(sysmapv),$C(124),1)=$P(vobj(sysmapv),$C(124),1)+1
	...			E  S $P(vobj(sysmapv),$C(124),2)=$P(vobj(sysmapv),$C(124),2)+1
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPVAR(sysmapv,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapv,-100) S vobj(sysmapv,-2)=1 Tcommit:vTp  
	...			K vobj(+$G(sysmapv)) Q 
	..		Q 
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
SAVLABLS(TARGET,sysmap)	;
	;
	N label S label=""
	;
	F  S label=$order(sysmap("L",label)) Q:(label="")  D
	.	;
	.	I '((($E(label,1)="v"))!(label=" ")) D
	..		;
	..		N sysmapl S sysmapl=$$vDbNew5(TARGET,label)
	..		N SEP S SEP=$E(sysmap("L",label),1)
	..		;
	..	 S $P(vobj(sysmapl),$C(124),1)=$piece(sysmap("L",label),SEP,4)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPLABEL(sysmapl,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapl,-100) S vobj(sysmapl,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(sysmapl)) Q 
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
SAVCALLS(TARGET,ELEMTYPE,ELEMENT,sysmap,msrc)	;
	;
	N calls N label N lineno
	;
	S (calls,label,lineno)=""
	F  S label=$order(sysmap("C",label)) Q:(label="")  D
	.	F  S lineno=$order(sysmap("C",label,lineno)) Q:(lineno="")  D
	..		F  S calls=$order(sysmap("C",label,lineno,calls)) Q:(calls="")  D
	...			;
	...			N i
	...			N clab N cparams N crtn N LABEL
	...			;
	...			I (calls["^") S crtn=$$clean($piece(calls,"^",2))
	...			E  D
	....				I $E(calls,1)="@" S crtn=$$clean(calls)
	....				E  S crtn=ELEMENT
	....				Q 
	...			;
	...			S clab=$$clean($piece(calls,"^",1))
	...			I (clab="") S clab=crtn
	...			;
	...			N sysmapr,vop1 S sysmapr=$$vDb10(crtn,.vop1)
	...			I ($G(vop1)>0) S crtn=$P(sysmapr,$C(124),2)
	...			;
	...			S cparams=sysmap("C",label,lineno,calls)
	...			F i=1:1:$L(cparams,",") S $piece(cparams,",",i)=$$vStrTrim($piece(cparams,",",i),0," ")
	...			;
	...			S LABEL=$$GETLABEL(label,ELEMTYPE,.msrc,.sysmap)
	...			;if LABEL.isNull() set LABEL = label
	...			;
	...			I LABEL=" " Q 
	...			;
	...			N sysmapc S sysmapc=$$vDb8(TARGET,LABEL,crtn,clab)
	...			;
	...		 S $P(vobj(sysmapc),$C(124),1)=cparams
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^MAPCALLS(sysmapc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapc,-100) S vobj(sysmapc,-2)=1 Tcommit:vTp  
	...			K vobj(+$G(sysmapc)) Q 
	..		Q 
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
MAPLITFN(FUNCFILE,sysmap,pdata)	;
	;
	N dsset,vos1,vos2,vos3,vos4 S dsset=$$vOpen4()
	;
	F  Q:'($$vFetch4())  D
	.	;
	.	N COLUMN N FUNC N LABEL N TABLE N XTARGET
	.	;
	.	N sysmaplf,vop1,vop2 S vop2=$P(dsset,$C(9),2),vop1=$P(dsset,$C(9),3),sysmaplf=$G(^SYSMAP("LITFUNC",$P(dsset,$C(9),1),vop2,vop1))
	.	;
	.	S LABEL=vop2
	.	S XTARGET=vop1
	.	;
	.	S FUNC=LABEL_"^"_FUNCFILE
	.	;
	.	S (COLUMN,TABLE)=""
	.	F  S TABLE=$order(pdata(TABLE)) Q:(TABLE="")  D
	..		F  S COLUMN=$order(pdata(TABLE,COLUMN)) Q:(COLUMN="")  D
	...			;
	...			I ($D(pdata(TABLE,COLUMN,LABEL))#2) D
	....				;
	....				N sysmapld S sysmapld=$$vDb4(XTARGET,TABLE,COLUMN,FUNC)
	....				;
	....				I ($G(vobj(sysmapld,-2))=0) N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SYSMAPLD(sysmapld,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(sysmapld,-100) S vobj(sysmapld,-2)=1 Tcommit:vTp  
	....				K vobj(+$G(sysmapld)) Q 
	...			Q 
	..		Q 
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
GETLABEL(INLABEL,ELEMTYPE,msrc,sysmap)	;
	N MSRCNO
	N RETURN N SEP N TAG
	;
	S TAG=$piece(INLABEL,"+",1)
	S RETURN=$get(sysmap("L",TAG))
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
FILERCHK(TABLE,cmperr)	;
	N isOK
	N filer
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vDb11("SYSDEV",TABLE)
	 S vop3=$G(^DBTBL(vop1,1,vop2,99))
	;
	S filer=$P(vop3,$C(124),2)
	;
	; No filer (including invalid table)
	I (filer="") D ERROR^UCGM("Filer required for literal - table "_TABLE)
	;
	; Check to be sure version of filer contains code for checking literals
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	.	;
	.	S isOK=$$vLITCHK^@filer
	.	Q 
	;
	I 'isOK D warnGroup^UCGM("SYSMAP","Regenerate filer for literals - table "_TABLE)
	;
	Q 
	;
vSIG()	;
	Q "60660^56835^e0101874^22527" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SYSMAPLITDTA WHERE TARGET=:XTARGET AND FUNC=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LITDATA",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM SYSMAPCALLS WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("CALLS",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM SYSMAPCOMMANDS WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("COMMAND",v1,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe4()	; DELETE FROM SYSMAPLABELS WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen8()
	F  Q:'($$vFetch8())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LABELS",v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe5()	; DELETE FROM SYSMAPLITDTA WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen9()
	F  Q:'($$vFetch9())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LITDATA",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe6()	; DELETE FROM SYSMAPLITFNC WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen10()
	F  Q:'($$vFetch10())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LITFUNC",v1,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe7()	; DELETE FROM SYSMAPM WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen11()
	F  Q:'($$vFetch11())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("METHOD",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe8()	; DELETE FROM SYSMAPMPROPS WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen12()
	F  Q:'($$vFetch12())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("DATA",v1,v2,"G",v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe9()	; DELETE FROM SYSMAPPROPDATA WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4,vos5 S vDs=$$vOpen13()
	F  Q:'($$vFetch13())  D
	.	N vRec S vRec=$$vDb3($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4))
	.	S vobj(vRec,-2)=3
	.	D ^MAPPPROP(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe10()	; DELETE FROM SYSMAPVAR WHERE TARGET=:TARGET
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen14()
	F  Q:'($$vFetch14())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("DATA",v1,v2,"V",v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe11()	; DELETE FROM SYSMAPCALLS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen15()
	F  Q:'($$vFetch15())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("CALLS",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe12()	; DELETE FROM SYSMAPCOMMANDS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen16()
	F  Q:'($$vFetch16())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("COMMAND",v1,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe13()	; DELETE FROM SYSMAPLABELS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen17()
	F  Q:'($$vFetch17())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LABELS",v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe14()	; DELETE FROM SYSMAPLITDTA
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen18()
	F  Q:'($$vFetch18())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LITDATA",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe15()	; DELETE FROM SYSMAPLITFNC
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen19()
	F  Q:'($$vFetch19())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("LITFUNC",v1,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe16()	; DELETE FROM SYSMAPM
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen20()
	F  Q:'($$vFetch20())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("METHOD",v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe17()	; DELETE FROM SYSMAPMPROPS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen21()
	F  Q:'($$vFetch21())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("DATA",v1,v2,"G",v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe18()	; DELETE FROM SYSMAPPROPDATA
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4,vos5 S vDs=$$vOpen22()
	F  Q:'($$vFetch22())  D
	.	N vRec S vRec=$$vDb3($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4))
	.	S vobj(vRec,-2)=3
	.	D ^MAPPPROP(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe19()	; DELETE FROM SYSMAPVAR
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen23()
	F  Q:'($$vFetch23())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("DATA",v1,v2,"V",v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe20()	; DELETE FROM SYSMAPRTNS
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2 S vRs=$$vOpen24()
	F  Q:'($$vFetch24())  D
	.	S v1=vRs
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SYSMAP("RTN2ELEM",v1)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	;
vDb10(v1,v2out)	;	voXN = Db.getRecord(SYSMAPRTNS,,1,-2)
	;
	N maprtns
	S maprtns=$G(^SYSMAP("RTN2ELEM",v1))
	I maprtns="",'$D(^SYSMAP("RTN2ELEM",v1))
	S v2out='$T
	;
	Q maprtns
	;
vDb11(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,1)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	;
	Q dbtbl1
	;
vDb3(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPPROPDATA,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPPROPDATA"
	S vobj(vOid)=$G(^SYSMAP("DATA",v1,v2,"P",v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("DATA",v1,v2,"P",v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb4(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPLITDTA,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPLITDTA"
	S vobj(vOid)=$G(^SYSMAP("LITDATA",v1,v2,v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("LITDATA",v1,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb5(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPM,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPM"
	S vobj(vOid)=$G(^SYSMAP("METHOD",v1,v2,v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("METHOD",v1,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb6(v1,v2,v3)	;	vobj()=Db.getRecord(SYSMAPMPROPS,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPMPROPS"
	S vobj(vOid)=$G(^SYSMAP("DATA",v1,v2,"G",v3))
	I vobj(vOid)="",'$D(^SYSMAP("DATA",v1,v2,"G",v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb7(v1,v2,v3)	;	vobj()=Db.getRecord(SYSMAPVAR,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPVAR"
	S vobj(vOid)=$G(^SYSMAP("DATA",v1,v2,"V",v3))
	I vobj(vOid)="",'$D(^SYSMAP("DATA",v1,v2,"V",v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb8(v1,v2,v3,v4)	;	vobj()=Db.getRecord(SYSMAPCALLS,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPCALLS"
	S vobj(vOid)=$G(^SYSMAP("CALLS",v1,v2,v3,v4))
	I vobj(vOid)="",'$D(^SYSMAP("CALLS",v1,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(SYSMAPCOMMANDS)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPCOMMANDS",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew3(v1,v2,v3,v4)	;	vobj()=Class.new(SYSMAPLITDTA)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPLITDTA",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDbNew5(v1,v2)	;	vobj()=Class.new(SYSMAPLABELS)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSYSMAPLABELS",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC WHERE FUNCFILE=:TARGET
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(TARGET) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^SYSMAP("LITFUNC",vos2,vos3),1) I vos3="" G vL1a0
	S vos4=""
vL1a5	S vos4=$O(^SYSMAP("LITFUNC",vos2,vos3,vos4),1) I vos4="" G vL1a3
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S dsdel=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen10()	;	FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL10a1
	Q ""
	;
vL10a0	S vos1=0 Q
vL10a1	S vos2=$G(TARGET) I vos2="" G vL10a0
	S vos3=""
vL10a3	S vos3=$O(^SYSMAP("LITFUNC",vos3),1) I vos3="" G vL10a0
	S vos4=""
vL10a5	S vos4=$O(^SYSMAP("LITFUNC",vos3,vos4),1) I vos4="" G vL10a3
	I '($D(^SYSMAP("LITFUNC",vos3,vos4,vos2))#2) G vL10a5
	Q
	;
vFetch10()	;
	;
	;
	I vos1=1 D vL10a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_vos2
	;
	Q 1
	;
vOpen11()	;	TARGET,LABEL,CLASS,METHOD FROM SYSMAPM WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL11a1
	Q ""
	;
vL11a0	S vos1=0 Q
vL11a1	S vos2=$G(TARGET) I vos2="" G vL11a0
	S vos3=""
vL11a3	S vos3=$O(^SYSMAP("METHOD",vos2,vos3),1) I vos3="" G vL11a0
	S vos4=""
vL11a5	S vos4=$O(^SYSMAP("METHOD",vos2,vos3,vos4),1) I vos4="" G vL11a3
	S vos5=""
vL11a7	S vos5=$O(^SYSMAP("METHOD",vos2,vos3,vos4,vos5),1) I vos5="" G vL11a5
	Q
	;
vFetch11()	;
	;
	;
	I vos1=1 D vL11a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen12()	;	TARGET,LABEL,GLOBALREF FROM SYSMAPMPROPS WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL12a1
	Q ""
	;
vL12a0	S vos1=0 Q
vL12a1	S vos2=$G(TARGET) I vos2="" G vL12a0
	S vos3=""
vL12a3	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL12a0
	S vos4=""
vL12a5	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"G",vos4),1) I vos4="" G vL12a3
	Q
	;
vFetch12()	;
	;
	;
	I vos1=1 D vL12a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen13()	;	TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL13a1
	Q ""
	;
vL13a0	S vos1=0 Q
vL13a1	S vos2=$G(TARGET) I vos2="" G vL13a0
	S vos3=""
vL13a3	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL13a0
	S vos4=""
vL13a5	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4),1) I vos4="" G vL13a3
	S vos5=""
vL13a7	S vos5=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4,vos5),1) I vos5="" G vL13a5
	Q
	;
vFetch13()	;
	;
	;
	I vos1=1 D vL13a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen14()	;	TARGET,LABEL,VAR FROM SYSMAPVAR WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL14a1
	Q ""
	;
vL14a0	S vos1=0 Q
vL14a1	S vos2=$G(TARGET) I vos2="" G vL14a0
	S vos3=""
vL14a3	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL14a0
	S vos4=""
vL14a5	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"V",vos4),1) I vos4="" G vL14a3
	Q
	;
vFetch14()	;
	;
	;
	I vos1=1 D vL14a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen15()	;	TARGET,LABEL,CALLELEM,CALLLAB FROM SYSMAPCALLS
	;
	;
	S vos1=2
	D vL15a1
	Q ""
	;
vL15a0	S vos1=0 Q
vL15a1	S vos2=""
vL15a2	S vos2=$O(^SYSMAP("CALLS",vos2),1) I vos2="" G vL15a0
	S vos3=""
vL15a4	S vos3=$O(^SYSMAP("CALLS",vos2,vos3),1) I vos3="" G vL15a2
	S vos4=""
vL15a6	S vos4=$O(^SYSMAP("CALLS",vos2,vos3,vos4),1) I vos4="" G vL15a4
	S vos5=""
vL15a8	S vos5=$O(^SYSMAP("CALLS",vos2,vos3,vos4,vos5),1) I vos5="" G vL15a6
	Q
	;
vFetch15()	;
	;
	;
	I vos1=1 D vL15a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen16()	;	TARGET,LABEL,COMMAND FROM SYSMAPCOMMANDS
	;
	;
	S vos1=2
	D vL16a1
	Q ""
	;
vL16a0	S vos1=0 Q
vL16a1	S vos2=""
vL16a2	S vos2=$O(^SYSMAP("COMMAND",vos2),1) I vos2="" G vL16a0
	S vos3=""
vL16a4	S vos3=$O(^SYSMAP("COMMAND",vos2,vos3),1) I vos3="" G vL16a2
	S vos4=""
vL16a6	S vos4=$O(^SYSMAP("COMMAND",vos2,vos3,vos4),1) I vos4="" G vL16a4
	Q
	;
vFetch16()	;
	;
	;
	I vos1=1 D vL16a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen17()	;	TARGET,LABEL FROM SYSMAPLABELS
	;
	;
	S vos1=2
	D vL17a1
	Q ""
	;
vL17a0	S vos1=0 Q
vL17a1	S vos2=""
vL17a2	S vos2=$O(^SYSMAP("LABELS",vos2),1) I vos2="" G vL17a0
	S vos3=""
vL17a4	S vos3=$O(^SYSMAP("LABELS",vos2,vos3),1) I vos3="" G vL17a2
	Q
	;
vFetch17()	;
	;
	;
	I vos1=1 D vL17a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen18()	;	TARGET,TABLE,COLUMN,FUNC FROM SYSMAPLITDTA
	;
	;
	S vos1=2
	D vL18a1
	Q ""
	;
vL18a0	S vos1=0 Q
vL18a1	S vos2=""
vL18a2	S vos2=$O(^SYSMAP("LITDATA",vos2),1) I vos2="" G vL18a0
	S vos3=""
vL18a4	S vos3=$O(^SYSMAP("LITDATA",vos2,vos3),1) I vos3="" G vL18a2
	S vos4=""
vL18a6	S vos4=$O(^SYSMAP("LITDATA",vos2,vos3,vos4),1) I vos4="" G vL18a4
	S vos5=""
vL18a8	S vos5=$O(^SYSMAP("LITDATA",vos2,vos3,vos4,vos5),1) I vos5="" G vL18a6
	Q
	;
vFetch18()	;
	;
	;
	I vos1=1 D vL18a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen19()	;	FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC
	;
	;
	S vos1=2
	D vL19a1
	Q ""
	;
vL19a0	S vos1=0 Q
vL19a1	S vos2=""
vL19a2	S vos2=$O(^SYSMAP("LITFUNC",vos2),1) I vos2="" G vL19a0
	S vos3=""
vL19a4	S vos3=$O(^SYSMAP("LITFUNC",vos2,vos3),1) I vos3="" G vL19a2
	S vos4=""
vL19a6	S vos4=$O(^SYSMAP("LITFUNC",vos2,vos3,vos4),1) I vos4="" G vL19a4
	Q
	;
vFetch19()	;
	;
	;
	I vos1=1 D vL19a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	FUNC FROM SYSMAPLITDTA WHERE TARGET=:XTARGET AND FUNC <> '0'
	;
	;
	S vos5=2
	D vL2a1
	Q ""
	;
vL2a0	S vos5=0 Q
vL2a1	S vos6=$G(XTARGET) I vos6="" G vL2a0
	S vos7=""
vL2a3	S vos7=$O(^SYSMAP("LITDATA",vos6,vos7),1) I vos7="" G vL2a0
	S vos8=""
vL2a5	S vos8=$O(^SYSMAP("LITDATA",vos6,vos7,vos8),1) I vos8="" G vL2a3
	S vos9=""
vL2a7	S vos9=$O(^SYSMAP("LITDATA",vos6,vos7,vos8,vos9),1) I vos9="" G vL2a5
	I '(vos9'="0") G vL2a7
	Q
	;
vFetch2()	;
	;
	;
	I vos5=1 D vL2a7
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S rs=$S(vos9=$C(254):"",1:vos9)
	;
	Q 1
	;
vOpen20()	;	TARGET,LABEL,CLASS,METHOD FROM SYSMAPM
	;
	;
	S vos1=2
	D vL20a1
	Q ""
	;
vL20a0	S vos1=0 Q
vL20a1	S vos2=""
vL20a2	S vos2=$O(^SYSMAP("METHOD",vos2),1) I vos2="" G vL20a0
	S vos3=""
vL20a4	S vos3=$O(^SYSMAP("METHOD",vos2,vos3),1) I vos3="" G vL20a2
	S vos4=""
vL20a6	S vos4=$O(^SYSMAP("METHOD",vos2,vos3,vos4),1) I vos4="" G vL20a4
	S vos5=""
vL20a8	S vos5=$O(^SYSMAP("METHOD",vos2,vos3,vos4,vos5),1) I vos5="" G vL20a6
	Q
	;
vFetch20()	;
	;
	;
	I vos1=1 D vL20a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen21()	;	TARGET,LABEL,GLOBALREF FROM SYSMAPMPROPS
	;
	;
	S vos1=2
	D vL21a1
	Q ""
	;
vL21a0	S vos1=0 Q
vL21a1	S vos2=""
vL21a2	S vos2=$O(^SYSMAP("DATA",vos2),1) I vos2="" G vL21a0
	S vos3=""
vL21a4	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL21a2
	S vos4=""
vL21a6	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"G",vos4),1) I vos4="" G vL21a4
	Q
	;
vFetch21()	;
	;
	;
	I vos1=1 D vL21a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen22()	;	TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA
	;
	;
	S vos1=2
	D vL22a1
	Q ""
	;
vL22a0	S vos1=0 Q
vL22a1	S vos2=""
vL22a2	S vos2=$O(^SYSMAP("DATA",vos2),1) I vos2="" G vL22a0
	S vos3=""
vL22a4	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL22a2
	S vos4=""
vL22a6	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4),1) I vos4="" G vL22a4
	S vos5=""
vL22a8	S vos5=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4,vos5),1) I vos5="" G vL22a6
	Q
	;
vFetch22()	;
	;
	;
	I vos1=1 D vL22a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen23()	;	TARGET,LABEL,VAR FROM SYSMAPVAR
	;
	;
	S vos1=2
	D vL23a1
	Q ""
	;
vL23a0	S vos1=0 Q
vL23a1	S vos2=""
vL23a2	S vos2=$O(^SYSMAP("DATA",vos2),1) I vos2="" G vL23a0
	S vos3=""
vL23a4	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL23a2
	S vos4=""
vL23a6	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"V",vos4),1) I vos4="" G vL23a4
	Q
	;
vFetch23()	;
	;
	;
	I vos1=1 D vL23a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen24()	;	TARGET FROM SYSMAPRTNS
	;
	;
	S vos1=2
	D vL24a1
	Q ""
	;
vL24a0	S vos1=0 Q
vL24a1	S vos2=""
vL24a2	S vos2=$O(^SYSMAP("RTN2ELEM",vos2),1) I vos2="" G vL24a0
	Q
	;
vFetch24()	;
	;
	;
	I vos1=1 D vL24a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen3()	;	TARGET,LABEL,TABLE,COLUMN FROM SYSMAPPROPDATA WHERE TARGET=:FUNCFILE
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(FUNCFILE) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^SYSMAP("DATA",vos2,vos3),1) I vos3="" G vL3a0
	S vos4=""
vL3a5	S vos4=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4),1) I vos4="" G vL3a3
	S vos5=""
vL3a7	S vos5=$O(^SYSMAP("DATA",vos2,vos3,"P",vos4,vos5),1) I vos5="" G vL3a5
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen4()	;	FUNCFILE,LABEL,TARGET FROM SYSMAPLITFNC WHERE FUNCFILE=:FUNCFILE
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(FUNCFILE) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^SYSMAP("LITFUNC",vos2,vos3),1) I vos3="" G vL4a0
	S vos4=""
vL4a5	S vos4=$O(^SYSMAP("LITFUNC",vos2,vos3,vos4),1) I vos4="" G vL4a3
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S dsset=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen5()	;	TARGET,TABLE,COLUMN,FUNC FROM SYSMAPLITDTA WHERE TARGET=:XTARGET AND FUNC=:V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(XTARGET) I vos2="" G vL5a0
	S vos3=$G(V1) I vos3="" G vL5a0
	S vos4=""
vL5a4	S vos4=$O(^SYSMAP("LITDATA",vos2,vos4),1) I vos4="" G vL5a0
	S vos5=""
vL5a6	S vos5=$O(^SYSMAP("LITDATA",vos2,vos4,vos5),1) I vos5="" G vL5a4
	I '($D(^SYSMAP("LITDATA",vos2,vos4,vos5,vos3))#2) G vL5a6
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)_$C(9)_vos3
	;
	Q 1
	;
vOpen6()	;	TARGET,LABEL,CALLELEM,CALLLAB FROM SYSMAPCALLS WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(TARGET) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^SYSMAP("CALLS",vos2,vos3),1) I vos3="" G vL6a0
	S vos4=""
vL6a5	S vos4=$O(^SYSMAP("CALLS",vos2,vos3,vos4),1) I vos4="" G vL6a3
	S vos5=""
vL6a7	S vos5=$O(^SYSMAP("CALLS",vos2,vos3,vos4,vos5),1) I vos5="" G vL6a5
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen7()	;	TARGET,LABEL,COMMAND FROM SYSMAPCOMMANDS WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(TARGET) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^SYSMAP("COMMAND",vos2,vos3),1) I vos3="" G vL7a0
	S vos4=""
vL7a5	S vos4=$O(^SYSMAP("COMMAND",vos2,vos3,vos4),1) I vos4="" G vL7a3
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen8()	;	TARGET,LABEL FROM SYSMAPLABELS WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(TARGET) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^SYSMAP("LABELS",vos2,vos3),1) I vos3="" G vL8a0
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen9()	;	TARGET,TABLE,COLUMN,FUNC FROM SYSMAPLITDTA WHERE TARGET=:TARGET
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(TARGET) I vos2="" G vL9a0
	S vos3=""
vL9a3	S vos3=$O(^SYSMAP("LITDATA",vos2,vos3),1) I vos3="" G vL9a0
	S vos4=""
vL9a5	S vos4=$O(^SYSMAP("LITDATA",vos2,vos3,vos4),1) I vos4="" G vL9a3
	S vos5=""
vL9a7	S vos5=$O(^SYSMAP("LITDATA",vos2,vos3,vos4,vos5),1) I vos5="" G vL9a5
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;do ZE^UTLERR
	;do ERROR^UCGM("UCSYSMAP error - "_error.thrownAt_" - "_error.description)
	D warnGroup^UCGM("SYSMAP","error - "_$P(error,",",2)_" - "_$P(error,",",4))
	Q 
	;
vtrap2	;	Error trap
	;
	N error S error=$ZS
	;
	S isOK=0
	Q 
