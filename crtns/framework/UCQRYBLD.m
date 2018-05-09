 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCQRYBLD ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework
 ;
UCQRYBLD(INPUT,INSTANTS,TABLES,PSLOBJ,PSLQRY) ; 
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
 N exe N frm N FROM N fsn N I N join N %LIBS N N N OBJ N ORDER N rng N RNG
 N SEQ N TABLE N vdd N vsql N vsub N vxp N WHERE N whr
 ;
 ; Catch GT.M errors
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^UTLERR"",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 K PSLOBJ,PSLQRY
 ;
 S %LIBS="SYSDEV"
 ;
 ; If no DQ query ID, then from and where are input
 I ($get(INPUT)="") D
 .	;
 .	S WHERE=INPUT("WHERE")
 .	S FROM=$get(INPUT("FROM"))
 .	I (FROM="") S FROM=$$GETFROM(WHERE,$get(INSTANTS))
 .	Q 
 ; Otherwise, convert DQ query to from and where clauses
 E  D GETSQL(INPUT)
 Q:ER 
 ;
 ; Parse instants to be able to use already instantiated objects
 F I=1:1 S N=$piece($get(INSTANTS),",",I) Q:(N="")  S INSTANTS($piece(N,"=",1))=$piece(N,"=",2)
 ;
 I '(FROM="") S TABLES=$$^SQLJ(FROM,WHERE,.fsn,.join)
 E  S TABLES=""
 Q:ER 
 ;
 F I=1:1 S TABLE=$piece(TABLES,",",I) Q:(TABLE="")  D
 .	;
 .	I ($D(INSTANTS(TABLE))#2) S OBJ(TABLE)=I_"|"_INSTANTS(TABLE)
 .	E  S OBJ(TABLE)=I_"|xobj"_I
 .	S ORDER(I)=TABLE
 .	Q 
 ;
 S OBJ=""
 F  S OBJ=$order(OBJ(OBJ)) Q:(OBJ="")  I '($D(INSTANTS(OBJ))#2) D
 .	;
 .	N I N JOINOBJ N KEY N KEYREF N KEYS N PREREQ
 .	;
 .	S PREREQ=0 ; Track prerequisite object
 .	;
 .	S KEYS=$piece(fsn(OBJ),"|",3)
 .	F I=1:1:$L(KEYS,",") D
 ..		;
 ..		S KEY=$piece(KEYS,",",I)
 ..		; No join, but save keys for loading
 ..		I '($D(join(OBJ))#2) S OBJ(OBJ,KEY)=""
 ..		E  D
 ...			;
 ...			S KEYREF=OBJ_"."_KEY
 ...			S OBJ(OBJ,KEY)=join(KEYREF)
 ...			S JOINOBJ=$piece(join(KEYREF),".",1)
 ...			I (OBJ(JOINOBJ)>PREREQ) S PREREQ=+OBJ(JOINOBJ)
 ...			Q 
 ..		Q 
 .	;
 .	S ORDER(PREREQ,OBJ)="" ; Dependency-based loading order
 .	S $piece(OBJ(OBJ),"|",3)=PREREQ ; Loading order for this object
 .	Q 
 ;
 ; Finalize loading order based on dependencies that get loaded later
 S N=0
 F  S N=$order(ORDER(N)) Q:(N="")  D
 .	;
 .	N LOADORDR
 .	;
 .	S OBJ=ORDER(N)
 .	S LOADORDR=$piece(OBJ(OBJ),"|",3)
 .	; If set to load after things dependent on it, move them to later
 .	I (LOADORDR'<N) D
 ..		;
 ..		N M S M=""
 ..		;
 ..		F  S M=$order(ORDER(N,M)) Q:(M="")  D
 ...			;
 ...			S ORDER(LOADORDR+1,M)=""
 ...			K ORDER(N,M)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 S (N,OBJ)=""
 S SEQ=1
 F  S N=$order(ORDER(N)) Q:(N="")  D
 .	;
 .	F  S OBJ=$order(ORDER(N,OBJ)) Q:(OBJ="")  D
 ..		;
 ..		N CODE N DEPEND N KEYNAME N KEYS N OBJNAME
 ..		;
 ..		S OBJNAME=$piece(OBJ(OBJ),"|",2)
 ..		S CODE="type Record"_$ZCONVERT(OBJ,"U")_" "_OBJNAME
 ..		S CODE=CODE_"=Db.getRecord("""_OBJ_""","""
 ..		; Build key references for getRecord
 ..		; plus key list to return in PSLOBJ
 ..		S (KEYNAME,KEYS)=""
 ..		F  S KEYNAME=$order(OBJ(OBJ,KEYNAME)) Q:(KEYNAME="")  D
 ...			;
 ...			N VALUE
 ...			;
 ...			S KEYS=KEYS_KEYNAME_","
 ...			S VALUE=OBJ(OBJ,KEYNAME)
 ...			I (VALUE="") S VALUE=$ZCONVERT(KEYNAME,"U")
 ...			E  S VALUE=$$GETNAME(VALUE)
 ...			S CODE=CODE_KEYNAME_"=:"_VALUE_","
 ...			Q 
 ..		;
 ..		; Remove comma from end and close parenthesis
 ..		S CODE=$E(CODE,1,$L(CODE)-1)_""")"
 ..		S PSLOBJ(SEQ,1)=CODE
 ..		I (N=0) S DEPEND=0 ; Independent of other objects
 ..		E  S DEPEND=1 ; Dependent
 ..		S KEYS=$E(KEYS,1,$L(KEYS)-1) ; Remove comma
 ..		S PSLOBJ(SEQ)=OBJ_"|"_DEPEND_"|"_KEYS
 ..		S SEQ=SEQ+1
 ..		Q 
 .	Q 
 ;
 D ^SQLQ(WHERE,TABLES,.whr,,,,.fsn,.vdd) Q:ER 
 S (N,RNG)=""
 F  S N=$order(whr(N)) Q:(N="")  D
 .	;
 .	S RNG=RNG_1 ; Bitmap of number of queries
 .	S whr(N)=$translate(whr(N),$char(1),$char(2))
 .	I (whr(N)["vsql(") D
 ..		;
 ..		N M S M=""
 ..		;
 ..		F  S M=$order(vsub(M)) Q:(M="")  I (whr(N)[vsub(M)) S whr(N)=$$vStrRep(whr(N),vsub(M),$translate(M,":"),0,0,"")
 ..		Q 
 .	Q 
 ;
 S frm=TABLES
 S vxp=1 ; Current executable line for ^SQLA
 D QUERY^SQLA(RNG,.whr,.PSLQRY,.vsub,TABLES,.fsn,0,"") Q:ER 
 ;
 S N=""
 F  S N=$order(PSLQRY(N)) Q:(N="")  D
 .	;
 .	N I
 .	N X
 .	;
 .	S X=PSLQRY(N)
 .	F I=2:2:$L(X,$char(2)) D
 ..		;
 ..		N VALUE
 ..		;
 ..		S VALUE=$piece(X,$char(2),I)
 ..		S VALUE=$$GETNAME(VALUE) ; Get object.col ref
 ..		S $piece(X,$char(2),I)=VALUE
 ..		Q 
 .	;
 .	S X=$translate(X,$char(2)) ; Remove markers
 .	S X=$piece(X,"I '(",2) ; Remove beginning
 .	S X=$piece(X,") S vsql=1",1) ; Remove end
 .	S PSLQRY(N)=X
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
GETNAME(REF) ; Return correct object name and column attribute
 ;
 N COLUMN N OBJECT N OBJNAME
 N OLDVAL S OLDVAL=""
 ;
 S OBJECT=$piece(REF,".",1)
 S OBJNAME=$piece(OBJ(OBJECT),"|",2)
 I ($E(OBJNAME,$L(OBJNAME)-7+1,1048575)=".oldVal") D
 .	;
 .	S OLDVAL=".oldVal"
 .	S OBJNAME=$piece(OBJNAME,".",1)
 .	Q 
 S COLUMN=$ZCONVERT($piece(REF,".",2),"L")
 ;
 Q OBJNAME_"."_COLUMN_OLDVAL
 ;
 ; ---------------------------------------------------------------------
GETSQL(QRYID) ; DATA-QWICK Query ID
 ;
 N DQQRY N TABLES
 ;
 I '($D(^DBTBL("SYSDEV",4,QRYID))) D  Q 
 .	;
 .	S ER=1
 .	; No query definition found for ~p1
 .	S RM=$$^MSG(3561,QRYID)
 .	Q 
 ;
 N dbtbl4,vop1,vop2,vop3 S vop1="SYSDEV",vop2=QRYID,dbtbl4=$$vRCgetRecord0Opt^RecordDBTBL4("SYSDEV",QRYID,0,"")
  S vop3=$G(^DBTBL(vop1,4,vop2,0))
 S TABLES=$P(vop3,$C(124),1)
 ;
 ; Load the query
 N dbtbl4rs,vos1,vos2,vos3,vos4,vos5 S dbtbl4rs=$$vOpen1()
 ;
 I '$G(vos1) D  Q 
 .	;
 .	S ER=1
 .	; Incomplete query - ~p1
 .	S RM=$$^MSG(3559,QRYID)
 .	Q 
 ;
 F  Q:'$$vFetch1()  S DQQRY($P(dbtbl4rs,$C(9),1))=$P(dbtbl4rs,$C(9),2)
 ;
 S FROM=$$DQJOIN^SQLCONV(TABLES)
 S WHERE=$$WHERE^SQLCONV(.DQQRY,TABLES)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
GETFROM(WHERE,INSTANTS) ; 
 ;
 N FROM N ITEM N TABLE
 N I N PTR
 N TABLES S TABLES=""
 ;
 I '($get(INSTANTS)="") D
 .	;
 .	F I=1:1:$L(INSTANTS,",") D
 ..		;
 ..		S TABLE=$piece($piece(INSTANTS,",",I),"=")
 ..		S TABLES=$S(((","_TABLES_",")[(","_TABLE_",")):TABLES,1:$S((TABLES=""):TABLE,1:TABLES_","_TABLE))
 ..		Q 
 .	Q 
 ;
 S PTR=0
 F  Q:PTR=$L(WHERE)  D
 .	S ITEM=$translate($$FINDINAM^SQLDD(WHERE,.PTR)," ")
 .	I '(ITEM="") D
 ..		;
 ..		S TABLE=$piece(ITEM,".")
 ..		S TABLES=$S(((","_TABLES_",")[(","_TABLE_",")):TABLES,1:$S((TABLES=""):TABLE,1:TABLES_","_TABLE))
 ..		Q 
 .	Q 
 ;
 S FROM=$$DQJOIN^SQLCONV(TABLES) ; Construct FROM clause
 ;
 Q FROM
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61293^42704^Frans S.C. Witte^13557" ; Signature - LTD^TIME^USER^SIZE
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
vOpen1() ; SEQ,LINE FROM DBTBL4D WHERE LIBS='SYSDEV' AND QID=:QRYID AND SEQ > 0
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRYID) I vos3="" G vL1a0
 S vos4=0
vL1a4 S vos4=$O(^DBTBL("SYSDEV",4,vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dbtbl4rs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",4,vos3,vos4))
 S dbtbl4rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N ERROR,$ET,$ES S ERROR=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 D ZX^UCGMR(voxMrk) Q 
