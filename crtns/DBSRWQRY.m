 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRWQRY ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRWQRY(dbtbl5h,PQINFO,WHERE) ; 
 N vpc
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 ;
 N ER S ER=0
 N RM S RM=""
 N DBLWILD N N N SEQ
 N BEGQRY N DQQRY N FROM N par N RAWQRY N RID N TABLES N vd N vdd
 ;
 K PQINFO
 S PQINFO=0
 ;
 S WHERE="" ; Return null if going to use dynamic where
 ;
 S RID=vobj(dbtbl5h,-4)
 ; Load raw query
 ;
 N ds,vos1,vos2,vos3,vos4,vos5,vOid S ds=$$vOpen1()
 ;
 S BEGQRY="" ; For continuation lines - end in ;, join to next line
 S SEQ=1
 F  Q:'$$vFetch1()  D
 .	N X
 .	;
 . N dbtbl5pr S dbtbl5pr=$$vRCgetRecord1Opt^RecordDBTBL5PR($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1,"")
 .	;
 .	S X=$P(dbtbl5pr,$C(12),1)
 .	S X=$$vStrRep(X,$char(9)," ",0,0,"")
 .	S X=$$vStrTrim(X,0," ") ; Remove leading and trailing spaces
 . S vpc=X=""!($E(X,1)=";")!($E(X,1,2)="//") Q:vpc 
 .	I BEGQRY'="" D
 ..		S X=BEGQRY_X
 ..		S BEGQRY=""
 ..		Q 
 .	; If continuation query, save to add to next line
 . I $E(X,$L(X))=";" D  Q 
 ..		S X=$E(X,1,$L(X)-1)
 ..		S BEGQRY=BEGQRY_X
 ..		Q 
 .	S RAWQRY(SEQ)=X
 .	S SEQ=SEQ+1
 . Q 
 ;
 ; For SQL query syntax, simply return query as WHERE clause
 I $P(vobj(dbtbl5h,0),$C(124),13) D  Q RM
 .	S WHERE=""
 .	F SEQ=1:1 Q:'$D(RAWQRY(SEQ))  D  Q:ER 
 ..		; <<*>> and <<**>> run-time input not allowed for MSQL syntax
 ..		I RAWQRY(SEQ)["<<*" D  Q 
 ...			S ER=1
 ...			; Invalid query syntax
 ...			S RM=$$^MSG(1434)_" "_RAWQRY(SEQ)
 ...			Q 
 ..		S WHERE=WHERE_RAWQRY(SEQ)_" "
 ..		Q 
 .	S WHERE=$E(WHERE,1,$L(WHERE)-1)
 .	Q 
 ;
 S TABLES=$P(vobj(dbtbl5h,0),$C(124),1)
 S DBLWILD=0 ; Double wild cards
 ;
 ; Parse prompts and queries to validate and return data to build prompts
 F SEQ=1:1 Q:'$D(RAWQRY(SEQ))  D
 .	N QRYLINE
 .	;
 .	S QRYLINE=RAWQRY(SEQ)
 .	;
 .	; Remove () if only on outer portion - not necessary and
 .	; affects SQLCONV
 .	I QRYLINE?1"(".E1")",$E(QRYLINE,2,1048575)'["(" S QRYLINE=$E(QRYLINE,2,$L(QRYLINE)-1)
 .	;
 .	; User-define variable - value entered at run-time
 .	I QRYLINE?1"&<<".E D
 ..		N I N KWNUM
 ..		N EXPR N KEYWRDS N PARAMS N TAB N TOK N VAR N X
 ..		;
 ..		; Parse parameters and build PQINFO
 ..		S VAR=$piece($piece(QRYLINE,">>",1),"<<",2) ; Variable name
 ..		S X=$piece(QRYLINE,">>",2,99)
 ..		S X=$$vStrTrim(X,0," ")
 ..		; Tokenize to avoid embedded quotes
 ..		S PARAMS=$$TOKEN^%ZS(X,.TOK)
 ..		S TAB="|255|||||||T" ; Default values
 ..		; Decode keywords and build TAB
 ..		D KEYWRDS(PARAMS,.TAB) Q:ER 
 ..		S TAB=$$UNTOK^%ZS(TAB,.TOK)
 ..		; Remove quotes from around prompt
 ..		I ($E($piece(TAB,"|",10),1)="""") S $piece(TAB,"|",10)=$$QSUB^%ZS($piece(TAB,"|",10),"""")
 ..		; If prompt missing, replace with question marks
 ..		I $piece(TAB,"|",10)="" S $piece(TAB,"|",10)="??"
 ..		S PQINFO(SEQ)=VAR_"|UV"
 ..		S PQINFO(SEQ,1)=TAB
 ..		Q 
 .	;
 .	; Fixed query - input within report
 .	E  I QRYLINE'?.E1"<<*".E1">>".E D
 ..		N WHERE
 ..		; Validate query syntax
 ..		S WHERE=$$WHERE^SQLCONV(QRYLINE,TABLES)
 ..		I ER WRITE !,$get(RM),"  ",QRYLINE,!
 ..		E  D
 ...			S PQINFO=1
 ...			S PQINFO(SEQ)="|F"
 ...			S PQINFO(SEQ,2)=QRYLINE
 ...			Q 
 ..		Q 
 .	;
 .	E  D
 ..		N DI N OP N PARAMS N TAB N WCT
 ..		;
 ..		; Get just data item reference - deal with syntaxes
 ..		; like [LIB,TBL]COL=<<*>> and [TBL]COL= <<*>>
 ..		D GETINFO(QRYLINE,.DI,.OP,.PARAMS)
 ..		I OP="" D  ; Double wild card
 ...			S WCT="WC2"
 ...			S DBLWILD=1
 ...			Q 
 ..		E  S WCT="WC1" ; Single wild card
 ..		;
 ..		; Validate query for <<*>> syntax.  Replace <<*>> with
 ..		; <<X>> for test.  <<**>> will be validated at run-time.
 ..		I WCT="WC1" D  Q:ER 
 ...			N WHERE N X
 ...			; set X=QRYLINE.piece("<<*",1)_"<<X>>"
 ...			S X=DI_" "_OP_" <<X>>"
 ...			S WHERE=$$WHERE^SQLCONV(X,TABLES)
 ...			I ER WRITE !,$get(RM),"  ",QRYLINE,!
 ...			Q 
 ..		; Create %TAB info for wild card
 ..		D BLDTAB(WCT,DI,OP,PARAMS,.TAB)
 ..		;
 ..		; Input required for <<*>>
 ..		I WCT="WC1" S $piece(TAB,"|",11)=1
 ..		;
 ..		; Save prompt/query info.  Will build up query from
 ..		; variable name, data item, and operation
 ..		S PQINFO=1
 ..		S PQINFO(SEQ)="VIN"_SEQ_"|"_WCT_"|"_DI
 ..		S PQINFO(SEQ,1)=TAB
 ..		S PQINFO(SEQ,2)=OP
 ..		Q 
 .	Q 
 ;
 I ER Q RM
 ;
 ; If there are any double wild cards, requires dynamic SQL, which will
 ; be built at run-time.
 I DBLWILD Q RM
 ;
 ; Buld WHERE clause from queries
 S N="" S SEQ=1
 F  S N=$order(PQINFO(N)) Q:N=""  D
 .	Q:$get(PQINFO(N,2))=""  ; No query
 .	; If fixed query, use as is
 .	I $piece(PQINFO(N),"|",2)'="WC1" S DQQRY(SEQ)=PQINFO(N,2)
 .	E  D  ; Single wild card
 ..		N X
 ..		S X=$piece(PQINFO(N),"|",3)_" " ; DI
 ..		S X=X_PQINFO(N,2)_" " ; Operator
 ..		S X=X_"<<"_$piece(PQINFO(N),"|",1)_">>" ; Variable
 ..		S DQQRY(SEQ)=X
 ..		Q 
 .	S SEQ=SEQ+1
 .	Q 
 ;
 S FROM=$$DQJOIN^SQLCONV(TABLES) Q:ER RM
 S WHERE=$$WHERE^SQLCONV(.DQQRY,TABLES)
 ;
 Q RM
 ;
GETINFO(X,DI,OP,PARAMS) ; 
 ;
 N PTR
 ;
 S X=$$vStrTrim(X,0," ") ; Remove leading/trailing spaces
 S PARAMS="<<*"_$piece(X,"<<*",2,999)
 S X=$piece(X,PARAMS,1) ; Get data reference and operator
 S X=$translate(X," ") ; Remove any spaces
 ; If double wild card, should be no operator, but some code has =, so remove
 I PARAMS?1"<<**".E S DI=$TR(X,"=") S OP=""
 E  D  ; Single wild card
 .	; Deal with [TABLE] syntax since [ and ] can also be operators.
 .	I $E(X,1)="[" D
 ..		S PTR=$F(X,"]")-1
 ..		S DI=$E(X,1,PTR)
 ..		;set X=X.extract(PTR+1,X.length())
 ..		Q 
 .	E  S DI=""
 .	;
 .	S DI=DI_$$ATOM^%ZS(X,.PTR,"[]'=><?")
 .	I PTR S OP=$E(X,PTR+1,1048575)
 .	E  S OP="=" ; Default operator for <<*>>
 .	Q 
 ;
 ; Remove library reference if it exists
 I $E(DI,1)="[",DI["," S DI="["_$piece(DI,",",2)
 ;
 Q 
 ;
BLDTAB(WCTYPE,DI,OP,PARAMS,TAB) ; 
 ;
 ; Old Syntax = <<*,PROMPT,DEFAULT,USER_VAR,DTCONV>>
 ; New Syntax = <<*/keyword=.../keyword=...>>
 ;
 N ATTR N DATACONV N HLP N POSTPROC N TBL N TOK
 ;
 S PARAMS=$$TOKEN^%ZS(PARAMS,.TOK)
 ;
 S ATTR=$$DI^DBSDD(DI,"",.vdd)
 S HLP=DI
 S TBL=$piece(ATTR,"|",5)
 I TBL'="" S TBL=TBL_":NOVAL"
 ; Otherwise, may be key lookup
 E  I $piece(ATTR,"|",1)["*" S TBL=DI_":DISTINCT:NOVAL"
 ;
 S TAB="|"_$piece(ATTR,"|",2)_"||"_HLP_"|"_TBL_"||||"_$piece(ATTR,"|",9)
 ;
 ; Create variable description
 D  Q:ER 
 .	N DONE
 .	N PTR
 .	N X N Z
 .	;
 .	; Get next >> until equal number of << and >>
 .	S (DONE,PTR)=0
 .	F  S PTR=$F(PARAMS,">>",PTR) Q:'PTR  D  Q:DONE 
 ..		S X=$E(PARAMS,1,PTR-1)
 ..		I $L(X,"<<")=$L(X,">>") S DONE=1
 ..		Q 
 .	;
 .	I 'PTR S Z=PARAMS
 .	E  S Z=$E(PARAMS,1,PTR-3)
 .	;
 .	I Z["**" S Z=$piece(Z,"**",2,9) ; &<<var>>/...* syntax
 .	E  S Z=$piece(Z,"*",2,9)
 .	;
 .	S Z=$$vStrTrim(Z,0," ") ; Trim leading and trailing blanks
 .	;
 .	I $E(Z,1)="/" D  Q:ER  ; New format
 ..		D KEYWRDS(Z,.TAB)
 ..		Q 
 .	;
 .	; Deal with old format -
 .	; <<**,Prompt,Default,User Variable,Date Conversion>>
 .	E  I $piece(Z,",",2,99)'="" D
 ..		N POSTPROC N UDVAR
 ..		S $piece(TAB,"|",10)=$piece(Z,",",2) ; Description
 ..		S $piece(TAB,"|",3)=$piece(Z,",",3) ; Default
 ..		S UDVAR=$piece(Z,",",4) ; User defined variable
 ..		I $piece(Z,",",5) D
 ...			S POSTPROC="S X=$$^SCAJD(X)" ; Date conversion
 ...			I UDVAR'="" S POSTPROC=UDVAR_" "_POSTPROC
 ...			Q 
 ..		E  S POSTPROC=UDVAR
 ..		S $piece(TAB,"|",7)=POSTPROC
 ..		Q 
 .	Q 
 ;
 I $piece(TAB,"|",7)?.E1"@["1E.E1"]".E S $piece(TAB,"|",7)=""
 ;
 S POSTPROC=$piece(TAB,"|",7)
 ;
 I WCTYPE="WC2" D  ; Handle double wild card
 .	;
 .	; Set default to "ALL" if no other default
 .	I $piece(TAB,"|",3)="" S $piece(TAB,"|",3)="""ALL"""
 .	I $piece(TAB,"|",10)="" S $piece(TAB,"|",10)=$piece(ATTR,"|",10) ; Prompt
 .	S $piece(TAB,"|",2)=255 S $piece(TAB,"|",9)="T"
 .	; Query post processor (QRYPOS)
 .	I $piece(TAB,"|",16)'="" D
 ..		S POSTPROC=$piece(TAB,"|",16)_" "_POSTPROC
 ..		S $piece(TAB,"|",16)=""
 ..		Q 
 .	; For double wild card, use EXT^DBSQRY to validate input
 .	I POSTPROC="" S POSTPROC="D EXT^DBSQRY"
 .	E  S POSTPROC=POSTPROC_" D EXT^DBSQRY"
 .	S $piece(TAB,"|",7)=POSTPROC
 .	Q 
 ;
 ; Single wild card
 E  I $piece(TAB,"|",10)="" D  ; Add prompt if missing
 .	N dbctlqry S dbctlqry=$$vRCgetRecord0Opt^RecordDBCTLQRY(0,OP,0,"")
 .	S $piece(TAB,"|",10)=$piece(ATTR,"|",10)_" "_$P(dbctlqry,$C(124),3)
 . Q 
 ;
 S TAB=$$UNTOK^%ZS(TAB,.TOK)
 ;
 ; Remove quotes from around prompt
 I ($E($piece(TAB,"|",10),1)="""") S $piece(TAB,"|",10)=$$QSUB^%ZS($piece(TAB,"|",10),"""")
 ;
 Q 
 ;
KEYWRDS(X,TAB) ; Private - Parse X for keywords and build TAB
 ;
 N EXPR N I N KEYWRDS N KWNUM
 ;
 ; Remove leading << and trailing >> if any
 I $E(X,1,2)="<<" S X=$E(X,3,1048575)
 I X?.E1">>" S X=$E(X,1,$L(X)-2)
 ;
 S KEYWRDS=",LENGTH/TYP=N/MAX=255,DEFAULT/NOQWT,HELP,TABLE,PATTERN,POST,PRE,FORMAT,PROMPT,REQUIRED/TYP=L,MINIMUM,MAXIMUM,DECIMAL/TYP=N,SUPPRESS,QRYPOS,TBL"
 F I=2:1:$L(X,"/") D  Q:ER 
 .	S EXPR=$piece(X,"/",I)
 .	S KWNUM=$$PAR^DBSQRY(.EXPR,KEYWRDS) Q:ER 
 .	I KWNUM=12!(KWNUM=13),EXPR?1A.AN.E!(EXPR?1"%".AN.E) S EXPR="<<"_EXPR_">>"
 .	I KWNUM=17 S KWNUM=5 ; Change /TBL to /TAB
 .	S $piece(TAB,"|",KWNUM)=EXPR
 .	Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60680^47183^Dan Russell^11600" ; Signature - LTD^TIME^USER^SIZE
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
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
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
vOpen1() ; LIBS,RID,SEQ FROM DBTBL5PR WHERE RID=:RID AND SEQ>'30.999' AND SEQ<'50' ORDER BY SEQ ASC
 ;
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(RID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL1a11
 S vos5=30.999
vL1a6 S vos5=$O(^DBTBL(vos4,5,vos3,vos5),1) I vos5=""!("50"']]vos5) G vL1a4
 I '(vos5]]"30.999") G vL1a6
 S vd=$S(vos4=vos2:"",1:vos4)_$C(9)_vos3_$C(9)_$S(vos5=vos2:"",1:vos5)
 S ^DBTMP($J,vOid,1,vos5,vos4)=vd
 G vL1a6
vL1a11 S vos2=""
vL1a12 S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL1a0
 S vos3=""
vL1a14 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL1a12
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a14
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" K ^DBTMP($J,vOid) Q 0
 ;
 S ds=^DBTMP($J,vOid,1,vos2,vos3)
 ;
 Q 1
