SQLTESTS	;Private; MSQL syntax analyzer
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/09/99 17:51:26 - SPIER
	; ORIG:	Frank Sanchez - 01/02/97
	; DESC:	Test SQL syntax for various anomolies
	;
	; KEYWORDS:	MSQL
	;
	; INPUTS:
	;	. %LIBS				/TYP=T/DEF=^CUVAR("%LIBS")
	;
	; RELATED: ^SQLTESTF
	;
	; I18N=OFF
	;----------------------------------------------------------------------
	;
	;---------- Revision History ------------------------------------------
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$UPPER^SCAUTL with $$UPPER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 03/30/99 - SPIER - 32496
	;            Changed call to HASHKEY^SQLCACHE to $$ELFHASH^%ZFUNC
	;
	; 04/16/98 - Bob Chiang - 28537
	;            Modified DEBUG section to also check "OPEN CURSOR nnn AS
	;	     SELECT" statement for missing join logic.
	;            
	;----------------------------------------------------------------------
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	;
	N dqm,dsp,line,lit,par,quit,rms,rng,test,x,z
	;
	S IO=$P,rng="ALL",rms="SYS$LOGIN:SQL.TEST"
	S $P(line,"-",30)=""
	S dqm=0,dsp=1,lit=1
	;
	S %TAB("rms")="/DES=Input Filename"
	S %TAB("IO")=$$IO^SCATAB()
	S %TAB("dqm")="/DES=Data-Qwik Mode/TYP=L"
	S %TAB("dsp")="/DES=Display Complaints Only/TYP=L"
	S %TAB("lit")="/DES=Check Query Literals/TYP=L"
	;
	S %READ="@@%FN,,rms/REQ,IO/REQ,dsp,dqm,lit"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D IO(rms,"READ") I ER W $$MSG^%TRMVT(.RM) Q
	;
	D OPEN^SCAIO					; Open output device
	S %LIBS="SYSDEV"
	;
	D ZBINIT^%TRMVT(),TERMSET^SCADRV 
	;
	I rng="ALL" S rng=""
	;
	I $G(dqm) S par("DQMODE")=1
	;
	S dsp='dsp
	S expr="",flag=0,line=0,quit=0,test=0
	;
	F numrec=1:1 U rms Q:$ZEOF  R rec D  Q:quit
	.	;
	.	I rec="" Q
	.	I $E(rec,1,2)="/*" U IO W !,rec,! Q
	.	I rec=";" D  Q
	..		;
	..		S flag='flag
	..		I flag S test=test+1,line=0
	..		I rng,'$$CONTAIN(rng,test) Q
	..		;
	..		N msg
	..		D RUN(expr,lit,.msg,.par) S expr=""
	..		;
	..		I 'dsp&('$D(msg)) Q
	..		;
	..		U IO
	..		;
	..		W !!,$$LINE("Test # "_test),!!
	..		F i=1:1:line W line(i),!
	..		;
	..		I $D(msg) D
	...			;
	...			W !!,$$LINE("*** COMPLAINTS ***"),!!
	...			F i=1:1 Q:'$D(msg(i))  W msg(i),!
	..		;
	..		I IO=$P S quit='$$YN^DBSMBAR("","Next?",1)
	.	;
	.	I 'flag Q
	.	I rng,'$$CONTAIN(rng,test) Q
	.	;
	.	I expr="",$E(rec)="/"
	.	E  S expr=expr_rec_" "
	.	;
	.	S line=$G(line)+1,line(line)=rec
	;
	C rms
	U IO W !
	C IO
	Q
	;
	;----------------------------------------------------------------------
RUN(expr,lit,msg,par,tok)	; MSQL interface 
	;----------------------------------------------------------------------
	;
	I expr="" Q
	;
	N ER,RM
	N all,access,exe,fsn,frm,jfiles,jfrm,join,mode,oby,ojflg,ojqry,pflg,out,rng,sel,sqlwhr,vdd,vsql,vsub,vxp,whr,z
	N SELECT,FROM,WHERE,ORDER,GROUP
	;
	S lit=+$G(lit)
	;
	S ER=0
	;
	I $G(tok)="" S expr=$$SQL^%ZS(.expr,.tok) I ER Q
	;
	I $E(expr,1,7)'="SELECT " S ER=1,RM="Invalid SQL expression" Q
	E  S expr=$E(expr,8,$L(expr))
	;
	S SELECT=$$TOK^SQL(expr,"FROM,WHERE,ORDER,GROUP",.tok)
	;
	S pflg=0,vsql=0,ojflg="",ojqry="",fsn="vsql(",rng="" 
	S exe=+$G(exe),vxp=-1,jfiles="",access="",mode=-1 
	; 
	S sel=SELECT
	S sqlwhr=$G(WHERE)
	;
	I $E(sel,1,9)="DISTINCT " S all=0,sel=$E(sel,10,$L(sel))
	E  S all=1 I $E(sel,1,4)="ALL " S sel=$E(sel,5,$L(sel))
	;
	D JOIN(FROM) I ER D COMPLAIN(.RM) Q
	D WHERE(sqlwhr) I ER D COMPLAIN(.RM) Q
	D OPTIMIZE I ER D COMPLAIN(.RM) Q
	I frm["," D CHKJOINS			; Check join logic
	I lit D LITERAL
	D CUSTOM
	Q
	;
	;----------------------------------------------------------------------
JOIN(FROM)	; Test Join Logic
	;----------------------------------------------------------------------
	; The routine SQLJ returns the join array and the whr array
	; Add whatever code makes sense to check these conditions
	;
	; Note: Additional join conditions may be present in the WHERE
	;	Clause, so it probably makes sense to check for join
	;	anomolies in the WHERE subroutine
	;
	S frm=$$^SQLJ(FROM,.whr,.fsn,.join,.tok)
	Q
	;
	;----------------------------------------------------------------------
WHERE(WHERE)	; Test WHERE Logic
	;----------------------------------------------------------------------
	; The routine SQLQ returns the join array and the whr array
	; Add whatever code makes sense to check these conditions
	;
	i $G(WHERE)'="" D ^SQLQ(WHERE,.frm,.whr,.rng,.mode,.tok,.fsn,.vdd,.out)
	Q
	;
	;----------------------------------------------------------------------
OPTIMIZE	; Call SQL optimizer
	;----------------------------------------------------------------------
	;
	D ^SQLO(.frm,.sel,.oby,.all,.vsql,.rng,.par,.tok,.fsn,.vdd)
	Q
	;
	;----------------------------------------------------------------------
CUSTOM	; Process tests (after all parsing) is complete
	;----------------------------------------------------------------------
	; This is the main logic section to test for query conditions
	; the complete join array, whr array, rng array and vsql array
	; is available to evaluate
	;
	; Example #1 -- See if RELCIF should be in the FROM clause
	;
	I $$CONTAIN(frm,"CIF"),'$$CONTAIN(frm,"RELCIF") D
	.	;
	.	I $P($O(rng("CIF.")),".",1)'="CIF" Q
	.	F table="ACN","DEP","LN" I $$CONTAIN(frm,table) Q
	.	E  Q
	.	I $D(join("CIF.ACN")) Q
	.	D COMPLAIN("Table RELCIF should probably be in the FROM clause")
	; 
	; Example #2 --
	;
	Q
	;
	;----------------------------------------------------------------------
CHKJOINS	; Test join Logic
	;----------------------------------------------------------------------
	;
	; Complain if there are any tables that aren't joined at all
	; or are joined on non-keys
	;
	N i,j,l1,l2,n,keys,pkey
	F i=1:1:$L(frm,",") D
	.	;
	.	S table=$P(frm,",",i),n=table_".",k=0
	.	S keys=$P(fsn(table),"|",3),pkey=$P(keys,",",1)
	.	I pkey="" Q
	.	;
	.	I $D(rng(table_"."_pkey,"=")) Q			; Literal
	.	;
	.	F j=0:1 S n=$O(join(n)) Q:$P(n,".",1)'=table  I i>1,$P(n,".",2)=pkey S k=1
	.	I j=0 S l1=$$ADDLIST(.l1,table) Q
	.	;
	.	I i=1!k Q
	.	;
	.	;D COMPLAIN("Non-Key join on table "_table_"("_keys_") will create dynamic index") Q
	;
	I $G(l1)'="" D COMPLAIN("Missing join on table(s) "_l1_" will create Cartesian Product")
	Q
	;
	;----------------------------------------------------------------------
ADDLIST(list,m)	; Add m to a list
	;----------------------------------------------------------------------
	;
	I $G(list)=""!($G(m)="") Q $G(list)_$G(m)
	Q list_","_m
	;
	;----------------------------------------------------------------------
LITERAL	; Check for literals in the whr array
	;----------------------------------------------------------------------
	;
	N datatyp,exprlft,exprght,oprelat,n,z
	;
	S n=""
	F  S n=$O(whr(n)) Q:n=""  D
	.	;
	.	S z=whr(n)
	.	S exprlft=$P(z,$C(9),1),exprght=$P(z,$C(9),2)
	.	S oprelat=$P(z,$C(9),3),datatyp=$P(z,$C(9),4)
	.	I oprelat="I"!(oprelat="L") Q
	.	;
	.	I exprlft=+exprlft!($E(exprlft)="""") D LITVAL(exprlft,datatyp)
	.	I exprght=+exprght!($E(exprght)="""") D LITVAL(exprght,datatyp)
	Q
	;
	;----------------------------------------------------------------------
LITVAL(v,datatyp)	; Build literal value complaint
	;----------------------------------------------------------------------
	I $G(par("ODBC")) Q				; Skip ODBC driver msg
	I v="""""" Q					; Null
	;
	I datatyp="D" S v=$$DAT^%ZM(v)
	D COMPLAIN("Query contains the literal "_v)
	Q
	;
	;----------------------------------------------------------------------
DEBUG(expr,par,tok)	; Run in Debug mode
	;----------------------------------------------------------------------
	;
	S ER=0
	I $G(tok)="" S expr=$$SQL^%ZS(expr,.tok) I ER Q ER
	;
	N i,msg,seq,z,zkey
	; *** 04/16/98 BC
	I $$UPPER^UCGMR(expr)["OPEN CURSOR",$$UPPER^UCGMR(expr)["AS SELECT" S expr=$P(expr,"AS ",2,99)
	S z=$P(expr," ",1) I z'="SELECT" Q ""			; For now
	D RUN(expr,1,.msg,.par,.tok)
	;
	I '$D(msg) Q ""
	S ER=1,RM=$G(msg(1))
	F i=2:1 Q:'$D(msg(i))  S RM=RM_$C(13,10)_msg(i)
	Q RM
	;
	;----------------------------------------------------------------------
COMPLAIN(m)	;
	;----------------------------------------------------------------------
	N hkey
	;
	S hkey=$$ELFHASH^%ZFUNC(expr)			; Calc hash key
	I $G(^zbadsql(hkey))="*" Q			; Verified
	S msg($O(msg(""),-1)+1)=$G(m)
	Q
	;
	;----------------------------------------------------------------------
LINE(x)	;
	;----------------------------------------------------------------------
	;
	N line,y
	S $p(line,"-",81)=""
	I $L(x)=0 Q line
	S y=78-$L(x)\2
	Q $E(line,1,y)_" "_x_" "_$E(line,1,y)
	;
	;----------------------------------------------------------------------
IO(IO,IOPAR)	; Initialize Device's
	;----------------------------------------------------------------------
	;
	I $G(IOPAR)="" S IOPAR="NEWV"
	S OK=$$FILE^%ZOPEN(IO,IOPAR)
	I 'OK S ER=1,RM=$P(OK,"|",2)
	Q
	;
CONTAIN(X,Y)	Q ","_X_","[(","_Y_",") 
	
