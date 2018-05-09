 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBMAP ****
 ; 
 ; 02/09/2009 03:10 - pip
 ; 
DBMAP ; 
 ;
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
 ; * of the upgrade process.  Therefore, other during an upgrade,    *
 ; * an mrtns version of this routine should not exist.              *
 ; *                                                                 *
 ; * Keep these comments as single line to ensure they exist in the  *
 ; * generated M code.                                               *
 ; *******************************************************************
 ;
 ; I18N=off
 ;
 Q  ; Do not call from top
 ;
MAP(dbid,table,column,position,notDef,coltype) ; Column type [*] /MECH=REFNAM:W/NOREQ
 ;
 ; Request is just for table data
 I ($get(column)="") D
 .	;
 .	N dbmapt,vop1 S dbmapt=$$vRCgetRecord1Opt^RecordDBMAPT(dbid,table,0,.vop1)
 .	;
 .	I ($G(vop1)>0) S table=$P(dbmapt,$C(9),1)
 .	Q 
 ;
 ; Table and column data
 E  D
 .	;
 .	N dbmap S dbmap=$$vRCgetRecord1^RecordDBMAP(dbid,table,column,0)
 .	;
 .	I ($G(vobj(dbmap,-2))>0) D
 ..		;
 ..		S table=$P(vobj(dbmap),$C(9),1)
 ..		;
 ..		; Return extended data for computeds and master fields
 ..		I ($P(vobj(dbmap),$C(9),4)>0) S column=$$extdata(dbmap)
 ..		E  S column=$P(vobj(dbmap),$C(9),2)
 ..		;
 ..		S position=$P(vobj(dbmap),$C(9),3)
 ..		S coltype=$P(vobj(dbmap),$C(9),4)
 ..		S notDef=0
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		S (position,coltype)=""
 ..		S notDef=1
 ..		Q 
 .	K vobj(+$G(dbmap)) Q 
 ;
 Q 
 ;
extdata(dbmap) ; DBMAP Record
 N vret
  S:'$D(vobj(dbmap,1,1)) vobj(dbmap,1,1)="" N von S von="" F  Q:'vobj(dbmap,-2)  S von=$O(^DBMAP("COLUMNS",vobj(dbmap,-3),vobj(dbmap,-4),vobj(dbmap,-5),von)) quit:von=""  S vobj(dbmap,1,1)=vobj(dbmap,1,1)_^DBMAP("COLUMNS",vobj(dbmap,-3),vobj(dbmap,-4),vobj(dbmap,-5),von)
 ;
 S vret=vobj(dbmap,1,1) Q vret
 ;
ALL(dbid) ; Database ID
 ;
 N rs,vos1,vos2 S rs=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D FILE(rs,dbid)
 ;
 Q 
 ;
FILE(dqtable,dbid) ; Database ID
 N vTp
 ;
 N isRDBtbl
 N I N pos
 N acckeys N btmkey N dqcol N N N mflist N parent N PARENT
 N rdbtable N RESERVED N tblarr N tmptable
 ;
 S isRDBtbl=$$rtIsRdb^UCXDD(dqtable)
 ;
  K ^DBMAP("COLUMNS",dbid,dqtable)
  K ^DBMAP("TABLES",dbid,dqtable)
  K ^DBINDX("SYSDEV","DBMAP",dbid,dqtable)
 ;
 N V1 S V1=dqtable Q:'($D(^DBTBL("SYSDEV",1,V1))) 
 ;
 N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=dqtable,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",dqtable,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,10))
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
 ;
 I '($P(vop3,$C(124),4)="") D
 .	;
 .	S parent=$P(vop3,$C(124),4)
 .	;
 .	N rs,vos1,vos2,vos3  N V2 S V2=parent S rs=$$vOpen2()
 .	F  Q:'$$vFetch2()  I '$$isLit^UCGM(rs) S PARENT(rs)=""
 .	;
 .	Q 
 ;
 ; Load reserved words
 ;  #ACCEPT Date=10/10/2006; Pgm=RussellDS; CR=22519; Group=PSLBOOT
 N rs2 S rs2=$$vOpen4()
 F  Q:'$$vFetch4(rs2)  S RESERVED($P(vobj(rs2),$C(9),1))=""
 ;
 S rdbtable=""
 ;
 ; Need to do master fields separately, and last, since they depend
 ; on data stored for sub-fields.
 I '($P(vop3,$C(124),4)="") D
 .	;
 .	N COLS
 .	;
 .	I (dqtable="DEP")!(dqtable="LN") D
 ..		;
 ..		D MAPPING(dbid,dqtable,.COLS)
 ..		;
 ..		Q 
 .	E  D
 ..		;
 ..		N rs,vos4,vos5,vos6  N V2 S V2=dqtable S rs=$$vOpen5()
 ..		F  Q:'$$vFetch5()  I '$$isLit^UCGM(rs) S COLS(dqtable,rs)=1
 ..		;
 ..		Q 
 .	;
 .	; Build tblarr with renamed table
 .	S dqcol=""
 .	F  S dqcol=$order(COLS(dqtable,dqcol)) Q:(dqcol="")  D
 ..		;
 ..		; Ignore columns not in schema
 ..		Q:'$$isColumn^UCXDD(dqtable,dqcol) 
 ..		;
 ..		; Do masterfields separately
 ..		I isRDBtbl,$$isSfdMaster^UCXDD(dqtable,dqcol) S mflist(dqcol)=""
 ..		E  D
 ...			;
 ...			I ($D(PARENT(dqcol))#2) S rdbtable=parent
 ...			E  S rdbtable="W_"_dqtable_"_"_COLS(dqtable,dqcol)
 ...			;
 ...			S tblarr(rdbtable,dqcol)=""
 ...			Q 
 ..		Q 
 .	Q 
 ;
 E  D
 .	;
 .	; If not split, but table name is a reserved word, change name
 .	I ($D(RESERVED(dqtable))#2) S rdbtable="S_"_dqtable
 .	E  S rdbtable=dqtable
 .	;
 .	N rs,vos7,vos8,vos9  N V2 S V2=dqtable S rs=$$vOpen6()
 .	;
 .	F  Q:'$$vFetch6()  D
 ..		;
 ..		S dqcol=rs
 ..		;
 ..		; Do masterfields separately
 ..		I isRDBtbl,$$isSfdMaster^UCXDD(dqtable,dqcol) S mflist(dqcol)=""
 ..		E  S tblarr(rdbtable,dqcol)=""
 ..		Q 
 .	Q 
 ;
 ; Get RDB table(s)
 S (N,rdbtable)=""
 F  S N=$order(tblarr(N)) Q:(N="")  D
 .	;
 .	; Skip computed tables from split tables
 .	I '($E(N,$L(N)-9+1,1048575)="_Computed") S rdbtable=rdbtable_N_","
 .	Q 
 ;
 I ($E(rdbtable,$L(rdbtable))=",") S rdbtable=$E(rdbtable,1,$L(rdbtable)-1)
 ;
 ; Update DBMAPT for split tables or tables with name changes
 I (dqtable'=rdbtable),'(rdbtable="") D
 .	;
 .	N dbmapt S dbmapt=$$vcdmNew^RecordDBMAPT() S vobj(dbmapt,-3)=dbid S vobj(dbmapt,-4)=dqtable
 .	;
 .  S $P(vobj(dbmapt),$C(9),1)=rdbtable
 .  S $P(vobj(dbmapt),$C(9),2)='($P(vop3,$C(124),4)="")
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBMAPT(dbmapt,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbmapt,-100) S vobj(dbmapt,-2)=1 TC:vTp  
 .	K vobj(+$G(dbmapt)) Q 
 ;
 ; Get positions in RDB
 I $$isRdb^vRuntime D
 .	;
 .	N J
 .	N colpos N data N table
 .	;
 .	F I=1:1:$L(rdbtable,",") D
 ..		;
 ..		S table=$piece(rdbtable,",",I)
 ..		;
 ..		Q:'$$rtIsRdb^UCXDD(table) 
 ..		;
 ..		D
 ...			;
 ...			N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ...			;
 ...			S data=$$EXECUTESP^%DBAPI("","FINDPOS",table,1,$char(124))
 ...			;
 ...			Q 
 ..		;
 ..		Q:'($D(data)#2) 
 ..		;
 ..		F J=1:1:$L(data,"|") D
 ...			;
 ...			S colpos=$piece(data,"|",J)
 ...			;
 ...			I ($piece(colpos,",",2)="") D
 ....				;
 ....				; Write message when schema mismatches are detected
 ....				;
 ....				WRITE !,"SCHEMA MISMATCH IN TABLE "_table
 ....				;
 ....				I '($piece(colpos,",",1)="") WRITE !,$piece(colpos,",",1)_" IS MISSING "
 ....				;
 ....				Q 
 ...			;
 ...			S pos(table,$piece(colpos,",",1))=$piece(colpos,",",2)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 ; Get bottom key for use in DBMAPIDX
 ;
 S acckeys=$P(vop4,$C(124),1)
 S btmkey=""
 F I=1:1:$L(acckeys,",") D
 .	;
 .	N key S key=$piece(acckeys,",",I)
 .	;
 .	I '$$isLit^UCGM(key) S btmkey=key
 .	Q 
 ;
 I (btmkey="") S btmkey=$$byte^vRuntime(254)
 ;
 S (rdbtable,dqcol)=""
 F  S rdbtable=$order(tblarr(rdbtable)) Q:(rdbtable="")  D
 .	F  S dqcol=$order(tblarr(rdbtable,dqcol)) Q:(dqcol="")  D
 ..		;
 ..		N position
 ..		N rdbcol
 ..		;
 ..		N dbtbl1d,vop5 S vop5=dqcol,dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",dqtable,dqcol,0,"")
 ..		;
 ..		; Change column name, if necessary
 ..		S rdbcol=$$RESWRD(vop5,.RESERVED)
 ..		;
 ..		N dbmap S dbmap=$$vcdmNew^RecordDBMAP() S vobj(dbmap,-3)=dbid S vobj(dbmap,-4)=dqtable S vobj(dbmap,-5)=dqcol
 ..		 S vobj(dbmap,1,1)=""
 ..		;
 ..		; COLTYPE - 0 = regular, 1 = computed, 2 = master field
 ..		I '(($P(dbtbl1d,$C(124),16)="")!($P(dbtbl1d,$C(124),16)=" ")) D
 ...			;
 ...		  S $P(vobj(dbmap),$C(9),4)=1
 ...		  S vobj(dbmap,1,1)=$$COMP(dqtable,dqcol,$P(dbtbl1d,$C(124),16))
 ...		  S $P(vobj(dbmap),$C(9),1)=dqtable
 ...		  S $P(vobj(dbmap),$C(9),3)=""
 ...			Q 
 ..		E  D
 ...			;
 ...		  S $P(vobj(dbmap),$C(9),4)=0
 ...		  S $P(vobj(dbmap),$C(9),1)=rdbtable
 ...		  S $P(vobj(dbmap),$C(9),2)=rdbcol
 ...		  S $P(vobj(dbmap),$C(9),3)=$get(pos(rdbtable,rdbcol))
 ...			Q 
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBMAP(dbmap,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbmap,-100) S vobj(dbmap,-2)=1 TC:vTp  
 ..		;
 ..		S position=$P(vobj(dbmap),$C(9),3)
 ..		;
 ..		I '(position="") D
 ...			;
 ...			N split
 ...			;
 ...			N dbmapidx S dbmapidx=$$vcdmNew^RecordDBMAPIDX() S vobj(dbmapidx,-3)="SYSDEV" S vobj(dbmapidx,-4)=dbid S vobj(dbmapidx,-5)=dqtable S vobj(dbmapidx,-7)=position S vobj(dbmapidx,-8)=dqcol
 ...			;
 ...			I ($P(vop3,$C(124),4)="") S split=btmkey
 ...			E  I $$vStrIsNum($piece(rdbtable,"_",3)) S split=$piece(rdbtable,"_",3)
 ...			E  S split=btmkey
 ...			;
 ...		  S vobj(dbmapidx,-6)=split
 ...			;
 ...		  S $P(vobj(dbmapidx),$C(124),1)=rdbcol
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBMAPIDX(dbmapidx,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbmapidx,-100) S vobj(dbmapidx,-2)=1 TC:vTp  
 ...			K vobj(+$G(dbmapidx)) Q 
 ..		K vobj(+$G(dbmap)) Q 
 .	Q 
 ;
 ; Set master field info
 I isRDBtbl F  S dqcol=$order(mflist(dqcol)) Q:(dqcol="")  D
 .	;
 .	N dbmap S dbmap=$$vcdmNew^RecordDBMAP() S vobj(dbmap,-3)=dbid S vobj(dbmap,-4)=dqtable S vobj(dbmap,-5)=dqcol
 .	 S vobj(dbmap,1,1)=""
 .	;
 .  S $P(vobj(dbmap),$C(9),4)=2
 .  S vobj(dbmap,1,1)=$$rtMfORC^UCCOLSF(dqtable,dqcol)
 .  S $P(vobj(dbmap),$C(9),1)=dqtable
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBMAP(dbmap,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbmap,-100) S vobj(dbmap,-2)=1 TC:vTp  
 .	K vobj(+$G(dbmap)) Q 
 ;
 K vobj(+$G(rs2)) Q 
 ;
COMP(dqtable,dqcol,cmp,RESERVED) ; Reserved words list  /MECH=REFARR:R
 ;
 N isExtFn
 N ptr
 N cmpcols N cmpuc N expr N rescol N restbl N tok
 ;
 S restbl=$$RESWRD(dqtable)
 S rescol=$$RESWRD(dqcol)
 ;
 I ($E(cmp,1)="(") S cmp=$$POP^%ZS(cmp)
 ;
 ; Do now allow Set or Do in computed
 S cmpuc=$ZCONVERT(cmp,"U")
 ;
 I (($E(cmpuc,1,2)="S ")!($E(cmpuc,1,2)="D ")) D
 .	;
 .	N RM
 .	;
 .	; Invalid computed data item = 'di'
 .	S RM=$$^MSG(8316,$$^MSG(595),dqtable_"."_dqcol)
 .	S $ZE="0,"_$ZPOS_","_"%DQ-E-DBMAP,"_$translate(RM,",","~"),$EC=",U1001,"
 .	Q 
 ;
 S cmp=$$TOKEN^%ZS(cmp,.tok)
 S expr=""
 S (isExtFn,ptr)=0
 ;
 F  D  Q:(ptr=0) 
 .	;
 .	N atom N delims N ref
 .	;
 .	S delims="[]+-*/\#_'=><\*(),!&:?"
 .	;
 .	S atom=$$ATOM^%ZS(cmp,.ptr,"[]+-*/\#_'=><\*(),!&:?",tok,0)
 .	;
 .	I $$isLit^UCGM(atom) D  Q 
 ..		;
 ..		N lit
 ..		;
 ..		S lit=$$QADD^%ZS($$QSUB^%ZS(atom,""""),"'")
 ..		;
 ..		I isExtFn,'((","_expr_",")[(","_lit_",")) S expr=expr_lit_","
 ..		Q 
 .	;
 .	I isExtFn,(atom=")") S isExtFn=0
 .	;
 .	I ($E(atom,1,2)="$$") S isExtFn=1 Q 
 .	;
 .	Q:(delims[atom) 
 .	Q:($ZCONVERT(atom,"U")="$C") 
 .	Q:($ZCONVERT(atom,"U")="$E") 
 .	Q:($ZCONVERT(atom,"U")="$P") 
 .	Q:($ZCONVERT(atom,"U")="$S") 
 .	;
 .	I ($E(atom,1,$L((dqtable_".")))=(dqtable_".")) S atom=$piece(atom,".",2)
 .	;
 .	; Not a column in this table
 .	  N V1,V2 S V1=dqtable,V2=atom Q:'($D(^DBTBL("SYSDEV",1,V1,9,V2))#2) 
 .	;
 .	S ref=dqtable_"."_atom
 .	I '((","_expr_",")[(","_ref_",")) S expr=expr_ref_","
 .	Q 
 ;
 S expr=$E(expr,1,$L(expr)-1)
 ;
 S expr=restbl_"_"_rescol_"("_expr_")"
 ;
 Q expr
 ;
nod(dbid,table,column) ; DATA-QWIK column name
 N vret
 ;
 N dbmap S dbmap=$G(^DBMAP("COLUMNS",dbid,table,column))
 ;
 S vret=$$tbl2nod($P(dbmap,$C(9),1)) Q vret
 ;
tbl2nod(rdbtbl) ; RDB Table Name
 ;
 N return S return=""
 ;
 I ($E(rdbtbl,1,2)="W_") S return=$piece(rdbtbl,"_",$L(rdbtbl,"_"))
 ;
 Q return
 ;
nod2tbl(dbid,dqtable,node) ; Node [*]
 ;
 N rdbtable S rdbtable=dqtable
 ;
 D MAP(dbid,.rdbtable)
 ;
 I (rdbtable[",") D
 .	;
 .	I (node="") S rdbtable=$piece(rdbtable,",",1)
 .	E  S rdbtable="W_"_dqtable_"_"_node
 .	Q 
 ;
 Q rdbtable
 ;
RESWRD(oldname,RESERVED) ; Reserved words [*] /NOREQ/MECH=REFARR:R
 ;
 N isResrvd
 N newname
 ;
 I ($E(oldname,1)="%") S newname="X"_$E(oldname,2,1048575)
 E  S newname=oldname
 ;
 S isResrvd=0
 ;
 I $D(RESERVED) D
 .	;
 .	I ($D(RESERVED(newname))#2) S isResrvd=1
 .	Q 
 E  D
 .	;
 .	;   #ACCEPT Date=10/10/2006; Pgm=RussellDS; CR=22519; Group=PSLBOOT
 .	N rs  N V1 S V1=newname S rs=$$vOpen8()
 .	I $$vFetch8(rs) S isResrvd=1
 .	K vobj(+$G(rs)) Q 
 ;
 I isResrvd S newname="S_"_newname
 ;
 Q newname
 ;
MAPPING(dbid,table,MAP) ; returned mapping array [*] /MECH=REFARR:W
 ;
 N haveERR
 N COLUMN N ERMSG N filename
 ;
 S filename=$$TRNLNM^%ZFUNC("SCAU$DBMAP_FILE","")
 I (filename="") S filename=$$FILE^%TRNLNM("DBMAP.txt","SCAU$DIR")
 ;
 ; Load mapping information
 D LOADMAP(dbid,filename,table,.MAP)
 ;
 ; Validate information and determine maximum split table
 S haveERR=0
 S COLUMN=""
 F  S COLUMN=$order(MAP(table,COLUMN)) Q:(COLUMN="")  D
 .	;
 .	N SPLIT S SPLIT=$ZCONVERT(MAP(table,COLUMN),"U")
 .	;
 .	S ERMSG=""
 .	;
 .	; Ignore columns not in schema
 .	Q:'$$isColumn^UCXDD(table,COLUMN) 
 .	;
 .	; Temporary to improve preformance
 .	; type SchemaColumn colrec = Db.getSchemaColumn(table, COLUMN)
 .	N ddrec S ddrec=$G(^DBTBL("SYSDEV",1,table,9,COLUMN))
 .	;
 .	I (SPLIT="") D
 ..		;
 ..		S ERMSG=table_"."_COLUMN_" has no split table mapping value"
 ..		Q 
 .	I $$isColumn^UCXDD("ACN",COLUMN),'((SPLIT="ACN")!(SPLIT="COMPUTED")) D
 ..		;
 ..		S ERMSG=table_"."_COLUMN_" is in ACN and must be mapped to ACN"
 ..		Q 
 .	I (SPLIT="ACN"),'$$isColumn^UCXDD("ACN",COLUMN) D
 ..		;
 ..		S ERMSG=table_"."_COLUMN_" is not in ACN and cannot be mapped to ACN"
 ..		Q 
 .	;if 'colrec.computation.isNull(), (SPLIT '= "COMPUTED") do {
 .	I '($P(ddrec,$C(124),16)=""),(SPLIT'="COMPUTED") D
 ..		;
 ..		S ERMSG=table_"."_COLUMN_" is a computed and must be mapped as 'Computed'"
 ..		Q 
 .	;if (SPLIT = "COMPUTED"), colrec.computation.isNull() do {
 .	I (SPLIT="COMPUTED"),($P(ddrec,$C(124),16)="") D
 ..		;
 ..		S ERMSG=table_"."_COLUMN_" is not a computed but is mapped as one"
 ..		Q 
 .	I (ERMSG=""),(SPLIT'="ACN"),(SPLIT'="COMPUTED"),((SPLIT'?1.2N)!(SPLIT<1)!(SPLIT>99)) D
 ..		;
 ..		S ERMSG=table_"."_COLUMN_" split table value must be an integer between 1 and 99"
 ..		Q 
 .	;
 .	I '(ERMSG="") D
 ..		;
 ..		S haveERR=1
 ..		WRITE ERMSG,!
 ..		Q 
 .	Q 
 ;
 I haveERR S $ZE="0,"_$ZPOS_","_"%DQ-E-DBMAP, Invalid mapping information",$EC=",U1001,"
 ;
 ; Add any missing columns
 D ADDMISNG(dbid,table,.MAP,100)
 ;
 Q 
 ;
TSV ; 
 ;
 N %READ N %TAB N COLUMN N filename N MAP N TAB N TABLE N VFMQ
 ;
 ; File Name
 S %TAB("filename")="/DES="_$$^MSG(5204)_"/TYP=T/LEN=80"
 ;
 S filename=$$TRNLNM^%ZFUNC("SCAU$DBMAP_FILE","")
 I (filename="") S filename=$$FILE^%TRNLNM("DBMAP.txt","SCAU$DIR")
 ;
 S %READ="@@%FN,,filename/REQ"
 ;
 D ^UTLREAD Q:(VFMQ="Q") 
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
 ; Load mapping information
 D LOADMAP(%DB,filename,"DEP",.MAP)
 D LOADMAP(%DB,filename,"LN",.MAP)
 ;
 ; Add any missing columns
 D ADDMISNG(%DB,"DEP",.MAP,"")
 D ADDMISNG(%DB,"LN",.MAP,"")
 ;
 ; Save the new file
 N file S file=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(file,1),"|",2)=$$PARSE^%ZFUNC(filename,"DIRECTORY")
 S $P(vobj(file,1),"|",1)=$$PARSE^%ZFUNC(filename,"NAME")_$$PARSE^%ZFUNC(filename,"TYPE")
 S $P(vobj(file,1),"|",3)="WRITE/NEWV"
 S $P(vobj(file,1),"|",4)=5
 ;
 D
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	;
 .	D open^UCIO(file,$T(+0),"TSV","file")
 .	Q 
 ;
 S TAB=$char(9)
 ;
 D write^UCIO(file,"TABLE"_TAB_"COLUMN"_TAB_"SPLIT_TABLE")
 ;
 S (TABLE,COLUMN)=""
 F  S TABLE=$order(MAP(TABLE)) Q:(TABLE="")  D
 .	;
 .	F  S COLUMN=$order(MAP(TABLE,COLUMN)) Q:(COLUMN="")  D
 ..		;
 ..		D write^UCIO(file,TABLE_TAB_COLUMN_TAB_MAP(TABLE,COLUMN))
 ..		Q 
 .	Q 
 ;
 D close^UCIO(file)
 ;
 K vobj(+$G(file)) Q 
 ;
LOADMAP(dbid,filename,table,MAP) ; Mapping array  /MECH=REFARR:W
 ;
 N X
 ;
 ; See if filename exists, and, if so, load map from it
 ;  #ACCEPT Date=08/04/06; Pgm=RussellDS; CR=22519; Group=BYPASS
 ;*** Start of code by-passed by compiler
 set X=$zsearch("x.x") ; Clear context
 set X=$zsearch(filename)
 ;*** End of code by-passed by compiler ***
 I '(X="") D
 .	;
 .	D LOADFILE(X,table,.MAP)
 .	Q 
 ; Otherwise load defaults
 E  D
 .	;
 .	;   #ACCEPT Date=04/10/07; Pgm=RussellDS; CR=26503; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZLINK "USTMAPDF"
 .	;*** End of code by-passed by compiler ***
 .	D ^USTMAPDF(dbid,table,.MAP)
 .	Q 
 ;
 Q 
 ;
LOADFILE(filename,table,MAP) ; Mapping info  /MECH=REFARR:W
 ;
 N i
 N TAB N X
 ;
 S TAB=$char(9)
 ;
 N file S file=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(file,1),"|",2)=$$PARSE^%ZFUNC(filename,"DIRECTORY")
 S $P(vobj(file,1),"|",1)=$$PARSE^%ZFUNC(filename,"NAME")_$$PARSE^%ZFUNC(filename,"TYPE")
 S $P(vobj(file,1),"|",3)="READ"
 S $P(vobj(file,1),"|",4)=5
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 ;
 D open^UCIO(file,$T(+0),"LOADFILE","file")
 ;
 ; Check file format based on first line
 S X=$$read^UCIO(file)
 I '(X=("TABLE"_TAB_"COLUMN"_TAB_"SPLIT_TABLE")) D
 .	;
 .	N ERMSG
 .	; file name - Input file header - Invalid format
 .	S ERMSG=$P(vobj(file,1),"|",6)_" - "_$$^MSG(3594)_" - "_$$^MSG(1350)
 .	;
 .	S $ZE="0,"_$ZPOS_","_"%DQ-E-DBMAP,"_$translate(ERMSG,",","~"),$EC=",U1001,"
 .	Q 
 ;
 ; Read the data from the file
 F i=2:1 D
 .	;
 .	N COLUMN N SPLIT
 .	;
 .	S X=$$read^UCIO(file) Q:(X="") 
 .	;
 .	; Not the table we care about
 .	Q:($ZCONVERT($piece(X,TAB,1),"U")'=table) 
 .	;
 .	S COLUMN=$ZCONVERT($piece(X,TAB,2),"U")
 .	S SPLIT=$piece(X,TAB,3)
 .	;
 .	I (COLUMN="") D
 ..		;
 ..		N ERMSG
 ..		; file name - Invalid format - Record i - COLUMN Column Cannot be NULL
 ..		S ERMSG=$P(vobj(file,1),"|",6)_" - "_$$^MSG(1350)_" - "_$$^MSG(2326)_" "_i_" - "
 ..		S ERMSG=ERMSG_"COLUMN "_$$^MSG(8557)
 ..		;
 ..		S $ZE="0,"_$ZPOS_","_"%DQ-E-DBMAP,"_$translate(ERMSG,",","~"),$EC=",U1001,"
 ..		Q 
 .	;
 .	I ($D(MAP(table,COLUMN))#2) D
 ..		;
 ..		; file name - table.COLUMN - Record i - already exists
 ..		S $ZE="0,"_$ZPOS_","_"%DQ-E-DBMAP,"_$P(vobj(file,1),"|",6)_" - "_$$^MSG(3019,table_"."_COLUMN_" - "_$$^MSG(2326)_" "_i_" -"),$EC=",U1001,"
 ..		Q 
 .	;
 .	S MAP(table,COLUMN)=SPLIT
 .	Q 
 ;
 K vobj(+$G(file)) Q 
 ;
ADDMISNG(dbid,table,MAP,SPLIT) ; Split table for missing 100 or null
 ;
 N COLUMN N DFTMAP N SPLITSUB
 ;
 D ^USTMAPDF(dbid,table,.DFTMAP)
 ;
 N rs,vos1,vos2,vos3,vos4,vOid  N V1 S V1=table S rs=$$vOpen9()
 ;
 F  Q:'$$vFetch9()  D
 .	;
 .	S COLUMN=rs
 .	;
 .	I '($D(MAP(table,COLUMN))#2) D
 ..		;
 ..		N colrec S colrec=$$getSchCln^UCXDD(table,COLUMN)
 ..		;
 ..		I '($P(colrec,"|",14)="") S SPLITSUB="Computed"
 ..		E  I $$isColumn^UCXDD("ACN",COLUMN) S SPLITSUB="ACN"
 ..		E  I '(SPLIT="") S SPLITSUB=100
 ..		E  S SPLITSUB="" ; New - needs to get mapped
 ..		;
 ..		S MAP(table,COLUMN)=SPLITSUB
 ..		;
 ..		WRITE table,".",COLUMN," - in schema, missing from mapping.  "
 ..		;
 ..		I ((SPLITSUB=100)!(SPLITSUB="")),($D(DFTMAP(table,COLUMN))#2) WRITE "Default mapping is to wide table ",DFTMAP(table,COLUMN),".  "
 ..		;
 ..		I '(SPLIT="") WRITE "Added to split table ",SPLITSUB,!!
 ..		E  WRITE "Added to file, must be mapped",!!
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ; ----------------
 ;  #OPTION ResultClass 1
vOpen4() ; PSLBOOT result set for STBLRESERVED
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","STBLRESERVED")) QUIT $$vOpen3()
 ;*** End of code by-passed by compiler ***
 N vRws S vRws=pslPrsr("boot","STBLRESERVED")
 N vOid S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-5)=2
 S vobj(vOid,-2)="$$vFetch4^"_$T(+0)
 S vobj(vOid,-3)="WORD"
 S vobj(vOid,-4)="T0"
 S vobj(vOid,0)=1
 S vobj(vRws,0)=0 
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF $$vFetch4(vOid) SET vobj(vOid,0)=2
 ;*** End of code by-passed by compiler ***
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vFetch4(vOid) ; PSLBOOT fetch for STBLRESERVED
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","STBLRESERVED")) QUIT $$vFetch3(vOid)
 ;*** End of code by-passed by compiler ***
 I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
 N vRws S vRws=pslPrsr("boot","STBLRESERVED")
 N vR
 S vobj(vOid,0)=$$vRwsNxt(vRws)
 S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
 S vobj(vOid)=$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"WORD"))
 S vret=vobj(vOid,0) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vOpen8() ; PSLBOOT result set for STBLRESERVED
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","STBLRESERVED")) QUIT $$vOpen7()
 ;*** End of code by-passed by compiler ***
 N vRws S vRws=pslPrsr("boot","STBLRESERVED")
 N vOid S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-5)=2
 S vobj(vOid,-2)="$$vFetch8^"_$T(+0)
 S vobj(vOid,-3)="WORD"
 S vobj(vOid,-4)="T0"
 S vobj(vOid,0)=1
 S vobj(vOid,1)=NEWNAME
 S vobj(vRws,0)=0 
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF $$vFetch8(vOid) SET vobj(vOid,0)=2
 ;*** End of code by-passed by compiler ***
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vFetch8(vOid) ; PSLBOOT fetch for STBLRESERVED
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","STBLRESERVED")) QUIT $$vFetch7(vOid)
 ;*** End of code by-passed by compiler ***
 I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
 N vRws S vRws=pslPrsr("boot","STBLRESERVED")
 N vR
 N vFnd S vFnd=0
 F  Q:'('vFnd)  D
 .	I '$$vRwsNxt(vRws) S vFnd=1 S vobj(vOid,0)=0 Q 
 .	S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
 .	I '($P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"WORD"))=vobj(vOid,1)) Q 
 .	S vFnd=1
 .	Q 
 S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
 S vobj(vOid)=$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"WORD"))
 S vret=vobj(vOid,0) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vRwGC(vList,vRef) ; Dynamic column position lookup
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (vRef="") Q ""
 I +vRef>0 Q vRef
 ;
 S vList=$ZCONVERT(vList,"U") S vRef=$ZCONVERT(vRef,"U")
 N vP S vP=$F((vList_",")," "_vRef_",")
 I vP=0 S vP=$F((","_vList_","),","_vRef_",") I vP=0 Q ""
 Q $L($E(vList,1,vP-$L(vRef)),",")
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vOpen1() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV'
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=""
vL1a2 S vos2=$O(^DBTBL("SYSDEV",1,vos2),1) I vos2="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a2
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos2=$ZCH(254):"",1:vos2)
 ;
 Q 1
 ;
vOpen2() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V2
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$G(V2) I vos2="" G vL2a0
 S vos3=""
vL2a3 S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL2a0
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
 S rs=$S(vos3=$ZCH(254):"",1:vos3)
 ;
 Q 1
 ;
vOpen3() ; WORD FROM STBLRESERVED
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch3^"_$T(+0)
 S vobj(vOid,-3)="WORD"
 S vobj(vOid,-4)="T0"
 D vL3a1
 Q vOid
 ;
vL3a0 S vobj(vOid,0)=0 Q
vL3a1 S vobj(vOid,1)=""
vL3a2 S vobj(vOid,1)=$O(^STBL("RESERVED",vobj(vOid,1)),1) I vobj(vOid,1)="" G vL3a0
 Q
 ;
vFetch3(vOid) ;
 ;
 ;
 I vobj(vOid,0)=1 D vL3a2
 I vobj(vOid,0)=2 S vobj(vOid,0)=1
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid)=$S(vobj(vOid,1)=$ZCH(254):"",1:vobj(vOid,1))
 ;
 Q 1
 ;
vOpen5() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V2
 ;
 ;
 S vos4=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos4=0 Q
vL5a1 S vos5=$G(V2) I vos5="" G vL5a0
 S vos6=""
vL5a3 S vos6=$O(^DBTBL("SYSDEV",1,vos5,9,vos6),1) I vos6="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos4=1 D vL5a3
 I vos4=2 S vos4=1
 ;
 I vos4=0 S rs="" Q 0
 ;
 S rs=$S(vos6=$ZCH(254):"",1:vos6)
 ;
 Q 1
 ;
vOpen6() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V2
 ;
 ;
 S vos7=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos7=0 Q
vL6a1 S vos8=$G(V2) I vos8="" G vL6a0
 S vos9=""
vL6a3 S vos9=$O(^DBTBL("SYSDEV",1,vos8,9,vos9),1) I vos9="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos7=1 D vL6a3
 I vos7=2 S vos7=1
 ;
 I vos7=0 S rs="" Q 0
 ;
 S rs=$S(vos9=$ZCH(254):"",1:vos9)
 ;
 Q 1
 ;
vOpen7() ; WORD FROM STBLRESERVED WHERE WORD=:V1
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch7^"_$T(+0)
 S vobj(vOid,-3)="WORD"
 S vobj(vOid,-4)="T0"
 D vL7a1
 Q vOid
 ;
vL7a0 S vobj(vOid,0)=0 Q
vL7a1 S vobj(vOid,1)=$G(V1) I vobj(vOid,1)="" G vL7a0
 I '($D(^STBL("RESERVED",vobj(vOid,1)))#2) G vL7a0
 Q
 ;
vFetch7(vOid) ;
 ;
 ;
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid,0)=100
 S vobj(vOid)=vobj(vOid,1)
 S vobj(vOid,0)=0
 ;
 Q 1
 ;
vOpen9() ; DI FROM DBTBL1D WHERE FID=:V1 ORDER BY DI
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL9a1
 Q ""
 ;
vL9a0 S vos1=0 Q
vL9a1 S vos2=$G(V1) I vos2="" G vL9a0
 S vos3=""
vL9a3 S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL9a9
 S vos4=""
vL9a5 S vos4=$O(^DBTBL(vos3,1,vos2,9,vos4),1) I vos4="" G vL9a3
 S vd=$S(vos4=$ZCH(254):"",1:vos4)
 S ^DBTMP($J,vOid,1,vos4,vos3)=vd
 G vL9a5
vL9a9 S vos2=""
vL9a10 S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL9a0
 S vos3=""
vL9a12 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL9a10
 Q
 ;
vFetch9() ;
 ;
 ;
 I vos1=1 D vL9a12
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" K ^DBTMP($J,vOid) Q 0
 ;
 S rs=^DBTMP($J,vOid,1,vos2,vos3)
 ;
 Q 1
 ;
vRwsNxt(vOid) ; RowSet.next
 ;
 N vLst S vLst=$O(vobj(vOid,""),-1)
 I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
 Q vobj(vOid,0)'>vLst
 ;
vStrIsNum(vStr) ; String.isNumber
 ;
 Q vStr=+vStr
 ;
vCatch4 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D close^UCIO(file)
 ;
 I '($P(error,",",3)["IOEOF") S $ZE=error,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N openerr,$ET,$ES S openerr=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D close^UCIO(file)
 ;
 S $ZE=openerr,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 S RM=$P(error,",",4)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 ; Write message about error, but otherwise ignore
 ;
 WRITE !!,"***** Error finding positions for table ",table," - ",$P(error,",",4),!
 ;
 D ZX^UCGMR(voxMrk) Q 
