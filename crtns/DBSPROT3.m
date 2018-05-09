 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSPROT3 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSPROT3 ; 
 ;
 ; I18N=OFF
 ;
 N %FRAME
 N %READ N %TAB N VFMQ N ZFID
 ;
 S %TAB("ZFID")=".FID1/TBL=[DBTBL14]FID:DISTINCT/XPP=D PP^DBSPROT3"
 S %FRAME=2
 S %READ="@@%FN,,ZFID/NOREQ," ;
 ;
 D ^UTLREAD Q:VFMQ="Q" 
 Q:(ZFID="") 
 ;
 D BUILD(ZFID)
 ;
 Q 
 ;
PP ; Screen post processor
 ;
 N XPGM
 ;
 I (X="") S %NOPRMT="Q" Q 
 ;
 D ^UPID(X,.XPGM)
 I (XPGM="") S ER=1 Q 
 ;
 ; Display run-time program name
 S RM=XPGM_"|3050"
 ;
 Q 
 ;
BUILD(FID) ; Table name
 ;
 N ER N isRECPRT N setVARS
 N I N POS N QSEQ
 N acckeys N CMPERR N CODE N DI N GROUP N KEYLIST N LINES N LINES2 N NEWLIST
 N OBJNAME N pslcode N RECOBJ N SORT N SUBSLIST N TAB N VAR N WHERE N XPGM
 ;
 Q:'$$VER(FID)  ; Protection logic not defined
 ;
 S ER=0
 ;
 D ^UPID(FID,.XPGM) Q:(XPGM="")  ; program name not available
 ;
 ; Build the VP01* routine
 ;
 ; Compile routine
 WRITE !!,$$^MSG(8021)," ",XPGM,"  ",$$TIM^%ZM,!
 ;
 S LINES="// ------------------------------------------------------------------"
 S LINES2="// =================================================================="
 S QSEQ=1
 S SUBSLIST=0
 S TAB=$char(9)
 ;
 N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",FID,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,12))
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
 ;
 S RECOBJ="Record"_$ZCONVERT(FID,"U")
 S OBJNAME=$P(vop3,$C(124),1)
 ;
 S KEYLIST=""
 S acckeys=$$TOKEN^%ZS($P(vop4,$C(124),1))
 F I=1:1:$L(acckeys,",") D
 .	;
 .	N key
 .	;
 .	S key=$piece(acckeys,",",I)
 .	Q:key?1.N  ; Ignore numeric keys
 .	Q:$E(key,1)=$char(0)  ; Ignore literal strings
 .	S KEYLIST=KEYLIST_key_","
 .	Q 
 S KEYLIST=$E(KEYLIST,1,$L(KEYLIST)-1)
 ;
 ; Header
 D addcode(0,XPGM_"()"_TAB_"// Date Item Protection procedure for "_FID)
 D addcode(1,"// Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$$USERNAM^%ZFUNC)
 D addcode(0,"")
 D addcode(1,"// THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSPROT3")
 D addcode(0,"")
 D addcode(1,"quit"_TAB_"// No entry from top")
 D addcode(0,"")
 ;
 N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen1()
 ;
 ; Get protection data and sort, convert query info and get variable substitution data
 F  Q:'$$vFetch1()  D  Q:ER 
 .	;
 . N dbtbl14,vop5,vop6 S vop6=$P(ds,$C(9),3),vop5=$P(ds,$C(9),4),dbtbl14=$$vRCgetRecord1Opt^RecordDBTBL14($P(ds,$C(9),1),$P(ds,$C(9),2),vop6,vop5,1,"")
 .	;
 .	S DI=vop6
 .	;
 .	S SORT(DI,vop5)=$P(dbtbl14,$C(124),1)_"|"_$P(dbtbl14,$C(124),2)_"|"_$P(dbtbl14,$C(124),3)
 .	;
 .	D SUBSADD(DI,.SUBSLIST)
 .	;
 .	S ER=$$BLDQRYS(FID,vop6,vop5,.SORT,.SUBSLIST)
 . Q 
 ;
 Q:ER 
 ;
 ; Build record level protection at top
 S ER=$$BUILDDI(FID,"*",OBJNAME,.SORT,KEYLIST,.QSEQ,.SUBSLIST)
 I ER Q 1
 ;
 ; Build data item protection code
 S DI=""
 F  S DI=$order(SORT(DI)) Q:(DI="")  I '(DI="*") S ER=$$BUILDDI(FID,DI,OBJNAME,.SORT,KEYLIST,.QSEQ,.SUBSLIST) Q:ER 
 I ER Q 1
 ;
 ; Get list of variables to be substituted (sort)
 S (NEWLIST,VAR)=""
 F  S VAR=$order(SUBSLIST("VAR",VAR)) Q:(VAR="")  S NEWLIST=NEWLIST_VAR_", "
 S NEWLIST=$E(NEWLIST,1,$L(NEWLIST)-2)
 ;
 ; Build %EXT section *************************************************
 D addcode(0,"")
 D addcode(1,LINES2)
 D addcode(0,"public %EXT("_RECOBJ_" "_OBJNAME_","_TAB_"// External entry point")
 D addcode(1,"    String VP())"_TAB_"// Data item name array [*]"_TAB_"/MECH=REFAFF:RW")
 D addcode(0,"")
 D addcode(1,"/*")
 D addcode(1,"ARGUMENT NOTES:")
 D addcode(2,". VP"_TAB_TAB_"Incoming data item name array, returns")
 D addcode(4,"restriction flag.  VP(*) = record level protection")
 D addcode(0,"")
 D addcode(1,"INPUT:")
 D addcode(2,". %UCLS"_TAB_TAB_"Userclass")
 D addcode(1,"*/")
 ;
 D addcode(0,"")
 D addcode(1,"type public String "_KEYLIST)
 D addcode(0,"")
 D addcode(1,"type Number vprot")
 D addcode(1,"type String "_NEWLIST)
 D addcode(0,"")
 D addcode(1,"quit:'%UserClass.exists()")
 D addcode(1,"quit:(VP.data() '> 0)")
 D addcode(0,"")
 ;
 ; Instantiate object if it wasn't passed in - backward compatible for old screen calls
 D addcode(1,$$INSTCODE(FID,OBJNAME,.KEYLIST))
 D addcode(0,"")
 ;
 D BLDSUBS(OBJNAME,.SUBSLIST)
 ;
 I ($D(SORT("*"))>0) D
 .	D addcode(1,"// Record level protection")
 .	D addcode(1,"set vprot = $$RECPROT if vprot set VP(""*"") = vprot")
 .	D addcode(0,"")
 .	Q 
 ;
 D addcode(1,"// Get data item protection for each data item requested")
 S DI=""
 F  S DI=$order(SORT(DI)) Q:(DI="")  I (DI'="*") D
 .	D addcode(1,"if VP("""_DI_""").exists() set vprot = $$"_DI_" if vprot set VP("""_DI_""") = vprot")
 .	Q 
 ;
 D addcode(0,"")
 D addcode(1,"quit")
 D addcode(0,"")
 ;
 ; Build EXT section **************************************************
 D addcode(0,"")
 D addcode(1,LINES2)
 D addcode(0,"public EXT("_RECOBJ_" "_OBJNAME_")"_TAB_"// Return record level protection indicator")
 D addcode(0,"")
 ;
 D addcode(1,"type public String "_KEYLIST)
 D addcode(0,"")
 D addcode(1,"type String "_NEWLIST)
 ;
 ; Instantiate object if it wasn't passed in - backward compatible for old screen calls
 D addcode(1,$$INSTCODE(FID,OBJNAME,KEYLIST))
 D addcode(0,"")
 ;
 D BLDSUBS(OBJNAME,.SUBSLIST)
 ;
 D addcode(1,"quit $$RECPROT")
 D addcode(0,"")
 ;
 D addcode(0,"")
 D addcode(1,LINES2)
 D addcode(0,"public ptinfo(String sel)"_TAB_"// Select list")
 D addcode(0,"")
 D addcode(1,"/*")
 D addcode(1,"Return a new select list including required column names,")
 D addcode(1,"as well as column mapping information for use by status section.")
 D addcode(0,"")
 D addcode(1,"RETURNS:")
 D addcode(2,". $$   newlist|vmatch|vmap")
 D addcode(0,"")
 D addcode(2,"       newlist  A list of column names required to process")
 D addcode(2,"                this protection logic")
 D addcode(2,"       vmatch   A list of column positions with protection")
 D addcode(2,"                logic defined")
 D addcode(2,"       vmap     Internal variable mapping table")
 D addcode(0,"")
 D addcode(1,"EXAMPLES:")
 D addcode(2,"- $$ptinfo(""DEP.CID,DEP.BAL,DEP.BOO"")")
 D addcode(0,"")
 D addcode(2,"    Returns DEP.CID,DEP.BAL,DEP.BOO,DEP.IRN|2|2,3,4")
 D addcode(1,"*/")
 D addcode(0,"")
 ;
 I ($D(SORT("*"))>0) S isRECPRT=1
 E  S isRECPRT=0
 ;
 I 'isRECPRT D addcode(1,"type Boolean vp = 0")
 D addcode(1,"type Number vpos")
 D addcode(1,"type String vmatch, vmap")
 D addcode(0,"")
 D addcode(1,"set vmatch = """"")
 D addcode(0,"")
 ;
 D addcode(1,"// Add required column names to the original list")
 ;
 S DI=""
 F  S DI=$order(SORT(DI)) Q:(DI="")  D
 .	;
 .	N REQDCOLS S REQDCOLS=$$REQDCOLS(DI,FID,.SORT)
 .	;
 .	I (DI="*") D
 ..		D addcode(1,"// Record level protection")
 ..		D addcode(1,"set sel = $$ADDCOLM^SQLPROT(sel ,"""_REQDCOLS_""")")
 ..		Q 
 .	E  D
 ..		;
 ..		D addcode(1,"set vpos = $$COLMPOS^SQLPROT(sel ,"""_FID_"."_DI_"""), vmatch = vmatch_"",""_vpos")
 ..		;
 ..		I (REQDCOLS=(FID_"."_DI)),'isRECPRT D  ; No queries
 ...			D addcode(1,"if (vpos > 0) set vp = 1")
 ...			Q 
 ..		E  D
 ...			S CODE="if (vpos > 0) set sel = $$ADDCOLM^SQLPROT(sel, """_REQDCOLS_""")"
 ...			I 'isRECPRT S CODE=CODE_", vp = 1"
 ...			D addcode(1,CODE)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 I 'isRECPRT D addcode(1,"if 'vp quit sel"_TAB_"// Protection logic not required")
 D addcode(0,"")
 ;
 D addcode(1,"// Match column position")
 D addcode(1,"set vmap=""""")
 ;
 S DI=""
 F  S DI=$order(SUBSLIST("DI",DI)) Q:(DI="")  D
 .	D addcode(1,"set vmap = vmap_"",""_$$COLMPOS^SQLPROT(sel, "_""""_FID_"."_DI_""""_", 1)")
 .	Q 
 D addcode(0,"")
 D addcode(1,"quit sel_""|""_vmatch.extract(2, vmatch.length())_""|""_vmap.extract(2, vmap.length())")
 D addcode(0,"")
 ;
 D addcode(0,"")
 D addcode(1,LINES2)
 D addcode(0,"public status(String val,"_TAB_"// Column values (tab separated)"_TAB_"MECH=REF:RW")
 D addcode(1,"      String vsts,"_TAB_"// Protection status"_TAB_"MECH=REF:RW")
 D addcode(1,"      String ptinfo)"_TAB_"// Protection API info [*]")
 D addcode(0,"")
 D addcode(1,"/*")
 D addcode(1,"Return data item protection status")
 D addcode(0,"")
 D addcode(1,"Return a possibly modified list of values, if some are protected,")
 D addcode(1,"as well as the protection status map in vsts.")
 D addcode(0,"")
 D addcode(1,"ARGUMENT NOTES:")
 D addcode(2,". ptinfo   vmatch|vmap|orgcolm|newcolm|vptopt")
 D addcode(2,"             vmatch   List of protected columns")
 D addcode(2,"             vmap     List of internal variable mapping table")
 D addcode(2,"             orgcolm  Total number of columns (original SELECT)")
 D addcode(2,"             newcolm  Total number of columns (new SELECT)")
 D addcode(2,"             vptopt   Protection option (0 = full access")
 D addcode(2,"                                         2 = read only access")
 D addcode(2,"                                         3 = no access)")
 D addcode(0,"")
 D addcode(1,"EXAMPLES:")
 D addcode(2,"do status(.val,.vsts,""2,|2,3,4|2|4"")  returns 02 in vsts")
 D addcode(1,"*/")
 D addcode(0,"")
 ;
 S setVARS=0
 S DI=""
 F I=1:1 S DI=$order(SORT(DI)) Q:(DI="")  I (DI'="*") S setVARS=1 Q 
 ;
 S CODE="type Number i, newcolm, orgcolm"
 I setVARS S CODE=CODE_", vpos, vprot"
 ;
 D addcode(1,CODE)
 D addcode(1,"type String vmatch, vmap, vptopt")
 I '(NEWLIST="") D addcode(1,"type String "_NEWLIST)
 D addcode(0,"")
 ;
 D addcode(1,"set vmatch = ptinfo.piece(""|"", 1)")
 D addcode(1,"set vmap = ptinfo.piece(""|"", 2)")
 D addcode(1,"set orgcolm = ptinfo.piece(""|"", 3)")
 D addcode(1,"set newcolm = ptinfo.piece(""|"", 4)")
 D addcode(1,"set vptopt = ptinfo.piece(""|"", 5)")
 D addcode(0,"")
 ;
 D addcode(1,"if vsts.isNull() set vsts.piece(0, orgcolm + 1)="""""_TAB_"// Init status to 0's")
 D addcode(0,"")
 ;
 D addcode(1,"// Map column values to internal variable names")
 S DI=""
 F I=1:1 S DI=$order(SUBSLIST("DI",DI)) Q:(DI="")  D
 .	D addcode(1,"set "_SUBSLIST("DI",DI)_" = val.piece($C(9), vmap.piece("","", "_I_"))"_TAB_"// "_FID_"."_DI)
 .	Q 
 D addcode(0,"")
 ;
 S POS=1
 D addcode(1,"// Get and insert protection status")
 F  S DI=$order(SORT(DI)) Q:(DI="")  I (DI'="*") D
 .	D addcode(1,"set vpos = vmatch.piece("","", "_POS_") if (vpos > orgcolm) set vpos = 0")
 .	S POS=POS+1
 .	D addcode(1,"if (vpos > 0) set vprot = $$"_DI_" if (vprot > 0) set vsts.extract(vpos) = (vprot + 1)")
 .	Q 
 D addcode(0,"")
 D addcode(1,"// Truncate data to original length")
 D addcode(1,"if (newcolm > orgcolm) set val = val.piece($C(9), 1, orgcolm)")
 ;
 D addcode(0,"")
 D addcode(1,"// Null out column data")
 D addcode(1,"if (vptopt = 2) for i = 1:1:vsts.length() if vsts.extract(i) = 3 set val.piece($C(9), i) = """"")
 ;
 D addcode(0,"")
 D addcode(1,"quit")
 D addcode(0,"")
 ;
 D addcode(0,"")
 D addcode(1,LINES2)
 D addcode(0,"public RPWHERE1()"_TAB_"// Return WHERE clause, protection options 1 and 2")
 D addcode(0,"")
 D addcode(1,"/*")
 D addcode(1,"Return Record Protect WHERE clause where both protection options")
 D addcode(1,"(1 = read only access; 2 = no access) are included")
 D addcode(0,"")
 D addcode(1,"RETURNS:")
 D addcode(2,". $$   WHERE clause")
 D addcode(1,"*/")
 D addcode(0,"")
 ;
 D BLDRPWHR(.SORT,1)
 ;
 D addcode(0,"")
 D addcode(0,"")
 D addcode(1,LINES2)
 D addcode(0,"public RPWHERE2()"_TAB_"// Return WHERE clause, protection option 2")
 D addcode(0,"")
 D addcode(1,"/*")
 D addcode(1,"Return Record Protect WHERE clause where only protection option")
 D addcode(1,"2 (no access) is included")
 D addcode(0,"")
 D addcode(1,"RETURNS:")
 D addcode(2,". $$   WHERE clause")
 D addcode(1,"*/")
 D addcode(0,"")
 ;
 D BLDRPWHR(.SORT,2)
 ;
 ; Build run-time routine *********************************************
 D BUILDRTN^UCGM(.pslcode,XPGM,.CMPERR)
 ;
 I ($get(CMPERR)>0) WRITE !!,"PSL error; unable to generate program - ",XPGM,!
 E  D
 .	;
 .	; Build SQL version - VQ01xxxx
 .	;set ER = $$^DBSPROT7(FID, XPGM)
 .	;
 .	I 'ER D MSG
 .	Q 
 ;
 HANG 5
 ;
 Q 
 ;
BUILDDI(FID,DINAM,OBJNAME,SORT,KEYLIST,QSEQ,SUBSLIST) ; Variable substitution list [*] /MECH=REFARR:RW
 ;
 N ER S ER=0
 N GROUP N GROUPNO N N N QUERY
 N CODE N FROM N NEWLIST N TAB
 ;
 S TAB=$char(9)
 ;
 D addcode(0,"")
 D addcode(1,LINES2)
 ;
 I (DINAM="*") D
 .	D addcode(0,"RECPROT()"_TAB_"// Record level protection")
 .	Q 
 E  D
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",FID,DINAM,0,"")
 .	;
 .	D addcode(0,DINAM_"()"_TAB_"// "_$P(dbtbl1d,$C(124),10))
 . Q 
 ;
 D addcode(1,LINES2)
 D addcode(0,"")
 ;
 I (DINAM="*"),($D(SORT("*"))'>0) D  Q 0
 .	D addcode(1,"quit 0"_TAB_"// No record level protection set up")
 .	D addcode(0,"")
 .	Q 
 ;
 S NEWLIST=$$NEWLIST(DINAM,"",.SORT,.SUBSLIST)
 ;
 D addcode(1,"type public String "_KEYLIST)
 I '(NEWLIST="") D addcode(1,"type public String "_NEWLIST)
 D addcode(0,"")
 D addcode(1,"type Number vprot = 0")
 D addcode(0,"")
 ;
 D addcode(1,"// Check each group, stop if get no access (vprot = 2)")
 S GROUP=""
 F  S GROUP=$order(SORT(DINAM,GROUP)) Q:(GROUP="")  D
 .	S GROUPNO(GROUP)=QSEQ
 .	D addcode(1,"do g"_QSEQ_"(.vprot) if (vprot = 2) quit 2"_TAB_"// Group "_GROUP)
 .	S QSEQ=QSEQ+1
 .	Q 
 D addcode(0,"")
 D addcode(1,"quit vprot")
 ;
 D addcode(0,"")
 ;
 ; Build the group section (header, user class check, queries)
 S GROUP=""
 F  S GROUP=$order(SORT(DINAM,GROUP)) Q:(GROUP="")  D  Q:ER 
 .	;
 .	N PROTOPT
 .	N NEWLIST N PROTDESC N RM N RUCLS N UCLSWHR
 .	;
 .	S PROTOPT=$piece(SORT(DINAM,GROUP),"|",2)
 .	I PROTOPT=2 S PROTDESC="No access"
 .	E  S PROTDESC="Read only"
 .	;
 .	S RUCLS=$piece(SORT(DINAM,GROUP),"|",3)
 .	;
 .	D addcode(0,"")
 .	D addcode(0,"g"_GROUPNO(GROUP)_"(Number vprot)")
 .	D addcode(1,"// Group               "_GROUP_" - "_$piece(SORT(DINAM,GROUP),"|",1))
 .	D addcode(1,"// Protection Option - "_PROTOPT_" ("_PROTDESC_")")
 .	D addcode(1,"// Userclass         - "_RUCLS)
 .	D addcode(1,"// Query:")
 .	;
 .	S N=""
 .	F  S N=$order(SORT(DINAM,GROUP,"QUERY",N)) Q:(N="")  D
 ..		D addcode(1,"//         "_SORT(DINAM,GROUP,"QUERY",N))
 ..		Q 
 .	;
 .	S NEWLIST=$$NEWLIST(DINAM,GROUP,.SORT,.SUBSLIST)
 .	;
 .	D addcode(0,"")
 .	I '(NEWLIST="") D
 ..		D addcode(1,"type public String "_NEWLIST)
 ..		D addcode(0,"")
 ..		Q 
 .	;
 .	; User class check - if doesn't pass, no need to check queries
 .	S ER=$$UCLS2WHR(RUCLS,.UCLSWHR,.RM)
 .	I ER WRITE !,RM,! Q 
 .	;
 .	I '(UCLSWHR="") D
 ..		;
 ..		N INPUT N PSLQRY
 ..		;
 ..		S SORT(DINAM,GROUP,"UCLSWHR")=UCLSWHR
 ..		S INPUT("WHERE")="NOT ("_UCLSWHR_")"
 ..		;
 ..		D ^UCQRYBLD(.INPUT,,,,.PSLQRY)
 ..		I ER WRITE !,RM,! Q 
 ..		;
 ..		S PSLQRY(1)=$$vStrRep(PSLQRY(1),"%UCLS","%UserClass",0,0,"")
 ..		D addcode(1,"if "_PSLQRY(1)_" quit"_TAB_"// Userclass not included")
 ..		D addcode(0,"")
 ..		Q 
 .	;
 .	I ($order(SORT(DINAM,GROUP,"PSLQRY",""))="") D
 ..		;
 ..		D addcode(1,"set vprot = "_PROTOPT_TAB_"// No queries")
 ..		Q 
 .	E  D
 ..		;
 ..		N isFIRST S isFIRST=1
 ..		;
 ..		S N=""
 ..		F  S N=$order(SORT(DINAM,GROUP,"PSLQRY",N)) Q:(N="")  D
 ...			S CODE="if "_SORT(DINAM,GROUP,"PSLQRY",N)
 ...			I 'isFIRST S CODE="if  "_CODE
 ...			S isFIRST=0
 ...			D addcode(1,CODE)
 ...			Q 
 ..		;
 ..		D addcode(1,"if  set vprot = "_PROTOPT)
 ..		Q 
 .	;
 .	D addcode(1,"quit")
 .	D addcode(0,"")
 .	Q 
 ;
 Q ER
 ;
BLDQRYS(FID,DINAM,GROUP,SORT,SUBSLIST) ; Variable substitution list /MECH=REFARR:RW
 ;
 N ER S ER=0
 N SEQ
 N DQQRY N INPUT N PSLQRY N RM N WHERE
 ;
 S SEQ=1
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen2()
 ;
 ;if rs.isEmpty() quit 0   // No queries
 ;
 F  Q:'$$vFetch2()  D
 . S DQQRY(SEQ)=$P(rs,$C(9),2)
 .	S SORT(DINAM,GROUP,"QUERY",SEQ)=DQQRY(SEQ)
 .	S SEQ=SEQ+1
 .	Q 
 ;
 S WHERE=$$WHERE^SQLCONV(.DQQRY,FID)
 ;
 S SORT(DINAM,GROUP,"WHERE")=WHERE ; Original where clause
 ;
 I (WHERE="") Q 0 ; No queries
 ;
 ; Convert to PSL code
 S INPUT("WHERE")=WHERE
 S INPUT("FROM")=FID
 ;
 D ^UCQRYBLD(.INPUT,FID_"="_FID,,,.PSLQRY)
 I ER WRITE !,RM,! Q 1
 ;
 ; Extract columns used in query and replace with variables.  Track by group, and
 ; add to variable substitution list.
 S SEQ=""
 F  S SEQ=$order(PSLQRY(SEQ)) Q:(SEQ="")  D
 .	;
 .	N ptr
 .	N atom N atomuc N NEWQRY N QRY N TOK
 .	;
 .	S QRY=PSLQRY(SEQ)
 .	;
 .	S QRY=$$TOKEN^%ZS(QRY,.TOK,"'")
 .	S NEWQRY=""
 .	S ptr=0
 .	F  D  Q:(ptr=0) 
 ..		;
 ..		; Retain space
 ..		I $E(QRY,ptr+1)=" " D  Q 
 ...			S NEWQRY=NEWQRY_" "
 ...			S ptr=ptr+1
 ...			Q 
 ..		;
 ..		S atom=$$ATOM^%ZS(QRY,.ptr," %?+-=[],/\!&*#()<>'",,1)
 ..		S atomuc=$ZCONVERT(atom,"U")
 ..		I $$vStrLike(atomuc,FID_".%","") D
 ...			;
 ...			N COLUMN S COLUMN=$piece(atomuc,".",2)
 ...			;
 ...			S SORT(DINAM,GROUP,"COLS",COLUMN)=""
 ...			;
 ...			D SUBSADD(COLUMN,.SUBSLIST)
 ...			;
 ...			; Substitute variable name
 ...			S atom=SUBSLIST("DI",COLUMN)
 ...			Q 
 ..		;
 ..		; Build new where clause
 ..		S NEWQRY=NEWQRY_atom
 ..		Q 
 .	;
 .	S SORT(DINAM,GROUP,"PSLQRY",SEQ)=NEWQRY
 .	Q 
 ;
 Q 0
 ;
BLDSUBS(OBJNAME,SUBSLIST) ; Substitution list data
 ;
 N VAR S VAR=""
 ;
 F  S VAR=$order(SUBSLIST("VAR",VAR)) Q:(VAR="")  D
 .	D addcode(1,"set "_VAR_" = "_OBJNAME_"."_$ZCONVERT(SUBSLIST("VAR",VAR),"L"))
 .	Q 
 ;
 D addcode(0,"")
 ;
 Q 
 ;
BLDRPWHR(SORT,OPT) ; Protection option
 ;
 N GROUP
 N TAB N WHERE N WHR N WHR1 N WHR2
 ;
 S TAB=$char(9)
 ;
 S (GROUP,WHERE)=""
 F  S GROUP=$order(SORT("*",GROUP)) Q:(GROUP="")  D
 .	;
 .	I ((OPT=1)!($piece(SORT("*",GROUP),"|",2)=2)) D
 ..		;
 ..		S WHR1=$get(SORT("*",GROUP,"UCLSWHR"))
 ..		S WHR2=$get(SORT("*",GROUP,"WHERE"))
 ..		;
 ..		I (WHR1=""),(WHR2="") S WHR=""
 ..		E  I (WHR1="") S WHR=WHR2
 ..		E  I (WHR2="") S WHR=WHR1
 ..		E  S WHR="("_WHR1_") AND ("_WHR2_")"
 ..		;
 ..		I '(WHERE="") S WHERE=WHERE_" OR "
 ..		S WHERE=WHERE_"("_WHR_")"
 ..		Q 
 .	Q 
 ;
 S WHERE=$$POP^%ZS(WHERE)
 ;
 I (WHERE="") D
 .	D addcode(1,"quit """""_TAB_"// No protection")
 .	Q 
 E  D
 .	;
 .	S WHERE="NOT ("_WHERE_")"
 .	;
 .	D addcode(1,"type String RETURN = """"")
 .	;
 .	D addcode(0,"")
 .	D addcode(1,"set RETURN = "_$$QADD^%ZS($E(WHERE,1,100),""""))
 .	;
 .	F  S WHERE=$E(WHERE,101,1048575) Q:(WHERE="")  D
 ..		D addcode(1,"set RETURN = RETURN_"_$$QADD^%ZS($E(WHERE,1,100),""""))
 ..		Q 
 .	;
 .	D addcode(0,"")
 .	D addcode(1,"quit RETURN")
 .	Q 
 ;
 Q 
 ;
INSTCODE(FID,OBJNAME,KEYLIST) ; Key list
 ;
 N I
 N CODE N KEY
 ;
 S CODE="if '"_OBJNAME_".exists() set "_OBJNAME_" = Db.getRecord("""_FID_""","""
 ;
 F I=1:1:$L(KEYLIST,",") D
 .	S KEY=$piece(KEYLIST,",",I)
 .	S CODE=CODE_KEY_"=:"_KEY_","
 .	Q 
 ;
 S CODE=$E(CODE,1,$L(CODE)-1)_""")"
 ;
 Q CODE
 ;
NEWLIST(DI,GROUP,SORT,SUBSLIST) ; Substitution list  /MECH=REFAFF:R
 ;
 N COL N LIST N RETURN N VAR
 ;
 S COL=""
 ;
 I (GROUP="") D
 .	F  S GROUP=$order(SORT(DI,GROUP)) Q:(GROUP="")  D
 ..		F  S COL=$order(SORT(DI,GROUP,"COLS",COL)) Q:(COL="")  D
 ...			S LIST(SUBSLIST("DI",COL))=""
 ...			Q 
 ..		Q 
 .	Q 
 ;
 E  D
 .	F  S COL=$order(SORT(DI,GROUP,"COLS",COL)) Q:(COL="")  D
 ..		S LIST(SUBSLIST("DI",COL))=""
 ..		Q 
 .	Q 
 ;
 S (RETURN,VAR)=""
 F  S VAR=$order(LIST(VAR)) Q:(VAR="")  S RETURN=RETURN_VAR_", "
 ;
 Q $E(RETURN,1,$L(RETURN)-2)
 ;
REQDCOLS(DI,FID,SORT) ; Sort list data  /MECH=REFARR:R
 ;
 N GROUP
 N COL N LIST N RETURN
 ;
 I (DI'="*") S LIST(DI)=""
 ;
 S (COL,GROUP)=""
 F  S GROUP=$order(SORT(DI,GROUP)) Q:(GROUP="")  D
 .	F  S COL=$order(SORT(DI,GROUP,"COLS",COL)) Q:(COL="")  D
 ..		S LIST(COL)=""
 ..		Q 
 .	Q 
 ;
 S RETURN=""
 F  S COL=$order(LIST(COL)) Q:(COL="")  S RETURN=RETURN_FID_"."_COL_","
 ;
 Q $E(RETURN,1,$L(RETURN)-1)
 ;
SUBSADD(DI,SUBSLIST) ; Substitution list
 ;
 I (DI'="*"),'($D(SUBSLIST("DI",DI))#2) D
 .	;
 .	N VAR
 .	;
 .	S SUBSLIST=SUBSLIST+1
 .	S VAR="vp"_SUBSLIST
 .	S SUBSLIST("DI",DI)=VAR
 .	S SUBSLIST("VAR",VAR)=DI
 .	Q 
 ;
 Q 
 ;
UCLS2WHR(RUCLS,WHERE,RM) ; Error message, if an error /MECH=REF:W
 ;
 N ER S ER=0
 N N
 ;
 S (RM,WHERE)=""
 ;
 F N=1:1:$L(RUCLS,",") D  Q:(WHERE="") 
 .	;
 .	N NOT S NOT=0
 .	N OPER N RIGHT N UCLS
 .	;
 .	S UCLS=$piece(RUCLS,",",N)
 .	;
 .	I '(WHERE="") S WHERE=WHERE_" OR "
 .	;
 .	I ($E(UCLS,1)="'") D
 ..		S NOT=1
 ..		S UCLS=$E(UCLS,2,1048575)
 ..		Q 
 .	;
 .	I (UCLS="*") S WHERE="" Q  ; All user classes
 .	;
 .	I ((UCLS?1A.AN)!(UCLS?1A.AN."_".AN)) D
 ..		S OPER="="
 ..		S RIGHT="'"_UCLS_"'"
 ..		Q 
 .	;
 .	E  I (UCLS?1A.E1"*") D
 ..		S OPER="LIKE"
 ..		S RIGHT="'"_$piece(UCLS,"*",1)_"%'"
 ..		Q 
 .	;
 .	E  I (UCLS["-") D
 ..		N FROM N TO
 ..		;
 ..		S FROM=$piece(UCLS,"-",1)
 ..		S TO=$piece(UCLS,"-",2)
 ..		;
 ..		I '((FROM?1A.AN)!(FROM?1A.AN."_".AN)) S ER=1
 ..		I '((TO?1A.AN)!(TO?1A.AN."_".AN)) S ER=1
 ..		;
 ..		I 'ER D
 ...			S OPER="BETWEEN"
 ...			S RIGHT="'"_FROM_"' AND '"_TO_"'"
 ...			Q 
 ..		Q 
 .	;
 .	E  S ER=1
 .	;
 .	I ER D
 ..		S RM="Invalid userclass syntax "_UCLS
 ..		S WHERE=""
 ..		Q 
 .	;
 .	I NOT S WHERE=WHERE_"NOT "
 .	S WHERE=WHERE_"(:%UCLS "_OPER_" "_RIGHT_")"
 .	Q 
 ;
 S WHERE=$$POP^%ZS(WHERE) ; Remove layer of parenthesis
 ;
 Q ER
 ;
VER(fid) ; Table name
 ;
 N pgm
 ;
 S pgm=$$PGM^UPID(fid) ; Get run-time routine name
 I (pgm="") Q 0 ; Name not defined
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=fid S rs=$$vOpen3()
 ;
 I ''$G(vos1) Q 1 ; Protection definition
 ;
 D DEL^%ZRTNDEL(pgm) ; Delete old routine VP01xxx
 WRITE !!,"Run-time protection routine ",pgm," deleted",!
 ;
 S pgm="VQ"_$E(pgm,3,12) ; VQ01xxx
 D DEL^%ZRTNDEL(pgm) ; Delete routine (SQL version)
 WRITE !!,"Run-time protection routine ",pgm," deleted",!
 ;
 D MSG
 ;
 HANG 5
 ;
 Q 0
 ;
MSG ; 
 ;
 WRITE !!,"***********************************************************************"
 WRITE !!,"Use function DBSSPB to rebuild stored procedure run-time routines"
 WRITE !,"Use function DBSPROTMC to recompile screen and report run-time routines"
 WRITE !!,"***********************************************************************"
 WRITE !
 ;
 Q 
 ;
addcode(TABS,CODE) ; Code to add to array
 ;
 N I N LINENO
 ;
 S LINENO=$order(pslcode(""),-1)+1 ; Add to end
 ;
 I TABS F I=1:1:TABS S CODE=$char(9)_CODE
 ;
 S pslcode(LINENO)=CODE
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61377^49746^Badrinath Giridharan^29850" ; Signature - LTD^TIME^USER^SIZE
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
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
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
 ;  #OPTION ResultClass 1
vStrLike(object,p1,p2) ; String.isLike
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (p1="") Q (object="")
 I p2 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
 I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
 I ($E(p1,$L(p1))="%") Q ($E(object,1,$L($E(p1,1,$L(p1)-1)))=$E(p1,1,$L(p1)-1))
 Q object=p1
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vOpen1() ; PLIBS,FID,DINAM,GROUP FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",14,vos3,vos4),1) I vos4="" G vL1a0
 S vos5=""
vL1a6 S vos5=$O(^DBTBL("SYSDEV",14,vos3,vos4,vos5),1) I vos5="" G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen2() ; QUERY,QRYDESC FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP AND QRYDESC IS NOT NULL ORDER BY QUERY ASC
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL2a0
 S vos4=$G(DINAM) I vos4="" G vL2a0
 S vos5=$G(GROUP)
 S vos6=""
vL2a6 S vos6=$O(^DBTBL("SYSDEV",14,vos3,vos4,vos5,vos6),1) I vos6="" G vL2a0
 S vos7=$G(^DBTBL("SYSDEV",14,vos3,vos4,vos5,vos6))
 I '($P(vos7,"|",1)'="") G vL2a6
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",14,vos3,vos4,vos5,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)_$C(9)_$P(vos7,"|",1)
 ;
 Q 1
 ;
vOpen3() ; DINAM FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:V1
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBTBL("SYSDEV",14,vos3,vos4),1) I vos4="" G vL3a0
 S vos5=""
vL3a6 S vos5=$O(^DBTBL("SYSDEV",14,vos3,vos4,vos5),1) I vos5="" G vL3a4
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
