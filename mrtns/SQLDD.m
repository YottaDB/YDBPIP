SQLDD	;; Library
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/10/03 11:24:02 - GIRIDHARANB
	;            
	;     ORIG:  FSANCHEZ - 25 DEC 1991
	;
	; This routine contains a library of data dictionary related functions.
	;
	;
	;  LIBRARY: LOAD        - Build Database Load Code
	;           PARSE	- Return MUMPS expression for ddref
	;           fsn         - Load File Header Record
	;	    dentry      - Load Data Entry Information
	;           $$CVTREF    - Convert external reference to internal
	;	    $$DI	- Return record from dictionary for ddref
	;           $$FINDINAM  - Find the next dictionary reference in string
	;	    $$GETSEQ	- Get unique sequence number
	;	    $$LIST	- Return data item list in file definition field order
	;           $$PCODE	- Parse Special code {} syntax
	;	    $$REQITEM	- Return a list of required column names
	;           $$VER       - Verify dictionary element 
	;	    $$TABLE     - Return lookup sysntax from file header page
	;
	Q
	; I18N=QUIT
	;---- Revision History ------------------------------------------------
	; 03/18/2009 - RussellDS - CR38348
	;	* Added checking for null character substitute in DBINDX
	;	  references
	;
	; 03/09/09 - Pete Chenard
	;	     Modified CVTREF to correctly deal with table alias.
	;
	; 02/23/09 - Pete Chenard
	;	Modified CMPUTED section to correctly deal with table aliases.
	;
	; 11/13/2008 - RussellDS - CRs 36391/35741
	;	Modified use of substitute null character to set it up at the
	;	beginning of the exe() array so that it is determined at
	;	runtime, but with only one call.  This avoids problems in
	;	code generated for PSL that is distributed to Unicode
	;	environments.
	;
	; 06/06/2008 - RussellDS - CR30801
	;	Modified fsn section to call fsn^DBSDD to eliminate duplicate
	;	code.
	;
	;	Modified FUNC to replace use of ^USUB with getSf^UCCOLSF.
	;
	;	Modified CVTREF to remove call to ^MSG.  Causing problems with
	;	bootstrap.  Will eventually provide framework message handler.
	;
	;	Removed old revision history.
	;
	; 06/06/08 - Pete Chenard - CR34196
	;	* Modified to pass nod to DBSMEMO.  nod is
	;	  necessary to build the correct code to read the data from
	;	  the database.
	;
	; 10/26/07 - Pete Chenard CR30087
	;	* Replaced references to $$BYTECHAR^SQLUTL with 
	;	  $$BYTECODE^SQLUTL to eliminate runtime determination
	;	  of whether to use $C or $ZCH based on character set 
	;	  configuration.
	;
	; 07/16/07 - Pete Chenard - CR 28171
	;	     Eliminate references to $C(254)
	;
	; 03/28/07 - RussellDS - CR26386
	;	     Added support for archiving in LOAD section.
	;
	; 01/31/07 - Pete Chenard - 24953/25147
	;	     Modified addz2 section to deal with the situation where
	;	     2 or more computed columns have identical expressions.  Prior
	;	     to this, the code would only load the vsql(n) entry for the
	;	     first column, leading to an undefined error when the second
	;	     column is reference.
	;
	; 01/25/07 - Pete Chenard - 24901
	;	     Modified LOAD section to generate code for computed columns
	;	     in the correct order.  Computeds that reference other computeds in
	;	     the parameter list were sometimes not loaded in the correct order prior
	;	     to this change (they were loaded in alphabetic order rather than 
	;	     the order in which they are referenced.
	;
	;----------------------------------------------------------------------
PARSE(ddexpr,X,cmp,fsn,frm,vdd,lvn,vsub,v255)	;public; Translate Dictionary Reference to MUMPS Expression
	;----------------------------------------------------------------------
	; Translate a DATA-QWIK dictionary reference to its corresponding
	; MUMPS expression.  The MUMPS expression is used in an assignment
	; statement to parse the selected field from a record held in
	; local storage.  Mapping is defined by the array name contained
	; in fsn(file) and the node, position, and subfield parameters
	; contained in vdd(ddref).
	;
	; If fsn(file), vdd(ddref) and/or X are not passed to this utility
	; their values will be loaded from [DBTBL1] and [DBTBL1D] respectively.
	;
	; KEYWORDS:	Database,Data Dictionary
	;
	; ARGUMENTS:
	;	. ddexpr	Dictionary Reference	/REQ/MECH=REF:RW
	;			See $$CVTREF^DBSDD for syntax
	;	. X		Parameter Record	/NOREQ/MECH=REF:RW
	;	. cmp(file,di)	MUMPS Computed Expr	/MECH=REF:WO
	;	. fsn(file)	File Attributes Record	/NOREQ/MECH=REF:RW
	;	. frm		List of valid files	/NOREQ/DEL=$C(44)
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;	. lvn		Local Variable Name	/NOREQ/MECH=REF:RW
	;	. vsub(ddref)	Literal Substition Valu	/NOREQ/MECH=REF:R
	;
	; RETURNS:
	;	. $$		MUMPS assignment expression
	;	. ER		(0,1) Error Flag
	;	. RM 		Error message message (If ER=1)
	;
	; EXAMPLES:
	;
	; W $$PARSE^DBSDD("DEP.BAL","",.cmp,.fsn,"",.vdd)
	; $P(DEP(51),""|"",1)"
	;
	;----------------------------------------------------------------------
	;
	S ER=0
	N file,di,nod,del,fld,sfd,ptr,typ,return,z,z1	; 04/22/1999
	;
	I $G(X)="" S X=$$DI(.ddexpr,.frm,.vdd,.fsn)
	E  S ddexpr=$$CVTREF(ddexpr,.frm,.fsn,.vdd)
	;
	I ER Q ""
	;
	I $D(vsub(ddexpr)) D  Q return
	.	;
	.	S return=vsub(ddexpr)
	.	I $D(v255(return)) S return="$S("_return_"="_$S($D(nullsymbl):nullsymbl,1:$$BYTECODE^SQLUTL(254))_":"""",1:"_return_")"
	;
	S file=$P(ddexpr,".",1),di=$P(ddexpr,".",2)
	;
	S nod=$P(X,"|",1),fld=$P(X,"|",21)
	S sfd=$P(X,"|",18),typ=$P(X,"|",11)
	S del=$P(fsn(file),"|",10)			; *** BC 08/29/96
	I del="",$P(X,"|",9)'="B" S del=124		; Default '|'
	;
	I nod="",fld="" S del=""
	;
	I sfd'="",$P(X,"|",1)["*" D  Q $$CMPUTED(return)
	.	S return=file_"."_$P($P(fsn(file),"|",2),",",+X)
	.	S return=$$FUNC()
	I $P(X,"|",1)["*" Q $S($G(lvn)="":di,1:$G(lvn))	; Access Key
	;
	I $P(X,"|",9)="M" D  Q z1  			; Memo field
	.	S z1=$$PARSE^DBSMEMO(file,nod)		; Computed expression
	.	; Remove [TABLE] syntax
	.	N ptr,remfid
	.	S remfid="["_file_"]"
	.	F  S ptr=$F(z1,remfid) Q:'ptr  D
	..		S z1=$E(z1,1,ptr-$L(remfid)-1)_$E(z1,ptr,999)
	.	S $P(X,"|",16)=z1			; put back in DD
	.	S z1=$$CMPUTED(z1)
	.	;
	I $P(X,"|",9)="B" S $P(X,"|",16)=$$PARSE^SQLBLOB(ddexpr) ; Binary
	I $P(X,"|",16)'="" Q $$CMPUTED($P(X,"|",16))
	;
	I nod'=+nod,$E(nod)'="""" D
	.	;
	.	N z
	.	S z=$P(fsn(file),"|",3),z=$P(z,",",$L(z,","))
	.	S nod=$S(z=nod:" ",1:""""_nod_"""")
	;
	S return=$P($G(fsn(file,nod)),"|",1)
	I return="" D lodnod(file,nod,.fsn) S return=$P(fsn(file,nod),"|",1)
	;
	; *** 09/03/98 Removed to correct nested computed expression error
	;
	;;;I $G(lvn)'="" S return=lvn			; Substitute lvn
	;
	Q $$FUNC()
FUNC()	; Apply MUMPS functions to array reference
	;
	I del S return="$P("_return_","_$S(del<32:"$C("_del_")",1:""""_$C(del)_"""")_","_$S(fld:fld,1:1)_")"
	;
	I sfd'="",$TR(sfd,"~0")'="" D
	.	;
	.	N sft,sfd1,sfd2,sfp
	.	S sft=$P(sfd,"~",1),sfd1=$P(sfd,"~",2),sfd2=$P(sfd,"~",3),sfp=$P(sfd,"~",4)
	.	S return="$$getSf^UCCOLSF("_return_","""_sft_""","""_sfd1_""","""_sfd2_""","_+sfp_")"
	Q return
	;
	;----------------------------------------------------------------------
CMPUTED(cmpin)	; Decode computed data items
	;----------------------------------------------------------------------
	;
	new atom,cmpinuc,cmputed,ddref,dels,expr,NS,ptr,return,tok,val,x,z
	;
	if $D(cmp(file,di)) do  quit return
	.	set return=$P(cmp(file,di),"=",1)
	.	if $E(return,1,2)="S " set return=$E(return,3,999)
        ;
	; Do not allow set or do in computed
	set cmpinuc=$$UPPER^UCGMR(cmpin)
	if $E(cmpinuc,1,2)="S "!($E(cmpinuc,1,2)="D ") do  quit ""
	.	set ER=1
	.	; Invalid computed data item = 'di'
	.	set RM=$$^MSG(8316,$$^MSG(595),file_"."_di)
	;
        set cmputed=$$TOKEN^%ZS(cmpin,.tok),return="",ER=0
        set dels="[]+-*/\#_'=><\*(),!&:?",ptr=0,ER=0
        ;
	; Build the M expression
	for  do  quit:(ptr=0)!ER
	.	;
	.	set atom=$$ATOM^%ZS(cmputed,.ptr,dels,tok,1) if ER quit
	.	;
	.	; Handle pattern match operations
	.	if atom="?" do  quit
	..		new origptr,pattern,z
	..		set origptr=ptr
	..		for ptr=ptr+1:1 quit:ptr>$L(cmputed)  set z=$E(cmputed,ptr) quit:'(z?1N!(z=".")!(z?1A)!($A(z)=0))
	..		set ptr=ptr-1
	..		set pattern=$E(cmputed,origptr,ptr)
	..		set return=return_pattern
	.	;
	.	if dels[atom set return=return_atom quit
	.	if $E(atom)="%",$D(^STBL("SYSKEYWORDS",atom)) set return=return_$p(^(atom),"|",1) quit
	.	if $A(atom)=0 set return=return_$$UNTOK^%ZS(atom,tok) quit
	.	if $E(atom)="$" set return=return_atom quit
	.	if $$isNum^UCGM(atom) set return=return_atom quit
	.	;
	.	; Shoud be column reference at this point
	.	; Invalid Table Value (if not this table)
	.	N tbl
	.	S tbl=$S($D(vAlias(file)):vAlias(file),1:file)
	.	if '$D(^DBTBL("SYSDEV",1,tbl,9,atom)) set ER=1,RM=$$^MSG(7194) quit
	.	;
	.	; Parse the column
	.	set ddref=file_"."_atom
	.	set val=$$PARSE(.ddref,"",.cmp,.fsn,.frm,.vdd,.lvn,.vsub) quit:ER
	.	set return=return_val
	.	if $$SIMPLFUN(val) quit
	.	;
	.	if $G(cmp(file))="" set cmp(file)=atom quit
	.	if ","_cmp(file)_","'[(","_atom_",") set cmp(file)=atom_","_cmp(file)
	;
	if ER quit ""
	set return=$$UNTOK^%ZS(return,tok)
	if $$SIMPLFUN(return) quit return
	set x=$$UPPER^UCGMR($E(return,1,3))
	if x="D "!(x="DO ") set cmp(file,atom)=return quit di
	set lvn=$S($G(fsn)="":di,1:$$getvar(.fsn))
	set cmp(file,di)="S "_lvn_"="_return
	quit lvn
	;
	;----------------------------------------------------------------------
FINDINAM(X,ptr)	;public; Find the next data item in a string
	;----------------------------------------------------------------------
	; Will return the next element within the string X from the position
	; ptr that matches a valid data item syntax.  The data item syntaxes
	; that are supported are FID.DI [FID]DI and [LIB,FID]DI.  Valid
	; dictionary syntax is required (i.e., a leading Alpha or %) for
	; filenames and data items.  Found elements are not verified. 
	;
	; KEYWORDS:	Parsing,Data Dictionary
	;
	; ARGUMENTS:
	;	. X		Input String		/REQ/TYP=T
	;	. ptr		Current pointer Locat	/NOREQ/MECH=REF:RW
	;
	; RETURNS:
	;	. $$		Dictionary Element
	;
	; EXAMPLE:
	;
	; S ptr=0,X="This is a [DEP]BAL, []BAD and LN.IRN test"
	; W $$FINDINAM^SQLDD(X,.ptr)
	; "[DEP]BAL"
	; W $$FINDINAM^SQLDD(X,.ptr)
	; "LN.IRN"
	; W $$FINDINAM^SQLDD(X,.ptr)
	; ""
	;----------------------------------------------------------------------
	;
	N s1,s2,chrldr,chrtbl,ptrz,ddref,y
	S y=0			; *** BC - 03/09/94 Check for comment field
	F  S y=$F(X,";",y) Q:y=""  I $L($E(X,1,y-2),"""")#2 Q
	I y S X=$E(X,1,y-2)
	;		
	I '$G(ptr) S ptr=1
	;
	S s1=ptr,s2=ptr
	;
	; chrldr = valid first characters for file and data item names
	; chrtbl = valid other characters for file and data item names
	;
	S chrldr="%ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	S chrtbl="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	;
FINDL	; Return linetag if found item is not legal
	;
	F  S s1=$F(X,"[",s1)  Q:$L($E(X,1,s1-1),"""")#2
	F  S s2=$F(X,".",s2)  Q:$L($E(X,1,s2-1),"""")#2
	;
	I s1=0,s2=0 S ptr=$L(X) Q ""
	;
	I s1 S ddref="" D  I ddref'="" S ptr=ptrz-1 I s1<s2!(s2=0) Q $TR(ddref," ")
	.	;
	.	I chrldr'[$E(X,s1) Q				; Invalid char
	.	;
	.	F ptrz=s1:1:$L(X) Q:chrtbl'[$E(X,ptrz)		; Scan for ,]
	.	I $E(X,ptrz)="," F ptrz=ptrz+1:1:$L(X) Q:chrtbl'[$E(X,ptrz)
	.	I $E(X,ptrz)'="]"!(ptrz=$L(X)) Q
	.	I chrldr'[$E(X,ptrz+1) Q			; Invalid dinam
	.	F ptrz=ptrz+2:1:$L(X)+1 Q:chrtbl'[$E(X,ptrz)&($$VLDUNDER($E(X,ptrz-1,ptrz+1)))
	.	S s1=s1-1,ddref=$E(X,s1,ptrz-1)
	;
	I s2 S ddref="" D  I ddref'="" Q $TR(ddref," ")
	.	;
	.	I s2'<$L(X) Q
	.	I chrldr'[$E(X,s2) Q				; Invalid Dinam
	.	I chrtbl'[$E(X,s2-2) Q				; Invalid file
	.	;
	.	S ptrz=s2-3
	.	F s2=s2+1:1:$L(X)+1 Q:chrtbl'[$E(X,s2)&($$VLDUNDER($E(X,s2-1,s2+1)))
	.	F ptrz=ptrz:-1:0 Q:chrtbl'[$E(X,ptrz)&($$VLDUNDER($E(X,ptrz-1,ptrz+1)))
	.	S ptr=s2-1					; FRS 08/16/93
	.	I chrldr'[$E(X,ptrz+1) Q			; Invalid 1st
	.	I ptrz,".?"[$e(X,ptrz) Q			; Pattern Match
	.	I "_(,"[$E(X,ptrz) S ptrz=ptrz+1
	.	S ddref=$E(X,ptrz,s2-1)			; RC 02/03/93
	;
	I s1=0 S s1=$L(X)
	I s2=0 S s2=$L(X)
	;
	G FINDL
	;
VLDUNDER(X); 	; Validate underscore
	;
	I X?1A1"_"1A Q 0
	I X?1A1"_"1N Q 0
	I X?1N1"_"1N Q 0
	I X?1N1"_"1A Q 0
	Q 1
	;----------------------------------------------------------------------
SIMPLFUN(X)	; Parse String & Determine if it contains a Do or Extrinsic
	;----------------------------------------------------------------------
	;
	I $E(X)="$",$E(X,2)="$" Q 0
	I $TR(X," ^","")'=X Q 0
	Q 1
	;
	;----------------------------------------------------------------------
DI(ddexpr,frm,vdd,fsn)	;public; Return Dictionary Record from [DBTBL1D]
	;----------------------------------------------------------------------
	; Returns a dictionry record from [DBTBL1D].  Also place it into
	; vdd(ddref) for subsequent access - Looks for existence in vdd
	; first.
	;
	; KEYWORDS:	Data Dictionary
	;
	; ARGUMENTS:
	;	. ddexpr	Dictionary Reference	/REQ/MECH=REF:RW
	;			See $$CVTREF^DBSDD for syntax
	;	. frm		List of valid files	/NOREQ
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;
	; RETURN:
	;	. $$		Dictionary Record
	;			NOD,LEN,DFT,DOM,TBL,PTN,XPO,XPR,TYP,DES,ITP,
	;			MIN,MAX,DEC,REQ,CMP,FCR,OFS,SIZ,DEL,POS,RHD,
	;			MNT,CNV,LTD,UID,MDD
	;
	;
	;	. ER		(0,1) Error Flag
	;	. RM		Error message message (If ER=1)
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	S ddexpr=$$CVTREF(ddexpr,.frm,.fsn,.vdd) I ER Q ""
	Q vdd(ddexpr)
	;
	;----------------------------------------------------------------------
CVTREF(ddref,frm,fsn,vdd)	;public; Convert dictionary references to LIB.FID.DI
	;----------------------------------------------------------------------
	; Verifies dictionary elements against the dictionary array or
	; Data dictionary DBTBL1D.
	;
	; KEYWORDS:	Dictionary,Parsing
	;
	; ARGUMENTS:
	;	. ddref		Dictionary Reference	/REQ/MECH=REF:R
	;	. frm		List of valid files	/NOREQ/DEL=$C(44)
	;	. fsn(file)	File Attributes Record	/NOREQ/MECH=REF:RW
	;	. vdd(ddref)	LIB.FID Base		/NOREQ/MECH=REF:RW
	;
	; RETURN:
	;	. $$		LIB.FID.DI
	;	. ER		(0,1) Error Flag
	;	. RM		Error message message	/COND
	; 
	; EXAMPLE:
	;
	;----------------------------------------------------------------------
	N tmpalias
	S ER=0
	;
	I ddref["""" S ddref=$$QSUB^%ZS(ddref)
	I ddref="" D ERROR("Invalid data item name - "_ddref) Q ""
	;
	N alias,f
	;
	S f=0
	I $L(ddref,".")=1 D
	.	;
	.	I $L($G(frm),",")=1 S (alias,tmpalias)=$G(frm) S:$D(vAlias(tmpalias)) tmpalias=vAlias(tmpalias) Q
	.	;
	.	N I
	.	F I=1:1:$L(frm,",") D  Q:f>0
	..		S (alias,tmpalias)=$P(frm,",",I)	;
	..		I $D(vAlias(tmpalias)) S tmpalias=vAlias(tmpalias)
	..		I $$VER(alias,ddref,.fsn,.vdd) S f=f+1
	..		E  S alias=""
	;
	E  D
	.	S (alias,tmpalias)=$P(ddref,".",1)
	.	S ddref=$P(ddref,".",2)
	.	I $D(vAlias(tmpalias)) S tmpalias=vAlias(alias)
	;
	I 'f,'$$VER(alias,ddref,.fsn,.vdd) D ERROR("Invalid data item name - "_tmpalias_"."_ddref) ; *** 12/18/97
	I ER=0,$g(frm)'="",'$$CONTAIN(frm,alias) D ERROR("Invalid file name "_ddref)
	;
	Q alias_"."_ddref
	;
	;----------------------------------------------------------------------
VER(alias,di,fsn,vdd)	;public; Verify the Existence of a reference
	;----------------------------------------------------------------------
	; Returns the truth flag of the existence of a dictionary element
	; reference in the table DBTBL1D.
	;
	; KEYWORDS:	Data Dictionary
	;
	; ARGUMENTS:
	;
	;	. ddexpr	Dictionary Reference	/REQ/MECH=REF:RW
	;			See $$CVTREF^DBSDD for syntax
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;	. fsn(file)	File Header array	/NOREQ
	;
	; RETURNS:
	;	. $$           Exists (1) or Not (0)  /TYP=L
	;
	; EXAMPLES:
	; W $$VER^DBSDD("DEP","BAL")
	; 1
	; W $$VER^DBSDD("DOESN'T","EXIST")
	; 0
	;
	I $G(alias)=""!($G(di)="") Q 0
	;
	I '$D(fsn(alias)) D fsn(.fsn,alias) I ER D ERROR(.RM) Q 0
 	;
        N ddref,lib,fid,ret
        S lib=$P(fsn(alias),"|",11)
 	;
	I lib["." S fid=$P(lib,".",2),lib=$P(lib,".",1)
	E  S fid=alias
	;
	S ddref=alias_"."_di
	I $D(vdd(ddref))
	E  I $D(^DBTBL("SYSDEV",1,fid,9,di)) S vdd(ddref)=^(di)
	S ret=$T
	; Turn off null indicator flag if not $ or N data types, or if column
	; is tied to a lookup table.
	I ret,"$N"'[$P(vdd(ddref),"|",9)!($P(vdd(ddref),"|",5)'="") S $P(vdd(ddref),"|",31)=""
	I '$$rdb^UCDB(fid) Q ret
	;
	N ER,d,pos,t
	S t=alias,d=di
	D MAP^DBMAP(%DB,.t,.d,.pos,.ER)
	S $P(vdd(alias_"."_di),"|",21)=$G(pos)
	I '$G(ER) Q 1
	E  Q 0
	;
	;----------------------------------------------------------------------
CONTAIN(list,entry)	; See if entry is contained in list
	;----------------------------------------------------------------------
	;
	Q (","_list_",")[(","_entry_",")
	;
	;----------------------------------------------------------------------
gbl(file,fsn)	; Return global reference
	;----------------------------------------------------------------------
	;
	I $D(fsn(file)) Q $P(fsn(file),"|",2)
	;
	N x
	S x=$P($G(^DBTBL("SYSDEV",1,file,100)),"|",1)
	I $P(x,"(",2)="""*""" S x=$P(x,"(",1)_"("
	Q x
	;
	;----------------------------------------------------------------------
fsn(fsn,file,vdd)	;public; Add a file header to the fsn(file) array
	;----------------------------------------------------------------------
	; This subroutine loads file information into a record (fsn) to be used
	; by compilers and other utilities that require included information.
	;
	D fsn^DBSDD(.fsn,file,.vdd)
	;
	Q
	;
	;----------------------------------------------------------------------
TABLE(file)	;public; Return lookup syntax from file header page
	;----------------------------------------------------------------------
	;	. file		File Name		/REQ/TBL=[DBTBL1]
	;----------------------------------------------------------------------
	;
	I $G(file)="" S ER=1,RM=$$^MSG(5285) Q ""
	; Invalid File Name
	I '$D(^DBTBL("SYSDEV",1,file)) S ER=1,RM=$$^MSG(1337,file) Q ""
	;
	N f10,tbl1,tbl2
	;
	S f10=$G(^DBTBL("SYSDEV",1,file,10))
	s tbl1=$P(f10,"|",6),tbl2=$P(f10,"|",9)
	Q (tbl1_tbl2)
	;
	;----------------------------------------------------------------------
KEYS(file,acckeys)	; Return 'true' key data items from MUMPS keys
	;----------------------------------------------------------------------
	N I,key,keys
	;
	I $G(acckeys)="" S acckeys=$G(^DBTBL("SYSDEV",1,file,16))
	S keys="" 
	F I=1:1:$L(acckeys,",") D
	.	S key=$P(acckeys,",",I)
	.	I key=+key!("""$"[$E(key)) Q	; ignore literal keys
	.	S keys=keys_","_key
	;
	Q $E(keys,2,$L(keys))
	;
	;----------------------------------------------------------------------
lodnod(file,nod,fsn)	; Get Local variable name for file,field
	;----------------------------------------------------------------------
	;
	N lvn,rectyp,z
	;
	I '$D(fsn(file)) D fsn(.fsn,file) 	; Get file short name
	S lvn=$P(fsn(file),"|",1)		; Local array reference
	S rectyp=$P(fsn(file),"|",4)		; Record type
	;
	I lvn="" S lvn=$$getvar(.fsn) ;		Named variable assigned
	E  D
	.	N z
	.	S z=$E(lvn,$L(lvn))
	.	I " "[nod S:"(,"[z lvn=$E(lvn,1,$L(lvn)-1) S:z="," lvn=lvn_")" Q
	.	E  I "(,"[z S lvn=lvn_nod_")" Q
	.	I z=")" Q	
	.	S lvn=lvn_nod
	;
	S fsn(file,nod)=lvn
	Q
	;
	;----------------------------------------------------------------------
getvar(fsn)	; Generate next unique variable
	;----------------------------------------------------------------------
	;
	N lvn
	I fsn["(" S lvn=fsn_($O(@(fsn_(1E18)_")"),-1)+1)_")",@lvn="" Q lvn
	;
	N I
	F I=1:1:$L(fsn)+1 Q:$E(fsn,I)?1N
	S fsn=$E(fsn,1,I-1)_($E(fsn,I,$L(fsn))+1)
	Q fsn
	;
	;----------------------------------------------------------------------
PCODE(X,dilist,cmp,fsn,vsub,vdd)	;public; Parse Code for macro {} substitution
	;----------------------------------------------------------------------
	; Parses input string for the sentinal characters {fid.di} and replaces
	; inbedded contents with parsed dictionary expression.
	;
	; KEYWORDS:	Database,Data Dictionary,Parsing
	;
	; RELATED: PARSE^DBSDD,$$LOAD^DBSDD
	;
	; ARGUMENTS:
	;	. X		String to Parse		/REQ/MECH=VAL
	;	. dilist	List of Found Data Items
	;	. cmp(file,di)	Computed Expressions	/NOREQ/MECH=REF:R
	;	. cmp		Computed Data Expressions
	;	. fsn(file)	File Headers
	;	. vsub(ddref	Library.file.di
	;	. vsub(ddref)	Literal Substitution	/NOREQ/MECH=REF:R
	;	. vdd(ddref	LIB.FID.DI Reference  
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;
	; RETURNS:
	;	. $$		Parsed String with replacement
	;	. ER		(0,1) Error Flag
	;	. RM		Error message message (If ER=1)
	;
	; EXAMPLES:
	; W $$PCODE^DBSDD("I {DEP.BAL}>100")
	; I $P(DEP(51),"|",1)>100
	;
	N Y,Yz,NS,ddref,lvn
	S Y=0,Yz=0,dilist=""
	;
	F  S Y=$F(X,"{",Y) Q:Y=0  I $L($E(X,1,Y-1),"""")#2 DO
	.	F  S Yz=$F(X,"}",Y) Q:Yz=0  I $L($E(X,1,Yz-1),"""")#2 Q
	.	I Yz=0 Q
	.	S ddref=$E(X,Y,Yz-2),lvn=""
	.	I ddref[":" S lvn=$P(ddref,":",2),ddref=$P(ddref,":",1)
	.	S NS=$$PARSE(.ddref,"",.cmp,.fsn,"",.vdd,lvn,.vsub) Q:ER
	.	S X=$E(X,1,Y-2)_NS_$E(X,Yz,9999),Y=Y+$L(NS)
	.	S dilist=dilist_","_ddref
	;
	S dilist=$E(dilist,2,$L(dilist))
	I ER Q ""
	Q X
	;
	;----------------------------------------------------------------------
LOAD(file,fsn,array,nlv,fma,frm,vsub,cmp,new)	;public; Generate Database Load Executable Code
	;----------------------------------------------------------------------
	; Builds MUMPS executable code used to load records from the physical
	; MUMPS database and store them in local variables and arrays.
	;
	; KEYWORDS:	Database,Data Dictionary
	;
	; RELATED: PARSE^DBSDD
	;
	; ARGUMENTS:
	;	. file		File Name		/REQ/MECH=REF:R
	;	. fsn(file)	File Attributes Record	/REQ/MECH=REF:R
	;	. fsn(file,nod)	Nodes to load		/REQ/MECH=REF:R
	;			The nod level in this array is automatically
	;			accumulated by calling PARSE^DBSDD
	;
	;	. array		Last Sequence #		/MECH=REF:RW
	;	. array(array)	MUMPS Code Returned	/MECH=REF:W
	;			This sequential array contains the
	;			MUMPS code that, when executed, loads
	;			database records into local arrays
	;
	;	. nlv		Ignore Local Array 	/NOREQ/TYP=L/DFT=N
	;			I nlv=1 S code="S var=$G(^GBL(key))"
	;			E  code="I $D(loc(1))#2=0 S loc(1)=$G(..."
	;
	;	. fma(asg)	Mask Previous Assig	/NOREQ/MECH=REF:RW
	;			This array is used to store previous
	;			assignments to prevent duplicate loading
	;
	;	. frm		File list		/NOREQ/DEL=44/MECH=VAL
	;			The global name defaults from the file
	;			header in fsn(file) if it is not provided
	;
	;	. vsub(ddref	Library.file.di
	;	. vsub(ddref)	Literal Substitution	/NOREQ/MECH=REF:R
	;			If an access key has a literal value as
	;			defined in this array, the literal value
	;			will replace the key variable.
	;
	;	. cmp(file,di)	Computed Expressions	/NOREQ/MECH=REF:R
	;	. new		List of named variables	/NOREQ/MECH=REF:RW
	;
	;
	; EXAMPLES:
	;
	; fsn("DEP")="DEP(|^ACN(CID|CID|10|0|^DEPFILE(%O)||||124|SYSDEV"
	; fsn("DEP",50)="DEP(50)"
	; fsn("DEP",51)="DEP(51)"
	; D LOAD^DBSDD("DEP",.fsn,.array)
	; ZWR array
	; array=2
	; array(1)="I $D(DEP(50))#2=0 S DEP(50)=$G(^ACN(CID,50))"
	; array(2)="I $D(DEP(51))#2=0 S DEP(51)=$G(^ACN(CID,51))"
	;----------------------------------------------------------------------
	;
	I '$D(fsn(file)) Q
	;
	N di,expr,gbl,ifflg,ifset,lvn,nod,z,zcmp
	;
	S gbl=$P(fsn(file),"|",2)
	I $D(vsub) D
	.	S gbl=$P(gbl,"(",1)_"("_$$LITKEY($P(gbl,"(",2,99),.vsub)
	.	I $P($G(vsql("ARCH",file)),"|",5)'="" S gbl="^|"_$P(vsql("ARCH",file),"|",5)_"|"_$E(gbl,2,$L(gbl))
	;
	S ifflg=$D(join(file))#2,ifset=""
	I ifflg,$P(fsn(file),"|",3)="" s ifflg=0	; File without access keys
	I ifflg D IFNUL(file,join(file),.fsn,.vsub,.ifflg)
	;
	S di="",ifset="",nod=""
	;
	; If archive file and using an index and we have to load data from nodes
	; need to add code to get correct archive file
	I $P($G(vsql("ARCH",file)),"|",6),$O(fsn(file,""))'="" D
	.	N archinfo
	.	S archinfo=vsql("ARCH",file)
	.	S array=$O(array(""),-1)+1
	.	S array(array)="S "_$P(archinfo,"|",5)_"="_$P(archinfo,"|",7)
	;
	F  S nod=$O(fsn(file,nod)) Q:nod=""  D addz1(file,nod,.array,.fsn,.nlv,.fma,gbl,.new,ifflg,.ifset)
	;
	; Computeds need to be loaded in the correct order to prevent undef errors.  This
	; block builds a temp array keyed by the vsql(n) subscript that each computed column
	; references.  The M code that gets generated then uses that information to generate
	; the code in the correct order.  Entries in the cmp array look like this:
	; S vsql(n)=$$LABEL^TRN(...)
	F  S di=$O(cmp(file,di)) Q:di=""  D
	.	N zexpr,zsub
	.	S zexpr=$E($P(cmp(file,di),"=",1),3,99)  ;vsql(n)
	.	Q:zexpr'["vsql("
	.	S zsub=$P($P(zexpr,")",1),"(",2)
	.	S zcmp(zsub)=file_","_di
        ;
	N i S i=""
	F  S i=$O(zcmp(i)) Q:i=""  D	; Computed's
        .       S file=$P(zcmp(i),",",1)
        .       S di=$P(zcmp(i),",",2) 
	.	S expr=cmp(file,di),lvn=$P(expr,"=",1),expr=$P(expr,"=",2,99)
	.	I $E(lvn,1,2)="S " S lvn=$E(lvn,3,$L(lvn))
	.	I $D(vsub(file_"."_lvn)) S lvn=vsub(file_"."_lvn)
	.	D addz2(file,di)
	;
	I ifflg D
	.	;
	.	I array=ifflg K array(ifflg) S array=array-1
	.	E  I ifset'="" S array(ifflg)=array(ifflg)_" "_ifset
	Q
	;
	;----------------------------------------------------------------------
addz1(file,nod,array,fsn,nlv,fma,gbl,new,ifflg,ifset)	; Add this nod to the loadable executable string
	;----------------------------------------------------------------------
	;
	N expr,lvn,lex,null,z
	I $D(nullsymbl) S null=nullsymbl
	E  S null=$$BYTECODE^SQLUTL(254)
	S lvn=$P(fsn(file,nod),"|",1)			; Local storage
	S lex=$P(fsn(file,nod),"|",2)			; Opt. Load expression
	;
	I lex="" D					; Normal Global Load
	.	;
	.	S expr=gbl
	.	I nod=" " S expr=expr_")" Q		; Data on Bottom key
	.	I $P(expr,"(",2)'="" S expr=expr_","
	.	S expr=expr_nod_")"
	;
	E  Q:$D(fma(lex))  D
	.	;					; Already loaded
	.	N I,bk,cnod,ddref,dilist
	.	;
	.	S fma(lex)=file				; 11/24/98 BC
	.	S cnod=nod
	.	S expr=$$PCODE(lex,.dilist,.cmp,.fsn,.vsub,.vdd)
	.	F  Q:expr'["flvn"  S expr=$P(expr,"flvn",1)_lvn_$P(expr,"flvn",2,999)
	.	;
	.	F I=1:1:$L(dilist,",") D
	..		;
	..		S ddref=$P(dilist,",",I)
	..		S nod=$P(vdd(ddref),"|",1) I nod["*" Q
	..		S bk=$P(fsn(file),"|",3),bk=$P(bk,",",$L(bk,","))
	..		I nod=bk S nod=" "
	..		I nod=cnod Q
	..		D addz1(file,nod,.array,.fsn,.nlv,.fma,gbl,.new,.ifflg,.ifset)
	D addz2(file,"")
	Q
	;
addz2(file,di)	;Build the line of M code based on lvn and expr
	;
	; The fma array is used to track expressions that have already been
	; parsed so we don't parse them multiple times.  Since a table can
	; contain 2 or more computed columns that reference the same expression
	; (see HIST.ITC6 and HIST.ITC12), we need to track this at a more granular
	; level than the expression itself.  We need to track it based on expression
	; and the column name (note only computed expressions will have a column 
	; name assigned here.  Other expressions are for loading nodes from disk
	; and do not reference column names specifically.
	I di="",$D(fma(expr,file)) Q
	I di'="",$D(fma(expr,file,di)) Q
	;
	; If expr has already been assigned an lvn, replace expr with that lvn
	S fma(expr,file,di)=""
	I $D(fma(expr,file))#2 S expr=fma(expr,file)
	E  S fma(expr,file)=lvn
	;
	I $E(expr)="^" S expr="$G("_expr_")"		; Protect UNDEFINED
 	S expr="S "_lvn_"="_expr			; Assign to local
	;
	I $G(ifflg) S expr="E  "_expr,ifset=$S($G(ifset)="":"S ",1:ifset_",")_lvn_"="""""
	I '$G(nlv) S expr="S:$D("_lvn_")#2=0 "_$E(expr,3,$L(expr))
	;
	I $G(new)="" S new=$P(lvn,"(",1)
	E  I '$$CONTAIN(new,$P(lvn,"(",1)) S new=new_","_$P(lvn,"(",1)
	;
	S array=$O(array(""),-1)+1
	S array(array)=expr
	Q
	;
	;----------------------------------------------------------------------
IFNUL(file,pfile,fsn,vsub,ifflg)	;private; Build checking for join keys
	;----------------------------------------------------------------------
	;
	I '$D(fsn(pfile)) D fsn(.fsn,pfile) Q:ER
	;
	N I,ddref,expr,key,keys1,keys2,null
	;
	I $D(nullsymbl) S null=nullsymbl
	E  S null=$$BYTECODE^SQLUTL(254)
	;
	S keys1=$P(fsn(pfile),"|",3),keys2=$P(fsn(file),"|",3)
	;
	S key=$P(keys2,",",$L(keys2,","))
	S ddref=file_"."_key
	I $$CONTAIN($G(join(ddref)),pfile) S ifflg=0 Q
	I '$D(vsub(ddref)) Q
	;
	S array=$O(array(""),-1)+1
	S array(array)="I "_vsub(ddref)_"="_null
	I $D(join(file,1)),join(file,1)'=vsub(ddref) S array(array)=array(array)_"!("_join(file,1)_"="""")"
	S ifflg=array
	Q
	;
	;----------------------------------------------------------------------
LITKEY(keys,vsub)	; Substitute literal keys for variables
	;----------------------------------------------------------------------
	;
	N I,comma
	;
	S comma=0
	;
	F I=1:1:$L(keys,",") D
	.	;
	.	S z=file_"."_$P(keys,",",I+comma)		; *** 02/08/96
	.	I $D(vsub(z))#2=0 Q
	.	S $P(keys,",",I+comma)=vsub(z)			; ***
	.	I vsub(z)["," S comma=comma+$L(vsub(z),",")-1	; Extra comma
	;
	Q keys
	; 
MASK()	Q "NOD,LEN,D,DOM,,,,,TYP,DES,ITP,,,DEC,REQ,CMP,FCR,SFD,SIZ,DEL,POS,RHD,MNT,CNV,LTD,USER,MDD,VAL4EXT"
	;
	;----------------------------------------------------------------------
GETSEQ(NAMESPAC)	;public; Return unique sequence number
	;----------------------------------------------------------------------
	; Returns either a globally unique general sequence number (if NAMESPAC
	; not provided, or a globally unique sequence number based on NAMESPAC.
	;
	; NOTE that the current implementation ignores NAMESPAC, and always
	; returns the general sequence number.  This number is currently a 16
	; digit number based on date, time, and process ID.  There are
	; restrictions on this number - (1) only one per second per process is
	; unique, so the requesting process may need to check uniqueness and
	; ask for a new number; (2) the sequence numbers are close to ordered,
	; however two processes requesting at the same time will get numbers
	; ordered by their process ID.
	;
	; ARGUMENTS:
	;	. NAMESPAC	Name space to use for	/TYP=T/NOREQ/MECH=VAL
	;		        generation of sequence
	;		        number.  Each name space
	;		        provides a different set
	;		        sequence numbers.
	;
	; RETURN:
	;	. $$		Sequence number		/TYP=N
	;
	quit $P($H,",",1)_$E($P($H,",",2)+100000,2,6)_$E(($J#1000000)+1000000,2,7)
	;
	;----------------------------------------------------------------------
LIST(file,skipcmp,skipsf)	; public; Return data items in DATA-QWIK file definition field order 
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. file		DATA-QWIK file name	/REQ/TYP=U/MECH=REFVAL
	;	. skipcmp	Excude computed items	/TYP=L/DEF=0/MECH=REFVAL
	;       . skipsf        Exclude Sub-field       /TYP=L/DEF=0/MECH=REFVAL
	; 
	; RETURNS:
	;	. ER		Error Flag		/NOREQ/TYP=N
	;	. RM		Error message		/NOREQ/TYP=T
	;	. $$		List of data items 
	;
	; EXAMPLE:
	;
	; W $$LIST^DBSDD("DMJ")
	;
	; TJD,DATETIME,CID,TSEQ,CC,ITC,ETC,TAMT,EFD,TLO,TSO,TCMT,CDT,TIME,BRCD,TRC,UID,CRCD
	; ,RATE,CHKTYP,MULT,BSEAMT,CUSTCD,TRESREF,GLSC,BCRCD
	;
	; W $$LIST^DBSDD("DMJ",1)
	;
	; TJD,DATETIME,CID,TSEQ,CC,ITC,ETC,TAMT,EFD,TLO,TSO,TCMT,CDT,TIME,BRCD,TRC,UID,CRCD
	; ,RATE,CHKTYP,MULT,BSEAMT,CUSTCD,TRESREF,GLSC,BCRCD,EFDCMP,ITC1,ITC10,ITC12,ITC6
	; ,ITC7,ITC8
	;
	;----------------------------------------------------------------------	  
	;
	N di,fid,i,k,key,keys,lib,libs,node,nullChar,on,pos,str,zdi
	;
	D fsn(.fsn,file) I $G(ER) Q ""
	;	
	S (node,pos,di,str,keys)=""
	S keys=$P(fsn(file),"|",3)_",",lib=$P(fsn(file),"|",11),fid=file
	;
	S nullChar=$$BYTECHAR^SQLUTL(254)
	F i=1:1:$L(keys,",") S di=$P(keys,",",i) I $E(di)="%" S $P(keys,",",i)=""""_di_""""
	;
	F  S node=$O(^DBINDX(lib,"STR",fid,node)) Q:node=""  D
	.	I $G(skipcmp),node=nullChar Q			; Skip computeds
	.	I node'=nullChar,node?1n1"*" Q			; Skip access key
	.	F  S pos=$O(^DBINDX(lib,"STR",fid,node,pos)) Q:pos=""  D
	..		s on=0					; Indicator
	..		F  S di=$O(^DBINDX(lib,"STR",fid,node,pos,di)) Q:di=""  D
	...			;
	...			I $G(skipsf),$p(^DBTBL(lib,1,fid,9,di),"|",18)'="" Q	; Sub-field
	...			S zdi=di			; *** 09/20/95 BC
	...			I $E(di)="%" S zdi=""""_di_""""	; Non SQL syntax
	...			S str=str_zdi_",",on=1		; Used
	..							; Or default to first item
	..		I 'on s str=str_$O(^DBINDX(lib,"STR",fid,node,pos,""))_","
	I str="" Q $E(keys,1,$l(keys)-1)
	I keys="," S keys=""				; *** 10/04/95 BC
	Q keys_$E(str,1,$L(str)-1)
	;
	;----------------------------------------------------------------------
RECFST(exe,hdg,frm,sel,fmt,fsn,fma,cmp,vsub,vdd)	; Fast record load 
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N I,col,del,expr,file,nod,qwt,savptr,seq,z,zexe
	;
	S qwt=$P(fmt,"|",2),del=$P(fmt,"|",3)
	I qwt'=""!del="" Q				; Not optimizable
	;
	I $G(hdg)="" S hdg=$P(fmt,"|",6) I hdg="" S hdg=1
	;
	I hdg'=1,hdg'=5 Q				; Not optimizable
	;
	S col=1 I hdg=5 S hdg(1)=frm,col=2
	;
	F I=1:1:$L(frm,",") D  Q:ER
	.	;
	.	S file=$P(frm,",",I)
	.	D FSTFIL Q:ER
	.	S savptr=$O(exe(""),-1)
	.	D LOAD(file,.fsn,.exe,1,.fma,frm,.vsub,.cmp,.new)
	;
	; *** 01/13/95 BC - Pack exe() array
	;
	S z=savptr F  S z=$O(exe(z)) Q:z=""  S zexe(z)=exe(z) K exe(z)
	;
	S z="",seq=savptr+1 F  S z=$O(zexe(z)) Q:z=""  D
	.	I '$D(exe(seq)) S exe(seq)=""
	.	I exe(seq)'="" s exe(seq)=exe(seq)_" "
	.	S exe(seq)=exe(seq)_zexe(z)
	.	I $L(exe(seq))>256 S seq=seq+1
	I $G(exe(seq))'="" S seq=seq+1			; Save pointer
	S expr(-1)=expr("*") K expr("*")		; Access key
	S nod="" F  S nod=$O(expr(nod)) Q:nod=""  D
	.	I '$d(exe(seq)) S exe(seq)=""
	.	I $L(exe(seq))>256 S seq=seq+1,exe(seq)=expr(nod) Q
	.	S exe(seq)=exe(seq)_" "_expr(nod)
	S exe=$o(exe(""),-1)
	Q
	;
FSTFIL	; Individual file for fast load
	;
	N bk,di,fdel,keys,nod,nullChar,pos,seq,segment,strpos,z,zdel,zexpr,znod,zpos
	;
	I '$D(fsn(file)) D fsn(.fsn,file) Q:ER
	;
	S fdel=$P(fsn(file),"|",10)
	S keys=$P(fsn(file),"|",3),bk=$P(keys,",",$L(keys,","))
	S expr=""
	S zdel=",$C("_del_"),"				; ,$c(del),
	;
	F I=1:1:$L(keys,",") D				; Put access keys front
	.	;
	.	N NS,ddexpr,di
	.	S di=$P(keys,",",I)
	.	S ddexpr=file_"."_di
	.	I $D(vsub(ddexpr))#2 S NS=vsub(ddexpr)
	.	E  S NS=di
	.	;
	.	I expr="" S expr="S v="_NS
	.	E  S expr=expr_"_$C("_del_")_"_NS
	.	;
	.	S $P(sel,",",col)=di
	.	S $P(hdg(1),$C(del),col)=di
	.	S col=col+1
	;
	S expr("*")=expr_"_$C("_del_")"		; Delimiter after keys
	;
	S nod="",pos="",di=""
	S nullChar=$$BYTECHAR^SQLUTL(254)
	F  S nod=$O(^DBINDX("SYSDEV","STR",file,nod)) Q:nod=""  D
	.	;
	.	I nod=nullChar Q			; Null substitute
	.	I nod["*" Q				; Access Key
	.	I nod'?.N,nod'=bk Q			; Computed's
	.	;
	.	S znod=nod
	.	I nod'=+nod,$E(nod)'="""" S znod=$S(bk=nod:" ",1:""""_znod_"""")
	.	I '$D(fsn(file,znod)) D lodnod(file,znod,.fsn)
	.	;
	.	K segment S pos="",zpos=1,strpos=1,seq=1
	.	F  S pos=$O(^DBINDX("SYSDEV","STR",file,nod,pos)) Q:pos=""  D
	..		;
	..		Q:pos=nullChar				; Null substitute
	..		I zpos'=pos,pos?1N.N,pos'=1 D		; Not sequential
	...			;				; Save segment			
	...			I zpos-1=strpos S segment(seq)=strpos
	...		   	E  S segment(seq)=strpos_","_(zpos-1)
	...			S seq=seq+1,strpos=pos		; New segment
	..		S zpos=pos+1
	..		F  S di=$O(^DBINDX("SYSDEV","STR",file,nod,pos,di)) Q:di=""  D
	...			S $P(sel,",",col)=di
	...			S $P(hdg(1),$C(del),col)=di
	...			S col=col+1
	..		;
	.	S zexpr=$P(fsn(file,znod),"|",1)
	.	I zpos=1 S zpos=2 				; Expand field
	.	S expr="S $P("_zexpr_zdel_zpos_")="""""	
	.	;						; Pack segments
	.	I $D(segment) D  S expr=expr_","_zexpr_"="_$E(z,2,9999)
	..		I zpos-1=strpos S segment(seq)=strpos	; Last field
	..		E  S segment(seq)=strpos_","_(zpos-1)	; Last segment
	..		S z="",seq=0
	..		F  S seq=$O(segment(seq)) Q:seq=""  D
	...			I segment(seq)[",",+segment(seq)>$P(segment(seq),",",2) Q
	...			S z=z_"_$P("_zexpr_zdel_segment(seq)_")_$C("_del_")"
	.	;
	.	S expr=expr_" S v=v_"
	.	I del'=fdel S expr=expr_"$TR("
	.	S expr=expr_$P(fsn(file,znod),"|",1)
	.	I del'=fdel S expr=expr_",$C("_fdel_"),$C("_del_"))"
	.	S expr(znod)=expr
	;
	Q
	;
NOD(ddexpr,x,vdd)	Q $$FIELD(ddexpr,1,.x,.vdd) ; Array Node
LEN(ddexpr,x,vdd)	Q $$FIELD(ddexpr,2,.x,.vdd) ; Field Length
DFT(ddexpr,x,vdd)	Q $$FIELD(ddexpr,3,.x,.vdd) ; Default expression
TBL(ddexpr,x,vdd)	Q $$FIELD(ddexpr,5,.x,.vdd) ; Table lookup
PTN(ddexpr,x,vdd)	Q $$FIELD(ddexpr,6,.x,.vdd) ; Pattern Match
XPO(ddexpr,x,vdd)	Q $$FIELD(ddexpr,7,.x,.vdd) ; Post Processor
XPR(ddexpr,x,vdd)	Q $$FIELD(ddexpr,8,.x,.vdd) ; Pre Processor
TYP(ddexpr,x,vdd)	Q $$FIELD(ddexpr,9,.x,.vdd) ; Data Type
DES(ddexpr,x,vdd)	Q $$FIELD(ddexpr,10,.x,.vdd) ; Description
ITP(ddexpr,x,vdd)	Q $$FIELD(ddexpr,11,.x,.vdd) ; Internal Data Type
MIN(ddexpr,x,vdd)	Q $$FIELD(ddexpr,12,.x,.vdd) ; Minimum Value
MAX(ddexpr,x,vdd)	Q $$FIELD(ddexpr,13,.x,.vdd) ; Maximum Value
DEC(ddexpr,x,vdd)	Q $$FIELD(ddexpr,14,.x,.vdd) ; Decimal Precision
REQ(ddexpr,x,vdd)	Q $$FIELD(ddexpr,15,.x,.vdd) ; Required Flag
CMP(ddexpr,x,vdd)	Q $$FIELD(ddexpr,16,.x,.vdd) ; Cmputed MUMPS Express
FCR(ddexpr,x,vdd)	Q $$FIELD(ddexpr,17,.x,.vdd) ; Cmpression Reference
OFS(ddexpr,x,vdd)	Q $$FIELD(ddexpr,18,.x,.vdd) ; Offset Pointer	04/22/1999
SFD(ddexpr,x,vdd)	Q $$FIELD(ddexpr,18,.x,.vdd) ; Sub-field
ILN(ddexpr,x,vdd)	Q $$FIELD(ddexpr,19,.x,.vdd) ; Internal Length
DEL(ddexpr,x,vdd)	Q $$FIELD(ddexpr,20,.x,.vdd) ; Field Delimiter
POS(ddexpr,x,vdd)	Q $$FIELD(ddexpr,21,.x,.vdd) ; Field Position 
RHD(ddexpr,x,vdd)	Q $$FIELD(ddexpr,22,.x,.vdd) ; Report Header
MNT(ddexpr,x,vdd)	Q $$FIELD(ddexpr,23,.x,.vdd) ; Maintenance Flag 
CNV(ddexpr,x,vdd)	Q $$FIELD(ddexpr,24,.x,.vdd) ; Conversion Flag
LTD(ddexpr,x,vdd)	Q $$FIELD(ddexpr,25,.x,.vdd) ; Last Maintained
UID(ddexpr,x,vdd)	Q $$FIELD(ddexpr,26,.x,.vdd) ; Username
MDD(ddexpr,x,vdd)	Q $$FIELD(ddexpr,27,.x,.vdd) ; Master Dictionary
NUL(ddexpr,x,vdd)       Q $$FIELD(ddexpr,31,.x,.vdd) ; Null Vs. Zero Indicator
	;
	;----------------------------------------------------------------------
REQITEM(fid)	; Required Data Item 
	;----------------------------------------------------------------------
	Q $G(^DBTBL("SYSDEV",1,fid,102))
	; 
FIELD(ddexpr,loc,x,vdd)	; Return the value of a field
	;
	I loc'=+loc S loc=$L($P($$MASK,loc,1),",") I loc="" Q ""
	;
	I $G(x)="" S x=$$DI(ddexpr,"",.vdd,.fsn) I x="" Q ""
	Q $P(x,"|",loc)
	;
	;-----------------------------------------------------------------------
getValues(table,list,array)	; Return values based on input list
	;-----------------------------------------------------------------------
	;
	new att,i,n,nam,pos,x,z
	;
	for i=1:1:$L(list,",") do
	.	;
	.	set nam=$P(list,",",i)
	.	set pos=$L($P($$MASK,nam,1),",")
	.	if pos set pos(pos)=nam
	;
	if $D(pos)<10 quit
	;
	set di="",pos=""
	;
	for  set di=$O(^DBTBL("SYSDEV",1,table,9,di)) quit:di=""  do  
	.	;
	.	set x=^(di)
	.	for  set pos=$O(pos(pos)) quit:pos=""  do
	..		;
	..		set z=$P(x,"|",pos)
	..		if z'="" set array(table,pos(pos),z)=""
	;
	quit
	;
	;----------------------------------------------------------------------
ERROR(M)	; General Error Handler
	;----------------------------------------------------------------------
	;
	S ER=1,RM=$G(M)
