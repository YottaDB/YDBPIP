UCUTIL	; PSL compiler related utility
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/19/02 13:32:49 - CHENARDP
	;
	; **** All functions and subroutines in this M routine except MARKER are
	; **** DEPRECATED, and retained for backward compatibility with Profile
	; **** V6.4 environments only.
	;
	; **** This routine will not be converted to PSL, and will not be part
	; **** of the PSL-to-Java project.
	;
	; LIBRARY: MARKER	- Add PSL makker to each line of code to enable trace
	;	   AUDIT	- **** DEPRECATED **** Wrap call to AUDIT^UCUTILN()
	;	   fsn		- **** DEPRECATED **** Load File Header Record
	;	   LOAD		- **** DEPRECATED **** Build Database Load Code
	;	   OBJGBL	- **** DEPRECATED **** Return global reference in PSL object format
	;	   OBJNAME	- **** DEPRECATED **** Return object name based on table name
	;	   PARSE	- **** DEPRECATED **** Return MUMPS expression for ddref
	;	   SN2OBj	- **** DEPRECATED **** Convert short name into vobj() structure
	;
	; REMAINING CALLS in versions V7.0 (V6.4 does not contain additional calls):
	;	LOG^SQLFILER.m		AUDIT^UCUTIL(obj,.vx,rtyp)
	;	CHECKDI^LNRENEW.proc	AUDIT^UCUTIL(.ln,.DIARRAY,10,"LN")
	;
	;	DEFAULT^DBSSCR4.m	fsn^UCUTIL(.fsn,fid)
	;	INSERT^SQLCMP.m		fsn^UCUTIL(.fsn,fid)
	;	UPDATE^SQLCMP.m		fsn^UCUTIL(.fsn,fid)
	;
	;	UPDATE^SQLCMP.m		LOAD^UCUTIL(.vinp,.vout)
	;
	;	DEFAULT^DBSSCR4.m	$$OBJGBL^UCUTIL(gbl,obj)
	;	DELETE^SQLCMP.m		$$OBJGBL^UCUTIL(gbl,obj)
	;	MULSEL^SQLCMP.m		$$OBJGBL^UCUTIL(gbl,obj)
	;	COMPILE^DBSFILB.proc	$$OBJGBL^UCUTIL($P(tblrec,"|",2),objName)
	;	MAIN^DBSFILB.proc	$$OBJGBL^UCUTIL($P(tblrec,"|",2),objName)
	;	INDEX^DBSINDXB.proc	$$OBJGBL^UCUTIL($P(tblrec,"|",2),OBJNAME)
	;	KEYCHG^DBSTRG.proc	$$OBJGBL^UCUTIL(gbl,objName)
	;
	;	DEFAULT^DBSSCR4.m	$$OBJNAME^UCUTIL(fid)
	;	INSERT^SQLCMP.m		$$OBJNAME^UCUTIL(fid)
	;	UPDATE^SQLCMP.m		$$OBJNAME^UCUTIL(fid)
	;	WHERE^SQLCMP.m		$$OBJNAME^UCUTIL(fid)
	;	DELETE^SQLCMP.m		$$OBJNAME^UCUTIL(fid)
	;	DBSINDXB^DBSINDXB.proc	$$OBJNAME^UCUTIL(fid)
	;	DBSJRNC^DBSJRNC.proc	$$OBJNAME^UCUTIL(PRITABLE)
	;	BLDJRN^DBSJRNC.proc	$$OBJNAME^UCUTIL(JRNTABLE)
	;	CHKTBLS^DBSJRNC.proc	$$OBJNAME^UCUTIL(TABLE)
	;	CASCDEL^DBSTRG.proc	$$OBJNAME^UCUTIL(fid)
	;
	;	DEFAULT^DBSSCR4.m	$$PARSE^UCUTIL(dinam,1)
	;	INSERT^SQLCMP.m		$$PARSE^UCUTIL(dinam)
	;	INSERT^SQLCMP.m		$$PARSE^UCUTIL(dinam)
	;	VALUE^SQLCMP.m		$$PARSE^UCUTIL(v)
	;	VALUE^SQLCMP.m		$$PARSE^UCUTIL(fid_"."_v)
	;	REQDI^SQLCMP.m		$$PARSE^UCUTIL(dinam))
	;	DEFAULT^SQLCMP.m	$$PARSE^UCUTIL(dinam)
	;	LOOKTBL^SQLCMP.m	$$PARSE^UCUTIL(dinam)
	;
	;	EXT^DBSFILER.proc	$$SN2OBJ^UCUTIL(fid)
	;
	; I18N=OFF
	;---- Revision History -------------------------------------------------
	; 04/13/07 - RussellDS - CR26386
	;	     Fixed syntax error in OBJNAME.
	;
	; 10/11/06 - Frans S.C. Witte - CRs: 22719 / 20613
	;	* Added deprecation notices, and re-arranged functions and
	;	  subroutines. Added documentation.
	;	* Removed all code that had been commented out.
	;	* Modified SN2OBJ to call $$getUpdCode^UCXDD() to be independent
	;	  of vobj(,-100,) tree structure.
	;	* case conversions now call ^UCGMR instead of ^%ZFUNC.
	;
	; 12/13/05 - Frans S.C. Witte - CRs: 18727 / 18164
	;	Corrected call to $$getOldNode^UCXDD()
	;
	; 10/10/05 - Frans S.C. Witte - CRs: 15592 / 15593
	;	Subroutine PARSE now calls $$rtGetExpr^UCXDD() for both MDB and
	;	RDB. Consequently, RPARSE has been commented out, because it was
	;	only called by PARSE.
	;
	; 09/01/05 - Frans S.C. Witte - CRs: 17101 / 17102
	;	SN2OBJ: replaced FOR loop + $QUERY() by MERGE, creation of -100
	;	tree now calls ^UCXDD. An exception will be trown if called for
	;	RDB table.
	;
	; 04/07/05 - Frans S.C. Witte - CRs: 15028 / 16039
	;	$$rdb^UCDB() changed to $$rdb^UCDBRT() (1 occurrence)
	;	Removed procedures delete, save, and bypassSave.
	;	Added accessibility of subroutines and functions.
	;	Rewrote RPARSE to use PSLColumn and $$rtCurNode^UCXDD().
	;
	; 02/11/05 - GIRIDHARANB - CR14407
	;	     Modified section RPARSE to account for a dummy node returned
	;	     in the case of a file type 11 on a relational database.
	;
	; 09/17/04 - Giridharanb - CR11515
	;	     Modified section RParse to correct the column name being passed
	;	     in into the $$getKeys^UCCOLUMN.
	;
	; 06/04/04 - GIRIDHARANB - CR9217
	;	     Modified section RPARSE to call getKey^UCCOLUMN to
	;	     skip dummy keys in the vobj level computation and added
	;	     support for wide tables.
	;
	; 05/21/05 - RussellDS - CR9676
	;	     Move to Profile01 to support single code base for PSL.
	;
	; 03/26/04 - RussellDS - CR9172
	;	     The AUDIT section has been moved to the new procedure
	;	     UCUTILN -- however retained AUDIT here for one
	;	     release since it is needed by filers until all of them
	;	     are recompiled and then make use of the new AUDIT
	;	     in UCUTILN.  Changed AUDIT here to call new AUDIT.
	;
	;	     Modify RPARSE section.
	;
	;	     Added coding to support Profile01 CR1390.  This modifies
	;	     the SN2OBJ section.
	;
	;	     NOTE that support for CR1390 is not yet fully implemented.
	;	     This change just brings PSL in line across the versions.
	;
	;	     Removed old change history.
	;
	quit
	;
	;-----------------------------------------------------------------------
MARKER(SRC,CURMARK)	;public void; 
	;-----------------------------------------------------------------------
	; Add a source code line marker to every line in SRC()
	;
	; ARGUMENTS:
	; . public String SRC() = PSL source code array
	;	Although the code in this subroutine does not assume anything
	;	about the subscripts, it does assume that the result of
	;		subscript value + CURMARK
	;	provides a useful reference to the PSL source code line.
	; . local Number CURMARK = base value for marker offset
	;	This value will be added to the subcript in SRC() to produce
	;	the marker comment.
	;
	; OUTPUTS:
	; . a comment
	;		//PSL++marker
	;	has been added to all "code lines"
	;
	; NOTES:
	; . Some lines that contain PSL code (as opposed to PSL comment) may
	;	not be marked.
	; . The marker value assumes that lines are numbered sequentially within
	;	SRC().
	; . A better way to achieve this is by adding this feature to the
	;	compiler itself. The compiler does already track line numbers
	;	and subroutine relative line numbers e.g. to show messages.
	;-----------------------------------------------------------------------
	S CURMARK=$G(CURMARK)
	N I
	S I=""
	F  S I=$O(SRC(I)) Q:I=""  D
	.	I SRC(I)["}" Q
	.	i SRC(I)["*/" Q
	.	I SRC(I)["#i"!(SRC(I)["#e") quit
	.	i $$UPPER^UCGMR(SRC(I))["CATCH" Q
	.	S SRC(I)=SRC(I)_$C(9)_"//PSL++"_(I+CURMARK)
	Q
	;
	;***********************************************************************
	;****         ALL CODE BELOW THIS COMMENT LINE IS DEPRECATED        ****
	;***********************************************************************
	;
	;-----------------------------------------------------------------------
AUDIT(obj,audit,rectyp,fid)	; deprecated public void 
	;-----------------------------------------------------------------------
	; Convert vobj(obj) into audit(column_name)=old_val|new_val
	;
	; NOTE:  This subroutine retained for backward compatibility for one
	; version until all code is recompiled to use AUDIT^UCUTILN
	;
	;-----------------------------------------------------------------------
	N del
	S del=$P(^DBTBL("SYSDEV",1,fid,10),"|",1)
	;;I '(del="") S del=$S(del<32!(del>127):"$C("_del_")",1:$$QADD^%ZS($C(del),""))
	S del=$S(del="":"|",1:$C(del))
	;
	D AUDIT^UCUTILN(obj,.audit,rectyp,del)
	;
	Q
	;
	;-----------------------------------------------------------------------
fsn(fsn,file)	;deprecated public void 
	;-----------------------------------------------------------------------
	; Define PSL storage mapping - from short name to vobj(obj
	;
	; ARGUMENTS:
	; . fsn		file attributes		/TYP=T/MECH=REFARRY:RW
	; . file	DQ file name		/TYP=T/REQ/MECH=VAL
	;
	; OUTPUTS:
	; . fsn(file) = vobj(recId, | ...
	;	with recId = $$OBJNAME(file), and all other fields as returned
	;	by fsn^SQLDD
	; . vsub(file.keycolumn) = vobj(recId,keysub)
	;	for each key column of the table
	;
	; EXAMPLES:
	;
	; D fsn^UCUTIL(.fsn,"DEP")
	; D fsn^UCUTIL(.fsn,"HIST")
	;
	; Returns internal storage variable in vobj(obj format and also map
	; access keys into level -3 to -9
	;
	; fsn("DEP")="vobj(dep,|^ACN(CID|CID|10|0|DEPFILE||FMLD||124|SYSDEV|50||PBS"
	; fsn("HIST")="vobj(hist,|^HIST(CID,TSEQ|CID,TSEQ|1|0|HISTFILE|0|||124|SYSDEV|||PBS
	; vsub("DEP.CID")="vobj(dep,-3)"
	; vsub("HIST.CID")="vobj(hist,-3)"
	; vsub("HIST.TSEQ")="vobj(hist,-4)"
	;
	; NOTES:
	; . This subroutine generates correct results for both MDB and RDB
	;	because the purpose nodes used for the primary key columns is
	;	the same for MDB and RDB.
	;-----------------------------------------------------------------------
	N i,keys,obj
	D fsn^SQLDD(.fsn,file) I $G(ER) Q	; File attributes
	S obj=$$OBJNAME(file)		 	; Assign object name
	S $P(fsn(file),"|",1)="vobj("_obj_","
	S keys=$P(fsn(file),"|",3)
	I keys="" Q
	F i=1:1:$L(keys,",") S vsub(file_"."_$P(keys,",",i))="vobj("_obj_",-"_(i+2)_")"
	Q
	;
	;-----------------------------------------------------------------------
LOAD(list,code,file)	;deprecated public void 
	;-----------------------------------------------------------------------
	; Create database loading logic
	;
	; ARGUMENTS:
	; . list	input list in tbl.col format	/TYP=T/REQ/MECH=REFARRY:R
	; . code	Database loading logic in vobj  /TYP=T/MECH=REFARRY:W
	;               format
	; . file	Primary table			/TYP=T/NOREQ/MECH=VAL
	;
	; THROWS:
	; . %PSL-E-RDBFAIL exception
	;	This exception will be thrown if one of the tables does not
	;	reside in M.
	;
	; EXAMPLE:
	;
	; S A("CIF.TAXID")="",A("CIF.ATN")="" D LOAD(.A,.B)
	;
	; returns:
	;
	;  B=2
	;  B(1)="S:$D(vobj(cif,2))#2=0 vobj(cif,2)=$G(^CIF(vobj(cif,-3),2))"
	;  B(2)="S:$D(vobj(cif,20))#2=0 vobj(cif,20)=$G(^CIF(vobj(cif,-3),20))"
	;-----------------------------------------------------------------------
	N di,fid,fsn,i,j,ref,vcode,z
	K code
	S i=""
	F  S i=$O(list(i)) Q:i=""  D
	.	S ref=$TR(i,"][",".")
	.	I ref'["." Q					; wrong format
	.	I $L(ref,".")=3 S ref=$P(ref,".",2,3)		; remove %LIBS
	.	S fid=$P(ref,".",1)				; table name
	.	I $$rtIsRdb^UCXDD(fid) S $ZS="-1,"_$ZPOS_",%PSL-E-RDBFAIL,"_fid X $ZT
	.	I '$D(fsn(fid)) D fsn(.fsn,fid)			; get attributes
	.	S z=$$PARSE^SQLDD(ref,,.cmp,.fsn,,.vdd,,.vsub)
	;
	I '$D(fid) Q						; nothing to build
	S j=1
	S fid=""
	F  S fid=$O(fsn(fid)) Q:fid=""  D
	.	K vcode
	.	I $P(fsn(fid),"|",4)=11 S fsn(fid," ")=$P(fsn(fid),",",1)_")"	; force load of top level
	.	D LOAD^SQLDD(fid,.fsn,.vcode,,,,.vsub,.cmp)	; build load logic
	.	I $g(file)'="",file'=fid D			; join primary table
	..		S z=$P($P(fsn(fid),"vobj(",2),",",1),code(j)=" N "_z_" S "_z_"=$O(vobj(""""),-1)+1",j=j+1
	..		s z=$$PARSE^SQLDD(file_"."_$P(fsn(fid),"|",3),,.cmp,.fsn,,.vdd,,.vsub)
	..		S code(j)=" S "_$P(fsn(fid),"|",1)_"-3)="_z,j=j+1
	.	S i=""  F  S i=$O(vcode(i)) Q:i=""  S code(j)=" "_vcode(i),j=j+1
	Q
	;
	;-----------------------------------------------------------------------
OBJGBL(gbl,obj)	; deprecated public String 
	;-----------------------------------------------------------------------
	; Convert global reference to vobj format
	;
	; Example:  ^ACN(CID  		-->  ^ACN(vobj(acn,-3)
	;           ^HIST(CID,TSEQ	--> ^HIST(vobj(hist,-3),vobj(hist,-4
	;-----------------------------------------------------------------------
	I gbl["vobj" Q gbl				; Already converted
	N i,j,k,zgbl
	S j=3,zgbl=$P(gbl,"(",1),gbl=$P(gbl,"(",2,99)
	F i=1:1:$L(gbl,",") D
	.	S k=$P(gbl,",",i)			; Access key
	.	I '(($E(k)?1A)!($E(k)="%")) Q		; Dummy key
	.       S $P(gbl,",",i)="vobj("_obj_";-"_j_")"	; Convert to vobj(obj,-
	.	S j=j+1
	Q zgbl_"("_$TR(gbl,";",",")
	;
	;-----------------------------------------------------------------------
OBJNAME(file)	;depreacted public String 
	;-----------------------------------------------------------------------
	; Assign default object name based on file name
	;
	I file'["_" Q $$LOWER^UCGMR(file) 	; Default to lowercase file name
	;
	Q $$LOWER^UCGMR($TR(file,"_"))		; Remove underscore
	;
	;-----------------------------------------------------------------------
PARSE(str,psl)	;deprecated public String 
	;-----------------------------------------------------------------------
	; Convert string expression into vobj format
	;
	; ARGUMENTS:
	; . str	= string expression			/TYP=T/REQ/MECH=VAL
	;	The value is tokenized. The string literals occur in
	;	public String tok (see INPUTS)
	; . psl = PSL format				/TYP=L/MECH=VAL
	;
	; INPUT:
	; . tok = tokenized literals (?!)
	;
	; EXAMPLE:
	;
	; DEP.BAL			->  $P(vobj(dep,51),"|",1)
	; DEP.BAL>100			->  $P(vobj(dep,51),"|",1)>100
	;
	; NOTES:
	; . By using $$rtGetExpr^UCXDD() for both MDB and RDM, intended
	;	side-effects to cmp, fsn, vdd, and vsub caused by
	;	$$PARSE^SQLDD(),  will no longer occur.
	; . The call to $$UNTOK^%ZS(,) remains, but is questionable. If the call
	;	comes from SQL, the M quote is used to delimit identifiers, not
	;	string literals. It shall be the caller's responsibility to take
	;	care of literals, and this function shall only need to strip
	;	the double quotes that may surround SQL identifiers.
	; . The check
	;		I atom'?1A.AN.E1".".E.AN
	;	will fail if the table name is quoted. Furthermore the use of
	;	.E on both sides of the "." is questionable (e.g. .E.AN == .E).
	;-----------------------------------------------------------------------
	N atom,cln,dels,fid,ptr,return,tbl
	;
	I str["_",$TR(str,"_")?1A.AN1"."1A.AN S psl=1	; PSL format
	;
	S dels=",()+-*/\#'=><[]\*"
	I '$G(psl) S dels=dels_"_"		; DQ mode (allow underscore)
	S ptr=0,return=""
	;
	F  D  Q:ptr=0
	.	S atom=$$ATOM^%ZS(str,.ptr,dels)
	.	I $L(atom,".")=3 S atom=$P(atom,".",2,3)	; remove %LIBS
	.	I atom'?1A.AN.E1".".E.AN S return=return_atom Q	; table.column format
	.	S atom=$$UPPER^UCGMR($$UNTOK^%ZS(atom,.tok))	; convert it to uppercase
	.	S tbl=$P(atom,".",1) I tbl["""" S tbl=$P(tbl,"""",2)
	.	S cln=$P(atom,".",2) I cln["""" S cln=$P(cln,"""",2)
	.	S return=return_$$rtCurExpr^UCXDD(tbl,cln,$$OBJNAME(tbl),0)
	Q return
	;
	;-----------------------------------------------------------------------
SN2OBJ(fid)	;deprecated public Number; 
	;-----------------------------------------------------------------------
	; Convert short name array into vobj() structure
	;
	; ARGUMENTS:
	; . fid		Table name	/TYP=T/REQ/MECH=VAL
	;
	; OUTPUTS:
	; . $$	= objectid
	;	The subscript in vobj() that contains the translated data
	; . vobj(objectid)
	;	This structure is initialized by
	;	- merging the data of DBTBL1.FSN
	;	- assigning vobj(objectid,key) from the key name variables
	;	- assigning the vobj(objectid,-100) tree from UX()
	;	- assigning the vobj(objectid,-400) tree from UX()
	; . ER and RM
	;	when set by fsn^SQLDD()
	;
	; THROWS:
	; . %PSL-E-RDBFAIL exception
	;	This exception will be thrown if the table does not reside in M
	;
	; INPUTS:
	; . the variable specified by DBTBL1.FSN contains the non-key data using
	;	exactly the same structure as the MDB vobj() structure for the
	;	table.
	; . the values of primary key columns are found in M lvns with the same
	;	name as the key column name (i.e. key ACN in variable ACN etc.)
	; . public Number %O
	;	The function uses %O'=2 and %O=1
	; . public String UX()
	;	Contains the equivalent of vobj(,-100,) and vobj(,-400,). The
	;	information will only be inspected if %O=1.
	;	In particular:
	;	- $P(UX(fid,column),"|",1) = old value
	;	- $P(UX(fid,column),"|",6) = 1 to indicate suppress journal
	;
	; EXAMPLE:
	;
	; W $$SN2OBJ("DEP")
	;
	; NOTES:
	; . The code has been rewritten to XECUTE $$getUpdAudit^UCXDD() with
	;	"obj" and "$P(UX(fid,col),""|"")" as literal parameters. This
	;	makes the code completely independent of the -100 structure.
	;-----------------------------------------------------------------------
	;
	; If table stored in RDB, shortname layout and vobj() layout will be
	; inherently different. Generate runtime error
	I $$rtIsRdb^UCXDD(fid) S $ZS="-1,"_$ZPOS_",%PSL-E-RDBFAIL,"_fid X $ZT
	;
	N fsn,i,keys,obj,sn,type
	D fsn^SQLDD(.fsn,fid) I $G(ER) quit ""		; File attributes
	S sn=$P($P(fsn(fid),"|",1),"(",1)		; File short name
	S keys=$P(fsn(fid),"|",3)			; Access keys
	;
	S obj=$O(vobj(""),-1)+1				; Next object
	S vobj(obj,-2)=$G(%O)+0				; Processing mode
	S vobj(obj,-1)="Record"_$$UPPER^UCGMR(fid)	; RecordType
	;
	; Merge short name into vobj(). This takes care of all non-key data
	I %O'=2 M vobj(obj)=@sn
	;
	; Add key columns
	I keys'="" F i=1:1:$L(keys,",") S vobj(obj,-2-i)=@$P(keys,",",i)
	;
	; On UPDATE convert UX into vobj(obj,-100,) and vobj(obj,-400,)
	I %O=1 D
	.	N cld,col,pslTbl
	.	S col=""
	.	F  S col=$O(UX(fid,col)) Q:col=""  D
	..		S cld=$$getPslCln^UCXDD(fid,col,.pslTbl)
	..		X $$getUpdAudit^UCXDD(cld,"obj","$P(UX(fid,col),""|"")",0)
	..		I $P(UX(fid,col),"|",6) S vobj(obj,-400,col)=0  ; Turn journalling off for this column
	Q obj
