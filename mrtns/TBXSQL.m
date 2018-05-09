TBXSQL  ;Public;schema and data loading utility for Oracle/db2
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/03/03 14:45:49 - GIRIDHARANB
        ; ORIG: KWANL - 09/27/2005
        ; DESC: schema and data loading utility for Oracle/db2
        ;
        ; KEYWORDS:     ORACLE,DB2,SQLLDR
        ; LIBRARY:
	;	. SCRIPT   - Export data based on a SQL-based script file
        ;
	;	. EXT	   - External interface for IMPORT function
	;
	;	. DDL	   - SQL DDL create table statement
	;
	;	. DDLINDEX - SQL DDL create index statement
	;
	;	. LIST     - Return column list for a table
	;
	;	
	; I18N=QUIT
	;---- Revision History -------------------------------------------------
	; 2009-06-18, CR40964, Jaywant Khairnar
	;	* Added code to display the name of SQL log file
	;	* Added the name of SQL log file in the installation log file
	;
	; 2009-04-28, CR39019, Jaywant Khairnar
	;	* Changed the default Log directory to LOG instead of SPOOL
	;	* changed label of subroutine from obsscrpt to OBSDQW
	;	* added new subroutine CHECK to check customization,
	;		which will alwars return 1
	;
	; 2008-12-22, CR 37328, Frans S.C. Witte
	;	* Corrected dConstrt and eConstrt to NEW and initiate ER
	;
	; 06/26/2008	Ajitkumar - CR 34458
	;		Variable SQL New-ed in the dConstrt Section for deleting
	;		SCATBL entry.Modified CRTBL2 section to set the default 
	;		value for BLOB data type columns to empty_blob() .
	;
	;	        Removed call to DBMAPDFT, as this routine no longer exists.
	;
	; 02/20/2008	KWANL
	;		Added isTblExt to check if table exists in RDB or not.
	;		Modified CRTBL2 to prevent existing wide table to be 
	;		recreated.
	;
	; 01/29/2008	KWANL
	;		Fixed incorrect table name in isWdTbl section.
	;
	; 01/09/2008	KWANL
	;		Modified TBXSQL to treat DEPSEG and LNSEG as wide table.
	;		Unlike DEP and LN, DEPSEG and LNSEG will not split their
	;		column to mutliple tables. However it is prefixed with "W_"
	;		in front of the table name and suffix "_1" after the table name
	;		to distinguish them from regular table.
	;		For oracle database, please run the SQL scripts attached to CR31660
	;		in Profile_Framework_v27 view before using the latest TBX programs. 
	;		The SQL scripts will rename the DEPSEG and LNSEG table according 
	;		to our wide table specification and it will clean up the common columns
	;		that are shared between the parent and child table.  
	;
	;----------------------------------------------------------------------
	Q
	;
	;-----------------------------------------------------------------------
CRTABLE	; Purpose: Create tables
	;-----------------------------------------------------------------------
	n fid,$ZT
	S $ZT=$$SETZT^%ZT("ZRDB^TBXCOL")
	;
	I '$D(db) s db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	I db="GTM" Q
	;
	Q:'$D(^TMPSQL($J,"TABLE"))
	;
	s fid="" f  s fid=$O(^TMPSQL($J,"TABLE",fid)) q:fid=""  d
	.	d CRTBL(fid)
	.	d FILE^DBMAP(fid,db)
	.	S ER=0,RM=""
	k ^TMPSQL($J,"TABLE")	
	Q
	;	
	;----------------------------------------------------------------------
CRTBL(table)	; Create new table in schema
	; script based on DQ file definition
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;  . table	Table name		/TYP=U/REQ/MECH=VAL
	;               Sigle: Table_name
	;
	;----------------------------------------------------------------------
	N akeys,comment,cnt,count,di,from,fsn,i,keys,list,q,select,xdinam,LIBS
	N dec,def,desc,dinam,error,len,node,nullind,pos,req,sub,tlen,to,typ,x
	N fcount
	;
	I table["DBTBL" Q
	I '$D(^DBTBL("SYSDEV",1,table)) D  Q
	.	d logmsg^TBXDQUTL("Table "_table_" does not exist in ^DBTBL",zlogf)
	D CRTBL1(table)
	;
	Q
	;
	;-----------------------------------------------------------------------
CRTBL1(table)	; Create table definition
	;----------------------------------------------------------------------
	; DROP TABLE table_name
	; CREATE TABLE table_name
	; (
	; Column_name type [NOT NULL],
	; Column_name type,
	; Primary key
	; )
	; IN table_space
	; ;
	;----------------------------------------------------------------------
	;
	N comment,COLS,db,fsn,tblarr,tmptable,$ZT
	;
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	;
	I $G(db)="" S db=$$TRNLNM^%ZFUNC("SCAU_DB")
	S q="""",tlen=0
	S count=0,select=""
	S LIBS="SYSDEV"
	S comment=$G(^DBTBL(LIBS,1,table))		; Table description
	S comment=$TR(comment,"&'","+")
	D fsn^SQLDD(.fsn,table)				; Table attributes
	S akeys=$P(fsn(table),"|",3)			; Access keys
	;D BLDINDX^DBSDF9(table)			; Create dinam xref file
	;
	; logic for large tables
	I "DEP,LN"[table D  Q ;Wide table
        .       N N,list,spltnam,spltbl
        .	; get the wide table mapping
	.	D getWtblM(db,table,.COLS)
        .       S N=""
        .       F  S N=$O(COLS(table,N)) Q:N=""  D
        ..         N split
        ..         S split=COLS(table,N)
        ..         Q:split?1"C".E                      ; Skip computeds
        ..         Q:$D(^DBTBL("SYSDEV",1,"ACN",9,N))   ; Skip ACN
        ..         S spltbl(split,N)=""
        .       ; Deal with each split table
        .       S split=""
        .       F  S split=$O(spltbl(split)) Q:split=""  D
        ..         S list=akeys_","
        ..         S N=""
        ..         F  S N=$O(spltbl(split,N)) Q:N=""  I (","_akeys_",")'[(","_N_",") S list=list_N_","
        ..         S list=$E(list,1,$L(list)-1)
        ..         S spltname="W_"_table_"_"_split
        ..         D CRTBL2(spltname,table,list,akeys)
	;
	; DEPSEG and LNSEG are similar to regular table except names are different 
	; which prefix with "W_" and suffix  with "_1". The function $$LIST will return 
	; the proper data item list from DEPSEG and LNSEG table which will exclude the common 
	; data item between ACNSEG table except the keys.
	;
	; Regular Table
	I ((table="DEPSEG")!(table="LNSEG")) S tmptable="W_"_table_"_1"
	E  S tmptable=$$RESWRD^DBMAP(table)
	S list=$$LIST(table,$G(comp))		 	; Data item list
	S list=$P(list,",",1,9999)			; limit number of columns
	I list="" D ERROR("No columns in table "_table) Q
	D CRTBL2(tmptable,table,list,akeys)
	;
	Q
	;
	;-----------------------------------------------------------------------
CRTBL2(tmptable,proftbl,list,akeys)
	; the proftbl would not be empty so the following line is commented out
	;;I $G(proftbl)="" S proftbl=tmptable	;large table
	;-----------------------------------------------------------------------
	; make sure that the table didn't exists before creating it
	; e.g. W_LN_1 may already exists but not W_LN_11
	; if the table is already exists, quit
	; it will quit either -1 (error) or 1 already exists 
	I $$isTblExt(tmptable,zlogf) Q
	;
	N sqlstr
	;
	S sqlstr="CREATE TABLE "_tmptable_" ("
	;
	;						; 
	S cnt=$L(list,",")				; Total columns
	F i=1:1:cnt D
	.	S dinam=$P(list,",",i)			; data item name
	.	I $E(dinam)=q Q				; Dummy data item
	.	I dinam?1N.E Q
	.	S x=$G(^DBTBL(LIBS,1,proftbl,9,dinam)) 	; Item definition
	.	I $$isCmnCol(proftbl,dinam) Q
	.	I x="" D ERROR("Invalid column name "_proftbl_"."_dinam) Q
	.	S di=""""_$$RESWRD^DBMAP(dinam)_""""
	.	S node=$P(x,"|",1),len=$P(x,"|",2),def=$P(x,"|",3)
	.	S typ=$P(x,"|",9),dec=$P(x,"|",14)+0
	.	S sub=$P(x,"|",18),req=$P(x,"|",15),pos=$P(x,"|",21)
	.	S desc=$P(x,"|",10),cmp=$P(x,"|",16)
	.	S nullind=$P(x,"|",31)			; null indicator
	.	;I len>2000 S len=2000			; Maximum length
	.	S tlen=tlen+len
	.	I "UTF"[typ S tlen=tlen+4		; 4 bytes of overhead
	.	;
	.	S desc=$TR(desc,"&'","+")
	.	S comment(di)=desc			; pc 7/5/2001
	.	;
	.	S TYPE=$$type(typ,db)
	. 	S sqlstr=sqlstr_"  "_di_"  "_TYPE
	.	I (nullind=1)!(TYPE="CLOB") S sqlstr=sqlstr_$$getDef(def,typ,len)
	.	I (node?1N1"*") D
	..		S sqlstr=sqlstr_" NOT NULL"
	.	; E  s sqlstr=sqlstr_"  "_di_"  "_$$type(typ,db)
	.	; I def'="" D default(def,typ)
	.	; 
	.	S sqlstr=sqlstr_","
	.	S count=count+1				; Item counter
	;
	; removing the last comma.
	S sqlstr=$E(sqlstr,1,$L(sqlstr)-1)
	;Check keys for invalid names (i.e., reserved words)
	;if reserved word, add "S_" to the front.
	S akeys=$$replace(akeys)	;replace invalid column names
	;
	; I akeys'="" s sqlstr=sqlstr_", CONSTRAINT pk_"_tmptable_" PRIMARY KEY ("_akeys_")"
	I akeys'="" s sqlstr=sqlstr_", PRIMARY KEY ("_akeys_")"
	S sqlstr=sqlstr_")"
	;
	; W !,sqlstr,!
	D logmsg^TBXDQUTL("Creating table : "_tmptable,zlogf,1)
	D DBAPI(sqlstr)
	D:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	D comment(tmptable)			; comments
	Q				; Text
	;
	;----------------------------------------------------------------------
comment(table) ; table and column comments
	;----------------------------------------------------------------------
	N SQL
	S SQL="COMMENT ON TABLE "_table_" IS "_$$QADD^%ZS(comment,"'")
	; W !,SQL,!
	D DBAPI(SQL)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	;							
	S di="" F  S di=$O(comment(di)) Q:di=""  D
	.	S SQL="COMMENT ON COLUMN "_table_"."_di_" IS "_$$QADD^%ZS(comment(di),"'")	; column description
	.	; w !,SQL,!	
	.	D DBAPI(SQL)
	.	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	.	K comment(di)
	Q
	;
	;----------------------------------------------------------------------
type(typ,db) ; convert DQ data type
	;----------------------------------------------------------------------
	;
	N TYPE,x
	S TYPE=""
	I db="ORACLE" DO  quit TYPE   				    ;Oracle format
	.	I typ="L" S TYPE="CHAR(1)" Q
	.	I typ="N" D  S TYPE=x Q
	..		I 'dec,len<10 s x="NUMBER" Q		; Max 9 digits(code
	..		I 'dec  s x="NUMBER("_len_")" Q		; Max 30 digits(account)
	..		I dec,dec>len s len=dec+1		; Length error?
	..		S x="NUMBER("_len_","_dec_")" Q		; Example:INTEREST RATE
	.	I typ="$" S TYPE="NUMBER("_(len+2)_","_dec_")" Q	;Currency
	.	I typ="D" D  S TYPE=x Q
	..		S x="NUMBER" Q				; Date
	..		S x="INTEGER" Q				; !!! what is this ?!!!!!
	.	;I typ="C" S TYPE="TIME" Q			;timestamp
	.	I typ="C" S TYPE="VARCHAR2("_len_")" Q		;timestamp
        .       I typ="M" D  Q
        ..		I len>4000 s TYPE="CLOB"
 	..		E  S TYPE="VARCHAR2("_len_")"
        .       I typ="B" S TYPE="BLOB" Q
	.	S TYPE="VARCHAR2("_len_")"
	;-----------------------------------------------------------------	
	;DB2 Format
	I typ="L" Q "CHARACTER(1)"
	I typ="N" D  Q x
	.       I len>9 S x="BIGINT" Q                ; DB2numeric(V5.2)*^
	.	I 'dec,len<10 s x="INTEGER" Q
	.       I dec,dec>len s len=dec+1               ; Length error?
 	.       S x="DECIMAL("_len_","_dec_")" Q
	I typ="$" Q "DECIMAL("_(len+2)_","_dec_")"      ; Currency
	I typ="D" D  Q x
        .       S x="DATE" Q                            ; Date
        .       S x="FLOAT" Q                         ;
        I typ="C" Q "TIME"                              ; time stamp
        ;I typ="C" Q "VARCHAR2("_len_")"                ; time stamp
        Q "VARCHAR("_len_")"                           ; String 1 to 32767 char
	;
	;----------------------------------------------------------------------
replace(keys,del); Replace invalid data item names w/ valid names.
	;-----------------------------------------------------------------------
	;	  Invalid names are names that are reserved keywords in
	;	  Oracle, DB2 and other commercial databases and also names
	;	  that contain invalid characters, such as %.
	;----------------------------------------------------------------------
	N I,x
	;
	I $G(del)="" S del=","
	E  S del=$C(del)
	F I=1:1:$L(keys,del) D				
	.	N x
	.	S x=$P(keys,del,I)
	.	q:x=""
	.	s x=$$RESWRD^DBMAP(x)
	.	;I $E(x)="%" S x="X"_$E(x,2,99)
	.	;I $D(^STBL("RESERVED",x)) S x="S_"_x
	.	S $P(keys,del,I)=x
	Q keys
	;
	;----------------------------------------------------------------------
ERROR(msg)	; Log error message
	;----------------------------------------------------------------------
	N seq
	S seq=$O(error(""),-1)+1
	S error(seq)=msg
	Q
	;
	;-----------------------------------------------------------------------
DSPERR	;
	;-----------------------------------------------------------------------
	I '$D(error) Q
	F i=1:1 Q:'$D(error(i))  d logmsg^TBXDQUTL(error(i),zlogf)
	Q
	;
	;-----------------------------------------------------------------
vindex(keys,fid,index,indexnm,indtbl)
	;-----------------------------------------------------------------
	; Checks if the specified Profile index is valid in the new
	; schema by checking if all columns in the order-by sequence
	; belong to the same table name (applies to wide tables only)
	;
	; INPUT ARGUMENTS:
	;		keys	- Index Sequence Columns (input)
	;		fid	- Profile Table Name (input)
	;		index	- Profile Index ID (input)
	;
	; OUTPUT ARGUMENTS:
	;		indexnm - Index Name (output)
	;		indtbl	- Table Name that the index will be created on (output)
	;
	;-----------------------------------------------------------------
	N col,error,i,newtbl,tblarr
	;
	;; I '(",DEP,LN,"[fid) S indexnm=fid_"_"_index,indtbl=fid Q 0
	I '$$isWdTbl(fid) S indexnm=fid_"_"_index,indtbl=fid Q 0
	;
	s newtbl="",error=0
	I (fid="DEP")!(fid="LN") D
	.	D getWtblM(db,fid,.tblarr)
	.	F i=1:1:$L(keys,",") D
	..		s col=$P(keys,",",i) Q:col=""
	..		I i=1 S newtbl=$G(tblarr(fid,col)) Q
	..		I $g(tblarr(fid,col))'=newtbl S error=1
	I (fid="DEPSEG")!(fid="LNSEG") D
	.	F i=1:1:$L(keys,",") D
	..		s col=$P(keys,",",i) Q:col=""
	..		I i=1,$D(^DBTBL("SYSDEV",1,"ACNSEG",9,col)) S newtbl="ACNSEG" Q
	..		I i=1,'$D(^DBTBL("SYSDEV",1,"ACNSEG",9,col)) S newtbl=fid Q
	..		I $D(^DBTBL("SYSDEV",1,"ACNSEG",9,col)),newtbl'="ACNSEG" S error=1
	..		I '$D(^DBTBL("SYSDEV",1,"ACNSEG",9,col)),newtbl="ACNSEG" S error=1
	;
	I error s RM="Warning: Invalid index: "_fid_"_"_index Q 1  ;failure
	;
	I newtbl="ACN" S indexnm=newtbl_"_"_index,indtbl=newtbl Q 0
	I newtbl="ACNSEG" S indexnm=newtbl_"_"_index,indtbl=newtbl Q 0
	;
	;All columns in same split table.  return ind name and table name
	; DEPSEG or LNSEG table
	I (newtbl="DEPSEG")!(newtbl="LNSEG") D  Q 0
	.	S indexnm="W_"_fid_"_1_"_index
	.	S indtbl="W_"_fid_"_1"
	;
	; DEP or LN table
	S indexnm="W"_"_"_fid_"_"_newtbl_"_"_index
	S indtbl="W"_"_"_fid_"_"_newtbl
	Q 0  ;success
        ;
	;----------------------------------------------------------------------
LIST(table,computed,collen)	; Return column names
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	; . table	Table name		/TYP=U/REQ/MECH=VAL
	; . computed	Include computed items	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;
	; RETURNS:
	;
	; . $$		A list of column names in following order:
	;
	; 		Access keys
	; 		Required data items
	; 		others
	; 		computed data items (based on second parameter)
	;
	; . collen	A list of the column lengths
	;
	; . ER		Error flag
	; . RM		Error message
	;----------------------------------------------------------------------
	N comp,di,fsn,noreq,req,v
	;
	I table["," S ER=1,RM=$$^MSG(8564)	; Support single table only
	S ER=0,RM="",collen=""
	;
	S req="",noreq=""
	;
	D fsn^SQLDD(.fsn,table)			; Table attributes
	I ER Q
	S req=$P(fsn(table),"|",3)		; Access keys
	;
	S di="" F  S di=$O(^DBTBL("SYSDEV",1,table,9,di)) Q:di=""  D
	.	I $E(di)="""" Q			; skip literals
	.	I di?.N Q			; skip literals
	.	I $$isCmnCol(table,di) Q
	.	S v=^DBTBL("SYSDEV",1,table,9,di)
	.	S collen(di)=$P(v,"|",2)
	.	;I $P(v,"|",18)'="" Q		; Skip sub-field
	.	I $P(v,"|",1)["*" Q		; Skip access key
	.	I $P(v,"|",16)'="",($P(v,"|",16)'=" ") Q ; Computed
	.	I $P(v,"|",17)=1 Q
	.	I $P(v,"|",15) S req=req_","_di Q	; Required
	.	;I $$isSfdMaster^UCXDD(table,di) Q
	.	;
	.	S noreq=noreq_","_di
	;
	S v=req_noreq
	I $E(v)="," S v=$E(v,2,9999)
	Q v
	;	 
	;----------------------------------------------------------------------
DBAPI(SQL)	; Process SQL statements
        ;----------------------------------------------------------------------
        ;
        n seq
	S ER=$$EXECUTE^%DBAPI("",SQL,,,.RM)
	;
	I (ER<0) d  Q 	; there is an error, no need to commit.
	.	s seq=$o(^TMPERR($J,""),-1)+1
	.	s ^TMPERR($J,seq)=$E($G(RM),1,512)
	;
	S ER=$$COMMIT^%DBAPI()
	I (ER<0) d
	.	s seq=$o(^TMPERR($J,""),-1)+1
	.	s ^TMPERR($J,seq)=$E($G(RM),1,512)
	;
	Q
	;
	;-----------------------------------------------------------------------
getidxky(tbl,idx);
	;-----------------------------------------------------------------------
	;
	n akey,fsn,i,k,key,query,seq,v
	;
	D fsn^SQLDD(.fsn,tbl)
	;I $G(ER) D ERROR(RM) k ER Q ""			; Invalid table name
	I $G(ER) Q ""
	S akey=$p(fsn(tbl),"|",3)			; Access keys
	I akey="" Q ""
	F i=1:1:$L(akey,",") S akey($P(akey,",",i))=""
	;
	S v=^DBTBL("SYSDEV",8,tbl,idx)		; index definition
	S query=$P(v,"|",7)			; with query condition
	S seq=$P(v,"|",3)			; index order by
	S key=""
	F i=1:1:$L(seq,",") D
	.	S k=$P(seq,",",i)
	.	I $E(k)="""" Q			; dummy key
	.	I $E(k)?1N Q
	.	I $E(k)="-" Q
	.	I akey'[",",$D(akey(k)) Q	; Remove access key
	.	S key=key_","_k	
	S key=$E(key,2,99)
	I key="",query'="" D			; missing column name
	.	S key=query			; find it in the query
	.	I key["." S key=$P(key,".",2)	; remove table name
	.	F i=1:1:$L(key) Q:$E(key,i)'?1A	; locate data item
	.	S key=$E(key,1,i-1)
	Q key
	;
	;----------------------------------------------------------------------
OBSTABLE; Obsolete table or columns 
	;----------------------------------------------------------------------
	;
	I '$D(db) s db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	I db="GTM" Q
	;
	Q:'$D(^TMPSQL($J,"obsolete"))
	;
	n FID,DI,col,sqlstr,table,$ZT
	;
	s table="" f  s table=$O(^TMPSQL($J,"obsolete",table)) q:table=""  d
	.	I $G(^TMPSQL($J,"obsolete",table))=1 d
	..		d obstbl(table)
	..		K ^TMPSQL($J,"obsolete",table)
	.		S ER=0,RM=""
	.	E  D
	..		;s FID=$$RESWRD^DBMAP(table)
	..		s col="" f  s col=$O(^TMPSQL($J,"obsolete",table,col)) q:col=""  d
	...			;;I "DEP,LN"[table s FID=$$getWtbl^TBXSQL(table,col)
	...			I $$isWdTbl(table) S FID=$$getWtbl^TBXSQL(table,col)
	...			E  s FID=$$RESWRD^DBMAP(table)
	...			I $G(FID)="" d  q
	....				d logmsg^TBXDQUTL("Error : unable to remove "_table_"."_col_" from database.",zlogf)
	...			;; I ("DEP,LN"[table),FID="ACN" Q
	...			I $$isWdTbl(table),((FID="ACN")!(FID="ACNSEG")) Q
	...			s DI=$$RESWRD^DBMAP(col)
	...			d obscol(FID,DI)
	...			; k ^TMPSQL($J,"obsolete",table,col)
	...			s ER=0,RM=""
	Q
	;
	;-----------------------------------------------------------------------
obstbl(table);
	;-----------------------------------------------------------------------
	;
	n FID,SQL
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	s FID=$$RESWRD^DBMAP(table)
	d logmsg^TBXDQUTL("Removing table : "_FID_" from RDB.",zlogf)
	S SQL=("SELECT COUNT(1) FROM USER_TABLES WHERE TABLE_NAME = '"_FID_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	I DATA'=1 D
	. d logmsg^TBXDQUTL("Warning : "_FID_" table does not exist in the database",zlogf)
	E  d
	. S SQL="DROP TABLE "_FID
	. D DBAPI(SQL)
	. d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	. d FILE^DBMAP(table,db)
	Q
	;	
	;-----------------------------------------------------------------------
obscol(table,col);
	;-----------------------------------------------------------------------
	n sqlstr,SQL
	;
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	;
	d logmsg^TBXDQUTL("Removing column "_DI_" from table "_FID,zlogf)
	S SQL=("SELECT COUNT(1) FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '"_FID_"' AND COLUMN_NAME = '"_DI_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	I DATA'=1 D
	. d logmsg^TBXDQUTL("Warning : Column "_DI_" does not exist in the table "_FID,zlogf)
	E  D
	. s SQL="ALTER TABLE "_FID_" DROP COLUMN "_DI
	. D DBAPI(SQL)
	. d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	. d FILE^DBMAP(table,db)
	Q
	;	
	;----------------------------------------------------------------------
UPDRDB	; Update index and foreign keys.
	;----------------------------------------------------------------------
	;
	I '$D(db) s db=$$TRNLNM^%ZFUNC("SCAU$DB")
	;
	I (db="GTM")!(db="") Q
	;
	d MODIFYFK,MODIFYID
	S ER=0
	Q
	;
	;----------------------------------------------------------------------
MODIFYTB; Modify columns
	;----------------------------------------------------------------------
	;
	n profcol,proftbl
	s proftbl="",profcol=""
	;
	I '$D(db) s db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	I db="GTM" Q
	;
	Q:'$D(^TMPSQL($J,"COLUMN"))
	;
	d logmsg^TBXDQUTL("Updating database schema...",zlogf)
	;
	s proftbl="" f  s proftbl=$O(^TMPSQL($J,"COLUMN",proftbl)) q:proftbl=""  d
	. s profcol="" f  s profcol=$O(^TMPSQL($J,"COLUMN",proftbl,profcol)) q:profcol=""  d
	.. D mdfcol(proftbl,profcol)
	.. S ER=0,RM=""
	. d FILE^DBMAP(proftbl,db)
	;
	; K ^TMPSQL($J,"COLUMN")
	Q
	;
	;----------------------------------------------------------------------
mdfcol(proftbl,profcol)
	; 
	;----------------------------------------------------------------------
	;
	n DATA,FID,LEN,REQ,SQL,TMPSTR,TYP,col,dec,dft,IsSubTyp,len,pos,table,typ
	n desc,defStr,mdef,metaData,mtype,mlen,mprec,mnull,nullind,reqStr,rowcnt,$ZT
	;
	I $E(profcol)="""" Q	; Literal
	I profcol?.n Q		; Literal
	Q:'$D(^DBTBL("SYSDEV",1,proftbl,9,profcol))
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	;
	if (profcol?.N)!($e(profcol))="""" quit	 ;ignore literal columns
	s TMPSTR=^DBTBL("SYSDEV",1,proftbl,9,profcol)
	;
	; 09/27/2005 KWANL
	I '$$rdb^UCDBRT(proftbl) Q 			; quit if it is not a RDB table
	I $P(TMPSTR,"|",16)'="",($P(TMPSTR,"|",16)'=" ") Q  ; quit if it is a computed column
	I $P(TMPSTR,"|",17)=1 Q				; quit if it is a master field
	;
	s len=$P(TMPSTR,"|",2)				; column length
	s dec=$P(TMPSTR,"|",14)+0			; decimal 
	s pos=$P(TMPSTR,"|",21)				; 
	S typ=$P(TMPSTR,"|",9)
	s dft=$P(TMPSTR,"|",3)				; default value
	S desc=$P(TMPSTR,"|",10)
	s nullind=$P(TMPSTR,"|",31)			; null indicator
	;
	; Required Column
	I $P(TMPSTR,"|",15)=1 S REQ="NOT NULL"
	E  S REQ=""
	;
	s IsSubTyp=0
	;;I "DEP,LN"[proftbl D
	I $$isWdTbl(proftbl) D
	. s table=$$getWtbl^TBXSQL(proftbl,profcol)
	. i (table="ACN")!(table="ACNSEG") s IsSubTyp=1
	E  D
	. S table=$$RESWRD^DBMAP(proftbl)
	;
	I IsSubTyp Q
	;
	I $G(table)="" d  q
	. d logmsg^TBXDQUTL("Error : wide table is not defined for "_proftbl_"."_profcol,zlogf)
	;
	S col=$$RESWRD^DBMAP(profcol)
	;
	s defStr=$$getDef(dft,typ,len)
	;
	i nullind=1,("$N"[typ),dft="" s dft=0
	;
	; ********* fix ******
	i typ="L" d
	. s REQ="NOT NULL"
	. i dft="Y" s dft=1
	. e  s dft=0
        ;
        ; SELECT DATA_TYPE, DATA_LENGTH, DATA_PRECISION, NULLABLE, DATA_DEFAULT, DATA_SCALE
	s metaData=$$getMData(table,col)
	Q:(ER<0)
	s mtype=$P(metaData,$C(9),1)
	s mlen=$P(metaData,$C(9),2)
	s mprec=$P(metaData,$C(9),3)
	s mnull=$P(metaData,$C(9),4)
	s mdef=$P(metaData,$C(9),5)
	s mdec=$P(metaData,$C(9),6)
	;
	; Modify column if it exists or add column if it does not exist.
	;
	S SQL=("SELECT COUNT(1) FROM USER_TAB_COLUMNS WHERE TABLE_NAME = '"_table_"' AND COLUMN_NAME = '"_col_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	;
	i DATA'=1 d		; add column
	.	s SQL="ALTER TABLE "_table_" ADD "_col_" "_$$type^TBXSQL(typ,db)_" "_defStr
	.	d execSQL(SQL)
	.	d cComment(table,col,desc)
	E  d	; modify column
	.	; if the data type of a column is already matched the data type
	.	; defined in RDB, don't specify the type again.
	.	n dataTyp s dataTyp=$$type^TBXSQL(typ,db)
	.	n rdbTyp s rdbTyp=$$getRdbTyp(mtype,mlen,mdec)
	.	i (dataTyp=rdbTyp) s dataTyp=""
	.	; if the column to be changed is not empty, it will not allow to change the type
	.	i (dataTyp'="")!(defStr'="") d
	..		s SQL="ALTER TABLE "_table_" MODIFY "_col_" "_dataTyp_" "_defStr
	..		d execSQL(SQL)	
	;
	s reqStr=REQ
	; if it is required in M and it is nullable in rdb set it to NOT NULL
	i mnull="Y",(REQ'="") s reqStr=" NOT NULL "
	; if it is not required in M and it is not nullabel in rdb set it to NULL
	I mnull="N",(REQ="") s reqStr=" NULL "
	; if it is required in M and it is not nullable in rdb, don't change it
	I mnull="N",(REQ'="") s reqStr=""
	;
	;	
	I reqStr'="" d
	.	; get row count
	.	; if rowcount=0 modify the column properties
	.	; if rowcount>0 update the NULL with default value then modify column properties
	.	s rowcnt=$$getrwcnt(table)
	.	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	.	Q:(ER<0)
	.	i (rowcnt=0)!(reqStr=" NULL ") d
	..		S SQL="ALTER TABLE "_table_" MODIFY "_col_" "_reqStr
	..		d execSQL(SQL)
	.	E  d
	..		S SQL=("UPDATE "_table_" SET "_col_" = '"_dft_"' where "_col_" IS NULL")
	..		D execSQL(SQL)
	..		S SQL=("ALTER TABLE "_table_" MODIFY "_col_" "_reqStr)
	..		d execSQL(SQL)
	;
	Q
	;
	;----------------------------------------------------------------------
MODIFYID;
	;----------------------------------------------------------------------
	;
	n profidx,proftbl
	;
	Q:'$D(^TMPSQL($J,"INDEX"))
	;
	s proftbl="" f  s proftbl=$O(^TMPSQL($J,"INDEX",proftbl)) q:proftbl=""  d
	. s profidx="" f  s profidx=$O(^TMPSQL($J,"INDEX",proftbl,profidx)) q:profidx=""  d
	.. d mdfindex(proftbl,profidx)
	.. S ER=0,RM=0
	;
	K ^TMPSQL($J,"INDEX")
	Q
	;
	;----------------------------------------------------------------------
mdfindex(proftbl,profidx)
	;----------------------------------------------------------------------
	;
	N DATA,indexnm,key,temptab,sqlstr,SQL,$ZT
	;
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	;
	I '$$rdb^UCDBRT(proftbl) Q 
	;
	S ER=0
	;
	I '$D(^DBTBL("SYSDEV",8,proftbl,profidx)) d  q
	. d logmsg^TBXDQUTL("Error : failed to modify index "_proftbl_"_"_profidx_" which does not exists in ^DBTBL",zlogf)
	;
	s key=$$getidxky(proftbl,profidx)
	I key="" D logmsg^TBXDQUTL("Invalid index definition "_proftbl_" ("_index_")",zlogf) Q
	;
	S ER=$$vindex(key,proftbl,profidx,.indexnm,.indtbl)
	I ER d logmsg^TBXDQUTL(RM,zlogf) Q
	;
	;Check keys for invalid names (i.e., reserved words)
	;if reserved word, add "_" to the front.
	S key=$$replace(key)
        s temptab=$$RESWRD^DBMAP(indtbl)
	;
	s indexnm="IDX_"_indexnm
	; prevent indentifier to be too long
	i $L(indexnm)>30 d
	. s indexnm=$E(indexnm,1,30)
	;
	S SQL=("SELECT COUNT(1) FROM USER_INDEXES WHERE INDEX_NAME = '"_indexnm_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	;
	; if index already exists, drop it.
	I DATA=1 D
	. s sqlstr="DROP INDEX "_indexnm
	. D DBAPI^TBXSQL(sqlstr)
	. d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_sqlstr_": "_RM,zlogf)   
	;
	s sqlstr="CREATE INDEX "_indexnm_" ON "_temptab_"("_key_") PCTFREE 10"
	;
	d logmsg^TBXDQUTL("Modifying index : "_indexnm,zlogf,1) 
	d DBAPI^TBXSQL(sqlstr)
	i $P($P(RM,":",1),"-",2)="01408" s ER=0,RM=""
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_sqlstr_": "_RM,zlogf)      
	Q
	;
	;----------------------------------------------------------------------
MODIFYFK;
	;----------------------------------------------------------------------
	;
	n profkey,proftbl
	;
	Q:'$D(^TMPSQL($J,"FOREIGN_KEY"))
	;
	s proftbl="" f  s proftbl=$O(^TMPSQL($J,"FOREIGN_KEY",proftbl)) q:proftbl=""  d
	. s profkey="" f  s profkey=$O(^TMPSQL($J,"FOREIGN_KEY",proftbl,profkey)) q:profkey=""  d
	.. d mdffkey(proftbl,profkey)
	.. s ER=0,RM=0
	;
	K ^TMPSQL($J,"FOREIGN_KEY")
	Q
	;
	;----------------------------------------------------------------------
mdffkey(tbl,key);
	;----------------------------------------------------------------------
	;
	n akey,command,fkyname,fparent,ftable,i,keys,newkey,parent,sqlstr,SQL,x,zkey,$ZT
	;
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	;
	I '$$rdb^UCDBRT(tbl) Q 
	;
	s ER=0,newkey=key
	;
	I '$D(^DBTBL("SYSDEV",19,tbl,newkey)) d  q
	. d logmsg^TBXDQUTL("Error : failed to modify foreign key "_tbl_"_"_newkey_" which does not exists in ^DBTBL",zlogf)
	;
	s x=^DBTBL("SYSDEV",19,tbl,newkey)
	s zkey=""
	S parent=$P(x,"|",5)
	S akey=$$replace^TBXSQL(newkey)
	S fparent=parent
	N error,table s table="",error=0
	F j=1:1:$L(newkey,",") D
	.	s ftable=tbl
	.	N fkey S fkey=$P(newkey,",",j)
	.	;  d FILE^DBMAP(db,ftable)
	.	D MAP^DBMAP(db,.ftable,.fkey)
	.	; d FILE^DBMAP(db,fparent)
	.	D MAP^DBMAP(db,.fparent,.fkey)
	.	S zkey=zkey_","_fkey
	.	S akey=$E(zkey,2,99)
	.	I j=1 s table=ftable Q
	.	I table'=ftable s error=1
	;
	I error d logmsg^TBXDQUTL("Error: Invalid foreign key "_tbl_"_"_newkey_" which reference more than one table",zlogf) Q
	s fkyname="FKY_"_tbl_"_"_$$TRKEY^TBXFKEY(key)
	;
	; prevent identifier to be too long.
	i $L(fkyname)>30 d
	. s fkyname=$E(fkyname,1,30)
	;
	S SQL=("SELECT COUNT(1) FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = '"_fkyname_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	; 
	; if constraint already exists, use modify otherwise use add.
	I DATA=1 d
	. s sqlstr="ALTER TABLE "_ftable_" DROP CONSTRAINT "_fkyname
	. d DBAPI^TBXSQL(sqlstr)
	. d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_sqlstr_": "_RM,zlogf)
	;
	s sqlstr="ALTER TABLE "_ftable_" ADD CONSTRAINT "_fkyname_" FOREIGN KEY ("_akey_") REFERENCES "_fparent_" ON DELETE CASCADE INITIALLY DEFERRED DEFERRABLE"
	;
	d logmsg^TBXDQUTL("Modifying foreign key : "_fkyname,zlogf,1)
	d DBAPI^TBXSQL(sqlstr)
	;; RM="ORA-02275: such a referential constraint already exists in the table"
	;; suppress error for duplicate constraint.
	I $P($P(RM,":",1),"-",2)="02275" s ER=0,RM=""
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_sqlstr_":  "_RM,zlogf)
	;
	Q
	;
	;----------------------------------------------------------------------
getMData(tbl,col); Get metadata.
	;----------------------------------------------------------------------
	;
	n SQL
	S SQL="SELECT DATA_TYPE, DATA_LENGTH, DATA_PRECISION, NULLABLE, DATA_DEFAULT, DATA_SCALE"
	s SQL=SQL_" FROM USER_TAB_COLUMNS"
	S SQL=SQL_" WHERE TABLE_NAME = '"_tbl_"' AND COLUMN_NAME = '"_col_"'"
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	Q DATA
	;
	;----------------------------------------------------------------------
getrwcnt(tbl); Get row count
	;----------------------------------------------------------------------
	n SQL
	s SQL="SELECT COUNT(*) FROM "_tbl
	s ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	Q DATA
	;
	;----------------------------------------------------------------------
ZRDB    ; Error trap for relational database element load 
        ;----------------------------------------------------------------------
        ;
	N X
	S X=$ZSTATUS
	S ER=1
        d logmsg^TBXDQUTL("Failed to load relational database element. "_X,zlogf)
        ;
        Q
        ;  
        ;----------------------------------------------------------------------
cComment(table,col,desc); create comment
	;----------------------------------------------------------------------
	;
	n comment    
	;S comment="COMMENT ON COLUMN "_table_"."_col_" IS '"_desc_"'"	; column description	
	S comment="COMMENT ON COLUMN "_table_"."_col_" IS "_$$QADD^%ZS(desc,"'")   ; columnn description
	D DBAPI(comment)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	Q
	;
	;----------------------------------------------------------------------
getWtbl(proftbl,profcol); Get wide table name
	;----------------------------------------------------------------------
	;
	n COLS,spltbl
	;
	I '$$isWdTbl(proftbl) Q ""
	;
	I ((proftbl="DEP")!(proftbl="LN")),$D(^DBTBL("SYSDEV",1,"ACN",9,profcol)) Q "ACN"
	I ((proftbl="DEPSEG")!(proftbl="LNSEG")),$D(^DBTBL("SYSDEV",1,"ACNSEG",9,profcol)) Q "ACNSEG"
	;
	; for DEPSEG and LNSEG, there is no need to look up the mapping information as there will be
	; only 1 table. ie W_LNSEG_1 or W_DEPSEG_1
	;
	I (proftbl="DEPSEG")!(proftbl="LNSEG") Q "W_"_proftbl_"_1"
	;
	; get wide table mapping.
	D getWtblM(db,proftbl,.COLS)
	s spltbl=$G(COLS(proftbl,profcol))
	;
	i $G(spltbl)="" Q ""
	Q "W_"_proftbl_"_"_spltbl
	;
	;----------------------------------------------------------------------
dConstrt(FID); Disabling table constraint to allow data to update.
	;----------------------------------------------------------------------
	n ctbl,ER,fkey,SQL,SQLCUR,vCurID,vd,vER,vRM
	;
	I '$D(db) S db=$$TRNLNM^%ZFUNC("SCAU$DB")
	s:db="" db="GTM"
	Q:(db="GTM")
	;
	Q:$D(^TMPSQL($J,"constraints",FID))	; constraints already disabled.
	;
	s ^TMPSQL($J,"constraints",FID)=""
	;
	s SQLCUR="select t.constraint_name, t.table_name FROM user_constraints t, user_constraints r"
	s SQLCUR=SQLCUR_" WHERE t.r_constraint_name = r.constraint_name"
	S SQLCUR=SQLCUR_" AND t.r_owner = r.owner "
	s SQLCUR=SQLCUR_" AND t.constraint_type='R'"
	s SQLCUR=SQLCUR_" AND r.table_name = '"_FID_"'"
	S ER=0,vER=$$OPENCUR^%DBAPI(0,SQLCUR,$C(9),"",.vCurID,.vd,.vRM)
        F  q:(vER=100)  d
	. S fkey=$P(vd,$C(9),1)
	. s ctbl=$P(vd,$C(9),2)
	. d logmsg^TBXDQUTL("Disabling constraint: "_fkey)
	. S SQL="ALTER TABLE "_ctbl_" DISABLE CONSTRAINT "_fkey
	. D DBAPI^TBXSQL(SQL)
	. D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(RM))
	. S vER=$$FETCH^%DBAPI(0,vCurID,1,$C(9),.vd,.vRM)
	;
	s:(vER'=100) ER=$$CLOSECUR^%DBAPI("",vCurID)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(vRM))
	Q
	;
	;----------------------------------------------------------------------
eConstrt; Enabling table constraints after all data are updated to DB.
	;----------------------------------------------------------------------
	n ctbl,ER,fkey,FID,SQLCUR,vCurID,vd,vER,vRM
	;
	I '$D(db) S db=$$TRNLNM^%ZFUNC("SCAU$DB")
	s:db="" db="GTM"
	q:db="GTM"
	;
	Q:'$D(^TMPSQL($J,"constraints"))
	;
	s FID="" f  s FID=$O(^TMPSQL($J,"constraints",FID)) q:FID=""  d
	. s SQLCUR="select t.constraint_name, t.table_name FROM user_constraints t, user_constraints r"
	. s SQLCUR=SQLCUR_" WHERE t.r_constraint_name = r.constraint_name"
	. S SQLCUR=SQLCUR_" AND t.r_owner = r.owner "
	. s SQLCUR=SQLCUR_" AND t.constraint_type='R'"
	. s SQLCUR=SQLCUR_" AND r.table_name = '"_FID_"'"	
	. S ER=0,vER=$$OPENCUR^%DBAPI(0,SQLCUR,$C(9),"",.vCurID,.vd,.vRM)
        . F  q:(vER=100)  d
	.. S fkey=$P(vd,$C(9),1)
	.. s ctbl=$P(vd,$C(9),2)
	.. d logmsg^TBXDQUTL("Enabling constraint "_fkey)
	.. S SQL="ALTER TABLE "_ctbl_" MODIFY CONSTRAINT "_fkey_" ENABLE NOVALIDATE"
	.. D DBAPI^TBXSQL(SQL)
	.. D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(RM))
	.. S vER=$$FETCH^%DBAPI(0,vCurID,1,$C(9),.vd,.vRM)
	. s:(vER'=100) ER=$$CLOSECUR^%DBAPI("",vCurID)
	. d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(vRM))
	;
	k ^TMPSQL($J,"constraints")			; clean up
	;
	Q
	;	
	;----------------------------------------------------------------------
getDef(default,type,len); Get default String;
	;----------------------------------------------------------------------	
	;
	; set default value to "" if it contains punctuation
	; ie $,<,>,.,*,abc^abc
	i default?.E1P.E Q ""
	;
	i type="L",default="Y" Q " DEFAULT 1"
	i type="L" Q " DEFAULT 0"
	;
	i type="M",len>4000 Q " DEFAULT empty_clob()"
	i type="B" Q " DEFAULT empty_blob()"
	;
	i "N$"[type,default'="" Q " DEFAULT "_default
	; 
	; i "N$"[type,default="" Q " DEFAULT "_0
	;
	i default'="","%IDENTIFIER,SYSTEMCURRENCY,CURRENTDATE,CURRENTTIME,SYSTEMDATE,USERID,TELLERLOC"[$$UPCASE(default) Q ""
	i default'="" Q " DEFAULT "_default
	Q ""
	;
	;----------------------------------------------------------------------
execSQL(SQL) ; execute SQL statment
	;----------------------------------------------------------------------	
	D DBAPI^TBXSQL(SQL)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR :"_SQL_": "_RM,zlogf)
	Q
	;
	;---------------------------------------------------------------------
sqllog(build,zlogf)	; Log SQL error to a different file.
	;---------------------------------------------------------------------
	i '$D(^TMPERR($J)) Q
	;
	n errseq,errbr,ok,sqlerr
	s $P(errbr,"*",50)=""
	s sqlerr=$$SCAU^%TRNLNM("LOG_DIR","SQLERR_"_build_"_"_$J_".LOG")
	s ok=$$FILE^%ZOPEN(sqlerr,"WRITE/NEWV",5)
	i +ok=0 D
	.	s sqlerr=$$SCAU^%TRNLNM("SPOOL","SQLERR_"_build_"_"_$J_".LOG")
	.	s ok=$$FILE^%ZOPEN(sqlerr,"WRITE/NEWV",5)
	i +ok=0 d logmsg^TBXDQUTL("Error unable to open SQL log file "_$P(ok,"|",2),zlogf) Q
	i ok d logmsg^TBXDQUTL("Name of SQL log file: "_sqlerr,zlogf)
	s errseq="" f  s errseq=$O(^TMPERR($J,errseq)) q:errseq=""  d
	.	u sqlerr w ^TMPERR($J,errseq),!,errbr,!
	c sqlerr
	k ^TMPERR($J)	
	Q
	;
	;--------------------------------------------------------------------
getCnStr(); read database connection information from dbi.ini file
	;--------------------------------------------------------------------
	n io,ok,pwd,sid,uid
	s io=$$TRNLNM^%ZFUNC("SCAU_DB_INI")
	i io="" d logmsg^TBXDQUTL("Error SCAU_DB_INI is not defined.",zlogf) q ""
	s ok=$$FILE^%ZOPEN(io,"READ",5)
	i +ok=0 d logmsg^TBXSQUTL("Error unable to open dbi.ini file to read "_$P(ok,"|",2),zlogf) q ""
	u io 
	r line s sid=$P(line,"=",2)
	r line s uid=$P(line,"=",2)
	r line s pwd=$P(line,"=",2)
	c io
	q uid_"/"_pwd_"@"_sid
	;
	;--------------------------------------------------------------------
OBSDQW(sqlfile); remove obsolete function or package from database
	;--------------------------------------------------------------------
	n SQL
	I $G(db)="GTM" Q 1
	;
	I sqlfile'["_" s SQL="DROP PACKAGE """_$P(sqlfile,".",1)_""""
	E  s SQL="DROP FUNCTION """_$P(sqlfile,".",1)_""""
	d execSQL(SQL)
	Q 1
	;
	;--------------------------------------------------------------------
regnproc; Recompile stored procdure if there is schema change
	;--------------------------------------------------------------------
	;
	n proftbl,status,X
	;
	Q:(('$D(^TMPSQL($J,"COLUMN")))&('$D(^TMPSQL($J,"obsolete"))))
	;
	d logmsg^TBXDQUTL("Recompiling stored procedures.",zlogf)
	;
	s proftbl="" f  s proftbl=$O(^TMPSQL($J,"COLUMN",proftbl)) q:proftbl=""  d
	.	s X=$$REGENSP^DBSDBASE(proftbl)
	.	i X'=0 d
	..		d logmsg^TBXDQUTL("Failed to recompile stored procedure for "_proftbl_".",zlogf)
	;
	s proftbl="" f  s proftbl=$O(^TMPSQL($J,"obsolete",proftbl)) q:proftbl=""  d
	.	Q:$D(^TMPSQL($J,"COLUMN",proftbl))
	.	s X=$$REGENSP^DBSDBASE(proftbl,.proc)
	.	i X'=0 d
	..		d logmsg^TBXDQUTL("Failed to recompile stored procedure for "_proftbl_".",zlogf)
	;
	K ^TMPSQL($J,"COLUMN")
	k ^TMPSQL($J,"obsolete")
	Q	
	;
	;-----------------------------------------------------------------------
UPCASE(string) ;private String; Translate to uppercase (simple ASCII only)
	;-----------------------------------------------------------------------
	quit $TR(string,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")	
	;
	;-----------------------------------------------------------------------
getRdbTyp(type,len,dec)
	;-----------------------------------------------------------------------
	;
	i type="INTEGER" Q "INTEGER"
	i type="CLOB" Q "CLOB"
	i type="BLOB" Q "BLOB"
	i type="NUMBER",len="" Q "NUMBER"
	i type="NUMBER",len'="",dec="" Q "NUMBER("_len_")"
	i type="NUMBER",len'="",dec'="" Q "NUMBER("_len_","_dec_")"
	i type="VARCHAR2" Q "VARCHAR2("_len_")"
	i type="CHAR" Q "CHAR(1)"
	Q ""	
	;
	;----------------------------------------------------------------------
isWdTbl(tbl); Return if a table is a wide table or not. ie DEP,LN,DEPSEG,LNSEG
	;----------------------------------------------------------------------
	I (tbl="DEP")!(tbl="LN")!(tbl="DEPSEG")!(tbl="LNSEG") Q 1
	Q 0
	;
	;----------------------------------------------------------------------
getWtblM(db,fid,map); Return wide table mapping for DEP or LN.	
	;----------------------------------------------------------------------
	;
	I '(",DEP,LN,"[fid) Q
	; D MAP^DBSDDMAP(fid,.tblarr)
	;;I $$VALID^%ZRTNS("DBMAPDFT") do MAPPING^DBMAP(db,fid,.map)
	I $$VALID^%ZRTNS("USTMAPDF") do MAPPING^DBMAP(db,fid,.map) Q
	I '$$VALID^%ZRTNS("USTMAPDF"),'$$VALID^%ZRTNS("DBMAPDFT") do MAP^DBSDDMAP(fid,.map)
	Q
	;
	;----------------------------------------------------------------------
isCmnCol(proftbl,dinam); Return if a data item is in its parent table or not.
	;----------------------------------------------------------------------
	; CID is the key for ACN, DEP and LN table.
	; CID, SEGMENT is the key for ACNSEG, DEPSEG and LNSEG.
	; Return 1 if the data itme is in its parent table as well as in child table but not a key
	;        0 if not in parent table or it is a key.
	;
	I "DEP,LN"[proftbl,$D(^DBTBL(LIBS,1,"ACN",9,dinam)),dinam'="CID" quit 1
	I ((proftbl="DEPSEG")!(proftbl="LNSEG")),$D(^DBTBL(LIBS,1,"ACNSEG",9,dinam)),'((dinam="CID")!(dinam="SEGMENT")) quit 1
	Q 0
	;
	;----------------------------------------------------------------------
isTblExt(proftbl,log); Check if table exists in RDB or not
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	; . proftbl	Table name		/TYP=T/REQ/MECH=VAL
	; . log		Error logger		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;
	; . $$		if table exists in database
	;			1  : if exists
	;			0  : not exists
	;			-1 : error
	;----------------------------------------------------------------------	
	; 
	N DATA,SQL
	S SQL=("SELECT COUNT(1) FROM USER_TABLES WHERE TABLE_NAME = '"_proftbl_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	I ER<0 D logmsg^TBXDQUTL("SQL Error : "_SQL_"$C(10)"_RM,log) Q -1
	Q DATA
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME)		; check for customization
	;-----------------------------------------------------------------------
	;
	Q 1
	;