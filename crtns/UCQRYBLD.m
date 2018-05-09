UCQRYBLD(INPUT,INSTANTS,TABLES,PSLOBJ,PSLQRY)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCQRYBLD ****
	;
	; 11/08/2007 14:08 - chenardp
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
	;
	 S ER=0
	;
	N exe N frm N FROM N fsn N I N join N %LIBS N N N OBJ N ORDER N rng N RNG N SEQ N TABLE
	N vdd N vsql N vsub N vxp N WHERE N whr
	;
	; Catch GT.M errors
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	K PSLOBJ,PSLQRY
	;
	S %LIBS="SYSDEV"
	;
	; If no DQ query ID, then from and where are input
	I $get(INPUT)="" D
	.	S WHERE=INPUT("WHERE")
	.	S FROM=$get(INPUT("FROM"))
	.	I FROM="" S FROM=$$GETFROM(WHERE,$get(INSTANTS))
	.	Q 
	; Otherwise, convert DQ query to from and where clauses
	E  D GETSQL(INPUT)
	Q:ER 
	;
	; Parse instants to be able to use already instantiated objects
	F I=1:1 S N=$piece(($get(INSTANTS)),",",I) Q:N=""  S INSTANTS($piece(N,"=",1))=$piece(N,"=",2)
	;
	I FROM'="" S TABLES=$$^SQLJ(FROM,WHERE,.fsn,.join)
	E  S TABLES=""
	Q:ER 
	;
	F I=1:1 S TABLE=$piece(TABLES,",",I) Q:TABLE=""  D
	.	I ($D(INSTANTS(TABLE))#2) S OBJ(TABLE)=I_"|"_INSTANTS(TABLE)
	.	E  S OBJ(TABLE)=I_"|xobj"_I
	.	S ORDER(I)=TABLE
	.	Q 
	;
	S OBJ=""
	F  S OBJ=$order(OBJ(OBJ)) Q:OBJ=""  I '($D(INSTANTS(OBJ))#2) D
	.	N I N JOINOBJ N KEY N KEYREF N KEYS N PREREQ
	.	S PREREQ=0 ; Track prerequisite object
	.	;
	.	S KEYS=$piece(fsn(OBJ),"|",3)
	.	F I=1:1:$L(KEYS,",") D
	..		S KEY=$piece(KEYS,",",I)
	..		; No join, but save keys for loading
	..		I '$D(join(OBJ)) S OBJ(OBJ,KEY)=""
	..		E  D
	...			S KEYREF=OBJ_"."_KEY
	...			S OBJ(OBJ,KEY)=join(KEYREF)
	...			S JOINOBJ=$piece(join(KEYREF),".",1)
	...			I OBJ(JOINOBJ)>PREREQ S PREREQ=+OBJ(JOINOBJ)
	...			Q 
	..		Q 
	.	;
	.	S ORDER(PREREQ,OBJ)="" ; Dependency-based loading order
	.	S $piece(OBJ(OBJ),"|",3)=PREREQ ; Loading order for this object
	.	Q 
	;
	; Finalize loading order based on dependencies that get loaded later
	S N=0
	F  S N=$order(ORDER(N)) Q:N=""  D
	.	N LOADORDR
	.	S OBJ=ORDER(N)
	.	S LOADORDR=$piece(OBJ(OBJ),"|",3)
	.	; If set to load after things dependent on it, move them to later
	.	I LOADORDR'<N D
	..		N M S M=""
	..		;
	..		F  S M=$order(ORDER(N,M)) Q:M=""  D
	...			S ORDER(LOADORDR+1,M)=""
	...			K ORDER(N,M)
	...			Q 
	..		Q 
	.	Q 
	;
	S (N,OBJ)="" S SEQ=1
	F  S N=$order(ORDER(N)) Q:N=""  D
	.	F  S OBJ=$order(ORDER(N,OBJ)) Q:OBJ=""  D
	..		N CODE N DEPEND N KEYNAME N KEYS N OBJNAME
	..		;
	..		S OBJNAME=$piece(OBJ(OBJ),"|",2)
	..		S CODE="type Record"_$$vStrUC(OBJ)_" "_OBJNAME
	..		S CODE=CODE_"=Db.getRecord("""_OBJ_""","""
	..		; Build key references for getRecord
	..		; plus key list to return in PSLOBJ
	..		S (KEYNAME,KEYS)=""
	..		F  S KEYNAME=$order(OBJ(OBJ,KEYNAME)) Q:KEYNAME=""  D
	...			N VALUE
	...			;
	...			S KEYS=KEYS_KEYNAME_","
	...			S VALUE=OBJ(OBJ,KEYNAME)
	...			I VALUE="" S VALUE=$$vStrUC(KEYNAME)
	...			E  S VALUE=$$GETNAME(VALUE)
	...			S CODE=CODE_KEYNAME_"=:"_VALUE_","
	...			Q 
	..		; Remove comma from end and close parenthesis
	..		S CODE=$E(CODE,1,$L(CODE)-1)_""")"
	..		S PSLOBJ(SEQ,1)=CODE
	..		I N=0 S DEPEND=0 ; Independent of other objects
	..		E  S DEPEND=1 ; Dependent
	..		S KEYS=$E(KEYS,1,$L(KEYS)-1) ; Remove comma
	..		S PSLOBJ(SEQ)=OBJ_"|"_DEPEND_"|"_KEYS
	..		S SEQ=SEQ+1
	..		Q 
	.	Q 
	;
	D ^SQLQ(WHERE,TABLES,.whr,,,,.fsn,.vdd) Q:ER 
	S (N,RNG)=""
	F  S N=$order(whr(N)) Q:N=""  D
	.	S RNG=RNG_1 ; Bitmap of number of queries
	.	S whr(N)=$TR(whr(N),$char(1),$char(2))
	.	I whr(N)["vsql(" D
	..		N M S M=""
	..		;
	..		F  S M=$order(vsub(M)) Q:M=""  D
	...			Q:whr(N)'[vsub(M) 
	...			S whr(N)=$$REPLACE(whr(N),vsub(M),$TR(M,":"))
	...			Q 
	..		Q 
	.	Q 
	;
	S frm=TABLES
	S vxp=1 ; Current executable line for ^SQLA
	D QUERY^SQLA(RNG,.whr,.PSLQRY,.vsub,TABLES,.fsn,0,"") Q:ER 
	;
	S N=""
	F  S N=$order(PSLQRY(N)) Q:N=""  D
	.	N I
	.	N X
	.	;
	.	S X=PSLQRY(N)
	.	F I=2:2:$L(X,$char(2)) D
	..		N VALUE
	..		S VALUE=$piece(X,$char(2),I)
	..		S VALUE=$$GETNAME(VALUE) ; Get object.col ref
	..		S $piece(X,$char(2),I)=VALUE
	..		Q 
	.	S X=$TR(X,$char(2)) ; Remove markers
	.	S X=$piece(X,"I '(",2) ; Remove beginning
	.	S X=$piece(X,") S vsql=1",1) ; Remove end
	.	S PSLQRY(N)=X
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
REPLACE(STRING,OLD,NEW)	; Replace old with new in string
	;
	N X S X=0
	;
	F  S X=$F(STRING,OLD,X) Q:X=0  D
	.	S STRING=$E(STRING,1,X-$L(OLD)-1)_NEW_$E(STRING,X,1048575)
	.	S X=X+$L(NEW)-$L(OLD)
	.	Q 
	;
	Q STRING
	;
	; ---------------------------------------------------------------------
GETNAME(REF)	; Return correct object name and column attribute
	;
	N COLUMN N OBJECT N OBJNAME
	;
	S OBJECT=$piece(REF,".",1)
	S OBJNAME=$piece(OBJ(OBJECT),"|",2)
	S COLUMN=$$vStrLC(($piece(REF,".",2)),0)
	;
	Q OBJNAME_"."_COLUMN
	;
	; ---------------------------------------------------------------------
GETSQL(QRYID)	; Turn DQ query into FROM and WHERE
	;
	N DQQRY N TABLES
	;
	; No query definition found for ~p1
	I '($D(^DBTBL("SYSDEV",4,QRYID))) S ER=1 S RM=$$^MSG(3561,QRYID) Q 
	;
	N dbtbl4,vop1,vop2,vop3 S vop1="SYSDEV",vop2=QRYID,dbtbl4=$$vDb2("SYSDEV",QRYID)
	 S vop3=$G(^DBTBL(vop1,4,vop2,0))
	S TABLES=$P(vop3,$C(124),1)
	;
	; Load the query
	N dbtbl4rs,vos1,vos2,vos3,vos4 S dbtbl4rs=$$vOpen1()
	;
	; Incomplete query - ~p1
	I '$G(vos1) S ER=1 S RM=$$^MSG(3559,QRYID) Q 
	;
	F  Q:'($$vFetch1())  S DQQRY($P(dbtbl4rs,$C(9),1))=$P(dbtbl4rs,$C(9),2)
	;
	S FROM=$$DQJOIN^SQLCONV(TABLES)
	S WHERE=$$WHERE^SQLCONV(.DQQRY,TABLES)
	;
	Q 
	;
	; ---------------------------------------------------------------------
GETFROM(WHERE,INSTANTS)	; Determine FROM clause, with joins, from WHERE
	; If tables already included in INSTANTS, include them in order
	;
	N FROM N ITEM N TABLE
	N I N PTR
	N TABLES S TABLES=""
	;
	I $get(INSTANTS)'="" D
	.	F I=1:1:$L(INSTANTS,",") D
	..		S TABLE=$piece($piece(INSTANTS,",",I),"=")
	..		S TABLES=$S(((","_TABLES_",")[(","_TABLE_",")):TABLES,1:$S((TABLES=""):TABLE,1:TABLES_","_TABLE))
	..		Q 
	.	Q 
	;
	S PTR=0
	F  Q:PTR=$L(WHERE)  D
	.	S ITEM=$translate($$FINDINAM^SQLDD(WHERE,.PTR)," ")
	.	I ITEM'="" D
	..		S TABLE=$piece(ITEM,".")
	..		S TABLES=$S(((","_TABLES_",")[(","_TABLE_",")):TABLES,1:$S((TABLES=""):TABLE,1:TABLES_","_TABLE))
	..		Q 
	.	Q 
	;
	S FROM=$$DQJOIN^SQLCONV(TABLES) ; Construct FROM clause
	;
	Q FROM
	;
vSIG()	;
	Q "60383^25599^Frans S.C. Witte^13304" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	;
vDb2(v1,v2)	;	voXN = Db.getRecord(DBTBL4,,0)
	;
	N dbtbl4
	S dbtbl4=$G(^DBTBL(v1,4,v2))
	I dbtbl4="",'$D(^DBTBL(v1,4,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL4" X $ZT
	Q dbtbl4
	;
vOpen1()	;	SEQ,LINE FROM DBTBL4D WHERE LIBS='SYSDEV' AND QID=:QRYID AND SEQ > 0
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(QRYID) I vos2="" G vL1a0
	S vos3=0
vL1a3	S vos3=$O(^DBTBL("SYSDEV",4,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",4,vos2,vos3))
	S dbtbl4rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	D ZE^UTLERR
	S ER=1
	Q 
