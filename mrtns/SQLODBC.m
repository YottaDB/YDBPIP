SQLODBC	;Library;ODBC functions
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/21/02 15:59:19 - CHENARDP
	; ORIG:	CHIANG - 05/06/97
	; DESC:	ODBC functions
	;
	; KEYWORDS:	SQL, ODBC
	;
	; LIBRARY:
	;	. PREPARE  - Return column attributes
	;	. DESCRIBE - Return attributes of a single table
	;	. CONCAT   - Concatenate two strings
	;	. KEYCOL   - Return access key names for one or more tables
	;       . LIST     - Return column names for a single table
	;
	; I18N=OFF
	;--------- Revision History ------------------------------------------
	; 07/10/07 - Pete Chenard - CR28171
	;            Replaced occurrences of $C(255) with the value returned
	;            from $$BYTECHAR^SQLUTL(255).
	;
	; 02/21/2002 Pete Chenard - 49204
	;	     Removed the patch for MS Access.  The code was changing 
	;	     the data type on primary keys to Text because that's all
	;	     MS Access can support.  This is causing problems in 
	;	     Xpress.  For MS Access to work, clients need to use the
	;	     Pass Through SQL feature of that product.
	;
	; 03/30/2000 Chiang - 32557  QAR#5
	;            Modified ATTR1 section to return status information.
	;
	; 03/02/2000 Chiang - 32557  QAR #2
	;            Modified COLATT section to return Frequency data type
	;            as F with the /PREPARE=3 option (PFW/PIA).
	;
	;            Modified DESCRIBE section to return the correct column
	;            attribute information.
	;
	;            Added a new function KEYCOL to return a list of access
	;            key names for one or more tables.
	;            Add a new function LIST to return a list of column names
	;            for a single table.
	;
	; 11/10/99 - Chiang - 35688
	;            Modified PREPARE section to support table alias syntax.
	;
	; 05/27/99 - Chiang - 32656
	;            Modified PACK section to use the correct column name for
	;            comparison purpose.
	;
	;	     Modified PREPARE section to use 250 as the default field
	;            length for computed text data.
	;
	; 05/03/99 - Chiang - 32656
	;            Modified PREPARE section to change column attributes into
	;            packed format.
	;
	;            Modified PREPARE section to keep clock time data type
	;            as 'C' instead of 'T'.
	;
	; 04/09/99 - Chiang - 32496
	;            Modified PREPARE section to new variable 'dinam'.
	;
	;            Removed old revision history.
	;
	; 12/29/98 - Chiang - 31187
	;            Modified DESCRIBE section to disable table access
	;            validation logic (Build 1.3).
	;
	; 12/18/98 - Chiang - 31187
	;            Modified DESCRIBE and PREPARE sections to change computed
	;            data item size from N1 to N2 and text field to 254.
	;
	; 11/30/98 - Chiang - 30934
	;            Modified PREPARE section to disable table access
	;            validation logic.
	;
	; 09/17/98 - Chiang - 29789
	;            Modified to change SQL PREPARE logic to support MS Access
	;            client software.
	;
	;----------------------------------------------------------------------
PREPARE(di,frm,vpack)	; Return column attributes 
	;----------------------------------------------------------------------
	; ARGUMENTS: 
	; 
	; . di          Column name             /TYP=T/REQ/MECH=REFVAL 
	; . frm         Table name              /TYP=T/REQ/MECH=REFVAL 
	; . vpack	Last table.col format	/TYP=T/REQ/MECH=REF:RW
	; 
	; RETURNS: 
	; ER 	Error flag
	; RM		Error message
	; $$            Column attributes 
	; 
	;  1 ColTable - Column's table name 
	;  2 ColName - Column name 
	;  3 DataLen - The actual length of data as stored in database
	;  4 DisplayLen - Max length of data when converted to a character
	;  5 Precision - Usually the same as length
	;  6 Scale - Number of digit after the decimal point
	;  7 isNullable
	;  8 isNullKnow
	;  9 isCaseSensitive Is it case sensitive?
	; 10 isSearchable Can the column be used in a where clause?
	; 11 isLikeable - Can this column be in a LIKE clause 
	; 12 isUnsigned 
	; 13 isSigned 
	; 14 isMoney 
	; 15 isAutoIncrement 
	; 16 isNotAutoIncrement 
	; 17 isUpdateable Is the column updateable? 
	; 18 ColType (format T,U,F,N,$,L,D,C,B,M)
	;
	; Procedure_name<13,10>f1<tab>f2<tab>...f20<13,10>f1<tab>...<13,10>
	;
	; CREATE PROCESURE Procedure_name AS SELECT column_list FROM table_list
	;
	; OPEN CURSOR Cursor_name AS PROCEDURE Procedure_name	/USING/ROWS
	;
	; FETCH Cursor_name					/ROWS
	;----------------------------------------------------------------------
	N alias,dinam,f,fn,i,len,req,typ,vdd,x,ER,RM
	;
	I frm["OUTER JOIN" S frm=jfiles			; all files 02/07/2000
	I frm?1a.an1" "1a.an.E D			; alias mapping
	.	F i=1:1:$L(frm,",") S f=$P(frm,",",i),alias($P(f," ",2))=$P(f," ",1)
	S dinam=di
	I di?1A.E1"("1E.E1")" D  Q $$CONSTANT(len,typ)	; Func_name(arg)
	.	S fn=$P(di,"(",1),typ=$P($G(^SQL("SQLFUNC",fn)),"|",2)
	.	I typ="" S len=500 Q			; Not defined
	.	I typ="L" S len=1 Q			; Logical
	.	I "N$DC"[typ S len=12 Q			; Default length
	.	S len=500				; Text format
	I di[$C(0) S dinam=$$UNTOK^%ZS(di,.tok)
	I dinam?1"'"1e.e1"'" Q $$CONSTANT($L(dinam)-2,"T") ; Text
	I dinam?1N.E Q $$CONSTANT($L(dinam),"N")	; Numeric
	S dinam=$TR(dinam,$C(34),"")
	I dinam["." D					; Replace alias
	.	S f=$P(dinam,".",1) I $D(alias(f)) S $p(dinam,".",1)=alias(f)
	;
	I dinam'["." S x=$$PARSE^SQLDD(.dinam,,,,frm)
	I $G(ER)!(dinam?1N.N) S x="99999|21|||||||$|||||2",dinam=frm_"."
	E  S x=$$DI^SQLDD(dinam)  		; Data item attributes
	S typ=$p(x,"|",9)		        ; Format type
	S f(1)=$P(dinam,".",1)  		; Table name
	;					; 
	S f(2)=$P(dinam,".",2)  		; Column name
	S f(5)=$P(x,"|",2)	  		; Length
	I $P(x,"|",16)'="" D 			;
	.	I typ="T",f(5)<250 S f(5)=250 Q	 ; Computed data item 05/27/99
	.	I typ="N",f(5)=1 S f(5)=2 Q
	S f(6)=$P(x,"|",14)+0		        ; Decimal precision
	S f(4)=f(5)
	I "N$"[typ D
	.	I 'f(6) S f(4)=f(5)+1		; Display length +-nnnnn
	.	E  S f(4)=f(5)+2		; sign and decimal +-nnnn.nn
	S f(3)=f(4)				; Length
	S req=$P(x,"|",15)	                ; Required field
	I req S f(7)=0,f(8)=0 			; Allow null value
	E  S f(7)=1,f(8)=1
	S f(9)=1  				; Case sensitive
	S f(10)=$S("BM"[typ:0,1:1)              ; Blob and memo type (WHERE)
	S f(11)=$S("TFU"[typ:1,1:0)             ; Text data type (LIKE)
	S f(12)=$S(typ="$":0,1:1)               ; Unsign
	S f(13)=$S(typ="$":1,1:0)               ; Signed (curency)
	S f(14)=$S(typ="$":1,1:0)               ; Signed (curency)
	I $P(x,"|",1)?1N1"*",typ="N" S f(15)=1,f(16)=0
	E  S f(15)=0,f(16)=1
	I $p(x,"|",16)="" S f(17)=1   		; Computed expression?
	E  S f(17)=0
	S f(18)=typ				; Type
	Q $$PACK
	;
PACK()	;
	;;W !,dinam,?20,f(5)
	n b1,b2,b3,b4,b5,b6,b7,b8,b9,dinam,x		; Pack data
	S b1=f(7)*128+(f(8)*64)+(f(9)*32)+(f(10)*16)+(f(11)*8)+(f(12)*4)+(f(13)*2)+f(14)
	S b2=f(15)*128+(f(16)*64)+(f(17)*32)
	S b3=$$BSASCII^SQLUTL(f(18),1)					; type
	S b4=f(3)\256,b5=f(3)#256			; DataLen
	S b6=f(4)\256,b7=f(4)#256			; DisplayLen
	S b8=f(5)\256,b9=f(5)#256			; Precision
	S x=$$BYTECHAR^SQLUTL(b1,b2,b3,b4,b5,b6,b7,b8,b9,f(6))		; first 10 bytes
	I f(2)="" S dinam=""
	E  S dinam=f(1)_"."_f(2)			; table.column
	I $G(vpack)="" S vpack=dinam Q x_$C(0)_vpack	; first item
	F i=1:1 I $E(vpack,i)=""!($E(dinam,i)="")!($E(vpack,i)'=$E(dinam,i)) Q
	S vpack=dinam					; new comparison value 05/27/99
	Q x_$$BYTECHAR^SQLUTL(i-1)_$E(dinam,i,99)			; compressed format
	;
	;----------------------------------------------------------------------
KEYCOL(frm)	; Return a list of access key names 
	;----------------------------------------------------------------------
	N i,j,keys,list,tbl
	S list=""
	F i=1:1:$L(frm,",") D  I $G(ER) Q
	.	S tbl=$P(frm,",",i)
	.	I tbl[" " S tbl=$P(tbl," ",1)			; Alias
	.	I '$D(fsn(tbl)) D fsn^SQLDD(.fsn,tbl) I $G(ER) Q	; table attributes
	.	S keys=$P(fsn(tbl),"|",3)			; Access keys
	.	F j=1:1:$L(keys,",") S list=list_","_tbl_"."_$P(keys,",",j)
	Q $E(list,2,$l(list))
	;---------------------------------------------------------------------- 
COLATT(frm,colfmt)	; Return column format attributes 
	;---------------------------------------------------------------------- 
	N fmt,i,typ,v 
	S fmt="" 
	F i=1:2:$L(colfmt) D 
	.       S typ=$E(colfmt,i) 
	.       I "TUBM"[typ S fmt=fmt_"T" Q            ; Text 
	.       I typ="F" S fmt=fmt_"F" Q           ; Frequency
	.       I "DCL$"[typ S fmt=fmt_typ Q            ; Date, time , logical 
	.       S fmt=fmt_$E(colfmt,i+1)                ; Precision 
	I $G(frm)="" Q fmt_"|"				; Information not required (PFW fetch)
	Q fmt_"|"_$$KEYCOL(frm)                         ; Access key information (PIA) 
	;----------------------------------------------------------------------
CONSTANT(len,type)	; Return attributes for constant 
	;----------------------------------------------------------------------
	n %,f,i,x 
	S %=$C(9) 
	I $G(type)="" S type="T"
	S x=%_%_len_%_len_%_len_%_0_%_1_%_1_%_1_%_0_%_0_%_1_%_0_%_0_%_0_%_1_%_0_%_type 
	F i=1:1:18 S f(i)=$P(x,%,i)
	Q $$PACK
	;----------------------------------------------------------------------
DESCRIBE(expr,sqlsta,sqldta,sqlcnt)	
	;----------------------------------------------------------------------
	; Return a list of column names in node and position order
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	; . expr	Table name		/TYP=T/REQ/MECH=REFVAL
	; 		Table name PRIMARY
	;		Table name FOREIGN PRIMARY
	;		Table name FOREIGN
	;		Table name 1, Table name 2 FOREIGN
	;		Table name INDEX
	;	        Table name COLUMNS
	;
	; . sqlsta	SQL status		/TYP=N/MECH=REFARRY:W
	; . sqldta      Return value		/TYP=N/MECH=REFARRY:W
	; . sqlcnt      Row count		/TYP=N/MECH=REFARRY:W
	;
	; EXAMPLE:
	;
	; D DESCRIBE("CIF",.sqlsta,.sqldta,.sqlcnt)
	;
	; sqldta value:
	;           
	;           Column_name<tab>NOT NULL<tab>type(size)<tab>Key<13,10>
	;
	;           ACN<tab>NOT NULL<tab>NUMBER(12)<tab>PRIMARY KEY<13,10>
	;           NAME<tab>NOT NULL<tab>VARCHAR2(40)<tab><13,10>
	;           ...
	;           NEWITEM<tab><tab>VARCHAR2(40)<tab>
	;
	; sqlcnt value = 111
	;----------------------------------------------------------------------
	; I18N=OFF
	;
	N cmp,dec,dinam,frm,fsn,i,len,list,nod,req,typ,v,x
	S sqldta="",sqlcnt=0,sqlsta=100,ER=0
	S frm=$$TRIM^%ZS(expr)
	I $P(expr," ",2)="COLUMNS" D  Q
	.	N par
	.	S frm=$P(expr," ",1)				; *** 12/29/98
	.	S sqldta=$$ATTR()				; Attributes
	.	I sqldta'="" S sqlcnt=$L(sqldta,$C(13,10))	; Row count
	I $P(expr," ",2,9)["INDEX" D INDEX Q
	I $P(expr," ",2,9)="PRIMARY" D PRIMARY Q
	I expr?1E.E1","1E.E1" FOREIGN" 	D FOREIGN2 Q
	I $P(expr," ",2,9)="FOREIGN" D FOREIGN Q
	I $P(expr," ",2,9)="FOREIGN PRIMARY" D FORPRI Q
	;
	I frm="" S ER=1,RM=$$^MSG(8564,"DESCRIBE") Q
	D fsn^SQLDD(.fsn,frm) I ER Q
	S list=$$LIST^SQLDD(frm)		; Column names
	S sqlcnt=$L(list,",")  			; Row count
	F i=1:1:sqlcnt D
	.	S dinam=frm_"."_$P(list,",",i) 	; fid.di format
	.	S x=$$DI^SQLDD(dinam)  		; Data item attributes
	.	S cmp=$$CMP^SQLDD(dinam,x)  	; Computed item
	.	S len=$$LEN^SQLDD(dinam,x)  	; Field length
	.	I len>250 S len=250		; *****
	.	S dec=$$DEC^SQLDD(dinam,x)+0    ; Decimal precision
	.	S typ=$$TYP^SQLDD(dinam,x)      ; Format type
	.	I cmp'="" D
	..		I typ="T",len<100 S len=len*2 Q  ; Patch to avoid Access error
	..		I typ="N",len=1 S len=2 Q
	.	S typ=$$type(typ) 		; Convert to long name
	.	S req=$$REQ^SQLDD(dinam,x)      ; Required field
	.	S nod=$$NOD^SQLDD(dinam,x)  	; Node location
	.	I nod?1N1"*" S req=1
	.	S v=$P(list,",",i)_$C(9)	; Column name
	.	I req S v=v_"NOT NULL"		; Required
	.	S v=v_$C(9)_typ_"("_len		; Length
	.	I dec S v=v_","_dec		; Precision
	.	S v=v_")"
	.	S v=v_$c(9)
	.	I cmp'="",cmp'=" " S v=v_"COMPUTED VALUE"
	.	I nod?1N1"*" S v=v_"PRIMARY KEY"
	.	I i<sqlcnt S v=v_$C(13,10)
	.	S sqldta=sqldta_v
	S sqlsta=0
	Q
	;----------------------------------------------------------------------
type(typ)	; 
	;----------------------------------------------------------------------
	I typ="B" Q "LONG RAW"
	I typ="M" Q "LONG"
	;;I "DC"[typ Q "DATE"
	I "N$"[typ Q "NUMBER"
	Q "VARCHAR2"
	;----------------------------------------------------------------------
PRIMARY	; Primary access keys 
	;----------------------------------------------------------------------
	; table name<tab>sequence<tab>column name<13,10>
	;----------------------------------------------------------------------
	N fsn,fid
	S sqldta="",sqlcnt=""
	S fid=$P(expr," ",1)  				; Table name
	D fsn^SQLDD(.fsn,fid)  				; Attributes
	I ER Q
	S keys=$P(fsn(fid),"|",3)  			; Access keys
	S sqlcnt=$L(keys,",")  				; Count
	F i=1:1:sqlcnt D
	.	S v=fid_$C(9)_$P(keys,",",i)_$C(9)_i  	; table<tab>seq<tab>name
	.	S sqldta=sqldta_v
	.	I i<sqlcnt S sqldta=sqldta_$C(13,10)
	Q
	;----------------------------------------------------------------------
FOREIGN	; Foreign key definition DESCRIBE Table_name FOREIGN 
	;----------------------------------------------------------------------
	N fid,fk,fk1,ftbl,fcol,fcol1,v,v1
	S sqldta="",sqlcnt=""
	S fid=$P(expr," ",1)  					; Table name
	I fid="" S ER=1,RM=$$^MSG(1484) Q
	I '$D(^DBTBL("SYSDEV",1,fid)) S ER=1,RM=$$^MSG(1484,fid) Q
	S fk="" F  S fk=$O(^DBTBL("SYSDEV",19,fid,fk)) Q:fk=""  S v=^(fk) D
	.	S ftbl=$P(v,"|",5),fcol=$P(v,"|",8)
	.	F i=1:1:$L(fk,",") D
	..		S fk1=$P(fk,",",i)			; key name
	..		S fcol1=$P(fcol,",",i)
	..		S v1=ftbl_$C(9)_fcol1_$C(9)_fid_$C(9)_fk1_$C(9)_i
	..		S sqlcnt=sqlcnt+1			; Row count
	..		S sqldta=sqldta_v1_$C(13,10)		; Row data
	S sqldta=$E(sqldta,1,$L(sqldta)-2)		; Remove extra 13,10
	Q
	;----------------------------------------------------------------------
FORPRI	; Foreign key definition DESCRIBE table_name FOREIGN PRIMARY 
	;----------------------------------------------------------------------
	N fid,ftbl,fcol,fcol1,fcol2,fsn,pkeys,v,v1
	S sqldta="",sqlcnt=""
	S fid=$P(expr," ",1)  					; Table name
	I fid="" S ER=1,RM=$$^MSG(1484) Q
	I '$D(^DBTBL("SYSDEV",1,fid)) S ER=1,RM=$$^MSG(1484,fid) Q
	D fsn^SQLDD(.fsn,fid) S pkeys=$P(fsn(fid),"|",3)
	S ftbl="",fcol=""
	F  S ftbl=$O(^DBINDX("SYSDEV","FKPTR",fid,ftbl)) Q:ftbl=""  D
	. F  S fcol=$O(^DBINDX("SYSDEV","FKPTR",fid,ftbl,fcol)) Q:fcol=""  D
	..	F i=1:1:$L(fcol,",") D
	...		S fcol1=$p(fcol,",",i),fcol2=$p(pkeys,",",i)
	...		S v=fid_$C(9)_fcol2_$C(9)_ftbl_$C(9)_fcol1_$C(9)_i
	...		S sqldta=sqldta_v_$C(13,10)		; Row data
	...		S sqlcnt=sqlcnt+1			; Row count
	S sqldta=$E(sqldta,1,$L(sqldta)-2)
	Q
	;----------------------------------------------------------------------
FOREIGN2	; Foreign key definition 
	;----------------------------------------------------------------------
	N fid,ftbl,fcol,fcol1,v,v1
	S sqldta="",sqlcnt=""
	S fid=$P(expr," ",1)  					; Table name
	S ftbl=$P(fid,",",1),fid=$P(fid,",",2)
	I fid=""!(ftbl="") S ER=1,RM=$$^MSG(1484) Q
	I '$D(^DBTBL("SYSDEV",1,fid)) S ER=1,RM=$$^MSG(1484,fid) Q
	I '$D(^DBTBL("SYSDEV",1,ftbl)) S ER=1,RM=$$^MSG(1484,ftbl) Q
	S fcol=""
	F  S fcol=$O(^DBINDX("SYSDEV","FKPTR",fid,ftbl,fcol)) Q:fcol=""  D
	.	F i=1:1:$L(fcol,",") D
	..		S fcol1=$p(fcol,",",i)
	..		S v=fid_$C(9)_fcol1_$C(9)_ftbl_$C(9)_fcol1_$C(9)_i
	..		S sqldta=sqldta_v_$C(13,10)		; Row data
	..		S sqlcnt=sqlcnt+1			; Row count
	S sqldta=$E(sqldta,1,$L(sqldta)-2)
	Q
	;----------------------------------------------------------------------
INDEX	; DESCRIBE table_name INDEX
	;----------------------------------------------------------------------
	; TABLE_QUALIFIER	null				null
	; TABLE_OWNER		nill				null
	; TABLE_NAME		DBTBL8.FID			DBTBL8.FID
	; NON_UNIQUE		0				null
	; INDEX_QUALIFIER	null				null
	; INDEX_NAME		DBTBL8.INDEXNM			DBTBL8.INDEXNM
	; TYPE			3				0
	; SEQ_IN_INDEX		order in DBTBL8.ORDERBY		null
	; COLUMN_NAME		DBTBL8.ORDERBY			null
	; COLLATION		A				null
	; CARDINALITY		null				null
	; PAGES			null				null
	; FILTER_CONDITION	null				null
	;----------------------------------------------------------------------
	N colnam,fid,i,index,order,seq,%
	S sqldta="",sqlcnt="",%=$C(9)
	S fid=$P(expr," ",1)  					; Table name
	I fid="" Q	
	I '$D(^DBTBL("SYSDEV",1,fid)) S ER=1,RM=$$^MSG(1484,fid) Q
	I $P(expr,"INDEX",2)["PRIMARY" D        ; Primary index key 
	.       D INDEXM 
	.       S sqldta=$E(sqldta,1,$L(sqldta)-1) 
	; 
	E  D INDEXM 
	S sqldta=$E(sqldta,1,$L(sqldta)-1)                      ; Index attributes 
	S sqlsta=100                                            ; SQL status 
	S sqlcnt=$L(sqldta,$C(13,10))                           ; Record Count 
	Q							; *** patch
	S index=""
	F  S index=$O(^DBTBL("SYSDEV",8,fid,index)) Q:index=""  D
	.	S order=$P(^(index),"|",3)
	.	D INDEXP(fid,index,order)
	.	Q
	S sqldta=$E(sqldta,1,$L(sqldta)-1)
	Q
INDEXM	; Primary index key
	D fsn^SQLDD(.fsn,fid)
	S order=$P(fsn(fid),"|",3)
	D INDEXP(fid,"MAIN",order)
	Q
INDEXP(fid,index,order)	; 
	;
	S seq=0
	S v="",$P(v,%,13)="",$P(v,%,7)=0		; SQL_TABLE_STAT
	S $P(v,%,3)=fid,$P(v,%,6)=""
	I index="MAIN" S $P(v,%,4)=1			; NON-UNIQUE
	S sqldta=sqldta_v_$C(13,10),sqlcnt=sqlcnt+1
	F i=1:1:$L(order,",") D
	.	S colnam=$P(order,",",i)
	.	I $E(colnam)="""" Q			; Dummy key
	.	S seq=seq+1
	.	S v=%_%_fid_%_0_%_%_index_%_3_%_seq_%_colnam_%_"A"_%_%_%
	.	S sqldta=sqldta_v_$C(13,10)
	.	S sqlcnt=sqlcnt+1
	Q
	;----------------------------------------------------------------------
ATTR()	; DESCRIBE table_name ATTRIBUTE
	;----------------------------------------------------------------------
	N R,col,i,fid,z
	S fid=$P(expr," ",1)  					; Table name
	S col=$P(expr," ",3)					; Columns
	I '$G(par("PREPARE")) Q $$ATTR1(fid,col)
	;
	S R(1)="DBTBL1D,FID,12,12,12,0,0,0,1,1,1,1,0,0,0,1,1,U"
	S R(2)=R(1)
	S R(3)=R(1)
	S R(4)="DBTBL1D,DI,20,20,20,0,0,0,1,1,1,1,0,0,0,1,1,U"
	S R(5)=",,500,500,500,0,1,1,1,0,0,1,0,0,0,1,0,T"
	S R(6)="DBTBL1D,TYP,1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,U"
	S R(7)=",,500,500,500,0,1,1,1,0,0,1,0,0,0,1,0,T"
	S R(8)=",,500,500,500,0,1,1,1,0,0,1,0,0,0,1,0,T"
	S R(9)=",,500,500,500,0,1,1,1,0,0,1,0,0,0,1,0,T"
	S R(10)=",,500,500,500,0,1,1,1,0,0,1,0,0,0,1,0,T" 
	S R(11)=",,500,500,500,0,1,1,1,0,0,1,0,0,0,1,0,T"
	S R(12)=R(1)
	S z="" F i=1:1:12 S z=z_$TR(R(i),",",$C(9)) I i<12 S z=z_$C(13,10)
	q z
	;----------------------------------------------------------------------
ATTR1(fid,col,nextcol)	; Column attributes DESCRIBE Table_name COLUMNS query 
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	; fid		Table name		/TYP=T/REQ/MECH=VAL
	; col		Column name		/TYP=T/MECH=VAL
	; nextcol	Next column name	/TYP=T/MECH=VAL
	;               Return column attributes after this column name
	;
	;UTBLBRCD,UTBLBRCD,UTBLBRCD,CCDEF,2,N,6,7,0,10,1,UTBLBRCD
	;UTBLBRCD,UTBLBRCD,UTBLBRCD,DESC,1,T,40,40,0,,1,UTBLBRCD
	;
	; Example:
	;
	; DESCRIBE UTBLBRCD COLUMNS
	;
	; DESCRIBE LN COLUMNS
	;
	; Called by ODBC driver after getting the data for the first 1000 column
	; 
	; EXECUTE $$ATTR1^SQLODBC("LN","","SCN")
	;----------------------------------------------------------------------
	N R,di,i,j,rec,v,z
	I '$D(^DBTBL("SYSDEV",1,fid)) S ER=1,RM=$$^MSG(1484,fid) Q ""
	I col'="" D					; Convert %_ to MUMPS
	.	I col[$C(0) S col=$$UNTOK^%ZS(col,.tok)
	.	I $E(col)'="'" S col="'"_col_"'"	; pattern code
	.	S col=$$MPAT^SQLQ(col)
	S rec=""
	S di=$G(nextcol)
	F j=1:1:1000 S di=$O(^DBTBL("SYSDEV",1,fid,9,di)) q:di=""  D  I ER Q
	.	I di?1N.E!($E(di)="""") Q
	.	I col'="" X "I di?"_col I '$T q		; Select column
	.	S v=^(di)
	.	S R(1)=fid,R(2)="",R(3)="",R(4)=di
	.	I $P(v,"|",1)["*" S R(5)=1		; *** patch to support MS Access
	.	E  S R(5)=$$TYPE(5)
	.	S R(6)=$P(v,"|",9),R(7)=$$TYPE(1)
	.	I R(6)="M" S R(6)="T"			; **********
	.	S R(8)=$$TYPE(3),R(9)=$$TYPE(4),R(10)=$$TYPE(6)
	.	S R(11)=$$TYPE(7),R(12)=""
	.	S z="" F i=1:1:12 S z=z_R(i) I i<12 S z=z_$C(9)
	.	S rec=rec_z_$C(13,10)
	I ER Q ""
	I di="" S sqlsta=100				; No more data
	E  S sqlsta=1					; Status - more data
	S sqlcnt=$L(rec,$c(13,10))-1			; Row count
	Q rec
	;----------------------------------------------------------------------
TYPE(opt)	; Convert attributes
	;----------------------------------------------------------------------
	;
	; option:
	;	1 Precision
	;	2 Display length
	;	3 length
	;	4 scare
	;	5 Type in numeric (from -4 to 10)
	;	6 Base (10 or null)
	;       7 Required
	;----------------------------------------------------------------------
	N len,type,dec,req,x
	S len=$P(v,"|",2)		; Length
	;;I len>250 s len=250		; ***********
	S type=$p(v,"|",9)		; Type
	S dec=$P(v,"|",14)+0		; Decimal precision
	S req=$P(v,"|",15)		; Required
	I $p(v,"|",16)'="" D
	.	I type="T",len<100 S len=len*2 Q
	.	I type="N",len=1 S len=2 Q
	I opt=1 Q len
	I opt=2!(opt=3) D  Q x
	.	I "N$"[type S x=len+$S(dec:2,1:1) Q
	.	S x=len
	I opt=4 Q dec
	;
	I opt=6 Q $S("N$"[type:10,1:0)
	I opt=7 Q $S(req:0,1:1)
	;
	; Option 5
	;
	I "DCTUFL"[type Q 1		; ***
	I "N$"[type Q 2
	I type="D" Q 9
	I type="C" Q 10
	I type="M" Q -1
	I type="B" Q -4
	Q 1
	;
	;----------------------------------------------------------------------
CONCAT(stra,strb)	; Concatenate two strings 
	;---------------------------------------------------------------------- 
	; 
	; ARGUMENTS: 
	;       . stra   First string 	/TYP=T/REQ/MECH=VAL
	; 
	;       . strb   Second string 	/TYP=T/REQ/MECH=VAL
	;
	; RETURNS: 
	;       .     String a + string b 
	; 
	; EXAMPLE: 
	;
	;  CONCAT("John","Doe") => JohnDoe
	;----------------------------------------------------------------------
	Q stra_strb
	;
	;----------------------------------------------------------------------
LIST(fid,skpcmp)	; 
	;----------------------------------------------------------------------
	Q $$LIST^SQLDD(fid,$G(skpcmp))
	;----------------------------------------------------------------------
QA(fid)	; Return prepare information
	;----------------------------------------------------------------------
	;
	; EXAMPLE:
	;
	;  S X=$$QA^SQLODBC("DEP")
	;----------------------------------------------------------------------
	;
	N col,fsn,list,pre,v,vpack
	;
	S pre=""
	S list=$$LIST^SQLDD(fid)		; select *
	F i=1:1:$L(list,",") D
	.	S col=$P(list,",",i)
	.	S v=$$PREPARE(col,fid,.vpack)	; Get column attributes
	.	S pre=pre_v_$$BYTECHAR^SQLUTL(255)	; prepare information
	Q pre
