SQLCONV	;Private;QWIK report to SQL conversion utility
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/11/97 13:40:34 - CHIANG
	; ORIG:	CHIANG - 11/03/95
	; DESC:	QWIK report to SQL conversion utility
	;
	; KEYWORDS:	SQL,QWIK REPORT
	;
	; INPUTS:
	;	. %LIBS Library Name		/TYP=T/NOREQ/DFT=^CUVAR("%LIBS")
	;
	; OUTPUTS:
	;	. ER	Error Flag		/TYP=N/NOREQ
	;	. RM	Error Message		/TYP=T/NOREQ
	;
	; RELATED:
	;	. ^DBSQRY - DATA-QWIK Query Parser
	;
	; LIBRARY:
	;
	;	. QRPT      - Convert QWIK report into SQL statement
	;	. $$DQJOIN  - Return default join logic in DQ mode
	;	. $$FROM    - Convert access files into FROM command
	;       . $$ORDERBY - Convert sort order into ORDER BY command
	;	. $$Q2SQL   - Convert Q() array into SQL WHERE command
	;	. $$SELECT  - Convert report data items into SELECT command
	;	. $$WHERE   - Convert DATA-QWIK queries into WHERE command
	;	. QRCONV    - Remove XCLS references from QWIK reports
	;----------------------------------------------------------------------
	;---------- Revision History ------------------------------------------
	; 02/06/06 - RussellDS - CR19176
	;	     Modified Q2SQL section to add single quotes around numeric
	;	     values if for text-type fields.
	;
	; 06/07/05 - RussellDS - CR16230
	;	     Modified Q2SQL and complex sections to do some code
	;	     clean-up, including handling of expressions such as
	;	     [LN]LTVC>([LN]RLVP+[LN]LVV), which produced bad code
	;	     previously.
	;
	;	     Note that this code still could use more work to provide
	;	     broader capabilities.
	;
	;	     Removed old revision history.
	;----------------------------------------------------------------------
	; I18N=QUIT
	;----------------------------------------------------------------------
QRPT(QRID,SQL,SELECT,FROM,WHERE,ORDER,QUERY) ; Private ; Convert QWIK report into a SQL statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. QRID	  QWIK report name	/TYP=U/REQ/MECH=VAL
	;	. SQL     SQL statement		/TYP=T/MECH=REF:W
	;       . SELECT  SELECT command	/TYP=T/MECH=REF:W
	;       . FROM    FROM command          /TYP=T/MECH=REF:W
	;       . WHERE   WHERE command         /TYP=T/MECH=REF:W
	;       . ORDER   ORDER BY command      /TYP=T/MECH=REF:W
	;       . QUERY   DATA-QWIK Q()         /TYP=T/MECH=ARRAR:W
	;
	; RETURNS:
	;
	;	. ER	Error flag		/TYP=N/NOREQ
	;	. RM	Error mesage		/TYP=T/NOREQ
	;
	; EXAMPLES:
	;
	;	D QRPT^SQLCONV("REP123",.SQL)  returns variable SQL:
	;
	;       SELECT CID,BAL,BOO FROM DEP WHERE BAL>1000 ORDER BY BOO,CID
	;
	;       D QRPT^SQLCONV("REP123",.SQL,.SEL) Returns SEL=CID,BAL,BOO
	;	       
	;----------------------------------------------------------------------
	N data,files,i,items,j,qry,sql,x,z
	K RM,SQL,SELECT,FROM,WHERE,ORDER,QUERY
	S ER=""
	;
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	;
	I '$D(^DBTBL(%LIBS,6,QRID)) S ER=1,RM=$$^MSG(1234) Q	; Invalid report
	;						; Report definition
	S x="" F  S x=$O(^DBTBL(%LIBS,6,QRID,x)) Q:x=""  S data(x)=^(x)
	;
	S files=$P(data(0),"|",1)			; Access files
	S FROM=$$FROM(files)				; Convert to FROM
	S order=$P(data(0),"|",10)			; Sort order
	I order="" S order=$$DFTORDER(FROM)		; Default order
	S ORDER=$$ORDERBY(order,FROM)			; Convert to ORDER BY
	;
	S items=""					; Data item list
	F i=12:1:16 I $G(data(i))'="" S items=items_","_data(i) 
	S SELECT=$$SELECT($E(items,2,9999))		; Convert to SELECT
	;
	S j=1						; DATA-QWIK query
	F i=1:1:10 I $G(data(i))'="" S qry(j)=data(i),j=j+1
	S WHERE=$$WHERE(.qry,files,.QUERY)			; Convert to WHERE
	;
	S SQL="select "_SELECT_" from "_FROM		; Required
	I WHERE'="" S SQL=SQL_" where "_WHERE		; Optional
	I ORDER'="" S SQL=SQL_" order by "_ORDER		; Optional
	;
	Q
	;----------------------------------------------------------------------
FROM(files) ; Private ; Convert access files into FROM command
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. files	Access files		/TYP=U/REQ/MECH=VAL
	;
	; RETURNS:
	;
	;	. $$	SQL FROM command	/TYP=T
	;	. ER	Error flag		/TYP=N/NOREQ
	;	. RM	Error mesage		/TYP=T/NOREQ
	;
	; EXAMPLES:
	;
	;	S from=$$FROM("DEP,CIF,MADDR")  returns the same data
	;----------------------------------------------------------------------
	;
	Q files
	;----------------------------------------------------------------------
SELECT(items) ; Private ; Convert data item list into SELECT command
	;----------------------------------------------------------------------
	; 1. Convert [lib,fid]di and [fid]di to fid.di
	; 2. Convert "text" to 'text'
	; 3. Quote data items starting with % character (%LIBS to "%LIBS")
	; 4. Quote keywords (DESC to "DESC")
	; 5. Skip @SCREEN and @WPS functions
	;
	; ARGUMENTS:
	;
	;	. items	data item list		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;
	;	. $$	SQL SELECT command	/TYP=T
	;	. ER	Error flag		/TYP=N/NOREQ
	;	. RM	Error mesage		/TYP=T/NOREQ
	;
	; EXAMPLES:
	;
	;	$$SELECT("CID,BAL,[DEP]ACN,TAXID") => CID,BAL,DEP.ACN,TAXID
	;       $$SELECT("BRCD,DESC")              => BRCD,"DESC"
	;       $$SELECT("%LIBS,FID")              => "%LIBS",FID
	;       $$SELECT("CID,""$"",BAL)           => CID,'$',BAL
	;       $$SELECT("@SCREEN(LIS)")           => null
	;----------------------------------------------------------------------
	N di,fid,i,sel
	;
	S sel=""
	F i=1:1:$L(items,",") D
	.	S di=$P(items,",",i)
	.	I $E(di)="""" S di=$TR(di,$C(34),"'")	; Convert "" to '
	.	I di["+$H" S di=$P(di,"+$H",1)_"SYSDAT"_$P(di,"+$H",2,99)
	.	I di["$H" S di=$P(di,"$H",1)_"SYSDAT"_$P(di,"$H",2,99)
	.	I di'["]" S sel=sel_","_$$KEYWD(di) Q	; di format
	.	S fid=$P($P(di,"]",1),"[",2)		; [fid]di
	.	S di=$P(di,"]",2)			; data item
	.	S fid=$$KEYWD(fid)			; Place quotes
	.	S di=$$KEYWD(di)			; Check kwyword list
	.	S sel=sel_","_fid_"."_di		; Add it to the list
	Q $E(sel,2,9999)
	;----------------------------------------------------------------------
KEYWD(name) ; Private ; place quotes for special data items and keywords
	;----------------------------------------------------------------------
	N i
	I $E(name)="%" Q """"_name_""""
	;						; One of the keyword?
	F i="SELECT","FROM","WHERE","ORDER","BY","DESC" I name=i S name=""""_name_"""" Q
	Q name
	;----------------------------------------------------------------------
ORDERBY(order,from) ;
	;----------------------------------------------------------------------
	N di,dinam,fid,i,ord
	;
	I order="" Q ""
	S ord=""
	F i=1:1:$L(order,",") D
	.	S dinam=$P(order,",",i)			; [fid]di
	.	S fid=$E($P(dinam,"]",1),2,99)		; fid
	.	S di=$P(dinam,"]",2)			; di
	.	I $E(di)="""" Q				; dummy key
	.	I $E(di)?1N Q				;
	.	S fid=$$KEYWD(fid)			; Place quotes?
	.	S di=$$KEYWD(di)			;
	.	I from'["," S ord=ord_","_di		; single file
	.	E  S ord=ord_","_fid_"."_di		; Add it to the list
	Q $E(ord,2,9999)
	Q order
	;----------------------------------------------------------------------
WHERE(qry,FILES,Q) ;
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. qry	 DATA-QWIK query synatx		/TYP=T/REQ/MECH=REFNAM:R
	;	. FILES  Access files			/TYP=T/REQ/MECH=VAL
	;	. Q      Parsed query syntax		/TYP=T/MECH=REFNAM:W
	;
	; RETURNS:
	;	. $$	 Equivalent WHERE statement
	;
	; EXAMPLES:
	;
	;    qry(1)="BAL>100"
	;    qry(2)="BOO=2"
	;
	;    $$WHERE(.qry,"DEP",.Q) returns  CID.BAL>100 AND DEP.BOO=2
	;----------------------------------------------------------------------
	N (qry,FILES,%LIBS,Q)
	;
	K Q
	I $G(qry)'="" S X=qry D ^DBSQRY
	F NI=1:1 Q:'$D(qry(NI))  S X=qry(NI) D ^DBSQRY
	Q $$Q2SQL(.Q)
	;
	;----------------------------------------------------------------------
Q2SQL(Q) ; Public ; Convert Q() array into SQL WHERE statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. Q	DATA-QWIK parsed query syntax	/TYP=T/REQ/MECH=REFNAM:R
	;
	; RETURNS:
	;	. $$	Equivalent SQL WHERE statement
	;
	; EXAMPLES:
	;  Q(2,1)=$C(1)_"SYSDEV.DEP.CID"_$C(1)_"|100||'<|&|N"
	;  Q(2,2)=$C(1)_"SYSDEV.DEP.CID"_$C(1)_"|200||'>||N"
	;
	;  returns: DEP.CID NOT <100 AND DEP.CID NOT >200
	;----------------------------------------------------------------------
	N cmd,func,i,j,left,log,or,opr,opra,q,remaindr,typ,val,x
	I $O(Q(""))="" Q ""				; Query logic not defined
	S (i,j)=""
	F  S i=$O(Q(i)) Q:i=""  D
	.	S j="",or=0
	.	F  S j=$O(Q(i,j)) Q:j=""  D
	..		S q=Q(i,j)			; Query definition
	..		S left=$TR($P(q,"|",1),$C(34),"'")
	..		I left[$C(1) D
	...			S func=$P(left,$C(1),1)
	...			S remaindr=$P(left,$C(1),2,99)
	..		E  S func=left,remaindr=""
	..		I remaindr'="" S remaindr=$$complex(remaindr)
	..		S val=$TR($p(q,"|",2),$C(34),"'")	; data value
	..		I val[$C(1) S val=$$complex(val)
	..		S opr=$P(q,"|",4)		; math operation
	..		S log=$P(q,"|",5)		; Logical operation
	..		S typ=$P(q,"|",6)		; Internal type
	..		I typ="D",val?5N D		; convert to string date
	...			S val="'"_$$DAT^%ZM(val,$G(%MSKD))_"'" ; *** 05/07/96
	...			I func="+" S func=""	; Remove Type conversion logic
	..		; If string datatype, add quotes
	..		I ("N$CL"'[typ),val?1.N set val="'"_val_"'"
	..		;
	..		S opra=$$OP(opr,val)		; Operation
	..		I opra="" Q			; <<**>> syntax
	..		I func="+",typ="N",val["<<" S func=""	; *** 02/12/96
	..		I func["<<",func[">>" S func=$$VAR(func)
	..		S x=func_remaindr_opra		; dinam opr value
	..		I $E(func,1,3)="$E(",opr="=" S x=$$FUNC(x) ; parse $E function
	..		I log="!" S x=x_" OR "		; OR logic
	..		I log="&" S x=x_" AND "		; AND logic
	..		I x="" Q
	..		S cmd(i)=$G(cmd(i))_x		; Save query
	;
	I $O(cmd(""))="" Q ""				; No query defined
	I $O(cmd(1))="" Q cmd(1)			; Single level query
	S cmd="",i=""
	F  S i=$O(cmd(i)) Q:i=""  D			; Insert AND for each level
	.	I cmd(i)="" Q
	.	I $O(Q(i,1))="" S cmd=cmd_cmd(i)	; single query
	.	E  S cmd=cmd_"("_cmd(i)_")"		; multiple
	.	I $O(cmd(i)) S cmd=cmd_" AND "		; More to follow
	Q cmd
	;----------------------------------------------------------------------
OP(opr,val) ;
	;----------------------------------------------------------------------
	N not
	I opr="" S opr="="				; Default to = operation
	I val="<<*>>"!(val="<<**>>") Q ""
	I val["<<",val[">>" D				; <<var expression>>
	.	S val=$$VAR(val)			; Convert to :var
	.	I val?1n.n Q				; *** 05/06/96
	.	I val?1"("1e.e1")" Q			; (expr)
	.	I val?1":"1A.AN!(val?1":%".AN) Q	; expt
	.	S val="("_val_")"			; change to (expr)
	S not=""
	I $E(opr)="'" S not=" NOT ",opr=$E(opr,2,9)
	I opr="[" Q not_" LIKE '%"_$S(val["'":$P(val,"'",2),1:val)_"%'"
	I opr="]" Q not_">"_val
	I opr="]]" Q not_">"_val
	I opr="=",val="''",not'="" Q " IS NOT NULL"
	I opr=">",val="''",not="" Q " IS NOT NULL"
	I opr="=",val="''" Q " IS NULL"
	I opr="I",val'["#" Q " IN "_$P(val,",",1)_",))"	; IN ^gbl(list)
	I opr="I",val["#" Q " IN ("_val_")"	; IN VAR(list) *** 01/31/96
	Q not_opr_val
	;----------------------------------------------------------------------
VAR(str) ; Replace variable with :var syntax
	;----------------------------------------------------------------------
	N ptr,nstr,val
	S str=$TR(str,"<>","")				; Remove <<>>
	S nstr="",ptr=0
	F  S val=$$ATOM^%ZS(str,.ptr,"(+-*/_#)") Q:'ptr  D	; Get next value
	.	S nstr=nstr_$$VAR1(val)
	Q nstr_$$VAR1(val)
	;
VAR1(val) ;
	I val?1A.AN!(val?1"%".AN) Q ":"_val 		; Change to :var
	I val="$J" Q $J					; *** 05/06/96
	E  Q val
	;----------------------------------------------------------------------
FUNC(x) ; Convert $E(dinam,1,n)='string' to LIKE command
	;----------------------------------------------------------------------
	N dinam,from,val
	S from=$P(x,",",2)			; starting location
	I from'="'1'" Q x			; keey $E format
	S dinam=$P($P(x,",",1),"(",2)		; fid.di
	S val=$P($P(x,"=",2),"'",2)		; string value
	Q dinam_" LIKE '"_val_"%'" 		; dinam like "string%"
	;----------------------------------------------------------------------
complex(expr) ; Convert di syntax
	;----------------------------------------------------------------------
	N di,i,return
	S return=""
	F i=1:1:$L(expr,$C(1)) D
	.	S di=$P(expr,$C(1),i)			; Each token
	.	I di="<<" S return=return_"(" Q		; <<...
	.	I di=">>" S return=return_")" Q		; ...>>
	.	I $L(di,".")=3 D
	..		N fid,dinam
	..		S fid=$$KEYWD($P(di,".",2))
	..		S dinam=$$KEYWD($P(di,".",3))
	..		S di=fid_"."_dinam
	.	S return=return_di
	;
	Q return
	;----------------------------------------------------------------------
QA	; Private ; Test/QA utility
	;----------------------------------------------------------------------
	;
	N line,msg,%TAB,%READ,I,IO,QRID,SQL,VFMQ
	S msg="Convert QWIK report query syntax into SQL syntax"
	S IO=$P
	S %TAB("IO")=$$IO^SCATAB
	S %READ="@msg/REV/CEN,,IO" D ^UTLREAD
	I VFMQ="Q" Q
	S QRID=""
	S $P(line,"-",80)=""
	D OPEN^SCAIO U IO
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	F opt=4,6 D QA46(opt)
	D CLOSE^SCAIO
	Q
QA46(opt) ;
	F  S QRID=$O(^DBTBL(%LIBS,opt,QRID)) Q:QRID=""  D
	.	U 0 W !,QRID
	.	U IO W !,line,!,QRID,!
	.	F I=1:1:10 I $G(^DBTBL(%LIBS,opt,QRID,I))'="" W !,^(I)
	.	K SQL
	.	D QRPT(QRID,,,,.SQL)
	.	I $G(SQL)="" Q
	.	W !! F J=1:76:9999 S X=$E(SQL,J,J+74) Q:X=""  W X,!
	Q
	;----------------------------------------------------------------------
CONVLN(old,len,new) ; Convert a single long line into multiple lines
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	old	Original string			/TYP=T/REQ/REF=VAL
	;       len     Maximum length of each line	/TYP=N/REQ/REF=VAL
	;       new     Converted string in multiple line format.  Each
	;               line length is less than 'len' characters
	;						/TYP=T/REQ/ARRAY:W
	; EXAMPLE:
	;       SQL = SELECT CID,BAL,LNM,BOO FROM DEP WHERE CID<100 ...AND IRN=10
	;       NSQL(1)="SELECT CID,BAL,LNM,BOO FROM DEP WHERE CID<100
        ;       NSQL(2)="AND IRN=10"
	;
	;----------------------------------------------------------------------
	N i,seq,v
	I $L(old)'>len S new(1)=old Q			; Fit in one line
	S v="",seq=1
	F i=1:1:$L(old," ") D
	.	S x=$P(old," ",i)
	.	I $L(v)+$L(x)>len S new(seq)=$E(v,1,$L(v)-1),seq=seq+1,v=""
	.	S v=v_x_" "
	S new(seq)=$E(v,1,$L(v)-1)
	Q
	;----------------------------------------------------------------------
QRCONV	; QWIK report conversion routine to remove XCLS references
	;----------------------------------------------------------------------
	N (%LIBS)
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	D ^SCAIO U IO
	S QRID="" 
	F  S QRID=$O(^DBTBL(%LIBS,6,QRID)) Q:QRID=""  D
	.	D CONV(QRID,.code)
	.	I '$D(code) Q
	.	Q
	.	S i="" F  S i=$O(code(i)) Q:i=""  S ^DBTBL(%LIBS,6,QRID,i)=code(i)
	.	K code
	C IO
	Q
	;----------------------------------------------------------------------
CONV(QRID,code) ;
	;----------------------------------------------------------------------
	N (%LIBS,QRID)
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	I '$D(^DBTBL(%LIBS,6,QRID)) Q
	S i="" F  S i=$O(^DBTBL(%LIBS,6,QRID,i)) Q:i=""  S code(i)=^(i)
	;
	S files=$P(code(0),"|",1)
	S nfiles=$$FILE(files)				; New access files
	I nfiles=files K code Q				; No need to change
	;
	D PRINT
	;
	S $P(code(0),"|",1)=nfiles			; Replace it
	S orderby=$P(code(0),"|",10)			; Order By
	I orderby="" S orderby="[XCLS]CLS,[XCLS]GRP,[XCLS]TYPE,[XCLS]CID"
	S breakon=$P(code(0),"|",11)			; Break On
	S pfid=$P(nfiles,",",1)				; Promary file
	S $P(code(0),"|",10)=$$VCHG(orderby,"XCLS",pfid)
	S $P(code(0),"|",11)=$$VCHG(breakon,"XCLS",pfid)
	I nfiles'["," S pfid=""				; Remove [fid] ref
	;
	F i=1:1:10,12:1:16 I $D(code(i)) S code(i)=$$VCHG(code(i),"XCLS",pfid)
	D PRINT
	Q
PRINT	;
	W !,QRID,! F i=0:1:15 I $G(code(i))'="" W !,i,?5,code(i)
	;
	Q
	;----------------------------------------------------------------------
FILE(files)	; Remove XCLS and replace it with either DEP or LN
	;----------------------------------------------------------------------
	N file,i,nfid,x
	S x=","_files_","
	I x'[",XCLS," Q files				; No need to change
	I x[",LN,",x[",DEP," S ER=1 Q files		; Replace it with ACN?
	F i=1:1:$L(files,",") S fid($P(files,",",i))=""
	I '$D(fid("DEP")),'$D(fid("LN")) Q		; Skip this
	K fid("XCLS")					; Remove XCLS file
	F i="DEP","LN" I $D(fid(i)) S nfid=i K fid(i)	; Remove DEP or LN file
	S i=""
	F  S i=$O(fid(i)) Q:i=""  S nfid=nfid_","_i     ; New access files
	Q nfid
	;----------------------------------------------------------------------
VCHG(x,ofid,nfid) ; Replace [ofid] references with [nfid]
	;----------------------------------------------------------------------
	N znfid,zofid
	S znfid=""
	I $G(nfid)'="" S znfid="["_nfid_"]"
	S zofid="["_ofid_"]"
	F  Q:x'[zofid  S x=$P(x,zofid,1)_znfid_$P(x,zofid,2,99)
	Q x
	;----------------------------------------------------------------------
DFTORDER(from) ; ORDER BY based on primary file
	;----------------------------------------------------------------------
	N file,fsn,i,keys,order
	S order=""
	S file=$P(from,",",1)				; Primary file
	D fsn^DBSDD(.fsn,file)				; File attributes
	I $G(ER) Q ""
	S keys=$P(fsn(file),"|",3)			; Access keys
	F i=1:1:$L(keys,",") S order=order_",["_file_"]"_$P(keys,",",i)
	Q $E(order,2,999)
	;
	;----------------------------------------------------------------------
DQJOIN(frm,fsn)	; Return DATA-QWIK mode FROM clause with LEFT JOIN logic
     	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;	. frm	Table names		/TYP=T/REQ/MECH=VAL
	;       . fsn   File attributes         /TYP=T/MECH=REFARRY:RW
	;
	; EXAMPLE:
	;
	;  W $$DQJOIN("HIST,DEP")
	;
	;
	;  W $$DQJOIN("DEP,HIST")
	;
	;  W $$DQJOIN("XCC,DEP,CIF")
	;
	;----------------------------------------------------------------------
	S ER=0
	;
	I '(frm[",") Q frm				; Single table
	I frm["JOIN" Q frm				; JOIN logic already specified
	;
	N i,j,k,key,keys,ptbl,return,tbl1,tbl2,on
	;						; Join secondary tables to primary table
	S on="",ptbl=$P(frm,",",1)			; Primary table
	;
	S return=ptbl_" LEFT JOIN ("_$P(frm,",",2,$L(frm,","))_")"
	;
	F i=1:1:$L(frm,",") D  Q:ER
	.	;
	.	S tbl1=$P(frm,",",i)
	.	;
	.	F j=1:1:$L(frm,",") D  Q:ER
	..		;
	..		S tbl2=$P(frm,",",j) I tbl2=tbl1 Q
	..		I tbl2=ptbl Q			
	..		S keys=$$NATURAL^SQLJ(tbl1,tbl2,.fsn)
	..		F k=1:1:$L(keys,",") D
	...			;
	...			S key=$P(keys,",",k) I key="" Q
	...			I $D(keys(tbl2,key)) Q
	...			S keys(tbl1,key)="",keys(tbl2,key)=""
	...			I on'="" s on=on_" AND "
	...			S on=on_""""_tbl1_"""."""_key_"""="""_tbl2_"""."""_key_""""
	;  
	I on'="" S return=return_" ON ("_on_")"
	Q return
	;
QA1	;
	F i="HIST,DEP","DEP,HIST","XCC,DEP,CIF" W !,i,!,$$DQJOIN(i)
	w !
	Q
	;----------------------------------------------------------------------
QAJOIN  ; Test library function DQJOIN logic
        ;----------------------------------------------------------------------
        N files,sql,v,RID,IO
        I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
        D ^SCAIO U IO
        S RID=""
        F  S RID=$O(^DBTBL(%LIBS,5,RID)) Q:RID=""  D
        .       S v=$G(^(RID,0))                        ; Report header
        .       S files=$P(v,"|",1)                     ; Access files
        .       I files'["," Q                          ; Single file
        .       S sql=$$DQJOIN(files)              	; Left outer join
        .       W !,RID,?15,files,!,?15,sql
        W !
        D CLOSE^SCAIO
	Q

