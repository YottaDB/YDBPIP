DBMAP	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBMAP ****
	;
	; 11/08/2007 14:07 - chenardp
	;
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
MAP(dbid,table,column,position,notDef,coltype)	;
	;
	; Request is just for table data
	I ($get(column)="") D
	.	;
	.	N dbmapt,vop1 S dbmapt=$$vDb5(dbid,table,.vop1)
	.	;
	.	I ($G(vop1)>0) S table=$P(dbmapt,$C(9),1)
	.	Q 
	;
	; Table and column data
	E  D
	.	;
	.	N dbmap S dbmap=$$vDb2(dbid,table,column)
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
extdata(dbmap)	; DBMAP Record
	N vret
	 S:'$D(vobj(dbmap,1,1)) vobj(dbmap,1,1)="" N von S von="" F  Q:'vobj(dbmap,-2)  S von=$O(^DBMAP("COLUMNS",vobj(dbmap,-3),vobj(dbmap,-4),vobj(dbmap,-5),von)) quit:von=""  S vobj(dbmap,1,1)=vobj(dbmap,1,1)_^DBMAP("COLUMNS",vobj(dbmap,-3),vobj(dbmap,-4),vobj(dbmap,-5),von)
	;
	S vret=vobj(dbmap,1,1) Q vret
	;
ALL(dbid)	; Database ID
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D FILE(rs,dbid)
	;
	Q 
	;
FILE(dqtable,dbid)	;
	;
	N isDEPLN N isRDBtbl N isSplit
	N I N pos
	N acckeys N btmkey N dqcol N N N mflist N rdbtable N RESERVED N tblarr
	;
	S isRDBtbl=$$rdb^UCDBRT(dqtable)
	;
	K ^DBMAP("COLUMNS",dbid,dqtable)
	K ^DBMAP("TABLES",dbid,dqtable)
	K ^DBINDX("SYSDEV","DBMAP",dbid,dqtable)
	;
	N V1 S V1=dqtable Q:'($D(^DBTBL("SYSDEV",1,V1))) 
	;
	I (",,DEP,LN,,"[(","_dqtable_",")) S isSplit=1
	E  S isSplit=0
	;
	I ((dqtable="DEP")!(dqtable="LN")) S isDEPLN=1
	E  S isDEPLN=0
	;
	; Load reserved words
	;  #ACCEPT Date=10/10/2006; Pgm=RussellDS; CR=22519; Group=PSLBOOT
	N rs2 S rs2=$$vOpen3()
	F  Q:'($$vFetch3(rs2))  S RESERVED($P(vobj(rs2),$C(9),1))=""
	;
	S rdbtable=""
	;
	; Need to do master fields separately, and last, since they depend
	; on data stored for sub-fields.
	I isSplit D
	.	;
	.	N ACN N COLS
	.	;
	.	; Split the table
	.	D MAPPING(dbid,dqtable,.COLS)
	.	;
	.	; Load list of ACN columns if DEP or LN
	.	I isDEPLN D
	..		;
	..		N rs,vos1,vos2 S rs=$$vOpen4()
	..		F  Q:'($$vFetch4())  S ACN(rs)=""
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
	...			I isDEPLN,($D(ACN(dqcol))#2) S rdbtable="ACN"
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
	.	N rs,vos3,vos4,vos5  N V2 S V2=dqtable S rs=$$vOpen5()
	.	;
	.	F  Q:'($$vFetch5())  D
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
	.	I '(($E(N,$L(N)-9+1,1048575)="_Computed")) S rdbtable=rdbtable_N_","
	.	Q 
	;
	I ($E(rdbtable,$L(rdbtable))=",") S rdbtable=$E(rdbtable,1,$L(rdbtable)-1)
	;
	; Update DBMAPT for split tables or tables with name changes
	I (dqtable'=rdbtable),'(rdbtable="") D
	.	;
	.	N dbmapt,vop1,vop2,vop3 S dbmapt="",vop2=dbid,vop1=dqtable,vop3=0
	.	;
	. S $P(dbmapt,$C(9),1)=rdbtable
	. S $P(dbmapt,$C(9),2)=isSplit
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBMAP("TABLES",vop2,vop1)=dbmapt S vop3=1 Tcommit:vTp  
	.	Q 
	;
	; Get positions in RDB
	I $$rdb^UCDBRT D
	.	;
	.	N ER
	.	N J
	.	N colpos N data N RM N table
	.	;
	.	F I=1:1:$L(rdbtable,",") D
	..		;
	..		S table=$piece(rdbtable,",",I)
	..		;
	..		Q:'$$rdb^UCDBRT(table) 
	..		;
	..		S ER=$$EXECSP^%DBAPI("","FINDPOS",table,1,$char(124),.data,.RM)
	..		;
	..		F J=1:1:$L(data,"|") D
	...			;
	...			S colpos=$piece(data,"|",J)
	...			;
	...			S pos(table,$piece(colpos,",",1))=$piece(colpos,",",2)
	...			Q 
	..		Q 
	.	Q 
	;
	; Get bottom key for use in DBMAPIDX
	N dbtbl1,vop4,vop5,vop6 S vop4="SYSDEV",vop5=dqtable,dbtbl1=$$vDb6("SYSDEV",dqtable)
	 S vop6=$G(^DBTBL(vop4,1,vop5,16))
	;
	S acckeys=$P(vop6,$C(124),1)
	S btmkey=""
	F I=1:1:$L(acckeys,",") D
	.	;
	.	N key S key=$piece(acckeys,",",I)
	.	;
	.	I '$$isLit^UCGM(key) S btmkey=key
	.	Q 
	I (btmkey="") S btmkey=$char(254) ; CUVAR-like tables
	;
	S (rdbtable,dqcol)=""
	F  S rdbtable=$order(tblarr(rdbtable)) Q:(rdbtable="")  D
	.	F  S dqcol=$order(tblarr(rdbtable,dqcol)) Q:(dqcol="")  D
	..		;
	..		N position
	..		N rdbcol
	..		;
	..		N dbtbl1d,vop7 S vop7=dqcol,dbtbl1d=$$vDb7("SYSDEV",dqtable,dqcol)
	..		;
	..		; Change column name, if necessary
	..		S rdbcol=$$RESWRD(vop7,.RESERVED)
	..		;
	..		N dbmap S dbmap=$$vDbNew2(dbid,dqtable,dqcol)
	..		 S vobj(dbmap,1,1)=""
	..		;
	..		; COLTYPE - 0 = regular, 1 = computed, 2 = master field
	..		I '(($P(dbtbl1d,$C(124),16)="")!($P(dbtbl1d,$C(124),16)=" ")) D
	...			;
	...		 S $P(vobj(dbmap),$C(9),4)=1
	...		 S vobj(dbmap,1,1)=$$COMP(dqtable,dqcol,$P(dbtbl1d,$C(124),16))
	...		 S $P(vobj(dbmap),$C(9),1)=dqtable
	...		 S $P(vobj(dbmap),$C(9),3)=""
	...			Q 
	..		E  D
	...			;
	...		 S $P(vobj(dbmap),$C(9),4)=0
	...		 S $P(vobj(dbmap),$C(9),1)=rdbtable
	...		 S $P(vobj(dbmap),$C(9),2)=rdbcol
	...		 S $P(vobj(dbmap),$C(9),3)=$get(pos(rdbtable,rdbcol))
	...			Q 
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbmap) S vobj(dbmap,-2)=1 Tcommit:vTp  
	..		;
	..		S position=$P(vobj(dbmap),$C(9),3)
	..		;
	..		I '(position="") D
	...			;
	...			N split
	...			;
	...			N dbmapidx,vop8,vop9,vop10,vop11,vop12,vop13,vop14 S dbmapidx="",vop13="SYSDEV",vop12=dbid,vop11=dqtable,vop10="",vop9=position,vop8=dqcol,vop14=0
	...			;
	...			I 'isSplit S split=btmkey
	...			E  I $$vStrIsNum($piece(rdbtable,"_",3)) S split=$piece(rdbtable,"_",3)
	...			E  S split=btmkey
	...			;
	...		 S vop10=split
	...			;
	...		 S $P(dbmapidx,$C(124),1)=rdbcol
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBINDX(vop13,"DBMAP",vop12,vop11,vop10,vop9,vop8)=$$RTBAR^%ZFUNC(dbmapidx) S vop14=1 Tcommit:vTp  
	...			Q 
	..		K vobj(+$G(dbmap)) Q 
	.	Q 
	;
	; Set master field info
	I isRDBtbl F  S dqcol=$order(mflist(dqcol)) Q:(dqcol="")  D
	.	;
	.	N dbmap S dbmap=$$vDbNew2(dbid,dqtable,dqcol)
	.	 S vobj(dbmap,1,1)=""
	.	;
	. S $P(vobj(dbmap),$C(9),4)=2
	. S vobj(dbmap,1,1)=$$rtMfORC^UCCOLSF(dqtable,dqcol)
	. S $P(vobj(dbmap),$C(9),1)=dqtable
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbmap) S vobj(dbmap,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(dbmap)) Q 
	;
	K vobj(+$G(rs2)) Q 
	;
COMP(dqtable,dqcol,cmp,RESERVED)	;
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
	S cmpuc=$$vStrUC(cmp)
	;
	I (($E(cmpuc,1,2)="S ")!($E(cmpuc,1,2)="D ")) D
	.	;
	.	N RM
	.	;
	.	; Invalid computed data item = 'di'
	.	S RM=$$^MSG(8316,$$^MSG(595),dqtable_"."_dqcol)
	.	S $ZS="-1,"_$ZPOS_","_"%DQ-E-DBMAP,"_$translate(RM,",","~") X $ZT
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
	.	I (($E(atom,1,2)="$$")) S isExtFn=1 Q 
	.	;
	.	Q:(delims[atom) 
	.	Q:($$vStrUC(atom)="$C") 
	.	Q:($$vStrUC(atom)="$E") 
	.	Q:($$vStrUC(atom)="$P") 
	.	Q:($$vStrUC(atom)="$S") 
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
nod(dbid,table,column)	;
	N vret
	;
	N dbmap S dbmap=$G(^DBMAP("COLUMNS",dbid,table,column))
	;
	S vret=$$tbl2nod($P(dbmap,$C(9),1)) Q vret
	;
tbl2nod(rdbtbl)	; RDB Table Name
	;
	N return S return=""
	;
	I ($E(rdbtbl,1,2)="W_") S return=$piece(rdbtbl,"_",$L(rdbtbl,"_"))
	;
	Q return
	;
nod2tbl(dbid,dqtable,node)	;
	;
	N rdbtable S rdbtable=dqtable
	;
	D MAP(dbid,.rdbtable)
	;
	I (rdbtable[",") D
	.	;
	.	I (node="") S rdbtable="ACN"
	.	E  S rdbtable="W_"_dqtable_"_"_node
	.	Q 
	;
	Q rdbtable
	;
RESWRD(oldname,RESERVED)	;
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
	.	N rs  N V1 S V1=newname S rs=$$vOpen7()
	.	I $$vFetch7(rs) S isResrvd=1
	.	K vobj(+$G(rs)) Q 
	;
	I isResrvd S newname="S_"_newname
	;
	Q newname
	;
MAPPING(dbid,table,MAP)	;
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
	.	N SPLIT S SPLIT=$$vStrUC(MAP(table,COLUMN))
	.	;
	.	S ERMSG=""
	.	;
	.	; Ignore columns not in schema
	.	Q:'$$isColumn^UCXDD(table,COLUMN) 
	.	;
	.	N colrec S colrec=$$getSchCln^UCXDD(table,COLUMN)
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
	.	I '($P(colrec,"|",14)=""),(SPLIT'="COMPUTED") D
	..		;
	..		S ERMSG=table_"."_COLUMN_" is a computed and must be mapped as 'Computed'"
	..		Q 
	.	I (SPLIT="COMPUTED"),($P(colrec,"|",14)="") D
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
	I haveERR S $ZS="-1,"_$ZPOS_","_"%DQ-E-DBMAP, Invalid mapping information" X $ZT
	;
	; Add any missing columns
	D ADDMISNG(dbid,table,.MAP,100)
	;
	Q 
	;
TSV	;
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
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
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
	N file S file=$$vClNew("IO")
	;
	S $P(vobj(file,1),"|",2)=$$PARSE^%ZFUNC(filename,"DIRECTORY")
	S $P(vobj(file,1),"|",1)=$$PARSE^%ZFUNC(filename,"NAME")_$$PARSE^%ZFUNC(filename,"TYPE")
	S $P(vobj(file,1),"|",3)="WRITE/NEWV"
	S $P(vobj(file,1),"|",4)=5
	;
	D
	.	N voZT set voZT=$ZT
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
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
LOADMAP(dbid,filename,table,MAP)	;
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
LOADFILE(filename,table,MAP)	;
	;
	N voZT set voZT=$ZT
	N i
	N TAB N X
	;
	S TAB=$char(9)
	;
	N file S file=$$vClNew("IO")
	;
	S $P(vobj(file,1),"|",2)=$$PARSE^%ZFUNC(filename,"DIRECTORY")
	S $P(vobj(file,1),"|",1)=$$PARSE^%ZFUNC(filename,"NAME")_$$PARSE^%ZFUNC(filename,"TYPE")
	S $P(vobj(file,1),"|",3)="READ"
	S $P(vobj(file,1),"|",4)=5
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
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
	.	S $ZS="-1,"_$ZPOS_","_"%DQ-E-DBMAP,"_$translate(ERMSG,",","~") X $ZT
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
	.	Q:($$vStrUC($piece(X,TAB,1))'=table) 
	.	;
	.	S COLUMN=$$vStrUC($piece(X,TAB,2))
	.	S SPLIT=$piece(X,TAB,3)
	.	;
	.	I (COLUMN="") D
	..		;
	..		N ERMSG
	..		; file name - Invalid format - Record i - COLUMN Column Cannot be NULL
	..		S ERMSG=$P(vobj(file,1),"|",6)_" - "_$$^MSG(1350)_" - "_$$^MSG(2326)_" "_i_" - "
	..		S ERMSG=ERMSG_"COLUMN "_$$^MSG(8557)
	..		;
	..		S $ZS="-1,"_$ZPOS_","_"%DQ-E-DBMAP,"_$translate(ERMSG,",","~") X $ZT
	..		Q 
	.	;
	.	I ($D(MAP(table,COLUMN))#2) D
	..		;
	..		; file name - table.COLUMN - Record i - already exists
	..		S $ZS="-1,"_$ZPOS_","_"%DQ-E-DBMAP,"_$P(vobj(file,1),"|",6)_" - "_$$^MSG(3019,table_"."_COLUMN_" - "_$$^MSG(2326)_" "_i_" -") X $ZT
	..		Q 
	.	;
	.	S MAP(table,COLUMN)=SPLIT
	.	Q 
	;
	K vobj(+$G(file)) Q 
	;
ADDMISNG(dbid,table,MAP,SPLIT)	;
	;
	N COLUMN N DFTMAP N SPLITSUB
	;
	D ^USTMAPDF(dbid,table,.DFTMAP)
	;
	N rs,vos1,vos2,vos3,vos4,vOid  N V1 S V1=table S rs=$$vOpen8()
	;
	F  Q:'($$vFetch8())  D
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
vSIG()	;
	Q "60731^85524^Dan Russell^24228" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vOpen3()	; PSLBOOT result set for STBLRESERVED
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","STBLRESERVED"))#2) Q $$vOpen2()
	N vRws S vRws=commands("boot","STBLRESERVED")
	N vOid S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-5)=2
	S vobj(vOid,-2)="$$vFetch3^"_$T(+0)
	S vobj(vOid,-3)="WORD"
	S vobj(vOid,-4)="T0"
	S vobj(vOid,0)=1
	S vobj(vRws,0)=0 
	I $$vFetch3(vOid) S vobj(vOid,0)=2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vFetch3(vOid)	; PSLBOOT fetch for STBLRESERVED
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","STBLRESERVED"))#2) Q $$vFetch2(vOid)
	N vRws S vRws=commands("boot","STBLRESERVED")
	I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
	N vR
	S vobj(vOid,0)=$$vRwsNxt(vRws)
	S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
	S vobj(vOid)=$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"WORD"))
	S vret=vobj(vOid,0) Q vret
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vOpen7()	; PSLBOOT result set for STBLRESERVED
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","STBLRESERVED"))#2) Q $$vOpen6()
	N vRws S vRws=commands("boot","STBLRESERVED")
	N vOid S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-5)=2
	S vobj(vOid,-2)="$$vFetch7^"_$T(+0)
	S vobj(vOid,-3)="WORD"
	S vobj(vOid,-4)="T0"
	S vobj(vOid,0)=1
	S vobj(vOid,1)=$G(NEWNAME) I vobj(vOid,1)="" Q 
	S vobj(vRws,0)=0 
	I $$vFetch7(vOid) S vobj(vOid,0)=2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vFetch7(vOid)	; PSLBOOT fetch for STBLRESERVED
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","STBLRESERVED"))#2) Q $$vFetch6(vOid)
	N vRws S vRws=commands("boot","STBLRESERVED")
	I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
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
	;  #OPTION ResultClass 0
vRwGC(vList,vRef)	; Dynamic column position lookup
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (vRef="") Q ""
	I +vRef>0 Q vRef
	;
	S vList=$$vStrUC(vList) S vRef=$$vStrUC(vRef)
	N vP S vP=$F((vList_",")," "_vRef_",")
	I vP=0 S vP=$F((","_vList_","),","_vRef_",") I vP=0 Q ""
	Q $L($E(vList,1,vP-$L(vRef)),",")
	;
vClNew(vCls)	;	Create a new object
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls
	Q vOid
	;
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBMAP,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBMAP"
	S vobj(vOid)=$G(^DBMAP("COLUMNS",v1,v2,v3))
	I vobj(vOid)="",'$D(^DBMAP("COLUMNS",v1,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb5(v1,v2,v2out)	;	voXN = Db.getRecord(DBMAPT,,1,-2)
	;
	N dbmapt
	S dbmapt=$G(^DBMAP("TABLES",v1,v2))
	I dbmapt="",'$D(^DBMAP("TABLES",v1,v2))
	S v2out='$T
	;
	Q dbmapt
	;
vDb6(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb7(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(DBMAP)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBMAP",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^DBTBL("SYSDEV",1,vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	WORD FROM STBLRESERVED
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch2^"_$T(+0)
	S vobj(vOid,-3)="WORD"
	S vobj(vOid,-4)="T0"
	D vL2a1
	Q vOid
	;
vL2a0	S vobj(vOid,0)=0 Q
vL2a1	S vobj(vOid,1)=""
vL2a2	S vobj(vOid,1)=$O(^STBL("RESERVED",vobj(vOid,1)),1) I vobj(vOid,1)="" G vL2a0
	Q
	;
vFetch2(vOid)	;
	;
	;
	I vobj(vOid,0)=1 D vL2a2
	I vobj(vOid,0)=2 S vobj(vOid,0)=1
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid)=$S(vobj(vOid,1)=$C(254):"",1:vobj(vOid,1))
	;
	Q 1
	;
vOpen4()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID='ACN'
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=""
vL4a2	S vos2=$O(^DBTBL("SYSDEV",1,"ACN",9,vos2),1) I vos2="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen5()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V2
	;
	;
	S vos3=2
	D vL5a1
	Q ""
	;
vL5a0	S vos3=0 Q
vL5a1	S vos4=$G(V2) I vos4="" G vL5a0
	S vos5=""
vL5a3	S vos5=$O(^DBTBL("SYSDEV",1,vos4,9,vos5),1) I vos5="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos3=1 D vL5a3
	I vos3=2 S vos3=1
	;
	I vos3=0 Q 0
	;
	S rs=$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen6()	;	WORD FROM STBLRESERVED WHERE WORD=:V1
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch6^"_$T(+0)
	S vobj(vOid,-3)="WORD"
	S vobj(vOid,-4)="T0"
	D vL6a1
	Q vOid
	;
vL6a0	S vobj(vOid,0)=0 Q
vL6a1	S vobj(vOid,1)=$G(V1) I vobj(vOid,1)="" G vL6a0
	I '($D(^STBL("RESERVED",vobj(vOid,1)))#2) G vL6a0
	Q
	;
vFetch6(vOid)	;
	;
	;
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid,0)=100
	S vobj(vOid)=vobj(vOid,1)
	S vobj(vOid,0)=0
	;
	Q 1
	;
vOpen8()	;	DI FROM DBTBL1D WHERE FID=:V1 ORDER BY DI
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(V1) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL8a9
	S vos4=""
vL8a5	S vos4=$O(^DBTBL(vos3,1,vos2,9,vos4),1) I vos4="" G vL8a3
	S vd=$S(vos4=$C(254):"",1:vos4)
	S ^DBTMP($J,vOid,1,vos4,vos3)=vd
	G vL8a5
vL8a9	S vos2=""
vL8a10	S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL8a0
	S vos3=""
vL8a12	S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL8a10
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a12
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S rs=^DBTMP($J,vOid,1,vos2,vos3)
	;
	Q 1
	;
vReSav1(dbmap)	;	RecordDBMAP saveNoFiler()
	;
	S ^DBMAP("COLUMNS",vobj(dbmap,-3),vobj(dbmap,-4),vobj(dbmap,-5))=$G(vobj(dbmap))
	N vC,vS s vS=0
	F vC=1:450:$L($G(vobj(dbmap,1,1))) S vS=vS+1,^DBMAP("COLUMNS",vobj(dbmap,-3),vobj(dbmap,-4),vobj(dbmap,-5),vS)=$E(vobj(dbmap,1,1),vC,vC+449)
	Q
	;
vRwsNxt(vOid)	;	RowSet.next
	;
	N vLst S vLst=$O(vobj(vOid,""),-1)
	I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
	Q vobj(vOid,0)'>vLst
	;
vStrIsNum(vStr)	;	String.isNumber
	;
	Q vStr=+vStr
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S ER=1
	S RM=$P(error,",",4)
	Q 
	;
vtrap2	;	Error trap
	;
	N openerr S openerr=$ZS
	;
	D close^UCIO(file)
	;
	S $ZS=openerr X voZT
	Q 
	;
vtrap3	;	Error trap
	;
	N error S error=$ZS
	;
	D close^UCIO(file)
	;
	I '($P(error,",",3)["IOEOF") S $ZS=error X voZT
	Q 
