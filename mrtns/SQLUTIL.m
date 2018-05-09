SQLUTIL ;Public;schema and data loading utility for Oracle/db2
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/03/03 14:45:49 - GIRIDHARANB
        ; ORIG: GIRIDHARANB - 01/06/03
        ; DESC: schema and data loading utility for Oracle/db2
        ;
        ; KEYWORDS:     ORACLE,DB2,SQLLDR
        ; LIBRARY:
        ;       . IMPORT   - Import text file (tab separated) into PROFILE
	;                    database
	;
        ;       . EXPORT   - Export data from PROFILE database based on a
	;                    SQL SELECT statement
	;
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
	;       . CUVAR    - Create CUVAR DDL statements
	;	
	;	. DBMAP    - Create mapping utility 
	; I18N=QUIT
	;---- Revision History -----------------------------------------------
	; 06/29/09 - GIRIDHARANB - CR41479
	;	     Added section DB2 to generate control cards for DB2 z/OS
	;	     Modified referenced to STBL-RESERVED to check based on db type.
	;		
	; 08/03/06 - RussellDS - CR22519
	;	     Modified to replace the call to MAP^DBSDDMAP with a call
	;	     to the new label MAPPING^DBMAP to return the mapping array.
	;
	; 07/13/06 - RussellDS - CR22121
	;	     Eliminate use of ^UCOLLATE and use end point for collation
	;	     of $$getPslValue^UCOPTS("maxCharValue") to make Unicode
	;	     compliant.
	;
	; 10/27/05 - Giridharan - CR18016
	;	     Modified section type to change the oracle data type to a CLOB
	;	     for memo columns larger than 4000 bytes.
	;
	; 05/24/05 - RussellDS - CR16071
	;	     Added "BA" transaction ID to tstart.
	;		   
	;	     Removed old revision history.
	;
	; 09/29/04 - Giridharanb - 11951
	;	     Modfied section LIST to correct error with duplicate column
	;	     names in the column list.
	;
	;----------------------------------------------------------------------
	Q
	;----------------------------------------------------------------------
IMPORT(file,table,option,errfile,del) ; Private ; Import data file (EXCEL format)
	;----------------------------------------------------------------------
	; Utility to import text file (tab separated format) into PROFILE
	; database.  The first row of the data file identifies the column names
	; (DATA-QWIK data item name).  A temporary M routine will be created to
	; process the SQL INSERT or UPDATE operation.  Rejected records will be
	; stored in a reject file (specified by the 4th parameter) and it can
	; be edited and imported again.
	;
	; ARGUMENTS:
	;
	; . file	Input file name		/TYP=T/REQ/MECH=VAL
	;   		RMS/UNIX file
	;
	; . table	DATA-QWIK table name	/TYP=T/REQ/MECH=VAL
	;
	; . option	Processing mode		/TYP=N/NOREQ/DEF=0/MECH=VAL
	;		0 - Insert new records
	;		1 - Update existing records
	;
	; . errfile	Reject file name	/TYP=T/NOREQ/DEF=SYS$LOGIN:IMPORT_ERR.LOG/MECH=VAL
	;               (store start time, stop time, and rejected records)
	;
	; . del		Field delimiter		/TYP=N/NOREQ/DEF=9/MECH=VAL
	;               support 9 (tab) and 124 (|) but not 44 (comma)
	;
	; EXAMPLE:
	;
	;  D IMPORT^SQLOADER("SYS$LOGIN:CCODE.TXT","UTBLCC",0)
	;  D IMPORT^SQLOADER("/V60DEV/CCODE.TXT","UTBLCC",0,"/V60DEV/SPOOL/CCODE.LOG") 
	;  D IMPORT^SQLOADER(/V53DEV/BRCD.TXT","UTBLBRCD",1)
	;
	; Record format
	;
	; column_name<tab>column_name<tab>...    (first record)
	; column_val<tab>column_val<tab>...	 (2->n records)
	;
	; Sample input data file
	; ----------------------
	;
	; CCODE<tab>DESC
	; 123<tab>new cc
	; 234<tab>cc 234
	; 90012<tab>Malvern Branch
	;
	; Sample log file
	; ---------------
	;
	; Username 06/01/98 11:45 AM	<--- user and start time
	; INSERT UTBLBRCD BRCD,DESC	<--- table and column names
	;
	; Record already exists		<--- error message
	; 90012   Malvern Branch	<--- rejected record
	;
	; 06/01/98 11:48 AM		<--- stop time
	;
	;----------------------------------------------------------------------
	K ER,RM
	N (%DB,ER,RM,del,file,table,option,errfile)
	I '$G(del) S del=9			; Column separator
	S option=$G(option)+0			; Insert/update
	I $G(errfile)="" S errfile=$$HOME^%TRNLNM("IMPORT_ERR.LOG")
	I $G(table)="" Q			; Missing table name
	I file=errfile Q			; Same file name?
	I '$D(^DBTBL("SYSDEV",1,table)) S ER=1,RM=$$^MSG(1484,table) Q	; Not valid table name
	;					; Open input data file
	S x=$$FILE^%ZOPEN(file,"READ",5,4096) I 'x S ER=1,RM=$$^MSG(1337,file) Q
	;		
	S list=$$^%ZREAD(file,.er)		; Read header record
	C file
	I er Q					; Read error
	I list="" Q				; Missing header record
	I $L(list,"|")>1 s list=$p(list,"|",2)
	U 0
	I '$$vercol(table,list) C file Q	; Invalid column names
	;
	I 'option D insert Q
	D update
	Q
	;
	;----------------------------------------------------------------------
insert	; Insert new records
	;----------------------------------------------------------------------
	; INSERT INTO table (column_list) VALUES (column_value)
	;
	u 0
	S list=$TR(list,$C(del),",")		; Replace delimiter with ,
	S vlist="",vcol=""
	F i=1:1:$L(list,",") D
	.	S vlist=vlist_",:ZZ"_i
	.	S vcol=vcol_",ZZ"_i_"=$P(data,$C("_del_"),"_i_")"
	S vlist=$E(vlist,2,999)
	S vcol=" S "_$E(vcol,2,999)
	S sql=" S ER=&&sqlinsert("_""""_table_" ("_list_") VALUES ("_vlist_")"_""""_")"
	D build
	Q
	;----------------------------------------------------------------------
update	; update existing records
	;----------------------------------------------------------------------
	; UPDATE table SET column=value,column=value,... WHERE key=val and ...
	;
	u 0
	S list=$TR(list,$C(del),",")		; Replace delimiter with ,
	S vlist="",vcol="",whr=""
	F i=1:1:$L(list,",") D
	.	S di=$P(list,",",i)		; Column name
	.	S expr=di_"=:ZZ"_i		; di=:var
	.	S vcol=vcol_",ZZ"_i_"=$P(data,$C("_del_"),"_i_")"
	.	I $$NOD^SQLDD(table_"."_di)?1N1"*" S whr=whr_" AND "_expr
	.	E  S vlist=vlist_","_expr
	S vlist=$E(vlist,2,999)
	S vcol=" S "_$E(vcol,2,999)
	S sql=" S ER=&&sqlupdate("_""""_table_" SET "_vlist
	S sql=sql_" WHERE "_$E(whr,6,9999)_""""_")"
	D build
	Q
build	;
        D add(" S x=$$FILE^%ZOPEN(file,""READ"",5,4096) I 'x Q")
        D add(" S x=$$FILE^%ZOPEN(errfile,""WRITE/NEWV"",5,4096) I 'x Q")
	D add(" U errfile W $$USERNAM^%ZFUNC,"" "",$$DAT^%ZM(+$H),"" "",$$TIM^%ZM,!")
	D add(" U errfile W !,"_""""_$S(option:"UPDATE ",1:"INSERT ")_list_""""_",!!")
	D add(" S data=$$^%ZREAD(file,.er) I er C file Q")	; Skip header record
	D add(" F  S data=$$^%ZREAD(file,.er) Q:er  D exec")	; Get data record
	D add(" U errfile W !,$$DAT^%ZM(+$H),"" "",$$TIM^%ZM,!")
	D add(" C file")					; Close data file"
	D add(" C errfile")	; Close exception file
	D add(" Q")
	D add("exec ;")
	D add(" u 0")
	D add(vcol)
	D add(" TSTART ():transactionid=""BA""")
	D add(sql)						; execute SQL
	D add(" I ER U errfile W $g(RM),!,data,! ; Exception file")
	D add(" I ER TROLLBACK  Q")
	D add(" I $TLEVEL TCOMMIT")
	D add(" Q")
	D compile(sql)						; build rtn
	Q
	;----------------------------------------------------------------------
EXT	; External interface
	;----------------------------------------------------------------------
	; Prompt for Input file name, DATA-QWIK table name, and log file name
	;
	N %FRAME,%TAB,%READ,DEL,IO,KVAR,LOG,MSG,OPT,PGM,TABLE,VFMQ,X
	S MSG="Database Import Utility"
	S LOG=$$HOME^%TRNLNM("IMPORT_ERR.LOG")	; Default log file
	S OPT=0					; Create mode
	S %FRAME=2
	;
	S %TAB("IO")=".IODUMP2"			; Input file name
	S %TAB("TABLE")=".DOCFID1/LEN=12/TYP=U"	; DQ table name
	S %TAB("OPT")=".OPT11"			; Processing option
	S %TAB("LOG")=".LOG4"			; Log file
	S %READ="@MSG/REV/CEN,,IO/REQ,TABLE/REQ,OPT/REQ,LOG,DEL"
	D ^UTLREAD
	I VFMQ="Q" Q
	D IMPORT(IO,TABLE,OPT,LOG,DEL)		; Import data
	Q
	;----------------------------------------------------------------------
EXPORT(expr,file,hdropt,del,comp,delflg)	;Private; Utility to execute SQL SELECT statement
	;----------------------------------------------------------------------
	; Utility to export data from PROFILE database and save it to a text
	; file.  Based on the SELECT statement, a temporary run-time routine
	; will be created to extract records from the database and save it
	; to a text file in a tab separated format (specified by the 4th
	; parameter).  If the header option (3rd parameter) is set to 1, the
	; column names will be included as the first row of the output file.
	; 
	; Values for Date and Time data types will be converted to its external
	; format MM/DD/YEAR and HH:MM:SS.
	;
	; ARGUMENTS:
	;
	; . expr	SQL SELECT statement	/TYP=T/REQ/MECH=VAL
	;               or table name
	;
	; . file	Output data file name	/TYP=T/REQ/MECH=VAL
	;
	; . hdropt	Column header option	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;               **** valid for single table only ****
	;	        0 = no header
	;               1 = Include table name and column names as first row of the data file
	;               2 = Include column names only
	;               3 = Include column names in ORACLE SQL*Loader format
	;
	;                   parameter_1.CTL will include following information:
	;
	;			LOAD DATA
	;			INFILE Parameter_2
	;			INTO TABLE Parameter_1
	;			FIELDS TERMINATED BY X'9' OPTIONALLY ENCLOSED '"'
	;			("column_1","column_2",...)
	;
	; . del		Field delimiter		/TYP=N/NOREQ/DEF=9/MECH=VAL
	;
	; . comp	Include computed item	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;
	; . delflg	No data flag		/TYP=L/NOREQ/MECH=REF
	;	        An output parameter that indicates that there is no data
	;	        in the specified table and the associated .dat file should
	;	        be deleted.  This flag is only used in section EXPALL.
	;
	; OUTPUT:
	;
	;   ER		Error flag
	;   RM		Error message
	;
	; EXAMPLE:
	;
	; Example 1:
	; ==========
	; D EXPORT^SQLOADER("UTBLCC","SYS$LOGIN:UTBLCC.DAT")
	;
	; Output (use standard TAB delimiter)
	; -----------------------------------
	;
	; 1<tab>MAIN
	; 2<tab>CC 2
	;
	; Example 2:
	; ==========
	; D EXPORT^SQLOADER("SELECT * FROM UTBLCC","SYS$LOGIN:UTBLCC.TXT",1,124)
	;
	; Output (select all columns and also use | for field delimiter)
	; --------------------------------------------------------------
	;
	; CCODE|DESC
	; 1|MAIN
	; 2|CC 2
	;
	; Example 3:
	; ==========
	; D EXPORT^SQLOADER("SELECT CID,BAL FROM LN WHERE TYPE=123","SYS$SPOOL:Z.Z")
	;
	; Output (select data based on query)
	; -----------------------------------
	;
	; 123<tab>2000.55
	; 222<tab>1234.56
	;
	; Example 4:
	; ==========
	; D EXPORT^SQLOADER("SELECT CID,BAL FROM LN WHERE TYPE=123","SYS$SPOOL:Z.Z",1)
	;
	; Output (use header option 1)
	; --------------------------
	; 
	; LN|CID<tab>BAL
	; 123<tab>2000.55
	; 222<tab>1234.56
	;
	; Example 5:
	; ==========
	; D EXPORT^SQLOADER("SELECT CID,BAL FROM LN WHERE TYPE=123","SYS$SPOOL:Z.Z",2)
	;
	; Output (use header option 2)
	; --------------------------
	;
	; CID<tab>BAL
	; 123<tab>2000.55
	; 222<tab>1234.56
	;
	; Example 6:
	; ==========
	; D EXPORT^SQLOADER("UTBLCC","SYS$SPOOL:UTBLCC.DAT",3)
	;
	; Output (use header option 3)
	;
	;   data file UTBLCC.CTL
	;   --------------------
	;
	;   LOAD DATA
	;   INFILE SYS$SPOOL:UTBLCC.DAT
	;   INTO TABLE "UTBLCC"
	;   FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED '"'
	;   ("CCODE","DESC")
	;
	;   data file SYS$SPOOL:UTBLCC.DAT
	;   ------------------------------
	;
	;   1<tab>MAIN
	;   2<tab>CC 2
	;
	;----------------------------------------------------------------------
	N %ZRO,code,col,collen,column,ddref,fsn,hdr,i,j,keylist,keypos,msrc,rtn,src,tblarr,vtbl,y
	N table,type,vsqltag,z
	;
	S ER=0
	I $G(expr)="" Q
	I expr?1A.AN D				; Table name
	.	I $G(file)="" S file=$$HOME^%TRNLNM(expr_".DAT")
	.	I ",DEP,LN,"[expr D SPLIT("ORACLE",expr,.tblarr,file) I 1
	.	E  S tblarr(expr)=file_"|SELECT * FROM "_expr	; Select all
	;
	;
	S vtbl=""
	F  S vtbl=$O(tblarr(vtbl)) Q:vtbl=""  D EXPORT1(vtbl,hdropt)
	D add(" Q")					; close device
	D compile(expr)
	;
	;close all files
	S vtbl=""
	F  S vtbl=$O(tblarr(vtbl)) q:vtbl=""  D
	.	N IO
	.	S IO=$P(tblarr(vtbl),"|",1)
	.	C IO
	Q	
	;	
	;
EXPORT1(vtbl,hdropt)
	N col,expr,file,gbl,table,z
	Q:'$D(tblarr(vtbl))
	;
	S file=$P(tblarr(vtbl),"|",1)
	S expr=$P(tblarr(vtbl),"|",2)
	;
	I $G(file)="" Q
	I '$G(del) S del=9			; Default delimiter (TAB)
	S expr=$$UPPER^UCGMR($p(expr,$C(13),1))
	S z=$$UPPER^UCGMR(expr)
	I $E(z,1,7)'="SELECT " Q
	S expr=$E(expr,8,$L(expr))			; Remove SELECT
	S col=$P(expr," ",1)			; Column list
	S table=$P($P(z,"FROM ",2)," ",1)	; Table name
	D fsn^SQLDD(.fsn,$p(table,",",1))
	S gbl=$P(fsn(table),"|",2)
	Q:gbl=""				; no global means no data
	;
	I col="*" D  I ER Q			; Allow single table only
	.	S col=$$LIST(table,$G(comp),.collen)	; Entire table
	.	S expr=col_$e(expr,2,999)	; Change expression
	;
	I $g(hdropt)=3 D ORACLE(vtbl)		; ORACLE loader format
	I $g(hdropt)=4 D DB2(vtbl)		; DB2 Load control card.
	;
	I $G(hdropt) D  I ER Q
	.	S hdr="",keypos=""					; 03/18/99 BC
	.	S keylist=","_$p(fsn($p(table,",",1)),"|",3)_","	; access key KEYS
	.	F i=1:1:$L(col,",") D
	..		S:i>1 hdr=hdr_$C(del)				; column header
	..		S hdr=hdr_$P(col,",",i)				; 
	..		N COMPARE
	..		S COMPARE=","_$p(col,",",i)_","
	..		if keylist[COMPARE s keypos=keypos_","_i
	.	S keypos=$E(keypos,2,100)
	.	S hdr=$$UPPER^UCGMR(hdr)				; Uppercase
	.	;							; 
	.	I $G(hdropt)=1 S hdr=table_$C(del)_keypos_"|"_hdr	; header option 1
	.	S hdr=$$replace(hdr,del)
	;
	D add(" S POP="""_file_""",RECSIZ=4096 D ^SCAIO I $G(ER) Q")		; Assign device
	;
	I $G(hdropt) D add(" U IO W hdr,!")		; file header
	D add(" N cnt S cnt=&&sqlopen("_""""_expr_""""_")")
	D add(" S delflg=0")
	D add(" I 'cnt D  Q")
	D add(" .      C IO")
	D add(" .      S delflg=1")             ; empty
	D add(" F  Q:'&&sqlfetch(.data)  D")		; fetch rows
	F i=1:1:$L(col,",") D  I ER Q			; validate each column name
	.	S ddref=$$CVTREF^SQLDD($P(col,",",i),table) I $G(ER) Q
	.	S type=$$TYP^SQLDD(ddref)		; data type
	.	S z="$P(data,$C(9),"_i_")"		; convert date and time
	.	;I type="D" D add(" . S "_z_"=$$DAT^%ZM("_z_","_""""_"MM/DD/YEAR"_""""_")")
	.	;I type="C" D add(" . S "_z_"=$$TIM^%ZM("_z_","_""""_"24:60:SS"_""""_")")
	.	;S x="$$DFT^SQLDD("""_ddref_""")"
	.	;S x="$CVTREF^SQLDD($P("_col_""","","_i_"),"_table_")"
	.	;D add(" . I "_z_"="""" S $P(data,$C(9),"_i_")="_x)
	.	;D add(" . I "_z_"="""" S $P(data,$C(9),"_i_")=$$DFT^SQLDD(ddref)")
	.	;D add(" . I $P(data,"","",i)="""" S $P(data,"","",i)=$$DFT^SQLDD(ddref)")
	I ER Q
 	I del=9 D add(" . U IO W data,!"); fetch rows
	I del'=9 D add(" . U IO W $TR(data,$C(9),$C("_del_")),$C("_del_"),!")
	Q
	;----------------------------------------------------------------------
compile(comment) ;
	;----------------------------------------------------------------------
	N (%DB,delflg,hdr,msrc,src,code,comment,file,errfile,fsn,outfile,ER,RM)
	I $G(outfile)'="" S file=outfile
	S ER=0
	U 0
	S rtn="Z"_($J#10000000)			; Run-time routine name
	S src(0.9)=" N (%DB,delflg,errfile,file,hdr,rtn,ER,RM)"
	S src(0.91)=" D SYSVAR^SCADRV0(""PBS"")"
	D ^DBSPARS2("",.src,.msrc)		; Parse &&macro statements
	;
	D COMPILE^SQLCMP(.vsqltag,.code)	; Build routine
	;
	S i=$O(msrc(""),-1)+1
	S j="" F  S j=$O(code(j)) Q:j=""  s msrc(i)=code(j),i=i+1
	;
	S msrc(0.1)=rtn_" ;"
	S msrc(0.2)=" ;"
	S msrc(0.3)=" ; "_$E(comment,1,450)
	S msrc(0.4)=" I $$NEW^%ZT N $ZT"		; 03/10/99 BC
        S msrc(0.5)=" S @$$SET^%ZT(""ER"") ; set up error trap"
	S msrc(0.8)=" S file="_""""_file_""""
	I $D(errfile) S msrc(0.9)=" S errfile="_""""_errfile_""""
	S z=$O(msrc(""),-1)+1
	S msrc(z)="ER C:$D(IO) IO D ZE^UTLERR Q  ; log error"	; 03/10/99 BC
	;
	D ^DBSCMP(rtn,"msrc")			; Create temporary routine
	;w !,rtn					; Display routine name
	K src,msrc,vsqltag,code,comment,zexpr,file,errfile
	D ^@rtn					; Run
	D DEL^%ZRTNDEL(rtn)			; Delete routine
	Q
	;----------------------------------------------------------------------
add(line) ; Insert procedure code into array
	;----------------------------------------------------------------------
	N ln
	S ln=$O(src(""),-1)+1
	S src(ln)=line
	Q
	;----------------------------------------------------------------------
vercol(table,list) ; Validate column names
	;----------------------------------------------------------------------
	N i,OK
	S OK=1
	F i=1:1:$L(list,$C(del)) I '$$VER^DBSDD(table_"."_$P(list,$C(del),i)) S OK=0 Q
	I 'OK S RM="Invalid header record ("_list_")"
	Q OK
	;----------------------------------------------------------------------
SCRIPT(file,hdropt,del) ; Export data based on SQL statements stored in a script file
	;----------------------------------------------------------------------
	; This function opens the text file, process each SQL statement
	; (separated by the header record) and output selected row data to
	; files defined in the header record (/* space output_file_name).
	;
	; ARGUMENTS:
	;
	; . file	Script file name	/TYP=T/REQ/MECH=VAL
	;
	; . hdropt	Column header option	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;	        0 = no header
	;               1 = Include table name and column names as first row of the data file
	;               2 = Include column names only
	;
	; . del		Field delimiter		/TYP=N/NOREQ/DEF=9/MECH=VAL
	;
	;
	; Script file structure
	; ---------------------
	; /* output_file_name		(header record  /* followed by a space)
	; single SQL SELECT statement ...       
	; continue ...
	; /* output_file_name
	; single SQL SELECT statement ...
	; // comment line		(line started with //)
	;
	; EXAMPLE:
	;
	; content of the script file
	; ------------------------------
	; // comments				<---- comment line (skipped)
	; /* /v60dev/FILEA.DAT			<---- output file name
	; SELECT CID,BAL,LNM FROM DEP
	;					<---- blank line (skipped)
	; /* /home/FILEB.DAT			<---- output file name
	; SELECT ACN,DOB,TAXID			<---- statement 
	; FROM CIF				<---- continue
	; // end of the script file		<---- comment line (skipped)
	;
	;
	; EXAMPLE 1:
	; ==========
	;
	; Use header option 2 and TAB as the column delimiter
	;
	; D SCRIPT^SQLOADER("/v60dev/TEST.TXT",2)
	;
	; output file /v60dev/FILEA.DAT
	;-------------------------------------
	; CID<tab>BAL<tab>LNM
	; 123<tab>100<tab>John Doe
	; 234<tab>250.45<tab>Smith
	;
	; output file /home/FILEB.DAT
	;-------------------------------------
	; ACN<tab>DOB<tab>TAXID
	; 11<tab>01/23/55<tab>111-11-1234
	; 15<tab>05/22/77<tab>123-45-9999
	;
	; EXAMPLE 2:
	; ==========
	;
	; No header and use | as the column delimiter
	;
	; D SCRIPT^SQLOADER("/v60dev/TEST.TXT",0,124)
	;
	; output file /v60dev/FILEA.DAT
	;-------------------------------------
	; 123|100|John Doe
	; 234|250.45|Smith
	;
	; output file /home/FILEB.DAT
	;-------------------------------------
	; 11|01/23/55|111-11-1234
	; 15|05/22/77|123-45-9999
	;----------------------------------------------------------------------
	N er,i,outfile,sqlexpr,v,x
	;
	I $G(file)="" Q
	S x=$$FILE^%ZOPEN(file,"READ",5,4096) I 'x S ER=1,RM=$$^MSG(1337,file) Q
	;
	S sqlexpr=""
	F  S v=$$^%ZREAD(file,.er) Q:er   D
	.	I v="" Q				; Blank line
	.	I $E(v,1,2)="//" Q			; Comment line
	.	I $E(v,1,3)'="/* " D  Q
	..		I sqlexpr="" S sqlexpr=v Q	; First statement line
	..		S sqlexpr=sqlexpr_" "_v Q	; Join long statement
	.	I sqlexpr'="" D extract			; Extract data
	.	S outfile=$E(v,4,99)			; Output file name
	.	F i=1:1:$L(outfile) Q:$E(outfile,i)'=" "  ; 02/24/99 BC
	.	S outfile=$E(outfile,i,999)		; Remove leading blanks
	.	F i=$L(outfile):-1:1 Q:$E(outfile,i)'=" "
	.	S outfile=$E(outfile,1,i)		; Remove trailing blanks
	C file
	I sqlexpr'="" D extract				; Last statement
	Q
extract	;
	I sqlexpr="" Q
	;						; Export data
	D EXPORT(sqlexpr,outfile,$G(hdropt),$G(del))
	S sqlexpr=""					; Reset expression
	Q
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
	S computed=$G(computed)
	S req="",noreq="",comp=""
	;
	D fsn^SQLDD(.fsn,table)			; Table attributes
	I ER Q
	S req=$P(fsn(table),"|",3)		; Access keys
	;
	S di="" F  S di=$O(^DBTBL("SYSDEV",1,table,9,di)) Q:di=""  D
	.       I ",DEP,LN"[table,$D(^DBTBL("SYSDEV",1,"ACN",9,di)),di'="CID" quit
	.	S v=^DBTBL("SYSDEV",1,table,9,di)
	.	S collen(di)=$P(v,"|",2)
	.	;I $P(v,"|",18)'="" Q		; Skip sub-field
	.	I $P(v,"|",1)["*" Q		; Skip access key
	.	I $P(v,"|",16)'="" D  Q		; Computed
	..		I 'computed,$E($P(v,"|",16))'[" " Q
	..		S comp=comp_","_di Q
	.	I $P(v,"|",15) S req=req_","_di Q	; Required
	.	S noreq=noreq_","_di
	;
	S v=req_noreq_comp
	I $E(v)="," S v=$E(v,2,9999)
	Q v
	;----------------------------------------------------------------------
DDL(table,outfile,com,index,comp,tblspace,fkey,db)	; Create SQL DDL
	; script based on DQ file definition
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;  . table	Table name		/TYP=U/REQ/MECH=VAL
	;               Sigle: Table_name
	;               Range: From_Table-To_table
	;               All  : *
	;
	;  . outfile	output file name	/TYP=T/REQ/MECH=VAL
	;  . com	Include comments	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;  . index      Include index def	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;  . comp	Include computed items	/TYP=L/NOREQ/DEF=0/MECH=VAL
	;  . tblspace	Table space name	/TYP=T/NOREQ/MECH=VAL
	;  . fkey       Include foreign keys    /TYP=L/NOREQ/DEF=0/MECH=VAL
	;
	; EXAMPLE:
	;
	; D DDL("CIF","SYS$LOGIN:CIF.SQL",1,1)
	; D DDL("*","SYS$LOGIN:PROFILE.SQL")
	;
	;----------------------------------------------------------------------
	N akeys,comment,cnt,count,di,from,fsn,i,j,keys,list,q,select,xdinam,LIBS
	N dec,def,desc,dinam,error,len,node,pos,req,sub,tlen,to,typ,x
	N fcount
	K ^ZSCHEMA
	;
	S db=+$G(db)
	I $G(outfile)="" S outfile=$$HOME^%TRNLNM(table_".SQL")	; default
        S x=$$FILE^%ZOPEN(outfile,"WRITE/NEWV",5) I 'x Q	; script file
	I table?1A.AN!(table["_") D  q
	.	D DDL1(table)
	.	I $G(fkey) D fkey	;define foreign keys 
	.	C outfile 
	.	D DSPERR Q	; Single table
	;
	I table["-" D						; Range
	.	S from=$P(table,"-",1)
	.	S to=$P(table,"-",2)
	I table="*" S from="",to=$C($$getPslValue^UCOPTS("maxCharValue"))
	;
	S fcount=0
	;
	; Do first table
	I from'="*",from'["DBTBL",$D(^DBTBL("SYSDEV",1,from)) D DDL1(from) S fcount=1
	S table=from
	F j=1:1 S table=$O(^DBTBL("SYSDEV",1,table)) Q:table=""!(table]to)  D
	.       I table["DBTBL" Q
	.	D DDL1(table)
	.	S fcount=fcount+1
	.	I '(fcount#25) u 0 w !,fcount,"   ",table
	;
	I $G(fkey) D fkey		; Define foreign keys
	C outfile
	D DSPERR
	Q
	;
DDL1(table)	; Create table definition
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
	N comment,fsn,tblarr,tmptable
	;
	I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	I %DB="" S %DB="GTM"
	;
	I '$D(^DBTBL("SYSDEV",1,table)) D  Q
	.	D ERROR("Table "_table_" does not exist in ^DBTBL")

	;	I $P(^DBTBL("SYSDEV",1,table,10),"|",12)=5 D  Q
	;	D ERROR("Table "_table_" not exported - dummy file")
	;
	S q="""",tlen=0
	S count=0,select=""
	S LIBS="SYSDEV"
	S comment=$G(^DBTBL(LIBS,1,table))		; Table description
	S comment=$TR(comment,"&'","+")
	D fsn^SQLDD(.fsn,table)				; Table attributes
	S akeys=$P(fsn(table),"|",3)			; Access keys
	D BLDINDX^DBSDF9(table)				; Create dinam xref file
	;
	; logic for large tables
	I "DEP,LN"[table D  ;Wide table
	.	D SPLIT(%DB,table,.tblarr,outfile)
	.	N spltbl S spltbl=""
	.	F  S spltbl=$O(tblarr(spltbl)) q:spltbl=""  D
	..		S list=$P(tblarr(spltbl),"|",2)
	..		S list=$P(list," ",2)
	..		N i,keys
	..		F i=1:1:$L(akeys,",") S keys($P(akeys,",",i))=""
	..		F i=1:1:$L(list,",") I $D(keys($P(list,",",i))) K keys($P(list,",",i))
	..		S keys=""  F  S keys=$O(keys(keys)) Q:keys=""  S list=list_","_keys
	..		D DDL2(spltbl,table,list,akeys)
	;
	E  D  ;Regular Table
	.	I $D(^STBL("RESERVED",%DB,table)) S tmptable="S_"_table
	.	E  S tmptable=table
	.	S list=$$LIST(table,$G(comp))		 	; Data item list
	.	S list=$P(list,",",1,9999)			; limit number of columns
	.	I list="" D ERROR("No columns in table "_table) Q
	.	D DDL2(tmptable,table,list,akeys)
	;
	I $G(index) D index(table)
	Q
	;
DDL2(tmptable,proftbl,list,akeys)
	I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	I %DB="" S %DB="GTM"
	I $G(proftbl)="" S proftbl=tmptable	;large table
	S ^ZSCHEMA(proftbl)=""
	;
	U outfile
	W !,"CREATE TABLE ",tmptable		;
	;					; Column definition
	W !,"("
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
	.	I $E(dinam)="%" S dinam="X"_$E(dinam,2,99)  ;pc 7/5/2001 % not permitted in Oracle
	.	S di=""""_dinam_"""" 
	.	I $D(^STBL("RESERVED",%DB,dinam)) D 
	..		S ^ZREST(proftbl_"."_dinam)=""
	..		;D ERROR("Invalid column name - reserved: "_table_"."_dinam)
	..		S di=q_"S_"_$E(di,2,99)	;add sentinel to front to make it acceptable
	.	S node=$P(x,"|",1),len=$P(x,"|",2),def=$P(x,"|",3)
	.	S typ=$P(x,"|",9),dec=$P(x,"|",14)+0
	.	S sub=$P(x,"|",18),req=$P(x,"|",15),pos=$P(x,"|",21)
	.	S desc=$P(x,"|",10),cmp=$P(x,"|",16)
	.	I len>2000 S len=2000			; Maximum length
	.	S tlen=tlen+len
	.	I "UTF"[typ S tlen=tlen+4		; 4 bytes of overhead
	.	;;  	.	I sub'="" Q				; Sub-field
	.	;
	.	;S comment(dinam)=desc			; Description
	.	S desc=$TR(desc,"&'","+")
	.	S comment(di)=desc			; pc 7/5/2001
	.	;					; Access key or required item
	.	;I (node?1N1"*")!($$REQ^SQLDD(proftbl_"."_dinam)) D
	.	I (node?1N1"*") D
	..		W !,"  "_di_"  "_$$type(typ,db)_" NOT NULL"
	.	E  W !,"  "_di_"  "_$$type(typ,db)
	.	I def'="" D default(def,typ)
	.	I i'=cnt W ","				; not last column
	.	S count=count+1				; Item counter
	;
	;Check keys for invalid names (i.e., reserved words)
	;if reserved word, add "S_" to the front.
	S akeys=$$replace(akeys)	;replace invalid column names
	;
	I akeys'="" W !,", PRIMARY KEY ("_akeys_")"
	W !,")"
	I $G(tblspace)="" W " ;"			; End of definition
	E  W !," IN "_tblspace_" ;"			; Table space
	W !
	;
	I tlen>7000 D ERROR("Total length of table "_proftbl_" is "_tlen)
	;
	I $G(com) D comment(tmptable)			; comments
	;
	;I $G(index) D index(proftbl)			; Index definition
	;
	;
	Q
	;----------------------------------------------------------------------
default(v,type) ; default value
	;----------------------------------------------------------------------
	Q
	I v="<<TJD>>"!(v="<<+$H>>")!(v="T") W " DEFAULT CURRENT DATE" Q
	;I v?1"<<$P($H,".E W " DEFAULT CURRENT TIME" Q
	I v'=$$UPPER^UCGMR(v) Q
	I v["<<" Q
	I "N$"[type W " DEFAULT "_v Q			; Numeric
	W " DEFAULT '"_v_"'"				; Text
	Q
	;----------------------------------------------------------------------
comment(table) ; table and column comments
	;----------------------------------------------------------------------
	W !,"COMMENT ON TABLE "_table_" IS '"_$TR(comment,"'","")_"';"	; table description
	;							; column description
	S di="" F  S di=$O(comment(di)) Q:di=""  D
	.	W !,"COMMENT ON COLUMN "_table_"."_di_" IS '"_comment(di)_"';" 
	.	K comment(di)
	Q
	;----------------------------------------------------------------------
type(typ,db) ; convert DQ data type
	;----------------------------------------------------------------------
	;
	N x,TYPE
	S TYPE=""
	I db=0 DO  quit TYPE   				    ;Oracle format
	.	I typ="L" S TYPE="CHAR(1)" Q
	.	I typ="N" D  S TYPE=x Q
	..		I 'dec,len<10 s x="NUMBER" Q		; Max 9 digits(code
	..		I 'dec  s x="NUMBER("_len_")" Q		; Max 30 digits(account)
	..		I dec,dec>len s len=dec+1		; Length error?
	..		S x="NUMBER("_len_","_dec_")" Q		; Example:INTEREST RATE
	.	I typ="$" S TYPE="DECIMAL("_(len+2)_","_dec_")" Q	;Currency
	.	I typ="D" D  S TYPE=x Q
	..		S x="NUMBER" Q				; Date
	..		S x="INTEGER" Q				; 
	.	;I typ="C" S TYPE="TIME" Q			;timestamp
	.	I typ="C" S TYPE="VARCHAR2("_len_")" Q		;timestamp
	.       I typ="M" D
	..              I len>4000 S TYPE="CLOB" Q
	..              E  S TYPE="VARCHAR2("_len_")" Q
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
	;----------------------------------------------------------------------
index(proftbl)	; Index definition
	;----------------------------------------------------------------------
	; DROP INDEX index_name
	; CREATE INDEX index_name ON Table (index_key1,index_key2)
	;----------------------------------------------------------------------
	N akey,fsn,i,idx,index,indexnm,k,key,seq,temptab,v
	I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	I %DB="" S %DB="GTM"	
	D fsn^SQLDD(.fsn,proftbl)
	I $G(ER) D ERROR(RM) K ER Q			; Invalid table name
	S akey=$p(fsn(proftbl),"|",3)			; Access keys
	I akey="" Q
	F i=1:1:$L(akey,",") S akey($P(akey,",",i))=""
	S index=""
	F  S index=$O(^DBTBL("SYSDEV",8,proftbl,index)) Q:index=""  D
	.	S v=^(index)				; index definition
	.	S query=$P(v,"|",7)			; with query condition
	.	S seq=$P(v,"|",3)			; index order by
	.	S key=""
	.	F i=1:1:$L(seq,",") D
	..		S k=$P(seq,",",i)
	..		I $E(k)="""" Q			; dummy key
	..		I $E(k)?1N Q
	..		I $E(k)="-" Q
	..		I akey'[",",$D(akey(k)) Q	; Remove access key
	..		S key=key_","_k
	.	S key=$E(key,2,99)
	.	I key="",query'="" D			; missing column name
	..		S key=query			; find it in the query
	..		I key["." S key=$P(key,".",2)	; remove table name
	..		F i=1:1:$L(key) Q:$E(key,i)'?1A	; locate data item
	..		S key=$E(key,1,i-1)
	.	;
	.	S ER=$$vindex(key,proftbl,index,.indexnm,.indtbl)
	.	;
	.	;Check keys for invalid names (i.e., reserved words)
	.	;if reserved word, add "_" to the front.
	.	S key=$$replace(key)
	.       I $D(^STBL("RESERVED",%DB,indtbl)) S temptab="S_"_indtbl
	.       E  S temptab=indtbl
	.	;
	.	I key="" D ERROR("Invalid index definition "_indexnm_" ("_seq_")") Q
	.	W !,"DROP INDEX "_indexnm_" ;"
	.	W !,"CREATE INDEX "_indexnm_" ON "_temptab_"("_key_") PCTFREE 10 ;"
	.	;
	.	I $D(idx(key)) D ERROR("Duplicate index definition "_indexnm_" "_idx(key))
	.	S idx(key)=indexnm
	Q

        ;----------------------------------------------------------------------
fkey	; Output foreign key info
	;----------------------------------------------------------------------
	;
	N parent,table,ftable,fparent
	S table=""
	I $G(%DB)="" S %DB=$$SCAU^%TRNLNM("DB")
	u outfile
	F  S table=$O(^ZSCHEMA(table)) Q:table=""  d
	.	Q:'$D(^DBTBL("SYSDEV",19,table))
	.	N akey,i,I,keys,tab,x
	.	;
	.	S tab=$C(9)
	.	S keys=""
	.       f  S keys=$O(^DBTBL("SYSDEV",19,table,keys)) q:keys=""  d
	..              N zkey s zkey=""
	..              S x=^(keys)
	..              S parent=$P(x,"|",5)
	..              ;
	..              S akey=keys
	..              ; Replace invalid column names
	..              S akey=$$replace(keys)
	..              S ftable=table,fparent=parent
	..              F i=1:1:$L(keys,",") D
	...                     N fkey S fkey=$P(keys,",",i)
	...                     D MAP^DBMAP(%DB,.ftable,.fkey)
	...                     D MAP^DBMAP(%DB,.fparent,.fkey)
	...                     S zkey=zkey_","_fkey
	...                     S akey=$E(zkey,2,99)
	..              ;
	..              W !,"ALTER TABLE ",ftable,!
	..              W tab,"ADD  FOREIGN KEY (",akey,")",!
	..		W ?40,"REFERENCES ",fparent," ON DELETE CASCADE;",!
	Q
	;
	;----------------------------------------------------------------------
replace(keys,del); Replace invalid data item names w/ valid names.
	;	  Invalid names are names that are reserved keywords in
	;	  Oracle, DB2 and other commercial databases and also names
	;	  that contain invalid characters, such as %.
	;----------------------------------------------------------------------
	N I,x
	;
	I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	I %DB="" S %DB="GTM"	
	;
	I $G(del)="" S del=","
	E  S del=$C(del)
	F I=1:1:$L(keys,del) D				
	.	N x
	.	S x=$P(keys,del,I)
	.	q:x=""
	.	I $E(x)="%" S x="X"_$E(x,2,99)
	.	I $D(^STBL("RESERVED",%DB,x)) S x="S_"_x
	.	S $P(keys,del,I)=x
	Q keys
	;
	;----------------------------------------------------------------------
DDLINDEX(outfile)	;
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	; . outfile	Output file name	/TYP=T/REQ/MECH=VAL
	;
	; EXAMPLE:
	;
	; D DDLINDEX("HOME:INDEX.SQL")
	;
	;----------------------------------------------------------------------
	N error,fid,x
	;
    	S x=$$FILE^%ZOPEN(outfile,"WRITE/NEWV",5) I 'x Q
	U outfile					; create index def
	S fid="" F  S fid=$O(^DBTBL("SYSDEV",8,fid)) Q:fid=""  D index(fid)
	C outfile	D DSPERR					; display errors
	Q
	;----------------------------------------------------------------------
ERROR(msg)	; Log error message
	;----------------------------------------------------------------------
	N seq
	S seq=$O(error(""),-1)+1
	S error(seq)=msg
	Q
DSPERR	;
	I '$D(error) Q
	F i=1:1 Q:'$D(error(i))  U 0 w !,error(i)
	w !!,i-1," errors",!
	Q
STAT	;
	N cmp,i,len,tbl
	F tbl="LN","DEP","ACN","CUVAR","CIF" D
	.	S cmp=0,x="",len=0
	.	F i=1:1 S x=$O(^DBTBL("SYSDEV",1,tbl,9,x)) q:x=""  D
	..		I $P(^(x),"|",1)="" S cmp=cmp+1 Q
	..		S len=len+$P(^(x),"|",2)		; record length
	..		I "TUF"[$P(^(x),"|",9) S len=len+3	; overhead
	.	W !,tbl,?10,i-1,?20,cmp,?30,i-1-cmp,?40,len," Bytes"
	Q
	;----------------------------------------------------------------------
CUVAR(outfile) ; Create DDL statements for CUVAR table
	;----------------------------------------------------------------------
	; Four columns will be created for each table:
	;
	; NAME	VARCHAR(25)		-> DQ column name	TJD
	; VALUE	VARCHAR(200)		-> column value		56123
	; TYPE  VARCHAR(1)		-> column type		D
	; DESC  VATCHAR(200)		-> column description	system date
	;
	; ARGUMENTS:
	;
	; . outfile	DDL script file		/TYP=T/REQ/MECH=VAL
	;
	; EXAMPLE:
	;
	; D SYSINI("/home/CUVAR.SQL")
	;
	;----------------------------------------------------------------------
	N des,di,fsn,name,q,str,table,type,value,x
	I $G(outfile)="" Q
	;
	S table="CUVAR"
	D fsn^SQLDD(.fsn,table) I $G(ER) Q	; Invalid table name
	;
        S x=$$FILE^%ZOPEN(outfile,"WRITE/NEWV",5) I 'x S ER=1,RM=$$^MSG(1337,outfile) Q
        ;
	; Create SQL create table statements
	;
	U outfile
	W "CREATE TABLE "_table,!,"(",!
	W " NAME VARCHAR(25) NOT NULL,",!
	W " VALUE VARCHAR(200),",!
	W " TYPE VARCHAR(1) NOT NULL,",!
	W " DES VARCHAR(200) NOT NULL,",!
	W " PRIMARY KEY (NAME)",!
	W ") ;",!
	;
	; Create SQL insert statements
	;
	S q="'"
	S str="INSERT INTO "_table_" VALUES ("
	S di="" F  S di=$O(^DBTBL("SYSDEV",1,table,9,di)) Q:di=""  D
	.	I di["""" Q				; dummy key
	.	I $$CMP^SQLDD(table_"."_di)'="" Q	; Computed item
	.	S name=q_di_q				; column name
	.	S type=q_$$TYP^SQLDD(table_"."_di)_q	; type
	.	S des=q_$TR($$DES^SQLDD(table_"."_di),"'")_q		; description
	.	S value=q_$$^CUVAR(di)_q		; column value
	.	W str_name_","_value_","_type_","_des_") ;",!
	C outfile
	Q
	;----------------------------------------------------------------------
ORACLE(table)	; Build ORACLE SQL*loader control file
	;----------------------------------------------------------------------
	N c,cnt,coldel,ctlfile1,i,x
	S ctlfile1=$P(file,".",1,$L(file,".")-1)_".CTL"
        S x=$$FILE^%ZOPEN(ctlfile1,"WRITE/NEWV",5,4096) I 'x S ER=1,RM=$$^MSG(1337,ctlfile1) Q
	U ctlfile1					; Create SQL*Loader control file
	W "LOAD DATA",!
        W "INFILE '"_file_"'",!
        W "INTO TABLE "_table_"",!
	I $G(del)'=9 S coldel="'"_$C(del)_"'"		; field delimiter
	E  S coldel="X'124'"				; Tab
        W "FIELDS TERMINATED BY "_coldel_"",!
	S c="",cnt=0 F i=1:1:$L(col,",") D		; Build column list
        .       N col1 S col1=$P(col,",",i) I ",DEP,LN,"[table,$D(^DBTBL("SYSDEV",1,"ACN",9,col1)),col1'="CID" Q
	.	S column=$$replace($P(col,",",i))
	.	S c=c_","_""_column_""
	.       I collen($P(col,",",i))>255 S c=c_" CHAR("_collen($P(col,",",i))_")"
	.	I $L(c)<70 Q				; break up into short line
	.	I cnt W c,! S c="" Q
	.	W "("_$E(c,2,$L(c)),! S c="",cnt=cnt+1
	I cnt W c_")",!
	E  W "("_$E(c,2,$L(c))_")",!
	S hdropt=""					; Cancel header option
	C ctlfile1
	Q
	;----------------------------------------------------------------------
DB2(table)	; Build DB2 control card
	;----------------------------------------------------------------------
	N c,cnt,coldel,ctlfile1,i,x
	S ctlfile1=$P(file,".",1,$L(file,".")-1)
	; Truncate the control card name to 8 characters, z/OS limitation.
	if $l(table)>8 S $P(ctlfile1,"/",$L(ctlfile1,"/"))=$E($P(ctlfile1,"/",$L(ctlfile1,"/")),1,7)_$E(ctlfile1,$L(ctlfile1))
        S x=$$FILE^%ZOPEN(ctlfile1,"WRITE/NEWV",5,4096) I 'x S ER=1,RM=$$^MSG(1337,ctlfile1) Q
	U ctlfile1					; DB2 control card for z/OS
	W "TEMPLATE "_$E(table,1,8)_" PATH='/u/profile/"_table_".dat' ",!
	W "LRECL=32756 RECFM=VB PATHOPTS=ORDONLY FILEDATA=TEXT PATHDISP=(,KEEP) ",!
        W "LOAD DATA INDDN("_$E(table,1,8)_") ",!
        W "WORKDDN(UT1,SOUT) ERRDDN(ERR) MAPDDN(MAP) ",!
        W "REPLACE FORMAT DELIMITED COLDEL X'4F' ",!
        W "LOG NO NOCOPYPEND ENFORCE NO ",!
        W "STATISTICS TABLE(ALL) INDEX(ALL) ",!
        W "INTO TABLE PROFILE."_table_" IGNOREFIELDS YES ",!
	S c="",cnt=0 F i=1:1:$L(col,",") D		; Build column list
        .       N col1 S col1=$P(col,",",i) I ",DEP,LN,"[table,$D(^DBTBL("SYSDEV",1,"ACN",9,col1)),col1'="CID" Q
        .	N typ S typ=$P(^DBTBL("SYSDEV",1,table,9,col1),"|",9)
        .	N len S len=$P(^DBTBL("SYSDEV",1,table,9,col1),"|",2)
	.	S column=$$replace($P(col,",",i))
	.	I (typ="T")!(typ="U") D
	..		I len=1 S c=c_","_""_column_" CHAR(1)"
	..		E  S c=c_","_""_column_" VARCHAR"
	.	E  I typ="F" S c=c_","_""_column_" VARCHAR"
	.	E  I typ="C" S c=c_","_""_column_" VARCHAR"
	.	E  I typ="L" S c=c_","_""_column_" CHAR(1)"
	.	E  I typ="M",len>4000 S c=c_","_""_column_" CLOB"
	.	E  S c=c_","_""_column_""
	.	I $L(c)<70 Q				; break up into short line
	.	I cnt W c,! S c="" Q
	.	W "("_$E(c,2,$L(c)),! S c="",cnt=cnt+1
	I cnt W c_")",!
	E  W "("_$E(c,2,$L(c))_")",!
	S hdropt=""					; Cancel header option
	C ctlfile1
	Q	
	;----------------------------------------------------------------------
QAEXP(opt,tblspace)	; Test EXPORT and DDL logic
	;----------------------------------------------------------------------
	F ztable="CIF","DEP","LN","UTBLBRCD","UTBLCC" D
	.	U 0 W !,ztable,?20,$H
	.	D DDL(ztable,,,,,$G(tblspace))
	.	I '$G(opt) Q				; Schema only
	.	S expr="SELECT * FROM "_ztable		; Extract data
  	.	D EXPORT(expr,"HOME:"_ztable_".DAT",0,124)
	Q
	;
SPLIT(db,tbl,array,file)
	;	tbl - original table name.  Passed by value
	;	array - Return map array.  Passed by reference
	;	db    - specifies the target database name.  Not currently used here.
	;
	;Returns an array (array) sorted by split table name and column name
	; Example:
	;	array(1,"PIPW")=""
	;	array(1,"PLDG")=""
	;	array(1,"PMEDAT")=""
	;	array(1,"PMO")=""
	;
	N A,X,di,dir,dilist,fsn,i,key,keys,name
	D fsn^DBSDD(.fsn,tbl)
	S keys=$P(fsn(tbl),"|",3)
	;
	;
	I file["]" S dir=$P(file,"]",1)_"]"
	E  I file["/" S dir=$P(file,"/",1,$L(file,"/")-1)_"/"
	E  S dir=$$HOME^%TRNLNM()
	;
	D MAPPING^DBMAP(db,tbl,.A) S X="" F  S X=$O(A(tbl,X)) Q:X=""  D  
	.	I $D(^DBTBL("SYSDEV",1,"ACN",9,X)),X'="CID" Q
	.	S name="W_"_tbl_"_"_A(tbl,X)
	.	I '$G(comp),$E($P(name,"_",$L(name,"_")))="C" Q ;Don't do computeds
	.	I $G(array(name))="" S array(name)=dir_name_".dat"
	.	S array(name,X)=""
	;
	S (di,dilist,name)=""
	F  S name=$O(array(name)) Q:name=""  D
	.	S dilist=""
        .       F  S di=$O(array(name,di)) Q:di=""  D
        ..              S dilist=dilist_","_di
        ..              S collen(di)=$P($G(^DBTBL("SYSDEV",1,tbl,9,di)),"|",2)
	.	S dilist=$e(dilist,2,$L(dilist))
	.	F i=1:1:$L(keys,",") S key=$P(keys,",",i) q:key=""  I '$D(array(name,key)) S dilist=key_","_dilist
	.	S $P(array(name),"|",2)="SELECT "_dilist_" FROM "_tbl
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
	I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	I %DB="" S %DB="GTM"
	;
	I '(",DEP,LN,"[fid) S indexnm=fid_"_"_index,indtbl=fid Q 0
	;
	D MAPPING^DBMAP(%DB,fid,.tblarr)
	;
	S newtbl="",error=0
	F i=1:1:$L(keys,",") D
	.	s col=$P(keys,",",i) Q:col=""
	.	I i=1 S newtbl=$G(tblarr(fid,col)) Q
	.	I $g(tblarr(fid,col))'=newtbl S error=1
	;
	I error D ERROR("Invalid index: "_fid_" --> "_index) Q error  ;failure
	;
	;All columns in same split table.  return ind name and table name
	S indexnm="W"_"_"_fid_"_"_newtbl_"_"_index
	S indtbl="W"_"_"_fid_"_"_newtbl
	Q 0  ;success
	;------------------------------------------------------------------------------
EXPALL	;  export data from all tables
	;------------------------------------------------------------------------------
        N connect,ctlfile,delflg,dir,file,init,logfile,OUTFILE,TABLE,VFMQ
	D INIT Q:VFMQ="Q"
	S dir=init("DATADIR")
	S connect=init("CONNECT")
	S OUTFILE=init("EXPSCRIPTFILE")
	S ctlfile=init("CTLFILE")
	S logfile=init("LOGFILE")
        O OUTFILE:NEWV
        S TABLE=""
	;	
	S $ZT=$$SETZT^%ZT("ZT^SQLUTIL")
        ;
TABLE	F  S TABLE=$O(^DBTBL("SYSDEV",1,TABLE)) Q:TABLE=""  DO
	.	Q:TABLE["DBTBL"
	.	S file=dir_TABLE_".dat"
        .       D EXPORT(TABLE,file,4,124,,.delflg)
	.	I 'delflg D
	..	       USE 0
        ..       	W !,TABLE
        ..              I $$wide^DBSDBASE(TABLE) D  Q
        ...                     USE OUTFILE
        ...                     W !,"echo  "_TABLE
        ...                     F i=1:1:5 W !,"sqlldr "_connect_" control="_ctlfile_"W_"_TABLE_"_"_i_".CTL log="_logfile_"W_"_TABLE_"_"_i_".log errors=1000"
        ...                     I TABLE="DEP" W !,"sqlldr "_connect_" control="_ctlfile_"W_"_TABLE_"_9.CTL log="_logfile_"W_"_TABLE_"_9.log errors=1000"
        ..       	USE OUTFILE
	..		W !,"echo "_TABLE
        ..       	W !,"sqlldr "_connect_" control="_ctlfile_TABLE_".CTL log="_logfile_TABLE_".log errors=1000"
        Q
	; 
INIT	;
	N %READ,file,keyword,OLNTB,value,x
	;
	S %TAB("file")="/DES=Initialization File Name/TYP=T/LEN=40" 
	;
	S %READ="file/REQ"
	D ^UTLREAD I VFMQ="Q" S ER=1 Q
	K %TAB
	;
	O file:read
	F  u file r x Q:$zeof  D
	.	S keyword=$P(x,"=",1)
	.	S value=$P(x,"=",2)
	.	S init(keyword)=value
	C file
	Q
        ;
ZT      D ZE^UTLERR
	G TABLE
 
