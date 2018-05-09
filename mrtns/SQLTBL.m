SQLTBL	;Private;SQL CREATE TABLE command
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/00 08:58:22 - SPIER
	; ORIG:	CHIANG - 01/24/97
	; DESC:	SQL CREATE TABLE command
	;
	; KEYWORDS:	SQL, CREATE TABLE
	;
        ; LIBRARY:
        ;       . CREATE   - Create TABLE/INDEX/FOREIGN KEY
	;	. TABLE	   - Create Table definition
	;       . INDEX	   - Create Index definition
	;       . FOREIGN  - Create foreign key definition
	;
	; INPUTS:
	;	. System	
	;	. Data	[ddfile]di
	;
	; I18N=QUIT
	;---------- Revision History -------------------------------------------
	; 2009-07-31, Frans S.C. Witte, CR 41833
	;	Disabled CREATE TABLE, as it creates an incomplete table
	;	definition. To be re-enabled and adapted once new DQ interface
	;	is available.
	;
	; 06/17/05 - Pete Chenard CR 16355
	;	     Modified TABLE section to create the table on Oracle if running
	;	     on RDB.
	;
	; 01/06/04 - Pete Chenard - 13875
	;            Modified type section to set memo & blob size to 1024000
	;            (1MB)
	;
	; 09/14/00 - SPIER - 41870
	;            Corrected size error for memo and blob fields. THe variable
	;	     setup was not correct.
	;
	; 09/07/00 - SPIER - 37925
	;            Change global name to remove underscores and also changed logic
	;	     behind getting next global not used by another table.
	;
	; 08/24/00 - SPIER - 37925
	;            Correction to logical format
	;
	; 07/26/00 - Dan Russell - 37925
	;            Various changes to allow longer table names, with
	;            underscores, to support additional data types, and
	;            load columns in order of input, versus alphabetical.
	;
	; 12/18/97 - Chiang  27185
	;	     Modified INDEX section to return error messages on invalid
	;            table name and column names.
	;
	;            Modified to convert LONG format to Text format with length
	;            of 250 characters.
	;
	; 08/13/97 - Chiang  25429
	;            Modified TABLE section to add logic to validate CREATE
	;            TABLE syntax.
	;
	; 05/28/97 - Chiang  24835
	;            Modified TABLE section to return "Missing key(s)" error
	;            message if PRIMARY KEY qualifier was not included the
	;            CREATE TABLE statement.
	Q
	;-----------------------------------------------------------------------
CREATE(expr) ; Create DQ file definition
	;-----------------------------------------------------------------------
	;
	N col,coldef,coldes,colnam,colseq,coltyp,colsiz,colreq,cols,dec,done
	N fDBTBL1,fDBTBL1D
	N doc,global,i,keynam,keys,lastkey,list,sql,tblnam,val,x,z
	;
	S ER=0,RM=""
	S expr=$$SQL^%ZS(expr)
	;
	I expr["TABLE" D TABLE(expr) Q
	I expr["INDEX"!(expr["CREATE NON-UNIQUE INDEX") D INDEX(expr) Q
	S ER=1,RM=$$^MSG(1287,expr) Q
	;
	;----------------------------------------------------------------------
ALTER(expr) ; Alter TABLE
	;----------------------------------------------------------------------
	I expr["FOREIGN KEY" D FOREIGN(expr) Q
	S ER=1,RM=$$^MSG(1287,expr)
	Q
	;----------------------------------------------------------------------
TABLE(expr) ; Create table definition
	;----------------------------------------------------------------------
	; TABLE Table_name (column_name TYPE NOT NULL,
	;                          column_name TYPE ...,
	;                          PRIMARY KEY (column_name)
	;			   ) ;
	;----------------------------------------------------------------------
	; NOT SUPPORTED UNTIL KNOWN HOW TO MAP TO GT.M
	;
	SET ER=1,RM=$$^MSG(1287,expr)
	QUIT
	;
	N isRDB
	S tblnam=$P(expr,"(",1),tblnam=$p(tblnam,"TABLE ",2)
	S tblnam=$$TRIM^%ZS(tblnam)				; Table name
	S isRDB=$$rdb^UCDB(tblnam)
	I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU$DB")
	S cols=$P(expr,"(",2,9999),cols=$P(cols,";",1)		; Column def
	I cols="" S ER=1,RM=$$^MSG(8564,expr) Q			; Missing def
	S col=$E(cols,1,$L(cols)-1) 				; Remove )
	S colseq=0
      	;
	S done=0,keys=""
	F i=1:1:$L(cols,",") D  Q:done  Q:ER
	.	S col=$P(cols,",",i)
	.	S col=$$TRIM^%ZS(col)
	.	S colnam=$P(col," ",1),coldes=colnam 		; Column name
	.	I colnam="PRIMARY" D key(col) Q			; Primary key
	.	S coltyp=$P(col," ",2,99)
	.	S dec=""
	.	I coltyp["(",coltyp'[")" S dec=$P(cols,",",i+1)+0,i=i+1
	.	;S coltyp=$$TRIM^%ZS(coltyp)
	.	S colsiz=$P($P(coltyp,"(",2),")",1)
	.	I colsiz["," s dec=+$p(colsiz,",",2)
	.	S colsiz=+colsiz
	.	S coltyp=$P(coltyp,"(",1)
	.	S coltyp=$$type(coltyp)				; DQ type
	.	I coltyp="D"!(coltyp="C") S colsiz=10		; Date/time
	.	I coltyp="X" S coltyp="T",colsiz=20,coldes="TIMESTAMP"	; Timestamp
	.	I coltyp="N",'colsiz S colsiz=12		; Numeric
	.	S colreq=$P(col," ",3,99)			; Not null flag
	.	S colreq=$S(colreq="NOT NULL":1,1:0)
	.	S coldef(colnam)="'"_coltyp_"',"_colsiz_","_colreq_",'"_coldes_"'"_",'"_dec_"'"
	.	S colseq=colseq+1,colseq(colseq)=colnam
	;
	I ER Q
	;
	; Create file header
	;
	;;;;U 0 W !,tblnam K ^DBTBL("SYSDEV",1,tblnam)
	;
	S doc=$E(tblnam,1,30)				; Documentation name
	S global=$E($tr($$LOWER^UCGMR(doc),"_",""),1,8)		; Global name
	S globtmp=global
	S z=$$^SQL("SELECT FID FROM DBTBL1 WHERE %LIBS='SYSDEV' and GLOBAL='"_globtmp_"'",,,.x)
	I x'="" D
	.	F I=1:1:9 s globtmp=$e(global,1,7)_I D  Q:x=""
	..		S z=$$^SQL("SELECT FID FROM DBTBL1 WHERE %LIBS='SYSDEV' and GLOBAL='"_globtmp_"'",,,.x)
	I x'="" D
	.	F I=10:1:99 s globtmp=$e(global,1,6)_I D  Q:x=""
	..		S z=$$^SQL("SELECT FID FROM DBTBL1 WHERE %LIBS='SYSDEV' and GLOBAL='"_globtmp_"'",,,.x)
	I x'="" S ER=1,RM=$$^MSG(1365) Q
	S global=globtmp
	;
	S list="%LIBS,FID,DES,FDOC,SYSSN,GLOBAL,FILETYP,ACCKEYS,NETLOC,LOG,RECTYP,DEL,EXTENDLENGTH"
	S val="'SYSDEV','"_tblnam_"','"_tblnam_"','"_doc_"','PBS','"_global_"'"
	I keys="" S ER=1,RM=$$^MSG(7962) Q  		; Missing keys
	S val=val_",1,'"_keys_"',1,1,1,124,1"			; File type 7
	S sql="INSERT INTO DBTBL1 ("_list_") VALUES ("_val_")"
	;
	S z=$$^SQL(sql) I ER Q
	;
	; Create column definition
  	;
	S pos=1
	;
	; Create columns in order that is in CREATE TABLE command
	F seq=1:1:colseq S colnam=colseq(seq) D  Q:ER
	.	N seq
	.	I $D(keynam(colnam)) D update Q 		; Access key
	.	S dinam="'"_colnam_"'"
	.	S list="%LIBS,FID,DI,TYP,LEN,REQ,DES,DEC,NOD,POS,RHD"
	.	S val="'SYSDEV','"_tblnam_"',"
	.	S val=val_dinam_","_coldef(colnam)_",'"_lastkey_"',"
	.	S val=val_pos_","_dinam
	.	S pos=pos+1
	.	S sql="INSERT INTO DBTBL1D ("_list_") VALUES ("_val_")"
	.	S z=$$^SQL(sql)
	;pass the create table statement to Oracle if on RDB
	I isRDB do
	.	S expr="CREATE "_expr
	.	S ER=$$EXECUTE^%DBAPI("",expr,$C(9),"",.RM)
	.	Q:ER
	.	; Build DBMAP entry for this table
	.	D FILE^DBMAP(tblnam,%DB)
	Q
	;
	;----------------------------------------------------------------------
key(col) ; Access keys
	;----------------------------------------------------------------------
	N j
	K lastkey,keynam,keys
	S done=1
	I col'[")" S col=$p(cols,",",i,99)
	S keys=$P(col,"(",2),keys=$P(keys,")",1)
	I keys="" S ER=1,RM=$$^MSG(48) Q			; Missing keys
	F j=1:1:$L(keys,",") S keynam($P(keys,",",j))=i		; Access keys
	S lastkey=$p(keys,",",$L(keys,","))			; Last key name
	Q
	;----------------------------------------------------------------------
type(typ) ;
	;----------------------------------------------------------------------
	; Note that some of these data types will not be generated by
	; tools such as ERwin or Oracle, etc., but can be edited in the
	; input files prior to processing.
	;
	S typ=$P(typ," ",1)
	I typ="NUMERIC" Q "N"
	I typ="NUMBER" Q "N"
	I typ="CHAR" Q "T"
	I typ="VARCHAR" Q "T"
	I typ="VARCHAR2" Q "T"
	I typ="INTEGER" S colsiz=5,dec=2 Q "N"
	I typ="SMALLINT" Q "N"
	I typ="DECIMAL" Q "$"  			; By convention
	I typ="FREQ" Q "F"
	I typ="TIMESTAMP" Q "X"
	I typ="DATE" Q "D"
	I typ="TIME" Q "C"
	I typ="LONG" S colsiz=250 Q "T"
	I typ="BLOB" S colsiz=1024000 Q "B"
	I typ="MEMO" S colsiz=1024000 Q "M"
	I typ="REAL" S colsiz=7,dec=2 Q "N"
	I typ="FLOAT" S colsiz=15,dec=2 Q "N"
	I typ="BOOLEAN" S colsiz=1 Q "L"	; Not valid external, but DQ
	S ER=1,RM=$$^MSG(1385,typ)		; Invalid keyword
	Q ""
update	;
	; Modify type and length of access keys
	;
	N typ,len,whr
	S typ=$P(coldef(colnam),",",1),len=$P(coldef(colnam),",",2)
	S sql="TYP="_typ_",LEN="_len
	S whr=" WHERE FID='"_tblnam_"' AND %LIBS='SYSDEV' AND DI='"_colnam_"'"
	S sql="UPDATE DBTBL1D SET "_sql_whr
	S z=$$^SQL(sql)
	Q
	;----------------------------------------------------------------------
INDEX(expr) ; Create index definition
	;----------------------------------------------------------------------
	; CREATE UNIQUE INDEX KEYIDX ON DATACLSMAP ( ITEMNAME ASC,USERCLS ASC );
	;
	;----------------------------------------------------------------------
	; NOT SUPPORTED UNTIL KNOWN HOW TO MAP TO GT.M
	;
	SET ER=1,RM=$$^MSG(1287,expr)
	QUIT
	;
	N col,fid,fsn,gbl,i,indexnm,key,keys,list,ord,order,sql,str,val,z
	;
	S order="",ER=0
	S str=$P(expr,"INDEX ",2,99)
	S indexnm=$P(str," ",1)				; Index name
	S fid=$P($P(str," ON ",2),"(",1)
	S fid=$$TRIM^%ZS(fid)				; Table name
	I fid="" S ER=1,RM=$$^MSG(1484) Q		; Missing table name
	I '$D(^DBTBL("SYSDEV",1,fid)) S ER=1,RM=$$^MSG(1484,fid) Q
	D fsn^SQLDD(.fsn,fid)				; File attributes
	S keys=$P(fsn(fid),"|",3)			; Access keys
	F i=1:1:$L(keys,",") S key($P(keys,",",i))=""	; each key
	S ord=$P($P(expr,"(",2),")",1)
	F i=1:1:$L(ord,",") D  I ER Q
	.	S col=$$TRIM^%ZS($P(ord,",",i))		; Column name
	.	S col=$P(col," ",1)
	.	I '$D(^DBTBL(%LIBS,1,fid,9,col)) S ER=1,RM=$$^MSG(1286,col) Q
	.	S order=order_","_col
	.	K key(col)				; Check it off
	I ER Q
	;						; Include missing keys
	S i="" F  S i=$O(key(i)) Q:i=""  S order=order_","_i
	S order=""""_fid_"%"_indexnm_""""_order
	;
	S gbl="zguindex"
	;
	;;;W !,expr K ^DBTBL("SYSDEV",8,fid,indexnm)
	;
	S list="%LIBS,FID,INDEXNM,NULLFLG,GLOBAL,ORDERBY,IDXDESC"
	S val="'SYSDEV','"_fid_"','"_indexnm_"',0,'"_gbl_"','"_order_"'"
	S val=val_",'GUI Index Definition'"
	S sql="INSERT INTO DBTBL8 ("_list_") VALUES ("_val_")"
	S z=$$^SQL(sql)
	Q
	;----------------------------------------------------------------------
FOREIGN(expr) ; Create foreign key definition
	;----------------------------------------------------------------------
	; ALTER TABLE APPTOCLSMAP
	; ADD FOREIGN KEY APPKEY (APPID) REFERENCES SECAPP (APPLICATIONID) ;
	;
	N chdkey,fid,fkeys,ftbl,list,parkey,pkeys,sql,val,z
	;
	S fid=$P($P(expr,"TABLE ",2)," ",1)		; Table name
	S fkeys=$P($P(expr,"(",2),")",1)		; Foreign keys
	S ftbl=$P($P(expr,"REFERENCES ",2)," ",1)	; Parent table
	S pkeys=$P($P(expr,"(",3),")",1)		; Parent keys
	I pkeys="" S pkeys=fkeys			; Handle ERwin syntax
	;
	;;;W !,expr,! K ^DBTBL("SYSDEV",19,fid,fkeys)
	;
	S list="%LIBS,FID,FKEYS,TBLREF,PKEYS"
	S val="'SYSDEV','"_fid_"','"_fkeys_"','"_ftbl_"','"_pkeys_"'"
	S sql="INSERT INTO DBTBL1F ("_list_") VALUES ("_val_")";
	S z=$$^SQL(sql)
	Q
	;
	;----------------------------------------------------------------------
BATCH	; Batch mode processing
	;----------------------------------------------------------------------
	N %UID,expr,line,tok,ER,IO,RM,X
	D ^SCAIO
	S expr="",%UID=1,$P(line,"*",79)=""
	F  U IO Q:$ZEOF  D RUN
	C IO
	Q
RUN	;
	R X S expr=expr_X I $E(X,$L(X))=";" D
	.	U 0
	.	S ER=0,RM=""
	.	S expr=$$SQL^%ZS(expr,.tok)
	.	I expr["ALTER" D ALTER(expr)
	.	I expr["CREATE" D CREATE(expr)
	.	I $G(ER) W !,line,!,RM,!! ZWR expr W !,line,!
	.	S expr=""
	Q

