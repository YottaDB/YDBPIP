DBSBCH	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSBCH ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q 
	;
VERSION()	; Batch compiler Version ID
	;
	Q "V7-0.02"
	;
COMPILE(BCHID,CMPFLG,PGM)	;
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	D SYSVAR^SCADRV0()
	D initflgs(.CMPFLG)
	D gen(BCHID,.CMPFLG,.PGM)
	;
	Q 
	;
gen(BCHID,CMPFLG,PGM)	;
	;
	; User code from batch definition
	;
	N commands N exec N m2src N mcode N open
	N schexec N schexit N schinit N schpost
	N threxec N threxit N thrinit
	N vmain N vproc
	N SELECT
	;
	N dbtbl33 S dbtbl33=$$vDb1("SYSDEV",BCHID)
	;
	S PGM=$P(vobj(dbtbl33),$C(124),2)
	;
	I ($D(CMPFLG("DEBUG"))#2) S $P(vobj(dbtbl33),$C(124),1)=$P(vobj(dbtbl33),$C(124),1)_" (debug mode)"
	WRITE !,BCHID,?15,$P(vobj(dbtbl33),$C(124),1)
	;
	D load(BCHID,"OPEN",.open)
	D load(BCHID,"EXEC",.exec)
	;
	; Compile error - procedural code req'd for ~p1
	I '$D(exec) N vo1 S vo1=$$^MSG(8744,"EXEC"),$ZS=($L($P(vo1,","),"-")=3*-1)_","_$ZPOS_","_vo1 X $ZT
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
	I '$D(schexec) N vo2 S vo2=$$^MSG(8744,"SCHEXEC"),$ZS=($L($P(vo2,","),"-")=3*-1)_","_$ZPOS_","_vo2 X $ZT
	;
	; Compile error - procedural code req'd for ~p1
	I '$D(threxec) N vo3 S vo3=$$^MSG(8744,"THREXEC"),$ZS=($L($P(vo3,","),"-")=3*-1)_","_$ZPOS_","_vo3 X $ZT
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
	D m2src(.dbtbl33,.m2src,"vOPEN","(String vINPUT, Boolean %BatchExit)",.open,"")
	D m2src(.dbtbl33,.m2src,"vTHRINIT","(vINPUT,vRETURN)",.thrinit,"private")
	D m2src(.dbtbl33,.m2src,"vTHREXIT","(vINPUT,vRETURN)",.threxit,"private")
	D m2src(.dbtbl33,.m2src,"vSCHINIT","(vINPUT,vRETURN)",.schinit,"private")
	D m2src(.dbtbl33,.m2src,"vSCHEXIT","(vINPUT,vRETURN)",.schexit,"private")
	;
	; Set PSL and SQL compiler switches
	I $get(CMPFLG("DEBUG","PSL"))'="" S commands("DEBUG")=CMPFLG("DEBUG","PSL")
	;
	; Add compiler version
	D vVERSION(.m2src)
	;
	; Add marker for code coverage utility
	I $get(CMPFLG("DEBUG","CCV")) D MARKER^UCUTIL(.m2src)
	;
	; Call PSL compiler
	D cmpA2F^UCGM(.m2src,PGM,,,.commands,,,BCHID_"~Batch")
	;
	K vobj(+$G(dbtbl33)) Q 
	;
load(BCHID,LABEL,code)	;
	;
	; Insert batch procedural code from batch definition
	;
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  S code($order(code(""),-1)+1)=rs
	Q 
	;
m2src(dbtbl33,m2src,tag,par,code,tagtype)	;
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
HDR(dbtbl33,m2src)	; Routine header & copyright message
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
vMAIN(dbtbl33,vmain)	; Build MAIN code
	;
	N seq
	;
	S seq=0
	;
	S seq=seq+1 S vmain(seq)=" type public Number ER"
	S seq=seq+1 S vmain(seq)=" type public String %FN,RM"
	;
	S seq=seq+1 S vmain(seq)=" catch vERROR {"
	S seq=seq+1 S vmain(seq)=" type public Number ER"
	S seq=seq+1 S vmain(seq)=" type public String RM"
	S seq=seq+1 S vmain(seq)=" "
	S seq=seq+1 S vmain(seq)=" do Runtime.rollback()"
	S seq=seq+1 S vmain(seq)=" "
	S seq=seq+1 S vmain(seq)=" // DBFILER errors do not log on a call to ZE^UTLERR"
	S seq=seq+1 S vmain(seq)=" if vERROR.type=""%PSL-E-DBFILER"" do {"
	S seq=seq+1 S vmain(seq)="  type String ET = vERROR.type"
	S seq=seq+1 S vmain(seq)="  do ^UTLERR"
	S seq=seq+1 S vmain(seq)=" }"
	S seq=seq+1 S vmain(seq)=" else  do ZE^UTLERR"
	S seq=seq+1 S vmain(seq)=" "
	S seq=seq+1 S vmain(seq)=" set ER = 1"
	S seq=seq+1 S vmain(seq)=" set RM = vERROR.description"
	S seq=seq+1 S vmain(seq)=" }"
	;
	S seq=seq+1 S vmain(seq)=" type Number %BatchExit,%BatchRestart,vBCHSTS"
	S seq=seq+1 S vmain(seq)=" type String vCONTEXT,vINPUT,vSYSVAR,vRESULT"
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
	S seq=seq+1 S vmain(seq)=" do vOPEN(.vINPUT,.%BatchExit) if %BatchExit"
	I $P(vobj(dbtbl33),$C(124),21) S vmain(seq)=vmain(seq)_" do EXIT^BCHUTL("""_vobj(dbtbl33,-4)_""")"
	S vmain(seq)=vmain(seq)_" quit"
	;
	S seq=seq+1 S vmain(seq)=" do JOBMGR^BCHUTL(%FN,"""_vobj(dbtbl33,-4)_""",.vINPUT)"
	S seq=seq+1 S vmain(seq)=" do ^JOBMGR(.vINPUT)"
	;
	I $P(vobj(dbtbl33),$C(124),21) S seq=seq+1 S vmain(seq)=" do EXIT^BCHUTL("""_vobj(dbtbl33,-4)_""")"
	Q 
	;
vPROC(dbtbl33,vproc,SELECT)	; Insert PROC code
	;
	N seq
	;
	; Note that this currently only supports a single Record object being passed
	; Not clear if more than one ever would be
	I (($E($P(vobj(dbtbl33),$C(124),24),1,6)="Record")) D
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
	S seq=seq+1 S vproc(seq)=" catch vERROR {"
	S seq=seq+1 S vproc(seq)=" type public Number ER"
	S seq=seq+1 S vproc(seq)=" type public String RM"
	S seq=seq+1 S vproc(seq)=" "
	S seq=seq+1 S vproc(seq)=" do Runtime.rollback()"
	S seq=seq+1 S vproc(seq)=" "
	S seq=seq+1 S vproc(seq)=" do LOG^UTLEXC("""_vobj(dbtbl33,-4)_""",""*"","""","_$$keyval(recname,SELECT)_", vERROR.thrownAt, vERROR.type)"
	S seq=seq+1 S vproc(seq)=" "
	S seq=seq+1 S vproc(seq)=" // DBFILER errors do not log on a call to ZE^UTLERR"
	S seq=seq+1 S vproc(seq)=" if vERROR.type=""%PSL-E-DBFILER"" do {"
	S seq=seq+1 S vproc(seq)="  type String ET = vERROR.type"
	S seq=seq+1 S vproc(seq)="  do ^UTLERR"
	S seq=seq+1 S vproc(seq)=" }"
	S seq=seq+1 S vproc(seq)=" else  do ZE^UTLERR"
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
sysgen(dbtbl33,commands,SELECT)	;
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
	.	N dbtbl1d S dbtbl1d=$$vDb4("SYSDEV",$P(vobj(dbtbl33),$C(124),8),di)
	.	S keylen=keylen+$P(dbtbl1d,$C(124),2)+1
	.	Q 
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
labels(labels)	; Return labels info for PSL UCLABEL checking
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
keyval(recname,keys)	;
	;
	N i
	N x
	;
	I (recname="") D
	.	S x=$piece(keys,",",1)_".get()"
	.	F i=2:1:$L(keys,",") S x=x_"_"",""_"_$piece(keys,",",i)_".get()"
	.	Q 
	E  D
	.	S x=recname_"."_$$vStrLC($piece(keys,",",1),0)
	.	F i=2:1:$L(keys,",") S x=x_"_"",""_"_recname_"."_$piece(keys,",",i)
	.	Q 
	;
	Q x
	;
initflgs(CMPFLG)	; Initialize compiler flags
	;
	N ref N x N y
	;
	S ref="CMPFLG"
	F  S ref=$query(@ref) Q:(ref="")  D
	.	S x=$$vStrUC(ref)
	.	;
	.	;   #ACCEPT Date=06/10/2003;PGM=Allan Mattson;CR=20967
	.	S y=$$vStrUC(@ref)
	.	ZWITHDRAW @ref
	.	S @x=y
	.	Q 
	;
	Q 
	;
debug(bchid,pro,trace,psl,sym,notp)	;
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
compile(bchid,par)	; Compile batch(es)
	;
	I bchid="*" D
	.	N rs,vos1,vos2 S rs=$$vOpen2()
	.	F  Q:'($$vFetch2())  D COMPILE(rs,.par)
	.	Q 
	;
	E  D COMPILE(bchid,.par)
	Q 
	;
add(m2src,data)	; Insert procedural code into buffer
	;
	S m2src($order(m2src(""),-1)+1)=data
	Q 
	;
vVERSION(m2src)	; Insert compiler Version ID
	;
	D add(.m2src,"vVERSION() // Compiler Version ID")
	D add(.m2src," quit """_$$VERSION_"""")
	Q 
	;
MPROF(BCHID,IO)	;
	;
	N CNT N OFF N SYS N USR
	N LBL N PGM N PID N TAB N TYP
	;
	I ($get(IO)="") S IO=$$FILE^%TRNLNM("MPROF_"_BCHID_".DAT","SCAU$SPOOL")
	I '$$FILE^%ZOPEN(IO,"WRITE/NEWV",2,1024) Q 
	USE IO
	;
	D vDbDe1()
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	S TYP=$P(rs,$C(9),1)
	.	S PID=$P(rs,$C(9),2)
	.	S PGM=$P(rs,$C(9),3)
	.	S LBL=$P(rs,$C(9),4)
	.	;
	.	N mprofa1,vop1,vop2,vop3,vop4,vop5,vop6,vop7 S vop6=BCHID,vop5=TYP,vop4="ALL",vop3=PGM,vop2=LBL,vop1="*",mprofa1=$$vDb5(BCHID,TYP,"ALL",PGM,LBL,"*",.vop7)
	.	;
	. S $P(mprofa1,$C(58),1)=$P(mprofa1,$C(58),1)+$P(rs,$C(9),5)
	. S $P(mprofa1,$C(58),2)=$P(mprofa1,$C(58),2)+$P(rs,$C(9),6)
	. S $P(mprofa1,$C(58),3)=$P(mprofa1,$C(58),3)+$P(rs,$C(9),7)
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^MPROF(vop6,vop5,vop4,vop3,vop2,vop1)=mprofa1 S vop7=1 Tcommit:vTp  
	.	;
	.	; Get offset data for this label
	.	N rs2,vos8,vos9,vos10,vos11,vos12,vos13,vos14,vos15 S rs2=$$vOpen4()
	.	;
	.	F  Q:'($$vFetch4())  D
	..		;
	..		S OFF=$P(rs2,$C(9),1)
	..		;
	..		N mprofa2,vop8,vop9,vop10,vop11,vop12,vop13,vop14 S vop13=BCHID,vop12=TYP,vop11="ALL",vop10=PGM,vop9=LBL,vop8=OFF,mprofa2=$$vDb5(BCHID,TYP,"ALL",PGM,LBL,OFF,.vop14)
	..		;
	..	 S $P(mprofa2,$C(58),1)=$P(mprofa2,$C(58),1)+$P(rs2,$C(9),2)
	..	 S $P(mprofa2,$C(58),2)=$P(mprofa2,$C(58),2)+$P(rs2,$C(9),3)
	..	 S $P(mprofa2,$C(58),3)=$P(mprofa2,$C(58),3)+$P(rs2,$C(9),4)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^MPROF(vop13,vop12,vop11,vop10,vop9,vop8)=mprofa2 S vop14=1 Tcommit:vTp  
	..		Q 
	.	Q 
	;
	N rs2,vos16,vos17,vos18,vos19,vos20,vos21,vos22 S rs2=$$vOpen5()
	;
	WRITE "Type"_$char(9)_"Program"_$char(9)_"Label"_$char(9)_"Offset"_$char(9)_"Count"_$char(9)_"User Time"_$char(9)_"System Time"_$char(9)_"Total Time"
	F  Q:'($$vFetch5())  WRITE !,rs2,$char(9),$P(rs2,$C(9),6)+$P(rs2,$C(9),7)
	;
	D CLOSE^SCAIO
	USE 0
	;
	Q 
	;
SYSMAPLB(tag,comment)	;
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
vSIG()	;
	Q "60726^46391^Dan Russell^25496" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ","abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM MPROF WHERE BCHID=:BCHID AND PID='ALL'
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4 N v5 N v6
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4) S v5=$P(vRs,$C(9),5) S v6=$P(vRs,$C(9),6)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^MPROF(v1,v2,v3,v4,v5,v6)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL33,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33"
	S vobj(vOid)=$G(^DBTBL(v1,33,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,33,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL33" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb4(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDb5(v1,v2,v3,v4,v5,v6,v2out)	;	voXN = Db.getRecord(MPROF,,1,-2)
	;
	N mprofa1
	S mprofa1=$G(^MPROF(v1,v2,v3,v4,v5,v6))
	I mprofa1="",'$D(^MPROF(v1,v2,v3,v4,v5,v6))
	S v2out='$T
	;
	Q mprofa1
	;
vOpen1()	;	CODE FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID=:BCHID AND LABEL=:LABEL
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(BCHID) I vos2="" G vL1a0
	S vos3=$G(LABEL) I vos3="" G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBTBL("SYSDEV",33,vos2,vos3,vos4),1) I vos4="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL("SYSDEV",33,vos2,vos3,vos4))
	S rs=$P(vos5,$C(12),1)
	;
	Q 1
	;
vOpen2()	;	BCHID FROM DBTBL33 WHERE %LIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=""
vL2a2	S vos2=$O(^DBTBL("SYSDEV",33,vos2),1) I vos2="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen3()	;	TYP,PID,PGM,LBL,CNT,USR,SYS FROM MPROF0 WHERE BCHID=:BCHID AND PID NOT = 'ALL'
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(BCHID) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^MPROF(vos2,vos3),1) I vos3="" G vL3a0
	S vos4=""
vL3a5	S vos4=$O(^MPROF(vos2,vos3,vos4),1) I vos4="" G vL3a3
	I '(vos4'="ALL") G vL3a5
	S vos5=""
vL3a8	S vos5=$O(^MPROF(vos2,vos3,vos4,vos5),1) I vos5="" G vL3a5
	S vos6=""
vL3a10	S vos6=$O(^MPROF(vos2,vos3,vos4,vos5,vos6),1) I vos6="" G vL3a8
	Q
	;
vFetch3()	;
	;
	I vos1=1 D vL3a10
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos7=$G(^MPROF(vos2,vos3,vos4,vos5,vos6))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)_$C(9)_$S(vos6=$C(254):"",1:vos6)_$C(9)_$P(vos7,":",1)_$C(9)_$P(vos7,":",2)_$C(9)_$P(vos7,":",3)
	;
	Q 1
	;
vOpen4()	;	OFF,CNT,USR,SYS FROM MPROF WHERE BCHID=:BCHID AND TYP=:TYP AND PID=:PID AND PGM=:PGM AND LBL=:LBL
	;
	;
	S vos8=2
	D vL4a1
	Q ""
	;
vL4a0	S vos8=0 Q
vL4a1	S vos9=$G(BCHID) I vos9="" G vL4a0
	S vos10=$G(TYP) I vos10="" G vL4a0
	S vos11=$G(PID) I vos11="" G vL4a0
	S vos12=$G(PGM) I vos12="" G vL4a0
	S vos13=$G(LBL) I vos13="" G vL4a0
	S vos14=""
vL4a7	S vos14=$O(^MPROF(vos9,vos10,vos11,vos12,vos13,vos14),1) I vos14="" G vL4a0
	Q
	;
vFetch4()	;
	;
	I vos8=1 D vL4a7
	I vos8=2 S vos8=1
	;
	I vos8=0 Q 0
	;
	S vos15=$G(^MPROF(vos9,vos10,vos11,vos12,vos13,vos14))
	S rs2=$S(vos14=$C(254):"",1:vos14)_$C(9)_$P(vos15,":",1)_$C(9)_$P(vos15,":",2)_$C(9)_$P(vos15,":",3)
	;
	Q 1
	;
vOpen5()	;	TYP,PGM,LBL,OFF,CNT,USR,SYS FROM MPROF WHERE BCHID=:BCHID AND PID='ALL'
	;
	;
	S vos16=2
	D vL5a1
	Q ""
	;
vL5a0	S vos16=0 Q
vL5a1	S vos17=$G(BCHID) I vos17="" G vL5a0
	S vos18=""
vL5a3	S vos18=$O(^MPROF(vos17,vos18),1) I vos18="" G vL5a0
	S vos19=""
vL5a5	S vos19=$O(^MPROF(vos17,vos18,"ALL",vos19),1) I vos19="" G vL5a3
	S vos20=""
vL5a7	S vos20=$O(^MPROF(vos17,vos18,"ALL",vos19,vos20),1) I vos20="" G vL5a5
	S vos21=""
vL5a9	S vos21=$O(^MPROF(vos17,vos18,"ALL",vos19,vos20,vos21),1) I vos21="" G vL5a7
	Q
	;
vFetch5()	;
	;
	I vos16=1 D vL5a9
	I vos16=2 S vos16=1
	;
	I vos16=0 Q 0
	;
	S vos22=$G(^MPROF(vos17,vos18,"ALL",vos19,vos20,vos21))
	S rs2=$S(vos18=$C(254):"",1:vos18)_$C(9)_$S(vos19=$C(254):"",1:vos19)_$C(9)_$S(vos20=$C(254):"",1:vos20)_$C(9)_$S(vos21=$C(254):"",1:vos21)_$C(9)_$P(vos22,":",1)_$C(9)_$P(vos22,":",2)_$C(9)_$P(vos22,":",3)
	;
	Q 1
	;
vOpen6()	;	BCHID,TYP,PID,PGM,LBL,OFF FROM MPROF WHERE BCHID=:BCHID AND PID='ALL'
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(BCHID) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^MPROF(vos2,vos3),1) I vos3="" G vL6a0
	S vos4=""
vL6a5	S vos4=$O(^MPROF(vos2,vos3,"ALL",vos4),1) I vos4="" G vL6a3
	S vos5=""
vL6a7	S vos5=$O(^MPROF(vos2,vos3,"ALL",vos4,vos5),1) I vos5="" G vL6a5
	S vos6=""
vL6a9	S vos6=$O(^MPROF(vos2,vos3,"ALL",vos4,vos5,vos6),1) I vos6="" G vL6a7
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a9
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_"ALL"_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	I $P(error,",",3)'["%GTM-" D ZE^UTLERR Q 
	;
	WRITE !,$P(error,",",3),"-",$P(error,",",4)
	WRITE !,"At source code line: ",$P(error,",",2)
	Q 
