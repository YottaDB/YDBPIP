DBSDB	;LIBRARY; Data-Dictionary Database Access Library
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/14/02 13:56:56 - RUSSELL
	;     ORIG:  FSANCHEZ - 25 DEC 1991
	;
	; This routine contains a library of data dictionary related functions.
	;
	;
	;  LIBRARY: FLTDB       - Load a Global Record into Memory
	;           SETVAL      - Set a value into a record
	;	    $$EXISTS	- Returns record exists status based on keys
	;           $$RETREC    - Return a record from the database
	;	    $$RETVAL    - Return a value from a record
	;
	;---------- Revision History ------------------------------------------
	; 12/06/05 - RussellDS - CR18400
	;	     Move ERR section into this routine from DBSDD since this
	;	     this was only use.
	;
	;	     Redirect call to addz1 from DBSDD to DBSLOD, where it now
	;	     resides.
	;
	; 10/31/05 - RussellDS - CR17834
	;	     Removed CASDEL, CASUPD, RESDEL, and RESUPD sections - no
	;	     longer called by anything.  Removed PROCESS, CHKDB, and
	;	     GETLIST sections, only called by them.
	;
	;	     Removed old revision history.
	;
	;----------------------------------------------------------------------
EXISTS(fid,acc,del,fsn,new)	;public; Return existence of a record
	;----------------------------------------------------------------------
	; Returns the current state of a record in the database based
	; on the primary key(s).  The primary keys(s) must be supplied
	; in the parameter acc, separated by the delimiter character in
	; the parameter del, in the order that they exist in the global.
	;
	; This function will make a network RPC call if it is invoked on
	; a client and the table exists on the server only.
	;
	; This function is similar to the MUMPS $DATA function.
	;
	; KEYWORDS: Database
	;
	; RELATED: SETVAL^DBSDD,$$RETVAL^DBSDD
	;
	; ARGUMENTS:
	;	. fid		Table Name		/REQ/MECH=VAL
	;	. acc		Access key values	/REQ/MECH=VAL
	;	. del		ASCII Field Delimiter	/NOREQ/MECH=VAL/DFT=124
	;	. fsn(file)	File Attributes	Header	/NOREQ/MECH=REF:RW
	;	. new		New Access Keys		/NOREQ/TYP=L
	;
	;   RETURNS:
	;	. $$	Record Defined=1, Not Defined=0
	;	. ER    (0,1) Error Flag
	;       . RM    Error message message (If ER=1)
	;
	;  EXAMPLES:
	; I '$$EXISTS^DBSDB("DEP",CID) W "Record Not on file"
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	I '$D(fsn(fid)) D fsn^DBSDD(.fsn,fid) I ER Q ""
	;
	I $G(%LOGID),'$P(fsn(fid),"|",5) Q $$MRPC^PBSCLI("$$EXIST^DBSEDIT(fid,acc,.del)")
	;
	I $G(del)="" S del="|"
	E  S del=$C(del)
	;
	N I,gbl,key,keys,v
	;
	S gbl=$P(fsn(fid),"|",2),keys=$P(fsn(fid),"|",3)
	;
	I $G(new) N @keys
	;
	F I=1:1:$L(keys,",") S key=$P(keys,",",I),v=$P(acc,del,I),@key=v I v="" S ER=1,RM=$$^MSG(8390,key) Q
	I ER Q ""
	;
	I $E(gbl,$L(gbl))'=")" S gbl=gbl_")"
	Q $D(@gbl)>0
	;
	;----------------------------------------------------------------------
RETREC(frm,sel,acc,ext,del,qwt,fsn,vdd,par,sqlind)	;public; Return database record
	;----------------------------------------------------------------------
	; Returns a list of values corresponding to an input list of data
	; items. Multi-table capability based on foriegn key definitions.
	; Uses RPC protocol in client mode.
	;
	; Note: See documentation for $$RETVAL
	;
	; KEYWORDS: Database
	;
	; RELATED: SETVAL^DBSDD,$$RETVAL^DBSDD
	;
	; ARGUMENTS:
	;	. frm		List of valid files	/TYP=T/REQ/MECH=VAL/DEL=44
	;	. sel		Select Item List	/TYP=T/REQ/MECH=VAL/DEL=44
	;	. acc		Access key values	/TYP=T/REQ/MECH=VAL
	;	. ext		External format		/TYP=L/DFT=0/MECH=VAL
	;	. del		ASCII Field Delimiter	/TYP=N/MECH=VAL/DFT=124
	;	. qwt		ASCII Quote Character	/TYP=N/MECH=VAL
	;	. fsn(file)	File Attributes	Header	/TYP=T/MECH=REF:RW
	;	. vdd(ddref)	Dictionary Record	/TYP=T/MECH=REF:RW
	;	. par(opt)      SQL parameters		/NTYP=T/MECH=ARRAY:RW          
	;	. sqlind        Column protections      /NTYP=T/MECH=REF:W       
	;
	;   RETURNS:
	;	. $$	Database value List
	;	. ER    (0,1) Error Flag
	;       . RM    Error message message (If ER=1)
	;
	;  EXAMPLES:
	;
	; W $$RETREC^DBSDB("DEP","BAL,BALAVL,LNM,TLD",123)
	; 1000|850.25|SMITH,JOHN|56613
	;
	; W $$RETREC^DBSDB("DEP","BAL,BALAVL,LNM,TLD",123,,44,34)
	; 1000,850.25,"SMITH,JOHN",56613
	;
	; W $$RETREC^DBSDB("DEP","BAL,BALAVL,LNM,TLD",123,,44,39)
	; 1000,850.25,'SMITH,JOHN',56613
	;
	; --- External format
	;
	; W $$RETREC^DBSDB("DEP","BAL,BALAVL,LNM,TLD",123,1)
	; 1000|850.25|SMITH,JOHN|01/01/96
	;
	; W $$RETREC^DBSDB("DEP","BAL,BALAVL,LNM,TLD",123,1,44,34)
	; 1000,850.25,"SMITH,JOHN","01/01/96"
	;
	; W $$RETREC^DBSDB("DEP","BAL,BALAVL,LNM,TLD",123,1,44,39)
	; 1000,850.25,'SMITH,JOHN','01/01/96'
	;
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N dinam,expr,i,file,key,keys,typ,whr,sqldta,sqlcod,sqlcnt,v,x,z
	;
	I $G(del)="" S del=124				; Default delimiter
	S qwt=$G(qwt)
	I qwt'="" S qwt=$C(qwt)
	S ext=$G(ext)
	;
	S file=$P(frm,",",1)
	I '$D(fsn(file)) D fsn^DBSDD(.fsn,file) I ER Q ""
	;
	D maplit(.fsn,file,.acc) I ER Q ""	; Map access keys
	;
	S par("JOIN")=1
	S par("DQMODE")=1				; *** BC 09/03/96
	;
	S keys=$P(fsn(file),"|",3),key=$P(keys,",",1)
	;I18N=OFF
	S expr=sel_" FROM "_frm
	;
	I key'="" S expr=expr_" WHERE "_file_"."_key_"=:"_key,par("USING")=key_"='"_$P(acc,",",1)_"'" ; *** 02/07/96
	;
	F i=2:1:$L(keys,",") I $P(acc,",",i)'="" D
	.	;
	.	S key=$P(keys,",",i)
	.	S expr=expr_" AND "_file_"."_key_"=:"_key
	.	S par("USING")=par("USING")_","_key_"='"_$P(acc,",",i)_"'" ; ***
	;
	S expr="SELECT "_expr
	;I18N=ON
	S ER=$$^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind)	; *** 02/16/96
	I ER Q ""
	;
	I '$G(sqlcnt) S ER=1,RM=$$^MSG(5521) Q ""
	; Modified from RM="" to RM=$G(RM) below	; gfm 02/04/00
	S RM=$G(RM)					; *** 11/01/96
	I qwt'=""!ext D		 		; Quotes or external format
	.	S z=""
	.	F i=1:1:$L(sqldta,$C(9)) D
	..		S dinam=$P(sel,",",i)		; Column name
	..		K typ
	..		S x=$$MCOL^SQLCOL(dinam,frm,,.typ)	; Column type
	..		S v=$P(sqldta,$C(9),i)		; Column value
	..		I ext,"DCL"[typ S v=qwt_$$EXT^%ZM(v,typ)_qwt
	..		I "TUF"'[typ S z=z_v_$C(9) Q	; Numeric type
	..		S z=z_qwt_v_qwt_$C(9)		; Text data type
	.	S sqldta=$E(z,1,$L(z)-1)
	;
	I $G(del)'=9 Q $TR($G(sqldta),$C(9),$C(del))
	Q $G(sqldta)
	;
	;----------------------------------------------------------------------
RETVAL(ddexpr,acc,buf,vfy,fsn,x,vdd)	;public; Return Field Value from Database
	;----------------------------------------------------------------------
	; Returns the value of 'ddexpr' with keys 'acc' as it exists
	; in the record in local memory.  Will fault from disk if
	; required. 
	;
	; Note: Use the 'buf' parameter in conjunction with the 'acc'
	;	parameter to keep track of the last record loaded.  This
	;	will optimize database IO by referencing local storage
	;	first (unless the access keys 'acc' have changed).
	;
	;	If the 'acc' parameter is not passed, $$RETVAL attempts
	;	to assign keys based on local variables in the symbol
	;       table.  This is not recommended - it exists for backward 
	;	compatibility, or if the caller is managing context and
	;	data arrays itself.
	;
	; KEYWORDS:	Database
	;
	; RELATED: SETVAL^DBSDD,$$RETREC^DBSDD
	;
	; ARGUMENTS:
	;	. ddexpr	Dictionary Reference	/REQ/MECH=REF:RW
	;			See $$CVTREF^DBSDD for syntax
	;	. acc		Access key values	/REQ/MECH=VAL/DEL=44
	;	. buf		Current Buffer		/NOREQ/MECH=REF:RW
	;	. vfy		Check if Defined	/NOREQ/DFT=N
	;	. fsn(file)	File Attributes Record	/NOREQ/MECH=REF:RW
	;	. x		Parameter Record	/NOREQ/MECH=REF:RW
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;
	; RETURNS:
	;	. $$           Field value from record
	;	. ER           (0,1) Error Flag
	;	. RM           Error message message (If ER=1)
	;
	; EXAMPLE:
	;
	; W $$RETVAL^DBSDD("DEP.IRN",1)
	; 12.5
	;-----------------------------------------------------------------------
	;
	S ER=0
	;
	I $L(ddexpr,".")'=3 S ddexpr=$$CVTREF^DBSDD(ddexpr) Q:ER ""
	;
	N cmp,file,gvn,vsub,lvn,z,nod,NS
	;
	I $G(x)="" S x=$$DI^DBSDD(.ddexpr,,.vdd) I ER Q ""
	;
	S nod=$P(x,"|",1)
	I nod["*" Q $$ACCKEY(ddexpr,.acc,.fsn,.vsub)
	;
	S file=$P(ddexpr,".",2)
	;
	D PARSE^DBSDD(ddexpr,x,.cmp,.fsn,file,.vdd,,.vsub) I ER Q ""
	;
	I nod'=+nod,$E(nod)'="""" S nod=" "
	;
	I '$D(cmp),$D(fsn(file,nod)) D
	.	;
	.	S lvn=$P(fsn(file,nod),"|",1)
	.	I $D(@lvn)#2,'$D(buf(lvn))!(buf(lvn)=$G(acc)) Q  ; *** 07/30/96
	.	I $G(@lvn)'="",'$D(buf(lvn))!(buf(lvn)=$G(acc)) Q
	.	;
	.	D FLTDB(file,nod,.acc,.fsn,.vfy,.vsub,.gvn) Q:ER
	.	S buf(lvn)=$G(acc)
	;
	E  D FLTREC(file,.gvn)
	;
	I ER Q ""
	X "S NS="_NS
	Q NS
	;
	;----------------------------------------------------------------------
ACCKEY(ddexpr,acc,fsn,vsub)	; Return the value of an access key
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N di,file,keys,z
	;
	S file=$P(ddexpr,".",2),di=$P(ddexpr,".",3)
	;
	I '$D(fsn(file)) D fsn^DBSDD(.fsn,file) I ER Q ""
	S keys=$P(fsn(file),"|",3) I keys="" Q ""
	;
	I $D(vsub(ddexpr))#2 S z=vsub(ddexpr),z=$S($E(z)="""":$E(z,2,$L(z)-1),z=+z:z,1:$G(@z))
	E  S z=$S($G(acc)="":$G(@di),1:$P(acc,$C(44),$L($P(","_keys_",",","_di_",",1),",")))
	;
	I z="" D ERR($$^MSG(48),$P(ddexpr,".",2,3))
	Q z
	;
	;----------------------------------------------------------------------
SETVAL(ddexpr,value,x,fsn,vdd,ux,scrseq)	;public; Set Value into Local Array
	;----------------------------------------------------------------------
	; Places a value into a record in memory based on dictionary rules.
	;
	; KEYWORDS:	Database
	;
	; RELATED: $$RETVAL^DBSDD,$$RETREC^DBSDD
	;
	; ARGUMENTS:
	;	. ddexpr	Dictionary Reference	/REQ/MECH=REF:RW
	;			See $$CVTREF^DBSDD for syntax
	;	. value		Value to insert		/REQ/MECH=VAL
	;	. x		Parameter Record	/NOREQ/MECH=REF:RW
	;	. fsn(file	File Name 
	;	. fsn(file)	File Attributes Record	/NOREQ/MECH=REF:RW
	;	. vdd(ddref	LIB.FID.DI Reference  
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;	. ux		Field change array	/NOREQ/MECH=REFNAM:RW
	;	. scrseq	Screen repeat region	/TYP=N/NOREQ/MECH=VAL
	;
	; RETURNS:
	;	. ER		(0,1) Error Flag
	;	. RM		Error message message (If ER=1)
	;
	; EXAMPLE:
	;
	; D SETVAL^DBSDD("DEP.IRN",12.5)
	; W DEP(54)
	; "12.5|||1"
	;-----------------------------------------------------------------------
	;
	S ER=0
	;
	I $L(ddexpr,".")'=3 S ddexpr=$$CVTREF^DBSDD(ddexpr) Q:ER
	;
	I $G(x)="" S x=$$DI^DBSDD(ddexpr,.flist,.vdd) I x="" Q
	I $P(x,"|",16)'="" D ERR($$^MSG(7914),ddexpr) Q
	;
	N acc,lvn,nod,file
	;
	S nod=$P(x,"|",1),file=$P(ddexpr,".",2)
	I nod["*" S @$P(ddexpr,".",3)=value Q
	;
	I nod'=+nod,$E(nod)'="""" S nod=" "
	I nod=1,$G(scrseq)>1 s nod=scrseq		; screen repeat region
	;
	S lvn=$P($G(fsn(file,nod)),"|",1)
	I lvn="" D lodnod^DBSDD(file,nod,.fsn) S lvn=$P(fsn(file,nod),"|",1)
	;
	I '$D(@lvn) D FLTDB(file,nod,,.fsn) Q:ER
	;
	N itp,vsf,del,pos
	;
	S del=$P(fsn(file),"|",10)
	S itp=$P(x,"|",11),vsf=$P(x,"|",18),pos=$P(x,"|",21)
	;
	I $G(ux) D
	.	;
	.	N old,di
	.	S old=$$RETVAL(ddexpr,,,1,.fsn,x,.vdd),di=$P(ddexpr,".",3)
	.	I old=value,'$D(UX(file,di)) Q			; No change
	.	I $D(UX(file,di)),$P(UX(file,di),"|",1)=value K UX(file,di) Q
	.	S UX(file,di)=old_"|"_value_"|"_nod_"|"_pos Q
	;
	I $G(vsf)'="" D  Q					; Subfield
	.	;
	.	N vsft,vsfd1,vsfd2,vsfp
	.	S vsft=$P(vsf,"~",1),vsfd1=$P(vsf,"~",2),vsfd2=$P(vsf,"~",3),vsfp=$P(vsf,"~",4)
	.	S:vsfd1 vsfd1=$C(vsfd1) S:vsfd2 vsfd2=$C(vsfd2)
	.	;
	.	I pos="" S @lvn=$$PUT^USUB(@lvn,value,vsft,vsfd1,vsfd2,vsfp) Q
	.	S $P(@lvn,$C(del),pos)=$$PUT^USUB($P(@lvn,$C(del),pos),value,vsft,vsfd1,vsfd2,vsfp)
	;
	I pos="" S @lvn=value Q  ;			No pieces
	S $P(@lvn,$C(del),pos)=value
	Q
	;
	;----------------------------------------------------------------------
FLTREC(file,gvn)	; Fault a record into memory based on fsn(file)
	;----------------------------------------------------------------------
	;
	N nod
	I $G(gvn)="" S gvn=$P($G(fsn(file)),"|",2)
	;
	S nod=""
	F  S nod=$O(fsn(file,nod)) Q:nod=""  D  Q:ER
	.	;
	.	S lvn=$P(fsn(file,nod),"|",1)
	.	I $G(acc)'="",$G(buf(lvn))=acc,$G(@lvn)'="" Q
	.	;
	.	D FLTDB(file,nod,.acc,.fsn,.vfy,.vsub,.gvn) Q:ER
	.	S buf(lvn)=$G(acc)
	I ER Q
	;
	F  S nod=$O(cmp(file,nod)) Q:nod=""  X cmp(file,nod)
	Q
	;
	;----------------------------------------------------------------------
FLTDB(file,nod,acc,fsn,vfy,vsub,gvn)	;public; Load a Global Record into Memory
	;----------------------------------------------------------------------
	; Load a MUMPS global reference into local memory.
	;
	; KEYWORDS:	Database
	;
	; RELATED: SETVAL^DBSDD,$$RETREC^DBSDD,$$RETVAL^DBSDD
	;
	; ARGUMENTS:
	;	. file		Data-Qwik Filename	/REQ
	;	. nod		Bottom key (nod)	/REQ
	;	. acc		Access key list		/REQ/MECH=VAL
	;	. fsn(file)	File Attributes Record	/REQ/MECH=REF:R
	;	. vsub(ddref)	Literal Substitution	/NOREQ/MECH=REF:R
	;	. gvn		Global Reference	/NOREQ
	;	. vfy		Check Database		/NOREQ/DFT=N
	;
	; RETURNS:
	;	. @lvn		Field value from record
	;	. ER		(0,1) Error Flag
	;	. RM		Error message message (If ER=1)
	;
	; EXAMPLE:
	;
	;----------------------------------------------------------------------
	;
	I '$D(fsn(file)) D fsn^DBSDD(.fsn,file)
	;
	N array,z
	;
	S ER=0
	;
	D maplit(.fsn,file,.acc,.vsub,.gvn) Q:ER
	;
	; *** 01/18/96 BC  (changed routine name from DBSDD to DBSDB)
	I $G(%LOGID),'$P(fsn(file),"|",5) D STUB^PBSCLI("FLTDB1^DBSDB",,,,"file,nod,acc,fsn",$P(fsn(file),"|",1))
FLTDB1	;
	; Database Reference Does not Exist
	I $G(vfy) S vfy=0,z=$S($P(gvn,"(",2)="":$P(gvn,"(",1),1:gvn_")") I '$D(@z) S ER=1,RM=$$^MSG(2335,acc) Q
	;
	N array
	D addz1^DBSLOD(file,nod,.array,.fsn,1,,.gvn,.vsub)
	F z=1:1:array X array(z)
	Q
	;
	;----------------------------------------------------------------------
maplit(fsn,file,acc,vsub,gvn)	; Map literal array lit based on acc or lvn
	;----------------------------------------------------------------------
	;
	N I,keys,ref,v,val,del,qwt
	;
	S del=$C(44),qwt=$C(34)
	;
	I '$D(fsn(file)) D fsn^DBSDD(.fsn,file)
	;
	S v=fsn(file),gvn=$P(v,"|",2),keys=$P(v,"|",3)
	S ref=$P(v,"|",11)_"."_file_"."
	;
	I $G(acc)="" D  Q:ER
	.	;
	.	F I=1:1:$L(keys,",") D  Q:ER
	..		;
	..		S z=$$ACCKEY(ref_$P(keys,",",I),,.fsn,.vsub) Q:ER
	..		I z["," S z=""""_z_""""
	..		I $G(acc)="" S acc=z
	..		E  S acc=acc_","_z
	;
	S val=acc
	S keys=$P(gvn,"(",2,999),gvn=$P(gvn,"(",1)_"("
	;
	I keys'="" F  D  S gvn=gvn_v_"," Q:keys=""
	.	;
	.	S v=$P(keys,",",1),keys=$P(keys,",",2,999)
	.	I v=+v Q
	.	I $E(v)="""" Q:$L(v,"""")#2  F  Q:keys=""  S v=v_","_$P(keys,",",1),keys=$P(keys,",",2,99) Q:$L(v,"""")#2
	.	I  Q
	.	;
	.	I val="" S keys="" D ERR($$^MSG(48),z) Q
	.	S z=v,v=$P(val,del,1),val=$P(val,del,2,999)
	.	I v'["E",v=+v S vsub(ref_z)=v Q			; MJZ - 31191
	.	I $E(v)=qwt Q:$L(v,qwt)#2  F  Q:val=""  S v=v_del_$P(val,del,1),val=$P(val,del,2,99) Q:$L(v,qwt)#2
	.	I  Q
	.	;  S v=""""_v_"""",vsub(ref_z)=v      ;  *** XUS 11/30/94
	.	S v=$$DBLQ^DBSEDIT(v),vsub(ref_z)=v   ;  *** XUS 11/30/94
	;
	S gvn=$E(gvn,1,$L(gvn)-1)
	Q
	; 
	;----------------------------------------------------------------------
CONTAIN(list,entry)	; See if entry is contained in list
	;----------------------------------------------------------------------
	;
	Q (","_list_",")[(","_entry_",")
	;
	;----------------------------------------------------------------------
ERR(msg,more)	;	Process Subroutine fatal error
	;
	;	Tag+Line^Routine, SCA_[System_Name], msg: more
	;----------------------------------------------------------------------
	;
	ZSH "S":msg
	S ER=1,RM=msg("S",2)_", SCA_"_$G(%SN)_", "_msg_": "_$G(more)
	Q
