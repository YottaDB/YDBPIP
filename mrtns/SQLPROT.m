SQLPROT	;Library;Data item protection utility routine
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/19/00 13:57:28 - SPIER
	; ORIG:	CHIANG - 11/28/95
	; DESC:	Data item protection utility routine
	;
	; KEYWORDS:	SQL,DATA ITEM PROTECTION
	;
	; INPUTS:
	;	. %LIBS		Library name		/TYP=T/REQ
	;
	; RETURNS:
	;	. ER	 	Error code		/TYP=N
	;	. RM     	Error message		/TYP=T
	;
	; RELATED:
	;	. VP01xxxx - Data item protection run-time routine
	;
	; LIBRARY:
	;	. $$ADDCOLM  Add a column name to a SELECT statement
	;	. $$COLMDEL  Return column delimiter based on format type
	;       . $$COLMVAL  Return a colmun value based on a SELECT statement
	;	. $$COLMPOS  Return one or more column positions in a SELECT statement
	;	. $$CONVCOLM Convert a SELECT statement into table.column format
	;	. $$NEWLIST  Return new SELECT statement based on protection logic
	;	. $$VIEW     Record level protection logic
	;	. CHGEXEC    Modify SQL run-time execution logic
	;----------------------------------------------------------------------
        ; I18N=QUIT: Excluded from I18N standards.
	;----------------------------------------------------------------------
	;--------------- Revision History -------------------------------------
	; 02/23/09 - Pete Chenard
	;	Modified CONVCOLM to pass .fsn to the call to MCOL^SQLCOL.
	;
	; 08/23/07 - Pete Chenard - CR 28171
	;	     Removed reference to ^CUVAR("%LIBS")
	;
	; 09/22/06 - Pete Chenard - CR22719
	;	     Added section getExe that will return the executable 
	;	     array containing the protection logic.  Called from UCDBRT.
	;
	; 03/30/05 - RussellDS - CR14908
	;	     Modified VIEW and VIEW1 sections to handle changes to DI
	;	     protection logic.
	;
	;	     Removed VIEW2.
	;
	;	     Modified newlist1 section to modify calls to obsolete
	;	     VQ01nnnnn data item protection routine to VP01nnnn.
	;
	;	     Removed old revision history.
	;
	;----------------------------------------------------------------------
ADDCOLM(sel,columns) ; Add one or more column names to a SELECT statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. sel		A list of column names	/TYP=T/REQ/MECH=VAL
	;
	;	. columns	Column names in		/TYP=T/REQ/MECH=VAL
	;                       fid.di format
	;
	; RETURNS:
	;	. $$		A new list of column names
	;
	; EXAMPLES:
	;	$$ADDCOL("DEP.CID,DEP.BOO,DEP.LNM","DEP.LNM,DEP.IRN")
	;       returns:  DEP.CID,DEP.BOO,DEP.LNM,DEP.IRN
	;----------------------------------------------------------------------
	N dinam,i
	F i=1:1:$L(columns,",") D			; Check each column name
	.	S dinam=$P(columns,",",i)		; Get column name
	.	I $$COLMPOS(sel,dinam,1) Q		; Already in the list
	.	S sel=sel_","_dinam			; Add it to the list
	Q sel
	;----------------------------------------------------------------------
COLMDEL(par) ; Return field delimiter
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. par		Parameter list		/TYP=T/REQ/MECH=REFNAM:R
	;----------------------------------------------------------------------
	N fmt
 	S fmt=$G(par("FORMAT"))				; Format definition
	I fmt=""!(fmt="IMAGE") Q ""			; Return NULL delimiter
        Q $P($G(^STBL("TFMT",fmt)),"|",3)		; Based on table value	
	;----------------------------------------------------------------------
COLMVAL(sel,val,dinam) ;  Return column value based on a SELECT statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. sel   A list of column names		/TYP=T/REQ/MECH=VAL
	;	. val   A list of column values in	/TYP=T/REQ/MECH=VAL
	;               the order defined by sel
	;	. dinam	column name in fid.di format	/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	Column value
	;	. ER	Error code			/TYP/NOREQ
	;	. RM    Error message			/TYP=T
	;
	; EXAMPLES:
	;  $$COLMVAL("DEP.CID,DEP.BAL,DEP.IRN","1234<tab>100.45<tab>15","DEP.BAL")
	;  returns:  100.45
	;
	;  $$COLMVAL("DEP.CID,DEP.BAL,DEP.IRN","1234<tab>100.45<tab>15","DEP.BOO")
	;  returns:  null value
	;            ER=1  RM="Invalid data item name ~p1"
	;----------------------------------------------------------------------
	N pos,del
	;;;S del=124 ;;;;;; replace it with 9 ;;;;;;;;;;;
	S pos=$$COLMPOS(sel,dinam,1)			; Get column position
	I 'pos S ER=1,RM=$$^MSG(1300,dinam) Q ""	; Not in the list
	Q $P(val,$C(9),pos)				; Return column value
	;----------------------------------------------------------------------
COLMPOS(sel,dinam,exact) ;  Return column value based on a SELECT statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. sel   A list of column names		/TYP=T/REQ/MECH=VAL
	;	. dinam	column name in fid.di format	/TYP=T/REQ/MECH=VAL
	;	. exact Exact match flag		/TYP=T/REQ/DEF=0/MECH=VAL
	;               0 = exact match or in a computed expression
	;               1 = Exact match only
	; RETURNS:
	;	. $$	Column position (one or more column numbers separated
	;               by a comma)
	; 
	; EXAMPLES:
	;	$$COLMPOS("DEP.CID,DEP.BAL,DEP.BOO,DEP.BOO+DEP.IRN","DEP.BOO",1)
	;       returns: 3
	;	$$COLMPOS("DEP.CID,DEP.BAL,DEP.BOO,DEP.BOO+DEP.IRN","DEP.BOO")
	;       returns: 3,4
	;----------------------------------------------------------------------
	N di,i,p,match,vdinam
	S match=""					; Default if not found
	S exact=$G(exact)
	F i=1:1:$L(sel,",") D  I exact,match Q		; Need only one match
	.	S vdinam=$P(sel,",",i)			; Colmn name or expression
	.	I exact D  Q
	..		I vdinam=dinam S match=i Q	; Exact match
	.	S p=1 F  S di=$$FINDINAM^SQLDD(vdinam,.p) Q:di=""  D
	..		I di=dinam S match=match_","_i ; Add it to the list
	I $E(match)="," S match=$E(match,2,999)
	Q match
	;----------------------------------------------------------------------
CONVCOLM(frm,sel) ;  Return SELECT statement in table.column format
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. frm	Table names			/TYP=T/REQ/MECH=VAL
	;	. sel   A list of column names		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	A list of column names in table.column format
	;               separated by comma
	;	. ER	Error code			/TYP/NOREQ
	;	. RM    Error message			/TYP=T
	;
	; EXAMPLES:
	;	$$CONVCOLM("DEP,CIF","CID,BAL,TAXID")
	;       returns  DEP.CID,DEP.BAL,CIF.TAXID
	;----------------------------------------------------------------------
	N columns,dinam,expr,i,j,val
	S columns=""
	F i=1:1:$L(sel,",") D
	.	S dinam=$P(sel,",",i)			; Get column name
	.	I dinam[$C(0) S dinam=$$UNTOK^%ZS(dinam,tok)
	.	S expr=$$MCOL^SQLCOL(dinam,frm,,,,.fsn,,,,,1) ; Parse expression
	.	S dinam=""
	.	F j=1:1:$L(expr,$C(1)) D		; Put it back again
	..		S val=$P(expr,$C(1),j)		; Each parsed element
	..		I $L(val,".")'=2 Q
	..		I dinam'="" S dinam=dinam_"+"
	..		S dinam=dinam_val		; Full expression
	.	S columns=columns_","_dinam		; Add it to the list
	I $G(ER) Q ""
	Q $E(columns,2,999)
	;----------------------------------------------------------------------
NEWLIST(frm,sel) ; Private ; Return new SELECT statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. frm		A list of table names	/TYP=T/REQ/MECH=VAL
	;	. sel		A list of column names	/TYP=T/REQ/MECH=VAL
	;
	; OUTPUT:
 	;	. vsql("prot",file)
	;			Protection mapping info /TYP=T/MECH=REFNAM:W
	;			vmatch|vmap|orgcolm|newcolm|routine
	;
	;              vmatch   Positions of each protected columns
	;              vmap     Internal variable name map
	;              orgcolm  Total number of columns (original SELECT)
	;              newcolm  Total number of columns (new SELECT)
	;              routine  Run-time protection routine name (VP01xxxx)
	; RETURNS:
	;	. $$	A new list of columns names with additonal columns
	;               added (required for processing protection logic)
	;         
	; EXAMPLES:             
	; $$NEWLIST("DEP","CID,BAL",.vpsts)
	; returns $$:   DEP.CID,DEP.BAL,DEP.BOO,DEP.IRN
	;		vpsts("DEP")=|2,|2,3,4|2|4|VP01DEP
	;              
	;----------------------------------------------------------------------
	N file,fl,maxcolm,newcolm,orgcolm,vnumcol,vmap,vmatch,vpgm,vpstat
	N vsel,ER,RM
   	I $G(%LIBS)="" N %LIBS S %LIBS="SYSDEV"		; Library name
	;                                               ; *** 06/21/96
	I frm[$C(0) S frm=$$UNTOK^%ZS(frm,.tok)		; Back to original list
	I sel[$C(0) S sel=$$UNTOK^%ZS(sel,.tok)		;
	S frm=$TR(frm,""""),sel=$TR(sel,"""")		; Remove quotes
	;
	S vsel=sel					; Save original SELECT statement
	S orgcolm=$L(vsel,",")				; Number of columns (old)
	S maxcolm=0
	S sel=$$CONVCOLM(frm,sel)			; Convert to fid.di format
	;
	F fl=1:1:$L(frm,",") D
	.	S file=$P(frm,",",fl)			; Process each file
	.	S sel=$$newlist1(file,sel)		; Get new list back
	.	I $P(sel,",",orgcolm+1)="" Q		; No new item added
	.	S vsel=vsel_","_$P(sel,",",orgcolm+1,99) ; Save old list
	.	S orgcolm=$L(vsel,",")			; New column count
	S file=""					; Number of columns (new)
	F  S file=$O(vpstat(file)) Q:file=""  D
	.	S $P(vpstat(file),"|",4)=maxcolm
	.	S vsql("prot",file)=vpstat(file)	; Copy it into vsql()
	I $E(vsel,$L(vsel))="," S vsel=$E(vsel,1,$L(vsel)-1)
	Q vsel
	;
	;----------------------------------------------------------------------
newlist1(file,sel) ;
	;----------------------------------------------------------------------
	S vpgm=""
	D ^UPID(file,.vpgm)				; Run-time protection routine name
	I vpgm="" Q vsel				; Protection logic not defined
	I $$NEW^%ZT N $ZT				; Set up error trap
        S @$$SET^%ZT("ZT^SQLPROT")			; *** 03/13/96
	X "S sel=$$ptinfo^"_vpgm_"(sel)"		; return new column names
	S vmatch=$P(sel,"|",2),vmap=$P(sel,"|",3)	; protection attributes
	S sel=$P(sel,"|",1)				; New SELECT list
	I vmatch="" Q vsel				; No protection logic defined
	I vmatch>orgcolm Q vsel				; Logic not required
	S newcolm=$L(sel,",")				; Number of columns (new)
	I newcolm>maxcolm S maxcolm=newcolm		; Total columns
	;						; Return other status information
	S vpstat(file)=vmatch_"|"_vmap_"|"_orgcolm_"||"_vpgm
	Q sel
	;
ZT	; Error trap
	S vpgm=""					; Disable protection logic
	Q vsel						; Return original value
	;
        ;----------------------------------------------------------------------
VIEW(lib,fid) ; Private ; Return reocrd level protection query logic
        ;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. lib	DATA-QWIK library name		/TYP=T/REQ/MECH=VAL
	;	. fid	File name			/TYP=T/REQ/MECH=VAL
	;
	; INPUTS:
	;
	;       . par	SQL qualifier table		/TYP=T/REQ/MECH=REFNAM:R
	;
	; OUTPUTS:
	;
	;	. $$	Record level protection logic in SQL WHERE statement
	;               format
	;
	; EXAMPLES:
	;
	;   $$VIEW("SYSDEV","DEP") returns:  DEP.CLS='D'
	;----------------------------------------------------------------------
	N qrycp,rowpt
	S rowpt=""
        S qrycp=$P($G(^DBTBL(lib,1,fid,14)),"|",1)      	; File control page
	I qrycp'="" S qrycp=$$WHERE^SQLCONV(qrycp,fid)		; Convert to SQL format
	I qrycp'="" S qrycp="("_qrycp_")"
	;
        I $G(par("PROTECTION")),$D(^DBTBL(lib,14,fid,"*")) S rowpt=$$VIEW1(fid)
        ;
	I qrycp="",rowpt="" Q ""				; No protection
	I qrycp'="",rowpt="" Q qrycp				; Control page query
	I qrycp="",rowpt'="" Q rowpt				; Row level only
	I qrycp'="",rowpt'="" Q "("_qrycp_" AND "_rowpt_")" 	; Both
	Q ""
	;
	;----------------------------------------------------------------------
VIEW1(fid)	; Row level protection
	;----------------------------------------------------------------------
	;
	; Return WHERE clause for row level protection (where protection
	; option = 2, no access).  Note that the WHERE clause returned
	; is a NOT of the expression
	;
	N WHERE
	;
	; Optimize for key tables
	I fid="DEP" S WHERE=$$RPWHERE2^VP01DEP
	E  I fid="LN" S WHERE=$$RPWHERE2^VP01LN
	E  I fid="ACN" S WHERE=$$RPWHERE2^VP01ACN
	E  I fid="CIF" S WHERE=$$RPWHERE2^VP01CIF
	E  D
	.	N PGM
	.	;
	.	S PGM=$$PGM^UPID(fid)
	.	I PGM="" S WHERE=""
	.	E  X "S WHERE=$$RPWHERE2^"_PGM
	;
	Q WHERE
	;
	;----------------------------------------------------------------------
CHGEXEC(exe,ptopt) ; Private ; Modify execution code to include protection logic
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. exe	SQL Run-time execution code	  /TYP=T/REQ/MECH=REFNAM:RW
	;	. ptopt Protection option		  /TYP=N/REQ/MECH=VAL
	;               1= Keep column data
	;               2= Null out column data
	; INPUTS:
	;	. vsql("prot",file)
	; 		 Status 			 /TYP=T/REQ/MECH=REFNAM:R
	;               vsql(fid)=(vmatch|vmap|orgcolm|newcolm|pgm) 
	; EXAMPLES:
	;	D CHGEXEC(.exe,2)  returns  S sqlind=$$status^VP01DEP(.v,vsts)
	;------------------- ---------------------------------------------------
	N code,fid,i,stat,vpgm
	S fid="" F i=1:1 S fid=$O(vsql("prot",fid)) Q:fid=""  D
	.	S stat=vsql("prot",fid)			; Status
	.	S vpgm=$P(stat,"|",5)			; routine name
	.	S $P(stat,"|",5)=$G(ptopt)		; Protection option
	.	I $O(vsts(fid))'="" D			; Not last call
	..		S $P(stat,"|",4)=""  		; Truncate flag off
	..		S $P(stat,"|",5)=""		; Null data flag off
	.	S code="" I i=1 S code="S vi="""" "		; Init vi on first call
	.	S code=code_"D status^"_vpgm_"(.vd,.vi,"_""""_stat_""""_")"
	.	;;;S code=code_" I vi=""*"" S vsql="_(vsql(0)-1) ; Record protection
	.	S exe=exe+1,exe(exe)=code		; Return status code
	.	S vsql("PROTCODE")=code			; Save for rdb use in RFETCH^SQLF
	Q
	;
	;------------------------------------------------------------
getExe(from,select,exe,par)
	; Generate code that calls protection routine.
	;
	; ARGUMENTS:
	;		. from - Table		/TYP=T/REQ/MECH=VAL
	;		. select - Select List	/TYP=T/REQ/MECH=VAL
	;		. code - Output Code Array /TYP=T/NOREQ/MECH=REFNAM:W
	;
        N sel
        S exe=+$G(exe)        ;init to zero is not defined
        S sel=$$NEWLIST(from,select)
        D CHGEXEC(.exe,$G(par("PROTECTION")))
        Q
