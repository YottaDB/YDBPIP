DBSFILARCH(TBL,ARCHTBL,PSLCODE)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSFILARCH ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	 ; Typed as Number by DBSFILB
	;
	N acckeys
	N delim N i N keycnt
	N archkey N file N keycode N keys N keyvals
	;
	N tblDes S tblDes=$$getSchTbl^UCXDD(ARCHTBL)
	;
	S delim=$P(tblDes,"|",10)
	S acckeys=$P(tblDes,"|",3)
	S keycnt=$$getArchiveKey^DBARCHIVE(tblDes,0)
	S archkey=$$vStrUC($piece(acckeys,",",keycnt))
	;
	F i=1:1:keycnt D
	.	;
	.	N colrec S colrec=$$getSchCln^UCXDD(ARCHTBL,$piece(acckeys,",",i))
	.	;
	.	S keys(i)=$$vStrUC($P(colrec,"|",2))_"|"_$$getClass^UCXDD(colrec)
	.	Q 
	;
	S keycode="" ; Formal parameters
	S keyvals="" ; Code to concatenate keys
	F i=1:1:keycnt-1 D
	.	;
	.	S keycode=keycode_$piece(keys(i),"|",2)_" "_$piece(keys(i),"|",1)_", "
	.	S keyvals=keyvals_$piece(keys(i),"|",1)_"_"_delim_".char()_"
	.	Q 
	;
	S keycode=$E(keycode,1,$L(keycode)-2)
	S keyvals=$E(keyvals,1,$L(keyvals)-($L($J(delim,0,""))+9))
	;
	I (keyvals="") S keyvals="0"
	;
	; Generate code for ARCHIVE^filerPgm if a primary archive table
	I (TBL=ARCHTBL) D  Q:ER 
	.	;
	.	S RM=$$genARCHIVE(.PSLCODE,tblDes,.keys,keycnt,keycode,keyvals,archkey)
	.	I '(RM="") S ER=1
	.	Q 
	;
	D genARCHFILE(.PSLCODE,tblDes,.keys,keycnt,keycode,keyvals,archkey)
	;
	Q 
	;
genARCHIVE(PSLCODE,tblDes,keys,keycnt,keycode,keyvals,archkey)	;
	;
	N ERR
	N included
	N acckeycnt N i N maxrecs N nonlits
	N acckeys N akeys N ARCHTBL N code N ERMSG N globkeys N globref
	N inclref N incltbl N lvpm N tok N WHERE
	;
	S ARCHTBL=$P(tblDes,"|",1)
	;
	S ERR=0
	;
	; If archive key is date, use it, otherwise find serial value column
	I $piece(keys(keycnt),"|",2)="Date" S WHERE=archkey
	E  D
	.	;
	.	; If serial column specified, use that, otherwise, use first one
	.	N dbutarch S dbutarch=$$vDb2(ARCHTBL)
	.	;
	.	S WHERE=$P(dbutarch,$C(124),2)
	.	;
	.	I (WHERE="") D
	..		;
	..		N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	..		;
	..		I $$vFetch1() S WHERE=rs
	..		E  D
	...			;
	...			S ERR=1
	...			; Archivable tables must have bottom date key or a serial column and cannot be a sub-table of another archivable table
	...			S ERMSG=$$^MSG(6891,ARCHTBL)
	...			Q 
	..		Q 
	.	Q 
	;
	I ERR Q ERMSG
	;
	; Maximum records to process between commits and index updates
	I (keycnt=1) S maxrecs=1
	E  S maxrecs=100
	;
	S WHERE=WHERE_" <= :vARCHDATE"
	;
	I (keycnt>1) D
	.	;
	.	N topwhere
	.	;
	.	S topwhere=""
	.	F i=1:1:keycnt-1 D
	..		;
	..		N key
	..		;
	..		S key=$piece(keys(i),"|",1)
	..		I (i>1) S topwhere=topwhere_" AND "
	..		S topwhere=topwhere_key_"=:"_key
	..		Q 
	.	;
	.	S WHERE=topwhere_" AND "_WHERE
	.	Q 
	;
	; Save at least last record
	S WHERE=WHERE_" AND "_archkey_"<:vMAX"
	;
	F i=1:1:keycnt S lvpm(i_"*")=$piece($P(tblDes,"|",3),",",i)
	S globref=$$getGbl^UCXDD(tblDes,"",.lvpm)
	;
	; Strip leading ^, trailing comma, and add closing parenthesis
	S globref=$E(globref,2,$L(globref)-1)_")"
	S globkeys="("_$piece(globref,"(",2,$L(globref))
	;
	; Get tables included to be archived with this table (excluding sub-tables)
	N dbutarchive S dbutarchive=$$vDb2(ARCHTBL)
	;
	S included=($P(dbutarchive,$C(124),1))
	;
	F i=1:1:$S((included=""):0,1:$L(included,",")) D
	.	;
	.	N ref
	.	;
	.	S incltbl=$piece(included,",",i)
	.	;
	.	N inclDes S inclDes=$$getPslTbl^UCXDD(incltbl,1)
	.	;
	.	S ref=$P(inclDes,"|",2)
	.	S ref=$piece($E(ref,2,1048575),"(",1)_globkeys
	.	;
	.	S inclref(i)=ref
	.	Q 
	;
	S code="public ARCHIVE(String vARCHDIR, Number vARCHNUM, Date vARCHDATE"
	I (keycnt>1) S code=code_", "_keycode
	S code=code_")"
	;
	D TAG^DBSFILB(.PSLCODE,code)
	;
	I (keycnt=1) D
	.	;
	.	D ADD^DBSFILB(.PSLCODE," type public String %INTRPT()","","")
	.	D ADD^DBSFILB(.PSLCODE,"","","")
	.	Q 
	;
	D ADD^DBSFILB(.PSLCODE," type Boolean vISDONE","","")
	D ADD^DBSFILB(.PSLCODE," type Number vI, vN, vRECCNT","","")
	D ADD^DBSFILB(.PSLCODE," type "_$piece(keys(keycnt),"|",2)_" "_archkey,"","")
	;
	S code=" type "_$piece(keys(keycnt),"|",2)_" vMAX"
	F i=1:1:$S((included=""):0,1:$L(included,",")) S code=code_",vMAX"_$piece(included,",",i)
	D ADD^DBSFILB(.PSLCODE,code,"","")
	F i=1:1:$S((included=""):0,1:$L(included,",")) D ADD^DBSFILB(.PSLCODE," type "_$piece(keys(keycnt),"|",2)_" vLAST"_$piece(included,",",i)_" = """"","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," set "_archkey_" = """"","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	;
	; Get maximum values for main and included tables to ensure keep at least one record
	D ADD^DBSFILB(.PSLCODE," #ACCEPT Date=03/01/07; Pgm=RussellDS; CR=25675; Group=Bypass","","")
	D ADD^DBSFILB(.PSLCODE," #BYPASS","","")
	D ADD^DBSFILB(.PSLCODE," set vMAX=$O(^"_globref_",-1)","","")
	D ADD^DBSFILB(.PSLCODE," if vMAX="""" quit 0","","")
	F i=1:1:$S((included=""):0,1:$L(included,",")) D ADD^DBSFILB(.PSLCODE," set vMAX"_$piece(included,",",i)_"=$O(^"_inclref(i)_",-1)","","")
	D ADD^DBSFILB(.PSLCODE," #ENDBYPASS","","")
	;
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," type ResultSet rs = Db.select("""_archkey_""", """_ARCHTBL_""", """_WHERE_""", """_archkey_" ASC"")","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," if rs.isEmpty() quit 0","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," set vRECCNT = 0","","")
	D ADD^DBSFILB(.PSLCODE," set vISDONE = false","","")
	D ADD^DBSFILB(.PSLCODE," for  do { quit:vISDONE","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"  type String vRECS()","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"  for vI = 1:1:"_maxrecs_" do { quit:vISDONE","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"   if rs.next() set vRECS(vI) = rs.getCol("""_archkey_""")","","")
	D ADD^DBSFILB(.PSLCODE,"   else  set vISDONE = true","","")
	D ADD^DBSFILB(.PSLCODE,"  }","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"  quit:'vRECS(1).exists()","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"  do Runtime.start(""BA"")","","")
	D ADD^DBSFILB(.PSLCODE,"  set vI = """"","","")
	D ADD^DBSFILB(.PSLCODE,"  for  set vI = vRECS(vI).order() quit:vI.isNull()  do {","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"   set vRECCNT = vRECCNT + 1","","")
	D ADD^DBSFILB(.PSLCODE,"   set "_archkey_" = vRECS(vI)","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"   // Archive main record and sub-tables. Save index","","")
	D ADD^DBSFILB(.PSLCODE,"   #ACCEPT Date=03/01/07; Pgm=RussellDS; CR=25675; Group=Bypass","","")
	D ADD^DBSFILB(.PSLCODE,"   #BYPASS","","")
	D ADD^DBSFILB(.PSLCODE,"   merge ^|vARCHDIR|"_globref_"=^"_globref,"","")
	D ADD^DBSFILB(.PSLCODE,"   kill ^"_globref,"","")
	;
	; Deal with included tables
	F i=1:1:$S((included=""):0,1:$L(included,",")) D
	.	;
	.	S incltbl=$piece(included,",",i)
	.	;
	.	D ADD^DBSFILB(.PSLCODE,"   ;","","")
	.	D ADD^DBSFILB(.PSLCODE,"   ; Related table "_incltbl,"","")
	.	D ADD^DBSFILB(.PSLCODE,"   if "_archkey_"<vMAX"_incltbl_" do","","")
	.	D ADD^DBSFILB(.PSLCODE,"   . merge ^|vARCHDIR|"_incltbl_"=^"_inclref(i),"","")
	.	D ADD^DBSFILB(.PSLCODE,"   . kill ^"_inclref(i),"","")
	.	D ADD^DBSFILB(.PSLCODE,"   . set vLAST"_incltbl_"="_archkey)
	.	Q 
	;
	D ADD^DBSFILB(.PSLCODE,"   #ENDBYPASS","","")
	D ADD^DBSFILB(.PSLCODE,"  }","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	;
	D ADD^DBSFILB(.PSLCODE,"  // Update index for current archive number with last "_archkey,"","")
	D ADD^DBSFILB(.PSLCODE,"  #ACCEPT Date=03/01/07; Pgm=RussellDS; CR=25675; Group=Bypass","","")
	D ADD^DBSFILB(.PSLCODE,"  #BYPASS","","")
	;
	; Update index for primary table, then included tables
	D ADD^DBSFILB(.PSLCODE,"  set vN=$O(^DBARCHX("""_ARCHTBL_""","_keyvals_",""""),-1)","","")
	D ADD^DBSFILB(.PSLCODE,"  if vN'="""",^(vN)=vARCHNUM kill ^(vN)","","")
	D ADD^DBSFILB(.PSLCODE,"  set ^DBARCHX("""_ARCHTBL_""","_keyvals_","_archkey_")=vARCHNUM","","")
	D ADD^DBSFILB(.PSLCODE,"  ;","","")
	;
	F i=1:1:$S((included=""):0,1:$L(included,",")) D
	.	;
	.	S incltbl=$piece(included,",",i)
	.	;
	.	D ADD^DBSFILB(.PSLCODE,"  if vLAST"_incltbl_"'="""" do","","")
	.	D ADD^DBSFILB(.PSLCODE,"   . set vN=$O(^DBARCHX("""_incltbl_""","_keyvals_",""""),-1)","","")
	.	D ADD^DBSFILB(.PSLCODE,"   . if vN'="""",^(vN)=vARCHNUM kill ^(vN)","","")
	.	D ADD^DBSFILB(.PSLCODE,"   . set ^DBARCHX("""_incltbl_""","_keyvals_","_archkey_")=vARCHNUM","","")
	.	D ADD^DBSFILB(.PSLCODE,"   . if "_archkey_"'<vLAST"_incltbl_" set vLAST"_incltbl_"=""""","","")
	.	D ADD^DBSFILB(.PSLCODE,"  ;","","")
	.	Q 
	;
	D ADD^DBSFILB(.PSLCODE,"  #ENDBYPASS","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE,"  do Runtime.commit()","","")
	;
	I (keycnt=1) D
	.	;
	.	D ADD^DBSFILB(.PSLCODE,"","","")
	.	D ADD^DBSFILB(.PSLCODE,"  if %INTRPT.data() > 1 do INTRPT^IPCMGR","","")
	.	D ADD^DBSFILB(.PSLCODE,"  if '%INTRPT.get().isNull() do {","","")
	.	D ADD^DBSFILB(.PSLCODE,"","","")
	.	D ADD^DBSFILB(.PSLCODE,"   if %INTRPT = ""STOP"" set vISDONE = true","","")
	.	D ADD^DBSFILB(.PSLCODE,"   else  set %INTRPT = """"","","")
	.	D ADD^DBSFILB(.PSLCODE,"  }","","")
	.	Q 
	;
	D ADD^DBSFILB(.PSLCODE," }","","")
	;
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," quit vRECCNT","","")
	;
	Q ""
	;
genARCHFILE(PSLCODE,tblDes,keys,keycnt,keycode,keyvals,archkey)	;
	;
	N oneTbl
	N archincl N archsubs
	N ARCHTBL N code N idxtbl N throwcode
	;
	S ARCHTBL=$P(tblDes,"|",1)
	S archincl=$$getArchiveIncluded^DBARCHIVE(tblDes)
	S archsubs=$$getArchiveSubs^DBARCHIVE(tblDes)
	;
	I ((archsubs="")&(archincl="")) S oneTbl=1
	E  S oneTbl=0
	;
	S code="public ARCHFILE(String vARCHTBL, Number vOPTION"
	I (keycnt>1) S code=code_", "_keycode
	S code=code_", "_$piece(keys(keycnt),"|",2)_" "_archkey_")"
	;
	D TAG^DBSFILB(.PSLCODE,code)
	;
	D ADD^DBSFILB(.PSLCODE," type Number vARCHNUM","","")
	S code=" type String "
	I 'oneTbl S code=code_"vIDXTBL, "
	S code=code_"vARCHFILE, vKEYVALS"
	D ADD^DBSFILB(.PSLCODE,code,"","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	;
	S throwcode="throw Class.new(""Error"", ""%DQ-E-DBFILER,""_$$^MSG(6901, vARCHTBL).replace("","",""~""))"
	;
	; Just the primary
	I oneTbl D
	.	;
	.	S idxtbl=""""_ARCHTBL_""""
	.	;
	.	S code=" if (vARCHTBL '= """_ARCHTBL_""") "_throwcode
	.	D ADD^DBSFILB(.PSLCODE,code,"","")
	.	Q 
	;
	; Check sub-tables, related tables, and subs-tables of related tables
	E  D
	.	;
	.	S idxtbl="vIDXTBL"
	.	;
	.	D ADD^DBSFILB(.PSLCODE," // Primary","","")
	.	D ADD^DBSFILB(.PSLCODE," if (vARCHTBL = """_ARCHTBL_""") set vIDXTBL = """_ARCHTBL_"""","","")
	.	;
	.	I '(archsubs="") D
	..		;
	..		D ADD^DBSFILB(.PSLCODE," // Sub-table of primary","","")
	..		;
	..		I ($S((archsubs=""):0,1:$L(archsubs,","))=1) S code=" else  if """_archsubs_""" = vARCHTBL set vIDXTBL = """_ARCHTBL_""""
	..		E  S code=" else  if {List}"""_archsubs_""".contains(vARCHTBL) set vIDXTBL = """_ARCHTBL_""""
	..		D ADD^DBSFILB(.PSLCODE,code,"","")
	..		Q 
	.	I '(archincl="") D
	..		;
	..		N addCmt
	..		N i
	..		;
	..		D ADD^DBSFILB(.PSLCODE," // Included With (related) table","","")
	..		;
	..		I ($S((archincl=""):0,1:$L(archincl,","))=1) S code=" else  if """_archincl_""" = vARCHTBL set vIDXTBL = vARCHTBL"
	..		E  S code=" else  if {List}"""_archincl_""".contains(vARCHTBL) set vIDXTBL = vARCHTBL"
	..		D ADD^DBSFILB(.PSLCODE,code,"","")
	..		;
	..		S addCmt=1
	..		F i=1:1:$S((archincl=""):0,1:$L(archincl,",")) D
	...			;
	...			N inclsubs
	...			N incltbl
	...			;
	...			S incltbl=$piece($$getArchiveIncluded^DBARCHIVE(tblDes),",",i)
	...			;
	...			N inclDes S inclDes=$$getPslTbl^UCXDD(incltbl,1)
	...			;
	...			S inclsubs=$$getArchiveSubs^DBARCHIVE(inclDes)
	...			;
	...			I '(inclsubs="") D
	....				;
	....				I addCmt D ADD^DBSFILB(.PSLCODE," // Sub-tables of related tables","","")
	....				S addCmt=0
	....				I ($S((inclsubs=""):0,1:$L(inclsubs,","))=1) S code=" else  if """_inclsubs_""" = vARCHTBL set vIDXTBL = """_incltbl_""""
	....				E  S code=" else  if {List}"""_inclsubs_""".contains(vARCHTBL) set vIDXTBL = """_incltbl_""""
	....				D ADD^DBSFILB(.PSLCODE,code,"","")
	....				Q 
	...			Q 
	..		Q 
	.	;
	.	D ADD^DBSFILB(.PSLCODE," // ~p1 is not an archived table","","")
	.	D ADD^DBSFILB(.PSLCODE," else  "_throwcode,"","")
	.	Q 
	;
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," set vKEYVALS = "_keyvals,"","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	;
	D ADD^DBSFILB(.PSLCODE," // Find archive this record would be in","","")
	D ADD^DBSFILB(.PSLCODE," if (vOPTION = 0) do { quit vARCHFILE","","")
	D ADD^DBSFILB(.PSLCODE," type Number vN","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," #ACCEPT Date=03/01/07; Pgm=RussellDS; CR=25675; Group=Bypass","","")
	D ADD^DBSFILB(.PSLCODE," #BYPASS","","")
	D ADD^DBSFILB(.PSLCODE," set vN=$O(^DBARCHX("_idxtbl_",vKEYVALS,"_archkey_"-1E-10))","","")
	D ADD^DBSFILB(.PSLCODE," if vN="""" set vARCHFILE=""""","","")
	D ADD^DBSFILB(.PSLCODE," else  do","","")
	D ADD^DBSFILB(.PSLCODE," .  set vARCHNUM=^DBARCHX("_idxtbl_",vKEYVALS,vN)","","")
	D ADD^DBSFILB(.PSLCODE," .  set vARCHFILE=$ZTRNLNM(""SCAU_ARCHIVE_""_vARCHNUM)","","")
	D ADD^DBSFILB(.PSLCODE," #ENDBYPASS","","")
	D ADD^DBSFILB(.PSLCODE," }","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	;
	D ADD^DBSFILB(.PSLCODE," // Find next/previous archive","","")
	D ADD^DBSFILB(.PSLCODE," #ACCEPT Date=03/01/07; Pgm=RussellDS; CR=25675; Group=Bypass","","")
	D ADD^DBSFILB(.PSLCODE," #BYPASS","","")
	D ADD^DBSFILB(.PSLCODE," if vOPTION=1,"_archkey_"'="""",'$D(^DBARCHX("_idxtbl_",vKEYVALS,"_archkey_")) set "_archkey_"=$O(^DBARCHX("_idxtbl_",vKEYVALS,"_archkey_"))","","")
	D ADD^DBSFILB(.PSLCODE," set "_archkey_"=$O(^DBARCHX("_idxtbl_",vKEYVALS,"_archkey_"),vOPTION)","","")
	D ADD^DBSFILB(.PSLCODE," if "_archkey_"="""" set vARCHFILE=""""","","")
	D ADD^DBSFILB(.PSLCODE," else  do","","")
	D ADD^DBSFILB(.PSLCODE," .  set vARCHNUM=^DBARCHX("_idxtbl_",vKEYVALS,"_archkey_")","","")
	D ADD^DBSFILB(.PSLCODE," .  set vARCHFILE=$ZTRNLNM(""SCAU_ARCHIVE_""_vARCHNUM)","","")
	D ADD^DBSFILB(.PSLCODE," #ENDBYPASS","","")
	D ADD^DBSFILB(.PSLCODE,"","","")
	D ADD^DBSFILB(.PSLCODE," quit vARCHFILE","","")
	;
	Q 
	;
getCHECK(TBL,ARCHTBL,RECNAME)	;
	;
	N acckeys
	N i N keycnt
	N code N archkey
	;
	N tblDes S tblDes=$$getSchTbl^UCXDD(ARCHTBL)
	;
	S acckeys=$P(tblDes,"|",3)
	S keycnt=$$getArchiveKey^DBARCHIVE(tblDes,0)
	S archkey=$$vStrUC($piece(acckeys,",",keycnt))
	;
	S code="$$ARCHFILE^"_$P(tblDes,"|",6)_"("""_TBL_""",0,"
	;
	F i=1:1:keycnt-1 S code=code_RECNAME_"."_$$vStrLC($piece(acckeys,",",i),0)_","
	S code=code_RECNAME_"."_archkey_")"
	;
	Q code
	;
vSIG()	;
	Q "60750^67304^Dan Russell^21144" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ","abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	;
vDb2(v1)	;	voXN = Db.getRecord(DBUTARCHIVE,,0)
	;
	N dbutarch
	S dbutarch=$G(^UTBL("DBARCHIVE",v1))
	I dbutarch="",'$D(^UTBL("DBARCHIVE",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBUTARCHIVE" X $ZT
	Q dbutarch
	;
vOpen1()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:ARCHTBL AND SRL=1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(ARCHTBL) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL1a0
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,9,vos3))
	I '(+$P(vos4,"|",23)=1) G vL1a3
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
