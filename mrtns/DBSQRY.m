DBSQRY	;PUBLIC;DATA-QWIK Query Parser
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/26/03 10:17:11 - CHENARDP
	;     ORIG: Frank Sanchez (2497) - Sometime in 1986
	;
	; This routine parses free-form user input by searching
	; for keywords and special symbols in order to validate
	; the query construction.  In prior versions, it would
	; construct the Q() array to be used to pass to DBSQRYA,
	; now obsolete, to be construct M executable code.
	;
	; KEYWORDS:	Parsing, DATA-QWIK
	;
	;   INPUTS:
	;	. X		String to parse		/REQ
	;	. %LIBS		DATA-QWIK Lirary	/REQ
	;	. NI		Query Line Number	/REQ
	;	. FILES		List of Files		/REQ
	;
	;  RETURNS:
	;	. ER	Error Indicator			/TYPE=T
	;
	;	. RM(line)	Return message	
	;			Error Message if ER=1, otherwise a descriptive
	;			interpretation of the parsed string
	;
	;	. Q(NI,#)	Intermediate record
	;	   		Exprlft|exprght||oprelat|oplogic|datatyp
	;			(Previously used by obsolete DBSQRYA)
	; EXAMPLE:
	; S X="DEP.BAL>200 OR DEP.CID=100"
	; D ^DBSQRY
	; ZWR
	; ER=0
	; Q(1,1)=$C(1)_"SYSDEV.DEP.BAL"_$C(1)_"|200||>|!|$"
	; Q(1,2)=$C(1)_"SYSDEV.DEP.CID"_$C(1)_"|100||=||N"
	;
	; EXAMPLE:
	; S X="DEP.BADITEM>200 OR DEP.CID=100"
	; D ^DBSQRY
	; ZWR
	; ER=1
	; RM(1)="DEP.BADITEM>200 OR DEP.CID=100"
	; RM(2)="    ^------INVALID DATA ITEM"
	;
	;---- Revision History -----------------------------------------------
	; 02/18/07 - RussellDS - CR25356
	;	     Eliminated use of obsoleted routine DBSQRYA.
	;
	;	     Pulled KEYWRD, COUNTP, and PAR sub-routines from DBSQRYA
	;	     into this code.
	;
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$UPPER^SCAUTL with $$UPPER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 08/10/06 - RussellDS - CR21280
	;	     Added check in FILE section to make sure Q reference
	;	     exists, otherwise trigger an error.  This can happen when
	;	     an invalid query syntax is used, e.g., ABC(,,,), where
	;	     the commas are interpreted as query separators.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-2003 revision history.
	;
	; 03/26/03 - Pete Chenard - 49451
	;	     Fixed bug relating to queries that use <<>> syntax.
	;---------------------------------------------------------------------
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;
	N INPUTX
	I $G(NI) K Q(NI)			; *** BC - 05/26/94
	;					; Add $G checking to avoid		
A	;					; <UNDEF> error
	I X?." " S X="" Q			; Change blanks to NULL
	I X?." "1"&<<".E Q
	I "*"[X!($$UPPER^UCGMR(X)="ALL") Q	;rhj $TR replaced
	;
	I X["*" D  I $G(ER) Q			; 05/03/93 BC
	.	I X["<<*" Q
	.       I ($P(X,"*",1)'[""""!($P(X,"*",2,99)'["""")) S ER=1,RM=$$^MSG(1475) Q    ; XUS 07/26/94 
	S:'$D(NI) NI=$O(Q(""),-1)+1
	;
	N WRD,I,D,addexpr,paran,litptr,lstypobj,object,qryseq,typobj,wrdptr,z
	;
	I '$D(%MSKD) D INIT^%ZM()			; Initialize Masks
	;
	F  Q:" "'[$E(X,$L(X))  S X=$E(X,1,$L(X)-1)	; Remove trailing " "
	;
	I $E(X,$L(X))=";" S Q(0,0)=$G(Q(0,0))_$E(X,1,$L(X)-1) Q
	I $D(Q(0,0)) S INPUTX=X,X=Q(0,0)_X K Q(0,0)	; Concatenate Previous
	;						; *** 12/01/94 BC
	S ER=0,wrdptr=0,litptr=0,object=3
	S WRD="",qryseq=$O(Q(NI,""),-1)+1,(lstypobj,typobj)=""
	F I=0,1,2,3,4,5,6 S D(I)=""
	;
	F  S WRD=$$PARSE(.X,.wrdptr) D COMPILE(.WRD) Q:ER!(wrdptr=$L(X))
	I 'ER D FILE
	I $D(INPUTX) S X=INPUTX				; Put X Back
	I ER K Q(NI) Q
	I $G(vdsp) D DISPLAY
	Q
	;
	;-----------------------------------------------------------------------
COMPILE(WRD)	; Compile Xecutable MUMPS code here
	;-----------------------------------------------------------------------
	;
	I WRD="?",wrdptr=$L(X),$G(vkeyb) S %fkey="SEL",X=$E(X,1,$L(X)-1),wrdptr=wrdptr-1 Q
	;
	I WRD=+WRD D LITERAL Q					; Numlit
	I $E(WRD)="""" D LITERAL Q				; Strlit
	;
	I $E(WRD)="{",object=5,D(5)="" D  Q
	.	;
	.	S z=wrdptr
	.	S wrdptr=$F(X,"}",wrdptr)
	.	I 'wrdptr S X=X_"}",wrdptr=$L(X)
	.	E  S wrdptr=wrdptr-1
	.	S D(5)=$E(WRD,2,999)_$E(X,z+1,wrdptr-1)		; *** 09/29/95
	.	I $P(D(5),"(",2)'="" S D(5)=D(5)_","		; ^TMP($J,
	.	I $E(D(5))'="^" S D(5)=":"_D(5)			; :VAR(
	.	S D(5)=D(5)_"#)"				; ^TMP($J,#)
	.	S D(0)="I"					; IN list
	;
	I "+-*/#"[WRD D ADDFRAG(4,WRD) Q			; Aritmetic OP
	I "><=[]"[WRD D ADDFRAG(0,WRD) Q			; Logical OP
	I "&!"[WRD D ADDFRAG(2,WRD) Q				; Boolean sep
	;
	I "()"[WRD D ENDLIT:litptr S D(object)=D(object)_WRD S lstypobj="" Q
	I $E(WRD,1,2)="<<" D VAR Q				; <<VAR>>
	I WRD[".",WRD["_",$TR(WRD,"_")?1A.AN1"."1A.AN D DINAM Q	; Support Underscore character ****
	I WRD["."!(WRD["["),$$FINDINAM^DBSDD(WRD,0)=WRD D DINAM Q  ; Data Item
	I WRD?1"@"1E.E D MACRO S qryseq=$O(Q(NI,""),-1)+1 Q	; @MACRO
	;
	N UPC,P
	S UPC=$$UPPER^UCGMR(WRD)
	;
	I $D(^DBCTL("QWRD","*",UPC)) D  Q
	.	S UPC=$O(^(UPC,0)),P=""
	.	F I=1:1:6 I $D(^(I)),^(I)'="" S P=P_^(I)_" "
	.	S X=$E(X,1,wrdptr)_P_$E(X,wrdptr+1,$L(X))
	;
	S P=$G(^DBCTL("QWRD",0,UPC)) I P="" G CONSTANT
	;
	S typobj=$P(P,"|",2)
	I typobj="" S X=$E(X,1,wrdptr)_" "_$P(P,"|",3)_" "_$E(X,wrdptr+1,$L(X)) Q
	i $P(P,"|",7)'="" S D(6)=$P(P,"|",7)		; Datatype
	D ADDFRAG($P(P,"|",2),$P(P,"|",1)) I ER Q
	I "|"'[$P(P,"|",5,6) D MASK($P(P,"|",5),$P(P,"|",6))
	Q
	;
	;-----------------------------------------------------------------------
ADDFRAG(typobj,val)	; Add section to parse string
	;-----------------------------------------------------------------------
	;
	I litptr D ENDLIT
	;
	I typobj=0 D  Q					; = < > [ ] ?
	.	;
	.	I D(0)'="" D  Q
	..		I val'=D(0) S addexpr=val Q	; =<  <>  => ...
	..		D ERROR() Q
	.	;
	.	I $E(val)="'" S D(1)="'",val=$E(val,2)	; '<  '>  '=
	.       ; Expression is before relational operator 
	.       I object=5 D ERROR($$^MSG(8033)) Q 
	.	S D(0)=val,object=5,lstypobj=0
	.	I qryseq>1,D(6)="" S D(6)=$P(Q(NI,qryseq-1),"|",6)
	.	I val="?" S D(5)=$$PARSE(.X,.wrdptr),lstypobj=5	; ?Pattern
	.	I "[]?"[val S:"TUF"'[D(6) D(6)="T" Q	; Force strlit type
	;
	I typobj=1 DO  Q				; '
	.	I wrdptr=$L(X) D ERROR() Q
	.	I D(1)="'" S D(1)="" Q			; '' (double negative)
	.	S D(1)=D(1)_val Q	
	;
	I typobj=2 D  Q					; ! & ,
	.	;
	.	I D(3)="",qryseq=1 D ERROR() Q
	.	S D(2)=val
	.	D FILE
	.	S qryseq=qryseq+1
	.	F I=0,1,2,3,4,5,6 S D(I)=""
	.	S object=3,lstypobj=""
	;
	I typobj=4 D  Q					; Arithmetic operator
	.	;
	.	I lstypobj=4 D ERROR() Q
	.	I D(object)=""&("+-"'[val) D ERROR() Q
	.	S:"TUFL"[D(6) D(6)="N"
	.	I WRD="%" D PCNT Q
	.	S D(object)=D(object)_val
	.	S lstypobj=4
	;
	I typobj=6 D FUNCTION Q
	Q
	;
	;-----------------------------------------------------------------------
CONSTANT	; Word is not in the table Should be a constant
	;-----------------------------------------------------------------------
	;
	I $F("|IS|THE","|"_UPC_"|") Q
	;
	I UPC?1A.AN!(UPC?1"%"1A.AN),'litptr,$$ISDINAM(.UPC) D DINAM Q
	;
	;-----------------------------------------------------------------------
LITERAL	; Object is a string or numeric literal
	;-----------------------------------------------------------------------
	;
	I lstypobj=4 S D(object)=D(object)_+WRD,lstypobj=object Q
	;
	; If the object is a Data_Item or <<>> then this must be the subject
	I object=3,D(object)[$C(1) S object=5
	;
	I D(6)="",$D(Q(NI,qryseq-1)) S D(6)=$P(Q(NI,qryseq-1),"|",6)
	;
	I D(6)'="","LN$CD"[D(6),$E(WRD)'="""" D
	.	I lstypobj=object!litptr D ERROR() Q
	.	I "LDC"[D(6) D CONVERT I ER Q
	.	S WRD=+WRD
	;
	I D(6)="U" S WRD=$$UPPER^UCGMR(WRD)			; Convert Upper
	;
	I WRD=+WRD!($E(WRD)=""""&$E(WRD,$L(WRD))="""") D  Q
	.	I lstypobj=object!litptr D ERROR() Q
	.	S D(object)=WRD,lstypobj=object
	;
	S lstypobj=object
	I 'litptr S litptr=wrdptr-$L(WRD)+1
	Q
	;
	;-----------------------------------------------------------------------
ENDLIT	; End of Literal String
	;-----------------------------------------------------------------------
	;
	N lit
	S lit=$E(X,litptr,wrdptr-$L(WRD))
	F  Q:$E(lit,$L(lit))'=" "  S lit=$E(lit,1,$L(lit)-1)
	I $E(lit)'="""" S lit=""""_lit
	I $E(lit,$L(lit))'="""" S lit=lit_""""
	S D(object)=D(object)_lit,litptr=0
	Q
	;
	;-----------------------------------------------------------------------
MASK(words,replac)	; Replace first occurrance of word with replac
	;-----------------------------------------------------------------------
	;
	Q:wrdptr=$L(X)
	;
	I '$D(INPUTX) S INPUTX=X			; Save original X
	;
	I words="" S X=$E(X,1,wrdptr)_" "_replac_" "_$E(X,wrdptr+1,$L(X)) Q
	;
	N ptr,WRD,z
	;
	S ptr=wrdptr
	F  S WRD=$$PARSE(X,.ptr) D  Q:ptr=$L(X)!(words="")
	.	;
	.	S WRD=$$UPPER^UCGMR(WRD)
	.	F I=1:1:$L(words,",") S z=$P(words,",",I) I z=WRD D  Q
	..	S X=$E(X,1,ptr-$L(z))_replac_$E(X,ptr+1,$L(X)),words=""
	Q
	;
	;-----------------------------------------------------------------------
ISDINAM(di)	; Find out if Keyword is a naked Data Item
	;-----------------------------------------------------------------------
	;
	I $G(FILES)="" Q ""
	;
	N PFID,I,z
	;
	F I=1:1:$L(FILES,",") I $$VER^DBSDD($P(FILES,",",I)_"."_di) Q
	I  S WRD=$P(FILES,",",I)_"."_di Q 1
	Q 0
	;
	;-----------------------------------------------------------------------
DINAM	; Data item syntax
	;-----------------------------------------------------------------------
	;
	I object=3,D(3)'="",4'[lstypobj S object=5
	S WRD=$$DDREF(WRD,.z) Q:ER
	;
	;-----------------------------------------------------------------------
DATA	;
	;-----------------------------------------------------------------------
	;
	S typobj=object
	I object=3,D(6)="" S D(6)=$P(z,"|",9)				; Data Type
	I D(typobj)'="",4'[lstypobj D ERROR() Q
	S D(typobj)=D(typobj)_WRD
	S lstypobj=typobj
	Q
	;
	;-----------------------------------------------------------------------
DDREF(ddref,z)	; Return Dictionary Reference and mask if required
	;-----------------------------------------------------------------------
	;
	S z=$$DI^DBSDD(.ddref,"",.vdd) I ER D ERROR($P(RM,":",1)) Q ""
	;
	Q $C(1)_ddref_$C(1)
	;
	;-----------------------------------------------------------------------
PARSE(STR,ptr)	; Get the next word part
	;-----------------------------------------------------------------------
	;
	N Y,z,zop,savptr,FRAG
	;
	S zop=$E(STR,ptr)			; Last operator *** 11/07/97
	F ptr=ptr+1:1 Q:$E(STR,ptr)'=" "
	S Y=ptr
	;
	F  S Y=$F(STR," ",Y) Q:'Y  I $L($E(STR,ptr,Y-1),"""")#2 Q
	S Y=$S(Y=0:$L(STR),1:Y-2)
	;
	S FRAG=$E(STR,ptr,Y)
	;
	I zop="?" S ptr=Y Q FRAG		; MUMPS pattern check
	I FRAG=+FRAG S ptr=Y Q FRAG
	I $L(FRAG,"""")=3,$E(FRAG)="""",$E(FRAG,$L(FRAG))="""" S ptr=Y Q FRAG
	I FRAG?.AN S ptr=Y Q FRAG
	;
	S savptr=ptr
	F ptr=ptr:1:Y S z=$E(STR,ptr) I "%?+-=[],/\!&*#()<>'"[z,$$KEYWRD Q
	I  I savptr<ptr S ptr=ptr-1
	Q $E(STR,savptr,ptr)
	;
KEYWRD()	; Look for special syntaxes or mask 
	; 
	I ptr=$L(STR),z'=")" Q 0 
	I z="#",$G(D(6))="T" Q 0        ; *** BC - Skip invalid # or / operation 
	I z="/",$G(D(6))="T" Q 0        ; *** 
	I z="[",$E(STR,ptr+1,$L(STR))["]" S ptr=$F(STR,"]",ptr) Q 0 
	I z="%",$E(STR,ptr+1)?1A Q 0                    ; %VAR 
	I $G(vqrymsk)[z Q 0 
	I z'="<" Q 1 
	I $E(STR,ptr+1)'="<"!($E(STR,ptr+2)="<") Q 1 
	; *** DSR patch - replace next line with structure DO 
	; *** to account for variable insertion in << >> prompt syntax 
	;I savptr=ptr S ptr=$F(STR,">>",ptr) S:'ptr ptr=savptr 
	I savptr=ptr D 
	.       N done,xstr 
	.       S done=0 
	.       ; Get next >> until equal number of << and >> 
	.       F  s ptr=$F(STR,">>",ptr)  Q:'ptr  D  Q:done 
	..              S xstr=$E(STR,savptr,ptr-1) 
	..              I $L(xstr,"<<")=$L(xstr,">>") S done=1 
	.       I 'ptr s ptr=savptr 
	Q 1 
	;
	;-----------------------------------------------------------------------
SYNTAX	;
	;-----------------------------------------------------------------------
	;
	I $F("|IS|THE","|"_WRD_"|") Q
	S WRD=""""_WRD_""""
	Q
	;
	;-----------------------------------------------------------------------
MACRO	; Compile MACRO code
	;-----------------------------------------------------------------------
	;
	N macro
	S macro=$E(WRD,2,$L(WRD))
	;
	; Macro name doesn't exist 
	I '$D(^DBTBL(%LIBS,4,macro)) D ERROR($$^MSG(1397)) Q 
	; 
	; Illegal use of a Macro 
	I (D(1)_D(2)_D(4)_D(5))'=""!($TR(D(3),"(","")'="") D ERROR($$^MSG(1397)) Q 
	; 
	F  S WRD=$$PARSE(.X,.wrdptr) Q:WRD'=")"  S D(5)=D(5)_")"
	;
	I "!&"'[WRD S WRD=$P($G(^DBCTL("QWRD",0,WRD)),"|",1) I WRD'="!"&(WRD'="&") D ERROR() Q
	;
	N libs,I,savseq,X
	;
	S libs=$G(^(macro,-3)) I libs="" S libs=%LIBS
	;
	S savseq=$O(Q(NI,""),-1)+1			; Save Sequence
	;
	F I=1:1 S X=$G(^DBTBL(libs,4,macro,I)) Q:X=""  D A Q:ER
	;
	I ER!'$D(Q(NI,savseq)) Q			; ??? Problem
	;
	S Q(NI,savseq)="("_D(3)_Q(NI,savseq),D(3)=""
	;
	S savseq=$O(Q(NI,""),-1)				; Get last seq
	S $P(Q(NI,savseq),"|",2)=$P(Q(NI,savseq),"|",2)_D(5)_")",D(5)=""
	S $P(Q(NI,savseq),"|",5)=WRD
	Q
	;
	;-----------------------------------------------------------------------
VAR	; Variable insertion syntax
	;-----------------------------------------------------------------------
	;
	I $F(WRD,"<<*",1) D  Q
	.       ; Invalid variable syntax 
	.       I $D(QEXT) D ERROR($$^MSG(1475)) Q 
	.	S par=$p($P(WRD,"<<*",2,99),">>",1)
	.	I $E(par)="*" S par=$E(par,2,$L(par))
	.	I par'="" D KEYWRDL(par) I ER D ERROR(RM) Q
	.	S (lstypobj,object)=5,D(5)=WRD
	;
	;S WRD=$E(WRD,3,$L(WRD)-2)
	;
	I D(6)="" S D(6)="T"
	;
	N ptr,ddref
	;
	F  S ddref=$$FINDINAM^DBSDD(WRD,.ptr) Q:ddref=""  D
	.	;
	.	N ddexpr
	.	S ddexpr=ddref
	.	I '$$VER^DBSDD(.ddexpr) Q
	.	S WRD=$P(WRD,ddref,1)_$C(1)_ddexpr_$C(1)_$P(WRD,ddref,2,999)
	.	S ptr=ptr+2+$L(ddexpr)-$L(ddref)
	;
	F  Q:WRD'["""|"""  S WRD=$P(WRD,"""|""",1)_"$C(124)"_$P(WRD,"""|""",2,99)
	D DATA Q
	;
	;-----------------------------------------------------------------------
CONVERT	; Convert external data format to internal format
	;-----------------------------------------------------------------------
	;
	I D(6)="D" S WRD=$$DATE
	I D(6)="C" S WRD=$$TIME
	;
	N z
	S z=$$INTYP^DBSCRT8(WRD,D(6))
	I ER D ERROR($$TYPERR^DBSCRT8(D(6))) Q
	S WRD=z
	Q
	;
	;-----------------------------------------------------------------------
DATE()	; D(6)="D" - Data data type
	;-----------------------------------------------------------------------
	;
	I WRD?5N Q WRD
	;
	N savptr
	S savptr=wrdptr				; Check for OR condition
	D					; *** 08/01/95 BC
	.	I $E(X,wrdptr,999)["," S wrdptr=$F(X,",",wrdptr)-2 Q  ; [fid]di=date1,date2,...
	.	I X["!" S wrdptr=$F(X,"!",wrdptr)-2 Q  ; [fid]di=date1,date2,...
	.	S wrdptr=$F(X," ",wrdptr)-2 	       ; [fid[di=date1 OR date2
	I wrdptr<0 S wrdptr=$L(X)		       ; [fid]di=date1
	Q WRD_$E(X,savptr+1,wrdptr)
	;
	;-----------------------------------------------------------------------
TIME()	; D(6)="C" - Time data type
	;-----------------------------------------------------------------------
	;
	I "AMPM"[$$UPPER^UCGMR($E(X,wrdptr+2,wrdptr+3)) S WRD=WRD_$E(X,wrdptr+1,wrdptr+3),wrdptr=wrdptr+3
	Q WRD
	;
	;-----------------------------------------------------------------------
ERROR(M)	; Input order syntax error
	;-----------------------------------------------------------------------
	;
	N num
	; Invalid Syntax 
	I $G(M)="" S M=$$^MSG(1477) 
	;
	S ER=1
	S M=$J("",wrdptr-$L(WRD))_"^"_$TR($J("",$L(WRD)-1)," ","-")_M
	;
	S num=1,RM(1)=$E(X,1,80)_"|22000"
	I $L(X)>80 F num=2:1 S RM(num)=$E(X,num*80-79,num*80) I $E(X,num*80+1)="" Q
	S num=num+1,RM(num)=$E(M,1,80)_"|23000"
	I $L(M)>80 N z F z=2:1 S num=num+1,RM(num)=$E(M,z*80-79,z*80) I $E(M,z*80+1)="" Q
	;
	I num>2 N I F I=1:1:num S $P(RM(I),"|",2)=(23-(num-I)*1000)
	Q
	;
	;-----------------------------------------------------------------------
HELP	; Interactive HELP for query building
	;-----------------------------------------------------------------------
	;
	N tbl,typ,recsiz,dft,min,max,hlp,vptr
	;
	S dft=X
	I D(3)'[$C(1),$D(FILES) D
	.	S D(3)=$TR(D(3),"""",""),dft=$E(X,1,$L(X)-$L(D(3))),X=D(3)
	.	S tbl="@SELDI^DBSFUN(FILES,X)",vptr=1
	;
	; *** BC - 05/03/94 - Replaced :MUMPS with :QUERY syntax
	;
	E  I D(0)="" S tbl="[DBCTLQRY]:QU ""[DBCTLQRY]QSYM=0""",vptr=""
	E  I D(3)[$C(1)  S tbl=$$TBL^DBSDD($P(D(3),$C(1),2),"",.vdd),vptr=""
	;
	I $G(tbl)="" Q
	;
	S typ="T",recsiz=80,min="",max="",hlp=""
	S X=dft_$$TBL^DBSCRT(X),V=X,NI=NI-1
	Q
	;
	;-----------------------------------------------------------------------
EXT	; External linecall %TAB array is defined (need operation and object)
	;-----------------------------------------------------------------------
	;
	K Q(NI),RM
	N INPUTX,OLDTBL
	S OLDTBL=I(3)					; Save look-up table
	;
	I "*"[X!($$UPPER^UCGMR(X)="ALL") S:X=""&(E67>2) X="ALL" S I(3)="" Q
	;
	; <<**>> syntax with look-up table entry
	;
	I X'?.AN,$D(I(3)),I(3)'="" S I(3)=""		; Skip table checking
	;
	S QEXT=$P(%TAB(NI),"|",3)
	S INPUTX=X,X=QEXT_" "_X		; *** - BC - Keep [LIB,FID]DI format
	I $E(QEXT)="[" S QEXT=$E($TR(QEXT,",]",".."),2,99)
	D A						; Parse query syntax
	I $G(ER) S I(3)=OLDTBL				; Restore look-up table
	Q
	;
	;-----------------------------------------------------------------------
FILE	; File D(array) into Q(NI,qryseq)
	;-----------------------------------------------------------------------
	;
	I litptr S WRD="" D ENDLIT
	I D(0)="",D(3)="",D(5)="" Q
	; 
	I $G(vkeyb),(%fkey="SEL") D HELP Q
	;
	I D(0)="",D(5)'["<<**" D  Q:ER
	.	I qryseq=1 S D(0)="=" Q			; Default operator =
	.	; Invalid syntax
	.	I '$D(Q(NI,qryseq-1)) D ERROR($$^MSG(1475)) Q
	.	S D(0)=$P(Q(NI,qryseq-1),"|",4)
	.	I D(5)="" S D(5)=D(3),D(3)=""
	;
	I D(3)="",qryseq>1 D				; Repeat Previous
	.	; Invalid syntax
	.	I '$D(Q(NI,qryseq-1)) D ERROR($$^MSG(1475)) Q
	.	S D(3)=$P(Q(NI,qryseq-1),"|",1)		; Subject expression
	.	S D(6)=$P(Q(NI,qryseq-1),"|",6)		; Data Type
	.	I $E(D(3))="(" S D(3)=$E(D(3),$$COUNTP(D(3))+1,$L(D(3)))
	;
	S WRD=""
	;
	; 
	; Missing Subject 
	I D(3)="" D ERROR($$^MSG(8041)) Q 
	; Missing Expression 
	I D(5)="" D ERROR($$^MSG(8040)) Q 
	;
	I D(1)="'",$E(D(0))="'" S D(1)=""	; *** - BC - 12/29/93
	S Q(NI,qryseq)=D(3)_"|"_D(5)_"||"_D(1)_D(0)_"|"_D(2)_"|"_D(6)
	;
	I $D(vxt) S $P(Q(NI,qryseq),"|",7)=vxt
	;
	I $G(addexpr)'="" D
	.	N z
	.	S z="("_Q(NI,qryseq),D(5)=D(5)_")"
	.	S $P(z,"|",5)="!",Q(NI,qryseq)=z
	.	S D(0)=addexpr,addexpr="",qryseq=qryseq+1
	.	D FILE
	Q
	;
	;-----------------------------------------------------------------------
FUNCTION	; $Function input verification
	;-----------------------------------------------------------------------
	;
	S wrdptr=wrdptr+1
	; Left parenthesis expected 
	I $E(X,wrdptr)'="(" D ERROR($$^MSG(7079)) Q 
	;
	N expr,fnam,pcnt,savobj,listpars,valpar,inptlist,numpars,parnum,nampar,rpar,ptr
	;
	S savobj=D(object),D(object)=""
	S pcnt=1,listpars="",inptlist="",numpars=0
	;
	S fnam=$P(P,"|",1)
	I fnam'["(" S fnam=fnam_"(1/REQ"_$S(fnam="$P":",DELIMETER/REQ,FROM/TYP=N,TO/TYP=N",fnam="$E":",FROM/TYP=N,TO/TYP=N",fnam="$L":",VALUE",1:"")_")"
	;
	F I=$L(fnam,"("):-1:1 S z=$P(fnam,"(",I,999) Q:$L(z,"""")#2
	;
	S fnam=$P(fnam,"(",1,I-1)_"("
	;
	F I=1:1:$L(z,",") D
	.	;
	.	S nampar=$P(z,",",I)
	.	I $E(nampar)=""""!'($L($P(z,",",numpars+1,I),"""")#2) Q
	.	S rpar="" I nampar[")" S rpar=")"_$P(nampar,")",2,999),nampar=$P(nampar,")",1)
	.	I $P(nampar,"/",1)?.N S nampar=nampar_"/NOQWT"	; Don't quote arqmnt
	.	S numpars=numpars+1,$P(listpars,",",numpars)=nampar
	.	S $P(z,",",I)=$C(0)_rpar			; Mark loction of par
	;
	S fnam=fnam_z
	;
	F  S WRD=$$PARSE(.X,.wrdptr) D  Q:pcnt=0!ER!(wrdptr=$L(X))
	.	;
	.	I WRD="(" S pcnt=pcnt+1,lstypobj=4,D(object)=D(object)_"(" Q
	.	I WRD=")" S pcnt=pcnt-1 D ENDLIT:litptr S inptlist=D(object),D(object)="" Q
	.	I WRD="," S inptlist=$$GETPAR(.X,.wrdptr,",",numpars) Q
	.	I WRD="/" S inptlist=$$GETPAR(.X,.wrdptr,"/",numpars) Q
	.	D COMPILE(.WRD)
	;
	I ER Q
	; Right parenthesis expected 
	I pcnt D ERROR($$^MSG(8042)) Q 
	;
	I inptlist="" S inptlist=D(object)
	;
	I listpars'="" D
	.	;
	.	N CMD,tree
	.	S CMD("Z")="("_listpars_")"
	.	; DSR NOTE - modify to pass .CMD() array
	.	D ^DBSINT("Z "_inptlist,"CMD(")
	.	I ER  D  Q
	..		S z=$G(RM(2))
	..		S WRD=$J("",$L(inptlist)-$F(z,"^"))
	..		K RM D ERROR($P(z,"^",2)) Q
	.	;
	.	S inptlist=$P($E(tree(1),1,$L(tree(1))-1),"(",2,999)
	.	F  Q:$E(inptlist,$L(inptlist)-2,$L(inptlist))'=","""""  S inptlist=$E(inptlist,1,$L(inptlist)-3),numpars=numpars-1
	;
	I ER Q
	;
	S ptr=1
	F parnum=1:1:numpars D					; Insert parameters
	.	;
	.	S nampar=$P(listpars,",",parnum)
	.	S valpar=$P(inptlist,",",ptr) I valpar="" S valpar=""""""
	.	I $L(valpar,"""")#2=0 F ptr=ptr+1:1:$L(inptlist,",") S valpar=valpar_","_$P(inptlist,",",ptr) Q:$L(valpar,"""")#2
	.	I valpar["(" S pcnt=$L(valpar,"(")-$L(valpar,")") I pcnt D
	..		;
	..		I valpar["""" S pcnt=$$COUNTP(valpar)	; Strict count
	..		F ptr=ptr+1:1:$L(inptlist,",") S z=$P(inptlist,",",ptr) D  Q:'pcnt
	...			;
	...			S valpar=valpar_","_z
	...			I $L(valpar,"""")#2=0 Q		; Inside Quotes
	...			S pcnt=pcnt+$L(z,"(")-$L(z,")")
	.	;
	.	S fnam=$P(fnam,$C(0),1)_valpar_$P(fnam,$C(0),2,99)
	.	S ptr=ptr+1 I ptr>$L(inptlist,",") S parnum=numpars+1
	;
	I fnam[$C(0) F  S y=$F(fnam,$C(0),1) Q:y=0  D		; Null parameters
	.	;
	.	I $E(fnam,y)="," S fnam=$E(fnam,1,y-2)_$E(fnam,y+1,$L(fnam)) Q
	.	I $E(fnam,y-2)="," S fnam=$E(fnam,1,y-3)_$E(fnam,y,$L(fnam)) Q
	;
	S D(object)=savobj_fnam
	Q
	;
	;-----------------------------------------------------------------------
GETPAR(str,wrdptr,delim,numpar)	; Return Parameters
	;-----------------------------------------------------------------------
	;
	N y,valpar,nampar,valarg,z
	;
	I litptr D ENDLIT
	S y=wrdptr+1,valarg=D(object),D(object)=""
	;
	F  S y=$F(str,")",y) Q:'y!($L($E(str,wrdptr,y-1),"""")#2)
	;
	; Right parenthesis expected 
	I y=0 S wrdptr=$L(str) D ERROR($$^MSG(8042)) Q "" 
	;	
	S expr=$E(str,wrdptr+1,y-2),wrdptr=y-1,pcnt=pcnt-1
	;
	I delim="," S parnum=2,z=expr,expr="" F I=1:1:$L(z,",") D   Q:ER
	.	;
	.	S nampar=$P($P(listpars,",",parnum),"/",1)
	.	S valpar=$P(z,",",I) I valpar="" Q:nampar=""  S valpar=""""""
	.       ; Unexpected parameter 
	.       I nampar="" D ERROR($$^MSG(2814)) Q 
	.	I $L(valpar,"""")#2=0 F I=I+1:1:$L(z,",") S valpar=valpar_","_$P(z,",",I) Q:$L(valpar,"""")#2
	.	E  I nampar["/NOQWT" D VARPAR Q:ER
	.	S expr=expr_"/"_nampar_"="_valpar,parnum=parnum+1
	;
	I expr'="",$E(expr)'="/" S expr="/"_expr
	I $L(expr,"/")-1'>numpar Q valarg_expr
	;
	N cntpar
	S cntpar=1,y=1
	F  S y=$F(expr,"/",y) Q:y=0  I $L($E(expr,1,y-1),"""") S cntpar=cntpar+1
	; Too many parameters 
	I cntpar>numpar D ERROR($$^MSG(8043)) Q "" 
	Q valarg_expr
	;
	;-----------------------------------------------------------------------
VARPAR	; Variable parameters enabled
	;-----------------------------------------------------------------------
	;
	I valpar["."!(valpar["["),$$FINDINAM^DBSDD(valpar,0)=valpar S valpar=$$DDREF(valpar) Q
	I valpar?1"<<"1E.E1">>" S valpar=$e(valpar,3,$L(valpar)-2) Q
	N WRD
	S WRD=valpar I $$ISDINAM(WRD) S valpar=WRD Q
	S valpar=""""_valpar_""""
	Q
	;-----------------------------------------------------------------------
DISPLAY	; Display formatted message at the bottom of the screen (This NI)
	;-----------------------------------------------------------------------
	;
	N num,seq,z
	S num=1,RM(num)=""
	;
	F seq=1:1 S z=$G(Q(NI,seq)) Q:z=""  DO
	.	S x=$$QRYTEXT(z)
	.	I $L(RM(num))+$L(x)>79 S num=num+1,RM(num)=x Q	; message
	.	S RM(num)=RM(num)_" "_x
	;
	I $D(RM)>1 F I=1:1:num D
	.	S z=23-(num-I)*1000
	.	I $G(OLNTB)>0,z<OLNTB K RM(I) Q		; *** 12/01/94
	.	S RM(I)=RM(I)_"|"_z			; No room for message
	Q
	;-----------------------------------------------------------------------
QRYQD(Q,QD)	; Public ; Create QD() array based on original Q(NI,SEQ) array
	;-----------------------------------------------------------------------
	;
	;  ARGUMENTS:
	;
	;	. Q	Input array			/TYP=T/REQ/MECH=REFNAM:R
	;	. QD	Output array			/TYP=T/REQ/MECH=REFNAM:W
	;
	;-----------------------------------------------------------------------
	;
	N ni,seq,z
	;
	K QD
	S ni="" F  S ni=$O(Q(ni)) Q:ni=""  S seq="" F  S seq=$O(Q(ni,seq)) Q:seq=""  DO
	.	;
	.	S z=Q(ni,seq),QD(ni,seq)=$$QRYTEXT(z)
	Q
	;-----------------------------------------------------------------------
QRYTEXT(z)	; Public ; Convert query into text messages
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;	. z  Query Input (fid.di|...)		/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;
	;       . $$ Query Description			/TYP=T/MECH=VAL
	;
	;-----------------------------------------------------------------------
	;
	N x,obj,sub,op,and,typ,I
	;
	S obj=$P(z,"|",1),sub=$P(z,"|",2),op=$P(z,"|",4),and=$P(z,"|",5),typ=$P(z,"|",6)
	S obj=$$EXP(obj),sub=$$EXP(sub)
	I op'="" D
	.	I op="''=" S op="="			; 04/14/93 BC
	.	S op=$P(^DBCTL("QWRD",0,op),"|",3)	; 
	;
	F I=1,2 S zz=$$EXP($P(z,"|",I)) I "DC"[$P(z,"|",6)
	;
	I "LDC"[typ D
	.	I obj=+obj S obj=$$EXTYP^DBSCRT8(obj,typ,"")
	.	I sub=+sub S sub=$$EXTYP^DBSCRT8(sub,typ,"")
	;
	S x=obj_" "_op_" "_sub
	I and'="" S x=x_" "_$P(^DBCTL("QWRD",0,and),"|",3)
	Q x
	;
D	
	;-----------------------------------------------------------------------
EXP(X)	; Replace data Item names with dictionary reference
	;-----------------------------------------------------------------------
	;
	F  Q:$P(X,$C(1),2)=""  S X=$P(X,$C(1),1)_$$DES^DBSDD($P(X,$C(1),2),"",.vdd)_$P(X,$C(1),3,999)
	Q X
	;
	;-----------------------------------------------------------------------
PCNT	; Percentage
	;-----------------------------------------------------------------------
	;
	N z,op,val,I,savptr
	;
	S z=D(object)
	F I=$L(z):-1:0 Q:"+-*/\#"[$E(z,I)
	;
	S val=$E(z,I+1,999),op=$E(z,I),D(object)=$E(z,1,I-1)
	I val?.N S val=val/100
	E  S:op="" op="-" I "+-"[op S val="("_op_val_"/100+1)",op="*"
	;
	S savptr=wrdptr,z=$$PARSE(X,.wrdptr)
	;
	I $$UPPER^UCGMR(z)="OF" D  Q:ER  S D(object)=D(object)_val_"*",lstypobj=4 Q
	.	;
	.	S z=$$PARSE(.X,wrdptr)
	.	I z?.N!(z?.N1".".N) Q
	.	I z?1"["1AN.E1"]"1AN.AN Q
	.	I z?1"<<".E1">>" Q
	.	I z=")" Q
	.	I z'="",$D(%UID),$D(^DBCTL("QWRD",%UID,z)) Q
	.	I z'="",$D(^DBCTL("QWRD","*",z)) Q
	.       ; Invalid percentage 
	.       D ERROR($$^MSG(5324)) Q 
	; 
	; Invalid percentage 
	I I=0 D ERROR($$^MSG(5324)) Q 
	;
	S wrdptr=savptr,lstypobj=object
	I "+-"[op S D(object)=D(object)_"*"_(1+$S(op="+":val,1:-val)) Q
	S D(object)=D(object)_op_val
	Q
	;
	;
	;----------------------------------------------------------------------
KEYWRDL(z)	; Check for keyword in list
	;----------------------------------------------------------------------
	;
	N list,pnum
	S list=",LENGTH/TYP=N/MAX=255,DEFAULT/NOQWT,HELP,TABLE,PATTERN,POST,PRE,FORMAT,PROMPT,REQUIRED/TYP=L,MINIMUM,MAXIMUM,DECIMAL/TYP=N,SUPPRESS,QRYPOS,TBL"
	;
	F I=2:1:$L(z,"/") D  Q:ER
	.	;
	.	S expr=$P(z,"/",I)
	.	I $L(expr,"""")#2=0 F I=I+1:1:$L(z,"/") S expr=expr_"/"_$P(z,"/",I) Q:$L(expr,"""")#2
	.	S pnum=$$PAR(.expr,list) Q:ER
	.	;
	.	I pnum=12!(pnum=13) I expr?1A.AN.E!(expr?1"%".AN.E) S expr="<<"_expr_">>"
	.	I pnum=17 S pnum=5
	Q
	;
	;----------------------------------------------------------------------
PAR(expr,list)	; Check for parameter and expression in PAR List
	;----------------------------------------------------------------------
	;
	N paramnum,y,chklist
	;
	S par=$$UPPER^%ZFUNC($P(expr,"=",1))
	S expr=$P(expr,"=",2,99)
	;
	F  Q:$E(expr,$L(expr))'=" "  S expr=$E(expr,1,$L(expr)-1)
	;
	I $E(par,1,2)="NO",expr="" S par=$E(par,3,$L(par))
	;
	; Invalid qualifier - ~p1
	S y=$F(list,","_par) I 'y S ER=1,RM=$$^MSG(1430,par) Q ""
	; Ambiguous qualifier - ~p1
	I $F(list,(","_par),y) S ER=1,RM=$$^MSG(255,par) Q ""
	;
	S paramnum=$L($E(list,1,y-1),",")
	S chklist=$P($P($E(list,y,$L(list)),",",1),"/",2,99) 
	;
	I chklist'["NOQWT",$E(expr)="""",$E(expr,$L(expr))="""" S expr=$E(expr,2,$L(expr)-1) I expr["""" D
	.	N y S y=0
	.	F  S y=$F(expr,"""",y) Q:'y  S expr=$E(expr,1,y-2)_$E(expr,y,$L(expr))
	; DSR NOTE - MOVE VALUERR^DBSINT CODE HERE
	I chklist'="" S chklist="/"_chklist N ET S ET=$$VALUERR^DBSINT(.expr) I ET'="" S ER=1,RM=ET_", "_par_"="_expr Q "" 
	Q paramnum
	;
	;--------------------------------------------------------------------
COUNTP(X)	; Count number of () in X and keep return net value
	;--------------------------------------------------------------------
	;
	N y,z
	;
	S z=0,y=0
	F  S y=$F(X,"(",y) Q:y=0  I $L($E(X,1,y-1),"""")#2 S z=z+1
	F  S y=$F(X,")",y) Q:y=0  I $L($E(X,1,y-1),"""")#2 S z=z-1
	;
	I z,X["<<*",X[">>" S X=$P($P(X,"<<*",2),">>",1),z=z-$L(X,"(")+$L(X,")")
	Q z
	;
	;----------------------------------------------------------------------
QA	; Quick QA/Test query parser
	;----------------------------------------------------------------------
	N (%LIBS)
	S X="[DEP]BOO=""""" D QA1
	S X="[DEP]BOO=0" D QA1
	S X="+[DEP]BOO=0" D QA1
	S X="[DEP]BOO>100" D QA1
	S X="[DEP]BOO<100" D QA1
	S X="[DEP]BOO'>100" D QA1
	S X="[DEP]BOO'<100" D QA1
	S X="[DEP]BOO=1,2" D QA1
	Q
QA1	;
	N (%LIBS,X)
	W !,X,!				; Display original query syntax
	D ^DBSQRY			; Convert to Q() array format
	ZWR Q
