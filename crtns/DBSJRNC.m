DBSJRNC(PRITABLE,PSLCODE)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSJRNC ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; I18N=OFF
	;
	 S ER=0
	;
	N INOREX N OLDORNEW
	N tld S tld=""
	N COUNT N N N OPT N PRIO
	N CMPERR N EFDOPT N JRNID N JRNIDX N KEYWORDS N MODE N PTONAME N SORT N TAB N TRANTYPE
	;
	D SORT(PRITABLE,.SORT,.JRNIDX,.COUNT,.tld)
	Q:'$D(SORT) 
	;
	; Load keywords
	N jrnfun,vos1,vos2,vos3 S jrnfun=$$vOpen1()
	F  Q:'($$vFetch1())  S KEYWORDS($P(jrnfun,$C(9),1))=$P(jrnfun,$C(9),2)
	I ($D(KEYWORDS("TableName"))#2) S KEYWORDS("TableName")=""""_PRITABLE_""""
	;
	S PTONAME=$$vStrLC(PRITABLE,0) ; Primary table object name
	;
	S TAB=$char(9)
	;
	S PSLCODE=COUNT_TAB_tld
	;
	D ADD("VJOURNAL(Record"_PRITABLE_" "_PTONAME_")",PRITABLE_" Journal file entries","H")
	D ADD("","","H")
	D ADD(TAB_"type Public Date %EffectiveDate",,"H")
	D ADD(TAB_"type Public String %TSRC,vpar,vx()",,"H")
	D ADD(TAB_"type String TSRC,vdi,vdx()",,"H")
	D ADD("",,"H")
	;
	D ADD(TAB_"if %TSRC.get().isNull() set TSRC=""O""",,"H")
	D ADD(TAB_"else  set TSRC=%TSRC",,"H")
	D ADD("",,"H")
	;
	; Build journal sections
	S JRNID=""
	F  S JRNID=$order(JRNIDX(JRNID)) Q:(JRNID="")  D  Q:ER 
	.	D BLDJRN(PRITABLE,PTONAME,JRNID,JRNIDX(JRNID),.OLDORNEW) Q:ER 
	.	S $piece(JRNIDX(JRNID),"|",2)=OLDORNEW
	.	Q 
	Q:ER 
	;
	; Add dispatch logic
	D DISPATCH(PRITABLE,.SORT,.JRNIDX,PTONAME)
	;
	D ADD("","","H")
	D ADD(TAB_"quit",,"H")
	D ADD("","","H")
	;
	Q 
	;
DISPATCH(PRITABLE,SORT,JRNIDX,PTONAME)	;
	;
	N MORELVL0 N MULTPRIO N VXQUIT
	N EFDCNT N MODECNT N TRANCNT
	N CODE N EFDOPT N INCOLUMN N MODE N PRIO N INCOL N JRNID N TAB N TABS N TRANTYPE N X
	;
	S (TAB,TABS)=$char(9)
	;
	S (EFDOPT,MODE,PRIO,INCOL,JRNID,TRANTYPE)=""
	S MODECNT=0
	F  S MODE=$order(SORT(MODE)) Q:(MODE="")  D
	.	I MODE'="I,U,D" D
	..		S CODE="if %ProcessMode="_$translate(MODE,"IUD","013")_" do {"
	..		I MODECNT S CODE="else  "_CODE
	..		S MODECNT=1
	..		D ADD(TAB_CODE,,"H")
	..		S TABS=TABS_TAB
	..		Q 
	.	;
	.	S TRANCNT=0
	.	F  S TRANTYPE=$order(SORT(MODE,TRANTYPE)) D  Q:(TRANTYPE="") 
	..		; Close structured do from MODE, if necessary
	..		I (TRANTYPE="") D  Q 
	...			I MODECNT D ADD(TABS_"}",,"H")
	...			S TABS=TAB
	...			Q 
	..		;
	..		I TRANTYPE'="F,O,B" D
	...			S CODE="if TSRC="""_TRANTYPE_""" do {"
	...			I TRANCNT S CODE="else  "_CODE
	...			S TRANCNT=1
	...			D ADD(TABS_CODE,,"H")
	...			S TABS=TABS_TAB
	...			Q 
	..		;
	..		S EFDCNT=0
	..		F  S EFDOPT=$order(SORT(MODE,TRANTYPE,EFDOPT)) D  Q:(EFDOPT="") 
	...			; Close structured do from TRANTYPE, if necessary
	...			I (EFDOPT="") D  Q 
	....				I TRANCNT D ADD(TABS_"}",,"H")
	....				S TABS=$E(TABS,1,$L(TABS)-1)
	....				Q 
	...			;
	...			I EFDOPT'="N,E" D
	....				S X="EFD.get()"
	....				I EFDOPT="N" S X="'"_X
	....				S CODE="if "_X_" do {"
	....				I EFDCNT S CODE="else  do {"
	....				S EFDCNT=1
	....				D ADD(TABS_CODE,,"H")
	....				S TABS=TABS_TAB
	....				Q 
	...			;
	...			S VXQUIT=0
	...			S MULTPRIO=$order(SORT(MODE,TRANTYPE,EFDOPT,""))'=$order(SORT(MODE,TRANTYPE,EFDOPT,""),-1)
	...			F  S PRIO=$order(SORT(MODE,TRANTYPE,EFDOPT,PRIO)) Q:(PRIO="")  D
	....				;
	....				; Determine if any priorities past this one have journals that
	....				; aren't dependend on specific columns (INCOLUMN)\
	....				S MORELVL0=0
	....				I MULTPRIO D
	.....					S X=PRIO
	.....					F  S X=$order(SORT(MODE,TRANTYPE,EFDOPT,X)) Q:X=""  I $D(SORT(MODE,TRANTYPE,EFDOPT,X,0)) S MORELVL0=1 Q 
	.....					Q 
	....				;
	....				F  S INCOL=$order(SORT(MODE,TRANTYPE,EFDOPT,PRIO,INCOL)) Q:(INCOL="")  D
	.....					; If single priority, or if multiple, but no further not-INCOLUMN journals, then
	.....					; can quit if vx not defined
	.....					I INCOL,'MORELVL0,'VXQUIT D
	......						D ADD(TABS_"quit:'vx.data()",,"H")
	......						S VXQUIT=1 ; Only add one quit on vx at EFD level
	......						Q 
	.....					;
	.....					F  S JRNID=$order(SORT(MODE,TRANTYPE,EFDOPT,PRIO,INCOL,JRNID)) Q:(JRNID="")  D
	......						S CODE="do vj"_+JRNIDX(JRNID)_"(."_PTONAME
	......						;
	......						I 'INCOL S CODE=CODE_")"
	......						; If INCOLUMNs, pass added parameter
	......						E  D
	.......							S INCOLUMN=SORT(MODE,TRANTYPE,EFDOPT,PRIO,INCOL,JRNID)
	.......							I INCOLUMN["," D
	........								S CODE=CODE_",vdi)"
	........								; If not OldValue or NewValue, just one journal entry,
	........								; otherwise, entry per column
	........								I '$piece(JRNIDX(JRNID),"|",2) S CODE=CODE_" quit"
	........								Q 
	.......							E  S CODE=CODE_","""_INCOLUMN_""")"
	.......							Q 
	......						;
	......						S CODE=CODE_TAB_"//"
	......						S CODE=CODE_" Mode="_MODE
	......						S CODE=CODE_" Tran="_TRANTYPE
	......						S CODE=CODE_" EFD="_EFDOPT
	......						S CODE=CODE_" Seq="_PRIO
	......						S CODE=CODE_" JRNID="_JRNID
	......						;
	......						; Do testing for column changes before journal call
	......						I INCOL S CODE=$$INCOLCK(INCOLUMN)_" "_CODE
	......						D ADD(TABS_CODE,,"H")
	......						Q 
	.....					Q 
	....				Q 
	...			;
	...			I EFDOPT'="N,E" D  ; Close this EFD loop
	....				D ADD(TABS_"}",,"H")
	....				S TABS=$E(TABS,1,$L(TABS)-1)
	....				Q 
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
INCOLCK(INCOLUMN)	; Private -- add check to see if columns defined before journal call
	;
	N CODE
	;
	; Only one column included
	I INCOLUMN'["," S CODE="if vx("""_INCOLUMN_""").exists()"
	E  D
	.	N I
	.	;
	.	S CODE=""
	.	F I=1:1:$L(INCOLUMN,",") S CODE=CODE_","""_$piece(INCOLUMN,",",I)_""""
	.	S CODE="for vdi="_$E(CODE,2,1048575)_" if vx(vdi).exists()"
	.	Q 
	;
	Q CODE
	;
BLDJRN(PRITABLE,PTONAME,JRNID,JRNSEQ,OLDORNEW)	;
	;
	N ISDO
	N I N SAVELINE
	N ACCKEYS N CODE N JRNOBNAM N JRNKEYS N JRNKEYSX N JRNTABLE N KEY N KEYS N MAP N MODE N N
	N TAB N TABLES N TABS N TAG N VARS
	;
	S TAB=$char(9)
	;
	N dbtbl9 S dbtbl9=$$vDb4("SYSDEV",PRITABLE,JRNID)
	;
	S JRNTABLE=$P(dbtbl9,$C(124),2) ; Journal table
	;
	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=JRNTABLE,dbtbl1=$$vDb5("SYSDEV",JRNTABLE,.vop3)
	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	I '$G(vop3) D  Q 
	.	S ER=1
	.	; Invalid table name - ~p1
	.	S RM=$$^MSG(1484,JRNTABLE)
	.	Q 
	;
	; Get journal table keys
	S JRNKEYS=0
	S ACCKEYS=$P(vop4,$C(124),1)
	F I=1:1:$L(ACCKEYS,",") D
	.	S KEY=$piece(ACCKEYS,",",I)
	.	; Ignore literal keys
	.	I '$$isLit^UCGM(KEY) D
	..		S JRNKEYS=JRNKEYS+1 ; Keep track of last key
	..		S JRNKEYS(JRNKEYS)=KEY ; Key number map
	..		S JRNKEYSX(KEY)="" ; List of columns that are keys
	..		Q 
	.	Q 
	;
	; Build MAP and determine if any other tables involved
	N rs9d,vos1,vos2,vos3,vos4,vos5 S rs9d=$$vOpen2()
	;
	; If use OldValue, NewValue, or FmTable, create separate entries for each modified column
	S OLDORNEW=0
	;
	; Only save map for columns that are mapped to some value
	S TABLES(PRITABLE)=PTONAME
	S TABLES=1
	F  Q:'($$vFetch2())  I $P(rs9d,$C(9),2)'="" D
	.	N VAL
	.	;
	.	S VAL=$$CHKTBLS($P(rs9d,$C(9),2),.TABLES)
	.	S MAP($P(rs9d,$C(9),1))=VAL
	.	I VAL["OldValue" S OLDORNEW=OLDORNEW+1
	.	I VAL["NewValue" S OLDORNEW=OLDORNEW+10
	.	I VAL["FmTable" S OLDORNEW=OLDORNEW+100
	.	Q 
	;
	; Set up line tag with reference to object passed to it
	S TAG="vj"_JRNSEQ_"(Record"_PRITABLE_" "_PTONAME
	;
	; If INCOLUMN, then include parameter passed as well
	I $P(dbtbl9,$C(124),7)'="" S TAG=TAG_",String vdi"
	;
	S TAG=TAG_")"
	;
	D ADD("")
	D ADD(TAG_TAB_"// "_JRNID_"  Table "_JRNTABLE_"  "_$P(dbtbl9,$C(124),1))
	D ADD("")
	;
	; If queries or multiple tables, add code to load other objects and execute queries
	I '($P(dbtbl9,$C(124),11)="")!'($P(dbtbl9,$C(124),12)="")!(TABLES>1) D
	.	N DQQRY
	.	;
	.	S DQQRY(1)=$P(dbtbl9,$C(124),11)
	.	S DQQRY(2)=$P(dbtbl9,$C(124),12)
	.	I (DQQRY(1)="") D
	..		S DQQRY(1)=DQQRY(2)
	..		K DQQRY(2)
	..		Q 
	.	;
	.	D QUERY(.TABLES,PRITABLE,PTONAME,.DQQRY) ; Add the query code
	.	Q 
	;
	; If update mode, generate journal for each change
	I $P(dbtbl9,$C(124),5)="U" D
	.	D UPDMODE($P(dbtbl9,$C(124),6),$P(dbtbl9,$C(124),7),OLDORNEW,.ISDO)
	.	I ISDO S TABS=TAB_TAB
	.	E  S TABS=TAB ; No added do level in journal
	.	Q 
	E  S TABS=TAB
	;
	D ADD(TABS,"// Save this line for Public datatyping, if needed",.SAVELINE)
	;
	; Type variables for key values
	S CODE="type String "
	I JRNKEYS>1 F I=1:1:JRNKEYS-1 S CODE=CODE_"v"_I_","
	S CODE=CODE_"vlastkey"
	D ADD(TABS_CODE)
	;
	; Handle OldValue/NewValue/FmTable keywords
	I $P(dbtbl9,$C(124),5)="U",OLDORNEW D
	.	D ADD("")
	.	S CODE="type String "
	.	I OLDORNEW#10 S CODE=CODE_"vold,"
	.	I (OLDORNEW#100)>9 S CODE=CODE_"vnew,"
	.	I OLDORNEW>99 S CODE=CODE_"vfmtable"
	.	I $E(CODE,$L(CODE))="," S CODE=$E(CODE,1,$L(CODE)-1)
	.	D ADD(TABS_CODE)
	.	D ADD("")
	.	I OLDORNEW#10 D ADD(TABS_"set vold=vx(vdi).piece(""|"",1)")
	.	I (OLDORNEW#100)>9 D ADD(TABS_"set vnew=vx(vdi).piece(""|"",2)")
	.	I OLDORNEW>99 D ADD(TABS_"set vfmtable=vx(vdi).piece(""|"",11)")
	.	D ADD("")
	.	Q 
	;
	; Assign key variables and build key string for journal object
	S KEYS=""
	I JRNKEYS>1 D
	.	F I=1:1:JRNKEYS-1 D  Q:ER 
	..		S KEY=JRNKEYS(I)
	..		D ADD(TABS_"set v"_I_"="_$$REF(MAP(KEY),PRITABLE,PTONAME,,.VARS))
	..		S KEYS=KEYS_KEY_"=:v"_I_","
	..		Q 
	.	S KEYS=$E(KEYS,1,$L(KEYS)-1) ; Strip comma
	.	Q 
	;
	; Set value to lastkey
	S KEY=JRNKEYS(JRNKEYS)
	I MAP(KEY)["NEXTVAL" S CODE="Db.nextVal("""_JRNTABLE_""","""_KEYS_""")"
	E  S CODE=$$REF(MAP(KEY),PRITABLE,PTONAME,KEY,.VARS)
	D ADD(TABS_"set vlastkey="_CODE)
	;
	S JRNOBNAM=$$vStrLC(JRNTABLE,0)
	;
	S CODE="type Record"_JRNTABLE_" "_JRNOBNAM_"=Db.getRecord("""_JRNTABLE_""","
	S KEYS=""
	I JRNKEYS'=1 D
	.	N I
	.	;
	.	F I=1:1:JRNKEYS-1 S KEYS=KEYS_JRNKEYS(I)_"=:v"_I_","
	.	Q 
	;
	S KEYS=KEYS_JRNKEYS(JRNKEYS)_"=:vlastkey" ; Add last key
	D ADD(TABS_CODE_""""_KEYS_""",1)") ; Add Db.getRecord(,,1)
	;
	; Set values into non-key columns
	S N=""
	F  S N=$order(MAP(N)) Q:(N="")  I '($D(JRNKEYSX(N))#2) D
	.	S CODE="set "_JRNOBNAM_"."_$S($E(N,1)="""":N,1:$$vStrLC(N,0))_"="_$$REF(MAP(N),PRITABLE,PTONAME,N,.VARS)
	.	D ADD(TABS_CODE)
	.	Q 
	;
	D ADD("")
	D ADD(TABS_"do "_JRNOBNAM_".save(""/NOVALFK/NOVALDD/NOVALRI"")") ; Save the record
	;
	I $P(dbtbl9,$C(124),5)="U",ISDO D ADD(TABS_"}") ; Close do, if there is one
	;
	D ADD("")
	D ADD(TAB_"quit")
	D ADD("")
	;
	; Type other variables as public, with exceptions as noted
	I $D(VARS) D
	.	N N N N1 N X
	.	;
	.	S X=""
	.	;
	.	; vdi, vnew, and vold are not public
	.	I ($D(VARS("vnew"))#2)!($D(VARS("vold"))#2) D
	..		S X=X_"vx(),"
	..		K VARS("vnew"),VARS("vold")
	..		Q 
	.	K VARS("vdi")
	.	;
	.	S N=""
	.	F  S N=$order(VARS(N)) Q:(N="")  D
	..		S N1=N
	..		I "+-"[$E(N1,1) S N1=$E(N1,2,1048575)
	..		I "$G$g"[$E(N1,1,2) S N1=$E(N1,4,$L(N1)-1)
	..		I (N1?1A.AN)!(N1?1"%".AN) S X=X_N1_","
	..		Q 
	.	S X=$E(X,1,$L(X)-1)
	.	I '(X="") D
	..		D ADD(TABS_"type Public String "_X,"",SAVELINE)
	..		Q 
	.	E  D ADD("",,SAVELINE)
	.	Q 
	;
	Q 
	;
SORT(PRITABLE,SORT,JRNIDX,COUNT,TLD)	;
	N vpc
	;
	N BREAKE N BREAKM N BREAKT
	N CODE N EFDOPT N INCOL N JRNID N MODE N PRIO N SORT1 N TRANTYPE
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen3()
	S vpc=('$G(vos1)) Q:vpc 
	;
	S COUNT=0
	F  Q:'($$vFetch3())  D
	.	N dbtbl9,vop1 S vop1=$P(ds,$C(9),3),dbtbl9=$G(^DBTBL($P(ds,$C(9),1),9,$P(ds,$C(9),2),vop1))
	.	;
	.	S CODE=$P(dbtbl9,$C(124),15)
	.	I '(CODE=""),'$$ifComp(CODE) Q  ; Conditionally include trigger
	.	;
	.	S COUNT=COUNT+1
	.	I $P(dbtbl9,$C(124),9)>TLD S TLD=$P(dbtbl9,$C(124),9) ; Get most recent update date
	.	S JRNIDX(vop1)=COUNT
	.	S INCOL='($P(dbtbl9,$C(124),7)="")
	.	;
	.	S SORT($P(dbtbl9,$C(124),5),$P(dbtbl9,$C(124),4),$P(dbtbl9,$C(124),3),$P(dbtbl9,$C(124),8),INCOL,vop1)=$P(dbtbl9,$C(124),7)
	.	Q 
	;
	S (EFDOPT,MODE,PRIO,INCOL,JRNID,TRANTYPE)=""
	I $order(SORT(""))'="I,U,D"!($order(SORT(""),-1)'="I,U,D") D BREAKM(.SORT)
	F  S MODE=$order(SORT(MODE)) Q:(MODE="")  D
	.	I $order(SORT(MODE,""))'="F,O,B"!($order(SORT(MODE,""),-1)'="F,O,B") D BREAKT(.SORT,MODE)
	.	F  S TRANTYPE=$order(SORT(MODE,TRANTYPE)) Q:(TRANTYPE="")  D
	..		I $order(SORT(MODE,TRANTYPE,""))'="N,E"!($order(SORT(MODE,TRANTYPE,""),-1)'="N,E") D BREAKE(.SORT,MODE,TRANTYPE)
	..		Q 
	.	Q 
	;
	Q 
	;
BREAKM(SORT)	; Private - break Mode level into components
	;
	N I
	N EFDOPT N MODE N MODE1 N TRANTYPE
	;
	S (EFDOPT,MODE,TRANTYPE)=""
	F  S MODE=$order(SORT(MODE)) Q:(MODE="")  I MODE["," D
	.	F I=1:1:$L(MODE,",") S MODE1=$piece(MODE,",",I) D
	..		F  S TRANTYPE=$order(SORT(MODE,TRANTYPE)) Q:(TRANTYPE="")  D
	...			F  S EFDOPT=$order(SORT(MODE,TRANTYPE,EFDOPT)) Q:(EFDOPT="")  D BREAKSET(.SORT,MODE,MODE1,TRANTYPE,TRANTYPE,EFDOPT,EFDOPT)
	...			Q 
	..		Q 
	.	K SORT(MODE) ; Remove this level now that broken into components
	.	Q 
	;
	Q 
	;
BREAKT(SORT,MODE)	;
	;
	N I
	N EFDOPT N TRANTYP1 N TRANTYPE
	;
	S (EFDOPT,TRANTYPE)=""
	F  S TRANTYPE=$order(SORT(MODE,TRANTYPE)) Q:(TRANTYPE="")  I TRANTYPE["," D
	.	F I=1:1:$L(TRANTYPE,",") S TRANTYP1=$piece(TRANTYPE,",",I) D
	..		F  S EFDOPT=$order(SORT(MODE,TRANTYPE,EFDOPT)) Q:(EFDOPT="")  D BREAKSET(.SORT,MODE,MODE,TRANTYPE,TRANTYP1,EFDOPT,EFDOPT)
	..		Q 
	.	K SORT(MODE,TRANTYPE) ; Remove this level now that broken into components
	.	Q 
	;
	Q 
	;
BREAKE(SORT,MODE,TRANTYPE)	;
	;
	N I
	N EFDOPT N EFDOPT1
	;
	S EFDOPT=""
	F  S EFDOPT=$order(SORT(MODE,TRANTYPE,EFDOPT)) Q:(EFDOPT="")  I EFDOPT["," D
	.	F I=1:1:$L(EFDOPT,",") S EFDOPT1=$piece(EFDOPT,",",I) D
	..		D BREAKSET(.SORT,MODE,MODE,TRANTYPE,TRANTYPE,EFDOPT,EFDOPT1)
	..		Q 
	.	K SORT(MODE,TRANTYPE,EFDOPT) ; Remove this level now that broken into components
	.	Q 
	;
	Q 
	;
BREAKSET(SORT,MODE,MODE1,TRANTYPE,TRANTYP1,EFDOPT,EFDOPT1)	;
	;
	N INCOL N JRNID N PRIO
	;
	S (PRIO,INCOL,JRNID)=""
	F  S PRIO=$order(SORT(MODE,TRANTYPE,EFDOPT,PRIO)) Q:(PRIO="")  D
	.	F  S INCOL=$order(SORT(MODE,TRANTYPE,EFDOPT,PRIO,INCOL)) Q:(INCOL="")  D
	..		F  S JRNID=$order(SORT(MODE,TRANTYPE,EFDOPT,PRIO,INCOL,JRNID)) Q:(JRNID="")  D
	...			S SORT(MODE1,TRANTYP1,EFDOPT1,PRIO,INCOL,JRNID)=SORT(MODE,TRANTYPE,EFDOPT,PRIO,INCOL,JRNID)
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
REF(REF,PRITABLE,PTONAME,COLNAME,VARS)	;
	;
	N KEYWD
	;
	I $E(REF,1)="""" Q REF ; "Text"
	I REF?.N!(REF?.N1"."1.N) Q REF ; Numeric
	;
	I REF?1"OLD.".E Q PTONAME_"."_$$vStrLC($piece(REF,".",2),0)_".oldVal"
	I REF?1"NEW.".E Q PTONAME_"."_$$vStrLC($piece(REF,".",2),0)_".curVal"
	;
	; Either keyword or $$ reference -- replace keywords
	S KEYWD=""
	F  S KEYWD=$order(KEYWORDS(KEYWD)) Q:(KEYWD="")  I REF[KEYWD D
	.	S REF=$$vStrRep(REF,KEYWD,KEYWORDS(KEYWD),0,0,"")
	.	S VARS(KEYWORDS(KEYWD))=""
	.	Q 
	;
	Q REF
	;
QUERY(TABLES,PRITABLE,OBJNAME,DQQRY)	;
	;
	N DUMMYQRY
	N N N SEQ
	N INPUT N NEWTBLS N PSLOBJ N PSLQRY N TAB N TBLS N VARINS N VARLIST
	;
	S TAB=$char(9)
	;
	S N=""
	F  S N=$order(DQQRY(N)) Q:(N="")  I '(DQQRY(N)="") D
	.	N NEWQRY N TOK N X
	.	;
	.	S NEWQRY=$$CHKTBLS(DQQRY(N),.TABLES)
	.	;
	.	S X=$$TOKEN^%ZS(NEWQRY,.TOK) ; Tokenize to remove quote issues
	.	;
	.	; Substitute any complex variable insertion, get variable list for public typing
	.	I X["<<" D
	..		N EXPR N RET
	..		;
	..		S RET=""
	..		F  D  Q:(X="") 
	...			S RET=RET_$piece(X,"<<",1)_"<<"
	...			S EXPR=$piece($piece(X,"<<",2),">>",1)
	...			; Deal with less than, e.g., X<<<ABC>>
	...			I $E(EXPR,1)="<" D
	....				S RET=RET_"<"
	....				S EXPR=$E(EXPR,2,1048575)
	....				Q 
	...			;
	...			; Replace if complex expression, otherwise, leave alone
	...			I '(EXPR?1A.AN!(EXPR?1"%".AN)) D
	....				S VARINS=$get(VARINS)+1
	....				S VARINS("VQ"_VARINS)=$$UNTOK^%ZS(EXPR,.TOK)
	....				S RET=RET_"VQ"_VARINS_">>"
	....				Q 
	...			E  D
	....				S RET=RET_EXPR_">>"
	....				S VARLIST(EXPR)=""
	....				Q 
	...			;
	...			S X=$piece(X,">>",2,999)
	...			I X'["<<" S RET=RET_X S X=""
	...			Q 
	..		;
	..		S DQQRY(N)=$$UNTOK^%ZS(RET,.TOK)
	..		Q 
	.	Q 
	;
	S TBLS=PRITABLE_","
	F  S N=$order(TABLES(N)) Q:(N="")  I N'=PRITABLE S TBLS=TBLS_N_","
	S TBLS=$E(TBLS,1,$L(TBLS)-1)
	;
	; If all we are dealing with is a need to load other table info use a dummy query
	I TABLES>1,($get(DQQRY(1))="") D
	.	S DUMMYQRY=1
	.	S DQQRY(1)="1>0"
	.	Q 
	E  S DUMMYQRY=0
	;
	; Convert to SQL FROM and WHERE to allow call to UCQRYBLD
	S INPUT("WHERE")=$$WHERE^SQLCONV(.DQQRY,TBLS)
	S INPUT("FROM")=$$DQJOIN^SQLCONV(TBLS)
	;
	D ^UCQRYBLD(.INPUT,PRITABLE_"="_OBJNAME,,.PSLOBJ,.PSLQRY)
	;
	; Add typing for any <<>> variables
	I $D(VARLIST) D
	.	N CODE N N
	.	;
	.	S CODE="type Public String "
	.	S N=""
	.	F  S N=$order(VARLIST(N)) Q:N=""  S CODE=CODE_N_","
	.	S CODE=$E(CODE,1,$L(CODE)-1)
	.	D ADD(TAB_CODE)
	.	D ADD("")
	.	Q 
	;
	I $D(PSLOBJ) D
	.	S (N,SEQ)=""
	.	F  S N=$order(PSLOBJ(N)) Q:(N="")  D
	..		F  S SEQ=$order(PSLOBJ(N,SEQ)) Q:(SEQ="")  D
	...			N CODE
	...			;
	...			S CODE=PSLOBJ(N,SEQ)
	...			I SEQ=1 D
	....				N OBJNEW N OBJOLD
	....				;
	....				S OBJNEW=TABLES($piece(PSLOBJ(N),"|",1))
	....				S OBJOLD=$piece($piece(CODE,"=Db.getRecord",1)," ",3)
	....				S CODE=$$vStrRep(CODE,OBJOLD,OBJNEW,0,0,"")
	....				S NEWTBLS(OBJOLD)=OBJNEW
	....				; Add 1 as third parameter
	....				S CODE=$E(CODE,1,$L(CODE)-1)_",1)"
	....				Q 
	...			D ADD(TAB_CODE)
	...			Q 
	..		Q 
	.	D ADD("")
	.	Q 
	;
	; If any variable substition for queries, set it
	I $D(VARINS) D
	.	N CODE
	.	;
	.	S CODE="type String "
	.	S N=""
	.	F  S N=$order(VARINS(N)) Q:(N="")  S CODE=CODE_N_","
	.	D ADD(TAB_$E(CODE,1,$L(CODE)-1))
	.	D ADD("")
	.	;
	.	F  S N=$order(VARINS(N)) Q:(N="")  D ADD(TAB_"set "_N_"="_VARINS(N))
	.	D ADD("")
	.	Q 
	;
	; Insert query logic - for tables instantiated by query logic, replace object names
	I 'DUMMYQRY D
	.	S (N,SEQ)=""
	.	F  S SEQ=$order(PSLQRY(SEQ)) Q:(SEQ="")  D
	..		F  S N=$order(NEWTBLS(N)) Q:(N="")  D
	...			I PSLQRY(SEQ)[N S PSLQRY(SEQ)=$$vStrRep(PSLQRY(SEQ),N,NEWTBLS(N),0,0,"")
	...			Q 
	..		D ADD(TAB_"if "_PSLQRY(SEQ))
	..		D ADD(TAB_"else  quit")
	..		Q 
	.	Q 
	;
	D ADD("")
	;
	Q 
	;
UPDMODE(EXC,INC,OLDORNEW,ISDO)	;
	;
	N CODE N TAB
	;
	S ISDO=1
	S TAB=$char(9)
	;
	; No include or exclude - do them all
	I (INC=""),(EXC="") D
	.	D ADD(TAB_"type Public String vx()")
	.	D ADD(TAB_"type String vdi")
	.	D ADD("")
	.	S CODE="set vdi="""" for  set vdi=vx(vdi).order() quit:vdi=""""  do {"
	.	I 'OLDORNEW S CODE=CODE_" quit"
	.	D ADD(TAB_CODE)
	.	Q 
	;
	; All testing/assignments will be done before the call in this case, so just
	; need to indicate not creating this is a structured do
	E  I '(INC="") S ISDO=0
	;
	; Excluded columns
	E  D
	.	N CODE
	.	D ADD(TAB_"type Public String vx()")
	.	D ADD(TAB_"type String vdi")
	.	S CODE="set vdi="""" for  set vdi=vx(vdi).order() quit:vdi="""""
	.	; Piece 3 of vx = 1 indicates journal flag off for this column
	.	S CODE=CODE_"  if 'vx(vdi).piece(""|"",3)"
	.	;
	.	; Only one column to exclude
	.	I EXC'["," S CODE=CODE_" if vdi'="""_EXC_""" do {"
	.	E  S CODE=CODE_" if "","_EXC_",""'[("",""_vdi_"","") do {"
	.	I 'OLDORNEW S CODE=CODE_" quit"
	.	D ADD(TAB_CODE)
	.	Q 
	;
	Q 
	;
CHKTBLS(REF,TABLES)	;
	;
	; Note - this code copied, in part, from PARSE^UCUTIL
	;
	N PTR
	N ATOM N DELS N RETURN N TOK
	;
	S DELS=",()+-*/\#'=><[]\*_"
	;
	I REF["""" S REF=$$TOKEN^%ZS(REF,.TOK)
	;
	S PTR=0 S RETURN=""
	F  D  Q:PTR=0 
	.	S ATOM=$$ATOM^%ZS(REF,.PTR,DELS,.TOK,1)
	.	I $L(ATOM,".")=3 S ATOM=$piece(ATOM,".",2,3) ; Remove library
	.	I ATOM?1A.AN.E1".".E.AN D  ; table.column
	..		N TABLE
	..		;
	..		S TABLE=$piece(ATOM,".",1)
	..		;
	..		; Ignore OLD.COL, NEW.COL syntax, and NEXTBAL
	..		Q:TABLE="OLD"!(TABLE="NEW")!(ATOM["NEXTVAL") 
	..		;
	..		; Get table object name
	..		I '($D(TABLES(TABLE))#2) D
	...			S TABLES(TABLE)=$$vStrLC(TABLE,0)
	...			S TABLES=TABLES+1
	...			Q 
	..		; Replace table.column reference with object reference
	..		S ATOM=TABLES(TABLE)_"."_$piece(ATOM,".",2)
	..		S ATOM=$$vStrLC(ATOM,0)
	..		Q 
	.	S RETURN=RETURN_ATOM
	.	Q 
	;
	I ($D(TOK)#2) S RETURN=$$UNTOK^%ZS(RETURN,.TOK)
	;
	Q RETURN
	;
ADD(DATA,COMMENT,LINE)	;
	;
	; Add to end of header section
	I $get(LINE)="H" S LINE=$order(PSLCODE(1000),-1)+1
	E  I '$get(LINE) D
	.	S LINE=$order(PSLCODE(""),-1)
	.	I LINE<1000 S LINE=1000
	.	S LINE=LINE+1
	.	Q 
	;
	I '($get(COMMENT)="") D
	.	I $E(DATA,1)=$char(9) D
	..		N LEN
	..		N X S X=$C(9,9,9,9,9,9,9,9,9,9)
	..		;
	..		S LEN=(($L(DATA,$char(9))-1)*7)+$L(DATA)
	..		I LEN<55 S DATA=DATA_$E(X,1,((63-LEN)\8)-1)
	..		Q 
	.	S DATA=DATA_$char(9)_"//"_COMMENT
	.	Q 
	;
	S PSLCODE(LINE)=DATA
	;
	Q 
	;
ifComp(code)	; xecute DBTBL9.IFCOMP and return truth
	;
	N isTrue S isTrue=0
	D ifCompx(code,.isTrue)
	Q isTrue
	;
ifCompx(code,isTrue)	;
	;
	N cnt N seq
	N cmperr N m N psl
	;
	S psl(1)=" if "_code
	D cmpA2A^UCGM(.psl,.m,,,,,.cmperr) I $get(cmperr) D  Q 
	.	S ER=1
	.	S RM="Journal condition compile error: "_code
	.	Q 
	;
	S cnt=0
	S seq=""
	F  S seq=$order(m(seq)) Q:(seq="")  S cnt=cnt+1
	I cnt>2 D  Q 
	.	S ER=1
	.	S RM="Invalid journal condition - multi-line generated code: "_code
	.	Q 
	;
	N $ZT
	S $ZT="S ER=1,RM=""Invalid journal condition: ""_code ZG "_($ZL-1)
	S cnt=$order(m("")) ; Get code to execute
	;  #ACCEPT DATE=07/07/05; PGM=Dan Russell; CR=16531
	XECUTE m(cnt)
	;
	S isTrue=$T
	;
	Q 
	;
vSIG()	;
	Q "60726^46471^Dan Russell^26129" ; Signature - LTD^TIME^USER^SIZE
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
vStrRep(object,p1,p2,p3,p4,qt)	; String.replace
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
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrFnd(object,p1,p2,p3,qt)	; String.find
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (p1="") Q $SELECT(p2<1:1,1:+p2)
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S p2=$F(object,p1,p2)
	I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
	.	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
	.	Q 
	Q p2
	;
vDb4(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL9,,0)
	;
	N dbtbl9
	S dbtbl9=$G(^DBTBL(v1,9,v2,v3))
	I dbtbl9="",'$D(^DBTBL(v1,9,v2,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL9" X $ZT
	Q dbtbl9
	;
vDb5(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL1,,1,-2)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	S v2out='$T
	;
	Q dbtbl1
	;
vOpen1()	;	FUNC,CODE FROM STBLJRNFUNC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^STBL("JRNFUNC",vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos3=$G(^STBL("JRNFUNC",vos2))
	S jrnfun=$S(vos2=$C(254):"",1:vos2)_$C(9)_$P(vos3,"|",2)
	;
	Q 1
	;
vOpen2()	;	COLNAM,MAP FROM DBTBL9D WHERE %LIBS='SYSDEV' AND PRITABLE=:PRITABLE AND JRNID=:JRNID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(PRITABLE) I vos2="" G vL2a0
	S vos3=$G(JRNID) I vos3="" G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^DBTBL("SYSDEV",9,vos2,vos3,vos4),1) I vos4="" G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL("SYSDEV",9,vos2,vos3,vos4))
	S rs9d=$S(vos4=$C(254):"",1:vos4)_$C(9)_$P(vos5,"|",1)
	;
	Q 1
	;
vOpen3()	;	%LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' AND PRITABLE=:PRITABLE
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(PRITABLE) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",9,vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
