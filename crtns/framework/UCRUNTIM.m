 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCRUNTIM ****
 ; 
 ; 02/24/2010 18:23 - pip
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
 ;  #PACKAGE framework.psl
 ;  #CLASSDEF extends=Primitive public delimiter=9
 ;
 ;  #PROPERTYDEF EREFCOMMIT   = "commit^vRuntime"   class=String private literal
 ;  #PROPERTYDEF EREFROLLBACK = "rollback^vRuntime" class=String private literal
 ;  #PROPERTYDEF EREFSTART    = "start^vRuntime"    class=String private literal
 ;
 ;  #PROPERTYDEF dummy    class=String position=2
 ;
 ; ---------------------------------------------------------------------
database() ; code generator for Runtime.database property
 S return="$$database^vRuntime"
 Q 
 ;
 ; ---------------------------------------------------------------------
isRdb() ; code generator for Runtime.isRdb property
 S return="$$isRdb^vRuntime"
 Q 
 ;
 ; ---------------------------------------------------------------------
commit() ; code generator for Runttime.commit()
 ;
 N cmitcnt S cmitcnt=0
 ;
 I $$isRdb^vRuntime D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N tranid S tranid=$$getAtt^UCGM("Runtime",0,11)
 .	I tranid="BA" D
 ..		S cmitcnt=500-1
 ..		I (cmitcnt="") S cmitcnt=499
 ..		I cmitcnt'>0 S cmitcnt=0 ; No commit count, commit each time
 ..		Q 
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode) ; Remove DO command
 I (postCond="") D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isRdb^vRuntime D pslNew^UCGM("vIgn") ; new vIgn
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S return=$$commitInline^vRuntime(cmitcnt)
 .	Q 
 E  S return=" D"_postCond_" "_"commit^vRuntime"_"("_cmitcnt_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
rollback() ; code generator for Runtime.rollback
 ;
 N saveptr S saveptr=actual(1)
 I $E(saveptr,1)="""" D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D WARNDEP^UCGM(3,0,"literalized savepoint name; Use standard ret parameter")
 .	S saveptr=$$QSUB^%ZS(saveptr,"""")
 .	Q 
 I (saveptr="") S saveptr=0
 ;
 ; Remove D command
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 ;
 I (postCond="") D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isRdb^vRuntime D pslNew^UCGM("vIgn") ; new vIgn
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S return=$$rollbackInline^vRuntime(saveptr)
 .	Q 
 E  S return=" D"_postCond_" "_"rollback^vRuntime"_"("_saveptr_") "
 Q 
 ;
 ; ---------------------------------------------------------------------
start() ; code generator for Runtime.start()
 I '(postCond="") D ERROR^UCGM("MISMATCH: postcondition not allowed on this method") Q 
 ;
 N param1 S param1=actual(1)
 I $E(param1,1)="""" D
 .	S param1=$$QSUB^%ZS(param1,"""")
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  D:'(param1="") WARNDEP^UCGM(3,0,"transactionid shall be literal parameter")
 I param1'="CS",param1'="BA" D ERROR^UCGM("SYNTAX: Transaction ID required") Q 
 ;
 N param2 S param2=actual(2)
 I $E(param2,1)="""" D
 .	S param2=$$QSUB^%ZS(param2,"""")
 .	Q 
 E  D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D:'(param2="") WARNDEP^UCGM(3,0,"list of restart variables shall be literal parameter")
 .	;
 .	I $E(param2,1)="." S param2=$E(param2,2,1048575)
 .	Q 
 I (param2="") S param2="vobj"
 E  I param2'="*",'(param2["vobj") S param2=param2_",vobj"
 ;
 N param3 S param3=actual(3)
 I $E(param3,1)="""" D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D WARNDEP^UCGM(3,0,"literalized savepoint name; Use standard ret parameter")
 .	S param3=$$QSUB^%ZS(param3,"""")
 .	Q 
 S:$E(param3,1)="." param3=$E(param3,2,1048575)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode) ;remove "D " from generated code
 ;
 ; Step 1: deal with explicit savepoint
 I (param3="") S return=""
 E  D
 .	S return=" S "_param3_"=$TL "
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I '$$getInst^UCGM(param3) D setInst^UCGM(param3,msrc+1,"")
 .	Q 
 ;
 ; Step 2: append restart lvns
 I param2="*" S return=return_"TS *"
 E  S return=return_"TS ("_param2_")"
 ;
 ; Step 3: add transactionid and the call to start^vRuntime
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S return=return_":transactionid="""_param1_""""_$$startInline^vRuntime(1)
 ;
 I $$isRdb^vRuntime D
 .	;
 .	N level S level=0 ; force DO-level zero for call to UCGM
 .	N curval S curval=$$getSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 .	I curval D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D typeDec^UCGM("Runtime","Runtime","NEW")
 .	I curval D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",1)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D typeFldSet^UCGM("Runtime",11,param1) ; Save CS or BA transaction ID
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D pslNew^UCGM("vIgn") ; new vIgn
 .	;
 .	S methods("Object","killCasc","Runtime")=$P($$getPSLClass^PSLCC(.pslPrsr,"Runtime"),$C(9),13)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
callCommitCS() ; return the code that corresponds to a commit CS
 Q "commit^vRuntime(0)"
 ;
 ; ---------------------------------------------------------------------
callRollback(vLvl) ; return the code that corresponds to a commit CS
 Q "rollback^vRuntime"_"("_vLvl_")"
 ;
 ; ---------------------------------------------------------------------
callStart() ; return the code that corresponds to a commit CS
 Q "start^vRuntime()"
 ;
 ; ---------------------------------------------------------------------
Charset() ; code generator for Runtime.charset()
 I $ZCHSET="UTF-8" D ERROR^UCGM("MISMATCH: method not available for Unicode") Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,3,"method Runtime.charset() will not be available for Unicode version")
 ;
 ;  #ACCEPT CR=30811;DATE=2007-12-05;PGM=Frans S.C. Witte;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 NEW ascList SET ascList=$$charAscii()
 IF $LENGTH(ascList)<450 SET return="$C("_ascList_")" QUIT ; inline
 ;
 ; Use subroutine
 NEW lbl SET lbl="vRunChrs"
 SET return="$$"_lbl_"()"
 IF $$hasSubr^UCGM(lbl) QUIT  ; already defined
 ;
 ; Create subroutine vRunChrs
 NEW max SET max=$$getPslValue^UCOPTS("maxLineLength")
 DO addSubr^UCGM(lbl,"()","get characterset")
 ;
 ; Fits on single line
 IF $LENGTH(ascList)+6<max DO append^UCGM(" Q $C("_ascList_")",lbl) QUIT
 ;
 ; Need multiple lines
 NEW line,pos
 DO append^UCGM(" N vRet",lbl)
 SET max=max-50,line=" S vRet=$C(",pos=$FIND(ascList,",",max)
 DO append^UCGM(line_$EXTRACT(ascList,1,pos-2)_")",lbl)
 DO append^UCGM(" Q vRet_$C("_$EXTRACT(ascList,pos,$LENGTH(ascList))_")",lbl)
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ; ---------------------------------------------------------------------
charAscii() ; Return list of $ASCII() values of character set
 N c N char N v
 N n
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S v=$$LC^%CHARSET_$$UC^%CHARSET_"/0123456789@[\]^_`%!~$#&*()-+={}<>?:."
 F n=1:1:$L(v) S char($E(v,n))="" ; M-sort it in order
 S c="" S v=""
 F  S c=$order(char(c)) Q:(c="")  S v=v_","_$ascii(c)
 Q $E(v,2,1048575)
 ;
 ; ---------------------------------------------------------------------
delayCmt() ; Implementation of Runtime.delayCommit()
 ;----------------------------------------------------------------------
 ; NOTES:
 ; . The generated code shall be enhanced with a catch-block that will
 ; ensure that the final commit and disable COMMIT_WRITE are always
 ; executed.
 ;
 N cmtF S cmtF=$P($$getPSLClass^PSLCC(.pslPrsr,"runtime"),$C(9),13)
 ;
 ; check value of call as if DO call occurred in the code
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N call S call=$$actual^UCGM($$QSUB^%ZS(actual(1),""""),.called)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isRdb^vRuntime() D
 .	N cmt N lbl
 .	S cmt="delay commits for "_call
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S lbl=$$findSubr^UCGM("vRunDC",cmt)
 .	S return=lbl_"()"
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	Q:$$hasSubr^UCGM(lbl) 
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D addSubr^UCGM(lbl,"()",cmt)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" N vRunDlay S vRunDlay=1",lbl)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" N vEr,vRm",lbl)
 .	;
 .	; enable COMMIT_WRITE setting.
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" S vEr=$$EXECUTE^%DBAPI(0,""ALTER SESSION SET COMMIT_WRITE=NOWAIT,BATCH"",$C(124),"""",.vRm)",lbl)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" D "_call,lbl)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" K vRunDlay",lbl)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" D "_cmtF_"(0)",lbl)
 .	;
 .	; disable COMMIT_WRITE setting.
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" S vEr=$$EXECUTE^%DBAPI(0,""ALTER SESSION SET COMMIT_WRITE=WAIT,IMMEDIATE"",$C(124),"""",.vRm)",lbl)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D append^UCGM(" Q",lbl)
 .	Q 
 E  S return=call
 Q 
 ;
 ; ---------------------------------------------------------------------
delxbad() ; code generator for Runtime.delErrXBAD
 I $$QSUB^%ZS(actual(1),"""")="*" S mcode=$E(mcode,1,$L(mcode)-2) S return="kill verrors" Q 
 S return="DELERR^DBSEXECU("_actual(1)_",""XBAD"","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
er() ; code generator for Runtime.setErrSTBLER( object, errcode)
 S return="SETERR^DBSEXECU("_actual(1)_",""ER"","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
msg() ; code generator for Runtime.setErrMSG method
 ;----------------------------------------------------------------------
 ; syntax: do Runtime.setErrMSG(object,msg_number,variable)
 ;
 ;----------------------------------------------------------------------
 ;  #ACCEPT CR=30811;DATE=2007-12-05;PGM=Frans S.C. Witte;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 N p1,p2,p3
 S p1=actual(1),p2=actual(2),p3=$G(actual(3))
 I p3?1a.an1"."1a.an S actual(2)=actual(3) D procPar(.fsn,1) S p3=actual(2)
 ;
 S return="SETERR^DBSEXECU("_p1_",""MSG"","_p2
 I $E(p3,$L(p3))="," S p3=$E(p3,1,$L(p3)-1) ; Remove extra comma
 I p3'="" S return=return_","_p3
 S return=return_")"
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ; ---------------------------------------------------------------------
procPar(fsn,sparse) ; 
 ;
 N table S table=$get(actual(1))
 N akeys S akeys=$get(actual(2))
 ;
 I $E(table,1)="""" S table=$$QSUB^%ZS(table,"""")
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,1)
 ;
 S actual(1)=table
 S actual(2)=$$akey2apl^UCDB(td,$get(var),akeys,sparse)
 ;
 I return'="" S return=return_"("_actual(2)_")"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
xbad() ; code gewnerator for Runtime.setErrXBAD()
 ;  #ACCEPT CR=30811;DATE=2007-12-05;PGM=Frans S.C. Witte;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 N i,expr,save2
 S save2=actual(2)
 S expr="SETERR^DBSEXECU("_actual(1)_",""XBAD"","_actual(2)
 I $G(actual(4))?1a.an1"."1a.an S actual(2)=actual(4) D procPar(.fsn,1) S actual(4)=actual(2)
 I $G(actual(5))?1a.an1"."1a.an S actual(2)=actual(5) D procPar(.fsn,1) S actual(5)=actual(2)
 S actual(2)=save2
 F i=3:1:5 I $G(actual(i))'="" S expr=expr_","_actual(i)
 S return=expr_")"
 ;*** End of code by-passed by compiler ***
 Q 
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61298^29758^Frans S.C. Witte^23398" ; Signature - LTD^TIME^USER^SIZE
vcdmNew(vC) ; Constructor, called for Class.new()
 N this
 S this=vC
 Q this
