 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSBCH ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;
VERSION() ; Batch compiler Version ID
 ;
 Q "V7-0.02"
 ;
COMPILE(BCHID,CMPFLG,PGM) ; Generated program name /NOREQ/MECH=REFNAM:W
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""ERRLOG^"_$T(+0)_""",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 D SYSVAR^SCADRV0()
 D gen(BCHID,.CMPFLG,.PGM)
 ;
 Q 
 ;
gen(BCHID,CMPFLG,PGM) ; 
 ;
 ; User code from batch definition
 ;
 N commands N exec N m2src N mcode N open
 N schexec N schexit N schinit N schpost
 N threxec N threxit N thrinit
 N vmain N vproc
 N SELECT
 ;
 N dbtbl33 S dbtbl33=$$vRCgetRecord0^RecordDBTBL33("SYSDEV",BCHID,0)
 ;
 S PGM=$P(vobj(dbtbl33),$C(124),2)
 ;
 I ($D(CMPFLG("DEBUG"))#2)  S $P(vobj(dbtbl33),$C(124),1)=$P(vobj(dbtbl33),$C(124),1)_" (debug mode)"
 WRITE !,BCHID,?15,$P(vobj(dbtbl33),$C(124),1)
 ;
 D load(BCHID,"OPEN",.open)
 D load(BCHID,"EXEC",.exec)
 ;
 ; Compile error - procedural code req'd for ~p1
 I '$D(exec) S $ZE="0,"_$ZPOS_","_"%DQ-E-COMPILE,"_$$^MSG(8744,"EXEC"),$EC=",U1001,"
 ;
 D load(BCHID,"SCHINIT",.schinit)
 D load(BCHID,"SCHEXEC",.schexec)
 D load(BCHID,"SCHPOST",.schpost)
 D load(BCHID,"SCHEXIT",.schexit)
 D load(BCHID,"THRINIT",.thrinit)
 D load(BCHID,"THREXEC",.threxec)
 D load(BCHID,"THREXIT",.threxit)
 ;
 D sysgen(.dbtbl33,.commands,.SELECT)
 ;
 ; Compile error - procedural code req'd for ~p1
 I '$D(schexec) S $ZE="0,"_$ZPOS_","_"%DQ-E-COMPILE,"_$$^MSG(8744,"SCHEXEC"),$EC=",U1001,"
 ;
 ; Compile error - procedural code req'd for ~p1
 I '$D(threxec) S $ZE="0,"_$ZPOS_","_"%DQ-E-COMPILE,"_$$^MSG(8744,"THREXEC"),$EC=",U1001,"
 ;
 D HDR(.dbtbl33,.m2src)
 D vMAIN(.dbtbl33,.vmain)
 D vPROC(.dbtbl33,.vproc,.SELECT)
 D m2src(.dbtbl33,.m2src,"","",.vmain,"")
 ;
 I $P(vobj(dbtbl33),$C(124),24)="" D
 .	D m2src(.dbtbl33,.m2src,"vPROC","("_SELECT_")",.vproc,"")
 .	D m2src(.dbtbl33,.m2src,"vEXEC","(vCONTEXT,"_SELECT_")",.exec,"")
 .	Q 
 ;
 E  D
 .	D m2src(.dbtbl33,.m2src,"vPROC","("_$P(vobj(dbtbl33),$C(124),24)_")",.vproc,"")
 .	D m2src(.dbtbl33,.m2src,"vEXEC","(vCONTEXT,"_$P(vobj(dbtbl33),$C(124),24)_")",.exec,"")
 .	Q 
 ;
 D m2src(.dbtbl33,.m2src,"vTHREXEC","(vINPUT,vRETURN)",.threxec,"private")
 D m2src(.dbtbl33,.m2src,"vSCHEXEC","(vINPUT,vRETURN)",.schexec,"private")
 D m2src(.dbtbl33,.m2src,"vSCHPOST","(vINPUT,vRETURN)",.schpost,"private")
 ;
 I '$D(open) S open(1)=" set %BatchExit=0"
 D m2src(.dbtbl33,.m2src,"vOPEN","(String vINPUT(), Boolean %BatchExit)",.open,"")
 D m2src(.dbtbl33,.m2src,"vTHRINIT","(vINPUT,vRETURN)",.thrinit,"private")
 D m2src(.dbtbl33,.m2src,"vTHREXIT","(vINPUT,vRETURN)",.threxit,"private")
 D m2src(.dbtbl33,.m2src,"vSCHINIT","(vINPUT,vRETURN)",.schinit,"private")
 D m2src(.dbtbl33,.m2src,"vSCHEXIT","(vINPUT,vRETURN)",.schexit,"private")
 ;
 ; Set PSL and SQL compiler switches
 I $get(CMPFLG("DEBUG","PSL"))'="" S commands("DEBUG","FILEQUAL")=CMPFLG("DEBUG","PSL")
 ;
 ; Add compiler version
 D vVERSION(.m2src)
 ;
 ; Add Error Logger
 D vERRLOG(.m2src)
 ;
 ; Add marker for code coverage utility
 I $get(CMPFLG("DEBUG","CCV")) D MARKER^UCUTIL(.m2src)
 ;
 ; Call PSL compiler
 D cmpA2F^UCGM(.m2src,PGM,,,.commands,,,BCHID_"~Batch")
 ;
 K vobj(+$G(dbtbl33)) Q 
 ;
load(BCHID,LABEL,code) ; 
 N vpc
 ;
 ; Insert batch procedural code from batch definition
 ;
 N seq S seq=$order(code(""),-1)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen1()
 ;
 S vpc='$G(vos1) Q:vpc 
 ;
 S seq=seq+1
 S code(seq)=" // ----- Begin user code for "_LABEL_" -----"
 ;
 F  Q:'$$vFetch1()  S seq=seq+1 S code(seq)=rs
 ;
 S seq=seq+1
 S code(seq)=" // ----- End user code for "_LABEL_" -----"
 ;
 Q 
 ;
m2src(dbtbl33,m2src,tag,par,code,tagtype) ; If not null, type of tag, e.g., private
 ;
 ; Build m2src
 ;
 N n N seq
 N trace
 ;
 S seq=$order(m2src(""),-1)+1
 S m2src(seq)=tag_par_" //"
 I '(tagtype="") S m2src(seq)=tagtype_" "_m2src(seq)
 ;
 I tag="vSCHINIT",$P(vobj(dbtbl33),$C(124),15) D
 .	S seq=seq+1
 .	S m2src(seq)=" type public Number vMONID,vMONCNT"
 .	S seq=seq+1
 .	S m2src(seq)=" type public String %FN"
 .	S seq=seq+1
 .	S m2src(seq)=" set vMONID=$$INIT^JOBMON($G(%FN)_""#""_"""_vobj(dbtbl33,-4)_"""),vMONCNT=0"
 .	Q 
 I tag="vTHRINIT",$P(vobj(dbtbl33),$C(124),16) D
 .	S seq=seq+1
 .	S m2src(seq)=" type public Number vMONID,vMONCNT"
 .	S seq=seq+1
 .	S m2src(seq)=" type public String %FN"
 .	S seq=seq+1
 .	S m2src(seq)=" set vMONID=$$INIT^JOBMON($G(%FN)_""#""_"""_vobj(dbtbl33,-4)_""")),vMONCNT=0"
 .	Q 
 ;
 I tag="vSCHEXIT",$P(vobj(dbtbl33),$C(124),15) D
 .	S seq=seq+1
 .	S m2src(seq)=" type public Number vMONID,vMONCNT"
 .	S seq=seq+1
 .	S m2src(seq)=" type public String %FN"
 .	S seq=seq+1
 .	S m2src(seq)=" do CLOSE^JOBMON(vMONID,vMONCNT)"
 .	Q 
 I tag="vTHREXIT",$P(vobj(dbtbl33),$C(124),16) D
 .	S seq=seq+1
 .	S m2src(seq)=" type public Number vMONID,vMONCNT"
 .	S seq=seq+1
 .	S m2src(seq)=" type public String %FN"
 .	S seq=seq+1
 .	S m2src(seq)=" do CLOSE^JOBMON(vMONID,vMONCNT)"
 .	Q 
 I tag="vEXEC",$P(vobj(dbtbl33),$C(124),15)!$P(vobj(dbtbl33),$C(124),16) D
 .	S seq=seq+1
 .	S m2src(seq)=" type Number vMONID,vMONCNT"
 .	Q 
 I tag="vSCHEXEC",$P(vobj(dbtbl33),$C(124),15)!$P(vobj(dbtbl33),$C(124),16) D
 .	S seq=seq+1
 .	S m2src(seq)=" type public Number vMONID,vMONCNT"
 .	Q 
 ;
 I $get(CMPFLG("DEBUG","PRO")) D
 .	I tag="vSCHINIT" D
 ..		S seq=seq+1 S m2src(seq)=" do Db.fastDelete(""MPROF"",""BCHID='"_vobj(dbtbl33,-4)_"'"")"
 ..		;
 ..		S seq=seq+1 S m2src(seq)=" #ACCEPT Date=08/01/03;PGM=Allan Mattson;CR=20967"
 ..		S seq=seq+1 S m2src(seq)=" #BYPASS"
 ..		;
 ..		S seq=seq+1 S m2src(seq)=" view ""TRACE"":1:""^MPROF("""""_vobj(dbtbl33,-4)_""""",""""SCH"""",$J)"""
 ..		S seq=seq+1 S m2src(seq)=" #ENDBYPASS"
 ..		Q 
 .	;
 .	I tag="vTHRINIT" D
 ..		S seq=seq+1 S m2src(seq)=" #ACCEPT Date=08/01/03;PGM=Allan Mattson;CR=20967"
 ..		S seq=seq+1 S m2src(seq)=" #BYPASS"
 ..		;
 ..		S seq=seq+1 S m2src(seq)=" view ""TRACE"":1:""^MPROF("""""_vobj(dbtbl33,-4)_""""",""""THR"""",$J)"""
 ..		S seq=seq+1 S m2src(seq)=" #ENDBYPASS"
 ..		Q 
 .	;
 .	I tag="vSCHEXIT"!(tag="vTHREXIT") D
 ..		S seq=seq+1 S m2src(seq)=" #ACCEPT Date=08/01/03;PGM=Allan Mattson;CR=20967"
 ..		S seq=seq+1 S m2src(seq)=" #BYPASS"
 ..		;
 ..		S seq=seq+1 S m2src(seq)=" view ""TRACE"":0"
 ..		S seq=seq+1 S m2src(seq)=" #ENDBYPASS"
 ..		Q 
 .	Q 
 ;
 I $get(CMPFLG("DEBUG","SYM")) D
 .	I tag="vSCHEXIT" S seq=seq+1 S m2src(seq)=" do DUMP^BCHUTL("""_vobj(dbtbl33,-4)_""")"
 .	I tag="vTHREXIT" S seq=seq+1 S m2src(seq)=" do DUMP^BCHUTL("""_vobj(dbtbl33,-4)_""")"
 .	Q 
 ;
 I $get(CMPFLG("DEBUG","TRACE")) D
 .	I tag="vSCHINIT" S trace=$get(CMPFLG("DEBUG","TRACE","SCH")) I (trace="") S trace="vSCHEXEC^"_$P(vobj(dbtbl33),$C(124),2)
 .	I tag="vTHRINIT" S trace=$get(CMPFLG("DEBUG","TRACE","THR")) I (trace="") S trace="vTHREXEC^"_$P(vobj(dbtbl33),$C(124),2)
 .	I $get(trace)'="" S seq=seq+1 S m2src(seq)=" do TRACE^SCAUTL("""_trace_""")"
 .	Q 
 ;
 S n=""
 F  S n=$order(code(n)) Q:(n="")  S seq=seq+1 S m2src(seq)=code(n)
 ;
 S seq=seq+1 S m2src(seq)=" #ACCEPT Date=07/15/03;PGM=Allan Mattson;CR=20967"
 S seq=seq+1 S m2src(seq)=" quit"
 Q 
 ;
HDR(dbtbl33,m2src) ; Routine header & copyright message
 ;
 N copyrght
 ;
 D add(.m2src,$P(vobj(dbtbl33),$C(124),2)_" //Batch "_vobj(dbtbl33,-4)_" - "_$P(vobj(dbtbl33),$C(124),1))
 D ^SCACOPYR(.copyrght)
 D add(.m2src,copyrght)
 D add(.m2src," //")
 ;
 D add(.m2src," // ********** This is a DATA-QWIK generated Routine **********")
 D add(.m2src," // Level 33  - "_vobj(dbtbl33,-4)_" Batch Definition")
 D add(.m2src," // ***********************************************************")
 D add(.m2src," //")
 Q 
 ;
vMAIN(dbtbl33,vmain) ; Build MAIN code
 ;
 N seq
 ;
 S seq=0
 ;
 S seq=seq+1 S vmain(seq)=" type public Number ER"
 S seq=seq+1 S vmain(seq)=" type public String %FN,RM"
 ;
 S seq=seq+1 S vmain(seq)=" catch vERROR@""vERRLOG"" {"
 S seq=seq+1 S vmain(seq)=" type public Number ER"
 S seq=seq+1 S vmain(seq)=" type public String RM"
 S seq=seq+1 S vmain(seq)=" "
 S seq=seq+1 S vmain(seq)=" set ER = 1"
 S seq=seq+1 S vmain(seq)=" set RM = vERROR.description"
 S seq=seq+1 S vmain(seq)=" }"
 ;
 S seq=seq+1 S vmain(seq)=" type Number %BatchExit,%BatchRestart,vBCHSTS"
 S seq=seq+1 S vmain(seq)=" type String vCONTEXT,vINPUT(),vSYSVAR,vRESULT"
 S seq=seq+1 S vmain(seq)=" set %BatchExit=0,%BatchRestart=0,ER=0,RM="""""
 S seq=seq+1 S vmain(seq)=" do INIT^BCHUTL(.vSYSVAR)"
 ;
 I $P(vobj(dbtbl33),$C(124),21) D
 .	S seq=seq+1 S vmain(seq)=" set vBCHSTS=$$STATUS^BCHUTL("""_vobj(dbtbl33,-4)_""")"
 .	; Batch ~p1 could not be restarted. Batch still active.
 .	S seq=seq+1 S vmain(seq)=" if vBCHSTS=1 set ER=1,RM=$$^MSG(3410) quit"
 .	;
 .	; Batch ~p1 could not be restarted. Batch completed successfully.
 .	S seq=seq+1 S vmain(seq)=" if vBCHSTS=2 set ER=1,RM=$$^MSG(3414) quit"
 .	S seq=seq+1 S vmain(seq)=" if vBCHSTS=0 set %BatchRestart=1"
 .	Q 
 ;
 S seq=seq+1 S vmain(seq)=" do vOPEN(vINPUT(),.%BatchExit) if %BatchExit"
 I $P(vobj(dbtbl33),$C(124),21) S vmain(seq)=vmain(seq)_" do EXIT^BCHUTL("""_vobj(dbtbl33,-4)_""")"
 S vmain(seq)=vmain(seq)_" quit"
 ;
 S seq=seq+1 S vmain(seq)=" do JOBMGR^BCHUTL(%FN,"""_vobj(dbtbl33,-4)_""",vINPUT())"
 S seq=seq+1 S vmain(seq)=" do ^JOBMGR(vINPUT())"
 ;
 I $P(vobj(dbtbl33),$C(124),21) S seq=seq+1 S vmain(seq)=" do EXIT^BCHUTL("""_vobj(dbtbl33,-4)_""")"
 Q 
 ;
vPROC(dbtbl33,vproc,SELECT) ; Insert PROC code
 ;
 N seq
 ;
 ; Note that this currently only supports a single Record object being passed
 ; Not clear if more than one ever would be
 I ($E($P(vobj(dbtbl33),$C(124),24),1,6)="Record") D
 .	N x S x=$P(vobj(dbtbl33),$C(124),24)
 .	;
 .	I (x[",") S recname=""
 .	E  S recname=$piece(x," ",2)
 .	Q 
 E  S recname=""
 ;
 S seq=0
 ;
 S seq=seq+1 S vproc(seq)=" type public Number ER"
 S seq=seq+1 S vproc(seq)=" type public String ET,%EVENT,%FN,%INTRPT(),RM,vCONTEXT"
 ;
 I $P(vobj(dbtbl33),$C(124),16) S seq=seq+1 S vproc(seq)=" type public Number vMONID,vMONCNT"
 ;
 ; Determine what variables are passed as parameters.  Publicly type any
 ; in SELECT that aren't coming in as parameters
 I '($P(vobj(dbtbl33),$C(124),24)="") D
 .	N I
 .	N formal N newlist N var
 .	;
 .	S formal=$P(vobj(dbtbl33),$C(124),24)
 .	S newlist=""
 .	F I=1:1:$L(SELECT,",") D
 ..		S var=$piece(SELECT,",",I)
 ..		I '((","_formal_",")[(","_var_",")) S newlist=newlist_var_","
 ..		Q 
 .	S newlist=$E(newlist,1,$L(newlist)-1)
 .	I '(newlist="") S seq=seq+1 S vproc(seq)=" type public String "_newlist
 .	Q 
 ;
 ;if 'SELECT.isNull() set seq=seq+1,vproc(seq)=" type public String "_SELECT
 ;
 S seq=seq+1 S vproc(seq)=" catch vERROR@""vERRLOG"" {"
 S seq=seq+1 S vproc(seq)=" type public Number ER"
 S seq=seq+1 S vproc(seq)=" type public String RM"
 S seq=seq+1 S vproc(seq)=" "
 S seq=seq+1 S vproc(seq)=" do LOG^UTLEXC("""_vobj(dbtbl33,-4)_""",""*"","""","_$$keyval(recname,SELECT)_", vERROR.thrownAt, vERROR.description)"
 S seq=seq+1 S vproc(seq)=" "
 S seq=seq+1 S vproc(seq)=" set ER = 1"
 S seq=seq+1 S vproc(seq)=" set RM = vERROR.description"
 S seq=seq+1 S vproc(seq)=" }"
 ;
 I $P(vobj(dbtbl33),$C(124),16) D
 .	S seq=seq+1 S vproc(seq)=" set vMONCNT=vMONCNT+1"
 .	S seq=seq+1 S vproc(seq)=" if vMONCNT#"_$P(vobj(dbtbl33),$C(124),16)_"=0 do UPDATE^JOBMON(vMONID,vMONCNT,"_$$keyval(recname,SELECT)_")"
 .	Q 
 ;
 S seq=seq+1 S vproc(seq)=" if ('%INTRPT.get().isNull())!(%INTRPT.data() > 1) do INTRPT^BCHUTL(%EVENT.get())"
 ;
 I $P(vobj(dbtbl33),$C(124),21) D
 .	S seq=seq+1 S vproc(seq)=" if %BatchRestart,$$CHKLOG^BCHUTL(%SystemDate,%FN,"""_vobj(dbtbl33,-4)_""","_$$keyval(recname,SELECT)_") do { quit"
 .	S seq=seq+1 S vproc(seq)=" do LOG^BCHUTL(%SystemDate,%FN,"""_vobj(dbtbl33,-4)_""","_$$keyval(recname,SELECT)_",""Record already processed"")"
 .	S seq=seq+1 S vproc(seq)=" }"
 .	Q 
 ;
 I '$get(CMPFLG("DEBUG","NOTP")) S seq=seq+1 S vproc(seq)=" do Runtime.start(""BA"")"
 S seq=seq+1 S vproc(seq)=" set vCONTEXT="""""
 S seq=seq+1 S vproc(seq)=" set (ET,RM)="""""
 S seq=seq+1 S vproc(seq)=" set ER=0"
 ;
 I $P(vobj(dbtbl33),$C(124),24)="" S seq=seq+1 S vproc(seq)=" do vEXEC(.vCONTEXT,"_SELECT_")"
 E  D
 .	; Reduce RecordXXX xxx syntax to xxx
 .	N i
 .	N formal N x N y
 .	;
 .	S x=$P(vobj(dbtbl33),$C(124),24)
 .	S formal=""
 .	;
 .	F i=1:1:$L(x,",") D
 ..		S y=$piece(x,",",i)
 ..		I y?1"Record".e1" ".e S y=$piece(y," ",2)
 ..		S formal=formal_y_","
 ..		Q 
 .	;
 .	S formal=$E(formal,1,$L(formal)-1)
 .	;
 .	S seq=seq+1 S vproc(seq)=" do vEXEC(.vCONTEXT,"_formal_")"
 .	Q 
 ;
 S seq=seq+1 S vproc(seq)=" if ER.get() do { quit"
 S seq=seq+1 S vproc(seq)=" type String et"
 S seq=seq+1 S vproc(seq)=" set et=$S(ET.get().isNull():RM.get(),1:ET)"
 S seq=seq+1 S vproc(seq)=" "
 ;
 I '$get(CMPFLG("DEBUG","NOTP")) S seq=seq+1 S vproc(seq)=" do Runtime.rollback()"
 S seq=seq+1 S vproc(seq)=" do LOG^UTLEXC("""_vobj(dbtbl33,-4)_""",""*"","""","_$$keyval(recname,SELECT)_","""",et)"
 S seq=seq+1 S vproc(seq)=" }"
 ;
 I $P(vobj(dbtbl33),$C(124),21) S seq=seq+1 S vproc(seq)=" do UPDLOG^BCHUTL(%SystemDate,%FN,"""_vobj(dbtbl33,-4)_""","_$$keyval(recname,SELECT)_",vCONTEXT)"
 I '$get(CMPFLG("DEBUG","NOTP")) S seq=seq+1 S vproc(seq)=" do Runtime.commit()"
 Q 
 ;
sysgen(dbtbl33,commands,SELECT) ; 
 ;
 ; System generated code
 ;
 N i N keycnt N keylen N seq
 N di N fsn N keys N var N val N x
 ;
 D fsn^SQLDD(.fsn,$P(vobj(dbtbl33),$C(124),8))
 S keys=$piece(fsn($P(vobj(dbtbl33),$C(124),8)),"|",3)
 ;
 S keycnt=0
 S keylen=0
 S SELECT=""
 ;
 F i=1:1:$L(keys,",") D
 .	S di=$piece(keys,",",i)
 .	I $P(vobj(dbtbl33),$C(124),22)'="",","_$P(vobj(dbtbl33),$C(124),22)_","'[(","_di_",") Q 
 .	;
 .	S keycnt=keycnt+1
 .	S $piece(SELECT,",",keycnt)=di
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",$P(vobj(dbtbl33),$C(124),8),di,0,"")
 .	S keylen=keylen+$P(dbtbl1d,$C(124),2)+1
 . Q 
 ;
 S commands("GLOBAL")=$P(vobj(dbtbl33),$C(124),23)
 ;
 ; vOPEN
 S x=""""
 I $P(vobj(dbtbl33),$C(124),22)'="" S x=x_"DISTINCT "
 S x=x_SELECT_""","""_$P(vobj(dbtbl33),$C(124),8)_""","""_$P(vobj(dbtbl33),$C(124),9)_""""
 ;
 S i=$order(open(""),-1)
 S open(i+1)=" #ACCEPT Date=08/01/03;PGM=Allan Mattson;CR=20967"
 S open(i+2)=" type public ResultSet vRESULT=Db.select("_x_")"
 S open(i+3)=" #ACCEPT Date=08/01/03;PGM=Allan Mattson;CR=20967"
 S open(i+4)=" if vRESULT.isEmpty() set %BatchExit=1 quit"
 S open(i+5)=" #ACCEPT Date=08/01/03;PGM=Allan Mattson;CR=20967"
 S open(i+6)=" set %BatchExit=0"
 ;
 I $D(schexec) Q 
 I $D(threxec) Q 
 ;
 S seq=0
 ;
 S seq=seq+1 S schexec(seq)=" type public String vBUFOVFL"
 ;
 S seq=seq+1 S schexec(seq)=" type String vRECORD,vrow,"_SELECT
 S seq=seq+1 S schexec(seq)=" type Number vcur,vlen"
 ;
 S seq=seq+1 S schexec(seq)=" set vINPUT=vBUFOVFL.get()"
 S seq=seq+1 S schexec(seq)=" set vBUFOVFL="""",vlen=0"
 ;
 S seq=seq+1 S schexec(seq)=" type public ResultSet vRESULT"
 ;
 S seq=seq+1 S schexec(seq)=" for  do { quit:'vcur"
 S seq=seq+1 S schexec(seq)=" set vcur=vRESULT.next() if 'vcur quit"
 S seq=seq+1 S schexec(seq)=" set vrow=vRESULT.getRow()_""|"",vlen=vlen+vrow.length()"
 S seq=seq+1 S schexec(seq)=" if vlen>"_$P(vobj(dbtbl33),$C(124),12)_" set vBUFOVFL=vrow,vcur=0 quit"
 S seq=seq+1 S schexec(seq)=" set vINPUT=vINPUT_vrow if vlen+"_keylen_">"_$P(vobj(dbtbl33),$C(124),12)_" set vcur=0 quit"
 S seq=seq+1 S schexec(seq)=" }"
 S seq=seq+1 S schexec(seq)=" set vINPUT=vINPUT.extract(1,vINPUT.length()-1)"
 ;
 I $P(vobj(dbtbl33),$C(124),15) D
 .	S seq=seq+1 S schexec(seq)=" set vMONCNT=vMONCNT+1"
 .	S seq=seq+1 S schexec(seq)=" if vMONCNT#"_$P(vobj(dbtbl33),$C(124),15)_"=0 do UPDATE^JOBMON(vMONID,vMONCNT,$TR(vrow,$C(9),$C(44)))"
 .	Q 
 ;
 S seq=0
 S seq=seq+1 S threxec(seq)=" type String vRECORD,"_SELECT
 S seq=seq+1 S threxec(seq)=" for  set vRECORD=vINPUT.piece(""|"",1),vINPUT=vINPUT.extract(vRECORD.length()+2,99999) quit:vRECORD.isNull()  do {"
 ;
 F i=1:1:$L(SELECT,",") D
 .	S di=$piece(SELECT,",",i)
 .	S seq=seq+1 S threxec(seq)=" set "_di_"=vRECORD.piece($C(9),"_i_")"
 .	Q 
 ;
 I $P(vobj(dbtbl33),$C(124),24)="" S seq=seq+1 S threxec(seq)=" do vPROC("_SELECT_")"
 E  S seq=seq+1 S threxec(seq)=" do vPROC("_$P(vobj(dbtbl33),$C(124),24)_")"
 ;
 S seq=seq+1 S threxec(seq)=" }"
 Q 
 ;
labels(labels) ; Return labels info for PSL UCLABEL checking
 ;
 S labels("vSCHINIT")="(vINPUT,vRETURN)"
 S labels("vSCHEXEC")="(vINPUT,vRETURN)"
 S labels("vSCHEXIT")="(vINPUT,vRETURN)"
 S labels("vSCHPOST")="(vINPUT,vRETURN)"
 S labels("vTHRINIT")="(vINPUT,vRETURN)"
 S labels("vTHREXIC")="(vINPUT,vRETURN)"
 S labels("vTHREXIT")="(vINPUT,vRETURN)"
 ;
 Q 
 ;
keyval(recname,keys) ; Key list
 ;
 N i
 N x
 ;
 I (recname="") D
 .	S x=$piece(keys,",",1)_".get()"
 .	F i=2:1:$L(keys,",") S x=x_"_"",""_"_$piece(keys,",",i)_".get()"
 .	Q 
 E  D
 .	S x=recname_"."_$ZCONVERT($piece(keys,",",1),"L")
 .	F i=2:1:$L(keys,",") S x=x_"_"",""_"_recname_"."_$piece(keys,",",i)
 .	Q 
 ;
 Q x
 ;
debug(bchid,pro,trace,psl,sym,notp) ; 
 ;
 N par
 ;
 S par("DEBUG","PRO")=$get(pro)
 S par("DEBUG","SYM")=$get(sym)
 S par("DEBUG","NOTP")=$get(notp)
 S par("DEBUG","TRACE")=$get(trace)
 I $get(psl) S par("DEBUG","PSL")="*"
 ;
 D compile(bchid,.par)
 Q 
 ;
compile(bchid,par) ; Compile batch(es)
 ;
 I bchid="*" D
 .	N rs,vos1,vos2,vos3 S rs=$$vOpen2()
 . F  Q:'$$vFetch2()  D COMPILE(rs,.par)
 . Q 
 ;
 E  D COMPILE(bchid,.par)
 Q 
 ;
add(m2src,data) ; Insert procedural code into buffer
 ;
 S m2src($order(m2src(""),-1)+1)=data
 Q 
 ;
vVERSION(m2src) ; Insert compiler Version ID
 ;
 D add(.m2src,"vVERSION() // Compiler Version ID")
 D add(.m2src," quit """_$$VERSION_"""")
 Q 
 ;
MPROF(BCHID,IO) ; 
 N vTp
 ;
 N CNT N OFF N SYS N USR
 N LBL N PGM N PID N TYP
 ;
 I ($get(IO)="") S IO=$$FILE^%TRNLNM("MPROF_"_BCHID_".DAT","SCAU$SPOOL")
 I '$$FILE^%ZOPEN(IO,"WRITE/NEWV",2,1024) Q 
 USE IO
 ;
 D vDbDe1()
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8 S rs=$$vOpen3()
 ;
 F  Q:'$$vFetch3()  D
 .	;
 . S TYP=$P(rs,$C(9),1)
 . S PID=$P(rs,$C(9),2)
 . S PGM=$P(rs,$C(9),3)
 . S LBL=$P(rs,$C(9),4)
 .	;
 .	N mprofa1 S mprofa1=$$vRCgetRecord1^RecordMPROF(BCHID,TYP,"ALL",PGM,LBL,"*",0)
 .	;
 .  S $P(vobj(mprofa1),$C(58),1)=$P(vobj(mprofa1),$C(58),1)+$P(rs,$C(9),5)
 .  S $P(vobj(mprofa1),$C(58),2)=$P(vobj(mprofa1),$C(58),2)+$P(rs,$C(9),6)
 .  S $P(vobj(mprofa1),$C(58),3)=$P(vobj(mprofa1),$C(58),3)+$P(rs,$C(9),7)
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordMPROF(mprofa1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(mprofa1,-100) S vobj(mprofa1,-2)=1 TC:vTp  
 .	;
 .	; Get offset data for this label
 .	N rs2,vos9,vos10,vos11,vos12,vos13,vos14,vos15,vos16,vos17 S rs2=$$vOpen4()
 .	;
 .	F  Q:'$$vFetch4()  D
 ..		;
 ..  S OFF=$P(rs2,$C(9),1)
 ..		;
 ..		N mprofa2 S mprofa2=$$vRCgetRecord1^RecordMPROF(BCHID,TYP,"ALL",PGM,LBL,OFF,0)
 ..		;
 ..   S $P(vobj(mprofa2),$C(58),1)=$P(vobj(mprofa2),$C(58),1)+$P(rs2,$C(9),2)
 ..   S $P(vobj(mprofa2),$C(58),2)=$P(vobj(mprofa2),$C(58),2)+$P(rs2,$C(9),3)
 ..   S $P(vobj(mprofa2),$C(58),3)=$P(vobj(mprofa2),$C(58),3)+$P(rs2,$C(9),4)
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordMPROF(mprofa2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(mprofa2,-100) S vobj(mprofa2,-2)=1 TC:vTp  
 ..		K vobj(+$G(mprofa2)) Q 
 . K vobj(+$G(mprofa1)) Q 
 ;
 N rs2,vos18,vos19,vos20,vos21,vos22,vos23,vos24,vos25 S rs2=$$vOpen5()
 ;
 WRITE "Type"_$C(9)_"Program"_$C(9)_"Label"_$C(9)_"Offset"_$C(9)_"Count"_$C(9)_"User Time"_$C(9)_"System Time"_$C(9)_"Total Time"
 F  Q:'$$vFetch5()  WRITE !,rs2,$C(9),$P(rs2,$C(9),6)+$P(rs2,$C(9),7)
 ;
 D CLOSE^SCAIO
 ;
 Q 
 ;
SYSMAPLB(tag,comment) ; Comment on the line
 ;
 N RETURN S RETURN=tag
 ;
 I (tag?1"v"1.U),'($E(tag,1,8)="vVERSION") D
 .	;
 .	S RETURN=$piece(tag,"(",1)
 .	S RETURN=$E(RETURN,2,1048575)
 .	S RETURN=tag_" (Section - "_$$vStrTrim(RETURN,0," ")_")"
 .	Q 
 ;
 Q RETURN
 ;
vERRLOG(m2src) ; 
 ;
 D add(.m2src,"public vERRLOG(Error vERROR)  //Error logger")
 D add(.m2src," ")
 D add(.m2src," /* The LOGERR^UTLERR will perfrom the runtime rollback")
 D add(.m2src,"    but the ^UTLERR won't. In order to perform the same behavior")
 D add(.m2src,"    the Runtime.rollback is executed in the logger. */")
 D add(.m2src," ")
 D add(.m2src," do Runtime.rollback()")
 D add(.m2src," if vERROR.type=""%PSL-E-DBFILER"" do {")
 D add(.m2src,"  type String ET = vERROR.type_ "",""_ vERROR.description")
 D add(.m2src,"  do ^UTLERR")
 D add(.m2src,"  }")
 D add(.m2src," else  do LOGERR^UTLERR(.vERROR)")
 D add(.m2src," quit ")
 Q 
 ;
ERRLOG(vErr) ; 
 I $P($P(vErr,",",3),"-",1)="%GTM" Q 
 D LOGERR^UTLERR(.vErr)
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61571^56930^Dan Russell^24958" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM MPROF WHERE BCHID=:BCHID AND PID='ALL'
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4 N v5 N v6
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4) S v5=$P(vRs,$C(9),5) S v6=$P(vRs,$C(9),6)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^MPROF(v1,v2,v3,v4,v5,v6)
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
vOpen1() ; CODE FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID=:BCHID AND LABEL=:LABEL
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(BCHID) I vos3="" G vL1a0
 S vos4=$G(LABEL) I vos4="" G vL1a0
 S vos5=""
vL1a5 S vos5=$O(^DBTBL("SYSDEV",33,vos3,vos4,vos5),1) I vos5="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos6=$G(^DBTBL("SYSDEV",33,vos3,vos4,vos5))
 S rs=$P(vos6,$C(12),1)
 ;
 Q 1
 ;
vOpen2() ; BCHID FROM DBTBL33 WHERE %LIBS='SYSDEV'
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL2a3 S vos3=$O(^DBTBL("SYSDEV",33,vos3),1) I vos3="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen3() ; TYP,PID,PGM,LBL,CNT,USR,SYS FROM MPROF0 WHERE BCHID=:BCHID AND PID NOT = 'ALL'
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(BCHID) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^MPROF(vos3,vos4),1) I vos4="" G vL3a0
 S vos5=""
vL3a6 S vos5=$O(^MPROF(vos3,vos4,vos5),1) I vos5="" G vL3a4
 I '(vos5'="ALL") G vL3a6
 S vos6=""
vL3a9 S vos6=$O(^MPROF(vos3,vos4,vos5,vos6),1) I vos6="" G vL3a6
 S vos7=""
vL3a11 S vos7=$O(^MPROF(vos3,vos4,vos5,vos6,vos7),1) I vos7="" G vL3a9
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a11
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos8=$G(^MPROF(vos3,vos4,vos5,vos6,vos7))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)_$C(9)_$S(vos7=vos2:"",1:vos7)_$C(9)_$P(vos8,":",1)_$C(9)_$P(vos8,":",2)_$C(9)_$P(vos8,":",3)
 ;
 Q 1
 ;
vOpen4() ; OFF,CNT,USR,SYS FROM MPROF WHERE BCHID=:BCHID AND TYP=:TYP AND PID=:PID AND PGM=:PGM AND LBL=:LBL
 ;
 ;
 S vos9=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos9=0 Q
vL4a1 S vos10=$$BYTECHAR^SQLUTL(254)
 S vos11=$G(BCHID) I vos11="" G vL4a0
 S vos12=$G(TYP) I vos12="" G vL4a0
 S vos13=$G(PID) I vos13="" G vL4a0
 S vos14=$G(PGM) I vos14="" G vL4a0
 S vos15=$G(LBL) I vos15="" G vL4a0
 S vos16=""
vL4a8 S vos16=$O(^MPROF(vos11,vos12,vos13,vos14,vos15,vos16),1) I vos16="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos9=1 D vL4a8
 I vos9=2 S vos9=1
 ;
 I vos9=0 S rs2="" Q 0
 ;
 S vos17=$G(^MPROF(vos11,vos12,vos13,vos14,vos15,vos16))
 S rs2=$S(vos16=vos10:"",1:vos16)_$C(9)_$P(vos17,":",1)_$C(9)_$P(vos17,":",2)_$C(9)_$P(vos17,":",3)
 ;
 Q 1
 ;
vOpen5() ; TYP,PGM,LBL,OFF,CNT,USR,SYS FROM MPROF WHERE BCHID=:BCHID AND PID='ALL'
 ;
 ;
 S vos18=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos18=0 Q
vL5a1 S vos19=$$BYTECHAR^SQLUTL(254)
 S vos20=$G(BCHID) I vos20="" G vL5a0
 S vos21=""
vL5a4 S vos21=$O(^MPROF(vos20,vos21),1) I vos21="" G vL5a0
 S vos22=""
vL5a6 S vos22=$O(^MPROF(vos20,vos21,"ALL",vos22),1) I vos22="" G vL5a4
 S vos23=""
vL5a8 S vos23=$O(^MPROF(vos20,vos21,"ALL",vos22,vos23),1) I vos23="" G vL5a6
 S vos24=""
vL5a10 S vos24=$O(^MPROF(vos20,vos21,"ALL",vos22,vos23,vos24),1) I vos24="" G vL5a8
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos18=1 D vL5a10
 I vos18=2 S vos18=1
 ;
 I vos18=0 S rs2="" Q 0
 ;
 S vos25=$G(^MPROF(vos20,vos21,"ALL",vos22,vos23,vos24))
 S rs2=$S(vos21=vos19:"",1:vos21)_$C(9)_$S(vos22=vos19:"",1:vos22)_$C(9)_$S(vos23=vos19:"",1:vos23)_$C(9)_$S(vos24=vos19:"",1:vos24)_$C(9)_$P(vos25,":",1)_$C(9)_$P(vos25,":",2)_$C(9)_$P(vos25,":",3)
 ;
 Q 1
 ;
vOpen6() ; BCHID,TYP,PID,PGM,LBL,OFF FROM MPROF WHERE BCHID=:BCHID AND PID='ALL'
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(BCHID) I vos3="" G vL6a0
 S vos4=""
vL6a4 S vos4=$O(^MPROF(vos3,vos4),1) I vos4="" G vL6a0
 S vos5=""
vL6a6 S vos5=$O(^MPROF(vos3,vos4,"ALL",vos5),1) I vos5="" G vL6a4
 S vos6=""
vL6a8 S vos6=$O(^MPROF(vos3,vos4,"ALL",vos5,vos6),1) I vos6="" G vL6a6
 S vos7=""
vL6a10 S vos7=$O(^MPROF(vos3,vos4,"ALL",vos5,vos6,vos7),1) I vos7="" G vL6a8
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a10
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_"ALL"_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$S(vos6=vos2:"",1:vos6)_$C(9)_$S(vos7=vos2:"",1:vos7)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 WRITE !,$P(error,",",3),"-",$P(error,",",4)
 WRITE !,"At source code line: ",$P(error,",",2)
 D ZX^UCGMR(voxMrk) Q 
