TBXSQL	;Public;schema and data loading utility for Oracle/db2 
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
	;---- Revision History ------------------------------------------------
	; 04/05/2007	KWANL
	;		Modifed comment section to use QADD^%ZS to add a layer of 
	;		single quote.
	;
	; 2/21/2007	KWANL
	;		Modified to skip close cursor if vER=100 and vd="".
	;
	; 01/22/2006	KWANL
	;		Changed RM to vRM in dConstrt and eConstrt section.
	;
	; 11/14/2006	KWANL
	;		Added Fetch in eConstr and dConstrt.
	;
	; 11/06/2006	KWANL
	;		Added an additional parameter to MAPPING^DBMAP.
	; 
	; 11/06/2006	KWANL
	;		Per Dan modifed CRTBL1 for CR22519.
	;
	; 10/20/2006	KWANL
	;		Per Badri modified the eConstrt, dConstrt, type and mdfcol section.
	;
	; 09/15/2006	KWANL
	;		Add quoted around the SQL function name
	;
	; 07/06/2006	KWANL
	;		Removed drop package body statement.
	;
	; 06/28/2006	KWANL
	;		Per Badri added "ON DELETE CASCADE" for foreign key and 
	;		check if a column required on the DQ DD and has a null 
	;		default on the Oracle side
	;
	; 06/22/2006	KWANL
	;		Fixed the code to determine if the column is required or not
	;
	; 05/24/2006	KWANL
	;		Modified to remove PACKAGE BODY after PACKAGE is removed.
	;
	; 05/03/2006	KWANL
	;		Added regnproc section to recompile stored procedures
	;		if there are schema changes
	;
	; 04/06/206	KWANL
	;		Modified getWtbl section to return the parent table if the 
	;		column is a sub-type.
	;
	; 02/15/2006	KWANL
	;		Modified LIST section to include memo and blob data type.
	;		The memo and blob data types have piece 16 set to a space " ".
	;
	; 02/09/2006	KWANL
	;		Added getCnStr section to get database connection information.
	;		Added obsscrpt section to remove function or package from database.
	;
	; 02/08/2006	KWANL
	;		Modified OBSTABLE section to handle column in wide table.
	;
	; 02/07/2006	KWANL
	;		Modified not to set column max len in CRTBL2 section 
	;
	; 02/03/2006	KWANL
	;		Added sqllog section to log SQL related error to a different file
	;		in the spool directory.
	;	
	; 01/30/2006	KWANL
	;		Modified type section to use LONG when the lenght of B or M
	;		type are more than 4000.
	;		Simplified mdfcol section.
	;		Set ER=0 after add/modify schema changes.
	;
	; 01/16/2006	KWANL
	;		Moved disable and enable constraints code here.
	;
	; 01/05/2006    KWANL 
	;               Modified the mdfcol section to allow schema change when 
	;               the column contains no null record and the default 
	;               value of the column is null. 
	;
	; 01/04/2006	KWANL
	;		Added getWtbl to retrieve wide table name. Modified mdfcol
	;		to deal with wide table.
	;		Merged Pete's changes.
	;
	; 12/13/2005    RussellDS 
	;               Modified CRTBL1 code for split tables due to change 
	;               in DBMAP. 
	; 
	; 10/21/2005	KWANL
	;		Added code to check if it is a masterfield.
	;
	; 10/20/2005	KWANL
	;		Modified OBSTABLE to check if table/column exists, before 
	;		dropping it from RDB. 
	;
	; 10/19/2005	KWANL
	;		Created OBSTABLE section to drop table or column from 
	;		relational database.
	;
	; 10/18/2005	KWANL
	;		This routine is copied from SQUTIL.m 
	;
	;----------------------------------------------------------------------
	Q
	;
	;***********************************************************************
CRTABLE	; Purpose: Create tables
	;***********************************************************************
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
	N dec,def,desc,dinam,error,len,node,pos,req,sub,tlen,to,typ,x,nullind
	N fcount
	;
	I table["DBTBL" Q
	I '$D(^DBTBL("SYSDEV",1,table)) D  Q
	.	d logmsg^TBXDQUTL("Table "_table_" does not exist in ^DBTBL",zlogf)
	D CRTBL1(table)
	;
	Q
	;
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
	N comment,fsn,tblarr,tmptable,db,$ZT,COLS
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
	I "DEP,LN"[table D  ;Wide table
	.       N N,list,spltnam,spltbl 
	.	If $$VALID^%ZRTNS("DBMAPDFT") do MAPPING^DBMAP(db,table,.COLS)
	.	If '$$VALID^%ZRTNS("DBMAPDFT") do MAP^DBSDDMAP(table,.COLS)
	.       ; D MAP^DBSDDMAP(table,.COLS) 
	.       S N="" 
	.       F  S N=$O(COLS(table,N)) Q:N=""  D 
	..         N split 
	..         S split=COLS(table,N) 
	..         ;Q:split?1"C".E                      ; Skip computeds 
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
	E  D  ;Regular Table
	.	S tmptable=$$RESWRD^DBMAP(table)
	.	S list=$$LIST(table,$G(comp))		 	; Data item list
	.	S list=$P(list,",",1,9999)			; limit number of columns
	.	I list="" D ERROR("No columns in table "_table) Q
	.	D CRTBL2(tmptable,table,list,akeys)
	;
	Q
	;
CRTBL2(tmptable,proftbl,list,akeys)	
	I $G(proftbl)="" S proftbl=tmptable	;large table
	N sqlstr
	;
	s sqlstr="CREATE TABLE "_tmptable_" ("
	;
	;						; 
	S cnt=$L(list,",")				; Total columns
	F i=1:1:cnt D
	.	S dinam=$P(list,",",i)			; data item name
	.	I $E(dinam)=q Q				; Dummy data item
	.	I dinam?1N.E Q
	.	S x=$G(^DBTBL(LIBS,1,proftbl,9,dinam)) 	; Item definition
	.       I "DEP,LN"[proftbl,$D(^DBTBL(LIBS,1,"ACN",9,dinam)),dinam'="CID" quit
	.	I x="" D ERROR("Invalid column name "_proftbl_"."_dinam) Q
	.	s di=""""_$$RESWRD^DBMAP(dinam)_""""
	.	S node=$P(x,"|",1),len=$P(x,"|",2),def=$P(x,"|",3)
	.	S typ=$P(x,"|",9),dec=$P(x,"|",14)+0
	.	S sub=$P(x,"|",18),req=$P(x,"|",15),pos=$P(x,"|",21)
	.	S desc=$P(x,"|",10),cmp=$P(x,"|",16)
	.	s nullind=$P(x,"|",31)			; null indicator
	.	;I len>2000 S len=2000			; Maximum length
	.	S tlen=tlen+len
	.	I "UTF"[typ S tlen=tlen+4		; 4 bytes of overhead
	.	;
	.	S desc=$TR(desc,"&'","+")
	.	S comment(di)=desc			; pc 7/5/2001
	.	;
	. 	s sqlstr=sqlstr_"  "_di_"  "_$$type(typ,db)
	.	i (nullind=1) s sqlstr=sqlstr_$$getDef(def,typ)
	.	I (node?1N1"*") D
	..		s sqlstr=sqlstr_" NOT NULL"
	.	; E  s sqlstr=sqlstr_"  "_di_"  "_$$type(typ,db)
	.	; I def'="" D default(def,typ)
	.	; 
	.	s sqlstr=sqlstr_","
	.	S count=count+1				; Item counter
	;
	; removing the last comma.
	s sqlstr=$E(sqlstr,1,$L(sqlstr)-1)
	;Check keys for invalid names (i.e., reserved words)
	;if reserved word, add "S_" to the front.
	S akeys=$$replace(akeys)	;replace invalid column names
	;
	; I akeys'="" s sqlstr=sqlstr_", CONSTRAINT pk_"_tmptable_" PRIMARY KEY ("_akeys_")"
	I akeys'="" s sqlstr=sqlstr_", PRIMARY KEY ("_akeys_")"
	s sqlstr=sqlstr_")"
	;
	; W !,sqlstr,!
	d logmsg^TBXDQUTL("Creating table : "_tmptable,zlogf,1)
	D DBAPI(sqlstr)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	D comment(tmptable)			; comments
	Q				; Text
	;----------------------------------------------------------------------
comment(table)	; table and column comments 
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
	;----------------------------------------------------------------------
type(typ,db)	; convert DQ data type 
	;----------------------------------------------------------------------
	;
	N x,TYPE
	S TYPE=""
	I db="ORACLE" DO  quit TYPE   				    ;Oracle format
	.	I typ="L" S TYPE="CHAR(1)" Q
	.	I typ="N" D  S TYPE=x Q
	..		I 'dec,len<10 s x="NUMBER" Q		; Max 9 digits(code
	..		I 'dec  s x="NUMBER("_len_")" Q		; Max 30 digits(account)
	..		I dec,dec>len s len=dec+1		; Length error?
	..		S x="NUMBER("_len_","_dec_")" Q		; Example:INTEREST RATE
	.	I typ="$" S TYPE="DECIMAL("_(len+2)_","_dec_")" Q	;Currency
	.	I typ="D" D  S TYPE=x Q
	..		S x="NUMBER" Q				; Date
	..		S x="INTEGER" Q				; !!! what is this ?!!!!!
	.	;I typ="C" S TYPE="TIME" Q			;timestamp
	.	I typ="C" S TYPE="VARCHAR2("_len_")" Q		;timestamp
	.       I "MB"[typ D  Q 
	..              I typ="M" set TYPE="CLOB" Q 
	..              I typ="B" set TYPE="BLOB" Q 
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
replace(keys,del);	Replace invalid data item names w/ valid names. 
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
DSPERR	;
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
	I '(",DEP,LN,"[fid) S indexnm=fid_"_"_index,indtbl=fid Q 0
	;
	D MAP^DBSDDMAP(fid,.tblarr)
	;
	S newtbl="",error=0
	F i=1:1:$L(keys,",") D
	.	s col=$P(keys,",",i) Q:col=""
	.	I i=1 S newtbl=$G(tblarr(fid,col)) Q
	.	I $g(tblarr(fid,col))'=newtbl S error=1
	;
	I error s RM="Warning: Invalid index: "_fid_"_"_index Q 1  ;failure
	;
	;All columns in same split table.  return ind name and table name
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
	.       I ",DEP,LN"[table,$D(^DBTBL("SYSDEV",1,"ACN",9,di)),di'="CID" quit
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
	;
getidxky(tbl,idx);	
	;
	n fsn,akey,key,i,v,k,query,seq
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
OBSTABLE;	Obsolete table or columns  
	;----------------------------------------------------------------------
	;
	I '$D(db) s db=$$TRNLNM^%ZFUNC("SCAU$DB")
	i db="" s db="GTM"
	I db="GTM" Q
	;
	Q:'$D(^TMPSQL($J,"obsolete"))
	;
	n table,col,sqlstr,FID,DI,$ZT
	;
	s table="" f  s table=$O(^TMPSQL($J,"obsolete",table)) q:table=""  d
	.	I $G(^TMPSQL($J,"obsolete",table))=1 d
	..		d obstbl(table)
	..		K ^TMPSQL($J,"obsolete",table)
	.		S ER=0,RM=""
	.	E  D
	..		;s FID=$$RESWRD^DBMAP(table)
	..		s col="" f  s col=$O(^TMPSQL($J,"obsolete",table,col)) q:col=""  d
	...			I "DEP,LN"[table s FID=$$getWtbl^TBXSQL(table,col)
	...			E  s FID=$$RESWRD^DBMAP(table)
	...			I $G(FID)="" d  q
	....				d logmsg^TBXDQUTL("Error : unable to remove "_table_"."_col_" from database.",zlogf)
	...			I ("DEP,LN"[table),FID="ACN" Q
	...			s DI=$$RESWRD^DBMAP(col)
	...			d obscol(FID,DI)
	...			; k ^TMPSQL($J,"obsolete",table,col)
	...			s ER=0,RM=""
	Q
	;
obstbl(table);	
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
	;
obscol(table,col);	
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
MODIFYTB;	Modify columns 
	;----------------------------------------------------------------------
	;
	n proftbl,profcol
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
	q
	;
	;----------------------------------------------------------------------
mdfcol(proftbl,profcol)	
	; How do I prevent multiple fp install for the same element??????
	;----------------------------------------------------------------------
	;
	n DATA,LEN,REQ,SQL,TYP,FID,len,dec,pos,typ,dft,table,col,TMPSTR,IsSubTyp
	n rowcnt,$ZT,desc,nullind,reqStr,metaData,mtype,mlen,mprec,mnull,mdef
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
	I "DEP,LN"[proftbl D
	. s table=$$getWtbl^TBXSQL(proftbl,profcol)
	. i table="ACN" s IsSubTyp=1
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
	; get row count
	s rowcnt=$$getrwcnt(table)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	Q:(ER<0)
	;
	; SELECT DATA_TYPE, DATA_LENGTH, DATA_PRECISION, NULLABLE, DATA_DEFAULT
	s metaData=$$getMData(table,col)
	Q:(ER<0)
	s mtype=$P(metaData,$C(9),1)
	s mlen=$P(metaData,$C(9),2)
	s mprec=$P(metaData,$C(9),3)
	s mnull=$P(metaData,$C(9),4)
	s mdef=$P(metaData,$C(9),5)
	;
	s defStr=""
	i dft="",(mdef'=""),(mdef'="NULL") s defStr=" DEFAULT NULL "
	;i dft'="" d
	;. i ("$N"[typ) s defStr=" DEFAULT "_dft
	;. e  s defStr=" DEFAULT '"_dft_"'"
	;
	i nullind=1,("$N"[typ) d
	. i dft="" s defStr=" DEFAULT "_0
	. e  s defStr=" DEFAULT "_dft
	;
	; ********* fix ******
	i typ="L" s defstr=" DEFAULT 0"
	; 
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
	E  d			; modify column
	.	i rowcnt=0 d
	..		s SQL="ALTER TABLE "_table_" MODIFY "_col_" "_$$type^TBXSQL(typ,db)_" "_defStr
	..		d execSQL(SQL)
	.	E  d
	..		; table must be empty to change data type. Need to do something!
	..		s SQL="ALTER TABLE "_table_" MODIFY "_col_" "_$$type^TBXSQL(typ,db)_" "_defStr
	..		d execSQL(SQL)	
	;
	; s nullable=$$CHKNULL(table,col)
	;
	s reqStr=""
	i mnull="Y",(REQ'="") s reqStr=" NOT NULL "
	;I mnull="N",(REQ'="") s reqStr=" NOT NULL "
	;I mnull="Y",(REQ="") s reqStr=" NULL "
	;	
	I reqStr'="" d
	.	i rowcnt=0 d
	..		S SQL="ALTER TABLE "_table_" MODIFY "_col_" "_reqStr
	..		d execSQL(SQL)
	.	E  d
	..		n nullcnt
	.. 		S SQL=("SELECT COUNT(*) FROM "_table_" WHERE '"_col_"' IS NULL")
	.. 		S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.nullcnt,.RM)
	..		i (nullcnt>0),(dft="") d   q
	...			d logmsg^TBXDQUTL("SQL warning : unable to update "_table_"_"_col_"  with the default value which is null",zlogf)
	..		i (dft'="") d
	...			S SQL=("UPDATE "_table_" SET "_col_" = '"_dft_"' where "_col_" IS NULL")		; set default value.
	...	 		D execSQL(SQL)
	.. 		S SQL=("ALTER TABLE "_table_" MODIFY "_col_" "_reqStr)
	.. 		d execSQL(SQL)
	;
	Q
	;
	;----------------------------------------------------------------------
MODIFYID;	
	;----------------------------------------------------------------------
	;
	n proftbl,profidx
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
	N indexnm,key,temptab,sqlstr,SQL,$ZT
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
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_sqlstr_": "_RM,zlogf)      
	Q
	;
	;----------------------------------------------------------------------
MODIFYFK;	
	;----------------------------------------------------------------------
	;
	n proftbl,profkey
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
	n parent,ftable,fparent,akey,i,keys,x,zkey,newkey,sqlstr,command,SQL,$ZT,fkyname
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
	S ftable=tbl,fparent=parent
	F j=1:1:$L(newkey,",") D
	.	N fkey S fkey=$P(newkey,",",j)
	.	;  d FILE^DBMAP(db,ftable)
	.	D MAP^DBMAP(db,.ftable,.fkey)
	.	; d FILE^DBMAP(db,fparent)
	.	D MAP^DBMAP(db,.fparent,.fkey)
	.	S zkey=zkey_","_fkey
	.	S akey=$E(zkey,2,99)
	;
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
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_sqlstr_":  "_RM,zlogf)
	;
	Q
	;
	;
	;----------------------------------------------------------------------
getMData(tbl,col);	Get metadata. 
	;----------------------------------------------------------------------
	;
	n SQL
	S SQL="SELECT DATA_TYPE, DATA_LENGTH, DATA_PRECISION, NULLABLE, DATA_DEFAULT"
	s SQL=SQL_" FROM USER_TAB_COLUMNS"
	S SQL=SQL_" WHERE TABLE_NAME = '"_tbl_"' AND COLUMN_NAME = '"_col_"'"
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	Q DATA
	;
	;----------------------------------------------------------------------
getrwcnt(tbl);	Get row count 
	;----------------------------------------------------------------------
	n SQL
	s SQL="SELECT COUNT(*) FROM "_tbl
	s ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	Q DATA
	;
	;----------------------------------------------------------------------
ZRDB	; Error trap for relational database element load  
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
cComment(table,col,desc);	create comment 
	;----------------------------------------------------------------------
	;
	n comment    
	S comment="COMMENT ON COLUMN "_table_"."_col_" IS '"_desc_"'"	; column description	
	D DBAPI(comment)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	Q
	;
	;----------------------------------------------------------------------
getWtbl(proftbl,profcol);	Get wide table name 
	;----------------------------------------------------------------------
	;
	n COLS,spltbl
	I $D(^DBTBL("SYSDEV",1,"ACN",9,profcol)) Q "ACN"
	D MAP^DBSDDMAP(proftbl,.COLS)
	s spltbl=$G(COLS(proftbl,profcol))
	;
	i $G(spltbl)="" Q ""
	Q "W_"_proftbl_"_"_spltbl
	;
	;----------------------------------------------------------------------
dConstrt(FID);	Disabling table constraint to allow data to update. 
	;----------------------------------------------------------------------
	n fkey,ctbl,SQLCUR,vER,vCurID,vRM,vd
	;
	I $D(db) S db=$$TRNLNM^%ZFUNC("SCAU$DB")
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
	S vER=$$OPENCUR^%DBAPI(0,SQLCUR,$C(9),"",.vCurID,.vd,.vRM)
	F  q:(vER=100)!(vd="")  d 
	. S fkey=$P(vd,$C(9),1)
	. s ctbl=$P(vd,$C(9),2)
	. d logmsg^TBXDQUTL("Disabling constraint: "_fkey)
	. S SQL="ALTER TABLE "_ctbl_" DISABLE CONSTRAINT "_fkey
	. D DBAPI^TBXSQL(SQL)
	. D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(RM))
	. S vER=$$FETCH^%DBAPI(0,vCurID,1,$C(9),.vd,.vRM)
	;
	s:(vER'=100)!(vd'="") ER=$$CLOSECUR^%DBAPI("",vCurID)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(vRM))
	Q
	;
	;
	;----------------------------------------------------------------------
eConstrt;	Enabling table constraints after all data are updated to DB. 
	;----------------------------------------------------------------------
	n fkey,ctbl,FID,SQLCUR,vER,vCurID,vRM,vd
	;
	I $D(db) S db=$$TRNLNM^%ZFUNC("SCAU$DB")
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
	. S vER=$$OPENCUR^%DBAPI(0,SQLCUR,$C(9),"",.vCurID,.vd,.vRM)
	. F  q:(vER=100)!(vd="")  d 
	.. S fkey=$P(vd,$C(9),1)
	.. s ctbl=$P(vd,$C(9),2)
	.. d logmsg^TBXDQUTL("Enabling constraint "_fkey)
	.. S SQL="ALTER TABLE "_ctbl_" MODIFY CONSTRAINT "_fkey_" ENABLE NOVALIDATE"
	.. D DBAPI^TBXSQL(SQL)
	.. D:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(RM))
	.. S vER=$$FETCH^%DBAPI(0,vCurID,1,$C(9),.vd,.vRM)
	. s:(vER'=100)!(vd'="") ER=$$CLOSECUR^%DBAPI("",vCurID)
	. d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_$G(vRM))
	;
	k ^TMPSQL($J,"constraints")			; clean up
	;
	Q
	;	
	;----------------------------------------------------------------------
getDef(default,type);	Get default String; 
	;----------------------------------------------------------------------	
	;
	i "N$"'[type Q ""
	i "N$"[type,default'="" Q " DEFAULT "_default
	Q " DEFAULT "_0
	;
	;----------------------------------------------------------------------
execSQL(SQL)	; execute SQL statment 
	;----------------------------------------------------------------------	
	D DBAPI^TBXSQL(SQL)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR :"_SQL_": "_RM,zlogf)
	Q
	;
	;---------------------------------------------------------------------
sqllog(build)	; Log SQL error to a different file.
	;---------------------------------------------------------------------
	i '$D(^TMPERR($J)) Q
	;
	n sqlerr,errseq,errbr,ok
	s $P(errbr,"*",50)=""
	s sqlerr=$$SCAU^%TRNLNM("SPOOL","SQLERR_"_build_"_"_$J_".LOG")
	s ok=$$FILE^%ZOPEN(sqlerr,"WRITE/NEWV",5)
	i +ok=0 d logmsg^TBXDQUTL("Error unable to open SQL log file "_$P(ok,"|",2),zlogf) Q
	s errseq="" f  s errseq=$O(^TMPERR($J,errseq)) q:errseq=""  d
	.	u sqlerr w ^TMPERR($J,errseq),!,errbr,!
	c sqlerr
	k ^TMPERR($J)	
	Q
	;
	;--------------------------------------------------------------------
getCnStr();	read database connection information from dbi.ini file 
	;--------------------------------------------------------------------
	n io,ok,sid,uid,pwd
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
obsscrpt(sqlfile);	remove obsolete function or package from database 
	;--------------------------------------------------------------------
	n SQL
	I $G(db)="GTM" Q
	;
	I sqlfile'["_" s SQL="DROP PACKAGE """_$P(sqlfile,".",1)_""""
	E  s SQL="DROP FUNCTION """_$P(sqlfile,".",1)_""""
	d execSQL(SQL)
	Q
	;
	;--------------------------------------------------------------------
regnproc;	Recompile stored procdure if there is schema change 
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
	q	
