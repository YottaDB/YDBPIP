 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDBRT ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;
 ; I18N=QUIT
 ; *******************************************************************
 ; * IMPORTANT NOTE:                                                 *
 ; * According to the rules that apply to PSL compiler upgrades,     *
 ; * the generated M routine associated with this procedure must be  *
 ; * checked into StarTeam and released with the procedure whenever  *
 ; * changes are made to this procedure.  The M routine from the     *
 ; * crtns directory should be used for this purpose.                *
 ; *                                                                 *
 ; * The M routine will be loaded to the mrtns directory during      *
 ; * upgrades and will then be removed from that directory as part   *
 ; * of the upgrade process.  Therefore, other than during an        *
 ; * upgrade an mrtns version of this routine should not exist.      *
 ; *                                                                 *
 ; * Keep these comments as single line to ensure they exist in the  *
 ; * generated M code.                                               *
 ; *******************************************************************
 Q 
 ;
 ; ---------------------------------------------------------------------
rdb(table) ; **** DEPRECATED ****
 I '($D(table)#2) Q $$isRdb^vRuntime()
 Q $$rtIsRdb^UCXDD(table)
 ;
 ; ---------------------------------------------------------------------
rdbColIns(noOverlay,recobj,intCln,nod,dlmStr,value) ; value to assign to column
 ;
 N obj
 ;
 ;  #ACCEPT Date=09/30/2007; Pgm=RussellDS; CR=29295; Group=DEPRECATED
 S obj=$G(recobj)
 ;
 I 'noOverlay,(vobj(obj,-161,nod)[(","_intCln_"=")) S $piece(vobj(obj,-162,nod),dlmStr,$L($piece(vobj(obj,-161,nod),(","_intCln_"=")),",")+1)=value
 E  D
 .	S vobj(obj,-161,nod)=vobj(obj,-161,nod)_","_intCln_"="
 .	S vobj(obj,-162,nod)=vobj(obj,-162,nod)_dlmStr_value
 .	S $piece(vobj(obj,-161,nod),",",1)=vobj(obj,-161,nod)+1
 .	Q 
 Q ""
 ;
 ; ---------------------------------------------------------------------
rdbColUpd(noOverlay,recobj,intCln,nod,dlmStr,value) ; value to assign to column
 ;
 N obj
 ;
 ;  #ACCEPT Date=09/30/2007; Pgm=RussellDS; CR=29295; Group=DEPRECATED
 S obj=$G(recobj)
 ;
 I 'noOverlay,(vobj(obj,-161,nod)[(","_intCln_"=")) S $piece(vobj(obj,-162,nod),dlmStr,$piece(vobj(obj,-161,nod),","_intCln_"=:HV",2)+1)=value
 E  D
 .	N vCc S vCc=+vobj(obj,-161,nod)
 .	;
 .	S vobj(obj,-161,nod)=vobj(obj,-161,nod)_","_intCln_"=:HV"_vCc
 .	S vobj(obj,-162,nod)=vobj(obj,-162,nod)_dlmStr_value
 .	S $piece(vobj(obj,-161,nod),",",1)=vCc+1
 .	Q 
 Q ""
 ;
 ; ---------------------------------------------------------------------
rdbSaveS(recobj,dlmStr,where) ; WHERE clause with host variables (*3)
 ;
 N obj
 N ret
 ;
 ;  #ACCEPT Date=09/30/2007; Pgm=RussellDS; CR=29295; Group=DEPRECATED
 S obj=$G(recobj)
 ;
 Q:(vobj(obj,-161,"0*")'>1)  ; No columns modified
 ;
 ; -152 will not exist if no keys, e.g., CUVAR
 I (vobj(obj,-2)=1) D
 .	;
 .	N vlist S vlist=$piece(vobj(obj,-162,"0*"),dlmStr,2,1048575)_dlmStr_$get(vobj(obj,-152))
 .	;
 .	S ret=$$EXECUTESQL^%DBAPI(0,"UPDATE "_$piece(vobj(obj,-162,"0*"),dlmStr,1)_" SET "_$piece(vobj(obj,-161,"0*"),",",2,1048575)_where,dlmStr,vlist)
 .	Q 
 E  D
 .	;
 .	N i
 .	N cols N HVs
 .	;
 .	S (cols,HVs)=""
 .	;
 .	F i=2:1:$L(vobj(obj,-162,"0*"),dlmStr) S cols=cols_","_$piece($piece(vobj(obj,-161,"0*"),",",i),"=",1) S HVs=HVs_",:HV"_(i-1)
 .	;
 .	S ret=$$EXECUTESQL^%DBAPI(0,"INSERT INTO "_$piece(vobj(obj,-162,"0*"),dlmStr,1)_" ("_$piece(cols,",",2,1048575)_") VALUES ("_$piece(HVs,",",2,1048575)_")",dlmStr,$piece(vobj(obj,-162,"0*"),dlmStr,2,1048575)_dlmStr)
 .	Q 
 ;
 ; Reset
 S vobj(obj,-161,"0*")="1" S vobj(obj,-162,"0*")=$piece(vobj(obj,-162,"0*"),dlmStr)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
rdbSaveC(recobj,dlmStr,where) ; WHERE clause with host variables (*3)
 ;
 N collOrder N obj
 N nod N ret
 ;
 ;  #ACCEPT Date=09/30/2007; Pgm=RussellDS; CR=29295; Group=DEPRECATED
 S obj=$G(recobj)
 ;
 I (vobj(obj,-2)=0) S collOrder=1
 E  S collOrder=-1
 ;
 S nod=""
 F  S nod=$order(vobj(obj,-161,nod),collOrder) Q:(nod="")  D
 .	;
 .	Q:(vobj(obj,-161,nod)'>1)  ; No columns
 .	;
 .	I (nod[",") D
 ..		;
 ..		N nod162 S nod162=vobj(obj,-162,nod)
 ..		N tbl S tbl=$ZPIECE(nod162,dlmStr,1)
 ..		;
 ..		I '($D(vobj(obj,-152))#2) D
 ...			;
 ...			N i
 ...			;
 ...			S vobj(obj,-152)=""
 ...			F i=-3:-1 Q:'($D(vobj(obj,i))#2)  S vobj(obj,-152)=vobj(obj,-152)_vobj(obj,i)_dlmStr
 ...			Q 
 ..		; Remove leading " WHERE" for call to LOBUPDATE
 ..		S ret=$$LOBUPDATE^%DBAPI(0,tbl,$piece($piece(vobj(obj,-161,nod),",",2),"=",1),$E(where,7,1048575),$ZEXTRACT(nod162,$ZLENGTH(tbl)+2,1048575),dlmStr,vobj(obj,-152))
 ..		Q 
 .	E  I (collOrder=-1) D
 ..		;
 ..		N vlist S vlist=$piece(vobj(obj,-162,nod),dlmStr,2,1048575)_dlmStr_vobj(obj,-152)
 ..		;
 ..		S ret=$$EXECUTESQL^%DBAPI(0,"UPDATE "_$piece(vobj(obj,-162,nod),dlmStr,1)_" SET "_$piece(vobj(obj,-161,nod),",",2,1048575)_where,dlmStr,vlist)
 ..		Q 
 .	E  D
 ..		;
 ..		N i
 ..		N cols N HVs
 ..		;
 ..		S (cols,HVs)=""
 ..		;
 ..		F i=2:1:$L(vobj(obj,-162,nod),dlmStr) S cols=cols_","_$piece($piece(vobj(obj,-161,nod),",",i),"=",1) S HVs=HVs_",:HV"_(i-1)
 ..		;
 ..		S ret=$$EXECUTESQL^%DBAPI(0,"INSERT INTO "_$piece(vobj(obj,-162,nod),dlmStr,1)_" ("_$piece(cols,",",2,1048575)_") VALUES ("_$piece(HVs,",",2,1048575)_")",dlmStr,$piece(vobj(obj,-162,nod),dlmStr,2,1048575)_dlmStr)
 ..		Q 
 .	;
 .	; Reset
 .	S vobj(obj,-161,nod)="1" S vobj(obj,-162,nod)=$piece(vobj(obj,-162,nod),dlmStr)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
RsDyRT(select,from,where,orderby,groupby,parlist,selmap) ; identifier map (*5) /MECH=REFARR:W
 N expr N fsn N HAVING N par N tok
 N ER ; exported by TOKEN^%ZS
 ;
 ; Rewrite components with literals removed, and converted to uppercase
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S select=$ZCONVERT($$TOKEN^%ZS(select,.tok,"'"),"U")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S from=$ZCONVERT($$TOKEN^%ZS(from,.tok,"'"),"U")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S where=$ZCONVERT($$TOKEN^%ZS(where,.tok,"'"),"U")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S orderby=$ZCONVERT($$TOKEN^%ZS(orderby,.tok,"'"),"U")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S groupby=$ZCONVERT($$TOKEN^%ZS(groupby,.tok,"'"),"U")
 ;
 ; Split GROUPBY in GROUP BY and HAVING part
 S groupby=$$TOK^SQL(groupby,"HAVING",tok)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I parlist]"" D PARSPAR^%ZS(parlist,.par)
 I $get(par("DQMODE")) S from=$$RsMsDQMD(from)
 ;
 ; Build Symbol Map
 S expr=$$RsMsBld(.selmap,.tok,select,from,where,orderby,groupby,$get(HAVING))
 ;
 ; insert columns (XC) and tables (XT)
 S expr=$$RsMsXI(.selmap,"XC",expr)
 S expr=$$RsMsXI(.selmap,"XT",expr)
 ;
 ; return result with SQL literals back in place
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$UNTOK^%ZS(expr,tok)
 ;
 ; ---------------------------------------------------------------------
RsMsBld(map,sqllit,select,from,where,orderby,groupby,having) ; HAVING-clause (*3)
  ; standard separator
 ;
 N expr N RsMsBld N tail S tail=""
 ;
 ; Ensure we have a symbol number counter
 S map=$get(map,0)
 ;
 I ($translate(from,"()","  ")[" JOIN ")!(from[" AS ") D
 .	S from=$$RsMsCls(.RsMsBld,.map,.sqllit,3,from,"")
 .	Q 
 E  S (RsMsBld("FROM"),from)=$translate(from," "_$char(9))
 ;
 S expr=$piece(select," ")
 I (expr="DISTINCT")!(expr="ALL") S select=$E(select,$L(expr)+2,1048575)
 E  S expr=""
 ;
 I select="*" S select=$$RsSelAll(RsMsBld("FROM"))
 ;
 S select=$$RsMsSel(.RsMsBld,.map,.sqllit,1,select,"")
 I expr'="" S RsMsBld("SELECT")=expr_" "_select
 E  S RsMsBld("SELECT")=select
 ;
 ; Handle WHERE-clause: do not yet add keyword WHERE, it may still be modified
 I where'="" S where=$$RsMsCls(.RsMsBld,.map,.sqllit,2,where)
 ;
 ; Handle GROUPBY-clause:
 I '(groupby="") S tail=" GROUP BY "_$$RsMsSel(.RsMsBld,.map,.sqllit,0,groupby,"")
 ;
 ; Handle HAVING-clause:
 I '(having="") S tail=tail_" HAVING "_$$RsMsCls(.RsMsBld,.map,.sqllit,2,having)
 ;
 ; Handle ORDERBY-clause
 I '(orderby="") S tail=tail_" ORDER BY "_$$RsMsSel(.RsMsBld,.map,.sqllit,0,orderby,"ASC,DESC")
 ;
 I from=RsMsBld("FROM") D  ; NOTE: do{} needed: call modifies from
 .	D RsMsWtList(.RsMsBld,.map,.sqllit,.from,.where)
 .	Q 
 E  D RsMsWtJoin(.RsMsBld,.map)
 ;
 I '(where="") S tail=" WHERE "_where_tail
 ;
 S map("SELNAM")=RsMsBld("SELNAM")
 S map("SELTYP")=RsMsBld("SELTYP")
 ;
 Q "SELECT "_RsMsBld("SELECT")_" FROM "_from_tail
 ;
 ; ---------------------------------------------------------------------
RsMsCls(bld,map,sqllit,mode,clause,kwds) ; (*6)
  ; standard delimiter
  ; quote char for computeds
 ;
 N atom ; current atom being examined
 N between S between=0 ; 1 indicates AND in between-predicate
 N delim ; accepted delimiters
 N dt S dt="" ; composite data type
 N dtmode
 N ER
 N origtbl S origtbl="" ; original table name in alias
 N null ; individual atoms of current null-pred
 N prevatom ; previous atom
 N ptr ; current position in clause
 N ptrnot ; position of NOT in clause
 N seltyp S seltyp="" ; column type in SELECT
 ;
 I mode=0 S delim="," ; and use supplied kwds
 E  D
 .	I mode<3 S delim="*/+-|,()" S kwds="NULL,COUNT,MIN,MAX,AVG,SUM,UPPER,LOWER,SUBSTR"
 .	I mode=2 S delim=delim_"<=>" S kwds=kwds_",IN,IS,OR,AND,LIKE,NOT,BETWEEN,EXISTS,ANY,ALL"
 .	I mode=3 S delim=",()" S kwds="AS,JOIN,LEFT,RIGHT,KEY,CROSS,NATURAL,USING,OUTER,INNER,FULL,UNION"
 .	Q 
 I mode=3 S bld("FROM")=""
 ;
 ; main decomposition loop =============================================
 S ptr=0 S atom="" S null=0 S null(0)=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S prevatom=atom S atom=$$ATOM^%ZS(clause,.ptr,delim,,1) D  Q:'ptr 
 .	I $get(ER) S ptr=0 Q 
 .	;
 .	S null=null+1 S null(null)=atom
 .	;
 .	I atom?.N.1"."1.N1"E" D
 ..		S ptr=ptr+1 ; advance to "+" or "-"
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S atom=atom_$E(clause,ptr)_$$ATOM^%ZS(clause,.ptr,delim,,1)
 ..		Q 
 .	;
 .	I prevatom?1"NOT".P,delim[atom,"<=>"[atom S atom=prevatom_atom Q 
 .	I prevatom?1"NOT".P,prevatom'="NOT" D
 ..		N opr
 ..		N pos
 ..		I $L(prevatom)>5 Q  ; incorrect anyway
 ..		S opr=$E(prevatom,4,1048575)
 ..		I $L(opr)=1 S opr=" "_opr
 ..		S pos=$F(" = < ><><=>=",opr)
 ..		S opr=$E("<>>=<= = > <",pos-2,pos-1)
 ..		;
 ..		D RsMsRpl(.clause,opr_atom,ptrnot-3,.ptr)
 ..		;
 ..		K null(null),null(null-1)
 ..		S null=null-$L(prevatom)+2 ; null()="NOT"
 ..		F pos=1:1:$L(opr) S null(null)=$E(opr,pos) S null=null+1
 ..		S null(null)=atom
 ..		Q 
 .	;
 .	; keywords that need context information ======================
 .	I atom="NOT" S ptrnot=ptr Q 
 .	;
 .	I atom="AS",mode=3 S origtbl=prevatom Q 
 .	;
 .	I (atom="OR")!(atom="AND") D  Q 
 ..		I between S between=0 Q 
 ..		D RsMsNull(.null,sqllit,.clause,.ptr)
 ..		S dt=""
 ..		Q 
 .	I atom="BETWEEN" S between=1 Q 
 .	;
 .	I atom="NULL" D  Q 
 ..		I null<3 Q  ; ro room for COLUMN IS
 ..		N comppred
 ..		N diff
 ..		I null(null-2)="IS" S comppred=" <> 0" S diff=3
 ..		E  S comppred=" = 0" S diff=2
 ..		I (null-diff)'=$piece(null(0),"|") Q 
 ..		N colnull S colnull=null($piece(null(0),"|"))
 ..		;
 ..		I $E($piece(colnull,"|",3),3)=0 Q 
 ..		D RsMsRpl(.clause,$char(9)_$piece(colnull,"|")_$char(9)_comppred,$piece(null(0),"|",2),.ptr)
 ..		Q 
 .	;
 .	I atom="ON",mode=3 D  Q  ; ON in from
 ..		N sptr S sptr=ptr N num S num=0
 ..		N satm
 ..		N found S found=0
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		F  S satm=$$ATOM^%ZS(clause,.sptr,"+*-/|,()<=>",,1) D  Q:found 
 ...			I sptr=0 S found=1 Q 
 ...			I (","_kwds_",")[(","_satm_",") S found=1 Q 
 ...			I satm="(" S num=num+1 Q 
 ...			I satm=")" S num=num-1 Q 
 ...			I satm=",",num=0 S found=1 Q 
 ...			Q 
 ..		I sptr=0 S sptr=$L(clause) S satm=""
 ..		N searcond S searcond=$E(clause,ptr+1,sptr-$L(satm))
 ..		S num=$L(searcond)
 ..		S searcond=$$RsMsCls(.bld,.map,.sqllit,2,searcond,"")
 ..		;
 ..		; replace original searchcond by returned and update ptr
 ..		S clause=$E(clause,1,ptr)_searcond_$E(clause,ptr+num+1,1048575)
 ..		S ptr=ptr+$L(searcond)
 ..		Q 
 .	;
 .	; =============================================================
 .	I (","_kwds_",")[(","_atom_",") Q  ; keyword
 .	;
 .	; =============================================================
 .	I atom="(" D  ; maybe subquery
 ..		N len S len=0
 ..		N nest S nest=$E(clause,ptr+1,1048575)
 ..		F  D  Q:len=0 
 ...			S len=$F(nest,")",len)
 ...			Q:len=0 
 ...			Q:$L($E(nest,1,len-1),"(")'=$L($E(nest,1,len-1),")") 
 ...			S nest=$E(nest,1,len-1)
 ...			S len=0
 ...			Q 
 ..		; save $L(nest) to update ptr, since $L(nest) may change
 ..		S len=$L(nest) S nest=$$vStrTrim(nest,0," ")
 ..		I $E(nest,1,7)'="SELECT " Q  ; not subquery
 ..		;
 ..		N ER
 ..		N FROM N GROUP N HAVING N RM N SELECT N subquery N WHERE
 ..		;
 ..		S SELECT=$$TOK^SQL($E(nest,8,1048575),"FROM,WHERE,GROUP,HAVING",sqllit)
 ..		I $E($get(GROUP),1,3)="BY " S GROUP=$E(GROUP,4,1048575)
 ..		S subquery=$$RsMsBld(.map,.sqllit,SELECT,$get(FROM),$get(WHERE),"",$get(GROUP),$get(HAVING))
 ..		;
 ..		; replace original subquery by returned and update ptr
 ..		S clause=$E(clause,1,ptr)_subquery_$E(clause,ptr+len+1,1048575)
 ..		S ptr=ptr+$L(subquery)
 ..		Q 
 .	;
 .	; =============================================================
 .	I atom="*",prevatom="(",mode=1 D  ; COUNT(*)
 ..		N tbl S tbl=$piece(bld("FROM"),",")
 ..		N sym S sym=$$RsMsIns(.bld,.map,"XT",tbl)
 ..		S tbl=$piece($piece(map("XT",tbl),"|",2),",")
 ..		S bld("FROM",tbl)=""
 ..		Q 
 .	;
 .	I atom="USERID" D
 ..		D RsMsSub(":%UID","USERID",.clause,.ptr)
 ..		S atom=":%UID"
 ..		Q 
 .	;
 .	I atom="SYSDAT" D
 ..		D RsMsSub(":%CurrentDate","SYSDAT",.clause,.ptr)
 ..		S atom=":%CurrentDate"
 ..		Q 
 .	;
 .	I delim[atom S dtmode=0 ; all delimiters
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	E  I $$isNum^UCGM($translate(atom,"+","-")) S dtmode=1
 .	;
 .	; =============================================================
 .	E  I $E(atom,1)=$char(0) S dtmode=2 ; string literal
 .	;
 .	; =============================================================
 .	E  I $E(atom,1)=":" D  ; hostvar
 ..		S atom=$E(atom,2,1048575)
 ..		N sym S sym=$$RsMsIns(.bld,.map,"XV",atom,$E(dt,1))
 ..		D RsMsSub($C(9)_sym_$C(9),atom,.clause,.ptr)
 ..		S null(null)=map("XV",sym)
 ..		S dtmode=3
 ..		Q 
 .	; =============================================================
 .	E  I mode=3 D  ; table in FROM
 ..		I '(origtbl="") D
 ...			S bld("FROM")=$piece(bld("FROM"),",",1,$L(bld("FROM"),",")-1)
 ...			S bld("ALIAS",atom)=origtbl
 ...			S origtbl=""
 ...			Q 
 ..		I '(bld("FROM")="") S bld("FROM")=bld("FROM")_","
 ..		S bld("FROM")=bld("FROM")_atom
 ..		S dtmode=5
 ..		;
 ..		D RsMsSub($C(9)_$$RsMsIns(.bld,.map,"XT",atom)_$C(9),atom,.clause,.ptr)
 ..		Q 
 .	; =============================================================
 .	E  D  ; column spec
 ..		N qcn S qcn=$$RsMsQcn(.bld,atom)
 ..		;
 ..		I $E(qcn,1,2)="_." S dtmode=5 Q 
 ..		;
 ..		; =====================================================
 ..		N sym S sym=$C(9)_$$RsMsIns(.bld,.map,"XC",qcn)_$C(9)
 ..		;
 ..		S null(null)=map("XC",qcn)
 ..		S dtmode=4
 ..		;
 ..		N ic S ic=$$vStrPce(map("XC",qcn),"|",2,2,$C(9))
 ..		I ic["(" D
 ...			;     #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ...			S ic=$$TOKEN^%ZS($piece(ic,$C(9),2),.sqllit)
 ...			S ic=$$RsMsCls(.bld,.map,.sqllit,1,ic,"")
 ...			;
 ...			 N V1,V2 S V1=$piece(qcn,"."),V2=$piece(qcn,".",2) I ($D(^STBL("CLBKCOL",V1,V2))#2),mode'=0 D
 ....				S ic=$E(ic,1,$L(ic)-1)
 ....				I '($E(ic,$L(ic))="(") S ic=ic_","
 ....				S ic=ic_":"_$C(9)_$$RsMsIns(.bld,.map,"XV","%%$S($G(%TOKEN)'="""":0_%TOKEN,1:1_$J)","T0")_$C(9)_")"
 ....				Q 
 ...			;
 ...			D RsMsSub(ic,atom,.clause,.ptr)
 ...			S null(0)=null_"|"_(ptr-$L(ic))
 ...			Q 
 ..		; =====================================================
 ..		E  D  ; just a column
 ...			D RsMsSub(sym,atom,.clause,.ptr)
 ...			S null(0)=null_"|"_(ptr-$L(sym))
 ...			Q 
 ..		;
 ..		I mode=1 D  ; SELECT clause
 ...			I (seltyp="") S seltyp=$E($$vStrPce(map("XC",qcn),"|",3,3,$C(9)),1,2)
 ...			E  S seltyp="T0"
 ...			Q 
 ..		I ic'["(",qcn["." D
 ...			S sym=$$RsMsIns(.bld,.map,"XT",$piece(qcn,"."))
 ...			; It's save to use map(,).piece() without TAB
 ...			S bld("FROM",$piece($piece(map("XC",qcn),"|",2),"."))=""
 ...			Q 
 ..		Q  ; end column specification
 .	S dt=$$RsMsDT(.map,.sqllit,dtmode,dt,.null,.clause,.ptr)
 .	Q  ; end main decomposition loop
 ;
 D RsMsNull(.null,sqllit,.clause,.ptr)
 ;
 I mode=1 D
 .	I seltyp="" S seltyp=$E(dt,1)_"0" I seltyp="0" S seltyp="T0"
 .	S bld("CLSTYP")=seltyp
 .	Q 
 ;
 Q clause
 ;
 ; ---------------------------------------------------------------------
RsMsDQMD(from) ; (*1)
 N count S count=$S((from=""):0,1:$L(from,","))
 I count=1 Q from
 I ($translate(from,"()","  ")[" JOIN ")!(from[" AS ") Q from
 ;
 N elm S elm=2 ; table name iterator for table being added
 N key ; key column of table being added
 N inner ; table being added
 N nk ; key ordinal position in table being added
 N on ; on-clause under construction
 N outer ; name of outer table in on construction
 N pk ; primary keys of table being added
 N RsMsDQMD S RsMsDQMD=$piece(from,",",1) ; function return value
 N td ; PSLTable instance for table being added
 ;
 ; strip quotes from table names
 I from["""" S from=$translate(from,"""")
 ;
 F elm=2:1:count D
 .	S inner=$piece(from,",",elm)
 .	S td=$$getPslTbl^UCXDD(inner,0)
 .	;
 .	; child-tables are INNER JOINed all others OUTER JOINed
 .	I ($P(td,"|",7)="") S RsMsDQMD=RsMsDQMD_" LEFT JOIN "_inner
 .	E  S RsMsDQMD=RsMsDQMD_" INNER JOIN "_inner
 .	S pk=$P(td,"|",3)
 .	;
 .	I (pk="") Q  ; CUVAR etc: no ON-clause
 .	S on=""
 .	F nk=1:1:$S((pk=""):0,1:$L(pk,",")) D
 ..		S key=$piece(pk,",",nk)
 ..		;
 ..		N no ; iterator
 ..		F no=1:1:elm-1 D
 ...			S outer=$piece(from,",",no)
 ...			I '$$isColumn^UCXDD(outer,key) Q 
 ...			I '(on="") S on=on_" AND "
 ...			S on=on_outer_"."_key_"="_inner_"."_key
 ...			S no=elm ; done when match found
 ...			Q 
 ..		Q 
 .	I (on="") S $ZE="0,"_$ZPOS_","_"%PSL-E-SQLJOINFAIL,,"_RsMsDQMD,$EC=",U1001,"
 .	S RsMsDQMD=RsMsDQMD_" ON ("_on_")"
 .	Q 
 Q RsMsDQMD
 ;
 ; ---------------------------------------------------------------------
RsMsDT(map,sqllit,mode,dt,pred,clause,ptr) ; char pointer (*7) /MECH=REF:RW
 N dt2 N dtdq ; datatype of next, datatype of first
 ;
 I mode=5 Q dt ; table, no-op
 ;
 N dtl S dtl=$L(dt)
 N next S next=pred(pred)
 ;
 I mode=0 D  Q dt
 .	I dtl'=1 Q 
 .	I "+*-/|"[next S dt=dt_next Q 
 .	I "<=>,"[next S dt=dt_"~"
 .	Q 
 ;
 I mode=1 S dt2="N"
 E  I mode=2 S dt2="T"
 E  I mode=3 S dt2="v"
 E  S dt2=$E($piece(next,"|",3),1)
 ;
 I dtl=1 S dt=dt_"~"
 ;
 I dt["~" D  Q dt ; already complete
 .	I mode=2 D RsMsDTL(.sqllit,$E(dt,1),pred,.pred,.clause,.ptr)
 .	Q 
 ;
 I dt="" Q dt2 ; first datatype is always OK
 ;
 S dtdq=$E(dt,1)
 I mode=4 D
 .	I dtdq="D",dt2="D" S dt="N" Q 
 .	I dtdq="C",dt2="C" S dt="N" Q 
 .	I dt2="N","CD"[dtdq S dt=dtdq Q  ; Date op Number = Date
 .	S dt=dt2 ; others: column type
 .	Q 
 E  I mode=3 D
 .	S dt=dtdq
 .	Q 
 E  I mode=2 D
 .	D RsMsDTL(.sqllit,dtdq,pred,.pred,.clause,.ptr)
 .	I "CDL"'[dtdq S dt=dtdq Q  ; keep previous datatype
 .	S dt="N"
 .	Q 
 E  D
 .	I "CD"[dtdq S dt="N" Q  ; Date binop Number = Date
 .	S dt=dtdq
 .	Q 
 ;
 Q dt
 ;
 ; ---------------------------------------------------------------------
RsMsDTL(sqllit,dtdq,sub,pred,clause,ptr) ; (*1)
 I "CDLU"'[dtdq Q  ; no conversion needed
 ;
 N atom S atom=pred(sub)
 N pos S pos=$piece(atom,$char(0),2)
 N lit S lit=$piece(sqllit,$char(1),pos)
 N val
 ;
 I lit="''" Q  ; don't touch empty string
 ;
 I dtdq="U",lit?.CNPU Q  ; no need to convert if no lowercase
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I dtdq="U" S val=$$TOKEN^%ZS($ZCONVERT(lit,"U"),.sqllit,"'")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  S val=$$INT^%ZM($$QSUB^%ZS(lit,"'"),dtdq)
 ;
 I ptr>0 S pos=ptr
 E  S pos=$L(clause)
 N len S len=$L(atom)
 S clause=$E(clause,1,pos-len)_val_$E(clause,pos+1,1048575)
 I ptr>0 S ptr=ptr-len+$L(val)
 S pred(sub)=val
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsEx(context) ; Text for Error.context
 N rErr S rErr=""
 S $P(rErr,",",3)="%PSL-E-SQLFAIL"
 S $P(rErr,",",5)=$translate(context,$char(10)_","," ~")
 S $ZE=rErr,$EC=",U1001,"
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsIns(bld,map,typ,int,dtd) ; (*5)   /NOREQ
  ; database environment variable
 ;
  ; standard separator
  ; quote char for computeds
 ;
 N ext N xtr
 N mmd S mmd=$get(map("MD"),1)
 ;
 I ($D(map(typ,int))#2) Q $piece(map(typ,int),"|") ; existing ident
 S map=map+1 ; new identifier
 ;
 I typ="XV" S ext=int S int=map S xtr=$get(dtd)
 ;
 I typ="XT" D
 .	S ext=int
 .	I mmd=1 D MAP^DBMAP(%DB,.ext)
 .	S xtr=""
 .	Q 
 I typ="XC" D
 .	I int="SYSDAT",mmd=1 S ext="CURRENT_DATE" S xtr="D00" Q 
 .	I int["""" S int=$$QSUB^%ZS(int,"""") ; quoted name
 .	N ER
 .	N extc N extt N intt N RM
 .	S intt=$piece(int,".")
 .	S extc=$piece(int,".",2)
 .	S extt=$get(bld("ALIAS",intt),intt)
 .	;
 .	I '$$isColumn^UCXDD(extt,extc) S xtr="T00"
 .	E  D
 ..		N coldef S coldef=$$getPslCln^UCXDD(extt,extc)
 ..		S xtr=$P(coldef,"|",6)_(+$P(coldef,"|",8))_(+$P(coldef,"|",9))
 ..		Q 
 .	I mmd=1 D MAP^DBMAP(%DB,.extt,.extc)
 .	;
 .	I extc["(" S ext=$C(9)_extc_$C(9) ; enclose in "quotes"
 .	E  S ext=extt_"."_extc
 .	Q 
 S map(typ,int)=map_"|"_ext_"|"_xtr
 Q map
 ;
 ; ---------------------------------------------------------------------
RsMsNull(null,sqllit,clause,ptr) ; current pointer  /MECH=REF:RW
 ;
 D
 .	N at ; subscript of empty string
 .	N pos ; subscript of column
 .	N isnull S isnull=""
 .	;
 .	S pos=$piece(null(0),"|")
 .	I pos<1 Q  ; no column
 .	I null-pos<2 Q  ; no room for = ''
 .	;
 .	S at=pos+1
 .	I null(at)="=" S at=at+1 S isnull=" IS NULL"
 .	E  I null(at)="<",null(at+1)=">" S at=at+2 S isnull=" IS NOT NULL"
 .	;
 .	I (isnull="") Q  ; incorrect compop
 .	I $E(null(at),1)'=$char(0) Q  ; atom not strlit
 .	N lit S lit=$piece(null(at),$char(0),2)
 .	I $piece(sqllit,$char(1),lit)'="''" Q  ; atom not ''
 .	;
 .	N atom S atom=null(pos)
 .	I $E($piece(atom,"|",3),3)=1 D
 ..		I isnull["NOT" S isnull=" <> 0"
 ..		E  S isnull=" = 0"
 ..		Q 
 .	;
 .	S isnull=$char(9)_$piece(atom,"|")_$char(9)_isnull
 .	;
 .	F pos=at+1:1:null S isnull=isnull_" "_null(pos)
 .	D RsMsRpl(.clause,isnull,$piece(null(0),"|",2),.ptr)
 .	Q 
 K null
 S null=0 S null(0)=0
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsQcn(bld,cln) ; (*2)
 I cln="SYSDAT" Q "SYSDAT"
 ;
 I cln["""" S cln=$$QSUB^%ZS(cln,"""")
 ;
 I cln["." Q cln
 ;
 N alias N fromlist S fromlist=bld("FROM") N tbl
 N ord
 ;
 F ord=1:1:$L(fromlist,",") D  Q:cln["." 
 .	S alias=$piece(fromlist,",",ord)
 .	S tbl=$get(bld("ALIAS",alias),alias)
 .	;
 .	I $$isColumn^UCXDD(tbl,cln) S cln=alias_"."_cln
 .	Q 
 ; if no match found, insert an arbitrary "table name"
 I cln'["." S cln="_."_cln
 Q cln
 ;
 ; ---------------------------------------------------------------------
RsMsQID1(DQtbl) ; DQ Table name
 ;
 N rec,vop1,vop2,vop3 S vop1="SYSDEV",vop2=DQtbl,rec=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",DQtbl,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,14))
 N clause S clause=$P(vop3,$C(124),1)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I clause["""" S clause=$$QSWP^%ZS(clause,"""","'")
 I $translate(clause,"()","  ")[" OR " S clause="("_clause_")"
 Q clause
 ;
 ; ---------------------------------------------------------------------
RsMsRpl(cls,val,old,cur) ; new vlaue of ptr (*4) /MECH=REF:RW
 N pos
 I cur>0 S pos=cur
 E  S pos=$L(cls)
 S cls=$E(cls,1,old)_val_$E(cls,pos+1,1048575)
 I cur>0 S cur=old+$L(val)
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsSel(bld,map,sqllit,mode,clause,kwds) ; (*6)
  ; standard delimiter
  ; quote char for computeds
 ;
 N elem ; current element being examined
 N ic ; internal column or expression
 N qcn ; qualified column name
 N RsMsSel S RsMsSel="" ; return value
 N selalias ; SELECT column name alias (if computed)
 N selnam S selnam="" ; column name in SELECT
 N selnum ; column ordinal position in SELECT
 N selprim ; value returned by $$RsMsCls()
 N seltyp ; value to be appended to SELTYP
 ;
 I mode=1,$$vStrTrim(clause,0," ")="*" D  Q "*"
 .	N ne N ni N sym
 .	N frme N tble N tbli
 .	F ni=1:1:$L(bld("FROM"),",") D
 ..		S tbli=$piece(bld("FROM"),",",ni)
 ..		S sym=$$RsMsIns(.bld,.map,"XT",tbli)
 ..		S frme=$piece(map("XT",tbli),"|",2)
 ..		F ne=1:1:$L(frme,",") S bld("FROM",$piece(frme,",",ne))=""
 ..		Q 
 .	S bld("SELECT","*")="" S bld("SELNAM")="" S bld("SELTYP")=""
 .	Q 
 ;
 ; initializations for mode=1 (only)
 I mode=1 S (bld("SELNAM"),bld("SELTYP"))="" S kwds=$get(kwds)
 ;
 ; main decomposition loop =============================================
 F selnum=1:1 S elem=$$RsMsSelE(.clause) Q:elem=""  D
 .	;
 .	S selnam=$piece(elem," ")
 .	I $translate(selnam,"""%","AA")?1A.ANP D
 ..		S qcn=$$RsMsQcn(.bld,selnam)
 ..		;set selalias = selnam_ "_"
 ..		;if selalias["." set selalias = selalias.piece(".", selalias.length("."))
 ..		S selalias=$$RESWRD^DBMAP($piece(selnam,".",$L(selnam,".")))_"_"
 ..		Q 
 .	E  D
 ..		S qcn="_._"
 ..		S selalias=""
 ..		Q 
 .	;
 .	I mode=0 S selprim=selnam
 .	E  S selprim=elem
 .	;
 .	S selprim=$$RsMsCls(.bld,.map,.sqllit,mode,selprim,"")
 .	;
 .	I ($D(map("XC",qcn))#2) S ic=$$vStrPce(map("XC",qcn),"|",2,2,$C(9))
 .	E  S ic=""
 .	;
 .	I mode=0 D
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I '($D(map("XC",qcn))#2) D RsMsEx(qcn_" in ORDER BY/GROUP BY "_$$UNTOK^%ZS(elem))
 ..		;
 ..		N kwd S kwd=$translate($E(elem,$L(selnam)+2,1048575)," ")
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I '(kwd="") S selprim=selprim_" "_kwd I '((","_kwds_",")[(","_kwd_",")) D RsMsEx(kwd_" in ORDER BY/GROUP BY "_$$UNTOK^%ZS(elem))
 ..		;
 ..		I ic["(" S selprim=selalias_" "_kwd Q 
 ..		;
 ..		I '($D(bld("SELECT",qcn))#2) D
 ...			I ($D(bld("SELECT","*"))#2) Q  ; SELECT *
 ...			;
 ...			;     #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-10-23;PGM=Frans S.C. Witte
 ...			 N V1,V2 S V1=$piece(qcn,"."),V2=$piece(qcn,".",2) I ($D(^STBL("CLBKCOL",V1,V2))#2) D RsMsEx("invalid callback-computed "_qcn_" in ORDER BY/GROUP BY "_$$UNTOK^%ZS(elem))
 ...			N sym S sym=$C(9)_$piece(map("XC",qcn),"|")_$C(9)
 ...			S bld("SELECT",qcn)=elem ; only once
 ...			S bld("SELECT")=bld("SELECT")_","_sym
 ...			S bld("SELNAM")=bld("SELNAM")_","_$piece(qcn,".",2)
 ...			S bld("SELTYP")=bld("SELTYP")_$E($$vStrPce(map("XC",qcn),"|",3,3,$C(9)),1,2)
 ...			Q 
 ..		Q 
 .	;
 .	I mode=1 D
 ..		I ($D(map("XC",qcn))#2) D
 ...			S seltyp=$E($$vStrPce(map("XC",qcn),"|",3,3,$C(9)),1,2)
 ...			S bld("SELECT",qcn)=elem
 ...			I ic["(" S selprim=selprim_" "_selalias
 ...			Q 
 ..		E  D
 ...			S selnam=$ZCONVERT($translate(elem,"*/+-|():""% "_$char(0),"_______"),"U")
 ...			I (selnam="") S selnam=selnum_"_"
 ...			S seltyp=bld("CLSTYP")
 ...			Q 
 ..		I selnum>1 S bld("SELNAM")=bld("SELNAM")_","
 ..		S bld("SELTYP")=bld("SELTYP")_seltyp S bld("SELNAM")=bld("SELNAM")_selnam
 ..		Q 
 .	;
 .	I (selprim="") Q 
 .	;
 .	I selnum>1 S RsMsSel=RsMsSel_","
 .	S RsMsSel=RsMsSel_selprim
 .	K bld("CLSTYP")
 .	Q 
 ;
 Q RsMsSel
 ;
 ; ---------------------------------------------------------------------
RsMsSelE(str) ; String to break down  /MECH=REFNAM:RW
 N pos S pos=1
 N found S found=0
 N sel
 F  Q:'('found)  D
 .	S pos=$F(str,",",pos)
 .	I pos=0 S pos=$L(str)+2 S found=1
 .	S sel=$E(str,1,pos-2)
 .	I $L(sel,"(")=$L(sel,")") S found=1
 .	Q 
 S str=$E(str,pos,1048575)
 Q $$vStrTrim(sel,0," ")
 ;
 ; ---------------------------------------------------------------------
RsMsSub(sym,org,str,pos) ; position of last char of org /MECH=REF:RW
 N lst
 I pos>0 S lst=pos
 E  S lst=$L(str)
 S str=$E(str,1,lst-$L(org))_sym_$E(str,lst+1,1048575)
 I pos>0 S pos=pos-$L(org)+$L(sym)
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsWtChild(child,bld,map) ; 
 ;
 I '($D(bld("FROM",$P(child,"|",7)))#2) Q ""
 ;
 N ci N cn S cn=$P(child,"|",1) N qcn S qcn=cn_"." N tbl S tbl=$P(child,"|",7)
 N cnt S cnt=0
 N pk S pk=$P(child,"|",3)
 N mx S mx=$S((pk=""):0,1:$L(pk,","))
 ;
 F  S qcn=$order(map("XC",qcn)) Q:(cnt>mx)!($piece(qcn,".")'=cn)!(qcn="")  D
 .	S ci=$piece(map("XC",qcn),"|",2)
 .	I $piece(ci,".")=tbl S cnt=cnt+1 I '((","_pk_",")[(","_$piece(ci,".",2)_",")) S cnt=mx+1
 .	Q 
 ;
 Q $$RsMsWtWhr($S(cnt>mx:tbl,1:"?"),pk)
 ;
 ; ---------------------------------------------------------------------
RsMsWtJoin(bld,map) ; 
 ;
 N dqtbl S dqtbl="" ; from-list element (DQ table name)
 N elm ; from-list iterator
 N fromlist S fromlist=bld("FROM")
 ;
 F elm=1:1:$S((fromlist=""):0,1:$L(fromlist,",")) D
 .	S dqtbl=$piece(fromlist,",",elm)
 .	I '($D(bld("FROM",dqtbl))#2) D
 ..		I '($D(map("XT",dqtbl))#2) Q 
 ..		N itl S itl=$piece(map("XT",dqtbl),"|",2)
 ..		;
 ..		I itl'["," Q 
 ..		;
 ..		N icn S icn="" ; internal column name
 ..		N frm S frm="" ; from clause
 ..		N it ; internal table name
 ..		N itc ; internal table iterator
 ..		N qcn ; qualified column name
 ..		N sel S sel="" ; select clause
 ..		N td S td=$$getPslTbl^UCXDD(dqtbl,0)
 ..		N pk S pk=$P(td,"|",3)
 ..		N whr S whr="" ; where clause
 ..		N whrkey S whrkey=$$RsMsWtChild(td,.bld,.map)
 ..		;
 ..		F itc=1:1:$S((itl=""):0,1:$L(itl,",")) D
 ...			S it=$piece(itl,",",itc)
 ...			;
 ...			; ignore if not used
 ...			I '($D(bld("FROM",it))#2) Q 
 ...			;
 ...			; ignore parent table if only key columns
 ...			I it=$P(td,"|",7),$E(whrkey,1)="?" Q 
 ...			;
 ...			I '(frm="") S frm=frm_","
 ...			S frm=frm_it
 ...			;
 ...			I it=$P(td,"|",7) Q 
 ...			;
 ...			; parent not included: first table sets whrkey
 ...			I (whrkey="") S whrkey=$$RsMsWtWhr(it,pk) Q 
 ...			;
 ...			; only key columns from parent
 ...			I $E(whrkey,1)="?" D  Q 
 ....				S whrkey=$$vStrRep(whrkey,"?",it,0,0,"")
 ....				N cn
 ....				N cc
 ....				F cc=1:1:$S((pk=""):0,1:$L(pk,",")) D
 .....					S cn=$piece(pk,",",cc)
 .....					I ($D(map("XC",dqtbl_"."_cn))#2) S $piece(map("XC",dqtbl_"."_cn),"|",2)=it_"."_cn
 .....					Q 
 ....				Q 
 ...			;
 ...			; subsequent wide table
 ...			I '(whr="") S whr=whr_" AND "
 ...			S whr=whr_$$vStrRep(whrkey,"!",it,0,0,"")
 ...			Q  ; end for all internal tables
 ..		;
 ..		I (frm[$P(td,"|",7)) D
 ...			I '(whr="") S whr=whr_" AND "
 ...			S whr=whr_$$RsMsQID1(dqtbl)
 ...			Q 
 ..		;
 ..		I frm'[",",(whr="") S $piece(map("XT",dqtbl),"|",2)=frm Q 
 ..		;
 ..		S qcn=dqtbl_"."
 ..		;
 ..		F  S qcn=$order(map("XC",qcn)) Q:$piece(qcn,".")'=dqtbl  D
 ...			S icn=$$vStrPce(map("XC",qcn),"|",2,2,$C(9))
 ...			;
 ...			I icn[$C(9) Q 
 ...			;
 ...			I '(sel="") S sel=sel_","
 ...			I ((","_pk_",")[(","_$piece(qcn,".",2)_",")) S sel=sel_icn
 ...			E  S sel=sel_$piece(icn,".",2)
 ...			;
 ...			S $piece(map("XC",qcn),"|",2)=dqtbl_"."_$piece(icn,".",2)
 ...			Q 
 ..		;
 ..		S frm="(SELECT "_sel_" FROM "_frm_" WHERE "_whr_")"
 ..		S frm=frm_" "_dqtbl
 ..		S $piece(map("XT",dqtbl),"|",2)=frm
 ..		Q  ; end if requires remap
 .	Q  ; end for each table in bld("FROM")
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsWtList(bld,map,sqllit,from,where) ; pre-processed where-clause /MECH=REF:RW
 ;
 N table S table="" ; from-list element
 N elm ; from-list iterator
 ;
 N fromlist S fromlist=from
 S from=""
 ;
 F elm=1:1:$S((fromlist=""):0,1:$L(fromlist,",")) D
 .	N joinwhr S joinwhr="" ; additional where-clause
 .	I '(from="") S from=from_","
 .	S table=$piece(fromlist,",",elm)
 .	I '($D(bld("FROM",table))#2) D
 ..		I '($D(map("XT",table))#2) Q 
 ..		N wtl S wtl=$piece(map("XT",table),"|",2)
 ..		;
 ..		I wtl'["," S table=wtl Q 
 ..		;
 ..		N dqt S dqt=table ; DQ table name
 ..		N wt ; wide table name
 ..		N wtc ; wide table iterator
 ..		N td S td=$$getPslTbl^UCXDD(dqt,0) ; child table
 ..		N pk S pk=$P(td,"|",3)
 ..		N whrkey S whrkey=$$RsMsWtChild(td,.bld,.map)
 ..		S table="" ;  list of wide tables
 ..		;
 ..		F wtc=1:1:$S((wtl=""):0,1:$L(wtl,",")) D
 ...			S wt=$piece(wtl,",",wtc)
 ...			;
 ...			; ignore if not used
 ...			I '($D(bld("FROM",wt))#2) Q 
 ...			;
 ...			; ignore parent if only key columns
 ...			I wt=$P(td,"|",7),$E(whrkey,1)="?" Q 
 ...			;
 ...			I wt=$P(td,"|",7),(","_table_",")[(","_$P(td,"|",7)_",") Q 
 ...			;
 ...			I '(table="") S table=table_","
 ...			S table=table_wt
 ...			;
 ...			I wt=$P(td,"|",7) Q 
 ...			;
 ...			; parent not included at all.
 ...			I (whrkey="") S whrkey=$$RsMsWtWhr(wt,pk) Q 
 ...			;
 ...			; Only key columns from parent
 ...			I $E(whrkey,1)="?" D  Q 
 ....				S whrkey=$$vStrRep(whrkey,"?",wt,0,0,"")
 ....				N cn
 ....				N cc
 ....				F cc=1:1:$S((pk=""):0,1:$L(pk,",")) D
 .....					S cn=$piece(pk,",",cc)
 .....					I ($D(map("XC",dqt_"."_cn))#2) S $piece(map("XC",dqt_"."_cn),"|",2)=wt_"."_cn
 .....					Q 
 ....				Q  ; end if whrkey starts with '?'
 ...			;
 ...			I '(joinwhr="") S joinwhr=joinwhr_" AND "
 ...			S joinwhr=joinwhr_$$vStrRep(whrkey,"!",wt,0,0,"")
 ...			Q  ; end for each wide table
 ..		;
 ..		I (table="") S table=$P(td,"|",7)
 ..		I table=$P(td,"|",7) D
 ...			N origFrom S origFrom=bld("FROM")
 ...			S bld("FROM")=table
 ...			S joinwhr=$$RsMsQID1($piece(fromlist,",",elm))
 ...			S joinwhr=$$RsMsCls(.bld,.map,.sqllit,2,joinwhr,"")
 ...			S bld("FROM")=origFrom
 ...			Q 
 ..		Q  ; end if table not in bld("FROM",*)
 .	;
 .	S from=from_table
 .	I '(joinwhr="") D
 ..		I (where="") S where=joinwhr Q 
 ..		I $translate(where,"()","  ")[" OR " S where="("_where_") AND "_joinwhr Q 
 ..		S where=where_" AND "_joinwhr
 ..		Q 
 .	Q  ; end for each table
 Q 
 ;
 ; ---------------------------------------------------------------------
RsMsWtWhr(left,pk) ; 
 N cnt
 N whr S whr=left_"."_$piece(pk,",",1)_" = !."_$piece(pk,",",1)
 F cnt=2:1:$S((pk=""):0,1:$L(pk,",")) S whr=whr_" AND "_left_"."_$piece(pk,",",cnt)_" = !."_$piece(pk,",",cnt)
 Q whr
 ;
 ; ---------------------------------------------------------------------
RsMsXI(map,typ,str) ; source string
 ;
 N extrep N intrep N sub
 N le N ls N pos
 ;
 S intrep=""
 F  S intrep=$order(map(typ,intrep)) Q:intrep=""  D
 .	S sub=$C(9)_$piece(map(typ,intrep),"|")_$C(9)
 .	S ls=$L(sub)
 .	S extrep=$$vStrPce(map(typ,intrep),"|",2,2,$C(9))
 .	Q:extrep[$C(9) 
 .	S le=$L(extrep)
 .	F pos=$F(str,sub):0 Q:'pos  D
 ..		S str=$E(str,1,pos-ls-1)_extrep_$E(str,pos,1048575)
 ..		S pos=$F(str,sub,pos-ls+le)
 ..		Q 
 .	Q 
 Q str
 ;
 ; ---------------------------------------------------------------------
RsMsXV(map,str,bExt,dlm) ; host value delimiter (*4) /NOREQ
 N dtd N extrep N hv N intrep N syskwd N sub N vallist
 N dec
 ;
 ; If no hostvars, then quit code to assign the empty string.
 I $order(map("XV",""))="" Q """"""
 ;
 S (intrep,vallist)=""
 F  S intrep=$order(map("XV",intrep)) Q:intrep=""  D
 .	S sub=$char(9)_$piece(map("XV",intrep),"|")_$char(9)
 .	S extrep=$piece(map("XV",intrep),"|",2)
 .	S dtd=$piece(map("XV",intrep),"|",3)
 .	S dec=$E(dtd,2)
 .	S dtd=$E(dtd,1)
 .	I (dtd="") S dtd="T" ; unknown
 .	I dtd="v" S dtd="T" ; another case of unknown
 .	;
 .	I $E(extrep,1)="%" D
 ..		S hv="V"_$piece(map("XV",intrep),"|")_"DBRT"
 ..		I $E(extrep,2)="%" S extrep=$E(extrep,3,1048575) Q 
 ..		N kwdRow S kwdRow=$$kwdRow^UCDTAUTL(extrep,.syskwd)
 ..		N newrep S newrep=$P(kwdRow,$C(124),2)
 ..		I (newrep="") Q  ; not a system keyword
 ..		S dtd=$translate($E($P(kwdRow,$C(124),4),1),"BS","LT")
 ..		S extrep=newrep
 ..		Q 
 .	E  S hv=extrep_"_"
 .	;
 .	I $get(bExt),"$CDLNU"[dtd D
 ..		S extrep="$$INT^%ZM("_extrep_","""_dtd_""""
 ..		I "$N"[dtd,'(dec="") S extrep=extrep_","_dec
 ..		S extrep=extrep_")"
 ..		Q 
 .	;
 .	I "CDLN$"[dtd S extrep="+"_extrep
 .	; else  set extrep = "$S(" _ extrep _ "'[""'"":""'""_" _ extrep _ "_""'"",1:$$QADD^%ZS(" _ extrep _ ",""'""))"
 .	I '(vallist="") S vallist=vallist_"_"
 .	S vallist=vallist_extrep_"_$C("_$get(dlm,9)_")"
 .	S str=$$vStrRep(str,sub,hv,1,0,"")
 .	Q 
 Q vallist
 ;
 ; ---------------------------------------------------------------------
RsRdb(from) ; FROM-clause (*1)
 I '$$isRdb^vRuntime Q 0
 ;
 I ($translate(from,"()","  ")[" JOIN ")!(from[" AS ") D
 .	N map S map=0
 .	N bld
 .	N lit
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N ignore S ignore=$$TOKEN^%ZS(from,.lit,"'")
 .	S ignore=$$RsMsCls(.bld,.map,.lit,3,from,"")
 .	S from=bld("FROM")
 .	Q 
 E  S from=$translate(from," "_$char(9))
 Q $$rtIsRdb^UCXDD(from)
 ;
 ; ---------------------------------------------------------------------
RsSelAll(from) ; from-list (*1)
 N n
 N selAll S selAll=$$COLLIST^DBSDD($piece(from,",",1),0,1,0)
 ;
 F n=2:1:$S((from=""):0,1:$L(from,",")) S selAll=selAll_","_$$COLLIST^DBSDD($piece(from,",",n),0,1,0)
 Q selAll
 ;
 ; ---------------------------------------------------------------------
RsSelList(select) ; SELECT-clause (*1)
 N expr N tok
 I $E(select,1)'="""" S expr=select
 E  S expr=$$QSUB^%ZS(select,"""")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$SQL^%ZS(expr,.tok)
 I expr["""" S expr=$$QSUB^%ZS(expr,"""") ; Strip quotes from names
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$UNTOK^%ZS(expr,.tok)
 I $E(expr,1,9)="DISTINCT " S expr=$E(expr,10,1048575)
 I $E(expr,1,4)="ALL " S expr=$E(expr,5,1048575)
 Q expr
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61480^60691^Dan Russell^111754" ; Signature - LTD^TIME^USER^SIZE
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
vStrPce(object,p1,p2,p3,qt) ; String.piece
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I '($D(p3)#2) S p3=p2
 I '(object[qt)!(qt="") Q $piece(object,p1,p2,p3)
 ;
 I $piece(object,p1,1,p2-1)[qt D  ; find real start
 .	N p N o S o=0
 .	F p=1:1:$L(object,p1) Q:p=(p2+o)  S o=($L($piece(object,p1,1,p),qt)#2=0)+o
 .	S p2=p2+o S p3=p3+o
 .	Q 
 I $piece(object,p1,p2,p3)[qt D  ; find real end
 .	N p N o
 .	F p=p2:1:$L(object,p1) S o=($L($piece(object,p1,p2,p),qt)#2=0) S p3=o+p3 Q:(p=p3)&'o 
 .	Q 
 Q $piece(object,p1,p2,p3)
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
