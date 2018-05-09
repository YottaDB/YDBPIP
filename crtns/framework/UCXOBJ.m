 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCXOBJ ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
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
rtClsIsAnc(a,d) ; Descendant class
 I d="Object"!(d=a) Q 0
 I a="Object" Q 1
 ;
 N cache  D vcdmNew^PSLParser(.cache,"PSLParser","")
 S cache("packageDirs")=$$packageDirs^PSLC("","") ; set default for all calls
 ;
 N ocd
 ;
 F  D  Q:a=d!(d="Object") 
 .	I $$isRecord^PSLClass(d)>1 D
 ..		S d=$E(d,7,1048575)
 ..		N td S td=$$getPslTbl^UCXDD(d,1)
 ..		S d="Record"_$P(td,"|",7)
 ..		Q 
 .	E  D
 ..		S ocd=$$getPSLClass^PSLCC(.cache,d)
 ..		S d=$P(ocd,$C(9),3)
 ..		Q 
 .	Q 
 Q d'="Object"
 ;
 ; ---------------------------------------------------------------------
rtClsByName(CLS) ; class name (*1)
 I $$isRecord^PSLClass(CLS)>0 Q CLS
 ;
 N name S name=""
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	N pslx  D vcdmNew^PSLX(.pslx,"PSLX",CLS)
 .	D classOnly^PSLX(.pslx)
 .	S name=pslx("moduleName") ; will have correct spelling
 .	N rwCls S rwCls=pslx("pslCls",name)
 .	I $P(rwCls,$C(9),5)<0 S name=""
 .	Q 
 Q name
 ;
 ; ---------------------------------------------------------------------
omTryPrim(prsr,tknzr,cls,mtd) ; method name (*1)
 ;
 N elm N nCase
 N pcls N retval S retval=""
 ;
 ; try case sensitive before case in-sensitive for selected PRIMITIVEs
 F nCase=0,1 D  Q:(retval="") 
 .	F elm=1:1:4 D  Q:'(retval="") 
 ..		S pcls=$piece("String,Number,Date,Time",",",elm)
 ..		I '($D(prsr("pslCls",pcls))#2) D loadClass^PSLCC(.prsr,pcls)
 ..		S retval=$$findPSLMethod^PSLParser(.prsr,.tknzr,pcls_"."_mtd,nCase)
 ..		Q 
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '(retval="") D warnGroup^UCGM("MISMATCH","Cast expression to class: "_pcls_"."_mtd)
 ;
 Q retval
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61058^29773^Frans S.C. Witte^7689" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; CLASS FROM OBJECT WHERE LOWER(CLASS) = :V1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^OBJECT(vos4),1) I vos4="" G vL1a0
 I '($$LOWER^UCGMR(vos4)=vos3) G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S name=""
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=$ZCONVERT(CLS,"L") S rs=$$vOpen1()
 I $$vFetch1() S name=rs
 D ZX^UCGMR(voxMrk) Q 
