 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SQLAG ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SQLAG ; 
 ;
 Q 
 ;
CREATE(AGID) ; Aggregate ID
 ;
  S ER=0
 ;
 N DTL
 N I
 N CMPERR N COLREFS N FRM N GRP N INFO N PSLCODE N RTN
 ;
 N dbtbl22 S dbtbl22=$$vRCgetRecord1^RecordDBTBL22("SYSDEV",AGID,0)
 ;
 I ($G(vobj(dbtbl22,-2))=0) D  K vobj(+$G(dbtbl22)) Q 
 .	;
 .	S ER=1
 .	; Missing aggregate definition for ~p1
 .	S RM=$$^MSG(1302)
 .	Q 
 ;
 I '$$hasRC(AGID) D  K vobj(+$G(dbtbl22)) Q 
 .	;
 .	S ER=1
 .	; Must define one column
 .	S RM=$$^MSG(1304)
 .	Q 
 ;
 S FRM=$ZCONVERT($P(vobj(dbtbl22),$C(124),3),"U") ; Table list
 S GRP=$ZCONVERT($P(vobj(dbtbl22),$C(124),7),"U")
 S INFO("MAIN","GRP")=$$GETCOLS(FRM,GRP,.COLREFS,.RM)
 I '(RM="") S ER=1 K vobj(+$G(dbtbl22)) Q 
 ;
 ; Determine if detail - if main table contains all keys, no separate
 ; detail table, even if dbtbl22.dtl is on
 S DTL=$P(vobj(dbtbl22),$C(124),5)
 I DTL,'(GRP=""),$$ISDETAIL(GRP,$P(vobj(dbtbl22),$C(124),3)) S DTL=0
 ;
 ; If detail, need to get all primary table's keys as well
 I DTL D
 .	;
 .	N KEYS N PRIMKEYS N PRIMTBL
 .	;
 .	S PRIMKEYS=""
 .	S PRIMTBL=$piece(FRM,",",1)
 .	;
 .	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=PRIMTBL,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",PRIMTBL,0,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
 .	;
 .	S KEYS=$P(vop3,$C(124),1)
 .	;
 .	F I=1:1:$L(KEYS,",") D
 ..		;
 ..		N PRIMKEY S PRIMKEY=$piece(KEYS,",",I)
 ..		;
 ..		I '$$isLit^UCGM(PRIMKEY),'((","_GRP_",")[(","_PRIMKEY_",")) D
 ...			;
 ...			S COLREFS(PRIMTBL_"."_PRIMKEY)=""
 ...			S PRIMKEYS=PRIMKEYS_PRIMKEY_","
 ...			Q 
 ..		Q 
 .	;
 .	S INFO("MAIN","DTL")=DTL
 .	S INFO("MAIN","PRIMKEYS")=$E(PRIMKEYS,1,$L(PRIMKEYS)-1)
 . Q 
 ;
 ; Get column data
 N dscol,vos1,vos2,vos3,vos4 S dscol=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D  Q:ER 
 .	;
 .	N N N ptr
 .	N COL N EXP N NEWEXP N tok N WHERE
 .	;
 . N dbtbl22c,vop4 S vop4=$P(dscol,$C(9),3),dbtbl22c=$$vRCgetRecord1Opt^RecordDBTBL22C($P(dscol,$C(9),1),$P(dscol,$C(9),2),vop4,1,"")
 .	;
 .	S INFO("COL",vop4,"DESC")=$P(dbtbl22c,$C(124),1)
 .	S INFO("COL",vop4,"FUN")=$P(dbtbl22c,$C(124),3)
 .	;
 .	S EXP=$$TOKEN^%ZS($P(dbtbl22c,$C(124),4),.tok)
 .	S NEWEXP=""
 .	;
 .	; Get column components of EXP (may be complex, e.g., A+B)
 .	S ptr=0
 .	F  D  Q:((ptr=0)!ER) 
 ..		;
 ..		S COL=$$ATOM^%ZS(EXP,.ptr,"()+-/*#\=_,!&@",tok)
 ..		I ((COL?1A.AN)!(COL?1"%".AN)) D
 ...			;
 ...			S COL=$$GETCOLS(FRM,COL,.COLREFS,.RM)
 ...			I '(RM="") S ER=1
 ...			Q 
 ..		;
 ..		I 'ER S NEWEXP=NEWEXP_COL
 ..		Q 
 .	;
 .	S INFO("COL",vop4,"EXP")=NEWEXP
 .	;
 .	I '($P(dbtbl22c,$C(124),6)="") D
 ..		;
 ..		N lnk S lnk=$$vRCgetRecord0Opt^RecordDBTBL22C("SYSDEV",AGID,$P(dbtbl22c,$C(124),6),0,"")
 ..		;
 ..		S WHERE=$P(lnk,$C(124),9)_" "_$P(lnk,$C(124),10)_" "_$P(lnk,$C(124),11)_" "_$P(lnk,$C(124),12)_" "_$P(lnk,$C(124),13)
 ..  Q 
 .	E  S WHERE=$P(dbtbl22c,$C(124),9)_" "_$P(dbtbl22c,$C(124),10)_" "_$P(dbtbl22c,$C(124),11)_" "_$P(dbtbl22c,$C(124),12)_" "_$P(dbtbl22c,$C(124),13)
 .	;
 .	S WHERE=$$vStrTrim(WHERE,0," ")
 .	;
 .	I '(WHERE="") D
 ..		;
 ..		; Locate columns used in where clause
 ..		D WHRCOLS(FRM,WHERE,.COLREFS)
 ..		;
 ..		; Build query code
 ..		D GETQRYS(FRM,WHERE,"COL",vop4,.INFO)
 ..		Q 
 . Q 
 ;
 K:ER vobj(+$G(dbtbl22)) Q:ER 
 ;
 ; Locate columns used in row where clause and build query code
 N dsrow,vos5,vos6,vos7,vos8 S dsrow=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 .	;
 .	N WHERE
 .	;
 . N dbtbl22r,vop5 S vop5=$P(dsrow,$C(9),3),dbtbl22r=$$vRCgetRecord1Opt^RecordDBTBL22R($P(dsrow,$C(9),1),$P(dsrow,$C(9),2),vop5,1,"")
 .	;
 .	S INFO("ROW",vop5,"DESC")=$P(dbtbl22r,$C(124),1)
 .	;
 .	S WHERE=$P(dbtbl22r,$C(124),3)_" "_$P(dbtbl22r,$C(124),4)_" "_$P(dbtbl22r,$C(124),5)_" "_$P(dbtbl22r,$C(124),6)_" "_$P(dbtbl22r,$C(124),7)
 .	S WHERE=$$vStrTrim(WHERE,0," ")
 .	;
 .	; Locate columns used in where clause
 .	D WHRCOLS(FRM,WHERE,.COLREFS)
 .	;
 .	; Build query code
 .	D GETQRYS(FRM,WHERE,"ROW",vop5,.INFO)
 . Q 
 ;
 D BLDCODE(.dbtbl22,.INFO,.COLREFS,.PSLCODE,.RTN)
 ;
 ; Call PSL compiler
 D cmpA2F^UCGM(.PSLCODE,RTN,,,,,.CMPERR,vobj(dbtbl22,-4)_"~Aggregate")
 ;
 I +$get(CMPERR) S ER=1 ; Hard compile errors
 ;
 K vobj(+$G(dbtbl22)) Q 
 ;
BLDCODE(dbtbl22,INFO,COLREFS,PSLCODE,RTN) ; Routine name   /MECH=REF:W
 N vTp
 ;
 N DTL N hasAVGS
 N I N VARCNT
 N AGTBL N AGTBLDTL N CODE N COL N DBTBL22 N GRP N GRPCOL N KEYREF N KEYREFDT
 N N N NEWLIST N SELECT N TAB N TABS N TYPE N VARS N VARSLEN N WHERE
 ;
 S RTN=$P(vobj(dbtbl22),$C(124),4)
 ;
 I (RTN="") D
 .	;
 .	S DBTBL22=""
 .	L +DBTBL22
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vOid S rs=$$vOpen3()
 .	;
 . I '$G(vos1) S RTN="AG010001"
 .	;
 .	E  I $$vFetch3() D
 ..		;
 ..  S RTN=rs
 ..		S RTN="AG01"_$E((10000+$E(RTN,5,8)+1),2,5)
 ..		Q 
 .	;
 .  S $P(vobj(dbtbl22),$C(124),4)=RTN
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22(dbtbl22,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl22,-100) S vobj(dbtbl22,-2)=1 TC:vTp  
 .	;
 .	L -DBTBL22
 . Q 
 ;
 ; Assign variable names to column references and build NEWLIST and SELECT
 I ($P(vobj(dbtbl22),$C(124),6)>0) S NEWLIST("Date")="DATE, "
 S NEWLIST("Number")="I, ROW, "
 S NEWLIST("String")="ROWS, "
 S NEWLIST("Boolean")=""
 ;
 S (COL,SELECT)=""
 F I=1:1 S COL=$order(COLREFS(COL)) Q:(COL="")  D
 .	;
 .	N DI N FID
 .	;
 .	S COLREFS(COL)="v"_I
 .	S VARS(I)=COL
 .	S VARSLEN($L(COL),COL)="v"_I ; For use in replacement
 .	S SELECT=SELECT_COL_","
 .	;
 .	S FID=$piece(COL,".",1)
 .	S DI=$piece(COL,".",2)
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",FID,DI,0,"")
 .	;
 .	I (($P(dbtbl1d,$C(124),9)="N")!($P(dbtbl1d,$C(124),9)="$")!($P(dbtbl1d,$C(124),9)="C")) S TYPE="Number"
 .	E  I ($P(dbtbl1d,$C(124),9)="L") S TYPE="Boolean"
 .	E  I ($P(dbtbl1d,$C(124),9)="D") S TYPE="Date"
 .	E  S TYPE="String"
 .	;
 .	S NEWLIST(TYPE)=$get(NEWLIST(TYPE))_"v"_I_", "
 . Q 
 ;
 S VARCNT=I-1
 ;
 S SELECT=$E(SELECT,1,$L(SELECT)-1)
 ;
 S TAB=$char(9)
 ;
 D addcode(RTN_TAB_"// DQ Aggregate Definition Routine for AGID = "_vobj(dbtbl22,-4))
 D addcode(TAB_"// Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$get(%UID))
 D addcode("")
 D addcode(TAB_"// THIS IS A COMPILED ROUTINE.  Compiled by procedure SQLAG.")
 D addcode("")
 D addcode(TAB_"// Refer to table DBTBL22 for the aggregate definition.")
 D addcode("")
 D addcode("")
 ;
 ; Add scoping, make sure line is not too long
 S TYPE=""
 F  S TYPE=$order(NEWLIST(TYPE)) Q:(TYPE="")  I '(NEWLIST(TYPE)="") D
 .	;
 .	S NEWLIST(TYPE)=$E(NEWLIST(TYPE),1,$L(NEWLIST(TYPE))-2)
 .	;
 .	F  D  Q:(NEWLIST(TYPE)="") 
 ..		;
 ..		D addcode(TAB_"type "_TYPE_" "_$piece(NEWLIST(TYPE),",",1,20))
 ..		S NEWLIST(TYPE)=$piece(NEWLIST(TYPE),",",21,$L(NEWLIST(TYPE)))
 ..		Q 
 .	Q 
 D addcode("")
 ;
 S DTL=$get(INFO("MAIN","DTL"))
 ;
 S AGTBL="DQA"_vobj(dbtbl22,-4)
 I DTL S AGTBLDTL=AGTBL_"DTL"
 E  S AGTBLDTL=""
 ;
 I ($P(vobj(dbtbl22),$C(124),6)=1) D addcode(TAB_"set DATE = %CurrentDate")
 I ($P(vobj(dbtbl22),$C(124),6)=2) D addcode(TAB_"set DATE = %SystemDate")
 ;
 I ($P(vobj(dbtbl22),$C(124),6)>0) D addcode("")
 ;
 ; Remove any existing data
 I DTL D  ; Detail table
 .	;
 .	S CODE="do Db.fastDelete("""_AGTBLDTL
 .	I ($P(vobj(dbtbl22),$C(124),6)>0) S CODE=CODE_""", ""DATE=:DATE"""
 .	S CODE=CODE_")"
 .	D addcode(TAB_CODE)
 .	Q 
 S CODE="do Db.fastDelete("""_AGTBL_""""
 I ($P(vobj(dbtbl22),$C(124),6)>0) S CODE=CODE_", ""DATE=:DATE"""
 S CODE=CODE_")"
 D addcode(TAB_CODE)
 ;
 D addcode("")
 ;
 ; Get main WHERE clause for result set
 S WHERE=$P(vobj(dbtbl22),$C(124),9)_" "_$P(vobj(dbtbl22),$C(124),10)_" "_$P(vobj(dbtbl22),$C(124),11)_" "_$P(vobj(dbtbl22),$C(124),12)_" "_$P(vobj(dbtbl22),$C(124),13)
 S WHERE=$$vStrTrim(WHERE,0," ")
 ;
 ; Select data
 D addcode(TAB_"type ResultSet rs = Db.select("""_SELECT_""", """_$P(vobj(dbtbl22),$C(124),3)_""", """_WHERE_""")")
 D addcode("")
 ;
 D addcode(TAB_"while rs.next() do {")
 D addcode("")
 ;
 ; Set variables
 F I=1:1:VARCNT D addcode(TAB_TAB_"set v"_I_" = rs.getCol("""_VARS(I)_""")")
 D addcode("")
 ;
 D addcode(TAB_TAB_"// Execute row level queries")
 D addcode(TAB_TAB_"set ROWS = """"")
 ;
 ; Execute row queries to determine which rows are selected
 S N=""
 F  S N=$order(INFO("ROW",N)) Q:(N="")  D
 .	;
 .	N QN
 .	N QUERY
 .	;
 .	S (QN,QUERY)=""
 .	F  S QN=$order(INFO("ROW",N,"QRY",QN)) Q:(QN="")  S QUERY=QUERY_INFO("ROW",N,"QRY",QN)_", "
 .	S QUERY=$E(QUERY,1,$L(QUERY)-2)
 .	;
 .	S CODE=""
 .	I '(QUERY="") D
 ..		;
 ..		; Replace column references with variables
 ..		S QUERY=$$REPLVAR(QUERY,.VARSLEN)
 ..		;
 ..		S CODE="if "_QUERY_" "
 ..		Q 
 .	S CODE=CODE_"set ROWS = ROWS_"_N_"_"","""
 .	D addcode("")
 .	D addcode(TAB_TAB_"// Row "_N_" - "_INFO("ROW",N,"DESC"))
 .	D addcode(TAB_TAB_CODE)
 .	Q 
 ;
 D addcode("")
 ;
 ; Build key references for AG tables
 S KEYREF=""
 I ($P(vobj(dbtbl22),$C(124),6)>0) S KEYREF="DATE=:DATE,"
 S KEYREF=KEYREF_"ROW=:ROW,"
 F I=1:1 S GRPCOL=$piece(INFO("MAIN","GRP"),",",I) Q:(GRPCOL="")  D
 .	;
 .	S KEYREF=KEYREF_$piece(GRPCOL,".",2)_"=:"_COLREFS(GRPCOL)_","
 .	Q 
 S KEYREF=$E(KEYREF,1,$L(KEYREF)-1)
 ;
 ; Detail table
 I DTL D
 .	;
 .	N PRIMKEYS N PRIMTBL
 .	;
 .	S KEYREFDT=KEYREF_",COL=:COL,"
 .	;
 .	S PRIMTBL=$piece($P(vobj(dbtbl22),$C(124),3),",",1)
 .	S PRIMKEYS=INFO("MAIN","PRIMKEYS")
 .	;
 .	F I=1:1:$L(PRIMKEYS,",") D
 ..		;
 ..		N PRIMKEY S PRIMKEY=$piece(PRIMKEYS,",",I)
 ..		;
 ..		S KEYREFDT=KEYREFDT_PRIMKEY_"=:"_COLREFS(PRIMTBL_"."_PRIMKEY)_","
 ..		Q 
 .	;
 .	S KEYREFDT=$E(KEYREFDT,1,$L(KEYREFDT)-1)
 .	Q 
 ;
 S CODE="for I = 1:1 set ROW = ROWS.piece("","", I) quit:ROW.isNull()  "
 S CODE=CODE_"do {"
 D addcode(TAB_TAB_"for I = 1:1 set ROW = ROWS.piece("","", I) quit:ROW.isNull()  do {")
 ;
 S TABS=TAB_TAB_TAB
 ;
 ; Instantiate the row
 D addcode(TABS_"type Record"_AGTBL_" rec = Db.getRecord("""_AGTBL_""","""_KEYREF_""",1)")
 D addcode("")
 ;
 ; Update each column, for selected row, based on column queries
 S hasAVGS=0
 D addcode(TABS_"// Update columns")
 S N=""
 F  S N=$order(INFO("COL",N)) Q:(N="")  D
 .	;
 .	N QN
 .	N CODE N COLREF N EXP N FUN N QUERY
 .	;
 .	S EXP=INFO("COL",N,"EXP")
 .	S FUN=INFO("COL",N,"FUN")
 .	;
 .	I (FUN="AVG") S hasAVGS=1
 .	;
 .	D addcode("")
 .	D addcode(TABS_"// Column "_N_" - ["_FUN_"] "_EXP_" - "_INFO("COL",N,"DESC"))
 .	;
 .	S (QN,QUERY)=""
 .	F  S QN=$order(INFO("COL",N,"QRY",QN)) Q:(QN="")  S QUERY=QUERY_INFO("COL",N,"QRY",QN)_", "
 .	S QUERY=$E(QUERY,1,$L(QUERY)-2)
 .	;
 .	S CODE=""
 .	I '(QUERY="") D
 ..		;
 ..		; Replace column references with variables
 ..		S QUERY=$$REPLVAR(QUERY,.VARSLEN)
 ..		;
 ..		D addcode(TABS_"if "_QUERY_" do {")
 ..		S TABS=TABS_TAB
 ..		Q 
 .	;
 .	S COLREF=$ZCONVERT(N,"L")
 .	S CODE="set rec."_COLREF_" = rec."_COLREF
 .	;
 .	; Replace expression references with variable names
 .	S EXP=$$REPLVAR(EXP,.VARSLEN)
 .	;
 .	I (FUN="CNT") D addcode(TABS_CODE_" + 1")
 .	I (FUN="SUM") D addcode(TABS_CODE_" + ("_EXP_")")
 .	I ((FUN="MAX")!(FUN="MIN")) D
 ..		;
 ..		N OPER
 ..		;
 ..		D addcode(TABS_"if (rec.getMode() = 0) set rec."_COLREF_" = "_EXP)
 ..		;
 ..		I (FUN="MAX") S OPER=" < "
 ..		E  S OPER=" > "
 ..		;
 ..		D addcode(TABS_"if rec."_COLREF_OPER_EXP_" set rec."_COLREF_" = "_EXP)
 ..		Q 
 .	E  I (FUN="AVG") D
 ..		;
 ..		; Count and sum as go, then do average at end
 ..		D addcode(TABS_"set rec."_COLREF_"cnt = rec."_COLREF_"cnt + 1")
 ..		D addcode(TABS_"set rec."_COLREF_"sum = rec."_COLREF_"sum + ("_EXP_")")
 ..		Q 
 .	;
 .	I DTL D
 ..		;
 ..		N COLNUM
 ..		N KREF
 ..		;
 ..		S COLNUM=$$NUMCOL(N)
 ..		;
 ..		; Move literal into reference
 ..		S KREF=$$vStrRep(KEYREFDT,"COL=:COL","COL="_COLNUM,0,0,"")
 ..		;
 ..		D addcode("")
 ..		D addcode(TABS_"// Save detail")
 ..		D addcode(TABS_"type Record"_AGTBLDTL_" recdtl"_COLNUM_" = Db.getRecord("""_AGTBLDTL_""","""_KREF_""",1)")
 ..		D addcode("")
 ..		D addcode(TABS_"do recdtl"_COLNUM_".bypassSave()")
 ..		Q 
 .	;
 .	I '(QUERY="") D
 ..		;
 ..		S TABS=$E(TABS,1,$L(TABS)-1)
 ..		D addcode(TABS_"}")
 ..		Q 
 .	Q 
 ;
 D addcode("")
 D addcode(TABS_"do rec.bypassSave()")
 ;
 S TABS=TAB_TAB
 ;
 D addcode(TABS_"}")
 D addcode("")
 ;
 ; If averages, need to calculate them from cnt and sum.  Loop through
 ; every row and update the columns that are averages
 I hasAVGS D
 .	;
 .	N CODE N N
 .	;
 .	D addcode(TABS_"// Calculate averages")
 .	;
 .	S CODE="type DbSet dsavg = Db.selectDbSet("""_AGTBL_""""
 .	;
 .	I ($P(vobj(dbtbl22),$C(124),6)>0) S CODE=CODE_", ""DATE=:DATE"""
 .	;
 .	S CODE=CODE_")"
 .	;
 .	D addcode(TABS_CODE)
 .	D addcode("")
 .	D addcode(TABS_"while dsavg.next() do {")
 .	D addcode("")
 .	D addcode(TABS_TAB_"type Record"_AGTBL_" rec = dsavg.getRecord("""_AGTBL_""")")
 .	;
 .	S N=""
 .	F  S N=$order(INFO("COL",N)) Q:(N="")  I (INFO("COL",N,"FUN")="AVG") D
 ..		;
 ..		N COLREF N COLREFC N COLREFS
 ..		;
 ..		S COLREF=$ZCONVERT(N,"L")
 ..		S COLREFC=COLREF_"cnt"
 ..		S COLREFS=COLREF_"sum"
 ..		;
 ..		; Leave average null if there is no count
 ..		D addcode("")
 ..		D addcode(TABS_TAB_"// Column "_N)
 ..		D addcode(TABS_TAB_"if (rec."_COLREFC_" <> 0) set rec."_COLREF_" = (rec."_COLREFS_" / rec."_COLREFC_").roundDec(5)")
 ..		Q 
 .	;
 .	D addcode("")
 .	D addcode(TABS_TAB_"do rec.bypassSave()")
 .	;
 .	D addcode(TABS_"}")
 .	D addcode("")
 .	Q 
 ;
 D addcode(TAB_"}")
 D addcode("")
 D addcode(TAB_"quit")
 ;
 Q 
 ;
GETCOLS(TABLES,COLLIST,COLREFS,RM) ; Error message [*]  /MECH=REF:W
 ;
 N I N J
 N COL N REF N RETURN N TABLE
 ;
 S (RETURN,RM)=""
 ;
 I (COLLIST="") Q ""
 ;
 S COLLIST=$ZCONVERT(COLLIST,"U")
 ;
 F I=1:1:$L(COLLIST,",") D  Q:'(RM="") 
 .	;
 .	S COL=$piece(COLLIST,",",I)
 .	;
 .	I (COL[".") D  ; Includes table name
 ..		;
 ..		S TABLE=$piece(COL,".",1)
 ..		S COL=$piece(COL,".",2)
 ..		; Invalid table value ~p1
 ..		I '((","_TABLES_",")[(","_TABLE_",")) S RM=$$^MSG(1485,TABLE)
 ..		; Invalid column name - ~p1
 ..		I '($D(^DBTBL("SYSDEV",1,TABLE,9,COL))#2) S RM=$$^MSG(1286,TABLE_"."_COL)
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		N HIT S HIT=0
 ..		;
 ..		F J=1:1:$L(TABLES,",") D  Q:HIT 
 ...			;
 ...			S TABLE=$piece(TABLES,",",J)
 ...			;
 ...			I ($D(^DBTBL("SYSDEV",1,TABLE,9,COL))#2) S HIT=1
 ...			Q 
 ..		; Invalid column name - ~p1
 ..		I 'HIT S RM=$$^MSG(1286,COL)
 ..		Q 
 .	;
 .	Q:'(RM="")  ; Error
 .	;
 .	S REF=TABLE_"."_COL
 .	S RETURN=RETURN_REF_","
 .	S COLREFS(REF)=""
 .	Q 
 ;
 Q $E(RETURN,1,$L(RETURN)-1)
 ;
WHRCOLS(TABLES,WHERE,COLREFS) ; Column reference list /MECH=REFAFF:W
 ;
 N I N N
 N COL N TABLE N whr
 ;
 D ^SQLQ(WHERE,TABLES,.whr)
 S N=""
 F  S N=$order(whr(N)) Q:(N="")  D
 .	;
 .	F I=1:1:$L(whr(N),$char(1)) D
 ..		;
 ..		S COL=$piece(whr(N),$char(1),I)
 ..		; Don't care about RM here, since will only add if valid column
 ..		I COL?1A.AN1".".E S COL=$$GETCOLS(TABLES,COL,.COLREFS)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
GETQRYS(TABLES,WHERE,TYPE,ID,INFO) ; INFO array  /MECH=REFAFF:W
 ;
 N I N N
 N INPUT N PSLQRY N TBLOBJS
 ;
 S INPUT("FROM")=TABLES
 S INPUT("WHERE")=WHERE
 ;
 ; Build table object reference for use with ^UCQRYBLD
 S TBLOBJS=""
 F I=1:1:$L(TABLES,",") D
 .	;
 .	N TABLE S TABLE=$piece(TABLES,",",I)
 .	;
 .	S TBLOBJS=TBLOBJS_TABLE_"="_$ZCONVERT(TABLE,"L")_","
 .	Q 
 ;
 S TBLOBJS=$E(TBLOBJS,1,$L(TBLOBJS)-1)
 ;
 D ^UCQRYBLD(.INPUT,TBLOBJS,,,.PSLQRY)
 ;
 S N=""
 F  S N=$order(PSLQRY(N)) Q:(N="")  S INFO(TYPE,ID,"QRY",N)=PSLQRY(N)
 ;
 Q 
 ;
REPLVAR(DATA,VARSLEN) ; Variable/column x-ref by length /MECH=REFARR:R
 ;
 N LEN
 ;
 S LEN=""
 F  S LEN=$order(VARSLEN(LEN),-1) Q:(LEN="")  D
 .	;
 .	N COL S COL=""
 .	;
 .	F  S COL=$order(VARSLEN(LEN,COL)) Q:(COL="")  D
 ..		;
 ..		S DATA=$$vStrRep(DATA,COL,VARSLEN(LEN,COL),0,1,"")
 ..		Q 
 .	Q 
 ;
 Q DATA
 ;
DQBLD(AGID,DDLOUT) ; DDL output file [*] /MECH=REF:W
 N vTp
 ;
  S ER=0
 ;
 N DTL
 N I N KEYCNT
 N ACCKEYS N FRM N GRP N KEY N MATDTBL N MATTBL
 ;
 S DDLOUT=""
 ;
 I '$$hasRC(AGID) D  Q 
 .	;
 .	S ER=1
 .	; Must define one column
 .	S RM=$$^MSG(1304)
 .	Q 
 ;
 N dbtbl22 S dbtbl22=$$vRCgetRecord0Opt^RecordDBTBL22("SYSDEV",AGID,0,"")
 ;
 ; Delete old definition(s)
 D DELMAT(AGID)
 ;
 S KEYCNT=0
 ;
 I ($P(dbtbl22,$C(124),6)>0) D
 .	;
 .	S KEYCNT=KEYCNT+1
 .	S KEY(1)="DATE||D|10"
 .	;
 .	; Calendar date
 .	I ($P(dbtbl22,$C(124),6)=1) S $piece(KEY(1),"|",2)=$$^MSG(1311)
 .	; System date
 .	E  S $piece(KEY(KEYCNT),"|",2)=$$^MSG(1313)
 .	Q 
 ;
 S KEYCNT=KEYCNT+1
 S KEY(KEYCNT)="ROW|Row|N|4"
 ;
 S GRP=$P(dbtbl22,$C(124),7)
 S FRM=$P(dbtbl22,$C(124),3)
 ;
 I '(GRP="") F I=1:1:$L(GRP,",") D  Q:ER 
 .	;
 .	N J
 .	N COL N KEYINFO
 .	;
 .	S KEYINFO=""
 .	S COL=$piece(GRP,",",I)
 .	;
 .	F J=1:1:$L(FRM,",") D  Q:'(KEYINFO="") 
 ..		;
 ..		N TABLE
 ..		;
 ..		S TABLE=$piece(FRM,",",J)
 ..		;
 ..		N dbtbl1d,vop1 S dbtbl1d=$$vRCgetRecord1Opt^RecordDBTBL1D("SYSDEV",TABLE,COL,0,.vop1)
 ..		;
 ..		I ($G(vop1)=1) S KEYINFO=COL_"|"_$P(dbtbl1d,$C(124),10)_"|"_$P(dbtbl1d,$C(124),9)_"|"_$P(dbtbl1d,$C(124),2)
 ..  Q 
 .	;
 .	I (KEYINFO="") D
 ..		;
 ..		S ER=1
 ..		; Invalid column name - ~p1
 ..		S RM=$$^MSG(1286,COL)
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		S KEYCNT=KEYCNT+1
 ..		S KEY(KEYCNT)=KEYINFO
 ..		Q 
 .	Q 
 ;
 Q:ER 
 ;
 S MATTBL="DQA"_AGID
 ;
 TS (vobj):transactionid="CS"
 ;
 D DBTBL1(AGID,MATTBL,.KEY,"Aggregate for AGID "_AGID,10,"DQA")
 ;
 ; Insert columns from DBTBL22C
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen4()
 ;
 F  Q:'$$vFetch4()  D
 .	;
 . N dbtbl22c,vop2 S vop2=$P(ds,$C(9),3),dbtbl22c=$$vRCgetRecord1Opt^RecordDBTBL22C($P(ds,$C(9),1),$P(ds,$C(9),2),vop2,1,"")
 .	;
 .	N dbtbl1d S dbtbl1d=$$vcdmNew^RecordDBTBL1D() S vobj(dbtbl1d,-3)="SYSDEV" S vobj(dbtbl1d,-4)=MATTBL S vobj(dbtbl1d,-5)=vop2
 .	;
 .	I $P(dbtbl22c,$C(124),3)="SUM" D
 ..		;
 ..	  S $P(vobj(dbtbl1d),$C(124),2)=18
 ..	  S $P(vobj(dbtbl1d),$C(124),9)="$"
 ..	  S $P(vobj(dbtbl1d),$C(124),14)=2
 ..		Q 
 .	E  I $P(dbtbl22c,$C(124),3)="CNT" D
 ..		;
 ..	  S $P(vobj(dbtbl1d),$C(124),2)=6
 ..	  S $P(vobj(dbtbl1d),$C(124),9)="N"
 ..	  S $P(vobj(dbtbl1d),$C(124),14)=""
 ..		Q 
 .	E  I $P(dbtbl22c,$C(124),3)="AVG" D
 ..		;
 ..	  S $P(vobj(dbtbl1d),$C(124),2)=18
 ..	  S $P(vobj(dbtbl1d),$C(124),9)="N"
 ..	  S $P(vobj(dbtbl1d),$C(124),14)="5"
 ..		Q 
 .	E  D
 ..		;
 ..	  S $P(vobj(dbtbl1d),$C(124),2)=12
 ..	  S $P(vobj(dbtbl1d),$C(124),9)="N"
 ..	  S $P(vobj(dbtbl1d),$C(124),14)=""
 ..		Q 
 .	;
 .  S $P(vobj(dbtbl1d),$C(124),10)=$P(dbtbl22c,$C(124),1)_" ("_$P(dbtbl22c,$C(124),3)_")"
 .  S:'$D(vobj(dbtbl1d,-100,"0*","NOD")) vobj(dbtbl1d,-100,"0*","NOD")="T001"_$P(vobj(dbtbl1d),$C(124),1),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),1)=$$NUMCOL(vop2)
 .  S:'$D(vobj(dbtbl1d,-100,"0*","POS")) vobj(dbtbl1d,-100,"0*","POS")="N021"_$P(vobj(dbtbl1d),$C(124),21),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),21)=1
 .  S $P(vobj(dbtbl1d),$C(124),22)=$$RHD($P(vobj(dbtbl1d),$C(124),10),$P(vobj(dbtbl1d),$C(124),2))
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 TC:vTp  
 .	;
 .	; For average, need to gather count and total to calculate AVG at end
 .	I $P(dbtbl22c,$C(124),3)="AVG" D
 ..		;
 ..		N dbtbl1d S dbtbl1d=$$vcdmNew^RecordDBTBL1D() S vobj(dbtbl1d,-3)="SYSDEV" S vobj(dbtbl1d,-4)=MATTBL
 ..		;
 ..	  S vobj(dbtbl1d,-5)=vop2_"CNT"
 ..	  S $P(vobj(dbtbl1d),$C(124),2)=6
 ..	  S $P(vobj(dbtbl1d),$C(124),9)="N"
 ..	  S $P(vobj(dbtbl1d),$C(124),14)=""
 ..	  S $P(vobj(dbtbl1d),$C(124),10)="CNT for average for column "_vop2
 ..	  S:'$D(vobj(dbtbl1d,-100,"0*","NOD")) vobj(dbtbl1d,-100,"0*","NOD")="T001"_$P(vobj(dbtbl1d),$C(124),1),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),1)=$$NUMCOL(vop2)
 ..	  S:'$D(vobj(dbtbl1d,-100,"0*","POS")) vobj(dbtbl1d,-100,"0*","POS")="N021"_$P(vobj(dbtbl1d),$C(124),21),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),21)=2
 ..	  S $P(vobj(dbtbl1d),$C(124),22)="CNT"
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 TC:vTp  
 ..		;
 ..		S vobj(dbtbl1d,-2)=0
 ..	  S vobj(dbtbl1d,-5)=vop2_"SUM"
 ..	  S $P(vobj(dbtbl1d),$C(124),2)=18
 ..	  S $P(vobj(dbtbl1d),$C(124),9)="$"
 ..	  S $P(vobj(dbtbl1d),$C(124),14)=2
 ..	  S $P(vobj(dbtbl1d),$C(124),10)="SUM for average for column "_vop2
 ..	  S:'$D(vobj(dbtbl1d,-100,"0*","POS")) vobj(dbtbl1d,-100,"0*","POS")="N021"_$P(vobj(dbtbl1d),$C(124),21),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),21)=3
 ..	  S $P(vobj(dbtbl1d),$C(124),22)="SUM"
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 TC:vTp  
 ..		K vobj(+$G(dbtbl1d)) Q 
 . K vobj(+$G(dbtbl1d)) Q 
 ;
 S DTL=$P(dbtbl22,$C(124),5)
 I DTL,'(GRP=""),$$ISDETAIL(GRP,FRM) S DTL=0
 ;
 ; Build detail table
 I DTL D
 .	;
 .	N KEYS N PRIMTBL
 .	;
 .	S MATDTBL="DQA"_AGID_"DTL"
 .	;
 .	S KEYCNT=KEYCNT+1
 .	S KEY(KEYCNT)="COL|Column Number|N|4"
 .	;
 .	; Add keys from primary table that aren't in GRP
 .	S PRIMTBL=$piece(FRM,",",1)
 .	;
 .	N dbtbl1,vop3,vop4,vop5 S vop3="SYSDEV",vop4=PRIMTBL,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",PRIMTBL,0,"")
 .	 S vop5=$G(^DBTBL(vop3,1,vop4,16))
 .	;
 .	S KEYS=$P(vop5,$C(124),1)
 .	;
 .	F I=1:1:$L(KEYS,",") D
 ..		;
 ..		N PRIMKEY S PRIMKEY=$piece(KEYS,",",I)
 ..		;
 ..		I '$$isLit^UCGM(PRIMKEY),'((","_GRP_",")[(","_PRIMKEY_",")) D
 ...			;
 ...			N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,PRIMTBL,9,PRIMKEY))
 ...			;
 ...			S KEYCNT=KEYCNT+1
 ...			S KEY(KEYCNT)=PRIMKEY_"|"_$P(dbtbl1d,$C(124),10)_"|"_$P(dbtbl1d,$C(124),9)_"|"_$P(dbtbl1d,$C(124),2)
 ...   Q 
 ..		Q 
 .	;
 .	D DBTBL1(AGID,MATDTBL,.KEY,"Aggregate detail for AGID "_AGID,1,"DQA")
 . Q 
 ;
  TC:$TL 
 ;
 I ($get(%DB)="") S %DB=$$SCAU^%TRNLNM("DB")
 ;
 ; Generate DDL code
 I '((%DB="")!(%DB="GTM")) D
 .	;
 .	N OUTFILE
 .	;
 .	S OUTFILE=$$FILE^%TRNLNM(MATTBL_".DDL","SCAU$SPOOL")
 .	;
 .	D DDL^SQLUTIL(MATTBL,OUTFILE,1)
 .	;
 .	S DDLOUT=OUTFILE
 .	;
 .	I DTL D
 ..		;
 ..		S OUTFILE=$$FILE^%TRNLNM(MATDTBL_".DDL","SCAU$SPOOL")
 ..		;
 ..		D DDL^SQLUTIL(MATDTBL,OUTFILE,1)
 ..		;
 ..		S DDLOUT=DDLOUT_" & "_OUTFILE
 ..		Q 
 .	Q 
 ;
 Q 
 ;
DBTBL1(AGID,TABLE,KEY,DESC,RECTYP,GLOBAL) ; Global
 N vTp
 ;
 N I N KEYCNT
 N ACCKEYS
 ;
 S KEYCNT=$order(KEY(""),-1)
 ;
 S ACCKEYS=""""_AGID_""""
 F I=1:1:KEYCNT S ACCKEYS=ACCKEYS_","_$piece(KEY(I),"|",1)
 ;
 N dbtbl1 S dbtbl1=$$vcdmNew^RecordDBTBL1() S vobj(dbtbl1,-3)="SYSDEV" S vobj(dbtbl1,-4)=TABLE
  S vobj(dbtbl1,16)=""
  S vobj(dbtbl1,10)=""
  S vobj(dbtbl1,13)=""
  S vobj(dbtbl1,0)=""
  S vobj(dbtbl1,100)=""
 ;
  S vobj(dbtbl1,-100,"0*")="" S $P(vobj(dbtbl1),$C(124),1)=DESC
  S vobj(dbtbl1,-100,16)="" S $P(vobj(dbtbl1,16),$C(124),1)=ACCKEYS
  S vobj(dbtbl1,-100,10)="" S $P(vobj(dbtbl1,10),$C(124),1)=124
  S vobj(dbtbl1,-100,13)="" S $P(vobj(dbtbl1,13),$C(124),1)=TABLE
  S vobj(dbtbl1,-100,10)="" S $P(vobj(dbtbl1,10),$C(124),12)=1
  S:'$D(vobj(dbtbl1,-100,0,"GLOBAL")) vobj(dbtbl1,-100,0,"GLOBAL")="T001"_$P(vobj(dbtbl1,0),$C(124),1),vobj(dbtbl1,-100,0)="" S $P(vobj(dbtbl1,0),$C(124),1)=GLOBAL
  S vobj(dbtbl1,-100,100)="" S $P(vobj(dbtbl1,100),$C(124),2)=RECTYP
  S vobj(dbtbl1,-100,10)="" S $P(vobj(dbtbl1,10),$C(124),2)="PBS"
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 TC:vTp  
 ;
 ; Update the access key records
 F I=1:1:KEYCNT D
 .	;
 .	N COL
 .	;
 .	S COL=$piece(KEY(I),"|",1)
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0^RecordDBTBL1D("SYSDEV",TABLE,COL,0)
 .	;
 .  S $P(vobj(dbtbl1d),$C(124),10)=$piece(KEY(I),"|",2)
 .  S $P(vobj(dbtbl1d),$C(124),9)=$piece(KEY(I),"|",3)
 .  S $P(vobj(dbtbl1d),$C(124),2)=$piece(KEY(I),"|",4)
 .  S $P(vobj(dbtbl1d),$C(124),22)=$$RHD($P(vobj(dbtbl1d),$C(124),10),$P(vobj(dbtbl1d),$C(124),2))
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 TC:vTp  
 .	K vobj(+$G(dbtbl1d)) Q 
 ;
 K vobj(+$G(dbtbl1)) Q 
 ;
RHD(DES,LEN) ; Length
 ;
 N HALF
 N RHD
 ;
 I ($L(DES)'>LEN) Q DES
 I '(DES[" ") Q DES
 ;
 S HALF=$L(DES)\2
 ;
 I ($E(DES,HALF)=" ") D
 .	;
 .	S RHD=DES
 .	S $E(RHD,HALF)="@"
 .	Q 
 E  I '($E(DES,1,HALF)[" ") S RHD=$piece(DES," ",1)_"@"_$piece(DES," ",2,999)
 E  D
 .	;
 .	N I
 .	;
 .	S RHD=""
 .	;
 .	F I=1:1:HALF D  Q:'(RHD="") 
 ..		;
 ..		I $E(DES,HALF+I)=" " S RHD=$E(DES,1,HALF+I-1)_"@"_$E(DES,HALF+I+1,1048575)
 ..		I $E(DES,HALF-I)=" " S RHD=$E(DES,1,HALF-I-1)_"@"_$E(DES,HALF-I+1,1048575)
 ..		Q 
 .	Q 
 ;
 Q RHD
 ;
ISDETAIL(grp,frm) ; DBTBL22.FRM - table list
 ;
 N NOHIT
 N I
 N KEYS N PRIMTBL
 ;
 S PRIMTBL=$piece(frm,",",1)
 ;
 N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=PRIMTBL,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",PRIMTBL,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,16))
 ;
 S KEYS=$P(vop3,$C(124),1)
 S NOHIT=0
 ;
 F I=1:1:$L(KEYS,",") D  Q:NOHIT 
 .	;
 .	N KEY S KEY=$piece(KEYS,",",I)
 .	;
 .	I '$$isLit^UCGM(KEY),'((","_grp_",")[(","_KEY_",")) S NOHIT=1
 .	Q 
 ;
 Q 'NOHIT
 ;
STRCOL(numcol) ; Column in numeric form
 ;
 N RETURN
 ;
 I (numcol<27) S RETURN=$char((numcol+64))
 E  S RETURN=$char((((numcol-1)\26)+64))_$char((((numcol-1)#26)+65))
 ;
 Q RETURN
 ;
NUMCOL(strcol) ; Column in string form
 ;
 N RETURN
 ;
 I ($L(strcol)=1) S RETURN=$ascii(strcol)-64
 E  S RETURN=(($ascii(strcol)-64)*26)+$ascii(strcol,2)-64
 ;
 Q RETURN
 ;
DELMAT(AGID) ; Aggregate definition ID
 ;
 N FID
 ;
 F FID="DQA"_AGID,"DQA"_AGID_"DTL" D
 .	I ($D(^DBTBL("SYSDEV",1,FID))) D
 ..		D DELETE^SQL(FID)
 ..		D vDbDe1()
 ..		D vDbDe2()
 ..		Q 
 .	Q 
 ;
 Q 
 ;
RUN(AGID) ; Aggregate ID
 ;
 N DQA N RTN
 ;
 N dbtbl22,vop1 S dbtbl22=$$vRCgetRecord1Opt^RecordDBTBL22("SYSDEV",AGID,0,.vop1)
 ;
 I ($G(vop1)=0) D  Q 
 .	;
 .	S ER=1
 .	; Missing aggregate definition for ~p1
 .	S RM=$$^MSG(1302,AGID)
 .	Q 
 ;
 S RTN=$P(dbtbl22,$C(124),4)
 ;
 I (RTN="") D  Q 
 .	;
 .	S ER=1
 .	; Aggregate definition ~p1 not compiled
 .	S RM=$$^MSG(1307,AGID)
 .	Q 
 ;
 L +DQA(AGID):5 ; Prevent concurrent running
 E  D  Q 
 .	;
 .	N ET S ET="RECLOC"
 .	;
 .	D ^UTLERR
 .	Q 
 ;
 S RTN="^"_RTN
 D @RTN
 ;
 L -DQA(AGID)
 ;
 Q 
 ;
hasRC(AGID) ; Aggregate ID
 ;
 N RETURN S RETURN=1
 ;
 N dsrow,vos1,vos2,vos3,vos4 S dsrow=$$vOpen5()
 ;
 I '$G(vos1) S RETURN=0 ; No rows
 ;
 N dscol,vos5,vos6,vos7,vos8 S dscol=$$vOpen6()
 ;
 I '$G(vos5) S RETURN=0 ; No columns
 ;
 Q RETURN
 ;
addcode(LINE) ; New line of code to add
 ;
 S PSLCODE($order(PSLCODE(""),-1)+1)=LINE
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60242^50783^Dan Russell^26730" ; Signature - LTD^TIME^USER^SIZE
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
vDbDe1() ; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen7()
 F  Q:'$$vFetch7()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1D($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1D(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1("SYSDEV",FID,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
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
vOpen1() ; %LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"C",vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dscol="" Q 0
 ;
 S dscol="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; %LIBS,AGID,ROW FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(AGID) I vos7="" G vL2a0
 S vos8=""
vL2a4 S vos8=$O(^DBTBL("SYSDEV",22,vos7,"R",vos8),1) I vos8="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos5=1 D vL2a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S dsrow="" Q 0
 ;
 S dsrow="SYSDEV"_$C(9)_vos7_$C(9)_$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vOpen3() ; RTN FROM DBTBL22 WHERE RTN LIKE 'AG01%' ORDER BY RTN DESC
 ;
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL3a3 S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL3a13
 S vos4=""
vL3a5 S vos4=$O(^DBTBL(vos3,22,vos4),1) I vos4="" G vL3a3
 S vos5=$G(^DBTBL(vos3,22,vos4))
 I '($P(vos5,"|",4)]]("AG0"_$C(48,1114109))) G vL3a5
 I '($P(vos5,"|",4)']]("AG01"_$C(1114109))) G vL3a5
 S vos5=$G(^DBTBL(vos3,22,vos4))
 S vd=$P(vos5,"|",4)
 S vos6=$P(vos5,"|",4) S ^DBTMP($J,vOid,1,vos6,vos3,vos4)=vd
 G vL3a5
vL3a13 S vos2=""
vL3a14 S vos2=$O(^DBTMP($J,vOid,1,vos2),-1) I vos2="" G vL3a0
 S vos3=""
vL3a16 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL3a14
 S vos4=""
vL3a18 S vos4=$O(^DBTMP($J,vOid,1,vos2,vos3,vos4),1) I vos4="" G vL3a16
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a18
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" K ^DBTMP($J,vOid) Q 0
 ;
 S rs=^DBTMP($J,vOid,1,vos2,vos3,vos4)
 ;
 Q 1
 ;
vOpen4() ; %LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"C",vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; %LIBS,AGID,ROW FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"R",vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dsrow="" Q 0
 ;
 S dsrow="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; %LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos5=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos5=0 Q
vL6a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(AGID) I vos7="" G vL6a0
 S vos8=""
vL6a4 S vos8=$O(^DBTBL("SYSDEV",22,vos7,"C",vos8),1) I vos8="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos5=1 D vL6a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S dscol="" Q 0
 ;
 S dscol="SYSDEV"_$C(9)_vos7_$C(9)_$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vOpen7() ; %LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL7a0
 S vos4=""
vL7a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL7a0
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
